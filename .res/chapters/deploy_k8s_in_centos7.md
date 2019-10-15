# 在 centos7 上部署 k8s集群

## 目录

* [step1:规划](#step1:规划)
* [step2:配置节点](#step2:配置节点)
* [step3:安装docker](#step3:安装docker)
* [step4:安装k8s管理工具](#step4:安装k8s管理工具)
* [step5:拉取k8s服务镜像](#step5:拉取k8s服务镜像)
* [step6:创建k8s集群](#step6:创建k8s集群)
* [step7:应用flannel网络](#step7:应用flannel网络)
* [step8:子节点加入集群](#step8:子节点加入集群)
* [step9:配置集群](#step9:配置集群)

## 前置要求

节点数 : >= 2  
节点核数 : >= 2

## [step1:规划](#目录)

|IP         |角色    |Hostname| OS       |
|--         |--      |--      |--       |
|192.168.0.1|master  |master  | centos7 |
|192.168.0.2|worker  |node1   | centos7 |
|192.168.0.3|worker  |node2   | centos7 |

## [step2:配置节点](#目录)

> 此步骤需要在所有节点上执行  
> 注：ip地址请自行修正，后续的步骤由于测试的原因 ip 地址可能匹配不上

`更新 hosts 文件`
```
cat <<EOF >>/etc/hosts

192.168.0.1 master
192.168.0.2 node1
192.168.0.3 node2

EOF
```

`修改 hostname，和 hosts 文件内容保持一致`
```
hostnamectl set-hostname master
```

`关闭防火墙、selinux和swap`
```
systemctl disable --now firewalld

setenforce 0                                                            # 临时关闭
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config    # 永久禁用

swapoff -a                          # 临时关闭
sed -i 's/.*swap.*/#&/' /etc/fstab  # 永久禁用
```

`配置内核参数，将桥接的IPv4流量传递到iptables的链`
```
yum install -y bridge-utils.x86_64
modprobe  br_netfilter  # 加载 br_netfilter 模块，使用lsmod查看开启的模块

cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system   # 更新所有配置
```

## [step3:安装docker](#目录)

> **此步骤需要在所有节点上执行**

`卸载原来的docker（如有必要）`
```
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

`安装依赖`
```
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
```

`添加docker yum源（选择一个）`
```
# 官方
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# 阿里
sudo yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

`安装docker`
```
sudo yum install -y docker-ce docker-ce-cli containerd.io
```
> 这里可以先查看有哪些支持的版本，然后安装指定的版本
> ```
> yum list docker-ce --showduplicates | sort -r
> ```


`查看docker版本`
```
docker --version
```

`设置开机启动`
```
systemctl enable --now docker
```

`修改docker cgroup驱动：native.cgroupdriver=systemd`
```
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

systemctl restart docker  # 重启使配置生效
```

## [step4:安装k8s管理工具](#目录) 
> 本步骤安装 kubelet kubeadm kubectl  
> **此步骤需要在所有节点上执行**

`添加阿里云yum源`
```
sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
       http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

`安装 kubelet kubeadm kubectl`
```
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
```

`设置 kubelet 自启动(当前不要启动)`
```
systemctl enable kubelet
```

## [step5:拉取k8s服务镜像](#目录)
> 我们使用docker运行 k8s 服务，所以需要先下载所有必要的 docker 镜像
> 如果可以科学上网，可以使用如下命令一步到位：
> ```
> kubeadm config images pull
> ```

`手动拉取 docker 镜像`
> 把所需的镜像下载好，init的时候就不会再拉镜像，由于无法连接google镜像库导致出错
> （推荐使用后面的 脚本进行操作）
```
# 先列出所需镜像
kubeadm config images list
```
>```
>W1011 16:41:22.007451    7794 version.go:101] could not fetch a Kubernetes version from the internet: unable to get URL "https://dl.k8s.io/release/stable-1.txt": Get https://dl.k8s.io/release/stable-1.txt: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
>W1011 16:41:22.007527    7794 version.go:102] falling back to the local client version: v1.16.1
>k8s.gcr.io/kube-apiserver:v1.16.1
>k8s.gcr.io/kube-controller-manager:v1.16.1
>k8s.gcr.io/kube-scheduler:v1.16.1
>k8s.gcr.io/kube-proxy:v1.16.1
>k8s.gcr.io/pause:3.1
>k8s.gcr.io/etcd:3.3.15-0
>k8s.gcr.io/coredns:1.6.2
>```

`使用以下脚本拉取镜像`
> * 此脚本使用阿里云服务器
> * 根据上述输出中版本号更新脚本中的版本号
> * 直接执行拉取 master 所需镜像（master 中执行）
> * 参数 node 拉取 node 所需镜像（node 中执行）
>   * ./pull_images.sh node
> 
> ```sh
> #!/bin/bash
> 
> ## 使用如下脚本下载国内镜像，并修改 tag 为 k8s 的 tag
> set -e
> 
> KUBE_VERSION=v1.16.1
> KUBE_PAUSE_VERSION=3.1
> ETCD_VERSION=3.3.15-0
> CORE_DNS_VERSION=1.6.2
> 
> GCR_URL=k8s.gcr.io
> ALIYUN_URL=registry.cn-hangzhou.aliyuncs.com/google_containers
> 
> if [ $# -ge 1 ]; then
>   
>    if [[ "$1" != "master" ]] && [[ "$1" != "node" ]]; then
>        echo only support \'master\' or \'node\'
>        exit
>    fi
>    
>    type=$1
> 
> else
>    
>    type=master 
> 
> fi
> 
> if [[ "$type" = "master" ]]; then
>  
>   images=(
>     kube-apiserver:${KUBE_VERSION}
>     kube-controller-manager:${KUBE_VERSION}
>     kube-scheduler:${KUBE_VERSION}
>     kube-proxy:${KUBE_VERSION}
>     pause:${KUBE_PAUSE_VERSION}
>     etcd:${ETCD_VERSION}
>     coredns:${CORE_DNS_VERSION}
>   )
> 
> else
> 
>   images=(
>     kube-proxy:${KUBE_VERSION}
>     pause:${KUBE_PAUSE_VERSION}
>   )
> 
> fi
> 
> for imageName in ${images[@]} ; do
>   docker pull $ALIYUN_URL/$imageName
>   docker tag  $ALIYUN_URL/$imageName $GCR_URL/$imageName
>   docker rmi  $ALIYUN_URL/$imageName
>   
>   #echo $ALIYUN_URL/$imageName
> 
> done
> ```

## [step6:创建k8s集群](#目录)
> **此步骤只需在 master 节点上执行**
```
# 初始化Master（Master需要至少2核）此处会各种报错,异常...成功与否就在此
kubeadm init --apiserver-advertise-address 192.168.200.25 --pod-network-cidr 10.244.0.0/16 --kubernetes-version 1.16.1
```
* --apiserver-advertise-address  指定与其它节点通信的接口
* --pod-network-cidr             指定 pod 网络子网，使用 fannel 网络必须使用这个CIDR
* --kubernetes-version           指定K8S版本，这里必须与之前导入到Docker镜像版本一致，否则会访问谷歌去重新下载K8S最新版的Docker镜像

运行初始化，程序会检验环境一致性，可以根据实际错误提示进一步修复问题。
程序会访问https://dl.k8s.io/release/stable-1.txt获取最新的k8s版本，访问这个连接需要科学上网，如果无法访问，则会使用 kubeadm client 的版本作为安装的版本号，使用 kubeadm version 查看 client 版本。也可以使用 --kubernetes-version 明确指定版本
```
[init] Using Kubernetes version: v1.16.1
[preflight] Running pre-flight checks
	[WARNING SystemVerification]: this Docker version is not on the list of validated versions: 19.03.3. Latest validated version: 18.09
	[WARNING Hostname]: hostname "matser" could not be reached
	[WARNING Hostname]: hostname "matser": lookup matser on 192.168.193.2:53: no such host
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Activating the kubelet service
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [matser kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.193.130]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [matser localhost] and IPs [192.168.193.130 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [matser localhost] and IPs [192.168.193.130 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[kubelet-check] Initial timeout of 40s passed.
[apiclient] All control plane components are healthy after 57.002155 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.16" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node matser as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node matser as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: 8tju9u.lctq826mmtpyltkc
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.193.130:6443 --token 8tju9u.lctq826mmtpyltkc \
    --discovery-token-ca-cert-hash sha256:c0bb0601d3ee49278190653197999a7d42b076948a45e5a147ed300bd729726d
```

出现如上所示的输出则表明初始化成功，其中最后面说明了完成 cluster 所要做的其它必要操作，主要有三步：
* 设置配置文件权限
* 为集群应用网络组件
* 子节点加入集群（具体执行的命令已经给出，在子节点上操作）

这里我们先做第一步即可：
```
# 设置配置文件权限
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## [step7:应用flannel网络](#目录)

在上一步，kubeadm 已提示我们要为 集群 应用专门的网络，这里我们选择 flannel，
如果可以科学上网，可以直接使用如下命令：
```  
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

如果不能科学上网，则需进行其它配置

`下载 yml 文件：`
```
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
查看上述文件可知，flannel 使用的镜像为

`下载镜像并设置tag`

`应用flannel网络`
```
kubectl apply -f kube-flannel.yml
```

`验证服务`
```
```
如果不出意外，所有的服务都应该正常运行，输出示例：


## [step8:子节点加入集群](#目录)

`拉取需要的镜像（node）`
> 在 node 端只需要安装 kube-proxy, pause 这两个服务
```
docker pull mirrorgooglecontainers/kube-proxy-amd64:v1.16.1
docker pull mirrorgooglecontainers/pause:3.1
docker tag docker.io/mirrorgooglecontainers/kube-proxy-amd64:v1.16.1  k8s.gcr.io/kube-proxy:v1.16.1
docker tag docker.io/mirrorgooglecontainers/pause:3.1                 k8s.gcr.io/pause:3.1
docker rmi mirrorgooglecontainers/kube-proxy-amd64:v1.16.1
docker rmi mirrorgooglecontainers/pause:3.1
```

`加入集群（node）`
```
# 运行 master 端 初始化时的 node 节点 join 命令
kubeadm join 192.168.193.130:6443 --token 8tju9u.lctq826mmtpyltkc \
    --discovery-token-ca-cert-hash sha256:c0bb0601d3ee49278190653197999a7d42b076948a45e5a147ed300bd729726d
```
> 输出如下
> ```
> [preflight] Running pre-flight checks
> 	[WARNING SystemVerification]: this Docker version is not on the list of validated versions: 19.03.3. Latest validated version: 18.09
> [preflight] Reading configuration from the cluster...
> [preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
> [kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.16" ConfigMap in the kube-system namespace
> [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
> [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
> [kubelet-start] Activating the kubelet service
> [kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...
> 
> This node has joined the cluster:
> * Certificate signing request was sent to apiserver and a response was received.
> * The Kubelet was informed of the new secure connection details.
> 
> Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
> ```


`验证服务（node）`

`验证服务（master）`

## [step9:配置集群](#目录)

`将Master作为工作节点（如有必要）`
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```
> 利用该方法，我们可以不使用 minikube 而创建一个单节点的K8S集群



