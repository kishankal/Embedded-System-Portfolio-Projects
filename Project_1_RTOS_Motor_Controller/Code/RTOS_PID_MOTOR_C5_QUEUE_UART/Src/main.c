#include "stm32f4xx_hal.h"
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include <string.h>
#include <stdio.h>
#include <ctype.h>

void SystemClock_Config(void);
void UART2_GPIO_Init(void);
void UART2_Init(void);

UART_HandleTypeDef huart2;
DMA_HandleTypeDef  hdma_usart2_rx;

// Queue holds speed values sent from UART to Motor task
QueueHandle_t xSpeedQueue;

#define RX_BUFFER_SIZE 32
uint8_t rx_buffer[RX_BUFFER_SIZE];

// ─── UART Task — receives command puts in queue ──────
void UART_Task(void *pvParameters)
{
    // Start DMA RX
    HAL_UART_Receive_DMA(&huart2, rx_buffer, RX_BUFFER_SIZE);
    __HAL_UART_ENABLE_IT(&huart2, UART_IT_IDLE);

    while(1)
    {
        vTaskDelay(pdMS_TO_TICKS(10));
    }
}

// ─── Motor Task — reads queue updates motor ──────────
void MOTOR_Task(void *pvParameters)
{
    uint32_t speed = 0;
    char msg[60];

    while(1)
    {
        // Block forever until speed arrives in queue
        if (xQueueReceive(xSpeedQueue, &speed,
                          portMAX_DELAY) == pdTRUE)
        {
            uint32_t ccr = (speed * 799) / 100;
            sprintf(msg, "Motor Speed: %lu%% | CCR: %lu\r\n",
                    speed, ccr);
            HAL_UART_Transmit(&huart2, (uint8_t*)msg,
                              strlen(msg), 100);
        }
    }
}

// ─── Main ────────────────────────────────────────────
int main(void)
{
    HAL_Init();
    SystemClock_Config();
    UART2_GPIO_Init();
    UART2_Init();

    HAL_Delay(100);
    char start_msg[] = "Queue UART Started!\r\nType: SET_SPEED 0-100\r\n";
    HAL_UART_Transmit(&huart2, (uint8_t*)start_msg,
                      strlen(start_msg), 100);
    HAL_Delay(100);

    // Create queue — holds 10 speed values
    xSpeedQueue = xQueueCreate(10, sizeof(uint32_t));

    xTaskCreate(UART_Task,  "UART_Task",  512, NULL, 2, NULL);
    xTaskCreate(MOTOR_Task, "MOTOR_Task", 512, NULL, 1, NULL);

    vTaskStartScheduler();
    while(1);
}

// ─── USART2 IRQ — IDLE detection ─────────────────────
void USART2_IRQHandler(void)
{
    if (__HAL_UART_GET_FLAG(&huart2, UART_FLAG_IDLE))
    {
        __HAL_UART_CLEAR_IDLEFLAG(&huart2);

        uint16_t received = RX_BUFFER_SIZE -
                            __HAL_DMA_GET_COUNTER(huart2.hdmarx);

        rx_buffer[received] = '\0';

        // Convert to uppercase
        for (int i = 0; i < received; i++)
            rx_buffer[i] = toupper(rx_buffer[i]);

        // Parse SET_SPEED command
        uint32_t speed = 0;
        if (sscanf((char*)rx_buffer,
                   "SET_SPEED %lu", &speed) == 1)
        {
            if (speed > 100) speed = 100;

            // Send to queue from ISR
            BaseType_t xHigherPriorityTaskWoken = pdFALSE;
            xQueueSendFromISR(xSpeedQueue, &speed,
                              &xHigherPriorityTaskWoken);
            portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
        }

        HAL_UART_AbortReceive(&huart2);
        HAL_UART_Receive_DMA(&huart2, rx_buffer, RX_BUFFER_SIZE);
    }
    HAL_UART_IRQHandler(&huart2);
}

