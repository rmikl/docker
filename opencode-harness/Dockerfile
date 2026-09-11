# OpenCode web UI, replacing the deepseek-harness (dsh) pod.
#
# Base image (ghcr.io/anomalyco/opencode) is Alpine + a single static Bun
# binary at /usr/local/bin/opencode, plus ripgrep and wget. No git, no
# node, no curl, no shell tools beyond busybox. That's deliberate on
# upstream's part -- this pod adds back exactly what our agent workflow
# needs and nothing more:
#   - rtk: token-optimizing wrapper the agent's own plugin rewrites bash
#     commands through (see rtk-plugin.ts, seeded onto the PVC by the
#     init-config initContainer, not baked in here -- same "seed once,
#     then PVC wins" pattern dsh used for settings.yaml). Local model
#     runs at ~70 tok/s prefill -- every unfiltered `cat`/`grep -r` is
#     measurable wall clock.
#
# Deliberately NOT added (unlike the old dsh image):
#   - git / gh / ssh: repo-sync and the self-update push path are being
#     dropped in this migration (decision 2026-09-12) -- opencode has no
#     equivalent watchdog/self-push mechanism and none is being built for
#     it. All cluster/GitHub access goes through the mcpproxy MCP gateway
#     instead (kubernetes/github/ssh MCP servers), not local CLI calls.
#   - node/npm/npx: mcpproxy runs the stdio MCP servers (argocd, doppler,
#     kubernetes, proxmox, ssh) in its OWN pod (apps/infra/mcpproxy), not
#     here. This pod only ever makes one outbound MCP connection: to
#     mcpproxy's HTTP endpoint. No local subprocess spawning needed.
FROM ghcr.io/anomalyco/opencode:1.18.30

# rtk: static Rust binary, no npm/apt package exists. musl x86_64 build
# matches this Alpine base exactly (no GLIBC version mismatch to worry
# about, unlike the old node:22-slim/bookworm dsh image). All cluster
# nodes are amd64 (verified 2026-09-12) -- if that ever changes, the
# aarch64-unknown-linux-gnu release asset needs `gcompat` installed first,
# since Alpine has no native glibc.
ARG RTK_VERSION=0.49.0
RUN wget -qO /tmp/rtk.tar.gz \
      "https://github.com/rtk-ai/rtk/releases/download/v${RTK_VERSION}/rtk-x86_64-unknown-linux-musl.tar.gz" && \
    tar -xzf /tmp/rtk.tar.gz -C /usr/local/bin rtk && \
    rm /tmp/rtk.tar.gz && \
    chmod 0755 /usr/local/bin/rtk && \
    rtk --version

# Everything persistent (opencode.json, plugins/, agents/, session data,
# logs) lives under $HOME on the PVC. Setting HOME=/data makes opencode's
# own XDG-based paths (~/.config/opencode, ~/.local/share/opencode,
# ~/.cache/opencode) all land there automatically -- one bind mount
# covers config + state, same as dsh's single $DSH_HOME did. The actual
# opencode.json / rtk plugin files are seeded onto this PVC by a k8s
# initContainer (see statefulset.yaml init-config), not baked into the
# image, so they can be hand-edited on the PVC between deploys without a
# rebuild -- exactly the "seed once, PVC wins after" pattern dsh used.
ENV HOME=/data
WORKDIR /workspace
EXPOSE 4096

COPY --chown=root:root entrypoint.sh /usr/local/bin/opencode-entrypoint
RUN chmod 0755 /usr/local/bin/opencode-entrypoint \
    && mkdir -p /workspace

ENTRYPOINT ["opencode-entrypoint"]
