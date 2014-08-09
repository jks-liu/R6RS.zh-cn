---
layout: page
title: 算法语言Scheme修订<sup>6</sup>报告
tagline: R6RS简体中文翻译
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
<center>已完成38%，最后修改于2014年08月09日</center>

# 摘要 <!-- SUMMARY -->

报告给出了程序设计语言Scheme的定义性描述。Scheme是由Guy Lewis Steele Jr.和Gerald Jay Sussman设计的具有静态作用域和严格尾递归特性的Lisp程序设计语言的方言。它的设计目的是以异常清晰，语义简明和较少表达方式的方法来组合表达式。包括函数（functional）式，命令（imperative）式和消息传递（message passing）式风格在内的绝大多数程序设计模式都可以用Scheme方便地表述。

和本报告一起的还有一个描述标准库的报告[^24]；用描述符“库的第多少小节（library section）”或“库的第多少章（library chapter）”来识别此文档的引用。和它一起的还有一个包含非规范性附录的报告[^22]。第四次报告在语言和库的许多方面阐述了历史背景和基本原理[^23]。

上面列到的人不是这篇报告文字的唯一作者。多年来，下面这些人也参与到Scheme语言设计的讨论中，我们也将他们列为之前报告的作者：

Hal Abelson, Norman Adams, David Bartley, Gary Brooks, William Clinger, R. Kent Dybvig, Daniel Friedman, Robert Halstead, Chris Hanson, Christopher Haynes, Eugene Kohlbecker, Don Oxley, Kent Pitman, Jonathan Rees, Guillermo Rozas, Guy L. Steele Jr., Gerald Jay Sussman和Mitchell Wand。

为了突出最近的贡献，他们没有被列为本篇报告的作者。然而，他们的贡献和服务应被确认。

我们认为这篇报告属于整个Scheme社区，并且我们授权任何人复制它的全部或部分。我们尤其鼓励Scheme的实现者使用本报告作为手册或其它文档的起点，必要时也可以对它进行修改。

# 目录 <!-- CONTENTS -->

* 这回生成一个目录，且这行文字会被忽略
{:toc}

# 概述 <!-- INTRODUCTION -->

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

# **语言描述** <!-- DESCRIPTION OF THE LANGUAGE -->

# 1. <!-- Overview of -->Scheme概论

本章概述了Scheme的语义。此概述的目的在于充分解释语言的基本概念，以帮助理解本报告的后面的章节，这些章节以参考手册的形式被组织起来。因此，本概述不是本语言的完整介绍，在某些方面也不够精确和规范。

像Algol语言一样，Scheme是一种静态作用域的程序设计语言。对变量的每一次使用都对应于该变量在词法上的一个明显的绑定。

Scheme中采用的是隐式类型而非显式类型[^28]。类型与对象（也称值）相关联，而非与变量相关联。（一些作者将隐式类型的语言称为弱类型或动态类型的语言。）其它采用隐式类型的语言有Python, Ruby, Smalltalk和Lisp的其他方言。采用显式类型的语言（有时被称为强类型或静态类型的语言）包括Algol 60, C, C#, Java, Haskell和ML。

在Scheme计算过程中创建的所有对象，包括过程和继续（continuation），都拥有无限的生存期（extent）。Scheme对象从不被销毁。Scheme的实现（通常！）不会耗尽空间的原因是，如果它们能证明某个对象无论如何都不会与未来的任何计算发生关联，它们就可以回收该对象占据的空间。其他允许多数对象拥有无限生存期的语言包括C#, Java, Haskell, 大部分Lisp方言, ML, Python, Ruby和Smalltalk。

Scheme的实现必须支持严格尾递归。这一机制允许迭代计算在常量空间内执行，即便该迭代计算在语法上是用递归过程描述的。借助严格尾递归的实现，迭代就可以用普通的过程调用机制来表示，这样一来，专用的迭代结构就只剩下语法糖衣的用途了。

Scheme是最早支持把过程在本质上当作对象的语言之一。过程可以动态创建，可以存储于数据结构中，可以作为过程的结果返回，等等。其他拥有这些特性的语言包括Common Lisp, Haskell, ML, Ruby和Smalltalk。

在大多数其他语言中只在幕后起作用的继续，在Scheme中也拥有“第一级”状态，这是Scheme的一个独树一帜的特征。第一级继续可用于实现大量不同的高级控制结构，如非局部退出（non-local exits）、回溯（backtracking）和协作程序（coroutine）等。

在Scheme中，过程的参数表达式会在过程获得控制权之前被求值，无论这个过程需不需要这个值。C, C#, Common Lisp, Python, Ruby和Smalltalk是另外几个总在调用过程之前对参数表达式进行求值的语言。这和Haskell惰性求值（lazy-evaluation）的语义以及Algol 60按名求值（call-by-name）的语义不同，在这些语义中，参数表达式只有在过程需要这个值的时候才会被求值。

Scheme的算术模型被设计为尽量独立于计算机内数值的特定表示方式。此外，他还区分精确数和非精确数对象：本质上，一个精确数对象精确地等价于一个数，一个非精确数对象是一个涉及到近似或其它误差的计算结果。

## 1.1. 基本类型 <!-- Basic types -->

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

## 1.3. <!-- Variables and -->变量和绑定（binding）

Scheme允许标识符代表一个包含值得位置。这些标识符叫做变量。在许多情况下，尤其是这个位置的值在创建之后再也不被修改的时候，认为变量直接代表这个值是非常有用的。

~~~ scheme
(let ((x 23)
      (y 42))
  (+ x y)) ‌        ⇒ 65
~~~

在这种情况下，以`let`开头的表达式是一种绑定结构。跟在`let`之后的括号结构列出了和表达式一起的变量：和23一起的变量`x`，以及和42一起的变量`y`。`let`表达式将`x`绑定到23，将`y`绑定到42。这些绑定在`let`表达式的*内部（body）*是有效的，如上面的`(+ x y)`，也仅仅在那是有效的。

## 1.4. 定义 <!-- Definitions -->

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

## 1.6. 过程 <!-- Procedures -->

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

## 1.7. <!-- Procedure calls and -->过程调用和语法关键词（syntactic keywords）

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

## 1.9. 衍生形式（Derived forms）<!-- and -->和宏（macros）

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

## 1.10. 语法数据（Syntactic data）<!-- and -->和数据值（datum values）

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

## 1.12. 库 <!-- Libraries -->

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

## 1.13. 顶层程序 <!-- Top-level programs -->

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

# 2. 需求等级 <!-- Requirement levels -->

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

## 3.3. 定长数和浮点数 <!-- Fixnums and flonums -->

一个*定长数*是一个精确的整数对象，这个整数对象在精确的整数对象的一个特定的实现相关的子范围（subrange）。（库的第11.2小节描绘了一个计算定长数的库。）同样地，每个实现应当指定一个非精确实数对象的子集作为*浮点数*，并将特定的外部表示转换成浮点数。（库的第11.3小节描绘了一个计算浮点数的库。）注意，这并不意味着实现必须使用浮点表示。

## 3.4. 实现要求 <!-- Implementation requirements -->

Scheme的实现必须支持3.1节给出的子类型的整个塔的数字对象。此外，实现必须支持几乎无限（Practically unlimited）大小和精度的精确整数对象和精确有理数对象，并实现特定的过程（在11.7.1节列出），当给它们精确参数的时候这些过程总是返回精确结果。（“几乎无限”意味着这些数字的大小和精度应当仅受可用内存大小的限制。）

实现可以只支持任意类型非精确数字对象的一个有限的值域（range），但需要遵从本节的要求。比如，一个实现可以限制非精确实数对象的值域（且因此限制非精确整数和有理数对象的值域）在浮点格式的动态值域内。此外，在使用这种值域限制的实现中，非精确整数对象和有理数之间的差异很可能会很大。

一个实现可以为非精确数字使用浮点或其它近似表示方法。本报告推荐但不要求实现遵从IEEE的浮点格式标准，使用其他表示方法的实现应当在精度上达到或超过这些浮点标准[^13]。

特别地，使用浮点数表示法的Scheme实现必须遵循以下规则：浮点数结果的表示精度必须达到或超过参与该运算的任意非精确参数的表示精度。只要有可能，像`sqrt`这样潜在的非精确操作当传递一个精确的参数时，应该返回一个精确的结果（比如精确数4的平方根应当是精确的2）。可是，这不是必须的。另一方面，如果参数是精确数的运算会产生非精确的结果（如通过sqrt），且该结果被表示为浮点数，那么就必须使用当前可用的精度最高的浮点数格式；不过，如果该结果是用其他形式表示的，那么该表示方法在精度上就必须达到或超过当前可用的精度最高的浮点数格式。

避免使用量级或有效数字大到实现无法表示的非精确数是程序员的责任。

## 3.5. 无穷大（Infinities）<!-- and -->和非数（NaNs）

一些Scheme实现，尤其是那些遵从IEEE浮点格式标准的实现区别叫做*正无穷大*，*负无穷大*和*非数*的特殊数字对象。

正无穷大被认为是一个非精确的实数（但不是有理数）对象，它表示大于所以有理数对象表示的数字的一个模糊的数字。负无穷大被认为是一个非精确的实数（但不是有理数）对象，它表示小于所以有理数对象表示的数字的一个模糊的数字。

一个非数被认为是一个非精确数（但不是一个实数）对象，它是如此不确定以至于它可以表示任何数，包括正负无穷大，且甚至可能大于正无穷大或小于负无穷大。

## 3.6. 可区别的-0.0 <!-- Distinguished -0.0 -->

一些Scheme实现，尤其是那些遵从IEEE浮点格式标准的实现区别数字对象0.0和-0.0。也就是说，正的和负的非精确的零。本报告有时会指定在这些数字对象上的特定算术操作的行为。这些说明会被写作“如果-0.0的话是不一样的”或“实现区分-0.0”。

# 4. 词汇（Lexical）<!-- syntax and -->语法和数据（datum）<!-- syntax -->语法

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

## 4.2. 词汇语法 <!-- Lexical syntax -->

词汇语法决定了怎样将字符的序列分隔成语义的序列，省略不重要的部分如注释和空白。字符序列被假定是Unicode标准[^27]的文本。词汇语法的一些语义，比如标识符，数字对象的表示，字符串等等，是数据语法中的句法数据，且因此代表对象。除了语法的形式解释（formal account），本节还描述了这些句法数据表示什么数据值。

注释中描述的词汇语法包含`<datum>`的一个向前引用，这是数据语法的一部分。然而，作为注释，这些`<datum>`在语法中并不起什么重要的作用。

除了布尔，数字对象以及用16进制表示的Unicode标量是不区分大小写的，其它情况下大小写是敏感的。比如，`#x1A`和`#X1a`是一样的。然而，标识符`Foo`和标识符`FOO`是有区别的。

### 4.2.1. 形式解释 <!-- Formal account -->

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

### 4.2.2. 换行符 <!-- Line endings -->

在Scheme单行注释（见4.2.3小节）和字符串字面量中，换行符是重要的。在Scheme源代码中，在`<line ending>`中的任意换行符都指示一个行的结束。此外，两字符的换行符`<carriage return> <linefeed>`和`<carriage return> <next line>`都仅表示一个单独的换行。

在一个字符串字面量中，一个之前没有`\`的`<line ending>`表示一个换行字符（linefeed character），这个字符是Scheme中的标准换行符。

### 4.2.3. 空白和注释 <!-- Whitespace and comments -->

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

### 4.2.4. 标识符 <!-- Identifiers -->

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

### 4.2.5. 布尔 <!-- Booleans -->

标准布尔对象真和假有外部表示`#t`和`#f`。

### 4.2.6.字符 <!-- Characters -->

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

### 4.2.7. 字符串 <!-- Strings -->

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

### 4.2.8. 数字 <!-- Numbers -->

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

## 4.3. 数据语法 <!-- Datum syntax -->

数据语法按照`<lexeme>`的序列描述句法的语法。

句法数据包括本报告前面章节描述的语义数据以及以下用于组织复合数据的结构。

* 点对和表，被`( )`或`[ ]`（见4.3.2节）括起来
* 向量（见4.3.3节）
* 字节向量（bytevectors）（见4.3.4节）

### 4.3.1. 形式解释 <!-- Formal account -->

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

### 4.3.2. 点对和表 <!-- Pairs and lists -->

表示值对和值的列表（见11.9节）的列表和点对数据使用小括号和中括号表示。规则`<list>`中匹配的中括号对等价于匹配的小括号对。

Scheme点对的句法数据最常用的符号是“点”符号<tt>(<datum<sub>1</sub>> . <datum<sub>2</sub>>)</tt>，其中<tt><datum<sub>1</sub>></tt>是car区域的值的表示，<tt><datum<sub>2</sub>></tt>是cdr区域的值的表示。比如`(4 . 5)`是一个car是4，cdr是5的点对。

表可以使用一个改进的记号：表中的元素被简单地括进小括号中并用空格分隔。空表用`()`表示。比如：

`(a b c d e)`

和

`(a . (b . (c . (d . (e . ())))))`

作为符号的表是等价的表示。

一个通用的规则是，如果一个点跟着一个左小括号，则在外部表示中可以省略这个点，左小括号和对应的右小括号。

符号序列“`(4 . 5)`”是一个点对的外部表示，而不是一个计算结果为点对的表达式。类似的，符号序列“`(+ 2 6)`”*不*是整数8的外部表示，虽然它*是*一个计算结果是整数8的表达式（在`(rnrs base (6))`库语言中）；当然，它是一个句法数据，这个句法数据表示一个三个元素的表，这个表的元素是符号`+`，整数2和6。

### 4.3.3. 向量 <!-- Vectors -->

表示向量对象（见11.13小节）的向量数据使用`#(<datum> ...)`表示。比如：一个长度是3，且0号元素位置是数字对象零，1号元素位置是表`(2 2 2 2)`，2号元素位置是字符串`"Anna"`，的向量可以如下表示：

`#(0 (2 2 2 2) "Anna")`

这是一个向量的外部表示，而不是一个计算结果为向量的表达式。

### 4.3.4. 字节向量 <!-- Bytevectors -->

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

# 5. 语义概念 <!-- Semantic concepts -->

## 5.1. 程序和库 <!-- Programs and libraries -->

一个Scheme程序由一个*顶层程序*以及一系列的*库*组成，每个库通过显式地指定导入和导出定义了和其它程序相联系的程序的一部分。一个库由一系列的导入导出说明和程序体组成，程序体由定义和表达式组成。一个顶层程序和一个库差不多，但是没有导出说明。第7章和第8章分别描述了库和顶层程序的语法和语义。第11章描述了定义了通常和Scheme一起的结构的一个基本库。一个单独的报告[^24]描述了Scheme系统提供的各种标准库。

基本库和其它标准库的划分是根据使用而不是结构。尤其那些通常被编译器或运行时系统实现为“原语（primitives）”而不是根据其它标准调用或句法形式的功能不是基本库的一部分，而是被定义在单独的库中。例子包括定长数和浮点数库，异常和条件库，以及用于记录的库。

## 5.2. 变量，关键词和作用域 <!-- Variables, keywords, and regions -->

