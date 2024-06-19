library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

--Code for measurment of angle from incremental encoder.
--input: CH_A, CH_B, CH_I
--CH_A and CH_B: two square waves with halv a wave ofset from each other.
--CH_I : has one pulse every full mechanical rotation.

entity encoder is
	generic(
		MAX_angle		: integer	:= 20000-1;--5000 per channel. and we have half a cycle offset on two channels -> 4*5000 (-1 pga 0 is included)
		output_width	: integer	:= 16
	);
	port(
		clk	:	in 	STD_LOGIC;
		rst	: 	in 	STD_LOGIC;
		CH_I	: 	in 	STD_LOGIC;
		CH_A	:	in 	STD_LOGIC;
		CH_B	:	in 	STD_LOGIC;
		angle	: 	out	unsigned(output_width-1 downto 0)
				
	);
end entity;
--Takes in CH_A, CH_B  and CH_I
--returns angle

architecture RTL of encoder is
	constant k	: integer :=839;--number that we multiply with and shift down to make it span 16 bits; --105
	constant k_offset : integer := 24-output_width; --number of shifts for line above                  --21
	signal counter	: unsigned(output_width -1 downto 0);
	signal offset_I : unsigned(output_width -1 downto 0);
	signal prev_CH	: unsigned(1 downto 0); --chA, CHB
	signal configured_offset : std_logic := '0';
	signal CH_l1 : std_logic_vector(2 downto 0); --CHI,A,B
	signal current_CH : STD_LOGIC_VECTOR(2 downto 0); --IAB
	signal CH_IAB  : STD_LOGIC_VECTOR(2 downto 0);
	

begin

	count	: process(all) is
	variable direction : STD_LOGIC;
	variable valid_dir : STD_LOGIC;
	variable counter_new : unsigned(counter'length-1 downto 0);
	variable counter_k : unsigned(counter'length+k_offset-1 downto 0);
	begin
		if rising_edge(clk) then
			if rst = '1' then
				CH_IAB <= CH_I & CH_A & CH_B; --Force input signals
				prev_ch <= CH_A & CH_B;
				CH_l1 <= CH_I & CH_A & CH_B;
				current_CH <= CH_I & CH_A & CH_B;
				counter		<= to_unsigned(0,counter'length);
				offset_I      <= to_unsigned(0,offset_I'length);
				counter_new := to_unsigned(0,counter'length);
				configured_offset <= '0';
				
			else 
				CH_IAB <= CH_I & CH_A & CH_B;
				CH_l1 <= CH_IAB;
				if CH_IAB = CH_l1 then --if we have two of the same in a row we are certain that it is not noise.
				    current_CH <= CH_l1;
				end if;

				prev_ch <= unsigned(current_CH(1 downto 0));
                valid_dir := '0';
                
				--increase or decrease counter depending on input. (do nothing if equal or if we jumped two states.)
				case prev_CH is
					when "10" =>
						if (current_CH(1) = '1') and (current_CH(0) = '1') then
							direction := '1';
							valid_dir := '1';
						elsif (current_CH(1) = '0') and (current_CH(0) = '0') then
							direction := '0';
							valid_dir := '1';
						end if;
					when "11" =>
						if (current_CH(1) = '0') and (current_CH(0) = '1') then
							direction := '1';
							valid_dir := '1';
						elsif (current_CH(1) = '1') and (current_CH(0) = '0') then
							direction := '0';
							valid_dir := '1';
						end if;
					when "01" =>
						if (current_CH(1) = '0') and (current_CH(0) = '0') then
							direction := '1';
							valid_dir := '1';
						elsif (current_CH(1) = '1') and (current_CH(0) = '1') then
							direction := '0';
							valid_dir := '1';
						end if;
					when "00" =>
						if (current_CH(1) = '1') and (current_CH(0) = '0') then
							direction := '1';
							valid_dir := '1';
						elsif (current_CH(1) = '0') and (current_CH(0) = '1') then
							direction := '0';
							valid_dir := '1';
						end if;
				end case;
 
                --Logic to increase or decrease counter so we get the correct value
				if valid_dir = '1' then
				    if direction = '1' then
				        --Move upwards
				        if (counter = to_unsigned(MAX_angle,counter'length)) then
				            --Wrap around
				            counter_new := to_unsigned(0,counter'length);
				        else
				            --just increase
				            counter_new := counter +1;
				        end if;
				    else
				        if (counter = to_unsigned(0,counter'length)) then
				            --Wrap around
				            counter_new := to_unsigned(MAX_angle,counter'length);
				        else
				            --just decrease
				            counter_new:= counter -1;
				        end if;
				    end if;
				else
				    counter_new := counter;
				end if;
				--Sets the counter to the new result
				counter <= counter_new;
				
				--Syncronizes the counter so when CH_I is active and the other channels are low we have made a rotation
                
				if (current_CH(2) = '1') and (current_CH(1) = '0') and (current_CH(0) = '0') then
					if configured_offset then --IF we have rotated before we can sync up to this spot
					   counter <= offset_I;
					else --we have not made a rotation past this point before, and we can now add the offset to the logic so we can sync up every round and not drift.
					   offset_I <= counter_new;
					   configured_offset <= '1';
					end if;
				end if;
				
				--set output
				counter_k := resize(resize(counter,counter_k'length) * k,counter_k'length);
				angle <= counter_k(counter_k'length -1 downto k_offset);
			end if;
		end if;
	end process;

end architecture;
