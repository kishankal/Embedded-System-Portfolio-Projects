#include "stm32f4xx_hal.h"
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"
#include <string.h>
#include <stdio.h>
#include <ctype.h>

void SystemClock_Config(void);
void UART2_GPIO_Init(void);
void UART2_Init(void);
void ENCODER_GPIO_Init(void);
void ENCODER_TIM4_Init(void);
void MOTOR_GPIO_Init(void);
void PWM_TIM3_Init(void);

UART_HandleTypeDef huart2;
DMA_HandleTypeDef  hdma_usart2_rx;
TIM_HandleTypeDef  htim4;
TIM_HandleTypeDef  htim3;

// Queue and Mutex handles
QueueHandle_t     xSpeedQueue;
SemaphoreHandle_t xUART_Mutex;

// DMA RX buffer
#define RX_BUFFER_SIZE 32
uint8_t rx_buffer[RX_BUFFER_SIZE];

// PID variables
typedef struct {
    float kp;
    float ki;
    float kd;
    float integral;
    float prev_error;
    float target;
} PID_t;

PID_t pid = {
    .kp       = 0.5f,
    .ki       = 0.01f,
    .kd       = 0.1f,
    .integral = 0.0f,
    .prev_error = 0.0f,
    .target   = 0.0f
};

// Safe UART print
void UART_Print_Safe(char *msg)
{
    if (xSemaphoreTake(xUART_Mutex,
                       pdMS_TO_TICKS(100)) == pdTRUE)
    {
        HAL_UART_Transmit(&huart2, (uint8_t*)msg,
                          strlen(msg), 100);
        xSemaphoreGive(xUART_Mutex);
    }
}

// ─── UART Task ───────────────────────────────────────
void UART_Task(void *pvParameters)
{
    HAL_UART_Receive_DMA(&huart2, rx_buffer,
                         RX_BUFFER_SIZE);
    __HAL_UART_ENABLE_IT(&huart2, UART_IT_IDLE);

    while(1)
    {
        vTaskDelay(pdMS_TO_TICKS(10));
    }
}

// ─── PID Task ────────────────────────────────────────
void PID_Task(void *pvParameters)
{
    uint32_t target_speed  = 0;
    int32_t  last_count    = 0;
    int32_t  current_count = 0;
    int32_t  delta         = 0;
    uint32_t pwm_duty      = 550;
    char     msg[80];

    // Start with fixed PWM so motor spins
    __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, 550);

    while(1)
    {
        // Check queue for new speed command
        if (xQueueReceive(xSpeedQueue, &target_speed,
                          0) == pdTRUE)
        {
            sprintf(msg, "New Target: %lu%%\r\n",
                    target_speed);
            UART_Print_Safe(msg);

            // Directly set PWM from speed percentage
            pwm_duty = (target_speed * 799) / 100;
            __HAL_TIM_SET_COMPARE(&htim3,
                                  TIM_CHANNEL_1,
                                  pwm_duty);
        }

        // Read encoder
        current_count = (int32_t)
                        __HAL_TIM_GET_COUNTER(&htim4);
        delta         = current_count - last_count;
        last_count    = current_count;
        if (delta < 0) delta = -delta;

        // Debug every 5 seconds
        static uint32_t dbg = 0;
        dbg++;
        if (dbg >= 500)
        {
            dbg = 0;
            sprintf(msg,
                "T:%lu%% PWM:%lu delta:%ld cnt:%ld\r\n",
                target_speed, pwm_duty, delta,
                current_count);
            UART_Print_Safe(msg);
        }

        vTaskDelay(pdMS_TO_TICKS(10));
    }
}

// ─── Main ────────────────────────────────────────────
int main(void)
{
    HAL_Init();
    SystemClock_Config();

    UART2_GPIO_Init();
    UART2_Init();
    MOTOR_GPIO_Init();
    PWM_TIM3_Init();
    ENCODER_GPIO_Init();
    ENCODER_TIM4_Init();

    HAL_Delay(100);
    char start_msg[] = "PID Motor Controller Started!\r\n"
                       "Type: SET_SPEED 0-100\r\n";
    HAL_UART_Transmit(&huart2, (uint8_t*)start_msg,
                      strlen(start_msg), 100);
    HAL_Delay(100);

    // Set motor direction
    HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(GPIOB, GPIO_PIN_10, GPIO_PIN_SET);

    // Start PWM at 0%
    HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_1);
    __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, 550);

    // Create queue and mutex
    xSpeedQueue = xQueueCreate(10, sizeof(uint32_t));
    xUART_Mutex = xSemaphoreCreateMutex();

    // Create tasks
    xTaskCreate(UART_Task, "UART", 512, NULL, 3, NULL);
    xTaskCreate(PID_Task,  "PID",  512, NULL, 2, NULL);

    vTaskStartScheduler();
    while(1);
}

