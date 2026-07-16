#!/usr/bin/env python3
"""Filter live microphone audio through the sys_fir_filter FPGA design.

    make program_fpga DESIGN=sys_fir_filter
    python3 /path/to/digital-design/material/py/fir_live_audio.py

Records from the default input, streams the samples through the FPGA and plays
the filtered ones on the default output. You should hear only the bass. Ctrl-C
to stop.

There is no hardware flow control, and the board drops samples if it is handed
more than BURST bytes back to back, so a writer thread paces the link at the
audio rate instead of sending each block in one go. The filtered bytes come
back a few ms later, so a reader thread collects them and LEAD blocks are
buffered before playback starts. PORT is the board's serial port.

Needs a PortAudio that can see your mic (on WSL: apt install libportaudio2
libasound2-plugins, with ALSA defaulting to pulse).
"""
import queue
import threading
import time

import numpy as np
import serial
import sounddevice as sd

PORT  = "/dev/ttyUSB1"
BAUD  = 2_000_000
BURST = 32       # bytes the board absorbs back to back (the bridge's buffer)
BLOCK = 512      # samples per audio callback
RATE  = 44100    # the rate the filter's coefficients were designed for
LEAD  = 4        # blocks buffered before playback, to cover the reply latency

to_fpga = queue.Queue()         # int8 blocks from the mic
from_fpga = bytearray()         # filtered bytes, filled by the reader thread
lock = threading.Lock()


def writer(ser):
    """Send BURST bytes at a time, paced at RATE bytes/s so the board keeps up."""
    due = time.perf_counter()
    while True:
        raw = to_fpga.get().tobytes()
        for i in range(0, len(raw), BURST):
            ser.write(raw[i:i + BURST])
            due = max(due + BURST / RATE, time.perf_counter() - 0.05)
            while time.perf_counter() < due:   # too coarse for time.sleep
                pass


def reader(ser):
    """Collect filtered bytes for as long as the board sends them."""
    while True:
        chunk = ser.read(1) + ser.read(ser.in_waiting or 0)
        with lock:
            from_fpga.extend(chunk)


def callback(indata, outdata, frames, time_info, status):
    # float [-1,1] -> int8, matching fir_audio.py's quantization
    to_fpga.put(np.clip(np.round(indata[:, 0] * 128), -128, 127).astype(np.int8))
    outdata[:] = 0
    with lock:
        if len(from_fpga) >= frames:
            y = np.frombuffer(bytes(from_fpga[:frames]), dtype=np.int8)
            del from_fpga[:frames]
            outdata[:, 0] = y.astype(np.float32) / 128.0


with serial.Serial(PORT, BAUD, timeout=0.1) as ser:
    ser.reset_input_buffer()
    threading.Thread(target=writer, args=(ser,), daemon=True).start()
    threading.Thread(target=reader, args=(ser,), daemon=True).start()

    with sd.Stream(samplerate=RATE, blocksize=BLOCK, dtype="float32",
                   channels=1, callback=callback):
        print(f"Filtering mic -> FPGA -> speakers at {RATE} Hz. Ctrl-C to stop.")
        try:
            while True:
                sd.sleep(1000)
        except KeyboardInterrupt:
            print("\nStopped.")
