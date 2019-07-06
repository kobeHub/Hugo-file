+++
draft = false

date = 2019-07-03T16:01:36+08:00
title = "C++ Standard Template Library (STL)(part 2)"
slug = "C++ Standard Template Library (STL)(part 2)" 
tags = ["Language"]
categories = ["Summary"]

+++

# STL 容器适配器

c++ STL提供了对于顺序容器的不同的访问接口：

+ **[queue](#-1.queue)**
+ **[priority_queue](#-2.priority_queue)**
+ **[stack](#-3.stack)**



# 1. queue

queue是一个典型的容器适配器对象，提供（FIFO）的用户接口，所有的元素都是在尾部插入，在头部删除。容器必须满足**顺序容器**的要求，必须提供以下接口:

`back`, `front`,`pop_front`, `push_back`.标准库中的`std::list`, `std::deque`满足该要求。注意容器适配器不支持遍历以及随机访问。

## 1.1 成员函数

+ **构造函数**

  可以使用`copy`, `move`语义的构造函数，以及初始列表的构造函数。

+ **元素访问**

  1. `front()`:访问第一个元素
  2. `end()`:访问最后一个元素

+ **容量**

  1. `empty()`:检查底层的容器是否为空
  2. `size()`：容器的大小

+ **修改**

  1. `push`
  2. `pop`
  3. `emplace`:与队列的末尾构造元素
  4. `swap`



# 2. priority_queue

一种容器适配器，默认提供对于最大元素的常数时间的查找，对数代价的插入以及删除，可以使用`Compare`更改顺序。不支持元素的随机访问，底层实现可以是最大堆。