// ─── DMA Init ─────────────────────────────────────────
void UART2_Init(void)
{
    __HAL_RCC_USART2_CLK_ENABLE();
    __HAL_RCC_DMA1_CLK_ENABLE();

    // DMA RX setup
    hdma_usart2_rx.Instance                 = DMA1_Stream5;
    hdma_usart2_rx.Init.Channel             = DMA_CHANNEL_4;
    hdma_usart2_rx.Init.Direction           = DMA_PERIPH_TO_MEMORY;
    hdma_usart2_rx.Init.PeriphInc           = DMA_PINC_DISABLE;
    hdma_usart2_rx.Init.MemInc              = DMA_MINC_ENABLE;
    hdma_usart2_rx.Init.PeriphDataAlignment = DMA_PDATAALIGN_BYTE;
    hdma_usart2_rx.Init.MemDataAlignment    = DMA_MDATAALIGN_BYTE;
    hdma_usart2_rx.Init.Mode                = DMA_CIRCULAR;
    hdma_usart2_rx.Init.Priority            = DMA_PRIORITY_LOW;
    hdma_usart2_rx.Init.FIFOMode            = DMA_FIFOMODE_DISABLE;
    HAL_DMA_Init(&hdma_usart2_rx);
    __HAL_LINKDMA(&huart2, hdmarx, hdma_usart2_rx);

    HAL_NVIC_SetPriority(DMA1_Stream5_IRQn, 6, 0);
    HAL_NVIC_EnableIRQ(DMA1_Stream5_IRQn);

    HAL_NVIC_SetPriority(USART2_IRQn, 6, 0);
    HAL_NVIC_EnableIRQ(USART2_IRQn);

    huart2.Instance          = USART2;
    huart2.Init.BaudRate     = 115200;
    huart2.Init.WordLength   = UART_WORDLENGTH_8B;
    huart2.Init.StopBits     = UART_STOPBITS_1;
    huart2.Init.Parity       = UART_PARITY_NONE;
    huart2.Init.Mode         = UART_MODE_TX_RX;
    huart2.Init.HwFlowCtl    = UART_HWCONTROL_NONE;
    HAL_UART_Init(&huart2);
}

void DMA1_Stream5_IRQHandler(void)
{
    HAL_DMA_IRQHandler(&hdma_usart2_rx);
}

void UART2_GPIO_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    __HAL_RCC_GPIOA_CLK_ENABLE();
    GPIO_InitStruct.Pin       = GPIO_PIN_2 | GPIO_PIN_3;
    GPIO_InitStruct.Mode      = GPIO_MODE_AF_PP;
    GPIO_InitStruct.Pull      = GPIO_NOPULL;
    GPIO_InitStruct.Speed     = GPIO_SPEED_FREQ_LOW;
    GPIO_InitStruct.Alternate = GPIO_AF7_USART2;
    HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
}

void SystemClock_Config(void)
{
    RCC_OscInitTypeDef RCC_OscInitStruct = {0};
    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};
    RCC_OscInitStruct.OscillatorType      = RCC_OSCILLATORTYPE_HSI;
    RCC_OscInitStruct.HSIState            = RCC_HSI_ON;
    RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
    RCC_OscInitStruct.PLL.PLLState        = RCC_PLL_NONE;
    HAL_RCC_OscConfig(&RCC_OscInitStruct);
    RCC_ClkInitStruct.ClockType      = RCC_CLOCKTYPE_HCLK
                                     | RCC_CLOCKTYPE_SYSCLK
                                     | RCC_CLOCKTYPE_PCLK1
                                     | RCC_CLOCKTYPE_PCLK2;
    RCC_ClkInitStruct.SYSCLKSource   = RCC_SYSCLKSOURCE_HSI;
    RCC_ClkInitStruct.AHBCLKDivider  = RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
    HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0);
}

void SysTick_Handler(void)
{
    HAL_IncTick();
    if (xTaskGetSchedulerState() != taskSCHEDULER_NOT_STARTED)
    {
        xPortSysTickHandler();
    }
}

void HardFault_Handler(void)
{
    while(1)
    {
        HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
        for(volatile int i = 0; i < 100000; i++);
    }
}

void vApplicationStackOverflowHook(TaskHandle_t xTask,
                                   char *pcTaskName)
{
    (void)xTask;
    (void)pcTaskName;
    while(1)
    {
        HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
        for(volatile int i = 0; i < 50000; i++);
    }
}

void vApplicationMallocFailedHook(void)
{
    while(1)
    {
        HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
        for(volatile int i = 0; i < 50000; i++);
    }
}
