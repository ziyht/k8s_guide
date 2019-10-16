# 国内镜像源


常用镜像仓库
|||
|--|--|
|DockerHub镜像仓库| https://hub.docker.com/|
|阿里云镜像仓库| https://cr.console.aliyun.com
|google镜像仓库|https://console.cloud.google.com/gcr/images/google-containers/GLOBAL
|coreos镜像仓库|https://quay.io/repository/
|RedHat镜像仓库|https://access.redhat.com/containers

部分国外镜像仓库无法访问，但国内有对应镜像源，例如kubernetes相关镜像、coreos相关镜像国内无法直接拉取，可以从以下镜像源拉取：

`微软google gcr镜像源`
```sh
#以gcr镜像为例，以下镜像无法直接拉取
docker pull gcr.io/google-containers/kube-apiserver:v1.15.2
#改为以下方式即可成功拉取：
docker pull gcr.azk8s.cn/google-containers/kube-apiserver:v1.15.2
```

`微软coreos quay镜像源`
```sh
#以coreos镜像为例，以下镜像无法直接拉取
docker pull quay.io/coreos/kube-state-metrics:v1.7.2
#改为以下方式即可成功拉取：
docker pull quay.azk8s.cn/coreos/kube-state-metrics:v1.7.2
```

`微软dockerhub镜像源`
```sh
#以下方式拉取镜像较慢
docker pull centos
#改为以下方式使用微软镜像源：
docker pull dockerhub.azk8s.cn/library/centos
docker pull dockerhub.azk8s.cn/willdockerhub/centos
```

`dockerhub google镜像源`
```sh
#以gcr镜像为例，以下镜像无法直接拉取
docker pull gcr.io/google-containers/kube-apiserver:v1.15.2
#改为以下方式即可成功拉取：
docker pull mirrorgooglecontainers/google-containers/kube-apiserver:v1.15.2
```

`阿里云google镜像源`
```sh
#以gcr镜像为例，以下镜像无法直接拉取
docker pull gcr.io/google-containers/kube-apiserver:v1.15.2
#改为以下方式即可成功拉取：
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.15.2
```