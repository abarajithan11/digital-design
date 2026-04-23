# Setting up Docker

First clone our repo:

```sh
git clone git@github.com:abarajithan11/digital-design.git
# or
git clone https://github.com/abarajithan11/digital-design.git
```


## Build, start, and enter docker container - from Ubuntu or WSL2

```bash
make fresh   # only once, unless something is broken
make enter   # to enter after you exit

# make restart - if your container gets stopped 
```

## Run simulation and RTL-to-GDS2 flow with ASAP7

From inside the container

```bash
make sim          DESIGN=alu
make gds          DESIGN=alu
make show_layout  DESIGN=alu
make show_3d      DESIGN=alu
make show_3d_cell CELL=NAND2x1 # just make show_3d_cell gives all cells
# exit - to leave the container 
```

* The root `Makefile` only manages the Docker image and container. 
* The `material/Makefile` handles simulation and RTL2GDS.
* Reports and layout images are stored in `material/openroad/work/reports/asap7/4_alu/base`
