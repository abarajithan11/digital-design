# Setting up Docker

## Target environment

These commands are intended for Ubuntu (Native OS or WSL2)

## Setup, start and enter docker container, from Ubuntu or WSL2

```bash
make fresh
make enter
```

## Run simulation, and RTL-to-GDS2 flow with ASAP7

From inside docker container

```bash
make sim DESIGN=adder
make gds DESIGN=adder
make show_layout DESIGN=adder
```

* The root `Makefile` only manages the Docker image and container. The `material/Makefile` handles simulation and RTL2GDS.
* Reports and layout images are stored in `material/openroad/work/reports/asap7/adder/base`
