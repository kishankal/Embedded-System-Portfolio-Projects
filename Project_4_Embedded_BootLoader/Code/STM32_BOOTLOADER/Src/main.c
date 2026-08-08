#include "stm32f4xx_hal.h"
#include <string.h>
#include <stdio.h>

// ── Address definitions ───────────────────────────
#define BOOTLOADER_START    0x08000000
#define APPLICATION_START   0x08004000

// ── UART handle ───────────────────────────────────
UART_HandleTypeDef huart2;
// -- CRC handler ------
CRC_HandleTypeDef hcrc;


// ── Function declarations ─────────────────────────
void SystemClock_Config(void);
void UART2_GPIO_Init(void);
void UART2_Init(void);
void LED_GPIO_Init(void);
void Bootloader_Print(char *msg);
void CRC_Init(void);
uint8_t Bootloader_ApplicationValid(void);
void Bootloader_JumpToApplication(void);
uint8_t Bootloader_CheckForUpdate(void);
uint8_t Bootloader_EraseFlash(void);
uint8_t Bootloader_WriteFlash(uint8_t *data,
                               uint32_t size);
uint8_t Bootloader_ReceiveFirmware(uint8_t *buffer,
                                    uint32_t *size);
uint32_t Calculate_CRC32(uint8_t *data,
                          uint32_t size);


// ── Safe UART print ───────────────────────────────
void Bootloader_Print(char *msg)
{
    HAL_UART_Transmit(&huart2,
                      (uint8_t*)msg,
                      strlen(msg), 100);
}

// CRC Init Function
void CRC_Init(void)
{
    __HAL_RCC_CRC_CLK_ENABLE();
    hcrc.Instance = CRC;
    HAL_CRC_Init(&hcrc);
}

// Add CRC Calculate Function
uint32_t Calculate_CRC32(uint8_t *data,
                          uint32_t size)
{
    HAL_CRC_StateTypeDef state =
        HAL_CRC_GetState(&hcrc);

    char dbg[60];
    sprintf(dbg,
        "First bytes: %02X %02X %02X %02X\r\n",
        data[0], data[1],
        data[2], data[3]);
    Bootloader_Print(dbg);

    // Reset CRC unit
    __HAL_RCC_CRC_FORCE_RESET();
    __HAL_RCC_CRC_RELEASE_RESET();
    HAL_CRC_Init(&hcrc);

    uint32_t word_count = size / 4;
    sprintf(dbg, "Words: %lu\r\n", word_count);
    Bootloader_Print(dbg);

    uint32_t result = HAL_CRC_Calculate(
                          &hcrc,
                          (uint32_t*)data,
                          word_count);

    sprintf(dbg, "CRC result: 0x%08lX\r\n",
            result);
    Bootloader_Print(dbg);

    return result;
}
// ── Check if valid application exists ────────────
uint8_t Bootloader_ApplicationValid(void)
{
    uint32_t app_stack = *(uint32_t*)APPLICATION_START;
    if (app_stack >= 0x20000000 &&
        app_stack <= 0x20020000)
    {
        return 1;
    }
    return 0;
}

// ── Jump to application ───────────────────────────
void Bootloader_JumpToApplication(void)
{
    Bootloader_Print("Jumping to Application...\r\n");
    HAL_Delay(100);

    __disable_irq();
    HAL_DeInit();

    SCB->VTOR = APPLICATION_START;

    uint32_t app_stack =
        *(uint32_t*)APPLICATION_START;
    uint32_t app_reset =
        *(uint32_t*)(APPLICATION_START + 4);

    __set_MSP(app_stack);

    void (*app_reset_handler)(void) =
        (void*)app_reset;
    app_reset_handler();
}

// ── Erase application flash ───────────────────────
uint8_t Bootloader_EraseFlash(void)
{
    Bootloader_Print("Erasing flash...\r\n");

    FLASH_EraseInitTypeDef erase;
    uint32_t sector_error = 0;

    erase.TypeErase    = FLASH_TYPEERASE_SECTORS;
    erase.VoltageRange = FLASH_VOLTAGE_RANGE_3;
    erase.Sector       = FLASH_SECTOR_1;
    erase.NbSectors    = 7;

    HAL_FLASH_Unlock();

    if (HAL_FLASHEx_Erase(&erase,
                           &sector_error) != HAL_OK)
    {
        HAL_FLASH_Lock();
        Bootloader_Print("Erase FAILED!\r\n");
        return 0;
    }

    HAL_FLASH_Lock();
    Bootloader_Print("Erase OK!\r\n");
    return 1;
}

