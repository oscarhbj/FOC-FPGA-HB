library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use work.config.all;


--DQ to alpha beta.
--uses 6 cycles. can take new input every 2nd cycle.
entity inv_park_transform is
	generic(
		theta_width	: integer := work.config.angle_bitdepth;
		lut_th_width : integer := work.config.sin_lut_length_bits;
		sin_width	: integer := work.config.sin_angle_bits;
		input_width	: integer := work.config.dq_domain_bits;
		output_width	: integer := work.config.alpha_beta_domain_bits
	);
	port(
		clk,en_str,rst	:	in STD_LOGIC;
		theta		: 	in STD_LOGIC_VECTOR(theta_width-1 downto 0);
		d,q		: 	in STD_LOGIC_VECTOR(input_width-1 downto 0);
		alpha,beta	: 	out STD_LOGIC_VECTOR(output_width-1 downto 0);
		en_out		:	out STD_LOGIC;

	--CONNECTIONS TO SIN LUT:
		angle_out	: out unsigned(lut_th_width-1 downto 0);
		angle_out_en	: out std_logic;
		lut_value	: in signed(sin_width-1 downto 0)
	);
end entity;

architecture RTL of inv_park_transform is
    constant diff_length : integer := theta_width-lut_th_width;
	signal en_reg 		: STD_LOGIC_vector(4 downto 0);
	signal cos_angle	: STD_LOGIC_VECTOR(angle_out'length-1 downto 0);
	signal sin_value	: signed(lut_value'length-1 downto 0);
	signal d_reg0		: STD_LOGIC_VECTOR(input_width-1 downto 0);
	signal q_reg0		: STD_LOGIC_VECTOR(input_width-1 downto 0);
	signal d_reg1		: STD_LOGIC_VECTOR(input_width-1 downto 0);
	signal q_reg1		: STD_LOGIC_VECTOR(input_width-1 downto 0);
	signal d_reg2		: signed(input_width-1 downto 0);
	signal q_reg2		: signed(input_width-1 downto 0);
	signal alpha_long,beta_long	: signed(sin_value'length + input_width-1 downto 0);
begin

	process(clk, rst) is --could extend one more cycle if timing problems. cycle 5 would then be the multiplication.
	variable cos_value		: signed(lut_value'length-1 downto 0);
	begin
		if rising_edge(clk) then
			en_reg(en_reg'length-1 downto 1) <= en_reg(en_reg'length-2 downto 0); --shift enable register
			en_reg(0)	<= en_str;
			angle_out_en	<= '0';
			en_out 		<= '0';
			if rst then
				alpha 	<= (others => '0'); 
				beta 	<= (others => '0');
				en_reg 	<= (others => '0');
			else
				if en_str then --cycle 1
					d_reg0	<= d;
					q_reg0 	<= q;
					cos_angle <= STD_LOGIC_VECTOR(resize(unsigned(theta(theta'length-1 downto diff_length)),cos_angle'length)); --find the cossine angle. cos(x)=sin(x+90 deg.)
					cos_angle(cos_angle'length-1 downto cos_angle'length-2) <= STD_LOGIC_VECTOR(unsigned(theta(theta'length-1 downto theta'length-2))+1);
					angle_out <= resize(unsigned(theta(theta'length-1 downto diff_length)),angle_out'length);
					angle_out_en<= '1';

				elsif en_reg(0) then --cycle 2
					angle_out <= unsigned(cos_angle);
					angle_out_en <= '1';
				end if;
				if en_reg(1) then --cycle 3, waiting for sin value
					d_reg1	<= d_reg0;
					q_reg1	<= q_reg0;
				end if;
				if en_reg(2) then --cycle 4
					d_reg2	<= signed(d_reg1);
					q_reg2	<= signed(q_reg1);
					sin_value <= lut_value;
				elsif en_reg(3) then --cycle 5
					cos_value 	:= lut_value;
					alpha_long 	<= (d_reg2*cos_value) - (q_reg2*sin_value); --alpha=d*c1-qs1
					beta_long 	<= (d_reg2*sin_value) + (q_reg2*cos_value); --beta=d*s1+q*c1
				end if;
				if en_reg(4) then
				    alpha 	<= STD_LOGIC_VECTOR(resize(alpha_long(alpha_long'length-1 downto sin_value'length-1),output_width));
				    beta    <= STD_LOGIC_VECTOR(resize(beta_long(beta_long'length-1 downto sin_value'length-1),output_width));
				    en_out <= '1';
				end if;
			end if;
		end if;
	end process;
end architecture;
