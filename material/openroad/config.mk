export PLATFORM = asap7

COURSE_CONFIG_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

include $(COURSE_CONFIG_DIR)/parameters.mk

export SDC_FILE = $(COURSE_CONFIG_DIR)/constraint.sdc
