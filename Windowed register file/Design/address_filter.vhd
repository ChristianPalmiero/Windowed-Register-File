library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.constants.all;

-- THIS MODULE IS A COMBINATIONAL MODULE THAT TRANSLATES THE VIRTUAL ADDRESS INTO THE PHYSICAL ADDRESS
entity address_filter is
	generic ( 
		width_word : integer := width;
		in_out_reg_number : integer := in_out_reg;	-- # of IN-OUT registers
		local_reg_number : integer := local_reg;	-- # of LOCAL registers
		f : integer := fw; 				-- # of windows
		m : integer := mw;				-- # of global registers
		n : natural := nw;				-- # of registers in each IN-LOCAL-OUT window
		depth : integer := depth_w;			-- # of registers in the physical RF
		address_width : integer := log2(depth_w);	-- physical address
		address_ext : integer := log2(mw+nw)		-- virtual address
	);
	port (
		-- Virtual addresses
		address_port_read_one : in std_logic_vector(address_ext-1 downto 0);
		address_port_read_two : in std_logic_vector(address_ext-1 downto 0);
		address_port_write : in std_logic_vector(address_ext-1 downto 0);
		cwp_in : in std_logic_vector( log_port-1 downto 0);
		-- Physical addresses
		address_port_read_one_out : out std_logic_vector(address_width-1 downto 0);
		address_port_read_two_out : out std_logic_vector(address_width-1 downto 0);
		address_port_write_out : out std_logic_vector(address_width-1 downto 0)
	);
end address_filter;

architecture Behavioral of address_filter is
	
begin

	address_translate : process (address_port_read_one,address_port_read_two,address_port_write, cwp_in)
	
	variable cwp : integer;
	variable add_rd_one : integer;
	variable add_rd_two : integer;
	variable add_wr : integer;

		begin
			cwp := to_integer(unsigned(cwp_in));
			add_rd_one := to_integer(unsigned(address_port_read_one));
			add_rd_two := to_integer(unsigned(address_port_read_two));
			add_wr := to_integer(unsigned(address_port_write));

			-- PHYSICAL ADDRESS = VIRTUAL ADDRESS + CWP*(LOCAL+IN_OUT);

			if(to_integer(unsigned(address_port_read_one)) < mw) then
				address_port_read_one_out <= '0' & address_port_read_one;
			else 
				address_port_read_one_out <= std_logic_vector(to_unsigned(cwp*(local_reg_number+in_out_reg_number)+add_rd_one, address_port_read_one_out'length));
			end if;

			if(to_integer(unsigned(address_port_read_two)) < mw) then
				address_port_read_two_out <= '0' & address_port_read_two;
			else 
				address_port_read_two_out <= std_logic_vector(to_unsigned(cwp*(local_reg_number+in_out_reg_number)+add_rd_two, address_port_read_two_out'length));
			end if;
			
			if(to_integer(unsigned(address_port_write)) < mw) then
				address_port_write_out <= '0' & address_port_write;
			else 
				address_port_write_out <= std_logic_vector(to_unsigned(cwp*(local_reg_number+in_out_reg_number)+add_wr, address_port_write_out'length));
			end if;
	end process;
end Behavioral;

configuration CFG_ADDRF_BEH of address_filter is
 
	for Behavioral
  
	end for;
end configuration;