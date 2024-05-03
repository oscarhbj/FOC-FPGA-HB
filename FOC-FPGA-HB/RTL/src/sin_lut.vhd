library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use work.config.all;
	use std.textio.all; --lut

-- MODULE TAKES IN A ANGLE AND LOOKS UP WHAT SINUS VALUE BELONGS TO THIS ANGLE. USES A LUT.
-- THE MODULE stores 0 to 90 degrees, and converts the rest into the stored angles. 
-- Convertion is as follows:
-- 0   to  90 degrees: index is angle%lut'len, 			sign is positive
-- 90  to 180 degrees: index is lut'len - angle%lut'len, 	sign is positive
-- 180 to 270 degrees: index is angle%lut'len, 			sign is negative.
-- 270 to 360 degrees: index is lut'len - angle%lut'len, 	sign is negative.

entity sin_lut is 
	generic(
		input_bits	: integer := work.config.sin_lut_length_bits;
		output_bits	: integer := work.config.sin_angle_bits
	);
	port(
		clk	: in std_logic;
		angle	: in unsigned(input_bits-1 downto 0);
		value	: out signed(output_bits-1 downto 0) --16 bits, highest value is 0x7fff
	);
end sin_lut;

architecture RTL of sin_lut is
	signal index_internal	: unsigned(angle'length-3 downto 0); --index for internal array. does not need the top two bits as it stores 0-90 degrees. -two bits less than the external angle
	signal sign		: STD_LOGIC;
	type sin_value is array (2**index_internal'length -1 downto 0) of STD_LOGIC_VECTOR(value'length-2 downto 0);
	constant lut_len 	: integer := 2**index_internal'length; 


	--IMPURE function to read from file and place values into lut.
	--read in lut from file.
	impure function init_lut return sin_value is
		file bit_file 		: text open read_mode is "sin_lut_bin.txt";
		variable text_line 	: line;
		variable ram_content 	: sin_value;
	begin
		for i in 0 to 2**index_internal'length -1 loop
			readline(bit_file, text_line);
			bread(text_line, ram_content(i));
		end loop;
		return ram_content;
	end function;	

	--The lut that contains the values of sin.
	signal sin_values : sin_value := init_lut; --create lut.
		

begin
	--uses one clock cycle to find correct index and sign. converts it to the range 0-90 degrees idx.
	process(clk, angle) is
	begin
		if rising_edge(clk) then
			--cycle 1
			if STD_LOGIC(angle(angle'length-1))='0' then	--set sign
				sign <= '0'; --positive
			else 
				sign <= '1'; --negative
			end if;
			if STD_LOGIC(angle(angle'length-2))='0' then	--(set idx)
				index_internal<= to_unsigned(to_integer(angle(angle'length-3 downto 0)), index_internal'length); -- angle%lut'len
			else
				index_internal<= to_unsigned(lut_len-1 - to_integer(angle(angle'length-3 downto 0)), index_internal'length);

			end if;
			
			--cycle 2
			--Uses this cycle to look up the value and convert it to a signed number with correct sign.
			if sign = '0' then
				value 	<= signed('0' & STD_LOGIC_VECTOR(sin_values(to_integer(index_internal)))); 	-- sets the positive value for first 180 degrees
			else												-- negaive values
				value	<= signed(-signed('0' & STD_LOGIC_VECTOR(sin_values(to_integer(index_internal)))));
			end if;
		end if;
	end process;
end architecture RTL;
