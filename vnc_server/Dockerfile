FROM elestio/docker-desktop-vnc:latest

# Install brew
RUN apt-get update && \
    apt-get install build-essential wget software-properties-common apt-transport-https curl file git ruby-full locales vim --no-install-recommends -y && \
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

ENV USER=linuxbrew
# Install kubectl
WORKDIR /home/linuxbrew
RUN brew install kubectl helm 

#Install zsh and oh-my-zsh
RUN brew install zsh && \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

USER root