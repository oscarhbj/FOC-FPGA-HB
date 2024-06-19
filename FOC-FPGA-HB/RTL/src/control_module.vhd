library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use work.config.all;

entity control_module is
--module to control pwm signal on startup. convert angle to electrical (2*polepairs*mechanical)


	generic(
		cycles_setup	: integer := 1000;
		angle_pwm_w	: integer := work.config.angle_bitdepth;
		amp_pwm_width	: integer := work.config.amp_width;
		electrical_a_w	: integer := work.config.angle_bitdepth;
		mechanical_a_w	: integer := work.config.angle_bitdepth;
		pole_pairs	: integer := 12
		
		
		
	); 
	port(
		clk, rst_all	: in STD_LOGIC;
		en_override   : in STD_LOGIC;
		init_str	: in STD_LOGIC;
		override_angle : in override_th;
		override_amp  : in override_amp;
		enable_polar	: in STD_LOGIC_vector(motors-1 downto 0);
		polar_angle_in	: in polar_ang_arr;
		polar_amp_in	: in polar_amp_arr;
		mechanical_angle: in angle_array;
		electrical_angle: out angle_array;
		angle_pwm_out	: out polar_ang_arr;
		amp_pwm_out	: out polar_amp_arr;
		en_pwm_signal	: out STD_LOGIC_VECTOR(motors-1 downto 0);
		rst_sensors, rst_controller, rst_command : out STD_LOGIC
		
	);
end entity;

architecture rtl of control_module is
constant max_amp : integer :=work.config.max_amp_svpwm;
constant amp_multiplier_override : integer := (2**amp_pwm_width) /max_amp;
constant angle_w_diff	: integer := electrical_a_w-mechanical_a_w;
type angle_offsets is array (motors-1 downto 0) of unsigned(mechanical_a_w-1 downto 0);
signal counter_init	: unsigned(32 downto 0) := (others => '0');
signal offset_pos	: angle_offsets;
signal init_str_local: STD_LOGIC;
signal en_override_synced : STD_LOGIC;

begin

init_control : process (init_str, rst_all, clk, counter_init) is
begin
	--initialization procedure for setting reset signals for a set amount of time for different modules. 
	--has reset enabeled for "cycles_setup" clock cycles.
	if rising_edge(clk) then
		--all reset signals follows the rst_all input.
		en_override_synced <= en_override;
		rst_sensors 	<= rst_all;
		rst_controller	<= rst_all;
		rst_command	<= rst_all;
		init_str_local <= init_str;
		if rst_all then
			counter_init <= (others => '0');
			init_str_local <= '1';
		elsif init_str_local then
			--if we want to init the setup. set the counter to 1. set all rst signals to reset for one cycle.
			counter_init <= to_unsigned(1,counter_init'length);
			rst_sensors 	<= '1';
			rst_controller	<= '1';
			rst_command	<= '1';
		elsif	not (counter_init = to_unsigned(0,counter_init'length)) then
			--counts for the reset period.
			counter_init <= counter_init +1;
			--continues to hold rst_sensors and rst_controller at 1 untill last cycle.
			rst_sensors 	<= '1';
			rst_controller	<= '1';
			if counter_init = to_unsigned(cycles_setup, counter_init'length) then
				-- once the counter is done we have hopefully homed around 0 electrical degrees, and do now have a offset.
				for n in 0 to motors-1 loop
					offset_pos(n) <= 0 - mechanical_angle(n);
				end loop;
				counter_init <= to_unsigned(0,counter_init'length);
			end if;
		end if;


	end if;
end process;

	
mec_to_electric : process (mechanical_angle, offset_pos) is
--Converts mecanical degrees to electrical degrees.
begin
	for i in 0 to motors-1 loop
		electrical_angle(i) <= resize((pole_pairs)*(mechanical_angle(i) + offset_pos(i))*(2**angle_w_diff),electrical_a_w);
	end loop;
end process;


pwm_mux : process (polar_angle_in, polar_amp_in, counter_init,en_override_synced, clk,enable_polar) is
--Process to that sends the desired angle and amplitude towards 0 degrees. This will ensure that we point towards 0 electrical degrees and can sample the ofset of the angle sensor.
begin
	if counter_init=to_unsigned(0,counter_init'length) then
		if en_override_synced then
			for n in 0 to motors-1 loop		
                  		angle_pwm_out(n) <= STD_LOGIC_VECTOR(override_angle(n));
                  		amp_pwm_out(n)   <= STD_LOGIC_VECTOR(override_amp(n)); --4096 er 100%
			end loop;
			en_pwm_signal <= enable_polar; --should probably change this to a different pulse...
            	else
			--no need to loop here due to everything having correct types.
                  	angle_pwm_out	<= polar_angle_in;
                  	amp_pwm_out	<= polar_amp_in;
                  	en_pwm_signal	<= enable_polar;
            	end if;
        else
            	angle_pwm_out	<= (others => (others => '0')); --desired angle is 0 degrees. so we want that direction.
            	amp_pwm_out	<= (others => STD_LOGIC_VECTOR(to_unsigned(amp_multiplier_override*max_amp/2, amp_pwm_out(0)'length))); --amplitude for start sequence 50%
            	en_pwm_signal	<= (others => '0');
            	if counter_init = to_unsigned(5,counter_init'length) then
                	en_pwm_signal	<= (others => '1');
            	end if;
        end if;
end process;

end architecture;
