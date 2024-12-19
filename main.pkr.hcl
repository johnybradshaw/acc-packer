# Packer template in HCL2 format for Linode Ubuntu 24.04 image

/* Call with:
To Debug set the following:
PACKER_LOG=1
PACKER_LOG_PATH="packer.log"

packer build \
  -var-file="secret.pkrvars.hcl" \
  -var-file="variables.pkrvars.hcl" .
*/

packer {
  required_plugins {
    linode = {
      version = ">=1.5.8"
      source  = "github.com/linode/linode"
    }
  }
}
