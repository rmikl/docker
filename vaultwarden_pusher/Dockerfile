# vaultwarden_pusher
#
# Syncs labeled k8s Secrets into a Vaultwarden/Bitwarden vault. Runs as a k8s
# CronJob (see argo-local). Built by the [Infra] Docker pipeline
# (pipelines/build.yaml) and pushed to Docker Hub as rmikl/vaultwarden_pusher.
#
# Base is debian (glibc) because the Bitwarden CLI is a self-contained .NET
# binary that requires glibc.
FROM debian:bookworm-slim

ARG BW_VERSION=2026.8.0
ARG KUBECTL_VERSION=v1.36.3

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash curl unzip jq ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Bitwarden CLI (bw) - handles all Bitwarden/Vaultwarden crypto.
RUN curl -fsSL "https://github.com/bitwarden/clients/releases/download/cli-v${BW_VERSION}/bw-linux-${BW_VERSION}.zip" -o /tmp/bw.zip \
    && unzip -o /tmp/bw.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/bw \
    && rm /tmp/bw.zip

# kubectl - reads the k8s Secrets using the in-pod ServiceAccount token.
RUN curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# bw stores its config (server URL, session) under $HOME.
ENV HOME=/root

COPY vaultwarden_push.sh /vaultwarden_push.sh
RUN chmod +x /vaultwarden_push.sh

ENTRYPOINT ["/vaultwarden_push.sh"]
