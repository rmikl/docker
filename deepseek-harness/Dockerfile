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
# Pin the version — the package is pre-release and floats. 0.1.2-rc.1 is the
# npm `latest` dist-tag; the `alpha` tag (0.1.5-alpha.x) is deliberately not
# used here, this pod is the operator's daily driver.
RUN npm install -g @deepseek-ai/dsh@0.1.2-rc.1

# git: node:22-slim ships without it. Needed for the PVC-local repo mirrors
# (repo-sync-configmap.yaml) and for dsh's own self-update push path (see
# git-hooks/pre-push, git-askpass.sh, and entrypoint.sh's git config).
# ca-certificates: required for HTTPS git push/fetch to github.com.
# curl/tar: fetch the rtk release tarball below.
RUN apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates curl tar && \
    rm -rf /var/lib/apt/lists/*

# rtk — token-optimizing wrapper around ls/read/grep/git/kubectl/... The agent
# in this pod runs against a local model at ~70 tok/s prefill, so every
# unfiltered `cat`/`git log` in its context is measurable wall clock. Shipped
# as a single static binary from the upstream release (there is no npm/apt
# package). The musl x86_64 build is used deliberately: the amd64 gnu build
# needs GLIBC_2.39 and node:22-slim is bookworm (2.36). This image is built
# amd64-only by the pipeline.
ARG RTK_VERSION=0.48.0
RUN curl -fsSL "https://github.com/rtk-ai/rtk/releases/download/v${RTK_VERSION}/rtk-x86_64-unknown-linux-musl.tar.gz" \
      | tar -xz -C /usr/local/bin rtk && \
    chmod 0755 /usr/local/bin/rtk && \
    rtk --version

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
COPY --chown=node:node git-hooks/pre-push /usr/local/lib/dsh-git-hooks/pre-push
COPY --chown=node:node git-askpass.sh /usr/local/lib/dsh-git-askpass.sh
# Explicit chmod rather than relying on the git-recorded file mode: files
# added via the GitHub Contents API (as these were) land as 100644
# regardless of local intent, silently dropping the execute bit that
# ENTRYPOINT and git's pre-push hook both require to run at all. Making
# this explicit means it can't regress the same way again no matter how a
# future edit gets into the repo.
USER root
RUN chmod 0755 /usr/local/bin/dsh-entrypoint \
                /usr/local/lib/dsh-git-hooks/pre-push \
                /usr/local/lib/dsh-git-askpass.sh
USER node
ENTRYPOINT ["dsh-entrypoint"]
