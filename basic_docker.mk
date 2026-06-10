SHELL := /bin/bash

USR      := $(shell id -un)
UID      := $(shell id -u)
GID      := $(shell id -g)

ARCH      ?= amd64
IMAGE     ?= ghcr.io/ucsd-cse140-s126/digital-design-$(ARCH):latest
CONTAINER ?= orfs-$(USR)

HOST_REPO     ?= $(CURDIR)
HOST_MATERIAL ?= $(HOST_REPO)
CONT_REPO     ?= /repo
CONT_MATERIAL ?= $(CONT_REPO)

DOCKER_USER  ?= $(UID):$(GID)
DOCKER_HOME  ?= /tmp
DOCKER_PS1   ?= \[\e[0;32m\][$(USR)@docker \W]\$$\[\e[m\]\040

HOSTNAME_VAR     := $(shell bash -lc 'echo $${USER:0:3}')
CONT_XDG_RUNTIME := $(CONT_MATERIAL)/openroad/work/.runtime-$(USR)

X11_MOUNT    := $(if $(wildcard /tmp/.X11-unix),-v /tmp/.X11-unix:/tmp/.X11-unix)
WSLG_MOUNT   := $(if $(wildcard /mnt/wslg),-v /mnt/wslg:/mnt/wslg)
XAUTH_MOUNT  := $(if $(wildcard $(HOME)/.Xauthority),-e XAUTHORITY=$(HOME)/.Xauthority -v $(HOME)/.Xauthority:$(HOME)/.Xauthority)
DRI_DEVICE   := $(if $(wildcard /dev/dri),--device /dev/dri)
DXG_DEVICE   := $(if $(wildcard /dev/dxg),--device /dev/dxg)
WSL_LIB_MOUNT := $(if $(wildcard /usr/lib/wsl/lib),-v /usr/lib/wsl:/usr/lib/wsl)
GL_ENV       := $(if $(wildcard /usr/lib/wsl/lib),\
	-e LD_LIBRARY_PATH=/usr/lib/wsl/lib -e LIBGL_ALWAYS_SOFTWARE=0 -e GALLIUM_DRIVER=d3d12 -e MESA_LOADER_DRIVER_OVERRIDE=d3d12,\
	-e LIBGL_ALWAYS_SOFTWARE=1)

.PHONY: fresh restart image run start enter kill

fresh: kill image start

restart: kill start

image:
	docker pull $(IMAGE)

run:
	docker run --rm \
		--user $(DOCKER_USER) \
		-e HOME=$(DOCKER_HOME) \
		-e USER=$(USR) \
		-e LOGNAME=$(USR) \
		-v "$(HOST_REPO)":"$(CONT_REPO)" \
		-w "$(CONT_MATERIAL)" \
		$(IMAGE) bash -lc '$(CMD)'

start:
	- xhost +Local:docker 2>/dev/null || true
	mkdir -p "$(HOST_MATERIAL)/openroad/work"
	docker run -d --name $(CONTAINER) \
		-h $(HOSTNAME_VAR) \
		--user $(DOCKER_USER) \
		-e HOME=$(DOCKER_HOME) \
		-e USER=$(USR) \
		-e LOGNAME=$(USR) \
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
		-v "$(HOST_REPO)":"$(CONT_REPO)" \
		-w "$(CONT_MATERIAL)" \
		$(IMAGE) /bin/bash -lc \
			'mkdir -p "$$XDG_RUNTIME_DIR" && chmod 700 "$$XDG_RUNTIME_DIR" && tail -f /dev/null'

enter:
	docker exec -it -e DOCKER_PS1='$(DOCKER_PS1)' $(CONTAINER) \
		bash -lc 'printf "export PS1=%q\n" "$$DOCKER_PS1" > /tmp/cse140-bashrc; exec bash --rcfile /tmp/cse140-bashrc -i'

kill:
	- docker kill $(CONTAINER) 2>/dev/null || true
	- docker rm  $(CONTAINER) 2>/dev/null || true
