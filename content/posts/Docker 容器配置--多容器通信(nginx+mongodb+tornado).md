+++
draft = false
date = 2019-03-24T15:29:39+08:00
title = "Docker 容器配置--多容器通信(Nginx + MongoDB + Tornado)"
slug = "Docker 容器配置--多容器通信(Nginx + MongoDB + Tornado)" 
tags = ["Docker"]
categories = ["Record"]

+++

# Docker 容器化部署尝试

## 1. 背景浅谈

作为学期中的项目实训，我们打算做一个基于 web 的 LaTex 编辑工具。为了方便环境的配置以及服务的分离，选用Docker 进行环境的搭建。初始想法是基于一个 `Nginx + MongoDB + Tornado + xeLaTex ` 的基本架构，至少使用4个容器满足基本的需求，下面进行一下简单的记录。

## 2. Dockerfile 自定义容器

该项目分为四个部分，对于数据库，可以直接使用 [dockerhub](<https://hub.docker.com/>) 中的Mongodb。不需要额外的定制，直接pull 最新版即可：

```shell
docker pull mongo:latest
```

对于 Nginx, 也可以直接使用官方的版本，只是添加了一些需要额外挂载的目录：

```shell
# Define mountable directories.
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]
```

对于 Tornado 服务端，暂时先拟定一个最为简单的Demo，对于以后的版本再进行迭代：

```dockerfile
# Base ENV
FROM python:3.7-slim

# set workdir to /app
WORKDIR /app

# Copy the current directory contents at /app
COPY . /app

# Install needed package
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Make port 80 available to the world outside this contaner
EXPOSE 8888

# Define environment variable
ENV NAME World

# Run app.py when it lanches
CMD ["python", "app.py"]
```

当然需要在当前目录下，添加`requirements.txt app.py`分别用于安装所必须的库，以及待执行的脚本。这三个文件会被复制到新建的容器中。

LaTex容器使用一个较为精简的配置，以后再进行扩充：

```dockerfile
FROM ubuntu:xenial
MAINTAINER Inno Jia
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -q --fix-missing \
    && apt-get install -qy build-essential wget libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*

# Install TexLive with scheme-basic
RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz; \
	mkdir /install-tl-unx; \
	tar -xvf install-tl-unx.tar.gz -C /install-tl-unx --strip-components=1; \
    echo "selected_scheme scheme-basic" >> /install-tl-unx/texlive.profile; \
	/install-tl-unx/install-tl -profile /install-tl-unx/texlive.profile; \
    rm -r /install-tl-unx; \
	rm install-tl-unx.tar.gz

# install Chinese support
RUN apt-get install latex-cjk-all \
	apt-get install texlive-lang-chinese
    

ENV PATH="/usr/local/texlive/2017/bin/x86_64-linux:${PATH}"

ENV HOME /data
WORKDIR /data

# Install latex packages
RUN tlmgr install latexmk

VOLUME ["/data"]
```

## 2. 多容器的通信

为了进行多容器间的通信，可以在创建容器时，添加`--link`参数，指定需要通信的对象：

```shell
 # 通过link指令建立连接
 $ docker run --name <Name> -d -p <path1>:<path2> --link <containerName>:<alias> <containerName:tag/imageID>
```

```dockerfile
--link 后跟需要进行通信的容器
：     用于为容器设置别名，可以在主动建立连接的容器使用该别名
```

为了检查是否已经成功简历连接，可以在一个容器中使用`env`查看环境变量，或者使用`curl <alias>`。

### 2.1 数据库`auth`

首先需要简历数据库容器，并且进行`auth`认证。`MongoDB`默认端口开放在 27017，可以将其映射到本地的端口，本地端口在前，使用`：`连接。除此之外，还可以使用`-v`操作，于本地建立文件共享。

```shell
docker run --name latex-mongo -d -p 27017:27017 mongo:latest --auth
```

> --auth 指令开启了mongo的连接身份校验 开启校验 

然后进入容器，创建数据库的管理员：

```shell
$ docker exec -it mock-mongo /bin/bash
$ mongo admin     # enter the admin db
$ db.createUser({user: "admin-name", pwd: "admin-pwd", roles: [{role: "userAdminAnyDataBase", db: "admin"}])   
$ db.auth("admin-name", "admin-pwd")
```

然后退出容器，建立需要使用的数据库，并且设置独立的用户：

```shell
docker exec latex-mongo mongo db_name
```

```shell
$ db.createUser({user: "name", pwd: "pwd", roles: [{role: "readWrite", db: "db1"}, {...}])
```

为一个用户赋予对于不同数据库的权限，另其单独管理。

### 2.2 构建Tornado容器并建立连接

我们可以实现约定好Mongo容器的别名，端口，以及账号,需要连接的数据库：

+ alias: db
+ port: 27017
+ account: admin-pwd : admin-name
+ DB： db_name

所以可以使用一下的url对于数据库进行连接：

```shell
url: 'mongodb://admin-pwd:admin-name@db:27017/db_name'
```

我们的Tornado服务默认在8888端口，所以再运行时需要映射到本地：

```shell
docker run -d -p 8888:8888 --name latex-server1 --link latex-mongo:db tornado:latest 
```

### 2.3 构建Nginx容器，与Tornado，Mongo连接

```shell
docker run -d -p 95:80 --name latex-nginx --link latex-server1:tornado --link latex-mongo:db nginx:latest
```

使用`env`:

```shell
DB_PORT=tcp://172.17.0.2:27017
TORNADO_ENV_GPG_KEY=0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
HOSTNAME=e98f5db2f429
NJS_VERSION=1.15.9.0.2.8-1~stretch
TORNADO_ENV_PYTHON_VERSION=3.7.2
TORNADO_PORT=tcp://172.17.0.3:8888
NGINX_VERSION=1.15.9-1~stretch
TORNADO_ENV_NAME=World
TORNADO_ENV_LANG=C.UTF-8
TORNADO_ENV_PYTHON_PIP_VERSION=19.0.3
DB_PORT_27017_TCP_PORT=27017
DB_PORT_27017_TCP_ADDR=172.17.0.2
PWD=/
HOME=/root
DB_PORT_27017_TCP=tcp://172.17.0.2:27017
DB_ENV_MONGO_VERSION=4.0.7
DB_ENV_MONGO_PACKAGE=mongodb-org
TORNADO_PORT_8888_TCP=tcp://172.17.0.3:8888
DB_ENV_GPG_KEYS=9DA31620334BD75D9DCB49F368818C72E52529D4
TERM=xterm
TORNADO_PORT_8888_TCP_PORT=8888
DB_ENV_MONGO_REPO=repo.mongodb.org
DB_ENV_MONGO_MAJOR=4.0
TORNADO_PORT_8888_TCP_ADDR=172.17.0.3
DB_ENV_JSYAML_VERSION=3.10.0
SHLVL=1
DB_NAME=/latex-nginx1/db
DB_PORT_27017_TCP_PROTO=tcp
TORNADO_NAME=/latex-nginx1/tornado
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
DB_ENV_GOSU_VERSION=1.10
TORNADO_PORT_8888_TCP_PROTO=tcp
_=/usr/bin/env
```

可以看到`DB_PORT`, `TORNADO_PORT`已成功映射到别名，建立连接成功。