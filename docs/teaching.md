# How I Built and Taught This Course

CSE 140 (Digital Hardware Design) is a challenging course to teach because it bridges two very different ways of thinking: software programming and hardware design.
My objective was to take students from C programming in CSE 30 to computer architecture in CSE 141 within an intensive five-week summer session.
The regular ten-week course had previously been taught in three different ways by different instructors.
I developed a fourth approach and built the material from scratch around what students needed to understand and be able to do by the end of the course.

This page explains why I made those choices, how I taught the course to 52 students in Summer Session I 2026, and what I learned from it.

## Starting from What Students Should Be Able to Do

Before this course, I mostly thought about what I wanted to teach.
The Summer Graduate Teaching Scholars (SGTS) program shifted my focus to what students needed to be able to do, and what evidence would show that they had learned it.
So I organized the course around the [weekly learning outcomes](syllabus.md), the assessments that measure them, and the in-class activities to practice them, rather than around a list of topics.

CSE 140L, the companion lab course, was not available, so I integrated its hands-on lab experience directly into CSE 140.
Each assignment is roughly half theory and half SystemVerilog design, so students apply each idea soon after learning it.

## Connecting Theory, Code, Waveforms, and Hardware

My goal was for students to see how theory, code, waveforms, and physical hardware connect, and to gain the confidence to build hardware themselves.

- **Diagrams next to code:** I presented circuit diagrams and their SystemVerilog side by side, so students could see how a hardware structure becomes code, and how that code behaves in simulation waveforms.
- **Hardware in 3D:** I developed interactive 3D visualizations of circuits and [standard cells](3d-cells.md), so students could explore how a design is physically built from transistors on a chip.
- **The full flow on their own computers:** A [Docker image](setting-up-docker.md) packages the simulation, synthesis, and layout tools, so every student could take their own designs from SystemVerilog to a 7 nm layout.
- **Real applications:** An [FIR audio filter](fpga_labs.md) let students hear the effect of the hardware we designed, and a neural-network accelerator showed how the same principles are used in modern computing.
  The final lecture builds a [CPU in 40 lines of SystemVerilog](cpu.md).
- **Live in class:** I ran FPGA demos, coded and debugged live, and walked through waveforms on the blackboard.

The topics build on each other, from Boolean logic and combinational circuits to sequential circuits, fixed-point arithmetic, streaming interfaces, and finally complete systems.
One student wrote:

> The example code alongside the theory material in the lecture slides helped me understand the concepts better and understand how a certain hardware is realized in code.

Others said the waveform walkthroughs and FPGA examples helped them understand difficult concepts and stay engaged.

## Teaching Students from Different Backgrounds

Students entered with different levels of preparation, and I received conflicting feedback about pacing.
Some felt I spent too much time reviewing prerequisites, while others felt the same material moved too quickly.
Rather than simply speeding up, I used in-class activities, quizzes, and questions to check whether students had the foundations needed for later topics.
When those checks showed gaps in Boolean algebra, fixed-point arithmetic, or other prerequisites, I reinforced them.
One student appreciated that I "didn't just assume that everyone knew the basic properties of boolean algebra."
Another wrote in the final evaluation:

> Professor [sic] Aba was just very understanding that people may be coming from different backgrounds so he starts at the basic fundamental concepts for each topic we start.

## Teaching as an Iterative Process

I used to think of student feedback as something collected at the end of a course.
In this course, I collected short feedback almost every class, presented a summary at the start of the next lecture, and explained what I was changing in response.

- When students found the SystemVerilog sections hard to follow, I added live coding, broke the code down line by line, and drew the matching hardware.
  Students later named these walkthroughs as particularly helpful.
- When waveform exercises were difficult, I drew the waveforms on the blackboard and traced them step by step.

In each case, the next round of feedback indicated that the change helped.
One student wrote:

> I really like the taking feedback from students and incorporating it into lectures.
> It allowed a lot of students to revisit particularly difficult topics and become more comfortable.

The [student feedback page](feedback.md) shows these comments before and after each change, along with the complete daily feedback.

Being responsive does not mean doing everything each student asks for.
In the same feedback round, some students wanted a faster pace and others a slower one.
I used the feedback together with quiz results, classroom interactions, and the learning outcomes to decide what the class as a whole needed.
This is why summarizing the previous session's feedback at the start of each session matters.
Students feel heard, and when they see the conflicting requests side by side, they understand why I could not follow every suggestion, instead of feeling ignored.

Treating teaching as an iterative process was my biggest change as a teacher.
I now see the initial course plan as a well-reasoned starting point, and I change it during the course when the evidence shows that students need a different approach.

## What I Would Keep and Change

I would keep the daily feedback loop.
It gave me a much more immediate picture of student learning than end-of-course evaluations alone, and students said they valued it.

I would change how SystemVerilog is introduced.
It is always challenging to rewire the brains of students to see familar-looking code of SystemVerilog as hardware description (RTL) and also as software code (testbench).
Because the summer session compressed a ten-week course into five, the first assignment had to start almost immediately, and several students felt they were writing SystemVerilog before they were familiar with its basic patterns.
Next time, especially in a full quarter, I would:

- Introduce the small [SystemVerilog subset](systemverilog.md) used in the course earlier and more gradually.
- Use short code-reading and code-writing exercises before larger assignments.
- Compare familiar programming concepts with their hardware equivalents, and point out where they differ.
- Provide a recurring checklist of common synthesis and simulation mistakes.
- Structure live coding around short checkpoints, so students who fall behind can quickly rejoin.

The [student feedback page](feedback.md) lists the other improvements I plan to make.

## My Teaching Philosophy

I teach digital design by connecting fundamentals, theory, implementation, simulation, and hands-on practice within one course.
I want students to not only understand how hardware works, but also to design it, test it, and see their own hardware working in their hands.
A few principles guide how I do this:

- **Theory and practice together:** Theory explains why a circuit works, and building the circuit is how students test that understanding.
  So every major idea goes from theory to SystemVerilog, waveforms, layout, and, where possible, an FPGA.
- **Real systems as motivation:** Students put effort into learning when they can see the real world utility of the designs.
  An audio filter they can hear, a neural network they can observe, and a CPU they can program make the fundamentals worth learning.
- **Clarity over completeness:** SystemVerilog has many ways to describe the same hardware.
  I teach a small, consistent subset well, so beginners spend their effort on design rather than on the language's historical quirks.
- **Doing the work themselves:** Beginners need to write and debug basic designs by hand to build intuition, so they can use AI effectively later in their careers.
  That is why I did not allow AI tools to write or debug assignment code.
  The paper-based exams were then designed such that they were easy if they did the assignments themselves, and hard if they did not.
- **Foundations for everyone:** I do not assume that every student arrives with the same preparation.
  I check what the class actually knows, and reinforce the foundations before building on them.
- **Tools students own:** I built the Docker image to run on students' own computers, than on a server set up just for one summer course.
  Running the full flow on their own machines makes the work personal and gives students a sense of ownership.
  The tools also stay with them after the course ends, so they can keep building designs and add them to a portfolio.
- **The course as a design:** I treat the course itself as something to test and improve.
  I start from a well-reasoned plan, measure how students are learning, and change it when the evidence calls for it.
