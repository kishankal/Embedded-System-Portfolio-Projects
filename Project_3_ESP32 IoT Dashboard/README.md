# ESP32 IoT Dashboard

**ESP32 · BME280 · MQTT · Node-RED · Wi-Fi · Real-Time Environmental Monitoring**

[![Platform](https://img.shields.io/badge/Platform-ESP32-red)](https://www.espressif.com/en/products/socs/esp32)
[![Protocol](https://img.shields.io/badge/Protocol-MQTT-purple)](https://mqtt.org/)
[![Language](https://img.shields.io/badge/Language-C%2B%2B-lightgrey)](https://en.wikipedia.org/wiki/C%2B%2B)
[![Dashboard](https://img.shields.io/badge/Dashboard-Node--RED-orange)](https://nodered.org/)
[![Status](https://img.shields.io/badge/Status-Planned-lightgrey)]()

---

## What This Project Does

This project implements a **live IoT environmental monitoring system** using an ESP32 microcontroller and a BME280 precision sensor. Every 5 seconds, the ESP32 reads temperature, humidity, and barometric pressure from the sensor and publishes the data as a structured JSON message over Wi-Fi to a local MQTT broker (Mosquitto). A Node-RED flow subscribes to the MQTT topic, parses the incoming data, and renders it as live gauge widgets on a browser-based dashboard accessible from any device on the same network.

The system includes configurable threshold alerting — when temperature exceeds a defined limit, a red warning banner appears on the dashboard immediately. The ESP32 handles automatic Wi-Fi and MQTT reconnection, so the device resumes publishing without manual intervention after a power cycle or network interruption.

**Data flow:**
```
BME280 Sensor → ESP32 (Wi-Fi) → MQTT Broker (Mosquitto) → Node-RED → Browser Dashboard
```

**Dashboard displays:**
- Temperature (°C) — live gauge, updates every 5 seconds
- Relative humidity (%) — live gauge
- Barometric pressure (hPa) — live gauge
- High temperature alert banner — triggers when temperature > configurable threshold

---

## Why This Project Was Built

### The Engineering Problem It Solves

Environmental conditions — temperature, humidity, and air pressure — affect almost every industrial and commercial process. Server rooms require precise temperature control to prevent hardware failures. Pharmaceutical cold chains must maintain strict humidity and temperature ranges throughout storage and transport. Factory floors monitor ambient conditions to ensure product quality in manufacturing processes sensitive to thermal expansion or moisture. Greenhouses automate ventilation and irrigation based on sensor readings. All of these applications share one fundamental architecture: **a sensor device that continuously measures conditions and transmits structured data to a monitoring system in real time**.

This project implements that architecture end-to-end, from the physical sensor to the live dashboard, using the exact protocols and tools deployed in production IoT systems across industry.

### Why MQTT Specifically

MQTT (Message Queuing Telemetry Transport) is the dominant messaging protocol for IoT devices worldwide. It was designed by engineers at IBM and Arcom (now part of Eurotech) in 1999 for monitoring oil pipelines over satellite connections — environments where bandwidth is limited and reliability under poor connectivity is critical. Those same properties make it ideal for battery-powered IoT sensors, factory floor devices, and any system where thousands of endpoints need to publish data efficiently without maintaining persistent HTTP connections.

MQTT operates on a publish/subscribe model: the ESP32 publishes to a topic (`home/environment`), and any number of subscribers (the Node-RED dashboard, a database logger, an alert system) receive the message simultaneously without the publisher knowing or caring who is listening. This decoupling is architecturally powerful — adding a new data consumer (a database, a mobile alert, a cloud backup) requires zero changes to the ESP32 firmware.

MQTT is used by: Amazon AWS IoT Core, Microsoft Azure IoT Hub, Google Cloud IoT, and virtually every industrial IoT platform in production. Learning MQTT on this project is directly applicable to enterprise IoT development.

### Why Node-RED Specifically

Node-RED is a flow-based visual programming tool developed by IBM and now maintained by the OpenJS Foundation. It is widely used in industrial IoT prototyping, smart building systems, and manufacturing automation dashboards because it allows rapid creation of data pipelines and dashboards without writing backend server code. A Node-RED flow can receive MQTT data, parse it, filter it, apply logic conditions, write to a database, and display it in a browser — all configured visually and deployable in minutes.

Node-RED is used in production by companies including Siemens, Honeywell, Schneider Electric, and numerous smart factory integrators across Germany. It is also the primary tool taught in many industrial IoT certification programmes in Europe.

### Industrial Relevance in Germany and Globally

Environmental monitoring using the exact architecture in this project is deployed across multiple sectors in Germany and worldwide:

**In Germany specifically:**
- **DAIKIN** and **Viessmann** (HVAC and building climate manufacturers) deploy distributed temperature and humidity sensors communicating via MQTT to building management systems across commercial real estate in Germany.
- **Bosch Building Technologies** (BT division) uses MQTT-based sensor networks for their building automation systems deployed in office buildings, hospitals, and industrial facilities across Europe.
- **GEA Group** (food processing equipment manufacturer, Düsseldorf) monitors temperature and humidity conditions in food processing lines — regulatory compliance in the food industry requires continuous environmental logging of exactly these three parameters.
- **Bayer AG** and **BASF** operate pharmaceutical and chemical production facilities where temperature and humidity monitoring is mandatory under GMP (Good Manufacturing Practice) regulations. The sensor nodes used in such systems are architecturally identical to this project.
- **Deutsche Telekom** and **Vodafone** have both deployed NB-IoT (Narrowband IoT) networks across Germany specifically to carry MQTT traffic from environmental sensors in logistics, agriculture, and smart city applications.
- **SAP** IoT platform, used by hundreds of German industrial companies, accepts MQTT-format sensor data from edge devices as its primary data ingestion method.

**Globally:**
- **Amazon** uses distributed environmental sensors in its fulfilment centres worldwide to maintain conditions suitable for electronics and temperature-sensitive goods — barometric pressure monitoring is used for altitude-related logistics planning.
- **Pfizer**, **Novartis**, and **Roche** operate cold chain monitoring systems for vaccine logistics that use BME280-equivalent sensors transmitting over MQTT with dashboard monitoring — the same stack this project implements.
- Smart agriculture systems (John Deere, Trimble) use arrays of environmental sensors per hectare of farmland, each transmitting temperature, humidity, and pressure data via MQTT to farm management dashboards.
- The International Space Station uses environmental monitoring systems in every module — the principle of continuous sensor-to-dashboard data streaming is identical, scaled up in reliability requirements.
- Data centre operators globally (Equinix, Digital Realty) run dense environmental sensor networks where BME280-type sensors monitor hot-aisle/cold-aisle temperature gradients and humidity levels to optimise cooling energy use.

The barometric pressure reading from the BME280 — which may seem less immediately useful than temperature or humidity — enables altitude estimation (useful in indoor positioning and drone applications), weather prediction (rapid pressure drops indicate incoming storms), and process quality control in altitude-sensitive manufacturing like semiconductor fabrication.

---

## Hardware Components

| Component | Specification | Role in System |
|-----------|--------------|----------------|
| **ESP32 DevKit** | Xtensa dual-core 240MHz, 4MB Flash, 520KB RAM, 802.11 b/g/n Wi-Fi, Bluetooth 4.2 | Main microcontroller and Wi-Fi radio. The ESP32's built-in Wi-Fi stack handles all TCP/IP networking — no external module required. Runs the MQTT client and sensor reading loop |
| **BME280 Sensor Module** | Bosch Sensortec BME280, I2C/SPI interface, temperature (±1°C), humidity (±3%RH), pressure (±1hPa), 3.3V operation, ultra-low power (0.1µA sleep) | All-in-one environmental sensor. Measures three independent physical quantities in a single 2.5mm chip. The Bosch BME280 is the industry-standard sensor for environmental monitoring — used in smartphones (Pixel, Galaxy), weather stations, and industrial nodes |

### Why Each Component Was Chosen

**ESP32 over STM32 for this project:** The ESP32 has a fully integrated Wi-Fi and Bluetooth radio with a mature Arduino-compatible SDK (ESP-IDF / Arduino-ESP32). Implementing Wi-Fi on an STM32 requires an external module (ESP8266/ESP32-AT or Wiznet chip), additional firmware drivers, and significantly more development time. Since the primary goal of this project is demonstrating IoT connectivity via MQTT, the ESP32 is the correct choice — it makes the networking layer straightforward while still running real embedded C++ firmware.

**BME280 over DHT22 or BMP280:** The DHT22 measures only temperature and humidity and uses a single-wire protocol with slow 500ms sample intervals. The BMP280 measures only temperature and pressure. The BME280 measures all three in a single package with I2C interface, 100ms sample capability, and significantly lower power consumption. It is a Bosch Sensortec product — Bosch is a major industrial sensor manufacturer headquartered in Stuttgart, and the BME280 is found in their own IoT reference designs. Using it in this project reflects real-world component selection.

**Mosquitto MQTT broker over cloud broker (HiveMQ, AWS IoT):** Running Mosquitto locally on the development PC demonstrates understanding of how MQTT infrastructure works independently of cloud services. In a production system, the broker would run on a dedicated server or cloud instance — but the protocol is identical. Local operation also means the project works without internet access, which is important for factory environments with isolated networks.

**Node-RED over a custom web dashboard:** Node-RED demonstrates a transferable tool skill. Building a custom JavaScript/React dashboard would take significantly more time and produce a less reusable result. Node-RED is what a professional embedded developer would reach for when building a rapid IoT prototype dashboard — demonstrating its use shows industrial tool awareness.

---

## System Architecture

```
┌─────────────────────────────────────────────────────┐
│                   ESP32 Firmware                    │
│                                                     │
│  BME280 ──I2C──▶ Read sensor() ──▶ Format JSON     │
│                                          │          │
│                                    Wi-Fi TCP/IP     │
│                                          │          │
└──────────────────────────────────────────┼──────────┘
                                           │
                                    MQTT publish
                                    topic: home/environment
                                    payload: {"temp":22.4,"hum":48.1,"pres":1013.2}
                                           │
                                           ▼
                               ┌─────────────────────┐
                               │  Mosquitto Broker   │
                               │  localhost:1883     │
                               └──────────┬──────────┘
                                          │
                                   MQTT subscribe
                                          │
                                          ▼
                               ┌─────────────────────┐
                               │    Node-RED Flow    │
                               │                     │
                               │  MQTT-in ──▶ JSON   │
                               │  parse ──▶ Gauges   │
                               │         ──▶ Alert   │
                               └──────────┬──────────┘
                                          │
                                          ▼
                               Browser Dashboard
                               localhost:1880/ui
                               (Any device on network)
```

---

## MQTT Message Format

The ESP32 publishes to topic `home/environment` every 5 seconds:

```json
{
  "temperature": 22.4,
  "humidity": 48.1,
  "pressure": 1013.2,
  "device": "esp32-bme280",
  "timestamp_ms": 142530
}
```

The Node-RED flow parses this JSON and routes each field to its corresponding dashboard widget. The `pressure` field value is compared against a configurable threshold — currently set to 30°C for temperature alerts.

---

## Demo Video

> 📹 *Link to be added — will show live dashboard updating, humidity response to breath, and temperature alert triggering*

---

## Repository Structure

```
esp32-iot-dashboard/
├── src/
│   └── main.cpp               # Complete ESP32 firmware
├── node-red/
│   └── flows.json             # Export of Node-RED dashboard flow (importable)
├── docs/
│   ├── wiring_diagram.png     # BME280 to ESP32 connections
│   └── dashboard_screenshot.png
├── README.md
└── platformio.ini             # PlatformIO project config (alternative to Arduino IDE)
```

---

## Build Instructions

**Requirements:** Arduino IDE with ESP32 board support, Mosquitto, Node-RED, hardware listed above.

**ESP32 Firmware:**
1. Install Arduino IDE and add ESP32 board support via Boards Manager URL: `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json`
2. Install libraries: `Adafruit BME280 Library`, `Adafruit Unified Sensor`, `PubSubClient`
3. Open `src/main.cpp`, update `ssid`, `password`, and `mqtt_server` with your network details
4. Select board: `ESP32 Dev Module`, flash size: `4MB`
5. Upload via USB

**MQTT Broker:**
1. Install Mosquitto: [mosquitto.org/download](https://mosquitto.org/download/)
2. Start service: `mosquitto -v` (Windows) or `sudo systemctl start mosquitto` (Linux)

**Node-RED Dashboard:**
1. Install Node-RED: `npm install -g --unsafe-perm node-red`
2. Start: `node-red`
3. Open `http://localhost:1880`
4. Menu → Import → paste contents of `node-red/flows.json`
5. Click Deploy
6. Open dashboard at `http://localhost:1880/ui`

---

## Author

**Kishan Harshukh Kalariya**
M.Sc. Embedded System Design · Germany · 2026
[LinkedIn](https://www.linkedin.com/in/kishan-kalariya-3b2205210/) · [GitHub](https://github.com/kishankalariya) · kkalariya201@gmail.com
