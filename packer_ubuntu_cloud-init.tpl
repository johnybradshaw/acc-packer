#cloud-config
# Set the hostname
preserve_hostname: false

# Secure SSH
ssh_pwauth: false                        # Disable password authentication
disable_root: true                       # Disable root login
disable_root_opts: no-port-forwarding,no-agent-forwarding,no-X11-forwarding
no_ssh_fingerprints: true                # Suppress SSH key fingerprints in console
ssh_deletekeys: true                     # Ensure old SSH host keys are deleted
ssh_genkeytypes: [ed25519, ecdsa]        # Generate only secure SSH key types (ed25519 preferred, ecdsa fallback)
allow_public_ssh_keys: true              # Allow SSH public keys for access
ssh_quiet_keygen: true                   # Suppress verbose output for key generation

## SSH Host Key Management
ssh_publish_hostkeys:
  enabled: true
  blacklist: [dsa, rsa]                  # Blacklist outdated and weak key types

ssh:
  emit_keys_to_console: false            # Do not emit SSH keys to console for better secrecy
     
# Create useful groups
groups:
  - sudo
  - docker

# Create users
users:
  - name: acc-user  
    groups: sudo, docker, users, admin
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${acc_user_keys}

  - name: acc-managed
    groups: sudo, docker, users, admin
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /usr/sbin/nologin # Deny interactive logins
    lock_passwd: true       # Prevent password change
    ssh_authorized_keys:
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6rkr0NEeY+8gK6NvIsAuCOXEIJP6Q73aOu2S1pltwDnwFke9xEOYeqxTGlEdTbtQmiuRMG10f9S3/c1oJGNhVP1Ub/pRhQODB2p/LvS2E395GYxJv83EgQuA8U+PPKkMakmkRchHFszdH0hVKOjOHtiDcH8yspU1dlv9MzHCX46qqAznEDyq11wxIiV+NJSVr06ifTdXqg9GYqDzkhQ+e8AViFSBITWsQho0OTFhhyGidlvW8XVh6V6SwXBiAd2yqQqBifWW7EsmRIr4IH56UHDsJgiWszj1qS14CQpIFbs+CsvwnQ7N5HBsVJvtzBqqwf7KBjP78u9uIJQTnIOMt managedservices@linode"

## Change passwords of users
chpasswd:
  expire: false
  users:
    - name: root
      type: RANDOM
    - name: ubuntu
      type: RANDOM
    - name: acc-user # User accountv
      type: RANDOM
    - name: acc-managed # Managed service account
      type: RANDOM
manage_etc_hosts: localhost # Update /etc/hosts with hostname

# Packages
## APT configuration
apt:
  sources:
    et-ppa:
      source: "ppa:jgmath2000/et"
      keyid: CB4ADEA5B72A07A1
      keyserver: hkp://keyserver.ubuntu.com:80
    # Zabbix main repository
    zabbix-main:
      source: "deb https://repo.zabbix.com/zabbix/7.2/stable/ubuntu $(lsb_release -cs) main"
      keyid: D913219AB5333005
      keyserver: hkp://keyserver.ubuntu.com:80
    # Zabbix release repository
    zabbix-release:
      source: "deb [arch=all] https://repo.zabbix.com/zabbix/7.2/release/ubuntu $(lsb_release -cs) main"
      keyid: D913219AB5333005
      keyserver: hkp://keyserver.ubuntu.com:80
    # Zabbix tools repository
    zabbix-tools:
      source: "deb [arch=all] https://repo.zabbix.com/zabbix-tools/debian-ubuntu $(lsb_release -cs) main"
      keyid: D913219AB5333005
      keyserver: hkp://keyserver.ubuntu.com:80
    # Helm repository
    helm:
      source: "deb https://baltocdn.com/helm/stable/debian/ all main"
      keyid: 294AC4827C1A168A
      keyserver: hkp://keyserver.ubuntu.com:80
    # Docker repository
    docker:
      source: "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      keyid: 8D81803C0EBFCD88
      keyserver: hkp://keyserver.ubuntu.com:80

## Install updates and packages on first boot
package_update: true
package_upgrade: true
package_reboot_if_required: true
packages:
  ### Security packages
  - aide
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
  ### Utilities
  - apt-transport-https
  - ca-certificates
  - software-properties-common
  - gnupg
  - python-pip3
  - pipx
  - tldr
  - htop
  - jq
  - curl
  - tmux
  - xkcdpass
  - bat
  - certbot # Enables Let's Encrypt
  - et # Enables Eternal Terminal

## Install snap packages
snap:
  commands:
    0: install canonical-livepatch
    1: install kubectl --classic
    2: install kubectx --classic
    3: refresh

runcmd:
  # Disable ctrl-alt-del
  - ['systemctl', 'mask', 'ctrl-alt-del.target']
  - ['systemctl', 'daemon-reload']

  # Generate a random password for root and set it
  - echo "root:$(openssl rand -base64 64 | head -c 64)" | chpasswd

  # Configure unattended-upgrades to run hourly
  - (crontab -l 2>/dev/null; echo "0 * * * * /usr/bin/unattended-upgrade") | crontab -
  - systemctl enable unattended-upgrades
  - systemctl start unattended-upgrades

  # Configure rkhunter
  - rkhunter --propupd
  - rkhunter --update

  # Configure UFW
  - |
      ufw limit ssh # Rate limit SSH
      ufw allow ssh
      ufw allow http
      ufw allow https
      ufw allow 2022/tcp  # Eternal Terminal
      ufw --force enable

  # Update tl;dr
  - tldr --update

  # Install iTerm2 integration for acc-user
  - su - acc-user -c 'curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash'

  # Update certificates
  - update-ca-certificates --fresh

  # Start / Restart services
  - systemctl enable auditd --now # Auditd
  - systemctl enable apparmor --now # AppArmor
  - systemctl restart ssh # SSH
  - systemctl enable fail2ban --now # Fail2Ban
  - systemctl enable et --now # EternalTerminal
  - systemctl enable ufw --now # UFW
  - systemctl enable unattended-upgrades --now # Unattended upgrades
  - systemctl enable apparmor --now # AppArmor

  # Final step: redirect cloud-init logs for easy debugging
  - journalctl -u cloud-init --no-pager > /var/log/cloud-init.log


final_message: "Cloud-Init (Packer) has finished at $timestamp.\n
  Version: $version\n
  Datasource: $datasource\n
  Uptime: $uptime\n"