在一个库或顶层程序的内部，一个标识符可以命名一种语法，或者它可以命名一个值可以被存储的位置。命名一种语法的标识符叫做*关键词*，或*句法关键词*，也可以说是关键词被*绑定*到那个语法（或者说是一个句法抽象，这个抽象将语法转换成更基本的形式；见7.2小节）。命名一个位置的标识符叫做*变量*，也可以说是变量被*绑定*到那个位置。在一个顶层程序或一个库的每一个位置，一个特定的固定集合的标识符被绑定。这些标识符的集合，也就是*可见绑定（visible bindings）*的集合，被称为影响该位置的*环境（environment）*。

特定的形式被用作创建语法抽象并绑定关键词到用于这些新的语法抽象的转换，同时其它的形式创建新的位置并将变量绑定到那些位置。这些表达式被统称为*绑定结构（binding constructs）*。一些绑定结构使用*定义*的形式，其它的是表达式。除了导出的库绑定是一个例外，一个定义创建的绑定只在这个定义出现的内部可见，例如，库，顶层程序或`lambda`表达式的内部。导出的库绑定在导入这些绑定的库和程序的内部是可见的（见第7章）。

绑定变量的表达式包括来自基础库的`lambda`，`let`，`let*`，`letrec`, `letrec*`, `let-values`和`let*-values`形式（见11.4.2和11.4.6小节）。在这些当中，`lambda`是最基本的。

出现在这样的表达式内部，或出现在库或顶层程序内部的变量定义被当作一系列的`letrec*`对待。另外，在库的内部，从库中导出的变量可以被导入的库或顶层程序引用。

绑定关键词的表达式包括`let-syntax`和`letrec-syntax`形式（见11.18小节）。一个`define`形式（见11.2.1小节）是一个创建变量绑定（见11.2小节）的定义，同时一个`define-syntax`形式是一个创建关键词绑定（见11.2.2小节）的定义。

Scheme是一个拥有块结构的静态作用域的语言。顶层程序或库的内部的每一个地方，一个标识符被绑定到代码的*作用域*，在这个作用域中绑定是可见的。这个作用域被特定的建立绑定的绑定结构决定；比如，如果一个绑定通过`lambda`表达式建立，那么作用域是整个`lambda`表达式。每当标识符引用标识符的绑定的时候，它总是引用包含这次使用的最内层绑定。如果找不到作用域包含该引用的标识符绑定，它可以引用库或顶层程序最上面的定义或导入建立的绑定（见第7章）。如果找不到标识符的绑定，它就被称为*未绑定的*。

## 5.3. 异常情况 <!-- Exceptional situations -->

在本报告中各种异常情况是有区别的，包括违反语法，违反过程调用，违反实现限制和环境中的异常情况。当实现检测到一个异常情况时，一个*异常被抛出*，这意味着一个被称为*当前异常处理程序（current exception handler）*的特殊过程被调用。一个程序也可以抛出一个异常且覆盖当前异常处理程序；见库的第7.1小节。

当一个异常被抛出时，会提供一个描述异常情况性质的对象。本报告使用库的第7.2小节描述的条件系统来描述异常情况，通过条件类型来区分它们。

如果异常处理程序采取适当动作的话，一些异常情况允许程序继续运行。对应的异常被称为是*可继续的（continuable）*。对于本报告描述的大部分异常情况，可移植的程序不应该依赖在异常被检测到的地方异常是可继续的。在那些异常中，被异常调用的异常处理程序不应该返回。可是，在有些情况下，继续是被允许的，这时处理程序应该返回。见库的第7.1小节。

当实现由于*实现限制（implementation restriction）*无法正确执行一个正确的程序时，实现必须抛出一个异常。比如，一个不支持无穷大的实现计算一个结果是无穷大的表达式时必须抛出一个条件类型是`&implementation-restriction`的异常。

一些可能的异常比如缺乏非数和无穷大的表示（见11.7.2小节）是本报告预知的，且实现必须在遭遇到这样的情况的时候抛出条件类型适当的异常。

本报告使用的措辞“一个异常被抛出”等价于“一个异常必须被抛出”。本报告使用措辞“一个条件类型为*t*的异常”指示跟随异常抛出的对象是一个有特定类型的条件对象。措辞“一个可继续的异常被抛出”指示一个异常情况允许异常处理程序返回。

## 5.4. 参数检查 <!-- Argument checking -->

本报告中的许多或一个标准库中的部分调用限制它们接受的参数。典型地，一个调用只接受特定的数字和参数类型。许多句法形式同样限制它们的一个或多个子形式计算结果的值。这些限制暗示着程序员和实现共同的责任。尤其，程序员负责确保这些值确实符合本规范描述的限制。实现必须检查本规范描述的限制确实被遵守，在某种程度上来说允许特定的操作成功完成是合理的，可能的，也是必要的。

在第6章以及整个报告中，实现的责任会被更加仔细地描述。

注意，一个实现完全检查一个规范的限制并不总是可行的。比如，如果一个操作接受一个有特定属性的过程，检查这些属性通常是不可行的。同样地，一些操作同时接受表和过程，并且这些操作会调用这些过程。因为表可以被来自`(rnrs mutable-pairs (6))`库（见库的第17章）的过程改变，所以，一个操作开始时还是表的参数可能在操作执行过程中变成一个非表。并且，过程可能逃逸到一个不同的继续中，从而阻止操作进行检查。要求操作检查参数在这样的过程的每一次调用后都是一个表是不现实的。并且，一些接受表参数操作仅仅需要部分地遍历表中的元素；要求实现去遍历表中的其它元素以检查所有的限制被满足可能违反合理的性能假设。由于这些原因，这些检查是程序员的义务而不是实现的检查义务。

当一个实现检测到参数违反限制的时候，它必须以5.6小节描述的符合执行安全性的方法抛出一个条件类型是`&assertion`的异常。


## 5.5. 违反语法 <!-- Syntax violations -->
<!-- TODO -->

一个特定形式的子形式通常需要遵循特定的句法限制。由于形式可能要遵从宏扩展，其可能不会终结，所以，它们是否符合特定的限制的问题通常是无法解答的。

可是，当宏扩展终结时，实现必须检测违反语法的地方。一个*语法错误*是一个关于库内部，顶层程序内部，或本报告基本库或标准库“语法”入口的错误。此外，试图给一个不可改变的变量（也就是一个库导出的变量；见7.1小节）也被认为是一个语法错误。

<!--
  原文好像有个错误：a top-level，少一个program。
-->
如果一个程序中的一个顶层或库形式是句法上不正确的，那么实现必须抛出一个条件类型是`&syntax`的异常，且顶层程序或库必须不能被允许开始。

## 5.6. 安全性 <!-- Safety -->

导出被本文档描述的标准库被认为是*安全库*。只从安全库导入的库或顶层程序也被认为是安全的。

正如本文档所定义的，Scheme编程语言在下列的场景下是安全的：一个顶层程序的执行不能严重错误到以至于崩溃或不能以和本报告描述的语义相一致的行为执行，除非一个异常被抛出。

违反实现限制的时候必须抛出一个条件类型是`&implementation-restriction`的异常，且必须是所有的违规和错误，其可能威胁系统的完整性，使得执行的结果无法和本报告中描述的语义相一致。

上面的安全性属性只有在顶层程序或库被认为是安全的时候被确保。特别地，实现可以提供访问非安全库的方法，这种方法不能保证安全性。

## 5.7. 布尔值 <!-- Boolean values -->

 尽管有单独的布尔值的存在，但是，Scheme的任何值可在条件测试中被当作一个布尔值使用，除了`#f`，所有的值在测试中被当成真。本报告使用词语“真”表示任意除了`#f`的Scheme值，用词语“假”表示`#f`。

## 5.8. 多个返回值 <!-- Multiple return values -->

一个Scheme表达式的结果可以是任意多个有限数量的值。这些值被传递给表达式的继续。

<!-- TODO -->
不是所有的继续都接受任意数量的值。比如，一个接受调用参数的继续可以确保精确地接受一个值。传递其它数量的值到这样一个继续的效果是未定义的。11.15小节描述的过程`call-with-values`使创建接受特定数量返回值的继续成为可能。如果传递给一个`call-with-values`过程创建的继续的返回值的数量不被这个继续接受，那么一个异常被抛出。11.15的小节过程`values`的描述给了一个关于不同继续接受的值的数量的更全面的描述。

基本库的许多的形式有作为子形式的表达式的序列，这个序列被按顺序求值，但除了最后一个表达式的值，其它所有的值都会被忽略。丢弃这些值得继续接受任意数量的值。

## 5.9. 未定义（Unspecified）<!-- behavior -->的行为

如果说一个表达式“返回未定义的值”，那么这个表达式必须正确计算而不是抛出一个异常，但是返回值是依赖于实现的；本报告故意不说多少值或什么值被返回。程序员不应该依赖返回值是特定的数量或依赖返回值是特定的值。

## 5.10. 存储模型 <!-- Storage model -->

变量和对象，比如点对，向量，字节向量，字符串，哈希表和含蓄地引用位置或位置序列的记录。一个字符串，比如说，包含很多位置因为在一个字符串中有许多的字符。（这些位置不需要对应于一个完整的机器字。）通过使用`string-set!`过程，一个新的值可以被存进这些位置的一个当中，但是，字符串的位置和以前还是一样的。

从一个位置获取的对象，不管是通过一个变量，还是通过一个类似`car`，`vector-ref`或`string-ref`的过程，在`eqv?`的意义来说与在获取之前最后存进的对象是等价的。但，当对象是一个过程时，这是一个例外。当对象是一个过程的时候，从这个位置获取的过程和最后存到这个位置的过程的行为是一样的，但是，它们可能不是相同的对象。（本节已根据勘误表进行修改。）

每一个位置都被标记以指示它是否在被使用。没有变量或对象会指向一个不在使用的位置。不管何时本报告谈及为变量或对象分配位置，这意味着一个适当数量的位置被从未被使用的位置的集合选择，且被选择的位置在变量或对象引用它们之前被标记为现在正在使用。

常数（也就是，字面量表达式的值）被存进只读存储器是可取的。为了表达这个，想象一下，每一个引用位置的对象被用一个标记指示为可变的或不可变的是很方便的。字面常量，`symbol->string`返回的字符串，不可变区域的记录和其它被显式地被指定为不可变的值是不可变的对象，被本报告列出的其它过程创建的对象是可以改变的。尝试给一个引用不可改变对象的位置赋值应该抛出一个条件类型是`&assertion`的异常。

## 5.11. 严格尾递归（Proper tail recursion）

Scheme的实现必须是*严格尾递归的*。发生在叫做*尾上下文（tail contexts）*的特定句法上下文的过程调用是*尾调用（tail calls）*。一个Scheme实现是严格尾递归的，如果它支持无限数量的活动尾调用。一个调用时*活动的（active）*如果被调用的过程可以返回。注意，这里所说的返回既包括了通过当前继续从调用中返回的情况，也包括了事先以`call-with-current-continuation`过程捕获继续，后来再调用该继续以便从调用中返回的情况。不存在被捕获的继续时，调用最多只能返回一次，活动调用就是那些还没有返回的调用。一个严格尾递归的正式定义可以在Clinger的论文[^5]中被发现。来自`(rnrs base (6))`库的结构上识别尾调用的规则在11.20小节被描述。

## 5.12. 动态生存期（Dynamic extent）<!-- and the dynamic environment -->和动态环境

对于一个过程调用，在它开始和它返回的过程之间的时间叫做它的*动态生存期*。在Scheme中，`call-with-current-continuation`（11.15小节）允许在它的过程调用返回之后重新进入一个动态生存期。因此，一个调用的动态生存期可能不是一个单独的，连贯的时间段。

<!-- TODO -->
本报告描述的一些操作除了从它们显式的参数中获得信息，还会从*动态环境*中获得信息。比如，`call-with-current-continuation`会访问一个`dynamic-wind`（11.15小节）创建的隐式的上下文，且*抛出*过程（库的第7.1小节）访问当前的异常处理程序。改变动态环境的操作是动态的，为了类似`dynamic-wind`或`with-exception-handler`的过程的调用的动态作用域。当这样的调用返回时，前一个动态环境被恢复。动态环境可以被认为是一个调用的动态生存期的一部分。因此，它可以被`call-with-current-continuation`捕获，并可以通过调用它创建的逃逸过程恢复。

# 6. 条目格式（Entry format）

描述基础库和标准库绑定的章节被用条目组织。每个条目描述一个语言特性或一组相关的特性，其中，一个特性是一个句法结构，或者是一个内置过程。一个条目以一个或多个标题行（header lines）开始，标题行有如下格式：

*`模板        类别`*

*`template‌‌    category`*

*类别*定义了条目描述的绑定的种类，其中类别通常要么是“语法”要么是“过程”。一个条目可以指定子形式或参数的各种限制。对于这些的背景知识，见5.4小节。

## 6.1. 语法条目 <!-- Syntax entries -->

如果*条目*是语法，则这个条目描述一个特定的句法结构，且模板给了这个结构的形式的语法。模板使用类似于第4章BNF规则右侧的符号，且描述了等价于匹配作为句法数据的模板的形式的形式的集合。一些“语法”条目带有一个后缀（<tt>扩展（expand）</tt>），指明结构的句法关键词是以级别0（level 0）被导出的。否则，句法关键词以级别1被导出。

一个模板描述的形式的要素（component）被句法变量（syntactic variables）指定，这些句法变量使用尖括号书写，比如：`<expression>`, `<variable>`。句法变量中的大小写是无关紧要的。句法变量代表其它的形式或它们的序列。一个句法变量可以在语法中为句法数据（见4.3.1小节）引用一个非终结符，在这种情况下，只有匹配非终结符的形式才被允许在那个位置。比如，`<identifier>`代表一个必须是标识符的形式。同样，`<expression>`代表一个句法上是一个合法表达式的形式。其它用在模板中的非终结符被定义为本规范的一部分。

符号

`<thing1> ...`

代表零个或多个`<thing>`，且

`<thing1> <thing2> ...`

代表一个或多个`<thing>`。

确保一个形式的每一个要素有模板指定的形状是程序员的责任。语法的描述可以表达一个形式的要素的其它限制。通常，这样的限制被格式化成如下形式的短语“`<x>`必须是一个...”。再次强调，这些是程序员的责任。只要宏转换涉及扩展形式终结符，检查这些限制被满足就是实现的责任。如果实现检测到一个要素不满足限制，一个条件类型是`&syntax`的异常被抛出。

## 6.2. 过程条目 <!-- Procedure entries -->

如果*类别*是“过程”，则条目描述一个过程，标题行给出一个过程调用的模板。模板中参数的名字是*斜体*。因此，标题行

<tt>(vector-ref <i>vector k</i>)</tt> 过程

表示一个内建的过程`vector-ref`接受两个参数，一个是向量*`vector`*，和一个精确的非负整数对象*`k`*（参见下面的内容）。标题行

<tt>(make-vector <i>k</i>)</tt> 过程  
<tt>(make-vector <i>k fill</i>)</tt> 过程

表示过程`make-vector`可以接受一个或两个参数。参数名字的大小写是不敏感的：*`Vector`*和*`vector`*是一样的。

正如语法模板，如下标题行结尾的省略号

<tt>(= <i>z1 z2 z3 ..</i>)</tt> 过程

表示过程接受和最后一个参数名相同类型的任意多个参数。在上面那个例子中，`=`接受两个或更多的复数对象参数。一个过程当检测到它没有指定的参数时必须抛出一个条件类型是`&assertion`的异常，并且，参数规格是详尽的：如果一个过程调用提供的参数数量不匹配过程接受参数的任何一个数量，一个条件类型是` &assertion`的异常必须被抛出。

