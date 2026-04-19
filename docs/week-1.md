# Week 1 – Digital Logic Design

## Lecture 1

- Electronic Chip - Demystified
  - Programming: program → assembly → machine code → Arduino's microprocessor
  - IC package, die, layers of transistors, metal wires
  - Visual 6502: [simulation of a CPU's layout](http://www.visual6502.org/JSSim/expert.html)
  - Today: Megacities on a Chip
- ASIC Design: Story of the first processor (Intel 4004)
  - Computer Architecture, Layout, Ruby cutting - all by hand
  - Today's chips are much more complex & performant - expensive software to help with the flow
    - Logic design
    - Physical design
    - Standard cells
    - Manufacturing: ASML machines, clean rooms, lithography
- FPGA Design:
  - Meta-chip: a flexible chip that lets you realize your own digital circuit within it.
  - ASIC vs FPGA: speed, power, cost, time-to-market
  - Real world applications
  - FPGA flow

## Lecture 2

- Take an example Boolean function (e.g.: adder)
  - Logic to gates
    - K-maps
    - Sum of products / Product of sums
    - Write a SystemVerilog module made of the gates
  - Run our script to generate 7 nm (ASAP7) layout, observe the transistors
  - Write a simple testbench, simulate the design, observe values over time.
  - Do the same by directly writing the function in SystemVerilog
- Abstraction layers: A map of career paths in digital design
  - Computer Architecture
  - Logic design - This course
  - Physical design
  - Verification
  - Analog design

## Discussion

- Setting up our docker container in your machine
- Setting up FPGA boards

## Assignment

- For a given list of boolean functions
  - Decompose into Sum of Products and Product of Sums
  - Write it as an SV file, get layout and observe transistors
  - Simulate
  - Write the function directly in SystemVerilog and do the same