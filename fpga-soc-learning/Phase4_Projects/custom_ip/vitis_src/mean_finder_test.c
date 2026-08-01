#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "sleep.h"

#define IP_BASEADDR   XPAR_PYNQ_PERIPHERAL_0_BASEADDR

#define REG0_OFFSET   0x00
#define REG1_OFFSET   0x04
#define REG2_OFFSET   0x08

int main()
{
    int test_vals[8] = {110, 200, 230, 140, 250, 360, 170, 980};
    u32 mean_result;
    int i;

    xil_printf("Starting Mean Finder Test...\r\n");

    for (i = 0; i < 8; i++) {
        Xil_Out32(IP_BASEADDR + REG0_OFFSET, (u32)test_vals[i]);
        Xil_Out32(IP_BASEADDR + REG2_OFFSET, 0x1);
        usleep(10);
        Xil_Out32(IP_BASEADDR + REG2_OFFSET, 0x0);

        xil_printf("Wrote value: %d\r\n", test_vals[i]);
        usleep(100);
    }

    usleep(5000);

    mean_result = Xil_In32(IP_BASEADDR + REG1_OFFSET);
    xil_printf("Computed Mean = %d\r\n", (int)mean_result);

    if ((int)mean_result == 305) {
        xil_printf("TEST PASSED!\r\n");
    } else {
        xil_printf("TEST FAILED - expected 45\r\n");
    }

    return 0;
}