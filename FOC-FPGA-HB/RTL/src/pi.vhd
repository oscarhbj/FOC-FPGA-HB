library IEEE;
 	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use work.config.all;

--its just a pi controller.
--This controller should be replaced.  to optimize chip consumption one would want a shared controller instead of independent controllers. As for this implementation we have not shared them, and one can therefore replace the controller on a per motor basis.
entity pi is
generic(
	input_width	: integer := 	work.config.dq_domain_bits;
	output_width	: integer := 	work.config.dq_domain_bits;
	total_shift	: integer :=	10
);
port(
	clk,rst,str_update		: in STD_LOGIC;
	desired_value, current_value	: in STD_LOGIC_VECTOR(input_width-1 downto 0);
	KP_s,KI_s : in signed(15 downto 0);
	commando_out			: out STD_LOGIC_VECTOR(output_width-1 downto 0);
	en_out                 : out STD_LOGIC
);
end entity;

Architecture RTL of pi is

signal i_sum 	: signed(31 downto 0);
signal en_next  : STD_LOGIC_vector(3 downto 0) 					:= (others => '0');
signal commando_internal    : signed(31 downto 0);
signal Kp_d : signed(31 downto 0);
signal Ki_d : signed(31 downto 0);
signal delta_value  : signed(input_width downto 0);
signal input_sum    : signed(31 downto 0);
signal KP_value : signed(15 downto 0);
signal KI_value : signed(15 downto 0);
signal desired_value_internal : signed(desired_value'length downto 0);

function safe_add(a,b: signed) return signed is
	variable mid_result 		: signed(a'length-1 downto 0);
begin
	mid_result := resize(a+b,mid_result'length);
	if a(a'length-1) = b(b'length-1) then 
		--if both numbers has the same sign a overflow/underflow might have happened
		if (a(a'length-1) = '1') and (mid_result(mid_result'length-1)='0') then
			--both had a negative sign and we ended up positive. a underflow as happened
			mid_result := (others => '0'); --1000...
			mid_result(mid_result'length-1) :='1';

		elsif (a(a'length-1) = '0') and (mid_result(mid_result'length-1)='1') then
			--both had a positive sign and we ended up negative. a underflow as happened
			mid_result := (others => '1'); --0111...
			mid_result(mid_result'length-1):='0';
	    end if;
	end if;
	return mid_result;
end function;



begin
	process(clk,rst) is
	variable current_value_check : signed(current_value'length-1 downto 0);
	begin
		if rising_edge(clk) then
			--update internal desired value:
			desired_value_internal <= resize(signed(desired_value),desired_value_internal'length);

			--Update internal Kp and Ki constants:
			KP_value <= KP_s;
			KI_value <= KI_s;

			--Sync enable signals to clock cycles:
			en_next(en_next'length-1 downto 1) <= en_next(en_next'length-2 downto 0);
			en_next(0)	<= str_update;

			--Send the result out with the final strobe signal.
			en_out 		<= en_next(en_next'length-1);
			commando_out	<= STD_LOGIC_VECTOR(resize(commando_internal(commando_internal'length-1 downto total_shift), commando_out'length));
			
			if rst then
				i_sum <= to_signed(0,i_sum'length);
				commando_internal <= to_signed(0,commando_internal'length);
				en_next <= (others =>'0');
				delta_value<= to_signed(0, delta_value'length);
			else
				if (str_update) then
				    --current_value_check := signed(current_value); --ensure that there is no wrong data. maximum value here should be around 1024
				    --if abs(current_value_check) < 2**(bits_adc-1) then
					   delta_value <=desired_value_internal - resize(signed(current_value),current_value'length+1); --Diff (desired-current) extend one bit.
				    --end if;
				end if;
				if en_next(0)='1' then
					Ki_d	<= resize((KI_value*delta_value),Ki_d'length);		--KI*delta_value (can use delta here since the time intervall is equal every time.
				   	Kp_d	<= resize((KP_value*delta_value),Kp_d'length);		--KP*delta_value
				end if;
				if en_next(1)='1' then
					i_sum <= safe_add(i_sum, Ki_d); --update integral.
				end if;
				if (en_next(2)='1') then
					commando_internal <= safe_add(Kp_d, i_sum); --32 bits;
				end if;
			end if;	
		end if;
	end process;
end architecture;
