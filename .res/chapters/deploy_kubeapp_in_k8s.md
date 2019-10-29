# 在 k8s 上部署 kubeapp

## kubeapp 简介
kubeapp 是 一个基于 helm 的带 UI 的 k8s 应用管理器，你可以认为它就是 helm 的UI版。通过它，我们可以通过 UI 界面交互式的部署应用，删除应用，升级应用等等。

## 前置要求

需要先在 k8s 中部署 helm，在使用 kubespray 部署 k8s 时 可以 通过修改 inventory/$name/group_vars/k8s-cluster/addons.yml 中的插件开关进行部署helm。
```yml
# Helm deployment
helm_enabled: true
```


## 部署

[查看官方步骤](https://github.com/kubeapps/kubeapps/blob/master/docs/user/getting-started.md)


添加源并安装 kubeapps
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install --name kubeapps --namespace kubeapps bitnami/kubeapps
```
> 这一步会花费比较长的时间，期间要下载镜像，可以先做后面的  
> 可通过 kubectl get pods -w --namespace kubeapps 查看实时状态

创建token
```
kubectl create serviceaccount kubeapps-operator
kubectl create clusterrolebinding kubeapps-operator --clusterrole=cluster-admin --serviceaccount=default:kubeapps-operator
```

获取token(登录密码)
```
kubectl get secret $(kubectl get serviceaccount kubeapps-operator -o jsonpath='{.secrets[].name}') -o jsonpath='{.data.token}' | base64 --decode
```

创建服务
```
vim  kubeapps-svc.yml
```
```yml
apiVersion: v1
kind: Service
metadata:
 name: kubeapps-svc
 namespace: kubeapps
 labels:
  app: kubeapps
spec:
 type: NodePort
 ports:
 - port: 8080
   nodePort: 30080  # 外部访问端口
 selector:
  app: kubeapps
```

应用服务
```
kubectl create -f kubeapps-svc.yml
```

检查 pods 是否都已启动
```
kubectl get pods --namespace kubeapps
NAME                                                          READY   STATUS      RESTARTS   AGE
apprepo-sync-bitnami-1571823600-vs8dc                         0/1     Completed   1          3m31s
apprepo-sync-bitnami-qrknw-rp6dg                              0/1     Completed   0          5m42s
apprepo-sync-incubator-1571823600-slv56                       0/1     Completed   1          3m31s
apprepo-sync-incubator-zrbcg-jm6lk                            0/1     Completed   0          5m42s
apprepo-sync-stable-1571823600-grhgm                          0/1     Completed   0          3m31s
apprepo-sync-stable-j6tkm-kqdg7                               0/1     Completed   0          5m42s
apprepo-sync-svc-cat-1571823600-8znl8                         0/1     Completed   0          3m31s
apprepo-sync-svc-cat-r9f6q-n5d9d                              0/1     Completed   3          5m42s
kubeapps-5744dc644b-5n6ww                                     1/1     Running     0          7m33s
kubeapps-5744dc644b-dkv87                                     1/1     Running     0          7m33s
kubeapps-internal-apprepository-controller-56c4d9d966-8ns8t   1/1     Running     0          7m33s
kubeapps-internal-chartsvc-7b6546754f-6p52w                   1/1     Running     4          7m33s
kubeapps-internal-chartsvc-7b6546754f-xgcqf                   1/1     Running     5          7m33s
kubeapps-internal-dashboard-587c896f59-6ppfz                  1/1     Running     0          7m33s
kubeapps-internal-dashboard-587c896f59-b6z62                  1/1     Running     0          7m33s
kubeapps-internal-tiller-proxy-554648bbb8-d75xp               1/1     Running     0          7m33s
kubeapps-internal-tiller-proxy-554648bbb8-mxlv4               1/1     Running     0          7m33s
kubeapps-mongodb-788ff89fd9-7rltn                             1/1     Running     0          7m33s
```

访问  
登录 http：//服务ip:30080 即可访问，输入之前获取的 token 登录

