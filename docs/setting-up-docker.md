# Setting up Docker

## Target environment

These commands are intended for WSL2. Run them from the Linux shell at the root
of this repository, not from PowerShell.

## Prerequisites

- Docker Desktop installed on Windows with WSL2 integration enabled for your distro
- A working WSL2 distro such as Ubuntu
- GUI support through WSLg or another X server if you want `make show_layout`

## Course flow

The repo is split into two layers:

- the root `Makefile` manages the Docker image and container
- `material/Makefile` manages the ORFS flow inside that container

```bash
git submodule update --init --recursive
make fresh
make enter

cd material
make check_tools
make gds DESIGN=adder
make show_layout DESIGN=adder
```

What each command does:

- `git submodule update --init --recursive` fetches the pinned ORFS checkout into `material/openroad/OpenROAD-flow-scripts/`.
- `make fresh` kills any previous container, rebuilds the image, and starts a fresh container.
- `make enter` drops you into an interactive shell in the running container.
- `cd material && make check_tools` prints the versions of OpenROAD, Yosys, KLayout, Verilator, and GTKWave inside that container.
- `cd material && make gds DESIGN=adder` runs ORFS using the shared config in `material/openroad/`, reads RTL such as `material/rtl/adder.sv`, and writes logs, reports, netlists, and GDS output under `material/openroad/work/`.
- `cd material && make show_layout DESIGN=adder` opens the final GDS in KLayout.

## GUI notes

`make start` forwards WSL GUI environment variables and mounts the usual X11 and
WSLg sockets. On a normal Windows 11 WSLg setup, that is enough for KLayout and
GTKWave to open on the Windows desktop.

## Quick Docker sanity check

Before using the course targets, confirm Docker itself works in WSL2:

```bash
docker version
docker run --rm hello-world
```
