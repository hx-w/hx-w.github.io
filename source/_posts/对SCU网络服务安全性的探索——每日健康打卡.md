---
title: 对SCU网络服务安全性的第一次探索
category: SCU相关
abbrlink: a44f
date: 2021-10-12 21:39:09
---

# 对【川大疫情防控每日报系统】的探索

## 前言

本文中的数据皆由合理/合法途径获取，旨在课业之余找点乐趣，别无其他。

## API

### 百度地图API

> 这里指百度地图的逆地理编码服务，下文中的`ak`为scu提供的

#### URL

[**GET**] https://api.map.baidu.com/reverse_geocoding/v3/

#### Query Params

| 键        | 值                               | 释义                      |
| --------- | -------------------------------- | ------------------------- |
| output    | json                             | 响应数据格式              |
| coordtype | wgs84ll                          | 坐标系统                  |
| ak        | 0hYGiH3Ob5ZhV0eWzrGVXCD3bEdBCi6L | access_key，使用scu自带的 |
| location  | <经度>,<纬度>                    | 经纬度（float）           |

#### Response / Example

```json
{
    "status": 0,
    "result": {
        "location": {
            "lng": 104.0790496319792,
            "lat": 30.641844458412959
        },
        "formatted_address": "四川省成都市武侯区一环路南2段-11号-附25号",
        "business": "跳伞塔,磨子桥,科华北路",
        "addressComponent": {
            "country": "中国",
            "country_code": 0,
            "country_code_iso": "CHN",
            "country_code_iso2": "CN",
            "province": "四川省",
            "city": "成都市",
            "city_level": 2,
            "district": "武侯区",
            "town": "",
            "town_code": "",
            "adcode": "510107",
            "street": "一环路",
            "street_number": "南2段-11号-附25号",
            "direction": "附近",
            "distance": "21"
        },
        "pois": [],
        "roads": [],
        "poiRegions": [],
        "sematic_description": "",
        "cityCode": 75
    }
}
```

### 疫情填报数据提交

#### URL 

[**POST**] https://wfw.scu.edu.cn/ncov/wap/default/save

#### Data Form

> 以下表单内容仅由我个人信息得到，不一定囊括全部内容，且仅在2021-10-12与未来的一段时间内有效

| 键          | 类型   | 默认值     | 释义                                                     |
| ----------- | ------ | ---------- | -------------------------------------------------------- |
| zgfxdq      | int | "0"        | 是否在中高风险地区                                   |
| mjry        | int | "0"        | 是否接触密接人员                                     |
| csmjry      | Int | "0"        | 近14日内本人/共同居住者是否去过疫情发生场所              |
| szxqmc      | string | "" | 所在校区名称，从"江安校区"、"望江校区"与"华西校区"中选择 |
| sfjzxgym    | int | "0"        | 是否接种新冠疫苗，"0"或"1"                               |
| jzxgymrq    | string | ""         | 接种第一剂新冠疫苗日期，日期格式：%Y-%m-%d               |
| sfjzdezxgym | int | "0"        | 是否接种第二剂新冠疫苗，"0"或"1"                         |
| jzdezxgymrq | string | ""         | 接种第二剂新冠疫苗日期，日期格式：%Y-%m-%d               |
| tw          | int | "1"        | 体温范围（实际表单上的选项编号），"2"和"3"为正常     |
| sfcxtz      | int | "0"        | 是否出现发热等症状，"0"或"1"                             |
| sfyyjc | int | "0" | 是否前往医院做过检查，如果sfcxtz为"1"需填写 |
| jcjgqr | int | "0" | 检查结果，如果sfyyjc为"1"需填写。"1" => 疑似感染; "2" => 确认感染; "3" => 其他 |
| jcjg | string | "" | 检查结果详细描述 |
| sfjcbh | int | "0" | 是否接触无症状感染或疑似感染人群，"0"或"1" |
| jcbhlx | int | "0" | 接触人群类型，如果sfjcbh为"1"需填写，"1" => 疑似; "2" => 确诊 |
| jcbhrq | string | "" | 接触时间，如果sfjcbh为"1"需填写，日期格式：%Y-%m-%d |
| sfcxzysx | int | "0" | 是否有疫情相关的情况，"0"或"1" |
| qksm | string | "" | 情况说明，如果sfcxzysx为"1"需填写 |
| remark       | string      | ""     | 其他信息 |
| sfzx | int | "1" | 是否在校 |
| fxyy | string | "" | 返校原因，sfxz为"1"时填写 |
| bzxyy | string | "" | 不在校原因，sfzx为"0"时填写 |
| sfjcwhry | int | "0" | 是否接触武汉人员 |
| sfjchbry | int | "0" | 是否接触河北人员 |
| sfcyglq | int | "0" | 是否处于观察期 |
| gllx | int | "0" | 观察场所（实际表单上的选项编号），如果sfcyglq为"1"需填写 |
| glksrq | string | "0" | 观察开始时间，日期格式：%Y-%m-%d |
| ismoved | int | "0" | 所在区域是否变化 |
| bztcyy | int | "0" | 不在同一城市的原因（实际表单上的选项编号），ismoved为"1"时需填写 |
| sftjhb | int | "0" | 是否途径河北 |
| sftjwh | int | "0" | 是否途径武汉 |
| szcs | string | "" | 所在城市，例："成都市" |
| szgj | string | "" | 所在国家，例："中国" |
| city | string | "" | 所在城市，例："成都市" |
| province | string | "" | 所在省，例："四川省" |
| area | string | "" | 所在地区，例："四川省 成都市 武侯区" |
| address | string | "" | 具体所在地点，例："四川省成都市武侯区望江路街道四川大学四川大学望江校区研究生院" |
| date | string | "" | 今日日期，日期格式：%Y%m%d |
| created | int | 0 | 表单创建的时间戳 |
| uid | int | 0 | 用户唯一标识 |
| id | int | 0 | 当前表单的标识 |
| geo_api_info | json/string | "" | 地理位置的详细信息，通过百度地图API获取 |

