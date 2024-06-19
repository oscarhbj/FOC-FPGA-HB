library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use work.config.all;

--TOP MODULE FOR CORE.
--REDESIGN IN PROGRESS

entity top is
generic(
	dt_max_bits			: integer := 15
);
port(
	clk_main, clk_pwm	: in STD_LOGIC;
	rst			: in STD_LOGIC;
	en_override   		: in STD_LOGIC;
	id_ref			: in i_refrence_array; --should be 0
	iq_ref			: in i_refrence_array;
	th_override    		: in override_th;
	amp_override   		: in override_amp;
	theta_mechanical	: in angle_array;
	null_state_h		: out STD_LOGIC_vector(motors-1 downto 0); --is high when we have a high null_state
	null_state_l		: out STD_LOGIC_vector(motors-1 downto 0); --is high when we have a low null_state
	i_a,i_b,i_c		: in current_array;
	KP_d,KI_d           	: in signed(15 downto 0); --probably need a change todo
	KP_q,KI_q           	: in signed(15 downto 0);
	pwm_pins	    	: out pwm_pin_config; -- pwm_pin_config(n)=[HA,LA,HB,LB,HC,LC]
	i_out               	: out dq_array
);
end entity;
architecture RTL of top is
--signals
    --CAN HAVE CONSTANTS FOR KI,KP.
	constant startup_time	: integer := 10;
	constant sync_stages	: integer := 6;
	
	--constants for delays:
	type delay_array_type is array(sync_stages-1 downto 0) of integer;
	constant delay_array : delay_array_type:=(35,32,14,8,2,0); 
	constant delay_between_motors : integer := 4; --minimum value here is 2!
	constant cycle_time0	: integer := 2000 -((motors-1)*delay_between_motors); --The base timing for updating each motor (when during the cycle of 2048) --leaves 18 cycles for calculating pwm timings
	constant global_max_time		: integer:= loop_frequency;

	signal theta_electrical	: angle_array;
	signal rst_sensors, rst_controller, rst_command : STD_LOGIC;
	signal startup_counter	: unsigned(7 downto 0) := (others => '0');

	--Enable timer for all_ synced:
	signal global_counter_sync	: integer:= 0;
	signal enable_cycle		: STD_LOGIC:= '0';

	--To syncorize signals with correct motors	
	type motor_id_array is array (sync_stages-1 downto 0) of integer range 0 to motors; --id of motor in current point
	--positions are (current for clarke, angle for park, input to pi, output from pi, angle for inv_park, output from polar_coord)
	
	signal id_syncronized	: motor_id_array;
	
	type pwm_angle_arr is array(motors-1 downto 0) of unsigned(sin_lut_length_bits-3 downto 0);
	signal pwm_angle_array : pwm_angle_arr;
	--enable signals:
	signal enable_start_seq    : STD_LOGIC;
	signal enable_invpark	: STD_LOGIC;
	signal enable_polar	: STD_LOGIC;
	signal en_polar_vec 	: STD_LOGIC_VECTOR(motors-1 downto 0);
	signal en_ab		: STD_LOGIC;
	signal park_valid_str	: STD_LOGIC;

	--clarke:
	
	signal i_al, i_bl, i_cl : current_array;
	signal en_clarke   		: STD_LOGIC;
	signal i_a_idx,i_b_idx,i_c_idx	: signed(current_domain_bits-1 downto 0);
	signal alpha_measured	: STD_LOGIC_VECTOR(alpha_beta_domain_bits-1 downto 0);
	signal beta_measured	: STD_LOGIC_VECTOR(alpha_beta_domain_bits-1 downto 0);
	
	--park:
	signal en_park			: STD_LOGIC;
	signal park_working_angle	: STD_LOGIC_VECTOR(angle_bitdepth-1 downto 0);
	signal d_measured	: STD_LOGIC_VECTOR(dq_domain_bits-1 downto 0);
	signal q_measured	: STD_LOGIC_VECTOR(dq_domain_bits-1 downto 0);
	signal park_valid_arr	: STD_LOGIC_VECTOR(motors-1 downto 0);

	--PI controllers:
	signal q_measurements	: dq_array;
	signal d_measurements	: dq_array;
	signal q_command_array	: dq_array;
	signal d_command_array	: dq_array;
	signal en_out_pi_vector	: STD_LOGIC_VECTOR(motors-1 downto 0);

	--inv park:
	signal d_command	: STD_LOGIC_VECTOR(dq_domain_bits-1 downto 0);
	signal q_command 	: STD_LOGIC_VECTOR(dq_domain_bits-1 downto 0);
	signal inv_park_working_angle	: STD_LOGIC_VECTOR(angle_bitdepth-1 downto 0);

	--polar frame (coordic algorithm)
	signal alpha_command	: STD_LOGIC_VECTOR(alpha_beta_domain_bits-1 downto 0);
	signal beta_command	: STD_LOGIC_VECTOR(alpha_beta_domain_bits-1 downto 0);
	signal polar_angle	: STD_LOGIC_VECTOR(angle_bitdepth-1 downto 0);
	signal polar_amp	: STD_LOGIC_VECTOR(amp_width-1 downto 0);
	signal polar_amp_array	: polar_amp_arr;
	signal polar_angle_array: polar_ang_arr;

	--muxed signals
	signal polar_angle_mux : STD_LOGIC_VECTOR(work.config.angle_bitdepth-1 downto 0);
	signal polar_amp_mux   : STD_LOGIC_VECTOR(work.config.amp_width-1 downto 0);
	signal mux_en_out      : STD_LOGIC;

	--SVPWM
	signal svpwm_angle	: polar_ang_arr;
	signal svpwm_amp	: polar_amp_arr;
	signal enable_svpwm_vec	: STD_LOGIC_VECTOR(motors-1 downto 0);
	signal svpwm_angle_lut	: unsigned(sin_lut_length_bits-3 downto 0);
	
	--SIN LUT with enable for choosing what value to get.
	signal angle_inv_park		: unsigned(sin_lut_length_bits-1 downto 0);
	signal angle_park_en		: STD_LOGIC;
	signal angle_park		: unsigned(sin_lut_length_bits-1 downto 0);
	signal angle_input_lut		: unsigned(work.config.sin_lut_length_bits-1 downto 0);
	signal lut_sin_value0		: signed(work.config.sin_angle_bits-1 downto 0);
	signal lut_sin_value1		: signed(work.config.sin_angle_bits-1 downto 0);

	--lut for sin60 with harmonic:
	signal sin60_idx		: unsigned(work.config.sin_lut_length_bits-3 downto 0);
	signal sin60_value		: unsigned(work.config.sin_harmonic_bits-1 downto 0);
	
    signal current_delay_s : unsigned(7 downto 0);
