# Week 5 – System-level Design

## Lecture

- FIR filter
- Retiming to improve performance
- End-to-end system: UART RX + FIR filter + UART TX
  - Open an audio file in Python
  - Send to FPGA as bytes
  - Apply a low-pass filter
  - Get data from the FPGA and listen to the sound
