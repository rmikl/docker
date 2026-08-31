#!/bin/sh
# dsh web launcher. The web server binds 127.0.0.1 (0.0.0.0 is rejected by
# design); the pod's caddy sidecar fronts it on 0.0.0.0:80.
set -eu

# --patch is a launcher flag (root `dsh --profile <name> --patch <path>`),
# not accepted by the `dsh web` alias in the currently pinned dsh version
# (0.1.1-rc.2 ships --patch on the root command but not on the web
# subcommand's own option list) -- so patches use `--profile web` explicitly
# instead of the `web` alias whenever DSH_PATCH_FILES is set.
if [ -n "${DSH_PATCH_FILES:-}" ]; then
  args="--profile web"
  # Space-separated list of extra --patch overlay paths (e.g. a ConfigMap-
  # mounted cordis.yml bridging the in-cluster mcpproxy gateway). Deployment
  # concern, not baked into the image, so this image stays runnable standalone.
  for patch in ${DSH_PATCH_FILES}; do
    args="$args --patch $patch"
  done
else
  args="web"
fi
args="$args --no-open --port ${DSH_WEB_PORT:-3080}"
# Space-separated list of Host-header authorities accepted by the /api
# browser-trust fence (e.g. "dsh.rmikl.pl").
for host in ${DSH_TRUSTED_HOSTS:-}; do
  args="$args --trusted-host $host"
done
# shellcheck disable=SC2086
exec dsh $args
