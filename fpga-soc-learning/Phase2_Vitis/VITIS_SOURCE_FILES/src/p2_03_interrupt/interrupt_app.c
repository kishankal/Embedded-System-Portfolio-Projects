/*
 * ═══════════════════════════════════════════════════════════════
 * PROJECT  : Phase 2 Day 3 — GPIO Interrupt + AXI Timer
 * BOARD    : PYNQ-Z2 (Zynq-7020, xc7z020clg400-1)
 * TOOLS    : Vivado + Vitis 2025.2
 * ═══════════════════════════════════════════════════════════════
 *
 * FUNCTION REFERENCE TABLE:
 * ─────────────────────────────────────────────────────────────
 * XScuGic_Initialize()
 *      Purpose : Initialize the GIC driver
 *      Use     : Must be called before any other GIC function
 *
 * XScuGic_Connect()
 *      Purpose : Register ISR function for a specific interrupt ID
 *      Use     : Links interrupt ID to your ISR function
 *
 * XScuGic_Enable()
 *      Purpose : Enable a specific interrupt ID in GIC
 *      Use     : GIC won't forward interrupt until enabled
 *
 * Xil_ExceptionRegisterHandler()
 *      Purpose : Tell ARM CPU where the GIC handler is
 *      Use     : Links ARM IRQ vector to XScuGic_InterruptHandler
 *
 * Xil_ExceptionEnable()
 *      Purpose : Enable ARM CPU exception/interrupt handling
 *      Use     : Final master switch — must be called last
 *
 * XGpio_InterruptEnable()
 *      Purpose : Enable interrupt on specific GPIO channel
 *      Use     : Use XGPIO_IR_CH2_MASK for channel 2 (buttons)
 *
 * XGpio_InterruptGlobalEnable()
 *      Purpose : Master enable for all GPIO interrupts
 *      Use     : Global ON switch for GPIO IP interrupts
 *
 * XGpio_InterruptClear()
 *      Purpose : Clear interrupt flag inside GPIO
 *      Use     : MUST call in ISR or ISR fires infinitely
 *
 * XTmrCtr_Initialize()
 *      Purpose : Initialize AXI Timer driver
 *      Use     : Must be called before using timer functions
 *
 * XTmrCtr_SetOptions()
 *      Purpose : Configure timer mode (countdown, auto-reload etc.)
 *      Use     : XTC_DOWN_COUNT_OPTION = count down from loaded value
 *
 * XTmrCtr_SetResetValue()
 *      Purpose : Load countdown start value into timer
 *      Use     : Value = desired_time_seconds x timer_clock_hz
 *                Timer clock = 50MHz → 1 second = 50,000,000 counts
 *
 * XTmrCtr_Start()
 *      Purpose : Start the timer counting
 *      Use     : Timer begins counting down immediately after this
 *
 * XTmrCtr_IsExpired()
 *      Purpose : Check if timer has reached zero
 *      Use     : Returns 1 when countdown complete
 *
 * XTmrCtr_Stop()
 *      Purpose : Stop the timer
 *      Use     : Call after IsExpired to reset for next use
 * ─────────────────────────────────────────────────────────────
 *
 * INTERRUPT FLOW:
 *      BTN pressed
 *          ↓
 *      AXI GPIO detects edge
 *          ↓
 *      ip2intc_irpt goes HIGH (1-bit)
 *          ↓
 *      Concat In0
 *          ↓
 *      Concat dout[1:0]
 *          ↓
 *      IRQ_F2P on Zynq PS
 *          ↓
 *      GIC (Generic Interrupt Controller) inside PS
 *          ↓
 *      ARM Cortex-A9 receives IRQ
 *          ↓
 *      CPU saves state → jumps to ISR
 *          ↓
 *      Your C function runs
 *          ↓
 *      Clear interrupt → return
 *          ↓
 *      CPU continues where it left off
 *
 * TIMER FLOW:
 *      Load 50,000,000 into timer (= 1 second at 50MHz)
 *          ↓
 *      XTmrCtr_Start() — hardware starts counting down
 *          ↓
 *      CPU free to do other work (check btn_pressed flag)
 *          ↓
 *      XTmrCtr_IsExpired() returns 1 when zero reached
 *          ↓
 *      Toggle LED → reload timer → repeat
 * ═══════════════════════════════════════════════════════════════
 */

#include "xgpio.h"          // AXI GPIO driver
#include "xscugic.h"        // GIC driver
#include "xtmrctr.h"        // AXI Timer driver
#include "xil_exception.h"  // ARM exception handling
#include "xil_printf.h"     // Lightweight UART print

// GPIO channels
#define LED_CHANNEL         1   // Channel 1 = LEDs (output)
#define BTN_CHANNEL         2   // Channel 2 = Buttons (input)

// GPIO interrupt ID
// Raw PL interrupt = 29, +32 GIC offset = 61
#define GPIO_IRQ_ID         (XPAR_FABRIC_AXI_GPIO_0_INTR + 32)

// Timer settings
// Timer clock = 50MHz (FCLK_CLK0 from Zynq PS)
// 1 second = 50,000,000 counts
#define TIMER_DEVICE_ID     XPAR_XTMRCTR_0_BASEADDR
#define TIMER_COUNTER_0     0           // use timer counter 0
#define TIMER_1_SECOND      50000000    // 50MHz x 1s

// Driver instances — global so ISR and main can both access
XGpio gpio;         // AXI GPIO driver instance
XScuGic gic;        // GIC driver instance
XTmrCtr timer;      // AXI Timer driver instance

// volatile flags — can change anytime from ISR
volatile int btn_pressed = 0;   // set by ISR, cleared by main
volatile u32 btn_value   = 0;   // button value captured in ISR

