---
title: CYK算法实现
tags:
  - 算法
  - Python
abbrlink: '7120'
math: true
date: 2019-04-28 19:26:15
---

## 概述

在计算机科学领域，CYK算法（也称为Cocke–Younger–Kasami算法）是一种用来对上下文无关文法（CFG，Context Free Grammar）进行语法分析（parsing）的算法。该算法最早由John Cocke, Daniel Younger and Tadao Kasami分别独立提出，其中John Cocke还是1987年度的图灵奖得主。CYK算法是基于动态规划思想设计的一种自底向上语法分析算法。

<!--more-->

## 乔姆斯基范式

CNF(Chomsky Normal Form)是一种这样的语法标准：
如果一个CFG $\epsilon-free$，而且它的规则只有如下两种形式:

- $A \rightarrow B C$
- $A \rightarrow a$

那么这个CFG就是CNF形式的，可见CNF语法都是二分叉的。任何语法都可以转化成一个弱等价的CNF形式，具体方法如下：

- Step 1: Convert $A \rightarrow Bc$ to $A\rightarrow BC, C\rightarrow c$
- Step 2: Convert $A \rightarrow BCD$ to $A \rightarrow BX, X \rightarrow CD$

## CYK算法

CYK算法处理的语法必须是CNF形式的，所以如果输入的是任意文法，那么需要按照前面的步骤把CFG转换成CNF形式。

CYK算法是用来判断一个字符串是否属于某个CNF语法，故设输入的字符串w长度为n。

接下来我们需要用程序填一个动态规划的状态转移表，这里我们叫这个表parse table。

parse table的规模为$(n + 1) \times n$

我们定义$PT[n + 1][n]$表示parse table，且$PT[n, :]$依次存储字符串w中的每一个符号($a_1, a_2, \dots, a_n$)。

$$
\begin{pmatrix}
&   &\dots & \\
& \vdots &  \ddots & \\
a_1 & a_2 & \dots &a_n
\end{pmatrix}
$$


我们设根据给定CNF，即G能推导出w中第i到第j个字符的串的集合为$x_{i,j}$。

为了填写这个表，我们一行一行，自下而上地处理。每一行对应一种长度的子串。最下面一行对应长度为1的子串，倒数第二行对应长度为2的子串，以此类推。最上面一行就对应长度为n的子串，即w本身。计算该表的任何一个表项的方法如下： 

1. 对于最下面一行的元素，即$x_{i,i}$，是使得$A \rightarrow a_i$是G的产生式的变元A的**集合**。
2. 对于不在最下面一行的元素，我们需要找到符合以下条件的变元A的集合：
   1. 整数k满足$i \leq k < j$
   2. $B \in X_{i,k}$
   3. $C \in X_{k+1, j}$
   4. $A \rightarrow BC$是G的产生式

根据这样的方法，我们可以填出一个下三角矩阵。

例如：

CNF文法G的产生式：


$$
S \rightarrow AB|BC \\
A \rightarrow BA|a \\
B \rightarrow CC|b \\
C \rightarrow AB|a
$$
对L(G)测试字符串$w = baaba$的成员性构造Parse Table如下：


$$
\begin{pmatrix}
x_{1,5}=\{S, A,C\} & & & & \\
& x_{2,5}=\{S, A, C\} & & & \\
& x_{2,4}=\{B\} & x_{3,5}=\{B\} & & \\
x_{1,2} = \{S, A\} & x_{2,3}=\{B\} & x_{3,4}=\{S, C\} & x_{4,5}=\{S, A\} &\\
x_{1,1} = \{B\} & x_{2,2} = \{A, C\} & x_{3,3} =\{A, C\} & x_{4,4}=\{B \} & x_{5,5}=\{A,C\} \\
a_1 = b & a_2 = a & a_3 = a & a_4 = b & a_5 = a
\end{pmatrix}
$$



最终得到$x_{1,5}$集合之后，判断起始变元$S$是否属于$x_{1,5}$。如果是，则w可被G接受，反之不接受。

## 程序展示

> CNF.cfg

```
S -> AB
A -> BC | a
B -> AC | b 
C -> a | b 
```



> CYK_algo.py

