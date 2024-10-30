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

# Start the VNC server with specified depth, geometry, and font path
vncserver :1 -depth 32 -geometry 1280x800 -fp "/usr/share/fonts/X11/100dpi" -httpport 5901

# Keep container running by tailing VNC log
tail -f /root/.vnc/*.log