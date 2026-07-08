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

## Assignment

- Create a module: adder tree `y = sum(X)`
- Create a constant-vector MAC to compute `y = sum(W.X + B)`, where `W` and `B` are constants
- Update it to include quantization and ReLU (`rq_cvmac`)
