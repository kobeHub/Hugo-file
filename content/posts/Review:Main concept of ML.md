+++
draft = false
date = 2019-01-12T17:43:29+08:00
title = "[Review] Main concept of ML"
slug = "[Review] Main concept of ML"
tags = ["Review"]
categories = ["Machine Learning"]
+++
# 机器学习的一些重要概念



## 1. 机器学习系统的主要操作

对于一个基于普通机器学习方法的分类系统，可能具有以下的基本操作步骤：

+ 数据收集**(Sensing)**

+ 数据预处理**(Preprocessing)**:

  通常使用分割操作，将分类目标与背景进行分离

+ 特征定义以及特征提取**(Feature definition and Extraction)**

  以上过程一般都需要使用到一定的先验知识**(Prior Knowledge)**

+ 选取模型**(Model Selection)**

+ 训练**(Training)**

+ 模型评估**(Evaluation)**

## 2.机器学习的主要任务

有标记数据的分类**(Classification)**以及回归**(Regression)**，无标记数据进行聚簇分析**(Clustering Analysis)**,异常检测**(Anomaly Detection)**.

### 1. 学习器

+ **K-Nearest Neighbor(K-NN)**

  在特征空间找到K个最近的邻居，选取数量最大的类别作为某个样本的预测类别。无需训练，适用于小数据量，非线性问题

+ **Decision Tree**

  通过每次选取最优特征进行进一步决策，构成了一组规则集组成的决策树，通过输入样本的特征进行分类任务。

  决策过程具有良好的可理解性，对于单一因素即可决定的预测结果的问题，可以弥补基于统计的机器学习的不足。

+ **Support Vector Machine**

  在特征空间选取一个超平面，使得所有样本点到超平面的总距离最小。通过定义一个间隔**(Margin)**,最大化Margin，选取一个合适的超平面用于分类任务。通过使用合适的变换核可以进行解决非线性问题。

  在解决小规模、非线性问题上具有优势，因为对于预测起到决定性作用的，是少数边界上的向量**(Support Vector)**

+ **朴素贝叶斯(Naive Bayesian)**

+ **Neural Networks**

+ **最小二乘 (Least Squares)**

+ **高斯混合模型（Gaussian Mixture Model）**

+ **Hidden Markov Model**

+ **Dynamic Bayesian Network**


## 3. 所使用的范式（Paradigms）

### 1. 集成学习  (Ensemble learning)

集成学习通过构建并结合多个学习器来完成学习任务。它的一般结构是先产生一组学习器，然后再用某种策略将这些个体学习器结合起来共同解决问题。

对于基学习器的选取：较高的准确率，更大的差异性   "好而不同"

#### 1.1 Bagging （Bootstrap AGGregatING）方法

使用并行的方法，同时训练多个学习器，对于每个学习器的训练数据采用**自助采样（Bootstrap）**的方法（有放回的随机采样，只使用63.2%的数据，剩下36.8%作为验证），使得获得的学习器通过样本扰动具有一定的多样性。

**Random Forest（随机森林）**

对于Bagging方法的一种扩展变体。使用决策树作为基学习器。对于每一个基学习器的每一个节点随机选取K个属性的集合作为特征集，从中选取最优特征用于划分。

随机森林中的基学习器的多样性不仅来自样本扰动，而且来自属性扰动，具有更高的差异度。泛化能力更强

### 2. 深度学习(DL)

### 3.半监督学习 (Semi-supervised learning)

### 4.代价敏感学习 (Cost-sensitive learning)

### 5.类别不平衡学习 (Class-imbalance learning)

### 6.多标记学习 (Multi-label learning)

### 7.多示例学习 (Multi-instance learning)

## 4. Data and Feature

+ 数据：样本、实例、对象
+ 特征： 属性集
+ 浅层模型：特征定义、特征提取、先验知识
+ 深度模型：特征学习

## 5. 误差（Error）与错误率（Error rate）

误差：样本的真实输出与预测输出之间的差异

```
训练误差（Training/Empirical Error）：在训练集上的误差
泛化误差（Generalization Error）：在新的样本上的误差
```

错误率：**错分**样本占总体样本的比例

