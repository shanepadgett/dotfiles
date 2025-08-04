# Use Ubuntu as base image for general development
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    unzip \
    zip \
    jq \
    tree \
    vim \
    nano \
    sudo \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    shellcheck \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget -O go.tar.gz https://go.dev/dl/go1.21.5.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go.tar.gz \
    && rm go.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Create Go workspace
RUN mkdir -p ${GOPATH}/bin ${GOPATH}/src ${GOPATH}/pkg

# Create non-root user
RUN useradd -m -s /bin/zsh devuser \
    && usermod -aG sudo devuser \
    && echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Fix Go workspace permissions
RUN chown -R devuser:devuser ${GOPATH}

# Switch to devuser
USER devuser

# Set working directory
WORKDIR /workspaces
