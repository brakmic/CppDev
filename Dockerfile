FROM ubuntu:24.04

###############################################################################
# (1) Configure default system locale settings
###############################################################################
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

###############################################################################
# (2) Install necessary packages and both compiler versions
###############################################################################
RUN apt update && apt install -y --no-install-recommends \
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
    gcc-14 \
    g++-14 \
    cmake \
    ninja-build \
    make \
    git \
    git-lfs \
    python3 \
    python3-pip \
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
    && rm -rf /var/lib/apt/lists/*

###############################################################################
# (3) Switch default compilers to GCC/G++ 14
###############################################################################
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 50 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 60 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 50 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 60 \
    && update-alternatives --set gcc /usr/bin/gcc-14 \
    && update-alternatives --set g++ /usr/bin/g++-14


###############################################################################
# (4) Configure locales
###############################################################################
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

###############################################################################
# (5) Install nano syntax highlighting
###############################################################################
RUN git clone https://github.com/scopatz/nanorc.git /tmp/nanorc \
    && mkdir -p /usr/share/nano-syntax \
    && cp -r /tmp/nanorc/* /usr/share/nano-syntax \
    && find /usr/share/nano-syntax -type f -name '*.nanorc' \
         -exec sh -c 'echo "include $1" >> /etc/nanorc' _ {} \; \
    && rm -rf /tmp/nanorc

###############################################################################
# (6) Create a non-root user with passwordless sudo
###############################################################################
ARG NONROOT_USER=cppdev
ENV NONROOT_USER=${NONROOT_USER}
RUN useradd -m -s /bin/bash ${NONROOT_USER} \
    && echo "${NONROOT_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${NONROOT_USER} \
    && chmod 0440 /etc/sudoers.d/${NONROOT_USER}

###############################################################################
# (7) Set default shell to bash
###############################################################################
SHELL ["/bin/bash", "-c"]

###############################################################################
# (8) Adjust file ownership for the non-root user
###############################################################################
WORKDIR /workspace
ENV HOME=/home/${NONROOT_USER}
RUN chown -R ${NONROOT_USER}:${NONROOT_USER} /workspace ${HOME}

###############################################################################
# (9) Switch to the non-root user
###############################################################################
USER ${NONROOT_USER}

###############################################################################
# (10) Configure default shell environment for the user
###############################################################################
RUN cp /etc/skel/.bashrc ${HOME}/.bashrc \
    && cp /etc/skel/.profile ${HOME}/.profile

###############################################################################
# (11) Add shell aliases
###############################################################################
RUN echo -e '\
alias ll="ls -la"\n\
alias la="ls -A"\n\
alias l="ls -CF"\n\
alias gs="git status"\n\
alias ga="git add"\n\
alias gp="git push"\n\
alias gl="git log"\n\
alias rm="rm -i"\n\
alias cp="cp -i"\n\
alias mv="mv -i"\n\
alias nano="nano -c"\n\
alias ..="cd .."\n\
alias ...="cd ../.."\n\
alias ....="cd ../../.."\n\
' >> ${HOME}/.bash_aliases

###############################################################################
# (12) Configure nano with syntax highlighting for the user
###############################################################################
RUN echo "include /usr/share/nano-syntax/*.nanorc" >> ${HOME}/.nanorc

###############################################################################
# (13) Set nano as the default editor and adjust ownership of config files
###############################################################################
RUN echo "export EDITOR=nano" >> ${HOME}/.bash_profile \
    && chown ${NONROOT_USER}:${NONROOT_USER} \
       ${HOME}/.bashrc \
       ${HOME}/.profile \
       ${HOME}/.bash_profile \
       ${HOME}/.nanorc

###############################################################################
# (14) Customize the terminal prompt for the user
###############################################################################
ENV TERM=xterm-256color
RUN echo "\
# Colorized PS1 prompt\n\
export PS1=\"\[\e[0;32m\]\u@\h\[\e[m\]:\[\e[0;34m\]\w\[\e[m\]\$ \"\
" >> ${HOME}/.bashrc

###############################################################################
# (15) Default command to start an interactive bash shell
###############################################################################
CMD ["bash", "-i"]
