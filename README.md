# Simple Register File
The simple register file is behavioral VHDL netlist describing a register file entity with the following specifications:
* 32 registers
* bitwidth = 64 bit
* 1 write port
* 2 read ports
* synchronous R/W on the clock rising edge if R1/R2/W signal active (high)
* synchronous reset
* enable signal active high
* simultaneous Read and Write capabilities

# Windowed_Register_File
VHDL design and synthesis of the windowed register file, a structure that allows context switching when a subroutine is called.
