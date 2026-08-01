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
  - Clamping/clipping - handling overflows

[Open slides in new tab](https://1drv.ms/p/c/154152893557b712/IQT7kM59SgRASaNRjaLbfVYhAYRXbM7EKvznsySSP964jGE)

<iframe src="https://1drv.ms/p/c/154152893557b712/IQT7kM59SgRASaNRjaLbfVYhAYRXbM7EKvznsySSP964jGE?em=2&amp;wdAr=1.7777777777777777" width="900px" height="534px" frameborder="0" title="PowerPoint Viewer">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>

## Lecture 2

- Number representation
  - Signed Multiplication
  - SystemVerilog Literals
  - Fixed Point Representation - calculate `kx + y`
  - Error from truncation
  - Banker's rounding - round to nearest even
  - Measure error
- Combinational Circuits 1
  - Half adder, Full adder, Ripple carry adder + Testbench
  - Adder-Subtractor
  - Comparator
  - Shifter: Logical, Arthmetic, Circular
  - Multiplexer
  - Saturating adder
  - ALU + Testbench
  - SV Functions
  - Lookup Tables
  - Demultiplexer

[Open slides in new tab](https://1drv.ms/p/c/154152893557b712/IQSgztkdDg20SIwxw_ZFSsguAVIiFKTMYSOc7TtWvFCauSc)

<iframe src="https://1drv.ms/p/c/154152893557b712/IQSgztkdDg20SIwxw_ZFSsguAVIiFKTMYSOc7TtWvFCauSc?em=2&amp;wdAr=1.7777777777777777" width="900px" height="534px" frameborder="0" title="PowerPoint Viewer">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>

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
