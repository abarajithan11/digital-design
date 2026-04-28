SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

USR       := $(shell id -un)
CONTAINER := orfs-$(USR)

DESIGN ?= alu
PDK ?= asap7

HOST_MATERIAL := $(CURDIR)
CONT_REPO ?= /repo
CONT_MATERIAL := $(CONT_REPO)/material

ORFS_FLOW_DIR := $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow
WORK_HOME    := $(CONT_MATERIAL)/openroad/work
DESIGN_CONFIG := $(CONT_MATERIAL)/openroad/config.mk
RESULTS_DIR  := $(WORK_HOME)/results/$(PDK)/$(DESIGN)/base
FINAL_GDS    := $(RESULTS_DIR)/6_final.gds
REPORT_IMAGE_SCALE ?= 4
PLATFORM_LYP := $(firstword \
	$(wildcard $(CONT_MATERIAL)/openroad/$(PDK).lyp) \
	$(wildcard $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/$(PDK)/KLayout/*.lyp) \
	$(wildcard $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/$(PDK)/*.lyp))

YOSYS_EXE        ?= yosys
OPENROAD_EXE     ?= openroad
KLAYOUT_CMD      ?= klayout
GDS3XTRUDE_EXE    ?= gds3xtrude
OPENSCAD_EXE      ?= openscad
GDS3XTRUDE_TECH   ?= $(CONT_MATERIAL)/openroad/gds3xtrude/$(PDK).layerstack
GDS3XTRUDE_TOP    ?= $(DESIGN)
GDS3XTRUDE_OUT    ?= $(RESULTS_DIR)/6_final.scad
GDS3XTRUDE_GLB    ?= $(patsubst %.scad,%.glb,$(GDS3XTRUDE_OUT))
GDS3XTRUDE_SCALE  ?= 1.0
GDS3XTRUDE_XY_SCALE ?= 1.0
GDS3XTRUDE_Z_SCALE ?= $(GDS3XTRUDE_SCALE)
GDS3XTRUDE_FLAGS  ?= --scale $(GDS3XTRUDE_XY_SCALE)
ASAP7_LIB_GDS    := $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/asap7/gds/asap7sc7p5t_28_R_220121a.gds
NANGATE45_LIB_GDS := $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/nangate45/gds/NangateOpenCellLibrary.gds
SKY130_LIB_GDS   := $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/sky130hd/gds/sky130_fd_sc_hd.gds
CELL ?=
CELL_3D_DIR      := $(CONT_MATERIAL)/openroad/work/results/cell_3d

TOP_TB       ?= tb_$(DESIGN)
SIM_WORKDIR  := $(CONT_MATERIAL)/sim/$(DESIGN)
SIM_GEN      := py/$(DESIGN)_gen.py
SIM_MAX_TIME ?= 1s
WAVE_VCD     ?= $(SIM_WORKDIR)/$(DESIGN).vcd
WAVE_SVG_SHORT ?= $(SIM_WORKDIR)/$(DESIGN)_short.svg
WAVE_SHORT_START ?= 0
WAVE_SHORT_END   ?= 10000
WAVE_WINDOW  ?= 65536
WAVE_SAMPLE  ?= 512
WAVE_HSCALE  ?= 1

.PHONY: require_container prepare gds sim sim_all gds_all gtkwave wave_svg clean show_layout show_layout_cells show_3d show_3d_cell glb cell_glbs 3d_assets

require_container:
	test -f /.dockerenv

prepare: require_container
	test -n "$(DESIGN)"
	mkdir -p "$(WORK_HOME)"
	mkdir -p "$(CONT_MATERIAL)/sim"
	mkdir -p $(CELL_3D_DIR)

gds: prepare
	if [ -f "$(SIM_GEN)" ]; then python3 "$(SIM_GEN)"; fi
	rm -rf "$(WORK_HOME)/results/$(PDK)/$(DESIGN)"
	rm -rf "$(WORK_HOME)/logs/$(PDK)/$(DESIGN)"
	rm -rf "$(WORK_HOME)/reports/$(PDK)/$(DESIGN)"
	rm -rf "$(WORK_HOME)/objects/$(PDK)/$(DESIGN)"
	REPORT_IMAGE_SCALE="$(REPORT_IMAGE_SCALE)" $(MAKE) -C "$(ORFS_FLOW_DIR)" DESIGN_NAME="$(DESIGN)" DESIGN_CONFIG="$(DESIGN_CONFIG)" WORK_HOME="$(WORK_HOME)" YOSYS_EXE="$(YOSYS_EXE)" OPENROAD_EXE="$(OPENROAD_EXE)" KLAYOUT_CMD="$(KLAYOUT_CMD)" gds

sim: prepare
	mkdir -p "$(SIM_WORKDIR)"
	if [ -f "$(SIM_GEN)" ]; then python3 "$(SIM_GEN)"; fi
	verilator --binary --trace-vcd --timing --sv --top-module "$(TOP_TB)" -Mdir "$(SIM_WORKDIR)/obj_dir" "-DVCD_PATH=\"$(WAVE_VCD)\"" "-DSIM_MAX_TIME=$(SIM_MAX_TIME)" -f "designs/$(DESIGN).f"
	"$(SIM_WORKDIR)/obj_dir/V$(TOP_TB)"

gtkwave:
	gtkwave "$(WAVE_VCD)"

wave_svg:
	mkdir -p "$(SIM_WORKDIR)"
	test -f "$(WAVE_VCD)"
	python3 "$(CONT_REPO)/scripts/vcd_to_svg.py" \
		--vcd "$(WAVE_VCD)" \
		--svg "$(WAVE_SVG_SHORT)" \
		--start "$(WAVE_SHORT_START)" \
		--end "$(WAVE_SHORT_END)" \
		--window "$(WAVE_WINDOW)" \
		--sample-rate "$(WAVE_SAMPLE)" \
		--hscale "$(WAVE_HSCALE)" \
		--max-depth 1
	echo "Wrote waveform image: $(WAVE_SVG_SHORT)"

sim_all:
	for design_file in designs/*.f; do \
		design_name="$${design_file##*/}"; \
		design_name="$${design_name%.f}"; \
		$(MAKE) sim DESIGN=$$design_name; \
	done

gds_all:
	for design_file in designs/*.f; do \
		design_name="$${design_file##*/}"; \
		design_name="$${design_name%.f}"; \
		$(MAKE) gds DESIGN=$$design_name; \
	done

