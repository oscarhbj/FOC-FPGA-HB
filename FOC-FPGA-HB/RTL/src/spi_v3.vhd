library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

entity	spi_v3 is
	generic(
		clk_time	: integer := 4; --16.66...mhz 12.00 now
		bitwidth	: integer := 12;
		msg_width	: integer := 16;
		CPOL 		: STD_LOGIC := '1';--active
		CPHA		: STD_LOGIC := '1'; --sampeled on trailing edge
		measurement_select : STD_LOGIC_VECTOR(7 downto 0):= "00000111"
	);
	port(
		clk_in		:	in  STD_LOGIC;
		rst		:	in  STD_LOGIC;
		MISO		: 	in  STD_LOGIC; --SDO --leses på falling edge
		MOSI		:	out STD_LOGIC; --SDI --settes når klokka blir høy
		clk_master	:	out STD_LOGIC;
		CS		:	out STD_LOGIC:= '1'; --active low. (also called sync
		data_out	:	out STD_LOGIC_VECTOR(bitwidth-1 downto 0); --data from spi that has been converted to bits
		idx_out		: 	out unsigned(2 downto 0); --index found in data recieved (included all 4 bits now. should be 3)
		en_out		:	out STD_LOGIC

	);
end entity;

architecture RTL of spi_v3 is
signal cs_internal	: STD_LOGIC:= '1';
--signal internal_counter : integer range 0 to (clk_time*2) := 0;
signal internal_counter : unsigned(15 downto 0) := to_unsigned(0,16);
signal message_index	: unsigned(3 downto 0) := to_unsigned(0,4); --0 to 15;
signal message_number	: unsigned(2 downto 0) := to_unsigned(0,3); --0 to 7;
signal recorded_data	: STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
signal recorded_en	: STD_LOGIC := '0';

--signal MISO_l   : STD_LOGIC := '0';

--constants for timing of CS
constant min_synctime   : integer := 1*(clk_time*2);
constant max_time_sync  : integer := 10*clk_time;

constant message_time_total	: integer := msg_width*clk_time*2;
--signal off_time_sync		: integer := max_time_sync;
constant total_time		: integer := message_time_total+max_time_sync;
constant total_time_0idx	: integer := total_time-1;
--signal synced_timer		: integer range 0 to total_time-1 := 0;

signal off_time_sync    : unsigned(15 downto 0) := to_unsigned(max_time_sync,16);
signal synced_timer     : unsigned(15 downto 0) := to_unsigned(0,16);
--messages to send
--constant selection_port : STD_LOGIC_VECTOR(7 downto 0) := STD_LOGIC_VECTOR(to_unsigned(2**adc_measure -1,8));
--constant adc_sequen_top : STD_LOGIC_VECTOR(7 downto 0) := "0" & "0010" & "010"; 
--constant adc_sequen	: STD_LOGIC_VECTOR(msg_width-1 downto 0) := adc_sequen_top & selection_port;

constant adc_sequen	: STD_LOGIC_VECTOR(msg_width-1 downto 0) := "0" & "0010" & "010" & measurement_select;
constant adc_config	: STD_LOGIC_VECTOR(msg_width-1 downto 0) := "0" & "0100" & "000" & "01111111";
constant gpio_config: STD_LOGIC_VECTOR(15 downto 0) := x"4100";


constant reset_message	: STD_LOGIC_VECTOR(msg_width-1 downto 0) := "01111" & "00000000000";
constant zero_message	: STD_LOGIC_VECTOR(msg_width-1 downto 0) := (others => '0');
constant one_msg        : STD_LOGIC_VECTOR(msg_width-1 downto 0) := (others => '1');

--combined messages in array
constant total_diff_messages_out : integer := 8;
type message_array is	array ((total_diff_messages_out-1) downto 0) of STD_LOGIC_VECTOR(recorded_data'length-1 downto 0);
signal message_to_spi : message_array:= (zero_message,zero_message, adc_sequen, zero_message, adc_config, zero_message, zero_message, zero_message); --(4,3,2,1,0)

--signal message_to_spi : message_array:= (zero_message,one_msg, zero_message, one_msg, zero_message, one_msg, zero_message, one_msg); --(4,3,2,1,0)


begin

process (clk_in) is
begin
	if rising_edge(clk_in) then
	--MISO_l <= MISO;
	synced_timer 	<= synced_timer+1;
	if rst='1' then
		--external signals:
		en_out			<= '0';
		CS			<= '1';
		clk_master		<= CPOL;
		MOSI			<= '0';
		--internal signals
		cs_internal 		<= '1';
		--internal_counter 	<= 0;
		internal_counter <= to_unsigned(0,internal_counter'length);
		message_index		<= to_unsigned(0,message_index'length);
		recorded_en		<= '0';
		--synced_timer		<= 0;
		synced_timer <= to_unsigned(0,synced_timer'length);
		message_number		<= to_unsigned(0,message_number'length);
		--off_time_sync<= max_time_sync; --increase sync time for the first config signals
		off_time_sync <= to_unsigned(max_time_sync,off_time_sync'length);
	else
		--logic for output:
		en_out		<= '0';
		if recorded_en then
			idx_out 	<= unsigned(recorded_data(bitwidth+2 downto bitwidth));
			data_out	<= recorded_data(bitwidth-1 downto 0);
			en_out 		<= '1';
			recorded_en 	<= '0';
		end if;

		--logic to set cs_internal
		CS <= cs_internal; --one cycle behind the logic to set it.
		if synced_timer = off_time_sync then --complained when i used case...
			cs_internal 	<= '0';
			message_index    <= to_unsigned(0,message_index'length);
			MOSI <= message_to_spi(to_integer(message_number))(15);
		elsif to_integer(synced_timer) = message_time_total+to_integer(off_time_sync)	then
			cs_internal 	<= '1';
			--clk_master<= CPOL;
			synced_timer 	<= to_unsigned(0,synced_timer'length);
		end if;

		--logic for messages 
		if cs_internal ='0' then
			if  internal_counter = to_unsigned(clk_time-1,internal_counter'length) then
				clk_master		<= not CPOL;
				internal_counter	<= internal_counter +1;
				if CPHA then
					MOSI <= message_to_spi(to_integer(message_number))(to_integer(15-message_index));
				else
					recorded_data(to_integer(15-message_index))	<= MISO;
					message_index			<= message_index+1;
					--when we complete a transaction of 15 bits
					if (message_index = to_unsigned(15,message_index'length)) then
						recorded_en <= '1';
						--jump to sending the next message if we have more messages, else: repeat last
						if not (message_number=to_unsigned(total_diff_messages_out-1,message_number'length)) then
							message_number<= message_number +1;
					    else
					       		message_number<= message_number;
					       		off_time_sync<= to_unsigned(min_synctime,off_time_sync'length);					
						end if;
					end if; 
				end if;
			elsif internal_counter = to_unsigned(clk_time*2 -1,internal_counter'length) then
				clk_master <= CPOL;
				internal_counter <= to_unsigned(0,internal_counter'length);
				if CPHA then
					recorded_data(to_integer(15-message_index))	<= MISO;
					message_index			<= message_index+1;
					--when we complete a transaction of 15 bits
					if (message_index = to_unsigned(15,message_index'length)) then
						recorded_en <= '1';
						--synced_timer <= 0;
						--jump to sending the next message if we have more messages, else: repeat last
						if not (message_number=to_unsigned(total_diff_messages_out-1,message_number'length)) then
							message_number<= message_number +1;
					    else
					       		message_number<= message_number;
					       	    off_time_sync<= to_unsigned(min_synctime,off_time_sync'length);				
						end if;
					end if;
				else
					MOSI <= message_to_spi(to_integer(message_number))(to_integer(15-message_index));
					if (message_index = to_unsigned(15,message_index'length)) then
					      --synced_timer <= 0; 
					end if;
				end if;	
			else
				internal_counter <= internal_counter +1;
			end if;
		end if;				
	end if;
	end if;
end process;
end architecture;
