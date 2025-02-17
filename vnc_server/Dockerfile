FROM lscr.io/linuxserver/webtop:ubuntu-kde
USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y \
        wget \
        curl \
        apt-transport-https \
        software-properties-common \
        gpg

# Prepare system

RUN curl -s https://packagecloud.io/install/repositories/datawireio/telepresence/script.deb.sh | bash

# Key management for repositories (modern approach)
RUN mkdir -p /etc/apt/keyrings

# Microsoft VSCode (verified from packages.microsoft.com/repos/vscode/dists/stable)
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft-vscode.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft-vscode.gpg] https://packages.microsoft.com/repos/vscode stable main" | tee /etc/apt/sources.list.d/vscode.list

# GitHub CLI (fixed signing key)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list

# Update with verified sources
RUN apt update -o Acquire::Check-Valid-Until=false

# Install packages with proper repository validation
RUN apt install -y \
        code \
        tree \
        git \
        gh \
        vim \
        fzf \
        inetutils-ping \
        inetutils-telnet \
        zsh \
        sshpass \
        tilix \
        engrampa \
        containerd \
        telepresence && \
# Cleanup legacy keyring references
    rm -f /etc/apt/trusted.gpg.d/*

#OTHER BINS
#KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt | grep -oP 'v\d+\.\d+\.\d+')
RUN wget "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -O /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

RUN wget https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.deb && apt install ./k9s_linux_amd64.deb &&  rm k9s_linux_amd64.deb && \
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

USER abc