show_layout: require_container
	$(KLAYOUT_CMD) -l "$(PLATFORM_LYP)" "$(FINAL_GDS)"

show_layout_cells: require_container
	$(KLAYOUT_CMD) -l "$(PLATFORM_LYP)" "$(ASAP7_LIB_GDS)"

show_3d: require_container
	echo "DISPLAY=$${DISPLAY:-<unset>}"
	apply_z_scale() { \
	  local scad="$$1"; \
	  local z_scale="$$2"; \
	  local tmp; \
	  if [ "$$z_scale" = "1" ] || [ "$$z_scale" = "1.0" ] || [ "$$z_scale" = "1.00" ]; then return 0; fi; \
	  tmp="$${scad}.zscale.$$$$"; \
	  { printf 'scale(v = [1, 1, %.10f]) {\n' "$$z_scale"; sed 's/^/\t/' "$$scad"; printf '}\n'; } > "$$tmp"; \
	  mv "$$tmp" "$$scad"; \
	}; \
	"$(GDS3XTRUDE_EXE)" -v --tech "$(GDS3XTRUDE_TECH)" --input "$(FINAL_GDS)" --cell "$(GDS3XTRUDE_TOP)" --output "$(GDS3XTRUDE_OUT)" $(GDS3XTRUDE_FLAGS) $(GDS3XTRUDE_EXTRA_FLAGS); \
	apply_z_scale "$(GDS3XTRUDE_OUT)" "$(GDS3XTRUDE_Z_SCALE)"; \
	"$(OPENSCAD_EXE)" "$(GDS3XTRUDE_OUT)"

glb: prepare
	test -f "$(FINAL_GDS)"
	apply_z_scale() { \
	  local scad="$$1"; \
	  local z_scale="$$2"; \
	  local tmp; \
	  if [ "$$z_scale" = "1" ] || [ "$$z_scale" = "1.0" ] || [ "$$z_scale" = "1.00" ]; then return 0; fi; \
	  tmp="$${scad}.zscale.$$$$"; \
	  { printf 'scale(v = [1, 1, %.10f]) {\n' "$$z_scale"; sed 's/^/\t/' "$$scad"; printf '}\n'; } > "$$tmp"; \
	  mv "$$tmp" "$$scad"; \
	}; \
	"$(GDS3XTRUDE_EXE)" -v --tech "$(GDS3XTRUDE_TECH)" --input "$(FINAL_GDS)" --cell "$(GDS3XTRUDE_TOP)" --output "$(GDS3XTRUDE_OUT)" $(GDS3XTRUDE_FLAGS) $(GDS3XTRUDE_EXTRA_FLAGS)
	apply_z_scale "$(GDS3XTRUDE_OUT)" "$(GDS3XTRUDE_Z_SCALE)"
	python3 "$(CONT_REPO)/scripts/scad_to_glb.py" "$(GDS3XTRUDE_OUT)" "$(GDS3XTRUDE_GLB)"
	printf '%s\n' "$(GDS3XTRUDE_GLB)"

