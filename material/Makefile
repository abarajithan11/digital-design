SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

USR       := $(shell id -un)
CONTAINER := orfs-$(USR)

DESIGN ?= adder
DESIGN_BASE := $(DESIGN)
DESIGN_NUMBERED := $(basename $(notdir $(firstword $(wildcard designs/*_$(DESIGN_BASE).f))))
PLATFORM ?= asap7

HOST_MATERIAL := $(CURDIR)
CONT_REPO ?= /repo
CONT_MATERIAL := $(CONT_REPO)/material

ORFS_FLOW_DIR := $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow
WORK_HOME    := $(CONT_MATERIAL)/openroad/work
DESIGN_CONFIG := $(CONT_MATERIAL)/openroad/config.mk
RESULTS_DIR  := $(WORK_HOME)/results/$(PLATFORM)/$(DESIGN_NUMBERED)/base
FINAL_GDS    := $(RESULTS_DIR)/6_final.gds
REPORT_IMAGE_SCALE ?= 4
PLATFORM_LYP := $(firstword \
	$(wildcard $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/$(PLATFORM)/KLayout/*.lyp) \
	$(wildcard $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/$(PLATFORM)/*.lyp))

YOSYS_EXE    := /OpenROAD-flow-scripts/tools/install/yosys/bin/yosys
OPENROAD_EXE := /OpenROAD-flow-scripts/tools/install/OpenROAD/bin/openroad
KLAYOUT_CMD  := /usr/bin/klayout
TOP_TB       ?= tb_$(DESIGN_BASE)
SIM_WORKDIR  := $(CONT_MATERIAL)/sim/$(DESIGN_NUMBERED)
WAVE_VCD     ?= $(SIM_WORKDIR)/$(DESIGN_NUMBERED).vcd
WAVE_SAVE    ?= $(SIM_WORKDIR)/$(DESIGN_NUMBERED).gtkw
WAVE_SVG_SHORT ?= $(SIM_WORKDIR)/$(DESIGN_NUMBERED)_short.svg
WAVE_SVG_FULL  ?= $(SIM_WORKDIR)/$(DESIGN_NUMBERED)_full.svg
WAVE_START   ?= auto
WAVE_END     ?= auto
WAVE_SHORT_START ?= 0
WAVE_SHORT_END   ?= 10000
WAVE_WINDOW  ?= 65536
WAVE_SAMPLE  ?= 512
WAVE_HSCALE  ?= 1

.PHONY: require_container prepare gds sim sim_all gds_all gtkwave wave_svg clean show_layout check_tools

require_container:
	test -f /.dockerenv

prepare: require_container
	test -n "$(DESIGN_NUMBERED)"
	mkdir -p "$(WORK_HOME)"
	mkdir -p "$(CONT_MATERIAL)/sim"

gds: prepare
	$(MAKE) -C "$(ORFS_FLOW_DIR)" DESIGN_NAME="$(DESIGN_BASE)" DESIGN_NICKNAME="$(DESIGN_NUMBERED)" DESIGN_CONFIG="$(DESIGN_CONFIG)" WORK_HOME="$(WORK_HOME)" YOSYS_EXE="$(YOSYS_EXE)" OPENROAD_EXE="$(OPENROAD_EXE)" KLAYOUT_CMD="$(KLAYOUT_CMD)" nuke
	REPORT_IMAGE_SCALE="$(REPORT_IMAGE_SCALE)" $(MAKE) -C "$(ORFS_FLOW_DIR)" DESIGN_NAME="$(DESIGN_BASE)" DESIGN_NICKNAME="$(DESIGN_NUMBERED)" DESIGN_CONFIG="$(DESIGN_CONFIG)" WORK_HOME="$(WORK_HOME)" YOSYS_EXE="$(YOSYS_EXE)" OPENROAD_EXE="$(OPENROAD_EXE)" KLAYOUT_CMD="$(KLAYOUT_CMD)" gds

sim: prepare
	mkdir -p "$(SIM_WORKDIR)"
	cd "$(CONT_MATERIAL)"
	verilator --binary --trace-vcd --timing --sv --top-module "$(TOP_TB)" -Mdir "$(SIM_WORKDIR)/obj_dir" "-DVCD_PATH=\"$(WAVE_VCD)\"" -f "designs/$(DESIGN_NUMBERED).f"
	"$(SIM_WORKDIR)/obj_dir/V$(TOP_TB)"

gtkwave:
	cd "$(CONT_MATERIAL)"
	if [[ -f "$(WAVE_SAVE)" ]]; then
		gtkwave "$(WAVE_VCD)" "$(WAVE_SAVE)"
	else
		gtkwave "$(WAVE_VCD)"
	fi

wave_svg: sim
	cd "$(CONT_MATERIAL)"
	mkdir -p "$(SIM_WORKDIR)"
	python3 "$(CONT_REPO)/scripts/vcd_to_svg.py" \
		--vcd "$(WAVE_VCD)" \
		--svg "$(WAVE_SVG_SHORT)" \
		--start "$(WAVE_SHORT_START)" \
		--end "$(WAVE_SHORT_END)" \
		--window "$(WAVE_WINDOW)" \
		--sample-rate "$(WAVE_SAMPLE)" \
		--hscale "$(WAVE_HSCALE)"
	python3 "$(CONT_REPO)/scripts/vcd_to_svg.py" \
		--vcd "$(WAVE_VCD)" \
		--svg "$(WAVE_SVG_FULL)" \
		--start "$(WAVE_START)" \
		--end "$(WAVE_END)" \
		--window "$(WAVE_WINDOW)" \
		--sample-rate "$(WAVE_SAMPLE)" \
		--hscale "$(WAVE_HSCALE)"
	echo "Wrote waveform images: $(WAVE_SVG_SHORT) $(WAVE_SVG_FULL)"

sim_all:
	for design_file in designs/*.f; do \
		design_numbered="$${design_file##*/}"; \
		design_numbered="$${design_numbered%.f}"; \
		$(MAKE) sim DESIGN=$$design_numbered; \
	done

gds_all:
	for design_file in designs/*.f; do \
		design_numbered="$${design_file##*/}"; \
		design_numbered="$${design_numbered%.f}"; \
		$(MAKE) gds DESIGN=$$design_numbered; \
	done

clean: require_container
	rm -rf "$(CONT_MATERIAL)/sim" "$(CONT_MATERIAL)/openroad/work"

show_layout: require_container
	$(KLAYOUT_CMD) -l "$(PLATFORM_LYP)" "$(FINAL_GDS)"

check_tools: require_container
	echo "openroad: $$($(OPENROAD_EXE) -version 2>/dev/null | head -n 1)"
	echo "yosys: $$($(YOSYS_EXE) -V)"
	echo "klayout: $$(klayout -zz -v 2>&1 | head -n 1)"
	echo "verilator: $$(verilator --version)"
	echo "gtkwave: $$(gtkwave --version | head -n 1)"
