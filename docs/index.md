# Digital Design - UCSD CSE140 SS1'26

This course is redesigned to help you learn digital design in a fun, interesting and inspiring way. 
You will learn the foundational theory, SystemVerilog implementation, and practical best practices, and get a hands-on taste of both ASIC and FPGA design flows.
This is a five-week course with 30 hours of lectures and a strong balance between the theory of digital circuits and building them.
It was developed and taught to 52 students as CSE 140 in the Department of Computer Science and Engineering at UC San Diego during Summer Session I 2026.
Read the [student feedback and course iteration](feedback.md) to see what students valued, how their feedback shaped the course within the week, and what I plan to improve next time.

- [Start with Docker](setting-up-docker.md)
- [Browse design examples](design_outputs.md)
- [View the syllabus](syllabus.md)

```{raw} html
<figure class="hero-model">
  <model-viewer
    class="hero-model-viewer"
    src="_static/n_adder.glb"
    poster="https://media.abapages.com/course-site/n_adder.png"
    alt="8-bit ripple-carry adder circuit in 7 nm ASAP7 visualized in 3D"
    orientation="135deg 0deg 0deg"
    camera-controls
    camera-target="0m 0m 0m"
    camera-orbit="0deg 150deg 1m"
    field-of-view="50deg"
    interaction-prompt="when-focused"
    touch-action="pan-y"
    shadow-intensity="1"
    exposure="0.8"
    tone-mapping="commerce"
    environment-image="neutral"
    transparent-background
    ar-status="not-presenting"
    loading="eager"
  >
    <div class="hero-model-fallback" hidden>
      <img
        class="hero-model-fallback-image"
        src="https://media.abapages.com/course-site/n_adder.png"
        alt="Top-down routing view of an 8-bit ripple-carry adder"
        loading="lazy"
      />
      <p>
        Interactive 3D preview unavailable in this browser.
        <a href="_static/n_adder.glb">Open the GLB file directly.</a>
      </p>
    </div>
  </model-viewer>
  <figcaption>
    An 8-bit ripple-carry adder taken from SystemVerilog to a 7 nm ASIC layout.
    Drag to rotate and scroll to zoom.
  </figcaption>
</figure>
```

## Why This Course?

Digital design is a discipline where the art of designing complex digital circuits and its rules of thumb are grounded in theoretical analysis.
Half of this course develops theory such as number representation, Boolean algebra, Karnaugh maps, logic minimization, sequential logic, and timing analysis.
That theory is woven into practical work that you design, simulate, inspect, synthesize, and run on your own computer.
Each assignment is roughly half theory and half SystemVerilog design, so you immediately apply the ideas you have learned.

Digital design is the foundation for compute architecture (including CPU, GPU, and accelerator design), physical design, EDA/CAD software for ASIC and FPGA development, and many other hardware disciplines.

