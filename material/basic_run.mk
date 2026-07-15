SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

DESIGN       ?=
RTL          ?= rtl
TB           ?= basic
FLIST        ?=
SIM_GEN      ?=
TOP_TB       ?= tb_$(TB)_$(DESIGN)
TOP_RTL      ?= $(DESIGN)
SIM_MAX_TIME ?= 1s
VERILATOR_EXTRA_FLAGS ?=

CONT_REPO     ?= /repo
CONT_MATERIAL ?= $(CONT_REPO)
# Build sources/outputs resolve relative to the directory make runs in, so the
# same logic works whether the material is the repo root (assignment / student
# template) or a subdir (digital-design/material), and from the staff monorepo
# you can cd into any of them and run make. CONT_MATERIAL/CONT_REPO above are
# only the container mount/-w targets used by basic_docker.mk.
MATERIAL_DIR  ?= $(CURDIR)
SIM_WORKDIR   ?= $(MATERIAL_DIR)/sim/$(DESIGN)
WAVE_FST      ?= $(SIM_WORKDIR)/$(DESIGN).fst

PDK              ?= asap7
ORFS_HOME        ?= /OpenROAD-flow-scripts
ORFS_FLOW_DIR    := $(ORFS_HOME)/flow
WORK_HOME        ?= $(MATERIAL_DIR)/openroad/work
DESIGN_CONFIG    ?= $(MATERIAL_DIR)/openroad/config.mk
RESULTS_DIR      := $(WORK_HOME)/results/$(PDK)/$(TOP_RTL)/base
FINAL_GDS        := $(RESULTS_DIR)/6_final.gds
SYNTH_NETLIST    := $(RESULTS_DIR)/1_2_yosys.v
FINAL_NETLIST    := $(RESULTS_DIR)/6_final.v
REPORT_IMAGE_SCALE ?= 4
USE_BASIC_GATES    ?= 0
BASIC_GATES_DONT_USE_CELLS ?= *x1p*_ASAP7* *xp*_ASAP7* SDF* ICG* OA21* OAI21*
NETLIST_VIEWER ?= pygmentize -l systemverilog -f terminal256

YOSYS_EXE    ?= yosys
OPENROAD_EXE ?= openroad
KLAYOUT_CMD  ?= klayout

GDS3XTRUDE_EXE       ?= gds3xtrude
OPENSCAD_EXE         ?= openscad
GDS3XTRUDE_TECH      ?= $(MATERIAL_DIR)/openroad/gds3xtrude/$(PDK).layerstack
GDS3XTRUDE_TOP       ?= $(TOP_RTL)
GDS3XTRUDE_OUT       ?= $(RESULTS_DIR)/6_final.scad
GDS3XTRUDE_GLB       ?= $(patsubst %.scad,%.glb,$(GDS3XTRUDE_OUT))
GDS3XTRUDE_SCALE     ?= 1.0
GDS3XTRUDE_XY_SCALE  ?= 1.0
GDS3XTRUDE_Z_SCALE   ?= $(GDS3XTRUDE_SCALE)
GDS3XTRUDE_FLAGS     ?= --scale $(GDS3XTRUDE_XY_SCALE)
GDS3XTRUDE_EXTRA_FLAGS ?=

