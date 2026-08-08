################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Src/FreeRTOS/portable/GCC/ARM_CM4F/port.c 

OBJS += \
./Src/FreeRTOS/portable/GCC/ARM_CM4F/port.o 

C_DEPS += \
./Src/FreeRTOS/portable/GCC/ARM_CM4F/port.d 


# Each subdirectory must supply rules for building sources it contributes
Src/FreeRTOS/portable/GCC/ARM_CM4F/%.o Src/FreeRTOS/portable/GCC/ARM_CM4F/%.su Src/FreeRTOS/portable/GCC/ARM_CM4F/%.cyclo: ../Src/FreeRTOS/portable/GCC/ARM_CM4F/%.c Src/FreeRTOS/portable/GCC/ARM_CM4F/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DSTM32 -DSTM32F4 -DSTM32F411RETx -DSTM32F411xE -c -I../Inc -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/CMSIS/Device/ST/STM32F4xx/Include" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/STM32_BOOTLOADER/Src/FreeRTOS/include" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/STM32_BOOTLOADER/Src/FreeRTOS/portable/GCC/ARM_CM4F" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/CMSIS/Include" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/STM32F4xx_HAL_Driver/Inc" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/STM32F4xx_HAL_Driver/Src" -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Src-2f-FreeRTOS-2f-portable-2f-GCC-2f-ARM_CM4F

clean-Src-2f-FreeRTOS-2f-portable-2f-GCC-2f-ARM_CM4F:
	-$(RM) ./Src/FreeRTOS/portable/GCC/ARM_CM4F/port.cyclo ./Src/FreeRTOS/portable/GCC/ARM_CM4F/port.d ./Src/FreeRTOS/portable/GCC/ARM_CM4F/port.o ./Src/FreeRTOS/portable/GCC/ARM_CM4F/port.su

.PHONY: clean-Src-2f-FreeRTOS-2f-portable-2f-GCC-2f-ARM_CM4F

