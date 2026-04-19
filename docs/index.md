# Intro to Digital Design - An End to End Approach

Expected prior knowledge:

* Basic knowledge on logic gates (AND, OR, NAND, XOR) and truth tables
* Familiarity in any programming language (Python, C...etc)

This is a five-week course, with 30 hours of lectures.

```{toctree}
:maxdepth: 1

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

###  A subset of SystemVerilog features for design and verification

- Design: 
  - Parametrization, hierarchical design
  - `always_ff`, `always_comb`, `logic`, 
  - `generate for`, `if`, `case`, `function`, packed arrays
  - 3 procedure coding style of FSMs
  - Wrapping SystemVerilog in old Verilog
- Verification: 
  - basic tbs, `function`, `task`, queues
  - randomizing with constraints, 
  - transactional tbs: simple driver/monitor, basic OOP

### Final Projects

- **We will show you:** FIR Filter on FPGA - extracting bass/treble from your favorite song
- **You will do (with our guidance):** A neural network hardware accelerated on FPGA to classify handwritten numbers

## Course Material

* Course repository: [github.com/abarajithan11/digital-design](https://github.com/abarajithan11/digital-design)
* Our designs: [design outputs](design_outputs.md)
