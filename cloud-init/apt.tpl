#cloud-config
## APT configuration
apt:
  sources:
    et-ppa:
      source: "ppa:jgmath2000/et"
      keyid: "CB4ADEA5B72A07A1"
      keyserver: hkp://keyserver.ubuntu.com:80
    # Zabbix main repository
    zabbix-main:
      source: "deb https://repo.zabbix.com/zabbix/7.2/stable/ubuntu $(lsb_release -cs | tee) main"
      keyid: "D913219AB5333005"
      keyserver: hkp://keyserver.ubuntu.com:80
    # Zabbix release repository
    zabbix-release:
      source: "deb [arch=all] https://repo.zabbix.com/zabbix/7.2/release/ubuntu $(lsb_release -cs | tee) main"
      keyid: "D913219AB5333005"
      keyserver: hkp://keyserver.ubuntu.com:80
    # Zabbix tools repository
    zabbix-tools:
      source: "deb [arch=all] https://repo.zabbix.com/zabbix-tools/debian-ubuntu $(lsb_release -cs | tee) main"
      keyid: "D913219AB5333005"
      keyserver: hkp://keyserver.ubuntu.com:80
    # Helm repository
    helm:
      source: "deb https://baltocdn.com/helm/stable/debian/ all main"
      keyid: "294AC4827C1A168A"
      keyserver: hkp://keyserver.ubuntu.com:80
    # Docker repository
    docker:
      source: "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs | tee) stable"
      keyid: "8D81803C0EBFCD88"
      keyserver: hkp://keyserver.ubuntu.com:80
    # Fastfetch
    fastfetch:
      source: "ppa:zhangsongcui3371/fastfetch"
      keyid: "0xEB65EE19D802F3EB1A13CFE47E2E5CB4D4865F21"
      keyserver: hkp://keyserver.ubuntu.com:80