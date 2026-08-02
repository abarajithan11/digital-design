# Week 3 – Sequential Logic

## Lecture 1

- ALU + Testbench
- Sequential Circuits 1
  - Storing a bit - Inverter loop
  - SR Latch
  - D Latch
  - Flipflops and Registers
  - Registers in SystemVerilog
  - Reset (active low/high, sync, async), clock enable
  - Shift register
- Timing Analysis
  - Why a chip needs a clock
  - Propagation Delay, Contamination Delay

[Open slides in new tab](https://1drv.ms/p/c/154152893557b712/IQQnF3pXUWjyRb1Q7vgkzwd7AYcaMCiqpMjAPdJWb0KKPMw)

<iframe src="https://1drv.ms/p/c/154152893557b712/IQQnF3pXUWjyRb1Q7vgkzwd7AYcaMCiqpMjAPdJWb0KKPMw?em=2&amp;wdAr=1.7777777777777777" width="900px" height="534px" frameborder="0" title="PowerPoint Viewer">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>

## Lecture 2

- Register file example: Flip flop + decoder + multiplexer + demultiplexer
- Timing Analysis
  - Setup time, Hold time
  - Critical path analysis
- Live coding SystemVerilog: pipelined `a*x + b`
- Parameterized Binary Reduction Tree to find the minimum value in a vector `y = min(X)`
- Finite State Machines
  - Counter
  - Pattern detector
  - Mealy and Moore Machines

## Discussion

- Hands-on FPGA
- Implement a counter on FPGA

[Open slides in new tab](https://1drv.ms/p/c/154152893557b712/IQQCbHLcMd9fTbYvzkfQvLRWAcFgFTIvopyMca2XEFBDY1k)

<iframe src="https://1drv.ms/p/c/154152893557b712/IQQCbHLcMd9fTbYvzkfQvLRWAcFgFTIvopyMca2XEFBDY1k?em=2&amp;wdAr=1.7777777777777777" width="900px" height="534px" frameborder="0" title="PowerPoint Viewer">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>

## Assignment 3: Fully parallel dense layer 

This assignment is intended to develop your skills in hierarchical design & parameterized hardware generation using SystemVerilog.

1. Convert the parameterized minimum-finding module to perform `y = sum(X)`
2. Create a constant-vector MAC module to compute `y = sum(K.X + B)`, where `K` and `B` are parameter arrays.
3. Create a module to requantize the output and optionally do ReLU, using the module from A2.
4. Create a module `dense_relu` with optional ReLU with `N_OUTPUTS` number of the above module.
5. Use our basic testbenches to test (1,2,3,4)
6. Write an advanced testbench to do randomized testing
