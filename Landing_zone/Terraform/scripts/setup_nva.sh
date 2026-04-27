#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# wait for cloud-init to finish before touching apt
cloud-init status --wait || true

# repair any interrupted dpkg state
dpkg --configure -a

apt-get update -y
apt-get upgrade -y
apt-get autoremove -y

# IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# NAT / masquerade
apt-get install -y iptables-persistent
iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE
netfilter-persistent save
