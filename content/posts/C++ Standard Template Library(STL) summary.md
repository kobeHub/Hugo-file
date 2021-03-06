+++
draft = false
date = 2019-06-12
title = "C++ Standard Template Library (STL)(part 1)"
slug = "C++ Standard Template Library (STL)" 
tags = ["Language"]
categories = ["Summary"]

+++

# STL 容器简介

C++ STL容器中常用的容器类型可以分为四类: 

+ 顺序性容器: 提供对于数据的序列化访问
  + [vector](#1-vector)
  + [list](#2-list)
  + [deque](#3-deque)
  + [arrays](#4-arrays)
  + [forward_list(c++11 引入)](#5-forward_list)
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

+ **修改器**

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



# 2. list

list是一个提供非连续存储的序列化容器，底层依赖于链表进行实现，相对于vector，对于元素的随机访问较慢，但是具有较快的插入删除速度。默认的list是一个双向链表，对于单向链表，对应于forward_list.**与forward_list相比，提供双向迭代，但是空间效率较低。**

+ 随机访问--O（n）
+ 插入删除--O(1)

## 2.1 成员函数

+ **构造函数**

  1. `list()`: 默认构造器，返回一个空的List容器
  2. `list(size_type count, const T& value)`: 构造具有`count`值为`value`的list
  3. `list(size_type count)`: 构造具有`count`个T类型的默认值的list
  4. `list(InputIt first, InputIt last)`: 构造迭代器范围`[first, last)`的list
  5. `list(const list& other)`: 复制构造器
  6. `list(list&& other)`: move 语义构造器
  7. `list(initializer_list<T> init)`:赋予初始值的list

  **构造函数的时间复杂度为O(n), 与初始值列表的长度成线性关系**

+ **元素访问**

  1. `front()`: 返回到容器首元素的引用
  2. `back()`:返回容器最后一个元素的引用

+ **迭代器**

  1. `begin()/cbegin()`:返回指向容器第一个元素的迭代器；若容器为空则返回值等同于`end()`
  2. end()/cend()`:指向最后一个元素的迭代器
  3. `rbegin()/crbegin()`:返回指向容器最后元素的逆向迭代器 
  4. `rend()/crend()`: 返回指向前端的逆向迭代器 

+ **容量**

  1. `empty()`:为空时返回1；否则返回0
  2. `size`：元素数量
  3. `max_size`: 最多可容纳元素数量

+ **修改器**:

  1. `clear()`:清除内容，但是不释放空间

  2. `insert()`:一共4个重载版本：

     > `insert(iterator pos, const T& value)`:在pos前插入value
     >
     > `insert(iterator pos, size_type count, const T& value)`:在pos前插入count个value
     >
     > `insert(iterator pos, InputIt first, InputIt last)`:在pos前插入范围在`[first, last)`内的元素
     >
     > `insert(iterator pos, initializer_list<T> ilist)`:在pos前插入多个值

  3. `erase(iterator pos, [iterator last])`：删除指定位置的元素，可以多个或者单个。**注意：由于list不是连续存储，所以不可以对于迭代器使用类似指针的+n, -n, 可以使用`std::advance(InputIt& it, Distance n)`进行指针的移动，距离可正可负。但是list的迭代器可以使用++, --.**

  4. `push_back(const T& value)`: 在list末尾插入元素

  5. `pop_back`: 末尾删除

  6. `pop_front()`:移除头部元素

  7. `resize（size_type count, [const T& value]）`: 改变容器的元素数量；两种重载形式；如果count 小于size,则取前count个元素；否则以value或者默认值填充

  8. `swap`:交换两个list

+ **操作**

  1. `merge`:合并两个已排序的list。`merge(list& other, Compare comp)`

  2. `sort`:对于元素进行稳定排序,O(NlogN), `sort(Compare comp)`,**注意:std::sort不可以用于list，因为其要求元素可以随机访问**

  3. `unique()`:从容器中移除所有相邻的重复元素，只留下第一个，返回移除的元素数。

  4. `reverse()`:将列表倒序，时间复杂度O(n)

  5. `splice`:从一个list中转移元素到另一个，不复制或者移动元素，只是简单的指针改变。

     >`splice(const_iterator pos, list& other)`: 在pos前将other移入list
     >
     >`splice(const_iterator pos, list& other, const_iterator it)`:从 `other` 转移 `it` 所指向的元素到 *this 。元素被插入到 `pos` 所指向的元素之前。
     >
     >`splice(const_iterator pos, list& other, const_iterator first, const_iterator last)`:
     >
     >从 `other` 转移范围 `[first, last)` 中的元素到 *this 。元素被插入到 `pos` 所指向的元素之前。若 `pos` 是范围 `[first,last)` 中的迭代器则行为未定义。

  6. `remove/ remove_if()`:移除某一个值，或者移除所有满足条件的值

  7. `emplace(const_iterator pos, Args&&... args)`:直接于pos前构造一个元素，使用传入的参数。使用new关键字；对应于双向链表，还有`emplace_front`, `emplace_back`.

# 3. deque

Deque是一个双向队列，可以同时在队列头部以及尾部进行高效的读写，基本API与vector相似，但是添加了在头部的高速的`pop_front`,`push_front`.但是数据不一定存储在连续的空间，所以随机读入速度较慢。另外，在 deque 任一端插入或删除不会非法化指向其余元素的指针或引用。deque 的存储按需自动扩展及收缩。扩张 deque 比扩展 [std::vector](https://zh.cppreference.com/w/cpp/container/vector) 更加方便，因为它不涉及到复制既存元素到新内存位置。另一方面， deque 典型地拥有较大的最小内存开销；只保有一个元素的 deque 必须分配其整个内部数组（例如 64 位 libstdc++ 上为对象大小 8 倍； 64 位 libc++ 上为对象大小 16 倍或 4096 字节的较大者）。

+ 随机访问--O（1）
+ 在头尾插入删除--O(1)
+ 插入或者移除--O(n)

## 3.1 成员函数

+ **构造函数**
  
  1. `deque(const Allocator& alloc)`: 默认构造函数
  2. `deque(size_type count, const T& value)`:构造拥有`count`个值为`value`的deque
  3. `deque（size_type count）`: 构造拥有`count`个默认值的deque
  4. `deque（InputIt first, InputIt last）`:使用范围`[first, last)`内的元素初始化deque
  5. `deque(const deque& other)`:复制构造函数
  6. `deque(const deque&& other)`: move语义
  7. `deque(std::initializer_list<T> init,)`:初始值的deque
+ **元素访问**
  
  1. `at()`: 访问指定元素，进行越界检查
  2. `[]`: 指针式访问
  3. `front()`:首个元素
4. `back()`: 最后一个元素

+ **迭代器**(所有迭代器的end都是指向NULL, 迭代器支持指针的+, -操作)

  1. `begin()/cbegin()`:返回指向容器首个元素的迭代器
  2. `end()/cend()`:指向最后一个元素的迭代器
  3. `rbegin()/crbegin()`:返回指向容器最后元素的逆向迭代器 
  4. `rend()/crend()`: 返回指向前端的逆向迭代器 

+ **容量**

  1. `empty()`:为空时返回1；否则返回0

  2. `size`：元素数量

  3. `max_size`: 最多可容纳元素数量

  6. `shrink_to_fit()`: 通过释放未使用的内存减少内存的使用 

+ **修改器**

  1. `clear()`: 清除内容，不释放空间

  2. >`insert(iterator pos, const T& value)`: 在位置pos前插入value
     >
     >`insert(iterator pos, size_type count, const T& value)`: 在迭代器位置pos前插入`count`个`value`.
     >
     >`insert(iterator pos, InputIt first, InputIt last)`: 在位置pos插入一个序列

     **注意：所有的insert的迭代器都被非法化，所以原有的迭代器对象指向原有元素，返回值指向新的第n个元素**
  
  3. `erase`: 删除指定位置或者范围的元素，位置以及范围由迭代器指定。**所有的迭代器都被非法化，所以原有的`it`指向第n个元素，删除后的`it`指向新的deque的第n个元素。**

  4. `push_back`:元素插入末尾，支持引用形式的参数传入，以及`move`语义的插入

  5. `pop_back`: 末尾删除

  6. `pop_front()`:头部删除元素
  
  7. `resize（size_type count, [const T& value]）`: 改变容器的元素数量；两种重载形式；如果count 小于size,则取前count个元素；否则以value或者默认值填充
  
  8. `swap`: 交换两个vector
  
  9. `emplace（const_iterator pos, Args&&... args）`:直接位于位置`pos`前根据所提供的参数构造一个元素，返回一个指向该元素的迭代器，所有的迭代器包括尾部迭代器都被非法化，引用也被非法化。还有`emplace_front`,`emplace_back`在头部以及尾部构造元素

## 3.2 非成员函数

+ **二元操作符**

  1. `==`, `!=`:

     检查 `lhs` 与 `rhs` 的内容是否相等，即它们是否拥有相同数量的元素且 `lhs` 中每个元素与 `rhs` 的同位置元素比较相等。

  2. `>, <, <=, >=`:

     按字典序比较两个deque中的数据,只要第一个元素满足于该操作符即可返回`true`

+ **erase, erase_if**: c++ 20 特性

  ```c++
  template<class T, class Alloc, class U>
  void erase(std::deque<T, Alloc>& c, const U& value)
      
  template< class T, class Alloc, class Pred >
  void erase_if(std::deque<T,Alloc>& c, Pred pred);
  ```

  在此之前可以使用`std::remove (<algorithm>)`结合`erase`成员函数实现

  ```c++
  c.erase(std::remove(c.begin(), c.end(), value), c.end());
  c.erase(std::remove_if(c.begin(), c.end(), pred), c.end());
  ```

  

# 4. arrays

  c++11中引入的`arrays`提供了c形式的数组的另一种选择，与c形式的数组相比，arrays有以下优点:

  + arrays具有size属性，c数组没有该属性，所以将一个数组作为参数传递时，不需要添加一个size的额外参数
  + 使用c风格的数组有更大的可能数组衰减为指针的形式，但是使用array没有该风险
  + `array`类相对于c风格数组更加轻量高效，可靠性强

  封装固定大小的容器，此容器是一个聚合类型，语义等同于保有一个c风格数组作为其唯一非静态数据成员结构体，**不同于c数组，他不会自动退化为`T*`,**该类型结合了c数组的性能与可访问性、容器的优点，可获取大小、支持赋值、随机访问迭代器等。

  ```c++
  template< 
      class T, 
      std::size_t N 
  > struct array;
  ```

## 4.1 成员函数

  + **构造函数**

  隐式声明，遵循聚合初始化的规则。聚合初始化是指使用一个花括号初始化器列表初始化聚合体。可以直接使用一下语法:

  ```c++
  T object = {arg1, arg2, ...};
  ```

  c++11起可以使用:

  ```c++
  T object{arg1, arg2, arg3, ...};
  ```

  c++20起可以使用:

  ```c++
  T object = {.指派符=arg1，.指派符{arg2}, ...}
  T object { .指派符 = arg1 , .指派符 { arg2 } ... };	
  T object (arg1, arg2, ...);
  ```

  + **元素访问**
    1. `at()`:访问指定元素，同时进行越界检查.
    2. `[]`：操作符进行c风格数组随机访问
    3. `template< size_t I, class T, size_t N > constexpr T& get( array<T,N>& a ) noexcept;`:使用`get`函数获取元素
    4. `front(), back()`:获取首尾元素
    5. `data（）`:返回指向底层数组的指针
    
  + **迭代器**
  
    1. begin()/cbegin()`:返回指向容器首个元素的迭代器
    2. `end()/cend()`:指向最后一个元素的迭代器
    3. `rbegin()/crbegin()`:返回指向容器最后元素的逆向迭代器 
    4. `rend()/crend()`: 返回指向前端的逆向迭代器 
    
  + **容量**
  
    1. `empty`:
    2. `size`:
    3. `max_size`
  
  + **操作**
  
    1. `void fill(const T& value)`:以指定值填充数组，复杂度与容器的大小呈线性关系
    2. `swap`：交换两个数组
    
    
    
# 5. forward_list

STL容器中的单向链表，c++11引入，单向链表可以方便的进行插入、删除、移动等操作，`forward_list`与`list`不同,不存储前一个元素的指针，所以节省了空间，但是不可以反向遍历。对于只需要进行单向遍历的场景应优先使用。

支持从容器中的任何位置快速插入和移除元素的容器。不支持快速随机访问。它实现为单链表，且实质上与其在 C 中实现相比无任何开销。

## 5.1 成员函数

+ **构造函数**

  1. `forward_list()`: 默认构造器，返回一个空的List容器
  2. `forward_list(size_type count, const T& value)`: 构造具有`count`值为`value`的list
  3. `forward_list(size_type count)`: 构造具有`count`个T类型的默认值的list
  4. `forward_list(InputIt first, InputIt last)`: 构造迭代器范围`[first, last)`的list
  5. `forward_list(const list& other)`: 复制构造器
  6. `forward_list(list&& other)`: move 语义构造器
  7. `forward_list(initializer_list<T> init)`:赋予初始值的list    

+ **元素访问**

  由于单向链表的实现，所以仅提供对于第一个元素的直接访问`front`

+ **迭代器**

  1. `before_begin/cbefore_begin()`:返回第一个元素前的迭代器对象
  2. `begin/cbegin()`：返回第一个元素的迭代器
  3. `end/cend()`：返回最后一个迭代器

+ **容量**

  注意单向链表没有size操作，list可以使用，只有`empty()`, `max_size()`

+ **修改器**

  1. `clear()`:清除所有内容

  2. `insert_after`:在一个位置后插入元素，支持的重载包括:

     >| iterator insert_after( const_iterator pos, const T& value ); | (1)  | (C++11 起) |
     >| ------------------------------------------------------------ | ---- | ---------- |
     >| iterator insert_after( const_iterator pos, T&& value );      | (2)  | (C++11 起) |
     >| iterator insert_after( const_iterator pos, size_type count, const T& value ); | (3)  | (C++11 起) |
     >| template< class InputIt > iterator insert_after( const_iterator pos, InputIt first, InputIt last ); | (4)  | (C++11 起) |
     >| iterator insert_after( const_iterator pos, [std::initializer_list](http://zh.cppreference.com/w/cpp/utility/initializer_list)<T> ilist ); | (5)  | (C++11 起  |

  3. `emplace_after()`:在一个位置后构造一个元素
  
  4. `erase_after()`:删除位置pos后的元素，或者是**(first, last)**范围内的元素
  
  5. `push_front`:将元素插入到容器起始位置
  
  6. `pop_front()`:删除第一个元素
  
  7. `emplace_front`:在第一个位置构造元素
  
  8. `resize(size_type count, [const value_type& value])`:重置容器的元素数量，可以赋予初值
  
  9. `swap`
  
+ **操作**

  1. `merge`:合并两个已排序的链表

     > | void merge( forward_list& other );                           | (1)  | (C++11 起) |
     > | ------------------------------------------------------------ | ---- | ---------- |
     > | void merge( forward_list&& other );                          | (1)  | (C++11 起) |
   > | template <class Compare>  void merge( forward_list& other, Compare comp ); | (2)  | (C++11 起) |
     > | template <class Compare>  void merge( forward_list&& other, Compare comp ); | (2)  | (C++11 起) |

  

     归并二个已排序链表为一个。链表应以升序排序。

     不复制元素。操作后容器 `other` 变为空。若 `other` 与 *this 指代同一对象则函数不做任何事。若 get_allocator() != other.get_allocator() ，则行为未定义。没有引用和迭代器变得非法，除了被移动元素的迭代器现在指代到 *this 中，而非到 `other` 中，第一版本用 operator< 比较元素，第二版本用给定的比较函数 `comp` 。
  
     此操作是稳定的：对于二个链表中的等价元素，来自 `*this` 的元素始终前驱来自 `other` 的元素，而且 `*this` 和 `other` 的等价元素顺序不更改。
  
  2. `splice_after`:将另一个`forward_list`的元素移入当前的单链表
  
     >
     >
     >| void splice_after( const_iterator pos, forward_list& other ); | (1)  | (C++11 起) |
     >| ------------------------------------------------------------ | ---- | ---------- |
     >| void splice_after( const_iterator pos, forward_list&& other ); | (1)  | (C++11 起) |
     >| void splice_after( const_iterator pos, forward_list& other,                     const_iterator it ); | (2)  | (C++11 起) |
     >| void splice_after( const_iterator pos, forward_list&& other,                    const_iterator it ); | (2)  | (C++11 起) |
     >| void splice_after( const_iterator pos, forward_list& other,                     const_iterator first, const_iterator last ); | (3)  | (C++11 起) |
     >| void splice_after( const_iterator pos, forward_list&& other,                     const_iterator first, const_iterator last ); | (3)  | (C++11 起) |
  
  3. `remove/remove_if`:删除满足条件的所有元素。
  
  4. `reverse`:将链表反转
  
  3. `sort（[Compare comp]）`:排序, O(NlogN)的时间复杂度

