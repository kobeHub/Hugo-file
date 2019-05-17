+++
draft = false
date = 2019-05-12T20:13:35+08:00
title = "[Review] Introduction to Coomputer Vision"
slug = "Introduction to Computer Vision" 
tags = ["Review"]
categories = ["CV"]

+++

# 计算机视觉绪论



## 1. 概述

### 1.1 视觉可以分为：

- 视感觉：从分子层次和观点理解人类对于光反应的基本性质
  - 光的物理特性
  - 刺激视觉感受器官的程度
  - 光作用于视网膜后经视觉系统加工产生的感觉
- 视知觉：最终目的从狭义上说是要能对于客观场景做出观察者有意义的解释和描述

### 1.2 计算机视觉的目标

- 建立CV系统来完成各种视觉任务
- 加深对于人脑是觉得掌握和理解

## 2. 图像基础

### 2.1 图像分类

- 模拟图像

  从连续的客观场景直接观察得到，用一个二维函数$f(x, y)$来表示

- 数字图像

  把连续的模拟图像在*坐标空间XY*以及*性质空间F*都离散化了的图像,基本单位**像素**

### 2.2 图像的表示

#### 函数表示

把图像看作一个由二维空间向一维空间的映射函数，有几个channel则有几个映射函数

#### 矩阵以及向量

#### RGB模型

三原色模型需要使用三个灰度值的映射表示：
$$
f_c(x, y) = (f_r(x, y), f_g(x, y), f_b(x, y))
$$

#### 存储

- 交叉存储[R G B] 为一个基本存储单元
- 顺序存储

#### 简单照明模型

Phong模型，基于RGB三基色颜色系统的Phong模型：

$$ I = k_a I_{pa} + \sum [ k_d I_{pd} cosi + K_s I_{ps} cos^n \theta ] $$


使用三个分量（$ I_{pa} , I_{pd} , I_{ps} $）表示RBG颜色空间,一旦**这三个分量以及其对应的系数（$k_a, k_d, k_s n,$）确定，** 从物体表面的某一点到达观察者的反射光的颜色就只和**光源入射角以及视角$\theta$有关** 。

这是一个纯几何模型。

#### HSL 模型

色调、饱和度、亮度

#### Lab 模型

L 亮度， ab 色度

#### YUV 模型

亮度信号Y，以及两个色度信号U(红)，V(蓝)

#### YCbCr模型（+）

### 2.3 取样和量化

取样: 坐标数字化，在2维空间进行网格取样

量化：振幅数字化，每一个像素点的值选取最接近的整数

信号的量化：量化为k个值，一般k为2的n次方

**空间取样决定了图像的分辨率，决定了可见的灰度等级送；量化决定了允许的强度级别，灰度等级，决定了图像的平滑程度。**

### 2.4 像素间联系

- 邻接：像素p在q的邻域中，则两个像素邻接
- 连接：p和q邻接而且灰度值满足一定的相似准则
- 连通：不直接邻接，但均在另一个像素的邻域中，且这些像素的灰度值满足某个特定的相似度准则
- 通路：如果从一个像素点p到另一个像素点q，前中的每一个点与前一个点都是k（k=4, 8, m）连接的，则从p到q有一条桐庐可以通过，如果是p，q同一个点则构成**闭合回路**。
- 连通集：一个集合中的所有像素点都连通，则构成了一个连通集；图像的一个连通集构成了一个区域

邻域：4， 8， m

m-邻域：像素p和q在彼此的8-邻域中，同时满足一定的相似度准则，同时他们的4-邻域中共同覆盖的像素点不满足该准则，则p和q位于彼此的m-邻域  **m-邻域可以消除8-连接的多路问题。**

### 2.5 像素间距离

满足以下三个条件的函数可以作为距离的度量:

- 同一性： $D(p, q) > 0 \;\;当p!=q; D(p,q)=0, p == q$
- 对称性
- 三角不等式

基本度量:

- 欧氏距离
- 城区距离
- 棋牌距离

分别对应l2, l1, l0 范数

距离变换:

也叫作距离函数或者斜切算法。描述的是图像中的像素点与某个区域的距离。距离变换给出每一个像素到区域边界的距离，**区域内部的点变换结果全为0**.如下，一个对于1区域的D4距离变换结果:

![ju](//media.innohub.top/190512-ju.jpg)

![](//media.innohub.top/190512-juli.jpg)
