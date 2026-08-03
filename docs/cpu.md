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

* Only 8 opcodes: `NOP=0`, `LOAD=1`, `STORE=2`, `MOVE=3`, `ADD=4`, `SUB=5`, `MUL=6`, and `JNZ=7`.
* `NOP` is the all-zero instruction and has no side effects.
* Two instruction formats:
  * Address type: `LOAD, STORE, JNZ` take a data-memory address (`dmem_addr`) and register index (`i_reg_a`)
  * Register type: `MOVE, ADD, SUB, MUL` take indices of three registers. Two sources (`i_reg_b, i_reg_c`) and one destination (`i_reg_a`).
* `JNZ` jumps to `dmem_addr` when `regs[i_reg_a]` is nonzero.

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
    <td colspan="2" align="center"><code>dmem_addr</code></td>
    <td><code>i_reg_a</code></td>
    <td><code>opcode</code></td>
  </tr>
  <tr>
    <td><code>MOVE</code>, <code>ADD</code>, <code>SUB</code>, <code>MUL</code></td>
    <td>Register</td>
    <td><code>i_reg_c</code></td>
    <td><code>i_reg_b</code></td>
    <td><code>i_reg_a</code></td>
    <td><code>opcode</code></td>
  </tr>
</table>

### Reading Instructions

Each instruction field is 4-bits, so it becomes a character when displayed as hex, making it easy to read binary. Read right to left (little endian). e.g.

```
0x 1251 : 1=LOAD regs[5] <- dmem[0x12]
0x 0124 : 4=ADD  regs[2] <- regs[1] + regs[0]
```

### Example: Sum to N numbers

The algorithm described in C:

```c
// setup:
uint16_t mem[256];
mem[0] = 0;    // sum seed
mem[1] = 1;    // the constant one
mem[2] = 10;   // N

// run:
uint16_t r0_sum   = mem[0];
uint16_t r1_one   = mem[1];
for (r2_count = mem[2]; r2_count !=0; r2_count -= r1_one) {
  r0_sum += r2_count;
}
mem[4] = r0_sum;  //55
```

The algorithm described in our machine code and assembly:

```
0: R0_SUM   = *(0);
1: R1_ONE   = *(1);
2: R2_COUNT = *(2);
3: R0_SUM   = R0_SUM + R2_COUNT;
4: R2_COUNT = R2_COUNT - R1_ONE;
5: if (R2_COUNT!=0) goto 3;
6: *(4) = R0_SUM;
```

![Fibonacci Code](https://media.abapages.com/course-site/fibonacci.png)

## Full CPU (40 LOC)

```{literalinclude} ../material/rtl/cpu/cpu.sv
:language: systemverilog
```
