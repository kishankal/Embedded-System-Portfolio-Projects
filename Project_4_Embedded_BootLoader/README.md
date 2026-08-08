# Project 4 — Bare-Metal UART Bootloader with CRC32
## STM32F411RE Nucleo-64

---

## Overview
A production-style bare-metal UART bootloader
implemented from scratch in C on STM32F411RE.
Enables firmware updates over standard UART
without ST-Link after initial deployment.
Includes a Python host script that automates
the complete update process with progress bar
and CRC32 integrity verification.

---

## Features
- Update command detection within 3 second window
- Custom 5-step binary UART protocol
- CRC32 hardware verification before flash write
- Sector-level flash erase (HAL_FLASHEx_Erase)
- Word-level flash write (HAL_FLASH_Program)
- Vector table relocation (SCB->VTOR)
- Graceful recovery on update failure
- Python host script with live progress bar

---

## Memory Map
| Region      | Address    | Size   | Content        |
|-------------|------------|--------|----------------|
| Bootloader  | 0x08000000 | 16 KB  | Sector 0       |
| Application | 0x08004000 | 496 KB | Sectors 1 to 7 |
| RAM         | 0x20000000 | 128 KB | Stack + Heap   |

---

## UART Protocol
Step 1: Host sends ASCII '11'
Step 2: Bootloader sends size request
Step 3: Host sends 4-byte firmware size
Step 4: Bootloader sends ACK (0x55)
Step 5: Host sends firmware binary
Step 6: Host sends CRC32 (4 bytes)
Step 7: Bootloader verifies, flashes, jumps

---

## Hardware Required
| Component         | Detail                    |
|-------------------|---------------------------|
| STM32F411RE       | Nucleo-64 development board|
| USB Cable         | Power + ST-Link flashing   |
| PC                | Python 3 + pyserial        |

No extra hardware needed beyond the Nucleo board.

---

## How To Use

### Step 1 — Flash Bootloader (one time only)
Open STM32CubeIDE
Open Code/STM32_BOOTLOADER project
Build and flash via ST-Link

### Step 2 — Flash Test Application (one time only)
Open Code/STM32_APP_TEST project
Build and flash via ST-Link
Confirm "App Running! v1.0" in PuTTY

### Step 3 — Update Firmware Via Python
Install pyserial:
pip install pyserial

Close PuTTY

Run:
python Python/flash_firmware.py

When prompted:
Press RESET button on Nucleo board

Watch progress bar and result

### Step 4 — Expected Output
STM32 Firmware Updater
Kishan Kalariya

Firmware size: 8172 bytes
CRC32: 0xAD7F7416
Port COM5 opened at 115200 baud

Press RESET on Nucleo board now...
Sending update command '11'...
ACK received! ✅
Sending firmware...
[████████████████████] 100% (8172/8172)

Erasing flash... Erase OK!
Writing flash... Write OK!
Update complete!

========================================
✅ FIRMWARE UPDATE SUCCESSFUL!

---

## Project Structure
Project_4_BootLoader/
├── Code/
│ ├── STM32_BOOTLOADER/ ← bootloader source
│ │ └── Src/main.c
│ └── STM32_APP_TEST/ ← test application
│ └── Src/main.c
├── Python/
│ └── flash_firmware.py ← PC upload script
├── Documents/
│ ├── P2_Bootloader_Report_Kishan_Kalariya.docx
│ └── P2_Interview_Prep_Kishan_Kalariya.docx
└── README.md

---

## Key Technical Concepts

| Concept                  | Implementation                        |
|--------------------------|---------------------------------------|
| Flash erase              | HAL_FLASHEx_Erase sectors 1-7         |
| Flash write              | FLASH_TYPEPROGRAM_WORD 4 bytes at time |
| CRC polynomial           | 0x04C11DB7 STM32 hardware unit         |
| Vector table relocation  | SCB->VTOR = 0x08004000                 |
| Stack pointer setup      | __set_MSP(app_stack)                   |
| Jump to application      | Function pointer to reset handler      |
| UART buffer flush        | While loop read until HAL_TIMEOUT      |
| Python byte ordering     | struct.pack('<I') little-endian        |

---

## Challenges Solved
1. **UART buffer contamination** — command bytes
   leaking into size receive buffer
2. **CRC32 endianness mismatch** — Python
   big-endian vs STM32 little-endian
3. **Python timing** — fixed delays replaced
   with event-driven banner detection
4. **ACK byte detection** — removed
   reset_input_buffer before ACK read

---

## PuTTY Settings
Port: COM5 (check Device Manager)
Baud: 115200
Data bits: 8
Stop bits: 1
Parity: None
Terminal: Enable implicit CR + LF

---

## Author
**Kishan Harshukh Kalariya**
MSc Embedded System Design
Hochschule Bremerhaven, Germany
GitHub: github.com/kishankal/Embedded-System-Portfolio-Projects

---

## License
MIT License — free to use and learn from