```python
#!usr/bin/env/python 3.6.5
#-*- coding: utf-8 -*-
'''
Python 3.6.5
installed module:
    - tkinter
'''

import re
import itertools
import tkinter
from tkinter import ttk


class CNF(object):
    def __init__(self):
        self.__rules = {}


    def read_file(self, filename):
        with open(filename, 'r') as inFile:
            for line in inFile.readlines():
                line = re.sub('[\n\t ]', '', line)
                rec_begin = line[:line.find('-')]
                for element in line[line.find('>') + 1:].split('|'):
                    if element in self._CNF__rules:
                        self.__rules[element].append(rec_begin)
                    else:
                        self._CNF__rules[element] = [rec_begin]


    def get_inf(self, tar):
        if isinstance(tar, list) == False: exit()
        inf_set = []
        for tarEle in tar:
            inf_set.extend(self.__rules.get(tarEle, []))
        return list(set(inf_set))


class CYK(object):
    def __init__(self, filename):
        if isinstance(filename, str) == False: exit()
        self.__str = ''
        self.__srtlen = 0
        self.__canvas = [] 
        self.__myCNF = CNF() 
        self.__myCNF.read_file(filename) 

        
    def get_str(self):
        self._CYK__str = input('input string:\n').strip() 
        if len(self._CYK__str) == 0: exit()
        self._CYK__srtlen = len(self._CYK__str)
        # MaxRow == MaxCol + 1 
        self._CYK__canvas = list(list([] for tmp in range(self._CYK__srtlen)) for tmp in range(self._CYK__srtlen + 1))
        for iter in range(self._CYK__srtlen):
            self._CYK__canvas[self._CYK__srtlen][iter].append(self._CYK__str[iter])
    

    def CYK_process(self):
        # for lowest level
        for col in range(self._CYK__srtlen):
            self._CYK__canvas[self._CYK__srtlen - 1][col].extend(self._CYK__myCNF.get_inf(self._CYK__canvas[self._CYK__srtlen][col]))
        # for upper level
        for row in range(self._CYK__srtlen - 2, -1, -1):
            for col in range(row + 1):
                mid_set = set()
                idx_i, idx_j = col + 1, col - row + self._CYK__srtlen               
                for mid_k in range(idx_i, idx_j):
                    fir_row, fir_col = idx_i - mid_k - 1 + self._CYK__srtlen, idx_i - 1
                    sec_row, sec_col = mid_k - idx_j + self._CYK__srtlen, mid_k
                    mid_set |= set(obj[0] + obj[1] for obj in itertools.product(self._CYK__canvas[fir_row][fir_col], self._CYK__canvas[sec_row][sec_col]))
                self._CYK__canvas[row][col].extend(self._CYK__myCNF.get_inf(list(mid_set)))
        # get answer
        if 'S' in self._CYK__canvas[0][0]:
            print ('%s can be accepted.' % self._CYK__str)
        else:
            print ('%s can not be accepted.' % self._CYK__str)
    

    def GUI_show(self):
        def exc(line, step, row):
            if isinstance(line, list) == False and isinstance(line[0], list) == False: exit()
            for col in range(len(line)):
                line[col] = str('{' + '%s, ' * (len(line[col]) - 1) + '%s' * (len(line[col]) > 0) + '}') % (tuple(line[col]))
                if col <= row: line[col] = 'X%d,%d = ' % (col + 1, step + col + 1) + line[col]
            return (line)

        # default
        window = tkinter.Tk()
        window.geometry('800x400')
        window.title('CYK algorithm')
        table = ttk.Treeview(window, height = 10, show = 'headings')
        table['columns'] = (list(elem for elem in range(self._CYK__srtlen)))
        for col in range(self._CYK__srtlen):
            table.column(str(col), width = 100)
        # y&x scrollbar
        yscrollbar = tkinter.Scrollbar(window, orient = tkinter.VERTICAL, command = table.yview)
        table.configure(yscrollcommand = yscrollbar.set)
        yscrollbar.pack(side = tkinter.RIGHT, fill = tkinter.Y)

        xscrollbar = tkinter.Scrollbar(window, orient = tkinter.HORIZONTAL, command = table.xview)
        table.configure(xscrollcommand = xscrollbar.set)
        xscrollbar.pack(side = tkinter.TOP, fill = tkinter.X)
        # insert information
        for row in range(self._CYK__srtlen):
            table.insert('', row, values = exc(self._CYK__canvas[row], self._CYK__srtlen - row - 1, row))
        table.insert('', self._CYK__srtlen, values = (self._CYK__canvas[self._CYK__srtlen]))

        # end
        table.pack(side = tkinter.TOP, expand = 1, fill = tkinter.BOTH)
        window.mainloop()


def main():
    myCYK = CYK('./CNF.cfg')
    myCYK.get_str()
    myCYK.CYK_process()
    myCYK.GUI_show()


if __name__ == '__main__':
    main()

```

实验效果：

![commandline](https://ibed.csgowiki.top/CYK-CYK_1.png)

![GUI](https://ibed.csgowiki.top/CYK-CYK_2.png)
