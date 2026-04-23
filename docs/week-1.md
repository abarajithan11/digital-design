# Week 1 – Digital Logic Design

Following are 3D visualizations of some standard cells in ASAP7 PDK. You can drag to rotate, scroll to zoom. To generate them from our docker container, do:

```bash
make show_3d_cell CELL=NAND2x1 
# just make show_3d_cell lists all possible cells
```

```{raw} html
<style>
  .week1-cell-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 1rem;
    margin: 1.25rem 0 1.75rem;
  }

  .week1-cell-card {
    margin: 0;
  }

  .week1-cell-viewer {
    width: 100%;
    aspect-ratio: 1 / 1;
    background: linear-gradient(180deg, #f8fafc 0%, #eef2f7 100%);
    border: 1px solid #d7dee8;
    border-radius: 0.75rem;
  }

  .week1-cell-card figcaption {
    margin-top: 0.55rem;
    text-align: center;
    font-size: 0.95rem;
  }

  @media (max-width: 900px) {
    .week1-cell-grid {
      grid-template-columns: 1fr;
    }
  }
</style>

<section class="week1-cell-grid">
  <figure class="week1-cell-card">
    <model-viewer
      class="week1-cell-viewer"
      src="_static/INVx1_ASAP7_75t_R.glb"
      alt="NOT gate standard cell in ASAP7 visualized in 3D"
      orientation="135deg 0deg 0deg"
      camera-controls
      camera-target="0m 0m 0m"
      camera-orbit="0deg 150deg 0.9m"
      field-of-view="50deg"
      interaction-prompt="when-focused"
      touch-action="pan-y"
      shadow-intensity="1"
      exposure="0.85"
      tone-mapping="commerce"
      environment-image="neutral"
      transparent-background
      ar-status="not-presenting"
      loading="eager"
    >
      <div class="hero-model-fallback" hidden>
        <img
          class="hero-model-fallback-image"
          src="https://media.abapages.com/course-site/inv_3d.png"
          alt="NOT gate standard cell in ASAP7"
          loading="lazy"
        />
        <p>
          Interactive 3D preview unavailable in this browser.
          <a href="_static/INVx1_ASAP7_75t_R.glb">Open the GLB file directly.</a>
        </p>
      </div>
    </model-viewer>
    <figcaption>NOT gate (INVx1)</figcaption>
  </figure>

  <figure class="week1-cell-card">
    <model-viewer
      class="week1-cell-viewer"
      src="_static/NAND2x1_ASAP7_75t_R.glb"
      alt="NAND gate standard cell in ASAP7 visualized in 3D"
      orientation="135deg 0deg 0deg"
      camera-controls
      camera-target="0m 0m 0m"
      camera-orbit="0deg 150deg 0.9m"
      field-of-view="50deg"
      interaction-prompt="when-focused"
      touch-action="pan-y"
      shadow-intensity="1"
      exposure="0.85"
      tone-mapping="commerce"
      environment-image="neutral"
      transparent-background
      ar-status="not-presenting"
      loading="eager"
    >
      <div class="hero-model-fallback" hidden>
        <img
          class="hero-model-fallback-image"
          src="https://media.abapages.com/course-site/nand_3d.png"
          alt="NAND gate standard cell in ASAP7"
          loading="lazy"
        />
        <p>
          Interactive 3D preview unavailable in this browser.
          <a href="_static/NAND2x1_ASAP7_75t_R.glb">Open the GLB file directly.</a>
        </p>
      </div>
    </model-viewer>
    <figcaption>NAND gate (NAND2x1)</figcaption>
  </figure>

  <figure class="week1-cell-card">
    <model-viewer
      class="week1-cell-viewer"
      src="_static/DFFHQNx1_ASAP7_75t_R.glb"
      alt="D flip-flop standard cell in ASAP7 visualized in 3D"
      orientation="135deg 0deg 0deg"
      camera-controls
      camera-target="0m 0m 0m"
      camera-orbit="0deg 150deg 1m"
      field-of-view="50deg"
      interaction-prompt="when-focused"
      touch-action="pan-y"
      shadow-intensity="1"
      exposure="0.85"
      tone-mapping="commerce"
      environment-image="neutral"
      transparent-background
      ar-status="not-presenting"
      loading="eager"
    >
      <div class="hero-model-fallback" hidden>
        <img
          class="hero-model-fallback-image"
          src="https://media.abapages.com/course-site/dff_3d.png"
          alt="D flip-flop standard cell in ASAP7"
          loading="lazy"
        />
        <p>
          Interactive 3D preview unavailable in this browser.
          <a href="_static/DFFHQNx1_ASAP7_75t_R.glb">Open the GLB file directly.</a>
        </p>
      </div>
    </model-viewer>
    <figcaption>D Flip-Flop (DFFHQNx1)</figcaption>
  </figure>
</section>
```

## Lecture 1

- Electronic Chip - Demystified
  - Programming: program → assembly → machine code → Arduino's microprocessor
  - IC package, die, layers of transistors, metal wires
  - Visual 6502: [simulation of a CPU's layout](http://www.visual6502.org/JSSim/expert.html)
  - Today: Megacities on a Chip
- ASIC Design: Story of the first processor (Intel 4004)
  - Computer Architecture, Layout, Ruby cutting - all by hand
  - Today's chips are much more complex & performant - expensive software to help with the flow
    - Logic design
    - Physical design
    - Standard cells
    - Manufacturing: ASML machines, clean rooms, lithography
- FPGA Design:
  - Meta-chip: a flexible chip that lets you realize your own digital circuit within it.
  - ASIC vs FPGA: speed, power, cost, time-to-market
  - Real world applications
  - FPGA flow

## Lecture 2

- Take an example Boolean function (e.g.: adder)
  - Logic to gates
    - K-maps
    - Sum of products / Product of sums
    - Write a SystemVerilog module made of the gates
  - Run our script to generate 7 nm (ASAP7) layout, observe the transistors
  - Write a simple testbench, simulate the design, observe values over time.
  - Do the same by directly writing the function in SystemVerilog
- A map of career paths
  - Computer Architecture
  - Logic design - This course
  - Physical design
  - Verification
  - Analog design

## Discussion

- Setting up our docker container in your machine
- Setting up FPGA boards

## Assignment

- For a given list of boolean functions
  - Decompose into Sum of Products and Product of Sums
  - Write it as an SV file, get layout and observe transistors
  - Simulate
  - Write the function directly in SystemVerilog and do the same
