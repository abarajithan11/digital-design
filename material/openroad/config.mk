export PLATFORM = asap7

COURSE_CONFIG_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

include $(COURSE_CONFIG_DIR)/parameters.mk

export SDC_FILE = $(COURSE_CONFIG_DIR)/constraint.sdc
export PRE_FINAL_REPORT_TCL = $(COURSE_CONFIG_DIR)/report_image.tcl
export VERILOG_INCLUDE_DIRS = $(abspath $(COURSE_CONFIG_DIR)/..)