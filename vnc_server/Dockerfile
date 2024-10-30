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
    apt-get install build-essential wget software-properties-common apt-transport-https curl file git ruby-full locales --no-install-recommends -y && \
    rm -rf /var/lib/apt/lists/*
RUN wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" && \
    apt update && \
    apt install code -y



RUN localedef -i en_US -f UTF-8 en_US.UTF-8
RUN useradd -m -s /bin/bash linuxbrew && \
    echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

RUN mkdir -p /home/ubuntu/.cache/Homebrew && \
    chown -R linuxbrew: /home/ubuntu/
    
USER linuxbrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

# Install kubectl
RUN brew install kubectl

#Install zsh and oh-my-zsh
RUN brew install zsh 
   # sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

USER root

#ENV USER=linuxbrew
#
## Install Visual Studio Code
#
#
##Install zsh and oh-my-zsh
#RUN brew install zsh && \
#    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"