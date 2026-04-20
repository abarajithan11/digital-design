# Common defaults for course designs. Override on the make command line if needed.

DESIGN_NUMBERED := $(if $(strip $(DESIGN_NICKNAME)),$(DESIGN_NICKNAME),$(DESIGN_NAME))
design_flist := /repo/material/designs/$(DESIGN_NUMBERED).f

design_files_raw := $(strip $(shell awk '{sub(/#.*/, ""); gsub(/^[ \t]+|[ \t]+$$/, ""); if (length) print $$0}' $(design_flist) 2>/dev/null))
export DESIGN_FILES ?= $(foreach f,$(design_files_raw),$(if $(filter /%,$(f)),$(f),/repo/material/$(patsubst ./%,%,$(f))))

# ORFS uses only RTL sources; simulation flows can use full DESIGN_FILES.
export VERILOG_FILES ?= $(filter /repo/material/rtl/%,$(DESIGN_FILES))
export TB_FILES ?= $(filter /repo/material/tb/%,$(DESIGN_FILES))

# Tiny ASAP7 designs can floorplan into too few rows for the shared M5/M6 PDN
# geometry, so keep a small-design allowlist with a safer utilization target.
SMALL_DESIGNS := full_adder not_gate flip_flop

ifneq ($(filter $(DESIGN_NAME),$(SMALL_DESIGNS)),)

export DIE_AREA ?= 0 0 20 20
export CORE_AREA ?= 2 2 18 18

else

export CORE_UTILIZATION ?= $(if $(filter $(DESIGN_NAME),$(SMALL_DESIGNS)),15,50)
export CORE_ASPECT_RATIO ?= 1
export CORE_MARGIN ?= 1

endif

export PLACE_DENSITY ?= 0.60
