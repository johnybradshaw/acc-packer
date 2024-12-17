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