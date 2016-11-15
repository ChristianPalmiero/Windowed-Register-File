library IEEE;
use work.constants.all;
use IEEE.std_logic_1164.all;

entity TBFSM is
end TBFSM;

architecture TEST of TBFSM is
	
       signal call : std_logic := '0';
       signal clock : std_logic := '0';
       signal reset, enable, ret, fill, spill, mmu_ack, ra, rb, w : std_logic;
       signal CWPOUT, SWPOUT: std_logic_vector(1 downto 0);
       signal data_in, data_out_a, data_out_b : std_logic_vector(31 downto 0);
       signal add_w, add_r_a, add_r_b : std_logic_vector(4 downto 0);

component register_file_top_entity is
	generic ( 
		width_word : integer := width;
		m : integer := mw;
		n : natural := nw;
		address_ext : integer := log2(mw+nw);
		log_port_rf : integer := log_port
	);
	port (
		-- 1 write port, 2 read ports
		data_in_port_w : in std_logic_vector(width_word-1 downto 0);
		data_out_port_a : out std_logic_vector(width_word-1 downto 0);
		data_out_port_b : out std_logic_vector(width_word-1 downto 0);
		address_port_read_one : in std_logic_vector(address_ext-1 downto 0);
		address_port_read_two : in std_logic_vector(address_ext-1 downto 0);
		address_port_write : in std_logic_vector(address_ext-1 downto 0);
		--active high signal, synchronous R/W
		r_signal_port_a : in std_logic;
		r_signal_port_b : in std_logic;
		w_signal : in std_logic;
		--synchronous reset, enable active high
		clock, reset, enable: in std_logic;
		-- Control signals
		call : in std_logic;				
		ret : in std_logic;				
		mmu_ack : in std_logic;				
		cwp_out : out std_logic_vector(log_port_rf-1 downto 0);	
		swp_out : out std_logic_vector(log_port_rf-1 downto 0);	
		fill : out std_logic;			
		spill : out std_logic	
	);
end component;

begin 

uut:register_file_top_entity

PORT MAP (data_in, data_out_a, data_out_b, add_r_a, add_r_b, add_w, ra, rb, w, clock, reset, enable, call, ret, mmu_ack, cwpout, swpout, fill, spill);
	
	reset<='0', '1' after 4 ns, '0' after 8 ns;
	mmu_ack <= '1';
	call<='1' after 10 ns, '0' after 12 ns,'1' after 20 ns, '0' after 22 ns, '1' after 36 ns,
	'0' after 38 ns, '1' after 52 ns, '0' after 54 ns, '1' after 82 ns, '0' after 84 ns;
	ret<='0', '1' after 66 ns, '0' after 68 ns, '1' after 98 ns, '0' after 100 ns, '1' after 114 ns,
	'0' after 116 ns, '1' after 130 ns, '0' after 132 ns;

	PCLOCK : process(CLocK)
	begin
		CLocK <= not(CLocK) after 1 ns;	
	end process;
	
end TEST;

---
configuration CFG_TESTFSM of TBFSM is
  for TEST
	for UUT:register_file_top_entity
		use configuration WORK.CFG_RF;
	end for; 
  end for;
end CFG_TESTFSM;
