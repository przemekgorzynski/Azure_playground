#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# wait for cloud-init to finish before touching apt
cloud-init status --wait || true

# disable ufw so it doesn't interfere with iptables rules
systemctl disable --now ufw || true

# IP forwarding
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-nva.conf
sysctl --system

# NAT / masquerade — flush first so re-runs don't accumulate duplicates
apt-get install -y iptables-persistent
iptables -F FORWARD
iptables -t nat -F POSTROUTING
iptables -A FORWARD -j ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE
netfilter-persistent save
