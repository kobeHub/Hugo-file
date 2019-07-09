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

+ **[queue](#1-queue)**
+ **[priority_queue](#2-priority-queue)**
+ **[stack](#3-stack)**



# 1. queue

queue是一个典型的容器适配器对象，提供（FIFO）的用户接口，所有的元素都是在尾部插入，在头部删除。容器必须满足**顺序容器**的要求，必须提供以下接口:

`back`, `front`,`pop_front`, `push_back`.标准库中的`std::list`, `std::deque`满足该要求。注意容器适配器不支持遍历以及随机访问。

## 1.1 成员函数

+ **构造函数**

  可以使用`copy`, `move`语义的构造函数，以及初始列表的构造函数。底层使用的默认容器是`deque`

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

一种容器适配器，默认提供对于最大元素的常数时间的查找，对数代价的插入以及删除，可以使用`Compare`更改顺序。不支持元素的随机访问，底层实现可以是最大堆。可以使用用户提供的`Compare`更改顺序，例如，使用`std::greater<T>`将元素按照非增序排列.

```c++
template<
	class T,
	class Container = std::vector<T>,
	class Compare = std::less<typename Contianer::value_type>
> class priority_queue;
```



## 2.1 成员函数

+ **构造函数**

  ```c++
  priority_queue()
  explicit priority_queue(const Compare& compare) : priority_queue(compare, Container) {}
  explicit priority_queue(const Compare& compare, const Contianer& cont)
  ```

  支持默认构造函数；传入`Compare`的构造函数，传入`Compare, Contianer`的构造函数，复制，move语义的构造函数。

  使用默认的底层容器是`std::vector<T>`.

  ```c++
  template< class InputIt >
  priority_queue( InputIt first, InputIt last,
                  const Compare& compare, const Container& cont );
  ```

  该构造函数从`cont`复制构造c，从compare复制构造comp。然后调用`c.insert(c.end(), first, last)`,再调用`std::make_heap(c.begin(), c.end(), comp)`

+ **元素访问**

  `top（）`：返回堆顶元素

+ **容量**

  1. `empty()`

  2. `size()`

+ **修改器**

  1. `push`:插入元素并对底层容器排序
  2. `pop`:闪出栈顶元素，并排序
  3. `emplace`:构造一个对象并且push
  4. `swap`:交换两个队列的数据

+ **成员对象**

  1. Container c
  2. Compare comp



# 3. stack

容器适配器，提供了FILO的访问顺序，该类底层容器为双向队列(deque),该类模板表现为底层容器的包装器--只提供特定的函数集合，栈的所有操作均位于栈顶。

```c++
template<
    class T,
    class Container = std::deque<T>
> class stack;
```

## 3.1 成员函数

+ **构造函数**

  提供了默认构造函数、传入`Container`的构造函数，复制、move语义的构造函数

- **元素访问**

  `top（）`：返回堆顶元素

- **容量**

  1. `empty()`

  2. `size()`

- **修改器**

  1. `push`:插入元素并对底层容器排序
  2. `pop`:闪出栈顶元素，并排序
  3. `emplace`:构造一个对象并且push
  4. `swap`:交换两个队列的数据

- **成员对象**

  1. Container c


