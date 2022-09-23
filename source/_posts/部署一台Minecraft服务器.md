---
title: 部署一台Minecraft服务器
tags:
  - Minecraft
  - 服务器
category: 教程
abbrlink: 101e
date: 2020-11-25 22:19:30
---

## 以往经历

我之前搭过两台Minecraft的服务器，一台是阿里云的1核2G内存5M带宽(9.5元/月)，一台是百度云的2核4G3M(30+元/月)，都是学生机比较便宜，百度云那台的基础价格是18元/月只有1M带宽，我是升了配置，记不清一共多少钱了。

阿里云那台用作创造的实验服务器还是可以的，百度云那台配置高一点，但是用作正常地图的生存(使用MCDR和Carpet Mod)还是有点吃力，三个人时tps经常不满20，而且百度云的客服真的很烦人:(反正不想再用百度云了。

这几天又有想法再部署一台空岛服务器，想用这篇博客把服务器的部署流程记录下来，希望能为别人提供一些帮助。

<!--more-->

> 空岛对服务器性能要求不高，且有一定趣味性。如果想要其他类型的玩法直接更改存档和对应插件即可。

## 服务器选购

Minecraft的服务器很吃性能(CPU，内存和带宽都很重要)，选购服务器时就要谨慎一些。

我没打算组实体机(没钱+没精力)，所以还是选择大厂的学生服务器来部署。根据我查到的信息以及我部署CSGO和Minecraft服务器的一些经验：阿里云提供5M带宽但是只有1核2G，百度云之前也提到了，学生机标配是2核4G1M还需要自己去升配带宽，其他还看了美团云，滴滴云，华为云以及腾讯云的学生机规格，最后还是选择腾讯云的2核4G3M。

>点击可查看[购买页面](https://cloud.tencent.com/act/campus?utm_source=qcloud&utm_medium=head&utm_campaign=campus)：

![](https://imgbed.scubot.com/server_mc-1.png)

选了上海地区的服务器，还是用Ubuntu做系统

![](https://imgbed.scubot.com/server_mc-2.png)

购买服务器后第一件事应该是重置密码，这里默认的用户名为`ubuntu`

![](https://imgbed.scubot.com/server_mc-3.png)

## 服务器环境搭建

有了服务器之后需要登录到上去，我选择使用Finalshell的ssh连接到服务器。

> Finalshell可以实时监控服务器性能，但是页面上的操作有时会有卡顿，看自己取舍，可以选择xshell等ssh工具

接下来就是要安装需求和依赖：

```bash
# 升级apt-get
sudo apt-get update
sudo apt-get upgrade

# 安装python3的pip功能
sudo apt-get install python3-pip

# 安装java环境
sudo apt-get install default-jre

# 安装后台管理软件
sudo apt-get install screen
```

## 整理游戏服务器文件包

Minecraft的服务端有很多种，我选择用[MCDReforged](https://github.com/Fallen-Breath/MCDReforged)搭配[Fabric Carpet](https://github.com/gnembon/fabric-carpet)来使用，服务器版本选择1.16.3。

**地图文件**

选择之前hsds的[空岛地图](https://www.curseforge.com/minecraft/worlds/skyblock-4?__cf_chl_captcha_tk__=c09714b33f19723923aecc3313aa5507dfb1bed8-1606356067-0-AT5ZMtqpmH2R6d3sC-XFDeIUuncdodC0ivUPpBNmFMF7eICy76s5wuCrZaV-XL-vVfV4BxNw-7v3ZYlx47ofjxriKW_BARssUsfyuUiUrQX6Qo2dOBQqv0cr26s3bHhCUDDCvxUHZ_3rk1swTnBb71ctggqFA3bTXRBc1VfZGARNDZIfRZ-mANe4dt4PphO--viVwkO7YyVYIIS2ayxmAvPSgfMEeeps7LCB0DqlyjgQdbhhgGo3hKY3v8xvqWSiK0JwF4rC0Fg1gbWb9chTiTs5ohC-3edUe_WfYZd5Rsedqd-twXXFdEB1kiXpYMd9dJAH5VfNJacR9pWTBcnx5GdW_T7bHk5sCVOyUnpA0CKnzaPwwS6E11hq3oQW74azmWAA6sIdqUhYPxbBopvd6RB3BbLDRPdb4YKD8xYg9a1G1zjlozn8pEzSTLHNLPZPfxFnAw1CErHavmPBQBZchwwSHckrqblPJ6atEhsXtW2LjP1zAXN8SM7Cn9Vf4QCNfRyqX_o98caADc6tECngKlVdEr8DwtnBvcqbUbC-BJ-inTHH6PQIHLNWcMdYv2YtmkFxDyaUFv59rSeNcy3InrIwGaWj8gXbOV1zKUgX58Y9IBFgblwr1Y-73mcOKRk4Jw)，搭配我写的+我找的一些资源包，包括[连锁挖矿](/static/mc/连锁挖矿.zip)和[特殊合成](/static/mc/Ld_datapack.zip)。

> 种子：244038804808138753

**整合MCDR**

下载最新的MCDR，将地图文件覆盖到`MCDReforged/server/world`。

然后更改`MCDReforged/server/server.properties`文件，用来更改服务器的设置。我将人数上限设为10，设离线模式，非正版玩家也可以连接。

参考：

```properties
#Minecraft server properties
enable-jmx-monitoring=false
rcon.port=25575
level-seed=
enable-command-block=true
gamemode=survival
enable-query=false
generator-settings=
level-name=JC-Farm
motd=JC Oldman Group
query.port=25565
keepBackupHours=10
pvp=true
generate-structures=true
difficulty=hard
network-compression-threshold=256
max-tick-time=100000
max-players=10
use-native-transport=true
enable-status=true
online-mode=false
allow-flight=true
broadcast-rcon-to-ops=true
view-distance=10
max-build-height=256
server-ip=
allow-nether=true
server-port=25565
autoBackup=true
sync-chunk-writes=true
enable-rcon=false
op-permission-level=4
prevent-proxy-connections=false
resource-pack=
entity-broadcast-range-percentage=100
player-idle-timeout=0
rcon.password=
force-gamemode=false
rate-limit=0
autoBackupMins=180
hardcore=false
white-list=false
broadcast-console-to-ops=true
spawn-npcs=true
spawn-animals=true
snooper-enabled=true
function-permission-level=2
level-type=default
spawn-monsters=true
enforce-whitelist=false
spawn-protection=0
resource-pack-sha1=
max-world-size=29999984
```

MCDR上装了这几个插件，其中`QuickAnswer.py`是我魔改之后的版本。

![](https://imgbed.scubot.com/server_mc-4.png)

## 部署服务器

1. 将`MCDReforged`文件夹上传至服务器上(时间有一点长)

2. 安装MCDR的依赖，在`MCDRefored/`下输入`pip3 install -r requirements `与`pip3 install psutil`

3. 执行`python3 MCDRefored.py`试运行服务端

   ![](https://imgbed.scubot.com/server_mc-5.png)

   可以看到运行成功，服务器内情况正常：

   ![](https://imgbed.scubot.com/server_mc-6.png)

   服务器资源占用也很低

   ![](https://imgbed.scubot.com/server_mc-7.png)

   空载时服务器负荷并不大

   ![](https://imgbed.scubot.com/server_mc-8.png)

4. 改用`screen`后端挂载服务端：

   - `screen -S mc` 创建mc窗口

   - `python3 MCDReforged.py`启动服务器

   - `Ctrl A D`将窗口挂载

      > `screen -ls`可以查看窗口列表
      >
      > `screen -S <name> -X quit` 可以删除某个窗口

## MCDR插件编写

MCDR以python为开发语言，开发文档见：https://github.com/Fallen-Breath/MCDReforged/blob/master/doc/plugin.md

以切换玩家观察者/生存模式的插件为例：

> CameraMode.py

```python
# -*- coding: utf-8 -*-
import os

def on_load(server, old):
    server.add_help_message('.c', '切换观察者模式')
    server.add_help_message('.s', '切换生存模式')

def on_info(server, info):
    if info.content.startswith(".c") and info.is_player == True:
        server.execute("gamemode spectator " + info.player)
    elif info.content.startswith(".s") and info.is_player == True:
        server.execute("gamemode survival " + info.player)
```

使用`.c和.s`在观察者和生存模式间切换，很简洁。

