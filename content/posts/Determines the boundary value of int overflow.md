+++
draft = true
date = 2019-02-18T12:56:03+08:00
title = "Determines the boundary value of the int overflow"
slug = "Determines the boundary value of the int overflow" 
tags = ["Leetcode"]
categories = ["notes"]
+++

# [Leetcode Note] 关于 int32 溢出值的判定

关于整数的处理，溢出是一个难以避免的话题。对于强类型静态语言来说，一个固定大小的整形的溢出值需要格外注意。以一个 32 bits 的整形为例：对于无符号数范围（0～4294967296），有符号数的范围（-2147483648~2147483647）。对于溢出值，不可能继续采用 32 bits整形进行存储，可以考虑使用 64 bits 整形存储。但是必须考虑一个情形，如果一个大整数，对于 64 bits 仍然溢出呢？我们如果在计算一个值之后再去估计存储它所需要的位数，未免南辕北辙，毕竟我们的工作只是判断是否溢出。

**有符号判定**

Leetcode [problem 7](https://leetcode.com/problems/reverse-integer/) [problem 8](https://leetcode.com/problems/string-to-integer-atoi/) 中，一个进行数字的倒序，一个实现 `atoi`操作，涉及到整形的操作，而且规定整形的容量为 32 bits。进行数字倒序时，循环的每次操作得到个位数字，然后加到最终结果`result`上。那么溢出判断在何时进行呢？一定要在进行加法之前进行。分为两种情况进行讨论：

+ `result > INT_MAX / 10 `,  下次操作一定会溢出
+ `result == INT_MAX / 10 `, 对于 32 bits 有符号数而言，进行下次操作时。最大可以加上`7`，所以当 `result == INT_MAX / 10 && digit > 7`(digit 为下一次加上的数字) 也会溢出

对于负数预制类似。

go 实现的 pro 7：

```go
func reverse(x int) int {
  var digit int32
  var d = int32(x)
  const MAX int32 = int32(^uint32(0) >> 1)
  const MIN = ^MAX
  var sum int32 = 0
  for d != 0 {
    digit = d % 10
    if sum > MAX / 10 || (sum == MAX / 10 && digit > 7) {
      return 0
    }
    if sum < MIN / 10 || (sum == MIN / 10 && digit < -8) {
      return 0
    }
    sum = sum * 10 + digit
    d /= 10
  }
  return int(sum)
}
```

**无符号判定**

与 pro 7 相似，pro 8 是一个无符号溢出的判定。要求提取一个字符串中的整数，忽略空格，遇到非数字则停止。可以根据数字前的 ”+， -“ 得到整形的符号。ASCII 码对应的数字范围为： 48-57(0-9), 由于符号已经经过处理，所以每次判定只是无符号数的判定：

+ `result > INT_MAX / 10 `,  下次操作一定会溢出
+ `result == INT_MAX / 10 `, 对于 32 bits 有符号数`+`而言，进行下次操作时。最大可以加上`7`（55），所以当 `result == INT_MAX / 10 && digit > 7`(digit 为下一次加上的数字) 也会溢出，符号位`-`，最大加上`8`（56）

```go
func myAtoi(str string) int {
  const MAX int32 = int32(^uint32(0) >> 1)
  const MIN int32 = ^MAX

  str = strings.Trim(str, " ")
  if len(str) == 0 {
    return 0
  }
  sign := 1
  if str[0] == '-' {
    sign = -1
    str = str[1:]
  } else if str[0] == '+' {
    str = str[1:]
  }
  if len(str) == 0 || str[0] < 48 || str[0] > 57 {
    return 0
  }

  result := 0
  for _, v := range str {
    if v < 48 || v > 57 {
      break
    }
    if sign * result > int(MAX) / 10 || (sign * result == int(MAX)/10 && int(v) > 55) {
      return int(MAX)
    }
    if sign * result < int(MIN) / 10 || (sign * result == int(MIN)/10 && int(v) > 56) {
      return int(MIN)
    }
    result = result * 10 + (int(v) - 48)
  }
 
  return result * sign
}

```

**动态类型语言**

对于动态类型语言来说，以 python3 为例，`<class int>` [integer have unlimited precision](https://docs.python.org/3/library/stdtypes.html#numeric-types-int-float-complex). 也就是说可以使用任意精度的整形，也就不需要每次在循环中判断是否溢出，可以计算出最终值后再判断。

```python

  if sign < 0 {
    if sign * result < int(MIN) {
      return int(MIN)
    } else {
      return sign * result
    }
  } else {
    if sign * result > int(MAX) {
      return int(MAX)
    } else {
      return result
    }
  }
```