简单地说，本报告遵循如下的惯例，如果一个参数的名字也是一个类型的名字，那么，对应的参数必须是这个类型。比如，上面的`vector-ref`的标题行指明`vector-ref`的第一个参数必须是一个向量。下面的命名惯例暗示类型的限制：

| *`obj`* | 任何对象
| *`z`* | 复数对象
| *`x`* | 实数对象
| *`y`* | 实数对象
| *`q`* | 有理数对象
| *`n`* | 整数对象
| *`k`* | 精确的非负整数对象
| *`bool`* |  布尔(`#f`或`#t`)
| *`octet`* | 范围在{0, ..., 255}的精确的整数对象
| *`byte`* |   范围在{−128, ..., 127}的精确的整数对象
| *`char`* |  字符(见11.11小节)
| *`pair`* |  点对(见11.9小节)
| *`vector`* |  向量(见11.13小节)
| *`string`* |  字符串(见11.12小节)
| *`condition`* | 条件(见库的第7.2小节)
| *`bytevector`* |  字节向量(见库的第2章)
| *`proc`* |  过程(见1.6小节)

其它类型限制通过特定章节描述的变量名字惯例表达。比如，库的第11章为数字的各种子集使用了很多特别的参数变量。

当使用上面列出的限制的时候，确保对应的参数拥有指定的类型是程序员的责任。检查那些类型是实现的责任。

一个叫做*表*的参数意味着传递一个类型是表（见11.9小节）的参数是程序员的责任。在某种程度上,将检查参数是为了操作执行它的功能适当组织的作为实现的责任是可能的也是合理的。实现必须至少检查参数或者是一个空表或者是一个点对。

过程的描述可以在过程的参数上表达其它的限制。代表性地，这样的限制被格式化成如下形式的短语“`x`必须是一个...”（或者，否则使用词语“必须”）。

## 6.3. 实现责任 <!-- Implementation responsibilities -->

除了通过命名惯例进行隐含的限制，一个条目可以列出另外的显式的限制。这些显式的限制通常同时描述程序员的责任和实现的责任，程序员的责任意味着程序员必须确保一个形式的子形式是适当的，或一个适当的参数被传递，实现的责任意味着实现必须检查子形式符合规范的限制（如果宏扩展终结的话），或检查参数是不是适当的。通过为参数或子形式打上“实现责任”的标签，一个描述可以显式地列出实现的责任。在这种情况下，在描述的其它部分为这些子形式或参数指定的责任就只是程序员的责任。一个描述实现责任的段落不影响那一段没有描述的实现检查子形式或参数的责任。

## 6.4. 其它种类的条目 <!-- Other kinds of entries -->

如果*类别*既不是“语法”也不是“过程”，那么，那个条目描述一个非过程值，且*类别*描述了这个值的种类。标题行

`&who‌‌` 条件类型

指示`&who`是一个条件类型。标题行

`unquote` 辅助语法

指示`unquote`是一个语法绑定，这个语法绑定只会作为特定周边表达式<!-- TODO -->的部分出现。任何作为一个独立的句法结构或标识符的使用是一个语法错误。和“语法”条目一样，一些“辅助语法”条目带有一个语法后缀（扩展），指明结构的句法关键词以级别1导出。

## 6.5. 等价的条目 <!-- Equivalent entries -->

一个条目的描述偶尔会说它和另外一个条目是*一样*的。这意味着这两个条目是等价的。特别地，它意味着如果两个条目有一样的形式，且从不同的库导出，则两个库的条目可以使用同样的名字导入而没有冲突。

## 6.6. 求值（Evaluation）<!-- examples -->的例子

用在程序例子中的符号“⇒”可以被读作“的值是”。比如，

`(* 5 8)         ⇒  40`

意味着表达式`(* 5 8)`的值是对象40。或者，更精确地说：符号序列“`(* 5 8)`”给出的表达式求值，在导入了相应的库的环境中，得到一个对象，这个对象在外部使用符号的序列“`40`”表示。见4.3小节对对象外部表示的讨论。

“⇒”符号也在表达式的计算导致错误的时候使用。比如，

`(integer->char #xD800)`  ⇒  `&assertion`*异常*

意味着表达式`(integer->char #xD800)`的求值必须抛出一个条件类型是`&assertion`的异常。

此外，“⇒”符号也被用作显式地说明一个表达式的值是未定义的。比如：

`(eqv? "" "")`             ‌⇒  未定义的

通常，例子仅仅阐述了条目中指定的行为。可是在有些时候，它们帮助规范中模糊不清的地方消歧义，所以此时它们是规范性的。注意，在有些情况下，特别是在非精确数字对象的情况下，返回值只会有条件地或近似的指明。比如

~~~ scheme
(atan -inf.0)
         ⇒ -1.5707963267948965 ; 近似地
~~~

## 6.7. 命名惯例 <!-- Naming conventions -->

依照惯例，将值存进上次分配的位置的过程的名字通常使用“`!`”。

依照惯例，“`->`”出现在以一个类型的对象作为参数，返回另一个类型的类似对象的过程名字中。

按照惯例，谓词（predicates）—总是返回一个布尔的过程—以“`?`”结尾，只有当名字不包含任何字母的时候，谓词才不以问号结尾。

按照惯例，复合名字的要素使用“`-`”进行分隔。尤其，是一个实际单词或可以像一个实际单词一样发音的单词的前缀会跟着一个连字符，除非跟在连字符后面的第一个字符不是一个字母，在这种情况下，连字符可以省略。简单地说，连字符不会跟在不可发音的前缀（“fx”和“fl”）后面。

按照惯例，条件类型的名字以“`&`”开头。

# 7. 库 <!-- Libraries --> 

库是一个程序可以被独立发布的部分。库系统支持库内的宏定义，宏导出，且区别需要定义和导出的不同阶段。本章为库定义了符号，且为库的扩展（expansion ）和执行定义了语义。

## 7.1. 库形式 <!-- Library form -->

一个库定义必须有下面的形式：

~~~ scheme
(library <library name>
  (export <export spec> ...)
  (import <import spec> ...)
  <library body>)
~~~

一个库的声明包含下面的要素：

* `<library name>`指定了库的名字（可能还有版本）。
* `export`子形式指定一个导出的列表，这个列表命名了定义在或导入到这个库的绑定的子集。
* `import`子形式指定了作为一个导入依赖列表导入的绑定，其中每一个依赖指定：
  - 导入的库的名字，且可以可选地包含它的版本，
  - 相应的级别，比如，扩展（expand）或运行时（run time）（见7.2小节）和
  - 为了在导入库中可用的库导出的子集，和为在导入库中可用的为每一个库导出准备的名字。
* `<library body>`是库的内部，由一系列定义和紧随其后的表达式组成。标识符可以既是本地的（未导出的）也是导出绑定的，且表达式是为它们的效果求值的初始化表达式。

一个标识符可以从两个或更多的库中使用相同的本地名字导入，或者使用两个不同的级别从相同的库中导入，只要每个库导出的绑定是一样的（也就是说，绑定在一个库中被定义，它只能<!-- TODO -->通过导出和再导出经过导入）。否则，没有标识符可以被导入多次，被定义多次，或者同时被定义和导入。除了被显式地导入到库中或在库中定义的标识符，其它标识符在库中都是不可见的。

一个`<library name>`在一个实现中唯一地标识一个库，且在实现中的其它所有的库的`import`子句（clauses）（见下面）中是全局可见的。一个`<library name>`有下面的形式：

`(<identifier1> <identifier2> ... <version>)`

其中`<version>`或者是空的，或者有以下的形式：

`(<sub-version> ...)`

每一个`<sub-version>`必须表示一个精确的非负整数对象。一个空的`<version>`等价于`()`。

一个`<export spec>`命名一个集合，这个集合包含导入的和本地的定义，这个集合将被导出，可能还会使用不同的外部名字。一个`<export spec>`必须是如下的形式当中的一个：

~~~ scheme
<identifier>
(rename (<identifier\(_1\)> <identifier\(_2\)>) ...)
~~~

在一个`<export spec>`中，一个`<identifier>`命名一个被定义在或被导入到库中的单独的绑定，其中，这个导入的外部名字和库中绑定的名字是一样的。一个`rename`指明在每一个`\(\texttt{(<identifier$_1$> <identifier$_2$>)}\)`这样的配对中，被命名为`\(\texttt{<identifier$_1$>}\)`的绑定使用`\(\texttt{<identifier$_2$>}\)`作为外部名字。

每一个`<import spec>`指定一个被导入到库中的绑定的集合，在这个集合中，级别是可见的，且通过它可以知道本地的名字。一个`<import spec>`必须是下面的一个：

~~~ scheme
<import set>
(for <import set> <import level> ...)
~~~

一个`<import level>`是下面中的一个：

~~~ scheme
run
expand
(meta <level>)
~~~

其中`<level>`表示一个精确的整数对象。

在一个`<import level>`中，`run`是`(meta 0)`的缩写，且`expand`是`(meta 1)`的缩写。级别和阶段（phases）在7.2小节讨论。

一个`<import set>`命名一个来自另一个库的绑定的集合，且可能为导入的绑定指定一个本地的名字。它必须是下面的一个：

~~~ scheme
<library reference>
(library <library reference>)
(only <import set> <identifier> ...)
(except <import set> <identifier> ...)
(prefix <import set> <identifier>)
(rename <import set> (<identifier\(_1\)> <identifier\(_2\)>) ...)
~~~

一个`<library reference>`通过它的名字和可选的版本标识一个库。它有下面形式中的一个：

~~~ scheme
(<identifier\(_1\)> <identifier\(_2\)> ...)
(<identifier\(_1\)> <identifier\(_2\)> ... <version reference>)
~~~

<!-- TODO -->
一个第一个`<identifier>`是`for`, `library`, `only`, `except`, `prefix`，或`rename`的`<library reference>`只允许出现在一个`library <import set>`中。否则`<import set> (library <library reference>)`等价于`<library reference>`。

一个没有`<version reference>`（上面的第一个形式）的`<library reference>`等价于`<version reference>`是`()`的`<library reference>`。

一个`<version reference>`指定它匹配的`<version>`的一个子集。`<library reference>`指定所有相同名字且版本匹配`<version reference>`的库。一个`<version reference>`有下面的形式：

~~~ scheme
(<sub-version reference\(_1\)> ... <sub-version reference\(_n\)>)
(and <version reference> ...)
(or <version reference> ...)
(not <version reference>)
~~~

第一个形式的一个`<version reference>`匹配`<version>`至少*n*个要素的，且`<sub-version reference>`匹配对应的`<sub-version>`。一个`and <version reference>`匹配一个版本，如果所有的跟在`and`后的`<version references>`都匹配的话。相应地，`or <version reference>`匹配一个版本，如果跟在`or`后的一个`<version references>`匹配的话。一个`not <version reference>`匹配一个版本，如果跟在其后的`<version reference>`都不匹配的话。

一个`<sub-version reference>`有下列形式之一：

~~~ scheme
<sub-version>
(>= <sub-version>)
(<= <sub-version>)
(and <sub-version reference> ...)
(or <sub-version reference> ...)
(not <sub-version reference>)
~~~

第一个形式的一个`<sub-version reference>`匹配一个版本，如果二者相等。第一个形式的`>= <sub-version reference>`匹配一个子版本如果它大于等于跟在它后面的`<sub-version>`；`<=`与其类似。一个`and <sub-version reference>`匹配一个子版本，如果所有随后的`<sub-version reference>`都匹配的话。相应地，一个`or <sub-version reference>`匹配一个子版本，如果随后的`<sub-version reference>`中的一个匹配的话。一个`not <sub-version reference>`匹配一个子版本，如果随后的`<sub-version reference>`都不匹配的话。

例子：

| 版本参考（version reference） | 版本（version） | 匹配？（match?）
| `()` | `(1)` | yes
| `(1)` | `(1)` | yes
| `(1)` | `(2)` | no
| `(2 3)` | `(2)` | no
| `(2 3)` | `(2 3)` | yes
| `(2 3)` | `(2 3 5)` | yes
| `(or (1 (>= 1)) (2))` | `(2)` | yes
| `(or (1 (>= 1)) (2))` | `(1 1)` | yes
| `(or (1 (>= 1)) (2))` | `(1 0)` | no
| `((or 1 2 3))` | `(1)` | yes
| `((or 1 2 3))` | `(2)` | yes
| `((or 1 2 3))` | `(3)` | yes
| `((or 1 2 3))` | `(4)` | no

当多于一个库被库参考引用的时候，库的选择有实现定义的方法决定。

为了避免诸如不兼容的类型和重复的状态这些问题，实现必须禁止库名字由相同标识符序列组成但版本不匹配的两个库在同一个程序中共存。

<!-- TODO -->
默认情况下，一个被导入的库导出的所有的绑定在一个使用被导入的库给的绑定的名字的导入库中是可见的。被导入的绑定和那些绑定的名字的精确的集合可以通过下面描述的`only`, `except`, `prefix`, 和`rename`形式进行调整。

* 一个`only`形式产生来自另一个`<import set>`的绑定的一个子集，只包括被列出的`<identifier>`。被包含的`<identifier>`必须在原始的`<import set>`中。
* 一个`except`形式产生来自另一个`<import set>`的绑定的一个子集，包括除了被列出的所有的`<identifier>`。所有被排除的`<identifier>`必须在原始的`<import set>`中。
* 一个`prefix`从另一个`<import set>`中添加一个`<identifier>`前缀到每个名字中。
* 一个`rename`形式，`\(\texttt{(rename (<identifier$_1$> <identifier$_2$>) ...)}\)`，从一个中间的`<import set>`删除`\(\texttt{<identifier$_1$> ...}\)`的绑定，然后将对应的`\(\texttt{<identifier$_2$> ...})`添加回到最终的`<import set>`中。每一个`\(\texttt{<identifier$_1$>}\)`必须在原始的`<import set>`中，每一个`\(\texttt{<identifier$_2$>})`必须不在中间的`<import set>`中，且`\(\texttt{<identifier$_2$>})`必须是不一样的。

不符合上面的约束是一个语法错误。

一个库形式的`<library body>`由被分类为*定义*或*表达式*的形式组成。哪些形式属于哪些类型是根据被导入的库和表达式的结果来决定的—见第10章。通常，不是定义（见11.2小节，有基本库可见的定义）的形式是表达式。

一个`<library body>`和`<body>`差不多（见11.3小节），除了一个`<library body>`不需要包括任何表达式。它必须有下面的形式：

`<definition> ... <expression> ...`

当`begin`, `let-syntax`, 或`letrec-syntax`形式先于第一个表达式出现在顶层内部的时候，它们被拼接成内部；见11.4.7小节。内部的一些或所以，包括在`begin`, `let-syntax`, 或`letrec-syntax`形式里面的部分，可以通过一个句法抽象指定（见9.2小节）。

转换表达式和绑定像第10章描述的，按从左向右的顺序被求值和被创建。变量的表达式按从左向右求值，就像在一个隐式的`letrec*`中，且内部的表达式也在变量定义的表达式之后从左向右进行求值。每一个导出的变量和它本地副本值得初始化都会创建一个新的位置。两次返回给内部最后表达式的继续的行为是未定义的。

