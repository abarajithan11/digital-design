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

.PHONY: image start enter kill fresh ci-image run ci-sim ci-gds-docs ci-build-pages

CI_IMAGE ?= pages-layouts:latest

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

ci-image:
	git submodule update --init --recursive
	docker build \
		-f Dockerfile \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		--build-arg USERNAME=$(USR) \
		--build-arg CONT_ROOT=$(CONT_MATERIAL) \
		-t $(CI_IMAGE) .

run:
	docker run --rm \
		-v $(HOST_REPO):$(CONT_REPO) \
		-w $(CONT_MATERIAL) \
		$(CI_IMAGE) bash -lc '$(CMD)'

ci-sim:
	shopt -s nullglob; \
	mkdir -p out/sim; \
	: > out/sim/status.tsv; \
	for design_file in material/designs/*.f; do \
		design="$${design_file##*/}"; \
		design="$${design%.f}"; \
		sim_status=pass; \
		if ! $(MAKE) run CMD="make sim DESIGN=$$design"; then sim_status=fail; fi; \
		printf '%s\t%s\n' "$$design" "$$sim_status" >> out/sim/status.tsv; \
	done

ci-gds-docs:
	CI_IMAGE="$(CI_IMAGE)" python scripts/generate_outputs.py

ci-build-pages:
	python -m pip install --upgrade pip
	pip install mkdocs
	mkdocs build

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
