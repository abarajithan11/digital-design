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

.PHONY: image start enter kill fresh run sim_outputs_all gds_outputs_all generate_outputs build_pages serve
FRESH ?= 0

# Docker container targets

fresh: kill image start

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
		-e LIBGL_ALWAYS_SOFTWARE=1 \
		-e QT_X11_NO_MITSHM=1 \
		--tty --interactive \
		$(XAUTH_MOUNT) \
		$(X11_MOUNT) \
		$(WSLG_MOUNT) \
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

serve: generate_outputs build_pages
	python3 -m http.server 8000 --directory site


# Bulk artifact targets

sim_outputs_all:
	mkdir -p out/sim; \
	: > out/sim/status.tsv; \
	fail=0; \
	for design_file in material/designs/*.f; do \
		design="$${design_file##*/}"; \
		design="$${design%.f}"; \
		if $(MAKE) run CMD="make sim DESIGN=$$design" IMAGE="$(IMAGE)"; then \
			printf '%s\t%s\n' "$$design" "pass" >> out/sim/status.tsv; \
			$(MAKE) run CMD="make wave_svg DESIGN=$$design" IMAGE="$(IMAGE)" || true; \
		else \
			printf '%s\t%s\n' "$$design" "fail" >> out/sim/status.tsv; \
			fail=1; \
		fi; \
	done; \
	exit $$fail

gds_outputs_all:
	rm -rf out/gds-assets; \
	fail=0; \
	for design_file in material/designs/*.f; do \
		design="$${design_file##*/}"; \
		design="$${design%.f}"; \
		if ! $(MAKE) run CMD="make gds DESIGN=$$design" IMAGE="$(IMAGE)"; then \
			fail=1; \
		fi; \
		mkdir -p "out/gds-assets/$$design"; \
		for img in final_routing.webp final_placement.webp final_worst_path.webp; do \
			src="material/openroad/work/reports/asap7/$$design/base/$$img"; \
			[ -f "$$src" ] && cp "$$src" "out/gds-assets/$$design/$$img" || true; \
		done; \
	done; \
	exit $$fail
