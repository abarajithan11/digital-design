## Week 4 – Practical Circuits

### Lecture:

- AXI-Stream Protocol
  - Ready-Valid handshake
  - Converting Adder Tree to AXI-Stream
- FSM
  - 3-process coding style
  - Parallel-to-serial converter
- UART serial protocol
  - AXI-Stream UART Transmitter
  - AXI-Stream UART Receiver

### Discussion: FPGA System

- Put UART RX + TX back to back on FPGA
- Write a Python script to send a series of numbers to FPGA via serial port, get numbers back and display

### Assignment:

- Put multiple `rq_cvmac` (relu-quantized-constant-vector-multiply-accumulate)s together to create a fully-parallel dense layer, test with our testbench
- Convert dense into AXI Stream module
- Chain multiple dense layers into a dense NN
- Integrate into the UART FPGA system, and test with our testbench
- Send MNIST inputs and get outputs
