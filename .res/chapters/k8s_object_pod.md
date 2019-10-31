# Pod


# 目录
* [特征](#特征)
* [定义](#定义)

## 特征
* `网络共享`：包含多个共享 IPC、Network 和 UTC namespace 的容器，可直接通过 localhost 通信
* 所有 Pod 内容器都可以访问共享的 Volume，可以访问共享数据
* `存储共享`：无容错性：直接创建的 Pod 一旦被调度后就跟 Node 绑定，即使 Node 挂掉也不会被重新调度（而是被自动删除），因此推荐使用 Deployment、Daemonset 等控制器来容错
* `优雅终止`：Pod 删除的时候先给其内的进程发送 SIGTERM，等待一段时间（grace period）后才强制停止依然还在运行的进程
* `特权容器`（通过 SecurityContext 配置）具有改变系统配置的权限（在网络插件中大量应用）

## API
|Kubernetes | API Ver | Auto ON|
|:--        |:--      |:--:    |
|v1.5+      | core/v1 | yes    |


## 定义

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```
`在生产环境中，推荐使用 Deployment、StatefulSet、Job 或者 CronJob 等控制器来创建 Pod，而不推荐直接创建 Pod。`

## 外置存储
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:           # 定义挂载卷
    - name: redis-storage       # 名称，需要在后续的 volumes 中进行定义
      mountPath: /data/redis    # 挂载到 镜像中的路径
  volumes:                  # 定义卷
  - name: redis-storage         # 名称
    emptyDir: {}                # 此卷的详情，类型，来源...
```
上述示例中 volume 的类型为 emptyDir，Pod 被分配到 Node 上时候，会创建 emptyDir，只要 Pod 运行在 Node 上，emptyDir 都会存在（容器挂掉不会导致 emptyDir 丢失数据），但是如果 Pod 从 Node 上被删除（Pod 被删除，或者 Pod 发生迁移），emptyDir 也会被删除，并且永久丢失。

### Volumes


