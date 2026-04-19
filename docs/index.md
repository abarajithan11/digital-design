# Intro to Digital Design - An End to End Approach

This is a five-week course, with 30 hours of lectures. Expected prior knowledge:

* Basic knowledge on logic gates (AND, OR, NAND, XOR) and truth tables
* Familiarity in any programming language (Python, C...etc.)

:::{admonition} Why take this course?
This course is designed to give you a first taste of the art and craft of digital design, help you experience the joy of designing real digital circuits, and build the confidence to take on bigger projects, more advanced modules, and future careers in the many areas of digital design.
:::

```{toctree}
:maxdepth: 1

Home <self>
week-1
week-2
week-3
week-4
week-5
design_outputs
setting-up-docker
setting-up-pynq
```

## Learning Outcomes

### Digital Design concepts

- Decomposing boolean functions into gates
- Combinational, Sequential elements
- Finite State Machines
- AXI-Stream protocol - Ready/valid handshake
- UART protocol - Make your circuit talk to your PC
- Setup time, hold time, critical path, retiming

###  SystemVerilog Features for Design

- Parametrization, hierarchical design
- `always_ff`, `always_comb`, `logic`, 
- `generate for`, `if`, `case`, `function`, packed arrays
- 3 procedure coding style of FSMs
- Wrapping SystemVerilog in old Verilog

###  SystemVerilog Features for Verification

- basic tbs, `function`, `task`, queues
- randomizing with constraints, 
- transactional tbs: simple driver/monitor, basic OOP

### Final Projects

- Worked example (gradually built in our lectures)
  - FIR Filter on FPGA to extract bass/treble from your favorite song
- Guided project (students will build through a series of assignments)
  - A fully-parallel neural network accelerator on FPGA to classify handwritten numbers
    - Simple fixed-point quantization and ReLU: *Week 2 - Combinational Circuits Assignment*
    - Adder Tree, Vector Multiply-Adder: *Week 3 - Sequential Circuits Assignment*
    - Fully-parallel dense layer, neural network, AXI-Stream: *Week 4 - Practical Circuits Assignment*
    - Full system on FPGA with UART RX & TX, Python serial to send/receive input/outputs: *Week 5 - FIR Filter Example Project*

## Course Material

* Course repository: [github.com/abarajithan11/digital-design](https://github.com/abarajithan11/digital-design)
* Our designs: [design outputs](design_outputs.md)
