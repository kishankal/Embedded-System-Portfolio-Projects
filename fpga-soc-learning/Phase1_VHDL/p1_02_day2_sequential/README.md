\# Day 2 — VHDL Foundations: Sequential Logic



\*\*Phase:\*\* 1 — VHDL Foundations

\*\*Topic:\*\* Flip-flops, Registers, Counters, Clock Divider

\*\*Tools:\*\* Xilinx Vivado 2025.2, Target board: PYNQ-Z2 (xc7z020clg400-1)



\## What's in this folder



| File | Description |

|---|---|

| `dff\_sync.vhd` / `dff\_sync\_tb.vhd` | D Flip-Flop with synchronous reset |

| `dff\_async.vhd` / `dff\_async\_tb.vhd` | D Flip-Flop with asynchronous reset |

| `shift\_reg.vhd` / `shift\_reg\_tb.vhd` | 4-bit serial-in shift register |

| `parallel\_load\_reg.vhd` / `parallel\_load\_reg\_tb.vhd` | Register with reset/load/hold |

| `up\_counter.vhd` / `up\_counter\_tb.vhd` | 4-bit up counter |

| `up\_down\_counter.vhd` / `up\_down\_counter\_tb.vhd` | 4-bit up/down counter |

| `mod10\_counter.vhd` / `mod10\_counter\_tb.vhd` | Mod-10 counter |

| `clock\_divider.vhd` / `clock\_divider\_tb.vhd` | Clock divider |



\## Concepts covered



\- process(clk) and rising\_edge(clk) — synchronous design basics

\- Synchronous vs asynchronous reset

\- Clock-to-Q delay

\- Internal signal vs out port limitations

\- "No else = hold" inferred memory behavior

\- unsigned arithmetic via IEEE.NUMERIC\_STD.ALL

\- Overflow/underflow wraparound vs forced Mod-N wraparound

\- Clock division via counter + toggle



\## Verification



All designs simulated and verified in Vivado XSIM, including edge-case tests like async reset firing mid-cycle and hold behavior confirmation.



\## Notes



First day involving memory/state — designs "remember" values between clock cycles.

