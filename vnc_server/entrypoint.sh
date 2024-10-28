#!/bin/bash

# Set default password if not provided
VNC_PASSWORD=${VNC_PASSWORD:-password}

# Create the VNC password file
mkdir -p /root/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

# Execute the command
exec "$@"