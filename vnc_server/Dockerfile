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

# Add trusted repository keys
RUN mkdir -p /etc/apt/keyrings && \
    # Microsoft VSCode
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list && \
    # GitHub CLI
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor > /etc/apt/keyrings/githubcli.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    # Kubernetes
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor > /etc/apt/keyrings/kubernetes.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

# Install system packages
RUN apt-get update -o Acquire::Check-Valid-Until=false && \
    apt-get install -y --no-install-recommends \
        code \
        git \
        gh \
        vim \
        fzf \
        zsh \
        tilix \
        rsync \
        containerd \
        kubectl && \
    # Install k9s directly from GitHub
    wget https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.deb && \
    apt-get install -y ./k9s_linux_amd64.deb && \
    rm k9s_linux_amd64.deb && \
    # Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /etc/apt/trusted.gpg.d/*

# Install ohmyzsh
RUN wget -q https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O- | sh