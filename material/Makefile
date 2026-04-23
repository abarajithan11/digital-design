SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

USR       := $(shell id -un)
CONTAINER := orfs-$(USR)

DESIGN ?= alu
PLATFORM ?= asap7

HOST_MATERIAL := $(CURDIR)
CONT_REPO ?= /repo
CONT_MATERIAL := $(CONT_REPO)/material

ORFS_FLOW_DIR := $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow
WORK_HOME    := $(CONT_MATERIAL)/openroad/work
DESIGN_CONFIG := $(CONT_MATERIAL)/openroad/config.mk
RESULTS_DIR  := $(WORK_HOME)/results/$(PLATFORM)/$(DESIGN)/base
FINAL_GDS    := $(RESULTS_DIR)/6_final.gds
REPORT_IMAGE_SCALE ?= 4
PLATFORM_LYP := $(firstword \
	$(wildcard $(CONT_MATERIAL)/openroad/$(PLATFORM).lyp) \
	$(wildcard $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/$(PLATFORM)/KLayout/*.lyp) \
	$(wildcard $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/$(PLATFORM)/*.lyp))

YOSYS_EXE        ?= yosys
OPENROAD_EXE     ?= openroad
KLAYOUT_CMD      ?= klayout
GDS3XTRUDE_EXE   ?= gds3xtrude
GDS3XTRUDE_TECH  ?= $(CONT_MATERIAL)/openroad/gds3xtrude/$(PLATFORM).layerstack
GDS3XTRUDE_TOP   ?= $(DESIGN)
GDS3XTRUDE_OUT   ?= $(RESULTS_DIR)/6_final.scad
GDS3XTRUDE_GLB   ?= $(patsubst %.scad,%.glb,$(GDS3XTRUDE_OUT))
GDS3XTRUDE_FLAGS ?=
ASAP7_LIB_GDS    := $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/asap7/gds/asap7sc7p5t_28_R_220121a.gds
CELL ?=
CELL_3D_DIR      := $(CONT_MATERIAL)/openroad/work/results/cell_3d
SHOW ?= 1

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

.PHONY: require_container prepare gds sim sim_all gds_all gtkwave wave_svg clean show_layout show_3d show_3d_cell week1_cell_glbs scad_model web_model check_tools

require_container:
	test -f /.dockerenv

prepare: require_container
	test -n "$(DESIGN)"
	mkdir -p "$(WORK_HOME)"
	mkdir -p "$(CONT_MATERIAL)/sim"
	mkdir -p $(CELL_3D_DIR)

gds: prepare
	if [ -f "$(SIM_GEN)" ]; then python3 "$(SIM_GEN)"; fi
	rm -rf "$(WORK_HOME)/results/$(PLATFORM)/$(DESIGN)"
	rm -rf "$(WORK_HOME)/logs/$(PLATFORM)/$(DESIGN)"
	rm -rf "$(WORK_HOME)/reports/$(PLATFORM)/$(DESIGN)"
	rm -rf "$(WORK_HOME)/objects/$(PLATFORM)/$(DESIGN)"
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

show_3d: require_container
	echo "DISPLAY=$${DISPLAY:-<unset>}"
	"$(GDS3XTRUDE_EXE)" -v --tech "$(GDS3XTRUDE_TECH)" --input "$(FINAL_GDS)" --cell "$(GDS3XTRUDE_TOP)" --output "$(GDS3XTRUDE_OUT)" --view $(GDS3XTRUDE_FLAGS)

show_3d_cell: require_container
	mkdir -p "$(CELL_3D_DIR)"
	if [ -z "$(CELL)" ]; then \
		printf '\n%s\n\n' "Possible values for CELL:"; \
		strings "$(ASAP7_LIB_GDS)" | grep '_ASAP7_75t_R$$' | sed 's/_ASAP7_75t_R$$//' | sort -u | paste -sd '\t' -; \
		exit 0; \
	fi
	full_cell="$(CELL)_ASAP7_75t_R"
	if [ "$(SHOW)" = "1" ]; then \
		"$(GDS3XTRUDE_EXE)" -v --tech "$(GDS3XTRUDE_TECH)" --input "$(ASAP7_LIB_GDS)" --cell "$$full_cell" --output "$(CELL_3D_DIR)/$$full_cell.scad" --view $(GDS3XTRUDE_FLAGS); \
	else \
		"$(GDS3XTRUDE_EXE)" -v --tech "$(GDS3XTRUDE_TECH)" --input "$(ASAP7_LIB_GDS)" --cell "$$full_cell" --output "$(CELL_3D_DIR)/$$full_cell.scad" $(GDS3XTRUDE_FLAGS); \
	fi

week1_cell_glbs: require_container
	mkdir -p "$(CELL_3D_DIR)"
	for cell in INVx1 NAND2x1 AOI211x1 DFFHQNx1; do \
		$(MAKE) show_3d_cell CELL="$$cell" SHOW="$(SHOW)"; \
		python3 "$(CONT_REPO)/scripts/scad_to_glb.py" "$(CELL_3D_DIR)/$${cell}_ASAP7_75t_R.scad" "$(CELL_3D_DIR)/$${cell}_ASAP7_75t_R.glb"; \
	done

scad_model: prepare
	test -f "$(FINAL_GDS)"
	"$(GDS3XTRUDE_EXE)" -v --tech "$(GDS3XTRUDE_TECH)" --input "$(FINAL_GDS)" --cell "$(GDS3XTRUDE_TOP)" --output "$(GDS3XTRUDE_OUT)" $(GDS3XTRUDE_FLAGS)

web_model: scad_model
	python3 "$(CONT_REPO)/scripts/scad_to_glb.py" "$(GDS3XTRUDE_OUT)" "$(GDS3XTRUDE_GLB)"
	printf '%s\n' "$(GDS3XTRUDE_GLB)"

check_tools: require_container
	echo "openroad: $$($(OPENROAD_EXE) -version 2>/dev/null | head -n 1)"
	echo "yosys: $$($(YOSYS_EXE) -V)"
	echo "klayout: $$(klayout -zz -v 2>&1 | head -n 1)"
	echo "verilator: $$(verilator --version)"
	echo "gtkwave: $$(gtkwave --version | head -n 1)"

clean: require_container
	rm -rf $(CONT_MATERIAL)/sim $(CONT_MATERIAL)/openroad/work
	rm -rf data/*.wav data/coef.svh data/y.txt data/x_music.txt data/y_exp.txt data/filter.png
