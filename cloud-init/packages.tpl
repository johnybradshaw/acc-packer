#cloud-config
## Install updates and packages on  boot
package_update: true # Update packages
package_upgrade: true # Upgrade packages
package_reboot_if_required: true # Reboot if required
packages:
  ### Security packages
  # - aide 
  - apparmor # apparmor is used for MAC
  - apparmor-profiles # apparmor-profiles is used for security
  - apparmor-utils # apparmor-utils is used for apparmor
  - auditd # auditd is used for audit logging
  - audispd-plugins # audispd-plugins is used for audit logging
  - fail2ban # fail2ban is used for DoS/DDoS protection
  - unattended-upgrades # unattended-upgrades is used for automatic updates
  - ufw # ufw is used for firewall
  ### Utilities
  - apt-transport-https # for HTTPS
  - ca-certificates # for SSL
  - software-properties-common # for add-apt-repository
  - gnupg # for GPG keys
  - tldr # tldr is used for command help
  - htop # htop is used for system monitoring
  - jq # jq is used for parsing JSON
  - yq # yq is used for parsing YAML
  - curl # curl is used for making HTTP requests
  - tmux # tmux is used for terminal multiplexing
  - bat # bat replaces the cat command
  - fastfetch # fastfetch is used for the banner
  - certbot # Used for Let's Encrypt SSL certificates
  - et # Used for Eternal Terminal support