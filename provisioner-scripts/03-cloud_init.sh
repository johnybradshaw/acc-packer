#!/bin/bash
DEBIAN_FRONTEND=noninteractive
echo 'Setting debconf to non-interactive mode...' # Set debconf to non-interactive mode
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update # Update package lists
apt-get dist-upgrade -y -o Dpkg::Options::=\"--force-confold\" -o Dpkg::Options::=\"--force-confdef\"
cloud-init init --local # Initialize cloud-init
cloud-init modules --mode=config # Generate cloud-init config
cloud-init modules --mode=final # Generate cloud-init final