# Render cloud-init
source "file" "cloud-init" { 
  content     = local.rendered_cloud_init
  target      = "/tmp/cloud-init.yml"
}

# echo the cloud-init template
build {
  sources = ["source.file.cloud-init"]
  provisioner "shell-local" {
    inline = [
      "cat '/tmp/cloud-init.yml'" # Echo cloud-init to console
    ]
  }
  provisioner "breakpoint" {
    disable = true # Disable breakpoint
  } 
}