// ─── USART2 IRQ ──────────────────────────────────────
void USART2_IRQHandler(void)
{
    if (__HAL_UART_GET_FLAG(&huart2, UART_FLAG_IDLE))
    {
        __HAL_UART_CLEAR_IDLEFLAG(&huart2);

        uint16_t received = RX_BUFFER_SIZE -
                __HAL_DMA_GET_COUNTER(huart2.hdmarx);
        rx_buffer[received] = '\0';

        for (int i = 0; i < received; i++)
            rx_buffer[i] = toupper(rx_buffer[i]);

        uint32_t speed = 0;
        if (sscanf((char*)rx_buffer,
                   "SET_SPEED %lu", &speed) == 1)
        {
            if (speed > 100) speed = 100;
            BaseType_t xHigherPriorityTaskWoken = pdFALSE;
            xQueueSendFromISR(xSpeedQueue, &speed,
                              &xHigherPriorityTaskWoken);
            portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
        }

        HAL_UART_AbortReceive(&huart2);
        HAL_UART_Receive_DMA(&huart2, rx_buffer,
                             RX_BUFFER_SIZE);
    }
    HAL_UART_IRQHandler(&huart2);
}

void DMA1_Stream5_IRQHandler(void)
{
    HAL_DMA_IRQHandler(&hdma_usart2_rx);
}

// ─── Peripheral Init ─────────────────────────────────
void ENCODER_GPIO_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    __HAL_RCC_GPIOB_CLK_ENABLE();
    GPIO_InitStruct.Pin       = GPIO_PIN_6 | GPIO_PIN_7;
    GPIO_InitStruct.Mode      = GPIO_MODE_AF_PP;
    GPIO_InitStruct.Pull      = GPIO_PULLUP;
    GPIO_InitStruct.Speed     = GPIO_SPEED_FREQ_HIGH;
    GPIO_InitStruct.Alternate = GPIO_AF2_TIM4;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
}

void ENCODER_TIM4_Init(void)
{
    TIM_Encoder_InitTypeDef sConfig = {0};
    __HAL_RCC_TIM4_CLK_ENABLE();

    htim4.Instance               = TIM4;
    htim4.Init.Prescaler         = 0;
    htim4.Init.Period            = 65535;
    htim4.Init.CounterMode       = TIM_COUNTERMODE_UP;
    htim4.Init.ClockDivision     = TIM_CLOCKDIVISION_DIV1;
    HAL_TIM_Encoder_Init(&htim4, &sConfig);
    HAL_TIM_Encoder_Start(&htim4, TIM_CHANNEL_ALL);

    sConfig.EncoderMode  = TIM_ENCODERMODE_TI12;
    sConfig.IC1Polarity  = TIM_ICPOLARITY_RISING;
    sConfig.IC1Selection = TIM_ICSELECTION_DIRECTTI;
    sConfig.IC1Prescaler = TIM_ICPSC_DIV1;
    sConfig.IC1Filter    = 0;
    sConfig.IC2Polarity  = TIM_ICPOLARITY_RISING;
    sConfig.IC2Selection = TIM_ICSELECTION_DIRECTTI;
    sConfig.IC2Prescaler = TIM_ICPSC_DIV1;
    sConfig.IC2Filter    = 0;
    HAL_TIM_Encoder_Init(&htim4, &sConfig);

}

void MOTOR_GPIO_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    __HAL_RCC_GPIOA_CLK_ENABLE();
    __HAL_RCC_GPIOB_CLK_ENABLE();

    GPIO_InitStruct.Pin   = GPIO_PIN_7;
    GPIO_InitStruct.Mode  = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull  = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

    GPIO_InitStruct.Pin = GPIO_PIN_10;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
}

void PWM_TIM3_Init(void)
{
    TIM_OC_InitTypeDef sConfigOC     = {0};
    GPIO_InitTypeDef   GPIO_InitStruct = {0};
    __HAL_RCC_TIM3_CLK_ENABLE();
    __HAL_RCC_GPIOA_CLK_ENABLE();

    GPIO_InitStruct.Pin       = GPIO_PIN_6;
    GPIO_InitStruct.Mode      = GPIO_MODE_AF_PP;
    GPIO_InitStruct.Pull      = GPIO_NOPULL;
    GPIO_InitStruct.Speed     = GPIO_SPEED_FREQ_LOW;
    GPIO_InitStruct.Alternate = GPIO_AF2_TIM3;
    HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

    htim3.Instance               = TIM3;
    htim3.Init.Prescaler         = 0;
    htim3.Init.Period            = 799;
    htim3.Init.CounterMode       = TIM_COUNTERMODE_UP;
    htim3.Init.ClockDivision     = TIM_CLOCKDIVISION_DIV1;
    htim3.Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_DISABLE;
    HAL_TIM_PWM_Init(&htim3);

    sConfigOC.OCMode     = TIM_OCMODE_PWM1;
    sConfigOC.Pulse      = 0;
    sConfigOC.OCPolarity = TIM_OCPOLARITY_HIGH;
    sConfigOC.OCFastMode = TIM_OCFAST_DISABLE;
    HAL_TIM_PWM_ConfigChannel(&htim3, &sConfigOC,
                              TIM_CHANNEL_1);
}

void UART2_Init(void)
{
    __HAL_RCC_USART2_CLK_ENABLE();
    __HAL_RCC_DMA1_CLK_ENABLE();

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
