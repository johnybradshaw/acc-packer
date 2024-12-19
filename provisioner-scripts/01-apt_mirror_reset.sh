#!/bin/bash
rm -rf /var/lib/apt/lists/*
sed -i 's|http://mirrors.linode.com|http://archive.ubuntu.com|g' /etc/apt/sources.list
echo 'Acquire::Languages \"none\";' | tee /etc/apt/apt.conf.d/99disable-translations
apt-get update -o Acquire::CompressionTypes::Order::=gz"