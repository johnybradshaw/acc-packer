#cloud-config
## Manage CA certificates
ca_certs:
  remove_defaults: false # Remove default CA certificates
  trusted:
    - |
      -----BEGIN CERTIFICATE-----
      asdhgasd2782example
      -----END CERTIFICATE-----