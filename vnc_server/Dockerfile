# Use the official Ubuntu base image
FROM ubuntu:latest

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    apt-transport-https \
    wget \
    curl \
    gnupg2 \
    lsb-release \
    git \
    gnome-session \
    gnome-terminal \
    tightvncserver \
    xauth \
    dbus-x11 \
    xfonts-base \
    xfonts-75dpi \
    xfonts-100dpi \
    fonts-dejavu-core \
    libgtk-3-0

# Install Visual Studio Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    rm microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"' > /etc/apt/sources.list.d/vscode.list && \
    apt-get update && apt-get install -y code

# Install kubectl
ENV USER=root

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl 

# Set environment variables
ENV DISPLAY=:1

# Create the .vnc directory and set up the VNC xstartup script
RUN mkdir /root/.vnc && \
    echo "#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec gnome-session &" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Expose the VNC port
EXPOSE 5901

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
