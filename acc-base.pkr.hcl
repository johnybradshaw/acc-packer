# Packer template in HCL2 format for Linode Ubuntu 24.04 image

/* Call with:
packer build \
  -var-file="secret.pkrvars.hcl" \
  -var-file="variables.pkrvars.hcl" .
*/

packer {
  required_plugins {
    linode = {
      version = ">=1.5.7"
      source  = "github.com/linode/linode"
    }
  }
}

# Local parsing and formatting
locals {
  rendered_cloud_init = templatefile("packer_ubuntu_cloud-init.tpl", { # Render cloud-init template file
    acc_user_keys = join("\n      - ", var.secrets.acc-user_keys) # Join keys into YAML list format
  })
  
  build_time = formatdate("YYYY-MM-DD'T'hhmm", timestamp()) # Get build time
  all_tags = concat(
    var.linode_instance.linode_tags,  
    ["build_date: ${local.build_time}"] # Add build time to tags
  )
}

# Define Linode image source
source "linode" "ubuntu" {
  linode_token      = var.secrets.linode_token
  image             = var.linode_instance.image
  image_label       = "${var.linode_instance.image_label}-${local.build_time}"
  image_description = var.linode_instance.image_description
  instance_label    = "temporary-${var.linode_instance.image_label}-${local.build_time}"
  region            = var.linode_instance.region
  instance_type     = var.linode_instance.instance_type
  instance_tags     = local.all_tags

  ssh_username      = "root"
  private_ip        = var.linode_instance.private_ip

  authorized_users  = var.secrets.authorized_users
  authorized_keys   = var.secrets.authorized_keys
  firewall_id       = var.linode_instance.firewall_id

  cloud_init        = true # Ensure the image supports cloud-init
}

# Build block with provisioners
build {
  sources = ["source.linode.ubuntu"]

  # Update and upgrade system
  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
      "echo 'Setting debconf to non-interactive mode...'",
      "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections",
      "apt-get update",
      "apt-get dist-upgrade -y -o Dpkg::Options::=\"--force-confold\" -o Dpkg::Options::=\"--force-confdef\""
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

  # Set permissions on provisioned files
  provisioner "shell" {
    inline = [
      "chown root:root /etc/aide/aide.conf /etc/fail2ban/jail.local",
      "chmod 644 /etc/aide/aide.conf /etc/fail2ban/jail.local /etc/ssh/sshd_config.d/10-hardening.conf /etc/audit/rules.d/audit.rules", # World-readable, Root-only write
      "chmod 700 /usr/local/bin/set-hostname.sh", # Root-only executable
      "chmod 755 /usr/local/bin/update-rkhunter-conf.sh", # World-readable and executable, Root-only write
      "chmod 755 /etc/profile.d/aliases.sh /etc/profile.d/autologout-tty.sh" # World-readable and executable, Root-only write
    ]
  }

  # Validate and deploy cloud-init template
  provisioner "file" {
    content     = local.rendered_cloud_init
    destination = "/tmp/cloud-init.yml"
  }

  provisioner "shell" {
    inline = [
      "cloud-init schema --config-file /tmp/cloud-init.yml", # Validate syntax
      "cloud-init init --local",
      "cloud-init modules --mode=config",
      "cloud-init modules --mode=final"
    ]
  }

  # Cleanup to reduce image size
  provisioner "shell" {
    inline = [
      "apt-get clean", # Remove cached packages
      "apt autoremove -y", # Remove unused packages
      "rm -rf /var/lib/apt/lists/*", # Remove apt cache
      "cloud-init clean --logs" # Remove cloud-init logs
    ]
  }
}