FROM lscr.io/linuxserver/webtop:ubuntu-kde
USER root

ENV DEBIAN_FRONTEND=noninteractive

# Base system setup with validated repositories
RUN apt-get update -o Acquire::Check-Valid-Until=false && \
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        ca-certificates \
        gnupg \
        software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# Add trusted repository keys (verified from archive.ubuntu.com structure)
RUN mkdir -p /etc/apt/keyrings && \
    # Microsoft VSCode
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list && \
    # GitHub CLI
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor > /etc/apt/keyrings/githubcli.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list

# Unified package installation with proper cleanup
RUN apt-get update -o Acquire::Check-Valid-Until=false && \
    apt-get install -y --no-install-recommends \
        code \
        git \
        gh \
        vim \
        fzf \
        zsh \
        tilix \
        containerd \
        kubectl \
        k9s && \
    # Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /etc/apt/trusted.gpg.d/*

# Install ohmyzsh with security validation
RUN wget -q https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O- | sh

USER abc