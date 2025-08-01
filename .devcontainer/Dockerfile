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
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash devuser \
    && usermod -aG sudo devuser \
    && echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to devuser
USER devuser

# Set working directory
WORKDIR /workspaces
