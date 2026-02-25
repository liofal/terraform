# Major LXC Template Upgrade Runbook (Worker Canary)

This runbook is for major base-image upgrades (example: Rocky 9 -> Rocky 10 template) with minimal risk.

## Scope and assumptions

- Terraform provisions LXC containers on Proxmox.
- Ansible performs K3s node join/cutover actions.
- Workloads are resilient to one worker drain at a time.
- Worker rootfs content is disposable (recreate destroys local state).

## 1. Build and register the new LXC template

In the Ansible repo, build a Rocky 10 template on Proxmox first:

```bash
ansible-playbook proxmox/playbook-build-rockylinux10-lxc-template.yaml \
  -e k3s_template_vmid=120
```

Then point Terraform workers to that template VMID:

```bash
export TF_VAR_worker_clone_template=120
```

Do not recreate existing workers yet.

## 2. Provision a temporary canary worker

Enable the extra canary node:

```bash
export TF_VAR_k3s_canary_worker_enabled=true
export TF_VAR_canary_worker_hostname=k3sw6
export TF_VAR_canary_worker_ip_cidr=192.168.1.210/24
export TF_VAR_canary_worker_hwaddr=7A:00:00:00:04:10
export TF_VAR_canary_worker_vmid=111

terraform plan
terraform apply
```

## 3. Join canary to cluster and validate

In the Ansible repo, add the canary host to `[k3s_workers]` with `pct_id` and `node_name`.

Join the canary only:

```bash
ansible-playbook k3s/playbook-join-k3s-worker.yaml \
  -e k3s_join_worker_host=k3sw6 \
  -e k3s_join_server_url=https://k3s-api.<domain>:6443
```

Run smoke checks:

```bash
ansible-playbook k3s/playbook-postcheck-k3s-upgrade.yaml
```

## 4. Canary cutover from one old worker

Move workload off one old worker:

```bash
ansible-playbook k3s/playbook-canary-worker-cutover.yaml \
  -e k3s_canary_old_worker_host=k3sw1 \
  -e k3s_canary_new_worker_host=k3sw6
```

Optional hard cutover (stop old agent + remove old node object):

```bash
ansible-playbook k3s/playbook-canary-worker-cutover.yaml \
  -e k3s_canary_old_worker_host=k3sw1 \
  -e k3s_canary_new_worker_host=k3sw6 \
  -e k3s_canary_stop_old_agent=true \
  -e k3s_canary_delete_old_node=true
```

## 5. Recreate workers one by one on new template

After canary validation, rotate each original worker serially.

Example for `k3s-worker1` Terraform resource:

```bash
terraform taint proxmox_lxc.k3s-worker1
terraform apply
```

Then re-join that recreated worker and postcheck before moving to the next.

Repeat one worker at a time to preserve capacity and rollback options.

## 6. Cleanup canary

When all standard workers are upgraded, remove the temporary canary:

```bash
export TF_VAR_k3s_canary_worker_enabled=false
terraform plan
terraform apply
```

Also remove canary inventory entry from Ansible.

## Rollback guidance

- If canary validation fails, keep existing workers unchanged and destroy only the canary.
- If a worker recreate fails, stop and recover that single node before proceeding.
- Keep Proxmox snapshots for critical controller nodes before major platform changes.
