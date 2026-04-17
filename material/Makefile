SHELL := /bin/bash
.ONESHELL:

USR       := $(shell id -un)
CONTAINER := orfs-$(USR)

DESIGN ?= adder
PLATFORM ?= asap7

HOST_MATERIAL := $(CURDIR)
CONT_MATERIAL := /material

OPENROAD_DIR := $(HOST_MATERIAL)/openroad
WORK_HOME    := $(CONT_MATERIAL)/openroad/work
DESIGN_CONFIG := $(CONT_MATERIAL)/openroad/config.mk
RESULTS_DIR  := $(WORK_HOME)/results/$(PLATFORM)/$(DESIGN)/base
FINAL_GDS    := $(RESULTS_DIR)/6_final.gds
LAYOUT_PNG   := $(RESULTS_DIR)/6_final_hires.png
PNG_SIZE    ?= 4096
KLAYOUT_EXPORT_SCRIPT := $(CONT_MATERIAL)/openroad/export_layout_png.rb
PLATFORM_LYP := $(firstword \
	$(wildcard $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/$(PLATFORM)/KLayout/*.lyp) \
	$(wildcard $(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow/platforms/$(PLATFORM)/*.lyp))

YOSYS_EXE    := /OpenROAD-flow-scripts/tools/install/yosys/bin/yosys
OPENROAD_EXE := /OpenROAD-flow-scripts/tools/install/OpenROAD/bin/openroad
KLAYOUT_CMD  := /usr/bin/klayout

.PHONY: require_container prepare gds export_layout_png show_layout show_layout_orfs check_tools

require_container:
	test -f /.dockerenv

prepare: require_container
	mkdir -p "$(OPENROAD_DIR)/work"

gds: prepare
	set -euo pipefail
	cd "$(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow"
	make DESIGN_NAME="$(DESIGN)" DESIGN_CONFIG="$(DESIGN_CONFIG)" WORK_HOME="$(WORK_HOME)" YOSYS_EXE="$(YOSYS_EXE)" OPENROAD_EXE="$(OPENROAD_EXE)" KLAYOUT_CMD="$(KLAYOUT_CMD)" nuke
	make DESIGN_NAME="$(DESIGN)" DESIGN_CONFIG="$(DESIGN_CONFIG)" WORK_HOME="$(WORK_HOME)" YOSYS_EXE="$(YOSYS_EXE)" OPENROAD_EXE="$(OPENROAD_EXE)" KLAYOUT_CMD="$(KLAYOUT_CMD)" gds
	$(MAKE) -C "$(CONT_MATERIAL)" export_layout_png DESIGN="$(DESIGN)" PLATFORM="$(PLATFORM)"

export_layout_png: require_container
	set -euo pipefail
	mkdir -p "$(dir $(LAYOUT_PNG))"
	GDS_FILE="$(FINAL_GDS)" LYP_FILE="$(PLATFORM_LYP)" PNG_FILE="$(LAYOUT_PNG)" PNG_SIZE="$(PNG_SIZE)" \
		$(KLAYOUT_CMD) -zz -b -r "$(KLAYOUT_EXPORT_SCRIPT)"
	echo "Exported high-resolution layout image: $(LAYOUT_PNG)"

show_layout: require_container
	set -euo pipefail
	$(KLAYOUT_CMD) -l "$(PLATFORM_LYP)" "$(FINAL_GDS)"

show_layout_orfs: require_container
	set -euo pipefail
	cd "$(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow"
	make DESIGN_NAME="$(DESIGN)" DESIGN_CONFIG="$(DESIGN_CONFIG)" WORK_HOME="$(WORK_HOME)" YOSYS_EXE="$(YOSYS_EXE)" OPENROAD_EXE="$(OPENROAD_EXE)" KLAYOUT_CMD="$(KLAYOUT_CMD)" klayout_6_final.gds

check_tools: require_container
	set -euo pipefail
	echo "openroad: $$($(OPENROAD_EXE) -version 2>/dev/null | head -n 1)"
	echo "yosys: $$($(YOSYS_EXE) -V)"
	echo "klayout: $$(klayout -zz -v 2>&1 | head -n 1)"
	echo "verilator: $$(verilator --version)"
	echo "gtkwave: $$(gtkwave --version | head -n 1)"
