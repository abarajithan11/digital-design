# Common defaults for course designs. Override on the make command line if needed.

DESIGN ?= $(DESIGN_NAME)
COURSE_MATERIAL_DIR := $(abspath $(COURSE_CONFIG_DIR)/..)
design_flists := $(wildcard \
  $(COURSE_MATERIAL_DIR)/designs/$(DESIGN).f \
  $(COURSE_MATERIAL_DIR)/designs/*/$(DESIGN).f)
ifneq ($(words $(design_flists)),1)
$(error DESIGN='$(DESIGN)' must match exactly one file in designs/ or designs/*/; found: $(design_flists))
endif
design_flist := $(firstword $(design_flists))

design_files_raw := $(strip $(shell awk '{sub(/#.*/, ""); gsub(/^[ \t]+|[ \t]+$$/, ""); if (length) print $$0}' $(design_flist) 2>/dev/null))
export DESIGN_FILES ?= $(foreach f,$(design_files_raw),$(if $(filter /%,$(f)),$(f),$(COURSE_MATERIAL_DIR)/$(patsubst ./%,%,$(f))))

# ORFS uses only RTL sources; simulation flows can use full DESIGN_FILES.
export VERILOG_FILES ?= $(filter $(COURSE_MATERIAL_DIR)/rtl/%,$(DESIGN_FILES))
export TB_FILES ?= $(filter $(COURSE_MATERIAL_DIR)/tb/%,$(DESIGN_FILES))

# Tiny ASAP7 designs can floorplan into too few rows for the shared M5/M6 PDN
# geometry, so keep a small-design allowlist with a safer utilization target.
SMALL_DESIGNS := full_adder not_gate and_gate xor_gate flip_flop auto_light \
                 mux demux encoder decoder priority_encoder look_up_table

ifneq ($(filter $(DESIGN),$(SMALL_DESIGNS)),)

export DIE_AREA ?= 0 0 3.5 3.5
export CORE_AREA ?= 0.5 0.5 2.5 2.5
export DONT_BUFFER_PORTS ?= 1

else

export CORE_UTILIZATION ?= 50
export CORE_ASPECT_RATIO ?= 1
export CORE_MARGIN ?= 1

endif

export PLACE_DENSITY ?= 0.60
export SKIP_CTS_REPAIR_TIMING ?= 1
