library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package CONSTANTS is
  function log2( arg : integer) return integer;
  constant IVDELAY : time := 0.1 ns;
  constant NDDELAY : time := 0.2 ns;
  constant NDDELAYRISE : time := 0.6 ns;
  constant NDDELAYFALL : time := 0.4 ns;
  constant NRDELAY : time := 0.2 ns;
  constant DRCAS : time := 1 ns;
  constant DRCAC : time := 2 ns;
  constant N_mux: integer := 4;
  constant TP_MUX : time := 0.5 ns;
  constant n_mul : integer := 8;
  constant N_add : integer := n_mul*2;
  constant width : integer := 32;		-- register width
  constant in_out_reg : integer := 6;		-- # of IN-OUT registers
  constant local_reg : integer := 10;		-- # of LOCAL registers
  constant fw : integer := 3; 			-- # of windows
  constant mw : integer := 10;			-- # of global registers
  constant nw : natural := in_out_reg*2+local_reg;	-- # of registers in each IN-LOCAL-OUT window
  -- depth : # of registers in the physical RF
  constant depth_w : integer := (local_reg + in_out_reg)*fw + in_out_reg + mw;
  constant log_port : integer := 2;
  
end CONSTANTS;

package body CONSTANTS is

  function log2 ( arg: integer )  return integer is
    variable temp    : integer := arg;
    variable result : integer := 0;
  begin
    while temp > 1 loop
      result := result + 1;
      temp    := temp / 2;
    end loop;
    return result;
  end function log2 ;

end CONSTANTS;
