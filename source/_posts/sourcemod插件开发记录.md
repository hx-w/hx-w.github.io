---
title: sourcemod插件开发记录
tags:
  - CSGO
  - sourcemod
category: 教程
index_img: 'https://imgbed.scubot.com/sourcemod.jpg'
abbrlink: 14fd
date: 2020-11-23 23:04:29
---

## 概述

sourcemod是基于source引擎的插件系统，广泛用于l4d2，csgo等使用source引擎的游戏中，可以用来处理游戏事件和玩家的行为等。

sourcemod采用sourcepawn编写，sourcepawn是一种轻量级编译语言，编译器由[sourcemod官方下载页面](https://www.sourcemod.net/downloads.php?branch=stable)给出，包含linux/windows/macos全平台版本。

sourcepawn的语法类似于c/c++与java的融合，也有部分独特的关键字，不过需要注意的是sourcepawn是一种标准的面向过程的语言，对结构体的支持并不完善，sourcemod提供了source引擎的多种事件和api用于方便插件的编写。

<!--more-->

## 技巧总结

关于更详细的插件编写教程可以参考[sourcemod官网](https://www.sourcemod.net/)或[b站教学](https://www.bilibili.com/video/BV1Pb411E7W6)，这里只总结一些我在开发过程中用到的一些技巧以及值得注意的事情。

### 热插拔

理论上，sourcemod的`sm plugins load <plugin>`和`sm plugins unload <plugin>`指令可以在游戏内(控制台)加载/卸载某个插件，但我在实践中并不能有效果，大部分情况下需要**重启服务器**或**更换地图**才能刷新插件列表，可能是sourcemod的bug也可能是我有些地方没有配置好。

### menu菜单逻辑

sourcemod可以实现在游戏中加载菜单，玩家可以通过数字键去选中菜单中的某一项进入下一步操作。**menu本身就是一个FSM有限状态机**，插件中menu对每个玩家的状态都有记录并保持其逻辑的正确性，接下来我简要说明编写menu需要注意的地方。

#### 创建menu

menu的创建需要一个handle用来保存菜单实例，通过sourcemod提供的`CreateMenu(MenuCallBack)`进行创建，返回值即为handle，`MenuCallBack`为回调函数，用来处理玩家选中菜单中某项需要执行的逻辑。

需要注意的是menu所列的选项大部分可以通过`AddMenuItem(handle, <id>, <message>)`来被开发者自定义，还有三种选项是menu自带的，可以通过这样来设置：

1. `SetMenuPagination(handle, <int>)`设置菜单中翻页按钮的位置
2. `SetMenuExitButton(handle, <bool>)`设置是否开启菜单的退出按钮
3. `SetMenuExitBackButton(handle, <bool>)`设置是否开启菜单的返回上一级父菜单按钮(需要再回调函数中额外处理)

最后设置完可以使用`DisplayMenu(handle, client, MENU_TIME_FOREVER)`将菜单显示(永久)。

#### 回调函数MenuCallBack

menu回调函数定义为`public MenuCallBack(Handle:menuhandle, MenuAction:action, client, Position)`，其中函数名字可以自定义，与创建menu时注册的回调函数保持一致即可。其中四个参数：

1. `Handle:menuhandle`为创建menu时的handle，可以理解为menu的实例
2. `MenuAction:action`中action是枚举类的实例，记录了玩家触发菜单回调函数所执行的操作种类
3. `client`玩家索引
4. `Position`玩家触发菜单中的选项位置

需要注意的是，如果设置了返回上一级父菜单的按钮，需要在回调函数中判断`Position`是否为`-6`，如果是，则表示选中了返回父菜单，即可执行重建父菜单的逻辑。

默认情况下用户选中某个菜单按钮之后菜单执行完任务就会消失，就算设置了`MENU_TIME_FOREVER`也是这样，如果需要用户选择完菜单仍保持显示，则需要在`action==MenuAction_Select`条件下设置`DisplayMenuAtItem(menuhandle, client, GetMenuSelectionPosition(), MENU_TIME_FOREVER)`来实现。

例：(hltv.sp中的某个菜单回调函数)

```java
public ResultMenuCallBack(Handle:menuhandle, MenuAction:action, client, Position) {
    if (action == MenuAction_Select) {
        decl String:Item[STRLENGTH];
        GetMenuItem(menuhandle, Position, Item, sizeof(Item));
        int idx = StringToInt(Item);
        queryProRecord(client, idx);

        DisplayMenuAtItem(menuhandle, client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
    }
    if (Position == -6) {
        setMainMenu(client);
    }
}
```

### Http/Https请求实现

sourcemod社区里有对应的扩展：[System2](https://forums.alliedmods.net/showthread.php?t=146019)，按要求配置好环境即可在sourcemod中使用网络请求的功能。

我比较常用的是http的GET和POST方法，GET一半用于获取网络api的数据到插件本地，POST一般用于将插件本地的数据发送到网站api，不过本质上两种方法没有严格的区分，习惯而已。

#### GET

按照教程通过`new System2HTTPRequest(HttpCallBack, <str: url>, <param1>, <param2> ...)`，因为GET请求中可以将请求的内容直接体现在url里，所以可以直接在url里使用占位符，在其后补上对应的变量，数量不固定。

#### POST

与GET相同，只不过在新建请求实例的时候只有两个参数，url是固定的值不带变量，需要额外通过`httpRequest.SetData("param1=%s&param2=%s", param1, param2)`来设置变量，参数用**&**分隔。

#### 额外数据

通常情况下，插件发送网络请求都与某个玩家的操作有关，所以需要在新建请求的时候记录玩家的id，可以通过`httpRequest.Any = client`记录到请求中，在回调函数里通过`int client = request.Any`即可获取之前保存的内容。

#### Json数据解析

sourcemod有一个很好用的json解析库，需要手动添加：[sm-json](https://github.com/clugg/sm-json)，文档里很详细的说明了sourcemod里json的用法，很适合解析和保存网络请求拿到的数据。

## 我的开发

前段时间在为[CSGOWiki](www.csgowiki.top)开发一些服务器插件，其中大部分我已经公开到[我的仓库](https://github.com/hx-w/CSGOWiki-Plugins)中了，欢迎指教。

## 一些有用的链接

- sourcemod社区：https://forums.alliedmods.net/index.php
- sourcemod官网：https://www.sourcemod.net/
- sourcemod Api文档：https://sm.alliedmods.net/new-api/