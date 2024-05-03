library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use work.config.all;

entity top_fpga_trenz is
generic(
    setup_time  : integer       := 27000;
    setup_time_en: integer      := 20000;
    ADC_NUM : integer := 1
);
port(
	clk_main	: in STD_LOGIC; --100 mhz (stolen right now)
	--clk_PWM		: in STD_LOGIC;
	rst		: in STD_LOGIC;
	--Control input:
	iq_ref0	: in STD_LOGIC_VECTOR(15 downto 0);
	iq_ref1	: in STD_LOGIC_VECTOR(15 downto 0);
--	iq_ref2	: in STD_LOGIC_VECTOR(15 downto 0);
--	iq_ref3	: in STD_LOGIC_VECTOR(15 downto 0);
--	iq_ref4	: in STD_LOGIC_VECTOR(15 downto 0);
--	iq_ref5	: in STD_LOGIC_VECTOR(15 downto 0);
--	iq_ref6	: in STD_LOGIC_VECTOR(15 downto 0);
--	iq_ref7	: in STD_LOGIC_VECTOR(15 downto 0);
--	iq_ref8	: in STD_LOGIC_VECTOR(15 downto 0);
--	iq_ref9	: in STD_LOGIC_VECTOR(15 downto 0);
--	iq_ref10	: in STD_LOGIC_VECTOR(15 downto 0);
--	iq_ref11	: in STD_LOGIC_VECTOR(15 downto 0);
	

	--pins for pwm output:
	pwm_motor0	: out STD_LOGIC_VECTOR(5 downto 0); --[HA,LA,HB,LB,HC,LC]
	pwm_motor1	: out STD_LOGIC_VECTOR(5 downto 0); --[HA,LA,HB,LB,HC,LC]
--	pwm_motor2	: out STD_LOGIC_VECTOR(5 downto 0); --[HA,LA,HB,LB,HC,LC]
--	pwm_motor3	: out STD_LOGIC_VECTOR(5 downto 0); --[HA,LA,HB,LB,HC,LC]
--	pwm_motor4	: out STD_LOGIC_VECTOR(5 downto 0); --[HA,LA,HB,LB,HC,LC]
--	pwm_motor5	: out STD_LOGIC_VECTOR(5 downto 0); --[HA,LA,HB,LB,HC,LC]
--	pwm_motor6	: out STD_LOGIC_VECTOR(5 downto 0); --[HA,LA,HB,LB,HC,LC]
--	pwm_motor7	: out STD_LOGIC_VECTOR(5 downto 0); --[HA,LA,HB,LB,HC,LC]
--	pwm_motor8	: out STD_LOGIC_VECTOR(5 downto 0); --[HA,LA,HB,LB,HC,LC]
--	pwm_motor9	: out STD_LOGIC_VECTOR(5 downto 0); --[HA,LA,HB,LB,HC,LC]
--	pwm_motor10	: out STD_LOGIC_VECTOR(5 downto 0); --[HA,LA,HB,LB,HC,LC]
--	pwm_motor11	: out STD_LOGIC_VECTOR(5 downto 0); --[HA,LA,HB,LB,HC,LC]
	
	
	
	en_gate		: out STD_LOGIC_vector(motors-1 downto 0) := (others => '0');
	
	
	--interface for overriding the control logic and giving angle+amp.
	--en_override	: in STD_LOGIC; --when '1', we control amp and angle.
	angle_override	: in STD_LOGIC_VECTOR(15 downto 0);
	amp_override	: in STD_LOGIC_VECTOR(15 downto 0);
	
	--PI PARAMETERS:
	KP_q,KI_q,KP_d,KI_d : in STD_LOGIC_VECTOR(15 downto 0);

	--SPI interface
	MISO		: in STD_LOGIC_VECTOR(ADC_NUM-1 downto 0); --sdo
	MOSI		: out STD_LOGIC_VECTOR(ADC_NUM-1 downto 0);--sdi
	SPI_clk	: out STD_LOGIC_VECTOR(ADC_NUM-1 downto 0);--sclk
	CS		: out STD_LOGIC_VECTOR(ADC_NUM-1 downto 0); --sync
	--rst_ADC		: out STD_LOGIC_VECTOR(0 downto 0) := (others => '1'); --This is an inverted reset signal
	--IO_16  : out STD_LOGIC_VECTOR(0 downto 0) := (others => '0');
	--IO_12  : out STD_LOGIC_VECTOR(0 downto 0) := (others => '0');
	--RDY : out STD_LOGIC_VECTOR(0 downto 0)    := (others => '0');

	--Data from angular encoder
	CHI,CHA,CHB	: in STD_LOGIC_VECTOR(motors-1 downto 0);
	
	--Dataoutput to computer:
	i_out		: out signed (15 downto 0);
	angle_out	: out unsigned (15 downto 0);
	
	--report current in a and b
	current_ia  : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	current_ib  : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0')	
);
end entity;


