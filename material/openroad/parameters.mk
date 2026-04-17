# Common defaults for course designs. Override on the make command line if needed.

rtl_sv := /material/rtl/$(DESIGN_NAME).sv
rtl_v := /material/rtl/$(DESIGN_NAME).v
rtl_flist := /material/rtl/$(DESIGN_NAME).flist

ifeq ($(wildcard $(rtl_flist)),)
export VERILOG_FILES ?= $(wildcard $(rtl_sv)) $(wildcard $(rtl_v))
else
export VERILOG_FILES ?= $(shell cat $(rtl_flist))
endif

# 70% was too aggressive for tiny ASAP7 examples like `adder`, where
# implementation overhead after synthesis can significantly exceed the
# raw cell-area estimate used for floorplanning.
export CORE_UTILIZATION ?= 50
export CORE_ASPECT_RATIO ?= 1
export CORE_MARGIN ?= 2
export PLACE_DENSITY ?= 0.60
