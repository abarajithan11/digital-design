# Intro to Digital Design - An End to End Approach

## Week 1 – Digital Logic and HDL

### Lecture:

- Inside an electronic chip: abstraction layers `Architecture, Verilog, Netlist, Gates, Transistors`
- Take an example Boolean function (e.g.: adder)
  - Logic to gates
    - K-maps
    - Sum of products / Product of sums
    - Write SystmVerilog module made of the gates
  - Run our script to generate 7nm (ASAP7) layout, observe the transistors
  - Write a simple testbench, simulate the design, observe values over time.
  - Do the same by directly writing the function in SystemVerilog
- Abstraction layers again, as a map of career paths in digital design
    - Architecture - cache type...etc.
    - Logic design - this course
    - Physical design - running tools to get GDS2, fixing problems
    - Verification - simulation
    - Analog design - creating PDK cells

### Assignment:

- For a given list of boolean functions
  - Decompose into gates
  - write as an SV file, get layout and observe transistors
  - simulate
  - write the function directly in verilog and do the same

## Week 2 – Combinational Logic

### Lecture:

- N-bit adder + testbench
- Mux
- ALU
- Encoder
- Decoder
- Verilog functions
- LUT

### Assignment:

- Create module to apply quantization and relu: `y = relu(quant(x))`
- Quantization: `q = y/(2^f)`. where `f` is a constant
- ReLU `z = (y > 0) ? y : 0`

## Week 3 – Sequential Logic

### Lecture:

- Intro
  - All circuits are a mix of combinational and sequential logic
  - Why a chip needs a clock
- Flip-flop, Register
- Counter
- Parametrized Adder Tree `y = sum(X)`
- Setup time & hold time

### Assignment:

- Based on the adder tree, create a constant vector MAC, to do `y = sum(W.X + B)`, where `W` & `B` are constants
- Update it to include quantization and relu (`rq_cvmac`)


## Week 4 – Practical Circuits

### Lecture:

- AXI-Stream Protocol
  - Ready-Valid handshake
  - Converting Adder Tree to AXI-Stream
- FSM
  - 3-process coding style
  - Parallel-to-serial converter
- UART serial protocol
  - UART Transmitter
  - UART Receiver

### Discussion: FPGA System

- Put UART RX + TX back to back on FPGA
- Write a Python script to send a series of numbers to serial, get numbers and display

### Assignment:

- Put multiple `rq_cvmac`s together to create a fully-parallel dense layer, test with our testbench
- Convert dense into AXI Stream module
- Chain multiple dense layers into a dense NN
- Integrate into the UART FPGA system, and test with our testbench
- Send MNIST inputs and get outputs

## Week 5 – System-level Design

### Lecture:

- FIR filter
- Retiming to improve performance
- Convert FIR filter into AXI Stream
- End-to-end system: UART RX + FIR filter + UART TX
  - Open an audio file in Python
  - Send to FPGA as bytes
  - Apply a low pass filter
  - Get data from FPGA, listen to the sound

## Navigation

```{toctree}
:maxdepth: 1

design_outputs
week-1
week-2
week-3
week-4
week-5
setting-up-pynq
setting-up-docker
```