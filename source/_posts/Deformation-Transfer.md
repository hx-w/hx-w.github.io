---
title: Mesh Deformation Transfer
tags:
  - CG
abbrlink: '4581'
date: 2022-10-20 14:39:27
index_img: https://imgbed.scubot.com/image/20221020145054.png
---

# Deformation Transfer For Triangle Mesh

## 概述

**问题描述**

对于两个具有一定视觉相似度的三角网格：原网格 $S_0$ 和目标网格 $T_0$，根据原网格已知的变形序列 $\mathcal S=\{S_0,\,\dots,\, S_{|\mathcal S|}\}$，生成目标网格的对应的变形序列$\mathcal T=\{T_0,\, \dots, T_{|\mathcal S|}\}$。

![banner](https://imgbed.scubot.com/image/20221020144729.png)

<!--more-->

**问题假设**

1. $\mathcal S$ 和 $\mathcal T$ 中的网格分别具有相同的拓扑结构，但两个集合对应网格之间不要求。
2. $S_0$ 与 $T_0$ 应当具有一定的视觉相似度，并且相关点对通过人为标记的方式体现。

**基本思想**

1. 根据人为标定的标记点，计算由 $S_0$ 到 $T_0$ 的三角面片对应关系 $M=\{(s_0,\,t_0),\, \dots,\,(s_{\lvert M\rvert},\, t_{\lvert M\rvert})\}$。
2. 对 $S_i,\, i\in \{1,\, \dots ,\, |\mathcal S|\}$ ，由于 $S_i$ 与 $S_0$ 具有相同的拓扑，可以根据对应关系$M$，将$S_i$每个三角面的变换作用到$T_0$，加上一些约束条件，得到变形后的 $T_i$ 。

## 三角面变换

在三维空间中，对于三角面$F_i = \left[v_0,\, v_1,\, v_2\right]$ 到另一个三角面$\widetilde{F_i} =\left[\widetilde v_0,\, \widetilde v_1,\, \widetilde v_2 \right]$ 的仿射变换可以分解为线型部分$Q_i$ 和非线性部分 $\mathbf d_i$。求解该仿射变换需要用四对点到点的关系，对每个三角面引入第四个点：
$$
v_3 = v_0 +(v_1 −v_0) \times (v_2 −v_0) \big / \sqrt{|(v_1 −v_0) \times (v_2 −v_0)|}
$$

线性部分$Q_i = \widetilde V_i {V_i}^{-1}$，其中$V_i = \left[v_1 - v_0\quad v_2 - v_0 \quad v_3-v_0\right]$

## 对应关系计算

根据标定点，将 $S_0$ 在保持拓扑不变的前提下变形为 $T_0$。

根据三角面变换中的定义，将$S_0$中每个三角面的第四个点加到顶点序列之后：
$$
x = \left(\underbrace{v_0,\, v_1,\, \dots,\, v_{n-1}}_{\text{原始顶点}},\, \underbrace{v_{n},\, \dots,\, v_{n+m-1}}_{\text{新增顶点}} \right)
$$
其中$n$为$S_0$中原始顶点的个数，$m$为三角面个数，$x \in \mathbb R^{3\times (n+m)}$。

通过改动$x$，来实现$S_0$到$T_0$的变形，具体表现为定义损失函数，最小二乘法搜索最优解：
$$
\min_{\widetilde x} (w_S E_S,\, w_IE_I,\, w_CE_C) \\\text{约束标记点对中 原网格顶点与目标网格顶点相同}
$$

| 损失项                  | 表达式                                                       | 备注                                               |
| :---------------------- | :----------------------------------------------------------- | :------------------------------------------------- |
| 平滑性<br/>(smoothness) | $E_S(x) = \sum_{Q_i}{ \sum_{Q_j \in \text{adj}(Q_i)}{\lVert Q_i -Q_j\rVert_F^2}}$ | 对每一个三角面，周围三角面的形变应该尽量与之相似   |
| 不变性<br/>(identity)   | $E_I(x) = \sum_{Q_i}{\lVert Q_i - \mathbf I \rVert_F^2}$     | 每个三角面的形变尽可能小                           |
| 最近点损失              | $E_C(x;\, c_0,\,\dots,\,c_n)=\sum_i{\lVert v_i -c_i\rVert^2_F}$ | 原网格的每个顶点都应该尽可能贴近与目标网格的最近点 |

当$S_0$在保持拓扑不变的情况下变形为接近 $T_0$后，计算两个网格三角面之间的对应关系$M$。

> 对$S_0$中的每个三角面，在$T_0$中至少存在一个三角面与之存在最近关系，反之亦然。所以两个网格中三角面的对应关系为多对多，并非映射。

## 形变迁移

在有原网格与目标网格三角面的对应关系$M$, 以及原网格 初始网格$S_0$ 与形变网格$S_i$ 的每个三角面形变关系后，我们可以直接将$S_0$ 到$S_i$的形变迁移到$T_0$ 上，得到$T_i$：


$$
\min_{Q_i+\mathbf d_i} \sum_{j=0}^{ | M | -1} { \lVert \mathbf S_{s_j}- \mathbf T_{t_j}\rVert_F^2} \\
\text{约束 }
Q_j\, v_i + \mathbf {d}_j 
= Q_k \, v_i + \mathbf d_k,
\quad
\forall i,
\forall j,k
\in
\text{adj}(v_i)
$$

这里的$\mathbf S_{s_j}$表述为网格$S_i$中标号为$s_j$的三角形的变换$Q_{s_j}$，$T_{t_j}$同理。

对于实际求解，可以将上述对三角面变换的逼近转换到对顶点变换的逼近。

> 由于三角面变换逼近时，可能会出现边缘撕裂的情况，所以需要添加三角形的邻域约束。而转用顶点表达时，通过同一网格类型拓扑不变的假设，蕴含了变换后的网格不会出现边缘撕裂。

具体的顶点公式推导在后面。

## 细节推导

### 三角面变换

以上描述的优化函数大多都是用三角面的形变表示，而优化目标是顶点序列$x$，需要进行推导将三角面的形变转换为关于顶点序列 $x$ 的表达式，即。
$$
Q_i = \widetilde V_i\, {V_i}^{-1} \quad \xrightarrow[]{\text{展开顶点序列 }x} \quad Q_i= x\,\hat{V}_i^{-1}
$$
**计算展开$x$**
$$
\begin{align*}
\underset{3\times 3}{Q_i} &= \widetilde V_i\, {V_i}^{-1} \\[2ex]
	 &= \begin{bmatrix} \widetilde v_1^i - \widetilde v_0^i & \widetilde v_2^i - \widetilde v_0^i & \widetilde v_3^i - \widetilde v_0^i \end{bmatrix} \, {V_i}^{-1} \\[2ex]
	 &= \begin{bmatrix} \widetilde v_1^i & \widetilde v_2^i & \widetilde v_3^i \end{bmatrix}\, {V_i}^{-1} -
	 		\begin{bmatrix} \widetilde v_0^i & \widetilde v_0^i & \widetilde v_0^i \end{bmatrix}\, {V_i}^{-1}\\[2ex]
	 &= \begin{bmatrix} \widetilde v_0 & \widetilde v_1 & \dots & \widetilde v_{n+m-1} \end{bmatrix}
	 \begin{bmatrix}&\dots\\0 & 0 & 0\\ & \dots\\1 &0&0\\&\dots&\\0&1&0\\&\dots&\\0&0&1\\&\dots\end{bmatrix}
	 {V_i}^{-1}
	 -
	 \begin{bmatrix} \widetilde v_0 & \widetilde v_1 & \dots & \widetilde v_{n+m-1} \end{bmatrix}
	 \begin{bmatrix}&\dots\\1&1&1\\& \dots\\0&0&0\\&\dots&\\0&0&0\\&\dots&\\0&0&0\\&\dots\end{bmatrix}
	{V_i}^{-1}
	\\[2ex]
	&=\begin{bmatrix} \widetilde v_0 & \widetilde v_1 & \dots & \widetilde v_{n+m-1} \end{bmatrix}
	\begin{bmatrix}&\dots\\-1&-1&-1\\& \dots\\1&0&0\\&\dots&\\0&1&0\\&\dots&\\0&0&1\\&\dots\end{bmatrix} {V_i}^{-1} \\[2ex]
	&= x \, \hat{V}_i^{-1}
\end{align*}
$$

### 一般的目标函数

对于一般情况，期望在保持原网格拓扑不变的同时满足每个三角面的变形目标$C_i$，写作：
$$
\begin{align*}
\sum_{i=0}^{\lvert M \rvert-1}{\big\lVert Q_i -C_i\big\rVert_F^2} &= \sum_{i=0}^{\lvert M \rvert-1}{\big\lVert x\, \hat{V}_i^{-1} - C_i\big\rVert_F^2} \\[2ex]
& =\sum_{i=0}^{\lvert M \rvert-1}{
\begin{Vmatrix} \left( x\, \hat{V}_i^{-1} - C_i\right)^T \end{Vmatrix}_F^2
} \\[2ex]
&= \sum_{i=0}^{\lvert M \rvert-1}{
\begin{Vmatrix}
\left(\hat{V}_i^{-1}\right)^T\, x^T-C_i^T
\end{Vmatrix}_F^2
}
\\[2ex]
&= \begin{Vmatrix}
\begin{pmatrix}
\left(\hat{V}_0^{-1}\right)^T \\
\left(\hat{V}_1^{-1}\right)^T \\
\dots\\
\left(\hat{V}_{\lvert M \rvert-1}^{-1}\right)^T
\end{pmatrix}
\,x^T - 
\begin{pmatrix}
C_0^T \\
C_1^T \\
\dots \\
C_{\lvert M \rvert-1}^T
\end{pmatrix}
\end{Vmatrix}
_F^2 \\[2ex]
&=\begin{Vmatrix}
A\,x^T - b
\end{Vmatrix}_F^2
\end{align*}
$$
即目标函数变为 $E (x) = \begin{Vmatrix} A\, x^T - b \end{Vmatrix}_F^2$ 的形式，使用最小二乘法[^1]，得到
$$
\frac{\partial E(x)}{\partial x} = \frac{\partial {\left( x^TA^TA\,x -2b^TA\,x+b^T\,b\right)} }{\partial x} = 2A^TA\,x - 2A^T b = 0\\[2ex]
A^T A\,x = A^T b
$$

### 具体的目标函数

**平滑性损失**
$$
\begin{align*}
E_S(x)&=\sum_{Q_i}{ \sum_{Q_j \in \text{adj}(Q_i)}{\lVert Q_i -Q_j\rVert_F^2}} \\[2ex]
&=
\begin{Vmatrix}
\begin{pmatrix}
\left(\hat{V}_0^{-1} - \hat{V}_{j_0}^{-1}\right)^T \\
\left(\hat{V}_0^{-1} - \hat{V}_{j_1}^{-1}\right)^T \\
\dots \\
\left(\hat{V}_0^{-1} - \hat{V}_{j_{\lvert \text{adj}(Q_i) \rvert-1}}^{-1}\right)^T \\
\left(\hat{V}_1^{-1} - \hat{V}_{j_0}^{-1}\right)^T\\
\dots
\end{pmatrix}
\, x^T - 0
\end{Vmatrix}_F^2
=
\begin{Vmatrix}
A_S\, x^T - b_S
\end{Vmatrix}_F^2
\end{align*}
$$
其中$A_S \in \mathbb R^{3q\times {(n+m)}}$， $b_S \in \mathbb R^{3q\times 3}$，$q = \sum_i {\lvert \text{adj}(Q_i)\rvert}$。

**不变性损失**
$$
\begin{align*}
E_I(x) &= \sum_{Q_i}{\lVert Q_i - \mathbf I \rVert_F^2}\\[2ex]
&= \begin{Vmatrix}
\begin{pmatrix}
\left(\hat{V}_0^{-1}\right)^T \\
\left(\hat{V}_1^{-1}\right)^T \\
\dots\\
\left(\hat{V}_{m-1}^{-1}\right)^T
\end{pmatrix}
\,x^T - 
\begin{pmatrix}
\mathbf I \\
\mathbf I \\
\dots \\
\mathbf I
\end{pmatrix}
\end{Vmatrix}
= \begin{Vmatrix}
A_I\, x^T - b_I
\end{Vmatrix}_F^2
\end{align*}
$$
其中$A_I \in \mathbb R^{3m \times (n+m)}$，$b_I \in \mathbb R^{3m\times 3}$。

**最近点损失**
$$
\begin{align*}
E_C(x;\, c_0,\,\dots,\,c_n)&=\sum_i{\lVert v_i -c_i\rVert^2} \\[2ex]
&=\begin{Vmatrix}
\mathbf I\, x^T - \begin{pmatrix}
C_0^T \\
C_1^T \\
\dots \\
C_{m+n-1}^T
\end{pmatrix}
\end{Vmatrix}_F^2 = \begin{Vmatrix}A_C \, x^T -b_C \end{Vmatrix}_F^2
\end{align*}
$$
其中$A_C \in \mathbb R^{3m \times (n+m)}$，$b_C \in \mathbb R^{3m\times 3}$。

> 为了统一使用变量$x^T$，需要有$n+m$个点的形式，但实际上只需要计算前$n$个顶点的最近点。

**形变迁移损失**
$$
\begin{align*}
E_Q(x)&=\sum_{j=0}^{\lvert M\rvert -1} {\lVert \mathbf S_{s_j}- \mathbf T_{t_j}\rVert_F^2}\\[2ex]
&=\sum_{j=1}^{\lvert M\rvert}{
\begin{Vmatrix}
\mathbf S_{s_j}^T - {\hat{V}_{t_j}^{-1}}^T\, x^T
\end{Vmatrix}_F^2
}
\\[2ex]
&= 
\begin{Vmatrix}
-\begin{pmatrix}
\left(\hat{V}_{t_0}^{-1}\right)^T \\
\left(\hat{V}_{t_1}^{-1}\right)^T \\
\dots\\
\left(\hat{V}_{t_{\lvert M \rvert-1}}^{-1}\right)^T
\end{pmatrix}
\,
x^T
+\begin{pmatrix}
\mathbf S_{s_0}^T \\
\mathbf S_{s_1}^T \\
\dots \\
\mathbf S_{s_{\lvert M\rvert -1}}^T
\end{pmatrix}
\end{Vmatrix}_F^2\\[2ex]
&= \begin{Vmatrix}
A_Q\, x^T - b_Q
\end{Vmatrix}_F^2
\end{align*}
$$
其中$A_Q \in \mathbb R^{3\vert M\rvert \times (n+m)}$，$b_Q \in \mathbb R^{3\vert M\rvert \times 3}$，$\lvert M \rvert$是对应关系中元素的个数，满足$\lvert M\rvert \ge m$。

## 实验

### 注意事项

**对应关系求解: 标记点约束**

在求解$\min_x E_S$、$\min_xE_I$和$\min_x E_Q$时，需要约束$S_0$和$T_0$对应的标记点相同：
$$
\begin{align*}
A^T\,A\, x^T &= A^T\, b\\[2ex]
({A^u})^T\,A^u\, \left(x^u\right)^T + ({A^m})^T\, A^m\, \left(\widetilde{x}^m\right)^T &= A^T\, b\\[2ex]
({A^u})^T\,A^u\, \left(x^u\right)^T &= A^T\,b - ({A^m})^T\,A^m\, \left(\widetilde{x}^m\right)^T
\end{align*}
$$
对于$S_0$，$A^u$、$x^u$分别为未标记点的系数矩阵以及顶点序列，$A^m$、$x^m$为已标记点的系数矩阵以及顶点序列，$\widetilde{x}^m$为$T_0$中已标记点的顶点序列。

再求解出$x^u$后再根据约束条件$x^m = \widetilde{x}^m$ 计算出结果 $\widetilde{x}$。

**对应关系求解: 目标函数组合与迭代**

对应关系计算时，可以将相关目标函数写在一起：
$$
\widetilde{x} = \underset{x}{\arg \min}
\begin{Vmatrix}
\begin{pmatrix}
w_SA_S \\
w_IA_I\\
w_CA_C
\end{pmatrix}
\,
x^T - 
\begin{pmatrix}
w_S b_S\\
w_I b_I\\
w_C b_C
\end{pmatrix}
\end{Vmatrix}_F^2
$$
其中$w_S=1.0$，$w_I=0.001$，$w_C=[0,\,1\, \dots,\, 5000]$。

**稀疏线性方程组求解[^2]**

1. 直接求解
   - LU分解：$Ax=b \Longrightarrow LUx = b$
   - Cholesky分解[^3]：$Ax = b \Longrightarrow L^TLx=b$
2. 间接求解
   - Jacobi method / Gauss-Seidel method

**优化**

1. 稀疏矩阵的计算：乘法、转置、切片、拼接和索引。
2. 稀疏方程组求解。
3. 计算$E_C$时，最近点的计算。
4. 计算对应关系$M$时，最近三角面重心以及法线夹角的计算。

### 计算流程

计算形变迁移，本质上在优化四个目标函数：$E_S$、$E_I$、$E_C$和$E_Q$。其中系数矩阵几乎都包含$\hat{V}^{-1}$的计算。



[^1]: https://eeweb.engineering.nyu.edu/iselesni/lecture_notes/least_squares/least_squares_SP.pdf
[^2]: https://zhuanlan.zhihu.com/p/479913328
[^3]: https://zhuanlan.zhihu.com/p/112091443

