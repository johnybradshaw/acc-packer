# Local parsing and formatting
locals {
  # Cloud-init modules
  
  # Dynamic rendering of cloud-init
  # List of all the cloud-init modules with their corresponding templates
  cloud_init_templates = {
    apt             = "./cloud-init/apt.tpl"
    ca_certs        = "./cloud-init/ca_certs.tpl"
    etc_hosts       = "./cloud-init/etc_hosts.tpl"
    final_message   = "./cloud-init/final_message.tpl"
    groups          = "./cloud-init/groups.tpl"
    packages        = "./cloud-init/packages.tpl"
    runcmd          = "./cloud-init/runcmd.tpl"
    seed_random     = "./cloud-init/seed_random.tpl"
    set_hostname    = "./cloud-init/set_hostname.tpl"
    snap            = "./cloud-init/snap.tpl"
    ssh             = "./cloud-init/ssh.tpl"
    timezone        = "./cloud-init/timezone.tpl"
    ubuntu_drivers  = "./cloud-init/ubuntu_drivers.tpl"
    update_hostname = "./cloud-init/update_hostname.tpl"
    users           = "./cloud-init/users.tpl"
  }

  # Concatenate and render templates based on enabled modules
  rendered_cloud_init = join("\n", [
    for key, path in local.cloud_init_templates :
    templatefile(path, {
      authorized_keys        = jsonencode(
        var.secrets.authorized_keys != null ? var.secrets.authorized_keys : []
        ),
      acc_user_keys          = jsonencode(
        var.secrets.acc-user_keys != null ? var.secrets.acc-user_keys : []
        ),
    }) if var.cloud_init[key]
  ])

  build_time = formatdate("YYYYMMDD'T'hhmm", timestamp()) # Get build time
  all_tags = concat(
    var.linode_instance.linode_tags,  
    ["build_date: ${local.build_time}"] # Add build time to tags
  )
}