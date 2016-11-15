library IEEE;
use work.constants.all;
use IEEE.std_logic_1164.all;

entity TBREGISTERFILE is
end TBREGISTERFILE;

architecture TESTA of TBREGISTERFILE is
	
       signal CLK: std_logic := '0';
       signal RESET: std_logic;
       signal ENABLE: std_logic;
       signal RD1: std_logic;
       signal RD2: std_logic;
       signal WR: std_logic;
       signal ADD_WR: std_logic_vector(4 downto 0);
       signal ADD_RD1: std_logic_vector(4 downto 0);
       signal ADD_RD2: std_logic_vector(4 downto 0);
       signal DATAIN: std_logic_vector(31 downto 0);
       signal OUT1: std_logic_vector(31 downto 0);
       signal OUT2: std_logic_vector(31 downto 0);

component register_file

	generic (width_word : integer := width;
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
	
	end component;

begin 

RG:register_file
GENERIC MAP (32, 0, 0, 0, 0, 32, 5)
PORT MAP (DATAIN,OUT1,OUT2,ADD_RD1,ADD_RD2,ADD_WR,RD1,RD2,WR,RESET,CLK,ENABLE);
	RESET <= '1','0' after 5 ns;
	ENABLE <= '0','1' after 3 ns, '0' after 10 ns, '1' after 15 ns;
	WR <= '0','1' after 6 ns, '0' after 7 ns, '1' after 10 ns, '0' after 20 ns;
	RD1 <= '1','0' after 5 ns, '1' after 13 ns, '0' after 20 ns; 
	RD2 <= '0','1' after 17 ns;
	ADD_WR <= "10110", "01000" after 9 ns;
	ADD_RD1 <="10110", "01000" after 9 ns;
	ADD_RD2<= "11100", "01000" after 9 ns;
	DATAIN<=(others => '0'),(others => '1') after 8 ns;



	PCLOCK : process(CLK)
	begin
		CLK <= not(CLK) after 0.5 ns;	
	end process;

end TESTA;

---
configuration CFG_TESTRF of TBREGISTERFILE is
  for TESTA
	for RG : register_file
		use configuration WORK.CFG_RF_BEH;
	end for; 
  end for;
end CFG_TESTRF;
