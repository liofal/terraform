#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <ssh_target> <output_file> [ssh_options]"
  echo "Example: $0 root@192.168.1.201 ./secrets/k3s_server_token '-i ~/.ssh/id_ed25519_ansible'"
  exit 1
fi

SSH_TARGET="$1"
OUTPUT_FILE="$2"
SSH_OPTS="${3:-}"

mkdir -p "$(dirname "$OUTPUT_FILE")"

TOKEN="$(ssh $SSH_OPTS "$SSH_TARGET" "sudo cat /var/lib/rancher/k3s/server/token")"
VERSION="$(ssh $SSH_OPTS "$SSH_TARGET" "sudo k3s -v | head -n1")"

if [ -z "$TOKEN" ]; then
  echo "ERROR: empty token returned from $SSH_TARGET" >&2
  exit 1
fi

printf '%s\n' "$TOKEN" > "$OUTPUT_FILE"
chmod 600 "$OUTPUT_FILE"

echo "Token saved to $OUTPUT_FILE"
echo "Server version: $VERSION"
