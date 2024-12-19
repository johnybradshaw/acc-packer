# Build block with provisioners
build {  
  sources = [ "source.linode.ubuntu"]

  # # Transfer cloud-init template
  # provisioner "file" {
  #   content     = local.rendered_cloud_init
  #   destination = "/tmp/cloud-init.yml"
  # }
  # provisioner "shell" { # Validate syntax
  #   inline = [
  #     "cloud-init schema --config-file /tmp/cloud-init.yml" # Validate syntax
  #   ]
  # }

  # Switch to Ubuntu archive mirror
  provisioner "shell" {
  inline = [
    "sudo rm -rf /var/lib/apt/lists/*",
    "sudo sed -i 's|http://mirrors.linode.com|http://archive.ubuntu.com|g' /etc/apt/sources.list",
    "echo 'Acquire::Languages \"none\";' | sudo tee /etc/apt/apt.conf.d/99disable-translations",
    "sudo apt-get update -o Acquire::CompressionTypes::Order::=gz"
  ]
}

  # Provision files and scripts
  # Copy scripts to the image
  provisioner "file" {
    source        = "./scripts/aliases.sh"
    destination   = "/etc/profile.d/aliases.sh"
  }

  provisioner "file" {
    source        = "./scripts/autologout-tty.sh"
    destination   = "/etc/profile.d/autologout-tty.sh"
  }

  provisioner "file" {
    source        = "./scripts/set-hostname.sh"
    destination   = "/usr/local/bin/set-hostname.sh"
  }

  provisioner "file" {
    source        = "./scripts/repollinate.sh"
    destination   = "/var/lib/cloud/scripts/per-instance/repollinate.sh"
  }

  provisioner "file" {
    source        = "./scripts/update-rkhunter.conf.sh"
    destination   = "/usr/local/bin/update-rkhunter-conf.sh"
  }

  # Config files
  provisioner "shell" {
    inline  = [
      "sudo mkdir -p /etc/aide", # Create aide directory
      "sudo mkdir -p /etc/audit/rules.d", # Create audit directory
      "sudo mkdir -p /etc/fail2ban" # Create fail2ban directory
    ]
  }

  provisioner "file" {
    source        = "./configs/aide.conf"
    destination   = "/etc/aide/aide.conf"
  }
  provisioner "file" {
    source        = "./configs/audit.rules"
    destination   = "/etc/audit/rules.d/audit.rules"
  }
  provisioner "file" {
    source        = "./configs/auto-upgrades.conf"
    destination   = "/etc/apt/apt.conf.d/20auto-upgrades"
  }
  provisioner "file" {
    source        = "./configs/jail.local"
    destination   = "/etc/fail2ban/jail.local"
  }
  provisioner "file" {
    source        = "./configs/ssh-hardening.conf"
    destination   = "/etc/ssh/sshd_config.d/10-hardening.conf"
  }

  # systemd services
  provisioner "file" {
    source        = "./systemd/set-hostname.service"
    destination   = "/etc/systemd/system/set-hostname.service"
  }

  # Set permissions on provisioned files
  provisioner "shell" {
    inline = [
      "chown root:root /etc/aide/aide.conf /etc/fail2ban/jail.local",
      "chmod 644 /etc/aide/aide.conf /etc/fail2ban/jail.local /etc/ssh/sshd_config.d/10-hardening.conf /etc/audit/rules.d/audit.rules", # World-readable, Root-only write
      "chmod 700 /usr/local/bin/set-hostname.sh", # Root-only executable
      "chmod 755 /usr/local/bin/update-rkhunter-conf.sh /var/lib/cloud/scripts/per-instance/repollinate.sh", # World-readable and executable, Root-only write
      "chmod 755 /etc/profile.d/aliases.sh /etc/profile.d/autologout-tty.sh" # World-readable and executable, Root-only write
    ]
  }

  # Enable and start systemd services
  provisioner "shell" { 
    inline = [
      "systemctl daemon-reload",
      "systemctl enable set-hostname.service",
      "systemctl start set-hostname.service"
    ]
  }

  # Update and upgrade packages then run cloud-init
  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
      "echo 'Setting debconf to non-interactive mode...'",
      "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections",
      "apt-get update",
      "apt-get dist-upgrade -y -o Dpkg::Options::=\"--force-confold\" -o Dpkg::Options::=\"--force-confdef\"",
      "cloud-init init --local",
      "cloud-init modules --mode=config",
      "cloud-init modules --mode=final"
    ]
  }

  # Cleanup to reduce image size
  provisioner "shell" {
    inline = [
      "update-initramfs -u", # Update initramfs
      "update-grub", # Update grub
      "apt-get clean", # Remove cached packages
      "journalctl --rotate", # Rotate journal
      "journalctl --vacuum-time=1d", # Vacuum journal
      "rm -rf /var/log/*.gz /var/log/*.1 /var/log/*-???????? /var/log/*.[0-9] /var/log/audit/*.[0-9]", # Remove log files
      "apt purge -y", # Remove unused packages
      "apt autoremove -y", # Remove unused packages
      "rm -rf /var/lib/apt/lists/*", # Remove apt cache
      "rm -rf /var/cache/apt/archives/*", # Remove apt cache
      "systemctl clean --all", # Remove systemd journal
      "cloud-init clean --logs" # Remove cloud-init logs
    ]
  }
}