begin


--Control unit and setup:
control_unit : entity work.control_module generic map (cycles_setup => 100000000, pole_pairs => 12) port map(clk => clk_main, rst_all => rst, en_override => en_override, init_str => enable_start_seq, override_angle => th_override, override_amp => amp_override, enable_polar => en_polar_vec, polar_angle_in => polar_angle_array, polar_amp_in => polar_amp_array, mechanical_angle => theta_mechanical , electrical_angle => theta_electrical, angle_pwm_out=> svpwm_angle, amp_pwm_out => svpwm_amp, en_pwm_signal => enable_svpwm_vec, rst_sensors => rst_sensors, rst_controller => rst_controller , rst_command => rst_command );


--SENSING
clarke_transformation : entity work.clarke_transform port map(clk => clk_main, en_str => en_clarke, i_a => i_a_idx, i_b => i_b_idx, i_c => i_c_idx, alpha => alpha_measured, beta => beta_measured, en_out => en_park);

--clarke --> park

--park transform
park_transformation : entity work.park_transform port map(en_str => en_park, clk => clk_main, rst=> rst_sensors,alpha => alpha_measured,beta => beta_measured, theta=> park_working_angle, d=>d_measured,q=> q_measured, en_out =>park_valid_str, angle_out =>angle_park, angle_out_en=>angle_park_en, lut_value =>lut_sin_value0);

--park -->PI

--Controllers 
g_PI : For n in (motors-1) downto 0 GENERATE
	iq_controller : entity work.pi generic map(total_shift => 9) port map(clk => clk_main, rst => rst_controller, str_update => park_valid_arr(n), desired_value => STD_LOGIC_VECTOR(iq_ref(n)), current_value => q_measurements(n), KP_s => KP_q, KI_s => KI_q, commando_out => q_command_array(n), en_out => en_out_pi_vector(n));
	id_controller : entity work.pi generic map(total_shift => 9) port map(clk => clk_main, rst => rst_controller, str_update => park_valid_arr(n), desired_value => STD_LOGIC_VECTOR(id_ref(n)), current_value => d_measurements(n), KP_s => KP_d, KI_s => KI_d, commando_out => d_command_array(n), en_out => open);
end GENERATE g_PI;

--PI --> inverse park

--inverse park transformation
inverse_park_transformation : entity work.inv_park_transform port map(clk => clk_main, en_str => enable_invpark,rst => rst_command,theta => inv_park_working_angle,d=> d_command,q=>q_command, alpha=> alpha_command, beta => beta_command, en_out=> en_ab, angle_out => angle_inv_park, angle_out_en =>  open, lut_value=> lut_sin_value1);

--inverse park --> polar coordinates

--Polar convertion
Polar : entity work.cordic_angle_abs port map(clk =>clk_main, x=> alpha_command, y=> beta_command,angle_out =>polar_angle, amplitude_out =>polar_amp,en_in=>en_ab,en_out=>enable_polar);

--Polar-->Control_unit-->SVPWM

