# Use the official Ubuntu base image
FROM elestio/docker-desktop-vnc:latest

# Install visual studio code
RUN apt-get update && apt-get install -y curl git && \
    curl -fsSL https://code-server.dev/install.sh | sh

# Install zsh and oh-my-zsh
RUN apt-get install -y zsh && \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"