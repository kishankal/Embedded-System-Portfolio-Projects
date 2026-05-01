# RTOS Motor Controller

**STM32 · FreeRTOS · PID Control · L298N Motor Driver · Hall Encoder**

[![Platform](https://img.shields.io/badge/Platform-STM32-blue)](https://www.st.com/en/microcontrollers-microprocessors/stm32-32-bit-arm-cortex-mcus.html)
[![RTOS](https://img.shields.io/badge/RTOS-FreeRTOS-green)](https://www.freertos.org/)
[![Language](https://img.shields.io/badge/Language-C-lightgrey)](https://en.wikipedia.org/wiki/C_(programming_language))
[![IDE](https://img.shields.io/badge/IDE-STM32CubeIDE-orange)](https://www.st.com/en/development-tools/stm32cubeide.html)
[![Status](https://img.shields.io/badge/Status-In%20Progress-yellow)]()

---

## What This Project Does

This project implements a **closed-loop DC motor speed controller** on an STM32 microcontroller. The system receives a target speed command over UART from a PC terminal, drives a DC motor through an L298N H-bridge driver, reads actual motor speed using a Hall effect encoder, and uses a **PID (Proportional-Integral-Derivative) algorithm** to automatically maintain the exact target RPM — regardless of mechanical load changes.

Three FreeRTOS tasks run concurrently on the microcontroller:

| Task | Responsibility |
|------|---------------|
| `MotorTask` | Reads target speed, runs PID calculation, applies PWM output to L298N every 10ms |
| `UARTTask` | Listens on UART2 for incoming speed commands, parses integer value, signals MotorTask via semaphore |
| `LEDTask` | Blinks onboard LED at different rates to indicate system state (running / stopped) |

A binary semaphore between `UARTTask` and `MotorTask` ensures the motor PWM updates only when a new command has been received — no wasted CPU cycles.

---

## Why This Project Was Built

### The Engineering Problem It Solves

In any motorised system — an industrial conveyor belt, a robotic arm joint, a CNC spindle, an electric vehicle wheel — the motor does not naturally maintain constant speed under varying load. When the load increases (more weight, more friction, more resistance), the motor slows down. A simple open-loop controller cannot compensate for this. A **closed-loop PID controller** continuously monitors the actual speed, calculates the error against the target, and adjusts the drive signal to bring the speed back to the setpoint automatically.

### Why FreeRTOS Specifically

A real motor controller cannot be written as a single loop. The system must simultaneously listen for new commands, compute PID output on a strict 10ms schedule, and update status indicators — all without any task blocking another. FreeRTOS provides preemptive multitasking on a microcontroller with kilobytes of RAM, which is the exact execution model used in commercial embedded products. Writing this from scratch demonstrates genuine understanding of task scheduling, inter-task communication, and real-time constraints.

### Industrial Relevance in Germany and Globally

This project directly reflects the core embedded software skills that companies in the German automotive and industrial automation sectors require:

**In Germany specifically:**
- **Bosch Rexroth** builds industrial servo drives and motion controllers that use exactly this PID architecture for axis control in factory machines.
- **Continental** designs electronic control units (ECUs) for electric power steering and brake-by-wire systems — both rely on closed-loop motor control running on RTOS-based microcontrollers.
- **Infineon** produces the power semiconductors and microcontrollers used in motor drive inverters across the European automotive industry.
- **Siemens** deploys RTOS-based PLC and drive firmware across its SINAMICS and SIMOTICS product lines in manufacturing plants worldwide.
- **Festo** and **Schunk** use real-time motor controllers in pneumatic and electric grippers used in automated assembly lines across German Mittelstand factories.

**Globally:**
- Electric vehicle manufacturers (Tesla, BYD, BMW EV division) run multiple RTOS-managed motor control tasks on ARM Cortex-M cores inside each motor controller unit.
- Industrial robot manufacturers (KUKA, ABB, Fanuc) run FreeRTOS or equivalent RTOSes on joint motor controllers in every robot axis.
- Drone flight controllers (ArduPilot, PX4) use FreeRTOS with PID loops for roll, pitch, yaw, and throttle control.
- Medical devices such as infusion pumps and surgical robots use closed-loop motor control with RTOS to meet safety-critical timing requirements.

The combination of **FreeRTOS + PID + PWM + encoder feedback** demonstrated in this project is not a toy example — it is the exact architecture used in production systems across these industries.

---

## Hardware Components

| Component | Specification | Role in System |
|-----------|--------------|----------------|
| **STM32 Nucleo Board** | STM32F411RE, 100MHz ARM Cortex-M4, 512KB Flash, 128KB RAM | Main microcontroller — runs FreeRTOS, PID algorithm, UART, and PWM generation |
| **L298N Motor Driver Module** | Dual H-bridge, 5V–35V input, 2A per channel, onboard 5V regulator | Power bridge between STM32 (3.3V logic) and DC motor (12V power). STM32 cannot drive a motor directly — the L298N handles the high current |
| **DC Gear Motor with Hall Encoder** | 12V, 300RPM, AB quadrature Hall encoder, 48 CPR | Actuator and feedback source. The motor is what spins. The encoder attached to its shaft sends pulses back to the STM32 — without this, closed-loop speed control is not possible |
| **12V DC Power Supply** | 2A rated, 5.5mm barrel jack | Motors require significantly more current than USB can provide. A separate 12V supply powers the motor through the L298N |
| **Breadboard + Jumper Wires** | 830-point breadboard, 120-piece wire set | Rapid prototyping connections without soldering |

### Why Each Component Was Chosen

**STM32 over Arduino:** The STM32 runs FreeRTOS natively with hardware timers precise enough for 10ms PID scheduling. Arduino's timer architecture cannot reliably support preemptive RTOS at this precision. STM32 is also the platform used in professional embedded development at ST customers (automotive, industrial, medical).

**L298N over direct GPIO drive:** A microcontroller GPIO pin can source approximately 8–16mA. A DC motor requires hundreds of milliamps to amperes. Connecting a motor directly to a GPIO pin destroys the microcontroller. The L298N's H-bridge handles the power amplification while accepting low-current logic signals from the STM32.

**Hall encoder over optical encoder:** Hall effect encoders use magnetic field sensing rather than infrared light interruption. They are more robust in dusty, oily, or contaminated industrial environments — making them the standard choice in automotive and factory automation applications.

---

## System Architecture

```
PC Terminal (PuTTY)
      │
      │  UART2 (115200 baud)
      ▼
┌─────────────────────────────────────────┐
│           STM32 (FreeRTOS)              │
│                                         │
│  ┌──────────┐    semaphore   ┌────────┐ │
│  │ UARTTask │ ─────────────▶ │MotorTask│ │
│  │          │                │ PID    │ │
│  └──────────┘                │ PWM out│ │
│                              └───┬────┘ │
│  ┌──────────┐                    │      │
│  │ LEDTask  │◀── motor state     │      │
│  └──────────┘                    │      │
└───────────────────────────────┬──┼──────┘
                                │  │ PWM (TIM3)
                    Encoder A/B │  ▼
                    (TIM4)      │  L298N Motor Driver
                         ◀──────┘       │
                    DC Motor ───────────┘
                    (12V + Hall Encoder)
```

---

## PID Control — How It Works

The PID algorithm runs inside `MotorTask` every 10 milliseconds:

```
error        = target_RPM - actual_RPM
P_term       = Kp × error
I_term      += Ki × error × dt
D_term       = Kd × (error - previous_error) / dt
PWM_output   = P_term + I_term + D_term
               (clamped 0–1000, applied to TIM3 compare register)
```

**Proportional (P):** Responds immediately to the current error. Larger error = larger correction. Controls response speed.

**Integral (I):** Accumulates past errors over time. Eliminates the steady-state offset where the motor nearly reaches target but never quite gets there. Controls precision.

**Derivative (D):** Reacts to the rate of change of error. Dampens overshoot — prevents the motor from zooming past the target and oscillating.

Tuned values: `Kp = 1.5, Ki = 0.05, Kd = 0.01`

---

## Demo Video

> 📹 *Link to be added after recording — will show motor running, speed command changing RPM, and load rejection demonstration*

---

## Repository Structure

```
stm32-rtos-motor-controller/
├── Core/
│   ├── Src/
│   │   ├── main.c              # Entry point, FreeRTOS task creation
│   │   ├── motor_task.c        # MotorTask + PID implementation
│   │   ├── uart_task.c         # UARTTask command parsing
│   │   ├── led_task.c          # LEDTask status indication
│   │   └── pid.c               # PID algorithm
│   └── Inc/
│       ├── motor_task.h
│       ├── uart_task.h
│       └── pid.h
├── Drivers/                    # STM32 HAL drivers (auto-generated)
├── Middlewares/                # FreeRTOS source (auto-generated)
├── docs/
│   ├── wiring_diagram.png      # Hardware connection diagram
│   └── architecture.png        # FreeRTOS task diagram
├── .project                    # STM32CubeIDE project file
└── README.md
```

---

## Build Instructions

**Requirements:** STM32CubeIDE (free from st.com), STM32 Nucleo board, hardware listed above.

1. Clone this repository
2. Open STM32CubeIDE → File → Import → Existing Projects into Workspace
3. Select the cloned folder
4. Click Build (hammer icon) — should compile with 0 errors
5. Connect STM32 via USB, click Run (green arrow) to flash
6. Open PuTTY at 115200 baud on the STM32 COM port
7. Type `SET_SPEED 80` and press Enter — motor starts at 80% speed

---

## Author

**Kishan Harshukh Kalariya**
M.Sc. Embedded System Design · Germany · 2026
[LinkedIn](https://www.linkedin.com/in/kishan-kalariya-3b2205210/) · [GitHub](https://github.com/kishankalariya) · kkalariya201@gmail.com
