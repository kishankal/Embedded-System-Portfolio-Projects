\# Day 1 — VHDL Foundations: Combinational Logic



\*\*Phase:\*\* 1 — VHDL Foundations

\*\*Topic:\*\* Basic gates, MUX, Adders

\*\*Tools:\*\* Xilinx Vivado 2025.2, Target board: PYNQ-Z2 (xc7z020clg400-1)



\## What's in this folder



| File | Description |

|---|---|

| `and\_gate.vhd` / `and\_gate\_tb.vhd` | 2-input AND gate + testbench |

| `or\_gate.vhd` / `or\_gate\_tb.vhd` | 2-input OR gate + testbench |

| `not\_gate.vhd` / `not\_gate\_tb.vhd` | 1-input NOT gate + testbench |

| `xor\_gate.vhd` / `xor\_gate\_tb.vhd` | 2-input XOR gate + testbench |

| `mux2to1.vhd` / `mux2to1\_tb.vhd` | 2:1 multiplexer (1-bit select) + testbench |

| `mux4to1.vhd` / `mux4to1\_tb.vhd` | 4:1 multiplexer (2-bit select, case statement) + testbench |

| `half\_adder.vhd` / `half\_adder\_tb.vhd` | Half adder (sum, carry) + testbench |

| `full\_adder.vhd` / `full\_adder\_tb.vhd` | Full adder (sum, cout, 3-input) + testbench |



\## Concepts covered



\- Entity / architecture structure, STD\_LOGIC and STD\_LOGIC\_VECTOR

\- Concurrent signal assignment vs. process blocks

\- if-else and case statements for selection logic

\- Writing and simulating testbenches

\- Exhaustive test case coverage (2^n combinations for n-input circuits)



\## Verification



All designs simulated in Vivado's behavioral simulator (XSIM) and waveforms checked against truth tables.



\## Notes



Pure combinational logic — no clock, no memory.

