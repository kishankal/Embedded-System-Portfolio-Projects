#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "sleep.h"

#define IP_BASEADDR   XPAR_ZEROCROSS_IP_0_BASEADDR

#define REG0_OFFSET   0x00   // leftv initial value (write)
#define REG1_OFFSET   0x04   // rightv initial value (write)
#define REG2_OFFSET   0x08   // bit0 = start (write) | bit16 = done, bits[15:0] = newx (read)
#define REG3_OFFSET   0x0C   // newy (read)

int main()
{
    int leftv_init  = 0;         // initial left bound = 0.0 in int16.10 format
    int rightv_init = 3 * 1024;  // initial right bound = 3.0 in int16.10 format

    u32 reg2_val;
    int done;
    int newx_raw;
    float newx_actual;
    int timeout;

    xil_printf("Starting Zero Crossing Test...\r\n");

    Xil_Out32(IP_BASEADDR + REG0_OFFSET, (u32)leftv_init);
    Xil_Out32(IP_BASEADDR + REG1_OFFSET, (u32)rightv_init);

    xil_printf("Wrote leftv = %d, rightv = %d\r\n", leftv_init, rightv_init);

    // Pulse the start bit (bit 0 of reg2) - held longer this time
    Xil_Out32(IP_BASEADDR + REG2_OFFSET, 0x1);
    usleep(100);
    Xil_Out32(IP_BASEADDR + REG2_OFFSET, 0x0);

    xil_printf("Start pulsed. Waiting for done...\r\n");

    // Poll for done flag (bit 16 of reg2), with a timeout so we don't hang forever
    timeout = 100000;
    do {
        reg2_val = Xil_In32(IP_BASEADDR + REG2_OFFSET);
        done = (reg2_val >> 16) & 0x1;
        timeout--;
    } while (done == 0 && timeout > 0);

    if (timeout == 0) {
        xil_printf("TIMEOUT - done never went high! reg2 = 0x%08x\r\n", (unsigned int)reg2_val);
    } else {
        xil_printf("Done detected! reg2 = 0x%08x\r\n", (unsigned int)reg2_val);

        // Extract newx from bits [15:0] (signed 16-bit, fixed point int16.10)
        newx_raw = (int16_t)(reg2_val & 0xFFFF);
        newx_actual = (float)newx_raw / 1024.0;

        xil_printf("newx (raw fixed-point) = %d\r\n", newx_raw);
        xil_printf("Approx sqrt(8) = %d.%03d\r\n",
                    (int)newx_actual,
                    (int)((newx_actual - (int)newx_actual) * 1000));
    }

    return 0;
}