#include "xil_printf.h"

int main()
{
    xil_printf("Hello World from PYNQ-Z2!\r\n");
    xil_printf("Phase 2 - Embedded C on Vitis\r\n");
    xil_printf("ARM Cortex-A9 is running!\r\n");

    while(1)
    {
        // loop forever
    }

    return 0;
}