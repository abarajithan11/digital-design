# Common defaults for course designs. Override on the make command line if needed.

design_flist := /repo/material/designs/$(DESIGN_NAME).f

design_files_raw := $(strip $(shell awk '{sub(/#.*/, ""); gsub(/^[ \t]+|[ \t]+$$/, ""); if (length) print $$0}' $(design_flist) 2>/dev/null))
export DESIGN_FILES ?= $(foreach f,$(design_files_raw),$(if $(filter /%,$(f)),$(f),/repo/material/$(patsubst ./%,%,$(f))))

# ORFS uses only RTL sources; simulation flows can use full DESIGN_FILES.
export VERILOG_FILES ?= $(filter /repo/material/rtl/%,$(DESIGN_FILES))
export TB_FILES ?= $(filter /repo/material/tb/%,$(DESIGN_FILES))

# Tiny ASAP7 designs can floorplan into too few rows for the shared M5/M6 PDN
# geometry, so keep a small-design allowlist with a safer utilization target.
SMALL_DESIGNS := full_adder

export CORE_UTILIZATION ?= $(if $(filter $(DESIGN_NAME),$(SMALL_DESIGNS)),15,50)
export CORE_ASPECT_RATIO ?= 1
export CORE_MARGIN ?= 1
export PLACE_DENSITY ?= 0.60
