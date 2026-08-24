---
layout: r6rs
title: '附录A. 形式语义'
title_plain: '附录A. 形式语义 — R6RS简体中文翻译'
permalink: /appendices/a/
r6rs: true
chapter_key: appendix-a
previous_url: /chapters/11/
previous_title: '11. 基本库'
next_url: /appendices/b/
next_title: '附录B. 衍生形式的定义示例'
---

<!-- 由 scripts/generate_chapters.ps1 从 single-page.md 生成；正文修改请在单页源文件中进行。 -->

# 附录 {#APPENDICES}

# 附录A. 形式语义 {#Aa}

本附录为Scheme提供了一个非正式的，形式的，操作语义，其基于一个早期的语义<sup class="citation"><a href="{{ '/references/' | relative_url }}#ref-18">25</a></sup>。它没有覆盖整个语言。明显没有包含的特性是宏系统，I/O，和数值塔。包含特性的精确列表在[第A.2小节]({{ '/appendices/a/' | relative_url }}#Aa-2)给出。

规范的核心是一个单步术语重写的关系，其指出一个（抽象的）机器行为。通常，报告不是完整的规范，已给予实现不同行为的自由，特别是在可以优化的时候。这种不指明在语义中以两种方式展示。

第一个是减少规则，其减少到特定的“**未知：***字符串*”状态（其中字符串提供未知状态的一个描述）。意图是减少到这种状态的规则可以用任意的减少规则取代。怎样代替这些规则的精确规范在[第A.12小节]({{ '/appendices/a/' | relative_url }}#Aa-12)被给出。

另一个是单步关系涉及到一个程序到多个程序，每一个对应于一个抽象机器可以做的合法的转换。相应地，我们使用单步关系`\(\rightarrow^*\)`的传递闭包来定义语义，`\(\cal S\)`，作为一个从程序（`\(\cal P\)`）到观察结果集合（`\(\cal R\)`）的函数。

$$
\begin{array}{l}
\cal S : \cal P \longrightarrow 2^{\cal R} \\
\cal S(\cal P) = \{ \scr O(\cal A) \mid \cal P \rightarrow^* \cal A \}
\end{array}
$$

其中函数`\(\scr O\)`将一个答案（`\(\cal A\)`）从语义转换到一个观察结果。大概的说，`\(\scr O\)`在简单的基本值上是恒等函数，对于更加复杂的值，像过程和点对，则返回特定的标签。

所以，一个实现符合这样的语义如果，对所有的程序`\(\cal P\)`，实现产生`\(\cal S(\cal P)\)`中结果的一个或，如果实现无限循环，那么有一个无限的减少序列以`\(\cal P\)`开始，假设减少关系`\(\rightarrow\)`已经被调整去取代**未知：***状态*。

`\(\cal P\)`, `\(\cal A\)`, `\(\cal R\)`, 和`\(\scr O\)`的精确定义也在[第A.2小节]({{ '/appendices/a/' | relative_url }}#Aa-2)被给出。

为帮助理解语义和它的行为，我们在PLT Redex中实现了它。我们可以在这篇报告的官方网站发现这个实现：<http://www.r6rs.org/>。在本语义图表中展示的所有的减少规则和元方程都是从源代码自动生成的。

## A.1. 背景 {#Aa-1}

我们假设读者对上下文敏感的减少语义有基础的了解。对此系统不了解的读者可能想要查阅Felleisen和Flatt的专题著作<sup class="citation"><a href="{{ '/references/' | relative_url }}#ref-10">26</a></sup>或Wright和Felleisen<sup class="citation"><a href="{{ '/references/' | relative_url }}#ref-29">27</a></sup>的一个全面的介绍，其包括相关的技术背景，或者轻松一点的PLT Redex<sup class="citation"><a href="{{ '/references/' | relative_url }}#ref-19">28</a></sup>的一个介绍。

作为一个简单的指南，我们通过程序术语的关系定义一个语言的操作语义，其中这个关系对应于一个抽象机器的单步。这个关系使用求值上下文定义，也就是<!-- TODO -->它们当中有区别地方的术语，叫做*孔（holes）*，求值的下一步在这里进行。我们说一个术语*e*分解成一个表达式上下文*E*和宁一个术语*e'*，如果*e*和*E*是一样的但孔被*e'*代替。我们写成*E[e']*来指示术语在*E*中用*e'*来代替孔。

比如，我们为表达式上下文（*E*），表达式（*e*），变量（*x*），和值（*v*）定义了一个包含了非终结符的语法。我们可以这样写：

$$
  \begin{array}{l}
    E_1[\texttt{((lambda}~\texttt{(}x_1 \cdots{}\texttt{)}~e_1\texttt{)}~v_1~\cdots\texttt{)}] \rightarrow
    \\
    E_1[\{ x_1 \cdots \mapsto v_1 \cdots \} e_1] ~~~~~ (\#x_1 = \#v_1)
  \end{array}
$$

去定义`\(\beta_v\)`重写规则（作为`\(\rightarrow\)`单步关系的一部分）。我们在重写规则中使用非终结符的名字（可能和下标一起使用）来限制规则的应用，所以只有当一些语法产生的条款出现在条款中对应的位置时，它才起作用。如果相同的非终结符和相同的下标出现多次，那么规则只有当相应的条款在结构上是一样的时候才起作用（没有下标的非终结符不强迫相互匹配。因此，上面规则中，`\(E_1\)`同时出现在左手边和右手边意味着应用表达式的上下文在使用这条规则的时候没有改变。省略号是Kleene星号的一个形式，意味着零个或多个省略号之前<!-- TODO: proceeding应该是preceding。 -->的匹配模式条款的事件可以出现在省略号和它之前模式的位置。我们使用符号`\(\{ x_1 \cdots \mapsto v_1 \cdots \} e_1\)`表示捕获避免的替代；在这种情况下它意味着每一个`\(x_1\)`在`\(e_1\)`中被替代成相应的`\(v_1\)`。最后，除了规则，我们在小括号中写附加条件（side-conditions）；上面规则的附加条件指示`\(x_1\)`的数量必须和`\(v_1\)`的数量相等。我们有时在附加条件中使用等式；当我们这样做时仅仅意味着简单的条目相等，也就是说，这两个条目必须有相同的句法形状。

在规则中指明求值上下文*E*允许我们定义操作它们上下文的关系。作为一个简单的例子，我们可以添加另一条规则，其在程序应用错误数量参数的时候通过丢弃规则右手边求值上下文的方式产生错误：

$$
  \begin{array}{l}
    E[\texttt{((lambda}~\texttt{(}x_1 \cdots\texttt{)}~e\texttt{)}~v_1~\cdots\texttt{)}] \rightarrow
    \\
    \textrm{\textbf{violation:} 错误的参数数量} ~~~~~ (\#x_1 \neq \#v_1)
  \end{array}
$$

以后，我们会以更复杂的方式利用显示的求值上下文。

## A.2. 语法 {#Aa-2}


$$
\begin{array}{lr@{}ll}
\\
\mathcal{P} & ::=~~& \texttt{(}\sy{store}~\texttt{(}\nt{sf}~\cdots\texttt{)}~\nt{es}\texttt{)}~~\mid~~\textbf{未捕获的异常: } \nt{v}~~\mid~~\textbf{未知: } \textit{description}\\
\mathcal{A} & ::=~~& \texttt{(}\sy{store}~\texttt{(}\nt{sf}~\cdots\texttt{)}~\texttt{(}\va{values}~\nt{v}~\cdots\texttt{)}\texttt{)}~~\mid~~\textbf{未捕获的异常: } \nt{v}~~\mid~~\textbf{未知: } \textit{description}\\
\mathcal{R} & ::=~~& \texttt{(}\va{values}~\ensuremath{\mathcal{R}_v}~\cdots\texttt{)}~~\mid~~\sy{exception}~~\mid~~\sy{unknown}\\
\ensuremath{\mathcal{R}_v} & ::=~~& \sy{pair}~~\mid~~\va{null}~~\mid~~'\nt{sym}~~\mid~~\nt{sqv}~~\mid~~\sy{condition}~~\mid~~\sy{procedure}\\
\nt{sf} & ::=~~& \texttt{(}\nt{x}~\nt{v}\texttt{)}~~\mid~~\texttt{(}\nt{x}~\sy{bh}\texttt{)}~~\mid~~\texttt{(}\nt{pp}~\texttt{(}\va{cons}~\nt{v}~\nt{v}\texttt{)}\texttt{)}\\
\nt{es} & ::=~~& '\nt{seq}~~\mid~~'\nt{sqv}~~\mid~~'\texttt{()}~~\mid~~\texttt{(}\sy{begin}~\nt{es}~\nt{es}~\cdots\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{begin0}~\nt{es}~\nt{es}~\cdots\texttt{)}~~\mid~~\texttt{(}\nt{es}~\nt{es}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{if}~\nt{es}~\nt{es}~\nt{es}\texttt{)}~~\mid~~\texttt{(}\sy{set\mbox{\texttt{!}}}~\nt{x}~\nt{es}\texttt{)}~~\mid~~\nt{x}~~\mid~~\nt{nonproc}\\
&\mid~~~~&
\nt{pproc}~~\mid~~\texttt{(}\sy{lambda}~\nt{f}~\nt{es}~\nt{es}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{letrec}~\texttt{(}\texttt{(}\nt{x}~\nt{es}\texttt{)}~\cdots\texttt{)}~\nt{es}~\nt{es}~\cdots\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{letrec\mbox{\texttt{*}}}~\texttt{(}\texttt{(}\nt{x}~\nt{es}\texttt{)}~\cdots\texttt{)}~\nt{es}~\nt{es}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{dw}~\nt{x}~\nt{es}~\nt{es}~\nt{es}\texttt{)}~~\mid~~\texttt{(}\sy{throw}~\nt{x}~\nt{es}\texttt{)}\\
&\mid~~~~&
\va{unspecified}~~\mid~~\texttt{(}\sy{handlers}~\nt{es}~\cdots~\nt{es}\texttt{)}~~\mid~~\texttt{(}\sy{l\mbox{\texttt{!}}}~\nt{x}~\nt{es}\texttt{)}~~\mid~~\texttt{(}\sy{reinit}~\nt{x}\texttt{)}\\
\nt{f} & ::=~~& \texttt{(}\nt{x}~\cdots\texttt{)}~~\mid~~\texttt{(}\nt{x}~\nt{x}~\cdots~\sy{dot}~\nt{x}\texttt{)}~~\mid~~\nt{x}\\
\nt{s} & ::=~~& \nt{seq}~~\mid~~\texttt{()}~~\mid~~\nt{sqv}~~\mid~~\nt{sym}\\
\nt{seq} & ::=~~& \texttt{(}\nt{s}~\nt{s}~\cdots\texttt{)}~~\mid~~\texttt{(}\nt{s}~\nt{s}~\cdots~\sy{dot}~\nt{sqv}\texttt{)}~~\mid~~\texttt{(}\nt{s}~\nt{s}~\cdots~\sy{dot}~\nt{sym}\texttt{)}\\
\nt{sqv} & ::=~~& \nt{n}~~\mid~~\semtrue{}~~\mid~~\semfalse{}\\
\\
\nt{p} & ::=~~& \texttt{(}\sy{store}~\texttt{(}\nt{sf}~\cdots\texttt{)}~\nt{e}\texttt{)}\\
\nt{e} & ::=~~& \texttt{(}\sy{begin}~\nt{e}~\nt{e}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{begin0}~\nt{e}~\nt{e}~\cdots\texttt{)}~~\mid~~\texttt{(}\nt{e}~\nt{e}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{if}~\nt{e}~\nt{e}~\nt{e}\texttt{)}~~\mid~~\texttt{(}\sy{set\mbox{\texttt{!}}}~\nt{x}~\nt{e}\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{handlers}~\nt{e}~\cdots~\nt{e}\texttt{)}~~\mid~~\nt{x}~~\mid~~\nt{nonproc}~~\mid~~\nt{proc}~~\mid~~\texttt{(}\sy{dw}~\nt{x}~\nt{e}~\nt{e}~\nt{e}\texttt{)}~~\mid~~\va{unspecified}\\
&\mid~~~~&
\texttt{(}\sy{letrec}~\texttt{(}\texttt{(}\nt{x}~\nt{e}\texttt{)}~\cdots\texttt{)}~\nt{e}~\nt{e}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{letrec\mbox{\texttt{*}}}~\texttt{(}\texttt{(}\nt{x}~\nt{e}\texttt{)}~\cdots\texttt{)}~\nt{e}~\nt{e}~\cdots\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{l\mbox{\texttt{!}}}~\nt{x}~\nt{es}\texttt{)}~~\mid~~\texttt{(}\sy{reinit}~\nt{x}\texttt{)}\\
\\
\nt{v} & ::=~~& \nt{nonproc}~~\mid~~\nt{proc}\\
\nt{nonproc} & ::=~~& \nt{pp}~~\mid~~\va{null}~~\mid~~'\nt{sym}~~\mid~~\nt{sqv}~~\mid~~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\nt{string}\texttt{)}\\
\nt{proc} & ::=~~& \texttt{(}\sy{lambda}~\nt{f}~\nt{e}~\nt{e}~\cdots\texttt{)}~~\mid~~\nt{pproc}~~\mid~~\texttt{(}\sy{throw}~\nt{x}~\nt{e}\texttt{)}\\
\nt{pproc} & ::=~~& \nt{aproc}~~\mid~~\nt{proc1}~~\mid~~\nt{proc2}~~\mid~~\va{list}~~\mid~~\va{dynamic\mbox{\texttt{-}}wind}~~\mid~~\va{apply}~~\mid~~\va{values}\\
\nt{proc1} & ::=~~& \va{null\mbox{\texttt{?}}}~~\mid~~\va{pair\mbox{\texttt{?}}}~~\mid~~\va{car}~~\mid~~\va{cdr}~~\mid~~\va{call\mbox{\texttt{/}}cc}~~\mid~~\va{procedure\mbox{\texttt{?}}}~~\mid~~\va{condition\mbox{\texttt{?}}}~~\mid~~\nt{raise\mbox{\texttt{*}}}\\
\nt{proc2} & ::=~~& \va{cons}~~\mid~~\sy{consi}~~\mid~~\va{set\mbox{\texttt{-}}car\mbox{\texttt{!}}}~~\mid~~\va{set\mbox{\texttt{-}}cdr\mbox{\texttt{!}}}~~\mid~~\va{eqv\mbox{\texttt{?}}}~~\mid~~\va{call\mbox{\texttt{-}}with\mbox{\texttt{-}}values}~~\mid~~\va{with\mbox{\texttt{-}}exception\mbox{\texttt{-}}handler}\\
\nt{aproc} & ::=~~& \va{\mbox{\texttt{+}}}~~\mid~~\va{\mbox{\texttt{-}}}~~\mid~~\va{\mbox{\texttt{/}}}~~\mid~~\va{\mbox{\texttt{*}}}\\
\nt{raise\mbox{\texttt{*}}} & ::=~~& \va{raise\mbox{\texttt{-}}continuable}~~\mid~~\va{raise}\\
\\
\nt{pp} & ::=~~& \nt{ip}~~\mid~~\nt{mp}\\
\nt{ip} & ::=~~ &  \textrm{[不可变点对指针]} \\
\nt{mp} & ::=~~ &  \textrm{[可变点对指针]} \\
\\
\nt{sym} & ::=~~ &  \textrm{[除了\sy{dot}的变量]} \\
\nt{x} & ::=~~ &  \textrm{[除了\sy{dot}的变量和关键词]} \\
\nt{n} & ::=~~ &  \textrm{[数字]} \\
\end{array}
$$

{:refdef .caption #Fa-2a}
**图A.2a：**程序和观测的语法
{: refdef}

图A.2a展示了本报告语义模型的子集。非终结符被写成*斜体*或一种艺术字体（`\(\cal P\)`<!-- TODO: 少了一个逗号 --> `\(\cal A\)`, `\(\cal R\)`, 和`\(\cal R_v\)`）且字面量被写成`\(\texttt{等宽}\)`字体。

非终结符`\(\cal P\)`表示可能的程序状态。第一个选择是有一个存储和一个表达式的程序。第二个选择是一个未捕获的异常，及第三个被用作指示它建模的模型没有完全指定原语行为的地方（那些情况具体的细节见[第A.12小节]({{ '/appendices/a/' | relative_url }}#Aa-12)）。非终结符`\(\cal A\)`表示程序的最终结果。它和`\(\cal P\)`是一样的除了表达式已经被减少到一些值得序列之外。

非终结符`\(\cal R\)`和`\(\cal R_v\)`表示程序的可观测结果。每个`\(\cal R\)`或者是一个对应于正常终止的程序产生的值的值的序列，或者是一个指示未捕获异常被抛出的标签，或者是`\(\sy{unknown}\)`如果程序到达一个本语义没有指明的情况的话。非终结符`\(\cal R_v\)`指明对于一个特定的值来说可观测的结果是什么：一个点对，空表，一个符号，一个自引用的值（`\(\schtrue\)`, `\(\schfalse\)`和数字），一个条件，或一个过程。

非终结符`\(\nt{sf}\)`产生存储的一个单独元素。存储保持一个程序所有的可变状态。它，连同操作它的规则一起，被更加详细地解释了。

表达式(`\(\mathit{es}\)`)包括被引用的数据，`\(\sy{begin}\)`表达式，`\(\sy{begin0}\)`表达式[[注1]]({{ '/appendices/a/' | relative_url }}#p63-1)，应用表达式，`\(\sy{if}\)`表达式，`\(\sy{set!}\)`表达式，变量，非过程值（*nonproc*），基本过程（*pproc*），lambda表达式，`\(\sy{letrec}\)`和`\(\sy{letrec*}\)`表达式。


{:refdef .note #p63-1}
**注1：**`\(\sy{begin0}\)`不是标准的一部分，但为了`\(\va{dynamic-wind}\)`和`\(\va{letrec}\)`的规则更加易读，我们包含了它。尽管我们直接给它建模，但是它可以根据我们在此定义的来自标准的其它形式被定义：
$$
  \begin{array}{rcl}\tt
    \texttt{(}\sy{begin0}~e_1~e_2~\cdots\texttt{)} &=&
    \begin{array}{l}
      \texttt{(}\va{call\mbox{-}with\mbox{-}values}\\
      ~\texttt{(}\sy{lambda}~\texttt{()}~e_1\texttt{)}\\
      ~\texttt{(}\sy{lambda}~x\\
      ~~~e_2~\cdots\\
      ~~~\texttt{(}\va{apply}~\va{values}~x\texttt{)))}
    \end{array}
  \end{array}
$$
{: refdef}

最后几个表达式形式仅仅是为了中间状态生成的（`\(\sy{dw}\)`为了`\(\sy{dynamic-wind}\)`，`\(\sy{throw}\)`为了继续，`\(\sy{unspecified}\)`为了赋值操作的规则，`\(\sy{handlers}\)`为了异常处理，及`\(\sy{l!}\)`和`\(\sy{reinit}\)`为了`\(\sy{letrec}\)`），且在初始程序中不应该出现。它们的使用在本附录的相关章节被描述。

非终结符`\(\nt{f}\)`描述`lambda`表达式的形式。（`dot`代替（西文）句号来描述接受任意数量参数的过程，这是为了避免和我们PLT Redex模型中的元圆（meta-circular）相混淆。）

非终结符`\(\nt{s} \)`覆盖所有的数据，其可以是非空序列（*seq*），空序列，自引用值（*sqv*），或符号。非空序列或者仅是一个数据的序列，或者以一个点终结，这个点或者跟着一个符号，或者跟着一个自引用值。最后，自引用值是数字和布尔`\(\semtrue{}\)`与`\(\semfalse{}\)`。

非终结符`\(\nt{p} \)`表示没有引用数据的程序。大部分消去规则重写*p*到*p*，而不是`\(\cal P\)`到`\(\cal P\)`，这是因为在平常的求值之前被引用的数据第一次被重写成表构造函数的调用。平行于*es*，*e*表示没有被引用表达式的表达式。



值（*v*）被分成四类：

* 非过程（*nonproc*）包括点对指针（pp），空表（null），符号，自引用值（*sqv*），和条件。条件表示报告的条件值，但这儿只包含一条信息且其它情况无效。
* 用户过程（`(lambda f e e ···)`）包括多参数的lambda表达式和伴随点参数列表的表达式。
* 基本函数（*pproc*）包括
  - 算术过程（*aproc*）：`+`, `-`, `/`, 和`*`，
  - 一个参数的过程（*proc1*）：`null?`, `pair?`, `car`, `cdr`, `call/cc`, `procedure?`, `condition?`, `unspecified?`, `raise`, 和`raise-continuable`,
  - 两个参数的过程（*proc2*）：`cons`, `set-car!`, `set-cdr!`, `eqv?`, 和`call-with-values`,
  - 以及`list`, `dynamic-wind`, `apply`, `values`, 和`with-exception-handler`。
* 最后，继续被表示为`throw`表达式，其内部由捕获继续的上下文组成。

图A.2a中非终结符的下面三个集合表示点对（*pp*），其分为不可变点对（*ip*）和可变点对（*mp*）。图A.2a中非终结符的最终集合，*sym*，*x*和*n*，分别表示符号，变量和数字。我们假设非终结符*ip*，*mp*和*sym*全被认为是不想交的。除此之外，假设变量*x*不包括任何关键词或基础操作，因此任何名字和它们相一致的程序变量必须在语义给予程序意义之前被重命名。

$$
\begin{array}{lr@{}ll}
\\
\nt{P} & ::=~~& \texttt{(}\sy{store}~\texttt{(}\nt{sf}~\cdots\texttt{)}~\Estar\texttt{)}\\
\\
\nt{E} & ::=~~& \nt{F}[\texttt{(}\sy{handlers}~\nt{proc}~\cdots~\Estar\texttt{)}]~~\mid~~\nt{F}[\texttt{(}\sy{dw}~\nt{x}~\nt{e}~\Estar~\nt{e}\texttt{)}]~~\mid~~\nt{F}\\
\Estar & ::=~~& \holes~~\mid~~\nt{E}\\
\Eo & ::=~~& \holeone~~\mid~~\nt{E}\\
\\
\nt{F} & ::=~~& \hole~~\mid~~\texttt{(}\nt{v}~\cdots~\Fo~\nt{v}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{if}~\Fo~\nt{e}~\nt{e}\texttt{)}~~\mid~~\texttt{(}\sy{set\mbox{\texttt{!}}}~\nt{x}~\Fo\texttt{)}~~\mid~~\texttt{(}\sy{begin}~\Fstar~\nt{e}~\nt{e}~\cdots\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{begin0}~\Fstar~\nt{e}~\nt{e}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{begin0}~\texttt{(}\va{values}~\nt{v}~\cdots\texttt{)}~\Fstar~\nt{e}~\cdots\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{begin0}~\va{unspecified}~\Fstar~\nt{e}~\cdots\texttt{)}~~\mid~~\texttt{(}\va{call\mbox{\texttt{-}}with\mbox{\texttt{-}}values}~\texttt{(}\sy{lambda}~\texttt{()}~\Fstar~\nt{e}~\cdots\texttt{)}~\nt{v}\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{l\mbox{\texttt{!}}}~\nt{x}~\Fo\texttt{)}\\
\Fstar & ::=~~& \holes~~\mid~~\nt{F}\\
\Fo & ::=~~& \holeone~~\mid~~\nt{F}\\
\nt{U} & ::=~~& \texttt{(}\nt{v}~\cdots~\hole~\nt{v}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{if}~\hole~\nt{e}~\nt{e}\texttt{)}~~\mid~~\texttt{(}\sy{set\mbox{\texttt{!}}}~\nt{x}~\hole\texttt{)}~~\mid~~\texttt{(}\va{call\mbox{\texttt{-}}with\mbox{\texttt{-}}values}~\texttt{(}\sy{lambda}~\texttt{()}~\hole\texttt{)}~\nt{v}\texttt{)}\\
\\
\nt{PG} & ::=~~& \texttt{(}\sy{store}~\texttt{(}\nt{sf}~\cdots\texttt{)}~\nt{G}\texttt{)}\\
\nt{G} & ::=~~& \nt{F}[\texttt{(}\sy{dw}~\nt{x}~\nt{e}~\nt{G}~\nt{e}\texttt{)}]~~\mid~~\nt{F}\\
\nt{H} & ::=~~& \nt{F}[\texttt{(}\sy{handlers}~\nt{proc}~\cdots~\nt{H}\texttt{)}]~~\mid~~\nt{F}\\
\\
\nt{S} & ::=~~& \hole~~\mid~~\texttt{(}\sy{begin}~\nt{e}~\nt{e}~\cdots~\nt{S}~\nt{es}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{begin}~\nt{S}~\nt{es}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{begin0}~\nt{e}~\nt{e}~\cdots~\nt{S}~\nt{es}~\cdots\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{begin0}~\nt{S}~\nt{es}~\cdots\texttt{)}~~\mid~~\texttt{(}\nt{e}~\cdots~\nt{S}~\nt{es}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{if}~\nt{S}~\nt{es}~\nt{es}\texttt{)}~~\mid~~\texttt{(}\sy{if}~\nt{e}~\nt{S}~\nt{es}\texttt{)}~~\mid~~\texttt{(}\sy{if}~\nt{e}~\nt{e}~\nt{S}\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{set\mbox{\texttt{!}}}~\nt{x}~\nt{S}\texttt{)}~~\mid~~\texttt{(}\sy{handlers}~\nt{s}~\cdots~\nt{S}~\nt{es}~\cdots~\nt{es}\texttt{)}~~\mid~~\texttt{(}\sy{handlers}~\nt{s}~\cdots~\nt{S}\texttt{)}~~\mid~~\texttt{(}\sy{throw}~\nt{x}~\nt{e}\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{lambda}~\nt{f}~\nt{S}~\nt{es}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{lambda}~\nt{f}~\nt{e}~\nt{e}~\cdots~\nt{S}~\nt{es}~\cdots\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{letrec}~\texttt{(}\texttt{(}\nt{x}~\nt{e}\texttt{)}~\cdots~\texttt{(}\nt{x}~\nt{S}\texttt{)}~\texttt{(}\nt{x}~\nt{es}\texttt{)}~\cdots\texttt{)}~\nt{es}~\nt{es}~\cdots\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{letrec}~\texttt{(}\texttt{(}\nt{x}~\nt{e}\texttt{)}~\cdots\texttt{)}~\nt{S}~\nt{es}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{letrec}~\texttt{(}\texttt{(}\nt{x}~\nt{e}\texttt{)}~\cdots\texttt{)}~\nt{e}~\nt{e}~\cdots~\nt{S}~\nt{es}~\cdots\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{letrec\mbox{\texttt{*}}}~\texttt{(}\texttt{(}\nt{x}~\nt{e}\texttt{)}~\cdots~\texttt{(}\nt{x}~\nt{S}\texttt{)}~\texttt{(}\nt{x}~\nt{es}\texttt{)}~\cdots\texttt{)}~\nt{es}~\nt{es}~\cdots\texttt{)}\\
&\mid~~~~&
\texttt{(}\sy{letrec\mbox{\texttt{*}}}~\texttt{(}\texttt{(}\nt{x}~\nt{e}\texttt{)}~\cdots\texttt{)}~\nt{S}~\nt{es}~\cdots\texttt{)}~~\mid~~\texttt{(}\sy{letrec\mbox{\texttt{*}}}~\texttt{(}\texttt{(}\nt{x}~\nt{e}\texttt{)}~\cdots\texttt{)}~\nt{e}~\nt{e}~\cdots~\nt{S}~\nt{es}~\cdots\texttt{)}\\
\end{array}
$$

{:refdef .caption #Fa-2b}
**图A.2b：**求值上下文的语法
{: refdef}

图A.2b展示求值上下文的非终结符集合。非终结符*P*控制在不包含任何引用数据的程序中求值在哪儿发生。*E*和*F*求值上下文用于表达式。它们以这种方式被作为考虑因素以至于*PG*，*G*，和*H*求值上下文可以重复使用*F*，且对支持异常和`dynamic-wind`的上下文具有细粒度的控制权。星号变量和圆圈变量，`\(\Estar{}\)`, `\(\Eo{}\)`, `\(\Fstar{}\)`, 和`\(\Fo{}\)`指示在哪儿单个值被提升为多个值，及在哪儿多个值被降级为单个值。*U*上下文被用作管理报告中`set!`, `set-car!`, 和`set-cdr!`未指定的结果（具体细节见[第A.12小节]({{ '/appendices/a/' | relative_url }}#Aa-12)）。最后，*S*上下文是被引用表达式可以被简化的地方。求值上下文的精确使用伴随着相关的规则被解释。

<!-- 只有网页版有
尽管没有被写进语法图中，但是绑定在存储上，以及在`lambda`, `letrec`, 和`letrec*`中的变量序列必须不能包含任意的副本。
-->

为了将语义的答案（`\(\calA\)`）转换成可观察的结果，我们使用这两个方程：

$$
\begin{array}{l@{}l}
\mathscr{O}& : \mathcal{A} \rightarrow \mathcal{R}\\
\mathscr{O} \llbracket & \texttt{(}\sy{store}~\texttt{(}\nt{sf}~\cdots\texttt{)}~\texttt{(}\va{values}~v_1~\cdots\texttt{)}\texttt{)} \rrbracket = \\
& \texttt{(}\va{values}~\mathscr{O}_{v}\llbracket{}v_1\rrbracket~\cdots\texttt{)} \extraspterm
\mathscr{O} \llbracket & \textbf{未捕获异常: }\nt{v} \rrbracket = \\
& \sy{exception} \extraspterm
\mathscr{O} \llbracket & \textbf{未知: } \textit{description} \rrbracket = \\
& \sy{unknown} \extraspterm
\end{array}
$$

$$
\begin{array}{lcl}
\mathscr{O}_{v} : \nt{v} \rightarrow \ensuremath{\mathcal{R}_v}\\
\mathscr{O}_{v} \llbracket \nt{pp}_{1} \rrbracket & = &
\sy{pair} \\
\mathscr{O}_{v} \llbracket \va{null} \rrbracket & = &
\va{null} \\
\mathscr{O}_{v} \llbracket \sy{'}sym_1 \rrbracket & = &
\sy{'}sym_1 \\
\mathscr{O}_{v} \llbracket \nt{sqv}_{1} \rrbracket & = &
\nt{sqv}_{1} \\
\mathscr{O}_{v} \llbracket \texttt{(}\sy{make\mbox{\texttt{-}}cond}~\nt{string}\texttt{)} \rrbracket & = &
\sy{condition} \\
\mathscr{O}_{v} \llbracket \nt{proc} \rrbracket & = &
\sy{procedure} \\
\end{array}
$$

它们排除了存储，且以简单的标签代替复杂的值，这些标签仅仅指示产生的值得种类或者，如果没有值产生的话，命令产生一个未捕获的异常，或者程序到达一个本语义没有指明的状态。

## A.3. 引用 {#Aa-3}

$$
\begin{array}{lr}
\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{S}_{1}['\nt{sqv}_{1}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{S}_{1}[\nt{sqv}_{1}]\texttt{)}}
  {\rulename{6sqv}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{S}_{1}['\texttt{()}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{S}_{1}[\va{null}]\texttt{)}}
  {\rulename{6eseq}}
  {\rightarrow}

\twolinescruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{S}_{1}['\nt{seq}_{1}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\texttt{(}\texttt{(}\sy{lambda}~\texttt{(}\nt{qp}\texttt{)}~\nt{S}_{1}[\nt{qp}]\texttt{)}~\mathscr{Q}_{i}\llbracket{}\nt{seq}_{1}\rrbracket\texttt{)}\texttt{)}}
  {\rulename{6qcons}}
  {(\nt{qp} \textrm{ fresh})}
  {\rightarrow}

\twolinescruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{S}_{1}['\nt{seq}_{1}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\texttt{(}\texttt{(}\sy{lambda}~\texttt{(}\nt{qp}\texttt{)}~\nt{S}_{1}[\nt{qp}]\texttt{)}~\mathscr{Q}_{m}\llbracket{}\nt{seq}_{1}\rrbracket\texttt{)}\texttt{)}}
  {\rulename{6qconsi}}
  {(\nt{qp} \textrm{ fresh})}
  {\rightarrow}

\end{array}
$$

$$
\begin{array}{lcl}
\mathscr{Q}_{i} : \nt{seq} \rightarrow \nt{e}\\\mathscr{Q}_{i} \llbracket \texttt{()} \rrbracket & = &
\va{null} \\
\mathscr{Q}_{i} \llbracket \texttt{(}\nt{s}_{1}~\nt{s}_{2}~\cdots\texttt{)} \rrbracket & = &
\texttt{(}\va{cons}~\mathscr{Q}_{i}\llbracket{}\nt{s}_{1}\rrbracket~\mathscr{Q}_{i}\llbracket{}\texttt{(}\nt{s}_{2}~\cdots\texttt{)}\rrbracket\texttt{)} \\
\mathscr{Q}_{i} \llbracket \texttt{(}\nt{s}_{1}~\sy{dot}~\nt{sqv}_{1}\texttt{)} \rrbracket & = &
\texttt{(}\va{cons}~\mathscr{Q}_{i}\llbracket{}\nt{s}_{1}\rrbracket~\nt{sqv}_{1}\texttt{)} \\
\mathscr{Q}_{i} \llbracket \texttt{(}\nt{s}_{1}~\nt{s}_{2}~\nt{s}_{3}~\cdots~\sy{dot}~\nt{sqv}_{1}\texttt{)} \rrbracket & = &
\texttt{(}\va{cons}~\mathscr{Q}_{i}\llbracket{}\nt{s}_{1}\rrbracket~\mathscr{Q}_{i}\llbracket{}\texttt{(}\nt{s}_{2}~\nt{s}_{3}~\cdots~\sy{dot}~\nt{sqv}_{1}\texttt{)}\rrbracket\texttt{)} \\
\mathscr{Q}_{i} \llbracket \texttt{(}\nt{s}_{1}~\sy{dot}~\nt{sym}_{1}\texttt{)} \rrbracket & = &
\texttt{(}\va{cons}~\mathscr{Q}_{i}\llbracket{}\nt{s}_{1}\rrbracket~'\nt{sym}_{1}\texttt{)} \\
\mathscr{Q}_{i} \llbracket \texttt{(}\nt{s}_{1}~\nt{s}_{2}~\nt{s}_{3}~\cdots~\sy{dot}~\nt{sym}_{1}\texttt{)} \rrbracket & = &
\texttt{(}\va{cons}~\mathscr{Q}_{i}\llbracket{}\nt{s}_{1}\rrbracket~\mathscr{Q}_{i}\llbracket{}\texttt{(}\nt{s}_{2}~\nt{s}_{3}~\cdots~\sy{dot}~\nt{sym}_{1}\texttt{)}\rrbracket\texttt{)} \\
\mathscr{Q}_{i} \llbracket \nt{sym}_{1} \rrbracket & = &
\sy{'}sym_1 \\
\mathscr{Q}_{i} \llbracket \nt{sqv}_{1} \rrbracket & = &
\nt{sqv}_{1} \\
\\\mathscr{Q}_{m} : \nt{seq} \rightarrow \nt{e}\\\mathscr{Q}_{m} \llbracket \texttt{()} \rrbracket & = &
\va{null} \\
\mathscr{Q}_{m} \llbracket \texttt{(}\nt{s}_{1}~\nt{s}_{2}~\cdots\texttt{)} \rrbracket & = &
\texttt{(}\sy{consi}~\mathscr{Q}_{m}\llbracket{}\nt{s}_{1}\rrbracket~\mathscr{Q}_{m}\llbracket{}\texttt{(}\nt{s}_{2}~\cdots\texttt{)}\rrbracket\texttt{)} \\
\mathscr{Q}_{m} \llbracket \texttt{(}\nt{s}_{1}~\sy{dot}~\nt{sqv}_{1}\texttt{)} \rrbracket & = &
\texttt{(}\sy{consi}~\mathscr{Q}_{m}\llbracket{}\nt{s}_{1}\rrbracket~\nt{sqv}_{1}\texttt{)} \\
\mathscr{Q}_{m} \llbracket \texttt{(}\nt{s}_{1}~\nt{s}_{2}~\nt{s}_{3}~\cdots~\sy{dot}~\nt{sqv}_{1}\texttt{)} \rrbracket & = &
\texttt{(}\sy{consi}~\mathscr{Q}_{m}\llbracket{}\nt{s}_{1}\rrbracket~\mathscr{Q}_{m}\llbracket{}\texttt{(}\nt{s}_{2}~\nt{s}_{3}~\cdots~\sy{dot}~\nt{sqv}_{1}\texttt{)}\rrbracket\texttt{)} \\
\mathscr{Q}_{m} \llbracket \texttt{(}\nt{s}_{1}~\sy{dot}~\nt{sym}_{1}\texttt{)} \rrbracket & = &
\texttt{(}\sy{consi}~\mathscr{Q}_{m}\llbracket{}\nt{s}_{1}\rrbracket~'\nt{sym}_{1}\texttt{)} \\
\mathscr{Q}_{m} \llbracket \texttt{(}\nt{s}_{1}~\nt{s}_{2}~\nt{s}_{3}~\cdots~\sy{dot}~\nt{sym}_{1}\texttt{)} \rrbracket & = &
\texttt{(}\sy{consi}~\mathscr{Q}_{m}\llbracket{}\nt{s}_{1}\rrbracket~\mathscr{Q}_{m}\llbracket{}\texttt{(}\nt{s}_{2}~\nt{s}_{3}~\cdots~\sy{dot}~\nt{sym}_{1}\texttt{)}\rrbracket\texttt{)} \\
\mathscr{Q}_{m} \llbracket \nt{sym}_{1} \rrbracket & = &
\sy{'}sym_1 \\
\mathscr{Q}_{m} \llbracket \nt{sqv}_{1} \rrbracket & = &
\nt{sqv}_{1} \\
\end{array}
$$

{:refdef .caption #Fa-3}
**图A.3：**引用
{: refdef}


第一个应用到所有程序的消去规则是[图A.3]({{ '/appendices/a/' | relative_url }}#Fa-3)中的规则。前两个规则为被引用的没有引入任何点对的表达式消去引用。最后两个规则将被引用的数据提到表达式的顶部，所以它们只被求值一次，且通过源方程`\(\mathscr{Q}_i\)`和`\(\mathscr{Q}_m\)`将数据转换成对`cons`或者`consi`的调用。

注意，规则`\(\rulename{6qcons}\)`和`\(\rulename{6qconsi}\)`的左边是一样的，这意味着对某一项，一条规则适用，另一条也适用。因此，一个被引用的表达式可以被提出到一系列的`consi`表达式中，其创造不可变点对（见[第A.7小节]({{ '/appendices/a/' | relative_url }}#Aa-7)中关于其怎样发生的规则）。

这些规则在任何其它规则之前被应用，这是由它们，及所有的其它规则，应用的上下文决定的。特别地，这些规则在*S*上下文中应用。图A.2b展示了*S*上下文允许这种消去应用到一个*e*的任意的子表达式中，以及左边没有被引用表达式在其中的所有的子表达式，尽管右边的表达式可以有被引用的表达式。相应地，在程序中，这条规则在每个被引用的表达式上应用一次，然后移到程序的开头。剩余的规则在不包含任何被引用的表达式的上下文中应用，其确保在那些规则引用之前这些规则将所有被引用的数据转换成表。

尽管标识符*qp*没有下标，但是PLT Redex的“fresh（新鲜）”声明的语义特别注意确保规则右边的*qp*确实和附加条件中的是一样的。

## A.4. 多个值 {#Aa-4}

$$
\begin{array}{lr}
\twolineruleA
  {\nt{P}_{1}[v_1]_{\star}}
  {\nt{P}_{1}[\texttt{(}\va{values}~v_1\texttt{)}]}
  {\rulename{6promote}}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{values}~v_1\texttt{)}]_{\circ}}
  {\nt{P}_{1}[v_1]}
  {\rulename{6demote}}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{call\mbox{\texttt{-}}with\mbox{\texttt{-}}values}~\texttt{(}\sy{lambda}~\texttt{()}~\texttt{(}\va{values}~v_2~\cdots\texttt{)}\texttt{)}~v_1\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}v_1~v_2~\cdots\texttt{)}]}
  {\rulename{6cwvd}}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{call\mbox{\texttt{-}}with\mbox{\texttt{-}}values}~v_1~v_2\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{call\mbox{\texttt{-}}with\mbox{\texttt{-}}values}~\texttt{(}\sy{lambda}~\texttt{()}~\texttt{(}v_1\texttt{)}\texttt{)}~v_2\texttt{)}]}
  {\rulename{6cwvw}}
  {(v_1 \neq \texttt{(lambda}~\texttt{()}~\nt{e}\texttt{)})}
  {\rightarrow}

\end{array}
$$

{:refdef .caption #Fa-4}
**图A.4：**多个值和`call-with-values`
{: refdef}

多个值的基本策略是添加一个将`\((\va{values}~v)\)`降级为*v*的规则和另一个将*v*提升为`\((\va{values}~v)\)`的规则。如果我们允许这些规则应用在一个任意的求值上下文中，可是那么，我们可能会在降级和提升中得到无尽替代的无穷的消去序列。所以，语义只允许在期待单个值得上下文中降级，只允许在期待多个值的上下文中提升。我们通过Felleisen-Hieb框架的一个小的扩展获得这个行为（R<sup>5</sup>RS<sup class="citation"><a href="{{ '/references/' | relative_url }}#ref-17">29</a></sup>的操作模型也同样提供）。我们扩展符号使得孔有名字（以下标写成），以及上下文匹配语法可以要求一个特定名字的孔（同样以下标写成，比如`\(E[e]_{\star}\)`）。这个扩展允许我们给孔不同的名字，其期待多个值，以及那些期待单个值，且因此组织上下文的语法。

为了开发这个扩展，[图A.2b]({{ '/appendices/a/' | relative_url }}#Fa-2b)中我们在求值上下文中使用三种形式的孔。普通的孔`\(\hole{}\)`出现在通常种类求值可以出现的地方。孔`\(\holes{}\)`出现在允许多个值和`\(\holeone{}\)`出现在期待单个值得上下文的上下文中。因此，规则`\(\rulename{6promote}\)`只应用`\(\holes{}\)`上下文，`\(\rulename{6demote}\)`只应用在`\(\holeone{}\)`上下文中。

为了知道求值上下文怎样被组织以确保提升和降级出现在正确的地方，请考虑`\(\nt{F}\)`, `\(\Fstar{}\)`和`\(\Fo{}\)`求值上下文。`\(\Fstar{}\)`和`\(\Fo{}\)`求值上下文和`\(\nt{F}\)`几乎是一样的，除了它们分别允许提升到多个值和降级到单个值之外。所以，`\(\nt{F}\)`求值上下文，相比于就其自己被定义，利用`\(\Fstar{}\)`和`\(\Fo{}\)`去指示提升和降级可以出现的地方。比如，`\(\nt{F}\)`可以是`\(\texttt{(}\sy{if}~\Fo{}~e~e\texttt{)}\)`意味着从`\(\texttt{(}\va{values}~v\texttt{)}\)`到*v*的降级可以出现在`if`表达式的测试中。同样地`\(\nt{F}\)`可以是`\(\texttt{(}\sy{begin}~\Fstar{}~e~e~\cdots\texttt{)}\)`意味着在`begin`的第一个子表达式中*v*可以被提升为`\(\texttt{(}\va{values}~v\texttt{)}\)`。

通常，提升和降级规则简化了其它规则的定义。比如，`if`规则不需要考虑在第一个子表达式中的多个值。同样地，`begin`规则不需要考虑单个值作为其第一个子表达式的情况。

[图A.4]({{ '/appendices/a/' | relative_url }}#Fa-4)中的其它两个规则处理`call-with-values`。（在非终结符*F*中）`call-with-values`的求值上下文允许在一个已被作为第一个参数传递给`call-with-values`的过程的内部求值，只有第二个参数被消去成一个值。一旦过程里面的求值完成，它会产生多个值（因为它属于一个`\(\Fstar{}\)`位置），且整个`call-with-values`表达式消去成其第二个参数通过规则`\(\rulename{6cwvd}\)`对那些值的一个应用。最终，在传递给`call-with-values`的第一个参数是一个值，但不是`(lambda () e)`，的情况下，规则`\(\rulename{6cwvw}\)`将它封装到一个槽（thunk）中以触发求值。

## A.5. 异常 {#Aa-5}

$$

\begin{array}{lr}
\twolineruleA
  {\nt{PG}[\texttt{(}\nt{raise\mbox{\texttt{*}}}~v_1\texttt{)}]}
  {\textbf{未捕获异常: }v_1}
  {\rulename{6xunee}}
  {\rightarrow}

\twolineruleA
  {\nt{P}[\texttt{(}\sy{handlers}~\nt{G}[\texttt{(}\nt{raise\mbox{\texttt{*}}}~v_1\texttt{)}]\texttt{)}]}
  {\textbf{未捕获异常: }v_1}
  {\rulename{6xuneh}}
  {\rightarrow}

\twolineruleA
  {\nt{PG}_{1}[\texttt{(}\va{with\mbox{\texttt{-}}exception\mbox{\texttt{-}}handler}~\nt{proc}_{1}~\nt{proc}_{2}\texttt{)}]}
  {\nt{PG}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\texttt{(}\nt{proc}_{2}\texttt{)}\texttt{)}]}
  {\rulename{6xwh1}}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\cdots~\nt{G}_{1}[\texttt{(}\va{with\mbox{\texttt{-}}exception\mbox{\texttt{-}}handler}~\nt{proc}_{2}~\nt{proc}_{3}\texttt{)}]\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\cdots~\nt{G}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\cdots~\nt{proc}_{2}~\texttt{(}\nt{proc}_{3}\texttt{)}\texttt{)}]\texttt{)}]}
  {\rulename{6xwhn}}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\cdots~\nt{G}_{1}[\texttt{(}\va{with\mbox{\texttt{-}}exception\mbox{\texttt{-}}handler}~v_1~v_2\texttt{)}]\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\cdots~\nt{G}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``with\!-\!exception\!\!-\!\!handler ~ expects ~ procs''}\texttt{)}\texttt{)}]\texttt{)}]}
  {\rulename{6xwhne}}
  {& \!\!\!\!(v_1 \not\in \nt{proc}\textrm{或}v_2 \not\in \nt{proc})}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\cdots~\nt{proc}_{2}~\nt{G}_{1}[\texttt{(}\va{raise\mbox{\texttt{-}}continuable}~v_1\texttt{)}]\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\cdots~\nt{proc}_{2}~\nt{G}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\cdots~\texttt{(}\nt{proc}_{2}~v_1\texttt{)}\texttt{)}]\texttt{)}]}
  {\rulename{6xrc}}
  {\rightarrow}

