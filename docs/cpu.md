# CPU in 40 lines of SV

This project builds a small 16-bit CPU in five incremental steps. 
Each step is complete, and adds only few new lines.
Programs are written directly in SV testbench.
[Full CPU here](#full-cpu-40-loc).

```{raw} html
<figure class="hero-model">
  <model-viewer
    class="hero-model-viewer"
    src="_static/cpu_factorial.glb"
    poster="_static/cpu_factorial.png"
    alt="16-bit CPU circuit in 7nm (ASAP7) visualized in 3D"
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
        src="_static/cpu_factorial.png"
        alt="Top-down routing view of the 16-bit CPU"
        loading="lazy"
      />
      <p>
        Interactive 3D preview unavailable in this browser.
        <a href="_static/cpu_factorial.glb">Open the GLB file directly.</a>
      </p>
    </div>
  </model-viewer>
  <figcaption>
    16-bit CPU circuit in 7nm (ASAP7) visualized in 3D. Drag to rotate, scroll to zoom.
  </figcaption>
</figure>
```

### Quickstart

```bash
make fresh     # if you havent started the container
make enter     # to enter the running container

make sim gtkwave DESIGN=cpu_3_store_data      # simulate the step 3 design & view waveform
# Ctrl+C to exit gtkwave

make sim gtkwave DESIGN=cpu_factorial         # run factorial on the final CPU

make gds show_layout DESIGN=cpu_factorial     # Run GDS flow
```

Example programs:
* [`sum_to_n`](https://github.com/abarajithan11/digital-design/blob/main/material/tb/cpu/tb_cpu_sum_to_n.sv)
* [`dot_product`](https://github.com/abarajithan11/digital-design/blob/main/material/tb/cpu/tb_cpu_dot_product.sv)
* [`factorial`](https://github.com/abarajithan11/digital-design/blob/main/material/tb/cpu/tb_cpu_factorial.sv)
* [`fibonacci`](https://github.com/abarajithan11/digital-design/blob/main/material/tb/cpu/tb_cpu_fibonacci.sv)


## Incremental evolution

| Level | Feature | RTL |
| --- | --- | --- |
| `0_memory` | Simple memory with zero-latency read and 1-cycle-latency write | [RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/cpu/memory.sv) |
| `1_load_instruction` | Just a counter to load instructions (PC) | [RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/cpu/cpu_1_load_instruction.sv) |
| `2_load_data_into_registers` | Sixteen registers and `LOAD` | [RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/cpu/cpu_2_load_data_into_registers.sv) |
| `3_store_data` | `STORE` | [RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/cpu/cpu_3_store_data.sv) |
| `4_move_alu` | `MOVE`, `ADD`, `SUB`, and `MUL` | [RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/cpu/cpu_4_move_alu.sv) |
| `5_jump` | `JNZ`: jump to a given address if a given register is not zero | [RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/cpu/cpu_5_jump.sv) |

## CPU Design

* Only 7 opcodes: `LOAD=0`, `STORE=1`, `MOVE=2`, `ADD=3`, `SUB=4`, `MUL=5`, and `JNZ=6`.
* Two instruction formats:
  * Address type: `LOAD, STORE, JNZ` take an `addr`ess and register index (`i_reg`)
  * Register type: `MOVE, ADD, SUB, MUL` take indices of three registers. Two source (`i_rs1, i_rs2`) and one destination `i_rd`.
* `JNZ` jumps to the `addr` when `regs[i_reg]` is nonzero.

<style>
  .cpu-instruction-table {
    width: 100%;
    border-collapse: collapse;
    font-family: inherit;
    font-size: inherit;
  }
  .cpu-instruction-table th,
  .cpu-instruction-table td {
    padding: 0.5rem 0.75rem;
  }
  .cpu-instruction-table th {
    white-space: nowrap;
  }
</style>

<table class="cpu-instruction-table" border="1">
  <tr>
    <th>Instructions</th>
    <th>Format</th>
    <th>4 Bits [15:12]</th>
    <th>4 Bits [11:8]</th>
    <th>4 Bits [7:4]</th>
    <th>4 Bits [3:0]</th>
  </tr>
  <tr>
    <td><code>LOAD</code>, <code>STORE</code>, <code>JNZ</code></td>
    <td>Address</td>
    <td colspan="2" align="center"><code>addr</code></td>
    <td><code>i_reg</code></td>
    <td><code>opcode</code></td>
  </tr>
  <tr>
    <td><code>MOVE</code>, <code>ADD</code>, <code>SUB</code>, <code>MUL</code></td>
    <td>Register</td>
    <td><code>i_rs2</code></td>
    <td><code>i_rs1</code></td>
    <td><code>i_rd</code></td>
    <td><code>opcode</code></td>
  </tr>
</table>

### Reading Instructions

Each instruction field is 4-bits, so it becomes a character when displayed as hex, making it easy to read binary. Read right to left (little endian). e.g.

```
0x 1250 : 0=LOAD regs[5] <- dmem[0x12]
0x 0123 : 3=ADD  regs[2] <- regs[1] + regs[0]
```

Waveform of Fibonacci program:
![Fibonacci Code](https://media.abapages.com/course-site/fibonacci.png)

## Full CPU (40 LOC)

```{literalinclude} ../material/rtl/cpu/cpu.sv
:language: systemverilog
```
