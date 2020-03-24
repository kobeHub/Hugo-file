+++
draft = false
date = 2019-01-14T12:01:51+08:00
title = "[Review] Support Vector Machine"
slug = "[Review] Support Vector Machine"
tags = ["Review"]
categories = ["Machine Learning"]
+++
# SVM



## 1. Margin and Support Vector

首先考虑一个线性分类任务,分类的最基本的想法就是在一个样本空间中划分一个超平面,将两个不同的类别的样本区分开。如何寻找超平面以及衡量超平面的好坏成为重要的问题。

为了正确的进行分类，我们需要找到一个鲁棒性更强的超平面，对于新的数据具有更强的泛化能力。在样本中，距离超平面的最近的样本点的距离应该尽可能的大，依据此规则选取超平面。

**间隔:**margin, 两类样本到划分超平面的最近的距离之和。代表着划分超平面对于样本局部扰动的”容忍性“，间隔越大，容忍性越好。

超平面可以用以下形式表示：
$$
W^Tx+b = 0
$$
根据超平面可以对样本进行划分：
$$
\begin{cases}
 w^T x_i + b \ge 1, \qquad   & y_i = +1
\\\\ w^Tx_i + b \le 1, \qquad & y_i = -1
\end{cases}
$$
**支持向量：** 距离超平面最小的训练样本使得等号成立，被称为支持向量

**Margin: $\gamma = \frac{2}{||w||}$,**

**Target**:最大化margin

为了找到具有最大间隔的超平面，使用以下**目标函数**：
$$
\begin{align}
& min_{w,b} \frac{1}{2} ||w||^2   \qquad (1)
 \\\\ & s.t. y_i(w^Tx_i+b) \ge 1, \qquad i=1,2,...,m
 \end{align}
$$
这是支持向量机的基本模型。

## 2. 对偶问题（Dual Problem）

我们希望求解的超平面划分模型是：
$$
f(x) = w^Tx + b
$$
这是一个凸二次规划问题**（Convex Quadratic Problem）**,可以通过现有的优化包进行计算，也可以使用其对偶问题进行更高效的计算。对于目标函数(1)每一条约束添加拉格朗日乘子$\alpha_i \ge 0$,问题的拉格朗日展开可写作：

$$
L(w, b, \alpha ) = \frac {1}{2} ||w||^2 + \sum _{i = 1}^m \alpha _i(1-y _i(w^Tx _i  +b))  \qquad (a)
$$

分别对于$w, b$求偏导可以得到：

$$
\begin{align}
& \frac { \partial L}{ \partial w} = w - \sum _{i=1}^m \alpha _i y_i x_i  \\
\\\\ & \frac{ \partial L}{ \partial b} = - \sum _{i=1}^m \alpha _i y_i  \\
\\\\ & 分别令其等于0：
\\\\ & w = \sum _{i=1}^m \alpha _i y_i x_i  \\
\\\\ & 0 = \sum _{i=1}^m \alpha _i y_i
 \end{align}
$$

将其带入式（a）中，可以得到(1)的**对偶问题**：

$$
\begin{align}
& max_{ \alpha } \sum _{i=1}^m \alpha _i - \frac{1}{2} \sum _{i = 1}^m \sum _{j=1}^m \alpha _i \alpha _j y_i y_j x_i^T x_j  \qquad (D)
\\\\ & s.t. \sum _{i=1}^m \alpha _i y_i = 0
\\\\ & \alpha _i \ge 0 ,i=  1, 2,,.., m
\end{align}
$$

求解出$\alpha$后，代入求解$w, b$即可得到模型。但是需要满足KKT（**Karush-Kuhn-Tucker**）条件：
$$
\begin{cases}
\alpha_i \ge 0
\\\\ y_i f(x_i) - 1 \ge 0
\\\\ \alpha _i (y_i f(x_i) - 1)  = 0
\end{cases}
$$

从三个条件可以得到，当$\alpha _i > 0$时，$y_i f(x_i) =1$,这些样本点属于支持向量，即位于margin上的向量；当其等于0时，是位于分界面以外可以明确区分的向量。

### 优化手段

对于对偶问题，这是一个二次规划问题，可以使用常规的二次规划手段来求解。但是可以使用更高效的算法，比如**SMO(Sequential Minimal Optimization)**，基本思路是先固定$\alpha_i$之外的所有参数，然后求$a_i$上的极值。由于存在约束条件$\sum _{i=1}^m \alpha _i y_i = 0$，所以每次选择每次选择两个变量$\alpha _i, \alpha _j$进行更新。重复以下步骤，直到收敛：

+ 选择一对需要更新的变量$\alpha _i, \alpha _j$;
+ 固定其他变量，求解(D)获得更新后的$\alpha _i, \alpha _j$

## 3. Kernel Function

对于原始空间线性不可分的问题，如果**原始空间是有限维，那么一定存在一个高维空间使得样本线性可分！** 现在考虑最一般的情形，使用一个函数$\phi(x)$将特征向一个高维空间映射。但是利用其对偶问题进行计算时，涉及到高维空间的内积，使得计算复杂度大大提升。为了避免这个问题，可以使用核函数。使用核函数在原始特征空间进行计算，得到的结果与在高维特征空间的结果一致。这与kernel-PCA中的思想相同：

$$
kernel(x_i, x_j) = < \phi (x_i), \phi (x_j)>  = \phi (x_i)^T \phi (x_j)
$$

那么其对偶问题就可以重写为:

$$
\begin{align}
& max_{\alpha} \sum _{i=1}^m \alpha _i - \frac{1}{2} \sum _{i = 1}^m \sum _{j=1}^m \alpha _i \alpha _j y_i y_j k(x_i, x_j)  \qquad (D)
\\\\ & s.t. \sum _{i=1}^m \alpha _i y_i = 0
\\\\ & \alpha _i \ge 0 ,i=  1, 2,,.., m
\end{align}
$$

