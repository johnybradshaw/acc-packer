#cloud-config
## Run commands
runcmd:
  # Disable ctrl-alt-del
  - ['systemctl', 'mask', 'ctrl-alt-del.target']
  - ['systemctl', 'daemon-reload']

  # Generate a random password for root and set it
  - ['/bin/bash', '-c', 'echo "root:$(openssl rand -base64 64 | head -c 64)" | chpasswd']

  # Configure unattended-upgrades to run hourly
  - ['/bin/bash', '-c', '(crontab -l 2>/dev/null; echo "0 * * * * /usr/bin/unattended-upgrade") | crontab -']
  - ['systemctl', 'enable', 'unattended-upgrades']
  - ['systemctl', 'start', 'unattended-upgrades']

  # Configure rkhunter
  - ['rkhunter', '--propupd']
  - ['rkhunter', '--update']

  # Configure UFW
  - ['/bin/bash', '-c', 'ufw limit ssh']
  - ['/bin/bash', '-c', 'ufw allow ssh']
  - ['/bin/bash', '-c', 'ufw allow http']
  - ['/bin/bash', '-c', 'ufw allow https']
  - ['/bin/bash', '-c', 'ufw allow 2022/tcp']
  - ['/bin/bash', '-c', 'ufw --force enable']

  # Update tl;dr
  - ['tldr', '--update']

  # Install iTerm2 integration for acc-user
  - ['su', '-', 'acc-user', '-c', 'curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash']

  # Update certificates
  - ['update-ca-certificates', '--fresh']

  # Start / Restart services
  - ['systemctl', 'enable', 'auditd', '--now']
  - ['systemctl', 'enable', 'apparmor', '--now']
  - ['systemctl', 'restart', 'ssh']
  - ['systemctl', 'enable', 'fail2ban', '--now']
  - ['systemctl', 'enable', 'et', '--now']
  - ['systemctl', 'enable', 'ufw', '--now']
  - ['systemctl', 'enable', 'unattended-upgrades', '--now']
  - ['systemctl', 'enable', 'apparmor', '--now']

  # Final step: redirect cloud-init logs for easy debugging
  - ['/bin/bash', '-c', 'journalctl -u cloud-init --no-pager > /var/log/cloud-init.log']