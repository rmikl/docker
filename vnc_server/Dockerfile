FROM consol/debian-xfce-vnc:nightly
USER root

# 1. Install essential packages and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        wget \
        software-properties-common \
        apt-transport-https \
        curl \
        file \
        git \
        ruby-full \
        locales \
        vim \
        sudo \
        gnupg2 \
        ca-certificates \
        dirmngr \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure locales
RUN localedef -i en_US -f UTF-8 en_US.UTF-8

# 3. Add Microsoft repository and install VS Code
RUN mkdir -p /etc/apt/keyrings && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
    tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
    rm -f packages.microsoft.gpg

RUN apt update && \
    apt install -y code # or code-insiders

# 4. Create user 'rmikl' with sudo privileges
RUN useradd -m -s /bin/bash rmikl && \
    echo 'rmikl ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 5. Set up Homebrew environment for 'rmikl'
RUN mkdir -p /home/rmikl/.cache/Homebrew && \
    chown -R rmikl:rmikl /home/rmikl/.cache/Homebrew

# 6. Set environment variables for Homebrew and HOME before switching user
ENV HOME=/home/rmikl \
    HOMEBREW_PREFIX=/home/rmikl/.linuxbrew \
    HOMEBREW_REPOSITORY=/home/rmikl/.linuxbrew/Homebrew \
    HOMEBREW_CELLAR=/home/rmikl/.linuxbrew/Cellar \
    CI=1

# 7. Switch to 'rmikl' user for Homebrew installation
USER rmikl

# 8. Install Homebrew for 'rmikl' with environment variables set inline
RUN /bin/bash -c " \
    echo 'Installing Homebrew...' && \
    /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\" > /home/rmikl/brew_install.log 2>&1 && \
    cat /home/rmikl/brew_install.log && \
    echo 'eval \"$(/home/rmikl/.linuxbrew/bin/brew shellenv)\"' >> /home/rmikl/.bash_profile"

# 9. Set environment variables for Homebrew
ENV PATH="/home/rmikl/.linuxbrew/bin:/home/rmikl/.linuxbrew/sbin:${PATH}" \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    USER=rmikl

# 10. Verify Homebrew installation directory
RUN ls -la /home/rmikl/.linuxbrew/bin

# 11. Verify Homebrew installation
RUN /home/rmikl/.linuxbrew/bin/brew --version

# 12. Install kubectl and helm using Homebrew
RUN /home/rmikl/.linuxbrew/bin/brew install kubectl helm && \
    /home/rmikl/.linuxbrew/bin/brew cleanup

# 13. Install Zsh via Homebrew
RUN /home/rmikl/.linuxbrew/bin/brew install zsh

# 14. Install Oh-My-Zsh manually to avoid interactive prompts
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git /home/rmikl/.oh-my-zsh && \
    cp /home/rmikl/.oh-my-zsh/templates/zshrc.zsh-template /home/rmikl/.zshrc && \
    chown -R rmikl:rmikl /home/rmikl/.oh-my-zsh /home/rmikl/.zshrc

# 15. (Optional) Set Zsh as the default shell for 'rmikl'
RUN chsh -s /bin/zsh rmikl
