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

  metadata {
    user_data = base64encode(local.rendered_cloud_init)
  }
}