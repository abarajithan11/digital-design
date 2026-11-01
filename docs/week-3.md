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

[Slides with animations](https://1drv.ms/p/c/154152893557b712/IQQnF3pXUWjyRb1Q7vgkzwd7AYcaMCiqpMjAPdJWb0KKPMw) · [PDF slides](https://media.abapages.com/course-site/slides/cse140_3_1.pdf)

<div class="slides-embed">
<iframe src="https://media.abapages.com/course-site/slides/cse140_3_1.pdf" title="Week 3 Lecture 1 slides (PDF)">Your browser does not support embedded PDFs. <a href="https://media.abapages.com/course-site/slides/cse140_3_1.pdf">Open the slides PDF</a>.</iframe>
</div>

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

[Slides with animations](https://1drv.ms/p/c/154152893557b712/IQQCbHLcMd9fTbYvzkfQvLRWAcFgFTIvopyMca2XEFBDY1k) · [PDF slides](https://media.abapages.com/course-site/slides/cse140_3_2.pdf)

<div class="slides-embed">
<iframe src="https://media.abapages.com/course-site/slides/cse140_3_2.pdf" title="Week 3 Lecture 2 slides (PDF)">Your browser does not support embedded PDFs. <a href="https://media.abapages.com/course-site/slides/cse140_3_2.pdf">Open the slides PDF</a>.</iframe>
</div>

## Assignment 3: Fully parallel dense layer 

This assignment is intended to develop your skills in hierarchical design & parameterized hardware generation using SystemVerilog.

1. Convert the parameterized minimum-finding module to perform `y = sum(X)`
2. Create a constant-vector MAC module to compute `y = sum(K.X + B)`, where `K` and `B` are parameter arrays.
3. Create a module to requantize the output and optionally do ReLU, using the module from A2.
4. Create a module `dense_relu` with optional ReLU with `N_OUTPUTS` number of the above module.
5. Use our basic testbenches to test (1,2,3,4)
6. Write an advanced testbench to do randomized testing