#### Response / Example

```json
{
    "zgfxdq": "0",
    "mjry": "0",
    "csmjry": "0",
    "szxqmc": "望江校区",
    "sfjzxgym": "1",
    "jzxgymrq": "2021-xx-xx",
    "sfjzdezxgym": "1",
    "jzdezxgymrq": "2021-xx-xx",
    "tw": "2",
    "sfcxtz": "0",
    "sfjcbh": "0",
    "sfcxzysx": "0",
    "qksm": "",
    "sfyyjc": "0",
    "jcjgqr": "0",
    "remark": "",
    "address": "四川省成都市武侯区望江路街道四川大学四川大学望江校区研究生院",
    "geo_api_info": "{...}",
    "area": "四川省 成都市 武侯区",
    "province": "四川省",
    "city": "成都市",
    "sfzx": "1",
    "sfjcwhry": "0",
    "sfjchbry": "0",
    "sfcyglq": "0",
    "gllx": "",
    "glksrq": "",
    "jcbhlx": "",
    "jcbhrq": "",
    "bztcyy": "1",
    "sftjhb": "0",
    "sftjwh": "0",
    "szcs": "",
    "szgj": "",
    "bzxyy": "",
    "jcjg": "",
    "hsjcrq": "",
    "hsjcdd": "",
    "hsjcjg": "0",
    "date": "20211011",
    "uid": "2134xxx",
    "created": 1633881623,
    "jcqzrq": "",
    "sfjcqz": "",
    "szsqsfybl": 0,
    "sfsqhzjkk": 0,
    "sqhzjkkys": "",
    "sfygtjzzfj": 0,
    "gtjzzfjsj": "",
    "fxyy": "开学返校",
    "id": 4365xxxx,
    "gwszdd": "",
    "sfyqjzgc": "",
    "jrsfqzys": "",
    "jrsfqzfy": ""
}
```

## `uid`与`id`的获取

从以上表单数据可以看出，`uid`为用户的唯一标识，我已测试过多次，对于同一用户的不同次提交，该字段未有变化。

而`id`根据我的猜测，可能是指表单创建的序号，从1开始自增的编号。

该猜测还在测试中。

## 一份可用的`geo_api_info`

对于川大望江校区的学生，这里有一份整理好可用的`geo_api_info`

