+++
draft = false
date = 2019-02-13T13:53:00+08:00
title = "Go detail to ASCII, Unicode and Character sets"
slug = "Go detail to ASCII, Unicode and Character sets" 
tags = ["computer science"]
categories = ["Summary"]
+++

# ASCII，Unicode 码与字符集                                                                                                                                                                                                                                                                                                                                                                                                                      

很早就对于编码方式，字符集等问题心存疑惑。在一些语言中，有关字符集的问题都被进行了简化。但是在一些语言中，比如 Rust，对于这个问题进行了较为接近本质的谈论。

## 1. 历史溯源

很久很久以前，有一群人，他们决定使用8个可以开合的晶体管来组合形成不同的状态，以表示世界上的万物。他们看见8个字节的开关状态最好，于是将其称为“字节”。后来产生了可以处理这些字节的工具，也就是计算机。最早计算机只在美国使用，八位的字节一共可以组合出256种不同的状态，他们使用了0-127进行编码。这样计算机就可以处理英文的文字了。这样的编码方案被称为 **ASCII**（America Standard Code for Information Translation）码。由于自己聚具有多大8bits的空间，所以很多人都在思考：“gosh， 我们可以使用128-255的编码”当很多人同时具有这个想法就很糟糕了，很多公司使用各自的规范，这造成了极大地混乱。除此之外，ASCII还有更大的先天不足，由于仅支持英文，所以对于世界上的其他语言无法进行表示。

但是简单地认为“plain text = ascii = characters 为8bits”的错误大错特错。为了对于世界上其他语系进行有效支持，必须使用更多的字节，并且使用统一的编码。由此，Unicode这一统一的编码集便应运而生了。在这里必须明确一个概念，ASCII， Unicode都是字符集，utf-8是一种编码方式，通过使用统一的编码方式，依据unicode字符集，可以满足所有的编码需求。

## 2. ASCII 码及其发展

使用一个字节表示进行编码，把其中0-31种状态用作特殊用途，`0x20`一下字段被称为控制码，然后将空格、标点、数字、大小写字母分别用连续的字节状态表示，一直编码到127号。

+ `0x20`--> space
+ `0x41` --> A

