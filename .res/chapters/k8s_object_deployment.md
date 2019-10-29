## Deployment

```
apiVersion: apps/v1
#对象类型
kind: Deployment
metadata:
  name: nginx-deployment  #deployment名字
  labels:
    app: nginx   #deployment标签，可以自由定义
spec:
  replicas: 3   #pod 副本数量
  selector:     #pod选择器定义，主要用于定义根据什么标签搜索需要管理的pod
    matchLabels:
      app: nginx  #pod标签
  template:  #pod模版定义
    metadata:
      labels:   #pod 标签定义
        app: nginx
    spec: 
      containers: #容器数组定义
      - name: nginx  #容器名
        image: nginx:1.7.9  #镜像地址
        command: #容器启动命令，【可选】
            - /alidata/www/scripts/start.sh
        ports:  #定义容器需要暴露的端口
            - containerPort: 80
        env: #环境变量定义【可选】
            - name: CONSOLE_URL #变量名
              value: https://www.xxx.com #变量值
```

## Service
```
apiVersion: v1
kind: Service       #对象类型
metadata:
  name: my-service  #服务名
spec:
  type: ClusterIP   # 
  clusterIP: "..."  # 服务IP地址，当 type 为 ClusterIP 时使用，可以为空，这时系统将进行自动分配
  selector:         # pod选择器定义，由这里决定请求转发给那些 pod 处理
    app: nginx          # pod 标签
  ports:            # 服务端口定义
  - name: ""            # 名称，当需要创建多个端口时，需要定义不同的名称
    protocol: TCP       # 协议类型，TCP/UDP
    port: 80            # pod 内部服务端口
    targetPort: 80      # pod 暴露的端口
```
### Service类型
* `ClusterIP`  默认模式，只能在集群内部访问  
* `NodePort`   在每个节点上都监听一个同样的端口号(30000-32767)，ClusterIP和路由规则会自动创建。集群外部可以访问<NodeIP>:<NodePort>联系到集群内部服务，可以配合外部负载均衡使用（可以使用这个模式配合阿里云的SLB）  
* `LoadBalancer` 要配合支持公有云负载均衡使用比如GCE、AWS。其实也是NodePort，只不过会把<NodeIP>:<NodePort>自动添加到公有云的负载均衡当中  
* `ExternalName` 创建一个dns别名指到service name上，主要是防止service name发生变化，要配合dns插件使用

## Ingress

```
apiVersion: extensions/v1beta1
kind: Ingress       # 对象类型
metadata:
  name: my-ingress  # ingress应用名
spec:
  rules:            #路由规则
    - host: www.xxx.com  #域名
      http:
        paths:              #访问路径定义
          - path: /             #代表所有请求路径
            backend:                #将请求转发至什么服务，什么端口
              serviceName: my-service   #服务名
              servicePort: 80           #服务端口
```

## ConfigMap
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config # 配置项名字
data:
    key1: value1
    key2: value2
```
在定义好 ConfigMap 后可以使用如下方式在容器中应用配置：
```
#通过环境变量注入配置
apiVersion: v1
kind: Pod
metadata:
   name: config-pod-1
spec:
   containers:
     - name: test-container
       image: busybox
       command: [ "/bin/sh", "-c", "env" ]
       env:
         - name: SPECIAL_LEVEL_KEY   # 环境变量
           valueFrom:                  # 使用 valueFrom 来指定 env 引用配置项的 value 值
             configMapKeyRef:
               name: my-config           # 引用的配置文件名称
               key: key1                 # 引用的配置项 key1
   restartPolicy: Never
```
```
#通过数据卷注入配置
apiVersion: v1
kind: Pod
metadata:
   name: config-pod-4
spec:
   containers:
     - name: test-container
       image: busybox
       command: [ "/bin/sh", "-c", "ls /etc/config/" ]   ## 列出该目录下的文件名
       volumeMounts:
       - name: config-volume        # 配置项名字
         mountPath: /etc/config     # 容器中的挂载目录
   volumes:                     # 数据卷定义
     - name: config-volume          # 数据卷名
       configMap:                       # 数据卷类型
         name: my-config                # 配置项名字
   restartPolicy: Never
```