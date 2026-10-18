# syntax=docker/dockerfile:1
ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION}

LABEL org.opencontainers.image.title="CppDev" \
      org.opencontainers.image.description="C++ development environment with GCC, CMake, Ninja, GDB and Valgrind" \
      org.opencontainers.image.source="https://github.com/brakmic/CppDev" \
      org.opencontainers.image.licenses="MIT"

ARG DEBIAN_FRONTEND=noninteractive

###############################################################################
# (1) Install base packages and the default compiler
###############################################################################
ARG GCC_VERSION=14
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    gnupg \
    software-properties-common \
    dirmngr \
    ca-certificates \
    xz-utils \
    sudo \
    nano \
    unzip \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    "gcc-${GCC_VERSION}" \
    "g++-${GCC_VERSION}" \
    cmake \
    ninja-build \
    make \
    git \
    git-lfs \
    python3 \
    python3-pip \
    python3-venv \
    bash-completion \
    locales \
    gdb \
    valgrind \
    net-tools \
    iproute2 \
    iputils-ping \
    dnsutils \
    strace \
    lsof \
    ccache \
    && rm -rf /var/lib/apt/lists/*

###############################################################################
# (2) Optionally install additional tooling
###############################################################################
ARG INSTALL_EXTRA_TOOLS=false
RUN if [ "${INSTALL_EXTRA_TOOLS}" = "true" ]; then \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            clang-format \
            clang-tidy \
            cppcheck \
            gcovr \
            gdbserver \
            lcov \
            meson \
            pipx \
        && rm -rf /var/lib/apt/lists/*; \
    fi

###############################################################################
# (3) Switch the default compilers to GCC/G++
###############################################################################
RUN update-alternatives --install /usr/bin/gcc gcc "/usr/bin/gcc-${GCC_VERSION}" 100 \
    && update-alternatives --install /usr/bin/g++ g++ "/usr/bin/g++-${GCC_VERSION}" 100 \
    && update-alternatives --set gcc "/usr/bin/gcc-${GCC_VERSION}" \
    && update-alternatives --set g++ "/usr/bin/g++-${GCC_VERSION}"


###############################################################################
# (4) Configure locales
###############################################################################
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

###############################################################################
# (5) Install nano syntax highlighting
#     The syntax files come from the GPL-3.0-or-later nanorc project and are
#     pinned to a fixed commit. Update NANORC_REF intentionally.
###############################################################################
ARG NANORC_REF=1aa64a86cf4c750e4d4788ef1a19d7a71ab641dd
RUN git clone --depth 1 https://github.com/scopatz/nanorc.git /tmp/nanorc \
    && test "$(git -C /tmp/nanorc rev-parse HEAD)" = "${NANORC_REF}" \
    && mkdir -p /usr/share/nano-syntax /usr/share/doc/nanorc-syntax \
    && find /tmp/nanorc -type f -name '*.nanorc' -exec cp {} /usr/share/nano-syntax/ \; \
    && cp /tmp/nanorc/license /usr/share/doc/nanorc-syntax/LICENSE \
    && echo 'include "/usr/share/nano-syntax/*.nanorc"' >> /etc/nanorc \
    && rm -rf /tmp/nanorc

###############################################################################
# (6) Create a non-root user with passwordless sudo
###############################################################################
ARG NONROOT_USER=cppdev
ARG USER_UID=1000
ARG USER_GID=1000
ENV NONROOT_USER=${NONROOT_USER}
RUN userdel --remove ubuntu 2>/dev/null || true; \
    groupdel ubuntu 2>/dev/null || true; \
    groupadd --gid "${USER_GID}" "${NONROOT_USER}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${NONROOT_USER}" \
    && echo "${NONROOT_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${NONROOT_USER}" \
    && chmod 0440 "/etc/sudoers.d/${NONROOT_USER}"

###############################################################################
# (7) Set default shell to bash
###############################################################################
SHELL ["/bin/bash", "-c"]

###############################################################################
# (8) Prepare the workspace directory
###############################################################################
WORKDIR /workspace
ENV HOME=/home/${NONROOT_USER}
RUN chown -R "${NONROOT_USER}:${NONROOT_USER}" /workspace

###############################################################################
# (9) Switch to the non-root user
###############################################################################
USER ${NONROOT_USER}

###############################################################################
# (10) Configure default shell environment for the user
###############################################################################
RUN cp /etc/skel/.bashrc "${HOME}/.bashrc" \
    && cp /etc/skel/.profile "${HOME}/.profile"

RUN printf '%s\n' \
    '# Read ~/.bashrc so login shells share the same environment.' \
    'if [ -f ~/.bashrc ]; then' \
    '    . ~/.bashrc' \
    'fi' \
    > "${HOME}/.bash_profile"

###############################################################################
# (11) Add shell aliases
###############################################################################
RUN cat > "${HOME}/.bash_aliases" <<'EOF'
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"
alias gs="git status"
alias ga="git add"
alias gp="git push"
alias gl="git log"
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias nano="nano -c"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
EOF

###############################################################################
# (12) Configure the interactive shell environment
###############################################################################
RUN cat >> "${HOME}/.bashrc" <<'EOF'

# Default editor
export EDITOR=nano
export VISUAL=nano

# User-local executables (pipx, custom scripts)
export PATH="${HOME}/.local/bin:${PATH}"

# Colorized prompt
export PS1='\[\e[0;32m\]\u@\h\[\e[m\]:\[\e[0;34m\]\w\[\e[m\]\$ '
EOF

###############################################################################
# (13) Default command to start an interactive bash shell
###############################################################################
CMD ["bash", "-i"]
