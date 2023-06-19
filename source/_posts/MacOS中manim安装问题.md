---
title: MacOS中manim安装问题
abbrlink: 62c3
date: 2023-06-19 23:04:39
tags:
---

- [**manim**](https://manim.community) 是社区维护版
- [**manimgl**](https://pypi.org/project/manimgl/#description) 是3Blue1Brown使用的版本

一般可以使用manim社区维护版。

在MacOS上安装manim时，除了按照官网上的描述操作外，也容易出现一些其他问题。

我遇到的：

```shell
pkg-config --print-errors --atleast-version 1.30.0 pangocairo
```

会报错找不到`xproto`这个库。

解决方法：

1. 去 [x.org/archive/individual/proto](https://www.x.org/archive/individual/proto/) 下载源码；
2. 生成配置文件 `./configure --prefix=/usr/local/<xxx>`
3. 安装 `make install`

实际上除了`xproto`，还需要下载`renderproto`，`kbproto`和`xextproto`这几个库。

