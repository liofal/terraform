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
    - create a terraform user with the proxmox ve Authorization service
    - make sure the user has the proper permissions
        - For more information, refer to [this online guide](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs).
    - create an api token linked to the user, make sure to preserver the permissions, or propagate them manually

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