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
  - **Activity** - Trace the logic through transistors, then extend the gates from 2-input to 3-input

### Slides:

[Open slides in new tab](https://1drv.ms/p/c/154152893557b712/IQQuacDuRzxWSLLzl9BVGtCuAc6n1SBptYIgBpoGn_IuJJE)

<iframe src="https://1drv.ms/p/c/154152893557b712/IQQuacDuRzxWSLLzl9BVGtCuAc6n1SBptYIgBpoGn_IuJJE?em=2&amp;wdAr=1.7777777777777777" width="900px" height="534px" frameborder="0" title="PowerPoint Viewer">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>


## Lecture 2: Logic Simplification

- Basics of Boolean Algebra
  - Constructing Truth Tables
  - AND, OR, NOT, XOR, XNOR
  - Logic circuit to Truth Tables - trace 1s and 0s
  - Count the number of transistors
  - Logic circuit to Algebraic expression - trace the variables
  - Three forms of boolean functions: Logic circuit, Expression and Truth Table (unique)
- Truth Tables to Expressions
  - Sum of Minterms
  - Product of Maxterms
- Logic Minimization
  - Boolean Identities
  - K-Maps
- Universal Gates: NAND/NOR

### Slides:

[Open slides in new tab](https://1drv.ms/p/c/154152893557b712/IQB0Bv1uTlPKQI_7FimzVf06AVy9lwVBkxRThs-X5KAyE5s?e=gZb6cb)

<iframe src="https://1drv.ms/p/c/154152893557b712/IQR0Bv1uTlPKQI_7FimzVf06AUgFBqAR0XmiipwJyGH7uBE?em=2&amp;wdAr=1.7777777777777777" width="900px" height="534px" frameborder="0" title="PowerPoint Viewer">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>

## Assignment

- For the given problems
  - Write truth tables
  - Write minterms and maxterms
  - Simplify algebraically
  - Use K-maps to find the minimal solution
