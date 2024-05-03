library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use work.config.all;

	--from ia,ib,ic to alpha beta
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
--function for ibetha is:
--ibetha=(ib-ic)/sqrt(3)

begin
	process(clk) is
	--variable b_extended(22 downto 0);
	begin
		if rising_edge(clk) then
		    alpha_internal 	<= resize(i_a,alpha_internal'length);
			beta_internal	<= resize(one_sqrt_three*resize(i_a,beta_internal'length) +(2*one_sqrt_three*resize(i_b,beta_internal'length)),beta_internal'length);
		    en_internal   <= en_str;
		    --alpha_internal(i_a'length-1 downto 0) 	                  <= STD_LOGIC_VECTOR(i_a);
		    --alpha_internal(alpha_internal'length-1 downto i_a'length)   <= (others => i_a(i_a'length-1));
		    --b_extended(22 downto 0) <= (one_sqrt_three*i_a) + (2*one_sqrt_three*i_b);
		    --beta_internal(22 downto 0) <= b_extended
		    --beta_internal(beta_internal'length-1 downto 23) => (others => b_extended(22));
				
		
		    --old transformation:
			--alpha_internal 	<= resize(two_third*resize(i_a,alpha_internal'length) - third*(resize(i_b,alpha_internal'length)+resize(i_c,alpha_internal'length)),alpha_internal'length);
			--beta_internal	<= resize(one_sqrt_three*(resize(i_b,beta_internal'length)-resize(i_c,beta_internal'length)),beta_internal'length);
			en_out		<= en_internal;
			alpha	<= STD_LOGIC_VECTOR(alpha_internal(alpha'length-1 downto 0));
            beta	<= STD_LOGIC_VECTOR(resize(beta_internal(beta_internal'length-1 downto 9),beta'length));
		end if;
	end process;
end architecture;
		
	