--SVPWM
--If we want offset between when the null state start, we need to have a reset at different times. nullstate starts when reset is off.
g_sv : For n in (motors-1) downto 0 GENERATE
	svpwm_gen : entity work.svpwm port map(clk_main => clk_main,clk_pwm => clk_pwm,rst => rst_command, en_str => enable_svpwm_vec(n), theta => svpwm_angle(n), amplitude => svpwm_amp(n), a_low => pwm_pins(n)(4), a_high => pwm_pins(n)(5), b_low => pwm_pins(n)(2), b_high => pwm_pins(n)(3), c_low => pwm_pins(n)(0), c_high =>pwm_pins(n)(1), null_state_low => null_state_l(n), null_state_high => null_state_h(n) , angle_out => pwm_angle_array(n), s_time => sin60_value, cycle => open);
end GENERATE g_sv;

--Look up tables for Sinus angles
--used for park and inverse park (0-90 degrees stored. extended to 360 degrees with logic)
lut_sin_park		: entity work.sin_lut port map(clk => clk_main, angle => angle_park, value => lut_sin_value0);
lut_sin_inv_park	: entity work.sin_lut port map(clk => clk_main, angle => angle_inv_park, value => lut_sin_value1);

--sinus lookup table with third harmonic injection. used in svpwm. (0-60 degrees stored)
sin_harmonic : entity work.sin_60_lut port map(clk => clk_main, angle => sin60_idx, value => sin60_value );


--Process to make the enable signal go every 2048 cycle.
cycle_update : process(clk_main,rst) is
begin
	if rising_edge(clk_main) then
		enable_cycle <= '0'; --enable signals has a default value of 0.
		if rst = '1' then
			--Reset the counter, then 
			global_counter_sync <= 0;
		else
			global_counter_sync <= global_counter_sync+1; --increase the counter.
			if global_counter_sync = global_max_time-1 then --null timer when top is reached
				global_counter_sync <= 0;
			end if;


			----AREA for updating id on motor core and update the cycle
			for m in motors-1 downto 0 loop
				if global_counter_sync = cycle_time0 + (delay_between_motors*m) then
					enable_cycle <= '1'; --strobe for begin
				end if;
				for j in id_syncronized'length-1 downto 0 loop --same length as delay_array

					if global_counter_sync = cycle_time0 + (delay_between_motors*m) + delay_array(j) then --needs to set it the cycle before
						id_syncronized(j) <= m; --sets the correct id for the current state of the core.
					end if;
				end loop;
			end loop;
		end if;
	end if;
end process;


--counter for startup sequence and sends out enable signals during startup.
init : process(clk_main, rst) is 
begin
	if rising_edge(clk_main) then
	    enable_start_seq <= '0';
		if rst then
			startup_counter <= (others => '0');
		else
			if (startup_counter = startup_time) then
				enable_start_seq <= '1';
				startup_counter <= startup_counter +1;
			elsif not(startup_counter = startup_time+1) then
				startup_counter <= startup_counter +1;
			end if;
		end if;
	end if;
end process;


--Synchronization of angles and controllers for pipelined logic.
update_indexed_values :process(clk_main, id_syncronized,en_out_pi_vector,enable_polar) is
begin
	if rising_edge(clk_main) then
	    i_al <= i_a;
	    i_bl <= i_b;
	    i_cl <= i_c;
		--initial values for enable strobes
		park_valid_arr <= (others => '0'); 

		--Update output from park to correct PI controller
		--update pi controller, one cycle delay:
		q_measurements(id_syncronized(2)) <= q_measured;
		d_measurements(id_syncronized(2)) <= d_measured;
		park_valid_arr(id_syncronized(2)) <= park_valid_str;
	end if;
	-- updating on change in id and in measurements.
	--Update the current for the clarke to the desired motor.
	i_a_idx<= i_al(id_syncronized(0));
	i_b_idx<= i_bl(id_syncronized(0));
	i_c_idx<= i_cl(id_syncronized(0));
	
	--Update angle for park
	park_working_angle <= STD_LOGIC_VECTOR(theta_electrical(id_syncronized(1)));
		
	--Update output from PI controller to inv_park
	enable_invpark	<= en_out_pi_vector(id_syncronized(3));
	d_command	<= d_command_array(id_syncronized(3));
	q_command	<= q_command_array(id_syncronized(3));
	--Update angle for inv_park
	inv_park_working_angle <= STD_LOGIC_VECTOR(theta_electrical(id_syncronized(3)));

	--update output from Polar-coordinate translation (coordic)
	polar_amp_array(id_syncronized(4))	<= polar_amp;
	polar_angle_array(id_syncronized(4))	<= polar_angle;

	en_polar_vec				<= (others => '0');
	en_polar_vec(id_syncronized(4))		<= enable_polar;
	--update the angle used for calculation of pwm signal (svpwm)
	sin60_idx <= pwm_angle_array(id_syncronized(5));
end process;

en_clarke <= enable_cycle;
i_out <= q_measurements;
end architecture;	
