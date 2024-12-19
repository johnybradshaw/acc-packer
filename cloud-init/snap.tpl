#cloud-config
## Install snap packages
snap:
  commands:
    0: [install, canonical-livepatch]
    1: [install, kubectl, --classic]
    2: [install, kubectx, --classic]
    3: [refresh]