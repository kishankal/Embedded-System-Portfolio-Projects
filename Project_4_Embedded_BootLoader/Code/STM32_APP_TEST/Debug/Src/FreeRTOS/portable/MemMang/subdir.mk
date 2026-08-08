################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Src/FreeRTOS/portable/MemMang/heap_4.c 

OBJS += \
./Src/FreeRTOS/portable/MemMang/heap_4.o 

C_DEPS += \
./Src/FreeRTOS/portable/MemMang/heap_4.d 


# Each subdirectory must supply rules for building sources it contributes
Src/FreeRTOS/portable/MemMang/%.o Src/FreeRTOS/portable/MemMang/%.su Src/FreeRTOS/portable/MemMang/%.cyclo: ../Src/FreeRTOS/portable/MemMang/%.c Src/FreeRTOS/portable/MemMang/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DSTM32 -DSTM32F4 -DSTM32F411RETx -DSTM32F411xE -c -I../Inc -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/CMSIS/Device/ST/STM32F4xx/Include" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/STM32_BOOTLOADER/Src/FreeRTOS/include" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/STM32_BOOTLOADER/Src/FreeRTOS/portable/GCC/ARM_CM4F" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/CMSIS/Include" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/STM32F4xx_HAL_Driver/Inc" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/STM32F4xx_HAL_Driver/Src" -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Src-2f-FreeRTOS-2f-portable-2f-MemMang

clean-Src-2f-FreeRTOS-2f-portable-2f-MemMang:
	-$(RM) ./Src/FreeRTOS/portable/MemMang/heap_4.cyclo ./Src/FreeRTOS/portable/MemMang/heap_4.d ./Src/FreeRTOS/portable/MemMang/heap_4.o ./Src/FreeRTOS/portable/MemMang/heap_4.su

.PHONY: clean-Src-2f-FreeRTOS-2f-portable-2f-MemMang

