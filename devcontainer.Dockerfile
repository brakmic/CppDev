FROM brakmic/cppdev:latest

# Set non-root user name
ARG NONROOT_USER=cppdev
ENV NONROOT_USER=${NONROOT_USER}
ENV HOME=/home/${NONROOT_USER}
ENV NVM_DIR=/usr/local/nvm

# Set Node.js version to major version only for flexibility
ARG NODE_VERSION=22
ENV NODE_VERSION=${NODE_VERSION}

USER root

###############################################################################
# (1) Install NVM, Node.js, and Global npm Packages
###############################################################################
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    bash -c "source $NVM_DIR/nvm.sh && \
            nvm install $NODE_VERSION && \
            nvm alias default $NODE_VERSION && \
            nvm use default && \
            node -v && npm -v && \
            npm install -g typescript tsx eslint prettier node-gyp nodemon"

###############################################################################
# (2) Install Docker
###############################################################################
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

###############################################################################
# (3) Install lsd
###############################################################################
RUN ARCH=$(dpkg --print-architecture) && \
    wget "https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd_1.1.5_${ARCH}.deb" -O /tmp/lsd.deb && \
    apt-get update && \
    apt-get install -y /tmp/lsd.deb && \
    rm /tmp/lsd.deb && \
    lsd --version

###############################################################################
# (4) Add existing user to the Docker group
###############################################################################
RUN groupadd -f docker \
&& usermod -aG docker ${NONROOT_USER}

###############################################################################
# (5) Adjust File Ownership
###############################################################################
WORKDIR /workspace
RUN mkdir -p /home/${NONROOT_USER}/.docker && \
    chown -R ${NONROOT_USER}:${NONROOT_USER} /workspace ${NVM_DIR} ${HOME}

# Ensure that the ${NONROOT_USER} user has the correct permissions for Docker
RUN mkdir -p ${HOME}/.docker \
&& chown -R ${NONROOT_USER}:docker ${HOME}/.docker

# Switch back to the non-root user
USER ${NONROOT_USER}

###############################################################################
# (6) Set default command to start an interactive bash shell
###############################################################################
CMD ["bash", "-i"]
