\# Day 4 — UART: Polled Mode + Command Parser



\*\*Phase:\*\* 2 — Embedded C on Vitis

\*\*Topic:\*\* PS UART, polled TX/RX, command parser, two-way communication

\*\*Tools:\*\* Vivado + Vitis 2025.2, Target board: PYNQ-Z2 (xc7z020clg400-1)



\## What's in this folder



| File | Description |

|---|---|

| `uart\_app.c` | UART command console — type commands to control LEDs |



\## No New Vivado Project Needed



PS UART is built into Zynq PS silicon — no new IP block required.

Reused platform from Day 3 (pynq\_interrupt\_platform).



\## UART Protocol Basics



Frame format (8N1):

\[START]\[D0]\[D1]\[D2]\[D3]\[D4]\[D5]\[D6]\[D7]\[STOP]

\- START bit = LOW

\- 8 data bits, LSB first

\- STOP bit = HIGH

\- 115200 baud = 1 bit per 8.68 microseconds

\- Full byte (10 bits) = 86.8 microseconds



\## PS UART vs AXI UART Lite



| | PS UART | AXI UART Lite |

|---|---|---|

| Location | Inside PS silicon | PL fabric (FPGA) |

| Resources | No FPGA LUTs used | Uses LUTs and FFs |

| Speed | Fast, reliable | Simpler |

| Pins | MIO pins | EMIO/PL pins |

| Use | Main console/debug | Extra serial ports |



\## Important Lesson Learned



Never mix xil\_printf() and XUartPs in same program.

xil\_printf() initializes UART with its own settings causing baud rate

conflict and garbled output. Use ONLY XUartPs functions exclusively.



\## Command Parser Flow



1\. Read characters one by one from RX FIFO

2\. Echo each character back (so user sees what they type)

3\. Build string in buffer until Enter pressed

4\. strcmp() against known commands

5\. Execute action + send response over UART



\## Available Commands



| Command | Action |

|---|---|

| led on | All 4 LEDs ON |

| led off | All 4 LEDs OFF |

| led1 | LD0 only ON |

| led2 | LD1 only ON |

| led3 | LD2 only ON |

| led4 | LD3 only ON |

| status | Show current LED hex value |

| help | Show all commands |



\## Concepts Covered



\- XUartPs driver: LookupConfig, CfgInitialize, SetBaudRate

\- XUartPs\_Send() polled TX

\- XUartPs\_IsReceiveData() non-blocking RX check

\- XUartPs\_Recv() polled RX

\- Command buffer with backspace support

\- strcmp() for command parsing

\- Echo back for terminal user experience



\## Verification



Tested on PYNQ-Z2 with PuTTY (COM4, 115200 baud):

\- All 8 commands working correctly

\- LEDs respond immediately to commands

\- Backspace works in terminal

\- Unknown commands handled gracefully

