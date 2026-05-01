#include "stm32f4xx_hal.h"
#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"
#include <string.h>
#include <stdio.h>

void SystemClock_Config(void);
void UART2_GPIO_Init(void);
void UART2_Init(void);

UART_HandleTypeDef huart2;

// Semaphore handle — global so all tasks can access
SemaphoreHandle_t xUART_Semaphore;

// ─── Safe UART print function ────────────────────────
void UART_Print_Safe(char *msg)
{
    // Take key before printing
    if (xSemaphoreTake(xUART_Semaphore,
                       pdMS_TO_TICKS(100)) == pdTRUE)
    {
        HAL_UART_Transmit(&huart2, (uint8_t*)msg,
                          strlen(msg), 100);
        // Give key back after printing
        xSemaphoreGive(xUART_Semaphore);
    }
}

// ─── Task 1 — Motor Status ───────────────────────────
void MOTOR_Task(void *pvParameters)
{
    char msg[50];
    uint32_t speed = 0;

    while(1)
    {
        speed += 10;
        if (speed > 100) speed = 0;
        sprintf(msg, "Motor Speed: %lu%%\r\n", speed);
        UART_Print_Safe(msg);
        vTaskDelay(pdMS_TO_TICKS(500));
    }
}

// ─── Task 2 — Encoder Status ────────────────────────
void ENCODER_Task(void *pvParameters)
{
    char msg[50];
    uint32_t rpm = 0;

    while(1)
    {
        rpm += 100;
        if (rpm > 3000) rpm = 0;
        sprintf(msg, "Encoder RPM: %lu\r\n", rpm);
        UART_Print_Safe(msg);
        vTaskDelay(pdMS_TO_TICKS(700));
    }
}

// ─── Task 3 — System Status ─────────────────────────
void SYSTEM_Task(void *pvParameters)
{
    char msg[50];
    uint32_t tick = 0;

    while(1)
    {
        tick++;
        sprintf(msg, "System Tick: %lu\r\n", tick);
        UART_Print_Safe(msg);
        vTaskDelay(pdMS_TO_TICKS(1000));
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
    char start_msg[] = "Semaphore Started!\r\n";
    HAL_UART_Transmit(&huart2, (uint8_t*)start_msg,
                      strlen(start_msg), 100);
    HAL_Delay(100);

    // Create semaphore — starts with 1 key available
    // xUART_Semaphore = xSemaphoreCreateBinary();
    // xSemaphoreGive(xUART_Semaphore);
    xUART_Semaphore = xSemaphoreCreateMutex();

    xTaskCreate(MOTOR_Task,   "MOTOR",   256, NULL, 1, NULL);
    xTaskCreate(ENCODER_Task, "ENCODER", 256, NULL, 1, NULL);
    xTaskCreate(SYSTEM_Task,  "SYSTEM",  256, NULL, 1, NULL);

    vTaskStartScheduler();
    while(1);
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

void UART2_Init(void)
{
    __HAL_RCC_USART2_CLK_ENABLE();
    huart2.Instance          = USART2;
    huart2.Init.BaudRate     = 115200;
    huart2.Init.WordLength   = UART_WORDLENGTH_8B;
    huart2.Init.StopBits     = UART_STOPBITS_1;
    huart2.Init.Parity       = UART_PARITY_NONE;
    huart2.Init.Mode         = UART_MODE_TX_RX;
    huart2.Init.HwFlowCtl    = UART_HWCONTROL_NONE;
    HAL_UART_Init(&huart2);
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
