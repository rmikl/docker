#!/bin/bash
#
# vaultwarden_push.sh
#
# Syncs labeled k8s Secrets into a Vaultwarden/Bitwarden vault. Designed to run
# as a k8s CronJob. For each Secret selected by LABEL_SELECTOR it upserts a
# Bitwarden "login" item named "<ITEM_PREFIX><namespace>/<secret-name>":
#   - the `username` / `password` keys (if present) map to the item fields,
#   - every key/value pair is written into the item notes (nothing is lost).
#
# Requires the Bitwarden CLI (bw) >= 2023.x, which uses the encoded-JSON
# `create item` / `edit item` / `list items` syntax (the older
# `create login <name> --username ...` flag syntax was removed upstream).
#
# Env:
#   BW_EMAIL        (required) Vaultwarden account email
#   BW_PASSWORD     (required) Vaultwarden master password
#   BW_HOST         (optional) default https://bt.rmikl.pl
#   NAMESPACES      (optional) space-separated namespaces; default = all non-system
#   LABEL_SELECTOR  (optional) default vaultwarden-sync/enabled=true
#   ITEM_PREFIX     (optional) default k8s/
#   DRY_RUN         (optional) "true" = log only, do not write to Bitwarden

set -euo pipefail

BW_HOST="${BW_HOST:-https://bt.rmikl.pl}"
BW_EMAIL="${BW_EMAIL:?BW_EMAIL is required}"
BW_PASSWORD="${BW_PASSWORD:?BW_PASSWORD is required}"
NAMESPACES="${NAMESPACES:-}"
LABEL_SELECTOR="${LABEL_SELECTOR:-vaultwarden-sync/enabled=true}"
ITEM_PREFIX="${ITEM_PREFIX:-k8s/}"
DRY_RUN="${DRY_RUN:-false}"
nl=$'\n'   # newline, used as the jsonpath range separator

log() { echo "[$(date -u +%H:%M:%S)] $*"; }

# ---- Authenticate -----------------------------------------------------------
# `bw login` authenticates but leaves the vault locked; `bw unlock` returns a
# NEW session key and invalidates the login one. So we adopt the unlock key as
# BW_SESSION for every subsequent vault operation.
bw config server "$BW_HOST"
if ! BW_SESSION=$(bw login "$BW_EMAIL" --passwordenv BW_PASSWORD --raw); then
  log "ERROR: login to $BW_HOST failed (check BW_EMAIL / BW_PASSWORD)"
  exit 1
fi
if ! BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw); then
  log "ERROR: vault did not unlock"
  exit 1
fi
export BW_SESSION
log "Authenticated to $BW_HOST as $BW_EMAIL"

# ---- Fetch existing items once (for upsert matching by name) ----------------
all_items=$(bw list items --raw 2>/dev/null | jq 'if type=="array" then . else (.data // []) end')

find_item_id() {
  echo "$all_items" | jq -r --arg n "$1" '.[] | select(.name == $n) | .id' | head -1
}

# ---- Namespaces to scan -----------------------------------------------------
if [ -z "$NAMESPACES" ]; then
  ns_list=$(kubectl get namespaces -o jsonpath="{range .items[*]}{.metadata.name}${nl}{end}")
else
  ns_list=$NAMESPACES
fi

total=0; created=0; updated=0; skipped=0; errors=0

for ns in $ns_list; do
  case "$ns" in
    kube-system|kube-public|kube-node-lease) continue ;;
  esac

  secret_names=$(kubectl get secrets -n "$ns" -l "$LABEL_SELECTOR" \
    -o jsonpath="{range .items[*]}{.metadata.name}${nl}{end}" 2>/dev/null) || continue
  [ -z "$secret_names" ] && continue

  while IFS= read -r sname; do
    [ -z "$sname" ] && continue
    total=$((total+1))
    item_name="${ITEM_PREFIX}${ns}/${sname}"

    # Decode all data entries to plaintext key/value JSON.
    kv_json=$(kubectl get secret "$sname" -n "$ns" -o json \
      | jq '.data // {} | with_entries(.value |= @base64d)')

    if [ "$(echo "$kv_json" | jq 'length')" -eq 0 ]; then
      log "SKIP $item_name (empty)"
      skipped=$((skipped+1)); continue
    fi

    notes=$(echo "$kv_json" | jq -r 'to_entries | map(.key + ": " + .value) | join("\n")')
    username=$(echo "$kv_json" | jq -r '.username // empty')
    password=$(echo "$kv_json" | jq -r '.password // empty')

    if [ "$DRY_RUN" = "true" ]; then
      log "DRY-RUN upsert $item_name (keys=$(echo "$kv_json" | jq 'length'), username=${username:-<none>})"
      continue
    fi

    # Build the item as base64-encoded JSON (bw create/edit item syntax).
    item_json=$(jq -cn \
      --arg name "$item_name" \
      --arg username "$username" \
      --arg password "$password" \
      --arg notes "$notes" \
      '{name: $name, type: 1, login: {username: $username, password: $password}, notes: $notes}')
    encoded=$(printf '%s' "$item_json" | base64 -w0)

    existing_id=$(find_item_id "$item_name")
    if [ -n "$existing_id" ]; then
      if bw edit item "$existing_id" "$encoded" >/dev/null 2>&1; then
        log "UPDATED $item_name"
        updated=$((updated+1))
      else
        log "ERROR updating $item_name"
        errors=$((errors+1))
      fi
    else
      if bw create item "$encoded" >/dev/null 2>&1; then
        log "CREATED $item_name"
        created=$((created+1))
      else
        log "ERROR creating $item_name"
        errors=$((errors+1))
      fi
    fi
  done <<< "$secret_names"
done

bw logout >/dev/null 2>&1 || true
log "Done: total=$total created=$created updated=$updated skipped=$skipped errors=$errors"
[ "$errors" -eq 0 ] || exit 1
