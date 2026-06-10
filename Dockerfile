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
 && rm -rf /var/lib/apt/lists/*

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

RUN groupadd -g "${GID}" "${USERNAME}" \
 && useradd --no-log-init -m -u "${UID}" -g "${GID}" -s /bin/bash "${USERNAME}"

USER ${USERNAME}
WORKDIR ${CONT_ROOT}

ENV ORFS_HOME="${ORFS_HOME}" \
    PATH="${ORFS_HOME}/tools/install/yosys/bin:${ORFS_HOME}/tools/install/OpenROAD/bin:${PATH}" \
    LIBGL_ALWAYS_SOFTWARE=1 \
    QT_X11_NO_MITSHM=1

RUN cat >> "/home/${USERNAME}/.bashrc" <<'EOF_BASHRC'
export PS1="\[\e[0;32m\][\u@\h \W]\$ \[\e[m\] "
EOF_BASHRC
