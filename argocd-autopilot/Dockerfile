# Start from Ubuntu 22.04 base image
FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Install Argo CD Autopilot
RUN curl -sSL -o /usr/local/bin/argocd-autopilot "https://github.com/argoproj-labs/argocd-autopilot/releases/latest/download/argocd-autopilot-linux-amd64" \
 && chmod +x /usr/local/bin/argocd-autopilot

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint to the autopilot script
ENTRYPOINT ["/entrypoint.sh"]