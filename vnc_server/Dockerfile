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
        gpg \
        sudo && \
    rm -rf /var/lib/apt/lists/*

# 2. Configure locales
RUN localedef -i en_US -f UTF-8 en_US.UTF-8

# 3. Add Microsoft repository and install VS Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg

RUN apt update && \
    apt install code # or code-insiders

# 4. Create user 'rmikl' with sudo privileges
RUN useradd -m -s /bin/bash rmikl && \
    echo 'rmikl ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 5. Set up Homebrew environment for 'rmikl'
RUN mkdir -p /home/rmikl/.cache/Homebrew && \
    chown -R rmikl:rmikl /home/rmikl/.cache/Homebrew

# 6. Switch to 'rmikl' user for Homebrew installation
USER rmikl

# 7. Install Homebrew for 'rmikl'
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    echo 'eval "$(/home/rmikl/.linuxbrew/bin/brew shellenv)"' >> /home/rmikl/.bash_profile

# 8. Set environment variables for Homebrew
ENV PATH="/home/rmikl/.linuxbrew/bin:${PATH}"
ENV HOMEBREW_NO_AUTO_UPDATE=1
ENV USER=rmikl

# 9. Install kubectl and helm using Homebrew
RUN brew install kubectl helm

# 10. Install Zsh and Oh-My-Zsh
RUN brew install zsh && \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

# 11. (Optional) Set Zsh as the default shell for 'rmikl'
RUN chsh -s /bin/zsh rmikl