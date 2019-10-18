# 在 centos7 上部署 k8s集群

## 目录

### 部署
* [step1:规划](#step1:规划)
* [step2:配置节点](#step2:配置节点)
* [step3:在master节点准备kubespray](#step3:在master节点准备kubespray)
* [step4:配置集群](#step4:配置kubespray)
* [step5:安装集群](#step5:安装集群)

### 维护
* [扩容节点](#扩容节点)
* [刪除节点](#删除节点)
* [卸载](#卸载)
* [升级](#升级)

## [step1:规划](#目录)

> 节点核数 : >= 2

|IP             | 角色                | Hostname| OS      |
|--             | --                  | --      |--       |
|192.168.193.110| master,etcd,ansible |master   | centos7 |
|192.168.193.111| master,node,etcd    |node1    | centos7 |
|192.168.193.112| node,etcd           |node2    | centos7 |

master: k8s master 节点  
node：k8s node 节点  
etcd：etcd 服务节点  
ansible：部署节点  

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
# vim inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml
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

`配置 dashboard（可忽略）`
```sh
# vim ./roles/kubernetes-apps/ansible/templates/coredns-deployment.yml.j2
# ------------------- Dashboard Service ------------------- #
...
...
      targetPort: 8443

  type: NodePort    //添加这一行   

  selector:

k8s-app: kubernetes-dashboard
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

`查看ipvs`
```
ipvsadm -L -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.233.0.1:443 rr
  -> 192.168.193.110:6443         Masq    1      1          0         
  -> 192.168.193.111:6443         Masq    1      3          0         
TCP  10.233.0.3:53 rr
  -> 10.233.90.1:53               Masq    1      0          0         
  -> 10.233.96.2:53               Masq    1      0          0         
TCP  10.233.0.3:9153 rr
  -> 10.233.90.1:9153             Masq    1      0          0         
  -> 10.233.96.2:9153             Masq    1      0          0         
TCP  10.233.11.128:443 rr
  -> 10.233.90.3:8443             Masq    1      0          0         
TCP  10.233.13.226:44134 rr
  -> 10.233.96.1:44134            Masq    1      0          0         
UDP  10.233.0.3:53 rr
  -> 10.233.90.1:53               Masq    1      0          0         
  -> 10.233.96.2:53               Masq    1      0          0
```
`登录 dashboard`
```sh
# 获取登录令牌
kubectl -n kube-system describe $(kubectl -n kube-system get secret -n kube-system -o name | grep namespace) | grep token
```
然后使用如下地址登录（使用firefox浏览器）：
https://192.168.193.110:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login


### [扩容节点](#目录)
`修改配置文件`
```
vim inventory/mycluster/hosts.yml
```

`应用 scale.yml`
```
ansible-playbook -i inventory/mycluster/hosts.yml scale.yml -b -v -k
```

### [刪除节点](#目录)
`应用 remove-node.yml`
```sh
# 这里不指定节点，将删除所有节点，类似卸载
ansible-playbook -i inventory/mycluster/hosts.yml remove-node.yml -b -v
```

### [卸载](#目录)
`应用 reset.yml`
```
ansible-playbook -i inventory/mycluster/hosts.yml reset.yml -b –vvv
```

### [升级](#目录)
`应用 upgrade-cluster.yml`
```
ansible-playbook upgrade-cluster.yml -b -i inventory/mycluster/hosts.yml -e kube_version=vX.XX.XX -vvv
```
