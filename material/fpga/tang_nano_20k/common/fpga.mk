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
#  Per design we compile exactly: common/board_top.sv + the RTL in the shared
#  designs/*/<DESIGN>.f list + the one top_glue/*.sv. Testbench and VIP sources
#  from the shared list are omitted. board_top runs every design at 54 MHz
#  from the board's 27 MHz crystal.
# ============================================================================

FPGA         ?= tang_nano_20k
FPGA_DIR     := $(MATERIAL_DIR)/fpga/$(FPGA)
FPGA_COMMON  := $(FPGA_DIR)/common
FPGA_BUILD   := $(FPGA_DIR)/build/$(DESIGN)

# Tang Nano 20K = Gowin GW2AR-18. Device selects the exact part; family is the
# apicula database key. (Flashing lives in the top-level Makefile, on the host.)
GOWIN_DEVICE ?= GW2AR-LV18QN88C8/I7
GOWIN_FAMILY ?= GW2A-18C

# Place-and-route timing target ONLY - this does NOT set the clock. The system
# clock is the rPLL in common/board_top.sv (54 MHz), and CLKS_PER_BIT in each
# top_glue is derived from that, not from here.
#
# Deliberately 2x the real 54 MHz: nextpnr's Gowin model prices inter-tile carry
# routing at 0 ns, so its Fmax overestimates silicon by ~2x. It reported 180 MHz
# for sys_fir_filter, which still corrupted data at 108 MHz. Over-constraining
# turns that optimism into real margin.
PNR_TARGET_HZ := 108000000

# Locate the design's glue. FLIST is the canonical list resolved by
# material/Makefile from material/designs/.
FPGA_GLUE    = $(firstword $(wildcard $(FPGA_DIR)/top_glue/$(DESIGN).sv $(FPGA_DIR)/top_glue/*/$(DESIGN).sv))
FPGA_FLIST   = $(MATERIAL_DIR)/$(FLIST)
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
	test -f "$(FPGA_FLIST)" || { echo "No shared flist for DESIGN='$(DESIGN)' in $(MATERIAL_DIR)/designs/" >&2; exit 1; }
	mkdir -p "$(FPGA_BUILD)"
	# Shared flist paths are relative to material/. Drop simulation-only files,
	# then append the board glue if the shared list does not already contain it.
	sources="$(FPGA_COMMON)/board_top.sv"
	while IFS= read -r f || [ -n "$$f" ]; do
	    f="$${f%%#*}"
	    f="$${f#"$${f%%[![:space:]]*}"}"
	    f="$${f%"$${f##*[![:space:]]}"}"
	    [ -n "$$f" ] || continue
	    case "$${f##*/}" in tb_*|vip_*) continue ;; esac
	    sources="$$sources $(MATERIAL_DIR)/$$f"
	done < "$(FPGA_FLIST)"
	case " $$sources " in
	    *" $(FPGA_GLUE) "*) ;;
	    *) sources="$$sources $(FPGA_GLUE)" ;;
	esac
	yosys -q -p "read_verilog -sv $(FPGA_INCS) $$sources; synth_gowin -top board_top -json $(FPGA_JSON)"
	nextpnr-himbaechel --device "$(GOWIN_DEVICE)" --vopt family=$(GOWIN_FAMILY) \
	    --vopt cst="$(FPGA_COMMON)/board.cst" --freq $$(($(PNR_TARGET_HZ) / 1000000)) \
	    --json "$(FPGA_JSON)" --write "$(FPGA_PNR)"
	gowin_pack -d $(GOWIN_FAMILY) -o "$(FPGA_FS)" "$(FPGA_PNR)"
	printf '\nBitstream: %s\n' "$(FPGA_FS)"

# Build every design that has a glue+flist (smoke test the whole set).
bitstream_all: check_fpga_tools
	for g in $(FPGA_DIR)/top_glue/*/*.sv; do \
	    d="$${g##*/}"; d="$${d%.sv}"; \
	    $(MAKE) bitstream DESIGN="$$d" FPGA=$(FPGA); \
	done
