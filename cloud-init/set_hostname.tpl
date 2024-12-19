#cloud-config
# Set hostname
preserve_hostname: false
hostname: myhost
create_hostname_file: true
fqdn: myhost.example.com
prefer_fqdn_over_hostname: true