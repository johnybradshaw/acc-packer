# Packer template example in HCL2 format for creating a Linode image
/* This should be called with
packer build \
  -var-file="secret.pkrvars.hcl" \
  -var-file="variables.pkrvars.hcl" .
*/
packer {
  required_plugins {
    linode = {
      version = ">= 1.0.1"
      source  = "github.com/linode/linode"
    }
  }
}

# Create a timestamp for the image name
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# This template creates a Linode image based on the latest Ubuntu 22.04 image

source "linode" "ubuntu" {
  linode_token      = var.secrets.linode_token
  image             = var.linode_instance.image
  image_label       = "${var.linode_instance.image_label}-${local.timestamp}"
  image_description = var.linode_instance.image_description
  instance_label    = "temporary-${var.linode_instance.image_label}-${local.timestamp}"
  region            = var.linode_instance.region
  instance_type     = var.linode_instance.instance_type

  ssh_username      = "root"
  private_ip        = var.linode_instance.private_ip

  authorized_users  = var.secrets.authorized_users
  authorized_keys   = var.secrets.authorized_keys

}

build {
  sources = ["source.linode.ubuntu"]

  # Update the image before running any provisioners
  provisioner "shell" {
    # Set the environment variables for the shell provisioner
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "echo 'Setting debconf to non-interactive mode...'",
      "sudo echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo echo 'debconf debconf/priority select critical' | sudo debconf-set-selections",
      "echo 'Updating package lists...'",
      "sudo apt-get update",
      "echo 'Upgrading existing packages without any prompts...'",
      "sudo apt-get upgrade -y -o Dpkg::Options::=\"--force-confold\" -o Dpkg::Options::=\"--force-confdef\"",
    ]
  }

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
      # Create aide directory
      "sudo mkdir -p /etc/aide"
    ]
  }

  provisioner "file" {
    source        = "./configs/aide.conf"
    destination   = "/etc/aide/aide.conf"
  }
  # Set permissions on files
  provisioner "shell" {
    inline  = [
      "sudo chmod 755 /etc/profile.d/aliases.sh",
      "sudo chmod 755 /etc/profile.d/autologout-tty.sh",
      "sudo chmod 700 /usr/local/bin/set-hostname.sh",
      "sudo chmod 755 /usr/local/bin/update-rkhunter-conf.sh",
      "sudo chmod 644 /etc/aide/aide.conf"
    ]
  }

  # Copy the cloud-init file to the image
  provisioner "file" {
      source      = "packer_ubuntu_cloud-init.yaml" # This file is in the same directory as this template
      destination = "/tmp/cloud-init.yml"
    }

  # Run cloud-init to configure the image
  provisioner "shell" {
    inline = [
      "sudo cloud-init init --local",
      "sudo cloud-init modules --mode=config",
      "sudo cloud-init modules --mode=final"
    ]
  }
}
