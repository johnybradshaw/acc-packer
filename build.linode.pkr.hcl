# Build block with provisioners
build {  
  sources = [ "source.linode.ubuntu"]

  # Prebuild scripts
  provisioner "shell" {
    scripts = [
      "./provisioner-scripts/01-apt_mirror_reset.sh", # Switch to Ubuntu archive mirror
      "./provisioner-scripts/02-ssh_hardening.sh", # SSH hardening
      "./provisioner-scripts/03-cloud_init.sh", # Run cloud-init
    ]
  }

  # Transfer scripts / configs / systemd units
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
  # Copy configs to the image
  provisioner "file" { # aide config
    source        = "./configs/aide.conf"
    destination   = "/etc/aide/aide.conf"
  }
  provisioner "file" { # audit rules
    source        = "./configs/audit.rules"
    destination   = "/etc/audit/rules.d/audit.rules"
  }
  provisioner "file" { # auto-upgrades
    source        = "./configs/auto-upgrades.conf"
    destination   = "/etc/apt/apt.conf.d/20auto-upgrades"
  }
  provisioner "file" { # fail2ban
    source        = "./configs/jail.local"
    destination   = "/etc/fail2ban/jail.local"
  }
  provisioner "file" { # ssh hardening
    source        = "./configs/ssh-hardening.conf"
    destination   = "/etc/ssh/sshd_config.d/10-hardening.conf"
  }
  provisioner "file" { # systemd unit to set hostname
    source        = "./systemd/set-hostname.service"
    destination   = "/etc/systemd/system/set-hostname.service"
  }

  # Finalise the image
  provisioner "shell" {
    scripts = [
      "./provisioner-scripts/04-finaliser.sh" # Run finaliser
    ]
  }
} 