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
