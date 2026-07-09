SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

USR          := $(shell id -un)
UID          := $(shell id -u)
GID          := $(shell id -g)
HOST_ARCH    := $(shell uname -m)
DEFAULT_ARCH := $(if $(filter x86_64 amd64,$(HOST_ARCH)),amd64,$(if $(filter aarch64 arm64,$(HOST_ARCH)),arm64,unsupported))
ARCH         ?= $(DEFAULT_ARCH)
ifneq ($(filter $(ARCH),amd64 arm64),$(ARCH))
$(error Unsupported ARCH '$(ARCH)' from uname -m='$(HOST_ARCH)'; set ARCH=amd64 or ARCH=arm64)
endif
ORFS_REF     ?= 26Q2
NUM_THREADS  ?= $(shell nproc)
PUBLISH_IMAGE := ghcr.io/ucsd-cse140-s126/digital-design-$(ARCH)
IMAGE        ?= $(PUBLISH_IMAGE):latest
ARM64_BASE_IMAGE := ghcr.io/ucsd-cse140-s126/digital-design-arm64-base:$(ORFS_REF)
GHCR_USER    ?=

HOST_REPO     := $(CURDIR)
HOST_MATERIAL := $(HOST_REPO)/material
CONTAINER     ?= orfs-$(USR)
CONT_REPO     := /repo
CONT_MATERIAL := $(CONT_REPO)/material

include basic_docker.mk

FRESH        ?= 0
SIM_MAX_TIME ?= 1s
DESIGN_FILES := $(wildcard material/designs/*.f material/designs/*/*.f)
DESIGNS := $(sort $(basename $(notdir $(DESIGN_FILES))))

.PHONY: image-scratch publish generate_outputs build_pages site serve \
        sim_output sim_outputs_all gds_output gds_outputs_all gds_glb_assets 3d_assets scratch

scratch: kill image-scratch start

# For ARCH=arm64, OpenROAD-flow-scripts is compiled from source (Dockerfile.arm64-base)
# since openroad/orfs is amd64-only. That base is slow (~hours) to build, so it's
# reused from $(ARM64_BASE_IMAGE) (registry or local) when available.
image-scratch:
ifeq ($(ARCH),arm64)
	if docker manifest inspect $(ARM64_BASE_IMAGE) >/dev/null 2>&1; then \
		echo "Using published arm64 base image $(ARM64_BASE_IMAGE)"; \
	elif docker image inspect $(ARM64_BASE_IMAGE) >/dev/null 2>&1; then \
		echo "Using local arm64 base image $(ARM64_BASE_IMAGE)"; \
	else \
		docker buildx build \
			--platform linux/arm64 \
			-f Dockerfile.arm64-base \
			--build-arg ORFS_REF=$(ORFS_REF) \
			--build-arg NUM_THREADS=$(NUM_THREADS) \
			-t $(ARM64_BASE_IMAGE) \
			--load .; \
	fi
	docker build \
		-f Dockerfile \
		--build-arg ORFS_BASE_IMAGE=$(ARM64_BASE_IMAGE) \
		--build-arg INSTALL_GUI=1 \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		--build-arg USERNAME=$(USR) \
		--build-arg CONT_ROOT=$(CONT_MATERIAL) \
		-t $(IMAGE) .
else
	docker build \
		-f Dockerfile \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		--build-arg USERNAME=$(USR) \
		--build-arg CONT_ROOT=$(CONT_MATERIAL) \
		-t $(IMAGE) .
endif

publish:
	if [ -n "$${GHCR_TOKEN:-}" ]; then \
		test -n "$(GHCR_USER)" || { echo "Set GHCR_USER=<github-user> when GHCR_TOKEN is set"; exit 1; }; \
		printf '%s' "$$GHCR_TOKEN" | docker login ghcr.io -u "$(GHCR_USER)" --password-stdin; \
	else \
		echo "GHCR_TOKEN not set; using existing docker login credentials for ghcr.io"; \
	fi
	docker push $(IMAGE)
ifeq ($(ARCH),arm64)
	if ! docker manifest inspect $(ARM64_BASE_IMAGE) >/dev/null 2>&1 && docker image inspect $(ARM64_BASE_IMAGE) >/dev/null 2>&1; then \
		docker push $(ARM64_BASE_IMAGE); \
	fi
endif

generate_outputs:
ifeq ($(FRESH),1)
	$(MAKE) sim_outputs_all IMAGE="$(IMAGE)"
	$(MAKE) gds_outputs_all IMAGE="$(IMAGE)"
endif
	python3 scripts/generate_outputs.py

build_pages:
	rm -rf site
	sphinx-build -a -b html docs site

site: generate_outputs build_pages

serve: site
	python3 -m http.server 8000 --directory site

sim_output:
	test -n "$(DESIGN)"
	mkdir -p out/sim out/sim-assets/$(DESIGN)
	if $(MAKE) run CMD="make sim wave_svg DESIGN=$(DESIGN) SIM_MAX_TIME=$(SIM_MAX_TIME)" IMAGE="$(IMAGE)"; then \
		fst="material/sim/$(DESIGN)/$(DESIGN).fst"; \
		svg="material/sim/$(DESIGN)/$(DESIGN)_short.svg"; \
		[ -f "$$fst" ] && cp "$$fst" "out/sim-assets/$(DESIGN)/$(DESIGN).fst" || true; \
		[ -f "$$svg" ] && cp "$$svg" "out/sim-assets/$(DESIGN)/$(DESIGN)_short.svg" || true; \
		printf '%s\n' "pass" > "out/sim/$(DESIGN).status"; \
	else \
		printf '%s\n' "fail" > "out/sim/$(DESIGN).status"; \
		exit 1; \
	fi

