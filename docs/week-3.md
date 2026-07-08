# Week 3 – Sequential Logic

## Lecture

- Timing Analysis
  - Why a chip needs a clock
  - Contamination Delay
  - Propagation Delay
  - Setup time, Hold time
  - Critical path analysis
- Sequential Circuits 2
  - Parameterized Binary Reduction Tree to find the minimum value in a vector `y = min(X)`

- Finite State Machines
  - Up Counter
  - Down Counter
  - Nested counters

## Assignment 3: Fully parallel dense layer 

This assignment is intended to develop your skills in hierarchical design & parameterized hardware generation using SystemVerilog.

1. Convert the parameterized minimum-finding module to perform `y = sum(X)`
2. Create a constant-vector MAC module to compute `y = sum(K.X + B)`, where `K` and `B` are parameter arrays.
3. Create a module to requantize the output and optionally do ReLU, using the module from A2.
4. Create a module `dense_relu` with optional ReLU with `N_OUTPUTS` number of the above module.
5. Use our basic testbenches to test (1,2,3,4)
6. Write an advanced testbench to do randomized testing
