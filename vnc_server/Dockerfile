# W razie braku oficjalnego obrazu 24.04 możesz użyć:
# FROM ubuntu:24.04
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV VNC_RESOLUTION="1280x800"
ENV VNC_PASSWD="password"
ENV DISPLAY=":1"

# Instalacja podstawowych pakietów + pakiety VNC/NoVNC/xfce4
RUN apt-get update && apt-get install -y \
    xfce4 \
    tigervnc-standalone-server \
    novnc \
    python3-websockify \
    wget \
    git \
    xterm \
    supervisor \
    xkb-data \
    x11-xkb-utils \
    net-tools \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Instalacja Visual Studio Code z repozytorium Microsoftu
RUN wget -qO - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /usr/share/keyrings/ms_vscode_key.gpg > /dev/null \
 && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ms_vscode_key.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list \
 && apt-get update \
 && apt-get install -y code \
 && rm -rf /var/lib/apt/lists/*

# Instalacja Firefoksa (w Ubuntu 22.04 zazwyczaj jest to pakiet snap, ale istnieje również transitional package)
RUN apt-get update && apt-get install -y firefox && rm -rf /var/lib/apt/lists/*

# Skrypt uruchamiający VNC + noVNC
RUN mkdir -p /opt/scripts
RUN echo '#!/usr/bin/env bash' > /opt/scripts/startup.sh \
 && echo '' >> /opt/scripts/startup.sh \
 && echo '# Ustaw hasło do VNC (domyślnie: password)' >> /opt/scripts/startup.sh \
 && echo 'mkdir -p ~/.vnc' >> /opt/scripts/startup.sh \
 && echo "echo \"\$VNC_PASSWD\" | vncpasswd -f > ~/.vnc/passwd" >> /opt/scripts/startup.sh \
 && echo 'chmod 600 ~/.vnc/passwd' >> /opt/scripts/startup.sh \
 && echo '' >> /opt/scripts/startup.sh \
 && echo '# Start TigerVNC' >> /opt/scripts/startup.sh \
 && echo "vncserver \$DISPLAY -geometry \$VNC_RESOLUTION -depth 24" >> /opt/scripts/startup.sh \
 && echo '' >> /opt/scripts/startup.sh \
 && echo '# Uruchom noVNC' >> /opt/scripts/startup.sh \
 && echo 'websockify --web=/usr/share/novnc/ 0.0.0.0:6080 127.0.0.1:5901 &' >> /opt/scripts/startup.sh \
 && echo '' >> /opt/scripts/startup.sh \
 && echo '# Pozostaw proces "w tle" – tutaj w nieskończonej pętli' >> /opt/scripts/startup.sh \
 && echo 'tail -f /dev/null' >> /opt/scripts/startup.sh

RUN chmod +x /opt/scripts/startup.sh

# EXPOSE informacyjne (VNC i noVNC)
EXPOSE 5901 6080

CMD ["/opt/scripts/startup.sh"]