SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

USR          := $(shell id -un)
UID          := $(shell id -u)
GID          := $(shell id -g)
HOSTNAME_VAR := $(shell bash -lc 'echo $${USER:0:3}')
IMAGE        := $(USR)/cse140-openroad:dev
CONTAINER    := orfs-$(USR)

HOST_REPO     := $(CURDIR)
HOST_MATERIAL := $(HOST_REPO)/material
CONT_REPO     := /repo
CONT_MATERIAL := $(CONT_REPO)/material
CONT_XDG_RUNTIME := $(CONT_MATERIAL)/openroad/work/.runtime-$(USR)

X11_MOUNT    := $(if $(wildcard /tmp/.X11-unix),-v /tmp/.X11-unix:/tmp/.X11-unix)
WSLG_MOUNT   := $(if $(wildcard /mnt/wslg),-v /mnt/wslg:/mnt/wslg)
XAUTH_MOUNT  := $(if $(wildcard $(HOME)/.Xauthority),-e XAUTHORITY=$(HOME)/.Xauthority -v $(HOME)/.Xauthority:$(HOME)/.Xauthority)
DRI_DEVICE   := $(if $(wildcard /dev/dri),--device /dev/dri)
DXG_DEVICE   := $(if $(wildcard /dev/dxg),--device /dev/dxg)
WSL_LIB_MOUNT := $(if $(wildcard /usr/lib/wsl/lib),-v /usr/lib/wsl:/usr/lib/wsl)
GL_ENV       := $(if $(wildcard /usr/lib/wsl/lib),-e LD_LIBRARY_PATH=/usr/lib/wsl/lib -e LIBGL_ALWAYS_SOFTWARE=0 -e GALLIUM_DRIVER=d3d12 -e MESA_LOADER_DRIVER_OVERRIDE=d3d12,-e LIBGL_ALWAYS_SOFTWARE=1)

.PHONY: image start enter kill fresh run sim_output sim_outputs_all gds_output gds_outputs_all generate_outputs build_pages serve
FRESH ?= 0
DESIGNS := $(basename $(notdir $(wildcard material/designs/*.f)))
DESIGN_BASE := $(subst $(firstword $(subst _, ,$(DESIGN)))_,,$(DESIGN))

# Docker container targets

fresh: kill image start

restart: kill start

image:
	git submodule update --init --recursive
	docker build \
		-f Dockerfile \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		--build-arg USERNAME=$(USR) \
		--build-arg CONT_ROOT=$(CONT_MATERIAL) \
		-t $(IMAGE) .

run:
	docker run --rm \
		-v $(HOST_REPO):$(CONT_REPO) \
		-w $(CONT_MATERIAL) \
		$(IMAGE) bash -lc '$(CMD)'

start:
	- xhost +Local:docker
	mkdir -p "$(HOST_MATERIAL)/openroad/work"
	docker run -d --name $(CONTAINER) \
		-h $(HOSTNAME_VAR) \
		-e DISPLAY=$(DISPLAY) \
		-e WAYLAND_DISPLAY=$(WAYLAND_DISPLAY) \
		-e XDG_RUNTIME_DIR=$(CONT_XDG_RUNTIME) \
		-e PULSE_SERVER=$(PULSE_SERVER) \
		$(GL_ENV) \
		-e QT_X11_NO_MITSHM=1 \
		--tty --interactive \
		$(XAUTH_MOUNT) \
		$(X11_MOUNT) \
		$(WSLG_MOUNT) \
		$(WSL_LIB_MOUNT) \
		$(DRI_DEVICE) \
		$(DXG_DEVICE) \
		-v $(HOST_REPO):$(CONT_REPO) \
		-w $(CONT_MATERIAL) \
				$(IMAGE) /bin/bash -lc 'mkdir -p "$$XDG_RUNTIME_DIR" && chmod 700 "$$XDG_RUNTIME_DIR" && tail -f /dev/null'

enter:
	docker exec -it $(CONTAINER) bash -i

kill:
	- docker kill $(CONTAINER) || true
	- docker rm $(CONTAINER) || true


# Build and serve the website

generate_outputs:
ifeq ($(FRESH),1)
	$(MAKE) sim_outputs_all IMAGE="$(IMAGE)"
	$(MAKE) gds_outputs_all IMAGE="$(IMAGE)"
endif
	python scripts/generate_outputs.py

build_pages:
	sphinx-build -a -b html docs site
	python scripts/generate_outputs.py copy-site-downloads

serve: generate_outputs build_pages
	python3 -m http.server 8000 --directory site


# Bulk artifact targets

sim_output:
	test -n "$(DESIGN)"
	mkdir -p out/sim
	mkdir -p out/sim-assets/$(DESIGN)
	if $(MAKE) run CMD="make sim DESIGN=$(DESIGN_BASE)" IMAGE="$(IMAGE)"; then \
		$(MAKE) run CMD="make wave_svg DESIGN=$(DESIGN_BASE)" IMAGE="$(IMAGE)" || true; \
		vcd_src="material/sim/$(DESIGN)/$(DESIGN).vcd"; \
		[ -f "$$vcd_src" ] && cp "$$vcd_src" "out/sim-assets/$(DESIGN)/$(DESIGN).vcd" || true; \
		svg_src="material/sim/$(DESIGN)/$(DESIGN)_short.svg"; \
		[ -f "$$svg_src" ] && cp "$$svg_src" "out/sim-assets/$(DESIGN)/$(DESIGN)_short.svg" || true; \
		printf '%s\n' "pass" > "out/sim/$(DESIGN).status"; \
	else \
		printf '%s\n' "fail" > "out/sim/$(DESIGN).status"; \
		exit 1; \
	fi

sim_outputs_all:
	rm -rf out/sim; \
	rm -rf out/sim-assets; \
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
		if [ -f "out/sim/$$design.status" ]; then \
			printf '%s\t%s\n' "$$design" "$$(cat out/sim/$$design.status)" >> out/sim/status.tsv; \
		fi; \
	done; \
	printf '\n==== [sim] summary ====\n'; \
	cat out/sim/status.tsv; \
	exit $$fail

gds_output:
	test -n "$(DESIGN)"
	mkdir -p "out/gds-assets/$(DESIGN)"
	if $(MAKE) run CMD="make gds DESIGN=$(DESIGN_BASE)" IMAGE="$(IMAGE)"; then \
		printf '%s\n' "pass" > "out/gds-assets/$(DESIGN)/status.txt"; \
	else \
		printf '%s\n' "fail" > "out/gds-assets/$(DESIGN)/status.txt"; \
		status=1; \
	fi; \
	gds_src="material/openroad/work/results/asap7/$(DESIGN)/base/6_final.gds"; \
	[ -f "$$gds_src" ] && cp "$$gds_src" "out/gds-assets/$(DESIGN)/$(DESIGN).gds" || true; \
	logs_src="material/openroad/work/logs/asap7/$(DESIGN)/base"; \
	rm -f "out/gds-assets/$(DESIGN)/logs.zip"; \
	if [ -d "$$logs_src" ]; then \
		zip -qr "out/gds-assets/$(DESIGN)/logs.zip" "$$logs_src" || true; \
	fi; \
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
		if [ -f "out/gds-assets/$$design/status.txt" ]; then \
			printf '%s\t%s\n' "$$design" "$$(cat out/gds-assets/$$design/status.txt)"; \
		fi; \
	done; \
	exit $$fail
