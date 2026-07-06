/*
 * ═══════════════════════════════════════════════════════════════
 * PROJECT  : Phase 2 Day 4 — UART Polled + Command Parser
 * BOARD    : PYNQ-Z2 (Zynq-7020, xc7z020clg400-1)
 * TOOLS    : Vivado + Vitis 2025.2
 * ═══════════════════════════════════════════════════════════════
 *
 * UART PROTOCOL BASICS:
 * ─────────────────────────────────────────────────────────────
 * UART = Universal Asynchronous Receiver Transmitter
 * Just 2 wires: TX (transmit) and RX (receive)
 * No clock wire — both sides agree on baud rate beforehand
 *
 * Frame format (8N1 — most common):
 *   [START][D0][D1][D2][D3][D4][D5][D6][D7][STOP]
 *   START = LOW, STOP = HIGH, Data LSB first
 *   115200 baud → 1 bit = 8.68us, full byte = 86.8us
 *
 * PS UART vs AXI UART Lite:
 *   PS UART  : hardened silicon inside Zynq PS, uses MIO pins,
 *              fast, reliable, supports FIFO and flow control
 *   AXI UART : soft IP in PL fabric, uses FPGA resources (LUTs/FFs)
 *   Today    : PS UART (XUartPs) — connected to PROG/UART USB port
 *
 * IMPORTANT LESSON LEARNED:
 *   Never mix xil_printf() and XUartPs in same program
 *   xil_printf() initializes UART with its own settings
 *   causing baud rate conflict and garbled output
 *   Use ONLY XUartPs functions when controlling UART directly
 *
 * POLLED MODE FLOW:
 *   1. LookupConfig → CfgInitialize → SetBaudRate
 *   2. TX: XUartPs_Send() → blocks until sent
 *   3. RX: XUartPs_IsReceiveData() → XUartPs_Recv()
 *   4. CPU waits during TX/RX
 *
 * COMMAND PARSER FLOW:
 *   1. Read chars one by one until Enter (\r)
 *   2. Build string in buffer
 *   3. strcmp() against known commands
 *   4. Execute action → send response
 * ─────────────────────────────────────────────────────────────
 *
 * FUNCTION REFERENCE TABLE:
 * ─────────────────────────────────────────────────────────────
 * XUartPs_LookupConfig()
 *      Purpose : Find UART hardware config from base address
 *      Use     : Returns config struct with clock freq, base addr
 *
 * XUartPs_CfgInitialize()
 *      Purpose : Initialize UART driver with found configuration
 *      Use     : Sets up internal driver state, maps hardware
 *
 * XUartPs_SetBaudRate()
 *      Purpose : Set UART communication speed
 *      Use     : Must match PuTTY — we use 115200
 *                Call BEFORE sending any data
 *
 * XUartPs_Send()
 *      Purpose : Transmit buffer of bytes over UART TX
 *      Use     : Polled — blocks until all bytes sent
 *                Returns number of bytes actually sent
 *
 * XUartPs_Recv()
 *      Purpose : Receive bytes from UART RX FIFO
 *      Use     : Returns immediately with available bytes
 *                Returns 0 if no data available
 *
 * XUartPs_IsReceiveData()
 *      Purpose : Check if RX FIFO has data waiting
 *      Use     : Non-blocking check before XUartPs_Recv()
 *                Returns 1 if data available, 0 if empty
 * ─────────────────────────────────────────────────────────────
 */

#include "xuartps.h"    // PS UART driver
#include "xgpio.h"      // AXI GPIO driver
#include "string.h"     // strcmp, memset, strlen

// UART settings
#define UART_BASEADDR    XPAR_XUARTPS_0_BASEADDR
#define BAUD_RATE        115200

// GPIO settings
#define LED_CHANNEL      1

// Command buffer
#define CMD_BUFFER_SIZE  32

// Driver instances
XUartPs uart;
XGpio   gpio;

/*
 * uart_send — Send string over UART
 * Never use xil_printf after XUartPs initialized
 * Use this function for all UART output
 */
void uart_send(const char *str)
{
    XUartPs_Send(&uart, (u8*)str, strlen(str));
}

/*
 * process_command — Parse and execute received command
 * Uses strcmp for exact string matching
 * Controls LEDs and sends response over UART
 */