show_3d_cell: require_container
	mkdir -p "$(CELL_3D_DIR)"
	apply_z_scale() { \
	  local scad="$$1"; \
	  local z_scale="$$2"; \
	  local tmp; \
	  if [ "$$z_scale" = "1" ] || [ "$$z_scale" = "1.0" ] || [ "$$z_scale" = "1.00" ]; then return 0; fi; \
	  tmp="$${scad}.zscale.$$$$"; \
	  { printf 'scale(v = [1, 1, %.10f]) {\n' "$$z_scale"; sed 's/^/\t/' "$$scad"; printf '}\n'; } > "$$tmp"; \
	  mv "$$tmp" "$$scad"; \
	}; \
	case "$(PDK)" in \
	  asap7) \
	    lib_gds="$(ASAP7_LIB_GDS)"; \
	    cell_suffix="_ASAP7_75t_R"; \
	    grep_pattern='_ASAP7_75t_R$$'; \
	    ;; \
	  nangate45) \
	    lib_gds="$(NANGATE45_LIB_GDS)"; \
	    cell_suffix=""; \
	    grep_pattern='^[A-Za-z0-9_]*_X[0-9]*$$'; \
	    ;; \
	  sky130|sky130hd) \
	    lib_gds="$(SKY130_LIB_GDS)"; \
	    cell_suffix=""; \
	    grep_pattern='^sky130_fd_sc_hd__'; \
	    ;; \
	  *) \
	    printf 'Unknown PDK: %s\n' "$(PDK)" >&2; \
	    exit 1; \
	    ;; \
	esac; \
	if [ -z "$(CELL)" ]; then \
		printf '\n%s\n\n' "Possible values for CELL:"; \
		strings "$$lib_gds" | grep "$$grep_pattern" | sed "s/$$cell_suffix$$//" | sort -u | paste -sd '\t' -; \
		exit 0; \
	fi; \
	full_cell="$(CELL)$$cell_suffix"; \
	scad="$(CELL_3D_DIR)/$$full_cell.scad"; \
	printf 'gds3xtrude %s (xy scale: %s, z scale: %s)\n' "$$full_cell" "$(GDS3XTRUDE_XY_SCALE)" "$(GDS3XTRUDE_Z_SCALE)"; \
	"$(GDS3XTRUDE_EXE)" -v --tech "$(GDS3XTRUDE_TECH)" --input "$$lib_gds" --cell "$$full_cell" --output "$$scad" $(GDS3XTRUDE_FLAGS); \
	apply_z_scale "$$scad" "$(GDS3XTRUDE_Z_SCALE)"; \
	"$(OPENSCAD_EXE)" "$$scad"

cell_glbs: require_container
	mkdir -p "$(CELL_3D_DIR)"
	for cell in INVx1 NAND2x1 AOI211x1 DFFHQNx1; do \
		full_cell="$${cell}_ASAP7_75t_R"; \
		"$(GDS3XTRUDE_EXE)" -v --tech "$(GDS3XTRUDE_TECH)" --input "$(ASAP7_LIB_GDS)" --cell "$$full_cell" --output "$(CELL_3D_DIR)/$$full_cell.scad" $(GDS3XTRUDE_FLAGS); \
		python3 "$(CONT_REPO)/scripts/scad_to_glb.py" "$(CELL_3D_DIR)/$${cell}_ASAP7_75t_R.scad" "$(CELL_3D_DIR)/$${cell}_ASAP7_75t_R.glb"; \
	done

3d_assets: require_container
	mkdir -p "$(CONT_REPO)/out/gds-assets/n_adder"
	if [ ! -f "$(CONT_MATERIAL)/openroad/work/results/$(PDK)/n_adder/base/6_final.gds" ]; then \
		$(MAKE) gds DESIGN=n_adder; \
	fi
	$(MAKE) glb DESIGN=n_adder
	cp "$(CONT_MATERIAL)/openroad/work/results/$(PDK)/n_adder/base/6_final.glb" "$(CONT_REPO)/out/gds-assets/n_adder/n_adder.glb"

clean: require_container
	rm -rf $(CONT_MATERIAL)/sim $(CONT_MATERIAL)/openroad/work
	rm -rf data/*.wav data/coef.svh data/y.txt data/x_music.txt data/y_exp.txt data/filter.png
