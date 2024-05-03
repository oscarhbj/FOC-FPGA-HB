library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use work.config.all;
	use std.textio.all; --lut

-- MODULE TAKES IN A ANGLE AND LOOKS UP WHAT SINUS VALUE BELONGS TO THIS ANGLE. USES A LUT.
-- THE MODULE stores 0 to 60 degrees, and converts the rest into the stored angles. 
-- Convertion is as follows:
-- 0   to  60 degrees: index is angle
-- has third harmonic injections inbuildt.

entity sin_60_lut is 
	generic(
		input_bits	: integer := work.config.sin_lut_length_bits-2;
		output_bits	: integer := work.config.sin_harmonic_bits
	);
	port(
		clk	: in std_logic;
		angle	: in unsigned(input_bits-1 downto 0);
		value	: out unsigned(output_bits-1 downto 0)
	);
end sin_60_lut;

architecture RTL of sin_60_lut is
	constant array_length : integer := ((2**input_bits -1)*2/3) +1;
	--LUT_type:
	type sin_value is array (array_length downto 0) of STD_LOGIC_VECTOR(output_bits-1 downto 0);

	--IMPURE function to read from file and place values into lut.
	--read in lut from file.
	impure function init_lut return sin_value is
		file bit_file 		: text open read_mode is "sin_lut_harmonic_bin.txt";
		variable text_line 	: line;
		variable ram_content 	: sin_value;
	begin
		for i in 0 to array_length loop
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
			value <= unsigned(sin_values(to_integer(angle)));
		end if;
	end process;
end architecture RTL;
