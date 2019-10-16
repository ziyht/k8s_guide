# 在 centos7 上部署 k8s集群

## 目录

* [step1:规划](#step1:规划)
* [step2:配置节点](#step2:配置节点)
* [step3:在master节点安装kubespray](#step3:在master节点安装kubespray)
* [step4:配置kubespray](#step4:配置kubespray)

## 前置要求

节点数 : >= 2  
节点核数 : >= 2

## [step1:规划](#目录)

|IP             | 角色              | Hostname| OS      |
|--             | --                |--       |--       |
|192.168.193.110| master,etcd       |master   | centos7 |
|192.168.193.111| master,node,etcd  |node1    | centos7 |
|192.168.193.112| node,etcd         |node2    | centos7 |

## [step2:配置节点](#目录)

> 此步骤需要在所有节点上执行  
> 注：ip地址请自行修正，后续的步骤由于测试的原因 ip 地址可能匹配不上

`更新 hosts 文件`
```sh
cat <<EOF >>/etc/hosts

192.168.193.110 master
192.168.193.111 node1
192.168.193.112 node2

EOF
```

`修改 hostname，和 hosts 文件内容保持一致`
```sh
hostnamectl set-hostname master
```

ansible -i inventory/inventory.cfg all -a "swapoff -a"

ansible -i inventory/mycluster/hosts.yml all -a "cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF"

ansible -i inventory/inventory.cfg all -a "sysctl --system"


`关闭防火墙、selinux和swap`
```sh
systemctl disable --now firewalld

setenforce 0                                                            # 临时关闭
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config    # 永久禁用

swapoff -a                          # 临时关闭
sed -i 's/.*swap.*/#&/' /etc/fstab  # 永久禁用
```

```sh
# master
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sysctl -w net.ipv4.ip_forward=1

# node
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --permanent --add-port=6783/tcp
firewall-cmd  --reload
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sysctl -w net.ipv4.ip_forward=1
```

`Docker从1.13版本开始调整了默认的防火墙规则，禁用了iptables filter表中FOWARD链，这样会引起Kubernetes集群中跨Node的Pod无法通信，在各个Docker节点执行下面的命令：`
```sh
iptables -P FORWARD ACCEPT
```

`配置内核参数，将桥接的IPv4流量传递到iptables的链`
```sh
yum install -y bridge-utils.x86_64
modprobe  br_netfilter  # 加载 br_netfilter 模块，使用lsmod查看开启的模块

cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system   # 更新所有配置
```

`配置ssh登录无密码验证`
```sh
# (master) 生成 ssh 证书 （三次回车）
ssh-keygen

# (master) 分发公钥到所有节点
ssh-copy-id root@master
ssh-copy-id root@node1
ssh-copy-id root@node2
```

## [step3:在master节点安装kubespray](#目录)

`安装 kubespray 的前置工具`
```sh
yum -y install epel-release
yum clean all && yum makecache
yum install -y python-pip python34 python-netaddr python34-pip ansible git
```

`从 git 上下载 kubespray`
```sh
# 使用 http地址直接 clone，不需要验证，clone 前也可先切换最新的 release 版本
git clone https://github.com/kubernetes-sigs/kubespray
```
> 也可查看最新的 release 分支，然后切换

```

`安装 kubespray 的依赖`
```sh
cd kubespray
pip install -r requirements.txt
pip3 install ruamel.yaml
```

## [step4:配置kubespray](#目录)
> **不特别说明，后续操作均在 kubespray 下进行**

`从模板创建一个属于我们自己的配置`
```sh
cp -rfp inventory/sample inventory/mycluster
```

`通过 inventory_builder 生成快速配置文件`
```sh
declare -a IPS=(192.168.193.110 192.168.193.111 192.168.193.112)
CONFIG_FILE=inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```

### `编辑生成的 host.yml 文件，使之符合我们的集群规划`
```yml
all:
  hosts:
    node1:
      ansible_host: 192.168.193.110
      ip: 192.168.193.110
      access_ip: 192.168.193.110
    node2:
      ansible_host: 192.168.193.111
      ip: 192.168.193.111
      access_ip: 192.168.193.111
    node3:
      ansible_host: 192.168.193.112
      ip: 192.168.193.112
      access_ip: 192.168.193.112
  children:
    kube-master:
      hosts:
        node1:
        node2:
    kube-node:
      hosts:
        node2:
        node3:
    etcd:
      hosts:
        node1:
        node2:
        node3:
    k8s-cluster:
      children:
        kube-master:
        kube-node:
    calico-rr:
      hosts: {}
```

`替换镜像地址`
```sh
grc_image_files=(
    ./kubespray/extra_playbooks/roles/dnsmasq/templates/dnsmasq-autoscaler.yml
    ./kubespray/extra_playbooks/roles/download/defaults/main.yml
    ./kubespray/extra_playbooks/roles/kubernetes-apps/ansible/defaults/main.yml
    ./kubespray/roles/download/defaults/main.yml
    ./kubespray/roles/dnsmasq/templates/dnsmasq-autoscaler.yml
    ./kubespray/roles/kubernetes-apps/ansible/defaults/main.yml
)

for file in ${grc_image_files[@]} ; do
    sed -i 's/gcr.io\/google_containers/registry.cn-hangzhou.aliyuncs.com\/szss_k8s/g' $file
done

quay_image_files=(
    ./kubespray/extra_playbooks/roles/download/defaults/main.yml
    ./kubespray/roles/download/defaults/main.yml
)

for file in ${quay_image_files[@]} ; do
    sed -i 's/quay.io\/coreos\//registry.cn-hangzhou.aliyuncs.com\/szss_quay_io\/coreos-/g' $file
    sed -i 's/quay.io\/calico\//registry.cn-hangzhou.aliyuncs.com\/szss_quay_io\/calico-/g' $file
    sed -i 's/quay.io\/l23network\//registry.cn-hangzhou.aliyuncs.com\/szss_quay_io\/l23network-/g' $file
done
```