求解后可以得到：

$$
 \begin{align}
 f(x)& =  w^T \phi(x) + b
 \\\\ & = \sum _{i=1}^m \alpha _i y_i  \phi (x_i)^T \phi (x_j) + b
 \\\\ & = \sum _{i=1}^m \alpha _i y_i k(x_i,x_j) + b
 \end{align}
$$

### 核函数定理

对于输入空间D，对于函数$k(.,.)$ 是定义在D×D的对称函数，当k对于任一的数据，核矩阵K总是半正定的，那么该函数就是一个核函数。对于一个半正定的核矩阵，总额能找到一个与之对应的$\phi$,也就是说，任意一个核函数都隐式的定义了一个**再生核希尔伯特空间（Reproducing Kernel Hilbert Space， RKHS）**。

+ 线性核
+ 多项式核
+ 高斯核
+ 拉普拉斯核
+ Sigmoid 核

*文本数据通常采用线性核，不明数据先采用高斯核；任意核函数的线性组合，直积，都是核函数*

## 4. Soft Margin

现实任务中很难判断样本在特征空间是否线性可分，即使找到了某个核函数使得其线性可分，也无法判断该结果是否由于过拟合造成。所以可以允许一些样本在SVM上错分，在margin附近的样本允许有有部分**不严格满足**约束条件。这样的间隔称之为**软间隔（soft margin）**.

同时需要保证，在最大化间隔的同时，要求不满足约束的样本尽可能少，通常的做法是在优化目标上添加一个**损失函数**：

$$
min_{w, b} \frac {1}{2} ||w||^2 + C \sum _{i = 1}^m l _{0/1} (y_i (w^T x_i+b)-1)
$$

其中C是一个常数，$l_{0/1}$是一个0-1损失函数，当自变量小于0时，结果为1，否则为0.*前一项是margin最大化，后一项表示的不满足约束的样本量尽可能少*

### 损失函数

但是由于0-1损失函数，是一个不连续非凸函数，通常用其他函数进行替代。

+ hinge损失 $max(0, 1-z)$
+ 指数损失 $exp(-z)$
+ 对率损失  $log(1+exp(-z))$

引入松弛变量$\xi_i = l _{hinge}(y_i(w^Tx_i+b)-1) = max(0, 1 - y_i(w^Tx_i+b))$ ,那么目标函数可以改写为：

$$
min_{w, b}\frac{1}{2}||w||^2 + C \sum _{i = 1}^m \xi _i \qquad (T1)
\\\\ s.t.y_i(w^Tx_i+b) \ge 1- \xi _i,\ \qquad  \xi_i \ge 0,\qquad i=1,2,...,m
$$

这就是常用的**软间隔支持向量机**

通过拉格朗日乘子法得到(T1)的拉格朗日函数：

$$
L(w, b, \alpha , \xi , \mu ) =  \frac {1}{2} ||w||^2 + \sum _{i = 1}^m \alpha _i(1- \xi _i - y_i (w^T x_i+b)) - \sum _{i=1}^m \mu _i \xi _i \qquad (a1)
$$

**求偏导：**

$$
w = \sum_{i=1}^m \alpha_iy_ix_i
\\\\ 0 = \sum _{i=1}^m \alpha _i y_i
\\\\ C = \alpha _i + \mu _i
$$

**软间隔SVM的对偶问题：**

$$
\begin{align}
& max_{\alpha} \sum _{i=1}^m \alpha _i - \frac{1}{2} \sum _{i = 1}^m \sum _{j=1}^m \alpha _i \alpha _j y_i y_j x_i^T x_j  \qquad (D1)
\\\\ & s.t. \sum _{i=1}^m \alpha _i y_i = 0
\\\\ & 0\le \alpha _i \le C ,i=  1, 2,,.., m
\end{align}
$$

**KKT条件：**

$$
\begin{cases}
\alpha_i \ge 0, \mu _i \ge 0
\\\\ y_i f(x_i) - 1+ \xi _i \ge 0
\\\\ \alpha _i (y_i f(x_i) - 1 + \xi _i)  = 0
\\\\ \xi _i \ge 0, \mu _i \xi _i =0
\end{cases}
$$

>+ $\alpha _i = 0$ 时，说明样本位于margin以外，这些样本点不对模型产生影响
>+ $\alpha _i > 0$ 时，那么就有 $y _I f(x_i) = 1 - \xi _i$ ，这些样本点都是支持向量
>  + $\alpha _i < C$, 那么 $\mu _i > 0$, 就有 $\xi _i = 0$,此时样本点位于margin上
>  + $ \alpha _i = C$, 那么 $\mu _i = 0$
>    + $0 \ge \xi _i \le 1$,样本点位于margin内部被正确分类
>    + $\xi _i > 1$,样本位于margin之外，分类错误

![soft margin](https://mediainter.innohub.top/190114-soft.png)



根据对偶问题可以看出，软间隔支持向量机与硬间隔的唯一不同就是规定了拉格朗日乘子的上界，也就是对于支持向量做了一定的”放宽“。因为没有上界时，该乘子可以取无穷大，对于支持向量必须严格满足约束，现在有了上界，表示允许一部分不满足约束。

## 5. 支持向量回归

**Support Vector Regression**，与传统的回归模型不同，允许预测值与真实值之间存在$\epsilon$ 的偏差，**也就是说当预测值与真实值的差的绝对值大于 $\epsilon$  时才计算损失**

也就是说，在以$f(x)$为中心，构建了一条宽度为$2\epsilon$ 的margin，当样本落入其中时，则认为预测正确。

![regression](https://mediainter.innohub.top/190114-reg.png)
