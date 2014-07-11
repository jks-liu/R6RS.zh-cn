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
<center>已完成5%，最后修改于2014年07月11日</center>

# 摘要
报告给出了程序设计语言Scheme的定义性描述。Scheme是由Guy Lewis Steele Jr.和Gerald Jay Sussman设计的具有静态作用域和严格尾递归特性的Lisp程序设计语言的方言。它的设计目的是以异常清晰，语义简明和较少表达方式的方法来组合表达式。包括函数（functional）式，命令（imperative）式和消息传递（message passing）式风格在内的绝大多数程序设计模式都可以用Scheme方便地表述。

和本报告一起的还有一个描述标准库的报告[^24]；用描述符“library section”或“library chapter”来识别此文档的引用。和它一起的还有一个包含非规范性附录的报告[^22]。第四次报告在语言和库的许多方面阐述了历史背景和基本原理[^23]。

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

