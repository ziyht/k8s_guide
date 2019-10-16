#!/bin/sh



yum install -y bridge-utils.x86_64
modprobe  br_netfilter  # 加载 br_netfilter 模块，使用lsmod查看开启的模块

cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system   # 更新所有配置

yum install iptables -y
yum install iptables-services -y
systemctl start iptables.service
systemctl enable iptables.service

iptables -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
service iptables save
systemctl restart iptables.service