ARG ORFS_IMAGE_TAG=26Q2-100-gae73a7dd2
# Newer ORFS/OpenROAD images can SIGILL during CTS on GitHub-hosted runners.
# ORFS_BASE_IMAGE can be overridden (e.g. to a from-source arm64 build, see
# Dockerfile.arm64-base) since openroad/orfs is amd64-only.
ARG ORFS_BASE_IMAGE=openroad/orfs:${ORFS_IMAGE_TAG}
FROM ${ORFS_BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=usr
ARG CONT_ROOT=/repo/material
ARG UID=1000
ARG GID=1000
ARG ORFS_HOME=/OpenROAD-flow-scripts
ARG VERILATOR_VERSION=v5.046
# INSTALL_GUI=1 adds the Xvfb+VNC GUI stack (set by the Makefile for arm64/macOS).
# Defaults to 0 so amd64/Linux images are unaffected.
ARG INSTALL_GUI=0

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    bash-completion \
    bison \
    build-essential \
    ca-certificates \
    flex \
    git \
    gtkwave \
    help2man \
    less \
    libfl-dev \
    libfl2 \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libx11-dev \
    make \
    openscad \
    perl \
    python3-pip \
    python3 \
    rsync \
    time \
    vim \
    xauth \
    z3 \
    zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

# On the from-source arm64 base, OpenROAD's DependencyInstaller places a
# klayout binary at /usr/local/klayout (not on PATH), which collides with the
# 'klayout' python package's install directory of the same name below.
RUN if [ -f /usr/local/klayout ] && [ ! -d /usr/local/klayout ]; then \
        mv /usr/local/klayout /usr/local/bin/klayout; \
    fi

RUN python3 -m pip install --no-cache-dir --use-pep517 \
    gds3xtrude \
    klayout \
    wavedrom \
    vcdvcd \
    numpy \
    scipy \
    trimesh \
    matplotlib 

RUN test -f "${ORFS_HOME}/flow/Makefile" \
 && test -x "${ORFS_HOME}/tools/install/yosys/bin/yosys" \
 && test -x "${ORFS_HOME}/tools/install/OpenROAD/bin/openroad"

RUN git clone --depth 1 --single-branch --branch "${VERILATOR_VERSION}" https://github.com/verilator/verilator.git /tmp/verilator \
 && cd /tmp/verilator \
 && autoconf \
 && ./configure \
 && make -j"$(nproc)" \
 && make install \
 && rm -rf /tmp/verilator

# macOS GUI support (only when INSTALL_GUI=1, i.e. arm64). On macOS the tools
# can't use XQuartz well (its only OpenGL path to a container is indirect GLX =
# OpenGL 1.4, too old for openscad), so the container runs its own Xvfb display
# where llvmpipe gives full OpenGL, served over VNC (see start-vnc.sh, launched by
# basic_docker.mk on macOS). Living in the final image keeps it cheap to rebuild
# and never recompiles the OpenROAD base. amd64 builds skip this entirely.
#   x11-apps=xeyes  xvfb=virtual X (llvmpipe GL)  x11vnc=serve it  fluxbox=WM
#   x11-utils=xdpyinfo (start-vnc.sh waits for Xvfb)
COPY scripts/start-vnc.sh /usr/local/bin/start-vnc.sh
RUN chmod +x /usr/local/bin/start-vnc.sh \
 && if [ "${INSTALL_GUI}" = "1" ]; then \
        apt-get update && apt-get install -y --no-install-recommends \
            x11-apps xvfb x11vnc fluxbox x11-utils \
         && rm -rf /var/lib/apt/lists/*; \
    fi

# Reuse an existing group if GID is already taken (e.g. on macOS the host
# primary GID is 20, which already exists in Ubuntu as "dialout"); otherwise
# create it. On Linux/Windows the host GID is normally free, so this behaves
# exactly like a plain `groupadd`.
RUN if ! getent group "${GID}" >/dev/null 2>&1; then groupadd -g "${GID}" "${USERNAME}"; fi \
 && useradd --no-log-init -m -u "${UID}" -g "${GID}" -s /bin/bash "${USERNAME}"

USER ${USERNAME}
WORKDIR ${CONT_ROOT}

ENV ORFS_HOME="${ORFS_HOME}" \
    PATH="${ORFS_HOME}/tools/install/yosys/bin:${ORFS_HOME}/tools/install/OpenROAD/bin:${PATH}" \
    LIBGL_ALWAYS_SOFTWARE=1 \
    QT_X11_NO_MITSHM=1 \
    VNC_DISPLAY=:99 \
    VNC_PORT=5901

RUN cat >> "/home/${USERNAME}/.bashrc" <<'EOF_BASHRC'
export PS1="\[\e[0;32m\][\u@\h \W]\$ \[\e[m\] "
EOF_BASHRC
