# Intro to Digital Design - An End to End Approach

This is a five-week course, with 30 hours of lectures. We expect the following prior knowledge from the students:

* Converting a number between decimal, binary and hexadecimal representations
* Basic knowledge on logical operations (AND, OR, NAND, XOR) and truth tables
* Familiarity with any programming language (Python, C...etc.)

:::{admonition} Why take this course?
Digital design is both an art and a craft. 
This course is meant to give you a first taste of both.
Along the way, you will experience the joy of designing real digital circuits and the challenge of making them work.

It is the first step in your digital design journey towards more advanced courses at the university, bigger projects, and eventually the many career paths in one of today’s most exciting and in-demand areas of technology.
:::

### Pages

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
contact-us
```

## Learning Outcomes

### Digital Design concepts

- Decomposing boolean functions into gates
- Combinational, Sequential elements
- Finite State Machines
- AXI-Stream protocol - Ready/valid handshake
- UART protocol - Make your circuit talk to your PC
- Setup time, hold time, critical path, retiming

###  SystemVerilog for Design

- Parametrization, hierarchical design
- `always_ff`, `always_comb`, `logic`, 
- `generate for`, `if`, `case`, `function`, packed arrays
- 3 procedure coding style of FSMs
- Wrapping SystemVerilog in old Verilog

###  SystemVerilog for Verification

- basic tbs, `function`, `task`, queues
- randomizing with constraints, 
- transactional tbs: simple driver/monitor, basic OOP

:::{admonition} Forbidden in this Course: Keywords & Features of SystemVerilog 

`reg`, `wire`, `assign`, `always`, unpacked arrays

SystemVerilog/Verilog is one of the most complex languages ever, with a lot of historical baggage and countless footguns. To avoid wasting our limited time in debating those, we will avoid the above. However, I will create a page here explaining each of their use in detail for the sake of completion.
:::

## Examples

In this course, digital design concepts and SystemVerilog features will be introduced through examples of gradually increasing complexity, inspired by real digital systems, as follows:

- [x] 1. Not Gate
- [x] 2. Full Adder
- [x] 3. N-Adder
- [x] 4. ALU
- [ ] 5. Encoder
- [ ] 6. Decoder
- [ ] 7. Verilog Functions
- [x] 8. Flip Flop
- [x] 9. Up counter
- [ ] 10. Vector Minimum
- [x] 11. Parallel to Serial Converter
- [x] 12. Down counter
- [x] 13. UART RX
- [x] 14. UART TX
- [x] 15. UART Echo (RX + TX)
- [ ] 16. FIR Filter
- [ ] 17. FIR Filter - Retimed
- [ ] 18. UART RX + TX + FIR Filter

## Final Projects

- **FIR Filter on FPGA to extract bass/treble from your favorite song** - A Worked example gradually built through our lectures and discussions
- **A fully-parallel neural network accelerator on FPGA to classify handwritten numbers** - The project you will gradually build as a series of guided assignments
  - Simple fixed-point quantization and ReLU: *Week 2 - Combinational Circuits Assignment*
  - Adder Tree, Vector Multiply-Adder: *Week 3 - Sequential Circuits Assignment*
  - Fully-parallel dense layer, neural network, AXI-Stream: *Week 4 - Practical Circuits Assignment*
  - Full system on FPGA with UART RX & TX, Python serial to send/receive input/outputs: *Week 5 - FIR Filter Example Project*

## Course Material

* Repository: [github.com/abarajithan11/digital-design](https://github.com/abarajithan11/digital-design)
* Our designs: 
  * [SystemVerilog RTL](https://github.com/abarajithan11/digital-design/tree/main/material/rtl)
  * [SystemVerilog Testbenches](https://github.com/abarajithan11/digital-design/tree/main/material/tb)
  * [Outputs](design_outputs.md)
