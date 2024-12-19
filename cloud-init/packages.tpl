#cloud-config
## Install updates and packages on  boot
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
  - fastfetch
  - certbot # Enables Let's Encrypt
  - et # Enables Eternal Terminal