---
title: CSGO-RealTimeMap开发记录
date: 2020-12-05 21:53:25
tags:
	- CSGO
	- sourcemod
---

## 介绍

CSGO-RealTimeMap是一个致力于将CSGO服务器内的信息实时显示到网页上的一个无数据库项目，灵感来源自Minecraft的插件dynmap。

插件分为两部分：游戏服务器的sourcemod插件和服务器本地的网站。

项目开源地址：[GitHub](https://github.com/hx-w/CSGO-RealTimeMap)。

开发日期：2020-12-3至今。

<!--more-->

### 技术栈

- **flask** 做网页显示。
- **websocket** 实现前端与数据的同步。

- **sourcemod** 实现游戏内数据向网站的同步。

最初版演示见[B站视频](https://www.bilibili.com/video/BV1mt4y1a7YG/)。

## 功能目标

- [ ] 易于部署&维护的插件/网站结构
- [ ] 网页上平滑的玩家移动
- [ ] 丰富的图标显示：玩家朝向、所持武器、所属阵营等
- [ ] 详细的服务器内信息：玩家在线时间、击杀情况等
- [ ] 在线聊天系统

## 开发记录

#### 2020-12-5

**feature**

1. 更新了道具效果的显示：

   ![示例1](/img/RTM/1.png)

2. 更多的关键帧，现在关键帧增加到了10，网页上人物移动的显示效果更加流畅

**bug**

1. 内存不释放，怀疑是道具的记录引起的
2. 程序运行日志未删除