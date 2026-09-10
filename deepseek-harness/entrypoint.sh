#!/bin/sh
# dsh web launcher. The web server binds 127.0.0.1 (0.0.0.0 is rejected by
# design); the pod's caddy sidecar fronts it on 0.0.0.0:80.
set -eu

# Self-update push path (see argo-local
# apps/media/deepseek-harness/additional-k8s-objects/agents-md-configmap.yaml,
# "Self-update" section, for the full rationale):
#   - core.hooksPath: repo-agnostic, applies under every mirror in
#     /workspace/repos without per-repo setup. pre-push enforces the Tier
#     A/B split (direct push vs branch+PR) by inspecting the remote URL.
#   - credential.helper "": explicitly cleared first so nothing else on the
#     image (or set by a future session) can silently cache GH_TOKEN in a
#     credential store file on the PVC.
#   - GIT_ASKPASS: supplies the token fresh from the GH_TOKEN env var on
#     every push, so it's never written to disk (not in the remote URL, not
#     in a credential store).
# All three are idempotent global git config -- safe to run on every start.
git config --global core.hooksPath /usr/local/lib/dsh-git-hooks
git config --global credential.helper ""
export GIT_ASKPASS=/usr/local/lib/dsh-git-askpass.sh

# Space-separated list of cordis patch overlays (DSH_PATCH_FILES), each passed
# as its own repeatable `--patch <path>`. Without these the mounted overlays
# are inert: verified 2026-09-10 that `dump-config` showed 0 mcpproxy entries
# and no subagent agentOptions until the flags were passed, i.e. the
# in-cluster MCP gateway and the Spark subagent routing were both silently
# doing nothing while the manifests looked correct.
#
# NOTE ON THE INVOCATION FORM. `--patch` is a LAUNCHER flag and cannot be
# combined with the `web` SUBCOMMAND -- dsh rejects that outright:
#
#     error: web takes none of parent --profile, --patch, --dump-config,
#            or --dump-default-config
#
# (image 1.0.763 shipped `dsh --patch ... web ...` and CrashLooped on exactly
# this.) The two equivalent spellings are `dsh web <app args>` and
# `dsh --profile web <app args>`; only the latter accepts --patch, so the
# entrypoint always uses the --profile form. Everything after the profile
# selection is forwarded to the web app.
launcher=""
for patch in ${DSH_PATCH_FILES:-}; do
  if [ -f "$patch" ]; then
    launcher="$launcher --patch $patch"
  else
    echo "entrypoint: WARNING: DSH_PATCH_FILES entry not found, skipping: $patch" >&2
  fi
done

args="--no-open --port ${DSH_WEB_PORT:-3080}"
# Space-separated list of Host-header authorities accepted by the /api
# browser-trust fence (e.g. "dsh.rmikl.pl").
for host in ${DSH_TRUSTED_HOSTS:-}; do
  args="$args --trusted-host $host"
done
# shellcheck disable=SC2086
exec dsh --profile web $launcher $args
