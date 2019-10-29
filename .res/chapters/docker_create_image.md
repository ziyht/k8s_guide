# 创建docker镜像

## 基本概念
`镜像`和`容器`:  
镜像的英文名称是 image，镜像是一个抽象的服务，镜像一旦构建之后就不能改变，但是可以重新构建，镜像有版本控制。可以使用 docker images 命令查看所有的镜像。  
而容器的英文名称是 container，是镜像的实例，是具体运行的服务，也就是一个镜像运行一次就产生一个容器。容器可以将当前的状态打包成一个新的镜像，使用 docker ps -a 可以查看所有的容器。

## 构建方式

* 一种是从一个镜像开始，手动进行各种操作，然后提交，构建镜像，类似于操作完成后使用 Git 提交构建一个新的镜像。  
* 第二种是使用一个构建脚本（Dockerfile）自动打包成新的镜像。

## 使用 dockerfile 构建镜像
[官方文档](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

首先，我们先建立一个项目目录：
```
mkdir docker_test
cd docker_test
touch Dockerfile
```
Dockerfile 为一个文本文件，脚本每行一个命令，一般命令用大写字母，后面接命令参数，# 开头的行是注释。
之后我们编辑这个文件，添加镜像的构建步骤
```
vim Dockerfile
```
> ```
> # 基于 busybox 镜像
> FROM busybox
> 
> # 拷贝本地文件到 /test/file
> COPY test /test/file
> 
> # 执行 ls 命令
> CMD ls /test
> ```

`创建本地文件`
```
touch test
```
Dockerfile 中描述了需要拷贝本地文件，这个文件必须存在

`构建镜像`
```
# docker build -t ziyht/test:0.1 --rm .
Sending build context to Docker daemon  3.072kB
Step 1/3 : FROM centos:7
 ---> 67fa590cfc1c
Step 2/3 : COPY test /test/file
 ---> 0158a29a406e
Step 3/3 : CMD ls /test
 ---> Running in abf56237f306
Removing intermediate container abf56237f306
 ---> 6b040408da48
Successfully built 6b040408da48
Successfully tagged ziyht/test:0.1
```
这条命令就会根据我们编写的 Dockerfile 构建镜像。  
* -t 参数指定的是镜像的名称和版本号  
* --rm 参数可以移除构建中生成的临时容器
注意最后一个点，用于使用默认的 Dockerfile 文件，也可以指定其他文件。

`运行镜像`
```
# docker run --name test1 ziyht/test:0.1
file
```

## Dockerfile语法糖
`FROM`
```dockerfile
FROM <image>
FROM <image>:<tag>
FROM <image>@<digest>
```
FROM 指令是最重要的一个并且必须为 Dockerfile 文件开篇的第一个非注释行，用于为镜像文件构建过程指定基础镜像，后续的指令运行于此基础镜像提供的运行环境

这个基础镜像可以是任何可用镜像，默认情况下 docker build 会从本地仓库找指定的镜像文件，如果不存在就会从 Docker Hub 上拉取

`MAINTAINER`(depreacted)
```dockerfile
MAINTAINER wwtg99 <wwtg99@126.com>
```
Dockerfile 的制作者提供的本人详细信息

Dockerfile 不限制 MAINTAINER 出现的位置，但是推荐放到FROM指令之后

`LABEL`
```dockerfile
LABEL <key>=<value> <key>=<value> <key>=<value>...
```
一个 Dockerfile 可以写多个LABEL，但是不推荐这么做，Dockerfile 每一条指令都会生成一层镜像，如果 LABEL 太长可以使用\符号换行。构建的镜像会继承基础镜像的 LABEL，并且会去掉重复的，但如果值不同，则后面的值会覆盖前面的值

`COPY`
> 用于从宿主机复制文件到创建的新镜像中
```dockerfile
COPY <src>...<dest>
COPY ["<src>",..."<dest>"]
# <src>：要复制的源文件或者目录，可以使用通配符
# <dest>：目标路径，即正在创建的 image 的文件系统路径；建议 <dest> 使用绝对路径，否则 COPY 指令则以 WORKDIR 为其起始路径
```

> 注意：如果你的路径中有空白字符，通常会使用第二种格式

规则：

* \<src\> 必须是 build 上下文中的路径，不能是其父目录中的文件
* 如果 \<src\> 是目录，则其内部文件或子目录会被递归复制，但 \<src\>目录自身不会被复制
* 如果指定了多个 \<src\>，或在 \<src\> 中使用了通配符，则 \<dest\>必须是一个目录，且必须以 / 符号结尾
* 如果 \<dest\> 不存在，将会被自动创建，包括其父目录路径

`ADD`
> 基本用法和 COPY 指令一样，ADD 支持使用 TAR 文件和 URL 路径
```dockerfile
ADD <src>...<dest>
ADD ["<src>",..."<dest>"]
```
规则：

* 和COPY规则相同
* 如果 \<src\>为 URL 并且 \<dest\> 没有以/结尾，则\<src\> 指定的文件将被下载到 \<dest\>
* 如果 \<src\> 是一个本地系统上压缩格式的 tar 文件，它会展开成一个目录；但是通过 URL 获取的 tar 文件不会自动展开
* 如果 \<src\> 有多个，直接或间接使用了通配符指定多个资源，则 \<dest\> 必须是目录并且以 / 结尾

`WORKDIR`  
> 用于为 Dockerfile 中所有的 RUN、CMD、ENTRYPOINT、COPY 和 ADD 指定设定工作目录，只会影响当前 WORKDIR 之后的指令。
```dockerfile
WORKDIR <dirpath>
```
在 Dockerfile 文件中，WORKDIR 可以出现多次，路径可以是相对路径，但是它是相对于前一个 WORKDIR 指令指定的路径

另外，WORKDIR 可以是 ENV 指定定义的变量

`VOLUME`
> 用来创建挂载点，可以挂载宿主机上的卷或者其他容器上的卷
```dockerfile
VOLUME <mountpoint>
VOLUME ["<mountpoint>"]
```
VOLUME 命令用于将镜像内部的文件点暴露，可以在运行时挂载其他的路径作为数据卷。简单地说就是我们这里指定镜像中的目录，在运行这个容器时我们挂载一个其他的目录上去，替换镜像中的这个目录。

`EXPOSE`
> 用于给容器打开指定要监听的端口以实现和外部通信

```dockerfile
EXPOSE <port>[/<protocol>] [<port>[/<protocol>]...]
```

\<protocol\> 用于指定传输层协议，可以是 TCP 或者 UDP，默认是 TCP 协议

EXPOSE 可以一次性指定多个端口，例如：EXPOSE 80/tcp 80/udp

`ENV`
> 用来给镜像定义所需要的环境变量，并且可以被 Dockerfile 文件中位于其后的其他指令(如 ENV、ADD、COPY 等)所调用，调用格式：$variable_name 或者 ${variable_name}
```dockerfile
ENV <key> <value>
ENV <key>=<value>...
```
第一种格式中，\<key\> 之后的所有内容都会被视为 \<value\> 的组成部分，所以一次只能设置一个变量

第二种格式可以一次设置多个变量，如果 \<value\> 当中有空格可以使用 \ 进行转义或者对 \<value\> 加引号进行标识；另外 \ 也可以用来续行

`ARG`
> 用法同 ENV
```dockerfile
ARG <name>[=<default value>]
```
指定一个变量，可以在docker build创建镜像的时候，使用 --build-arg \<varname\>=\<value\> 来指定参数

`RUN`
> 用来指定 docker build 过程中运行指定的命令
```dockerfile
RUN <command>
RUN ["<executable>","<param1>","<param2>"]
```

第一种格式里面的参数一般是一个 shel l命令，以 /bin/sh -c 来运行它

第二种格式中的参数是一个 JSON 格式的数组，当中 \<executable\> 是要运行的命令，后面是传递给命令的选项或者参数；但是这种格式不会用 /bin/sh -c 来发起，所以常见的 shell 操作像变量替换和通配符替换不会进行；如果你运行的命令依赖 shell 特性，可以替换成类型以下的格式
```dockerfile
RUN ["/bin/bash","-c","<executable>","<param1>"]
```

`CMD`
> 容器启动时运行的命令
```dockerfile
CMD <command>
CMD ["<executable>","<param1>","<param2>"]
CMD ["<param1>","<param2>"]
```
前两种语法和 RUN 相同

第三种语法用于为 ENTRYPOINT 指令提供默认参数

RUN 和 CMD 区别：

* RUN 指令运行于镜像文件构建过程中，CMD 则运行于基于 Dockerfile 构建出的新镜像文件启动为一个容器的时候
* CMD 指令的主要目的在于给启动的容器指定默认要运行的程序，且在运行结束后，容器也将终止；不过，CMD 命令可以被 docker run 的命令行选项给覆盖
* Dockerfile 中可以存在多个 CMD 指令，但是只有最后一个会生效

`ENTRYPOINT`
> 类似于CMD指令功能，用于给容器指定默认运行程序
```dockerfile
ENTRYPOINT <command>
ENTRYPOINT ["<executable>","<param1>","<param2>"]
```

和 CMD 不同的是 ENTRYPOINT 启动的程序不会被 docker run 命令指定的参数所覆盖，而且，这些命令行参数会被当做参数传递给 ENTRYPOINT 指定的程序(但是，docker run 命令的--entrypoint 参数可以覆盖 ENTRYPOINT)

docker run 命令传入的参数会覆盖 CMD 指令的内容并且附加到 ENTRYPOINT 命令最后作为其参数使用

同样，Dockerfil e中可以存在多个 ENTRYPOINT 指令，但是只有最后一个会生效

Dockerfile 中如果既有 CMD 又有 ENTRYPOINT，并且 CMD 是一个完整可执行命令，那么谁在最后谁生效

`ONBUILD`
```dockerfile
ONBUILD <instruction>
```
Dockerfile 用来构建镜像文件，镜像文件也可以当成是基础镜像被另外一个 Dockerfile 用作 FROM 指令的参数

在后面这个 Dockerfile 中的 FROM 指令在构建过程中被执行的时候，会触发基础镜像里面的 ONBUILD 指令

ONBUILD 不能自我嵌套，ONBUILD 不会触发 FROM 和 MAINTAINER 指令

在 ONBUILD 指令中使用 ADD 和 COPY 要小心，因为新构建过程中的上下文在缺少指定的源文件的时候会失败。

## Dockerfile语法糖进阶
`多阶段构建`（自从Docker 17.05版本提供的方法）  
多阶段允许在创建 Dockerfile 时使用多个 FROM，它非常有用，因为它使我们能够使用所有必需的工具构建应用程序。

举个例子，首先我们使用 Golang 的基础镜像，然后在第二阶段的时候使用构建好的镜像的二进制文件，最后阶段构建出来的镜像用于发布到我们自己的仓库或者是用于上线发布。

```dockerfile
# ----------------------------------------
# 构建阶段，使用go基础镜像构建产生的镜像比较大，一般几百兆
#

# basic
FROM golang:1.12 AS builder

# build
WORKDIR /go/src/ziyht/proj_name
ADD . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo .

# ----------------------------------------
# 生产阶段
# 在这个阶段，我们只添加我们需要的内容，这将使我们的镜像非常纯净
#
FROM scratch AS prod

# port
EXPOSE 9400

# 拷贝构建的文件
COPY --from=builder /go/src/ziyht/proj_name/proj_name .

# 最终的CMD
CMD ["./proj_name", "-p 9400"]
```

## 常用命令
`镜像操作`
```sh
docker images               # 查看镜像
docker rmi <镜像ID或名称>    # 删除镜像
docker search <关键词>      # 在镜像仓库中搜索
docker pull <镜像>          # 从镜像仓库拉取镜像
docker save -o image.tar <镜像ID或名称>  # 将镜像保存到文件
docker load -i image.tar                # 从文件载入镜像
```
`容器操作`
```sh
docker ps                       # 查看运行的容器
docker ps -a                    # 查看所有的容器
docker restart <容器ID或名称>    # 重启容器
docker stop <容器ID或名称>       # 停止容器
docker start <容器ID或名称>      # 启动停止的容器
docker rm <容器ID或名称>         # 删除容器，必须先停止，使用 -f 参数强制删除
docker logs <容器ID或名称>       # 查看容器的日志
docker exec <容器ID或名称> <命令>       # 在容器中执行命令
docker exec -ti <容器ID或名称> bash     # 典型的用法是登陆容器的 bash
docker top <容器ID或名称>        # 查看容器的进程
docker inspect <容器ID或名称>    # 查看容器的底层信息，如 IP 等
```

`删除none镜像`
```
docker ps -a | grep "Exited" | awk '{print $1 }'|xargs docker stop
docker ps -a | grep "Exited" | awk '{print $1 }'|xargs docker rm
docker images|grep none|awk '{print $3 }'|xargs docker rmi
```

## 镜像仓库
`登录`
> 在发布前，我们需要先登录到 docker hub 服务器，当然，首先你得有自己的账号
```
docker login
```
然后输入你的用户密码即可

`发布`
```
docker push ${youname}/${image_name}:${image_version}
```

`备份别人的镜像到自己的仓库`
```
docker tag ${other}/${image_name}:${image_version} ${youname}/${image_name}:${image_version}
docker push ${youname}/${image_name}:${image_version}
```
这里其实就是使用 tag 把指定镜像的标签改了一下


## 自动编排（todo）