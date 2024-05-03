library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use work.config.all;

	--uses 6 cycles.
	--can take input every 2nd cycle.

	--ALPHA, beta to dq
entity park_transform is
	generic(
		theta_width	: integer := work.config.angle_bitdepth;
		lut_th_width : integer := work.config.sin_lut_length_bits;
		sin_width	: integer := work.config.sin_angle_bits;
		input_width	: integer := work.config.alpha_beta_domain_bits;
		output_width	: integer := work.config.dq_domain_bits
	);
	port(
		en_str		: in STD_LOGIC;
		clk,rst		: in STD_LOGIC;
		alpha,beta	: in STD_LOGIC_VECTOR(input_width-1 downto 0);
		theta		: in STD_LOGIC_VECTOR(theta_width-1 downto 0);
		d,q		: out STD_LOGIC_VECTOR(output_width-1 downto 0);
		en_out		: out STD_LOGIC;

		--CONNECTIONS TO SIN LUT:
		angle_out	: out unsigned(lut_th_width-1 downto 0);
		angle_out_en	: out std_logic;
		lut_value	: in signed(sin_width-1 downto 0)
	);
end park_transform;

architecture RTL of park_transform is
signal en_reg 		: STD_LOGIC_vector(4 downto 0);
signal cos_angle	: STD_LOGIC_VECTOR(lut_th_width-1 downto 0);
signal sin_value	: signed(lut_value'length-1 downto 0);
signal beta_reg0	: STD_LOGIC_VECTOR(input_width-1  downto 0);
signal alpha_reg0	: STD_LOGIC_VECTOR(input_width-1  downto 0);
signal beta_reg1	: STD_LOGIC_VECTOR(input_width-1 downto 0);
signal alpha_reg1	: STD_LOGIC_VECTOR(input_width-1 downto 0);
signal beta_reg2	: signed(input_width-1 downto 0);
signal alpha_reg2	: signed(input_width-1 downto 0);
constant diff_length : integer := theta_width-lut_th_width;

signal d_internal : STD_LOGIC_VECTOR(d'length-1 downto 0);
signal q_internal : STD_LOGIC_VECTOR(q'length-1 downto 0);

signal d_long		: signed(input_width +lut_value'length-1 downto 0);
signal q_long		: signed(input_width +lut_value'length-1 downto 0);

begin
	process(clk, rst) is --could extend one more cycle if timing problems. cycle 5 would then be the multiplication.
	variable cos_value	: signed(lut_value'length-1 downto 0);
	begin
		if rising_edge(clk) then
			en_reg(en_reg'length-1 downto 1) <= en_reg(en_reg'length-2 downto 0); --shift enable register
			en_reg(0)	<= en_str;
			angle_out_en	<= '0';
			en_out 		<= '0';
			if rst then
				d 	<= (others => '0'); 
				q 	<= (others => '0');
				en_reg 	<= (others => '0');
			else
				if en_str then --cycle 1
					alpha_reg0 <= alpha;
					beta_reg0  <= beta;
					cos_angle <= STD_LOGIC_VECTOR(unsigned(theta(theta'length-1 downto diff_length))); --find the cossine angle. cos(x)=sin(x+90 deg.)
					cos_angle(cos_angle'length-1 downto cos_angle'length-2) <= STD_LOGIC_VECTOR(unsigned(theta(theta'length-1 downto theta'length-2))+1);
					angle_out <= unsigned(theta(theta'length-1 downto diff_length));
					angle_out_en<= '1';

				elsif en_reg(0) then --cycle 2
					angle_out <= unsigned(cos_angle);
					angle_out_en <= '1';
				end if;
				if en_reg(1)  then --cycle 3
					alpha_reg1 <= alpha_reg0;
					beta_reg1  <= beta_reg0;
				end if;
				if en_reg(2) then --cycle 4
					alpha_reg2 	<= signed(alpha_reg1);
					beta_reg2  	<= signed(beta_reg1);
					sin_value	<= lut_value;
				elsif en_reg(3) then --cycle 5
					cos_value := lut_value;
					d_long <= (alpha_reg2*cos_value) + (beta_reg2*sin_value); --q=alpha*c1 + beta*s1
					q_long <= (-alpha_reg2*sin_value) + (beta_reg2*cos_value); --d=-alpha*s1 + beta*c1
				end if;
				if en_reg(4) then
				    d <= STD_LOGIC_VECTOR(resize(d_long(d_long'length-1 downto sin_value'length-1),output_width));
				    q <= STD_LOGIC_VECTOR(resize(q_long(q_long'length-1 downto sin_value'length-1),output_width));
				    en_out <= '1';
				end if;
			end if;
		end if;
	end process;
end architecture RTL;

