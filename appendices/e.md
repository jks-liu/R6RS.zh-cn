---
layout: r6rs
title: '附录E. 语言的变化'
title_plain: '附录E. 语言的变化 — R6RS简体中文翻译'
permalink: /appendices/e/
r6rs: true
chapter_key: appendix-e
previous_url: /appendices/d/
previous_title: '附录D. 示例'
next_url: /references/
next_title: '参考文献'
---

<!-- 由 scripts/generate_chapters.ps1 从 single-page.md 生成；正文修改请在单页源文件中进行。 -->

# 附录E. 语言的变化 {#Ae}

本章描述了自“修订<sup>5</sup>报告”<sup class="citation"><a href="{{ '/references/' | relative_url }}#ref-14">4</a></sup>出版以来Scheme发生的大部分变化：

* 现在，Scheme源代码使用Unicode字符集。尤其，可被用作标识符的字符集被大大地扩展了。
* 现在，标识符可以以`->`字符开始。
* 现在，标识符和符号字面量是大小写敏感的。
* 标识符和字符，布尔，数字对象和`.`的表示必须被显式地区分。<!-- TODO -->
* 现在，`#`是定界符（delimiter）。
* 字节向量字面量语法已被添加。
* 匹配的中括号可以和小括号等价得使用。
* 数据语法的简写`#'` (即`syntax`), `` #` `` (即`quasisyntax`), `#,` (即`unsyntax`), and `#,@` (即`unsyntax-splicing`)被添加；见[第4.3.5小节]({{ '/chapters/04/' | relative_url }}#s4-3-5)。<!-- TODO: 1. read-syntax 应该是 datum-syntax；2. 括号不对 -->
* `#`不再可以用在数字的表示中替换数字。
* 现在，数字对象的外部表示可以包括一个尾数宽度。
* 非输和无限大的字面量被添加。
* 现在，字符串和字符字面量可以使用各种转移序列。
* 块注释和数据注释被添加。
* 用作报告兼容的`#!r6rs`注释词汇语法被添加。
* 现在，字符指定对应的Unicode标量值。
* 现在，许多的程序和语言的句法形式是`(rnrs base (6))`库的一部分。一些过程和句法形式被转移到其它库中；见表A.1。

{:refdef .center}
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
{: refdef}

{:refdef .caption}
**图A.1：**标识符转移到库中
{: refdef}

* 基本语言有下列新的过程和句法形式：`letrec*`, `let-values`, `let*-values`, `real-valued?`, `rational-valued?`, `integer-valued?`, `exact`, `inexact`, `finite?`, `infinite?`, `nan?`, `div`, `mod`, `div-and-mod`, `div0`, `mod0`, `div0-and-mod0`, `exact-integer-sqrt`, `boolean=?`, `symbol=?`, `string-for-each`, `vector-map`, `vector-for-each`, `error`, `assertion-violation`, `assert`, `call/cc`, `identifier-syntax`。
* 下列的过程被移除：`char-ready?`, `transcript-on`, `transcript-off`, `load`。
* 大小写不敏感的字符串比较（`string-ci=?`, `string-ci<?`, `string-ci>?`, `string-ci<=?`, `string-ci>=?`）操作字符串大小写折叠（case-folded）的版本，而不是其对应的字符比较过程的简单的字典序。
* 库被加到了语言当中。
* 许多的标准库在一个单独的报告<sup class="citation"><a href="{{ '/references/' | relative_url }}#ref-24">1</a></sup>中被描述。
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
* 指称语义（denotational semantics）被一个基于“修订<sup>5</sup>报告”<sup class="citation"><a href="{{ '/references/' | relative_url }}#ref-14">4</a></sup>一个早期语义的操作语义（operational semantics）<sup class="citation"><a href="{{ '/references/' | relative_url }}#ref-18">25</a></sup>取代。
