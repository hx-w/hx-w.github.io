---
title: CSGO-RealTimeMap开发记录
tags:
  - CSGO
  - sourcemod
category: 教程
abbrlink: c038
date: 2020-12-05 21:53:25
---

## 介绍

CSGO-RealTimeMap是一个致力于将CSGO服务器内的信息实时显示到网页上的一个无数据库项目，灵感来源自Minecraft的插件dynmap。

插件分为两部分：游戏服务器的sourcemod插件和服务器本地的网站。

项目开源地址：[GitHub](https://github.com/hx-w/CSGO-RealTimeMap)。

开发日期：2020-12-3至2021-01-01。

<!--more-->

### 技术栈

- **flask** 做网页显示。
- **websocket** 实现前端与数据的同步。

- **sourcemod** 实现游戏内数据向网站的同步。

最初版演示见[B站视频](https://www.bilibili.com/video/BV1mt4y1a7YG/)。


## 功能目标

- 易于部署&维护的插件/网站结构
- 网页上平滑的玩家移动
- 丰富的图标显示：玩家朝向、所持武器、所属阵营等
- 详细的服务器内信息：玩家在线时间、击杀情况等
- 在线聊天系统

## 开发记录

#### 2020-12-5

**feature**

1. 更新了道具效果的显示：

   ![道具效果](https://imgbed.scubot.com/RTM-1.jpg)

2. 更多的关键帧，现在关键帧增加到了10，网页上人物移动的显示效果更加流畅

**bug**

1. 内存不释放，怀疑是道具的记录引起的
2. 程序运行日志未删除

#### 2020-12-6

**bug fix& feature**
1. 解决内存不释放的问题，采用garbage collector主动释放内存。
  > python中的dict删除某个元素之后并不会直接释放内存，需要用`gc.collect()`来主动释放
2. 实现服务器到网页的聊天信息显示(server2web)
3. 实现网页到服务器的聊天信息显示(web2server)
    ![聊天信息](https://imgbed.scubot.com/RTM-2.jpg)

**bug**
1. 人物移动在网页上显示越来越滞后


#### 2020-12-7

**feature**
1. 增加诱饵弹的道具显示效果
2. 重构网站的消息机制，构造消息队列`MessageQueue`用于系统化的处理从服务器到网站的数据
3. 关键帧减少为5，否则会有明显数据滞后问题

> 游戏服务器向网站发消息

![server2web](https://imgbed.scubot.com/RTM-4.png)

> 网站向服务器发消息

![web2server](https://imgbed.scubot.com/RTM-3.png)

> `MessageQueue`结构

```python
import queue

class MessageQueue():
    def __init__(self, qMapSz=1, qPlayerMoveSz=100, qUtilitySz=10, q2ServerMsgSz=10, q2WebMsgSz=5):
        '''
        qMap: [mapname]
        qPlayersMove: [[posX, posY, name, steam3id, clientid]]
        qUtility: [utid, uttype, posX, posY]
        q2WebMsg: [ip/name, msg]
        q2ServerMsg: [ip, msg]
        '''
        self.qMsg = {
            "qMap": queue.Queue(maxsize=qMapSz),
            "qPlayersMove": queue.Queue(maxsize=qPlayerMoveSz),
            "qUtility": queue.Queue(maxsize=qUtilitySz),
            "q2WebMsg": queue.Queue(maxsize=q2WebMsgSz),
            "q2ServerMsg": queue.Queue(maxsize=q2ServerMsgSz),
        }
    
    def qPut(self, qName: str, value: list=[]):
        try:
            if self.qMsg[qName].full(): self.qMsg[qName].get_nowait()
            self.qMsg[qName].put_nowait(value)
        except:
            raise Exception("Queue({}) Put Error!".format(qName))
    
    def qGetAllMsg_noWait(self, qExcept=[]):
        allMsg = {}
        for key, value in self.qMsg.items():
            if key in qExcept: continue
            allMsg[key] = [] if value.empty() else value.get_nowait()
        return allMsg

    def qGet_noWait(self, qName: str):
        try:
            # success, Msg
            return (False, []) if self.qMsg[qName].empty() else (True, self.qMsg[qName].get_nowait())
        except:
            raise Exception("Queue({}) Get Error!".format(qName))

    def qClearAll(self):
        for key in self.qMsg.keys():
            self.qMsg[key] = queue.Queue()

```