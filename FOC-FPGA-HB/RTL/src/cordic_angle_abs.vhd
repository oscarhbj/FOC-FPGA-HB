library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use work.config.all;
	use std.textio.all; --lut
--The cordic algorithm will find the angle and the amplitude of a vector.

entity cordic_angle_abs is
generic(
	lut_angle_width		: integer :=work.config.cordic_lut_width;--16 bits
	input_width		: integer := work.config.alpha_beta_domain_bits;
	angle_width		: integer :=work.config.angle_bitdepth;
	iterations		: integer :=10
);

port(
	clk		: in STD_LOGIC;
	x,y		: in STD_LOGIC_VECTOR(input_width-1 downto 0);
	angle_out	: out STD_LOGIC_VECTOR(angle_width-1 downto 0);
	amplitude_out	: out STD_LOGIC_VECTOR(input_width-1 downto 0);
	en_in		: in STD_LOGIC;
	en_out		: out STD_LOGIC
);
end entity;

Architecture RTL of cordic_angle_abs is
--signals
type 	t_value	is array (iterations downto 0) of signed(input_width+1 downto 0); --one more bit than the input vector.
type 	t_angle	is array (iterations downto 0) of signed(lut_angle_width downto 0); --one more bit for sign.
type 	t_angle_pre	is array (iterations downto 0) of unsigned(lut_angle_width-1 downto 0);
signal x_sign_register		: STD_LOGIC_VECTOR(iterations downto 0);
signal x_register, y_register 	: t_value;
signal angle_register		: t_angle;
signal x_null 			: STD_LOGIC_VECTOR(iterations downto 0);
signal enable_register		: STD_LOGIC_VECTOR(iterations downto 0);


--IMPURE function to read lut from file. This lut contains some atan2 values. 
impure function init_angles return t_angle_pre is
	file bit_file 		: text open read_mode is "tan_lut_bin.txt";
	variable text_line 	: line;
	variable angle_vector 	: t_angle_pre;
	variable line_bin	: STD_LOGIC_VECTOR(lut_angle_width-1 downto 0);
begin
	for i in 0 to iterations-1 loop
		readline(bit_file, text_line);
		bread(text_line, line_bin);
		angle_vector(i) := unsigned(line_bin); --ARCTAN LUT.
	end loop;
	return angle_vector;
end function;

constant angle_reg		: t_angle_pre :=init_angles;
signal 		angle_reg_copy	: t_angle_pre :=init_angles;

begin
	
	process(clk) is
	variable angle_std	: STD_LOGIC_VECTOR(lut_angle_width downto 0);
	variable amp_mid_res	: signed(input_width+10-1 downto 0);
	begin
		if rising_edge(clk) then
			en_out			<= enable_register(enable_register'length-1);
			enable_register(0)	<= en_in;
			enable_register(enable_register'length-1 downto 1) 	<= enable_register(enable_register'length-2 downto 0);
			--set initial signals
			x_register(0) 		<= resize(ABS(SIGNED(x)),input_width+2); --this number becomes positive and increasing the size here means having the bit in front 0.
			y_register(0) 		<= resize(SIGNED(y),input_width+2); --increase the number size by one bit in so we dont overflow
			x_sign_register(0)					<= x(x'length-1);
			x_sign_register(x_sign_register'length-1 downto 1) 	<= x_sign_register(x_sign_register'length-2 downto 0); --shift the sign register.
			angle_register(0)<=to_signed(0,angle_register(0)'length);
			x_null(x_null'length-1 downto 1) <= x_null(x_null'length-2 downto 0);

			for i in 1 to iterations loop
				if y_register(i-1)(input_width) = '0' then --sign bit
					x_register(i) 		<= x_register(i-1) + resize(y_register(i-1)(input_width+1 downto (i-1)), y_register(i)'length);
					y_register(i) 		<= y_register(i-1) - resize(x_register(i-1)(input_width+1 downto (i-1)), x_register(i)'length);					
					angle_register(i) 	<= angle_register(i-1) + to_integer(angle_reg(i-1));
				else --rotate upwards
					x_register(i) 		<= x_register(i-1) - resize(y_register(i-1)(input_width+1 downto (i-1)), y_register(i)'length);
					y_register(i) 		<= y_register(i-1) + resize(x_register(i-1)(input_width+1 downto (i-1)), x_register(i)'length);					
					angle_register(i) 	<= angle_register(i-1) - to_integer(angle_reg(i-1));
				end if;
			end loop;
			--1.108567337295119 = 71/(2^6)
			--0.6072533210998718 => 
			--39797/(2^16) = [0.607254028] 		0.000226% større
			-- 311/(2^9) = [0.607421875] 		0.0278% større (BRUKES NÅ)
			
			--angle_convertion:
			if x_sign_register(iterations) = '0' then
				if angle_register(angle_register'length-1)(angle_register(0)'length-1)='0' then --L (0-90)
					angle_std := STD_LOGIC_VECTOR(ABS(angle_register(angle_register'length-1)));
					angle_out(angle_out'length-1 downto angle_out'length -2) <= "00";
				else							-- (270-360)
					angle_std := STD_LOGIC_VECTOR((2**(lut_angle_width+1) -1) - ABS(angle_register(angle_register'length-1)));
					angle_out(angle_out'length-1 downto angle_out'length -2) <= "11";
				end if;
			else
				if angle_register(angle_register'length-1)(angle_register(0)'length-1)='0' then -- (90-180)
					angle_std := STD_LOGIC_VECTOR((2**(lut_angle_width+1) -1) - ABS(angle_register(angle_register'length-1)));
					angle_out(angle_out'length-1 downto angle_out'length -2) <= "01";
				else							-- (180-270)
					angle_std := STD_LOGIC_VECTOR(ABS(angle_register(angle_register'length-1)));
					angle_out(angle_out'length-1 downto angle_out'length -2) <= "10";
				end if;
			end if;
			angle_out(angle_out'length-3 downto 0) <= angle_std(angle_std'length-2 downto angle_std'length-angle_out'length+1);
			amp_mid_res := resize(x_register(iterations)*311,input_width+10);
			amplitude_out <= STD_LOGIC_VECTOR(resize(amp_mid_res(amp_mid_res'length-1 downto 9),amplitude_out'length));			
			--amplitude_out	<= STD_LOGIC_VECTOR(resize((resize(x_register(iterations),input_width+10) * 311)/(2**9),amplitude_out'length));
			end if;
	end process;
end architecture RTL;
