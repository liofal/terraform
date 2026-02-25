# K3s HA Migration Runbook (Single Server -> Embedded etcd)

This runbook is for the current topology:
- `k3sc1` (existing controller)
- `k3sc2` and `k3sc3` (new controllers)

## 1. Preflight

On `k3sc1`:

```bash
sudo k3s -v
sudo test -d /var/lib/rancher/k3s/server/db/etcd && echo etcd || echo sqlite
sudo k3s kubectl get nodes -o wide
```

Take Proxmox snapshots before control-plane changes:

```bash
pct snapshot 103 pre-ha-migration
pct snapshot 108 pre-ha-migration
pct snapshot 107 pre-ha-migration
```

## 2. Capture active token and version

From this repo, save the active server token:

```bash
./scripts/ha_capture_token.sh root@192.168.1.201 ./secrets/k3s_server_token
```

Keep this token in your secret store. It is required for disaster recovery/restore.

## 3. Convert single-node sqlite to embedded etcd (only if sqlite)

K3s supports conversion by restarting the existing server with `--cluster-init`.

On `k3sc1`:

```bash
sudo mkdir -p /etc/rancher/k3s
sudo tee /etc/rancher/k3s/config.yaml >/dev/null <<'YAML'
cluster-init: true
YAML
sudo systemctl restart k3s
```

Validate etcd is active:

```bash
sudo test -d /var/lib/rancher/k3s/server/db/etcd && echo "etcd enabled"
sudo k3s kubectl get nodes -o wide
```

## 4. Join additional controller servers

Use same version as `k3sc1` and same token file:

```bash
./scripts/ha_join_server.sh \
  --target root@192.168.1.207 \
  --server-url https://192.168.1.201:6443 \
  --token-file ./secrets/k3s_server_token \
  --version <same-as-k3sc1> \
  --node-name k3sc2

./scripts/ha_join_server.sh \
  --target root@192.168.1.208 \
  --server-url https://192.168.1.201:6443 \
  --token-file ./secrets/k3s_server_token \
  --version <same-as-k3sc1> \
  --node-name k3sc3
```

## 5. Validate quorum and control-plane health

On any controller:

```bash
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl get pods -n kube-system -o wide
sudo k3s etcd-snapshot save --name post-ha-$(date +%F)
```

Expected:
- 3 servers in `Ready` state
- `etcd` datastore in use

## 6. Stabilize API endpoint (recommended)

Move server registration from `k3sc1` IP to a stable endpoint (VIP/LB), then update join configs and kubeconfigs.

## 7. Rollback path

If migration fails:
1. Stop k3s on affected controllers.
2. Restore Proxmox snapshots on `103`, `108`, `107`.
3. Start `k3sc1` only, verify cluster health.

## Notes

- Ensure critical K3s server flags remain consistent across all server nodes.
- Never store `./secrets/k3s_server_token` in git.