PLATFORM_LYP := $(firstword \
	$(wildcard $(MATERIAL_DIR)/openroad/$(PDK).lyp) \
	$(wildcard $(ORFS_HOME)/flow/platforms/$(PDK)/KLayout/*.lyp) \
	$(wildcard $(ORFS_HOME)/flow/platforms/$(PDK)/*.lyp))

# VERILOG_FILES: leave empty to let DESIGN_CONFIG/parameters.mk derive from .f file (course designs),
# or set explicitly (assignments) to pass directly to ORFS.
VERILOG_FILES ?=

ifeq ($(FLIST),)
_SIM_SOURCES ?= "$(MATERIAL_DIR)/$(RTL)/$(DESIGN).sv" "$(MATERIAL_DIR)/tb/$(TOP_TB).sv"
else
_SIM_SOURCES ?= -f "$(FLIST)"
endif

_GDS_VERILOG_ARG = $(if $(VERILOG_FILES),VERILOG_FILES="$(VERILOG_FILES)")
_GDS_BASIC_GATES_ARG = $(if $(filter 1,$(USE_BASIC_GATES)),DONT_USE_CELLS="$(BASIC_GATES_DONT_USE_CELLS)")

SIM_TOOLS ?= verilator python3
GDS_TOOLS ?= yosys openroad klayout

.PHONY: check_tools compile sim gds show_syn_netlist show_final_nestlist \
        show_layout show_3d sim_all gds_all

check_tools:
	@missing=""; \
	for t in $(SIM_TOOLS) $(GDS_TOOLS); do \
	    command -v "$$t" >/dev/null 2>&1 || missing="$$missing $$t"; \
	done; \
	[ -z "$$missing" ] || { \
	    printf 'Missing tools:%s\n' "$$missing" >&2; \
	    printf 'Use the Docker container (make start / make run CMD="..."),\n' >&2; \
	    printf 'or ensure these tools are in PATH on your server.\n' >&2; \
	    exit 1; \
	}

compile: check_tools
	mkdir -p "$(SIM_WORKDIR)"
	if [ -n "$(SIM_GEN)" ] && [ -f "$(SIM_GEN)" ]; then python3 "$(SIM_GEN)"; fi
	verilator --binary --trace-fst --trace-structs --timing --sv --timescale 1ns/1ps \
	    $(VERILATOR_EXTRA_FLAGS) \
	    --preproc-token-limit 2000000 \
	    --top-module "$(TOP_TB)" \
	    -Mdir "$(SIM_WORKDIR)/obj_dir" \
	    "-DFST_PATH=\"$(WAVE_FST)\"" \
	    "-DSIM_MAX_TIME=$(SIM_MAX_TIME)" \
	    $(_SIM_SOURCES)

sim: compile
	"$(SIM_WORKDIR)/obj_dir/V$(TOP_TB)"

gds: check_tools
	if [ -n "$(SIM_GEN)" ] && [ -f "$(SIM_GEN)" ]; then \
	    ( cd "$(MATERIAL_DIR)" && python3 "$(abspath $(SIM_GEN))" ); \
	fi
	mkdir -p "$(WORK_HOME)"
	rm -rf \
	    "$(WORK_HOME)/results/$(PDK)/$(TOP_RTL)" \
	    "$(WORK_HOME)/logs/$(PDK)/$(TOP_RTL)" \
	    "$(WORK_HOME)/reports/$(PDK)/$(TOP_RTL)" \
	    "$(WORK_HOME)/objects/$(PDK)/$(TOP_RTL)"
	REPORT_IMAGE_SCALE="$(REPORT_IMAGE_SCALE)" \
	$(MAKE) -C "$(ORFS_FLOW_DIR)" \
	    $(_GDS_VERILOG_ARG) \
	    $(_GDS_BASIC_GATES_ARG) \
	    DESIGN_NAME="$(TOP_RTL)" \
	    DESIGN_CONFIG="$(DESIGN_CONFIG)" \
	    WORK_HOME="$(WORK_HOME)" \
	    YOSYS_EXE="$(YOSYS_EXE)" \
	    OPENROAD_EXE="$(OPENROAD_EXE)" \
	    KLAYOUT_CMD="$(KLAYOUT_CMD)" \
	    gds
	printf '\n\nSynthesis netlist: %s\nFinal netlist:     %s\n' \
	    "$(SYNTH_NETLIST)" "$(FINAL_NETLIST)"

show_syn_netlist:
	test -n "$(DESIGN)"
	test -f "$(SYNTH_NETLIST)"
	$(NETLIST_VIEWER) "$(SYNTH_NETLIST)"

show_final_nestlist:
	test -n "$(DESIGN)"
	test -f "$(FINAL_NETLIST)"
	$(NETLIST_VIEWER) "$(FINAL_NETLIST)"

show_layout: check_tools
	$(KLAYOUT_CMD) -l "$(PLATFORM_LYP)" "$(FINAL_GDS)"

show_3d: check_tools
	apply_z_scale() { \
	  local scad="$$1" z="$$2" tmp; \
	  case "$$z" in 1|1.0|1.00) return 0;; esac; \
	  tmp="$${scad}.tmp.$$$$"; \
	  { printf 'scale(v=[1,1,%.10f]){\n' "$$z"; sed 's/^/\t/' "$$scad"; printf '}\n'; } > "$$tmp"; \
	  mv "$$tmp" "$$scad"; \
	}; \
	echo "DISPLAY=$${DISPLAY:-<unset>}"; \
	"$(GDS3XTRUDE_EXE)" -v --tech "$(GDS3XTRUDE_TECH)" \
	    --input "$(FINAL_GDS)" --cell "$(GDS3XTRUDE_TOP)" \
	    --output "$(GDS3XTRUDE_OUT)" $(GDS3XTRUDE_FLAGS) $(GDS3XTRUDE_EXTRA_FLAGS); \
	apply_z_scale "$(GDS3XTRUDE_OUT)" "$(GDS3XTRUDE_Z_SCALE)"; \
	"$(OPENSCAD_EXE)" "$(GDS3XTRUDE_OUT)"

sim_all: check_tools
	for design_file in designs/*.f designs/*/*.f; do \
	    [ -f "$$design_file" ] || continue; \
	    design_name="$${design_file##*/}"; \
	    design_name="$${design_name%.f}"; \
	    $(MAKE) sim DESIGN=$$design_name; \
	done

gds_all: check_tools
	declare -A seen_tops=()
	for design_file in designs/*.f designs/*/*.f; do \
	    [ -f "$$design_file" ] || continue; \
	    design_name="$${design_file##*/}"; \
	    design_name="$${design_name%.f}"; \
	    rtl_top="$$($(MAKE) -s print_rtl_top DESIGN="$$design_name")"; \
	    if [ -n "$${seen_tops[$$rtl_top]:-}" ]; then \
	        printf 'Skipping %s: RTL top %s was already built by %s\n' \
	            "$$design_name" "$$rtl_top" "$${seen_tops[$$rtl_top]}"; \
	        continue; \
	    fi; \
	    seen_tops[$$rtl_top]="$$design_name"; \
	    $(MAKE) gds DESIGN=$$design_name; \
	done
