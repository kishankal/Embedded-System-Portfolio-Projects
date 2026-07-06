\# Day 3 — GPIO Interrupt + AXI Timer



\*\*Phase:\*\* 2 — Embedded C on Vitis

\*\*Topic:\*\* GIC interrupts, ISR, AXI Timer, concurrent tasks

\*\*Tools:\*\* Vivado + Vitis 2025.2, Target board: PYNQ-Z2 (xc7z020clg400-1)



\## What's in this folder



| File | Description |

|---|---|

| `interrupt\_app.c` | Button interrupt ISR + AXI Timer 1-second blink running together |



\## Hardware Setup (Vivado Block Design)



\- Zynq7 PS block (IRQ\_F2P enabled)

\- AXI SmartConnect

\- AXI GPIO (leds\_4bits + btns\_4bits, interrupt enabled)

\- AXI Timer

\- Concat block: GPIO ip2intc\_irpt → In0, Timer interrupt → In1, dout → IRQ\_F2P



\## Interrupt Flow

BTN pressed
↓
AXI GPIO detects edge
↓
ip2intc_irpt goes HIGH (1-bit)
↓
Concat In0
↓
Concat dout[1:0]
↓
IRQ_F2P on Zynq PS
↓
GIC (Generic Interrupt Controller) inside PS
↓
ARM Cortex-A9 receives IRQ
↓
CPU saves state → jumps to ISR
↓
Your C function runs
↓
Clear interrupt → return
↓
CPU continues where it left off

## Key Fix — Vitis 2025.2 SDT Interrupt ID Offset

Raw PL interrupt ID from xparameters.h = 29
GIC requires +32 offset for PL interrupts on Zynq
Final working ID = 61

```c
#define GPIO_IRQ_ID  (XPAR_FABRIC_AXI_GPIO_0_INTR + 32)  // = 61
```

## Concepts Covered

- ISR (Interrupt Service Routine) — short, fast, flag-based
- volatile keyword — prevents compiler optimization of ISR flags
- GIC initialization and ISR registration flow
- XScuGic_Connect() + XScuGic_Enable() + Xil_ExceptionEnable()
- AXI Timer countdown mode — 50MHz clock, 50000000 counts = 1 second
- XTmrCtr_SetOptions, SetResetValue, Start, IsExpired, Stop
- Two concurrent tasks in main loop (timer + interrupt)

## Verification

Tested on PYNQ-Z2:
- LD0 blinks every 1 second via AXI Timer
- Button press fires ISR instantly, independent of timer
- Both tasks run simultaneously without interfering