![Diagram showing where an introductory digital-design course fits among related computer engineering subjects](https://media.abapages.com/course-site/where_fits.png)

## From Theory to Hardware

The course repeatedly takes ideas through the same end-to-end flow:

**Theory → SystemVerilog RTL → Simulation and waveforms → Synthesis and timing → ASIC layout and 3D visualization → FPGA hardware**

Use the [SystemVerilog guide](systemverilog.md) as a language reference, inspect the [generated design outputs](design_outputs.md), explore [standard cells in 3D](3d-cells.md), and implement complete systems in the [FPGA labs](fpga_labs.md).

## Systems You Will Build and Explore

- **CPU:** Build an eight-opcode CPU in approximately 40 lines of SystemVerilog and run programs such as Sum-to-N, Fibonacci, factorial, and dot product in the [CPU walkthrough](cpu.md).
- **FIR audio filter:** Implement a 100-tap filter, connect it to a computer over UART, and process files or live audio in the [FPGA labs](fpga_labs.md).
- **Neural-network accelerator:** Progress from quantization and multiply-accumulate units to fully parallel MNIST inference on an FPGA in the [FPGA labs](fpga_labs.md).

The CPU and the FIR Filter are taught as examples in the lectures. 
You will be building the neural-network accelerator through your assignments.
Listen to the original audio and the output of a 4-bit-quantized low-pass FIR filter with a 250 Hz cutoff.

```{raw} html
<table style="border-collapse:collapse; width:100%; max-width:900px;">
  <tr>
    <td style="padding:0.5rem 1rem 0.5rem 0; vertical-align:top; width:50%;">
      <audio controls preload="metadata" style="display:block; width:100%;" src="https://media.abapages.com/course-site/chill_sub.wav"></audio>
    </td>
    <td style="padding:0.5rem 0 0.5rem 1rem; vertical-align:top; width:50%;">
      <audio controls preload="metadata" style="display:block; width:100%;" src="https://media.abapages.com/course-site/bass_only_8bit.wav"></audio>
    </td>
  </tr>
  <tr>
    <td style="padding:0.25rem 1rem 0 0; vertical-align:top; text-align:center;">Original music</td>
    <td style="padding:0.25rem 0 0 1rem; vertical-align:top; text-align:center;">Bass only</td>
  </tr>
</table>
```

## Five-Week Learning Journey

| Week | Theory and practice |
| --- | --- |
| [[W1]](week-1.md) | Boolean functions, gates, simulation, and a first RTL-to-GDS design |
| [[W2]](week-2.md) | Number representation, logic simplification, combinational circuits, quantization, and ReLU |
| [[W3]](week-3.md) | Sequential logic, setup and hold time, critical paths, reduction trees, and multiply-accumulate units |
| [[W4]](week-4.md) | Finite-state machines, ready/valid handshakes, UART, and streaming neural-network integration |
| [[W5]](week-5.md) | FIR architecture, retiming, and complete CPU, filter, and accelerator systems |

## What You Will Learn

- Reason about digital circuits using number representation, Boolean algebra, logic minimization, and timing analysis.
- Write maintainable, parameterized SystemVerilog RTL and testbenches using practical design and verification conventions.
- Simulate and debug circuits, evaluate timing and physical layout, generate FPGA bitstreams, and communicate with hardware over UART.

## Choose Where to Begin

- **Enrolled students:** Read the [syllabus](syllabus.md), complete the [Docker setup](setting-up-docker.md), and begin with [Week 1](week-1.md).
- **Independent learners:** Complete the [Docker setup](setting-up-docker.md), try the [running examples](running-examples.md), and use the [SystemVerilog guide](systemverilog.md) as a reference.
- **Visitors:** Browse the [design examples](design_outputs.md), [CPU walkthrough](cpu.md), [3D standard cells](3d-cells.md), and [FPGA labs](fpga_labs.md).

## Before You Begin

You should be comfortable with the following foundations:

- Converting numbers between decimal, binary, and hexadecimal representations ([refresher](https://diveintosystems.org/book/C4-Binary/index.html))
- Basic logical operations and truth tables ([refresher](https://en.wikibooks.org/wiki/Digital_Electronics/Printable_version))
- Writing simple programs in any language, such as Python or C

See the [syllabus](syllabus.md) for formal prerequisites, required materials, grading, and course policies.
All [RTL sources](https://github.com/abarajithan11/digital-design/tree/main/material/rtl), [testbenches](https://github.com/abarajithan11/digital-design/tree/main/material/tb), and build tools are available in the [course repository](https://github.com/abarajithan11/digital-design).

```{toctree}
:maxdepth: 1
:caption: Course
:hidden:

Home <self>
Syllabus <syllabus>
Feedback (2026) <feedback>
Exams <exams>
Lecture Recordings <https://podcast.ucsd.edu/watch/s126/cse140_a00>
Contact Us <contact-us>
```

```{toctree}
:maxdepth: 1
:caption: Get Started
:hidden:

Docker for ASIC+FPGA <setting-up-docker>
Running Our Examples <running-examples>
SystemVerilog Basics <systemverilog>
Acronyms from Lectures <acronyms>
```

```{toctree}
:maxdepth: 1
:caption: Explore
:hidden:

Design Examples <design_outputs>
FPGA Labs <fpga_labs>
CPU in 40 Lines of SystemVerilog <cpu>
Standard Cells in 3D <3d-cells>
```

```{toctree}
:maxdepth: 1
:caption: Weekly Content
:hidden:

Week 1 <week-1>
Week 2 <week-2>
Week 3 <week-3>
Week 4 <week-4>
Week 5 <week-5>
```
