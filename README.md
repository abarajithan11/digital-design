# Course Website and Material (SystemVerilog) for CSE 140

Visit the site: [abapages.com/digital-design](https://abapages.com/digital-design/)

### Set up, start, and enter the Docker container from Ubuntu or WSL2

```bash
make fresh
make enter
```

### Run simulation and the RTL-to-GDS2 flow with ASAP7

From inside the Docker container:

```bash
make sim          DESIGN=alu
make gds          DESIGN=alu
make sim_all
make gds_all
make show_layout  DESIGN=alu
make show_3d      DESIGN=alu
make show_3d_cell CELL=NAND2x1 # omit CELL to list available cells
make show_layout_cells
```

* The root `Makefile` handles Docker, artifact collection, and site generation. The `material/Makefile` handles the in-container design flows.
* Reports and layout images are stored in `material/openroad/work/reports/asap7/alu/base`

## To locally serve the site

```bash
pip install sphinx furo myst-parser
make 3d_assets
make site
make serve
```

Then open `http://localhost:8000` in your browser.
