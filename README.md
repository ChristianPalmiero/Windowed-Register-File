# Simple Register File
The simple register file is a behavioral VHDL netlist describing a parametric register file entity with the following specifications:
* M registers
* N bitwidth
* 1 write port
* 2 read ports
* synchronous R/W on the clock rising edge if R1/R2/W signal active (high)
* synchronous reset
* enable signal active high
* simultaneous read and write capabilities

A 64-entry register file with 32-bit registers is synthesized with Synopsys Design Compiler and the design is mapped on a 0.045 μm library.

# Windowed_Register_File
The simple register file is transformed in a structure that allows context switching when a subroutine is called. 
The following parameters are used:
* M for the number of global registers
* N for the number of registers in each of the IN or OUT or LOCAL window (fixed window)
* F for the number of windows

The structure is similar to the one in the figure below: on the right there is the structure of the physical RF and
on the left the part of the physical RF that are included in the active window.
Four registers are necessary to transform the virtual in the physical RF and to manage the
moment in which the RF must SPILL/FILL to/from memory without the need of eccessive HW.
These registers are SWP, CWP, CANSAVE, CANRESTORE and are used only internally.
Four further signals at least are necessary as I/O of you RF: CALL and RETURN for subroutine
management, and FILL and SPILL when data are to be moved from and to the memory respectively. 

![alt text](https://github.com/ChristianPalmiero/Windowed_Register_File/blob/master/RF_Windowed.png "RF Windowed")

#### Within a SUB
For each subroutine the external blocks see only the active window. The whole
active window is composed by the ensemble of the global registers, of one IN, one LOCAL and
one OUT block of N registers. The fact that data will be written in a IN or LOCAL does not
depend on the RF control: it only receives an address related to that active window and has to
transform in an actual address to the physical register file.
In order to transform the external address into the physical address, a few registers
which save the values of pointers are used. The Current Window Pointer (CWP) holds the pointer to
the IN block of the current window. During normal operations within a subroutine, the CWP
is used to transform the the external address to the physical address.
#### SUB call
A signal CALL is risen, for example by the control unit or decode stage. When a
new subroutine is called (CALL active) the CWP is shifted by 2 × N positions so that OUT of
current window becomes a IN of next window. This can be done provided that new windows are
available in the physical register. This information (new windows are still available, if not see
SPILL below) is stored in the CANSAVE register. 
#### SUB return 
When the current subroutine gives a RETURN, then the CWP is shifted back of 2×N
positions, provided that the window correspondent to the parent subdirectory is present in the
register file (otherwise see FILL below). This information (parent is in RF) is stored in the
CANRESTORE register.
#### SPILL
In case no more registers are available, a SPILL in memory must be performed for the
oldest IN-LOCAL blocks. This operation means that the RF rises the SPILL signal to an ex-
ternal block (e.g. the MMU) the reads the bus where the RF puts the data in the window to
be spilled. This operation cannot be executed in one clock cycle: only one register at each clock cycle is spilled.
The CWP that must be correctly updated (this is used as a circular buffer). At the end of this operation
the SAVED WINDOW POINTER (SWP) holds the pointer to the RF address (or block
number) which is no more in the RF.
#### FILL
It happens sooner or later that the values spilled must be fed again in the RF from memory.
This is detected when the CWP (that is being decremented as during a return phase) equalizes
the SWP: this means that a further decrement of CWP must be preceeded by a FILL. For this
the RF rises the SPILL command. Once the fill is concluded also the CWP and the SWP should be updated.

Writing and reading to/from memory is not our concern. Finally, no controller is written here.

A 64-entry register file with 32-bit registers is synthesized with Synopsys Design Compiler and the design is mapped on a 0.045 μm library.