// Timer LED state — toggles every 1 second
u32 timer_led = 0x1;            // starts with LD0 ON

/*
 * gpio_isr — Button Interrupt Service Routine
 * Called automatically by GIC when button state changes
 * Rules:
 *   - Short and fast only
 *   - Set flag, clear interrupt, return
 *   - Never use sleep() inside ISR
 */
void gpio_isr(void *callback_ref)
{
    XGpio *gpio_ptr = (XGpio*)callback_ref;

    // Capture button value at moment of interrupt
    btn_value = XGpio_DiscreteRead(gpio_ptr, BTN_CHANNEL);

    // Set flag for main loop to handle
    btn_pressed = 1;

    // Clear interrupt — MUST do this or ISR fires forever
    XGpio_InterruptClear(gpio_ptr, XGPIO_IR_CH2_MASK);
}

int main()
{
    int status;
    XScuGic_Config *gic_config;

    // ── Step 1: Initialize GPIO ───────────────────────────────
    status = XGpio_Initialize(&gpio, XPAR_AXI_GPIO_0_BASEADDR);
    xil_printf("GPIO Init: %s\r\n", status == XST_SUCCESS ? "OK" : "FAIL");

    // LEDs = output (0x0), Buttons = input (0xF)
    XGpio_SetDataDirection(&gpio, LED_CHANNEL, 0x0);
    XGpio_SetDataDirection(&gpio, BTN_CHANNEL, 0xF);

    // ── Step 2: Initialize AXI Timer ─────────────────────────
    status = XTmrCtr_Initialize(&timer, TIMER_DEVICE_ID);
    xil_printf("Timer Init: %s\r\n", status == XST_SUCCESS ? "OK" : "FAIL");

    // Configure timer: countdown mode
    // XTC_DOWN_COUNT_OPTION = count down from loaded value to zero
    XTmrCtr_SetOptions(&timer, TIMER_COUNTER_0, XTC_DOWN_COUNT_OPTION);

    // Load 1 second countdown value
    XTmrCtr_SetResetValue(&timer, TIMER_COUNTER_0, TIMER_1_SECOND);
    xil_printf("Timer configured: 1 second countdown\r\n");

    // ── Step 3: Initialize GIC ────────────────────────────────
    gic_config = XScuGic_LookupConfig(XPAR_XSCUGIC_0_BASEADDR);
    xil_printf("GIC Config: %s\r\n", gic_config != NULL ? "OK" : "NULL");

    status = XScuGic_CfgInitialize(&gic, gic_config,
                                   gic_config->CpuBaseAddress);
    xil_printf("GIC Init: %s\r\n", status == XST_SUCCESS ? "OK" : "FAIL");

    // ── Step 4: Register GPIO ISR with GIC ───────────────────
    // Link interrupt ID 61 to gpio_isr function
    status = XScuGic_Connect(&gic, GPIO_IRQ_ID,
                             (Xil_InterruptHandler)gpio_isr,
                             (void*)&gpio);
    xil_printf("GIC Connect: %s\r\n", status == XST_SUCCESS ? "OK" : "FAIL");

    // ── Step 5: Enable interrupts ─────────────────────────────
    XScuGic_Enable(&gic, GPIO_IRQ_ID);     // enable in GIC
    XGpio_InterruptEnable(&gpio, XGPIO_IR_CH2_MASK);  // enable ch2
    XGpio_InterruptGlobalEnable(&gpio);    // master enable GPIO
    xil_printf("Interrupts enabled\r\n");

    // ── Step 6: Connect GIC to ARM exception handler ──────────
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                                 (Xil_ExceptionHandler)XScuGic_InterruptHandler,
                                 &gic);
    Xil_ExceptionEnable();  // unmask IRQ at ARM CPU level
    xil_printf("Exception handler registered\r\n");

    // ── Step 7: Start Timer ───────────────────────────────────
    XTmrCtr_Start(&timer, TIMER_COUNTER_0);
    xil_printf("Timer started!\r\n");

    xil_printf("System ready!\r\n");
    xil_printf("- Timer blinks LD0 every 1 second\r\n");
    xil_printf("- Press buttons to light corresponding LEDs\r\n");

    // ── Main Loop ─────────────────────────────────────────────
    // Two things happening simultaneously:
    // 1. Timer polling — blinks LED every 1 second
    // 2. Interrupt handling — button press lights LED instantly
    while(1)
    {
        // ── Timer Task ────────────────────────────────────────
        // Check if 1 second countdown complete
        if(XTmrCtr_IsExpired(&timer, TIMER_COUNTER_0))
        {
            // Toggle timer LED (LD0 only)
            timer_led = (timer_led == 0x1) ? 0x0 : 0x1;
            XGpio_DiscreteWrite(&gpio, LED_CHANNEL, timer_led);
            xil_printf("Timer tick — LED: %s\r\n",
                       timer_led ? "ON" : "OFF");

            // Restart timer for next 1 second
            XTmrCtr_Stop(&timer, TIMER_COUNTER_0);
            XTmrCtr_SetResetValue(&timer, TIMER_COUNTER_0, TIMER_1_SECOND);
            XTmrCtr_Start(&timer, TIMER_COUNTER_0);
        }

        // ── Button Interrupt Task ─────────────────────────────
        // Handle button press flagged by ISR
        if(btn_pressed)
        {
            xil_printf("BTN interrupt! Value: 0x%X\r\n", btn_value);
            // Overwrite timer LED with button value temporarily
            XGpio_DiscreteWrite(&gpio, LED_CHANNEL, btn_value);
            btn_pressed = 0;
        }
    }

    return 0;
}