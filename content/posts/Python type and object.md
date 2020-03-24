+++
draft = false
date = 2019-07-06T15:50:20+08:00
title = "Python type 以及 object详解"
slug = "Python type 以及 object详解"
tags = ["Language"]
categories = ["Python"]

+++

# 基础概念

## 1. 什么是object?

在python中，遵守着“一切皆对象”的箴言。所有的类型、实例、类均为对象。这是在本文开始前需要明确的。那么在python中，对象的定义到底是什么呢？所有表示实体的概念都可以视为一个对象，一般具有以下特征:

+ **标识符（Identity）**： 用于唯一标示一个对象的标志
+ **值(value)**: 对象所存储的值，可能包含很多属性（可以使用`object.attr`对于属性进行操作）
+ **类型(type)**: 每个对象**有且仅有一个**类型
+ **基类（bases）**： 可以有一个或者多个基类，类似于面向对象语言的父类或者超类，支持多继承。并不是所有的对象都有基类。

如果对于python对象的内存分布更感兴趣，其实可以通过理解**元数据（meta）**抽象，加深理解。所有的对象在内存中都有一个特定的地址，可以通过`id()`函数获取其地址。

类型以及基类对于object至关重要，因为他们确定了对象的具体行为，以及与其他对象的关系。同时需要牢记的是所有的类型以及基类都是object！

以一个简单的`1`对象为例:

```python
>>> a = 1     			# 在当前的命名空间给一个整数object名字为a
>>> type(a)
<class 'int'>
>>> type(type(a))
<class 'type'>
>>> type(a).__base__
<class 'object'>
>>> type(a).__bases__
(<class 'object'>,)
>>> dir(a)
['__abs__', '__add__', '__and__', '__bool__', '__ceil__', '__class__', '__delattr__', '__dir__', '__divmod__', '__doc__', '__eq__', '__float__', '__floor__', '__floordiv__', '__format__', '__ge__', '__getattribute__', '__getnewargs__', '__gt__', '__hash__', '__index__', '__init__', '__init_subclass__', '__int__', '__invert__', '__le__', '__lshift__', '__lt__', '__mod__', '__mul__', '__ne__', '__neg__', '__new__', '__or__', '__pos__', '__pow__', '__radd__', '__rand__', '__rdivmod__', '__reduce__', '__reduce_ex__', '__repr__', '__rfloordiv__', '__rlshift__', '__rmod__', '__rmul__', '__ror__', '__round__', '__rpow__', '__rrshift__', '__rshift__', '__rsub__', '__rtruediv__', '__rxor__', '__setattr__', '__sizeof__', '__str__', '__sub__', '__subclasshook__', '__truediv__', '__trunc__', '__xor__', 'bit_length', 'conjugate', 'denominator', 'from_bytes', 'imag', 'numerator', 'real', 'to_bytes']
```

一个object有一个**名字（name）**，但是却不属于对象本身，对象的名称在对象之外，存在于命名空间中，或者作为另一个对象的属性。对于一个object，可以使用`__bases__`属性获取其所有基类的元组，使用`dir()`函数获取所有的方法以及属性。

****

*注意*

以上测试在python 2.x中`type（）`输出是`<type 'type_name'>` 这是语言最初设计时的遗留问题.最初`type`是cpython是现实的内置类型，而`class`语句用于声明一个类，由于命名不同，所以两者不可以混用，不可以用`class`扩展`type`。在python2.2之后，开发者开始逐渐统一两个概念，python3.X中所有的内置类型也都是标签式的`class`,所以可以对于内置类型进行继承.

python type与class关系:

```
Type(Metaclass) -> Class -> Instance
```

****



## 2. 第一箴言：一切皆对象

这句话不仅仅意味着`23， 88`等`int`的实例是对象，而且`int`本身也是对象，他可能在内存中就坐落在某一个数字实例的旁边，可以查看其地址:

```python
>>> id(int)
140268716333408
```

实际上，所有的`int`实例都使用它们的`__class__`属性指向该地址，表示*"That guy really knows me!"*.使用`type()`函数，实际返回的对象的`__class__`属性。

此时需要将先入为主的面向对象的概念放到一边，而把一切视为对象，然后开始探究对象间的关系。不同对象间的主要关系包括**子类和父类的关系、类型以及实例的关系。**

### 2.1 第一对象