void process_command(char *cmd)
{
    if(strcmp(cmd, "led on") == 0)
    {
        // Turn all 4 LEDs ON — 0xF = 1111 in binary
        XGpio_DiscreteWrite(&gpio, LED_CHANNEL, 0xF);
        uart_send("LEDs ON\r\n");
    }
    else if(strcmp(cmd, "led off") == 0)
    {
        // Turn all 4 LEDs OFF — 0x0 = 0000 in binary
        XGpio_DiscreteWrite(&gpio, LED_CHANNEL, 0x0);
        uart_send("LEDs OFF\r\n");
    }
    else if(strcmp(cmd, "led1") == 0)
    {
        // Turn only LD0 ON — bit 0 = 1
        XGpio_DiscreteWrite(&gpio, LED_CHANNEL, 0x1);
        uart_send("LED1 ON\r\n");
    }
    else if(strcmp(cmd, "led2") == 0)
    {
        // Turn only LD1 ON — bit 1 = 1
        XGpio_DiscreteWrite(&gpio, LED_CHANNEL, 0x2);
        uart_send("LED2 ON\r\n");
    }
    else if(strcmp(cmd, "led3") == 0)
    {
        // Turn only LD2 ON — bit 2 = 1
        XGpio_DiscreteWrite(&gpio, LED_CHANNEL, 0x4);
        uart_send("LED3 ON\r\n");
    }
    else if(strcmp(cmd, "led4") == 0)
    {
        // Turn only LD3 ON — bit 3 = 1
        XGpio_DiscreteWrite(&gpio, LED_CHANNEL, 0x8);
        uart_send("LED4 ON\r\n");
    }
    else if(strcmp(cmd, "status") == 0)
    {
        // Read current LED state and report
        u32 led_val = XGpio_DiscreteRead(&gpio, LED_CHANNEL);
        char buf[32];
        // Build response string manually (no printf available)
        uart_send("LED status: 0x");
        // Convert hex value to string manually
        char hex[3];
        hex[0] = "0123456789ABCDEF"[(led_val >> 4) & 0xF];
        hex[1] = "0123456789ABCDEF"[led_val & 0xF];
        hex[2] = '\0';
        uart_send(hex);
        uart_send("\r\n");
    }
    else if(strcmp(cmd, "help") == 0)
    {
        // Print all available commands
        uart_send("Commands:\r\n");
        uart_send("  led on   → All LEDs ON\r\n");
        uart_send("  led off  → All LEDs OFF\r\n");
        uart_send("  led1     → LED1 only\r\n");
        uart_send("  led2     → LED2 only\r\n");
        uart_send("  led3     → LED3 only\r\n");
        uart_send("  led4     → LED4 only\r\n");
        uart_send("  status   → Show LED state\r\n");
        uart_send("  help     → Show this menu\r\n");
    }
    else
    {
        uart_send("Unknown command! Type 'help'\r\n");
    }
}

int main()
{
    int status;
    XUartPs_Config *uart_config;

    // ── Step 1: Initialize GPIO ───────────────────────────────
    XGpio_Initialize(&gpio, XPAR_AXI_GPIO_0_BASEADDR);
    XGpio_SetDataDirection(&gpio, LED_CHANNEL, 0x0); // LEDs = output
    XGpio_DiscreteWrite(&gpio, LED_CHANNEL, 0x0);    // start with LEDs OFF

    // ── Step 2: Initialize PS UART ────────────────────────────
    // PS UART0 = connected to PROG/UART USB port on PYNQ-Z2
    // No new Vivado IP needed — PS UART is built into Zynq PS silicon
    uart_config = XUartPs_LookupConfig(UART_BASEADDR);
    XUartPs_CfgInitialize(&uart, uart_config, uart_config->BaseAddress);

    // ── Step 3: Set Baud Rate ─────────────────────────────────
    // Set BEFORE sending any data
    // Must match PuTTY exactly — 115200 baud
    XUartPs_SetBaudRate(&uart, BAUD_RATE);

    // Small delay to let baud rate settle before sending
    volatile int i;
    for(i = 0; i < 1000000; i++);

    // ── Step 4: Send Welcome Banner ───────────────────────────
    uart_send("\r\n");
    uart_send("================================\r\n");
    uart_send("  PYNQ-Z2 UART Command Console  \r\n");
    uart_send("================================\r\n");
    uart_send("Type 'help' for commands\r\n");
    uart_send("> ");  // command prompt

    // ── Step 5: Main Loop — Command Parser ────────────────────
    // Reads characters one by one
    // Builds command string until Enter pressed
    // Processes complete command string
    char cmd_buffer[CMD_BUFFER_SIZE];
    int  cmd_index = 0;
    memset(cmd_buffer, 0, CMD_BUFFER_SIZE);

    while(1)
    {
        // Non-blocking check for received character
        if(XUartPs_IsReceiveData(UART_BASEADDR))
        {
            u8 ch;
            XUartPs_Recv(&uart, &ch, 1);

            // Echo character back so user sees what they type
            XUartPs_Send(&uart, &ch, 1);

            if(ch == '\r')
            {
                // Enter pressed — process command
                uart_send("\r\n");
                cmd_buffer[cmd_index] = '\0'; // null terminate

                if(cmd_index > 0)
                    process_command(cmd_buffer);

                // Reset for next command
                memset(cmd_buffer, 0, CMD_BUFFER_SIZE);
                cmd_index = 0;
                uart_send("> "); // show prompt again
            }
            else if(ch == '\b' || ch == 0x7F)
            {
                // Backspace — remove last character
                if(cmd_index > 0)
                {
                    cmd_index--;
                    uart_send("\b \b"); // erase on terminal
                }
            }
            else if(cmd_index < CMD_BUFFER_SIZE - 1)
            {
                // Normal character — add to buffer
                cmd_buffer[cmd_index++] = ch;
            }
        }
    }

    return 0;
}