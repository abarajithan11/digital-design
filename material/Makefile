SHELL := /bin/bash

USR       := $(shell id -un)
CONTAINER := orfs-$(USR)

DESIGN ?= adder
PLATFORM ?= asap7

HOST_MATERIAL := $(CURDIR)
CONT_MATERIAL := /material

OPENROAD_DIR := $(HOST_MATERIAL)/openroad
ORFS_DIR     := $(OPENROAD_DIR)/OpenROAD-flow-scripts
WORK_HOME    := $(CONT_MATERIAL)/openroad/work
DESIGN_CONFIG := $(CONT_MATERIAL)/openroad/config.mk

YOSYS_EXE    := /OpenROAD-flow-scripts/tools/install/yosys/bin/yosys
OPENROAD_EXE := /OpenROAD-flow-scripts/tools/install/OpenROAD/bin/openroad
KLAYOUT_CMD  := /usr/bin/klayout

.PHONY: require_container prepare gds show_layout check_tools

require_container:
	test -f /.dockerenv

prepare: require_container
	test -f "$(ORFS_DIR)/flow/Makefile"
	mkdir -p "$(OPENROAD_DIR)/work"

gds: prepare
	/bin/bash -lc '\
		set -euo pipefail && \
		cd "$(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow" && \
		make DESIGN_NAME="$(DESIGN)" DESIGN_CONFIG="$(DESIGN_CONFIG)" WORK_HOME="$(WORK_HOME)" YOSYS_EXE="$(YOSYS_EXE)" OPENROAD_EXE="$(OPENROAD_EXE)" KLAYOUT_CMD="$(KLAYOUT_CMD)" nuke && \
		make DESIGN_NAME="$(DESIGN)" DESIGN_CONFIG="$(DESIGN_CONFIG)" WORK_HOME="$(WORK_HOME)" YOSYS_EXE="$(YOSYS_EXE)" OPENROAD_EXE="$(OPENROAD_EXE)" KLAYOUT_CMD="$(KLAYOUT_CMD)" gds \
	'

show_layout: require_container
	/bin/bash -lc '\
		set -euo pipefail && \
		cd "$(CONT_MATERIAL)/openroad/OpenROAD-flow-scripts/flow" && \
		make DESIGN_NAME="$(DESIGN)" DESIGN_CONFIG="$(DESIGN_CONFIG)" WORK_HOME="$(WORK_HOME)" YOSYS_EXE="$(YOSYS_EXE)" OPENROAD_EXE="$(OPENROAD_EXE)" KLAYOUT_CMD="$(KLAYOUT_CMD)" klayout_6_final.gds \
	'

check_tools: require_container
	/bin/bash -lc '\
		set -euo pipefail && \
		echo "openroad: $$($(OPENROAD_EXE) -version 2>/dev/null | head -n 1)" && \
		echo "yosys: $$($(YOSYS_EXE) -V)" && \
		echo "klayout: $$(klayout -zz -v 2>&1 | head -n 1)" && \
		echo "verilator: $$(verilator --version)" && \
		echo "gtkwave: $$(gtkwave --version | head -n 1)" \
	'