\threelinescruleA
  {\nt{P}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\cdots~\nt{proc}_{2}~\nt{G}_{1}[\texttt{(}\va{raise}~v_1\texttt{)}]\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\cdots~\nt{proc}_{2}}
  {\hphantom{\nt{P}_{1}[\texttt{(}}\nt{G}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\cdots~\texttt{(}\sy{begin}~\texttt{(}\nt{proc}_{2}~v_1\texttt{)}~\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``handler ~ returned''}\texttt{)}\texttt{)}\texttt{)}\texttt{)}]\texttt{)}]}
  {\rulename{6xr}}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{condition\mbox{\texttt{?}}}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\nt{string}\texttt{)}\texttt{)}]}
  {\nt{P}_{1}[\semtrue{}]}
  {\rulename{6ct}}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{condition\mbox{\texttt{?}}}~v_1\texttt{)}]}
  {\nt{P}_{1}[\semfalse{}]}
  {\rulename{6cf}}
  {(v_1 \neq (\sy{make\mbox{\texttt{-}}cond}~\nt{string}))}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\sy{handlers}~\nt{proc}_{1}~\cdots~\texttt{(}\va{values}~v_1~\cdots\texttt{)}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{values}~v_1~\cdots\texttt{)}]}
  {\rulename{6xdone}}
  {\rightarrow}

