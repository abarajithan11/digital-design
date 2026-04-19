# Course Website and Material (SystemVerilog) for CSE 140

### Setup, start and enter docker container, from Ubuntu or WSL2

```bash
make fresh
make enter
```

### Run simulation, and RTL-to-GDS2 flow with ASAP7

From inside docker container

```bash
make sim DESIGN=adder
make gds DESIGN=adder
make show_layout DESIGN=adder
```

* The root `Makefile` only manages the Docker image and container. The `material/Makefile` handles simulation and RTL2GDS.
* Reports and layout images are stored in `material/openroad/work/reports/asap7/adder/base`

## To locally serve the site

```bash
pip install sphinx furo myst-parser
make serve
```

Then open `http://localhost:8000` in your browser.


## Examples

1. Not Gate
2. Full Adder
3. N-Adder
4. ALU
5. Encoder
6. Decoder
7. Verilog Functions
8. Flip Flop
9. Register
10. Vector Minimum
11. Up counter
12. Down counter
13. Nested counters
14. Parallel to Serial Converter
15. UART RX
16. UART TX
17. UART RX + TX
18. FIR Filter
19. FIR Filter - Retimed
20. UART RX + TX + FIR Filter
