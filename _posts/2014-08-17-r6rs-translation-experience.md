---
layout: post
title: "R6RS翻译笔记"
description: ""
category: 
tags: []
---
{% include JB/setup %}

本文记载了任何与[R6RS](/)有关的东西。

# 目录 <!-- CONTENTS -->

* 这回生成一个目录，且这行文字会被忽略
{:toc}

# 名词解释

## 对称的（symmetric），自反的（reflexive），且传递的（transitive）

谓词P，对任意属于P的作用域的x1，x2，x3：

* 如果`(P x1 x2)`为真可以推导出`(P x2 x1)`为真，那么P具有对称性。
* 如果`(P x1 x1)`为真，那么P具有自反性。
* 如果`(P x1 x2)`、`(P x2 x3)`都为真可以推导出`(P x1 x3)`为真，那么P具有传递性。

同时满足以上三种性质的谓词在Scheme中用于模拟数学上的等价关系（见第11.5小节）。

Scheme要求`=`，`>`，`<`，`<=`和`>=`等谓词具有传递性（见第11.7.4.3小节）。

## 幂等（idempotent）

在11.7.4.2小节中说“`inexact`和`exact`过程是幂等的”。一个过程幂等的意思是这个过程对参数作用一次的结果和作用多次的结果是一样的。即对所有的`x`：

~~~ scheme
(inexact (inexact x)) = (inexact x)
(exact (exact x)) = (exact x)
~~~

上面的等式中，令`x = (inexact x)`，`x = (inexact (inexact x))`，……，可以无穷地推广。