\twolinescruleA
  {\nt{PG}_{1}[\texttt{(}\va{with\mbox{\texttt{-}}exception\mbox{\texttt{-}}handler}~v_1~v_2\texttt{)}]}
  {\nt{PG}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``with\!\!-\!\!exception\!-\!handler ~ expects ~ procs''}\texttt{)}\texttt{)}]}
  {\rulename{6weherr}}
  {(v_1 \not\in \nt{proc}\textrm{或}v_2 \not\in \nt{proc})}
  {\rightarrow}

\end{array}
$$

{:refdef .caption #Fa-5}
**图A.5：** 异常
{: refdef}

异常系统的苦力是

$$
\texttt{(}\sy{handlers}~\nt{proc}~\cdots{}~\nt{e}\texttt{)}
$$

表达式以及*G*和*PG*求值上下文（在[图A.2b]({{ '/appendices/a/' | relative_url }}#Fa-2b)中展示）。`handlers`表达式在某个上下文（*e*）中记录活动的异常处理程序（*proc* ...)。此意图是只有最内部靠近的`handlers`表达式和被抛出的异常是相关的，且*G*和*PG*求值上下文帮助达到这个目标。它们和对应的*E*和*P*是一样的，除了`handlers`表达式不能出现在孔的路径上之外，且异常系统规则利用那个上下文去发现最内部靠近的处理程序。

为了查看上下文怎样和`handler`<!-- TODO: 应该是handlers -->表达式一起工作，考虑[图A.5]({{ '/appendices/a/' | relative_url }}#Fa-5)中`\(\rulename{6xunee}\)`规则的左侧。它在*PG*求值上下文中匹配有`raise`或`raise-continuable`（非终结符`\(\nt{raise*}\)`匹配这两个抛出异常的过程）调用的表达式。因为*PG*上下文不包含任何的`handlers`表达式，所以这个异常不能被捕获，因此这个表达式消去到一个被指示为未捕获异常的最终状态。规则`\(\rulename{6xuneh}\)`同样产生一个为捕获的异常，但是它包含`handlers`表达式耗尽所有可用的处理程序的情况。这条规则在任意的求值上下文中应用到有（不包含异常处理程序的）`handlers`表达式的表达式上，在这个求值上下文中一个抛出异常的程序的调用在`handlers`表达式中被嵌套。*G*求值上下文的使用确保在这个和抛出之间没有其它的`handler`<!-- TODO -->表达式。

下面的两条规则覆盖过程`with-exception-handler`<!-- TODO -->的调用。当没有`handler`<!-- TODO -->表达式的时候，规则`\(\rulename{6xwh1}\)`。它构造了一个新的，且将`\(\nt{v}_2\)`作为`handler`<!-- TODO -->内部的一个槽应用。如果已经有了一个处理函数表达式，那么`\(\rulename{6xwhn}\)`应用。它收集当前的处理函数，并添加新的到新的`handlers`表达式中，且和前一条表达式一样，调用`with-exception-handlers`的第二个参数。

下面两个规则覆盖在`handlers`表达式上下文中抛出的异常。如果可继续的异常被抛出，那么`\(\rulename{6xrc}\)`应用。它从最内部靠近的表达式中使用最近安装的处理程序，且将其应用到`raise-continuable`的参数中，但是是在一个异常处理程序不包含最后一个处理程序的上下文中。规则`\(\rulename{6xr}\)`行为类似，除了在处理程序返回的时候它抛出一个新的异常之外。特殊形式`make-cond`创建这个新的异常。

特殊形式`make-cond`是报告条件的一个替身。它不计算它的参数（注意[图A.2b]({{ '/appendices/a/' | relative_url }}#Fa-2b)语法*E*中是没有它的）。那个参数仅仅是描述抛出异常的上下文的字符串字面量。条件上唯一的操作是`condition?`，`\(\rulename{6ct}\)`和`\(\rulename{6cf}\)`这两个规则给出了其语义。

最后，规则`\(\rulename{6xdone}\)`在它的内部被完全计算的时候终止`handlers`表达式，同时规则`\(\rulename{6weherr}\)`当`with-exception-handler`<!-- TODO -->被提供错误的参数的时候抛出一个异常。

## A.6. 算术和基本形式 {#Aa-6}

$$
\begin{array}{l@{}l@{}lr}
\onelineruleA
  {\nt{P}_{1}[\texttt{(}\va{\mbox{\texttt{+}}}\texttt{)}]}
  {\nt{P}_{1}[0]}
  {\rulename{6+0}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\va{\mbox{\texttt{+}}}~\nt{n}_{1}~\nt{n}_{2}~\cdots\texttt{)}]}
  {\nt{P}_{1}[ \gopen~\Sigma \{\nt{n}_{1}, \nt{n}_{2}\cdots \}~\gclose ]}
  {\rulename{6+}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\va{\mbox{\texttt{-}}}~\nt{n}_{1}\texttt{)}]}
  {\nt{P}_{1}[ \gopen~- \nt{n}_{1}~\gclose ]}
  {\rulename{6u-}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\va{\mbox{\texttt{-}}}~\nt{n}_{1}~\nt{n}_{2}~\nt{n}_{3}~\cdots\texttt{)}]}
  {\nt{P}_{1}[ \gopen~n_1 - \Sigma \{\nt{n}_{2}, \nt{n}_{3}\cdots \}~\gclose ]}
  {\rulename{6-}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\va{\mbox{\texttt{-}}}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``arity ~ mismatch''}\texttt{)}\texttt{)}]}
  {\rulename{6-arity}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\va{\mbox{\texttt{*}}}\texttt{)}]}
  {\nt{P}_{1}[1]}
  {\rulename{6*1}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\va{\mbox{\texttt{*}}}~\nt{n}_{1}~\nt{n}_{2}~\cdots\texttt{)}]}
  {\nt{P}_{1}[ \gopen~\Pi \{\nt{n}_{1}, \nt{n}_{2}\cdots \}~\gclose ]}
  {\rulename{6*}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\va{\mbox{\texttt{/}}}~\nt{n}_{1}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{\mbox{\texttt{/}}}~1~\nt{n}_{1}\texttt{)}]}
  {\rulename{6u/}}
  {\rightarrow}

