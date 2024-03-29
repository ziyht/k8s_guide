#!/bin/sh

# 依赖
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

# 阿里云源
sudo yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装
sudo yum install -y docker-ce docker-ce-cli containerd.io

# 设置开机自动启动
systemctl enable --now docker

# 修改docker cgroup驱动：native.cgroupdriver=systemd
cat > /etc/docker/daemon.json <<EOF 
{
  "exec-opts": ["native.cgroupdriver=cgroupfs"],
  "log-driver": "json-file",
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

# Restart Docker
systemctl daemon-reload
systemctl restart docker
