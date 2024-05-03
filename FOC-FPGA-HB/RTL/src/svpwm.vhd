library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use work.config.all;

entity svpwm is

generic(
	angle_width	: integer := work.config.angle_bitdepth;
	amp_width	: integer := work.config.amp_width;
	pwm_bits	: integer := 16;
	max_v_amp	: integer := work.config.max_amp_svpwm;
	sin_bits	: integer := work.config.sin_harmonic_bits;
	sin_lut_idx	: integer := work.config.sin_lut_length_bits-2;
	shift_amp	: integer := 3 --we use the top bits. 2048=0x800. look at num [15 downto 3] (12 bits) where the 11 bottom bits of those 12 are used for pwm. if number is over 2048, we round down to 2048. 
	

);

port(
	clk_main, clk_pwm	: in STD_LOGIC;
	rst			: in STD_LOGIC;
	en_str			: in STD_LOGIC;
	theta			: in STD_LOGIC_VECTOR(angle_width-1 downto 0);
	amplitude		: in STD_LOGIC_VECTOR(amp_width-1 downto 0); --looks at value 14 downto 4. (if idx 15 is used, it is changed to max_amp)
	a_low,a_high		: out STD_LOGIC;
	b_low,b_high		: out STD_LOGIC;
	c_low,c_high		: out STD_LOGIC;
	null_state_high		: out STD_LOGIC; --signal out when we are in 0 state
	null_state_low		: out STD_LOGIC;

	--sin_rom with third_harmonic:
	angle_out		: out unsigned(sin_lut_idx-1 downto 0); --could be entity initialized here.
	s_time			: in unsigned(sin_bits-1 downto 0);

	--Test signal
	cycle			: out STD_LOGIC --not really used
	 
);
end entity;

architecture RTL of svpwm is

