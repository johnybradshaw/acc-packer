# Packer Variables for ACC
variable "secrets" {
    type    = object({
        linode_token        = string
        authorized_users    = list(string)
        authorized_keys     = list(string)
        acc-user_keys       = list(string)
    })
    sensitive = true
}

variable "linode_instance" {
    type    = object({
        region              = string
        instance_type       = string
        instance_label      = string
        image               = string
        image_label         = string
        image_description   = string
        linode_tags         = list(string)
        private_ip          = bool
        firewall_id         = string
    })
    default = {
        region              = "fr-par"
        instance_type       = "g6-nanode-1"
        instance_label      = "packer-ubuntu24.04"
        image               = "linode/ubuntu24.04"
        image_label         = "ubuntu24.04-packer-image"
        image_description   = "ubuntu24.04 - ACC Packer Image"
        linode_tags         = ["os: ubuntu24.04", "builder: packer"]
        private_ip          = false
        firewall_id         = ""
    }
}

# Cloud Init Template
variable "cloud_init" {
    type    = object({
        apt = bool
        ca_certs = bool
        etc_hosts = bool
        final_message = bool
        groups = bool
        packages = bool
        runcmd = bool
        seed_random = bool
        set_hostname = bool
        snap = bool
        ssh = bool
        timezone = bool
        ubuntu_drivers = bool
        update_hostname = bool
        users = bool
    })
    default = {
        apt = true
        ca_certs = false # Not required in most cases
        etc_hosts = true
        final_message = true
        groups = true
        packages = true
        runcmd = true
        seed_random = true
        set_hostname = false # Not advisable in most cases
        snap = true
        ssh = true
        timezone = true
        ubuntu_drivers = false # Not required in most cases
        update_hostname = false # Not advisable in most cases
        users = true
    }
}