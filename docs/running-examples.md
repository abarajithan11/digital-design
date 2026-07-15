# Running our Examples

## Setup

Install Docker and set up the course container using the repository README:

https://github.com/abarajithan11/digital-design#quickstart-on-examples

```bash
git clone https://github.com/abarajithan11/digital-design
cd digital-design
make fresh
make enter
```

The repository is mounted into the container, so files created inside the container are visible in the same repository in VS Code.

Run the remaining commands from:

```text
/repo/material
```

You can write your own designs & testbenches, and then run simulations and ASIC flow.

## Invoking Verilator directly

Create a temporary directory:

```bash
mkdir -p /tmp/and_gate
cd /tmp/and_gate
```

Save this as `and_gate.sv`:

```systemverilog
module and_gate (
  input  logic a, b,
  output logic y
);
  always_comb y = a & b;
endmodule
```

Save this as `tb_and_gate.sv`:

```systemverilog
`timescale 1ns/1ps

module tb_and_gate;
  logic a, b, y;

  and_gate dut (.*);

  initial begin
    $dumpfile("and_gate.fst");
    $dumpvars;

    for (int i = 0; i < 4; i++) begin
      {a, b} = i;
      #1; assert (y == (a & b));
    end
    $finish;
  end
endmodule
```

Compile and run:

```bash
verilator --binary --trace-fst --timing --sv --top-module tb_and_gate and_gate.sv tb_and_gate.sv

./obj_dir/Vtb_and_gate
```

Open the waveform:

```bash
gtkwave and_gate.fst
```

This is manageable for a small example, but larger designs may contain many files. Therefore, we use a build system.

## Using our build system

General format:

```bash
make <command> DESIGN=<design_name>
```

Example:

```bash
make sim DESIGN=and_gate
```

The Makefile searches a file named `<design_name>` here:

```text
designs/<design_name>.f
designs/*/<design_name>.f
```

For example:

```text
designs/reference/and_gate.f
```

The `.f` file lists all RTL and testbench files required for that design.

## Simulation

```bash
make sim DESIGN=and_gate
```

This compiles and runs the testbench using Verilator and generates:

```text
sim/and_gate/and_gate.fst
```

You can view it with:

```bash
make gtkwave DESIGN=and_gate
```

## Reading the waveform

In GTKWave:

- Signals are listed on the left.
- Time increases from left to right.
- Each `#` delay or clock/event control advances simulation time.
- Statements between two delays occur at the same simulation time.

For the AND-gate testbench, each loop iteration occupies one nanosecond in the waveform.

## ASIC flow

```bash
make gds DESIGN=and_gate
```

This performs:

1. Synthesis
2. Placement
3. Clock-tree synthesis
4. Routing
5. Final GDS generation

The flow maps the RTL to standard cells: pre-designed gates and flip-flops used like electronic LEGO blocks.

## Generated files

Synthesis netlist:

```text
openroad/work/results/asap7/<rtl_top>/base/1_2_yosys.v
```

Final netlist:

```text
openroad/work/results/asap7/<rtl_top>/base/6_final.v
```

Final layout:

```text
openroad/work/results/asap7/<rtl_top>/base/6_final.gds
```

Reports:

```text
openroad/work/reports/asap7/<rtl_top>/base/
```

Open these files directly in VS Code.

Useful commands:

```bash
make show_syn_netlist    DESIGN=and_gate
make show_final_nestlist DESIGN=and_gate
make show_layout         DESIGN=and_gate
```

The reports include cell count, area, timing, and routing statistics.