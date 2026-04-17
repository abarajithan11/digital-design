# Common defaults for course designs. Override on the make command line if needed.

design_flist := /repo/material/designs/$(DESIGN_NAME).f

design_files_raw := $(strip $(shell awk '{sub(/#.*/, ""); gsub(/^[ \t]+|[ \t]+$$/, ""); if (length) print $$0}' $(design_flist) 2>/dev/null))
export DESIGN_FILES ?= $(foreach f,$(design_files_raw),$(if $(filter /%,$(f)),$(f),/repo/material/$(patsubst ./%,%,$(f))))

# ORFS uses only RTL sources; simulation flows can use full DESIGN_FILES.
export VERILOG_FILES ?= $(filter /repo/material/rtl/%,$(DESIGN_FILES))
export TB_FILES ?= $(filter /repo/material/tb/%,$(DESIGN_FILES))

# 70% was too aggressive for tiny ASAP7 examples like `adder`, where
# implementation overhead after synthesis can significantly exceed the
# raw cell-area estimate used for floorplanning.
export CORE_UTILIZATION ?= 50
export CORE_ASPECT_RATIO ?= 1
export CORE_MARGIN ?= 1
export PLACE_DENSITY ?= 0.60
