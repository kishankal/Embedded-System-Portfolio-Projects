################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Src/FreeRTOS/list.c \
../Src/FreeRTOS/queue.c \
../Src/FreeRTOS/tasks.c \
../Src/FreeRTOS/timers.c 

OBJS += \
./Src/FreeRTOS/list.o \
./Src/FreeRTOS/queue.o \
./Src/FreeRTOS/tasks.o \
./Src/FreeRTOS/timers.o 

C_DEPS += \
./Src/FreeRTOS/list.d \
./Src/FreeRTOS/queue.d \
./Src/FreeRTOS/tasks.d \
./Src/FreeRTOS/timers.d 


# Each subdirectory must supply rules for building sources it contributes
Src/FreeRTOS/%.o Src/FreeRTOS/%.su Src/FreeRTOS/%.cyclo: ../Src/FreeRTOS/%.c Src/FreeRTOS/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DSTM32 -DSTM32F4 -DSTM32F411RETx -DSTM32F411xE -c -I../Inc -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/CMSIS/Device/ST/STM32F4xx/Include" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/STM32_BOOTLOADER/Src/FreeRTOS/include" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/STM32_BOOTLOADER/Src/FreeRTOS/portable/GCC/ARM_CM4F" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/CMSIS/Include" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/STM32F4xx_HAL_Driver/Inc" -I"C:/Embedded System Projects (Personal)/P1_FREERTOS_PID_CONTROL_MOTOR/Code/RTOS_PID_MOTOR/chip_headers/STM32F4xx_HAL_Driver/Src" -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Src-2f-FreeRTOS

clean-Src-2f-FreeRTOS:
	-$(RM) ./Src/FreeRTOS/list.cyclo ./Src/FreeRTOS/list.d ./Src/FreeRTOS/list.o ./Src/FreeRTOS/list.su ./Src/FreeRTOS/queue.cyclo ./Src/FreeRTOS/queue.d ./Src/FreeRTOS/queue.o ./Src/FreeRTOS/queue.su ./Src/FreeRTOS/tasks.cyclo ./Src/FreeRTOS/tasks.d ./Src/FreeRTOS/tasks.o ./Src/FreeRTOS/tasks.su ./Src/FreeRTOS/timers.cyclo ./Src/FreeRTOS/timers.d ./Src/FreeRTOS/timers.o ./Src/FreeRTOS/timers.su

.PHONY: clean-Src-2f-FreeRTOS

