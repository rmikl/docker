#!/bin/sh
# dsh web launcher. The web server binds 127.0.0.1 (0.0.0.0 is rejected by
# design); the pod's caddy sidecar fronts it on 0.0.0.0:80.
set -eu

args="web --no-open --port ${DSH_WEB_PORT:-3080}"
# Space-separated list of Host-header authorities accepted by the /api
# browser-trust fence (e.g. "dsh.rmikl.pl").
for host in ${DSH_TRUSTED_HOSTS:-}; do
  args="$args --trusted-host $host"
done
# shellcheck disable=SC2086
exec dsh $args
