# mcpproxy + all stdio MCP servers in a single image.
#
# mcpproxy (static Go binary) aggregates 11 MCP servers:
#   - 6 stdio servers (argocd, azure-devops, doppler, kubernetes, proxmox,
#     ssh) are spawned in-process via npx (docker_isolation: none) — so this
#     image ships node + the 6 npm packages pre-installed.
#   - 5 remote servers (github, home-assistant, qnap, tavily, cloudflare-docs)
#     are reached over the network at runtime — no image dependency.
#
# The MCP config is mounted at runtime from a ConfigMap; secrets come via env.
FROM node:22-slim

# Fetch tooling for the mcpproxy release binary.
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates tar && \
    rm -rf /var/lib/apt/lists/*

# mcpproxy static Go binary (single file in the release tarball).
ARG MCPPROXY_VERSION=0.57.0
RUN curl -fsSL "https://github.com/smart-mcp-proxy/mcpproxy-go/releases/download/v${MCPPROXY_VERSION}/mcpproxy-${MCPPROXY_VERSION}-linux-amd64.tar.gz" -o /tmp/mcpproxy.tar.gz && \
    tar -xzf /tmp/mcpproxy.tar.gz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/mcpproxy && \
    rm /tmp/mcpproxy.tar.gz && \
    mcpproxy version

# Pre-install the stdio MCP servers so mcpproxy's `npx` resolves them locally
# (no runtime npm fetch when spawning tools).
#   argocd-mcp            ArgoCD
#   @azure-devops/mcp     Azure DevOps (bin: mcp-server-azuredevops), PAT auth
#   @dopplerhq/mcp-server Doppler
#   kubernetes-mcp-server Kubernetes (Go binary via npm optional dep)
#   proxmox-mcp-server    Proxmox
#   ssh-mcp               SSH
RUN npm install -g argocd-mcp @azure-devops/mcp @dopplerhq/mcp-server kubernetes-mcp-server proxmox-mcp-server ssh-mcp

# Config (ConfigMap mount) + writable data dir (activity log, telemetry id).
ENV MCPPROXY_CONFIG=/etc/mcpproxy/mcp_config.json \
    MCPPROXY_DATA_DIR=/data
RUN mkdir -p /etc/mcpproxy /data

WORKDIR /data
EXPOSE 8080

# litellm (separate pod) reaches this via the in-cluster Service on :8080.
ENTRYPOINT ["mcpproxy", "serve", "--listen", "0.0.0.0:8080", "--config", "/etc/mcpproxy/mcp_config.json", "--data-dir", "/data"]