sim_outputs_all:
	rm -rf out/sim out/sim-assets; \
	mkdir -p out/sim; \
	fail=0; \
	for design in $(DESIGNS); do \
		printf '\n==== [sim] %s ====\n' "$$design"; \
		if ! $(MAKE) sim_output DESIGN=$$design IMAGE="$(IMAGE)"; then \
			printf -- '---- [sim] %s: FAIL ----\n' "$$design"; \
			fail=1; \
		else \
			printf -- '---- [sim] %s: PASS ----\n' "$$design"; \
		fi; \
	done; \
	: > out/sim/status.tsv; \
	for design in $(DESIGNS); do \
		[ -f "out/sim/$$design.status" ] && \
			printf '%s\t%s\n' "$$design" "$$(cat out/sim/$$design.status)" >> out/sim/status.tsv || true; \
	done; \
	printf '\n==== [sim] summary ====\n'; cat out/sim/status.tsv; \
	exit $$fail

gds_output:
	test -n "$(DESIGN)"
	mkdir -p "out/gds-assets/$(DESIGN)"
	rtl_top="$$( $(MAKE) --no-print-directory -s -C material print_rtl_top DESIGN="$(DESIGN)" | tail -n 1 | tr -d '\r' )"; \
	case "$$rtl_top" in \
		""|*[!A-Za-z0-9_$$]*) \
			printf 'Invalid RTL top for %s: <%s>\n' "$(DESIGN)" "$$rtl_top" >&2; \
			exit 1 ;; \
	esac; \
	printf 'Resolved design %s to RTL top %s\n' "$(DESIGN)" "$$rtl_top"; \
	if $(MAKE) run CMD="make gds DESIGN=$(DESIGN)" IMAGE="$(IMAGE)"; then \
		results_dir="material/openroad/work/results/asap7/$$rtl_top/base"; \
		logs_dir="material/openroad/work/logs/asap7/$$rtl_top/base"; \
		reports_dir="material/openroad/work/reports/asap7/$$rtl_top/base"; \
		artifact_status=0; \
		gds_src="$$results_dir/6_final.gds"; \
		if [ -f "$$gds_src" ]; then \
			cp "$$gds_src" "out/gds-assets/$(DESIGN)/$(DESIGN).gds"; \
		else \
			printf 'Missing GDS artifact: %s\n' "$$gds_src" >&2; \
			artifact_status=1; \
		fi; \
		rm -f "out/gds-assets/$(DESIGN)/logs.zip"; \
		if [ -d "$$logs_dir" ]; then \
			zip -qr "out/gds-assets/$(DESIGN)/logs.zip" "$$logs_dir"; \
		else \
			printf 'Missing GDS logs: %s\n' "$$logs_dir" >&2; \
			artifact_status=1; \
		fi; \
		for img in final_routing.webp final_placement.webp final_worst_path.webp; do \
			src="$$reports_dir/$$img"; \
			if [ -f "$$src" ]; then \
				cp "$$src" "out/gds-assets/$(DESIGN)/$$img"; \
			else \
				printf 'Missing layout image: %s\n' "$$src" >&2; \
				artifact_status=1; \
			fi; \
		done; \
		if [ "$$artifact_status" -eq 0 ]; then \
			printf '%s\n' "pass" > "out/gds-assets/$(DESIGN)/status.txt"; \
		else \
			printf '%s\n' "fail" > "out/gds-assets/$(DESIGN)/status.txt"; \
			status=1; \
		fi; \
	else \
		printf '%s\n' "fail" > "out/gds-assets/$(DESIGN)/status.txt"; \
		status=1; \
	fi; \
	exit $${status:-0}

gds_outputs_all:
	rm -rf out/gds-assets; \
	fail=0; \
	for design in $(DESIGNS); do \
		printf '\n==== [gds] %s ====\n' "$$design"; \
		if ! $(MAKE) gds_output DESIGN=$$design IMAGE="$(IMAGE)"; then \
			printf -- '---- [gds] %s: FAIL ----\n' "$$design"; \
			fail=1; \
		else \
			printf -- '---- [gds] %s: PASS ----\n' "$$design"; \
		fi; \
	done; \
	printf '\n==== [gds] summary ====\n'; \
	for design in $(DESIGNS); do \
		[ -f "out/gds-assets/$$design/status.txt" ] && \
			printf '%s\t%s\n' "$$design" "$$(cat out/gds-assets/$$design/status.txt)" || true; \
	done; \
	exit $$fail

gds_glb_assets:
	mkdir -p out/gds-assets/n_adder
	if [ ! -f material/openroad/work/results/asap7/n_adder/base/6_final.glb ]; then \
		if [ ! -f material/openroad/work/results/asap7/n_adder/base/6_final.gds ]; then \
			$(MAKE) run CMD="make gds DESIGN=n_adder" IMAGE="$(IMAGE)"; \
		fi; \
		$(MAKE) run CMD="make glb DESIGN=n_adder" IMAGE="$(IMAGE)"; \
	fi
	cp material/openroad/work/results/asap7/n_adder/base/6_final.glb out/gds-assets/n_adder/n_adder.glb

3d_assets:
	$(MAKE) run CMD="make 3d_assets" IMAGE="$(IMAGE)"