**由于无法计算泛化误差，只能将最小化经验误差作为泛化误差的近似**

*****

*最终目标：得到泛化误差最小的学习器*

*****

## 6. 泛化能力

+ 已训练或者学习好的模型，在**全集**上的预测性能，而非在训练集上的性能
+ （有标记）全集无法获得，只能用测试集上模型的性能作为模型的泛化能力
+ 泛化能力是针对具体任务、训练或者学习好的模型而言

## 7. 独立同分布的假设

**Independent Identical Distribution**是机器学习，模式识别的重要假设。是所训练或者学习获得/建立的模型有效性的基本保障条件

+ 独立： 每次抽样间没有关系，互不影响
+ 同分布：训练集分布与全集分布一致

## 8.模型的拟合程度

### 1. 过拟合

一个模型过多的描述随机错误以及噪声，而不是刻画样本之间的潜在关系。过拟合对于训练集的拟合过好，而导致泛化性能下降。

违反了**奥卡姆剃刀（Occam's razor）原则：（若有多个假设与观察一致，选取最简单的一个）**

```
1. 优化目标加正则项
2. 提前停止
```

### 2.欠拟合

模型还不能够刻画样本的基本趋势，或者说模型对训练样本的一般性质还尚未学好。例如：使用线性模型来拟合非线性数据。

对于决策树来说，可以拓展分支的方式；  对于神经网络来说，可以相应增加训练轮数。

## 9. 评估方法（Evaluation Method）

### 数据集的划分

+ 留出法（Hold-out）：分为两个不相交子集分别作为训练集，测试集
+ 交叉验证（Cross validation）:分为K个子集，每次选取一个子集作为验证集，k-1个用于训练，进行k次（如：十折交叉验证）
+ 自助取样（Bootstrapping）：有放回的随机取样，每次取够m个数据

## 10. 性能度量

对于一般的有监督预测任务，例如分类以及回归任务，通过比较预测结果$f(x)$与真实标签之间的差异，进行度量。

+ 回归任务：均方误差作为度量（损失函数）

+ 分类任务：错误率（Error rate: **错分**样本占总体的比例）以及精度(Accuracy：**正分**样本占总体比例)

+ 查准率（Precision：准确率）与查全率（Recall：召回率）

  + 检索出的真正例所占的比例：
  ![](http://latex.codecogs.com/gif.latex?P=\\frac{TP}{TP+FP})

  + 检索出的真正例占全部正例的比例：
  ![](http://latex.codecogs.com/gif.latex?R=\\frac{TP}{TP+FN})

  + 分类正确的比例：
  ![](http://latex.codecogs.com/gif.latex?Acc=\\frac{TP+TN}{TP+FP+TN+FN})

+ ROC

  **Receiver Operating Characteristic**受试者工作曲线。若一个学习器的ROC曲线完全位于另一个学习器曲线下，则后者的性能较优。该曲线基于两个主要量进行绘制：真正例率（True Positive Rate），假正例率（False Positive Rate）

  ROC曲线下的面积AUC(Area Under ROC Curve)



  ![](http://latex.codecogs.com/gif.latex?TPR=\\frac{TP}{TP+FN}=R)

  ![](http://latex.codecogs.com/gif.latex?FPT=\\frac{FP}{FP+TN})

  ![ROC](https://mediainter.innohub.top/190112-roc.png)

## 11. 比较检验

## 12. 方差和偏差

+ 偏差（Bias）：度量了学习算法预测值的期望与真实值的偏离程度；即刻画了学习算法本身的拟合能力；

+ 方差（Variance）: 度量了同样大小训练集的变动所导致的学习性能的变化；即刻画了数据扰动所造成的影响

  ![bias and variance](https://mediainter.innohub.top/190112-bv.png)

### 二者关系

+ 在训练不足时，学习器拟合能力不强，训练数据的扰动产生的影响小，此时偏差主导泛化错误率；
+ 随着训练程度加深，学习器拟合能力逐渐增强，方差逐渐主导泛化错误率
+ 训练充足后，学习器的拟合能力非常强，训练数据的轻微扰动都会导致学习器的显著变化，容易发生过拟合。
