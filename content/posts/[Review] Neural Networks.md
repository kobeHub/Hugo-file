+++
draft = false
date = 2019-01-14T20:23:39+08:00
title = "[Review] Neural Networks"
slug = "[Review] Neural Networks"
tags = ["Review"]
categories = ["Machine Learning"]
+++
# 神经网络与深度学习



## 1. Artificial Neural Networks

### 1.1 M-P Neuron Model

由生物神经元的启发，McCulloch and Pitts在1943年提出了MP神经元模型。神经元模型是一个包含输入，输出与计算功能的模型。

输入可以类比为神经元的树突，而输出可以类比为神经元的轴突，计算则可以类比为细胞核。神经元接收来自n个其他神经元传递过来的输入信号，这些输入信号通过带权重的连接进行传递，神经元接收到的总输入值将与神经元的阈值进行比较，然后通过激活函数的处理产生神经元的输出。这是仅有一个神经元的模型。

**激活函数：**

阶跃函数，输出值大于0则为1，否则为0
$$
sgn(x)= \begin{cases}
1, & x \geq 0;
\\\\
0, & x < 0;
\end{cases}
\\\\y= \begin{cases}
1, & \sum_{i=1}^{n}w_ix_i-b \geq 0;
\\\\0, & otherwise;
\end{cases}
$$

### 1.2 Perceptron

第一个可以根据输入样本学习权重的模型，是首个可以学习的人工神经网络。The Perceptron was introduced in 1958 by Frank Rosenblatt.

该模型有两个层次。分别是输入层和输出层。输入层里的“输入单元”只负责传输数据，不做计算。输出层里的“输出单元”则需要对前面一层的输入进行计算我们把需要计算的层次称之为“计算层”，并把拥有一个计算层的网络称之为“单层神经网络”。单层感知机只可以处理线性可分的数据。

**多层感知机（MLP）**

多层感知机具有一个或者多个隐含层，不同的层之间神经元是全连接的。这是一个典型的前馈网络（Feedforward ）,在该网络中，信息只朝着一个方向移动。

深度学习之父**杰弗里·辛顿（Geoffrey Hinton）**，其在1986年发明了适用于多层感知器（MLP）的BP算法（反向传播算法），并采用Sigmoid激活函数进行非线性映射，有效解决了非线性分类和学习的问题。

**Activate Function:**

`Sigmoid` 函数，与用于分类问题的线性回归中使用的联系函数相同。

### 1.3 LeNet

1989 年。 Yann LeCun（乐困）利用反向传播的思想发明了卷积神经网络-LeNet，并将其用于数字识别，且取得了较好的成绩。BP算法被指出存在梯度消失问题，即在误差梯度反向传递的过程中，误差梯度传到前层时几乎为0，因此无法对前层进行有效的学习。

1997：LSTM模型（长短期记忆模型，long-short term memory）被发明。

### 1.4 Deep learning

Hinton提出了深度信念网络的神经网络,可以训练更深的网络，由此提出了深度学习的概念

举例：略

## 2. 学习/训练过程

关于神经网络，需要预先确定一些超参数。比如隐含层的数量，每一层神经元的数量，激活函数，损失函数，学习率，批大小（Batch）,训练时段(Epoch).

+ 首先随机初始化参数$(w_1, w_2, ..,w_n), (b_1, b_2, ...,b_n)$.
+ 根据训练集的输出与真是标记之间的差异获取损失函数
+ 利用有关最优化方法，以及反向传播使得损失降为小来调整网络参数

训练过程的一个时段代表了一次将整个训练集传递给网络进行的学习过程。通常包含多洗迭代。通常将数据集分为多个batch,每个epoch遍历整个数据集，每次迭代遍历一个batch。当batch大小为1时表示 每次迭代使用一个样本对参数进行更新，又称为**随机梯度下降SGD（Stochastic Gradient Descent）**

使用**Batch Gradient Descent，BGD**时，使用的损失函数是batch全部样本的平均损失。此时一个epoch更新一次网络权重。

## 3. Gradient Descent

具体的说对于连续可微函数$f(x, y)$,梯度就是该函数增长最快的地方，或者说沿着梯度的方向最容易找到最大值。反过来说，沿着梯度的反方向就是函数下降最快的方向，即对于$-(\frac{\partial f}{\partial x}, \frac{\partial f}{\partial y})^T$ 的方向，更容易找到最小值。

**基本损失函数：**
$$
E=\frac{1}{2}\sum_{j=1}^l(\hat y_j - y_j)^2
$$
**参数更新：**
$$
\vec{w} \leftarrow \vec{w}-\eta \nabla E
\\\\ \vec{b} \leftarrow \vec{w}-\eta \nabla E
$$

