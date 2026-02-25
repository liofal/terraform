#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  $0 --target <ssh_target> --server-url <https://server:6443> --token-file <path> --version <k3s_version> --node-name <name> [--ssh-opts '<opts>']

Example:
  $0 --target root@192.168.1.207 \\
     --server-url https://192.168.1.201:6443 \\
     --token-file ./secrets/k3s_server_token \\
     --version v1.32.8+k3s1 \\
     --node-name k3sc2 \\
     --ssh-opts '-i ~/.ssh/id_ed25519_ansible'
USAGE
}

TARGET=""
SERVER_URL=""
TOKEN_FILE=""
VERSION=""
NODE_NAME=""
SSH_OPTS=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --server-url) SERVER_URL="$2"; shift 2 ;;
    --token-file) TOKEN_FILE="$2"; shift 2 ;;
    --version) VERSION="$2"; shift 2 ;;
    --node-name) NODE_NAME="$2"; shift 2 ;;
    --ssh-opts) SSH_OPTS="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [ -z "$TARGET" ] || [ -z "$SERVER_URL" ] || [ -z "$TOKEN_FILE" ] || [ -z "$VERSION" ] || [ -z "$NODE_NAME" ]; then
  usage
  exit 1
fi

if [ ! -f "$TOKEN_FILE" ]; then
  echo "ERROR: token file not found: $TOKEN_FILE" >&2
  exit 1
fi

TOKEN="$(tr -d '\n' < "$TOKEN_FILE")"
if [ -z "$TOKEN" ]; then
  echo "ERROR: token file is empty: $TOKEN_FILE" >&2
  exit 1
fi

# Skip installation if server already joined.
if ssh $SSH_OPTS "$TARGET" "sudo systemctl is-enabled k3s >/dev/null 2>&1"; then
  echo "k3s already installed on $TARGET, skipping"
  exit 0
fi

ssh $SSH_OPTS "$TARGET" \
  "INSTALL_K3S_VERSION='$VERSION' K3S_TOKEN='$TOKEN' sh -c 'curl -sfL https://get.k3s.io | sh -s - server --server $SERVER_URL --node-name $NODE_NAME'"

echo "Joined $TARGET as server node '$NODE_NAME'"