\onelinescruleA
  {\nt{P}_{1}[\texttt{(}\va{\mbox{\texttt{/}}}~\nt{n}_{1}~\nt{n}_{2}~\nt{n}_{3}~\cdots\texttt{)}]}
  {\nt{P}_{1}[ \gopen~n_1 / \Pi \{\nt{n}_{2}, \nt{n}_{3}\cdots \}~\gclose ]}
  {\rulename{6/}}
  {(0\not\in \{ \nt{n}_{2}, \nt{n}_{3}, \ldots \})}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\va{\mbox{\texttt{/}}}~\nt{n}~\nt{n}~\cdots~0~\nt{n}~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``divison ~ by ~ zero''}\texttt{)}\texttt{)}]}
  {\rulename{6/0}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\va{\mbox{\texttt{/}}}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``arity ~ mismatch''}\texttt{)}\texttt{)}]}
  {\rulename{6/arity}}
  {\rightarrow}

\onelinescruleA
  {\nt{P}_{1}[\texttt{(}\nt{aproc}~v_1~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``arith\!\!-\!\!op ~ applied ~ to ~ non\!\!-\!\!number''}\texttt{)}\texttt{)}]}
  {\rulename{6ae}}
  {(\exists v \in v_1 \cdots  \textrm{ ~ s.t.~  } v \textrm{不是一个数字})}
  {\rightarrow}

