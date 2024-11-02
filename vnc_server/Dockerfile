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


RUN apt-get update && \
    apt-get install -y -q --allow-unauthenticated \
    git \
    sudo
RUN useradd -m -s /bin/zsh linuxbrew && \
    usermod -aG sudo linuxbrew &&  \
    mkdir -p /home/linuxbrew/.linuxbrew && \
    chown -R linuxbrew: /home/linuxbrew/.linuxbrew
USER linuxbrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
USER root
RUN chown -R $CONTAINER_USER: /home/linuxbrew/.linuxbrew
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
RUN git config --global --add safe.directory /home/linuxbrew/.linuxbrew/Homebrew
RUN brew update
RUN brew doctor
USER root

RUN sudo chown -R rmikl /headless/.cache/Homebrew /home/linuxbrew/.linuxbrew/Cellar /home/linuxbrew/.linuxbrew/Homebrew /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/etc /home/linuxbrew/.linuxbrew/etc/bash_completion.d /home/linuxbrew/.linuxbrew/include /home/linuxbrew/.linuxbrew/lib /home/linuxbrew/.linuxbrew/opt /home/linuxbrew/.linuxbrew/sbin /home/linuxbrew/.linuxbrew/share /home/linuxbrew/.linuxbrew/share/doc /home/linuxbrew/.linuxbrew/share/man /home/linuxbrew/.linuxbrew/share/man/man1 /home/linuxbrew/.linuxbrew/share/zsh /home/linuxbrew/.linuxbrew/share/zsh/site-functions /home/linuxbrew/.linuxbrew/var/homebrew/linked /home/linuxbrew/.linuxbrew/var/homebrew/locks
RUN chmod u+w /headless/.cache/Homebrew /home/linuxbrew/.linuxbrew/Cellar /home/linuxbrew/.linuxbrew/Homebrew /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/etc /home/linuxbrew/.linuxbrew/etc/bash_completion.d /home/linuxbrew/.linuxbrew/include /home/linuxbrew/.linuxbrew/lib /home/linuxbrew/.linuxbrew/opt /home/linuxbrew/.linuxbrew/sbin /home/linuxbrew/.linuxbrew/share /home/linuxbrew/.linuxbrew/share/doc /home/linuxbrew/.linuxbrew/share/man /home/linuxbrew/.linuxbrew/share/man/man1 /home/linuxbrew/.linuxbrew/share/zsh /home/linuxbrew/.linuxbrew/share/zsh/site-functions /home/linuxbrew/.linuxbrew/var/homebrew/linked /home/linuxbrew/.linuxbrew/var/homebrew/locks

# 7. Switch to 'rmikl' user for Homebrew installation
WORKDIR /home/rmikl
ENV USER=rmikl
USER rmikl
# 12. Install kubectl and helm using Homebrew
RUN brew install kubectl helm && \
    brew cleanup

# 13. Install Zsh via Homebrew
RUN brew install zsh

# 14. Install Oh-My-Zsh manually to avoid interactive prompts
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git /home/rmikl/.oh-my-zsh && \
    cp /home/rmikl/.oh-my-zsh/templates/zshrc.zsh-template /home/rmikl/.zshrc && \
    chown -R rmikl:rmikl /home/rmikl/.oh-my-zsh /home/rmikl/.zshrc

# 15. (Optional) Set Zsh as the default shell for 'rmikl'
RUN chsh -s /bin/zsh rmikl