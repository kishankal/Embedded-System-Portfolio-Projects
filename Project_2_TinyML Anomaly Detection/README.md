# TinyML Anomaly Detection

**STM32 · MPU6050 · Edge Impulse · TensorFlow Lite Micro · On-Device Neural Network Inference**

[![Platform](https://img.shields.io/badge/Platform-STM32-blue)](https://www.st.com/en/microcontrollers-microprocessors/stm32-32-bit-arm-cortex-mcus.html)
[![ML](https://img.shields.io/badge/ML-Edge%20Impulse-brightgreen)](https://edgeimpulse.com/)
[![Language](https://img.shields.io/badge/Language-C%2B%2B-lightgrey)](https://en.wikipedia.org/wiki/C%2B%2B)
[![Inference](https://img.shields.io/badge/Inference-On--Device-orange)]()
[![Status](https://img.shields.io/badge/Status-Planned-lightgrey)]()

---

## What This Project Does

This project implements a **real-time vibration anomaly detection system** that runs entirely on an STM32 microcontroller — with no internet connection, no cloud server, and no external computer involved. A MPU6050 accelerometer sensor measures vibration in three axes (X, Y, Z) at 100 samples per second. A neural network, trained on labelled vibration data using Edge Impulse, classifies every 2-second window of sensor readings into one of three states:

| Classification | What It Means | System Response |
|---------------|--------------|----------------|
| `NORMAL` | Vibration is within expected range | LED off, no alert |
| `IMBALANCE` | Rhythmic deviation detected — early warning | LED blinks at 2Hz, terminal warning |
| `FAULT` | Irregular, high-magnitude vibration — critical | LED flashes at 10Hz, terminal alert |

The complete machine learning pipeline — data collection, feature extraction, neural network training, and C++ model export — is handled by Edge Impulse, a professional TinyML platform used by embedded engineers worldwide.

---

## Why This Project Was Built

### The Engineering Problem It Solves

Machines break down. A bearing wearing out, a rotor becoming unbalanced, a fastener loosening — these events do not happen instantly. They develop gradually over hours or weeks, with detectable changes in vibration patterns well before physical failure occurs. A human operator cannot monitor thousands of machines simultaneously. An internet-connected cloud system introduces latency, dependency on connectivity, and data privacy concerns. **The solution is to run the detection intelligence directly inside a microcontroller attached to the machine** — this is TinyML.

The challenge is fitting a functional neural network into a device with 512KB of flash memory and 128KB of RAM while meeting real-time inference requirements. This project solves that challenge using quantisation-aware training and the TensorFlow Lite Micro inference engine, which is specifically designed for microcontrollers.

### Why Edge Impulse Specifically

Edge Impulse is the industry-standard platform for deploying machine learning on embedded devices. It handles the most technically complex parts of the pipeline — signal windowing, spectral feature extraction, neural architecture design, and model optimisation — through a professional graphical interface while exporting production-quality C++ code. Engineers at Bosch, ST Microelectronics, Arduino, and Nordic Semiconductor use Edge Impulse in their own hardware products. Learning this tool is directly transferable to a professional environment.

### Why Not Cloud-Based ML

Cloud inference requires: a working network connection at all times, a server endpoint that may have downtime, 100–500ms of network latency per inference, and transmission of potentially sensitive operational data to a third party. In a factory environment, none of these are acceptable. The sensor must detect a fault within milliseconds of it occurring, regardless of network status. **On-device inference eliminates all of these constraints** — the detection happens in the same chip that reads the sensor, with inference latency under 100ms.

### Industrial Relevance in Germany and Globally

Predictive maintenance is one of the most actively invested areas in German industry. The specific technique used in this project — vibration-based anomaly detection using machine learning deployed at the edge — is not experimental. It is in production across multiple sectors:

**In Germany specifically:**
- **Schaeffler** (bearing and linear motion manufacturer, Herzogenaurach) has deployed vibration-based ML anomaly detection on their FAG SmartCheck sensor systems for industrial bearing condition monitoring. The algorithms running in those systems are architecturally identical to what this project implements.
- **Siemens** SIMATIC Edge computing platform and their MindSphere IoT analytics both support edge-deployed ML for machine health monitoring across German manufacturing clients.
- **Bosch Connected Industry** offers the Bosch IoT Insights platform which incorporates edge-level anomaly detection using accelerometer data — the same sensor type used in this project.
- **Festo** uses vibration analysis for predictive maintenance of pneumatic actuators and electric drives in their SmartMaintenance product line.
- **TRUMPF**, **Kuka**, and **Deckel Maho** (machine tool manufacturers) embed vibration monitoring in their CNC machines to detect tool wear before it causes part defects.
- **Deutsche Bahn** uses vibration anomaly detection on rolling stock to predict wheel bearing failures before they cause service disruptions.

**Globally:**
- **GE Aviation** uses accelerometer-based anomaly detection on jet engine components to predict maintenance needs during flight.
- **SKF** (global bearing manufacturer) has built the SKF Enlight Collect IMx-1 — a standalone sensor running edge ML for bearing fault detection — which is architecturally the same as this project but in a commercial enclosure.
- **Rockwell Automation** and **Emerson** have both released TinyML-capable vibration monitoring modules for industrial IoT integration.
- In wind energy, companies like Vestas and Siemens Gamesa run on-blade vibration analysis using ML to detect ice accumulation and structural fatigue before physical inspection.

The three vibration classes used in this project — **normal, imbalance, fault** — directly correspond to the three most common failure mode categories in rotating machinery (ISO 13373 standard for machine condition monitoring). This project is not a simplified demonstration. It mirrors real industrial practice.

---

## Hardware Components

| Component | Specification | Role in System |
|-----------|--------------|----------------|
| **STM32 Nucleo Board** | STM32F411RE, ARM Cortex-M4, 512KB Flash, 128KB RAM | Runs the FreeRTOS task that collects sensor data and executes neural network inference. The 128KB RAM is sufficient for the TFLite Micro runtime and model weights after quantisation |
| **MPU6050 Accelerometer + Gyroscope (GY-521)** | 6-axis (3-axis accel + 3-axis gyro), I2C interface, ±2g range for accel, 16-bit resolution, 3.3V/5V compatible | Primary sensor. Reads acceleration in X, Y, Z axes at 100Hz. The three-axis data over a 2-second window forms the input feature set for the neural network |
| **OLED Display 0.96" (SSD1306)** | 128×64 pixels, I2C, SSD1306 driver, 3.3V | Optional output device. Displays the current classification result (NORMAL / IMBALANCE / FAULT) as large text, updated every 2 seconds. Makes the demo visually compelling |

### Why Each Component Was Chosen

**MPU6050 over single-axis accelerometer:** Mechanical faults in rotating machinery produce characteristic vibration signatures across multiple axes simultaneously. A single-axis sensor would miss fault patterns that appear predominantly in the lateral or axial direction. The MPU6050 captures all three spatial dimensions in a single chip at low cost (~€3), making it the standard choice for industrial vibration monitoring prototypes.

**STM32 over ESP32 for inference:** While the ESP32 is used in Project 3 for its Wi-Fi capability, it has a less deterministic execution environment due to its dual-core Xtensa architecture and background Wi-Fi stack activity. The STM32 Cortex-M4 with FreeRTOS provides predictable interrupt latency and consistent 10ms sampling intervals — critical for accurate frequency-domain feature extraction. In industrial applications, timing determinism is not optional.

**Edge Impulse over manual TensorFlow Lite:** Building a complete ML pipeline manually — windowing, FFT feature extraction, network architecture search, quantisation calibration, C code export — requires weeks of work and deep ML expertise. Edge Impulse automates the entire pipeline correctly while remaining fully configurable. The exported C++ library is production-quality and has been validated on STM32 hardware by ST Microelectronics themselves.

---

## Machine Learning Pipeline

```
1. DATA COLLECTION
   STM32 + MPU6050 → Edge Impulse (via USB)
   3 classes × 60 samples × 2 seconds = 360 samples total
   Each sample: 200 readings × 3 axes = 600 float values

2. FEATURE EXTRACTION
   Edge Impulse Spectral Analysis block
   Input: raw time-series (200 × 3 values)
   Output: frequency-domain features (FFT bins, spectral power, RMS)
   Why: Fault frequencies are much more visible in frequency domain than time domain

3. NEURAL NETWORK TRAINING
   Architecture: 2 dense layers (20 neurons each) + softmax output (3 classes)
   Training: 30 epochs, Adam optimiser, learning rate 0.001
   Quantisation: INT8 post-training quantisation (reduces model size by ~4×)
   Target accuracy: > 90% overall, > 85% per class

4. DEPLOYMENT
   Export: STM32 CMSIS-PACK (C++ library)
   Runtime: TensorFlow Lite Micro inference engine
   Inference time: < 100ms on STM32F411RE at 100MHz
   Flash usage: ~120KB (model weights + TFLite Micro runtime)
   RAM usage: ~40KB (inference buffers)

5. ON-DEVICE INFERENCE
   STM32 collects 2s of data → runs ei_run_classifier() → classifies → outputs result
   Runs continuously, no external dependency
```

---

## Demo Video

> 📹 *Link to be added — will demonstrate all three classification states with live terminal output and LED response*

---

## Repository Structure

```
stm32-tinyml-anomaly-detection/
├── Core/
│   ├── Src/
│   │   ├── main.c                  # Entry point, task creation
│   │   ├── inference_task.c        # FreeRTOS task: collect → infer → output
│   │   ├── sensor.c                # MPU6050 I2C driver
│   │   └── display.c               # SSD1306 OLED driver (optional)
│   └── Inc/
│       ├── inference_task.h
│       └── sensor.h
├── edge-impulse-sdk/               # Edge Impulse C++ library (download separately — see instructions)
├── docs/
│   ├── wiring_diagram.png
│   └── ml_pipeline.png             # Data → EI → C++ → STM32 flowchart
├── README.md
└── EDGE_IMPULSE_PROJECT.md         # Link to public Edge Impulse project
```

---

## Build Instructions

**Requirements:** STM32CubeIDE, Edge Impulse account (free), hardware listed above.

1. Clone this repository
2. Download the Edge Impulse C++ library: go to the [Edge Impulse project](<!-- link to be added -->) → Deployment → STM32 Cube MX CMSIS-PACK → Build → download .pack file
3. Extract and copy the `edge-impulse-sdk` folder into the project root
4. Open STM32CubeIDE → Import → Existing Projects → select cloned folder
5. Add the Edge Impulse library include paths in Project Properties → C/C++ Build → Settings
6. Build and flash to the STM32 Nucleo board
7. Open PuTTY at 115200 baud — classification results appear every 2 seconds

---

## Author

**Kishan Harshukh Kalariya**
M.Sc. Embedded System Design · Germany · 2026
[LinkedIn](https://www.linkedin.com/in/kishan-kalariya-3b2205210/) · [GitHub](https://github.com/kishankalariya) · kkalariya201@gmail.com