\end{array}
$$

$$
\begin{array}{l@{}l@{}lr}
\onelinescruleA
  {\nt{P}_{1}[\texttt{(}\sy{if}~v_1~\nt{e}_{1}~\nt{e}_{2}\texttt{)}]}
  {\nt{P}_{1}[\nt{e}_{1}]}
  {\rulename{6if3t}}
  {(v_1 \neq \semfalse{})}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\sy{if}~\semfalse{}~\nt{e}_{1}~\nt{e}_{2}\texttt{)}]}
  {\nt{P}_{1}[\nt{e}_{2}]}
  {\rulename{6if3f}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\sy{begin}~\texttt{(}\va{values}~\nt{v}~\cdots\texttt{)}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\sy{begin}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}]}
  {\rulename{6beginc}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\sy{begin}~\nt{e}_{1}\texttt{)}]}
  {\nt{P}_{1}[\nt{e}_{1}]}
  {\rulename{6begind}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\sy{begin0}~\texttt{(}\va{values}~v_1~\cdots\texttt{)}~\texttt{(}\va{values}~v_2~\cdots\texttt{)}~\nt{e}_{2}~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\sy{begin0}~\texttt{(}\va{values}~v_1~\cdots\texttt{)}~\nt{e}_{2}~\cdots\texttt{)}]}
  {\rulename{6begin0n}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\sy{begin0}~\nt{e}_{1}\texttt{)}]}
  {\nt{P}_{1}[\nt{e}_{1}]}
  {\rulename{6begin01}}
  {\rightarrow}

\end{array}
$$

{:refdef .caption #Fa-6}
**图A.6：**算术和基本形式
{: refdef}

本模型不包括报告的算术，但为了和其它特性做实验和为本模型写测试套件更加简单，包括理想化的形式。[图A.6]({{ '/appendices/a/' | relative_url }}#Fa-6)展示了实现加减乘除基本过程的消去规则。它们尊重它们的数学类似物。此外，当减法和除法没有参数，或除非收到一个零作为除数，或非数传递给任意的算术过程的时候，一个异常被抛出。

[图A.6]({{ '/appendices/a/' | relative_url }}#Fa-6)的下半部展示了`if`, `begin`, 以及`begin0`的规则。相关的求值上下文通过非终结符*F*被给出。

`if`的求值上下文只允许在它的测试表达式中求值。一旦求出一个值，如果测试不是`#f`，那么`if`表达式被规则消去成它的后项（consequent），如果测试是`#f`的话，则被消去成替代项（alternative）。

`begin`求值上下文允许在begin的第一个子表达式中求值，但只有在有两个或更多子表达式的时候才可以。在那种情况下，一旦第一个表达式被完全简化，消去规则就会丢弃它的值。如果只有一个子表达式的话，`begin`它自己被丢弃。

和`begin`求值上下文类似，当有两个或更多的子表达式的时候，`begin0`求值上下文允许字第一个子表达式中求值。`begin0`求值上下文同时允许在`begin0`表达式的第二个子表达式中求值，只要第一个子表达式被完全简化。`begin0`的`\(\rulename{6begin0n}\)`规则然后丢弃被完全简化的第二个子表达式。最终，在`begin0`中只有一个单独的表达式，在这时规则`\(\rulename{begin01}\)`开火，且删除`begin0`表达式。

## A.7. 表 {#Aa-7}

$$
\begin{array}{lr}
\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{list}~v_1~v_2~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{cons}~v_1~\texttt{(}\va{list}~v_2~\cdots\texttt{)}\texttt{)}]}
  {\rulename{6listc}}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{list}\texttt{)}]}
  {\nt{P}_{1}[\va{null}]}
  {\rulename{6listn}}
  {\rightarrow}

\twolinescruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{cons}~v_1~v_2\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{mp}~\texttt{(}\va{cons}~v_1~v_2\texttt{)}\texttt{)}\texttt{)}~\nt{E}_{1}[\nt{mp}]\texttt{)}}
  {\rulename{6cons}}
  {(\nt{mp} \textrm{新生})}
  {\rightarrow}

\twolinescruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\sy{consi}~v_1~v_2\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{ip}~\texttt{(}\va{cons}~v_1~v_2\texttt{)}\texttt{)}\texttt{)}~\nt{E}_{1}[\nt{ip}]\texttt{)}}
  {\rulename{6consi}}
  {(\nt{ip} \textrm{新生})}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_i~\texttt{(}\va{cons}~v_1~v_2\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{car}~\nt{pp}_i\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_i~\texttt{(}\va{cons}~v_1~v_2\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[v_1]\texttt{)}}
  {\rulename{6car}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_i~\texttt{(}\va{cons}~v_1~v_2\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{cdr}~\nt{pp}_i\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_i~\texttt{(}\va{cons}~v_1~v_2\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[v_2]\texttt{)}}
  {\rulename{6cdr}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{mp}_{1}~\texttt{(}\va{cons}~v_1~v_2\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{set\mbox{\texttt{-}}car\mbox{\texttt{!}}}~\nt{mp}_{1}~\nt{v}_{3}\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{mp}_{1}~\texttt{(}\va{cons}~\nt{v}_{3}~v_2\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\va{unspecified}]\texttt{)}}
  {\rulename{6setcar}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{mp}_{1}~\texttt{(}\va{cons}~v_1~v_2\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{set\mbox{\texttt{-}}cdr\mbox{\texttt{!}}}~\nt{mp}_{1}~\nt{v}_{3}\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{mp}_{1}~\texttt{(}\va{cons}~v_1~\nt{v}_{3}\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\va{unspecified}]\texttt{)}}
  {\rulename{6setcdr}}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{null\mbox{\texttt{?}}}~\va{null}\texttt{)}]}
  {\nt{P}_{1}[\semtrue{}]}
  {\rulename{6null?t}}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{null\mbox{\texttt{?}}}~v_1\texttt{)}]}
  {\nt{P}_{1}[\semfalse{}]}
  {\rulename{6null?f}}
  {(v_1 \neq \va{null})}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{pair\mbox{\texttt{?}}}~\nt{pp}\texttt{)}]}
  {\nt{P}_{1}[\semtrue{}]}
  {\rulename{6pair?t}}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{pair\mbox{\texttt{?}}}~v_1\texttt{)}]}
  {\nt{P}_{1}[\semfalse{}]}
  {\rulename{6pair?f}}
  {(v_1 \not\in \nt{pp})}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{car}~\nt{v}_{i}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``can't ~ take ~ car ~ of ~ non\!\!-\!\!pair''}\texttt{)}\texttt{)}]}
  {\rulename{6care}}
  {(\nt{v}_{i} \not\in \nt{pp})}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{cdr}~\nt{v}_{i}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``can't ~ take ~ cdr ~ of ~ non\!\!-\!\!pair''}\texttt{)}\texttt{)}]}
  {\rulename{6cdre}}
  {(\nt{v}_{i} \not\in \nt{pp})}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{set\mbox{\texttt{-}}car\mbox{\texttt{!}}}~v_1~v_2\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``can't ~ set\!\!-\!\!car! ~ on ~ a ~ non\!\!-\!\!pair ~ or ~ an ~ immutable ~ pair''}\texttt{)}\texttt{)}]}
  {\rulename{6scare}}
  {& \!\!\!\!(v_1 \not\in \nt{mp})}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{set\mbox{\texttt{-}}cdr\mbox{\texttt{!}}}~v_1~v_2\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``can't ~ set\!\!-\!\!cdr! ~ on ~ a ~ non\!\!-\!\!pair ~ or ~ an ~ immutable ~ pair''}\texttt{)}\texttt{)}]}
  {\rulename{6scdre}}
  {& \!\!\!\!(v_1 \not\in \nt{mp})}
  {\rightarrow}

\end{array}
$$

{:refdef .caption #Fa-7}
**图A.7：**表
{: refdef}

[图A.7]({{ '/appendices/a/' | relative_url }}#Fa-7)中的规则处理表。前两个规则通过将它们消去成一系列跟着`null`的`cons`调用来处理表。

下面两个规则`\(\rulename{6cons}\)`和`\(\rulename{6consi}\)`分配新的`cons`单元。它们都将`\(\texttt{(}\va{cons}~v_1~v_2\texttt{)}\)`移到存储中，被绑定到一个新鲜的点对指针上（同时参加[第A.3小节]({{ '/appendices/a/' | relative_url }}#Aa-3)“新生（fresh）”的描述）。`\(\rulename{6cons}\)`使用一个*mp*变量去指示点对是可变的，`\(\rulename{6consi}\)`使用一个*ip*变量去指示点对是不可变的。

当提供一个点对指针（如[图A.2a]({{ '/appendices/a/' | relative_url }}#Fa-2a)所示，*pp*可以是*mp*也可以是*ip*）的时候，规则`\(\rulename{6car}\)`和`\(\rulename{6cdr}\)`从存储中提取一个点对的元素。

规则`\(\rulename{6setcar}\)`和`\(\rulename{6setcdr}\)`处理可变点对的赋值。它们以新的值在存储中替换适当位置的内容，且消去成`unspecified`。[第A.12小节]({{ '/appendices/a/' | relative_url }}#Aa-12)解释了怎样减少成`unspecified`。

下面四个规则处理`null?`谓词和`pair?`谓词，且当`car`, `cdr`, `set-car!` 或`set-cdr!`接收到不是点对的参数的时候，最后的四个规则会抛出异常。

## A.8. Eqv等价 {#Aa-8}

$$
\begin{array}{lr}
\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{eqv\mbox{\texttt{?}}}~v_1~v_1\texttt{)}]}
  {\nt{P}_{1}[\semtrue{}]}
  {\rulename{6eqt}}
  {(v_1 \not\in \nt{proc}, v_1 \neq (\sy{make\mbox{\texttt{-}}cond}~\nt{string}))}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{eqv\mbox{\texttt{?}}}~v_1~v_2\texttt{)}]}
  {\nt{P}_{1}[\semfalse{}]}
  {\rulename{6eqf}}
  {(v_1 \neq v_2, v_1 \not\in \nt{proc}\textrm{ ~ or ~ }v_2 \not\in \nt{proc}, v_1 \neq (\sy{make\mbox{\texttt{-}}cond}~\nt{string})\textrm{ ~ or } & \!\!\!\! v_2 \neq (\sy{make\mbox{\texttt{-}}cond}~\nt{string}))}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{eqv\mbox{\texttt{?}}}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\nt{string}\texttt{)}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\nt{string}\texttt{)}\texttt{)}]}
  {\nt{P}_{1}[\semtrue{}]}
  {\rulename{6eqct}}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{eqv\mbox{\texttt{?}}}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\nt{string}\texttt{)}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\nt{string}\texttt{)}\texttt{)}]}
  {\nt{P}_{1}[\semfalse{}]}
  {\rulename{6eqcf}}
  {\rightarrow}

