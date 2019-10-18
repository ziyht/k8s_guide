# 在 k8s 中部署一个 nginx 的 deployment

### 创建一个 nginx_deployment.yml 文件
[service](https://feisky.gitbooks.io/kubernetes/concepts/service.html)
[deployment](https://feisky.gitbooks.io/kubernetes/concepts/deployment.html)

```yml
# vim nginx_deployment.yml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-dm
spec:
  replicas: 3
  selector:
    matchLabels:
      name: nginx
  template:
    metadata:
      labels:
        name: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
              name: http
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  ports:
    - port: 80
      name: http
      targetPort: 80
      protocol: TCP
  selector:
    name: nginx
```

### 使用 kubectl 部署
```
[root@node1 k8s]# kubectl apply -f nginx_deployment.yml 
deployment.apps/nginx-dm created
service/nginx-svc created
```

### 验证服务
```
[root@node1 k8s]# kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
nginx-dm-b97f5f447-77mqt   1/1     Running   0          39s
nginx-dm-b97f5f447-9rrnk   1/1     Running   0          39s
nginx-dm-b97f5f447-qtvtb   1/1     Running   0          39s

[root@node1 k8s]# kubectl get svc -o wide
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE     SELECTOR
kubernetes   ClusterIP   10.233.0.1     <none>        443/TCP   3h55m   <none>
nginx-svc    ClusterIP   10.233.33.52   <none>        80/TCP    55s     name=nginx

[root@node1 k8s]# curl -I 10.233.33.52
HTTP/1.1 200 OK
Server: nginx/1.17.4
Date: Fri, 18 Oct 2019 07:07:03 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 24 Sep 2019 16:01:13 GMT
Connection: keep-alive
ETag: "5d8a3dc9-264"
Accept-Ranges: bytes
```