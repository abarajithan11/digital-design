# Syllabus

This five-week course introduces digital design by taking circuits from SystemVerilog to simulation, ASIC layout (transistors), and FPGA implementations that talk to your computer. Students build increasingly realistic designs, ending with a neural-network accelerator and an FIR filter for music that communicate via UART.

## Prerequisites

* Binary/hex/decimal conversion
* Basic logic operations and truth tables
* Familiarity with any programming language

## Weekly Outcomes, Topics, and Assignments

| Week | Learning outcome | Topics and major assignment |
| --- | --- | --- |
| 1 | Understand the digital design flow from Verilog to gates and transistors. | ASIC vs FPGA, layout, standard cells, Boolean functions, gates, testbenches, Docker/FPGA setup.<br><br>Assignment 1: decompose Boolean functions, write/simulate SystemVerilog, generate layout, inspect transistors. |
| 2 | Design combinational circuits in SystemVerilog. | Adders, muxes, ALUs, encoders, decoders, functions, LUTs.<br><br>Assignment 2: build `relu(quant(x))` and decompose mux, encoder, decoder, and ReLU logic. |
| 3 | Build and debug sequential and parameterized circuits. | Clocks, flip-flops, registers, counters, reduction trees, setup/hold time, critical path.<br><br>Assignment 3: build an adder tree, constant-vector MAC, and ReLU-quantized MAC. |
| 4 | Integrate streaming, FSM, and UART designs. | AXI-Stream ready/valid, FSMs, UART TX/RX, FPGA serial loopback.<br><br>Assignment 4: build dense layers, a dense neural network, and a UART-integrated MNIST system. |
| 5 | Create end-to-end digital systems. | FIR filters, retiming, UART RX + FIR + UART TX, Python audio/file I/O.<br><br>Extra credit: optimize the end-to-end FPGA systems. |

## Materials and Support

* Course repository: [github.com/abarajithan11/digital-design](https://github.com/abarajithan11/digital-design)
* Website: [abapages.com/digital-design](https://abapages.com/digital-design)
* Examples: [abapages.com/digital-design/design_outputs.html](https://abapages.com/digital-design/design_outputs.html)
* Online logic simulation: [https://digitaljs.tilk.eu/](https://digitaljs.tilk.eu/)
* Docker design flow, [3D chip/cell visualizations](https://abapages.com/digital-design/3d-cells.html), FeedbackFruits, Discord, and the [course contact form](https://abapages.com/digital-design/contact-us.html). 
* Instructor contact details and office hours will be posted on the course site and Discord.


## Class Format and Participation

Class sessions mix short lectures, live code/design prediction, visual simulations, 3D chip exploration, group design time, and low-stakes questions. In a three-hour session, you may expect concept-building, group design/debugging, and integration or reflection, with pauses about every 30 minutes for discussion or problem-solving.

Participation means answering all in-class quizzes, discussing designs with classmates, seeking help early, contributing to Discord, and annotating or responding during lecture. Our classroom will be collaborative: learn each others' names, work with new peers, discuss your reasoning, and help each other improve.

Attendance is mandatory. Summer courses are fast-paced, and I don't want you to fall back. Each session has 2–3 easy multiple-choice quizzes; to be counted present, you must answer all of them, regardless of correctness. Each missed session subtracts 2% from the course grade. You may recover the penalty for at most two missed sessions by submitting printed slides from the missed session with sufficient handwritten annotations on every slide, based on the recording, within four days.

## Grading

| Component | Weight |
| --- | ---: |
| Assignments (4) | 15% each |
| Final exam, in person and paper-based | 35% |
| In-class quiz correctness | 5% |
| **Total** | **100%** |

Programming assignments are auto-graded with released and hidden testbenches. Strong work is correct, readable, tested, parameterized where appropriate, and written in the SystemVerilog style taught in class. The paper-based exam will include code closely related to the assignments.

**Bonus opportunities:** up to 5% for meaningful Discord participation, up to 10% for neural-network resource optimization, and up to 5% for FIR-filter resource optimization. Raise grade questions promptly through the Discord channel, with the assignment name and a specific explanation.

**Late work:** Extensions must be requested before the deadline; otherwise, assignments incur a 10% per day penalty and are not accepted after 48 hours. Attendance recovery follows the four-day rule above.

## AI Use, Accessibility and Inclusivity

Because the final is paper-based, do not use AI to write or debug your code, and avoid IDE-based AI tools entirely. If you do the assignments yourself, you can easily score 100% on the exam. Chat-based AI may be used only for search. Misuse may result in zero credit and an academic integrity referral. *Why:* As beginners, you need to do this manually to rewire your brain, so you can use AI more effectively in your jobs later. 

Contact the instructor or the [campus accessibility office](https://osd.ucsd.edu/) early to request disability, religious, or other accommodations. All students are welcome here!
