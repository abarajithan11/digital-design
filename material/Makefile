SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

USR       := $(shell id -un)
CONTAINER := orfs-$(USR)

DESIGN ?= alu
PDK    ?= asap7

CONT_REPO     ?= /repo
CONT_MATERIAL := $(CONT_REPO)/material

TOP_TB      = tb_$(DESIGN)
FLIST       = designs/$(DESIGN).f
SIM_GEN     = py/$(DESIGN)_gen.py
SIM_WORKDIR = $(CONT_MATERIAL)/sim/$(DESIGN)
WAVE_FST    = $(SIM_WORKDIR)/$(DESIGN).fst

WAVE_SVG_SHORT   ?= $(SIM_WORKDIR)/$(DESIGN)_short.svg
WAVE_SHORT_START ?= 0
WAVE_SHORT_END   ?= 10000
WAVE_WINDOW      ?= 65536
WAVE_SAMPLE      ?= 512
WAVE_HSCALE      ?= 1

ASAP7_LIB_GDS    := /OpenROAD-flow-scripts/flow/platforms/asap7/gds/asap7sc7p5t_28_R_220121a.gds
NANGATE45_LIB_GDS := /OpenROAD-flow-scripts/flow/platforms/nangate45/gds/NangateOpenCellLibrary.gds
SKY130_LIB_GDS   := /OpenROAD-flow-scripts/flow/platforms/sky130hd/gds/sky130_fd_sc_hd.gds

CELL         ?=
CELL_3D_DIR  := $(CONT_MATERIAL)/openroad/work/results/cell_3d

include basic_run.mk

.PHONY: prepare gtkwave wave_svg show_layout_cells show_3d_cell glb cell_glbs 3d_assets clean

prepare: check_tools
	mkdir -p "$(WORK_HOME)" "$(CONT_MATERIAL)/sim" "$(CELL_3D_DIR)"

gtkwave: check_tools
	gtkwave "$(WAVE_FST)"

wave_svg: check_tools
	mkdir -p "$(SIM_WORKDIR)"
	test -f "$(WAVE_FST)"
	vcd="$(SIM_WORKDIR)/$(DESIGN).vcd"; \
	fst2vcd "$(WAVE_FST)" -o "$$vcd"; \
	python3 "$(CONT_REPO)/scripts/vcd_to_svg.py" \
		--vcd "$$vcd" \
		--svg "$(WAVE_SVG_SHORT)" \
		--start "$(WAVE_SHORT_START)" \
		--end "$(WAVE_SHORT_END)" \
		--window "$(WAVE_WINDOW)" \
		--sample-rate "$(WAVE_SAMPLE)" \
		--hscale "$(WAVE_HSCALE)" \
		--max-depth 1
	echo "Wrote waveform image: $(WAVE_SVG_SHORT)"

show_layout_cells: check_tools
	case "$(PDK)" in \
	  asap7)     lib="$(ASAP7_LIB_GDS)";; \
	  nangate45) lib="$(NANGATE45_LIB_GDS)";; \
	  sky130*)   lib="$(SKY130_LIB_GDS)";; \
	esac; \
	$(KLAYOUT_CMD) -l "$(PLATFORM_LYP)" "$$lib"

glb: check_tools
	test -f "$(FINAL_GDS)"
	apply_z_scale() { \
	  local scad="$$1" z="$$2" tmp; \
	  case "$$z" in 1|1.0|1.00) return 0;; esac; \
	  tmp="$${scad}.tmp.$$$$"; \
	  { printf 'scale(v=[1,1,%.10f]){\n' "$$z"; sed 's/^/\t/' "$$scad"; printf '}\n'; } > "$$tmp"; \
	  mv "$$tmp" "$$scad"; \
	}; \
	"$(GDS3XTRUDE_EXE)" -v --tech "$(GDS3XTRUDE_TECH)" \
		--input "$(FINAL_GDS)" --cell "$(GDS3XTRUDE_TOP)" \
		--output "$(GDS3XTRUDE_OUT)" $(GDS3XTRUDE_FLAGS) $(GDS3XTRUDE_EXTRA_FLAGS); \
	apply_z_scale "$(GDS3XTRUDE_OUT)" "$(GDS3XTRUDE_Z_SCALE)"; \
	python3 "$(CONT_REPO)/scripts/scad_to_glb.py" "$(GDS3XTRUDE_OUT)" "$(GDS3XTRUDE_GLB)"; \
	printf '%s\n' "$(GDS3XTRUDE_GLB)"

