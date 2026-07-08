# Week 2 – Combinational Logic

## Lecture 1

- K-Maps
  - 3 variable, 4-variable
  - don't cares
  - wrap around
  - limits of K-maps: Half Adder
- Hello SystemVerilog!
  - Programming language vs HDL
  - Two roles: design (hardware) & verification (software)
  - **Activity:** Run hello world examples, view waveforms
- Number representation
  - Unsigned Integer: Binary ↔ Decimal
  - Addition, bit growth
  - Dot product of vectors of size N
  - Sign-Magnitude, Two's complement
  - Multiplication
  - Overflow
  - Handling overflow: clamping/clipping

## Lecture 2

- Number representation
  - Fixed-point arithmatic, measure error
  SystemVerilog Literals
- Combinational Circuits 1
  - Half adder, Full adder, Ripple carry adder + Testbench
  - Adder-Subtractor
  - Comparator
  - Shifter: Logical, Arthmetic, Circular
  - Error from truncation
  - Multiplexer
  - Logic using multiplexers
  - Saturating adder
  - ALU + Testbench
  - SV Functions
  - Lookup Tables
  - Demultiplexer
- Sequential Circuits 1
  - Latches, Flipflops and Registers
- Combinational circuits 2
  - Encoder, priority encoder
  - Decoder
  - Logic using decoders
  - Register file example

### Slides

[Open slides in new tab](https://1drv.ms/p/c/154152893557b712/IQT7kM59SgRASaNRjaLbfVYhAYRXbM7EKvznsySSP964jGE)

<iframe src="https://1drv.ms/p/c/154152893557b712/IQT7kM59SgRASaNRjaLbfVYhAYRXbM7EKvznsySSP964jGE?em=2&amp;wdAr=1.7777777777777777" width="900px" height="534px" frameborder="0" title="PowerPoint Viewer">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>

## Discussion

- FPGA Design:
  - Meta-chip: a flexible chip that lets you realize your own digital circuit within it.
  - ASIC vs FPGA: speed, power, cost, time-to-market
  - Real-world applications
  - FPGA flow


## Assignment 2

- Theory
  - Number representation, 
  - K-maps of muxes, multipliers...etc.
- Programming Assignments:
  - `quant_relu` module to perform:
    - Divide an input by `2^SHIFT`
    - Perform banker's rounding / round to nearest even
    - Clamp it to the output width
    - `ReLU(x) = max(0,x)`
  - Two `popcount(x)` modules that count the number of 1s in `x`. One as a LUT, other as a combinational circuit (SV function)
