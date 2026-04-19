# Common defaults for course designs. Override on the make command line if needed.

design_flist := /repo/material/designs/$(DESIGN_NAME).f

design_files_raw := $(strip $(shell awk '{sub(/#.*/, ""); gsub(/^[ \t]+|[ \t]+$$/, ""); if (length) print $$0}' $(design_flist) 2>/dev/null))
export DESIGN_FILES ?= $(foreach f,$(design_files_raw),$(if $(filter /%,$(f)),$(f),/repo/material/$(patsubst ./%,%,$(f))))

# ORFS uses only RTL sources; simulation flows can use full DESIGN_FILES.
export VERILOG_FILES ?= $(filter /repo/material/rtl/%,$(DESIGN_FILES))
export TB_FILES ?= $(filter /repo/material/tb/%,$(DESIGN_FILES))

# ASAP7's shared PDN script uses fixed M5/M6 strap geometry. Tiny designs can
# floorplan into just a few rows, which makes the core too short for those
# straps even when synthesis area looks small. A lower common default keeps
# small teaching examples like `full_adder` routable without per-design knobs.
export CORE_UTILIZATION ?= 15
export CORE_ASPECT_RATIO ?= 1
export CORE_MARGIN ?= 1
export PLACE_DENSITY ?= 0.60
