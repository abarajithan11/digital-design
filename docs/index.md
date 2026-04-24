# Intro to Digital Design - An End-to-End Approach

This is a five-week course, with 30 hours of lectures. We expect the following prior knowledge:

* Converting a number between decimal, binary and hexadecimal representations
* Basic knowledge of logical operations (AND, OR, NAND, XOR) and truth tables
* Familiarity with any programming language (Python, C, etc.)

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
    poster="https://media.abapages.com/course-site/n_adder.png"
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
      <img
        class="hero-model-fallback-image"
        src="https://media.abapages.com/course-site/n_adder.png"
        alt="Top-down routing view of the 8-bit ripple carry adder"
        loading="lazy"
      />
      <p>
        Interactive 3D preview unavailable in this browser.
        <a href="_static/n_adder.glb">Open the GLB file directly.</a>
      </p>
    </div>
  </model-viewer>
  <figcaption>
    8-bit ripple carry adder circuit in 7nm (ASAP7) visualized in 3D. Drag to rotate, scroll to zoom.
  </figcaption>
</figure>
```

## Learning Outcomes

The following will be taught through examples ([listed here](https://abapages.com/digital-design/design_outputs.html)) of increasing complexity, inspired by real digital systems.

### Digital Design Concepts

- Decomposing boolean functions into gates
- Combinational and sequential elements
- Finite-state machines
- AXI-Stream protocol - ready/valid handshake
- UART protocol - make your circuit talk to your PC
- Setup time, hold time, critical path, retiming

###  SystemVerilog for Design

- Parametrization, hierarchical design
- `always_ff`, `always_comb`, `logic`
- `generate for`, `if`, `case`, `function`, packed arrays
- 3-process coding style for FSMs
- Wrapping SystemVerilog in old Verilog

###  SystemVerilog for Verification

- Basic testbenches, `function`, `task`, queues
- Randomizing with constraints
- Transactional testbenches: simple driver/monitor, basic OOP

:::{admonition} Keywords & Features of SystemVerilog Avoided in this Course

`reg`, `wire`, `assign`, `always`, unpacked arrays

SystemVerilog/Verilog is one of the most complex languages ever, with a lot of historical baggage and countless footguns. To avoid wasting our limited time debating those, we will avoid the above. However, I will create a page here explaining each of their uses in detail for the sake of completeness.
:::


## Final Projects

- **FIR Filter on FPGA to extract bass/treble from your favorite song** 
  - A worked example gradually built through our lectures and discussions.
  - We will **NOT** teach the mathematics of calculating the filter coefficients. [Here is our Python file](https://github.com/abarajithan11/digital-design/blob/main/material/py/sys_fir_filter_gen.py) to generate them. We will teach you how such filters work and how to implement them as a circuit.
  - You can listen to the audio before and after applying our 4-bit-quantized, 100-tap low-pass filter ([**see filter characteristics**](https://media.abapages.com/course-site/filter.png)) with a cutoff of 250 Hz here:

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
    <td style="padding:0.25rem 0 0 1rem; vertical-align:top; text-align:center;">Bass only (250 Hz cutoff)</td>
  </tr>
</table>
```

- **A fully-parallel neural network accelerator on FPGA to classify handwritten numbers** 
  - You will gradually build this as a series of guided assignments.
  - Week 2: Simple fixed-point quantization and ReLU
  - Week 3: Adder Tree, Vector Multiply-Adder
  - Week 4: Fully-parallel dense layer, neural network, AXI-Stream
  - Week 5: Full system on FPGA with UART RX & TX, plus Python serial to send/receive inputs/outputs

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
contact-us
```
