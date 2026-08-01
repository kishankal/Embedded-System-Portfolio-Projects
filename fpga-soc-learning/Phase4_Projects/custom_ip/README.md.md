# Custom AXI IP — 8-Value Mean Finder

A custom AXI4-Lite hardware peripheral built in VHDL that computes the mean (average) of 8 integers entirely in hardware, controlled by a bare-metal C application running on the Zynq-7000 ARM Cortex-A9 processor.

## What This Project Demonstrates

- Custom AXI4-Lite IP design and packaging in Vivado
- A hardware Finite State Machine (FSM) that performs accumulation and division
- A software/hardware handshake using a trigger-pulse + edge-detection pattern
- Full Zynq SoC integration: PS (Processing System) + PL (Programmable Logic)
- Bare-metal application development in Vitis
- Real hardware verification on a PYNQ-Z2 board

## How It Works

1. Software writes 8 integer values one at a time into an input register.
2. After each value, software pulses a trigger bit to tell hardware "a new value is ready."
3. A VHDL FSM detects the trigger, stores the value, and repeats until all 8 are collected.
4. The FSM sums all 8 values and divides by 8 (using a bit-shift, since plain division is not synthesizable in VHDL).
5. The final mean is placed in an output register for software to read.

## Register Map

| Register  | Direction | Purpose                                   |
|-----------|-----------|--------------------------------------------|
| slv_reg0  | Write     | Input data (one value at a time)           |
| slv_reg1  | Write     | Trigger bit (bit 0) — pulse to store value |
| slv_reg2  | Read      | Final computed mean                        |
| slv_reg3  | —         | Unused                                     |

## Folder Structure

```
custom_ip/
├── custom_ip.xpr                        # Vivado project file
├── custom_ip.srcs/                      # Block design sources
├── ip_repo/pynq_peripheral_1_0/         # Packaged custom AXI IP (VHDL source in hdl/)
├── design_1_wrapper.xsa                 # Exported hardware platform for Vitis
├── vitis_src/mean_finder_test.c         # Bare-metal C test application
└── documenation/Mean_Finder_Documentation.docx   # Full write-up: design, build steps, problems & fixes
```

## Result (verified on PYNQ-Z2 hardware via UART/PuTTY)

```
Starting Mean Finder Test...
Wrote value: 110
Wrote value: 200
Wrote value: 230
Wrote value: 140
Wrote value: 250
Wrote value: 360
Wrote value: 170
Wrote value: 980
Computed Mean = 305
TEST PASSED!
```

## Key Problems Solved

- Multiple-driver conflict on an output register (two processes writing the same signal)
- Software-writes-faster-than-hardware-clock timing bug, fixed with a trigger + edge-detect handshake
- Vivado IP revision caching — a source fix did not take effect until the IP instance was explicitly upgraded

Full details, step-by-step build instructions, and the complete problems/fixes list are in `documenation/Mean_Finder_Documentation.docx`.

## Tools Used

Vivado 2025.2 · Vitis 2025.2 · VHDL · PYNQ-Z2 (Zynq-7020) · PuTTY (UART, 115200 baud)
