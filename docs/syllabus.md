# Syllabus: CSE140 SS1'26

This five-week course introduces digital design by taking circuits from SystemVerilog to simulation, ASIC layout (transistors), and FPGA implementations that talk to your computer. Students build increasingly realistic designs, ending with a neural-network accelerator and an FIR filter for music that communicate via UART.

## Course Logistics

* **Instructional Team:** Abarajithan G (Instructor), Zhenghua Ma (TA), Sriharsha Kavuri (Tutor) & Aarav Vidhawan (Tutor).
* **Lectures:** Tuesdays & Thursdays, 11am-1.50pm, [COA - Coalition Building](https://maps.app.goo.gl/bmoSkuejwRAZGHEy9), Room B26.
* **Discussion:** Fridays, 3pm-4.50pm, EBU3B - CSE Building, Room 4140.
* **Expected workload** 24 hours per week total. 8 instructional hours, and 24 hours outside class (4 extra hours a day, sans Sunday).
* **Office hours:** [TODO: to be scheduled][days/times, location/link].
* **Mid exam:** [TODO: to be scheduled][days/times, location/link].
* **Final exam:** [TODO: to be scheduled][days/times, location/link].

## Prerequisites

* Binary/hex/decimal conversion. [[refresher]](https://diveintosystems.org/book/C4-Binary/index.html)
* Basic logic operations and truth tables [[refresher]](https://en.wikibooks.org/wiki/Digital_Electronics/Printable_version)
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
* **Required materials:** 
  * Reference books: For Week 1,2: [Digital Design](https://www.zybooks.com/catalog/digital-design/) by Frank Vahid; [SystemVerilog: RTL Modeling, Simulation and Verification](https://systemverilog.dev/) by Keyi Zhang.
  * You'll be using your own machines (not server) for examples and assignments. You need a computer that can run docker (Ubuntu x86/64, Windows x86/64 (via WSL), MacOS arm64).
  * **Cheap FPGA:** We highly recommend you to buy this cheap FPGA from either [Amazon](https://www.amazon.com/Tang-Nano-20K-Development-Computer/dp/B0GCVFLFPP/ref=sr_1_1?crid=32SUSOZGEPZC6&dib=eyJ2IjoiMSJ9.Ow-0YEuarWedIbDbBtOwJv4xyhVW5_qqUfOOYW4fjGJ99bRBUHdab_BTUgz_6cyVtW1qZHPo8yTWj7sGpRE0HKkyiMDAd1MSCc4Ea5OlgFsarB_M8y7Nu8sm-REsz0zofY8SMuVfBaJi9QecvRpHNlEv532AEdds7yn9hJ7QXQg.ZnVmNGdJX19GAopy9VviKF0bf9yAC0TmHz8vlWZ4xGQ&dib_tag=se&keywords=speed%2Btang%2Bnano%2B20k&qid=1779923800&sprefix=sipeed%2Btang%2Bnano%2B20k%2B%2Caps%2C286&sr=8-1&th=1), or [AliExpress](https://www.aliexpress.us/item/3256805394833478.html?spm=a2g0o.productlist.main.1.4b04HoNAHoNAIF&algo_pvid=809e9b1f-24a1-4c4b-b135-129d55ab0ff9&algo_exp_id=809e9b1f-24a1-4c4b-b135-129d55ab0ff9-0&pdp_ext_f=%7B%22order%22%3A%22621%22%2C%22eval%22%3A%221%22%2C%22fromPage%22%3A%22search%22%7D&pdp_npi=6%40dis%21USD%2132.39%2131.89%21%21%2132.39%2131.89%21%402103110517799236779054890ef451%2112000033650315249%21sea%21US%210%21ABX%211%210%21n_tag%3A-29910%3Bd%3A4ca8c57d%3Bm03_new_user%3A-29895%3BpisId%3A5000000204886261&curPageLogUid=zXmtXJ517f75&utparam-url=scene%3Asearch%7Cquery_from%3A%7Cx_object_id%3A1005005581148230%7C_p_origin_prod%3A), so you can get the hands-on experience. In AliExpress, carefully choose "Bundle: Nano 20K No header", and triple-check the delivery address before checkout.
* **Where things live:** starter code will be in [GitHub](https://github.com/ucsd-cse140-s126/); assignments submitted and auto-graded on [Gradescope](https://www.gradescope.com/courses/1324483); grades on Canvas; slides at [TODO] link and recordings at [TODO] link.
* **Primary communication channel** will be our Discord server, for all announcements and discussions.


## Class Format and Participation

Class sessions mix short lectures, live code/design prediction, visual simulations, 3D chip exploration, group design time, and low-stakes questions. In a three-hour session, you may expect concept-building, group design/debugging, and integration or reflection, with pauses about every 30 minutes for discussion or problem-solving.

Participation means answering all in-class quizzes, discussing designs with classmates, seeking help early, contributing to Discord, and annotating or responding during lecture. Our classroom will be collaborative: learn each others' names, work with new peers, discuss your reasoning, and help each other improve.

**Attendance is mandatory for all lectures and discussions.** Summer courses are fast-paced, and I don't want you to fall back. Each session has 2–3 easy multiple-choice quizzes; to be counted present, you must answer all of them, regardless of correctness. Each missed session has a [penalty](#missed_session). You may recover the penalty for at most two missed sessions by submitting printed slides from the missed session with sufficient handwritten annotations on every slide, based on the recording, within four days.

## Grading

| Weight | Component |
| ---: | --- |
| 15% each | Assignments (4)|
| 10% | Mid exam, in person and paper-based |
| 25% | Final exam, in person and paper-based |
| 5% | In-class quiz correctness (zero for the sessions you don't attend, cannot be recovered) |
| **100%** | **Total** |
| -2% | <a id="missed_session">Per each missed session(if any in-class quiz was not answered) |
| +0.5% | <a id="unused_late_day"></a>Per unused late day |
| up to +5% | Meaningful participation in Discord with peers |
| up to +5% | FIR Filter Resource Optimization |
| up to +10% | Neural Network Resource Optimization |


Programming assignments are auto-graded with released and hidden testbenches. Strong work is correct, readable, tested, parameterized where appropriate, and written in the SystemVerilog style taught in class. The paper-based exam will include code closely related to the assignments.

## Key Policies:

- **Letter grades:** `A+ >=97, A >=93, A- >=90, B+ >=87, B >=83, B- >=80, C+ >=77, C >=73, C- >=70, D >=60, F otherwise`; Ranges may only move in students' favor.
- **Late work:** A total of 4 late days (24 hours) for the entire course with **no exceptions**; we recommend you to save them, in case you encounter a true emergency, and also because [you get credit for unused late days](#unused_late_day). -10% penalty on assignment grade per late day after you exhaust late days.
- **Exam logistics:** the mid & final are in-person, paper-based, and closed-book; [TODO] We are currently deciding a makeup exam policy. We are inclined to not offer them.
- **Assignments:** released Monday on that week's material, due the following Tuesday at 10 am.
- **Collaboration:** you may discuss concepts and approaches with classmates, but each student must write and submit their own code. Do not copy or share solutions.
- **Academic integrity:** plagiarism from any source (classmates, past students, online code, or AI tools) is not tolerated and results in a zero on the assignment and an academic-integrity referral. Check [UCSD Policy](https://senate.ucsd.edu/Operating-Procedures/Senate-Manual/Appendices/2). If you're unsure whether something is allowed, ask first.
- **Regrades:** raise requests through Gradescope with detailed explanation within the days allowed on the assignment. No regrades allowed on the final & mid exams.

## AI Use, Accessibility and Inclusivity

Because the mid & final are paper-based, do not use AI to write or debug your code, and avoid IDE-based AI tools entirely. If you do the assignments yourself, you can easily score 100% on the exam. Chat-based AI may be used only for search. Misuse may result in zero credit and an academic integrity referral. *Why:* As beginners, you need to do the basic designs manually to rewire your brain, so you can use AI more effectively in your jobs later. 

Contact the instructor or the [campus accessibility office](https://osd.ucsd.edu/) early to request disability, religious, or other accommodations. Your health and well-being come first. If you're struggling, reach out, and see campus [basic needs](https://basicneeds.ucsd.edu/), [counseling (CAPS)](https://caps.ucsd.edu/), and other support resources. Everyone is welcome here!
