SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

# ============================================================================
#  fpga.mk - Tang Nano 20K bitstream build (open-source apicula flow).
#
#  Included by material/Makefile; run INSIDE the container (that is where the
#  toolchain lives):
#     make bitstream DESIGN=full_adder            # -> build/<design>/<design>.fs
#  FPGA defaults to tang_nano_20k. Flash from the host with the top-level
#  program_fpga target after leaving the container.
#
#  Pipeline (tools live in the Docker image; see Dockerfile):
#     yosys synth_gowin  ->  nextpnr-himbaechel  ->  gowin_pack
#
#  Per design we compile exactly: common/board_top.sv + the one top_glue/*.sv +
#  the RTL listed in design/*/<DESIGN>.f (no testbenches). board_top runs every
#  design at 108 MHz from the board's 27 MHz crystal.
# ============================================================================

FPGA         ?= tang_nano_20k
FPGA_DIR     := $(MATERIAL_DIR)/fpga/$(FPGA)
FPGA_COMMON  := $(FPGA_DIR)/common
FPGA_BUILD   := $(FPGA_DIR)/build/$(DESIGN)

# Tang Nano 20K = Gowin GW2AR-18. Device selects the exact part; family is the
# apicula database key. (Flashing lives in the top-level Makefile, on the host.)
GOWIN_DEVICE ?= GW2AR-LV18QN88C8/I7
GOWIN_FAMILY ?= GW2A-18C

SYS_HZ       := 108000000

# Locate the design's glue and flist under either <cat>/ subdir (reference|system).
FPGA_GLUE    = $(firstword $(wildcard $(FPGA_DIR)/top_glue/$(DESIGN).sv $(FPGA_DIR)/top_glue/*/$(DESIGN).sv))
FPGA_FLIST   = $(firstword $(wildcard $(FPGA_DIR)/design/$(DESIGN).f $(FPGA_DIR)/design/*/$(DESIGN).f))
FPGA_INCS    = -I$(MATERIAL_DIR) -I$(FPGA_DIR)

FPGA_JSON    = $(FPGA_BUILD)/board_top.json
FPGA_PNR     = $(FPGA_BUILD)/board_top_pnr.json
FPGA_FS      = $(FPGA_BUILD)/$(DESIGN).fs

FPGA_TOOLS ?= yosys nextpnr-himbaechel gowin_pack

.PHONY: bitstream bitstream_all check_fpga_tools

check_fpga_tools:
	@missing=""; for t in $(FPGA_TOOLS); do command -v "$$t" >/dev/null 2>&1 || missing="$$missing $$t"; done; \
	[ -z "$$missing" ] || { \
	    printf 'Missing FPGA tools:%s\n' "$$missing" >&2; \
	    printf 'Run inside the Docker container (make enter, or make run CMD="...").\n' >&2; \
	    exit 1; }

bitstream: check_fpga_tools
	test -n "$(FPGA_GLUE)"  || { echo "No top_glue for DESIGN='$(DESIGN)' in $(FPGA_DIR)/top_glue/" >&2; exit 1; }
	test -n "$(FPGA_FLIST)" || { echo "No flist for DESIGN='$(DESIGN)' in $(FPGA_DIR)/design/"     >&2; exit 1; }
	mkdir -p "$(FPGA_BUILD)"
	# flist paths are relative to material/; strip comments/blanks and absolutize.
	dut=$$(sed 's/#.*//' "$(FPGA_FLIST)" | while read -r f; do [ -n "$$f" ] && printf '%s ' "$(MATERIAL_DIR)/$$f"; done)
	yosys -q -p "read_verilog -sv $(FPGA_INCS) $(FPGA_COMMON)/board_top.sv $(FPGA_GLUE) $$dut; synth_gowin -top board_top -json $(FPGA_JSON)"
	nextpnr-himbaechel --device "$(GOWIN_DEVICE)" --vopt family=$(GOWIN_FAMILY) \
	    --vopt cst="$(FPGA_COMMON)/board.cst" --freq $$(($(SYS_HZ) / 1000000)) \
	    --json "$(FPGA_JSON)" --write "$(FPGA_PNR)"
	gowin_pack -d $(GOWIN_FAMILY) -o "$(FPGA_FS)" "$(FPGA_PNR)"
	printf '\nBitstream: %s\n' "$(FPGA_FS)"

# Build every design that has a glue+flist (smoke test the whole set).
bitstream_all: check_fpga_tools
	for g in $(FPGA_DIR)/top_glue/*/*.sv; do \
	    d="$${g##*/}"; d="$${d%.sv}"; \
	    $(MAKE) bitstream DESIGN="$$d" FPGA=$(FPGA); \
	done
