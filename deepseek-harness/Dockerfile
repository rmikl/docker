# DeepSeek Harness (dsh) web UI.
#
# `dsh web` binds 127.0.0.1 only (0.0.0.0 is rejected by design), so the pod
# runs a caddy sidecar that fronts it on 0.0.0.0:80 — see the k8s manifests
# in argo-local (apps/sites/deepseek-harness).
#
# Persistence: $DSH_HOME (sessions, credentials, settings) lives on a PVC
# mounted at /data; the agent's working directory is /workspace (same PVC).
FROM node:22-slim

# dsh requires node ^22.19 || >=24; node:22-slim tracks the latest 22.x.
# Pin the version — the package is pre-release and floats.
RUN npm install -g @deepseek-ai/dsh@0.1.1-rc.2

# Basic Linux debugging tools available to the model/user inside the
# container: curl/wget (HTTP), net-tools (netstat), iproute2 (ip/ss),
# iputils-ping (ping), dnsutils (dig/nslookup), procps (ps/top), less,
# python3 (+ pip, venv) to run Python scripts, sshpass for password-auth SSH,
# git + gh (GitHub CLI, official apt repo -- not in Debian's) for the
# PVC-local repo clones (see repo-sync-configmap.yaml in argo-local).
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    net-tools \
    iproute2 \
    iputils-ping \
    dnsutils \
    procps \
    less \
    python3 \
    python3-pip \
    python3-venv \
    sshpass \
    git \
    ca-certificates \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# DSH_HOME: harness home on the PVC. Telemetry: any non-empty value disables
# the OTel session-telemetry row (privacy switch prefers off-by-mistake).
ENV DSH_HOME=/data/.dsh \
    DSH_TELEMETRY_DISABLED=1

# /data and /workspace must exist and be writable by the non-root node user
# before the PVC is mounted over them.
RUN mkdir -p /data /workspace && chown -R node:node /data /workspace

USER node
WORKDIR /workspace
EXPOSE 3080

COPY --chown=node:node entrypoint.sh /usr/local/bin/dsh-entrypoint
ENTRYPOINT ["dsh-entrypoint"]
