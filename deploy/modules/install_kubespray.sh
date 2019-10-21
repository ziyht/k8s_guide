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
#yum clean all && yum makecache

# 安装前置依赖
yum install -y epel-release ansible git gcc openssl-devel
yum install -y python36 python36-devel python-netaddr
yum install -y python36-pip

# 获取 kubespray
git clone https://github.com/kubernetes-incubator/kubespray.git /opt/kubespray

# 安装依赖
pip3 install -r /opt/kubespray/requirements.txt
pip3 install -r /opt/kubespray/contrib/inventory_builder/test-requirements.txt
pip3.6 install ruamel.yaml

cd /opt/kubespray/
git checkout -f v2.11.0

# 配置国内源
sed -i "s/k8s\.gcr\.io/gcr\.azk8s\.cn/g"   /opt/kubespray/roles/download/defaults/main.yml 
sed -i "s/gcr\.io/gcr\.azk8s\.cn/g"        /opt/kubespray/roles/download/defaults/main.yml 
sed -i "s/quay\.io/quay\.azk8s\.cn/g"      /opt/kubespray/roles/download/defaults/main.yml
sed -i "s/gcr\.azk8s\.cn\/k8s-dns-node-cache/gcr\.azk8s\.cn\/google-containers\/k8s-dns-node-cache/g" /opt/kubespray/roles/download/defaults/main.yml
sed -i "s/gcr\.azk8s\.cn\/cluster-proportional-autoscaler/gcr\.azk8s\.cn\/google-containers\/cluster-proportional-autoscaler/g" /opt/kubespray/roles/download/defaults/main.yml
sed -i "s/k8s\.gcr\.io/gcr\.azk8s\.cn/g"   /opt/kubespray/inventory/sample/group_vars/k8s-cluster/k8s-cluster.yml
sed -i "s/gcr\.io/gcr\.azk8s\.cn/g"        /opt/kubespray/inventory/sample/group_vars/k8s-cluster/k8s-cluster.yml
sed -i "s/gcr\.azk8s\.cn\/addon-resizer/gcr\.azk8s\.cn\/google-containers\/addon-resizer/g" /opt/kubespray/roles/download/defaults/
