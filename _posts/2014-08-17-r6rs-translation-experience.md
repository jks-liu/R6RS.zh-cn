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

## 幂等（idempotent）

在11.7.4.2小节中说“`inexact`和`exact`过程是幂等的”。一个过程幂等的意思是这个过程对参数作用一次的结果和作用多次的结果是一样的。即对所有的`x`：

~~~ scheme
(inexact (inexact x)) = (inexact x)
(exact (exact x)) = (exact x)
~~~

上面的等式中，令`x = (inexact x)`，`x = (inexact (inexact x))`，……，可以无穷地推广。


