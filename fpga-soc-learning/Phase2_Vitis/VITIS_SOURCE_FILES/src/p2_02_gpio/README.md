\# Day 2 — GPIO: LED Output + Button Input



\*\*Phase:\*\* 2 — Embedded C on Vitis

\*\*Topic:\*\* AXI GPIO IP, LED control, Button reading, Memory-mapped I/O

\*\*Tools:\*\* Vivado 2025.2 + Vitis 2025.2, Target board: PYNQ-Z2 (xc7z020clg400-1)



\## What's in this folder



| File | Description |

|---|---|

| `gpio\_btn.c` | Button-controlled LEDs — reads 4 buttons, drives 4 LEDs |



\## Hardware Setup (Vivado Block Design)



\- Zynq7 PS block → AXI SmartConnect → AXI GPIO IP

\- AXI GPIO Channel 1 (GPIO) → leds\_4bits (output, width=4)

\- AXI GPIO Channel 2 (GPIO2) → btns\_4bits (input, width=4)

\- Dual channel enabled



\## Concepts Covered



\- Memory-mapped I/O — ARM CPU controls hardware by writing to addresses

\- AXI GPIO IP configuration in Vivado IP Integrator

\- XGpio driver: Initialize, SetDataDirection, DiscreteWrite, DiscreteRead

\- XPAR\_AXI\_GPIO\_0\_BASEADDR — hardware address from xparameters.h

\- Channel 1 = output (LEDs), Channel 2 = input (buttons)

\- Button debounce using usleep()

\- Detecting state changes (prev\_btn vs btn\_value)



\## Button to LED Mapping



| Button | Value | LED |

|---|---|---|

| BTN0 | 0x1 | LD0 |

| BTN1 | 0x2 | LD1 |

| BTN2 | 0x4 | LD2 |

| BTN3 | 0x8 | LD3 |



\## Verification



Tested on PYNQ-Z2 board:

\- All 4 LEDs blink correctly with sleep(1) delay

\- Each button press lights corresponding LED immediately

\- Button release turns LED off

\- UART prints button value on state change



\## Key Code Pattern



```c

XGpio\_Initialize(\&gpio, XPAR\_AXI\_GPIO\_0\_BASEADDR);

XGpio\_SetDataDirection(\&gpio, LED\_CHANNEL, 0x0); // output

XGpio\_SetDataDirection(\&gpio, BTN\_CHANNEL, 0xF); // input

btn\_value = XGpio\_DiscreteRead(\&gpio, BTN\_CHANNEL);

XGpio\_DiscreteWrite(\&gpio, LED\_CHANNEL, btn\_value);

```



\## Notes



Vitis workspace kept outside Git repo at C:\\VITIS\_WORKSPACE\\p2\_03\\

Only source .c files pushed to GitHub.