![img](https://upload-images.jianshu.io/upload_images/1271566-5f2e864323d9226c?imageMogr2/auto-orient/strip%7CimageView2/2/w/875/format/webp)

我们们可以这样理解ASCII码，她就是一个字典，是英文世界和计算机世界沟通的通道。这个通道让一开始的沟通变顺畅。就这样计算机和程序员愉快的交流着。

英文使用128个编码就足够了，但是用于其同语言的编码，必须对于128之后的码点进行编码，或者使用新的字符集。

后来，就像建造巴比伦塔一样，世界各地都开始使用计算机，但是很多国家用的不是英文，他们的字母里有许多是ASCII里没有的，为了可以在计算机保存他们的文字，他们决定采用 
127号之后的空位来表示这些新的字母、符号，还加入了很多画表格时需要用下到的横线、竖线、交叉等形状，一直把序号编到了最后一个状态255。从128 到255这一页的字符集被称”**扩展字符集**“。

等中国人们得到计算机时，已经没有可以利用的字节状态来表示汉字，况且有6000多个常用汉字需要保存呢。但是这难不倒智慧的中国人民，我们不客气地把那些127号之后的奇异符号们直接取消掉, 规定：一个小于127的字符的意义与原来相同，但两个大于127的字符连在一起时，就表示一个汉字，前面的一个字节（他称之为高字节）从0xA1用到0xF7，后面一个字节（低字节）从0xA1到0xFE，这样我们就可以组合出大约7000多个简体汉字了。在这些编码里，我们还把数学符号、罗马希腊的字母、日文的假名们都编进去了，连在 ASCII 里本来就有的数字、标点、字母都统统重新编了两个字节长的编码，这就是常说的”全角”字符，而原来在127号以下的那些就叫”半角”字符了。中国人民看到这样很不错，于是就把这种汉字方案叫做 “**GB2312**“。GB2312 是对 ASCII 的中文扩展。但是中国的汉字太多了，为了满足需求，干脆不再要求低字节一定是127号之后的内码，只要第一个字节是大于127就固定表示这是一个汉字的开始，不管后面跟的是不是扩展字符集里的内容。结果扩展之后的编码方案被称为 **GBK** 标准，GBK包括了GB2312 的所有内容，同时又增加了近20000个新的汉字（包括繁体字）和符号。 后来少数民族也要用电脑了，于是我们再扩展，又加了几千个新的少数民族的字，GBK扩成了 **GB18030**。

 由于使用双字节进行编码，形成了 **DBCS(Double Byte Character Set)**双字节字符集，所以才有了“一个中文算两个英文字符.........”

##  3. Unicode 码 

由于每个国家都试图编写自己的编码标准，导致了互相之间都不支持。此时，ISO着手解决了这个问题：废了所有的地区性编码方案，重新搞一个包括了地球上所有文化、所有字母和符号 的编码！他们打算叫它”Universal Multiple-Octet Coded Character Set”，简称 **UCS**, 俗称 “**unicode**“。

 Unicode 是一次伟大的尝试，希望可以创造包含世界上所有有意义符号统一字符集。有人误以为，unicode 码使用两个字节，每一个编码使用16 bits 进行编码，所以最多可以编码 65,536 个字符。这实际上是不对的。事实上，Unicode有一种不同的思考角色的方式，你必须要理解Unicode的思维方式否则没有任何意义。

在 Unicode 中，一个字符映射到的内容被称为**码点**，这只是一个理论上的概念，码点如何在内存进行存储才是重点。在 Unicode 中每一个不同的字母必须赋予不同的码点表示，但是相同字母的不同字体需要被认为一致，不同语言中字母的表示都是需要考虑的问题。但这些问题都已经得到了完美的解决。字母表中的每一个字母都被赋予了一个特殊的魔术字类似于：**U+0639**. 这个魔术字被称为码点，使用十六进制表示。

事实上，Unicode 可以定义的字符数量没有限制，实际上它们已超过65,536，因此不是每个 Unicode 字母都可以真正地压缩成两个字节，但这无论如何都是一个神话。

所以在 Unicode 中，字符都可以表示为码点的形式：

```
Hello   ---->   U+0048 U+0065 U+006C U+006C U+006F.
```

直接用两个字节存入字符的 Unicode 码,被称为 UCS-2编码方式。

## 4. UTF-8 编码

将字符映射到一个字典很简单，更大的问题是如何进行编码，如何在内存中进行存储。对于原本的ASCII字符，使用了两个字节进行存储显然造成了很大的空间浪费，而且从“旧社会”走过来的程序员开始发现一个奇怪的现象：他们的 *strlen* 函数靠不住了，一个汉字不再是相当于两个字符了，而是一个是的，从unicode开始，无论是半角的英文字母，还是全角的汉字，它们都是统一的”**一个字符**“。同时，也都是统一的”**两个字节**“。Unicode 的另一个缺点是，无法有效区分 ASCII 码以及Unicode 码，如何得知两个字节是一个 Unicode 字符，还是两个 ASCII 字符？

所以,很长时间 Unicode 都无法得到推广，，直到互联网的出现，为解决unicode如何在网络上传输的问题，于是面向传输的众多 **UTF**（UCS Transfer Format）标准出现了，顾名思义，**UTF-8**就是每次8个位传输数据，而**UTF-16**就是每次16个位。UTF-8就是在互联网上使用最广的一种unicode的实现方式，这是为传输而设计的编码，并使编码无国界。

UTF-8 的最大特点就是使用变长的编码方式，每一个符号使用 1-4 个字节进行存储，所以对于ASCII码仅使用一个字节进行存储即可，其他字符使用各自的编码进行存储。这有一个显然的优点，英文的表示的ASCII中与UTF-8中完全一致，又可以容纳足够多的字符。其基本规则很简单：

+  单字节符号，首位设为0，后7为为对应的Unicode码
+ 对于`n`字节符号，第一个字节的前`n`位设为1，`n+1`位设为0，后面字节的前两位一律设为`10`

```rust
Unicode符号范围     |        UTF-8编码方式
(十六进制)        |              （二进制）
----------------------+---------------------------------------------
0000 0000-0000 007F | 0xxxxxxx
0000 0080-0000 07FF | 110xxxxx 10xxxxxx
0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
```

## 5.  Big endian or little endian

UCS-2 格式可以存储 Unicode 码（码点不超过`0xFFFF`）。以汉字`严`为例，Unicode 码是`4E25`，需要用两个字节存储，一个字节是`4E`，另一个字节是`25`。存储的时候，`4E`在前，`25`在后，这就是 Big endian 方式；`25`在前，`4E`在后，这是 Little endian 方式。

这两个古怪的名称来自英国作家斯威夫特的《格列佛游记》。在该书中，小人国里爆发了内战，战争起因是人们争论，吃鸡蛋时究竟是从大头(Big-endian)敲开还是从小头(Little-endian)敲开。为了这件事情，前后爆发了六次战争，一个皇帝送了命，另一个皇帝丢了王位。

第一个字节在前，就是"大头方式"（Big endian），第二个字节在前就是"小头方式"（Little endian）。

那么很自然的，就会出现一个问题：计算机怎么知道某一个文件到底采用哪一种方式编码？

Unicode 规范定义，每一个文件的最前面分别加入一个表示编码顺序的字符，这个字符的名字叫做"零宽度非换行空格"（zero width no-break space），用`FEFF`表示。这正好是两个字节，而且`FF`比`FE`大`1`。

如果一个文本文件的头两个字节是`FE FF`，就表示该文件采用大头方式；如果头两个字节是`FF FE`，就表示该文件采用小头方式。

-----

*Reference:*

*[The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets](https://www.joelonsoftware.com/2003/10/08/the-absolute-minimum-every-software-developer-absolutely-positively-must-know-about-unicode-and-character-sets-no-excuses)*

*[字符编码笔记：ASCII，Unicode 和 UTF-8](http://www.ruanyifeng.com/blog/2007/10/ascii_unicode_and_utf-8.html)*

*https://www.zhihu.com/question/23374078*



 

 

 

 
