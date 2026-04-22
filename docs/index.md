# Intro to Digital Design - An End to End Approach

This is a five-week course, with 30 hours of lectures. We expect the following prior knowledge:

* Converting a number between decimal, binary and hexadecimal representations
* Basic knowledge on logical operations (AND, OR, NAND, XOR) and truth tables
* Familiarity with any programming language (Python, C...etc.)

:::{admonition} Why take this course?
This course is meant to give you a first taste of the art and craft of digital design.
Along the way, you will experience the joy of designing real digital circuits and the challenge of making them work.

It is the first step in your journey towards more advanced courses at the university, bigger projects, and eventually the many career paths in one of today’s most exciting and in-demand areas of technology.
:::

```{raw} html
<figure class="hero-model">
  <model-viewer
    class="hero-model-viewer"
    src="_static/n_adder.glb"
    alt="8-bit ripple carry adder circuit in 7nm (ASAP7) visualized in 3D"
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
      3D model preview unavailable.
      <a href="_static/n_adder.glb">Open the GLB file directly.</a>
    </div>
  </model-viewer>
  <figcaption>
    8-bit ripple carry adder circuit in 7nm (ASAP7) visualized in 3D. Drag to rotate, scroll to zoom.
  </figcaption>
</figure>
```

## Learning Outcomes

The following will be taught through will be introduced through increasing complexity, inspired by real digital systems. The examples are [listed here](https://abapages.com/digital-design/design_outputs.html).

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

:::{admonition} Keywords & Features of SystemVerilog Avoided in this Course

`reg`, `wire`, `assign`, `always`, unpacked arrays

SystemVerilog/Verilog is one of the most complex languages ever, with a lot of historical baggage and countless footguns. To prevent wasting our limited time in debating those, we will avoid the above. However, I will create a page here explaining each of their use in detail for the sake of completion.
:::


## Final Projects

- **FIR Filter on FPGA to extract bass/treble from your favorite song** 
  - A worked example gradually built through our lectures and discussions.
  - We will **NOT** teach the mathematics of calculating the filter coefficients. [Here is our python file](https://github.com/abarajithan11/digital-design/blob/main/material/py/sys_fir_filter_gen.py) to generate them. We will teach you how such filters work, and how to implement them as a circuit.
  - You can listen to the audio before and after applying our [8-bit-quantized, 100-tap low pass filter](https://media.abapages.com/course-site/filter.png) with a cutoff of 800 Hz, here:

```{raw} html
<table style="border-collapse:collapse; width:100%; max-width:900px;">
  <tr>
    <td style="padding:0.5rem 1rem 0.5rem 0; vertical-align:top; width:50%;">
      <audio controls preload="metadata" style="display:block; width:100%;" src="https://raw.githubusercontent.com/abarajithan11/digital-design-content/main/chill_sub.wav"></audio>
    </td>
    <td style="padding:0.5rem 0 0.5rem 1rem; vertical-align:top; width:50%;">
      <audio controls preload="metadata" style="display:block; width:100%;" src="https://media.abapages.com/course-site/bass_only_8bit.wav"></audio>
    </td>
  </tr>
  <tr>
    <td style="padding:0.25rem 1rem 0 0; vertical-align:top; text-align:center;">Original song</td>
    <td style="padding:0.25rem 0 0 1rem; vertical-align:top; text-align:center;">Bass only (800 Hz cutoff)</td>
  </tr>
</table>
```

- **A fully-parallel neural network accelerator on FPGA to classify handwritten numbers** 
  - You will gradually build this as a series of guided assignments.
  - Week 2: Simple fixed-point quantization and ReLU
  - Week 3: Adder Tree, Vector Multiply-Adder: *Week 3 - Sequential Circuits Assignment*
  - Week 4: Fully-parallel dense layer, neural network, AXI-Stream
  - Week 5: Full system on FPGA with UART RX & TX, Python serial to send/receive input/outputs

## Course Material

* Repository: [github.com/abarajithan11/digital-design](https://github.com/abarajithan11/digital-design)
* Our designs: 
  * [SystemVerilog RTL](https://github.com/abarajithan11/digital-design/tree/main/material/rtl)
  * [SystemVerilog Testbenches](https://github.com/abarajithan11/digital-design/tree/main/material/tb)
  * [Outputs](design_outputs.md)

## Pages

```{toctree}
:maxdepth: 1

Home <self>
design_outputs
week-1
week-2
week-3
week-4
week-5
setting-up-docker
setting-up-pynq
contact-us
```
