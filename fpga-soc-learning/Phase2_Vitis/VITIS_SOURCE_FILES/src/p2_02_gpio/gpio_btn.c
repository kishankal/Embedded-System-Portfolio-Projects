#include "xgpio.h"
#include "xil_printf.h"
#include "sleep.h"

#define LED_CHANNEL  1
#define BTN_CHANNEL  2

XGpio gpio;

int main()
{
    int status;
    u32 btn_value;
    u32 prev_btn = 0;

    status = XGpio_Initialize(&gpio, XPAR_AXI_GPIO_0_BASEADDR);
    if (status != XST_SUCCESS){
        xil_printf("GPIO Init Failed!\r\n");
        return -1;
    }

    XGpio_SetDataDirection(&gpio, LED_CHANNEL, 0x0);
    XGpio_SetDataDirection(&gpio, BTN_CHANNEL, 0xF);

    xil_printf("Ready - Press buttons!\r\n");

    while(1)
    {
        btn_value = XGpio_DiscreteRead(&gpio, BTN_CHANNEL);
        XGpio_DiscreteWrite(&gpio, LED_CHANNEL, btn_value);

        if(btn_value != prev_btn){
            xil_printf("Buttons: 0x%X\r\n", btn_value);
            prev_btn = btn_value;
        }

        usleep(50000);
    }

    return 0;
}