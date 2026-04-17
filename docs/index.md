# Intro to Digital Design - An End to End Approach

Welcome to the course site.

## Overview

This site contains week-by-week material and setup guides for the course.

- Weekly notes and activities
- Hardware setup with PYNQ
- Development setup with Docker

Use the navigation menu to move between sections.


## Syllabus

### Week 1 – Digital Logic and HDL

- **Intro**
  - Inside an electronic chip: abstraction layers
    - Architecture
    - Verilog
    - Netlist (cells)
    - Gates
    - Transistors
- Take an example Boolean function (e.g.: adder)
  - Logic to gates
    - K-maps
    - Sum of products / Product of sums
    - Write SystmVerilog module made of the gates
  - Run our script to generate 7nm (ASAP7) layout, observe the transistors
  - Write a simple testbench, simulate the design, observe values over time.
  - Do the same by directly writing the function in SystemVerilog
- **Assignment**
  - For a given list of boolean functions, decompose into gates, write get layout and observe transistors, simulate, write the function directly and do the same
- **Outro**
  - Abstraction layers again
  - A map of different jobs in digital design and what they do
    - Architecture - cache type...etc.
    - Logic design - boolean function
    - Physical design - running tools to get GDS2, fixing problems
    - Verification - simulation
    - Analog design - creating PDK cells

### Week 2 – Combinational Logic

- N-bit adder + testbench
- Mux
- ALU
- Encoder
- Decoder
- Verilog functions
- LUT

### Week 3 – Sequential Logic

- Intro
  - All circuits are a mix of combinational and sequential logic
  - Why a chip needs a clock
- Flip-flop
- Register
- Counter
- FIR filter
- FSM
  - 3-process coding style

### Week 4 – Practical Circuits

- Parallel-to-serial converter
- AXI-Stream: Ready-Valid handshake
- Vector Multiply Adder: `y = sum(W.X + B)`
- Converting it to AXI-Stream

- UART serial protocol
  - UART Transmitter
  - UART Receiver

- Discussion: **FPGA System**
  - Put UART RX + TX back to back on FPGA
  - Write a Python script to send a series of numbers to serial, get numbers and display

### Week 5 – System-level Design

- Constant Vector MAC: (`y = sum(W.X + B)`), where W, B are constant parameter arrays

- **Assignment**
  - Add ReLU to CVMAC
  - Put multiple CVMACs into a dense layer, and test with our testbench
  - Convert dense into AXI Stream module
  - Chain multiple dense layers into a dense NN
  - Integrate into the UART FPGA system, and test with our testbench
  - Send MNIST inputs and get outputs
