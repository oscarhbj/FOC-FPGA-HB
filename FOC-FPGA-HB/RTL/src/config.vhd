library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

package config is
--Configuration file. here are some of the parameters that can be adjusted inside the code.

--Constants for code:
	constant motors 			: positive := 2; --amount of motors
	constant angle_bitdepth 		: positive := 16;
	constant bits_adc 			: positive := 12;
	constant current_domain_bits   : integer := 16;
	constant alpha_beta_domain_bits		: integer := 16;
	constant dq_domain_bits			: integer := 16;
	constant cordic_lut_width		: integer := 16;

	--Sinus lut.
	constant sin_lut_length_bits		: positive := 10; --takes in an angle in the range 0-1023 
	constant sin_angle_bits			: positive := 16; -- returns a value thats 16 bits. signed number. max value is 1, min is -1.

	constant sin_harmonic_bits		: integer := 16;

	constant amp_width			: integer :=16;
	

	constant max_amp_svpwm			: integer := 2048;
	constant loop_frequency			: integer := max_amp_svpwm; --how often the loop is run.
	constant id_bits			: integer :=8;




--costom types
--arrays for multiple motors.
type dq_array is array(motors-1 downto 0) of STD_LOGIC_VECTOR(dq_domain_bits-1 downto 0);
type i_refrence_array is array (motors-1 downto 0) of signed(dq_domain_bits-1 downto 0);
type angle_array is array (motors-1 downto 0) of unsigned(angle_bitdepth-1 downto 0);
type current_array is array (motors-1 downto 0) of signed(current_domain_bits-1 downto 0);
type pwm_pin_config is array(motors-1 downto 0) of STD_LOGIC_VECTOR(5 downto 0); --[(a_low, a_high, b_low, b_high, c_low, c_high)]  [HA,LA,HB,LB,HC,LC]
type override_th is array(motors-1 downto 0) of unsigned(angle_bitdepth-1 downto 0);
type override_amp is array(motors-1 downto 0) of unsigned(amp_width-1 downto 0);

type polar_ang_arr is array(motors-1 downto 0) of STD_LOGIC_VECTOR(angle_bitdepth-1 downto 0);
type polar_amp_arr is array(motors-1 downto 0) of STD_LOGIC_VECTOR(amp_width-1 downto 0);
type i_array is array(2 downto 0) of current_array;
--coil power config: (high_low) ex: AB_c (A and B are high, c is low). C_b (C is high, b is low, a is not connected)
--				[		SVPWM		    ]	[	SPWM		    ]	[	NULL vectors	->]	
	type pwm_power_config is (AB_c, A_bc, BC_a, B_ac, AC_b, C_ab,	A_b, A_c, B_a, B_c, C_a, C_b,	null_A, null_B, null_C, null_AB, null_AC, null_BC, null_n_a, null_n_b, null_n_c, null_n_ab, null_n_ac, null_n_bc, null_Tri, null_ABC, null_n_abc); --3³ states = 27


--list of functions and proceedures:

procedure set_pwm(variable current_state : in pwm_power_config; signal a_low,a_high,b_low,b_high,c_low,c_high : out STD_LOGIC);
end package;

package body config is