python中最重要的两个对象是`<class type>`, `<class object>`.这两个对象是python中的原始对象。我们可以逐一的介绍这两个对象，但是无疑会陷入“鸡生蛋还是蛋生鸡”的问题。其实两者是相互依赖的，不能独立存在，因为他们是依据彼此进行定义的。

```python
>>> object
<class 'object'>
>>> type
<class 'type'>
>>> object.__class__
<class 'type'>
>>> object.__bases__
()
>>> type.__bases__
(<class 'object'>,)
>>> type.__class__
<class 'type'>
>>> isinstance(object, object)
True
>>> isinstance(object, type)
True
>>> isinstance(type, type)
True
>>> isinstance(type, object)
True
```

可以惊喜的看到，`object, type`的类型都是`type`,而`type`的基类是`object`,**所以二者互为对方的实例，同时由于双箭头的存在，所以他们自身又是自身的实例。**

![type and object](https://mediainter.innohub.top/190706-py.png)

### 2.2 类型对象

在第一对象的基础上，可以引入类型对象。例如：`int`， `User`等预定义或者自定义的对象。实际上，`<class type>`可以看作是一个`trait`（Rust概念），规定了**类型对象**具有以下特征:

+ 类型对象用于**表示抽象数据类型**，例如：一个`User`的对象可以表示系统中的所有用户，`int`的对象可以表示所有的整数
+ **可以被子类化**，也就是可以根据现有的类型对象创建一个具有类似行为的类型对象。此时现有的对象就是基类。
+ **可以被实例化**，可以根据一个类型对象创建任意多个实例，实例的`__class__`属性是该对象
+ **该对象的类型为`<class type>`**
+ 类型对象一般被称为`class`或者`type`

在python2.2之后,type与class的你语义相同，所以`type()`函数与`__class__`属性获取的结果是一样的。类型以及非类型对象都是对象，但是只有**类型**才可以具有子类，其他的对象不可以被继承。

判断一个对象是否为类型对象？

**如果`type(obj) == type`,那么就是类型对象!!!**

*总结*

> 1. `object`是`type`的一个实例
> 2. `object`不是任何对象的子类
> 3. `type`， `object`是本身的一个实例
> 4. `type`是`object`的子类

### 2.3 更多内置类型

![list dict tuple](https://mediainter.innohub.top/190706-ty.png)

python还有很多其他的原始类型，他们都继承自`object`,同时是`type`的一种实现，都是类型对象。



## 3. 创建对象

### 3.1 通过子类创建新的对象

可以通过创建子类的方式创建新的对象：

+ 使用`class`关键字创建一个新的类型
+ 支持多个基类
+ 大多数的内置类型都是可以被继承的（并不是全部）
+ 任何 object 的子类(以及他们的子类)的类型都是 type

```python

class AtheletList(list):
    def __init__(self, name=None, des=None, times=[]):
        list.__init__([])
        self.name = name
        self.des = des
        self.extend(times)

    def top3(self):
        return str(sorted(self)[0:3])
```

```python
>>> class A:
...     pass
...
>>> type(A)
<class 'type'>
>>> class B(A):
...     pass
...
>>> type(B)
<class 'type'>

```



### 3.2 通过实例化创建新对象

通过使用`()`操作符调用一个类型对象用以实例化一个该类型的实例。那么python进行实例化时到底发生了什么呢?

```c++
1. 首先，python创建一个新的对象时，需要根据一个具体的类型
2. 调用该类型对象的 __new__ 方法为该实例分配空间，然后再调用 __init__ 方法进行初始化
3. 此时，该类型作为一个工厂生产出新的对象
```

*最终的对象图谱：*

![object map](https://mediainter.innohub.top/190706-map.png)

可以把对象分为三类:

+ 元类
+ 类
+ 实例

图中的实线表示继承，虚线可以表示实现。

# Reference

https://www.oreilly.com/library/view/learning-python-3rd/9780596513986/ch04.html

[https://www.cs.utexas.edu/~cannata/cs345/Class%20Notes/15%20Python%20Types%20and%20Objects.pdf](https://www.cs.utexas.edu/~cannata/cs345/Class Notes/15 Python Types and Objects.pdf)

[https://stackoverflow.com/questions/35958961/class-vs-type-in-python](https://stackoverflow.com/questions/35958961/class-vs-type-in-python)
