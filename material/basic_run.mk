SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

DESIGN       ?=
RTL          ?= rtl
TB           ?= basic
FLIST        ?=
SIM_GEN      ?=
TOP_TB       ?= tb_$(TB)_$(DESIGN)
SIM_MAX_TIME ?= 1s

CONT_REPO     ?= /repo
CONT_MATERIAL ?= $(CONT_REPO)
SIM_WORKDIR   ?= $(CONT_MATERIAL)/sim/$(DESIGN)
WAVE_VCD      ?= $(SIM_WORKDIR)/$(DESIGN).vcd

PDK              ?= asap7
ORFS_HOME        ?= /OpenROAD-flow-scripts
ORFS_FLOW_DIR    := $(ORFS_HOME)/flow
WORK_HOME        ?= $(CONT_MATERIAL)/openroad/work
DESIGN_CONFIG    ?= $(CONT_MATERIAL)/openroad/config.mk
RESULTS_DIR      := $(WORK_HOME)/results/$(PDK)/$(DESIGN)/base
FINAL_GDS        := $(RESULTS_DIR)/6_final.gds
REPORT_IMAGE_SCALE ?= 4

YOSYS_EXE    ?= yosys
OPENROAD_EXE ?= openroad
KLAYOUT_CMD  ?= klayout

GDS3XTRUDE_EXE       ?= gds3xtrude
OPENSCAD_EXE         ?= openscad
GDS3XTRUDE_TECH      ?= $(CONT_MATERIAL)/openroad/gds3xtrude/$(PDK).layerstack
GDS3XTRUDE_TOP       ?= $(DESIGN)
GDS3XTRUDE_OUT       ?= $(RESULTS_DIR)/6_final.scad
GDS3XTRUDE_GLB       ?= $(patsubst %.scad,%.glb,$(GDS3XTRUDE_OUT))
GDS3XTRUDE_SCALE     ?= 1.0
GDS3XTRUDE_XY_SCALE  ?= 1.0
GDS3XTRUDE_Z_SCALE   ?= $(GDS3XTRUDE_SCALE)
GDS3XTRUDE_FLAGS     ?= --scale $(GDS3XTRUDE_XY_SCALE)
GDS3XTRUDE_EXTRA_FLAGS ?=

PLATFORM_LYP := $(firstword \
	$(wildcard $(CONT_MATERIAL)/openroad/$(PDK).lyp) \
	$(wildcard $(ORFS_HOME)/flow/platforms/$(PDK)/KLayout/*.lyp) \
	$(wildcard $(ORFS_HOME)/flow/platforms/$(PDK)/*.lyp))

# VERILOG_FILES: leave empty to let DESIGN_CONFIG/parameters.mk derive from .f file (course designs),
# or set explicitly (assignments) to pass directly to ORFS.
VERILOG_FILES ?=

ifeq ($(FLIST),)
_SIM_SOURCES ?= "$(CONT_MATERIAL)/$(RTL)/$(DESIGN).sv" "$(CONT_MATERIAL)/tb/$(TOP_TB).sv"
else
_TB_IN_FLIST := $(shell grep -q "^tb/" "$(FLIST)" 2>/dev/null && echo 1 || echo 0)
ifeq ($(_TB_IN_FLIST),1)
_SIM_SOURCES ?= -f "$(FLIST)"
else
_SIM_SOURCES ?= -f "$(FLIST)" "$(CONT_MATERIAL)/tb/$(TOP_TB).sv"
endif
endif

_GDS_VERILOG_ARG = $(if $(VERILOG_FILES),VERILOG_FILES="$(VERILOG_FILES)")

SIM_TOOLS ?= verilator python3
GDS_TOOLS ?= yosys openroad klayout

.PHONY: check_tools compile sim gds show_layout show_3d sim_all gds_all

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
	verilator --binary --trace-vcd --timing --sv \
	    --top-module "$(TOP_TB)" \
	    -Mdir "$(SIM_WORKDIR)/obj_dir" \
	    "-DVCD_PATH=\"$(WAVE_VCD)\"" \
	    "-DSIM_MAX_TIME=$(SIM_MAX_TIME)" \
	    $(_SIM_SOURCES)

sim: compile
	"$(SIM_WORKDIR)/obj_dir/V$(TOP_TB)"

gds: check_tools
	mkdir -p "$(WORK_HOME)"
	rm -rf \
	    "$(WORK_HOME)/results/$(PDK)/$(DESIGN)" \
	    "$(WORK_HOME)/logs/$(PDK)/$(DESIGN)" \
	    "$(WORK_HOME)/reports/$(PDK)/$(DESIGN)" \
	    "$(WORK_HOME)/objects/$(PDK)/$(DESIGN)"
	REPORT_IMAGE_SCALE="$(REPORT_IMAGE_SCALE)" \
	$(MAKE) -C "$(ORFS_FLOW_DIR)" \
	    $(_GDS_VERILOG_ARG) \
	    DESIGN_NAME="$(DESIGN)" \
	    DESIGN_CONFIG="$(DESIGN_CONFIG)" \
	    WORK_HOME="$(WORK_HOME)" \
	    YOSYS_EXE="$(YOSYS_EXE)" \
	    OPENROAD_EXE="$(OPENROAD_EXE)" \
	    KLAYOUT_CMD="$(KLAYOUT_CMD)" \
	    gds

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
	for design_file in designs/*.f; do \
	    design_name="$${design_file##*/}"; \
	    design_name="$${design_name%.f}"; \
	    $(MAKE) sim DESIGN=$$design_name; \
	done

gds_all: check_tools
	for design_file in designs/*.f; do \
	    design_name="$${design_file##*/}"; \
	    design_name="$${design_name%.f}"; \
	    $(MAKE) gds DESIGN=$$design_name; \
	done
