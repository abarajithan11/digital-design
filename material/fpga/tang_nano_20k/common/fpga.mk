SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

# ============================================================================
#  fpga.mk - Tang Nano 20K bitstream + programming (open-source apicula flow).
#
#  Included by material/Makefile. From material/ you can run:
#     make bitstream DESIGN=full_adder            # -> build/<design>/<design>.fs
#     make program   DESIGN=full_adder            # load to SRAM and run (volatile)
#     make program_flash DESIGN=full_adder        # write to flash (persists)
#  FPGA defaults to tang_nano_20k.
#
#  Pipeline (tools live in the Docker image; see Dockerfile):
#     yosys synth_gowin  ->  nextpnr-himbaechel  ->  gowin_pack  ->  openFPGALoader
#
#  Per design we compile exactly: common/board_top.sv + the one top_glue/*.sv +
#  the RTL listed in design/*/<DESIGN>.f (no testbenches). board_top runs on the
#  27 MHz crystal, or a 108 MHz rPLL when SYS_HZ says so (the UART designs).
# ============================================================================

FPGA         ?= tang_nano_20k
FPGA_DIR     := $(MATERIAL_DIR)/fpga/$(FPGA)
FPGA_COMMON  := $(FPGA_DIR)/common
FPGA_BUILD   := $(FPGA_DIR)/build/$(DESIGN)

# Tang Nano 20K = Gowin GW2AR-18. Device selects the exact part; family is the
# apicula database key; board is the openFPGALoader cable/board profile.
GOWIN_DEVICE ?= GW2AR-LV18QN88C8/I7
GOWIN_FAMILY ?= GW2A-18C
OFL_BOARD    ?= tangnano20k

# System clock. The UART link runs at 2 Mbaud through the Tang Nano's onboard
# USB-serial bridge, which needs a clean divisor: we PLL to 108 MHz so
# CLKS_PER_BIT = 108e6/2e6 = 54 exactly. Non-UART designs stay on the raw 27 MHz
# crystal (no PLL). board_top switches between crystal and PLL on this value.
_UART_DESIGNS := uart_echo uart_rx uart_tx sys_fir_filter
SYS_HZ       ?= $(if $(filter $(DESIGN),$(_UART_DESIGNS)),108000000,27000000)

# Locate the design's glue and flist under either <cat>/ subdir (reference|system).
FPGA_GLUE    = $(firstword $(wildcard $(FPGA_DIR)/top_glue/$(DESIGN).sv $(FPGA_DIR)/top_glue/*/$(DESIGN).sv))
FPGA_FLIST   = $(firstword $(wildcard $(FPGA_DIR)/design/$(DESIGN).f $(FPGA_DIR)/design/*/$(DESIGN).f))
FPGA_INCS    = -I$(MATERIAL_DIR) -I$(FPGA_DIR)

FPGA_JSON    = $(FPGA_BUILD)/board_top.json
FPGA_PNR     = $(FPGA_BUILD)/board_top_pnr.json
FPGA_FS      = $(FPGA_BUILD)/$(DESIGN).fs

FPGA_TOOLS      ?= yosys nextpnr-himbaechel gowin_pack
FPGA_PROG_TOOLS ?= openFPGALoader

.PHONY: bitstream program program_flash fpga_all check_fpga_tools check_prog_tools

check_fpga_tools:
	@missing=""; for t in $(FPGA_TOOLS); do command -v "$$t" >/dev/null 2>&1 || missing="$$missing $$t"; done; \
	[ -z "$$missing" ] || { \
	    printf 'Missing FPGA tools:%s\n' "$$missing" >&2; \
	    printf 'Run inside the Docker container (make enter, or make run CMD="...").\n' >&2; \
	    exit 1; }

check_prog_tools:
	@command -v $(FPGA_PROG_TOOLS) >/dev/null 2>&1 || { \
	    printf 'Missing %s. See fpga/%s/README for USB passthrough on WSL/macOS.\n' \
	        '$(FPGA_PROG_TOOLS)' '$(FPGA)' >&2; exit 1; }

bitstream: check_fpga_tools
	test -n "$(FPGA_GLUE)"  || { echo "No top_glue for DESIGN='$(DESIGN)' in $(FPGA_DIR)/top_glue/" >&2; exit 1; }
	test -n "$(FPGA_FLIST)" || { echo "No flist for DESIGN='$(DESIGN)' in $(FPGA_DIR)/design/"     >&2; exit 1; }
	mkdir -p "$(FPGA_BUILD)"
	# flist paths are relative to material/; strip comments/blanks and absolutize.
	dut=$$(sed 's/#.*//' "$(FPGA_FLIST)" | while read -r f; do [ -n "$$f" ] && printf '%s ' "$(MATERIAL_DIR)/$$f"; done)
	yosys -q -p "read_verilog -sv $(FPGA_INCS) $(FPGA_COMMON)/board_top.sv $(FPGA_GLUE) $$dut; chparam -set SYS_HZ $(SYS_HZ) board_top; synth_gowin -top board_top -json $(FPGA_JSON)"
	nextpnr-himbaechel --device "$(GOWIN_DEVICE)" --vopt family=$(GOWIN_FAMILY) \
	    --vopt cst="$(FPGA_COMMON)/board.cst" --freq $$(($(SYS_HZ) / 1000000)) \
	    --json "$(FPGA_JSON)" --write "$(FPGA_PNR)"
	gowin_pack -d $(GOWIN_FAMILY) -o "$(FPGA_FS)" "$(FPGA_PNR)"
	printf '\nBitstream: %s\n' "$(FPGA_FS)"

# OFL_FREQ lowers the JTAG clock. Over usbip (WSL) the default ~6 MHz is flaky
# ("TDO stuck at 0" / mpsse_read errors); 1 MHz is reliable. Harmless on native.
OFL_FREQ ?= 1000000

# Load to volatile SRAM (runs immediately, gone on power cycle).
program: check_prog_tools bitstream
	openFPGALoader -b $(OFL_BOARD) --freq $(OFL_FREQ) "$(FPGA_FS)"

# Write to onboard flash (persists across power cycles).
program_flash: check_prog_tools bitstream
	openFPGALoader -b $(OFL_BOARD) --freq $(OFL_FREQ) -f "$(FPGA_FS)"

# Build every design that has a glue+flist (smoke test the whole set).
fpga_all: check_fpga_tools
	for g in $(FPGA_DIR)/top_glue/*/*.sv; do \
	    d="$${g##*/}"; d="$${d%.sv}"; \
	    $(MAKE) bitstream DESIGN="$$d" FPGA=$(FPGA); \
	done
