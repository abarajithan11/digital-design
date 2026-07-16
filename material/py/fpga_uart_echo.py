#!/usr/bin/env python3
"""Loopback test for the uart_echo design: send random bytes, check they come
back byte-for-byte.

    make program_fpga DESIGN=uart_echo
    python3 /path/to/digital-design/material/py/uart_echo.py

PORT is the board's serial port: /dev/ttyUSB1 in WSL/Linux, COM5 on Windows,
/dev/tty.usbserial-* on macOS. We send in 32-byte chunks (the bridge's buffer
size) and read each chunk back, since there is no hardware flow control.
"""
import random
import serial

PORT  = "/dev/ttyUSB1"
BAUD  = 2_000_000
N     = 4096
CHUNK = 32

data = bytes(random.randrange(256) for _ in range(N))

got = bytearray()
with serial.Serial(PORT, BAUD, timeout=2) as ser:
    ser.reset_input_buffer()
    for i in range(0, N, CHUNK):
        chunk = data[i:i + CHUNK]
        ser.write(chunk)
        ser.flush()
        received = bytearray()
        while len(received) < len(chunk):
            part = ser.read(len(chunk) - len(received))
            if not part:
                raise TimeoutError(
                    f"UART timeout at byte {i + len(received)} ({len(got)}/{N} completed)"
                )
            received += part
        got += received

if bytes(got) == data:
    print(f"PASS: echoed {N} bytes with no loss.")
else:
    print(f"FAIL: sent {N}, got {len(got)} bytes back (mismatch).")
