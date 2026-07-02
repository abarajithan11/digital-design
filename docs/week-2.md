# Week 2 – Combinational Logic

## Lecture

- Hello SystemVerilog!
- Number representation
  - Unsigned Integer
  - Addition, Multiplication
  - Two's complement
  - Dot product of vectors of size N
- ALU Components
  - Full adder
  - Ripple carry adder
  - Adder-Subtractor
  - Multiplication
  - Comparator
  - Shifter
  - Multiplexer
  - ALU
- Other combinational circuits
  - Demultiplexer
  - Encoder
  - Decoder
- SystemVerilog Functions
- Look-up Tables
- FPGA Design:
  - Meta-chip: a flexible chip that lets you realize your own digital circuit within it.
  - ASIC vs FPGA: speed, power, cost, time-to-market
  - Real-world applications
  - FPGA flow

## Assignment

- Create a module to apply quantization and ReLU: `y = relu(quant(x))`
  - Quantization: `q = clip(y / (2^f))`, where `f` is a constant
  - ReLU: `z = max(0, q)`
- For each combinational element
  - Consider inputs of 3 bits
  - Decompose into sum of minterms
  - Derive the minimal expression using K-maps