architecture TOP of top_fpga_trenz is
    type adc_mask_type is array (ADC_NUM-1 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
    constant adc_mask_arr : adc_mask_type := (others=>"11111111");--, "11111111", "11111111", "11111111", "11111111");

	--signals for id and iq vectors

	signal id_ref_vec	: i_refrence_array;
	signal iq_ref_vec	: i_refrence_array;

	--signals for kp and kd in controller:
	signal KPd, KId, KPq, KIq	: signed(15 downto 0);

	--Signals and types for adc sensor
	
	signal i_abc		: i_array := (others => (others => (others => '0'))); --abc[m1,m2,m3[bits]]
	signal valid_power_h	: STD_LOGIC_VECTOR(motors-1 downto 0);
	signal valid_power_l	: STD_LOGIC_VECTOR(motors-1 downto 0);
	signal en_i_spi		: STD_LOGIC_VECTOR(ADC_NUM-1 downto 0); 	--strobe for new output from spi
	type i_sen_array_type  is array (ADC_NUM-1 downto 0) of STD_LOGIC_VECTOR(bits_adc-1 downto 0);
	signal i_sen		: i_sen_array_type;
	signal i_sen_dir	: i_sen_array_type;

	type idx_i_array_type is array(ADC_NUM-1 downto 0) of integer range 0 to 2;
	signal i_idx		: idx_i_array_type;

	type idx_i_array_type_unsigned is array(ADC_NUM-1 downto 0) of unsigned(2 downto 0);
	signal i_idx_dir	: idx_i_array_type_unsigned;
	signal en_spi_output	: STD_LOGIC_VECTOR(ADC_NUM-1 downto 0);
	
	--type update_order is array(motors-1 downto 0) of integer range 2 downto 0;
	--signal prev_updated    : update_order;
	
	--signals from core that are high during null states
	signal null_state_low	: STD_LOGIC_VECTOR(motors-1 downto 0);
	signal null_state_low_p	: STD_LOGIC_VECTOR(motors-1 downto 0);
	signal null_state_high	: STD_LOGIC_VECTOR(motors-1 downto 0);
	signal null_state_high_p: STD_LOGIC_VECTOR(motors-1 downto 0);
	--signal null_pulse	: STD_LOGIC_VECTOR(0 downto 0);

	--signals for angular encoding
	signal angle		: unsigned(15 downto 0);
	signal angle_vector : angle_array;
	signal mechanical_vector: angle_array;

	--signals for reset and setup during reset:
	signal setup_timer	: integer range 0 to setup_time:=0;
	signal rst_core 	: STD_LOGIC;
	signal rst_encoder 	: STD_LOGIC;

	--signals for override vectors:
	signal en_override	: STD_LOGIC := '0'; --when '1', we control amp and angle. --UPDATES ON LAST INPUT SIGNAL
	signal th_ow		: override_th;
	signal amp_ow		: override_amp;

	signal pwm_pins		: pwm_pin_config;
	signal clk_PWM		: STD_LOGIC;
	signal i_out_internal 	: dq_array;
	signal data_vector_output : STD_LOGIC_VECTOR(15 downto 0);
	
	signal iq_ref0_l	: STD_LOGIC_VECTOR(15 downto 0);
	--signal iq_ref1_l	: STD_LOGIC_VECTOR(15 downto 0);
	signal angle_override_l	:  STD_LOGIC_VECTOR(15 downto 0);
	signal amp_override_l	:  STD_LOGIC_VECTOR(15 downto 0);


	--Parameters when scaling:
	--signal iq_ref1	: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

	type ADC_MOTOR_INDEX is array(ADC_NUM-1 downto 0, 7 downto 0) of integer range 0 to (motors-1);
	type ADC_Current_INDEX is array(ADC_NUM-1 downto 0, 7 downto 0) of integer range 0 to 2;

	signal motor_index_ADC : ADC_MOTOR_INDEX :=((0,0,1,1,1,0,0,0), others =>(0,0,0,0,0,0,0,0) );-- (5,4,4,4,3,3,3,2), (7,7,7,6,6,6,5,5), (10,10,9,9,9,8,8,8),(0,0,0,0,11,11,11,10)); --needed others here for one adc
	signal abc_index_ADC : ADC_CURRENT_INDEX :=((1,0,2,1,0,2,1,0), others =>(0,0,0,0,0,0,0,0));-- (0,2,1,0,2,1,0,2), (2,1,0,2,1,0,2,1), ( 2, 1,0,2,1,0,2,1),(0,0,0,0, 2, 1, 0, 1)); --needed others here for one adc
	
	
	--function to convert adc data to actual signed value
	function normalize_current_funk( inp_value : STD_LOGIC_VECTOR(bits_adc-1 downto 0) ) return signed is
	   variable mid_extended : STD_LOGIC_VECTOR(current_domain_bits-1 downto 0);
	   begin
	       mid_extended(current_domain_bits-1 downto bits_adc-1) := (others => not inp_value(bits_adc-1));
	       mid_extended(bits_adc-2 downto 0) := inp_value(bits_adc-2 downto 0);
	       return signed(mid_extended);
	end function;
	