// ── Write firmware to flash ───────────────────────
uint8_t Bootloader_WriteFlash(uint8_t *data,
                               uint32_t size)
{
    Bootloader_Print("Writing flash...\r\n");

    HAL_FLASH_Unlock();

    uint32_t address = APPLICATION_START;

    for (uint32_t i = 0; i < size; i += 4)
    {
        uint32_t word = *(uint32_t*)(data + i);

        if (HAL_FLASH_Program(
                FLASH_TYPEPROGRAM_WORD,
                address, word) != HAL_OK)
        {
            HAL_FLASH_Lock();
            Bootloader_Print("Write FAILED!\r\n");
            return 0;
        }
        address += 4;
    }

    HAL_FLASH_Lock();
    Bootloader_Print("Write OK!\r\n");
    return 1;
}

// ── Receive firmware via UART ─────────────────────
uint8_t Bootloader_ReceiveFirmware(uint8_t *buffer,
                                    uint32_t *size)
{
	Bootloader_Print(
	    "Send firmware size (4 bytes)\r\n");

	// Flush UART buffer first
	uint8_t flush_byte;
	while(HAL_UART_Receive(&huart2,
	                        &flush_byte,
	                        1, 10) == HAL_OK);

	HAL_Delay(100);

	HAL_StatusTypeDef rx_status =
	    HAL_UART_Receive(&huart2,
	                     (uint8_t*)size,
	                     4, 5000);

    if (rx_status != HAL_OK)
    {
        char dbg[50];
        sprintf(dbg, "Size rx status: %d\r\n",
                rx_status);
        Bootloader_Print(dbg);
        Bootloader_Print("Size receive FAILED!\r\n");
        return 0;
    }

    char dbg[50];
    sprintf(dbg, "Size OK: %lu bytes\r\n", *size);
    Bootloader_Print(dbg);

    char msg[50];
    sprintf(msg, "Size received: %lu bytes\r\n",
            *size);
    Bootloader_Print(msg);

    sprintf(msg, "Size hex: 0x%08lX\r\n", *size);
    Bootloader_Print(msg);

    if (*size == 0 || *size > 496*1024)
    {
        Bootloader_Print("Size validation FAILED!\r\n");
    }
    else
    {
        Bootloader_Print("Size validation OK!\r\n");
    }

    if (*size == 0 || *size > 496*1024)
    {
        Bootloader_Print("Invalid size!\r\n");
        return 0;
    }

    uint8_t ack = 0x55;
    HAL_UART_Transmit(&huart2, &ack, 1, 100);

    Bootloader_Print("Receiving firmware...\r\n");

    if (HAL_UART_Receive(&huart2,
                         buffer,
                         *size, 30000) != HAL_OK)
    {
        Bootloader_Print("Firmware receive FAILED!\r\n");
        return 0;
    }

    Bootloader_Print("Firmware received OK!\r\n");

    // Receive CRC from PC (4 bytes)
    Bootloader_Print("Waiting for CRC...\r\n");
    uint32_t received_crc = 0;

    if (HAL_UART_Receive(&huart2,
                         (uint8_t*)&received_crc,
                         4, 5000) != HAL_OK)
    {
        Bootloader_Print("CRC receive FAILED!\r\n");
        return 0;
    }

    // Calculate CRC of received firmware
    uint32_t calculated_crc =
        Calculate_CRC32(buffer, *size);

    // Compare CRC values
    char crc_msg[60];
    sprintf(crc_msg,
        "Received CRC:   0x%08lX\r\n",
        received_crc);
    Bootloader_Print(crc_msg);

    sprintf(crc_msg,
        "Calculated CRC: 0x%08lX\r\n",
        calculated_crc);
    Bootloader_Print(crc_msg);

    if (received_crc == calculated_crc)
    {
        Bootloader_Print("CRC OK! ✅\r\n");
        return 1;
    }
    else
    {
        Bootloader_Print("CRC MISMATCH! ❌\r\n");
        Bootloader_Print("Firmware corrupted!\r\n");
        return 0;
    }
}

