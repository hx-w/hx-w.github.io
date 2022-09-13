---
title: C++小技巧-Lambda表达式
tags:
  - C++
abbrlink: 808a
date: 2021-04-14 22:29:58
index_img: https://ibed.csgowiki.top/image/lambda_expression.png
---

由于最近项目中用到了C++ Lambda表达式的相关内容，在这里记录一下。

<!--more-->

## 什么是Lambda表达式

我自己理解的是Lambda表达式就是不需要复杂逻辑的匿名函数，在很多高级语言中都有。

比如Python中：

```python
my_list = [1, 2, 3]
new_list = list(map(lambda x: 'new' + str(x), my_list))
```
就可以在map中使用Lambda表达式使得程序更加简洁。

## C++的Lambda表达式
C++11提供了Lambda表达式的功能，完整声明的格式如下：
```c++
[capture_list] (params_list) mutable exception -> return_type { function_body }
```
{% note success %}
各项定义如下：
- `capture_list`：捕获列表，用于捕获外部变量
- `params_list`：形参列表
- `mutable`：是否可以修改捕获的外部变量
- `exception`：异常设定
- `return_type`：返回类型
- `function_body`：函数体
{% endnote %}

这6部分中，除了`capture_list`和`function_body`，其他4部分都是可选的。

常见的情况有以下三种：
- `[capture_list](params_list) -> return_type { function_body }`
- `[capture_list](params_list) { function_body }` 
  > 省略返回类型，编译器可以根据规则推断出Lambda表达式的返回类型。
  > 即如果Lambda表达式中出现return，则根据return的类型确定，
  > 如果没有return，则返回类型为void。
  > **在项目中最常用**
- `[capture_list] { function_body }`

## 捕获外部变量-进阶说明

在C++中，函数参数的传递方式有三种：值传递、引用传递和指针传递。

Lambda表达式的外部变量捕获方式有三种：值捕获、引用捕获和隐式捕获。

### 1.值捕获
在`capture_list`中直接传入变量值，<span  style="color: #519D9E; ">在Lambda表达式构建时，外部变量将通过值拷贝的方式传入，如果后面外部变量被修改，也不会影响Lambda表达式中的值</span>

```c++
int main() {
    int val = 0;
    auto func = [val] { cout << val << endl; };
    val = 1;
    func(); // 输出 0
}
```

### 2.引用捕获

在外部变量名前加`&`，使用引用捕获的变量，将会在Lambda表达式中与外部变量绑定。在表达式构造结束，该外部变量变化之后再调用Lambda表达式，这时会使用最新的外部变量对象。

```c++
int main() {
    int val = 0;
    auto func = [&val] { cout << val << endl; };
    val = 1;
    func(); // 输出 1
}
```

### 3.隐式捕获

除了在`capture_list`中指定外界变量名之外，还可以用隐式捕获的办法，即让Lambda表达式自行推断需要哪些外部变量。隐式捕获具体有两种：
- `[=]` 表示以值捕获的方式捕获外界变量
  ```c++
    int main() {
        int val = 0;
        auto func = [=] { cout << val << endl; };
        val = 1;
        func(); // 输出 0
    }
  ```
- `[&]` 表示以引用捕获的方式捕获外界变量
  ```c++
    int main() {
        int val = 0;
        auto func = [&] { cout << val << endl; };
        val = 1;
        func(); // 输出 1
    }
  ```

### 4.混合捕获

C++11中的Lambda表达式支持将以上三种捕获方式混用，常见的情况如下：

| 捕获形式 | 说明 |
|---|----|
| `[]` | 不捕获外部变量 | 
| `[a, b, ...]` | 全部以值捕获捕捉 |
| `[this]` | 捕获`this`指针 |
| `[=]` | 值捕获所有外部变量 |
| `[&]` | 引用捕获所有外部变量 |
| `[=, &a]` | 变量`a`使用引用捕获，其他使用值捕获|
| `[&, a]` | 变量`a`使用值捕获，其他使用引用捕获|

### 捕获外部变量并修改

当外部参数采用**值捕获**时，在`function_body`函数体内部无法修改捕获的外部变量值，会提示`read-only`。
这时需要添加`mutable`关键字。
```c++
int main() {
    int val = 0;
    auto func = [val]() mutable { cout << ++val << endl; };
    func(); // 输出 1
    cout << val << endl; // 输出 0
}
```
{% note info %}
如果使用**引用捕获**，则不需要添加`mutable`关键字，在Lambda表达式中更改的内容会直接影响到外部变量。
{% endnote %}

## Lambda表达式参数`params_list`的限制
Lambda表达式的参数和普通函数的参数类似，不过有一些限制：

1. 参数列表中不能有默认参数
2. 不支持可变参数，即用`...`表示的参数，不定个数。
3. 所有参数必须有参数名

## 其他例子

```c++
#include <iostream>
#include <functional>

using namespace std;

int main() {
    auto funcA = [](int x) -> function<int(int, int)> { return [=](int y, int z) { return (x + y) * z; }; };

    cout << funcA(2)(4, 8) << endl; // 输出 48      (2 + 4) * 8 = 48

    auto funcB = [](const function<int(int, int)>& func, int valA, int valB) { return -func(valA, valB); };

    cout << funcB(funcA(3), 6, 9) << endl;  // 输出 -81    -(2 + 6) * 9
    return 0;
}}
```