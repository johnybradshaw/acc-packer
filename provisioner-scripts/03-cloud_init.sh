#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status
export DEBIAN_FRONTEND=noninteractive

echo "Setting debconf to non-interactive mode..."
echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections

echo "Updating package lists..."
apt-get update

echo "Performing a distribution upgrade..."
apt-get dist-upgrade -y \
    -o Dpkg::Options::='--force-confold' \
    -o Dpkg::Options::='--force-confdef'
cloud-init init --local # Initialize cloud-init
cloud-init modules --mode=config # Generate cloud-init config
cloud-init modules --mode=final # Generate cloud-init final