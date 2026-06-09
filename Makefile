SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

USR          := $(shell id -un)
UID          := $(shell id -u)
GID          := $(shell id -g)
PUBLISH_IMAGE := ghcr.io/ucsd-cse140-s126/digital-design
IMAGE        ?= $(PUBLISH_IMAGE):latest
GHCR_USER    ?=

HOST_REPO     := $(CURDIR)
HOST_MATERIAL := $(HOST_REPO)/material
CONTAINER     ?= orfs-$(USR)
CONT_REPO     := /repo
CONT_MATERIAL := $(CONT_REPO)/material

include basic_docker.mk

FRESH        ?= 0
SIM_MAX_TIME ?= 1s
DESIGNS := $(basename $(notdir $(wildcard material/designs/*.f)))

.PHONY: image-scratch publish-docker generate_outputs build_pages site serve \
        sim_output sim_outputs_all gds_output gds_outputs_all gds_glb_assets 3d_assets scratch

scratch: kill image-scratch start

image-scratch:
	docker build \
		-f Dockerfile \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		--build-arg USERNAME=$(USR) \
		--build-arg CONT_ROOT=$(CONT_MATERIAL) \
		-t $(IMAGE) .

publish-docker: image-scratch
	if [ -n "$${GHCR_TOKEN:-}" ]; then \
		test -n "$(GHCR_USER)" || { echo "Set GHCR_USER=<github-user> when GHCR_TOKEN is set"; exit 1; }; \
		printf '%s' "$$GHCR_TOKEN" | docker login ghcr.io -u "$(GHCR_USER)" --password-stdin; \
	else \
		echo "GHCR_TOKEN not set; using existing docker login credentials for ghcr.io"; \
	fi
	docker push $(IMAGE)

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
	if $(MAKE) run CMD="make sim DESIGN=$(DESIGN) SIM_MAX_TIME=$(SIM_MAX_TIME)" IMAGE="$(IMAGE)"; then \
		vcd="material/sim/$(DESIGN)/$(DESIGN).vcd"; \
		svg="material/sim/$(DESIGN)/$(DESIGN)_short.svg"; \
		[ -f "$$vcd" ] && cp "$$vcd" "out/sim-assets/$(DESIGN)/$(DESIGN).vcd" || true; \
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
	if $(MAKE) run CMD="make gds DESIGN=$(DESIGN)" IMAGE="$(IMAGE)"; then \
		printf '%s\n' "pass" > "out/gds-assets/$(DESIGN)/status.txt"; \
	else \
		printf '%s\n' "fail" > "out/gds-assets/$(DESIGN)/status.txt"; \
		status=1; \
	fi; \
	gds_src="material/openroad/work/results/asap7/$(DESIGN)/base/6_final.gds"; \
	[ -f "$$gds_src" ] && cp "$$gds_src" "out/gds-assets/$(DESIGN)/$(DESIGN).gds" || true; \
	logs_src="material/openroad/work/logs/asap7/$(DESIGN)/base"; \
	rm -f "out/gds-assets/$(DESIGN)/logs.zip"; \
	[ -d "$$logs_src" ] && zip -qr "out/gds-assets/$(DESIGN)/logs.zip" "$$logs_src" || true; \
	for img in final_routing.webp final_placement.webp final_worst_path.webp; do \
		src="material/openroad/work/reports/asap7/$(DESIGN)/base/$$img"; \
		[ -f "$$src" ] && cp "$$src" "out/gds-assets/$(DESIGN)/$$img" || true; \
	done; \
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
