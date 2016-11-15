library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity control_unit is
	port (
		clock, reset, enable: in std_logic;
		call : in std_logic;				-- If call signal high, a CALL has been executed
		ret : in std_logic;				-- If ret signal high, a RET has been executed
		mmu_ack : in std_logic;				-- If ack high, the MMU transaction is terminated
		cwp_out : out std_logic_vector(log_port-1 downto 0);	-- Cwp needed for the address_filter module
		swp_out : out std_logic_vector(log_port-1 downto 0);	-- Swp needed for the MMU module
		--mmu_bus : buffer std_logic_vector(width_word-1 downto 0);
		fill : out std_logic;				-- If fill signal high, the MMU performs a POP
		spill : out std_logic				-- If spill signal high, the MMU performs a PUSH
	);
end control_unit;

architecture Behavioral of control_unit is
	signal cwp, swp :  std_logic_vector(log_port-1 downto 0);
	signal cansave,canrestore : std_logic_vector(log_port-1 downto 0);

	type Statetype is (S_Off,S_on1,S_Call,S_ret,S_wait_spill,S_wait_fill);
	signal CurrState : Statetype;
	
begin
	process (clock)
	variable temp : integer;
	begin
		IF (Reset= '1') THEN
			Currstate<= S_Off;
		ELSE
			case Currstate is 	
			-- Reset state
			when S_Off => 
				swp <= (others => '0');
				cwp <= (others => '1');
				cansave <= std_logic_vector(to_unsigned(fw, cansave'length));
				canrestore <= (others => '0');
				Currstate <= S_on1;
	
			-- In this state, the FSM waits either for a CALL or for a RETURN
			when S_on1 =>
				if(call='1') then
					canrestore <= canrestore + 1;
					cansave <= cansave - 1;
					temp := to_integer(unsigned(cwp +1)) mod fw;
					cwp <= std_logic_vector(to_unsigned(temp, cwp'length));
					Currstate <= S_call;
				elsif (ret='1') then 
					canrestore <= canrestore - 1;
					cansave <= cansave + 1;
					temp := to_integer(unsigned(cwp -1));
					if (temp > (fw-1)) then 
						temp:= fw-1;
					end if;
					cwp <= std_logic_vector(to_unsigned(temp, cwp'length));
					Currstate <= S_ret;
				else 
					Currstate <= S_on1;
				end if;
	
			-- In the case of a CALL, if cansave is equal to 0, a SPILL operation must be performed
			when S_call => 
				if(cansave=(cansave'range=>'0')) then
					spill <= '1';
					temp := to_integer(unsigned(swp +1)) mod fw;
					swp <= std_logic_vector(to_unsigned(temp, swp'length));
					cansave <= cansave + 1;
					canrestore <= canrestore -1;
					Currstate <= S_wait_spill;
				else 
					Currstate <= S_on1;
				end if;
	
			-- In the case of a RET, if canrestore is equal to 0, a FILL operation must be performed
			when S_ret => 	
				if(canrestore=(canrestore'range=>'0')) then
					fill <= '1';
					temp := to_integer(unsigned(swp -1));
					if (temp > (fw-1)) then 
						temp:= fw-1;
					end if;
					swp <= std_logic_vector(to_unsigned(temp, swp'length));
					canrestore <= canrestore + 1;
					cansave <= cansave - 1;
					Currstate <= S_wait_fill;
				else 
					Currstate <= S_on1;
				end if;
	
			-- Wait for spill states
			when S_wait_spill =>
				spill<='0';
				if(mmu_ack='1') then 
					Currstate <= s_on1;
				else
					Currstate <= s_wait_spill;
				end if;
	
			-- Wait for fill states
			when S_wait_fill =>
				fill<='0';
				if(mmu_ack='1') then 
					Currstate <= s_on1;
				else
					Currstate <= s_wait_fill;
				end if;

			-- Safe state
			when others =>
				Currstate <= S_off;
			end case;
		end if;
	end process;	
	
	-- Concurrent assignment
	cwp_out <= cwp;
	swp_out <= swp;

end Behavioral;

configuration CFG_FSM_BEH of control_unit is
	for Behavioral
	end for;
end configuration;