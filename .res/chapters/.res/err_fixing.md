## 1. apply flannel 报错

```
Error from server (Forbidden): error when retrieving current configuration of:
Resource: "policy/v1beta1, Resource=podsecuritypolicies", GroupVersionKind: "policy/v1beta1, Kind=PodSecurityPolicy"
Name: "psp.flannel.unprivileged", Namespace: ""
Object: &{map["apiVersion":"policy/v1beta1" "kind":"PodSecurityPolicy" "metadata":map["annotations":map["apparmor.security.beta.kubernetes.io/allowedProfileNames":"runtime/default" "apparmor.security.beta.kubernetes.io/defaultProfileName":"runtime/default" "kubectl.kubernetes.io/last-applied-configuration":"" "seccomp.security.alpha.kubernetes.io/allowedProfileNames":"docker/default" "seccomp.security.alpha.kubernetes.io/defaultProfileName":"docker/default"] "name":"psp.flannel.unprivileged"] "spec":map["allowPrivilegeEscalation":%!q(bool=false) "allowedCapabilities":["NET_ADMIN"] "allowedHostPaths":[map["pathPrefix":"/etc/cni/net.d"] map["pathPrefix":"/etc/kube-flannel"] map["pathPrefix":"/run/flannel"]] "defaultAddCapabilities":[] "defaultAllowPrivilegeEscalation":%!q(bool=false) "fsGroup":map["rule":"RunAsAny"] "hostIPC":%!q(bool=false) "hostNetwork":%!q(bool=true) "hostPID":%!q(bool=false) "hostPorts":[map["max":'\uffff' "min":'\x00']] "privileged":%!q(bool=false) "readOnlyRootFilesystem":%!q(bool=false) "requiredDropCapabilities":[] "runAsUser":map["rule":"RunAsAny"] "seLinux":map["rule":"RunAsAny"] "supplementalGroups":map["rule":"RunAsAny"] "volumes":["configMap" "secret" "emptyDir" "hostPath"]]]}
from server for: "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml": podsecuritypolicies.policy "psp.flannel.unprivileged" is forbidden: User "system:node:master" cannot get resource "podsecuritypolicies" in API group "policy" at the cluster scope
Error from server (Forbidden): error when retrieving current configuration of:
Resource: "rbac.authorization.k8s.io/v1beta1, Resource=clusterroles", GroupVersionKind: "rbac.authorization.k8s.io/v1beta1, Kind=ClusterRole"
Name: "flannel", Namespace: ""
Object: &{map["apiVersion":"rbac.authorization.k8s.io/v1beta1" "kind":"ClusterRole" "metadata":map["annotations":map["kubectl.kubernetes.io/last-applied-configuration":""] "name":"flannel"] "rules":[map["apiGroups":["extensions"] "resourceNames":["psp.flannel.unprivileged"] "resources":["podsecuritypolicies"] "verbs":["use"]] map["apiGroups":[""] "resources":["pods"] "verbs":["get"]] map["apiGroups":[""] "resources":["nodes"] "verbs":["list" "watch"]] map["apiGroups":[""] "resources":["nodes/status"] "verbs":["patch"]]]]}
from server for: "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml": clusterroles.rbac.authorization.k8s.io "flannel" is forbidden: User "system:node:master" cannot get resource "clusterroles" in API group "rbac.authorization.k8s.io" at the cluster scope
Error from server (Forbidden): error when retrieving current configuration of:
Resource: "rbac.authorization.k8s.io/v1beta1, Resource=clusterrolebindings", GroupVersionKind: "rbac.authorization.k8s.io/v1beta1, Kind=ClusterRoleBinding"
Name: "flannel", Namespace: ""
Object: &{map["apiVersion":"rbac.authorization.k8s.io/v1beta1" "kind":"ClusterRoleBinding" "metadata":map["annotations":map["kubectl.kubernetes.io/last-applied-configuration":""] "name":"flannel"] "roleRef":map["apiGroup":"rbac.authorization.k8s.io" "kind":"ClusterRole" "name":"flannel"] "subjects":[map["kind":"ServiceAccount" "name":"flannel" "namespace":"kube-system"]]]}
from server for: "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml": clusterrolebindings.rbac.authorization.k8s.io "flannel" is forbidden: User "system:node:master" cannot get resource "clusterrolebindings" in API group "rbac.authorization.k8s.io" at the cluster scope
Error from server (Forbidden): error when retrieving current configuration of:
Resource: "/v1, Resource=serviceaccounts", GroupVersionKind: "/v1, Kind=ServiceAccount"
Name: "flannel", Namespace: "kube-system"
Object: &{map["apiVersion":"v1" "kind":"ServiceAccount" "metadata":map["annotations":map["kubectl.kubernetes.io/last-applied-configuration":""] "name":"flannel" "namespace":"kube-system"]]}
from server for: "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml": serviceaccounts "flannel" is forbidden: User "system:node:master" cannot get resource "serviceaccounts" in API group "" in the namespace "kube-system": can only create tokens for individual service accounts
Error from server (Forbidden): error when retrieving current configuration of:
Resource: "/v1, Resource=configmaps", GroupVersionKind: "/v1, Kind=ConfigMap"
Name: "kube-flannel-cfg", Namespace: "kube-system"
Object: &{map["apiVersion":"v1" "data":map["cni-conf.json":"{\n  \"name\": \"cbr0\",\n  \"cniVersion\": \"0.3.1\",\n  \"plugins\": [\n    {\n      \"type\": \"flannel\",\n      \"delegate\": {\n        \"hairpinMode\": true,\n        \"isDefaultGateway\": true\n      }\n    },\n    {\n      \"type\": \"portmap\",\n      \"capabilities\": {\n        \"portMappings\": true\n      }\n    }\n  ]\n}\n" "net-conf.json":"{\n  \"Network\": \"10.244.0.0/16\",\n  \"Backend\": {\n    \"Type\": \"vxlan\"\n  }\n}\n"] "kind":"ConfigMap" "metadata":map["annotations":map["kubectl.kubernetes.io/last-applied-configuration":""] "labels":map["app":"flannel" "tier":"node"] "name":"kube-flannel-cfg" "namespace":"kube-system"]]}
from server for: "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml": configmaps "kube-flannel-cfg" is forbidden: User "system:node:master" cannot get resource "configmaps" in API group "" in the namespace "kube-system": no relationship found between node "master" and this object
Error from server (Forbidden): error when retrieving current configuration of:
Resource: "apps/v1, Resource=daemonsets", GroupVersionKind: "apps/v1, Kind=DaemonSet"
Name: "kube-flannel-ds-amd64", Namespace: "kube-system"
Object: &{map["apiVersion":"apps/v1" "kind":"DaemonSet" "metadata":map["annotations":map["kubectl.kubernetes.io/last-applied-configuration":""] "labels":map["app":"flannel" "tier":"node"] "name":"kube-flannel-ds-amd64" "namespace":"kube-system"] "spec":map["selector":map["matchLabels":map["app":"flannel"]] "template":map["metadata":map["labels":map["app":"flannel" "tier":"node"]] "spec":map["affinity":map["nodeAffinity":map["requiredDuringSchedulingIgnoredDuringExecution":map["nodeSelectorTerms":[map["matchExpressions":[map["key":"beta.kubernetes.io/os" "operator":"In" "values":["linux"]] map["key":"beta.kubernetes.io/arch" "operator":"In" "values":["amd64"]]]]]]]] "containers":[map["args":["--ip-masq" "--kube-subnet-mgr"] "command":["/opt/bin/flanneld"] "env":[map["name":"POD_NAME" "valueFrom":map["fieldRef":map["fieldPath":"metadata.name"]]] map["name":"POD_NAMESPACE" "valueFrom":map["fieldRef":map["fieldPath":"metadata.namespace"]]]] "image":"quay.io/coreos/flannel:v0.11.0-amd64" "name":"kube-flannel" "resources":map["limits":map["cpu":"100m" "memory":"50Mi"] "requests":map["cpu":"100m" "memory":"50Mi"]] "securityContext":map["capabilities":map["add":["NET_ADMIN"]] "privileged":%!q(bool=false)] "volumeMounts":[map["mountPath":"/run/flannel" "name":"run"] map["mountPath":"/etc/kube-flannel/" "name":"flannel-cfg"]]]] "hostNetwork":%!q(bool=true) "initContainers":[map["args":["-f" "/etc/kube-flannel/cni-conf.json" "/etc/cni/net.d/10-flannel.conflist"] "command":["cp"] "image":"quay.io/coreos/flannel:v0.11.0-amd64" "name":"install-cni" "volumeMounts":[map["mountPath":"/etc/cni/net.d" "name":"cni"] map["mountPath":"/etc/kube-flannel/" "name":"flannel-cfg"]]]] "serviceAccountName":"flannel" "tolerations":[map["effect":"NoSchedule" "operator":"Exists"]] "volumes":[map["hostPath":map["path":"/run/flannel"] "name":"run"] map["hostPath":map["path":"/etc/cni/net.d"] "name":"cni"] map["configMap":map["name":"kube-flannel-cfg"] "name":"flannel-cfg"]]]]]]}
from server for: "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml": daemonsets.apps "kube-flannel-ds-amd64" is forbidden: User "system:node:master" cannot get resource "daemonsets" in API group "apps" in the namespace "kube-system"
Error from server (Forbidden): error when retrieving current configuration of:
Resource: "apps/v1, Resource=daemonsets", GroupVersionKind: "apps/v1, Kind=DaemonSet"
Name: "kube-flannel-ds-arm64", Namespace: "kube-system"
Object: &{map["apiVersion":"apps/v1" "kind":"DaemonSet" "metadata":map["annotations":map["kubectl.kubernetes.io/last-applied-configuration":""] "labels":map["app":"flannel" "tier":"node"] "name":"kube-flannel-ds-arm64" "namespace":"kube-system"] "spec":map["selector":map["matchLabels":map["app":"flannel"]] "template":map["metadata":map["labels":map["app":"flannel" "tier":"node"]] "spec":map["affinity":map["nodeAffinity":map["requiredDuringSchedulingIgnoredDuringExecution":map["nodeSelectorTerms":[map["matchExpressions":[map["key":"beta.kubernetes.io/os" "operator":"In" "values":["linux"]] map["key":"beta.kubernetes.io/arch" "operator":"In" "values":["arm64"]]]]]]]] "containers":[map["args":["--ip-masq" "--kube-subnet-mgr"] "command":["/opt/bin/flanneld"] "env":[map["name":"POD_NAME" "valueFrom":map["fieldRef":map["fieldPath":"metadata.name"]]] map["name":"POD_NAMESPACE" "valueFrom":map["fieldRef":map["fieldPath":"metadata.namespace"]]]] "image":"quay.io/coreos/flannel:v0.11.0-arm64" "name":"kube-flannel" "resources":map["limits":map["cpu":"100m" "memory":"50Mi"] "requests":map["cpu":"100m" "memory":"50Mi"]] "securityContext":map["capabilities":map["add":["NET_ADMIN"]] "privileged":%!q(bool=false)] "volumeMounts":[map["mountPath":"/run/flannel" "name":"run"] map["mountPath":"/etc/kube-flannel/" "name":"flannel-cfg"]]]] "hostNetwork":%!q(bool=true) "initContainers":[map["args":["-f" "/etc/kube-flannel/cni-conf.json" "/etc/cni/net.d/10-flannel.conflist"] "command":["cp"] "image":"quay.io/coreos/flannel:v0.11.0-arm64" "name":"install-cni" "volumeMounts":[map["mountPath":"/etc/cni/net.d" "name":"cni"] map["mountPath":"/etc/kube-flannel/" "name":"flannel-cfg"]]]] "serviceAccountName":"flannel" "tolerations":[map["effect":"NoSchedule" "operator":"Exists"]] "volumes":[map["hostPath":map["path":"/run/flannel"] "name":"run"] map["hostPath":map["path":"/etc/cni/net.d"] "name":"cni"] map["configMap":map["name":"kube-flannel-cfg"] "name":"flannel-cfg"]]]]]]}
from server for: "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml": daemonsets.apps "kube-flannel-ds-arm64" is forbidden: User "system:node:master" cannot get resource "daemonsets" in API group "apps" in the namespace "kube-system"
Error from server (Forbidden): error when retrieving current configuration of:
Resource: "apps/v1, Resource=daemonsets", GroupVersionKind: "apps/v1, Kind=DaemonSet"
Name: "kube-flannel-ds-arm", Namespace: "kube-system"
Object: &{map["apiVersion":"apps/v1" "kind":"DaemonSet" "metadata":map["annotations":map["kubectl.kubernetes.io/last-applied-configuration":""] "labels":map["app":"flannel" "tier":"node"] "name":"kube-flannel-ds-arm" "namespace":"kube-system"] "spec":map["selector":map["matchLabels":map["app":"flannel"]] "template":map["metadata":map["labels":map["app":"flannel" "tier":"node"]] "spec":map["affinity":map["nodeAffinity":map["requiredDuringSchedulingIgnoredDuringExecution":map["nodeSelectorTerms":[map["matchExpressions":[map["key":"beta.kubernetes.io/os" "operator":"In" "values":["linux"]] map["key":"beta.kubernetes.io/arch" "operator":"In" "values":["arm"]]]]]]]] "containers":[map["args":["--ip-masq" "--kube-subnet-mgr"] "command":["/opt/bin/flanneld"] "env":[map["name":"POD_NAME" "valueFrom":map["fieldRef":map["fieldPath":"metadata.name"]]] map["name":"POD_NAMESPACE" "valueFrom":map["fieldRef":map["fieldPath":"metadata.namespace"]]]] "image":"quay.io/coreos/flannel:v0.11.0-arm" "name":"kube-flannel" "resources":map["limits":map["cpu":"100m" "memory":"50Mi"] "requests":map["cpu":"100m" "memory":"50Mi"]] "securityContext":map["capabilities":map["add":["NET_ADMIN"]] "privileged":%!q(bool=false)] "volumeMounts":[map["mountPath":"/run/flannel" "name":"run"] map["mountPath":"/etc/kube-flannel/" "name":"flannel-cfg"]]]] "hostNetwork":%!q(bool=true) "initContainers":[map["args":["-f" "/etc/kube-flannel/cni-conf.json" "/etc/cni/net.d/10-flannel.conflist"] "command":["cp"] "image":"quay.io/coreos/flannel:v0.11.0-arm" "name":"install-cni" "volumeMounts":[map["mountPath":"/etc/cni/net.d" "name":"cni"] map["mountPath":"/etc/kube-flannel/" "name":"flannel-cfg"]]]] "serviceAccountName":"flannel" "tolerations":[map["effect":"NoSchedule" "operator":"Exists"]] "volumes":[map["hostPath":map["path":"/run/flannel"] "name":"run"] map["hostPath":map["path":"/etc/cni/net.d"] "name":"cni"] map["configMap":map["name":"kube-flannel-cfg"] "name":"flannel-cfg"]]]]]]}
from server for: "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml": daemonsets.apps "kube-flannel-ds-arm" is forbidden: User "system:node:master" cannot get resource "daemonsets" in API group "apps" in the namespace "kube-system"
Error from server (Forbidden): error when retrieving current configuration of:
Resource: "apps/v1, Resource=daemonsets", GroupVersionKind: "apps/v1, Kind=DaemonSet"
Name: "kube-flannel-ds-ppc64le", Namespace: "kube-system"
Object: &{map["apiVersion":"apps/v1" "kind":"DaemonSet" "metadata":map["annotations":map["kubectl.kubernetes.io/last-applied-configuration":""] "labels":map["app":"flannel" "tier":"node"] "name":"kube-flannel-ds-ppc64le" "namespace":"kube-system"] "spec":map["selector":map["matchLabels":map["app":"flannel"]] "template":map["metadata":map["labels":map["app":"flannel" "tier":"node"]] "spec":map["affinity":map["nodeAffinity":map["requiredDuringSchedulingIgnoredDuringExecution":map["nodeSelectorTerms":[map["matchExpressions":[map["key":"beta.kubernetes.io/os" "operator":"In" "values":["linux"]] map["key":"beta.kubernetes.io/arch" "operator":"In" "values":["ppc64le"]]]]]]]] "containers":[map["args":["--ip-masq" "--kube-subnet-mgr"] "command":["/opt/bin/flanneld"] "env":[map["name":"POD_NAME" "valueFrom":map["fieldRef":map["fieldPath":"metadata.name"]]] map["name":"POD_NAMESPACE" "valueFrom":map["fieldRef":map["fieldPath":"metadata.namespace"]]]] "image":"quay.io/coreos/flannel:v0.11.0-ppc64le" "name":"kube-flannel" "resources":map["limits":map["cpu":"100m" "memory":"50Mi"] "requests":map["cpu":"100m" "memory":"50Mi"]] "securityContext":map["capabilities":map["add":["NET_ADMIN"]] "privileged":%!q(bool=false)] "volumeMounts":[map["mountPath":"/run/flannel" "name":"run"] map["mountPath":"/etc/kube-flannel/" "name":"flannel-cfg"]]]] "hostNetwork":%!q(bool=true) "initContainers":[map["args":["-f" "/etc/kube-flannel/cni-conf.json" "/etc/cni/net.d/10-flannel.conflist"] "command":["cp"] "image":"quay.io/coreos/flannel:v0.11.0-ppc64le" "name":"install-cni" "volumeMounts":[map["mountPath":"/etc/cni/net.d" "name":"cni"] map["mountPath":"/etc/kube-flannel/" "name":"flannel-cfg"]]]] "serviceAccountName":"flannel" "tolerations":[map["effect":"NoSchedule" "operator":"Exists"]] "volumes":[map["hostPath":map["path":"/run/flannel"] "name":"run"] map["hostPath":map["path":"/etc/cni/net.d"] "name":"cni"] map["configMap":map["name":"kube-flannel-cfg"] "name":"flannel-cfg"]]]]]]}
from server for: "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml": daemonsets.apps "kube-flannel-ds-ppc64le" is forbidden: User "system:node:master" cannot get resource "daemonsets" in API group "apps" in the namespace "kube-system"
Error from server (Forbidden): error when retrieving current configuration of:
Resource: "apps/v1, Resource=daemonsets", GroupVersionKind: "apps/v1, Kind=DaemonSet"
Name: "kube-flannel-ds-s390x", Namespace: "kube-system"
Object: &{map["apiVersion":"apps/v1" "kind":"DaemonSet" "metadata":map["annotations":map["kubectl.kubernetes.io/last-applied-configuration":""] "labels":map["app":"flannel" "tier":"node"] "name":"kube-flannel-ds-s390x" "namespace":"kube-system"] "spec":map["selector":map["matchLabels":map["app":"flannel"]] "template":map["metadata":map["labels":map["app":"flannel" "tier":"node"]] "spec":map["affinity":map["nodeAffinity":map["requiredDuringSchedulingIgnoredDuringExecution":map["nodeSelectorTerms":[map["matchExpressions":[map["key":"beta.kubernetes.io/os" "operator":"In" "values":["linux"]] map["key":"beta.kubernetes.io/arch" "operator":"In" "values":["s390x"]]]]]]]] "containers":[map["args":["--ip-masq" "--kube-subnet-mgr"] "command":["/opt/bin/flanneld"] "env":[map["name":"POD_NAME" "valueFrom":map["fieldRef":map["fieldPath":"metadata.name"]]] map["name":"POD_NAMESPACE" "valueFrom":map["fieldRef":map["fieldPath":"metadata.namespace"]]]] "image":"quay.io/coreos/flannel:v0.11.0-s390x" "name":"kube-flannel" "resources":map["limits":map["cpu":"100m" "memory":"50Mi"] "requests":map["cpu":"100m" "memory":"50Mi"]] "securityContext":map["capabilities":map["add":["NET_ADMIN"]] "privileged":%!q(bool=false)] "volumeMounts":[map["mountPath":"/run/flannel" "name":"run"] map["mountPath":"/etc/kube-flannel/" "name":"flannel-cfg"]]]] "hostNetwork":%!q(bool=true) "initContainers":[map["args":["-f" "/etc/kube-flannel/cni-conf.json" "/etc/cni/net.d/10-flannel.conflist"] "command":["cp"] "image":"quay.io/coreos/flannel:v0.11.0-s390x" "name":"install-cni" "volumeMounts":[map["mountPath":"/etc/cni/net.d" "name":"cni"] map["mountPath":"/etc/kube-flannel/" "name":"flannel-cfg"]]]] "serviceAccountName":"flannel" "tolerations":[map["effect":"NoSchedule" "operator":"Exists"]] "volumes":[map["hostPath":map["path":"/run/flannel"] "name":"run"] map["hostPath":map["path":"/etc/cni/net.d"] "name":"cni"] map["configMap":map["name":"kube-flannel-cfg"] "name":"flannel-cfg"]]]]]]}
from server for: "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml": daemonsets.apps "kube-flannel-ds-s390x" is forbidden: User "system:node:master" cannot get resource "daemonsets" in API group "apps" in the namespace "kube-system"
```

