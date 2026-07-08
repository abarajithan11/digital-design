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

## Assignment 4: AXI Stream NN Accelerator System

1. Convert your `dense_relu` layer into an AXI-Stream module
1. Chain multiple dense layers into a dense NN accelerator (AXI stream)
1. Integrate into the UART system, and test with our testbench
1. [Optional] Implement on your FPGA, send MNIST inputs and get outputs