\end{array}
$$

{:refdef .caption #Fa-8}
**图A.8：**Eqv等价
{: refdef}

`eqv?`规则在[图A.8]({{ '/appendices/a/' | relative_url }}#Fa-8)中展示。前两个规则覆盖了`eqv?`的大部分行为。第一个说当`eqv?`的两个参数是句法上完全相同的时候，那么`eqv?`产生`#t`，第二个说，当参数不是句法上完全相同的时候，`eqv?`产生`#f`。*v*的结构被仔细地设计使得简单的术语相等紧密地对应于`eqv?`的行为。比如，点对被表示成存储位置的指针，且`eqv?`只是简单地比较那些指针。

前两条规则的附加条件确保当简单的术语相等不匹配`eqv?`的行为的时候，它们不会被应用。有两种不匹配的情况：比较两个条件和比较两个过程。对于第一个，本报告没有指定`eqv?`的行为，除了指明它必须返回一个布尔之外，所以剩下的两个规则（`\(\rulename{6eqct}\)`和`\(\rulename{6eqcf}\)`）允许这样的比较返回`#t`或`#f`。比较两个过程在[第A.12小节]({{ '/appendices/a/' | relative_url }}#Aa-12)有讲述。

## A.9. 过程和应用（application） {#Aa-9}

$$
\begin{array}{lr}
\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\nt{e}_{1}~\cdots~\nt{e}_{i}~\nt{e}_{i\mbox{\texttt{+}}1}~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\texttt{(}\sy{lambda}~\texttt{(}\nt{x}\texttt{)}~\texttt{(}\nt{e}_{1}~\cdots~\nt{x}~\nt{e}_{i\mbox{\texttt{+}}1}~\cdots\texttt{)}\texttt{)}~\nt{e}_{i}\texttt{)}]}
  {\rulename{6mark}}
  {(\nt{x} \textrm{新生}, \nt{e}_{i} \not\in \nt{v}, \exists e \in \nt{e}_{1} \cdots \nt{e}_{i\mbox{\texttt{+}}1} \cdots  \textrm{ ~ s.t. ~ } e \not\in \nt{v})}
  {\rightarrow}

\twolinescruleB
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\texttt{(}\sy{lambda}~\texttt{(}x_1~x_2~\cdots\texttt{)}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}~v_1~v_2~\cdots\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{bp}~v_1\texttt{)}\texttt{)}~\nt{E}_{1}[\texttt{(}\{x_1\mapsto \nt{bp}\}\texttt{(}\sy{lambda}~\texttt{(}x_2~\cdots\texttt{)}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}~v_2~\cdots\texttt{)}]\texttt{)}}
  {\rulename{6appN!}}
  {(\nt{bp} \textrm{新生}, \# x_2 = \# v_2, \mathscr{V} \llbracket x_1, \texttt{(}\sy{lambda}~\texttt{(}x_2~\cdots\texttt{)}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)} \rrbracket)}
  {\rightarrow}

\end{array}
$$

$$
\begin{array}{lr}
\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\texttt{(}\sy{lambda}~\texttt{(}x_1~x_2~\cdots\texttt{)}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}~v_1~v_2~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\{x_1\mapsto v_1\}\texttt{(}\sy{lambda}~\texttt{(}x_2~\cdots\texttt{)}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}~v_2~\cdots\texttt{)}]}
  {\rulename{6appN}}
  {(\# x_2 = \# v_2, \ensuremath{\neg} \mathscr{V} \llbracket x_1, \texttt{(}\sy{lambda} & \!\! \texttt{(}x_2~\cdots\texttt{)}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)} \rrbracket)}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\texttt{(}\sy{lambda}~\texttt{()}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\sy{begin}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}]}
  {\rulename{6app0}}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\texttt{(}\sy{lambda}~\texttt{(}x_1~x_2~\cdots~\sy{dot}~\nt{x}_{r}\texttt{)}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}~v_1~v_2~\cdots~\nt{v}_{3}~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\texttt{(}\sy{lambda}~\texttt{(}x_1~x_2~\cdots~\nt{x}_{r}\texttt{)}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}~v_1~v_2~\cdots~\texttt{(}\va{list}~\nt{v}_{3}~\cdots\texttt{)}\texttt{)}]}
  {\rulename{6$\ensuremath{\mu}$app}}
  {(\# x_2 = \# v_2)}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\texttt{(}\sy{lambda}~x_1~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}~v_1~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\texttt{(}\sy{lambda}~\texttt{(}x_1\texttt{)}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}~\texttt{(}\va{list}~v_1~\cdots\texttt{)}\texttt{)}]}
  {\rulename{6$\ensuremath{\mu}$app1}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~v_1\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[x_1]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~v_1\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[v_1]\texttt{)}}
  {\rulename{6var}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~v_1\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\sy{set\mbox{\texttt{!}}}~x_1~v_2\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~v_2\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\va{unspecified}]\texttt{)}}
  {\rulename{6set}}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{procedure\mbox{\texttt{?}}}~\nt{proc}\texttt{)}]}
  {\nt{P}_{1}[\semtrue{}]}
  {\rulename{6proct}}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{procedure\mbox{\texttt{?}}}~\nt{nonproc}\texttt{)}]}
  {\nt{P}_{1}[\semfalse{}]}
  {\rulename{6procf}}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\texttt{(}\sy{lambda}~\texttt{(}x_1~\cdots\texttt{)}~\nt{e}~\nt{e}~\cdots\texttt{)}~v_1~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``arity ~ mismatch''}\texttt{)}\texttt{)}]}
  {\rulename{6arity}}
  {(\# x_1 \neq \# v_1)}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\texttt{(}\sy{lambda}~\texttt{(}x_1~x_2~\cdots~\sy{dot}~\nt{x}\texttt{)}~\nt{e}~\nt{e}~\cdots\texttt{)}~v_1~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``arity ~ mismatch''}\texttt{)}\texttt{)}]}
  {\rulename{6$\ensuremath{\mu}$arity}}
  {(\# v_1 < \# x_2 + 1)}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\nt{nonproc}~\nt{v}~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``can't ~ call ~ non\!\!-\!\!procedure''}\texttt{)}\texttt{)}]}
  {\rulename{6appe}}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\nt{proc1}~v_1~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``arity ~ mismatch''}\texttt{)}\texttt{)}]}
  {\rulename{61arity}}
  {(\#v_1 \neq 1)}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\nt{proc2}~v_1~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``arity ~ mismatch''}\texttt{)}\texttt{)}]}
  {\rulename{62arity}}
  {(\#v_1 \neq 2)}
  {\rightarrow}

\end{array}
$$

{:refdef .caption #Fa-9a}
**图A.9a：**过程&应用
{: refdef}

$$
\begin{array}{lc@{~}l}
\mathscr{V} \in 2^{\nt{x} \times \nt{e}}\\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{set\mbox{\texttt{!}}}~x_2~\nt{e}_{1}\texttt{)} \rrbracket & \textrm{if} &
x_1 = x_2\\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{set\mbox{\texttt{!}}}~x_2~\nt{e}_{1}\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \nt{e}_{1} \rrbracket  \textrm{~and~} x_1 \neq x_2\\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{begin}~\nt{e}_{1}~\nt{e}_{2}~\nt{e}_{3}~\cdots\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \nt{e}_{1} \rrbracket \textrm{或}\mathscr{V} \llbracket{}x_1, \texttt{(}\sy{begin}~\nt{e}_{2}~\nt{e}_{3}~\cdots\texttt{)} \rrbracket \\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{begin}~\nt{e}_{1}\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \nt{e}_{1} \rrbracket \\
\mathscr{V} \llbracket x_1, \texttt{(}\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \texttt{(}\sy{begin}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)} \rrbracket \\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{if}~\nt{e}_{1}~\nt{e}_{2}~\nt{e}_{3}\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \nt{e}_{1} \rrbracket \textrm{或}\mathscr{V} \llbracket{}x_1, \nt{e}_{2} \rrbracket \textrm{或}\mathscr{V} \llbracket{}x_1, \nt{e}_{3} \rrbracket \\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{begin0}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \texttt{(}\sy{begin}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)} \rrbracket \\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{lambda}~\texttt{(}x_2~\cdots\texttt{)}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \texttt{(}\sy{begin}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)} \rrbracket  \textrm{~and~} x_1 \not\in \{ x_2 \cdots \}\\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{lambda}~\texttt{(}x_2~\cdots~\sy{dot}~\nt{x}_{3}\texttt{)}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \texttt{(}\sy{begin}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)} \rrbracket  \textrm{~and~} x_1 \not\in \{ x_2 \cdots \nt{x}_{3} \}\\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{lambda}~x_2~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \texttt{(}\sy{begin}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)} \rrbracket  \textrm{~and~} x_1 \neq x_2\\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{letrec}~\texttt{(}\texttt{(}x_2~\nt{e}_{1}\texttt{)}~\cdots\texttt{)}~\nt{e}_{2}~\nt{e}_{3}~\cdots\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \texttt{(}\sy{begin}~\nt{e}_{1}~\cdots~\nt{e}_{2}~\nt{e}_{3}~\cdots\texttt{)} \rrbracket  \textrm{~and~} x_1 \not\in \{ x_2 \cdots \}\\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{letrec\mbox{\texttt{*}}}~\texttt{(}\texttt{(}x_2~\nt{e}_{1}\texttt{)}~\cdots\texttt{)}~\nt{e}_{2}~\nt{e}_{3}~\cdots\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \texttt{(}\sy{begin}~\nt{e}_{1}~\cdots~\nt{e}_{2}~\nt{e}_{3}~\cdots\texttt{)} \rrbracket  \textrm{~and~} x_1 \not\in \{ x_2 \cdots \}\\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{l\mbox{\texttt{!}}}~x_2~\nt{e}_{1}\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \texttt{(}\sy{set\mbox{\texttt{!}}}~x_2~\nt{e}_{1}\texttt{)} \rrbracket \\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{reinit}~x_2~\nt{e}_{1}\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \texttt{(}\sy{set\mbox{\texttt{!}}}~x_2~\nt{e}_{1}\texttt{)} \rrbracket \\
\mathscr{V} \llbracket x_1, \texttt{(}\sy{dw}~x_2~\nt{e}_{1}~\nt{e}_{2}~\nt{e}_{3}\texttt{)} \rrbracket & \textrm{if} &
\mathscr{V} \llbracket{}x_1, \nt{e}_{1} \rrbracket \textrm{或}\mathscr{V} \llbracket{}x_1, \nt{e}_{2} \rrbracket \textrm{或}\mathscr{V} \llbracket{}x_1, \nt{e}_{3} \rrbracket \\
\end{array}
$$

{:refdef .caption #Fa-9b}
**图A.9b：**变量赋值关系
{: refdef}

$$
\begin{array}{lr}
\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{apply}~\nt{proc}_{1}~v_1~\cdots~\va{null}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\nt{proc}_{1}~v_1~\cdots\texttt{)}]}
  {\rulename{6applyf}}
  {\rightarrow}

\twolinescruleB
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_{1}~\texttt{(}\va{cons}~v_2~\nt{v}_{3}\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{apply}~\nt{proc}_{1}~v_1~\cdots~\nt{pp}_{1}\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_{1}~\texttt{(}\va{cons}~v_2~\nt{v}_{3}\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{apply}~\nt{proc}_{1}~v_1~\cdots~v_2~\nt{v}_{3}\texttt{)}]\texttt{)}}
  {\rulename{6applyc}}
  {(\ensuremath{\neg} \mathscr{C} \llbracket \nt{pp}_{1}, \nt{v}_{3}, \texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_{1}~\texttt{(}\va{cons}~v_2~\nt{v}_{3}\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)} \rrbracket)}
  {\rightarrow}

\twolinescruleB
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_{1}~\texttt{(}\va{cons}~v_2~\nt{v}_{3}\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{apply}~\nt{proc}_{1}~v_1~\cdots~\nt{pp}_{1}\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_{1}~\texttt{(}\va{cons}~v_2~\nt{v}_{3}\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``apply ~ called ~ on ~ circular ~ list''}\texttt{)}\texttt{)}]\texttt{)}}
  {\rulename{6applyce}}
  {(\mathscr{C} \llbracket \nt{pp}_{1}, \nt{v}_{3}, \texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_{1}~\texttt{(}\va{cons}~v_2~\nt{v}_{3}\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)} \rrbracket)}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{apply}~\nt{nonproc}~\nt{v}~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``can't ~ apply ~ non\!\!-\!\!procedure''}\texttt{)}\texttt{)}]}
  {\rulename{6applynf}}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{apply}~\nt{proc}~v_1~\cdots~v_2\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``apply's ~ last ~ argument ~ non\!\!-\!\!list''}\texttt{)}\texttt{)}]}
  {\rulename{6applye}}
  {(v_2 \not\in \nt{list-v})}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{apply}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``arity ~ mismatch''}\texttt{)}\texttt{)}]}
  {\rulename{6apparity0}}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\va{apply}~\nt{v}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``arity ~ mismatch''}\texttt{)}\texttt{)}]}
  {\rulename{6apparity1}}
  {\rightarrow}

