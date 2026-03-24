# Kishan Harshukh Kalariya — Embedded Systems Portfolio

**M.Sc. Embedded System Design** | Bremerhaven, Germany | 2026

[![LinkedIn](https://img.shields.io/badge/LinkedIn-kishan--kalariya-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/kishan-kalariya-3b2205210/)
[![GitHub](https://img.shields.io/badge/GitHub-kishankalariya-black?style=flat&logo=github)](https://github.com/kishankalariya)
[![Email](https://img.shields.io/badge/Email-kkalariya201@gmail.com-red?style=flat&logo=gmail)](mailto:kkalariya201@gmail.com)

---

## About Me

I am a Master's student in Embedded System Design studying in Germany, with 1.5 years of prior industry experience in embedded systems engineering. My work focuses on real-time firmware, motor control, machine learning at the edge, and IoT connectivity — the four areas that define modern embedded engineering.

This portfolio contains three hands-on hardware projects, each targeting a distinct layer of the embedded engineering stack. Every project is built from scratch using physical components, documented with wiring diagrams and architecture diagrams, and demonstrated with a recorded video.

I am actively seeking **Werkstudent positions** in embedded systems, IoT, or real-time software engineering at companies operating in Germany.

---

## Portfolio Projects

| # | Project | Technologies | Status |
|---|---------|-------------|--------|
| 1 | [RTOS Motor Controller](./stm32-rtos-motor-controller) | STM32 · FreeRTOS · PID · C · UART | 🔄 In Progress |
| 2 | [TinyML Anomaly Detection](./stm32-tinyml-anomaly-detection) | STM32 · Edge Impulse · MPU6050 · C++ | 📋 Planned |
| 3 | [ESP32 IoT Dashboard](./esp32-iot-dashboard) | ESP32 · MQTT · BME280 · Node-RED · C++ | 📋 Planned |

---

## Project 1 — RTOS Motor Controller

> **STM32 · FreeRTOS · PID Control · L298N · Hall Encoder**

A closed-loop DC motor speed controller running on an STM32 microcontroller. Three concurrent FreeRTOS tasks manage PWM output, UART command reception, and LED status indication simultaneously. A PID algorithm reads encoder feedback 100 times per second and automatically adjusts motor power to maintain the target RPM — even when mechanical load is applied.

This project directly demonstrates the real-time operating system and control theory skills that appear in every embedded engineering job description at companies like Bosch Rexroth, Continental, and Siemens.

📁 [View Project →](./stm32-rtos-motor-controller)

---

## Project 2 — TinyML Anomaly Detection

> **STM32 · MPU6050 · Edge Impulse · TensorFlow Lite Micro · C++**

An on-device machine learning system that detects mechanical anomalies from vibration patterns in real time. A neural network trained on three classes of accelerometer data (normal, imbalance, fault) runs entirely inside the STM32 chip — no cloud connection, no external server, no latency. When the vibration pattern deviates from normal, the system raises an alert immediately.

Predictive maintenance using this exact approach is deployed across manufacturing lines at Festo, Schaeffler, and Siemens Factory Automation.

📁 [View Project →](./stm32-tinyml-anomaly-detection)

---

## Project 3 — ESP32 IoT Dashboard

> **ESP32 · BME280 · MQTT · Node-RED · Wi-Fi · C++**

A real-time environmental monitoring system using an ESP32 microcontroller and a BME280 precision sensor. The device reads temperature, humidity, and barometric pressure every 5 seconds and publishes structured JSON data over Wi-Fi using the MQTT protocol to a Node-RED dashboard accessible from any browser on the network. Configurable threshold alerts notify when conditions exceed defined limits.

This architecture — edge sensor → MQTT broker → live dashboard — is the fundamental pattern behind smart building systems, industrial condition monitoring, and connected logistics infrastructure across Europe.

📁 [View Project →](./esp32-iot-dashboard)

---

## Technical Skills

### Embedded Hardware & Firmware
`STM32` `ESP32` `ARM Cortex-M` `FreeRTOS` `Bare-metal C` `PWM` `I2C` `SPI` `UART` `GPIO` `ADC` `Hall Encoder` `Timer Interrupt`

### AI & Machine Learning at the Edge
`Edge Impulse` `TensorFlow Lite Micro` `TinyML` `MPU6050` `Anomaly Detection` `Neural Network Deployment` `Model Quantization`

### IoT & Connectivity
`MQTT` `Wi-Fi` `Node-RED` `BME280` `Sensor Fusion` `JSON` `ESP32 OTA`

### Software & Tools
`C` `C++` `Python` `Git` `GitHub` `STM32CubeIDE` `STM32CubeMX` `Arduino IDE` `Linux` `VS Code` `PuTTY`

---

## Education

**M.Sc. Embedded System Design**
University in Germany · 2024 – Present (Expected 2026)
*Relevant modules: Real-Time Systems, Digital Signal Processing, IoT Architecture, Embedded AI, Computer Architecture*

**B.E. Electronics / Electrical Engineering**
*(Details to be updated)*

---

## Work Experience

**Embedded Systems Engineer** · 1.5 years prior industry experience
*(Company details to be updated)*

---

## Contact

I am actively looking for Werkstudent positions in embedded systems engineering in Germany.

- 📧 **Email:** kkalariya201@gmail.com
- 💼 **LinkedIn:** [kishan-kalariya-3b2205210](https://www.linkedin.com/in/kishan-kalariya-3b2205210/)
- 💻 **GitHub:** [kishankalariya](https://github.com/kishankalariya)

---

*Kishan Harshukh Kalariya · Embedded System Projects · 2026*
