import serial
import time
import os
import struct

# ── Configuration ─────────────────────────────────
PORT     = "COM5"
BAUD     = 115200
FIRMWARE = r"C:\Embedded System Projects (Personal)\P1_FREERTOS_PID_CONTROL_MOTOR\Code\RTOS_PID_MOTOR\STM32_APP_TEST\Debug\STM32_APP_TEST.bin"

# ── STM32 CRC32 Calculation ───────────────────────
def stm32_crc32(data):
    crc = 0xFFFFFFFF

    # Pad to multiple of 4
    padded = bytearray(data)
    while len(padded) % 4 != 0:
        padded += b'\x00'

    for i in range(0, len(padded), 4):
        word = struct.unpack('<I',
               padded[i:i+4])[0]
        crc ^= word
        for _ in range(32):
            if crc & 0x80000000:
                crc = (crc << 1) ^ 0x04C11DB7
            else:
                crc <<= 1
            crc &= 0xFFFFFFFF
    return crc

# ── Main Script ───────────────────────────────────
def main():
    print("=" * 40)
    print("  STM32 Firmware Updater")
    print("  Kishan Kalariya")
    print("=" * 40)

    # Check firmware file exists
    if not os.path.exists(FIRMWARE):
        print(f"ERROR: File not found:")
        print(f"  {FIRMWARE}")
        return

    # Read firmware file
    with open(FIRMWARE, "rb") as f:
        firmware_data = f.read()

    firmware_size = len(firmware_data)
    print(f"Firmware size: {firmware_size} bytes")

    # Calculate CRC early for debug
    crc_value = stm32_crc32(firmware_data)
    print(f"CRC32: 0x{crc_value:08X}")
    print(f"First 4 bytes: "
          f"{firmware_data[0]:02X} "
          f"{firmware_data[1]:02X} "
          f"{firmware_data[2]:02X} "
          f"{firmware_data[3]:02X}")

    # Open serial port
    try:
        ser = serial.Serial(PORT, BAUD, timeout=5)
        print(f"Port {PORT} opened at {BAUD} baud")
    except Exception as e:
        print(f"ERROR opening port: {e}")
        return

    # ── Wait for bootloader banner ─────────────────
    print("\nPress RESET on Nucleo board now...")
    print("Waiting for bootloader...")

    ser.reset_input_buffer()
    time.sleep(0.2)

    banner = ""
    timeout = time.time() + 10
    found   = False

    while time.time() < timeout:
        if ser.in_waiting:
            banner += ser.read(
                ser.in_waiting).decode(
                'utf-8', errors='ignore')
            if "Waiting for update" in banner:
                found = True
                break
        time.sleep(0.1)

    print(f"Bootloader says:\n{banner}")

    if not found:
        print("ERROR: Bootloader not detected!")
        ser.close()
        return

    # ── Send update command ────────────────────────
    print("Sending update command '11'...")
    ser.write(b"11")
    time.sleep(1)

    response = ""
    timeout2 = time.time() + 3
    while time.time() < timeout2:
        if ser.in_waiting:
            response += ser.read(
                ser.in_waiting).decode(
                'utf-8', errors='ignore')
        time.sleep(0.1)

    print(f"Response: {response}")

    if "Update command received" not in response:
        print("ERROR: Update command not accepted!")
        ser.close()
        return

    # ── Send firmware size ────────────────────────
    print("Sending firmware size...")
    time.sleep(0.1)
    size_bytes = struct.pack('<I', firmware_size)
    ser.write(size_bytes)
    print(f"Size sent: {firmware_size} bytes")
    print(f"Size hex: {size_bytes.hex()}")

    # ── Wait for ACK ──────────────────────────────
    print("Waiting for ACK...")
    time.sleep(1)

    ack_data = ser.read(100)
    print(f"ACK buffer hex: {ack_data.hex()}")
    print(f"ACK buffer text: "
          f"{ack_data.decode('utf-8', errors='ignore')}")

    if b'\x55' in ack_data:
        print("ACK received! ✅")
    else:
        print("ERROR: No ACK received!")
        print("Trying to continue anyway...")

    # ── Send firmware data ─────────────────────────
    print("Sending firmware...")
    chunk_size = 128
    total_sent = 0

    for i in range(0, firmware_size, chunk_size):
        chunk = firmware_data[i:i + chunk_size]
        ser.write(chunk)
        total_sent += len(chunk)

        percent = (total_sent * 100) // firmware_size
        bar     = "█" * (percent // 5)
        print(f"\r  [{bar:<20}] {percent}%"
              f" ({total_sent}/{firmware_size})",
              end="", flush=True)
        time.sleep(0.02)

    print("\n\nAll bytes sent!")

    # ── Send CRC32 ────────────────────────────────
    print(f"Sending CRC32: 0x{crc_value:08X}")
    crc_bytes = struct.pack('<I', crc_value)
    ser.write(crc_bytes)
    print(f"CRC bytes hex: {crc_bytes.hex()}")

    # ── Wait for final response ────────────────────
    print("Waiting for bootloader result...")
    time.sleep(5)

    final = ""
    timeout4 = time.time() + 15
    while time.time() < timeout4:
        if ser.in_waiting:
            final += ser.read(
                ser.in_waiting).decode(
                'utf-8', errors='ignore')
        time.sleep(0.1)

    print(f"Final response:\n{final}")

    if "Update complete" in final:
        print("\n" + "=" * 40)
        print("  ✅ FIRMWARE UPDATE SUCCESSFUL!")
        print("  New application is running!")
        print("=" * 40)
    elif "Write OK" in final:
        print("\n✅ Flash write successful!")
        print("Application should be running!")
    elif "App Running" in final:
        print("\n✅ Application is running!")
    else:
        print("\n❌ UPDATE FAILED!")
        print("Check connections and try again")

    ser.close()

if __name__ == "__main__":
    main()