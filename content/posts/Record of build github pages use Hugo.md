+++
draft = false
date = 2019-01-08T20:40:41+08:00
title = ""
slug = "" 
tags = []
categories = []
+++

# 前期准备

## 1. 本地下载安装Hugo

基于Ubuntu 16.04安装Hugo,Hugo使用Golang实现，可以直接通过源码编译安装。也可以使用已发行的版本，对于基于Debian的linux发行版，可以使用 `apt`,或者  `snap` 包管理进行最快速的安装

```shell

apt-get install hugo
snap install install hugo --channel=extended
# 安装Sass/SCSS版本
```

**源码安装：**

首先需要声明一个系统的GOPATH指明默认golang程序的安装路径，`export GOPATH=$HOME/go` ,然后clone 到本地进行编译安装

```
git clone https://github.com/gohugoio/hugo.git
cd hugo
go install
```

## 2. 建立的站点

在工作目录下，建立一个新的站点

```shell
hugo new site Hugo-site
cd Hugo-site
git init 
```

该名称可以任意更换，然后添加新的主题。初始化git仓库后添加主题。可以采用`hugo-coder` 主题做为新的站点主题。

```shell
git submodule add https://github.com/luizdepra/hugo-coder.git themes/hugo-coder
cp themes/hugo-coder/exampleSite/config.toml  config.toml 
```

然后将样例站点的配置文件cp到主文件夹下，同时将`themes/hugo-coder` 文件夹下的`static`, `layouts` 文件夹复制到主目录下，进行内容的更换。

## 3. 编辑新的文章

`hugo new posts/title.md` 

hugo使用markdown进行文章书写，可以使用该命令建立一篇新的文章，新的文件出现在`content/posts/` 文件夹下。注意需要将文件头的`draft` 改为`false`,才可以正式发布。

## 4.测试站点

```
hugo server -D
```

在浏览器访问[http://localhost:1313]就可以查看网站内容。

# 搭建到GitHub

## 1. 搭建脚本

首先写一个自动构建网站的脚本，每次有新的内容或者网站布局有所改变都可以使用该脚本推送到远程服务器。

```shell
#!/bin/sh 

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

msg="rebuilding site `date`"
if [ $# -eq 1  ]
    then msg="$1"
    fi
"]]"

# push Hugo all
git add -A
git commit -m "$msg"
git push hugo master

# Build the project
hugo 

#Add public folder
cd public
git add -A

git commit -m "$msg"

git push siteio master

cd ..
```

每次进行git提交时，可以在后面跟上提交的内容，如果没有的话，默认采用提交时间作为提交日志。

## 2.建立远程仓库

首先建立一个`yourgitname.github.io` 的仓库，然后转到设置，将该仓库设置为`github pages`,可以选择从`master`进行构建。

![hugo](http://media.innohub.top/190108-hugo.png)

然后在主目录执行`hugo` 命令，此时会产生一个名为`public`的文件夹，这就是hugo产生的静态网站，可以被直接访问，现在将远程仓库与`public` 文件夹绑定在一起

```shell
cd public 
git init 
git remote add site  git@github.com:kobeHub/kobehub.github.io
git push u site master
```

同时建立一个防治Hugo文件的远程仓库`Hugo-site`, 将原本在主目录下的git仓库与该远程库绑定，现在已经配置完成，可以访问`kobeHub.github.io` 进行查看了。

