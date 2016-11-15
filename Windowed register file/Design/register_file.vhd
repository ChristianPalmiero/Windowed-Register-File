library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use ieee.numeric_std.all;
use work.constants.all;

-- This module implements the physical RF
entity register_file is
	generic ( 
		width_word : integer := width;
		in_out_reg_number : integer := in_out_reg;	-- # of IN-OUT registers
		local_reg_number : integer := local_reg;	-- # of LOCAL registers
		f : integer := fw; 				-- # of windows
		m : integer := mw;				-- # of global registers
		depth : integer := depth_w;			-- # of registers in the physical RF
		address_width : integer := log2(depth_w)	-- physical address
	);
	
	port(
		-- 1 write port, 2 read ports
		data_in_port_w : in std_logic_vector(width_word-1 downto 0);
		data_out_port_a : out std_logic_vector(width_word-1 downto 0);
		data_out_port_b : out std_logic_vector(width_word-1 downto 0);
		address_port_a : in std_logic_vector(address_width-1 downto 0);
		address_port_b : in std_logic_vector(address_width-1 downto 0);
		address_port_w : in std_logic_vector(address_width-1 downto 0);
		--active high signal, synchronous R/W
		r_signal_port_a : in std_logic;
		r_signal_port_b : in std_logic;
		w_signal : in std_logic;
		--synchronous reset, enable active high
		reset,clock,enable : in std_logic
	);

end register_file;

architecture Behavioral of register_file is
	
	type regFile is array(0 to depth-1) of std_logic_vector(width_word-1 downto 0);
	signal registers : regFile;

begin

regFileProcess : process (clock) is
	 begin
    if(clock = '1' and clock'event)then
		if(reset = '1')then
			registers <= (others =>(others =>'0'));
		else
			if(enable = '1')then
				-- Read A before bypass, in case the read signal is asserted
				if(r_signal_port_a = '1')then
					data_out_port_a <= registers(to_integer(unsigned(address_port_a)));
				end if;
				
				-- Read B before bypass, in case the read signal is asserted
				if(r_signal_port_b = '1')then
					data_out_port_b <= registers(to_integer(unsigned(address_port_b)));
				end if;
				
				-- Write and bypass, in case the read signal is asserted
				if w_signal = '1' then
				  registers(to_integer(unsigned(address_port_w))) <= data_in_port_w;  -- Write
				  if address_port_a = address_port_w then  -- Bypass for read A
					 data_out_port_a <= data_in_port_w;
				  end if;
				  if address_port_b = address_port_w then  -- Bypass for read B
					 data_out_port_b <= data_in_port_w;
				  end if;
				end if;
			else 
				data_out_port_a <= (others => 'Z');
				data_out_port_b <= (others => 'Z');
			end if;	--enable if
		end if; --reset if
		
    end if; --clock if
 end process;

end Behavioral;

configuration CFG_RF_BEH of register_file is
 
	for Behavioral
  
	end for;

end configuration;