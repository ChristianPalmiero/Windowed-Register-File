library IEEE;
use IEEE.std_logic_1164.all;	
use WORK.constants.all; 	

entity  register_file_top_entity is
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

end register_file_top_entity;


architecture struct of register_file_top_entity is

	component address_filter is
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
		address_port_read_one : in std_logic_vector(address_ext-1 downto 0);
		address_port_read_two : in std_logic_vector(address_ext-1 downto 0);
		address_port_write : in std_logic_vector(address_ext-1 downto 0);
		cwp_in : in std_logic_vector( log_port-1 downto 0);
		address_port_read_one_out : out std_logic_vector(address_width-1 downto 0);
		address_port_read_two_out : out std_logic_vector(address_width-1 downto 0);
		address_port_write_out : out std_logic_vector(address_width-1 downto 0)
	);
	end component;
	
	component register_file is
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
		data_in_port_w : in std_logic_vector(width_word-1 downto 0);
		data_out_port_a : out std_logic_vector(width_word-1 downto 0);
		data_out_port_b : out std_logic_vector(width_word-1 downto 0);
		address_port_a : in std_logic_vector(address_width-1 downto 0);
		address_port_b : in std_logic_vector(address_width-1 downto 0);
		address_port_w : in std_logic_vector(address_width-1 downto 0);
		r_signal_port_a : in std_logic;
		r_signal_port_b : in std_logic;
		w_signal : in std_logic;
		reset,clock,enable : in std_logic
	);
	end component;

	component control_unit is
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
	end component;

	signal cwp_in : std_logic_vector( log_port-1 downto 0);
	signal address_port_read_one_out, address_port_read_two_out, address_port_write_out : std_logic_vector(log2(depth_w)-1 downto 0);

	
begin

	AF : address_filter
	port map ( address_port_read_one, address_port_read_two, address_port_write, cwp_in, address_port_read_one_out, address_port_read_two_out,
	address_port_write_out);

	RF: register_file
	port map (data_in_port_w, data_out_port_a, data_out_port_b, address_port_read_one_out, address_port_read_two_out, address_port_write_out, r_signal_port_a, r_signal_port_b, w_signal, reset, clock, enable);
	
	CU: control_unit
	port map (clock, reset, enable, call, ret, mmu_ack, cwp_out, swp_out, fill, spill);
        

end struct;



configuration CFG_RF of register_file_top_entity is
	for struct
		for AF : address_filter
			use configuration WORK.CFG_ADDRF_BEH;
		end for;
                for RF : register_file
                   use configuration WORK.CFG_RF_BEH;
                end for;
                for CU : control_unit
                   use configuration WORK.CFG_FSM_BEH;
                end for;
	end for;
end CFG_RF;