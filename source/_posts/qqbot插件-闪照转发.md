---
title: qqbot插件-闪照转发
tags:
  - qqbot
category: 教程
abbrlink: 51135
date: 2021-04-06 22:50:50
---

{% note primary %}
该QQ机器人使用<a href="https://github.com/Mrs4s/go-cqhttp">go-cqhttp</a>和<a href="https://github.com/nonebot/nonebot">nonebot</a>框架。
{% endnote %}

利用改框架，可以实现破解闪照并转发到指定qq号的功能

<!--more-->

## 原理

qq的特殊消息都可以表示为CQ码(纪念原来的酷Q)，CQ码文档可以参考[go-cqhttp文档](https://docs.go-cqhttp.org/guide/achieve.html)。

我们需要的闪照的CQ码是这样的格式：
```
[CQ:image,type=flash,file=xxxx.image]
```
去掉`type=flash,`即可表示为正常的图片。

所以反闪照插件的功能思路就是：

1. 利用正则表达式：`\[CQ:image,type=flash,file=.*?\]`捕获Bot接收到的所有闪照CQ码
2. 解析出发送者，所在群号以及CQ码的全部信息
3. 将CQ码中的`type=flash,`去掉，再私聊转发给预设的qq号即可

{% note danger %}

`NoneBot2`中提供了`on_regex`装饰器，可以直接正则监视所有满足条件的消息，

而NoneBot1并未提供类似`on_regex`的正则匹配装饰器，所以需要用`on_message`监听所有消息，再对消息进行正则过滤。

为了减少计算压力，只监听群聊中的消息即可。
{% endnote %}


## 源码

```python
import re
from nonebot import get_bot

target_user = 765892480

pattens = re.compile(r"\[CQ:image,type=flash,file=.*?\]")

bot = get_bot()

@bot.on_message("group")
async def AntiFlashImage(event):
    raw_info = (await bot.get_msg(message_id=event.message_id))
    raw_message = raw_info["raw_message"]
    if re.match(pattens, raw_message):
        image_ = raw_message.replace('type=flash,', '')
        new_message = (
            f"在群({raw_info['group_id']})中捕获闪照\n"
            f"发送者：{raw_info['sender']['nickname']}({raw_info['sender']['user_id']})\n"
            f"{image_}"
        )
        await bot.send_private_msg(user_id=target_user, message=new_message)

```

## 效果图

> 群聊发送闪图

![](https://imgbed.scubot.com/1617721464951.png)

> Bot私聊转发原图

![](https://imgbed.scubot.com/1617721489042.png)