```
# 第一步，在master节点删除flannel
kubectl delete -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#第二步，在node节点清理flannel网络留下的文件
ifconfig cni0 down
ip link delete cni0
ifconfig flannel.1 down
ip link delete flannel.1
rm -rf /var/lib/cni/
rm -f /etc/cni/net.d/*

# 重置 iptables
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
```

## 2. 应用 flannel 网络时 出现 Init:ImagePullBackOff
```
[root@localhost k8s]# kubectl get all -n kube-system
NAME                                                READY   STATUS                  RESTARTS   AGE
pod/coredns-5644d7b6d9-xn557                        0/1     Pending                 0          15m
pod/coredns-5644d7b6d9-xskpk                        0/1     Pending                 0          15m
pod/etcd-localhost.localdomain                      1/1     Running                 0          14m
pod/kube-apiserver-localhost.localdomain            1/1     Running                 0          14m
pod/kube-controller-manager-localhost.localdomain   1/1     Running                 0          14m
pod/kube-flannel-ds-amd64-zk65p                     0/1     Init:ImagePullBackOff   0          52s
pod/kube-proxy-lf4cq                                1/1     Running                 0          15m
pod/kube-scheduler-localhost.localdomain            1/1     Running                 0          14m
```

出现此问题的原因是 https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml 中的镜像地址无法拉取，这里可以使用docker拉取其它地址的镜像，再修改tag:  
> 注意： 拉取镜像的操作在子节点上也要执行
```
# 方案1: 直接拉取
docker pull quay.azk8s.cn/coreos/flannel:v0.11.0-amd64
docker tag quay.azk8s.cn/coreos/flannel:v0.11.0-amd64 quay.io/coreos/flannel:v0.11.0-amd64

# 方案2：主服务器无法访问时，先下载，再导入
docker image save quay.azk8s.cn/coreos/flannel:v0.11.0-amd64 >flannelv0.11.0-amd64.tar
docker load < flannelv0.11.0-amd64.tar
docker tag quay.azk8s.cn/coreos/flannel:v0.11.0-amd64 quay.io/coreos/flannel:v0.11.0-amd64
```

然后重新应用 flannel 网络
```
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl delete -f kube-flannel.yml
kubectl apply  -f kube-flannel.yml
```