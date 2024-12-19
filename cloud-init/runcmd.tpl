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

  # Configure UFW
  - ['/bin/bash', '-c', 'ufw limit ssh'] # Limit SSH
  - ['/bin/bash', '-c', 'ufw limit 2022/tcp'] # Limit port 2022 (et)
  - ['/bin/bash', '-c', 'ufw allow ssh'] # Allow SSH
  - ['/bin/bash', '-c', 'ufw allow http'] # Allow HTTP
  - ['/bin/bash', '-c', 'ufw allow https'] # Allow HTTPS
  - ['/bin/bash', '-c', 'ufw allow 2022/tcp'] # Allow port 2022 (et)
  - ['/bin/bash', '-c', 'ufw --force enable'] # Enable UFW

  # Update tl;dr
  - ['su', '-', 'acc-user', '-c', 'tldr', '--update']

  # Install iTerm2 integration for acc-user
  - ['su', '-', 'acc-user', '-c', 'curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash']

  # Update certificates
  - ['update-ca-certificates', '--fresh'] # Update CA certificates

  # Final step: redirect cloud-init logs for easy debugging
  - ['/bin/bash', '-c', 'journalctl -u cloud-init --no-pager > /var/log/cloud-init.log'] # Redirect cloud-init logs
  - ['/bin/bash', '-c', 'journalctl -u cloud-config --no-pager > /var/log/cloud-config.log'] # Redirect cloud-config logs
  - ['/bin/bash', '-c', 'journalctl -u cloud-finalize --no-pager > /var/log/cloud-finalize.log'] # Redirect cloud-finalize logs
  - ['/bin/bash', '-c', 'journalctl -u cloud-init.service --no-pager > /var/log/cloud-init.service.log'] # Redirect cloud-init.service logs
