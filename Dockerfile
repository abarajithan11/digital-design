FROM openroad/orfs:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=usr
ARG CONT_ROOT=/material
ARG UID=1000
ARG GID=1000

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    git \
    gtkwave \
    less \
    python3 \
    rsync \
    time \
    verilator \
    vim \
    xauth \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd -g "${GID}" "${USERNAME}" \
 && useradd -m -u "${UID}" -g "${GID}" -s /bin/bash "${USERNAME}"

USER ${USERNAME}
WORKDIR ${CONT_ROOT}

ENV LIBGL_ALWAYS_SOFTWARE=1 \
    QT_X11_NO_MITSHM=1

RUN cat >> "/home/${USERNAME}/.bashrc" <<'EOF_BASHRC'
export PS1="\[\e[0;32m\][\u@\h \W]\$ \[\e[m\] "
EOF_BASHRC