\end{array}
$$

$$
\begin{array}{lc@{~}l}
\mathscr{C} \in 2^{\nt{pp} \times \nt{val} \times \texttt{(}\nt{sf}~\cdots\texttt{)}}\\
\mathscr{C} \llbracket \nt{pp}_{1}, \nt{pp}_{2}, \texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_{2}~\texttt{(}\va{cons}~v_1~v_2\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)} \rrbracket & \textrm{if} &
\nt{pp}_{1} = v_2\\
\mathscr{C} \llbracket \nt{pp}_{1}, \nt{pp}_{2}, \texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_{2}~\texttt{(}\va{cons}~v_1~v_2\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)} \rrbracket & \textrm{if} &
\mathscr{C} \llbracket{}\nt{pp}_{1}, v_2, \texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{pp}_{2}~\texttt{(}\va{cons}~v_1~v_2\texttt{)}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)} \rrbracket  \textrm{~and~} \nt{pp}_{1} \neq v_2\\
\end{array}
$$

{:refdef .caption #Fa-9c}
**图A.9c：**应用
{: refdef}

在对一个过程调用进行求值的时候，本报告故意让参数的求值顺序是未定义的。所以，我们的消去系统允许发生多个不同的消去，每个对应一个可能的求值顺序。

虽然没有指定求值顺序，但程序子表达式的求值结果应该就像以某种顺序求值一样，只有在我们还没有承诺消去其它子表达式的时候，我们才使用未确定的选择来挑选第一个被消去的子表达式。为了获得那个效果，我们将应用表达式的求值限制到只有那些有一个单独的没有完全消去的表达式，如[图A.2b]({{ '/appendices/a/' | relative_url }}#Fa-2b)中非终结符*F*所示。求值有超过两个参数需要的求值的的应用表达式，规则`\(\rulename{6mark}\)`挑选没有完全简化的应用中的一个子表达式，且将它提升到它自己的应用中，以允许其被求值。一旦被提升的表达式中的一个被求值，那么`\(\rulename{6appN}\)`将它的值替换回原来的应用中。

规则`\(\rulename{6appN}\)`也处理这样的应用，其完成其参数通过在表达式中以第一个参数替代其第一个形式参数。附加条件使用[图A.9b]({{ '/appendices/a/' | relative_url }}#Fa-9b)中的关系来确保没有以`\(x_1\)`作为目标的`set!`表达式。如果没有这样的赋值，那么应用规则`\(\rulename{6appN!}\)`（同时参考[第A.3小节]({{ '/appendices/a/' | relative_url }}#Aa-3)对“新生（fresh）”的描述）。我们没有直接将形式参数替换为实际参数，而是创建了一个新的存储位置，初始地绑定实际参数，并将形式参数替换为代表这个位置的变量。然后，这个参数负责处理任何最终的参数赋值。一旦所有的参数都被替换掉，就应用规则`\(\rulename{6app0}\)`以及开始过程内部的计算。

乍一看，规则`\(\rulename{6appN}\)`是多余的，因为好像这条规则只能通过`\(\rulename{6appN!}\)`第一次消去，且在被求值的时候查找变量。然而，有两个保留`\(\rulename{6appN}\)`的原因。第一个纯粹是传统：我们在早期就被教育使用替代来消去程序，且在文献当中，其也被在写系统中广泛使用。第二个是更技术上的原因：规则`\(\rulename{6mark}\)`要求一旦`\(e_i\)`被消去成一个值，就要应用`\(\rulename{6appN}\)`。`\(\rulename{6appN!}\)`会将值提进存储中，且在应用中放入一个变量引用，其导致`\(\rulename{6mark}\)`的另一个使用，以及`\(\rulename{6appN!}\)`的另一个使用，并继续下去。

规则`\(\rulename{6$\mu$app}\)`处理点参数列表的函数的应用。通过将额外的参数组织成一个表，一个这样的应用被转换成普通过程的应用。类似地，规则`\(\rulename{6$\mu$app1}\)`处理单个变量作为参数列表的过程的应用。

规则`\(\rulename{6var}\)`处理存储中的变量查找，`\(\rulename{6set}\)`处理变量赋值。

下面两个规则`\(\rulename{6proct}\)`和`\(\rulename{6procf}\)`处理`procedure?`的应用，其余的规则覆盖了非过程和任意错误的应用。

[图A.9c]({{ '/appendices/a/' | relative_url }}#Fa-9c)中的规则覆盖了`apply`。第一个规则`\(\rulename{6applyf}\)`，覆盖了`apply`的最后一个参数是空表的情况，并通过消去删去空表和`apply`来进行简单的消去。第二个规则，`\(\rulename{6applyc}\)`覆盖一个形式良好的`apply`应用，其中，apply的最后一个参数是一个点对。它通过从存储中萃取点对的组件以及将它们放到`apply`的应用中来进行消去。这样重复本规则的应用可以萃取存储外的传递给`apply`的表的所有元素<!--TODO-->。

剩余的五条规则覆盖在使用`apply`的过程中可能出现的各种各样的错误。第一个覆盖`apply`应用到循环表的情况。后四个覆盖应用到非过程，传递非表作为最后一个参数，以及传递给`apply`过少的参数。

## A.10. Call/cc和动态缠绕（dynamic wind） {#Aa-10}

$$
\begin{array}{lr}
\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{dynamic\mbox{\texttt{-}}wind}~\nt{proc}_{1}~\nt{proc}_{2}~\nt{proc}_{3}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\sy{begin}~\texttt{(}\nt{proc}_{1}\texttt{)}~\texttt{(}\sy{begin0}~\texttt{(}\sy{dw}~\nt{x}~\texttt{(}\nt{proc}_{1}\texttt{)}~\texttt{(}\nt{proc}_{2}\texttt{)}~\texttt{(}\nt{proc}_{3}\texttt{)}\texttt{)}~\texttt{(}\nt{proc}_{3}\texttt{)}\texttt{)}\texttt{)}]}
  {\rulename{6wind}}
  {(\nt{x} \textrm{新生})}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{dynamic\mbox{\texttt{-}}wind}~v_1~v_2~\nt{v}_{3}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``dynamic\!\!-\!\!wind ~ expects ~ procs''}\texttt{)}\texttt{)}]}
  {\rulename{6winde}}
  {(v_1 \not\in \nt{proc}\textrm{或}v_2 \not\in \nt{proc} & \!\! \textrm{或}\nt{v}_{3} \not\in \nt{proc})}
  {\rightarrow}

\twolinescruleA
  {\nt{P}_{1}[\texttt{(}\va{dynamic\mbox{\texttt{-}}wind}~v_1~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``arity ~ mismatch''}\texttt{)}\texttt{)}]}
  {\rulename{6dwarity}}
  {(\#v_1 \neq 3)}
  {\rightarrow}

\twolineruleA
  {\nt{P}_{1}[\texttt{(}\sy{dw}~\nt{x}~\nt{e}~\texttt{(}\va{values}~v_1~\cdots\texttt{)}~\nt{e}\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\va{values}~v_1~\cdots\texttt{)}]}
  {\rulename{6dwdone}}
  {\rightarrow}

\twolinescruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{call\mbox{\texttt{/}}cc}~v_1\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}v_1~\texttt{(}\sy{throw}~\nt{x}~\nt{E}_{1}[\nt{x}]\texttt{)}\texttt{)}]\texttt{)}}
  {\rulename{6call/cc}}
  {(\nt{x} \textrm{新生})}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\texttt{(}\sy{throw}~x_1~\nt{E}_{2}[x_1]\texttt{)}~v_1~\cdots\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\mathscr{T}\llbracket{}\nt{E}_{1}, \nt{E}_{2}\rrbracket[\texttt{(}\va{values}~v_1~\cdots\texttt{)}]\texttt{)}}
  {\rulename{6throw}}
  {\rightarrow}

\end{array}
$$

$$
\begin{array}{lcl}
\mathscr{T} : \nt{E} \times \nt{E} \rightarrow \nt{E}\\\mathscr{T} \llbracket \nt{H}_{1}[\texttt{(}\sy{dw}~x_1~\nt{e}_{1}~\nt{E}_{1}~\nt{e}_{2}\texttt{)}], \nt{H}_{2}[\texttt{(}\sy{dw}~x_1~\nt{e}_{3}~\nt{E}_{2}~\nt{e}_{4}\texttt{)}] \rrbracket & = &
\nt{H}_{2}[\texttt{(}\sy{dw}~x_1~\nt{e}_{3}~\mathscr{T}\llbracket{}\nt{E}_{1}, \nt{E}_{2}\rrbracket~\nt{e}_{4}\texttt{)}] \\
\mathscr{T} \llbracket \nt{E}_{1}, \nt{E}_{2} \rrbracket & = &
\texttt{(}\sy{begin}~\mathscr{S}\llbracket{}\nt{E}_{1}\rrbracket[1]~\mathscr{R}\llbracket{}\nt{E}_{2}\rrbracket\texttt{)} ~ ~ ~ ~ ~ ~ ~ \mbox{\textrm{(否则)}}\\
\\\mathscr{R} : \nt{E} \rightarrow \nt{E}\\\mathscr{R} \llbracket \nt{H}_{1}[\texttt{(}\sy{dw}~x_1~\nt{e}_{1}~\nt{E}_{1}~\nt{e}_{2}\texttt{)}] \rrbracket & = &
\nt{H}_{1}[\texttt{(}\sy{begin}~\nt{e}_{1}~\texttt{(}\sy{dw}~x_1~\nt{e}_{1}~\mathscr{R}\llbracket{}\nt{E}_{1}\rrbracket~\nt{e}_{2}\texttt{)}\texttt{)}] \\
\mathscr{R} \llbracket \nt{H}_{1} \rrbracket & = &
\nt{H}_{1} ~ ~ ~ ~ ~ ~ ~ \mbox{\textrm{(否则)}}\\
\\\mathscr{S} : \nt{E} \rightarrow \nt{E}\\\mathscr{S} \llbracket \nt{E}_{1}[\texttt{(}\sy{dw}~x_1~\nt{e}_{1}~\nt{H}_{2}~\nt{e}_{2}\texttt{)}] \rrbracket & = &
\mathscr{S} \llbracket{}\nt{E}_{1} \rrbracket [\texttt{(}\sy{begin0}~\texttt{(}\sy{dw}~x_1~\nt{e}_{1}~\hole~\nt{e}_{2}\texttt{)}~\nt{e}_{2}\texttt{)}] \\
\mathscr{S} \llbracket \nt{H}_{1} \rrbracket & = &
\hole ~ ~ ~ ~ ~ ~ ~ \mbox{\textrm{(否则)}}\\
\end{array}
$$

