# Custom AXI IP — Zero-Crossing Detector (Hardware Square Root via Binary Search)

A custom AXI4-Lite hardware peripheral built in VHDL that computes √8 using a binary-search algorithm implemented entirely in fixed-point hardware logic — no divider or square-root circuit used — controlled from a bare-metal C application on the Zynq-7000 ARM Cortex-A9 processor.

## What This Project Demonstrates

- Binary search algorithm implemented as a hardware FSM
- Fixed-point arithmetic in VHDL (int16.10 / int32.20 format)
- Multi-step iterative hardware computation (16 iterations, ~6 clock cycles each)
- A "done" status flag handshake between hardware and software
- Full Zynq SoC integration and bare-metal application development in Vitis
- Real hardware verification on a PYNQ-Z2 board

## How It Works

The function under test is f(x) = 8 − x². The algorithm searches for the x where f(x) = 0 (i.e. x = √8) by repeatedly halving a search interval:

1. Software writes initial left and right search bounds.
2. Software pulses a "start" trigger bit.
3. The FSM computes the midpoint, evaluates f(midpoint), and narrows the bound that is wrong.
4. This repeats for 16 iterations, each time doubling the precision.
5. The FSM raises a "done" flag and holds it until the next search starts.
6. Software reads back the final answer (in fixed-point format) and converts it to a normal decimal value.

## Register Map

| Register  | Read / Write   | Purpose                                                              |
|-----------|----------------|-----------------------------------------------------------------------|
| slv_reg0  | Write          | Initial left search bound (leftv)                                     |
| slv_reg1  | Write          | Initial right search bound (rightv)                                   |
| slv_reg2  | Write + Read   | Write: bit 0 = start trigger. Read: bit 16 = done flag, bits[15:0] = answer (newx) |
| slv_reg3  | Read           | Last computed function value (newy) — for debugging                   |

## Folder Structure

```
zerocross/
├── zerocross.xpr                              # Vivado project file
├── zerocross.srcs/                            # Block design sources
├── ip_repo/zerocross_ip_1_0/                  # Packaged custom AXI IP (VHDL source in hdl/)
├── updated_design_1_wrapper.xsa                # Exported hardware platform for Vitis
├── vitis_src/zerocross_test.c                  # Bare-metal C test application
└── documentation/ZeroCrossing_Documentation.docx   # Full write-up: design, build steps, problems & fixes
```

## Result (verified on PYNQ-Z2 hardware via UART/PuTTY)

```
Starting Zero Crossing Test...
Wrote leftv = 0, rightv = 3072
Start pulsed. Waiting for done...
Done detected! reg2 = 0x00010B50
newx (raw fixed-point) = 2896
Approx sqrt(8) = 2.828
```
(2896 / 1024 = 2.828125 — accurate to 3 decimal places against the true value 2.828427…, in only 16 iterations.)

## Key Problems Solved

- Library conflict: two VHDL libraries defining the same `signed` type — resolved by using only `numeric_std`
- 32-bit width mismatch when packing a status flag and result into a single register
- "Done" flag being cleared automatically every idle cycle before software could ever read it — fixed by only clearing it when a new search actually starts

Full details, step-by-step build instructions, and the complete problems/fixes list are in `documentation/ZeroCrossing_Documentation.docx`.

## Tools Used

Vivado 2025.2 · Vitis 2025.2 · VHDL (fixed-point arithmetic) · PYNQ-Z2 (Zynq-7020) · PuTTY (UART, 115200 baud)