show_3d_cell: check_tools
	mkdir -p "$(CELL_3D_DIR)"
	apply_z_scale() { \
	  local scad="$$1" z="$$2" tmp; \
	  case "$$z" in 1|1.0|1.00) return 0;; esac; \
	  tmp="$${scad}.tmp.$$$$"; \
	  { printf 'scale(v=[1,1,%.10f]){\n' "$$z"; sed 's/^/\t/' "$$scad"; printf '}\n'; } > "$$tmp"; \
	  mv "$$tmp" "$$scad"; \
	}; \
	case "$(PDK)" in \
	  asap7)     lib="$(ASAP7_LIB_GDS)"; suffix="_ASAP7_75t_R"; pat='_ASAP7_75t_R$$';; \
	  nangate45) lib="$(NANGATE45_LIB_GDS)"; suffix=""; pat='^[A-Za-z0-9_]*_X[0-9]*$$';; \
	  sky130*)   lib="$(SKY130_LIB_GDS)"; suffix=""; pat='^sky130_fd_sc_hd__';; \
	  *)         printf 'Unknown PDK: %s\n' "$(PDK)" >&2; exit 1;; \
	esac; \
	if [ -z "$(CELL)" ]; then \
		printf '\n%s\n\n' "Possible CELL values:"; \
		strings "$$lib" | grep "$$pat" | sed "s/$$suffix$$//" | sort -u | paste -sd '  ' -; \
		exit 0; \
	fi; \
	full_cell="$(CELL)$$suffix"; \
	scad="$(CELL_3D_DIR)/$$full_cell.scad"; \
	"$(GDS3XTRUDE_EXE)" -v --tech "$(GDS3XTRUDE_TECH)" \
		--input "$$lib" --cell "$$full_cell" \
		--output "$$scad" $(GDS3XTRUDE_FLAGS); \
	apply_z_scale "$$scad" "$(GDS3XTRUDE_Z_SCALE)"; \
	"$(OPENSCAD_EXE)" "$$scad"

cell_glbs: check_tools
	mkdir -p "$(CELL_3D_DIR)"
	for cell in INVx1 NAND2x1 AOI211x1 DFFHQNx1; do \
		full_cell="$${cell}_ASAP7_75t_R"; \
		"$(GDS3XTRUDE_EXE)" -v --tech "$(GDS3XTRUDE_TECH)" \
			--input "$(ASAP7_LIB_GDS)" --cell "$$full_cell" \
			--output "$(CELL_3D_DIR)/$$full_cell.scad" $(GDS3XTRUDE_FLAGS); \
		python3 "$(CONT_REPO)/scripts/scad_to_glb.py" \
			"$(CELL_3D_DIR)/$$full_cell.scad" "$(CELL_3D_DIR)/$$full_cell.glb"; \
	done

3d_assets: check_tools
	mkdir -p "$(CONT_REPO)/out/gds-assets/n_adder"
	if [ ! -f "$(CONT_MATERIAL)/openroad/work/results/$(PDK)/n_adder/base/6_final.gds" ]; then \
		$(MAKE) gds DESIGN=n_adder; \
	fi
	$(MAKE) glb DESIGN=n_adder
	cp "$(CONT_MATERIAL)/openroad/work/results/$(PDK)/n_adder/base/6_final.glb" \
		"$(CONT_REPO)/out/gds-assets/n_adder/n_adder.glb"

clean: check_tools
	rm -rf $(CONT_MATERIAL)/sim $(CONT_MATERIAL)/openroad/work
	rm -rf data/*.wav data/coef.svh data/y.txt data/x_music.txt data/y_exp.txt data/filter.png
