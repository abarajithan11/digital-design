# Week 1 – Digital Logic Design

## Lecture 1

- First day info sheet
- Course logistics
- Inside a Chip 
  - Programming an M1 MacBook
  - Taking a MacBook apart
  - Taking an M1 chip apart (decapping)
  - Visual 6502: [simulation of a CPU's layout](http://www.visual6502.org/JSSim/expert.html)
- Making a chip 
  - How Intel 4004 was designed. Computer architecture, schematic & layout done by hand.
  - The YouTube guy who makes chips in his garage, doing layout with Photoshop.
- Modern ASIC flow
  - Computer Arch, Logic Design, Physical Design, Verification, Tapeout, Packaging
  - Job opportunities
  - Where CSE140 fits in the curriculum
- **Activity** - Run ASIC flow for a simple circuit, and inspect netlist & chip layout 
- Transistors to Gates
  - Switches, MOSFETs, Gates
  - NOT, NAND, NOR
  - AND, OR


<iframe src="https://1drv.ms/p/c/154152893557b712/IQQuacDuRzxWSLLzl9BVGtCuAc6n1SBptYIgBpoGn_IuJJE?em=2&amp;wdAr=1.7777777777777777" width="900px" height="506px" frameborder="0" title="PowerPoint Viewer">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>


## Lecture 2: Logic Simplification

- Circuit of gates to Truth Table
- Boolean Algebra
- Minterms and Maxterms - Truth table to circuit
- Minimizing with algebra
- K-maps
  - 2, 3, 4 variables
  - Don't cares
  - Algorithm:
    - Find essential prime implicants
    - Find minters not covered by ESPs
    - Include them using non-essential prime implicants
  - Limitations of K-maps
- Hello SystemVerilog
  - Print hello world
  - Simulate a design, observe waveform

## Discussion

- Setting up our Docker container on your machine

## Assignment

- For the given problems
  - Write truth tables
  - Write minterms and maxterms
  - Simplify algebraically
  - Use K-maps to find the minimal solution