begin


--process to update the current measured by the adc.
update_current	: process (en_i_spi,clk_main,rst) is
variable motor_num          : integer range 0 to motors-1;
variable abc_index_current : integer range 0 to 2;--a,b,c (0,1,2)
begin
	if rising_edge(clk_main) then
		if rst = '1' then
			--If we reset, then every signal should be 0
			--i_abc(0)<= (others => to_signed(0, current_domain_bits));
			--i_abc(1)<= (others => to_signed(0, current_domain_bits));
			--i_abc(2)<= (others => to_signed(0, current_domain_bits));
			--counter_samples <= 0;
			valid_power_h <= (others => '0');
			valid_power_l <= (others => '0');
		else
			current_ia   <= STD_LOGIC_VECTOR(i_abc(0)(0));
            		current_ib   <= STD_LOGIC_VECTOR(i_abc(1)(0));
			for adc in ADC_NUM-1 downto 0 loop
				if en_i_spi(adc) = '1' then --if we have a output from the adc.
					motor_num:=motor_index_ADC(adc,i_idx(adc)); --get the correct motor this signal is mapped to.
					if (valid_power_h(motor_num)='1') or (valid_power_l(motor_num)='1') then --Can be split up into two if statements to only sample on one of them.
						valid_power_h(motor_num)<= '0'; --set low when we trigger. overwritten later if we are still in sample area.
						valid_power_l(motor_num)<= '0'; --set low when we trigger. overwritten later if we are still in sample area.
						abc_index_current := abc_index_ADC(adc,i_idx(adc)); --find out if its current a,b or c
						i_abc(abc_index_current)(motor_num)<= normalize_current_funk(i_sen(adc)); --the current has now been shifted from min num beeing 0 to a negative number.
					end if;			
				end if;
			end loop;
			
			--Code block for setting valid signals spi data
			--to use this, valid_power_h/l has to be vectors. would also need to rewrite code above
			for adc in ADC_NUM-1 downto 0 loop
				if en_i_spi(adc) = '1' then --if output from adc
					--update the output so the next is valid from the adc
					valid_power_h(motor_index_ADC(adc,i_idx(adc))) <= null_state_high(motor_index_ADC(adc,i_idx(adc)));
					valid_power_l(motor_index_ADC(adc,i_idx(adc))) <= null_state_low(motor_index_ADC(adc,i_idx(adc)));
				end if;
			end loop; --adc

		end if; --rst
	end if; --clk
end process;	
	
setup : process (rst, clk_main) is
begin
	if rising_edge(clk_main) then
		if rst = '1' then
			setup_timer 	<= 0;
			rst_core 	<= '1';
			rst_encoder 	<= '1';
			en_gate		<= (others => '0');
		else
			rst_encoder	<= '0';

			if(setup_timer = setup_time_en) then
				rst_core <= '0';
				setup_timer <= setup_timer +1;
			elsif setup_timer = setup_time then
			    en_gate <= (others => '1');
			else 
				setup_timer <= setup_timer +1;
			end if; --timing
		end if; --rst, else
	end if; --rising_edge
end process;

--process to sync controller parameters
process(clk_main) is
begin
	if rising_edge(clk_main) then
	    KPd <= signed(KP_d);
	    KId <= signed(KI_d);
	    KPq <= signed(KP_q);
	    KIq <= signed(KI_q);
	end if;
end process;


