FROM openroad/orfs:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=usr
ARG CONT_ROOT=/material
ARG UID=1000
ARG GID=1000
ARG VERILATOR_VERSION=v5.038

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
    perl \
    python3 \
    rsync \
    time \
    vim \
    xauth \
 && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${VERILATOR_VERSION}" https://github.com/verilator/verilator.git /tmp/verilator \
 && cd /tmp/verilator \
 && autoconf \
 && ./configure \
 && make -j"$(nproc)" \
 && make install \
 && rm -rf /tmp/verilator

RUN groupadd -g "${GID}" "${USERNAME}" \
 && useradd -m -u "${UID}" -g "${GID}" -s /bin/bash "${USERNAME}"

USER ${USERNAME}
WORKDIR ${CONT_ROOT}

ENV LIBGL_ALWAYS_SOFTWARE=1 \
    QT_X11_NO_MITSHM=1

RUN cat >> "/home/${USERNAME}/.bashrc" <<'EOF_BASHRC'
export PS1="\[\e[0;32m\][\u@\h \W]\$ \[\e[m\] "
EOF_BASHRC
