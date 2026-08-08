################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Src/main.c \
../Src/stm32f4xx_hal.c \
../Src/stm32f4xx_hal_cortex.c \
../Src/stm32f4xx_hal_crc.c \
../Src/stm32f4xx_hal_dma.c \
../Src/stm32f4xx_hal_flash.c \
../Src/stm32f4xx_hal_flash_ex.c \
../Src/stm32f4xx_hal_gpio.c \
../Src/stm32f4xx_hal_i2c.c \
../Src/stm32f4xx_hal_pwr.c \
../Src/stm32f4xx_hal_pwr_ex.c \
../Src/stm32f4xx_hal_rcc.c \
../Src/stm32f4xx_hal_rcc_ex.c \
../Src/stm32f4xx_hal_tim.c \
../Src/stm32f4xx_hal_tim_ex.c \
../Src/stm32f4xx_hal_uart.c \
../Src/syscalls.c \
../Src/sysmem.c \
../Src/system_stm32f4xx.c 

OBJS += \
./Src/main.o \
./Src/stm32f4xx_hal.o \
./Src/stm32f4xx_hal_cortex.o \
./Src/stm32f4xx_hal_crc.o \
./Src/stm32f4xx_hal_dma.o \
./Src/stm32f4xx_hal_flash.o \
./Src/stm32f4xx_hal_flash_ex.o \
./Src/stm32f4xx_hal_gpio.o \
./Src/stm32f4xx_hal_i2c.o \
./Src/stm32f4xx_hal_pwr.o \
./Src/stm32f4xx_hal_pwr_ex.o \
./Src/stm32f4xx_hal_rcc.o \
./Src/stm32f4xx_hal_rcc_ex.o \
./Src/stm32f4xx_hal_tim.o \
./Src/stm32f4xx_hal_tim_ex.o \
./Src/stm32f4xx_hal_uart.o \
./Src/syscalls.o \
./Src/sysmem.o \
./Src/system_stm32f4xx.o 

C_DEPS += \
./Src/main.d \
./Src/stm32f4xx_hal.d \
./Src/stm32f4xx_hal_cortex.d \
./Src/stm32f4xx_hal_crc.d \
./Src/stm32f4xx_hal_dma.d \
./Src/stm32f4xx_hal_flash.d \
./Src/stm32f4xx_hal_flash_ex.d \
./Src/stm32f4xx_hal_gpio.d \
./Src/stm32f4xx_hal_i2c.d \
./Src/stm32f4xx_hal_pwr.d \
./Src/stm32f4xx_hal_pwr_ex.d \
./Src/stm32f4xx_hal_rcc.d \
./Src/stm32f4xx_hal_rcc_ex.d \
./Src/stm32f4xx_hal_tim.d \
./Src/stm32f4xx_hal_tim_ex.d \
./Src/stm32f4xx_hal_uart.d \
./Src/syscalls.d \
./Src/sysmem.d \
./Src/system_stm32f4xx.d 


# Each subdirectory must supply rules for building sources it contributes
Src/%.o Src/%.su Src/%.cyclo: ../Src/%.c Src/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DSTM32 -DSTM32F4 -DSTM32F411RETx -DSTM32F411xE -c -I../Inc -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/CMSIS/Device/ST/STM32F4xx/Include" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/CMSIS/Include" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/STM32F4xx_HAL_Driver/Inc" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/STM32F4xx_HAL_Driver/Src" -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Src

clean-Src:
	-$(RM) ./Src/main.cyclo ./Src/main.d ./Src/main.o ./Src/main.su ./Src/stm32f4xx_hal.cyclo ./Src/stm32f4xx_hal.d ./Src/stm32f4xx_hal.o ./Src/stm32f4xx_hal.su ./Src/stm32f4xx_hal_cortex.cyclo ./Src/stm32f4xx_hal_cortex.d ./Src/stm32f4xx_hal_cortex.o ./Src/stm32f4xx_hal_cortex.su ./Src/stm32f4xx_hal_crc.cyclo ./Src/stm32f4xx_hal_crc.d ./Src/stm32f4xx_hal_crc.o ./Src/stm32f4xx_hal_crc.su ./Src/stm32f4xx_hal_dma.cyclo ./Src/stm32f4xx_hal_dma.d ./Src/stm32f4xx_hal_dma.o ./Src/stm32f4xx_hal_dma.su ./Src/stm32f4xx_hal_flash.cyclo ./Src/stm32f4xx_hal_flash.d ./Src/stm32f4xx_hal_flash.o ./Src/stm32f4xx_hal_flash.su ./Src/stm32f4xx_hal_flash_ex.cyclo ./Src/stm32f4xx_hal_flash_ex.d ./Src/stm32f4xx_hal_flash_ex.o ./Src/stm32f4xx_hal_flash_ex.su ./Src/stm32f4xx_hal_gpio.cyclo ./Src/stm32f4xx_hal_gpio.d ./Src/stm32f4xx_hal_gpio.o ./Src/stm32f4xx_hal_gpio.su ./Src/stm32f4xx_hal_i2c.cyclo ./Src/stm32f4xx_hal_i2c.d ./Src/stm32f4xx_hal_i2c.o ./Src/stm32f4xx_hal_i2c.su ./Src/stm32f4xx_hal_pwr.cyclo ./Src/stm32f4xx_hal_pwr.d ./Src/stm32f4xx_hal_pwr.o ./Src/stm32f4xx_hal_pwr.su ./Src/stm32f4xx_hal_pwr_ex.cyclo ./Src/stm32f4xx_hal_pwr_ex.d ./Src/stm32f4xx_hal_pwr_ex.o ./Src/stm32f4xx_hal_pwr_ex.su ./Src/stm32f4xx_hal_rcc.cyclo ./Src/stm32f4xx_hal_rcc.d ./Src/stm32f4xx_hal_rcc.o ./Src/stm32f4xx_hal_rcc.su ./Src/stm32f4xx_hal_rcc_ex.cyclo ./Src/stm32f4xx_hal_rcc_ex.d ./Src/stm32f4xx_hal_rcc_ex.o ./Src/stm32f4xx_hal_rcc_ex.su ./Src/stm32f4xx_hal_tim.cyclo ./Src/stm32f4xx_hal_tim.d ./Src/stm32f4xx_hal_tim.o ./Src/stm32f4xx_hal_tim.su ./Src/stm32f4xx_hal_tim_ex.cyclo ./Src/stm32f4xx_hal_tim_ex.d ./Src/stm32f4xx_hal_tim_ex.o ./Src/stm32f4xx_hal_tim_ex.su ./Src/stm32f4xx_hal_uart.cyclo ./Src/stm32f4xx_hal_uart.d ./Src/stm32f4xx_hal_uart.o ./Src/stm32f4xx_hal_uart.su ./Src/syscalls.cyclo ./Src/syscalls.d ./Src/syscalls.o ./Src/syscalls.su ./Src/sysmem.cyclo ./Src/sysmem.d ./Src/sysmem.o ./Src/sysmem.su ./Src/system_stm32f4xx.cyclo ./Src/system_stm32f4xx.d ./Src/system_stm32f4xx.o ./Src/system_stm32f4xx.su

.PHONY: clean-Src