get_adc_dat : process(clk_main,rst) is
begin
    if rising_edge(clk_main) then
    if rst = '0' then
	for adc in ADC_NUM-1 downto 0 loop
		if en_spi_output(adc)='1' then
		    i_sen(adc) <= i_sen_dir(adc);
		    i_idx(adc)<= to_integer(i_idx_dir(adc));
		    en_i_spi(adc)<= '1';
		else
		    en_i_spi(adc)<= '0';
        	end if;--en
	end loop;
    end if;--rst
    end if;--edge
end process;

set_ow_signals : process(clk_main) is
begin
    if rising_edge(clk_main) then
        ow_loop: for m in motors-1 downto 0 loop
            th_ow(m)	<= unsigned(angle_override);
            amp_ow(m)	<= unsigned(amp_override);
            id_ref_vec(m)	<= to_signed(0,16);
        end loop;
    end if;
end process;


detect_ow: process(clk_main,rst) is
begin
    if rising_edge(clk_main) then
    --owerride enables when a change in ow signals are detected
        iq_ref0_l <= iq_ref0;
        --iq_ref1_l <= iq_ref1;
        angle_override_l    <= angle_override;
        amp_override_l      <= amp_override;
        
        if rst = '1' then
            en_override<= '0';
        else
            if not ((angle_override=angle_override_l) or (amp_override=amp_override_l)) then
                en_override<= '1';
            end if;
            if not ((iq_ref0=iq_ref0_l)) then --or (iq_ref1=iq_ref1_l)) then
                en_override<= '0';
            end if;
        end if;
    end if;
end process;

core_motor : entity work.top port map(clk_main => clk_main, clk_pwm => clk_PWM, rst => rst, en_override => en_override, id_ref => id_ref_vec, iq_ref => iq_ref_vec, th_override => th_ow, amp_override => amp_ow, theta_mechanical => mechanical_vector, null_state_h => null_state_high, null_state_l => null_state_low, i_a => i_abc(0), i_b => i_abc(1), i_c => i_abc(2), KP_d => KPd, KI_d => KId, KP_q => KPq, KI_q => KIq, pwm_pins => pwm_pins, i_out => i_out_internal);

Gen_angle_encoders: for m in (motors-1 ) downto 0 GENERATE
    angular_encoder : entity work.encoder port map(clk => clk_main, rst => rst_encoder, CH_I => CHI(m), CH_A => CHA(m), CH_B => CHB(m), angle => mechanical_vector(m));
end GENERATE;


gen_ADC_S : for adc in ADC_NUM-1 downto 0 GENERATE
	current_SENSOR : entity work.spi_v3 generic map(measurement_select => adc_mask_arr(adc)) port map(clk_in => clk_main, rst => rst, MISO => MISO(adc), MOSI => MOSI(adc), clk_master => SPI_clk(adc), CS => CS(adc), data_out => i_sen_dir(adc), idx_out => i_idx_dir(adc), en_out => en_spi_output(adc));
end GENERATE;


--set signals
i_out 		<= signed(i_out_internal(0));
--IO_16   	<= '0';
angle_out 	<= mechanical_vector(0);
clk_PWM		<= clk_main;
--set special types:
iq_ref_vec(0)	<= signed(iq_ref0);
iq_ref_vec(1)	<= signed(iq_ref1);
--iq_ref_vec(2)	<= signed(iq_ref2);
--iq_ref_vec(3)	<= signed(iq_ref3);
--iq_ref_vec(4)	<= signed(iq_ref4);
--iq_ref_vec(5)	<= signed(iq_ref5);
--iq_ref_vec(6)	<= signed(iq_ref6);
--iq_ref_vec(7)	<= signed(iq_ref7);
--iq_ref_vec(8)	<= signed(iq_ref8);
--iq_ref_vec(9)	<= signed(iq_ref9);
--iq_ref_vec(10)	<= signed(iq_ref10);
--iq_ref_vec(11)	<= signed(iq_ref11);

pwm_motor0	<= pwm_pins(0);
pwm_motor1	<= pwm_pins(1);
--pwm_motor2	<= pwm_pins(2);
--pwm_motor3	<= pwm_pins(3);
--pwm_motor4	<= pwm_pins(4);
--pwm_motor5	<= pwm_pins(5);
--pwm_motor6	<= pwm_pins(6);
--pwm_motor7	<= pwm_pins(7);
--pwm_motor8	<= pwm_pins(8);
--pwm_motor9	<= pwm_pins(9);
--pwm_motor10	<= pwm_pins(10);
--pwm_motor11	<= pwm_pins(11);

end architecture;
