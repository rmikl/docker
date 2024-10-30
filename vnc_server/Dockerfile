# Use the official Ubuntu base image
FROM elestio/docker-desktop-vnc:latest

# Install visual studio code
#RUN apt-get update && apt-get install -y curl git wget gpg && \
#    echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections && \
#    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
#    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
#    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
#    rm -f packages.microsoft.gpg && \
#    sudo apt install apt-transport-https && \
#    sudo apt update && \
#    sudo apt install code # or code-insider
#

# Install brew
RUN apt-get update && \
    apt-get install build-essential curl file git ruby-full locales --no-install-recommends -y && \
    rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -f UTF-8 en_US.UTF-8
RUN useradd -m -s /bin/bash linuxbrew && \
    echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

USER linuxbrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

# Install Visual Studio Code
RUN brew install --cask visual-studio-code

#Install zsh and oh-my-zsh
RUN brew install zsh && \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"