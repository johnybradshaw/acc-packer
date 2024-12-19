#cloud-config
## Create users
users:
  - name: acc-user  
    groups: sudo, docker, users, admin
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys: ${ acc_user_keys }

## Prevent password change on first login
chpasswd:
  expire: false