procedure set_pwm (variable current_state : in pwm_power_config;
signal a_low,a_high,b_low,b_high,c_low,c_high : out STD_LOGIC) is
begin
	case current_state is
		--SVPWM
		when AB_c =>
			a_low	<= '0';
			a_high	<= '1';
			b_low	<= '0';
			b_high	<= '1';
			c_low	<= '1';
			c_high	<= '0';
		when A_bc =>
			a_low	<= '0';
			a_high	<= '1';
			b_low	<= '1';
			b_high	<= '0';
			c_low	<= '1';
			c_high	<= '0';
		when BC_a =>
			a_low	<= '1';
			a_high	<= '0';
			b_low	<= '0';
			b_high	<= '1';
			c_low	<= '0';
			c_high	<= '1';
		when B_ac =>
			a_low	<= '1';
			a_high	<= '0';
			b_low	<= '0';
			b_high	<= '1';
			c_low	<= '1';
			c_high	<= '0';
		when AC_b =>
			a_low	<= '0';
			a_high	<= '1';
			b_low	<= '1';
			b_high	<= '0';
			c_low	<= '0';
			c_high	<= '1';
		when C_ab =>
			a_low	<= '1';
			a_high	<= '0';
			b_low	<= '1';
			b_high	<= '0';
			c_low	<= '0';
			c_high	<= '1';
		--SPWM
		when A_b =>
			a_low	<= '0';
			a_high	<= '1';
			b_low	<= '1';
			b_high	<= '0';
			c_low	<= '0';
			c_high	<= '0';
		when A_c =>
			a_low	<= '0';
			a_high	<= '1';
			b_low	<= '0';
			b_high	<= '0';
			c_low	<= '1';
			c_high	<= '0';
		when B_a =>
			a_low	<= '1';
			a_high	<= '0';
			b_low	<= '0';
			b_high	<= '1';
			c_low	<= '0';
			c_high	<= '0';
		when B_c =>
			a_low	<= '0';
			a_high	<= '0';
			b_low	<= '0';
			b_high	<= '1';
			c_low	<= '1';
			c_high	<= '0';
		when C_a =>
			a_low	<= '1';
			a_high	<= '0';
			b_low	<= '0';
			b_high	<= '0';
			c_low	<= '0';
			c_high	<= '1';
		when C_b =>
			a_low	<= '0';
			a_high	<= '0';
			b_low	<= '1';
			b_high	<= '0';
			c_low	<= '0';
			c_high	<= '1';
		--NULL VECTORS
		when null_A =>
			a_low	<= '0';
			a_high	<= '1';
			b_low	<= '0';
			b_high	<= '0';
			c_low	<= '0';
			c_high	<= '0';
		when null_B =>
			a_low	<= '0';
			a_high	<= '0';
			b_low	<= '0';
			b_high	<= '1';
			c_low	<= '0';
			c_high	<= '0';
		when null_C =>
			a_low	<= '0';
			a_high	<= '0';
			b_low	<= '0';
			b_high	<= '0';
			c_low	<= '0';
			c_high	<= '1';

		when null_AB =>
			a_low	<= '0';
			a_high	<= '1';
			b_low	<= '0';
			b_high	<= '1';
			c_low	<= '0';
			c_high	<= '0';
		when null_AC =>
			a_low	<= '0';
			a_high	<= '1';
			b_low	<= '0';
			b_high	<= '0';
			c_low	<= '0';
			c_high	<= '1';
		when null_BC =>
			a_low	<= '0';
			a_high	<= '0';
			b_low	<= '0';
			b_high	<= '1';
			c_low	<= '0';
			c_high	<= '1';

		when null_n_a =>
			a_low	<= '1';
			a_high	<= '0';
			b_low	<= '0';
			b_high	<= '0';
			c_low	<= '0';
			c_high	<= '0';
		when null_n_b =>
			a_low	<= '0';
			a_high	<= '0';
			b_low	<= '1';
			b_high	<= '0';
			c_low	<= '0';
			c_high	<= '0';
		when null_n_c =>
			a_low	<= '0';
			a_high	<= '0';
			b_low	<= '0';
			b_high	<= '0';
			c_low	<= '1';
			c_high	<= '0';

		when null_n_ab =>
			a_low	<= '1';
			a_high	<= '0';
			b_low	<= '1';
			b_high	<= '0';
			c_low	<= '0';
			c_high	<= '0';
		when null_n_ac =>
			a_low	<= '1';
			a_high	<= '0';
			b_low	<= '0';
			b_high	<= '0';
			c_low	<= '1';
			c_high	<= '0';
		when null_n_bc =>
			a_low	<= '0';
			a_high	<= '0';
			b_low	<= '1';
			b_high	<= '0';
			c_low	<= '1';
			c_high	<= '0';

		when null_Tri =>
			a_low	<= '0';
			a_high	<= '0';
			b_low	<= '0';
			b_high	<= '0';
			c_low	<= '0';
			c_high	<= '0';
		when null_ABC =>
			a_low	<= '0';
			a_high	<= '1';
			b_low	<= '0';
			b_high	<= '1';
			c_low	<= '0';
			c_high	<= '1';
		when null_n_ABC =>
			a_low	<= '1';
			a_high	<= '0';
			b_low	<= '1';
			b_high	<= '0';
			c_low	<= '1';
			c_high	<= '0';
	end case;
end procedure;

end package body config;
