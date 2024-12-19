#!/bin/bash

# Set permissions on provisioned files
chmod 700 /usr/local/bin/set-hostname.sh # Root-only executable
chmod 755 /usr/local/bin/update-rkhunter-conf.sh \
    /var/lib/cloud/scripts/per-instance/repollinate.sh \
    /etc/profile.d/aliases.sh \
    /etc/profile.d/autologout-tty.sh # World-readable and executable, Root-only write
# Start / Restart services
systemctl daemon-reload 
systemctl enable set-hostname.service 
systemctl start set-hostname.service 
systemctl enable auditd --now  # Enable and start auditd
systemctl enable apparmor --now  # Enable and start apparmor
systemctl restart ssh  # Restart SSH
systemctl enable fail2ban --now  # Enable and start fail2ban
systemctl enable et --now  # Enable and start et
systemctl enable ufw --now  # Enable and start ufw
systemctl enable unattended-upgrades --now  # Enable and start unattended-upgrades
# Update kernel
update-initramfs -u # Update initramfs
update-grub # Update grub
# Clean up
apt-get clean # Remove cached packages
journalctl --rotate # Rotate journal
journalctl --vacuum-time=1d # Vacuum journal
rm -rf /var/log/*.gz /var/log/*.1 /var/log/*-???????? /var/log/*.[0-9] /var/log/audit/*.[0-9] # Remove log files
apt purge -y # Remove unused packages
apt autoremove -y # Remove unused packages
rm -rf /var/lib/apt/lists/* # Remove apt cache
rm -rf /var/cache/apt/archives/* # Remove apt cache
cloud-init clean --logs # Remove cloud-init logs