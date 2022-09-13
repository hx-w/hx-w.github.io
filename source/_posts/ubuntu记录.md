---
title: ubuntu记录
tags:
  - 服务器
category: 教程
index_img: 'https://ibed.csgowiki.top/ubuntu.png'
abbrlink: 7b14
date: 2021-02-05 15:48:32
---

用来记录我操作ubuntu系服务器的一些需要注意的点
<!--more-->

## 版本

我一直用的是ubuntu的服务器，更关心服务器版本。

ubuntu目前稳定版为LTS(Long-Term-Support)，每两年发布一次，且永久免费。

国内不同服务器厂商提供的ubuntu云服务器不尽相同：

- [三丰云] 只提供 14.04LTS和16.04LTS
- [青云] 与 [阿里云] 都提供 18.04LTS
- [腾讯云] 提供20.04LTS

### 升级版本

根据ssh登录服务器后的提示，使用指令`do-release-upgrade`即可升级版本

## apt相关

### 使用`apt`还是`apt-get`？

泛泛来讲`apt`是`apt-get`的封装，对用户更加友好，也能显示更多的安装信息。以下的指令我都以`apt`为准。

### 更新与换源

初次使用root登陆服务器之后先：

```bash
apt update -y && apt upgrade -y # 更新服务器软件包
```

一般大厂会在云服务器预置自家的apt镜像，如果没有的话可以自己更换apt的源：

```bash
cp /etc/apt/sources.list /etc/apt/sources.list.bak # 备份

vim /etc/apt/sources.list # 编辑源 
```

删掉原来的内容，添加进以下内容，我这里用阿里源(18.04LTS)：

```bash
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
```

保存退出之后再更新一下包管理器即可：`apt update`

**注意**

不同操作系统版本对应的源不一定相同，可能换源之后会遇到有些软件包安装不了的情况，可以考虑换成初始的源，安装之后再换回来。

### 基础软件包

- gcc编译器以及一些基础的通用程序安装：`apt install build-essential`
- 通用软件包：`apt install software-properties-common`

## 添加用户

```bash
sudo adduser <name>

sudo usermod -aG sudo <name> # 赋予sudo权限

su <name> # 切换用户
```

## Python相关

### 升级版本

一般服务器自带的python版本是3.5或者3.6，如果要用python写东西，建议使用高版本。

> 3.6版本新出了一种语法：f-string，写起来很方便

手动升级版本：

1. 安装依赖

    ```bash
    sudo apt update -y && apt install -y build-essential zlib1g-dev libbz2-dev libssl-dev libncurses5-dev libsqlite3-dev libreadline-dev tk-dev libgdbm-dev libdb-dev libpcap-dev xz-utils libexpat1-dev liblzma-dev libffi-dev libc6-dev
    ```

2. 去官网：https://www.python.org/downloads/source/ 找到最新的稳定版(Stable Releases)为3.8.7，使用wget下载

    ```bash
    wget 'https://www.python.org/ftp/python/3.8.7/Python-3.8.7.tgz' 
    
    tar zxvf Python-3.8.7.tgz  # 解压
    ```

3. 编译源码

    ```bash
    cd Python-3.8.7 
    sudo mkdir -p /usr/local/python3  # 建立安装目录
    
    # --enable-optimizations 会自动安装pip3以及优化配置，建议加上
    ./configure --prefix=/usr/local/python3 --enable-optimizations
    
    make
    sudo make install # 编译
    ```

4. 更新软连接

    ```bash
    # 删除旧连接
    sudo rm -rf /usr/bin/python3
    sudo rm -rf /usr/bin/pip3
    
    # 添加新连接
    # 注意这里 python3.8根据实际情况更改，可能是3.7 / 3.9 xxx
    #添加python3的软链接
    sudo ln -s /usr/local/python3/bin/python3.8 /usr/bin/python3
    #添加 pip3 的软链接
    sudo ln -s /usr/local/python3/bin/pip3.8 /usr/bin/pip3
    ```

5. 检测版本

    ```bash
    python3 -V
    
    pip3 -V
    ```

    

