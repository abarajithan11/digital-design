SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

USR       := $(shell id -un)
CONTAINER := orfs-$(USR)

DESIGN ?= adder
PLATFORM ?= asap7

HOST_MATERIAL := $(CURDIR)
CONT_REPO ?= /repo
CONT_MATERIAL := $(CONT_REPO)/material

OPENROAD_DIR := $(HOST_MATERIAL)/openroad
ORFS_FLOW_DIR := $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow
WORK_HOME    := $(CONT_MATERIAL)/openroad/work
DESIGN_CONFIG := $(CONT_MATERIAL)/openroad/config.mk
RESULTS_DIR  := $(WORK_HOME)/results/$(PLATFORM)/$(DESIGN)/base
FINAL_GDS    := $(RESULTS_DIR)/6_final.gds
REPORT_IMAGE_SCALE ?= 4
PLATFORM_LYP := $(firstword \
	$(wildcard $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/$(PLATFORM)/KLayout/*.lyp) \
	$(wildcard $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/$(PLATFORM)/*.lyp))

YOSYS_EXE    := /OpenROAD-flow-scripts/tools/install/yosys/bin/yosys
OPENROAD_EXE := /OpenROAD-flow-scripts/tools/install/OpenROAD/bin/openroad
KLAYOUT_CMD  := /usr/bin/klayout
TOP_TB       ?= tb_$(DESIGN)
SIM_WORKDIR  := $(CONT_MATERIAL)/sim/$(DESIGN)
WAVE_VCD     ?= $(SIM_WORKDIR)/$(DESIGN).vcd
WAVE_SAVE    ?= $(SIM_WORKDIR)/$(DESIGN).gtkw
WAVE_PNG     ?= $(SIM_WORKDIR)/$(DESIGN).png
WAVE_START   ?= auto
WAVE_END     ?= auto
WAVE_WINDOW  ?= 100000

.PHONY: require_container prepare gds sim gtkwave wave_png show_layout show_layout_orfs check_tools

require_container:
	test -f /.dockerenv

prepare: require_container
	mkdir -p "$(OPENROAD_DIR)/work"
	mkdir -p "$(CONT_MATERIAL)/sim"

gds: prepare
	$(MAKE) -C "$(ORFS_FLOW_DIR)" DESIGN_NAME="$(DESIGN)" DESIGN_CONFIG="$(DESIGN_CONFIG)" WORK_HOME="$(WORK_HOME)" YOSYS_EXE="$(YOSYS_EXE)" OPENROAD_EXE="$(OPENROAD_EXE)" KLAYOUT_CMD="$(KLAYOUT_CMD)" nuke
	REPORT_IMAGE_SCALE="$(REPORT_IMAGE_SCALE)" $(MAKE) -C "$(ORFS_FLOW_DIR)" DESIGN_NAME="$(DESIGN)" DESIGN_CONFIG="$(DESIGN_CONFIG)" WORK_HOME="$(WORK_HOME)" YOSYS_EXE="$(YOSYS_EXE)" OPENROAD_EXE="$(OPENROAD_EXE)" KLAYOUT_CMD="$(KLAYOUT_CMD)" gds

sim: prepare
	cd "$(CONT_MATERIAL)"
	verilator --binary --trace --timing --sv --top-module "$(TOP_TB)" -Mdir "$(SIM_WORKDIR)/obj_dir" -f "designs/$(DESIGN).f"
	"$(SIM_WORKDIR)/obj_dir/V$(TOP_TB)" +VCD="$(WAVE_VCD)"

gtkwave: sim
	cd "$(CONT_MATERIAL)"
	if [[ -f "$(WAVE_SAVE)" ]]; then
		gtkwave "$(WAVE_VCD)" "$(WAVE_SAVE)"
	else
		gtkwave "$(WAVE_VCD)"
	fi

wave_png: sim
	cd "$(CONT_MATERIAL)"
	mkdir -p "$(SIM_WORKDIR)"
	python3 "$(CONT_REPO)/scripts/vcd_to_png.py" \
		--vcd "$(WAVE_VCD)" \
		--png "$(WAVE_PNG)" \
		--start "$(WAVE_START)" \
		--end "$(WAVE_END)" \
		--window "$(WAVE_WINDOW)"
	echo "Wrote waveform image: $(WAVE_PNG)"

show_layout: require_container
	$(KLAYOUT_CMD) -l "$(PLATFORM_LYP)" "$(FINAL_GDS)"

show_layout_orfs: require_container
	$(MAKE) -C "$(ORFS_FLOW_DIR)" DESIGN_NAME="$(DESIGN)" DESIGN_CONFIG="$(DESIGN_CONFIG)" WORK_HOME="$(WORK_HOME)" YOSYS_EXE="$(YOSYS_EXE)" OPENROAD_EXE="$(OPENROAD_EXE)" KLAYOUT_CMD="$(KLAYOUT_CMD)" klayout_6_final.gds

check_tools: require_container
	echo "openroad: $$($(OPENROAD_EXE) -version 2>/dev/null | head -n 1)"
	echo "yosys: $$($(YOSYS_EXE) -V)"
	echo "klayout: $$(klayout -zz -v 2>&1 | head -n 1)"
	echo "verilator: $$(verilator --version)"
	echo "gtkwave: $$(gtkwave --version | head -n 1)"
