# syntax=docker/dockerfile:1
ARG BASE_IMAGE=brakmic/cppdev:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="CppDev devcontainer" \
      org.opencontainers.image.description="CppDev image with Node.js, Docker Engine and lsd for dev container use" \
      org.opencontainers.image.source="https://github.com/brakmic/CppDev" \
      org.opencontainers.image.licenses="MIT"

ARG DEBIAN_FRONTEND=noninteractive

# Set non-root user name
ARG NONROOT_USER=cppdev
ENV NONROOT_USER=${NONROOT_USER}
ENV HOME=/home/${NONROOT_USER}

# Set Node.js version to major version
ARG NODE_VERSION=22
ENV NODE_VERSION=${NODE_VERSION}

# Pin lsd and verify the downloaded package
ARG LSD_VERSION=1.2.0
ARG LSD_SHA256_AMD64=b212d4c941fa0960c44d94d44039645802a5b7cc8554900e4d53bab5b2574f07
ARG LSD_SHA256_ARM64=9f799c1258b6acbefbb2135b6128ab4369ea3872fb1d402cb5375aa7184dd677

USER root

###############################################################################
# (1) Install Node.js and global npm packages via NodeSource
###############################################################################
RUN curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g typescript tsx node-gyp yarn nodemon eslint \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/*

###############################################################################
# (2) Install Docker Engine and CLI for Docker-in-Docker or host socket use
###############################################################################
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /tmp/docker.asc \
    && gpg --dearmor -o /etc/apt/keyrings/docker.gpg /tmp/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" \
       > /etc/apt/sources.list.d/docker.list \
    && rm -f /tmp/docker.asc \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

###############################################################################
# (3) Install lsd with a verified checksum
###############################################################################
RUN ARCH="$(dpkg --print-architecture)" \
    && case "${ARCH}" in \
         amd64) LSD_SHA256="${LSD_SHA256_AMD64}" ;; \
         arm64) LSD_SHA256="${LSD_SHA256_ARM64}" ;; \
         *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;; \
       esac \
    && wget -q "https://github.com/lsd-rs/lsd/releases/download/v${LSD_VERSION}/lsd_${LSD_VERSION}_${ARCH}.deb" -O /tmp/lsd.deb \
    && echo "${LSD_SHA256}  /tmp/lsd.deb" | sha256sum -c - \
    && apt-get update \
    && apt-get install -y --no-install-recommends /tmp/lsd.deb \
    && rm -f /tmp/lsd.deb \
    && rm -rf /var/lib/apt/lists/* \
    && lsd --version

###############################################################################
# (4) Add the non-root user to the Docker group
###############################################################################
RUN groupadd -f docker \
    && usermod -aG docker "${NONROOT_USER}"

###############################################################################
# (5) Prepare the workspace directory
###############################################################################
WORKDIR /workspace
RUN mkdir -p "${HOME}/.docker" \
    && chown -R "${NONROOT_USER}:${NONROOT_USER}" /workspace "${HOME}"

# Switch back to the non-root user
USER ${NONROOT_USER}

###############################################################################
# (6) Set default command to start an interactive bash shell
###############################################################################
CMD ["bash", "-i"]