## 4. Back propagation

神经网络中使用最为广泛的学习算法。使用链式法则，对于网络中的所有参数都可以从后向前依次求解梯度，然后进行更新。现在以一个单隐层的全连接网络为例,使用sigmoid激活函数，损失函数使用均方差，学习率为$\eta$：

+ input: $x_1, x_2, x_3$
+ weights: $w^{(i)}$表示第i层的权重，其中$w_{ij}^{(1)}$ 表示第一层权重中，连接第i个输入神经元以及第2层的第j个神经元的权重
+ 隐含层的输入：$\alpha_i$
+ 隐含层输出： $h_i$
+ 输出层的输入：$\beta _i$
+ output: $\hat{y}_i$

![bp](https://mediainter.innohub.top/190114-bp.png)

$$
E = \frac{1}{2} \sum _{j=1} ^3 (\hat{y_j} - y_j)^2$$

$$\beta _2 = \sum _{j=1}^4 w _{j2}^{(2)} h_j$$

$$
h_3 = f ( \alpha _3 - b_3 ^{(1)}) $$

$$\alpha _3 = \sum _{k=1}^3  w _{k3}^{(1)} x_k$$

$$
w _{32}^{(2)} \leftarrow w _{32}^{(2)} - \eta \frac{\partial E }{\partial w _{32}^{(2)}}
$$



**使用链式法则：**

以$w_{23}^{(1)}$的更新为例：

$$
\frac{ \partial E}{ \partial w _{23}^{(1)}} = \frac{ \partial E}{ \partial h_3}. \frac{ \partial h_3}{ \partial \alpha _3}.\frac{ \partial \alpha _3}{ \partial w _{23}^{(1)}}
$$

求E对h3的梯度继续使用链式法则：

$$
\begin{align} \frac{\partial E}{\partial h_3}
& = \sum _{j=1}^3 \frac{\partial \beta _j}{\partial h_3} . \frac{ \partial E}{ \partial \beta _j}
 \\\\  & = \sum _{j=1}^3 w _{3j}^{(2)} g_j
\end{align}
$$

$h_3对于\alpha _3$的梯度，同样使用链式法则，同时由于sigmoid函数的导数具有以下性质:$f^\' = f(x)f(1-x) $:

$$
\begin{align}
\frac{ \partial h_3}{ \partial \alpha _3}
& = f'( \alpha _3 - b _3^{(1)})
\\\\ & = f( \alpha _3 - b _3^{(1)})(1 - f( \alpha _3 - b _3^{(1)}))
\\\\ & = h_3(1- h_3)
\end{align}
$$

所以可以得到最终的梯度：

$$
\frac{ \partial E}{ \partial w _{23}^{(1)}} = h _3(1- h_3) \sum _{j=1}^3 w _{3j}^{(2)} g_j x_2
$$

对于输出层有：

$$
{\color{Red} w _{ij}^{(2)} \leftarrow w _{ij}^{(2)} - \eta g_j h_i}
 \\\\ b _{j}^{(2) } \leftarrow =  b _{j}^{(2) } + \eta g_j
\\\\ {\color{Red} g_j = \frac{ \partial E}{ \partial \beta _j}= \hat y_j (1-\hat y_j)(\hat y_j - y_j)}
$$

均方差损失函数和sigmoid函数结合使用效果不好，因为存在梯度消失的问题.

## 5. Softmax

对于多分类问题，在输出层通常使用softmax,进行分类，当然可以使用任意的分类器，只要可以满足需求。

$$
S(y_i) = \frac{e^{y_i}}{\sum _{j = 1}^m e^{y_i}}
$$


## 6. CNN

### 6.1 Receptive Field

与全连接神经网络不同，卷积神经网络使用的是局部感受野，每一个隐含层结点只连接到图像的某个局部像素区域，从而大大减少了需要训练的参数数量。

### 6.2 Parameter Sharing

形象地说，就如同你的某个神经中枢中的神经细胞，它们的结构、功能是相同的，甚至是可以互相替代的特征和形式不管在哪个位置，其实他们都是一样的，不会因为位置的改变而改变，所以可以用共用一套参数

### 6.3 Padding

为了满足卷积操作的有关卷积核，步长，感受野大小的关系，需要添加0界来进行填充。关于卷积操作后的输出size：

```c++
Output = (N + 2P -F) / S + 1
N: input size
F： filter
P： padding
S： Strides
```



[详情](http://www.innohub.top/cnn-base/#more-160)
