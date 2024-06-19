library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use work.config.all;

	--Transforms our currents from a three phase domain into the orthogonal alpha beta reference frame.
entity clarke_transform is
	generic(
		input_width	: integer :=	work.config.current_domain_bits;
		output_width	: integer := 	work.config.alpha_beta_domain_bits
	);
	port(	
		clk		: 	in  STD_logic;
		en_str		:	in  STD_LOGIC;
		i_a, i_b, i_c	:	in  signed(input_width-1 downto 0);
		alpha,beta	: 	out STD_LOGIC_VECTOR(output_width-1 downto 0);
		en_out		:	out STD_LOGIC
	);

end entity;
architecture RTL of clarke_transform is
	constant third 		: integer := 85; --1/3 *2⁸
	constant two_third 	: integer := 2*third;
	--constant two_sqrt_three : integer := 295; --(2/sqrt3)*2⁸
	constant one_sqrt_three : integer := 295; --(1/sqrt3)*2⁹
	--constant one_sqrt_three : unsigned(8 downto 0) := 295; 
	signal alpha_internal	: signed(alpha'length+8  downto 0);
	signal beta_internal	: signed(alpha'length+9  downto 0);
	signal en_internal     : STD_LOGIC;
--function to calculate ialpha is:
--ialpha=(2/3) * (ia - (ib+ic)/2)
--function for ibeta is:
--ibeta=(ib-ic)/sqrt(3)
--alpha = i_a
--beta  = i_a/sqrt(3) + 2*ib/sqrt(3)
--Functions used:


begin
	process(clk) is
	begin
		if rising_edge(clk) then
		    alpha_internal 	<= resize(i_a,alpha_internal'length);
			beta_internal	<= resize(one_sqrt_three*resize(i_a,beta_internal'length) +(2*one_sqrt_three*resize(i_b,beta_internal'length)),beta_internal'length);
		    en_internal   <= en_str;
			--next clock cycle
			en_out		<= en_internal;
			alpha	<= STD_LOGIC_VECTOR(alpha_internal(alpha'length-1 downto 0));
            beta	<= STD_LOGIC_VECTOR(resize(beta_internal(beta_internal'length-1 downto 9),beta'length));
		end if;
	end process;
end architecture;
		
	
