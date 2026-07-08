# Week 5 – System-level Design

## Lecture

- FIR filter
- Retiming to improve performance
- End-to-end system: UART RX + FIR filter + UART TX
  - Open an audio file in Python
  - Send to FPGA as bytes
  - Apply a low-pass filter
  - Get data from the FPGA and listen to the sound
- Incremental CPU Design (7 opcodes, 40-lines of SV)
  1. Memory module
  2. Reading instructions (PC)
  3. Load data: `LOAD`
  4. Store data: `STORE`
  5. ALU operations: `MOV, ADD, SUB, MUL`
  6. Jump instruction: `JNZ`
- Try programs:
  - Sum first N numbers
  - Fibonacci sequence
  - Factorial