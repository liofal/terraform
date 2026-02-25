# k3s

## introduction 
This repository aims to provide some sort of provisioning automation to populate the LXC containers necessary for this setup
https://betterprogramming.pub/rancher-k3s-kubernetes-on-proxmox-containers-2228100e2d13

## prerequisites
- dns services enabled and configured on the proper search domain
- generating the lxc template is a prereq (contid: 100)
   - as of now, automation of lxc template is not yet implemented
   - follow here above steps to reach example (100.conf.example)

## disclaimer
this experiment is still ongoing and the result reached may not meet all the possible use cases of a k3s functionning cluster
I simplified the template to make it unprivileged, and limited the container to an unconfined profile but this container may still be a security breach on your setup
additionnaly it's possible that current limitation may affect the integration of other network functionalities like NFS

## in the future
- generate template with terraform
- initiate k3s clusters with cloud-init
- isolate into proper vlan
- management of remote tfstate file

## preparation
- prepare proxmox api token
    - create a terraform service user with the proxmox ve Authorization service
    - make sure the user has the proper permissions
        - For more information, refer to [this online guide](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs).
    - create an api token linked to the user, make sure to preserver the permissions, or propagate them manually

### Proxmox ACL baseline for Terraform (minimal and strict)

Use a dedicated role bound to your group on `/`.

Proxmox 9+:

```bash
pveum role add TerraformProvisioner -privs "Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Pool.Audit Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt SDN.Use"
```

Proxmox 8 and older (same as above, plus `VM.Monitor`):

```bash
pveum role add TerraformProvisioner -privs "Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Pool.Audit Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Migrate VM.PowerMgmt SDN.Use"
```

If the role already exists, replace `role add` with `role modify`.

Create/assign group and ACL:

```bash
pveum group add terraformprovisioner
pveum user modify terraform@pve -group terraformprovisioner
pveum aclmod / -group terraformprovisioner -role TerraformProvisioner
```

Create token inheriting user/group ACLs (important):

```bash
pveum user token add terraform@pve terraform --privsep 0
```

If token already exists:

```bash
pveum user token modify terraform@pve terraform --privsep 0
```

Quick checks:

```bash
pveum user token list terraform@pve
pveum user permissions terraform@pve
```

## installation
- adapt .env.example into .env file adapted to your needs
- source .env
- terraform init
- terraform plan
- terraform apply (-auto-approve)

### on controller node

    curl -fsL https://get.k3s.io | sh -s - --disable traefik --node-name <controller-node>

    cat /var/lib/rancher/k3s/server/node-token

    cat /etc/rancher/k3s/k3s.yaml

### on worker nodes

    curl -fsL https://get.k3s.io | K3S_URL=https://<controller-node>:6443 K3S_TOKEN=<node_token> sh -s - --node-name <worker-node>

## HA controllers (embedded etcd)

By default, this stack provisions one controller (`k3sc1`) and workers.

To provision additional controller LXCs (`k3sc2`, `k3sc3`) for an HA-ready topology:

```bash
export TF_VAR_k3s_ha_enabled=true
terraform plan
terraform apply
```

Controller sizing can be tuned independently from workers:

```bash
export TF_VAR_controller_cores=2
export TF_VAR_controller_memory_mb=4096
```

API endpoint options:
- Preferred: `k3s-api.<domain>` -> single VIP/LB IP.
- Temporary lab mode: DNS round-robin (`A` records to all controller IPs) with low TTL.

Notes:
- This Terraform stack provisions LXCs only.
- K3s HA still requires server bootstrap/join with embedded etcd.
- Use the runbook `HA_MIGRATION.md` for migration and validation.

Recommended bootstrap order:
1. Start `k3sc1` as first server with `--cluster-init` (and optional `--tls-san <stable-api-endpoint>`).
2. Join `k3sc2` and `k3sc3` as server nodes (`K3S_URL=https://<stable-api-endpoint>:6443`).
3. Point workers/agents to the same stable API endpoint.
4. Validate quorum and health before maintenance operations.
