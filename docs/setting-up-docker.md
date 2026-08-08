# Docker for ASIC+FPGA

Digital design is often taught as a collection of abstract topics, such as logic minimization, setup and hold time, and critical-path analysis. 
In this course, you will connect those ideas to an end-to-end ASIC design flow: writing SystemVerilog, running simulations, inspecting waveforms, generating a layout from RTL, and reading timing reports. 
You will also apply the same skills to moderately complex systems, including a neural-network accelerator, an FIR filter, and a CPU.

This flow relies on tools such as Verilator, GTKWave, Yosys, Magic, and KLayout, along with process design kits and standard-cell libraries such as ASAP7, Nangate45, and SkyWater 130. Installing and configuring all of them separately is difficult, so we provide a preconfigured Docker image of approximately 3–5 GB. 
The image gives everyone a consistent environment while still allowing you to run the complete flow on your own computer. 
After the course, you can continue using it to develop, test, and publish designs for personal projects or a portfolio.

You may also implement your designs on an inexpensive Tang Nano 20K FPGA. 
FPGA toolchains can be difficult to configure and debug, so the course setup provides a simplified interface for designs that use the board's buttons and LEDs, as well as UART support for designs that communicate with your computer. 
This makes it practical to demonstrate projects such as CPUs and small accelerators on real hardware and share recordings of them in a project portfolio.

## Initial Setup

Follow the [Quickstart on Examples](https://github.com/abarajithan11/digital-design#quickstart-on-examples) in the GitHub README to install Docker, clone the repository, start the course container, and configure graphical applications for your operating system.

The repository is mounted inside the container, so edits and generated files are shared between the host and container. 
Stopping or recreating the container does not delete the files in your local repository.

## Basic Docker Commands

Run these commands from the repository's top-level directory:

| Command | Purpose |
| --- | --- |
| `make fresh` | Pull the latest course image and start a new container. |
| `make enter` | Open an interactive terminal inside the running container. |
| `exit` | Leave the container terminal without stopping the container. |
| `make kill` | Stop and remove the course container. Your repository files remain on the host. |
| `make run CMD="<command>"` | Run one command in a temporary container, then remove that container. |

For example, after running `make enter`, the following commands can be used for the ASIC and FPGA flows:

```bash
make sim         DESIGN=alu  # Compile & run verilator simulation
make gtkwave     DESIGN=alu  # View waveform in GTKWave
make gds         DESIGN=alu  # Run openroad rtl2gds
make show_layout DESIGN=alu  # View GDSII
make bitstream   DESIGN=alu  # Generate bitstream for FPGA
```

## Running Examples

`make enter` starts an interactive terminal in `/repo/material`, where the provided examples and build system are located. Commands use this general format:

```bash
make <command> DESIGN=<design_name>
```

For example, simulate the AND gate and open its waveform with:

```bash
make sim     DESIGN=and_gate
make gtkwave DESIGN=and_gate
```

The build system finds exactly one matching file at `designs/<design_name>.f` or `designs/*/<design_name>.f`. This file lists the RTL and testbench sources required for the design. `make sim` compiles and runs the testbench with Verilator.


## ASIC Flow

Run the RTL-to-GDS flow with:

```bash
make gds DESIGN=and_gate
```

This synthesizes the RTL into standard cells, places the cells, builds the clock tree, routes the design, and generates the final GDS layout.

## Generated Files

- Simulation waveform: `sim/<design_name>/<design_name>.fst`
- Synthesis netlist: `openroad/work/results/asap7/<rtl_top>/base/1_2_yosys.v` (`make show_syn_netlist DESIGN=<design_name>`)
- Final netlist: `openroad/work/results/asap7/<rtl_top>/base/6_final.v` (`make show_final_nestlist DESIGN=<design_name>`)
- Final layout: `openroad/work/results/asap7/<rtl_top>/base/6_final.gds` (`make show_layout DESIGN=<design_name>`)
- Area, timing, cell-count, and routing reports: `openroad/work/reports/asap7/<rtl_top>/base/`

## Using Your Own Designs

### For quick iterations

For a small design, if you prefer, you can invoke Verilator and GTKWave directly instead of using the build system. The testbench must enable waveform tracing and write the `.fst` file passed to GTKWave.

```bash
verilator --binary --trace-fst --timing --sv --top-module tb_<DESIGN> tb_<DESIGN>.sv <DESIGN>.sv
./obj_dir/Vtb_<DESIGN>
gtkwave <DESIGN>.fst
```

But this quickly gets tedious if your design requires many files, like `sys_fir_filter`, which requires six RTL and three testbench files [listed here](https://github.com/abarajithan11/digital-design/blob/main/material/designs/systems/sys_fir_filter.f).

### Using our build system

Choose the category that best fits your design: `reference`, `systems`, or `cpu`. Replace `CATEGORY` and `YOUR_DESIGN` below with your choices, and use the same category for the RTL, testbench, and file-list directories:

```text
material/rtl/CATEGORY/YOUR_DESIGN.sv
material/tb/CATEGORY/tb_YOUR_DESIGN.sv
material/designs/CATEGORY/YOUR_DESIGN.f
```

The file list contains the paths of every source file needed by the design, relative to the `material` directory. Put the top-level RTL file first, followed by any supporting RTL files and the testbench. For example, `material/designs/systems/YOUR_DESIGN.f` might contain:

```text
rtl/systems/YOUR_DESIGN.sv
rtl/reference/supporting_module.sv
tb/systems/tb_YOUR_DESIGN.sv
```

The RTL module may use its own module name, but the testbench's top-level module must be named `tb_YOUR_DESIGN`. When you run a command with `DESIGN=YOUR_DESIGN`, the build system searches `material/designs/` and its immediate subdirectories for exactly one file named `YOUR_DESIGN.f`, then uses the sources listed there.

```bash
make sim         DESIGN=YOUR_DESIGN
make gds         DESIGN=YOUR_DESIGN
make show_layout DESIGN=YOUR_DESIGN
```

If the design is very small, add `YOUR_DESIGN` to the `SMALL_DESIGNS` list in `material/openroad/parameters.mk`. Small designs use a safer floorplan for the ASAP7 power-delivery geometry; without it, designs with only a few cells may fail during layout generation.
