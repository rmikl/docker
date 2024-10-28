#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -xve

# Set default password if not provided
VNC_PASSWORD=${VNC_PASSWORD:-password}

# Create the VNC password file
mkdir -p /root/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

# Ensure .Xauthority exists
touch /root/.Xauthority
chmod 600 /root/.Xauthority

# Start the VNC server
vncserver :1 -geometry 1280x800 -depth 24 -httpport 5901