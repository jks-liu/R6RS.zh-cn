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

# 摘要
报告给出了程序设计语言Scheme的定义性描述。Scheme是由Guy Lewis Steele Jr.和Gerald Jay Sussman设计的具有静态作用域和严格尾递归特性的Lisp程序设计语言的方言。它的设计目的是以异常清晰，语义简明和较少表达方式的方法来组合表达式。包括函数式，命令式和消息传递式风格在内的绝大多数程序设计模式都可以用Scheme方便地表述。

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
[^14]:     Richard Kelsey, William Clinger, and Jonathan Rees. Revised5 report on the algorithmic language Scheme. Higher-Order and Symbolic Computation, 11(1):7–105, 1998.
[^15]:     Eugene E. Kohlbecker, Daniel P. Friedman, Matthias Felleisen, and Bruce Duba. Hygienic macro expansion. In Proceedings of the 1986 ACM Conference on Lisp and Functional Programming, pages 151–161, 1986.
[^16]:     Eugene E. Kohlbecker Jr. Syntactic Extensions in the Programming Language Lisp. PhD thesis, Indiana University, August 1986.
[^17]:     Jacob Matthews and Robert Bruce Findler. An operational semantics for R5RS Scheme. In J. Michael Ashley and Michael Sperber, editors, Proceedings of the Sixth Workshop on Scheme and Functional Programming, pages 41–54, Tallin, Estonia, September 2005. Indiana University Technical Report TR619.
[^18]:     Jacob Matthews and Robert Bruce Findler. An operational semantics for Scheme. Journal of Functional Programming, 2007. From http://www.cambridge.org/journals/JFP/.
[^19]:     Jacob Matthews, Robert Bruce Findler, Matthew Flatt, and Matthias Felleisen. A visual environment for developing context-sensitive term rewriting systems. In Proceedings 15th Conference on Rewriting Techniques and Applications, Aachen, June 2004. Springer-Verlag.
[^20]:     MIT Department of Electrical Engineering and Computer Science. Scheme manual, seventh edition, September 1984.
[^21]:     Jonathan A. Rees, Norman I. Adams IV, and James R. Meehan. The T manual. Yale University Computer Science Department, fourth edition, January 1984.
[^22]:     Michael Sperber, R. Kent Dybvig, Matthew Flatt, and Anton van Straaten. Revised6 report on the algorithmic language Scheme (Non-Normative appendices). http://www.r6rs.org/, 2007.
[^23]:     Michael Sperber, R. Kent Dybvig, Matthew Flatt, and Anton van Straaten. Revised6 report on the algorithmic language Scheme (Rationale). http://www.r6rs.org/, 2007.
[^24]:     Michael Sperber, R. Kent Dybvig, Matthew Flatt, Anton van Straaten, Richard Kelsey, William Clinger, and Jonathan Rees. Revised6 report on the algorithmic language Scheme (Libraries). http://www.r6rs.org/, 2007.
[^25]:     Guy Lewis Steele Jr. Common Lisp: The Language. Digital Press, Burlington, MA, second edition, 1990.
[^26]:     Texas Instruments, Inc. TI Scheme Language Reference Manual, November 1985. Preliminary version 1.0.
[^27]:     The Unicode Consortium. The Unicode standard, version 5.0.0. defined by: The Unicode Standard, Version 5.0 (Boston, MA, Addison-Wesley, 2007. ISBN 0-321-48091-0), 2007.
[^28]:     William M. Waite and Gerhard Goos. Compiler Construction. Springer-Verlag, 1984.
[^29]:     Andrew Wright and Matthias Felleisen. A syntactic approach to type soundness. Information and Computation, 115(1):38–94, 1994. First appeared as Technical Report TR160, Rice University, 1991.

