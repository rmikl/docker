#!/bin/sh
# opencode web-server launcher.
#
# Uses `opencode serve`, NOT `opencode web`: `web` shells out to `xdg-open`
# to launch a local browser and crashes hard (uncaught ENOENT) when that
# binary doesn't exist, which it never does in this container (verified
# 2026-09-12 against ghcr.io/anomalyco/opencode:1.18.30 -- `web` crashed
# immediately with "Executable not found in $PATH: xdg-open"; `serve` came
# up clean and serves the identical web UI + API on the same port, per
# opencode's own docs: "opencode serve runs a headless HTTP server").
#
# --hostname 0.0.0.0: opencode binds 127.0.0.1 by default, same restriction
# dsh had. No sidecar proxy needed here, unlike dsh's Caddy sidecar --
# opencode accepts 0.0.0.0 directly via this flag.
set -eu

exec opencode serve --hostname 0.0.0.0 --port "${OPENCODE_PORT:-4096}"
