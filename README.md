# Course Website and Material (SystemVerilog) for CSE 140

## Open-source ASIC flow from WSL2

Run these commands from the repo root inside WSL2:

```bash
make fresh
make enter

cd material
make check_tools
make gds DESIGN=adder
make show_layout DESIGN=adder
```

* The root `Makefile` only manages the Docker image and container. The `material/Makefile` handles the ORFS flow itself.
* Reports and layout images are stored in `material/openroad/work/reports/asap7/adder/base`

## To locally serve the site

```bash
source .venv/Scripts/activate
python -m mkdocs serve

# Visit http://127.0.0.1:8000/digital-design
```