constant change_idx			: integer := 0; --where we want to update our pwm. (null state, 1 state, 2 state, null state, 2 state, 1 state) (can be 0,2,3,5)
constant one_sixth			: integer := (2**angle_width)/6;
constant shift_amount			: integer := sin_bits;
constant angle_convertion		: integer := angle_width-2-sin_lut_idx;
constant offset                 : integer := shift_amp;
signal counter				: unsigned(pwm_bits-1 downto 0);
signal time_slow, time_next		: unsigned(pwm_bits-1 downto 0);
signal pwm_state_slow, pwm_next 	: work.config.pwm_power_config;
signal s_null0, s_null1, s1, s2		: work.config.pwm_power_config;
signal section_theta			: unsigned(angle_width-3 downto 0); -- we only need 60 degrees, so we can shorten it by two bits (so it holds 90 deg).
signal s1_time				: unsigned(s_time'length-1 downto 0);
signal enable_calc_time_vector		: STD_LOGIC_VECTOR(4 downto 0);
signal section_set			: STD_LOGIC;
signal lock_pwm				: STD_LOGIC;
signal changing_pwm			: STD_LOGIC;
signal pwm_array_en, pwm_array_en1	: STD_LOGIC;
signal time_idx				: integer range 0 to 5	:=0;
signal flipped				: STD_LOGIC := '0';
signal amplitude_locked			: unsigned(amp_width-1 downto 0);
signal amplitude_locked0		: unsigned(amp_width-1 downto 0);


type sextant is (origo,QI, QII, QIII, QIV, QV, QVI);
signal section 				: sextant;

--time in each state before we switch.
type time_state is array(5 downto 0) of unsigned(pwm_bits-1 downto 0);
signal time_pwm_array, time_pwm_array_new, time_pwm_array_used		: time_state := (others => to_unsigned(10,pwm_bits));

--"list" of the states we should switch between in order.
type t_pwm is array (5 downto 0) of work.config.pwm_power_config;
signal pwm_state_array, pwm_state_array_new, pwm_state_array_used	: t_pwm := (others => work.config.null_Tri);

begin

--PROCESS to select the current SECTION from the angle.
select_section : process(clk_main,en_str) is
begin
	if rising_edge(clk_main) then
		section_set <= '0';
		if en_str='1' then
			amplitude_locked0 <= unsigned(amplitude);
			--Find the section, and crop the angle so its between 0 and 60 degrees.
			if unsigned(theta) < one_sixth then
				section <= QI;
				section_theta <= resize(unsigned(theta),section_theta'length);
			elsif unsigned(theta) < 2*one_sixth then
				section <= QII;
				section_theta <= resize(unsigned(theta) - (1*one_sixth),section_theta'length);
			elsif unsigned(theta) < 3*one_sixth then
				section <= QIII;
				section_theta <= resize(unsigned(theta) - (2*one_sixth),section_theta'length);
			elsif unsigned(theta) < 4*one_sixth then
				section <= QIV;
				section_theta <= resize(unsigned(theta) - (3*one_sixth),section_theta'length);	
			elsif unsigned(theta) < 5*one_sixth then
				section <= QV;
				section_theta <= resize(unsigned(theta) - (4*one_sixth),section_theta'length);	
			else
				section <= QVI;
				section_theta <= resize(unsigned(theta) - (5*one_sixth),section_theta'length);
				
			end if;
			section_set<='1';
		end if;
	end if;	
end process;

--^HAS BEEN TESTED AND WORKS (Gives correct section and angle in that sector.

--process that sets the order of states for the pwm signal generation.
select_vectors : process(clk_main, section_set, section) is
variable s_null0, s_null1, s1, s2 : work.config.pwm_power_config;
begin
	if rising_edge(clk_main) then
		enable_calc_time_vector(0) <= '0';
		if (section_set = '1') then
			s_null0	:= work.config.null_n_abc;
			s_null1	:= work.config.null_ABC;
			--set the states we are going to switch between from the section we are in.
			case section is
				when QI		=>
					s1	:= work.config.A_bc;
					s2	:= work.config.AB_c;
					flipped <= '0';
				when QII	=>
					s1	:= work.config.B_ac;
					s2	:= work.config.AB_c;
					flipped <= '1';
				when QIII	=>
					s1	:= work.config.B_ac;
					s2	:= work.config.BC_a;
					flipped <= '0';
				when QIV	=>
					s1	:= work.config.C_ab;
					s2	:= work.config.BC_a;
					flipped <= '1';
				when QV		=>
					s1	:= work.config.C_ab;
					s2	:= work.config.AC_b;
					flipped <= '0';
				when QVI	=>
					s1	:= work.config.A_bc;
					s2	:= work.config.AC_b;
					flipped <= '1';
				when others	=>
					s1	:= work.config.null_n_abc;
					s2	:= work.config.null_n_abc;
					s_null1	:= work.config.null_n_abc;
			end case;
			--set pwm states in order.
			pwm_state_array_new(0) <= s_null0;
			pwm_state_array_new(1) <= s1;
			pwm_state_array_new(2) <= s2;
			pwm_state_array_new(3) <= s_null1;
			pwm_state_array_new(4) <= s2;
			pwm_state_array_new(5) <= s1;

			--make sure amplitude is in the corret range.
			amplitude_locked <= resize(amplitude_locked0(amplitude_locked0'length -1 downto offset),amplitude_locked'length); -- we care about the bits in our specified range.
			if amplitude_locked0 >= (max_v_amp-1) then
				amplitude_locked <= to_unsigned(max_v_amp-1,amplitude_locked'length);
			end if;
			enable_calc_time_vector(0) <= '1';
		end if;
	end if;
end process;


--Updates the next pwm timings. so we can find what amount of time we want to bring in each state.
calculate_time : process(clk_main) is
variable s2_time 	: unsigned(s_time'length-1 downto 0);
variable time_zero 	: unsigned(pwm_bits-1 downto 0);
variable time_s1, time_s2 : unsigned(pwm_bits-1 downto 0);
begin
	if rising_edge(clk_main) then
		enable_calc_time_vector(4 downto 1) <= enable_calc_time_vector(3 downto 0);
		pwm_array_en	<= '0';
		if enable_calc_time_vector(0) then --cycle 1:
			angle_out <= resize((one_sixth - section_theta)/(2**angle_convertion),angle_out'length); --sin(60-angle)
		end if;
		if enable_calc_time_vector(1) then --cycle 2:
			angle_out <= resize(section_theta/(2**angle_convertion),angle_out'length); --convert to 8 bit.
		end if;
		if enable_calc_time_vector(2) then --I kry, I needed one more clock cycle for the lut. I used 1 whole day to find this bug.
			s1_time <= s_time;
		end if;
		if enable_calc_time_vector(3) then --cycle 4:
			s2_time	:= s_time;
			--T1
			time_s1:=to_unsigned((to_integer(s1_time * amplitude_locked) / (2**(shift_amount+1))),time_pwm_array_new(1)'length);
			--T2			
			time_s2:=to_unsigned((to_integer(s2_time * amplitude_locked) / (2**(shift_amount+1))),time_pwm_array_new(1)'length);
			

			--This is needed due to we always wanting a state with two 0 and one 1 first in our commutation.
			if flipped = '0' then
				time_pwm_array_new(1) <= time_s1;
				time_pwm_array_new(5) <= time_s1;
				time_pwm_array_new(2) <= time_s2;
				time_pwm_array_new(4) <= time_s2;
			else
				time_pwm_array_new(1) <= time_s2;
				time_pwm_array_new(5) <= time_s2;
				time_pwm_array_new(2) <= time_s1;
				time_pwm_array_new(4) <= time_s1;
			end if;
		end if;
		if enable_calc_time_vector(4) then --cycle 5:
			--calculate null time
			time_zero := to_unsigned(max_v_amp/2,time_pwm_array_new(1)'length) -time_pwm_array_new(1) - time_pwm_array_new(2); --t_max - t1 -t2 = t0
			if time_zero > max_v_amp then --make sure we did not overflow.
				time_zero := to_unsigned(1,time_zero'length);
			end if;
			time_pwm_array_new(0) <= time_zero;
			time_pwm_array_new(3) <= time_zero;
			pwm_array_en	<= '1';
		end if;
	end if;
end process;


--PROCESS THAT BLOCKS AND HOLDS SIGNAL IF IT IS TRYING TO CHANGE WHILE SLOW DOMAIN READS IN NUMBERS.
--delay 1 cycle + (whatever it needs if nessecarry)
cdc_pwm	: process(clk_main) is
begin
	if rising_edge(clk_main) then
		if pwm_array_en	= '1' then
			pwm_array_en1 <= '1';	
		end if;
		if (pwm_array_en1 = '1') and (changing_pwm = '0') then
			time_pwm_array 	<= time_pwm_array_new;
			pwm_state_array	<= pwm_state_array_new;
			pwm_array_en1 	<= '0';
		end if;			
	end if;
end process;


--TAKES IN time and state. holds the state for that amount of time.
--Will send out signal when we are in 0 states. and it will send out a signal when its changing pwm.
pwm_gen : process(clk_pwm) is
variable pwm_current : work.config.pwm_power_config;
begin
	if rising_edge(clk_pwm) then
		counter	<= counter +1;
		changing_pwm <= '0';
		null_state_high   <= '0';
		null_state_low    <= '0';
		cycle	<= '0';	
		if (time_idx = 0) then --index 0 is a null state
		      null_state_low <= '1';
		elsif (time_idx = 3) then  --index 3 is a null state
	          null_state_high <= '1';
		end if;

		--we have reached desired time in this state.
		if rst = '1' then
			null_state_low <= '1';
			counter 		<= to_unsigned(0, counter'length);
			changing_pwm		<= '0';
			pwm_state_array_used 	<= pwm_state_array;
			time_pwm_array_used	<= time_pwm_array;
			time_idx 		<= 0;

		elsif counter >= time_pwm_array_used(time_idx) then
			counter 	<= to_unsigned(0, counter'length);
			if time_idx=5 then --wrap around
				time_idx 	<= 0;
			else
				time_idx 	<= time_idx+1; 
			end if;
			if (time_idx = change_idx) then --send signal so we can change the pwm.
				changing_pwm	<= '1';
				cycle		<= '1';
				pwm_state_array_used 	<= pwm_state_array;
				time_pwm_array_used	<= time_pwm_array;
			end if;
		end if;

		--set signal out for pwm:
		pwm_current := pwm_state_array_used(time_idx);
		if rst= '1' then
		      pwm_current := work.config.null_Tri;
		end if;
		work.config.set_pwm(pwm_current,a_low,a_high,b_low,b_high,c_low,c_high);
	end if;
end process;

end architecture;
