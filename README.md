# acc-packer

This repo can help prepare a base VM image (Ubuntu 24.04 LTS) on the [Akamai Connected Cloud](https://www.akamai.com/solutions/cloud-computing) (aka Linode).

## What does it do?

[Packer](https://developer.hashicorp.com/packer/plugins/builders/linode) will build a Virtual Machine, run `cloud-init` to configure, and then package the resulting build as an [Image](https://www.linode.com/docs/products/tools/images/) to be used on the Akamai Connected Cloud.

This will also apply some sensible security restrictions:

- SSH
  - Disables `root` login
  - Disables password login
  - Updates SSH presets
- Regenerate the random seed
- Installs anti-malware, file intergrity monitoring, and fail2ban
- Configure the firewall to only accept certain traffic (SSH/HTTP/HTTPS/Webmin)
- Automatically logout users connected to the 'psuedo-physical' terminal ([Weblish/Glish](https://www.linode.com/docs/products/compute/compute-instances/guides/lish/))
- Disable ctrl-alt-delete on the 'psuedo-physical' terminal ([Weblish/Glish](https://www.linode.com/docs/products/compute/compute-instances/guides/lish/))
- Installs the Akamai Connected Cloud managed user (remove if not using Managed Services)

## What is installed?

Several security packages and utilities are installed.

### Security Packages

- apparmor
- apparmor-profiles
- apparmor-utils
- auditd
- audispd-plugins
- fail2ban
- unattended-upgrades
- rkhunter
- clamav
- clamav-daemon
- clamav-freshclam
- ufw
- aide
- wireguard
- livepatch
- puppet

### Utilities

- docker
- neofetch
- tldr
- htop
- jq
- curl
- tmux
- webmin
- apache2
- certbot
- linode-cli

## How to use

Several sections need to be updated in order for the script to work correctly.

### Update `packer_ubuntu_cloud-init.yaml`

Update the following with your Tailscale key

```yaml
# Start Tailscale and register this node
--authkey=tskey-xxxxxxxxxxxxxxxxxxxxxxxxxx
```

Update the following with your Ubuntu Pro key

```yaml
ubuntu_advantage:
  token: ""
  ```

Update the non-root user's SSH key

```yaml
users:
  - name: acc-user  
    groups: sudo, docker, users, admin
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - "ssh-rsa <<PUBLIC KEY>>"
```

Update your Puppet configuration (if used)

```yaml
conf:
    agent:
      server: puppet.server.tld
    ca_cert: |
      -----BEGIN PUBLIC KEY-----
      MIICI...==
      -----END PUBLIC KEY-----
```

### Update `variables.pkrvars.hcl`

Rename `variables.pkvars.hcl.example` to `variables.pkvars.hcl` and update as appropriate, **do not** change the `instance_type`

```json
linode_instance = {
    region              = "fr-par"
    instance_type       = "g6-nanode-1"
    instance_label      = "packer-ubuntu24.04"
    image               = "linode/ubuntu24.04"
    image_label         = "ubuntu24.04-acc-packer-image"
    image_description   = "ubuntu24.04 - ACC Packer Image"
    linode_tags         = ["ubuntu24.04", "packer"]
    private_ip          = false
}
```

### Update `secret.pkvars.hcl`

Rename `secret.pkvars.hcl.example` to `secret.pkvars.hcl` and add your Linode Token, Authorised Users, and Authorised Keys as appropriate.

```json
# Secrets needed to run the build script
secrets = [
    linode_token    = "<<LINODE_TOKEN>>",
    authorized_users = [
        "<<AUTHORIZED_USER_1>>",
        "<<AUTHORIZED_USER_2>>"
    ],
    authorized_keys =  [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5A...",
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5A..."
    ]
]
```

## Create your image

Initialise the Packer environment:

```bash
packer init .
```

To begin your build run the following command:

```bash
packer build \
  -var-file="secret.pkrvars.hcl" \
  -var-file="variables.pkrvars.hcl" \
.
```

Once completed you can find it at <https://cloud.linode.com/images>
