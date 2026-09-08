# Watchdog for the deepseek-harness (dsh) self-update loop (see
# apps/media/deepseek-harness in argo-local: dsh-update-watchdog CronJob).
#
# Same base pattern as ../kubectl (ubuntu:24.04 + a single static kubectl
# binary), plus curl/jq for talking to the GitHub Contents API and the k8s
# API server. No git binary: the tag revert is a single-file
# get-modify-put over the GitHub Contents API, not a clone+commit+push, so
# there's no working tree to manage and no SSH/HTTPS git auth to wire up
# inside a CronJob pod.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq && \
    rm -rf /var/lib/apt/lists/*

ENV KUBECTL_VERSION=v1.30.3

RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    curl -LO "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl kubectl.sha256
