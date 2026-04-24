# Week 4 – Practical Circuits

## Lecture

- AXI-Stream Protocol
  - Ready/valid handshake
  - Converting an adder tree to AXI-Stream
- FSM
  - 3-process coding style
  - Parallel-to-serial converter
- UART serial protocol
  - AXI-Stream UART Transmitter
  - AXI-Stream UART Receiver

## Discussion: FPGA System

- Put UART RX + TX back-to-back on an FPGA
- Write a Python script to send a series of numbers to the FPGA via a serial port, get the numbers back, and display them

## Assignment

- Put multiple `rq_cvmac` (ReLU-quantized constant-vector multiply-accumulate) blocks together to create a fully parallel dense layer, and test it with our testbench
- Convert the dense layer into an AXI-Stream module
- Chain multiple dense layers into a dense NN
- Integrate into the UART FPGA system, and test with our testbench
- Send MNIST inputs and get outputs
