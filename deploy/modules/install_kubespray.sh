#!/bin/sh

# 添加 pip 源
mkdir ~/.pip
cat > ~/.pip/pip.conf << EOF 
[global]
trusted-host=mirrors.aliyun.com
index-url=https://mirrors.aliyun.com/pypi/simple/
EOF

# 配置 yum 源
yum install -y wget
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum clean all && yum makecache

# 安装前置依赖
yum install -y epel-release ansible git gcc openssl-devel
yum install -y python36 python36-devel python36-pip

# 获取 kubespray
git clone https://github.com/kubernetes-incubator/kubespray.git /opt/kubespray

# 安装依赖
pip3.6 install -r /etc/kubespray/requirements.txt
pip3.6 install -r /etc/kubespray/contrib/inventory_builder/test-requirements.txt
pip3.6 install ruamel.yaml