# Setting up Docker

First clone our repo:

```sh
git clone git@github.com:abarajithan11/digital-design.git
# or
git clone https://github.com/abarajithan11/digital-design.git
```


## Build, start, and enter the Docker container from Ubuntu or WSL2

```bash
make fresh   # only once, unless something is broken
make enter   # to enter after you exit

# make restart - if your container gets stopped
```

## Run simulation and RTL-to-GDS2 flow with ASAP7

From inside the container:

```bash
make sim                DESIGN=alu
make gds                DESIGN=alu
make sim_all
make gds_all
make show_layout        DESIGN=alu
make show_3d            DESIGN=alu
make show_3d_cell       CELL=NAND2x1 
make show_3d_cell       # show all available cells
make show_layout_cells
# exit - to leave the container
```

* The root `Makefile` handles Docker, artifact collection, and site generation.
* The `material/Makefile` handles the in-container design flows.
* Reports and layout images are stored in `material/openroad/work/reports/asap7/4_alu/base`
