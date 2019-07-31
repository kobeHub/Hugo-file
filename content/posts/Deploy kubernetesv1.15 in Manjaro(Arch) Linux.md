+++
draft = false
date = 2019-07-26T10:36:43+08:00
title = "使用 kubeadm 配置 Kubernetes 1.15集群 （基于Ubuntu 16.04）"
slug = "使用 kubeadm 配置 Kubernetes 1.15集群 （基于Ubuntu 16.04）" 
tags = ["k8s", "Docker"]
categories = ["Record"]

+++



Kubernetes 是用于自动部署、扩展和管理容器化应用的开源系统。它将组成应用程序的容器组合成逻辑单元，以便于管理以及服务，其抽象性允许将容器化应用部署到集群，而不必专门绑定到一个计算机。同时可以提供24/7的全天候使用能力，支持不停机的发布以及更新。**Kubernetes 用于协调高度可用的计算机集群，这些计算机群集被连接作为单个单元工作**。对于一个Kubernetes集群而言具有两种类型的资源：

+ **Master**: 集群的调度节点
+ **Nodes**：应用程序实际运行的工作节点

![cluster](https://d33wubrfki0l68.cloudfront.net/99d9808dcbf2880a996ed50d308a186b5900cec9/40b94/docs/tutorials/kubernetes-basics/public/images/module_01_cluster.svg)

kubeadm是Kubernetes官方提供的用于快速安装Kubernetes集群的工具, 可以通过该工具快速部署一个集群。本次部署使用虚拟机，基于Ubuntu 16.04进行。

# 1. 准备 

1. 首先确定三台虚拟机的IP，修改每一台的`/etc/hosts`文件:

```shell
192.168.118.128 node1
192.168.118.129 master
192.168.118.130 node2
```

*除此之外，每一台虚拟机(或者物理机)必须满足至少双CPU， 内存大于2G, 拥有root权限*

2. 然后修改每一个主机的`hostname`

```shell
hostnamectl set-hostname <name>
```

3. 配置内核参数，将桥接流量传递到iptables的链

   ```bash
   cat > /etc/sysctl.d/k8s.conf <<EOF
   net.bridge.bridge-nf-call-ip6tables = 1
   net.bridge.bridge-nf-call-iptables = 1
   net.ipv4.ip_forward = 1
   EOF
   ```

   ```shell
   modprobe br_netfilter
   sysctl -p /etc/sysctl.d/k8s.conf
   ```

4. 开启kube-proxy ipvs模式的前提条件，由于ipvs已经加入到了内核的主干，所以为kube-proxy开启ipvs的前提需要加载以下的内核模块：

   ```bash
   ip_vs
   ip_vs_rr
   ip_vs_wrr
   ip_vs_sh
   nf_conntrack_ipv4
   ```

   可以建立`k8s`的工作目录，将其作为一个shell脚本：

   ```bash
   cat > ipvsset.sh <<EOF
   #!/bin/bash
   modprobe -- ip_vs
   modprobe -- ip_vs_rr
   modprobe -- ip_vs_wrr
   modprobe -- ip_vs_sh
   modprobe -- nf_conntrack_ipv4
   EOF
   
   chmod +x ipvsset.sh && sudo ./ipvsset.sh
   lsmod | grep -e ip_vs -e nf_conntrack_ipv4
   ```

   然后需要在每一个节点上安装`ipset`,为了便于ipvs的代理查看，可以安装管理工具`ipvsadm`.

5. Kubectl 的运行要求在`swap`分区关闭的前提下，同时`coredns`的运行需要以`/etc/resolv.conf`为配置文件

   ```shell
   sudo swapoff -a -v
   sudo sed -i '/^127.0.0.1/a\nameserver 8.8.8.8' /etc/resolv.conf
   sudo sed -i '/8.8.8.8$/a\nameserver 8.8.4.4' /etc/resolv.conf
   ```



# 2. Docker 以及k8s安装

## 2.1 Docker

```shell
# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install apt-transport-https ca-certificates curl software-properties-common

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository.
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install Docker CE.
apt-get update && apt-get install docker-ce=18.06.2~ce~3-0~ubuntu

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker
```

## 2.2 Kubeadm, kubelet, kubectl

```shell
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
```

然后在每一个节点开启docker， kubelet服务

```shell
sudo systemctl ebable --now docker
```



# 3. 配置集群

## 3.1 初始化集群

进入k8s工作目录,可以打印kubeadm的默认配置文件`kubeadm config print init-defaults`，修改使用如下的启动文件：

```yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.118.129       # master ip
  bindPort: 6443
nodeRegistration:
  taints:
  - effect: PreferNoSchedule
    key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.15.1   # 版本需要与k8s版本一致
networking:
  podSubnet: 10.244.0.0/16   # 子网不可与节点的ip在同一字段
```

在启动之前可以在每个节点使用`kubeadm config imags pull`拉取必要的镜像（注意：如果无法科学上网，可以自行配置阿里云个人镜像。）

初始化集群：

```shell
kubeadm init --config kubeadm.yaml
```

log记录了完成的初始化输出的内容，根据输出的内容基本上可以看出手动初始化安装一个Kubernetes集群所需要的关键步骤。 其中有以下关键内容：

- [kubelet-start] 生成kubelet的配置文件”/var/lib/kubelet/config.yaml”

- [certs]生成相关的各种证书

- [kubeconfig]生成相关的kubeconfig文件

- [control-plane]使用/etc/kubernetes/manifests目录中的yaml文件创建apiserver、controller-manager、scheduler的静态pod

- [bootstraptoken]生成token记录下来，后边使用kubeadm join往集群中添加节点时会用到

- 下面的命令是配置常规用户如何使用kubectl访问集群：

- ```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  ```

- 最后给出了将节点加入集群的命令kubeadm join 192.168.118.129:6443 –token xxxxx.xxxxxxxxxxx \ –discovery-token-ca-cert-hash shaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

查看一下集群状态，确认个组件都处于healthy状态：

```shell
kubectl get cs
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok                  
scheduler            Healthy   ok                  
etcd-0               Healthy   {"health":"true"}
```



## 3.2 配置pod网络

使用flannel插件进行网络配置:

```shell
curl -O https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f  kube-flannel.yml
```

如果Node有多个网卡的话，参考[flannel issues 39701](https://github.com/kubernetes/kubernetes/issues/39701)，目前需要在kube-flannel.yml中使用–iface参数指定集群主机内网网卡的名称，否则可能会出现dns无法解析。需要将kube-flannel.yml下载到本地，flanneld启动参数加上–iface=<iface-name>

```shell
containers:
      - name: kube-flannel
        image: quay.io/coreos/flannel:v0.11.0-amd64
        command:
        - /opt/bin/flanneld
        args:
        - --ip-masq
        - --kube-subnet-mgr
        - --iface=eth1
......
```

使用kubectl get pod –all-namespaces -o wide确保所有的Pod都处于Running状态。

我在这里遇到了`coredns`的崩溃，原因是coredns配置文件中的`loop`参数导致,使用`kubectl -n kube-system edit configmap coredns `:

```yaml
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           upstream
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf
        loop			
        cache 30
        reload
        loadbalance
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2019-07-29T11:20:38Z"
  name: coredns
  namespace: kube-system
  resourceVersion: "13188"
  selfLink: /api/v1/namespaces/kube-system/configmaps/coredns

```

删除即可，然后重启服务:

```shell
 kubectl get pods -n kube-system -oname |grep coredns |xargs kubectl delete -n kube-system
```



## 3.3 添加节点

使用kubeadm输出的join提示，分别在两个工作节点上执行,使用`kubectl get nodes`:

```c++
NAME     STATUS   ROLES         AGE   VERSION                                                        master   Ready    master   39h   v1.15.1                                                       
node1    Ready    <none>        39h   v1.15.1                                                       node2    Ready    <none>        39h   v1.15.1 
```



## 3.4 节点的移除以及集群销毁

### 移除node2结点

```shell
kubectl drain node2 --delete-local-data --force --ignore-daemonsets
kubectl delete node node2
```

node2 执行:

```shell
kubeadm reset
ifconfig cni0 down
ip link delete cni0
ifconfig flannel.1 down
ip link delete flannel.1
rm -rf /var/lib/cni/
ipvsadm --clear
```

### 集群销毁

```shell
kubeadm reset
ifconfig cni0 down
ip link delete cni0
ifconfig flannel.1 down
ip link delete flannel.1
rm -rf /etc/cni/
```



## 3.5 kube-proxy设置ipvs

修改ConfigMap的kube-system/kube-proxy中的config.conf，mode: “ipvs”

```shell
kubectl edit cm kube-proxy -n kube-system
```

之后重启各个节点上的kube-proxy pod：

```shell
kubectl get pod -n kube-system | grep kube-proxy | awk '{system("kubectl delete pod "$1" -n kube-system")}'
kubectl get pod -n kube-system | grep kube-proxy
kube-proxy-7fsrg                1/1     Running   0          3s
kube-proxy-k8vhm                1/1     Running   0          9s

kubectl logs kube-proxy-7fsrg  -n kube-system
I0703 04:42:33.308289       1 server_others.go:170] Using ipvs Proxier.
W0703 04:42:33.309074       1 proxier.go:401] IPVS scheduler not specified, use rr by default
I0703 04:42:33.309831       1 server.go:534] Version: v1.15.0
I0703 04:42:33.320088       1 conntrack.go:52] Setting nf_conntrack_max to 131072
I0703 04:42:33.320365       1 config.go:96] Starting endpoints config controller
I0703 04:42:33.320393       1 controller_utils.go:1029] Waiting for caches to sync for endpoints config controller
I0703 04:42:33.320455       1 config.go:187] Starting service config controller
I0703 04:42:33.320470       1 controller_utils.go:1029] Waiting for caches to sync for service config controller
I0703 04:42:33.420899       1 controller_utils.go:1036] Caches are synced for endpoints config controller
I0703 04:42:33.420969       1 controller_utils.go:1036] Caches are synced for service config controller
```

日志中打印出了Using ipvs Proxier，说明ipvs模式已经开启。



# 4. Kubernetes 常用组件

## 4.1 Helm 

Helm由客户端命helm令行工具和服务端tiller组成，Helm的安装十分简单。 下载helm命令行工具到master节点node1的/usr/local/bin下，这里下载的2.14.1版本：

```shell
curl -O https://get.helm.sh/helm-v2.14.1-linux-amd64.tar.gz
tar -zxvf helm-v2.14.1-linux-amd64.tar.gz
cd linux-amd64/
cp helm /usr/local/bin/
```

因为Kubernetes APIServer开启了RBAC访问控制，所以需要创建tiller使用的service account: tiller并分配合适的角色给它。 详细内容可以查看helm文档中的[Role-based Access Control](https://docs.helm.sh/using_helm/#role-based-access-control)。 这里简单起见直接分配cluster-admin这个集群内置的ClusterRole给它。创建helm-rbac.yaml文件：

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
```

```shell
kubectl create -f helm-rbac.yaml
serviceaccount/tiller created
clusterrolebinding.rbac.authorization.k8s.io/tiller created
```

使用helm部署tiller:

```shell
helm init --service-account tiller --skip-refresh
kubectl get pod -n kube-system -l app=helm
```

对于无法科学上网时，可以配置azure的helm repo:

```shell
helm repo add stable http://mirror.azure.cn/kubernetes/charts
helm repo list
```

## 4.2 使用Helm部署Nginx Ingress

为了便于将集群中的服务暴露到集群外部，需要使用Ingress。接下来使用Helm将Nginx Ingress部署到Kubernetes上。 Nginx Ingress Controller被部署在Kubernetes的边缘节点上.

将master作为边缘节点，加上label:

```shell
kubectl label node master node-role.kubernetes.io/edge=
```

stable/nginx-ingress chart的值文件ingress-nginx.yaml如下:

```yaml
controller:
  replicaCount: 1
  hostNetwork: true
  nodeSelector:
    node-role.kubernetes.io/edge: ''
  affinity:
    podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - nginx-ingress
            - key: component
              operator: In
              values:
              - controller
          topologyKey: kubernetes.io/hostname
  tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: PreferNoSchedule
defaultBackend:
  nodeSelector:
    node-role.kubernetes.io/edge: ''
  tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: PreferNoSchedule
```

部署安装:

```shell
helm repo update

helm install stable/nginx-ingress \
-n nginx-ingress \
--namespace ingress-nginx  \
-f ingress-nginx.yaml
```

查看:

```shell
kubectl get pod -n ingress-nginx -o wide
```

如果访问http://192.168.118.129返回default backend，则部署完成。

## 4.3 使用Helm部署dashboard

对应配置文件:

```yaml
image:
  repository: k8s.gcr.io/kubernetes-dashboard-amd64
  tag: v1.10.1
ingress:
  enabled: true
  hosts: 
    - k8s.frognew.com
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
  tls:
    - secretName: frognew-com-tls-secret
      hosts:
      - k8s.frognew.com
nodeSelector:
    node-role.kubernetes.io/edge: ''
tolerations:
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: NoSchedule
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: PreferNoSchedule
rbac:
  clusterAdminRole: true
```

```shell
helm install stable/kubernetes-dashboard \
-n kubernetes-dashboard \
--namespace kube-system  \
-f kubernetes-dashboard.yaml
```

## 4.4 使用Helm部署metrics-server

```yaml
args:
- --logtostderr
- --kubelet-insecure-tls
- --kubelet-preferred-address-types=InternalIP
nodeSelector:
    node-role.kubernetes.io/edge: ''
tolerations:
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: NoSchedule
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: PreferNoSchedule
```

```shell
helm install stable/metrics-server \
-n metrics-server \
--namespace kube-system \
-f metrics-server.yaml
```

使用下面的命令可以获取到关于集群节点基本的指标信息：

```shell
kubectl top node
kubectl top pod -n kube-system
```

使用到镜像:

```shell
# network and dns
quay.io/coreos/flannel:v0.11.0-amd64
k8s.gcr.io/coredns:1.3.1


# helm and tiller
gcr.io/kubernetes-helm/tiller:v2.14.1

# nginx ingress
quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.1
k8s.gcr.io/defaultbackend:1.5

# dashboard and metric-sever
k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1
gcr.io/google_containers/metrics-server-amd64:v0.3.2
```

