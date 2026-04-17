SHELL := /bin/bash

USR          := $(shell id -un)
UID          := $(shell id -u)
GID          := $(shell id -g)
HOSTNAME_VAR := $(shell bash -lc 'echo $${USER:0:3}')
IMAGE        := $(USR)/cse140-openroad:dev
CONTAINER    := orfs-$(USR)

HOST_MATERIAL := $(CURDIR)/material
CONT_MATERIAL := /material
CONT_XDG_RUNTIME := /material/openroad/work/.runtime-$(USR)

X11_MOUNT    := $(if $(wildcard /tmp/.X11-unix),-v /tmp/.X11-unix:/tmp/.X11-unix)
WSLG_MOUNT   := $(if $(wildcard /mnt/wslg),-v /mnt/wslg:/mnt/wslg)
XAUTH_MOUNT  := $(if $(wildcard $(HOME)/.Xauthority),-e XAUTHORITY=$(HOME)/.Xauthority -v $(HOME)/.Xauthority:$(HOME)/.Xauthority)

.PHONY: image start enter kill fresh

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
		-v $(HOST_MATERIAL):$(CONT_MATERIAL) \
		-w $(CONT_MATERIAL) \
			$(IMAGE) /bin/bash -lc 'mkdir -p "$$XDG_RUNTIME_DIR" && chmod 700 "$$XDG_RUNTIME_DIR" && tail -f /dev/null'

enter:
	docker exec -it $(CONTAINER) bash -i

kill:
	- docker kill $(CONTAINER) || true
	- docker rm $(CONTAINER) || true
