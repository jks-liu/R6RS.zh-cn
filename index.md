---
layout: page
title: 算法语言Scheme修订<sup>6</sup>报告
tagline: 简体中文
---

<center><font size="4">M</font>ICHAEL <font size="4">S</font>PERBER</center>  
<center><font size="4">R. K</font>ENT <font size="4">D</font>YBVIG, <font size="4">M</font>ATTHEW <font size="4">F</font>LATT, <font size="4">A</font>NTON <font size="4">V</font>AN <font size="4">S</font>TRAATEN</center>  
<center>(编辑)</center>  
<center><font size="4">R</font>ICHARD <font size="4">K</font>ELSEY, <font size="4">W</font>ILLIAM <font size="4">C</font>LINGER, <font size="4">J</font>ONATHAN <font size="4">R</font>EES</center>  
<center>(编辑, 算法语言Scheme修订<sup>5</sup>报告)</center>  
<center><font size="4">R</font>OBERT <font size="4">B</font>RUCE <font size="4">F</font>INDLER, <font size="4">J</font>ACOB <font size="4">M</font>ATTHEWS</center>  
<center>(编辑, 形式语义)</center>  
**<center>2007年09月26日</center>**

[<center>在GitHub联系译者</center>](https://github.com/jks-liu/R6RS.zh-cn)
<center>已完成18%，最后修改于2014年07月24日</center>

# 摘要
报告给出了程序设计语言Scheme的定义性描述。Scheme是由Guy Lewis Steele Jr.和Gerald Jay Sussman设计的具有静态作用域和严格尾递归特性的Lisp程序设计语言的方言。它的设计目的是以异常清晰，语义简明和较少表达方式的方法来组合表达式。包括函数（functional）式，命令（imperative）式和消息传递（message passing）式风格在内的绝大多数程序设计模式都可以用Scheme方便地表述。

和本报告一起的还有一个描述标准库的报告[^24]；用描述符“库的第多少小节（library section）”或“库的第多少章（library chapter）”来识别此文档的引用。和它一起的还有一个包含非规范性附录的报告[^22]。第四次报告在语言和库的许多方面阐述了历史背景和基本原理[^23]。

上面列到的人不是这篇报告文字的唯一作者。多年来，下面这些人也参与到Scheme语言设计的讨论中，我们也将他们列为之前报告的作者：

Hal Abelson, Norman Adams, David Bartley, Gary Brooks, William Clinger, R. Kent Dybvig, Daniel Friedman, Robert Halstead, Chris Hanson, Christopher Haynes, Eugene Kohlbecker, Don Oxley, Kent Pitman, Jonathan Rees, Guillermo Rozas, Guy L. Steele Jr., Gerald Jay Sussman和Mitchell Wand。

为了突出最近的贡献，他们没有被列为本篇报告的作者。然而，他们的贡献和服务应被确认。

我们认为这篇报告属于整个Scheme社区，并且我们授权任何人复制它的全部或部分。我们尤其鼓励Scheme的实现者使用本报告作为手册或其它文档的起点，必要时也可以对它进行修改。

# 目录
* 这回生成一个目录，且这行文字会被忽略
{:toc}

# 概述
程序设计语言的设计不应该是特征的堆砌，而应消除那些需要依赖于多余特征的弱点和局限。Scheme语言证明，极少的表达式构造规则和不加限制的表达式复合方式可以构造出实用而高效的程序设计语言，其灵活性足以支持今天的大部分主流编程模型。

Scheme是最早的像在lambda演算里一样提供了第一级过程的程序设计语言之一，并由此在动态类型的语言中提供了有用的静态作用域规则和块结构的特征。在Lisp的主要方言中，Scheme第一次使过程有别于lambda表达式和符号，为所有变量使用单一的词法环境，在确定运算符的位置时采用与确定运算对象位置一样的方式。Scheme完全依赖过程调用来表示迭代，并以此强调，尾递归过程调用在本质上就是传递参数的goto。Scheme是第一种被广泛使用的，采纳第一级逃逸过程（escape procedure）的程序设计语言，通过第一级逃逸过程可以合成所有已知的顺序控制结构。Scheme的后续版本引入了精确和非精确数的概念，这是CommonLisp语言通用算术功能的扩展。最近，Scheme成为了第一种支持卫生宏（hygienic macro）的程序设计语言，该机制允许我们以一种一致和可靠的方式扩展块结构语言的语法。

**<font size="4">指导原则</font>**

为帮助指导标准化的工作，编辑采纳了如下的一系列原则。正如《算法语言Scheme修订<sup>5</sup>报告》[^14]定义的Scheme语言，本报告描述的语言致力于：

* 允许程序员互相阅读别人的代码，允许能被任何符合标准的Scheme实现执行的可移植程序的开发；
* 得益于它简单的力量，只有少量有用的核心形式和过程，并且在它们如何组合方面没有不必要的限制；
* 允许程序定义新的过程和新的语法形式；
* 支持以数据的形式呈现程序源代码；
* 使过程调用足够强大以表达任意形式的顺序控制，也允许在不使用全局程序变换的情况下执行非本地控制操作；
* 允许有趣的纯函数式程序无限期运行而不被中断且在有限内存的机器上不会内存不足；
* 允许教育工作者在各个层次用各种教育方法使用本语言去有效地进行编程教学；并
* 允许研究工作者使用这门语言去探索编程语言的设计，实现和语义。

此外，本报告致力于：

* 允许程序员创建和分发大量的程序和库，比如：Scheme要求的在不修改的情况下在各个Scheme实现中运行的实现；
* 通过任意作用域的过程和卫生宏以及允许程序定义卫生弯曲（hygiene-bending）和卫生破坏（hygiene-breaking）的语法抽象和新的独特的数据类型来更全面地支持程序，语法和数据抽象；
* 允许程序员在一定程度上依赖足够确保类型安全的自动的运行时类型和边界检查；且
* 允许实现在不要求程序员使用实现定义的运算符和声明的情况下生成高效的代码。

尽管在《算法语言Scheme修订<sup>5</sup>报告》表述的Scheme中编写可移植的程序是可能的，且在这篇报告之前也确实有可移植的程序被写出，但是许多Scheme程序是不可移植的，这主要是因为标准库的缺乏和繁多的实现定义的语言扩展。

通常，Scheme应当包含编写各种库程序的积木，包括常用的用户层的特性以提高库和用户程序的可移植性（portability）和可读性（readability），排除不常用且可以在单独库中轻松实现的特性。

本报告描述的语言同样致力于在不违背上述原则和语言未来发展的情况下尽可能与用《算法语言Scheme修订<sup>5</sup>报告》表述的Scheme编写的程序反向兼容。

**<font size="4">致谢</font>**

许多人对本版本的报告做出了有意义的贡献。我们尤其感谢Aziz Ghuloum和André van Tonder贡献的库系统的参考实现。我们感谢Alan Bawden, John Cowan, Sebastian Egner, Aubrey Jaffer, Shiro Kawai, Bradley Lucier和André van Tonder在语言设计上的洞察力。Marc Feeley, Martin Gasbichler, Aubrey Jaffer, Lars T Hansen, Richard Kelsey, Olin Shivers和André van Tonder编写了用于本报告文本直接录入的SRFIs。Marcus Crestani, David Frese, Aziz Ghuloum, Arthur A. Gleckler, Eric Knauel, Jonathan Rees和André van Tonder细致彻底地校对了本报告的早期版本。

我们同样感谢下面这些人对本报告的帮助： Lauri Alanko, Eli Barzilay, Alan Bawden, Brian C. Barnes, Per Bothner, Trent Buck, Thomas Bushnell, Taylor Campbell, Ludovic Courtès, Pascal Costanza, John Cowan, Ray Dillinger, Jed Davis, J.A. “Biep” Durieux, Carl Eastlund, Sebastian Egner, Tom Emerson, Marc Feeley, Matthias Felleisen, Andy Freeman, Ken Friedenbach, Martin Gasbichler, Arthur A. Gleckler, Aziz Ghuloum, Dave Gurnell, Lars T Hansen, Ben Harris, Sven Hartrumpf, Dave Herman, Nils M. Holm, Stanislav Ievlev, James Jackson, Aubrey Jaffer, Shiro Kawai, Alexander Kjeldaas, Eric Knauel, Michael Lenaghan, Felix Klock, Donovan Kolbly, Marcin Kowalczyk, Thomas Lord, Bradley Lucier, Paulo J. Matos, Dan Muresan, Ryan Newton, Jason Orendorff, Erich Rast, Jeff Read, Jonathan Rees, Jorgen Schäfer, Paul Schlie, Manuel Serrano, Olin Shivers, Jonathan Shapiro, Jens Axel Søgaard, Jay Sulzberger, Pinku Surana, Mikael Tillenius, Sam Tobin-Hochstadt, David Van Horn, André van Tonder, Reinder Verlinde, Alan Watson, Andrew Wilcox, Jon Wilson, Lynn Winebarger, Keith Wright和Chongkai Zhu。

我们同样感谢下面这些人对本报告以前版本的帮助： Alan Bawden, Michael Blair, George Carrette, Andy Cromarty, Pavel Curtis, Jeff Dalton, Olivier Danvy, Ken Dickey, Bruce Duba, Marc Feeley, Andy Freeman, Richard Gabriel, Yekta Gürsel, Ken Haase, Robert Hieb, Paul Hudak, Morry Katz, Chris Lindblad, Mark Meyer, Jim Miller, Jim Philbin, John Ramsdell, Mike Shaff, Jonathan Shapiro, Julie Sussman, Perry Wagle, Daniel Weise, Henry Wu和Ozan Yigit。

我们感谢Carol Fessenden, Daniel Friedman和Christopher Haynes，他们允许我们使用Scheme 311第4版参考手册的内容。我们感谢德州仪器公司（Texas Instruments, Inc.）允许我们使用《TI Scheme语言参考手册》（*TI Scheme Language Reference Manual*）[^26]的内容。我们衷心感谢MIT Scheme[^20], T[^21], Scheme 84[^12], Common Lisp[^25], Chez Scheme[^8], PLT Scheme[^11]和Algol 60[^1]的手册对本报告的影响。

我们也感谢Betty Dexter，她在将本报告设为\\\(\\TeX\\\)格式的工作中做出了杰出的贡献；感谢高德纳（Donald Knuth），他设计的程序给Betty添了不少麻烦。

The Artificial Intelligence Laboratory of the Massachusetts Institute of Technology, the Computer Science Department of Indiana University, the Computer and Information Sciences Department of the University of Oregon和the NEC Research Institute支持了本报告的预备工作。The Advanced Research Projects Agency of the Department of Defense根据Office of Naval Research的N00014-80-C-0505号合同为MIT的工作提供了部分支持。NSF的NCS 83-04567和NCS 83-03325号基金为Indiana University的工作提供了支持。

# **语言描述**

# 1. Scheme概论
本章概述了Scheme的语义。此概述的目的在于充分解释语言的基本概念，以帮助理解本报告的后面的章节，这些章节以参考手册的形式被组织起来。因此，本概述不是本语言的完整介绍，在某些方面也不够精确和规范。

像Algol语言一样，Scheme是一种静态作用域的程序设计语言。对变量的每一次使用都对应于该变量在词法上的一个明显的绑定。

Scheme中采用的是隐式类型而非显式类型[^28]。类型与对象（也称值）相关联，而非与变量相关联。（一些作者将隐式类型的语言称为弱类型或动态类型的语言。）其它采用隐式类型的语言有Python, Ruby, Smalltalk和Lisp的其他方言。采用显式类型的语言（有时被称为强类型或静态类型的语言）包括Algol 60, C, C#, Java, Haskell和ML。

在Scheme计算过程中创建的所有对象，包括过程和继续（continuation），都拥有无限的生存期（extent）。Scheme对象从不被销毁。Scheme的实现（通常！）不会耗尽空间的原因是，如果它们能证明某个对象无论如何都不会与未来的任何计算发生关联，它们就可以回收该对象占据的空间。其他允许多数对象拥有无限生存期的语言包括C#, Java, Haskell, 大部分Lisp方言, ML, Python, Ruby和Smalltalk。

Scheme的实现必须支持严格尾递归。这一机制允许迭代计算在常量空间内执行，即便该迭代计算在语法上是用递归过程描述的。借助严格尾递归的实现，迭代就可以用普通的过程调用机制来表示，这样一来，专用的迭代结构就只剩下语法糖衣的用途了。

Scheme是最早支持把过程在本质上当作对象的语言之一。过程可以动态创建，可以存储于数据结构中，可以作为过程的结果返回，等等。其他拥有这些特性的语言包括Common Lisp, Haskell, ML, Ruby和Smalltalk。

在大多数其他语言中只在幕后起作用的继续，在Scheme中也拥有“第一级”状态，这是Scheme的一个独树一帜的特征。第一级继续可用于实现大量不同的高级控制结构，如非局部退出（non-local exits）、回溯（backtracking）和协作程序（coroutine）等。

在Scheme中，过程的参数表达式会在过程获得控制权之前被求值，无论这个过程需不需要这个值。C, C#, Common Lisp, Python, Ruby和Smalltalk是另外几个总在调用过程之前对参数表达式进行求值的语言。这和Haskell惰性求值（lazy-evaluation）的语义以及Algol 60按名求值（call-by-name）的语义不同，在这些语义中，参数表达式只有在过程需要这个值的时候才会被求值。

Scheme的算术模型被设计为尽量独立于计算机内数值的特定表示方式。此外，他还区分精确数和非精确数对象：本质上，一个精确数对象精确地等价于一个数，一个非精确数对象是一个涉及到近似或其它误差的计算结果。

## 1.1. 基本类型

Scheme程序操作对象（object），有时也被成为值（value）。Scheme对象被组织为叫做类型（type）的值的集合。本节将给你Scheme语言十分重要的类型的一个概述。更多的类型将在后面章节进行描述。

<font size="2">
<i>注意：</i>由于Scheme采用隐式类型，所以本报告中术语<i>类型</i>的使用与其它语言文本中本术语的使用不同，尤其是与那些显式语言中的不同。
</font>

**布尔（Booleans）** 布尔类型是一个真值，可以是真或假。在Scheme中，对象“假”被写作`#f`。对象“真”被写作`#t`。然而，在大部分需要一个真值的情况下，凡是不同于`#f`的对象被看作真。

**数值（Numbers）** Scheme广泛支持各类数值数据结构，包括任意精度的整数，有理数，复数和各种类型的非精确数。第3章给了Scheme数值塔结构的概述。

**字符（Characters）** Scheme字符多半等价于一个文本字符。更精确地说，它们同构与Unicode字符编码标准的*标量值（scalar values）*。

**字符串（Strings）** 字符串是确定长度字符的有限序列，因此它代表任意的Unicode文本。

**符号（Symbols）** 符号是一个表示为字符串的对象，即它的名字。不同于字符串，两个名字拼写一样的符号永远无法区分。符号在许多应用中十分有用；比如：它们可以像其它语言中枚举值那样使用。

**点对（Pairs）和表（lists）** 一个点对是两个元素的数据结构。点对最常用的用法是（逐一串联地）表示表，在这种表结构中，第一个元素（即“car”）表示表的第一个元素，第二个元素（即“cdr”）表示表的剩余部分。Scheme还有一个著名的空表，它是表中一串点对的最后一个cdr。

**向量（Vectors）** 像表一样，向量是任意对象有限序列的线性数据结构。然而，表的元素循环地通过链式的点对进行访问，向量的元素通过整数索引进行标识。所以，比起表，向量更适合做元素的随机访问。

**过程（Procedures）** 在Scheme中过程是值。

## 1.2. 表达式（Expressions）

Scheme代码中最重要的元素是*表达式*。表达式可以被*计算（evaluated）*，产生一个*值（value）*。（实际上，是任意数量的值—参见5.8.节。）最基本的表达式就是字面的表达式：

~~~ scheme
#t ‌        ⇒ #t
23 ‌        ⇒ 23
~~~

这表明表达式`#t`的结果就是`#t`，也就是“真”的值，同时，表达式23计算得出一个表示数字23的对象。

复合表达式通过在子表达式周围放置小括号来组合。第一个子表达式表示一个运算；剩余的子表达式是运算的操作数：

~~~ scheme
(+ 23 42) ‌             ⇒ 65
(+ 14 (* 23 42)) ‌      ⇒ 980
~~~

上面例子中的第一个例子，`+`是内置的表示加法的运算的名字，23和42是操作数。表达式`(+ 23 42)`读作“23和42的和”。复合表达式可以被嵌套—第二个例子读作“14和23和42的积的和”。

正如这些例子所展示的，Scheme中的复合表达式使用相同的前缀表示法书写。所以，括号在表达这种结构的时候是必要的。所以，在数学表示和大部分语言中允许的“多余的”括号在Scheme中是不被允许的。

正如其它许多语言，空白符（包括换行符）在表达式中分隔子表达式的时候不是很重要，它也可以用来表示结构。

## 1.3. 变量和绑定（binding）

Scheme允许标识符代表一个包含值得位置。这些标识符叫做变量。在许多情况下，尤其是这个位置的值在创建之后再也不被修改的时候，认为变量直接代表这个值是非常有用的。

~~~ scheme
(let ((x 23)
      (y 42))
  (+ x y)) ‌        ⇒ 65
~~~

在这种情况下，以`let`开头的表达式是一种绑定结构。跟在`let`之后的括号结构列出了和表达式一起的变量：和23一起的变量`x`，以及和42一起的变量`y`。`let`表达式将`x`绑定到23，将`y`绑定到42。这些绑定在`let`表达式的*内部（body）*是有效的，如上面的`(+ x y)`，也仅仅在那是有效的。

## 1.4. 定义

`let`表达式绑定的变量是*局部的（local）*，因为绑定只在`let`的内部可见。Scheme同样允许创建标识符的顶层绑定，方法如下：

~~~ scheme
(define x 23)
(define y 42)
(+ x y) ‌           ⇒ 65
~~~

（这些实际上是在顶层程序或库的内部的“顶层”；参见下面的1.12节。）

开始的两个括号结构是*定义*，它们创造了顶层的绑定，绑定`x`到23，绑定`y`到42。定义不是表达式，它不能出现在所有需要一个表达式出现的地方。而且，定义没有值。

绑定遵从程序的词法结构：当存在相同名字的绑定的时候，一个变量参考离它最近的绑定，从它出现的地方开始，并且以从内而外的方式进行，如果在沿途没有发现局部绑定的话就使用顶层绑定：

~~~ scheme
(define x 23)
(define y 42)
(let ((y 43))
  (+ x y)) ‌            ⇒ 66

(let ((y 43))
  (let ((y 44))
    (+ x y))) ‌         ⇒ 67
~~~

## 1.5. 形式（Forms）
尽管定义不是表达式，但是复合表达式和定义有相同的语法形式：

~~~ scheme
(define x 23)
(* x 2)
~~~

尽管第一行包含一个定义，第二行包含一个表达式，但它们的不同依赖于`define`和`*`的绑定。在纯粹的语法层次上，两者都是*形式*，*形式*是Scheme程序一个语法部分的名字。特别地，23是形式`(define x 23)`的一个*子形式（subform）*。

## 1.6. 过程

定义也可以被用作定义一个过程：

~~~ scheme
(define (f x)
  (+ x 42))
(f 23) ‌            ⇒ 65
~~~

简单地说，过程是一个表达式对象的抽象。在上面这个例子中，第一个定义定义了一个叫`f`的过程。（注意`f x`周围的括号，这表示这是一个过程的定义。）表达式`(f 23)`是一个过程调用，大概意思是“将`x`绑定到23计算`(+ x 42)`（过程的内部）的值”。

由于过程是一个对象，所以它们可以被传递给其它过程：

~~~ scheme
(define (f x)
  (+ x 42))

(define (g p x)
  (p x))

(g f 23) ‌              ⇒ 65
~~~

在上面这个例子中，`g`的内部被视为`p`绑定到`f`，`x`绑定到23，这等价于`(f 23)`，最终结果是65。

实际上，Scheme许多预定义的操作不是通过语法提供的，而是值是过程的变量。比如，在其它语言中受到特殊对待的`+`操作，在Scheme中只是一个普通的标识符，这个标识符绑定到一过程，这个过程将数字对象加起来。`*`和许多其它的操作也是一样的：

~~~ scheme
(define (h op x y)
  (op x y))

(h + 23 42) ‌               ⇒ 65
(h * 23 42) ‌               ⇒ 966
~~~

过程定义不是定义过程的唯一方法。一个lambda表达式可以在不指定一个名字的情况下以对象的形式生成一个过程：

~~~ scheme
((lambda (x) (+ x 42)) 23) ‌        ⇒ 65
~~~

这个例子中的整个表达式是一个过程调用；`(lambda (x) (+ x 42))`，相当于一个输入一个数字并加上42的过程。

## 1.7. 过程调用和语法关键词（syntactic keywords）

尽管`(+ 23 42)`, `(f 23)`和`((lambda (x) (+ x 42)) 23)`都是过程调用的例子，但`lambda`和`let`表达式不是。这时因为尽管`let`是一个标识符，但它不是一个变量，而是一个*语法关键词*。以一个语法关键词作为第一个子表达式的形式遵从关键词决定的特殊规则。`define`标识符是一个定义，也是一个语法关键词。因此，定义也不是一个过程调用。

`lambda`关键词的规则规定第一个子形式是一个参数的表，其余的子形式是过程的内部。在`let`表达式中，第一个子形式是一个绑定规格的表，其余子形式构成表达式的内部。

通过在形式的第一个位置查找语法关键词的方法，过程调用通常可以和这些特殊的形式区别开来：如果第一个位置不包含一个语法关键词，则这个表达式是一个过程调用。（所谓的*标识符的宏（identifier macros）*允许创建另外的特殊形式，但相当不常见。）Scheme语法关键词的集合是非常小的，这通常使这项任务变得相当简单。可是，创建新的语法关键词的绑定也是有可能的，见下面的1.9节。

## 1.8. 赋值（Assignment）

Scheme变量通过定义或`let`或`lambda`表达式进行的绑定不是直接绑定在各自绑定时指定的对象上，而是包含这些对象的位置上。这些位置的内容随后可通过赋值破坏性地改写：

~~~ scheme
(let ((x 23))
  (set! x 42)
  x)                ‌⇒ 42
~~~

在这种情况下，`let`的内部包括两个表达式，这两个表达式被顺序地求值，最后一个表达式的值会成为整个`let`表达式的值。表达式`(set! x 42)`是一个赋值，表示“用42代替`x`所指向位置的对象”。因此，`x`以前的值，23，被42代替了。

## 1.9. 衍生形式（Derived forms）和宏（macros）

在本报告中，许多特殊的形式可被转换成更基本的特殊形式。比如，一个`let`表达式可以被转换成一个过程调用和一个lambda表达式。下面两个表达式是等价的：

~~~ scheme
(let ((x 23)
      (y 42))
  (+ x y))                          ‌⇒ 65

((lambda (x y) (+ x y)) 23 42)      ⇒ 65
~~~

像`let`表达式这样的特殊形式叫做*衍生形式*，因为它们的语义可以通过语法转换衍生自其它类型的形式。一些过程定义也是衍生形式。下面的两个定义是等价的：

~~~ scheme
(define (f x)
  (+ x 42))

(define f
  (lambda (x)
    (+ x 42)))
~~~

在Scheme中，一个程序通过绑定语法关键词到宏以定义它自己的衍生形式是可能的：

~~~ scheme
(define-syntax def
  (syntax-rules ()
    ((def f (p ...) body)
     (define (f p ...)
       body))))

(def f (x)
  (+ x 42))
~~~

`define-syntax`结构指定一个符合`(def f (p ...) body)`模式的括号结构，其中`f`，`p`和`body`是模式变量，被转换成`(define (f p ...) body)`。因此，这个例子中的`def`形式将被转换成下面的语句：

~~~ scheme
(define (f x)
  (+ x 42))
~~~

创建新的语法关键词的能力使得Scheme异常灵活和负有表现力，允许许多内建在其它语言的特性在Scheme中以衍生形式出现。

## 1.10. 语法数据（Syntactic data）和数据值（datum values）

Scheme对象的一个子集叫做*数据值*。这些包括布尔，数据对象，字符，符号，和字符串还有表和向量，它们的元素是数据。每一个数据值都可以语法数据的形式被表现成字面形式，语法数据可以在不丢失信息的情况下导出和读入。一个数据值可以被表示成多个不同的语法数据。而且，每一个数据值可以被平凡地转换成一个一个字面表达式，这种转换通过在程序中加上一个`'`在其对应的语法数据前：

~~~ scheme
'23 ‌⇒ 23
'#t ‌⇒ #t
'foo ‌⇒ foo
'(1 2 3) ‌⇒ (1 2 3)
'#(1 2 3) ‌⇒ #(1 2 3)
~~~

在数字对象和布尔中，前一个例子中的`'`是不必要的。语法数据`foo`表示一个名字是“foo”的符号，且`'foo`是一个符号作为其值对的字面表达式。`(1 2 3)`是一个元素是1，2和3的表的语法数据，且`'(1 2 3)`是一个值是表的字面表达式。同样，`#(1 2 3)`是一个元素是1，2和3的向量，且`'#(1 2 3)`是对应的字面量。

语法数据是Scheme形式的超集。因此，数据可以被用作以数据对象的形式表示Scheme形式。特别地，符号可以被用作表示标识符。

~~~ scheme
'(+ 23 42) ‌⇒ (+ 23 42)
'(define (f x) (+ x 42)) 
‌‌              ⇒ (define (f x) (+ x 42))
~~~

这方便了操作Scheme源代码程序的编写，尤其是解释和程序转换。

## 1.11. 继续（Continuations）

在Scheme表达式被求值的时候，总有一个*继续*在等待这个结果。继续表示计算的一整个（默认的）未来。比如，不正式地说，表达式

~~~ scheme
(+ 1 3)
~~~

中3的继续，给它加1。一般地，这些普遍存在的继续是隐藏在背后的，程序员不需要对它们考虑太多。可是，偶尔，一个程序员需要显示地处理继续。过程`call-with-current-continuation`（见11.15节）允许Scheme程序员通过创建一个接管当前继续的过程来处理这些。过程`call-with-current-continuation`传入一个过程，并以一个*逃逸过程*作为参数，立刻调用这个过程。随后，这个逃逸过程可以用一个参数调用，这个参数会成为`call-with-current-continuation`的结果。也就是说，这个逃逸过程放弃了它自己的继续，恢复了`call-with-current-continuation`调用的继续。

在下面这个例子中，一个逃逸过程代表加1到其绑定到`escape`参数的继续，且然后以参数3调用。`escape`调用的继续被放弃，取而代之的是3被传递给加1这个继续：

~~~ scheme
(+ 1 (call-with-current-continuation
       (lambda (escape)

         (+ 2 (escape 3))))) 
            ‌‌⇒ 4
~~~

一个逃逸过程有无限的生存期：它可以在它捕获的继续被调用之后被调用，且它可以被调用多次。这使得`call-with-current-continuation`相对于特定的非本地跳转,如其它语言的异常,显得异常强大。

## 1.12. 库

Scheme代码可以被组织在叫做*库*的组件中。每个库包含定义和表达式。它可以从其它的库中导入定义，也可以向其它库中导出定义。

下面叫做`(hello)`的库导出一个叫做`hello-world`的定义，且导入基础库（base library）（见第11章）和简单I/O库（simple I/O library）（见库的第8.3小节）。导出的`hello-world`是一个在单独的行上显示Hello World的过程。

~~~ scheme
(library (hello)
  (export hello-world)
  (import (rnrs base)
          (rnrs io simple))
  (define (hello-world)
    (display "Hello World")
    (newline)))
~~~

## 1.13. 顶层程序

一个Scheme程序被一个*顶层程序*调用。像库一样，一个顶层程序包括导入，定义和表达式，且指定一个执行的入口。因此，一个顶层程序通过它导入的库的传递闭包定义了一个Scheme程序。

下面的程序通过来自`(rnrs programs (6))`库（见库的第10章）的`command-line`过程从命令行获得第一个参数。它然后用`open-file-input-port`（见库的第8.2小节）打开一个文件，产生一个*端口（port）*，也就是作为一个数据源的文件的一个连接，并调用`get-bytes-all`过程以获得文件的二进制数据。程序然后使用`put-bytes`输出文件的内容到标准输出：

（译注：以下的示例程序已根据勘误表进行了修正。）

~~~ scheme
#!r6rs
(import (rnrs base)
        (rnrs io ports)
        (rnrs programs))
(let ((p (standard-output-port)))
  (put-bytevector p
                  (call-with-port
                      (open-file-input-port
                        (cadr (command-line)))
                    get-bytevector-all))
  (close-port p))
~~~

# 2. 需求等级

本报告中的关键词“必须（must）”, “必须不（must not）”, “应该（should）”, “不应该（should not）”, “推荐的（recommended）”, “可以（may）”和“可选的（optional）”按照RFC2119[^3]描述的进行解释。特别地：

**必须** 这个词意味着一个陈述是规范的一个绝对必要条件。

**必须不** 这个短语意味着一个陈述是规范绝对禁止的。

**应该** 这个词，或形容词“推荐的”，意味着有合适的理由的时候，在特定的情况下可以忽略这个陈述，但应当理解其含义，并在选择不同的做法前要仔细权衡。

**不应该** 这个短语，或短语“不推荐”，意味着有合适的理由的时候，在特定的情况下，一个陈述的行为是可接受的，但应当理解其含义，且选择本陈述的描述前应当仔细权衡。

**可以** 这个词，或形容词“可选的”，意味着一个条目是真正可选的。

尤其，本报告偶尔使用“应该”去指定本报告规范之外但是实际上无法被一个实现检测到的情况；见5.4小节。在这种情况下，一个特定的实现允许程序员忽略本报告的建议甚至表现出其它合理的行为。然而，由于本报告没有指定这种行为，这些程序可能是不可移植的，也就是说，它们的执行在不同的实现上可能产生不同的结果。

此外，本报告偶尔使用短语“不要求”来指示绝对必要条件的缺失。

# 3. 数字（Numbers）

本章描绘Scheme的数字模型。区别如下对象的不同是重要的：数学上的数字，尝试去建模这些数字的Scheme对象，用于实现这些数字的机器表示和用于书写数字的符号。在本报告中，术语*数字*表示数学上的数字，术语*数字对象（number object）*表示代表一个数字的Scheme对象。本报告使用类型*复数（complex）*，*实数（real）*，*有理数（rational）*和*整数（integer）*同时表示数学上的数字和数字对象。*定长数（fixnum）*和*浮点数（flonum）*类型表示这些数字对象的特殊子集，由通常的机器表示决定，这些会在下面说明。

## 3.1. 数值塔（Numeracal tower）

数字可以被组织在一个子集的塔中，在这个塔中，每一层是上一层的子集：

      number  
      complex  
      real  
      rational  
      integer

比如，5是一个整数。因此，5也是一个有理数，实数和复数。为5建模的数字对象也一样。

数字对象也被组织为一个对应的子类型的塔，这些类型被谓词（predicates）`number?`, `complex?`, `real?`, `rational?`和`integer?`定义；见11.7.4.1节。整形数字对象也被叫做*整数对象（integer objects）*。

包含一个数字的子集和它在计算机中的表示是没有简单的关系的。比如，整数5可以有多个表示。Scheme的数值操作将数字对象当作抽象数据对待，尽可能和它们的表示相独立。尽管Scheme的实现可以使用不同的数字表示方法，但这些对于偶尔编些简单程序的程序员来说不应该是明显可见的。

## 3.2. 精确性（Exactness）

区分一个已知的精确等于一个数字的数字对象和那些在计算过程中有近似和误差的数字对象是有用的。比如，数据结构的索引操作可能需要精确地了解索引，符号代数系统中的多项式系数也应如此。另一方面，测量的结果在本质上就是不精确的，无理数可以被近似地表示为有理数，这也是不精确的近似。为了在需要精确数的地方使用非精确数，Scheme显式区分*精确（exact）*和*非精确（inexact）*数。这种区分和类型的划分是正交的（orthogonal）关系。

如果一个数值被写作精确的常量，或是完全通过精确运算从精确数得出，它就是精确的。一个精确的数字对象明显地与一个数学上的数字相一致。

同样地，如果一个数值被写作非精确的常量，或者是由非精确的成分得出的，或者是由非精确的运算得出的，它就是非精确的。也就是说，非精确性是数值的一种可传染的特性。

精确算术在下面的场景是可靠的：一个精确数对象被传递到11.7.1节描述的任意一个算术过程，并返回一个精确数对象，这个结果是数学上正确的。然而在涉及到非精确数的计算的时候，这通常是不正确的，这时因为像浮点算法的近似方法可能被使用，但是，让结果尽可能接近数学上的理想结果是每个实现的职责。

## 3.3. 定长数和浮点数

一个*定长数*是一个精确的整数对象，这个整数对象在精确的整数对象的一个特定的实现相关的子范围（subrange）。（库的第11.2小节描绘了一个计算定长数的库。）同样地，每个实现应当指定一个非精确实数对象的子集作为*浮点数*，并将特定的外部表示转换成浮点数。（库的第11.3小节描绘了一个计算浮点数的库。）注意，这并不意味着实现必须使用浮点表示。

## 3.4. 实现要求

Scheme的实现必须支持3.1节给出的子类型的整个塔的数字对象。此外，实现必须支持几乎无限（Practically unlimited）大小和精度的精确整数对象和精确有理数对象，并实现特定的过程（在11.7.1节列出），当给它们精确参数的时候这些过程总是返回精确结果。（“几乎无限”意味着这些数字的大小和精度应当仅受可用内存大小的限制。）

实现可以只支持任意类型非精确数字对象的一个有限的值域（range），但需要遵从本节的要求。比如，一个实现可以限制非精确实数对象的值域（且因此限制非精确整数和有理数对象的值域）在浮点格式的动态值域内。此外，在使用这种值域限制的实现中，非精确整数对象和有理数之间的差异很可能会很大。

一个实现可以为非精确数字使用浮点或其它近似表示方法。本报告推荐但不要求实现遵从IEEE的浮点格式标准，使用其他表示方法的实现应当在精度上达到或超过这些浮点标准[^13]。

特别地，使用浮点数表示法的Scheme实现必须遵循以下规则：浮点数结果的表示精度必须达到或超过参与该运算的任意非精确参数的表示精度。只要有可能，像`sqrt`这样潜在的非精确操作当传递一个精确的参数时，应该返回一个精确的结果（比如精确数4的平方根应当是精确的2）。可是，这不是必须的。另一方面，如果参数是精确数的运算会产生非精确的结果（如通过sqrt），且该结果被表示为浮点数，那么就必须使用当前可用的精度最高的浮点数格式；不过，如果该结果是用其他形式表示的，那么该表示方法在精度上就必须达到或超过当前可用的精度最高的浮点数格式。

避免使用量级或有效数字大到实现无法表示的非精确数是程序员的责任。

## 3.5. 无穷大（Infinities）和非数（NaNs）

一些Scheme实现，尤其是那些遵从IEEE浮点格式标准的实现区别叫做*正无穷大*，*负无穷大*和*非数*的特殊数字对象。

正无穷大被认为是一个非精确的实数（但不是有理数）对象，它表示大于所以有理数对象表示的数字的一个模糊的数字。负无穷大被认为是一个非精确的实数（但不是有理数）对象，它表示小于所以有理数对象表示的数字的一个模糊的数字。

一个非数被认为是一个非精确数（但不是一个实数）对象，它是如此不确定以至于它可以表示任何数，包括正负无穷大，且甚至可能大于正无穷大或小于负无穷大。

## 3.6. 可区别的-0.0

一些Scheme实现，尤其是那些遵从IEEE浮点格式标准的实现区别数字对象0.0和-0.0。也就是说，正的和负的非精确的零。本报告有时会指定在这些数字对象上的特定算术操作的行为。这些说明会被写作“如果-0.0的话是不一样的”或“实现区分-0.0”。

# 4. 词汇（Lexical）语法和数据（datum）语法

Scheme的语法被组织进三个层次：

1. *词汇语法*描述一个程序文本怎样被分成语义（lexemes）的序列。
2. *数据语法*，按词汇语法制定，将句法（syntactic）数据的序列组织为语义的序列，其中一个句法数据递归地组织一个实体。
3. *程序语法*按数据语法制定，实施进一步的句法数据含义的组织和分配。（本句已根据勘误表修改。）

句法数据（也叫做*外部表示（external representations）*）兼作为对象的一个符号，且Scheme的`(rnrs io ports (6))`库（见库的8.2小节）提供了`get-datum`和`put-datum`过程用作句法数据的读写，在它们的文本表示和对应的对象之间进行转换。每一个句法数据表示一个对应的*数据值*。一个句法数据可以使用`quote`在一个程序中获得对应的数据值（见第11.4.1节）。

Scheme源程序包含句法数据和（不重要的）注释。Scheme源程序中的句法数据叫做*形式*。（嵌套在另一个形式中的形式叫做*子形式*。）因此，Scheme的语法有如下性质，字符的任何序列是一个形式也是一个代表一些对象的句法数据。这可能导致混淆，因为在脱离上下文的情况下，一个给定的字符序列是用于对象的表示还是一个程序的文本可能不是很明显。它可能也是使Scheme强大的原因，因为它使得编写解释器或编译器这类把程序当作对象（或相反）的程序变得简单。

一个数据值可能有多个不同的外部表示。比如“`#e28.000`”和“`#x1c`”都是表示精确整数对象28的句法数据，句法数据“`(8 13)`”, “`( 08 13 )`”和“`(8 . (13 . ()))`”都表示包含精确整数对象8和13的表。表示相同对象（从`equal?`的意义来说；见11.5小节）的句法数据作为程序的形式来说总是等价的。

因为句法数据和数据值之间密切的对应关系，所以当根据上下文精确含义显而易见时，本报告有时使用术语*数据*来表示句法数据或数据值。

一个实现不允许以任何方式扩展词汇或数据语法，仅有一个例外：实现不需要把`#!<identifier>`当作一个语法错误，其中`<identifier>`不是r6rs内建的，且实现可以使用特定的`#!-prefixed identifiers`作为指示接下来的输入包含标准词汇和数据语法的扩展的标记。语法`#!r6rs`可被用作预示接下来的输入是用本报告中描述的词汇语法和数据语法写成的。另外，`#!r6rs`被当作注释对待，见4.2.3小节。

## 4.1. 符号（Notation）

Scheme的形式语法（formal syntax）被用扩展的BNF写成。非终结符（Non-terminals）使用尖角括号进行书写。非终结符名字的大小写是无关紧要的。

语法中的空格都是为了便于阅读而存在的。`<Empty>`代表空字符串。

对BNF的以下扩展可以使描述更加简洁：`<thing>*`代表零个或更多的`<thing>`；`<thing>+`代表至少一个`<thing>`。

一些非终结符的名字表示相同名字的Unicode标量值：`<character tabulation> (U+0009)`, `<linefeed> (U+000A)`, `<line tabulation> (U+000B)`, `<form feed> (U+000C)`, `<carriage return> (U+000D)`, `<space> (U+0020)`, `<next line> (U+0085)`, `<line separator> (U+2028)`和`<paragraph separator> (U+2029)`。（本句已根据勘误表修改。）

## 4.2. 词汇语法

词汇语法决定了怎样将字符的序列分隔成语义的序列，省略不重要的部分如注释和空白。字符序列被假定是Unicode标准[^27]的文本。词汇语法的一些语义，比如标识符，数字对象的表示，字符串等等，是数据语法中的句法数据，且因此代表对象。除了语法的形式解释（formal account），本节还描述了这些句法数据表示什么数据值。

注释中描述的词汇语法包含`<datum>`的一个向前引用，这是数据语法的一部分。然而，作为注释，这些`<datum>`在语法中并不起什么重要的作用。

除了布尔，数字对象以及用16进制表示的Unicode标量是不区分大小写的，其它情况下大小写是敏感的。比如，`#x1A`和`#X1a`是一样的。然而，标识符`Foo`和标识符`FOO`是有区别的。

### 4.2.1. 形式解释

`<Interlexeme space>`可以出现在任意词位（lexeme）的两侧，但不允许出现在一个词位的中间。

`<Identifier>`, `.`, `<number>`, `<character>`和`<boolean>`必须被一个`<delimiter>`或输入的结尾终结。

下面的两个字符保留用作未来的语言扩展：`{``}`

（以下规则已根据勘误表修改。）

~~~ bnf
<lexeme> → <identifier> ∣ <boolean> ∣ <number>
‌ ∣ <character> ∣ <string>
    ∣ ( ∣ ) ∣ [ ∣ ] ∣ #( ∣ #vu8( | ' ∣ ` ∣ , ∣ ,@ ∣ .
    ∣ #' ∣ #` ∣ #, ∣ #,@
<delimiter> → ( ∣ ) ∣ [ ∣ ] ∣ " ∣ ; ∣ #
    ∣ <whitespace>
<whitespace> → <character tabulation>
    ∣ <linefeed> ∣ <line tabulation> ∣ <form feed>
    ∣ <carriage return> ∣ <next line>
    ∣ <any character whose category is Zs, Zl, or Zp>
<line ending> → <linefeed> ∣ <carriage return>
    ∣ <carriage return> <linefeed> ∣ <next line>
    ∣ <carriage return> <next line> ∣ <line separator>
<comment> → ; <all subsequent characters up to a
    <line ending> or <paragraph separator>>
‌ ∣ <nested comment>
    ∣ #; <interlexeme space> <datum>
    ∣ #!r6rs
<nested comment> → #| <comment text>
    <comment cont>* |#
<comment text> → <character sequence not containing
    #| or |#>
<comment cont> → <nested comment> <comment text>
<atmosphere> → <whitespace> ∣ <comment>
<interlexeme space> → <atmosphere>*

<identifier> → <initial> <subsequent>*
‌ ∣ <peculiar identifier>
<initial> → <constituent> ∣ <special initial>
    ∣ <inline hex escape>
<letter> → a ∣ b ∣ c ∣ ... ∣ z
    ∣ A ∣ B ∣ C ∣ ... ∣ Z
<constituent> → <letter>
    ∣ <any character whose Unicode scalar value is greater than
    ‌127, and whose category is Lu, Ll, Lt, Lm, Lo, Mn,
    ‌Nl, No, Pd, Pc, Po, Sc, Sm, Sk, So, or Co>
<special initial> → ! ∣ $ ∣ % ∣ & ∣ * ∣ / ∣ : ∣ < ∣ =
    ∣ > ∣ ? ∣ ^ ∣ _ ∣ ~
<subsequent> → <initial> ∣ <digit>
    ∣ <any character whose category is Nd, Mc, or Me>
    ∣ <special subsequent>
<digit> → 0 ∣ 1 ∣ 2 ∣ 3 ∣ 4 ∣ 5 ∣ 6 ∣ 7 ∣ 8 ∣ 9
<hex digit> → <digit>
    ∣ a ∣ A ∣ b ∣ B ∣ c ∣ C ∣ d ∣ D ∣ e ∣ E ∣ f ∣ F
<special subsequent> → + ∣ - ∣ . ∣ @
<inline hex escape> → \x<hex scalar value>;
<hex scalar value> → <hex digit>+
<peculiar identifier> → + ∣ - ∣ ... ∣ -> <subsequent>*
<boolean> → #t ∣ #T ∣ #f ∣ #F
<character> → #\<any character>
    ∣ #\<character name>
    ∣ #\x<hex scalar value>
<character name> → nul ∣ alarm ∣ backspace ∣ tab
    ∣ linefeed ∣ newline ∣ vtab ∣ page ∣ return
    ∣ esc ∣ space ∣ delete
<string> → " <string element>* "
<string element> → <any character other than " or \>
    ∣ \a ∣ \b ∣ \t ∣ \n ∣ \v ∣ \f ∣ \r
    ∣ \" ∣ \\
    ∣ \<intraline whitespace>*<line ending>
       <intraline whitespace>*
    ∣ <inline hex escape>
<intraline whitespace> → <character tabulation>
    ∣ <any character whose category is Zs>
~~~

一个`<hex scalar value>`表示一个`0`到`#x10FFFF`的Unicode标量值，这个范围要排除`[#xD800, #xDFFF]`。

让R = 2， 8， 10 和 16，然后重复下面的规则`<num R>`, `<complex R>`, `<real R>`, `<ureal R>`, `<uinteger R>`和`<prefix R>`。没有`<decimal 2>`, `<decimal 8>`和`<decimal 16>`的规则，这意味着包含小数点和指数的数字表示必须使用十进制基数。

下面的规则中，大小写是不重要的。（本句根据勘误表添加。）

（以下规则已根据勘误表修改。）

~~~ bnf
<number> → <num 2> ∣ <num 8>
‌ ∣ <num 10> ∣ <num 16>
<num R> → <prefix R> <complex R>
<complex R> → <real R> ∣ <real R> @ <real R>
    ∣ <real R> + <ureal R> i ∣ <real R> - <ureal R> i
    ∣ <real R> + <naninf> i ∣ <real R> - <naninf> i
    ∣ <real R> + i ∣ <real R> - i
    ∣ + <ureal R> i ∣ - <ureal R> i
    ∣ + <naninf> i ∣ - <naninf> i
    ∣ + i ∣ - i
<real R> → <sign> <ureal R>
    ∣ + <naninf> ∣ - <naninf>
<naninf> → nan.0 ∣ inf.0
<ureal R> → <uinteger R>
    ∣ <uinteger R> / <uinteger R>
    ∣ <decimal R> <mantissa width>
<decimal 10> → <uinteger 10> <suffix>
    ∣ . <digit 10>+ <suffix>
    ∣ <digit 10>+ . <digit 10>* <suffix>
<uinteger R> → <digit R>+
<prefix R> → <radix R> <exactness>
    ∣ <exactness> <radix R>

<suffix> → <empty>
‌ ∣ <exponent marker> <sign> <digit 10>+
<exponent marker> → e ∣ E ∣ s ∣ S ∣ f ∣ F
    ∣ d ∣ D ∣ l ∣ L
<mantissa width> → <empty>
    ∣ | <digit 10>+
<sign> → <empty> ∣ + ∣ -
<exactness> → <empty>
    ∣ #i∣ #I ∣ #e∣ #E
<radix 2> → #b∣ #B
<radix 8> → #o∣ #O
<radix 10> → <empty> ∣ #d ∣ #D
<radix 16> → #x∣ #X
<digit 2> → 0 ∣ 1
<digit 8> → 0 ∣ 1 ∣ 2 ∣ 3 ∣ 4 ∣ 5 ∣ 6 ∣ 7
<digit 10> → <digit>
<digit 16> → <hex digit>
~~~

### 4.2.2. 换行符

在Scheme单行注释（见4.2.3小节）和字符串字面量中，换行符是重要的。在Scheme源代码中，在`<line ending>`中的任意换行符都指示一个行的结束。此外，两字符的换行符`<carriage return> <linefeed>`和`<carriage return> <next line>`都仅表示一个单独的换行。

在一个字符串字面量中，一个之前没有`\`的`<line ending>`表示一个换行字符（linefeed character），这个字符是Scheme中的标准换行符。

### 4.2.3. 空白和注释

*空白*字符是空格，换行，回车，字符制表符，换页符，行制表符和其它种类是Zs，Zl或Zp的任意其它字符。空白字符用于提高可读性和必要地相互分隔词位。空白可以出现在两个词位中间，但不允许出现在一个词位的中间。空白字符也可以出现在一个字符串中，但此时空白是有意义的。

词汇语法包括一些注释形式。在所有的情况下，注释对Scheme是不可见的，除非它们作为分隔符，所以，比如，一个注释不能出现在标识符或一个数字对象的表示的中间。

一个分号（`;`）指示一个行注释的开始。注释一直延续到分号出现的那一行的结尾。

另一个指示注释的方法是在`<datum>`（参见4.3.1节）前加一个前缀`#;`，可选的在`<datum>`前加上`<interlexeme space>`。注释包括注释前缀`#;`和`<datum>`。这个符号用作“注释掉”代码段。

块注释可用正确嵌套的`#|`和`|#`指示。

~~~ scheme
#|
    FACT过程计算一个非负数的阶乘。
|#
(define fact
  (lambda (n)
    ;; 基本情况
    (if (= n 0)
        #;(= n 1)
        1       ; *的单位元（identity）
        (* n (fact (- n 1))))))
~~~

词位`#!r6rs`，表示接下来的输入是用本报告中描述的词汇语法和数据语法写成的，另外，它也被当作注释对待。

### 4.2.4. 标识符

其他程序设计语言认可的大多数标识符也能被Scheme接受。通常，第一个字符不是任何数值的字母、数字和“扩展字符”序列就是一个标识符。此外，`+`、`-`和`...`都是标识符，以两个字符序列`->`开始的字母、数字和“扩展字符”序列也是。这里有一些标识符的例子：

~~~ scheme
lambda         q                soup
list->vector   +                V17a
<=             a34kTMNs         ->-
the-word-recursion-has-many-meanings
~~~

扩展字符可以像字母那样用于标识符内。以下是扩展字符：

`! $ % & * + - . / : < = > ? @ ^ _ ~ `

此外，所有Unicode标量值大于127且类型属于Lu, Ll, Lt, Lm, Lo, Mn, Mc, Me, Nd, Nl, No, Pd, Pc, Po, Sc, Sm, Sk, So或Co的字符都可以被用在标识符中。当通过一个`<inline hex escape>`表示的时候，任何字符都可以用在标识符中。比如，标识符`H\x65;llo`和标识符`Hello`是一样的，标识符`\x3BB;`和标识符`λ`是一样的。

在Scheme程序中，任意标识符可作为一个变量或一个语法关键词（见5.2和9.2节）。任何标识符也可以作为一个句法数据，在这种情况下，它表示一个*符号*（见11.10小节）。

### 4.2.5. 布尔

标准布尔对象真和假有外部表示`#t`和`#f`。

### 4.2.6.字符

字符可以用符号`#\<character>`或`#\<character name>`或`#\x<hex scalar value>`表示。

比如：

| `#\a` |           小写字母a
| `#\A` |           大写字母A
| `#\(` |           做小括号  
| `#\ ` |           空格  
| `#\nul` |         U+0000  
| `#\alarm` |       U+0007  
| `#\backspace` |   U+0008  
| `#\tab` |         U+0009  
| `#\linefeed` |    U+000A  
| `#\newline` |     U+000A  
| `#\vtab` |        U+000B  
| `#\page` |        U+000C  
| `#\return` |      U+000D  
| `#\esc` |         U+001B  
| `#\space` |       U+0020  
| |                 表示一个空格时优先使用这种方法  
| `#\delete` |      U+007F  
| `#\xFF` |         U+00FF  
| `#\x03BB` |       U+03BB  
| `#\x00006587` |   U+6587  
| `#\λ` |           U+03BB  
| `#\x0001z` |      `词法`*异常*（`&lexical` *exception*）
| `#\λx` |          `词法`*异常*
| `#\alarmx` |      `词法`*异常*
| `#\alarm x` |     U+0007  
| |                 跟着`x`
| `#\Alarm` |       `词法`*异常*
| `#\alert` |       `词法`*异常*
| `#\xA` |          U+000A  
| `#\xFF` |         U+00FF  
| `#\xff` |         U+00FF  
| `#\x ff` |        U+0078  
| |                 跟着另外一个数据，`ff` 
| `#\x(ff)` |       U+0078  
| |                 跟着另外一个数据， 
| |                 一个被括号括着的`ff` 
| `#\(x)` |         `词法`*异常*
| `#\(x` |          `词法`*异常*
| `#\((x)` |        U+0028  
| |                 跟着另外一个数据， 
| |                 一个被括号括着的`x` 
| `#\x00110000` |   `词法`*异常*
| |                 超出范围
| `#\x000000001` |  U+0001  
| `#\xD800` |       `词法`*异常*
| |                 在被排除的范围内

（`词法`*异常*记号表示有问题的行违反了词汇语法。）

在`#\<character>`和`#\<character name>`中，大小写是重要的，但在`#\x<hex scalar value>`中的`<hex scalar value>`是不重要的。（上句已根据勘误表进行修改。）一个`<character>`必须跟着一个`<delimiter>`或输入的结束。此规则解决了关于命名字符的各种歧义，比如，要求字符序列`#\space`被解释为一个空白字符而不是字符`#\s`和跟着的标识符`pace`。

<font size="2">
<i>注意：</i>由于反向兼容的原因我们保留符号<code>#\newline</code>。它的使用是不赞成的；应使用<code>#\linefeed</code>代替。
</font>

### 4.2.7. 字符串

字符串使用被双引号（`"`）括起来的字符序列表示。在字符串字面量中，各种转义序列（escape sequences）被用来表示字符，而不是字符自己。转义序列总是以一个反斜杠（`\`）开始：

* `\a` : 响铃（alarm）, U+0007
* `\b` : 退格（backspace）, U+0008
* `\t` : 制表（character tabulation）, U+0009
* `\n` : 换行（linefeed）, U+000A
* `\v` : 行制表（line tabulation）, U+000B
* `\f` : 换页（formfeed）, U+000C
* `\r` : 回车（return）, U+000D
* `\"` : 双引号（doublequote）, U+0022
* `\\` : 反斜杠（backslash）, U+005C
* `\<intraline whitespace><line ending><intraline whitespace>` : 无
* `\x<hex scalar value>;` : 指定字符（注意结尾的分号）。

这些转义序列是大小写敏感的，除了`<hex scalar value>`中的字母数字（alphabetic digits）可以是大写也可以是小写。

字符串中反斜杠后的任意其它字符都是违反语法的。除了行结尾外，任意在转义序列外且不是一个双引号的字符在字符串字面量中代表它自己。比如，但字符字符串字面量`"λ"`（双引号，一个小写的lambda，双引号）和`"\x03bb;"`表示一样的字符串。一个前面不是反斜杠的行结尾表示一个换行字符。

比如：

| "abc" | U+0061, U+0062, U+0063
| "\x41;bc" | "Abc" ; U+0041, U+0062, U+0063
| "\x41; bc" | "A bc" 
| |U+0041, U+0020, U+0062, U+0063
| "\x41bc;" | U+41BC
| "\x41" |  `词法`*异常*
| "\x;" | `词法`*异常*
| "\x41bx;" | `词法`*异常*
| "\x00000041;" | "A" ; U+0041
| "\x0010FFFF;" | U+10FFFF
| "\x00110000;" | `词法`*异常*
| | 超出范围
| "\x000000001;" |  U+0001
| "\xD800;" | `词法`*异常*
| | 在被排除的范围内
|"A |
| bc" | U+0041, U+000A, U+0062, U+0063
| | 如果A后面没有空格

### 4.2.8. 数字

数字对象外部表示的语法在形式语法的`<number>`规则中被正式描述。在数字对象的外部表示中，大小写是不重要的。

数字对象的表示可以通过特定的基数前缀被写作二进制，八进制，十进制和十六进制。基数前缀是`#b`（二进制），`#o`（八进制），`#d`（十进制）和`#x`（十六进制）。在没有基数前缀时，一个数字对象的表示被假设是十进制的。

一个数字对象的表示可通过前缀被指定为精确的货非精确的。前缀`#e`表示精确的，前缀`#i`表示非精确的。如果使用基数前缀的话，精确性前缀可使用在其之前或之后。如果一个数字对象的表示没有精确性前缀，则在下列情况是非精确的，包含一个小数点，指数，或一个非空的尾数宽度（mantissa width），否则它是精确的。

在一个非精确数可以有不同精度的系统中，指定一个常数的精度可能是有用的。如果这样的话，数字对象的表示可以用一个指示非精确数预期精度的指数标记写成。字母`s`, `f`, `d`和`l`分别表示使用*short*，*single*，*double*和*long*精度。（当内部非精确表示少于四种时，这四个精度定义被映射到当前可用的定义。例如，只有两种内部表示的实现可以将short和single映射为一种精度，将long和double映射为一种）。另外，指数标记`e`指明了Scheme实现的缺省精度。缺省精度应达到或超过*double*的精度，但Scheme实现也许会希望用户可设置此缺省精度。

~~~ scheme
3.1415926535898F0 
       舍入到single, 大概是3.141593
0.6L0
       扩展到long, 大概是.600000000000000
~~~

一个有非空尾数宽度数字对象的表示，`x|p`，代表有*p*位有效数字的*x*的最好的二进制浮点数近似。比如，`1.1|53`是使用IEEE double精度的1.1最好的近似的表示。如果*x*是一个不包含竖线的非精确实数对象的外部表示，那么它的数值应该被认为有53或更多的尾数宽度。

如果实际可行的话，实数对象使用二进制浮点表示的实现应该用*p*位精度表示`x|p`，或者如果实际不行的话，应该使用大于*p*位精度的实现，或者如果以上两个都不行的话，应该使用实现中最大的精度。

<font size="2">
  <i>注意：</i>有效数字的精度不应该和用作表示有效数字的位的数量相混淆。在IEEE浮点标准中，比如，有效数字的最高有效位暗示在single和double精度之间但明确使用扩展精度。不管那一位是不是明确指定的都不影响数学精度。使用二进制浮点的实现，默认的精度可通过调用下面的过程计算：

<pre><code>(define (precision)
  (do ((n 0 (+ n 1))
       (x 1.0 (/ x 2.0)))
    ((= 1.0 (+ 1.0 x)) n)))   
</code></pre>
</font>

<font size="2">
  <i>注意：</i>当优先使用的浮点表示是IEEE double精度时，<code>|p</code>后缀不应该总是被省略：非规范化浮点数在精度上有所松懈，所以它们的外部表示应该加上一个使用有效数字真实宽度的<code>|p</code>后缀。
</font>

字面量`+inf.0`和`-inf.0`分别表示正无穷大和负无穷大。字面量`+nan.0`表示非数，它是`(/ 0.0 0.0)`的结果，且同样也可以表示其它非数。字面量`-nan.0`也表示一个非数。（上句根据勘误表添加。）

如果*x*是一个非精确实数对象的外部表示且不包括竖线且不包括除了`e`之外的指数标记，这个非精确实数对象表示一个浮点数（见库的第11.3小节）。其它非精确实数对象外部表示的一些或所有也可以表示浮点数，但这不是本报告要求的。

## 4.3. 数据语法

数据语法按照`<lexeme>`的序列描述句法的语法。

句法数据包括本报告前面章节描述的语义数据以及以下用于组织复合数据的结构。

* 点对和表，被`( )`或`[ ]`（见4.3.2节）括起来
* 向量（见4.3.3节）
* 字节向量（bytevectors）（见4.3.4节）

### 4.3.1. 形式解释

下面的语法按照定义在4.2节的语法的各种语义描述句法数据的语法：

~~~ scheme
<datum> → <lexeme datum>
‌ ∣ <compound datum>
<lexeme datum> → <boolean> ∣ <number>
    ∣ <character> ∣ <string> ∣ <symbol>
<symbol> → <identifier>
<compound datum> → <list> ∣ <vector> ∣ <bytevector>
<list> → (<datum>*) ∣ [<datum>*]
    ∣ (<datum>+ . <datum>) ∣ [<datum>+ . <datum>]
    ∣ <abbreviation>
<abbreviation> → <abbrev prefix> <datum>
<abbrev prefix> → ' ∣ ` ∣ , ∣ ,@
    ∣ #' | #` | #, | #,@
<vector> → #(<datum>*)
<bytevector> → #vu8(<u8>*)
<u8> → <any <number> representing an exact
      ‌‌integer in {0, ..., 255}>
~~~

### 4.3.2. 点对和表

表示值对和值的列表（见11.9节）的列表和点对数据使用小括号和中括号表示。规则`<list>`中匹配的中括号对等价于匹配的小括号对。

Scheme点对的句法数据最常用的符号是“点”符号<tt>(<datum<sub>1</sub>> . <datum<sub>2</sub>>)</tt>，其中<tt><datum<sub>1</sub>></tt>是car区域的值的表示，<tt><datum<sub>2</sub>></tt>是cdr区域的值的表示。比如`(4 . 5)`是一个car是4，cdr是5的点对。

表可以使用一个改进的记号：表中的元素被简单地括进小括号中并用空格分隔。空表用`()`表示。比如：

`(a b c d e)`

和

`(a . (b . (c . (d . (e . ())))))`

作为符号的表是等价的表示。

一个通用的规则是，如果一个点跟着一个左小括号，则在外部表示中可以省略这个点，左小括号和对应的右小括号。

符号序列“`(4 . 5)`”是一个点对的外部表示，而不是一个计算结果为点对的表达式。类似的，符号序列“`(+ 2 6)`”*不*是整数8的外部表示，虽然它*是*一个计算结果是整数8的表达式（在`(rnrs base (6))`库语言中）；当然，它是一个句法数据，这个句法数据表示一个三个元素的表，这个表的元素是符号`+`，整数2和6。

### 4.3.3. 向量

表示向量对象（见11.13小节）的向量数据使用`#(<datum> ...)`表示。比如：一个长度是3，且0号元素位置是数字对象零，1号元素位置是表`(2 2 2 2)`，2号元素位置是字符串`"Anna"`，的向量可以如下表示：

`#(0 (2 2 2 2) "Anna")`

这是一个向量的外部表示，而不是一个计算结果为向量的表达式。

### 4.3.4. 字节向量

表示字节向量（见库的第2章）的向量数据使用符号`#vu8(<u8> ...)`表示，其中`<u8>`表示字节向量的八位字节（octets）。比如：一个长度是3且包含八位字节2，24和123的字节向量可以如下表示：

`#vu8(2 24 123)`

这是一个字节向量的外部表示，也是一个计算结果为字节向量的表达式。

### 4.3.5 缩写（Abbreviations）

~~~ scheme
'<datum>‌‌ 
`<datum>‌‌ 
,<datum>‌‌ 
,@<datum>‌‌ 
#'<datum>‌‌ 
#`<datum>‌‌ 
#,<datum>‌‌ 
#,@<datum
~~~

上面的每一个都是一个缩写：

`` ‌'<datum> ``是`` (quote <datum>) ``的缩写，   
`` ‌`<datum> ``是`` (quasiquote <datum>) ``的缩写，   
`` ‌,<datum> ``是`` (unquote <datum>) ``的缩写，   
`` ‌,@<datum> ``是`` (unquote-splicing <datum>) ``的缩写，   
`` ‌#'<datum> ``是`` (syntax <datum>) ``的缩写，   
`` ‌#`<datum> ``是`` (quasisyntax <datum>) ``的缩写，   
`` ‌#,<datum> ``是`` (unsyntax <datum>) ``的缩写，且  
`` ‌#,@<datum> ``是`` (unsyntax-splicing <datum>) ``的缩写。

# 5. 语义概念

## 5.1. 程序和库

一个Scheme程序由一个*顶层程序*以及一系列的*库*组成，每个库通过显式地指定导入和导出定义了和其它程序相联系的程序的一部分。一个库由一系列的导入导出说明和程序体组成，程序体由定义和表达式组成。一个顶层程序和一个库差不多，但是没有导出说明。第7章和第8章分别描述了库和顶层程序的语法和语义。第11章描述了定义了通常和Scheme一起的结构的一个基本库。一个单独的报告[^24]描述了Scheme系统提供的各种标准库。

基本库和其它标准库的划分是根据使用而不是结构。尤其那些通常被编译器或运行时系统实现为“原语（primitives）”而不是根据其它标准调用或句法形式的功能不是基本库的一部分，而是被定义在单独的库中。例子包括定长数和浮点数库，异常和条件库，以及用于记录的库。

## 5.2. 变量，关键词和作用域

在一个库或顶层程序的内部，一个标识符可以命名一种语法，或者它可以命名一个值可以被存储的位置。命名一种语法的标识符叫做*关键词*，或*句法关键词*，也可以说是关键词被*绑定*到那个语法（或者说是一个句法抽象，这个抽象将语法转换成更基本的形式；见7.2小节）。命名一个位置的标识符叫做*变量*，也可以说是变量被*绑定*到那个位置。在一个顶层程序或一个库的每一个位置，一个特定的固定集合的标识符被绑定。这些标识符的集合，也就是*可见绑定（visible bindings）*的集合，被称为影响该位置的*环境（environment）*。

特定的形式被用作创建语法抽象并绑定关键词到用于这些新的语法抽象的转换，同时其它的形式创建新的位置并将变量绑定到那些位置。这些表达式被统称为*绑定结构（binding constructs）*。一些绑定结构使用*定义*的形式，其它的是表达式。除了导出的库绑定是一个例外，一个定义创建的绑定只在这个定义出现的内部可见，例如，库，顶层程序或`lambda`表达式的内部。导出的库绑定在导入这些绑定的库和程序的内部是可见的（见第7章）。

绑定变量的表达式包括来自基础库的`lambda`，`let`，`let*`，`letrec`, `letrec*`, `let-values`和`let*-values`形式（见11.4.2和11.4.6小节）。在这些当中，`lambda`是最基本的。

出现在这样的表达式内部，或出现在库或顶层程序内部的变量定义被当作一系列的`letrec*`对待。另外，在库的内部，从库中导出的变量可以被导入的库或顶层程序引用。

绑定关键词的表达式包括`let-syntax`和`letrec-syntax`形式（见11.18小节）。一个`define`形式（见11.2.1小节）是一个创建变量绑定（见11.2小节）的定义，同时一个`define-syntax`形式是一个创建关键词绑定（见11.2.2小节）的定义。

Scheme是一个拥有块结构的静态作用域的语言。顶层程序或库的内部的每一个地方，一个标识符被绑定到代码的*作用域*，在这个作用域中绑定是可见的。这个作用域被特定的建立绑定的绑定结构决定；比如，如果一个绑定通过`lambda`表达式建立，那么作用域是整个`lambda`表达式。每当标识符引用标识符的绑定的时候，它总是引用包含这次使用的最内层绑定。如果找不到作用域包含该引用的标识符绑定，它可以引用库或顶层程序最上面的定义或导入建立的绑定（见第7章）。如果找不到标识符的绑定，它就被称为*未绑定的*。

## 4.3. 异常情况

在本报告中各种异常情况是有区别的，包括违反语法，违反过程调用，违反实现限制和环境中的异常情况。当实现检测到一个异常情况时，一个*异常被抛出*，这意味着一个被称为*当前异常处理程序（current exception handler）*的特殊过程被调用。一个程序也可以抛出一个异常且覆盖当前异常处理程序；见库的第7.1小节。

当一个异常被抛出时，会提供一个描述异常情况性质的对象。本报告使用库的第7.2小节描述的条件系统来描述异常情况，通过条件类型来区分它们。

如果异常处理程序采取适当动作的话，一些异常情况允许程序继续运行。对应的异常被称为是*可继续的（continuable）*。对于本报告描述的大部分异常情况，可移植的程序不应该依赖在异常被检测到的地方异常是可继续的。在那些异常中，被异常调用的异常处理程序不应该返回。可是，在有些情况下，继续是被允许的，这时处理程序应该返回。见库的第7.1小节。

当实现由于*实现限制（implementation restriction）*无法正确执行一个正确的程序时，实现必须抛出一个异常。比如，一个不支持无穷大的实现计算一个结果是无穷大的表达式时必须抛出一个条件类型是`&implementation-restriction`的异常。

一些可能的异常比如缺乏非数和无穷大的表示（见11.7.2小节）是本报告预知的，且实现必须在遭遇到这样的情况的时候抛出条件类型适当的异常。

本报告使用的措辞“一个异常被抛出”等价于“一个异常必须被抛出”。本报告使用措辞“一个条件类型为*t*的异常”指示跟随异常抛出的对象是一个有特定类型的条件对象。措辞“一个可继续的异常被抛出”指示一个异常情况允许异常处理程序返回。

## 5.4. 参数检查

本报告中的许多或一个标准库中的部分调用限制它们接受的参数。典型的，一个调用只接受特定的数字和参数类型。许多句法形式同样限制它们的一个或多个子形式计算结果的值。这些限制暗示着程序员和实现共同的责任。尤其，程序员负责确保这些值确实符合本规范描述的限制。实现必须检查本规范描述的限制确实被遵守，在某种程度上来说允许特定的操作成功完成是合理的，可能的，也是必要的。

在第6章以及整个报告中，实现的责任会被更加仔细地描述。

注意，一个实现完全检查一个规范的限制并不总是可行的。比如，如果一个操作接受一个有特定属性的过程，检查这些属性通常是不可行的。同样地，一些操作同时接受表和过程，并且这些操作会调用这些过程。因为表可以被来自`(rnrs mutable-pairs (6))`库（见库的第17章）的过程改变，所以，一个操作开始时还是表的参数可能在操作执行过程中编程一个非表。并且，过程可能逃逸到一个不同的继续中，从而阻止操作进行检查。要求操作检查参数在这样的过程的每一次调用后都是一个表是不现实的。并且，一些接受表参数操作仅仅需要部分地遍历表中的元素；要求实现去遍历表中的其它元素以检查所有的限制被满足可能违反合理的性能假设。由于这些原因，这些检查时程序员的义务而不是实现的检查义务。

当一个实现检测到参数违反限制的时候，它必须以5.6小节描述的符合执行安全性的方法抛出一个条件类型是`&assertion`的异常。

## 5.5. 违反语法

一个特定形式的子形式通常需要遵循特定的句法限制。由于形式可能要遵从宏扩展，其可能不会终结，所以，它们是否符合特定的限制的问题通常是无法解答的。

可是，当宏扩展终结时，实现必须检测违反语法的地方。一个*语法错误*是一个关于库内部，顶层程序内部，或本报告基本库或标准库“语法”入口的错误。此外，试图给一个不可改变的变量（也就是一个库导出的变量；见7.1小节）也被认为是一个语法错误。

<!--
  原文好像有个错误：a top-level，少一个program。
-->
如果一个程序中的一个顶层或或库形式是句法上住正确的，那么实现必须抛出一个条件类型是`&syntax`的异常，且顶层程序或库必须不能被允许开始。

## 5.6. 安全性

 导出被本文档描述的标准库被认为是*安全库*。只从安全库导入的库或顶层程序也被认为是安全的。

 正如本文档所定义的，Scheme编程语言在下列的场景下是安全的：一个顶层程序的执行不能严重错误到以至于崩溃或不能以和本报告描述的语义相一致的行为执行，除非一个异常被抛出。

 违反实现限制的时候必须抛出一个条件类型是` &implementation-restriction`的异常，且必须是所有的违规和错误，其可能威胁系统的完整性，使得执行的结果无法和本报告中描述的语义相一致。

 上面的安全性属性只有在顶层程序或库被认为是安全的时候被确保。特别地，实现可以提供访问非安全库的方法，这种方法不能保证安全性。

 ## 5.7. 布尔值

 尽管有单独的布尔值的存在，但是，Scheme的任何值可被当作一个布尔值在条件测试中使用，除了`#f`，所有的值在测试中被当成真。本报告使用词语“真”表示任意除了`#f`的Scheme值，用词语“假”表示`#f`。

 ## 5.8. 多个返回值

 一个Scheme表达式的结果可以是任意多个有限数量的值。这些值被传递给表达式的继续。

 不是所有的继续都接受任意数量的值。比如，一个接受调用参数的继续可以确保精确地接受一个值。传递其它数量的值到这样一个继续的效果是未定义的。11.15小节描述的过程`call-with-values`使创建接受特定数量返回值的继续成为可能。如果传递给一个`call-with-values`过程创建的继续的返回值的数量不被这个继续接受，那么一个异常被抛出。





<!--
  （勘误：5.10）

  TODO：将逗号由中文改为英文
-->

# 参考文献

[^1]:      J. W. Backus, F.L. Bauer, J.Green, C. Katz, J. McCarthy P. Naur, A. J. Perlis, H. Rutishauser, K. Samuelson, B. Vauquois J. H. Wegstein, A. van Wijngaarden, and M. Woodger. Revised report on the algorithmic language Algol 60. Communications of the ACM, 6(1):1–17, 1963.
[^2]:      Alan Bawden and Jonathan Rees. Syntactic closures. In ACM Conference on Lisp and Functional Programming, pages 86–95, Snowbird, Utah, 1988. ACM Press.
[^3]:      Scott Bradner. Key words for use in RFCs to indicate requirement levels. http://www.ietf.org/rfc/rfc2119.txt, March 1997. RFC 2119.
[^4]:      Robert G. Burger and R. Kent Dybvig. Printing floating-point numbers quickly and accurately. In Proceedings of the ACM SIGPLAN '96 Conference on Programming Language Design and Implementation, pages 108–116, Philadelphia, PA, USA, May 1996. ACM Press.
[^5]:      William Clinger. Proper tail recursion and space efficiency. In Keith Cooper, editor, Proceedings of the 1998 Conference on Programming Language Design and Implementation, pages 174–185, Montreal, Canada, June 1998. ACM Press. Volume 33(5) of SIGPLAN Notices.
[^6]:      William Clinger and Jonathan Rees. Macros that work. In Proceedings 1991 ACM SIGPLAN Symposium on Principles of Programming Languages, pages 155–162, Orlando, Florida, January 1991. ACM Press.
[^7]:      William D. Clinger. How to read floating point numbers accurately. In Proceedings Conference on Programming Language Design and Implementation '90, pages 92–101, White Plains, New York, USA, June 1990. ACM.
[^8]:      R. Kent Dybvig. Chez Scheme Version 7 User's Guide. Cadence Research Systems, 2005. http://www.scheme.com/csug7/.
[^9]:      R. Kent Dybvig, Robert Hieb, and Carl Bruggeman. Syntactic abstraction in Scheme. Lisp and Symbolic Computation, 1(1):53–75, 1988.
[^10]:     Matthias Felleisen and Matthew Flatt. Programming languages and lambda calculi. http://www.cs.utah.edu/plt/publications/pllc.pdf, 2003.
[^11]:     Matthew Flatt. PLT MzScheme: Language Manual. Rice University, University of Utah, July 2006. http://download.plt-scheme.org/doc/352/html/mzscheme/.
[^12]:     Daniel P. Friedman, Christopher Haynes, Eugene Kohlbecker, and Mitchell Wand. Scheme 84 interim reference manual. Indiana University, January 1985. Indiana University Computer Science Technical Report 153.
[^13]:     IEEE standard 754-1985. IEEE standard for binary floating-point arithmetic, 1985. Reprinted in SIGPLAN Notices, 22(2):9-25, 1987.
[^14]:     Richard Kelsey, William Clinger, and Jonathan Rees. Revised<sup>5</sup> report on the algorithmic language Scheme. Higher-Order and Symbolic Computation, 11(1):7–105, 1998.
[^15]:     Eugene E. Kohlbecker, Daniel P. Friedman, Matthias Felleisen, and Bruce Duba. Hygienic macro expansion. In Proceedings of the 1986 ACM Conference on Lisp and Functional Programming, pages 151–161, 1986.
[^16]:     Eugene E. Kohlbecker Jr. Syntactic Extensions in the Programming Language Lisp. PhD thesis, Indiana University, August 1986.
[^17]:     Jacob Matthews and Robert Bruce Findler. An operational semantics for R5RS Scheme. In J. Michael Ashley and Michael Sperber, editors, Proceedings of the Sixth Workshop on Scheme and Functional Programming, pages 41–54, Tallin, Estonia, September 2005. Indiana University Technical Report TR619.
[^18]:     Jacob Matthews and Robert Bruce Findler. An operational semantics for Scheme. Journal of Functional Programming, 2007. From http://www.cambridge.org/journals/JFP/.
[^19]:     Jacob Matthews, Robert Bruce Findler, Matthew Flatt, and Matthias Felleisen. A visual environment for developing context-sensitive term rewriting systems. In Proceedings 15th Conference on Rewriting Techniques and Applications, Aachen, June 2004. Springer-Verlag.
[^20]:     MIT Department of Electrical Engineering and Computer Science. Scheme manual, seventh edition, September 1984.
[^21]:     Jonathan A. Rees, Norman I. Adams IV, and James R. Meehan. The T manual. Yale University Computer Science Department, fourth edition, January 1984.
[^22]:     Michael Sperber, R. Kent Dybvig, Matthew Flatt, and Anton van Straaten. Revised<sup>6</sup> report on the algorithmic language Scheme (Non-Normative appendices). http://www.r6rs.org/, 2007.
[^23]:     Michael Sperber, R. Kent Dybvig, Matthew Flatt, and Anton van Straaten. Revised<sup>6</sup> report on the algorithmic language Scheme (Rationale). http://www.r6rs.org/, 2007.
[^24]:     Michael Sperber, R. Kent Dybvig, Matthew Flatt, Anton van Straaten, Richard Kelsey, William Clinger, and Jonathan Rees. Revised<sup>6</sup> report on the algorithmic language Scheme (Libraries). http://www.r6rs.org/, 2007.
[^25]:     Guy Lewis Steele Jr. Common Lisp: The Language. Digital Press, Burlington, MA, second edition, 1990.
[^26]:     Texas Instruments, Inc. TI Scheme Language Reference Manual, November 1985. Preliminary version 1.0.
[^27]:     The Unicode Consortium. The Unicode standard, version 5.0.0. defined by: The Unicode Standard, Version 5.0 (Boston, MA, Addison-Wesley, 2007. ISBN 0-321-48091-0), 2007.
[^28]:     William M. Waite and Gerhard Goos. Compiler Construction. Springer-Verlag, 1984.
[^29]:     Andrew Wright and Matthias Felleisen. A syntactic approach to type soundness. Information and Computation, 115(1):38–94, 1994. First appeared as Technical Report TR160, Rice University, 1991.

