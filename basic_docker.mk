SHELL := /bin/bash

USR      := $(shell id -un)
UID      := $(shell id -u)
GID      := $(shell id -g)

ARCH      ?= amd64
IMAGE     ?= ghcr.io/ucsd-cse140-s126/digital-design-$(ARCH):latest
CONTAINER ?= orfs-$(USR)

# macOS GUI support. XQuartz can't display these tools well (its only OpenGL
# path to a container is indirect GLX = OpenGL 1.4, too old for openscad), so on
# macOS the container runs its own virtual display + VNC server (start-vnc.sh)
# where apps render with llvmpipe (full OpenGL). The container's DISPLAY is set
# to that virtual display and the VNC port is published; you view the GUI with a
# VNC client at vnc://localhost:$(VNC_PORT). All of this is gated on IS_MAC, so
# Linux/Windows/WSL hosts are completely unaffected and keep their native display.
VNC_PORT     ?= 5901
VNC_DISPLAY  ?= :99
IS_MAC       := $(filter Darwin,$(shell uname -s))
VNC_PUBLISH  := $(if $(IS_MAC),-e VNC_PORT=$(VNC_PORT) -p 127.0.0.1:$(VNC_PORT):$(VNC_PORT),)
# An && fragment inserted into the container's start command on macOS only; empty
# elsewhere, so the non-macOS start command is byte-for-byte unchanged.
VNC_START    := $(if $(IS_MAC), && { command -v start-vnc.sh >/dev/null 2>&1 && start-vnc.sh || true; },)
# On macOS, send the GUI to the in-container VNC display; elsewhere use the
# host's DISPLAY as before.
DISPLAY_ENV  := $(if $(IS_MAC),$(VNC_DISPLAY),$(DISPLAY))

HOST_REPO     ?= $(CURDIR)
HOST_MATERIAL ?= $(HOST_REPO)
CONT_REPO     ?= /repo
CONT_MATERIAL ?= $(CONT_REPO)

DOCKER_USER  ?= $(UID):$(GID)
DOCKER_HOME  ?= /tmp
DOCKER_PS1   ?= \[\e[0;32m\][$(USR)@docker \W]\$$\[\e[m\]\040

HOSTNAME_VAR     := $(shell bash -lc 'echo $${USER:0:3}')
CONT_XDG_RUNTIME := $(CONT_MATERIAL)/openroad/work/.runtime-$(USR)

# Bind-mount /etc/passwd and /etc/group with entries for the running UID/GID so
# that tools resolving the user/group (getpwuid/getgrgid: gtkwave segfaults on a
# NULL passwd entry; the login shell's `groups` warns on a missing group) work
# when the pre-built image baked a different UID/GID than the local user.
DOCKER_PASSWD    := $(HOST_MATERIAL)/openroad/work/.docker-passwd
DOCKER_GROUP     := $(HOST_MATERIAL)/openroad/work/.docker-group
IDENT_MOUNT      := -v $(DOCKER_PASSWD):/etc/passwd:ro -v $(DOCKER_GROUP):/etc/group:ro

# On macOS the GUI goes through the in-container VNC display, not the host X
# server, so don't mount the host's X11 socket / Xauthority there (mounting the
# host socket would also let Xvfb leak its own socket back onto the host).
X11_MOUNT    := $(if $(IS_MAC),,$(if $(wildcard /tmp/.X11-unix),-v /tmp/.X11-unix:/tmp/.X11-unix))
WSLG_MOUNT   := $(if $(wildcard /mnt/wslg),-v /mnt/wslg:/mnt/wslg)
XAUTH_MOUNT  := $(if $(IS_MAC),,$(if $(wildcard $(HOME)/.Xauthority),-e XAUTHORITY=$(HOME)/.Xauthority -v $(HOME)/.Xauthority:$(HOME)/.Xauthority))
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
	printf 'root:x:0:0:root:/root:/bin/bash\n%s:x:%d:%d::%s:/bin/bash\n' \
		'$(USR)' '$(UID)' '$(GID)' '$(DOCKER_HOME)' > '$(DOCKER_PASSWD)'
	printf 'root:x:0:\n%s:x:%d:\n' '$(USR)' '$(GID)' > '$(DOCKER_GROUP)'
	docker run -d --name $(CONTAINER) \
		-h $(HOSTNAME_VAR) \
		--user $(DOCKER_USER) \
		-e HOME=$(DOCKER_HOME) \
		-e USER=$(USR) \
		-e LOGNAME=$(USR) \
		-e DISPLAY=$(DISPLAY_ENV) \
		-e WAYLAND_DISPLAY=$(WAYLAND_DISPLAY) \
		-e XDG_RUNTIME_DIR=$(CONT_XDG_RUNTIME) \
		-e PULSE_SERVER=$(PULSE_SERVER) \
		$(GL_ENV) \
		-e QT_X11_NO_MITSHM=1 \
		--tty --interactive \
		$(VNC_PUBLISH) \
		$(XAUTH_MOUNT) \
		$(X11_MOUNT) \
		$(WSLG_MOUNT) \
		$(WSL_LIB_MOUNT) \
		$(DRI_DEVICE) \
		$(DXG_DEVICE) \
		$(IDENT_MOUNT) \
		-v "$(HOST_REPO)":"$(CONT_REPO)" \
		-w "$(CONT_MATERIAL)" \
		$(IMAGE) /bin/bash -lc \
			'mkdir -p "$$XDG_RUNTIME_DIR" && chmod 700 "$$XDG_RUNTIME_DIR"$(VNC_START) && tail -f /dev/null'

enter:
	docker exec -it -e DOCKER_PS1='$(DOCKER_PS1)' $(CONTAINER) \
		bash -lc 'printf "export PS1=%q\n" "$$DOCKER_PS1" > /tmp/cse140-bashrc; exec bash --rcfile /tmp/cse140-bashrc -i'

kill:
	- docker kill $(CONTAINER) 2>/dev/null || true
	- docker rm  $(CONTAINER) 2>/dev/null || true
