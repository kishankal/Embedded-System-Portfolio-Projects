Open README.md and paste this:

# Project 1 — FreeRTOS PID DC Motor Controller

## Overview
Closed-loop DC motor speed controller on STM32F411RE
Nucleo board using FreeRTOS real-time operating system.

## Hardware
- STM32F411RE Nucleo-64
- L298N motor driver
- DC motor with quadrature encoder
- 12V / 2A power supply

## Software Stack
- FreeRTOS v202406.04
- STM32 HAL drivers (manual setup)
- PID control algorithm
- UART DMA + IDLE interrupt command interface

## Features
- SET_SPEED 0-100 command via PuTTY
- Real-time PID feedback every 10ms
- FreeRTOS UART_Task + PID_Task concurrent operation
- Queue-based inter-task communication
- Mutex-protected UART output

## Project Structure
- Code/ — All STM32CubeIDE projects
- Documents/ — Project report and interview prep
- Images/ — Hardware photos

## Author
Kishan Kalariya