{:refdef .caption #Fa-10}
**图A.10：**Call/cc和动态缠绕
{: refdef}

`dynamic-wind`的规范使用表达式`(dw x e e e)`来记录在计算的每个点哪些dynamic-wind*槽*是活动的。它的第一个参数是一个全局唯一的标识符，且可以用作指示`dynamic-wind`的调用，其作用是为了避免在一个继续的切换中推出并重新进入相同的动态上下文中。第二三四个参数是来自`dynamic-wind`调用的一些*before*，*thunk*和*after*过程调用。求值只发生在中间的表达式中；`dw`表达式只用作记录哪个*before*和*after*过程需要在继续切换期间被运行。相应地，`dynamic-wind`应用的消去规则消去到*before*过程的调用，`dw`表达式和`after`过程的调用，如[图A.10]({{ '/appendices/a/' | relative_url }}#Fa-10)中规则`\(\rulename{6wind}\)`所示。下面两条规则覆盖`dynamic-wind`过程的滥用：传递非过程调用，以错误数量的参数调用。规则`\(\rulename{6dwdone}\)`在它的第二个参数已经完成计算的时候消除`dw`表达式。

下面两条规则覆盖`call/cc`。规则`\(\rulename{6call/cc}\)`创建一个新的继续。这个继续拥有`call/cc`的上下文，且将其打包到表示这个继续的`throw`表达式中。`throw`表达式使用新生的*x*来记录`call/cc`应用在上下文中发生的地方，这时为了在继续被应用的时候在规则`\(\rulename{6throw}\)`中使用。那个规则取得继续的参数，使用`values`调用将其打包，并将其放回到原始`call/cc`调用出现的地方，以元函数`\(\mathscr{T}\)`返回的上下文替换当前的上下文。

元函数`\(\mathscr{T}\)`（为了“修正”）接受两个D上下文，且绑定一个匹配其第二个参数的上下文，即目的上下文，这在已经被加入的上下文中排除了来自`dw`表达式的*before*和*after*过程的多余的调用。

元函数`\(\mathscr{T}\)`的第一个子句利用H上下文，这是一个包含除了`dynamic-wind`上下文之外任何东西的上下文。它确保`dynamic-wind`上下文的公共部分被忽略，更深地返回到两个表达式的上下文中，只要每个里面的第一个`dw`表达式有匹配的标识符`\((x_1)\)`。最后的规则是一个大杂烩；它只有在其它规则失败的时候才应用，且因此或者在没有`dw`的时候应用，或者在`dw`表达式不匹配的时候应用。它调用定义在[图A.10]({{ '/appendices/a/' | relative_url }}#Fa-10)中的两个其它的元函数，且将它们的结果一起放进`begin`表达式中。

元函数`\(\mathscr{R}\)`从其参数中提前所有的*before*过程，元函数`\(\mathscr{S}\)`从其参数中提前所有的*after*过程。它们都构造新的上下文，且利用H处理完它们的参数，每次一个`dw`。在任何情况下，元函数小心地保持正确的在每个过程周围的上下文，以防万一一个继续跳转发生在它们的求值中。由于`\(\mathscr{R}\)`接收目的上下文，所以它在其结果中保持上下文的中间部分。这和`\(\mathscr{S}\)`抛弃所有除了`dw`之外的上下文形成对比，因为那是继续发生的上下文。

## A.11. Letrec {#Aa-11}

$$
\begin{array}{lr}
\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~\sy{bh}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\sy{l\mbox{\texttt{!}}}~x_1~v_2\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~v_2\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\va{unspecified}]\texttt{)}}
  {\rulename{6initdt}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~v_1\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\sy{l\mbox{\texttt{!}}}~x_1~v_2\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~v_2\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\va{unspecified}]\texttt{)}}
  {\rulename{6initv}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~\sy{bh}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\sy{set\mbox{\texttt{!}}}~x_1~v_1\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~v_1\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\va{unspecified}]\texttt{)}}
  {\rulename{6setdt}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~\sy{bh}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\sy{set\mbox{\texttt{!}}}~x_1~v_1\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~\sy{bh}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``letrec ~ variable ~ touched''}\texttt{)}\texttt{)}]\texttt{)}}
  {\rulename{6setdte}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~\sy{bh}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[x_1]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~\sy{bh}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``letrec ~ variable ~ touched''}\texttt{)}\texttt{)}]\texttt{)}}
  {\rulename{6dt}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~\semfalse{}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\sy{reinit}~x_1\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~\semtrue{}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}['\nt{ignore}]\texttt{)}}
  {\rulename{6init}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~\semtrue{}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\sy{reinit}~x_1\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~\semtrue{}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}['\nt{ignore}]\texttt{)}}
  {\rulename{6reinit}}
  {\rightarrow}

\twolineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~\semtrue{}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\sy{reinit}~x_1\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}x_1~\semtrue{}\texttt{)}~\nt{sf}_{2}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\va{raise}~\texttt{(}\sy{make\mbox{\texttt{-}}cond}~\textrm{``reinvoked ~ continuation ~ of ~ letrec ~ init''}\texttt{)}\texttt{)}]\texttt{)}}
  {\rulename{6reinite}}
  {\rightarrow}

\fourlinescruleB
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\sy{letrec}~\texttt{(}\texttt{(}x_1~\nt{e}_{1}\texttt{)}~\cdots\texttt{)}~\nt{e}_{2}~\nt{e}_{3}~\cdots\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{lx}~\sy{bh}\texttt{)}~\cdots~\texttt{(}\nt{ri}~\semfalse{}\texttt{)}~\cdots\texttt{)}}
  {~~~\nt{E}_{1}[\texttt{(}\texttt{(}\sy{lambda}~\texttt{(}x_1~\cdots\texttt{)}~\texttt{(}\sy{l\mbox{\texttt{!}}}~\nt{lx}~x_1\texttt{)}~\cdots~\{x_1 \mapsto \nt{lx}\cdots \}\nt{e}_{2}~\{x_1 \mapsto \nt{lx}\cdots \}\nt{e}_{3}~\cdots\texttt{)}}
  {~~~\hphantom{\nt{E}_{1}[\texttt{(}}\texttt{(}\sy{begin0}~\{x_1 \mapsto \nt{lx}\cdots \}\nt{e}_{1}~\texttt{(}\sy{reinit}~\nt{ri}\texttt{)}\texttt{)} \cdots\texttt{)])}}
  {\rulename{6letrec}}
  {(\nt{lx} \cdots \textrm{新生}, \nt{ri} \cdots \textrm{新生})}
  {\rightarrow}

\fourlinescruleB
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots\texttt{)}~\nt{E}_{1}[\texttt{(}\sy{letrec\mbox{\texttt{*}}}~\texttt{(}\texttt{(}x_1~\nt{e}_{1}\texttt{)}~\cdots\texttt{)}~\nt{e}_{2}~\nt{e}_{3}~\cdots\texttt{)}]\texttt{)}}
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}_{1}~\cdots~\texttt{(}\nt{lx}~\sy{bh}\texttt{)}~\cdots~\texttt{(}\nt{ri}~\semfalse{}\texttt{)}~\cdots\texttt{)}~ }
  {~~~ \nt{E}_{1}[\{x_1 \mapsto \nt{lx}\cdots \} }
  {~~~ \hphantom{\nt{E}_{1}[} \texttt{(}\sy{begin}~\texttt{(}\sy{begin}~\texttt{(}\sy{l\mbox{\texttt{!}}}~\nt{lx}~\nt{e}_{1}\texttt{)}~\texttt{(}\sy{reinit}~\nt{ri}\texttt{)}\texttt{)}~\cdots~\nt{e}_{2}~\nt{e}_{3}~\cdots\texttt{)}]\texttt{)}}
  {\rulename{6letrec*}}
  {(\nt{lx} \cdots \textrm{新生}, \nt{ri} \cdots \textrm{新生})}
  {\rightarrow}

\end{array}
$$

{:refdef .caption #Fa-11}
**图A.11：**Letrec和letrec*
{: refdef}

[图A.11]({{ '/appendices/a/' | relative_url }}#Fa-11)显示了处理`letrec`，`letrec*`,及它们产生的补充表达式，`l!`和`reinit`。作为第一个近似，`letrec`和`letrec*`两者都通过在新的位置分配空间来保持初始表达式的值的方式来消去，并将这些位置初始化为`bh`（是“black hole（黑洞）”的简写），计算初始表达式，并使用`l!`更新存储有初始表达式的值的位置。我们同时使用`reinit`去检测一个letrec中的初始表达式是通过继续重新进入的情况。

在考虑`letrec`和`letrec*`怎样使用`l!`和`reinit`之前，首先考虑`l!`和`reinit`怎样工作。[图A.11]({{ '/appendices/a/' | relative_url }}#Fa-11)中的前两个规则覆盖了`l!`。它和`set!`的行为非常像，但它同时初始化普通的变量和当前绑定到黑洞（`bh`）的变量。

下面两个规则覆盖当普通的`set!`应用到当前被绑定到黑洞的情况。这种情况在程序在letrec初始化变量之前赋值给它的时候会发生，比如，`(letrec ((x (set! x 5))) x)`。本报告指定一个实现应当或者执行一个赋值，如规则`\(\rulename{6setdt}\)`所示，或是抛出一个异常，如规则`\(\rulename{6setdte}\)`所示。

规则`\(\rulename{6dt}\)`覆盖变量在初始化之前被引用的情况，在这种情况下必须总是抛出一个异常。

`reinit`表达式用作检测在一个初始化表达式中捕获了一个继续的程序，并重新进入其中，这在`\(\rulename{6init}\)`，`\(\rulename{6reinit}\)`和`\(\rulename{6reinite}\)`这三个规则中被展示。`reinit`形式接受一个标识符，其被作为参数绑定到一个布尔的存储位置。它们被初始化为`#f`。当`reinit`被计算，它就会检查这个变量的值，如果其还是`#f`，就将其改为`#t`。如果其已经是`#t`，`reinit`或者什么都不做，或者抛出一个异常，并与`letrec`和`letrec*`两个的合法行为相一致。

[图A.11]({{ '/appendices/a/' | relative_url }}#Fa-11)中的最后两个规则将`l!`和`reinit`放在一起。为了获得初始表达式未定义的求值顺序，规则`\(\rulename{6letrec}\)`将一个`letrec`表达式消去为一个应用表达式。每个初始表达式被包裹进一个记录初始值的`begin0`中，然后使用`reinit`去检测返回到初始表达式中的继续。一旦所有的初始表达式被求值，规则右手边的过程被调用，其导致初始表达式的值被填充到存储位置，且求值以原始的`letrec`表达式的内部继续。

规则`\(\rulename{6letrec*}\)`的行为类似，但使用`begin`表达式而不是一个应用，这是因为初始表达式被从左到右进行求值。此外，每个初始表达式在其被求值的时候被填充到存储位置，以便接下来的初始表达式可以引用它的值。

## A.12. 规范不足（Underspecification） {#Aa-12}

$$
\begin{array}{l@{}l@{}lr}
\onelineruleA
  {\nt{P}[\texttt{(}\va{eqv\mbox{\texttt{?}}}~\nt{proc}~\nt{proc}\texttt{)}]}
  {\mbox{\textbf{unknown:}过程的等价}}
  {\rulename{6ueqv}}
  {\rightarrow}

\onelinescruleA
  {\nt{P}[\texttt{(}\va{values}~v_1~\cdots\texttt{)}]_{\circ}}
  {\mbox{\textbf{unknown: }上下文期待一个值，接受到\#}v_1}
  {\rulename{6uval}}
  {(\#v_1 \neq 1)}
  {\rightarrow}

\onelineruleA
  {\nt{P}[\nt{U}[\va{unspecified}]]}
  {\mbox{\textbf{unknown:}未定义的结果}}
  {\rulename{6udemand}}
  {\rightarrow}

\onelineruleA
  {\texttt{(}\sy{store}~\texttt{(}\nt{sf}~\cdots\texttt{)}~\va{unspecified}\texttt{)}}
  {\mbox{\textbf{unknown:}未定义的结果}}
  {\rulename{6udemandtl}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\sy{begin}~\va{unspecified}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\sy{begin}~\nt{e}_{1}~\nt{e}_{2}~\cdots\texttt{)}]}
  {\rulename{6ubegin}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\sy{handlers}~\nt{v}~\cdots~\va{unspecified}\texttt{)}]}
  {\nt{P}_{1}[\va{unspecified}]}
  {\rulename{6uhandlers}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\sy{dw}~\nt{x}~\nt{e}~\va{unspecified}~\nt{e}\texttt{)}]}
  {\nt{P}_{1}[\va{unspecified}]}
  {\rulename{6udw}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\sy{begin0}~\texttt{(}\va{values}~v_1~\cdots\texttt{)}~\va{unspecified}~\nt{e}_{1}~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\sy{begin0}~\texttt{(}\va{values}~v_1~\cdots\texttt{)}~\nt{e}_{1}~\cdots\texttt{)}]}
  {\rulename{6ubegin0}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\sy{begin0}~\va{unspecified}~\texttt{(}\va{values}~v_2~\cdots\texttt{)}~\nt{e}_{2}~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\sy{begin0}~\va{unspecified}~\nt{e}_{2}~\cdots\texttt{)}]}
  {\rulename{6ubegin0u}}
  {\rightarrow}

\onelineruleA
  {\nt{P}_{1}[\texttt{(}\sy{begin0}~\va{unspecified}~\va{unspecified}~\nt{e}_{2}~\cdots\texttt{)}]}
  {\nt{P}_{1}[\texttt{(}\sy{begin0}~\va{unspecified}~\nt{e}_{2}~\cdots\texttt{)}]}
  {\rulename{6ubegin0uu}}
  {\rightarrow}

\end{array}
$$

{:refdef .caption #Fa-12}
**图A.12：**显式未定义的行为
{: refdef}

[图A.12]({{ '/appendices/a/' | relative_url }}#Fa-12)中的规则覆盖未显式定义的语义部分。实现可以用不同的覆盖左边的规则替换规则`\(\rulename{6ueqv}\)`和`\(\rulename{6uval}\)`，只要它们遵守非正式的规范，任何的替换都是合法的。那三种情况对应于`eqv?`应用到两个过程和多值被用在单值的上下文中的情况。

[图A.12]({{ '/appendices/a/' | relative_url }}#Fa-12)中剩余的规则覆盖从赋值操作，`set!`，`set-car!`和`set-cdr!`的结果。实现不调整这些规则，而是通过调整插入`unspecified:``\(\rulename{6setcar}\)`,`\(\rulename{6setcdr}\)`,`\(\rulename{6set}\)`和`\(\rulename{6setd}\)`的规则使其失效。那些规则可通过在其中将`unspecified`替换为任意数量的值来调整。

所以，剩余的规则只是指定了我们知道的一个值或多个值必须有的最小的行为，否则消去到`unknown:`状态。规则`\(\rulename{6udemand}\)`使`unspecified`掉落到上下文`U`中。`U`的精确定义见[图A.2b]({{ '/appendices/a/' | relative_url }}#Fa-2b)，但是直观地，他是一个只有一个单独的表达式层深度的上下文，其包含值取决于子表达式的表达式，就像`if`的第一个子表达式。以下是在表达式中忽略`unspecified`的规则，这些表达式忽略它们的一些子表达式的值。`\(\rulename{6ubegin}\)`展示了`begin`怎样在有多个表达式要求值的时候忽略其第一个表达式。接下来的两个规则，`\(\rulename{6uhandlers}\)`和`\(\rulename{6udew}\)`将`unspecified`传播到它们的上下文中，这是因为它们也返回任意数量的值到它们的上下文中。最后，两个`begin0`规则保留`unspecified`直到规则`\(\rulename{6begin01}\)`可以将其返回到它的上下文中。
