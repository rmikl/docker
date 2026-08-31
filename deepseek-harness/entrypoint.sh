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
# Space-separated list of extra --patch overlay paths (e.g. a ConfigMap-
# mounted cordis.yml bridging the in-cluster mcpproxy gateway). Deployment
# concern, not baked into the image, so this image stays runnable standalone.
for patch in ${DSH_PATCH_FILES:-}; do
  args="$args --patch $patch"
done
# shellcheck disable=SC2086
exec dsh $args