<font size="2">
  <i>注意：</i>出现在库语法的名字<code>library</code>, <code>export</code>, <code>import</code>, <code>for</code>, <code>run</code>, <code>expand</code>, <code>meta</code>, <code>import</code>, <code>export</code>, <code>only</code>, <code>except</code>, <code>prefix</code>, <code>rename</code>, <code>and</code>, <code>or</code>, <code>not</code>, <code>>=</code>, 和<code><=</code>是语法的一部分，且不是被保留的，也就是说，相同的名字可以在库中用作其它的用途，甚至以不同的含义导出或导入到其它库中，这些都不会影响它们在库形式中的使用。
</font>

在一个库的里面定义的绑定在库外面的代码中是不可见的，除非绑定被显式地从这个库中导出。可是，一个导出的宏可能*隐式地导出*一个另外的标识符，其是在库中定义的或导入到库中的。也就是说，它可以插入标识符的一个引用到其产生的代码中。

所有的显式地导出的变量在导出的和导入的的库中都是不可变的。因此，不管是在导入的还是导出的库中，一个显式地导出的变量出现在一个`set!`表达式的左边是一个语法错误。

所有的隐式地导出的变量在导出的和导入的的库中也都是不可变的。因此，在一个变量被定义的库的外面通过宏产生的代码中，如果这个变量出现在一个`set!`表达式的左边，那么这是一个语法错误。如果一个被赋值的变量的引用出现在这个变量被定义的库的外面通过宏产生的代码中，那么这也是一个语法错误，其中，一个被赋值的变量指出现在导出库中一个`set!`表达式左边的变量。

所有其它的定义在一个库中的变量是可变的。

## 7.2. 导入和导出级别 <!-- Import and export levels -->

扩展一个库可能需要来自其它库的运行时信息。比如，如果一个宏转换调用一个来自库*A*的过程，那么在库*B*中扩展宏的任何使用之前，库*A*必须被实例化（instantiated）。当库*B*作为一个程序的部分被最终运行的时候，库*A*可能不被需要，或者，它可能也被库*B*的运行时需要。库机制使用阶段来区别这些时间，这会在本小节解释。

每个库可用通过扩展时（expand-time）信息（最低限度地，它的导入的库，导出的关键词的一个列表，导出的变量的一个列表，计算转换表达式的代码）和运行时信息（最低限度地，计算变量定义的右边表达式的代码，计算内部表达式的代码）表现其特征。扩展时信息必须对任何导出绑定的扩展引用可见，且运行时信息必须对任何导出变量绑定的求值引用可见。

一个*阶段*是一段时间，在这段时间里库中的表达式被求值。在一个库的内部，顶层表达式和`define`形式的右边在运行时，也就是阶段0，被求值，且`define-syntax`形式的右边在扩展时，也就是阶段1，被求值。当`define-syntax`, `let-syntax`, 或`letrec-syntax`出现在在阶段*n*被求值的代码中时，它们的右边将在阶段*n* + 1被求值。

这些阶段和库它自己使用的阶段是相关的。库的一个*实例（instance）*对应于一个与另一个库相关的特定阶段的它的变量定义和表达式的求值过程—一个叫做实例化的过程。比如，如果库*B*中的一个顶层表达式引用库*A*中导出的一个变量，那么它在阶段0（相对于*B*的阶段）从*A*的一个实例中引用这个导出。但是，*B*中一个阶段1的表达式引用*A*中相同的绑定，那么，它在阶段1（相对于*B*的阶段）从*A*的一个实例中引用这个导出。

<!-- TODO -->
一个库的*访问（visit）*对应于在一个特定阶段与另一个库相关的语法定义的计算过程—一个叫做*访问（visiting）*的过程。比如，如果库*B*中的一个顶层表达式引用来库*A*导出的一个宏，那么，它在阶段0（相对应*B*的阶段）从*A*的访问中引用这个导出，其对应于在阶段1宏转换表达式的求职过程。

一个*级别（level）*是一个标识符的词法属性，其决定了它可以在哪个阶段被引用。在一个库中，每个用定义绑定的标识符的级别是0；也就是说，在库中只能在阶段0引用这个标识符。除了导出库中标识符的级别之外，每一个导入的绑定的级别由导入库中`import`的封装的`for`形式决定。导入和导出级别通过所有级别组合的成对相加的方式组合。比如，一个以`\(p_a\)`和`\(p_b\)`级别导出，以`\(q_a\)`，`\(q_b\)`和`\(q_c\)`级别导入的被导入的标识符的引用在以下级别是有效的：`\(p_a + q_a\)`, `\(p_a + q_b\)`, `\(p_a + q_c\)`, `\(p_b + q_a\)`, `\(p_b + q_b\)`, 和`\(p_b + q_c\)`。一个没有封装的`for`的`<import set>`等价于`(for <import set> run)`，它和`(for <import set> (meta 0))`是一样的。

对于所有的定义在导出库中的绑定来说，一个被导出的的绑定的级别是0.一个重新导出的绑带，也就是一个从其它库导入的导出，的级别和重新导出库中的绑定的有效导入级别是一样的。

对于定义在库报告中的库来说，几乎所有的绑定，导出级别是0。例外是来自`(rnrs base (6))`库的`syntax-rules`, `identifier-syntax`, `...`, 和`_`形式以级别1被导出，来自`(rnrs base (6))`库的`set!`形式以级别0和1被导出，来自复合`(rnrs (6))`库（见库的第15章）的所有绑定以级别0和1被导出。

一个库中的宏扩展可以引出标识符的一个引用，其中这个标识符没有显式地导入到这个库中。在这种情况下，引用的阶段必须符合标识符的作为偏移的级别，<!-- TODO -->这个偏移是源库（也就是提供标识符词法上下文的库）和封装引用的库的阶段的不同。比如，假设扩展一个库调用一个宏转换，且宏转换的求值引用一个标识符，这个标识符被从另一个库中被导出（所以，库的阶段1的实例被使用）；进一步假设绑定的值是一个表示一个指示级别*n*绑定的标识符的语法对象；那么，在库被扩展的时候，标识符必须只能在*n* + 1阶段被使用。这个级别和阶段的组合就是为什么标识符负的级别是有用的，甚至，尽管库只存在非负的阶段。

<!-- TODO -->
如果在一个程序的扩展形式中，一个库的定义中的任何一个在阶段0被引用，那么被引用的库的一个作为阶段0实例会在程序的定义和表达式被求值之前被创建。这条规则的应用是透明的：如果一个库的扩展形式在阶段0从另一个库引用一个标识符，那么，在引用库在阶段*n*被实例化之前，被引用的库必须在阶段*n*被实例化。当一个标识符在任何大于0的阶段*n*被引用，那么于此相反，定义库会在阶段*n*被实例化，其在引用被求值之前的一些未定义的时间。同样地，在一个库的扩展期间，当一个宏关键词在阶段*n*被引用的时候，定义库在阶段*n*被访问，其是引用被计算之前的一定未定义的时间。

一个实现可以为不同的阶段区别实例/访问，或者在任何阶段使用一个实例/访问就像在任何其它阶段的一个实例/访问一样。更进一步，一个实现可以扩展每一个库形式以区别在任何阶段的库的访问和/或在大于0的阶段的库的实例。一个实现可以创建更多库的实例/访问在比要求的安全引用的更多的阶段。当一个标识符作为一个表达式出现在一个与标识符级别不一致的阶段时，那么一个实现可以抛出一个异常，异常的抛出可以在扩展时也可以在运行时，或者，它也可以允许这个引用。因此，一个库可能是不可移植的，当其含义依赖于一个库的实例在库的整个阶段或`library`扩展时是有区别的还是共享的时候。

## 7.3. 例子 <!-- Examples -->

各种`<import spec>`和`<export spec>`的例子：

（注：下面的例子已根据勘误表更正。）

