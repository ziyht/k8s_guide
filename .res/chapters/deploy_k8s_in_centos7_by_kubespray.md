# 在 centos7 上部署 k8s集群

## 目录

* [step1:规划](#step1:规划)
* [step2:配置节点](#step2:配置节点)
* [step3:在master节点准备kubespray](#step3:在master节点准备kubespray)
* [step4:配置集群](#step4:配置kubespray)
* [step5:安装集群](#step5:安装集群)
* [step6:后续操作](#step6:后续操作)

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

`修改 hostname，和 hosts 文件内容保持一致（所有节点）`
```sh
hostnamectl set-hostname master
hostname master
```

`配置ssh登录无密码验证（master节点）`
```sh
# (master) 生成 ssh 证书 （三次回车）
ssh-keygen

# (master) 分发公钥到所有节点
ssh-copy-id root@192.168.193.110
ssh-copy-id root@192.168.193.111
ssh-copy-id root@192.168.193.112
```

## [step3:在master节点准备kubespray](#目录)

`下载本项目`
```
git clone https://github.com/ziyht/k8s_guide.git
```

`进入 deploy 目录`
```
cd k8s_guide/deploy
```

`创建 hosts 文件`
```
vim hosts

192.168.193.110 master
192.168.193.111 node1
192.168.193.112 node2
```

`执行 prepare 操作`
```
./kubespray_prepare_master.sh
```
> 此脚本 会下载 kubespray 最新版，并切换到 v2.11.0
> 会自动更新 repo 到国内镜像源
> hosts 文件的内容会自动拷贝到 /etc/hosts 中

## [step4:配置kubespray](#目录)
> **不特别说明，后续操作均在 kubespray 下进行**

`进入 kubespray 目录`
```
cd /opt/kubespray
```

`从模板创建一个属于你自己的配置`
```sh
cp -rfp inventory/sample inventory/mycluster
```

`通过 inventory_builder 生成快速配置文件`
```sh
declare -a IPS=(192.168.193.110 192.168.193.111 192.168.193.112)
CONFIG_FILE=inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```

`编辑 hosts.yml(根据自己的需要修改配置)`
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
        node1:
        node3:
    ethonode3:
    k8chkube-node:r:
    cahosts: {}
```

`配置集群`
```
vim inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml
```

`配置附加组件（根据需要）`
```
vim inventory/mycluster/group_vars/k8s-cluster/addons.yml
```

## [step5:安装集群](#目录)
`开始配置`
```
ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root cluster.yml
```

> 注意：这一步要花费比较长的时间，期间要下载镜像，如果网速很慢，可能会持续很久

```
PLAY RECAP ************************************************************************************************************************************************************************************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0   
node1                      : ok=701  changed=91   unreachable=0    failed=0   
node2                      : ok=604  changed=72   unreachable=0    failed=0   
node3                      : ok=508  changed=61   unreachable=0    failed=0
```

`验证服务`
```
[root@master1 kubespray]# kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-646595ffff-72fss   1/1     Running   0          14m
kube-system   calico-node-22jt8                          1/1     Running   1          14m
kube-system   calico-node-mfchb                          1/1     Running   0          14m
kube-system   calico-node-vsnm2                          1/1     Running   0          14m
kube-system   coredns-74c9d4d795-5t7hq                   1/1     Running   0          14m
kube-system   coredns-74c9d4d795-9c484                   1/1     Running   0          14m
kube-system   dns-autoscaler-784ffdfff4-vrsm4            1/1     Running   0          14m
kube-system   kube-apiserver-node1                       1/1     Running   0          16m
kube-system   kube-apiserver-node2                       1/1     Running   0          15m
kube-system   kube-controller-manager-node1              1/1     Running   0          16m
kube-system   kube-controller-manager-node2              1/1     Running   0          15m
kube-system   kube-proxy-97rfw                           1/1     Running   0          15m
kube-system   kube-proxy-gq9j8                           1/1     Running   0          15m
kube-system   kube-proxy-sbzhr                           1/1     Running   0          15m
kube-system   kube-scheduler-node1                       1/1     Running   0          16m
kube-system   kube-scheduler-node2                       1/1     Running   0          15m
kube-system   kubernetes-dashboard-7bbcdcdbf6-whhrb      1/1     Running   0          14m
kube-system   nginx-proxy-node3                          1/1     Running   0          15m
kube-system   nodelocaldns-hdl6m                         1/1     Running   0          14m
kube-system   nodelocaldns-mzsqs                         1/1     Running   0          14m
kube-system   nodelocaldns-wwn88                         1/1     Running   0          14m
kube-system   tiller-deploy-55fc49c595-slnr4             1/1     Running   0          13m
```

```
[root@node1 kubespray]# kubectl get nodes
NAME    STATUS   ROLES    AGE    VERSION
node1   Ready    master   119m   v1.15.3
node2   Ready    master   117m   v1.15.3
node3   Ready    <none>   117m   v1.15.3
```