// ── Check for update command ──────────────────────
uint8_t Bootloader_CheckForUpdate(void)
{
    char rx_byte      = 0;
    char update_cmd[] = "11";
    char rx_buf[5]    = {0};
    uint8_t idx       = 0;

    Bootloader_Print("Waiting for update command...\r\n");
    Bootloader_Print("Send '11' within 3 seconds\r\n");

    uint32_t start = HAL_GetTick();

    while (HAL_GetTick() - start < 3000)
    {
        if (HAL_UART_Receive(&huart2,
                             (uint8_t*)&rx_byte,
                             1, 10) == HAL_OK)
        {
            rx_buf[idx++] = rx_byte;
            if (idx >= 2)
            {
                rx_buf[2] = '\0';
                if (strcmp(rx_buf,
                           update_cmd) == 0)
                {
                    Bootloader_Print(
                        "Update command received!\r\n");
                    return 1;
                }
                idx = 0;
                memset(rx_buf, 0,
                       sizeof(rx_buf));
            }
        }
    }

    Bootloader_Print("Timeout — no update command\r\n");
    return 0;
}

// ── Main ──────────────────────────────────────────
int main(void)
{
    HAL_Init();
    SystemClock_Config();
    LED_GPIO_Init();
    CRC_Init();
    UART2_GPIO_Init();
    UART2_Init();

    // 3 blinks = bootloader starte
    for(int i = 0; i < 6; i++)
    {
        HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
        for(volatile int d = 0; d < 800000; d++);
    }

    Bootloader_Print("\r\n==========================\r\n");
    Bootloader_Print("   STM32 BOOTLOADER v1.0  \r\n");
    Bootloader_Print("   Kishan Kalariya        \r\n");
    Bootloader_Print("==========================\r\n\r\n");

    if (Bootloader_CheckForUpdate())
    {
        Bootloader_Print("Update mode started!\r\n");

        static uint8_t fw_buffer[32 * 1024];
        uint32_t fw_size = 0;

        if (Bootloader_ReceiveFirmware(
                fw_buffer, &fw_size))
        {
            if (Bootloader_EraseFlash())
            {
                if (Bootloader_WriteFlash(
                        fw_buffer, fw_size))
                {
                    Bootloader_Print(
                        "Update complete!\r\n");
                    Bootloader_Print(
                        "Jumping to new app...\r\n");
                    HAL_Delay(500);
                    Bootloader_JumpToApplication();
                }
            }
        }
        else
        {
            Bootloader_Print("Update FAILED!\r\n");
            Bootloader_Print("Running old application...\r\n");
			HAL_Delay(500);
			Bootloader_JumpToApplication();
        }
    }
    else
    {
        if (Bootloader_ApplicationValid())
        {
            Bootloader_JumpToApplication();
        }
        else
        {
            Bootloader_Print(
                "No valid application found!\r\n");
            Bootloader_Print(
                "Please flash application first\r\n");
            while(1)
            {
                HAL_GPIO_TogglePin(GPIOA,
                                   GPIO_PIN_5);
                HAL_Delay(500);
            }
        }
    }

    while(1);
}

// ── Peripheral Init ───────────────────────────────
void LED_GPIO_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    __HAL_RCC_GPIOA_CLK_ENABLE();
    GPIO_InitStruct.Pin   = GPIO_PIN_5;
    GPIO_InitStruct.Mode  = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull  = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
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
    RCC_OscInitStruct.OscillatorType =
        RCC_OSCILLATORTYPE_HSI;
    RCC_OscInitStruct.HSIState =
        RCC_HSI_ON;
    RCC_OscInitStruct.HSICalibrationValue =
        RCC_HSICALIBRATION_DEFAULT;
    RCC_OscInitStruct.PLL.PLLState =
        RCC_PLL_NONE;
    HAL_RCC_OscConfig(&RCC_OscInitStruct);
    RCC_ClkInitStruct.ClockType =
        RCC_CLOCKTYPE_HCLK  |
        RCC_CLOCKTYPE_SYSCLK |
        RCC_CLOCKTYPE_PCLK1  |
        RCC_CLOCKTYPE_PCLK2;
    RCC_ClkInitStruct.SYSCLKSource =
        RCC_SYSCLKSOURCE_HSI;
    RCC_ClkInitStruct.AHBCLKDivider =
        RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider =
        RCC_HCLK_DIV2;
    RCC_ClkInitStruct.APB2CLKDivider =
        RCC_HCLK_DIV1;
    HAL_RCC_ClockConfig(&RCC_ClkInitStruct,
                        FLASH_LATENCY_0);
}

void SysTick_Handler(void)
{
    HAL_IncTick();
}

void HardFault_Handler(void)
{
    while(1)
    {
        HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
        for(volatile int i = 0; i < 200000; i++);
    }
}