~~~ scheme
(library (stack)
  (export make push! pop! empty!)
  (import (rnrs)
          (rnrs mutable-pairs))

  (define (make) (list '()))
  (define (push! s v) (set-car! s (cons v (car s))))
  (define (pop! s) (let ([v (caar s)])
                     (set-car! s (cdar s))
                     v))
  (define (empty! s) (set-car! s '())))

(library (balloons)
  (export make push pop)
  (import (rnrs))

  (define (make w h) (cons w h))
  (define (push b amt)
    (cons (- (car b) amt) (+ (cdr b) amt)))
  (define (pop b) (display "Boom! ") 
                  (display (* (car b) (cdr b))) 
                  (newline)))

(library (party)
  ;; 所以的导出:
  ;; make, push, push!, make-party, pop!
  (export (rename (balloon:make make)
                  (balloon:push push))
          push!
          make-party
          (rename (party-pop! pop!)))
  (import (rnrs)
          (only (stack) make push! pop!) ; 非空的!
          (prefix (balloons) balloon:))

  ;; 以气球的堆栈创建一个派对（party）,
  ;; 从两个气球开始
  (define (make-party)
    (let ([s (make)]) ; from stack
      (push! s (balloon:make 10 10))
      (push! s (balloon:make 12 9))
      s))
  (define (party-pop! p)
    (balloon:pop (pop! p))))

(library (main)
  (export)
  (import (rnrs) (party))

  (define p (make-party))
  (pop! p)        ; 显示"Boom! 108"
  (push! p (push (make 5 5) 1))
  (pop! p))       ; 显示"Boom! 24"
~~~

宏和阶段的例子:

~~~ scheme
(library (my-helpers id-stuff)
  (export find-dup)
  (import (rnrs))

  (define (find-dup l)
    (and (pair? l)
         (let loop ((rest (cdr l)))
           (cond
            [(null? rest) (find-dup (cdr l))]
            [(bound-identifier=? (car l) (car rest)) 
             (car rest)]
            [else (loop (cdr rest))])))))

(library (my-helpers values-stuff)
  (export mvlet)
  (import (rnrs) (for (my-helpers id-stuff) expand))

  (define-syntax mvlet
    (lambda (stx)
      (syntax-case stx ()
        [(_ [(id ...) expr] body0 body ...)
         (not (find-dup (syntax (id ...))))
         (syntax
           (call-with-values
               (lambda () expr) 
             (lambda (id ...) body0 body ...)))]))))

(library (let-div)
  (export let-div)
  (import (rnrs)
          (my-helpers values-stuff)
          (rnrs r5rs))

  (define (quotient+remainder n d)
    (let ([q (quotient n d)])
      (values q (- n (* q d)))))
  (define-syntax let-div
    (syntax-rules ()
     [(_ n d (q r) body0 body ...)
      (mvlet [(q r) (quotient+remainder n d)]
        body0 body ...)])))
~~~

# 8. 顶层程序 <!-- Top-level programs -->

一个*顶层程序*为定义和运行一个Scheme程序制定一个入口点。一个顶层程序指定导入库和准备运行的程序的一个集合。通过被导入的库，不管是直接地还是通过导入的传递闭包（transitive closure），一个顶层程序定义了一个完整的Scheme程序。

## 8.1. 顶层程序语法 <!-- Top-level program syntax -->

一个顶层程序是一个带分隔符的文本片段，通常是一个文件，其有如下的形式：

`<import form> <top-level body>`

一个`<import form>`有如下的形式：

`(import <import spec> ...)`

一个`<top-level body>`有如下的形式：

`<top-level body form> ...`

一个`<top-level body form>`或者是一个`<definition>`或者是一个`<expression>`。

`<import form>`和库中的导入子句是相同的（见7.1小节），且指定要导入的库的一个集合。一个`<top-level body>`就像一个`<library body>`（见7.1小节）一样，除了定义和表达式可以以任何次序出现。因此，`<top-level body form>`指定的语法引用了宏扩展的结果。

<!-- TODO -->
当使用来自`(rnrs base (6))`库的`begin`, `let-syntax`, 或`letrec-syntax`的时候，如果其先于第一个表达式出现在顶层程序的内部时，那么它们被拼接到内部中；见11.4.7小节。内部的一些或所有，包括`begin`, `let-syntax`, 或`letrec-syntax`里面的部分，可以通过一个句法抽象指定（见9.2小节）。

## 8.2. 顶层程序语义 <!-- Top-level program semantics -->

一个顶层程序被执行的时候，程序就像一个库一样被对待，执行其定义和表达式。一个顶层内部的语义可以通过一个简单的转换将其转换到库内部来解释：在顶层内部中每一个出现在定义前的`<expression>`被转换为一个哑（dummy）定义

`(define <variable> (begin <expression> <unspecified>))`

其中，`<variable>`是一个新鲜的标识符，`<unspecified>`是一个返回未定义值得无副作用的表达式。（如果不同时对内部进行扩展，那么，判断哪个形式是定义，哪个形式是表达式通常是不可能的，因此，实际的转换多少会更加复杂；见第10章。）

在支持它的平台上，一个顶层程序可以通过调用`command-line`过程（见库的第10章<!-- TODO: 原文错写成小节 -->）访问它的命令行。

# 9. 基本语法 <!-- Primitive syntax -->

在一个`library`形式或顶层程序的`import`形式的后面，构成库或顶层程序内部的形式依赖于被导入的库。尤其，被导入的句法关键词决定可用的句法抽象以及每个形式是一个定义还是一个表达式。可是，一些形式总是可用的，它们独立于被导入的库，包括常量字面量，变量引用，过程调用，和宏的使用。

## 9.1. 基本表达式类型（Primitive expression types）

本节的条目都是都是描述表达式，其可以出现在`<expression>`句法变量的地方。也可以参见第11.4小节。

**常量字面量**

`<number>`‌‌ syntax  
`<boolean>`‌‌ syntax  
`<character>`‌‌ syntax  
`<string>`‌‌ syntax  
`<bytevector>`‌‌ syntax  

一个由一个数字对象，或一个布尔，或一个字符，或一个字符串，或一个字节向量组成的表达式求值“等于它自己”。

~~~ scheme
145932     ‌          ⇒  145932
#t   ‌                ⇒  #t
"abc"      ‌          ⇒  "abc"
#vu8(2 24 123) ‌      ⇒ #vu8(2 24 123)
~~~

就像5.10小节描述的那样，一个字面量表达式的值是不可改变的。

**变量引用**

`<variable>`‌‌ syntax 

由一个变量组成的表达式（5.2小节）是一个变量引用，如果它不是一个宏使用（见下面）的话。这个变量引用的值是被存储在这个变量绑定的位置的值。引用一个未绑定的变量是一个语法错误。

<!-- TODO：原文多了一个“examples” -->
下面的例子假设基本库已经被导入：

~~~ scheme
(define x 28)
x   ‌⇒  28
~~~

**过程调用**

`(<operator> <operand1> ...)‌‌` 语法

一个过程调用由被调用的过程表达式，传递给这个过程的参数以及两边的下括号组成。在一个表达式上下文中，如果`<operator>`不是一个作为句法关键字绑定的标识符（见下面的9.2小节），那么这个形式是一个过程调用。

当一个过程调用被求值的时候，操作和操作数被（以一个未定义的顺序）求值，且最终产生的过程接受最终产生的参数。

下面的例子假设`(rnrs base (6))`库已被导入：

~~~ scheme
(+ 3 4)                           ‌⇒  7
((if #f + *) 3 4)                 ‌⇒  12
~~~

如果`<operator>`的值不是一个过程，那么一个条件类型是`&assertion`的异常被抛出。并且，如果一个过程接受的参数的数量不是`<operand>`的数量，那么一个条件类型是`&assertion`的异常被抛出。

<p><font size="2"><i>注意：</i> 相比于其它的Lisp方言，求值的顺序是未定义的，且操作表达式和操作数表达式总是以相同的求值规则被求值。</font></p>

<p><font size="2">此外，尽管求值的顺序是未定义，但是对操作和操作数表达式进行的任何并发求值的结果必须与按某种顺序求值的结果一致。对每个过程调用的求值顺序可以有不同的选择。</font></p>

<p><font size="2"><i>注意：</i>在许多Lisp方言中，空组合式<code>()</code>是合法的表达式。在Scheme中，写成表/点对形式的表达式至少要包含一个子表达式，因此<code>()</code>不是一个语法上有效的表达式。</font></p>

## 9.2. 宏 <!-- Macros -->

库的顶层程序可以定义和使用新的叫做*句法抽象*或*宏*派生表达式和定义。一个句法抽象通过绑定一个关键词到一个*宏转换*，或简称为*转换*，来创建。转换决定一个宏的使用（被称为*宏使用（macro use）*）怎样被转录我一个更加基本的形式。

大部分宏有形式：

`(<keyword> <datum> ...)`

其中`<keyword>`是唯一决定形式种类的标识符。这个标识符叫做宏的*句法关键词*，或简称为宏的*关键词*。`<datum>`的数量和每一个的语法由句法抽象决定。

<!-- 原文的括号匹配有问题 -->
宏使用可以表现为不正确的表形式，单独的标识符或`set!`形式，其中`set!`形式的第二个子形式是关键字（见第11.19小节，库的第12.3小节）：

~~~ scheme
(<keyword> <datum> ... . <datum>)
<keyword>
(set! <keyword> <datum>)
~~~

在11.2.2和11.18小节描述的`define-syntax`, `let-syntax` 和`letrec-syntax`形式创建关键词的绑定，将它们与宏转换的形式联系起来，且控制它们可见的范作用域。

在11.19小节描述的`syntax-rules` 和`identifier-syntax`形式通过一个模式语言创建转换。并且，库的第12章描述的`syntax-case`形式允许通过任意的Scheme代码创建转换。

关键词和变量占据相同的名字空间。也就是，在相同的作用域内，一个标识符可以被绑定到一个变量或一个关键词中的零个或一个，不能同时绑定到两个，且任何一种本地绑定可以覆盖任何一种其它的绑定。

使用`syntax-rules` 和`identifier-syntax`定义的宏是“卫生的”和“引用透明的”，且因此保持了Scheme词法作用域的特点[^16][^15][^2][^6][^9]：

* 如果一个宏转换为一个没有出现在宏使用中的标识符（变量或关键词）插入一个绑定，就实际效果而言，该标识符在其整个作用域中将被改名使用，以避免与其他标识符冲突。
* 如果一个宏转换器插入了对某标识符的自由引用，那么，无论是否存在包围该宏的使用的局部绑定，该引用都将指向定义转换器时可见的绑定。

使用`syntax-case`工具定义的宏也是卫生的，除非`datum->syntax`（见库的第12.6小节）被使用。

# 10. 扩展过程 <!-- Expansion process -->

<!-- 将前面的transformer翻译成转换器 -->
宏使用（见第9.2小节）在求值开始的时候（在编译或解释之前）通过语法*扩展器（expander）*被扩展为*核心形式*。核心形式的集合石实现定义的，在扩展器输出中这些形式的表示也是。如果扩展器遇到一个句法抽象，那么他会调用相关的转换器去扩展句法抽象，然后对转换器（transformer）返回的形式重复扩展过程。如果扩展器遇到一个核心形式，它会递归地处理表达式或定义上下文中它的子形式，如果有的话，且从被扩展的子形式中重建形式。关于标识符绑定的信息在为变量和关键词实施词法作用域扩展的时候被维持。

为了处理定义，扩展器从左向右地处理`<body>`或`<library body>`（见7.1小节）中的初始形式。扩展器怎样处理每个遇到的形式取决于形式的种类。

宏使用
: 扩展器调用相关的转换器来转换宏使用，然后对产生的形式递归地执行适当的操作。

`define-syntax`形式
: 扩展器扩展和求值右边的表达式，且绑定关键词到最终的转换器。

`define`形式
: 扩展器记录这样的事实直到所有的定义都被处理，被定义的标识符是一个变量，而不是右边表达式的推迟扩展。

`begin`形式
: 扩展器将子形式拼接到它正在处理的内部形式的表中。

`let-syntax`或`letrec-syntax`形成
: 扩展器将里面的内部形式拼接到它正在处理的（外面的）内部形式的表中，使得通过`let-syntax`和`letrec-syntax`绑定的关键词只在里面的内部形式可见。

表达式，也就是，非定义
: 扩展器完成推迟的右边表达式和内部当前的即遗留的表达式的扩展，且然后从被定义的变量，被扩展的右边的表达式，和被扩展的内部表达式创建等价于`letrec*`的形式。

对于一个变量定义的右边，扩展被推迟到所以的定义可见之后。因此，如果可以的话，右边的每个关键词和变量引用都解析到本地绑定。

<!-- TODO -->
在形式序列中的一个定义必须不能定义任意下列的标识符，其绑定被用作判断定义或形式序列中任何在其之前的定义的含义。比如，下列表达式的内部违反了这个限制：

~~~ scheme
(let ()
  (define define 17)
  (list define))

(let-syntax ([def0 (syntax-rules ()
                     [(_ x) (define x 0)])])
  (let ([z 3])
    (def0 z)
    (define def0 list)
    (list z)))

(let ()
  (define-syntax foo
    (lambda (e)
      (+ 1 2)))
  (define + 2)
  (foo))
~~~

下面的没有违反这个限制：

~~~ scheme
(let ([x 5])
  (define lambda list)
  (lambda x x))         ‌⇒  (5 5)

(let-syntax ([def0 (syntax-rules ()
                     [(_ x) (define x 0)])])
  (let ([z 3])
    (define def0 list)
    (def0 z)
    (list z)))          ‌⇒  (3)

(let ()
  (define-syntax foo
    (lambda (e)
      (let ([+ -]) (+ 1 2))))
  (define + 2)
  (foo))                ‌⇒  -1
~~~

实现应当将违反限制当作语法错误对待。

注意这个算法不直接地再处理任何形式。它要求整个定义中一个单独的从左到右的途径，其后是表达式和推迟的右手边里的一个单独的途径（任何顺序）。

例如：

~~~ scheme
(lambda (x)
  (define-syntax defun
    (syntax-rules ()
      [(_ x a e) (define x (lambda a e))]))
  (defun even? (n) (or (= n 0) (odd? (- n 1))))
  (define-syntax odd?
    (syntax-rules () [(_ n) (not (even? n))]))
  (odd? (if (odd? x) (* x x) x)))
~~~

<!-- TODO -->
在这个例子中，第一次遇到`defun`的定义，且关键词`defun`与转换器相关，转换器从扩展和对应的右手边的求值得来。`defun`的一个使用在接下来被遇到，且扩展到一个`define`形式中。这个定义形式右手边的扩展是推迟的。`odd?`的定义是下一个且是与其相关的关键词`odd?`的结果，其转换器从对应的右手边的扩展和求值得来<!-- TODO -->。`odd?`的一个使用出现在旁边，且被扩展；作为结果的对`not`的调用被认为是一个表达式，这是因为`not`作为一个变量被绑定。此时，扩展器完成当前表达式（`not`的调用）和被推迟的`even?`定义右侧的扩展；出现在这些表达式中的`odd?`的使用通过使用与`odd?`关联的转换器扩展。最终的输出等价于：

~~~ scheme
(lambda (x)
  (letrec* ([even?
              (lambda (n)
                (or (= n 0)
                    (not (even? (- n 1)))))])
    (not (even? (if (not (even? x)) (* x x) x)))))
~~~

尽管输出的结构是实现定义的。

因为定义被表达式在一个`<top-level body>`中可以交错地出现（见第8章），所以`<top-level body>`扩展器的处理有时更加复杂。它的行为想上面描述的`<body>`或`<library body>`以及以下例外：当扩展器发现一个非定义，它推迟其扩展并继续扫描定义。一旦它到达形式集合 的结尾，那么它处理推迟的右手边和内部表达式，然后从被定义的变量中生成等价于`letrec*`的形式，扩展右手边表达式，且扩展内部表达式。对于每一个出现在内部变量定义之前的内部表达式`<expression>`，在对应的地方一个哑绑定被创建以`letrec*`绑定的集合的形式，其左边是一个新鲜的临时变量，右边等价于`(begin <expression> <unspecified>)`，其中`<unspecified>`是没有副作用的，所以从左到右的求值顺序被保留。`begin`的包装使得`<expression>`可以求值得到任意数量的值。

# 11. 基本库 <!-- Base library -->

本章描述Scheme的`(rnrs base (6))`库，其导出了很多通常和Scheme一起的过程和语法绑定。

第11.20小节定义了来自`(rnrs base (6))`库的从结构上识别尾调用和尾上下文的规则。

## 11.1. 基本类型 <!-- Base types -->

没有变量满足下列谓词中的多个：

~~~ scheme
boolean?          pair?
symbol?           number?
char?             string?
vector?           procedure?
null?
~~~

这些谓词定义了基本的类型*布尔*，*点对*，*符号*，*数字*，*字符*，*字符串*，*向量*，以及*过程*。此外，空表是一个特殊的对象，它有自己的类型。

注意，尽管有一个单独的布尔类型，但是，任何Scheme值在条件测试中都可以被当作一个布尔值使用；见5.7小节。

## 11.2. 定义 <!-- Definitions -->

定义出现在一个`<top-level body>`（8.1小节）中，`<library body>`的最上面（7.1小节），或`<body>`的最上面（11.3小节）。

一个`<definition>`可以是一个变量定义（11.2.1小节），或一个关键词定义（11.2.1小节）。扩展到定义或定义组（打包在一个`begin`, `let-syntax`, 或`letrec-syntax`形式中）中的宏使用也可以出现在任何其它定义可以出现的地方。

### 11.2.1. 变量定义 <!-- Variable definitions -->

本节描述的`define`形式是一个用作创建变量绑定的`<definition>`，且可以出现在其它定义可以出现的任何地方。

| `(define <variable> <expression>)‌‌` | 语法 
| `(define <variable>)‌‌` | 语法 
| `(define (<variable> <formals>) <body>)‌‌` | 语法 
| `(define (<variable> . <formal>) <body>)‌‌` | 语法

`define`的第一个形式绑定`<variable>`到一个新的位置，然后将`<expression>`的值赋值给这个位置。

~~~ scheme
(define add3
  (lambda (x) (+ x 3)))
(add3 3)                            ‌⇒  6
(define first car)
(first '(1 2))                      ‌⇒  1
~~~

`<expression>`的继续不应该被调用多于一次。

*实现的责任*：实现应当检测`<expression>`的继续被调用多于一次的情况。如果实现检测到这个的话，它必须抛出一个条件类型是`&assertion`的异常。

`define`的第二种形式等价于

`(define <variable> <unspecified>)`

其中`<unspecified>`是一个返回未定义值得无副作用的表达式。

在`define`的第三个形式中，`<formals>`必须或者是零个或多个变量的序列，或者是一个或多个变量的序列，其跟着一个点`.`和另一个变量（就像在一个`lambda`表达式中一样，见11.4.2小节）。这个形式等价于

<!-- TODO：句号是程序的一部分吗？ -->

~~~ scheme
(define <variable>
  (lambda (<formals>) <body>)).
~~~

在`define`的第四个形式中，`<formal>`必须是一个单独的变量。

~~~ scheme
(define <variable>
  (lambda <formal> <body>)).
~~~

### 11.2.2. 语法定义 <!-- Syntax definitions -->

本节描述的`define-syntax`形式是一个用作创建关键词绑定的`<definition>`，其可以出现在任何其它定义可以出现的地方。

`(define-syntax <keyword> <expression>)` 语法

绑定`<keyword>`到`<expression>`的值，其必须在宏扩展的阶段求值得到一个转换器。宏转换器可以使用11.19小节描述的`syntax-rules`和`identifier-syntax`形式创建。见库的第12.3小节，那儿有一个转换器更全面的描述。

通过`define-syntax`建立的关键词绑定在其出现的整个内部都是可见的，除非被其它绑定覆盖外都是可见的，就像`define`建立的变量绑定一样。通过一组定义建立的绑定，不管是关键词还是变量定义，在定义它们自己中是可见的。

*实现的责任*：实现应该检测`<expression>`的值是不是一个适当的转换器。

例子：

~~~ scheme
(let ()
  (define even?
    (lambda (x)
      (or (= x 0) (odd? (- x 1)))))
  (define-syntax odd?
    (syntax-rules ()
      ((odd?  x) (not (even? x)))))
  (even? 10))                       ‌⇒ #t
~~~

<!-- TODO:
  在所有的地方加上第：
  x章（小节）是不通顺的，那么x.y章（小节）也是不通顺的。
-->
从左到右的处理顺序（第10章）的言外之意是一个定义可以影响后续的形式是否也是一个定义。

例子：

~~~ scheme
(let ()
  (define-syntax bind-to-zero
    (syntax-rules ()
      ((bind-to-zero id) (define id 0))))
  (bind-to-zero x)
  x) ‌⇒ 0
~~~

任何出现在`let`表达式外面的`bind-to-zero`的绑定都不会影响其行为。

## 11.3. 内部 <!-- Bodies -->

`lambda`, `let`, `let*`, `let-values`, `let*-values`, `letrec`, 或`letrec*`表达式的`<body>`，或由零个或多个跟着一个或多个表达式的定义。

`<definition> ... <expression1> <expression2> ...`

通过一个定义定义的标识符在`<body>`中局部的。也就是说，标识符被绑定到，且绑定的作用域是这个`<body>`（见第5.2小节）。

例子

~~~ scheme
(let ((x 5))
  (define foo (lambda (y) (bar x y)))
  (define bar (lambda (a b) (+ (* a b) a)))
  (foo (+ x 3)))                ‌⇒  45
~~~

当`begin`, `let-syntax`, 或`letrec-syntax`形式先于第一个表达式出现在内部的时候，它们被拼接到内部；见第11.4.7小节。内部的一些或所以<!-- TODO -->，包括`begin`, `let-syntax`, 或`letrec-syntax`形式里面的部分，可以通过一个宏使用指定（见第9.2小节）。

一个包含变量定义的被扩展的`<body>`（见第10章）总是可以被转换成一个等价的`letrec*`表达式。比如，上面例子中的`let`表达式等价于

~~~ scheme
(let ((x 5))
  (letrec* ((foo (lambda (y) (bar x y)))
            (bar (lambda (a b) (+ (* a b) a))))
    (foo (+ x 3))))
~~~

## 11.4. 表达式 <!-- Expressions -->

本节的条目描述`(rnrs base (6))`库中的表达式，除了第9.1小节描述的基本表达式类型，其可以出现在`<expression>`句法变量的位置中。

### 11.4.1. 引用（Quotation）

`(quote <datum>)` 语法

*语法*：`<Datum>`应该是一个句法数据。

*语义*：`quote <datum>)`的值是`<datum>`表示的数据值（见第4.3小节）。这个符号被用作包含常量。

~~~ scheme
(quote a)                     ‌⇒  a
(quote #(a b c))              ‌⇒  #(a b c)
(quote (+ 1 2))               ‌⇒  (+ 1 2)
~~~

正如第4.3.5小节所说，`(quote <datum>)`可以使用缩写`'<datum>`：

~~~ scheme
'"abc"               ‌⇒  "abc"
'145932              ‌⇒  145932
'a                   ‌⇒  a
'#(a b c)            ‌⇒  #(a b c)
'()                  ‌⇒  ()
'(+ 1 2)             ‌⇒  (+ 1 2)
'(quote a)           ‌⇒  (quote a)
''a                  ‌⇒  (quote a)
~~~

正如第5.10小节所说，常量是不可变得。

<p><font size="2"><i>注意：</i>是<code>quote</code>表达式值得不同常数可以共享相同的位置。</font></p>

### 11.4.2 过程 <!-- Procedures -->

`(lambda <formals> <body>)` 语法

*语法*：`<Formals>`必须是一个下面描述的形参（formal parameter）列表，且`<body>`必须和第11.3小节描述的一样。

<!-- TODO：将所有的“evaluate to”翻译成“的值是” -->
*语义*：一个`lambda`表达式的值是一个过程。当`lambda`表达式被求值时的有效环境被作为过程的一部分被记忆。当过程随后以一些参数被调用的时候，`lambda`表达式被求值时使用的环境通过绑定参数列表中的变量到新的位置的方式被扩展，且相应的实参值被存储到那些位置。然后，`lambda`表达式内部的表达式（其可能包含定义，因此可能表现为一个`letrec*`形式，见第11.3小节）在扩展的环境中被顺序地求值。内部最后一个表达式的结果作为过程调用的结果被返回。

~~~ scheme
(lambda (x) (+ x x))            ‌⇒  a procedure
((lambda (x) (+ x x)) 4)        ‌⇒  8

((lambda (x)
   (define (p y)
     (+ y 1))
   (+ (p x) x))
 5)                             ‌⇒ 11

(define reverse-subtract
  (lambda (x y) (- y x)))
(reverse-subtract 7 10)         ‌⇒  3

(define add4
  (let ((x 4))
    (lambda (y) (+ x y))))
(add4 6)                        ‌⇒  10
~~~

`<Formals>`必须有下列的形式之一：

* `\(\texttt{(<variable$_1$> ...)}\)` :过程拥有固定数量的参数。当过程被调用时，参数将被存储在相应变量的绑定中。
* `<variable>`:过程拥有任意数量的参数。当过程被调用时，实参的序列被转换为一个新创建的表，该表存储在󰀎variable󰀏的绑定中。
* `\(\texttt{(<variable$_1$> ... <variable$_n$> . <variable$_{n+1}$>)}\)`:如果一个由空格分隔的句点出现在最后一个变量之前，该过程就拥有n个或更多个参数，这里的n是句点前面形参的个数（至少要有一个）。存储在最后一个参数绑定中的值是一个新创建的表。除了已和其他形参匹配的所有其他实参外，剩余的实参都被存入该表中。

~~~ scheme
((lambda x x) 3 4 5 6)          ‌⇒  (3 4 5 6)
((lambda (x y . z) z)
 3 4 5 6)                       ‌⇒  (5 6)
~~~

在`<formals>`中任何`<variable>`必须不能出现超过一次。

### 11.4.3. 条件表达式（Conditionals）

| `(if <test> <consequent> <alternate>)‌‌` | 语法 
| `(if <test> <consequent>)‌‌` | 语法

*语法*：`<Test>`, `<consequent>`, 和`<alternate>`必须是表达式。

*语义*：一个`if`表达式按如下方式计算：首先，计算`<test>`的值。如果产生一个真值（见第5.7小节），然后`<consequent>`被计算，且它的值被返回。否则，`<alternate>`被计算，且它的值被返回。如果`<test>`产生`#f`且没有指定`<alternate>`，那么，表达式的结果是未定义的。

~~~ scheme
(if (> 3 2) 'yes 'no)           ‌⇒  yes
(if (> 2 3) 'yes 'no)           ‌⇒  no
(if (> 3 2)
    (- 3 2)
    (+ 3 2))                    ‌⇒  1
(if #f #f)                    ‌⇒ unspecified
~~~

`<Consequent>`和`<alternate>`表达式在尾上下文中，如果`if`表达式它自己在的话；见第11.20小节。

### 11.4.4. 赋值 <!-- Assignments -->

`(set! <variable> <expression>)` 语法

<!-- 将前面所有的出现在句首的<>的第一个字母大写 -->
`<Expression>`被计算，且结果值被存进`<variable>`绑定的位置。<Variable>必须在包含`set!`表达式的区域或顶层被绑定。`set!`表达式的结果是未定义的。

~~~ scheme
(let ((x 2))
  (+ x 1)
  (set! x 4)
  (+ x 1)) ‌⇒  5
~~~

如果`<variable>`引用一个不可修改的绑定，那么这时一个语法错误。

<p><font size="2"><i>注意：</i>标识符<code>set!</code>同时以级别1被导出。见第11.19小节。</font></p>

### 11.4.5. 派生条件表达式（Derived conditionals）

| |
|:-|-:
| `(cond <cond clause1> <cond clause2> ...)‌‌` |  语法
| `=>` | 辅助语法
| `else` | 辅助语法

语法：每一个` <cond clause>`必须是形式

`(<test> <expression1> ...)`

其中`<test>`是一个表达式。或有另一种选择，一个`<cond clause>`可以是形式

`(<test> => <expression>)`

最后一个`<cond clause>`可以是一个“`else`子句”，其有形式

`(else <expression1> <expression2> ...)`。

*语义*：一个`cond`表达式通过以下方式求值，按顺序连续地对`<test>`表达式进行求值直到它们其中一个的值是真值（见第5.7小节）。当一个`<test>`的值是真值的时候，就会顺序地对它`<cond clause>`中剩余的`<expression>`进行求值，且`<cond clause>`中最后一个`<expression>`的结果会作为整个`cond`表达式的结果被返回。如果被选择的`<cond clause>`只包含`<test>`且没有`<expression>`，那么`<test>`的值会作为结果被返回。如果被选择的`<cond clause>`使用`=>`辅助形式，那么`<expression>`被计算。它的值必须是一个过程。这个过程必须接受一个参数；它被以`<test>`的值调用，且过程返回的值作为`cond`表达式的值返回。如果所有的`<test>`的值都是`#f`，那么条件表达式返回未定义的值；如果有一个`else`子句，那么它的`<expression>`被计算，且最后一个的值被返回。

~~~ scheme
(cond ((> 3 2) 'greater)
      ((< 3 2) 'less))          ‌⇒  greater
(cond ((> 3 3) 'greater)
      ((< 3 3) 'less)
      (else 'equal))            ‌⇒  equal
(cond ('(1 2 3) => cadr)
      (else #f))                ‌⇒  2
~~~

对于一个有下列的形式之一的`<cond clause>`

~~~ scheme
(<test> <expression1> ...)
(else <expression1> <expression2> ...)
~~~

最后一个`<expression>`在尾上下文中，如果`cond`形式它自己在的话。一个如下形式的`<cond clause>`

`(<test> => <expression>)`

来自`<expression>`求值结果的过程的（隐式）调用在尾上下文中如果`cond`形式它自己在的话。见第11.20小节。

一个更简单形式的`cond`的参考定义可以在附录B中被找到。

`\(\texttt{(case <key> <case clause$_1$> <case clause$_2$> ...)}\)` 语法

*语法*：`<Key>`必须是一个表达式。每一个`<case clause>`必须有下列形式之一：

~~~ scheme
((<datum\(_1\)> ...) <expression\(_1\)> <expression\(_2\)> ...)
(else <expression\(_1\)> <expression\(_2\)> ...)
~~~

第二个形式，其指定一个“`else`子句”，只可以作为最后一个`<case clause>`出现。每一个`<datum>`是一些对象的一个外部表示。`<Datum>`表示的数据不需要有区别。

*语义*：一个`case`按如下求值。`<key>`被求值，且它的结果被和每个`<case clause>`中的`<datum>`表示的数据轮流比较，比较的依据是`eqv?`（见第11.5小节），以从左到右的顺序在整个子句的集合中进行。如果求值后`<key>`的值等于一个`<case clause>`的数据，对应的表达式被从左向右地求值，且`<case clause>`最后一个表达式的结果将作为`case`表达式的结果被返回。如果求值后的`<key>`的值和每个子句中的数据都不一样，那么如果有一个`else`子句的话，它的表达式被计算且最后一个的结果作为`case`表达式的结果被返回；否则`case`表达式的返回未定义的值。

~~~ scheme
; 本示例已根据勘误表修改
(case (* 2 3)
  ((2 3 5 7) 'prime)
  ((1 4 6 8 9) 'composite))     ‌⇒  composite
(case (car '(c d))
  ((a) 'a)
  ((b) 'b))                     ‌⇒  unspecified
(case (car '(c d))
  ((a e i o u) 'vowel)
  ((w y) 'semivowel)
  (else 'consonant))            ‌⇒  consonant
~~~

一个`<case clause>`的最后一个`<expression>`在尾上下文中，如果`case`表达式它自己在的话；见第11.20小节。

`\(\texttt{(and <test$_1$> ...)}\)` 语法

*语法*：`<Test>`必须是一个表达式。

*语义*：如果没有`<test>`，`#t`被返回。否则`<test>`表达式被从左向右地求值，直到一个`<test>`返回`#f`，或到达最后一个`<test>`。前一种情况下，`and`表达式在不计算剩余表达式的情况下返回`#f`。后一种情况，最后一个表达式被计算且它的值被返回。

~~~ scheme
(and (= 2 2) (> 2 1))           ‌⇒  #t
(and (= 2 2) (< 2 1))           ‌⇒  #f
(and 1 2 'c '(f g))             ‌⇒  (f g)
(and)                           ‌⇒  #t
~~~

`and`关键词可以使用`syntax-rules`（见第11.19小节）根据`if`进行定义，如下所示：

~~~ scheme
(define-syntax and
  (syntax-rules ()
    ((and) #t)
    ((and test) test)
    ((and test1 test2 ...)
     (if test1 (and test2 ...) #f))))
~~~

最后一个`<test>`表达式在尾上下文中，如果`and`表达式它自己在的话；见第11.20小节。

`\(\texttt{(or <test$_1$> ...)}\)` 语法

*语法*：`<Test>`必须是一个表达式。

*语义*：如果没有`<test>`，那么`#f`被返回。否则，`<test>`按照从左到右的顺序被求值，直到一个`<tesst>`返回真值*val*（见第5.7小节），或到达最后一个`<test>`。在前一种情况，`or`表达式在不计算剩余表达式的情况下返回*val*。后一种情况，最后一个表达式被求值，且它的值被返回。

~~~ scheme
(or (= 2 2) (> 2 1))            ‌⇒  #t
(or (= 2 2) (< 2 1))            ‌⇒  #t
(or #f #f #f) ‌⇒  #f
(or '(b c) (/ 3 0))             ‌⇒  (b c)
~~~

`or`关键词可以使用`syntax-rules`（见第11.19小节）根据`if`进行定义，如下所示：

~~~ scheme
(define-syntax or
  (syntax-rules ()
    ((or) #f)
    ((or test) test)
    ((or test1 test2 ...)
     (let ((x test1))
       (if x x (or test2 ...))))))
~~~

最后一个`<test>`表达式在尾上下文中，如果`or`表达式它自己也在的话；见第11.20小节。

### 11.4.6. 绑定结构 <!-- Binding constructs -->

本节描述的绑定结构为变量创建本地绑定，它们只可以在一个限定的区域可见。结构`let`, `let*`, `letrec`, 和`letrec*`的语法是一样的，但是它们为它们的变量绑定建立的作用域是不一样的，且绑定的值计算的顺序是不一样的。在一个`let`表达式中，初始值被计算在任何变量被绑定之前；在一个`let*`表达式中，绑定和求值依次地执行。在一个`letrec`或`letrec*`表达式中，当所有的绑定正在被计算的时候所以的绑定生效，因此允许相互递归的定义。在一个`letrec`表达式中，初始值在赋值给变量之前被计算；在一个`letrec*`中，计算和赋值依次地进行。

此外，绑定结构`let-values`和`let*-values`使得`let`和`let*`更加通用，起允许多个变量绑定到值是多个值得表达式的结果。在建立作用域的方面，它们类似于`let`和`let*`：在一个`let-values`表达式中，初始值被计算在任何变量被绑定之前；在一个`let*-values`表达式中，绑定依次进行。

本节提到的所有绑定形式根据更简单形式的参考定义可以在附录B中找到。

`(let <bindings> <body>)` 语法

*语法*：`<Bindings>`必须有形式

`\(\texttt{((<variable$_1$> <init$_1$>) ...)}\)`，

其中，每一个`<init>`是一个表达式，且`<body>`如第11.3小节描述。在`<variable>`中任何变量不能出现超过一次。

*语义*：`<Init>`在当前的环境被求值（以一个未定义的顺序），`<variable>`被绑定到存有结果的新鲜的位置，`<body>`在扩展后的环境被求值，且`<body>`的最后一个表达式的值被返回。每个`<variable>`的绑定都将`<body>`作为它的作用域。

~~~ scheme
(let ((x 2) (y 3))
  (* x y))                      ‌⇒  6

(let ((x 2) (y 3))
  (let ((x 7)
        (z (+ x y)))
    (* z x)))                   ‌⇒  35
~~~

零参见命名的`let`，见第11.16小节。

`(let* <bindings> <body>)` 语法

*语义*：`<Bindings>`必须是形式

`\(\texttt{((<variable$_1$> <init$_1$>) ...)}\)`，

其中，每一个`<init>`是一个表达式，且`<body>`如第11.3小节描述。

*语义*：`let*`形式类似于`let`，但是`<init>`的求值和绑定的创建是从左向右顺序进行的，但其作用域不但包括`<body>`，还包括其右边的部分。因此，第二个绑定在第一个绑定可见且初始化的环境中被计算，以此类推。

~~~ scheme
(let ((x 2) (y 3))
  (let* ((x 7)
         (z (+ x y)))
    (* z x)))             ‌⇒  70
~~~

<p><font size="2"><i>注意：</i>通过<code>let</code>表达式绑定的变量必须是不一样的，而通过<code>let*</code>表达式绑定的变量则没有这个限制。</font></p>

`(letrec <bindings> <body>)` 语法

*语法*：`<Bindings>`必须有形式

`\(\texttt{((<variable$_1$> <init$_1$>) ...)}\)`，

其中，每一个`<init>`是一个表达式，且`<body>`如第11.3小节描述。在`<variable>`中任何变量不能出现超过一次。

*语义*：`<variable>`被绑定到新的位置，`<init>`在结果环境中被求值（以一些未定义的顺序），每一个`<variable>`被分配给对应的`<init>`的结果，`<body>`在结果环境中被求值，且`<body>`中最后一个表达式的值被返回。每个`<variable>`的绑定将整个`letrec`表达式作为它的作用域，这使得定义相互递归的过程成为可能。

~~~ scheme
(letrec ((even?
          (lambda (n)
            (if (zero? n)
                #t
                (odd? (- n 1)))))
         (odd?
          (lambda (n)
            (if (zero? n)
                #f
                (even? (- n 1))))))
  (even? 88))   
                ‌⇒  #t
~~~

在不赋值或引用任何`<variable>`的值的情况下，计算每个`<init>`应该是可能的。在`letrec`的大部分常规使用中，所有的`init`是`lambda`表达式，此时限制被自动满足。另一个限制是，每个`<init>`的继续不能被调用多于一次。

*实现的责任*：实现必须在`<init>`表达式求值（使用一个特定的求值顺序且<!-- TODO -->顺序`<init>`表达式的值）期间检测`<variable>`的引用。如果实现检测到这样一个限制的违反，它必须抛出一个条件类型是`&assertion`的异常。实现可以也可以不检测每个`<init>`的继续是否被调用多于一次。可是，如果实现检测到的话，它必须抛出一个条件类型是`&assertion`的异常。

`(letrec* <bindings> <body>)` 语法

*语法*：`<Bindings>`必须有形式

`\(\texttt{((<variable$_1$> <init$_1$>) ...)}\)`，

其中，每一个`<init>`是一个表达式，且`<body>`如第11.3小节描述。在`<variable>`中任何变量不能出现超过一次。

*语义*：`<Variable>`被绑定到新鲜的位置，每个`<variable>`被按从左向右的顺序分配给对应的`<init>`的求值结果，`<body>`在结果环境中被求值，且`<body>`中最后一个表达式的值被返回。尽管求值和赋值的顺序是从左向右的，但是每一个`<variable>`的绑定将整个`letrec*`表达式作为其作用域，这使得定义相互递归的过程成为可能。

~~~ scheme
(letrec* ((p
           (lambda (x)
             (+ 1 (q (- x 1)))))
          (q
           (lambda (y)
             (if (zero? y)
                 0
                 (+ 1 (p (- y 1))))))
          (x (p 5))
          (y x))
  y)
                ‌⇒  5
~~~

在不赋值或引用对应的`<variable>`或任何在`<bindings>`跟随它的任何绑定的`<variable>`的值的情况下，计算每个`<init>`必须是可能的。如果实现检测到这样一个限制的违反，它必须抛出一个条件类型是`&assertion`的异常。实现可以也可以不检测每个`<init>`的继续是否被调用多于一次。可是，如果实现检测到的话，它必须抛出一个条件类型是`&assertion`的异常。

`(let-values <mv-bindings> <body>)` 语法

*语法*：`<Mv-bindings>`必须有形式

`\(\texttt{((<formals$_1$> <init$_1$>) ...)}\)`，


其中，每一个`<init>`是一个表达式，且`<body>`如第11.3小节描述。在`<formals>`集合中任何变量必须不能出现超过一次。

*语义*：`<Init>`在当前的环境中被求值（以一些未定义的顺序），且出现在`<formals>`中的变量被绑定到包含`<init>`返回值的新鲜位置，其中`<formals>`匹配返回值就像`lambda`表达式中的`<formals>`在过程调用中匹配参数一样。然后，`<body>`在扩展后的环境中被求值，且`<body>`中最后一个表达式的值被返回。每个变量绑定将`<body>`作为它的作用域。如果`<formals>`不匹配的话，那么一个条件类型是`&assertion`的异常被抛出。

~~~ scheme
(let-values (((a b) (values 1 2))
             ((c d) (values 3 4)))
  (list a b c d))                ‌⇒ (1 2 3 4)

(let-values (((a b . c) (values 1 2 3 4)))
  (list a b c))                  ‌⇒ (1 2 (3 4))

(let ((a 'a) (b 'b) (x 'x) (y 'y))
  (let-values (((a b) (values x y))
               ((x y) (values a b)))
    (list a b x y)))             ‌⇒ (x y a b)
~~~

`(let*-values <mv-bindings> <body>)` 语法

*语法*：`<Mv-bindings>`必须有形式

`\(\texttt{((<formals$_1$> <init$_1$>) ...)}\)`，


其中，每一个`<init>`是一个表达式，且`<body>`如第11.3小节描述。在每个`<formals>`中，任何变量必须不能出现超过一次。

*语义*：`let*-value`形式类似于`let-value`，但是`<init>`被计算和绑定被创建是按从左到右的顺序进行的，每个`<formals>`绑定的作用域除了`<body>`还包括它的右边。因此，第二个`<init>`在第一个`<formals>`可见且被初始化的环境中被求值，以此类推。


<p><font size="2"><i>注意：</i>通过<code>let-values</code>表达式绑定的变量必须是不一样的，而通过<code>let*-values</code>表达式的不同<code>&lt;formals&gt;</code>绑定的变量则没有这个限制。</font></p>

### 11.4.7. 顺序结构（Sequencing）

| `(begin <form> ...)` | ‌‌语法
| `(begin <expression> <expression> ...)` | ‌‌语法

`<Begin>`关键词有两个不同的作用，取决于它的上下文：

* 它可以作为一个形式出现在一个`<body>`中（见第11.3小节），一个`<library body>`中（见第7.1小节），或一个`<top-level body>`（见第3章），或直接嵌套在一个内部的`begin`形式中。在这种情况下，`begin`形式必须有第一个标题行指定的形状。`begin`的这种用法作为一种*拼接（splicing）*形式—`<body>`里面的形式被拼接到内部周围，就好像原来的`begin`包装不存在一样。  
`<Body>`或`<library body>`中的`begin`形式必须是非空的，如果它在内部出现在第一个`<expression>`之后。

* 它可以作为一个普通的表达式出现，且必须有第二个标题行指定的形状。在这种情况下，`<expression>`被按从左到右的顺序求值，且最后一个`<expression>`的值被返回。这种表达式类型被用作按顺序排列副作用，如赋值或输入输出。

~~~ scheme
(define x 0)

(begin (set! x 5)
       (+ x 1))                  ‌⇒  6

(begin (display "4 plus 1 equals ")
       (display (+ 4 1)))      ‌⇒  unspecified
  and prints  4 plus 1 equals 5
~~~

## 11.5 等价谓词 <!-- Equivalence predicates -->

一个*谓词*是一个总是返回布尔值（`#t`或`#f`）的过程。一个*等价谓词*在计算上模拟数学上的等价关系（它是对称的（symmetric），自反的（reflexive），且传递的（transitive））。在本节表述的等价谓词中，`eq?`是最好或最精细的，`equal?`是最粗糙的。`eqv?`比`eq?`的辨别能力稍差。

`\(\texttt{(eqv? obj$_1$ obj$_2$)}\)` 过程

`eqv?`定义在对象上定义一个有用的等价关系。简单地说，它返回`#t`，如果*obj\\\(_1\\\)*和*obj\\\(_2\\\)*在通常情况下被认为是相等的对象的话，否则返回`#f`。这种关系不太好解释，但下面所列的`eqv?`部分规范必须被所有的实现遵守。

`eqv?`过程在以下情况返回`#t`：

* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*都是布尔，且根据`boolean=?`过程它们是一样的（第11.8小节）。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*都是符号，且根据`symbol=?`过程它们是一样的（第11.10小节）。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*都是精确数，且在数学上相等（见`=`，第11.7小节）。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*都是非精确数字对象，且在数学上相等（见`=`，第11.7小节），且作为参数传递给任意其它可以通过Scheme标准算术过程定义的过程时产生的结果都是一样的（从`eqv?`的意义上说），只要计算过程中不涉及非数。（本句已根据勘误表补全。）
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*都是字符，且根据`char=?`过程它们是一样的（见第11.11小节）。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*都是空表。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*都是对象，比如点对，向量，字节向量（库的第2章），字符串，记录（库的第6章），端口（库的第8.2小节），或哈希表（库的第13章），且指向相同的存储位置（第5.10小节）。（原文中有一个重复的“哈希表”，已被删除。）
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*都是记录类型（record-type）描述符，它们在库的第6.3小节被指定为是`eqv?`等价的。

`eqv?`过程在以下情况返回`#f`：

* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*是不同的类型（第11.1小节）。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*是布尔，但`boolean=?`过程返回`#f`。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*是符号，但`symbol=?`过程返回`#f`。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*一个是精确数字对象，另一个是非精确数字对象。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*是有理数字对象，但`=`过程返回`#f`。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*作为参数传递给任意其它可以通过Scheme标准算术过程定义的过程时产生不一样的结果（从`eqv?`的意义上说），只要计算过程中不涉及非数。（本句已根据勘误表补全。）
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*是字符，但`char=?`过程返回`#f`。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*一个是空表，但另一个不是。<!-- TODO：和类型不同重复 -->
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*是对象，比如点对，向量，字节向量（库的第2章），字符串，记录（库的第6章），端口（库的第8.2小节），或哈希表（库的第13章），但指向不同的位置。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*是点对，向量，字符串，或记录，或哈希表，向其内部应用相同的访问器（也就是`car`, `cdr`, `vector-ref`, `string-ref`, 或记录访问器）但产生的值在`eqv?`下返回`#f`。
* *Obj\\\(_1\\\)*和*obj\\\(_2\\\)*是过程，但对于某些参数有不同的行为（返回不同的值或有不同的副作用）。

<p><font size="2"><i>注意：</i>当<i>obj\(_1\)</i>和<i>obj\(_2\)</i>是数字对象时，`eqv?`过程返回`#t`并不意味着`=`在相同的<i>obj\(_1\)</i>和<i>obj\(_2\)</i>参数下也返回`#t`。</font></p>

~~~ scheme
(eqv? 'a 'a)                     ‌⇒  #t
(eqv? 'a 'b)                     ‌⇒  #f
(eqv? 2 2)                       ‌⇒  #t
(eqv? '() '())                   ‌⇒  #t
(eqv? 100000000 100000000)       ‌⇒  #t
(eqv? (cons 1 2) (cons 1 2))     ‌⇒  #f
(eqv? (lambda () 1)
      (lambda () 2))             ‌⇒  #f
(eqv? #f 'nil)                   ‌⇒  #f
~~~

下面的例子展示了上面的规则没有完全定义的`eqv?`的行为。对于这些情况，我们只能说`eqv?`的返回值必须是一个布尔。

~~~ scheme
(let ((p (lambda (x) x)))
  (eqv? p p))                    ‌⇒  unspecified
(eqv? "" "")                     ‌⇒  unspecified
(eqv? '#() '#())                 ‌⇒  unspecified
(eqv? (lambda (x) x)
      (lambda (x) x))            ‌⇒  unspecified
(eqv? (lambda (x) x)
      (lambda (y) y))            ‌⇒  unspecified
(eqv? +nan.0 +nan.0)             ‌⇒  unspecified
~~~

下面的例子集合展示了对有本地状态的过程使用`eqv?`的情况。对`gen-counter`的每一次调用都必须付汇一个不同的过程，因为每个过程都有它自己内部的计数。`gen-loser`的调用返回的过程被调用的时候行为是一样的。然而，`eqv?`可以不检测这种相等。

~~~ scheme
(define gen-counter
  (lambda ()
    (let ((n 0))
      (lambda () (set! n (+ n 1)) n))))
(let ((g (gen-counter)))
  (eqv? g g))           ‌⇒  unspecified
(eqv? (gen-counter) (gen-counter))
                        ‌⇒  #f

(define gen-loser
  (lambda ()
    (let ((n 0))
      (lambda () (set! n (+ n 1)) 27))))
(let ((g (gen-loser)))
  (eqv? g g))           ‌⇒  unspecified
(eqv? (gen-loser) (gen-loser))
                        ‌⇒  unspecified

(letrec ((f (lambda () (if (eqv? f g) 'both 'f)))
         (g (lambda () (if (eqv? f g) 'both 'g))))
  (eqv? f g)) ‌⇒  unspecified

(letrec ((f (lambda () (if (eqv? f g) 'f 'both)))
         (g (lambda () (if (eqv? f g) 'g 'both))))
  (eqv? f g))           ‌⇒  #f
~~~

实现可以在适当的时候在常量间共享结构。（根据勘误表，此处省略一句话。）因此，作用在常量上的`eqv?`的返回值有时是实现定义的。

~~~ scheme
(eqv? '(a) '(a))                 ‌⇒  unspecified
(eqv? "a" "a")                   ‌⇒  unspecified
(eqv? '(b) (cdr '(a b)))         ‌⇒  unspecified
(let ((x '(a)))
  (eqv? x x))                    ‌⇒  #t
~~~

`\(\texttt{(eq? obj$_1$ obj$_2$)}\)` 过程

`eq?`谓词和`eqv?`类似，除了在一些情况其识别差别的能力比`eqv?`更加精细之外。

`eq?`和`eqv?`确保在符号，布尔，空表，点对，过程，非空字符串，字节向量，和向量，以及记录的行为是一样的。`eq?`在数字对象，字符上的行为是实现定义的，但是它总是或者返回`#t`或者返回`#f`，且只有当`eqv?`返回`#t`时它才有可能返回`#t`。`eq?`谓词在空表，空向量，空字节向量和空字符串上的行为也可以是不一样的。

~~~ scheme
(eq? 'a 'a)                     ‌⇒  #t
(eq? '(a) '(a))                 ‌⇒  unspecified
(eq? (list 'a) (list 'a))       ‌⇒  #f
(eq? "a" "a")                   ‌⇒  unspecified
(eq? "" "")                     ‌⇒  unspecified
(eq? '() '())                   ‌⇒  #t
(eq? 2 2)                       ‌⇒  unspecified
(eq? #\A #\A)                   ‌⇒  unspecified
(eq? car car)                   ‌⇒  unspecified（本条已根据勘误表修改）
(let ((n (+ 2 3)))
  (eq? n n))                    ‌⇒  unspecified
(let ((x '(a)))
  (eq? x x))                    ‌⇒  #t
(let ((x '#()))
  (eq? x x))                    ‌⇒  unspecified
(let ((p (lambda (x) x)))
  (eq? p p))                    ‌⇒  unspecified
~~~

`\(\texttt{(equal? obj$_1$ obj$_2$)}\)` 过程

`equal?`谓词返回`#t`当且仅当它的参数（可能无限地）到正则树（regular trees）的展开作为有序树是一样的（ordered trees）。<!-- TODO -->

`equal?`谓词对待点对和向量作为有出边（outgoing edges）的节点，使用`string=?`比较字符串，使用`bytevector=?`比较字节向量（见库的第2章），且使用`eqv?`比较其它节点。

~~~ scheme
(equal? 'a 'a)                  ‌⇒  #t
(equal? '(a) '(a))              ‌⇒  #t
(equal? '(a (b) c)
        '(a (b) c))             ‌⇒  #t
(equal? "abc" "abc")            ‌⇒  #t
(equal? 2 2)                    ‌⇒  #t
(equal? (make-vector 5 'a)
        (make-vector 5 'a))     ‌⇒  #t
(equal? '#vu8(1 2 3 4 5)
        (u8-list->bytevector
         '(1 2 3 4 5))          ‌⇒  #t
(equal? (lambda (x) x)
        (lambda (y) y))         ‌⇒  unspecified

(let* ((x (list 'a))
       (y (list 'a))
       (z (list x y)))
  (list (equal? z (list y x))
        (equal? z (list x x))))             
                                ‌‌⇒  (#t #t)
~~~

<p><font size="2"><i>注意：</i><code>equal?</code>必须总是可以终止的，哪怕它的参数存在循环。</font></p>

## 11.6. 过程谓词 <!-- Procedure predicate -->

`(procedure? obj)` 过程

返回`#t`如果*obj*是一个过程，否则返回`#f`。

~~~ scheme
(procedure? car)            ‌⇒  #t
(procedure? 'car)           ‌⇒  #f
(procedure? (lambda (x) (* x x)))   
                            ‌⇒  #t
(procedure? '(lambda (x) (* x x)))  
                            ‌⇒  #f
~~~

## 11.7. 算术（Arithmetic）

这里描述的过程实现了在第3章描述的数值塔上通用的算术。本节描述的通用过程既接受精确数也接受非精确数对象作为其参数，并根据它们参数的数值子类型执行强制转换和选取适当的操作。

库的第11章描述了定义其它数值过程的库。

### 11.7.1. 精确性和非精确性的传播 <!-- Propagation of exactness and inexactness -->

下面列出的过程在传递给它们的参数都是精确的时候必须返回数学上正确的精确结果：

~~~ scheme
+            -            *
max          min          abs
numerator    denominator  gcd
lcm          floor        ceiling
truncate     round        rationalize
real-part    imag-part    make-rectangular
~~~

下面列出的过程当传递给它们的参数都是精确的且没有除数是零的时候必须返回正确的精确结果：

~~~ scheme
/
div          mod           div-and-mod
div0         mod0          div0-and-mod0
~~~

此外，过程`expt`必须返回正确的精确结果，当传递给它的第一个参数是一个精确的实数对象且第二个参数是一个精确的整数对象。

通用的规则是，一般操作返回正确精确的结果，当所有传递给它们的参数都是精确的且结果是数学上明确定义的，但是当任何一个参数是非精确的时候返回一个非精确结果。这条规则的例外包括`sqrt`, `exp`, `log`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `expt`, `make-polar`, `magnitude`, 和`angle`，其甚至可以（但不要求）在传递精确参数的时候返回非精确的结果，如这些过程的规范所示。

上面规则的一个普遍的例外是，一个实现可以返回一个精确结果尽管其参数是非精确的，但这个精确的结果对于所有可能的对这个非精确参数的精确替代，都应该是正确的。一个例子是`(* 1.0 0)`，其可以返回`0`（精确地）或`0.0`（非精确的）。

### 11.7.2. 无穷大和非数的表示性（Representability）<!-- of infinities and NaNs -->





<!--
  （勘误：11.6（9），11.7.4）

  TODO：将逗号由中文改为英文
-->

# 附录E 语言的变化 <!-- Language changes -->

本章描述了自“修订<sup>5</sup>报告”[^14]出版以来Scheme发生的大部分变化：

* 现在，Scheme源代码使用Unicode字符集。尤其，可被用作标识符的字符集被大大地扩展了。
* 现在，标识符可以以`->`字符开始。
* 现在，标识符和符号字面量是大小写敏感的。
* 标识符和字符，布尔，数字对象和`.`的表示必须被显式地区分。<!-- TODO -->
* 现在，`#`是定界符（delimiter）。
* 字节向量字面量语法已被添加。
* 匹配的中括号可以和小括号等价得使用。
* 数据语法的简写`#'` (即`syntax`), `` #` `` (即`quasisyntax`), `#,` (即`unsyntax`), and `#,@` (即`unsyntax-splicing`)被添加；见4.3.5小节。<!-- TODO: 1. read-syntax 应该是 datum-syntax；2. 括号不对 -->
* `#`不再可以用在数字的表示中替换数字。
* 现在，数字对象的外部表示可以包括一个尾数宽度。
* 非输和无限大的字面量被添加。
* 现在，字符串和字符字面量可以使用各种转移序列。
* 块注释和数据注释被添加。
* 用作报告兼容的`#!r6rs`注释词汇语法被添加。
* 现在，字符指定对应的Unicode标量值。
* 现在，许多的程序和语言的句法形式是`(rnrs base (6))`库的一部分。一些过程和句法形式被转移到其它库中；见表A.1。

| 标识符 |  转移到
|:-|:-
| `assoc` | (rnrs lists (6))
| `assv` |  (rnrs lists (6))
| `assq` |  (rnrs lists (6))
| `call-with-input-file` |  (rnrs io simple (6))
| `call-with-output-file` | (rnrs io simple (6))
| `char-upcase` | (rnrs unicode (6))
| `char-downcase` | (rnrs unicode (6))
| `char-ci=?` | (rnrs unicode (6))
| `char-ci<?` | (rnrs unicode (6))
| `char-ci>?` | (rnrs unicode (6))
| `char-ci<=?` |  (rnrs unicode (6))
| `char-ci>=?` |  (rnrs unicode (6))
| `char-alphabetic?` |  (rnrs unicode (6))
| `char-numeric?` | (rnrs unicode (6))
| `char-whitespace?` |  (rnrs unicode (6))
| `char-upper-case?` |  (rnrs unicode (6))
| `char-lower-case?` |  (rnrs unicode (6))
| `close-input-port` |  (rnrs io simple (6))
| `close-output-port` | (rnrs io simple (6))
| `current-input-port` |  (rnrs io simple (6))
| `current-output-port` | (rnrs io simple (6))
| `display` | (rnrs io simple (6))
| `do` |  (rnrs control (6))
| `eof-object?` | (rnrs io simple (6))
| `eval` |  (rnrs eval (6))
| `delay` | (rnrs r5rs (6))
| `exact->inexact` |  (rnrs r5rs (6))
| `force` | (rnrs r5rs (6))
| `inexact->exact` |  (rnrs r5rs (6))
| `member` |  (rnrs lists (6))
| `memv` |  (rnrs lists (6))
| `memq` |  (rnrs lists (6))
| `modulo` |  (rnrs r5rs (6))
| `newline` | (rnrs io simple (6))
| `null-environment` |  (rnrs r5rs (6))
| `open-input-file` | (rnrs io simple (6))
| `open-output-file` |  (rnrs io simple (6))
| `peek-char` | (rnrs io simple (6))
| `quotient` |  (rnrs r5rs (6))
| `read` |  (rnrs io simple (6))
| `read-char` | (rnrs io simple (6))
| `remainder` | (rnrs r5rs (6))
| `scheme-report-environment` | (rnrs r5rs (6))
| `set-car!` |  (rnrs mutable-pairs (6))
| `set-cdr!` |  (rnrs mutable-pairs (6))
| `string-ci=?` | (rnrs unicode (6))
| `string-ci<?` | (rnrs unicode (6))
| `string-ci>?` | (rnrs unicode (6))
| `string-ci<=?` |  (rnrs unicode (6))
| `string-ci>=?` |  (rnrs unicode (6))
| `string-set!` | (rnrs mutable-strings (6))
| `string-fill!` |  (rnrs mutable-strings (6))
| `with-input-from-file` |  (rnrs io simple (6))
| `with-output-to-file` | (rnrs io simple (6))
| `write` | (rnrs io simple (6))
| `write-char` |  (rnrs io simple (6))

表 A.1：标识符转移到库中

* 基本语言有下列新的过程和句法形式：`letrec*`, `let-values`, `let*-values`, `real-valued?`, `rational-valued?`, `integer-valued?`, `exact`, `inexact`, `finite?`, `infinite?`, `nan?`, `div`, `mod`, `div-and-mod`, `div0`, `mod0`, `div0-and-mod0`, `exact-integer-sqrt`, `boolean=?`, `symbol=?`, `string-for-each`, `vector-map`, `vector-for-each`, `error`, `assertion-violation`, `assert`, `call/cc`, `identifier-syntax`。
* 下列的过程被移除：`char-ready?`, `transcript-on`, `transcript-off`, `load`。
* 大小写不敏感的字符串比较（`string-ci=?`, `string-ci<?`, `string-ci>?`, `string-ci<=?`, `string-ci>=?`）操作字符串大小写折叠（case-folded）的版本，而不是其对应的字符比较过程的简单的字典序。
* 库被加到了语言当中。
* 许多的标准库在一个单独的报告[^24]中被描述。
* 许多“是一个错误”的情况现在有了预定义的或强制的行为。尤其，其中许多现在按照异常系统指定。
* 现在，完整的数值塔是必须的。
* 超越函数（transcendental functions）的语义被更加完整地指定。
* 以零为底数的`expt`的语义被改善
* 在`syntax-rules`形式中，一个`_`可以被用作取代关键词。
* `let-syntax`和`letrec-syntax`不再为它们的内部引入一个新的环境。
* 对于支持非数和无限大的实现，在这些值上的许多算术操作被指定和IEEE 754相一致。
* 对于支持严格的-0.0的实现，关于-0.0的许多算术操作的语义被指定和IEEE 754相一致。
* 现在，Scheme的实数对象有一个精确的零作为它们的虚部。
* `quasiquote`的规范被扩展了。现在，嵌套的quasiquotation可以正确地工作，且`unquote`和`unquote-splicing`被扩展到一些操作数上。
* 现在，过程可以指向一个位置，或者也可以不指向一个位置。因此，在一些以前`eqv?`有指定行为的地方，现在，其是未定义的。
* `quasiquote`结构的值的易变性在某种程度上被指定。
* 现在，`dynamic-wind`的*before*和*after*过程的动态环境是定义的。
* 现在，只有副作用的各种表达式允许返回任意数量的值。
* 宏扩展的顺序和语义被更加完整地指定。
* 现在，内部定义按照`letrec*`定义。
* 程序结构和Scheme顶层环境的旧符号被顶层程序和库代替。
* 指称语义（denotational semantics）被一个基于“修订<sup>5</sup>报告”[^14]一个早期语义的操作语义（operational semantics）[^18]取代。

# 参考文献 <!-- REFERENCES -->

[^1]:      J. W. Backus, F.L. Bauer, J.Green, C. Katz, J. McCarthy P. Naur, A. J. Perlis, H. Rutishauser, K. Samuelson, B. Vauquois J. H. Wegstein, A. van Wijngaarden, and M. Woodger. Revised report on the algorithmic language Algol 60. *Communications of the ACM*, 6(1):1–17, 1963.
[^2]:      Alan Bawden and Jonathan Rees. Syntactic closures. In *ACM Conference on Lisp and Functional Programming*, pages 86–95, Snowbird, Utah, 1988. ACM Press.
[^3]:      Scott Bradner. Key words for use in RFCs to indicate requirement levels. <http://www.ietf.org/rfc/rfc2119.txt>, March 1997. RFC 2119.
[^4]:      Robert G. Burger and R. Kent Dybvig. Printing floating-point numbers quickly and accurately. In *Proceedings of the ACM SIGPLAN '96 Conference on Programming Language Design and Implementation*, pages 108–116, Philadelphia, PA, USA, May 1996. ACM Press.
[^5]:      William Clinger. Proper tail recursion and space efficiency. In Keith Cooper, editor, *Proceedings of the 1998 Conference on Programming Language Design and Implementation*, pages 174–185, Montreal, Canada, June 1998. ACM Press. Volume 33(5) of SIGPLAN Notices.
[^6]:      William Clinger and Jonathan Rees. Macros that work. In *Proceedings 1991 ACM SIGPLAN Symposium on Principles of Programming Languages*, pages 155–162, Orlando, Florida, January 1991. ACM Press.
[^7]:      William D. Clinger. How to read floating point numbers accurately. In *Proceedings Conference on Programming Language Design and Implementation '90*, pages 92–101, White Plains, New York, USA, June 1990. ACM.
[^8]:      R. Kent Dybvig. *Chez Scheme Version 7 User's Guide*. Cadence Research Systems, 2005. <http://www.scheme.com/csug7/>.
[^9]:      R. Kent Dybvig, Robert Hieb, and Carl Bruggeman. Syntactic abstraction in Scheme. *Lisp and Symbolic Computation*, 1(1):53–75, 1988.
[^10]:     Matthias Felleisen and Matthew Flatt. Programming languages and lambda calculi. <http://www.cs.utah.edu/plt/publications/pllc.pdf>, 2003.
[^11]:     Matthew Flatt. *PLT MzScheme: Language Manual*. Rice University, University of Utah, July 2006. <http://download.plt-scheme.org/doc/352/html/mzscheme/>.
[^12]:     Daniel P. Friedman, Christopher Haynes, Eugene Kohlbecker, and Mitchell Wand. *Scheme 84 interim reference manual*. Indiana University, January 1985. Indiana University Computer Science Technical Report 153.
[^13]:     IEEE standard 754-1985. IEEE standard for binary floating-point arithmetic, 1985. Reprinted in SIGPLAN Notices, 22(2):9-25, 1987.
[^14]:     Richard Kelsey, William Clinger, and Jonathan Rees. Revised<sup>5</sup> report on the algorithmic language Scheme. *Higher-Order and Symbolic Computation*, 11(1):7–105, 1998.
[^15]:     Eugene E. Kohlbecker, Daniel P. Friedman, Matthias Felleisen, and Bruce Duba. Hygienic macro expansion. In *Proceedings of the 1986 ACM Conference on Lisp and Functional Programming*, pages 151–161, 1986.
[^16]:     Eugene E. Kohlbecker Jr. *Syntactic Extensions in the Programming Language Lisp*. PhD thesis, Indiana University, August 1986.
[^17]:     Jacob Matthews and Robert Bruce Findler. An operational semantics for R5RS Scheme. In J. Michael Ashley and Michael Sperber, editors, *Proceedings of the Sixth Workshop on Scheme and Functional Programming*, pages 41–54, Tallin, Estonia, September 2005. Indiana University Technical Report TR619.
[^18]:     Jacob Matthews and Robert Bruce Findler. An operational semantics for Scheme. *Journal of Functional Programming*, 2007. From <http://www.cambridge.org/journals/JFP/>.
[^19]:     Jacob Matthews, Robert Bruce Findler, Matthew Flatt, and Matthias Felleisen. A visual environment for developing context-sensitive term rewriting systems. In *Proceedings 15th Conference on Rewriting Techniques and Applications*, Aachen, June 2004. Springer-Verlag.
[^20]:     MIT Department of Electrical Engineering and Computer Science. *Scheme manual, seventh edition*, September 1984.
[^21]:     Jonathan A. Rees, Norman I. Adams IV, and James R. Meehan. *The T manual*. Yale University Computer Science Department, fourth edition, January 1984.
[^22]:     Michael Sperber, R. Kent Dybvig, Matthew Flatt, and Anton van Straaten. Revised<sup>6</sup> report on the algorithmic language Scheme (Non-Normative appendices). <http://www.r6rs.org/>, 2007.
[^23]:     Michael Sperber, R. Kent Dybvig, Matthew Flatt, and Anton van Straaten. Revised<sup>6</sup> report on the algorithmic language Scheme (Rationale). <http://www.r6rs.org/>, 2007.
[^24]:     Michael Sperber, R. Kent Dybvig, Matthew Flatt, Anton van Straaten, Richard Kelsey, William Clinger, and Jonathan Rees. Revised<sup>6</sup> report on the algorithmic language Scheme (Libraries). <http://www.r6rs.org/>, 2007.
[^25]:     Guy Lewis Steele Jr. *Common Lisp: The Language*. Digital Press, Burlington, MA, second edition, 1990.
[^26]:     Texas Instruments, Inc. *TI Scheme Language Reference Manual*, November 1985. Preliminary version 1.0.
[^27]:     The Unicode Consortium. *The Unicode standard, version 5.0.0*. defined by: The Unicode Standard, Version 5.0 (Boston, MA, Addison-Wesley, 2007. ISBN 0-321-48091-0), 2007.
[^28]:     William M. Waite and Gerhard Goos. *Compiler Construction*. Springer-Verlag, 1984.
[^29]:     Andrew Wright and Matthias Felleisen. A syntactic approach to type soundness. *Information and Computation*, 115(1):38–94, 1994. First appeared as Technical Report TR160, Rice University, 1991.

