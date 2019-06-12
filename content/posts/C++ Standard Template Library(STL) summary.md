+++
draft = false
date = 2019-06-12
title = "C++ Standard Template Library (STL)"
slug = "C++ Standard Template Library (STL)" 
tags = ["Language"]
categories = ["Summary"]

+++

# STL 容器简介

C++ STL容器中常用的容器类型可以分为四类: 

+ 顺序性容器: 提供对于数据的序列化访问
  + [vector](#1-vector)
  + list
  + deque
  + arrays
  + forward_list(c++11 引入)
+ 容器适配器: 提供了对于序列化数据的另一种访问接口
  + queue
  + priority_queue
  + stack
+ 关联容器: 实现了对于有序数据结构的快速访问(O(logn)) （红黑树）
  + set
  + multiset
  + map
  + multimap
+ 无序关联容器: 提供对于无序数据的快速访问（hash）(c++11 引入)
  + unordered_set
  + unordered_multiset
  + unordered_map
  + unordered_multimap

# 1. vector

vector 可以看作一个动态数组，自身维护数组大小。vector在内存中是连续存储，所以可以使用迭代器(iterator)或者常规指针进行访问。vector中的数据在末尾插入，有时可能需要对于底层数组的长度进行扩展(扩展为现有大小的2倍)，所以**插入时间可能不一致**，删除末尾元素可以在O(1)时间内完成，不发生`resize`操作。对于非末尾元素的操作（插入，删除），可以在线性时间O(n)内完成（*由于进行连续存储，所以插入以及删除较慢*）.

vector 上的常见操作复杂度（效率）如下：

- 随机访问——常数 *O(1)*
- 在末尾插入或移除元素——均摊常数 *O(1)*
- 插入或移除元素——与到 vector 结尾的距离成线性 *O(n)*

**vector使用的空间大小可以通过`capacity()`进行查询; （c++ 11）额外的空间可以通过`shrink_to_fit()`函数返还给系统。**

## 1.1 成员函数

+ **构造函数**

  **`std::vector<T, Allocator>::vector`**

  1. `vector<T>()`: 默认构造函数，构造一个空容器。若不提供分配器，则从默认构造的实例获得分配器。:books:
  2. `vector<T>(size_type count, const T& value)`: 构造具有`count`个值为`value`的动态数组 :books:
  3. `vector<T>(size_type count)`: 构造具有`count`个值为T类型默认值的动态数组 :books:
  4. `vector<T>(InputIt first, InputIt last)`:构造拥有范围为`[first, last)`的内容的容器
  5. `vector<T>(const vector& other)`: 复制构造函数 :books:
  6. `vector<T>(vector&& other)`: 移动构造函数，实现右值向左值类型的转移
  7. `vector<T>(std::initializer_list<T> init)`:构造具有初始内容的容器 :books:

+ **元素访问**

  1. `at()`: 访问指定元素，进行越界检查
  2. `[]`: 指针式访问
  3. `front()`:首个元素
  4. `back()`: 最后一个元素
  5. `data()`:返回指向内存数组第一个元素的指针

+ **迭代器**(所有迭代器的end都是指向NULL, 迭代器支持指针的+, -操作)

  1. `begin()/cbegin()`:返回指向容器首个元素的迭代器
  2. `end()/cend()`:指向最后一个元素的迭代器
  3. `rbegin()/crbegin()`:返回指向容器最后元素的逆向迭代器 
  4. `rend()/crend()`: 返回指向前端的逆向迭代器 

+ **容量**

  1. `empty()`:为空时返回1；否则返回0

  2. `size`：元素数量

  3. `max_size`: 最多可容纳元素数量

  4. `reserve(size_type new_cap)`:增加vector的容量，直到大于或等于`new_cap`

  5. `capacity()`:容器容量

  6. `shrink_to_fit()`: 通过释放未使用的内存减少内存的使用 

+ 修改器

  1. `clear()`: 清除内容，不释放空间

  2. >`insert(iterator pos, const T& value)`: 在位置pos前插入value
     >
     >`insert(iterator pos, size_type count, const T& value)`: 在迭代器位置pos前插入`count`个`value`.
     >
     >`insert(iterator pos, InputIt first, InputIt last)`: 在位置pos插入一个序列

  3. `erase`: 删除指定位置或者范围的元素，位置以及范围由迭代器指定。

  4. `push_back`:元素插入末尾

  5. `pop_back`: 末尾删除

  6. `resize（size_type count, [const T& value]）`: 改变容器的元素数量；两种重载形式；如果count 小于size,则取前count个元素；否则以value或者默认值填充

  7. `swap`: 交换两个vector

## 1.2 兼容 C 数组

C++很重要的一个特性就是兼容C语言，C的接口中，如果需要传入一个数组，通常的方式s是传入一个起始地址加上一个长度，如下：

```c++
void* memset( void* dest, int ch, std::size_t count );
```

如果你现在有一个`std::vector`，现在需要把它传递给C，接口你可以调用`std::vector::data`这个成员变量获取底层的内存空间的首地址。`std::vector`和其他的容器一个非常重要的区别就是它保证了底层的内存空间的连续性，也就是说，它保证了内存空间和C数组的兼容性，能用C数组的地方都可以使用`std::vector`，而且它还能保证内存空间的自动管理。