```json
{
    "type": "complete",
    "position": {
        "Q": 30.630839301216,
        "R": 104.079966362848,
        "lng": 104.07997,
        "lat": 30.630839
    },
    "location_type": "ip",
    "message": "Get ipLocation success.Get address success.",
    "accuracy": null,
    "isConverted": true,
    "status": 1,
    "addressComponent": {
        "citycode": "028",
        "adcode": "510107",
        "businessAreas": [
            {
                "name": "跳伞塔",
                "id": "510107",
                "location": {
                    "Q": 30.636149,
                    "R": 104.071224,
                    "lng": 104.071224,
                    "lat": 30.636149
                }
            },
            {
                "name": "小天竺",
                "id": "510107",
                "location": {
                    "Q": 30.639354,
                    "R": 104.068942,
                    "lng": 104.068942,
                    "lat": 30.639354
                }
            }
        ],
        "neighborhoodType": "科教文化服务;学校;高等院校",
        "neighborhood": "四川大学",
        "building": "",
        "buildingType": "",
        "street": "科华北路",
        "streetNumber": "194号",
        "country": "中国",
        "province": "四川省",
        "city": "成都市",
        "district": "武侯区",
        "township": "望江路街道"
    },
    "formattedAddress": "四川省成都市武侯区望江路街道四川大学四川大学望江校区研究生院",
    "roads": [],
    "crosses": [],
    "pois": [],
    "info": "SUCCESS"
}
```

需要注意的是：

- `province` = `geo_api_info.addressComponent.province`
- `city`=`geo_api_info.addressComponent.city`
- `address`=`geo_api_info.province`+ ' ' + `geo_api_info.city`+ ' ' + `geo_api_info.addressComponent.district`

## 一个猜想

对于现有的表单设计，只用了`uid`一项字段来唯一标识一名用户，而且根据我的`uid`内容，可以认为所有`uid`的内容都为较小的整形数。也就是说，也许可以暴力的遍历所有小整数，从而获取有效的`uid`。

## 自动打卡脚本示例

`cookies_str`从https://wfw.scu.edu.cn/ncov/wap/default/index获取

> 以下内容仅作参考

```python
# -*- coding: utf-8 -*-
import re
import json
import time
import datetime
import requests


# handle cookies and init session
def init_session(cookies_str: str) -> requests.Session():
    cookies_dict = {}
    for line in cookies_str.split(';'):
        key, value = line.split('=', 1)
        cookies_dict[key] = value

    session = requests.session()
    cookiesJar = requests.utils.cookiejar_from_dict(
        cookies_dict,
        cookiejar=None, 
        overwrite=True
    )
    session.cookies = cookiesJar
    return session


# get default json with uid and id
def get_default_json(session: requests.Session) -> tuple:
    url = 'https://wfw.scu.edu.cn/ncov/wap/default/index'

    resp = session.get(url=url)

    if resp.status_code != 200:
        print('[ERROR]', resp.status_code)
        exit()

    html = resp.content.decode('utf-8')

    pattern = re.compile('var def =(.*);!?')

    res = re.findall(pattern, html)
    if len(res) == 0:
        print('[ERROR] not found')
        exit()

    res_json = json.loads(res[0])
    return session, res_json


# load default geo_api_info
def modify_json(res_json: dict) -> dict:
    with open('geo_api_info.json', 'r') as ifile:
        res_json['geo_api_info'] = json.load(ifile)

    res_json['province'] = res_json['geo_api_info']['addressComponent']['province']
    res_json['city'] = res_json['geo_api_info']['addressComponent']['city']
    res_json['address'] = res_json['geo_api_info']['formattedAddress']
    res_json['area'] = ' '.join([
        res_json['province'],
        res_json['city'],
        res_json['geo_api_info']['addressComponent']['district']
    ])
    res_json['date'] = datetime.datetime.now().strftime("%Y%m%d")
    res_json['created'] = int(time.time())
    res_json['ismoved'] = 0
    return res_json


def post_json(session: requests.Session, res_json: dict):
    url = 'https://wfw.scu.edu.cn/ncov/wap/default/save'
    resp = session.post(url=url, data=res_json)
    print(resp.status_code, resp.content.decode('utf-8'))


if __name__ == '__main__':
    cookies_str = 'eai-sess=xxx; UUkey=xxx'
    session = init_session(cookies_str)
    session, res_json = get_default_json(session)
    res_json = modify_json(res_json)
    post_json(session, res_json)
```

