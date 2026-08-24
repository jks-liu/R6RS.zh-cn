---
layout: r6rs
title: '附录B. 衍生形式的定义示例'
title_plain: '附录B. 衍生形式的定义示例 — R6RS简体中文翻译'
permalink: /appendices/b/
r6rs: true
chapter_key: appendix-b
previous_url: /appendices/a/
previous_title: '附录A. 形式语义'
next_url: /appendices/c/
next_title: '附录C. 附加材料'
---

<!-- 由 scripts/generate_chapters.ps1 从 single-page.md 生成；正文修改请在单页源文件中进行。 -->

# 附录B. 衍生形式的定义示例 {#Ab}

本附录包含本报告描述的一些关键词根据比较简单的形式的定义示例。

`cond`

`cond`关键词（[第11.4.5小节]({{ '/chapters/11/' | relative_url }}#s11-4-5)）可以根据`if`，`let`和`begin`通过`syntax-rules`定义如下：

~~~ scheme
(define-syntax cond
  (syntax-rules (else =>)
    ((cond (else result1 result2 ...))
     (begin result1 result2 ...))
    ((cond (test => result))
     (let ((temp test))
       (if temp (result temp))))
    ((cond (test => result) clause1 clause2 ...)
     (let ((temp test))
       (if temp
           (result temp)
           (cond clause1 clause2 ...))))
    ((cond (test)) test)
    ((cond (test) clause1 clause2 ...)
     (let ((temp test))
       (if temp
           temp
           (cond clause1 clause2 ...))))
    ((cond (test result1 result2 ...))
     (if test (begin result1 result2 ...)))
    ((cond (test result1 result2 ...)
           clause1 clause2 ...)
     (if test
         (begin result1 result2 ...)
         (cond clause1 clause2 ...)))))
~~~

`case`

`case`关键词（[第11.4.5小节]({{ '/chapters/11/' | relative_url }}#s11-4-5)）可以根据`let`，`cond`和`memv`（见库的第3章）通过`syntax-rules`定义如下：

~~~ scheme
(define-syntax case
  (syntax-rules (else)
    ((case expr0
       ((key ...) res1 res2 ...)
       ...
       (else else-res1 else-res2 ...))
     (let ((tmp expr0))
       (cond
         ((memv tmp '(key ...)) res1 res2 ...)
         ...
         (else else-res1 else-res2 ...))))
    ((case expr0
       ((keya ...) res1a res2a ...)
       ((keyb ...) res1b res2b ...)
       ...)
     (let ((tmp expr0))
       (cond
         ((memv tmp '(keya ...)) res1a res2a ...)
         ((memv tmp '(keyb ...)) res1b res2b ...)
         ...)))))
~~~

`let*`

`let*`关键词（[第11.4.6小节]({{ '/chapters/11/' | relative_url }}#s11-4-6)）可以根据`let`通过`syntax-rules`定义如下：

~~~ scheme
(define-syntax let*
  (syntax-rules ()
    ((let* () body1 body2 ...)
     (let () body1 body2 ...))
    ((let* ((name1 expr1) (name2 expr2) ...)
       body1 body2 ...)
     (let ((name1 expr1))
       (let* ((name2 expr2) ...)
         body1 body2 ...)))))
~~~

`letrec`

`let*`关键词（[第11.4.6小节]({{ '/chapters/11/' | relative_url }}#s11-4-6)）可以大概根据`let`和`set!`通过`syntax-rules`定义，使用一个辅助对象来产生需要在赋值前被创造需要保存值得临时变量，如下所示：

~~~ scheme
(define-syntax letrec
  (syntax-rules ()
    ((letrec () body1 body2 ...)
     (let () body1 body2 ...))
    ((letrec ((var init) ...) body1 body2 ...)
     (letrec-helper
       (var ...)
       ()
       ((var init) ...)
       body1 body2 ...))))

(define-syntax letrec-helper
  (syntax-rules ()
    ((letrec-helper
       ()
       (temp ...)
       ((var init) ...)
       body1 body2 ...)
     (let ((var <undefined>) ...)
       (let ((temp init) ...)
         (set! var temp)
         ...)
       (let () body1 body2 ...)))
    ((letrec-helper
       (x y ...)
       (temp ...)
       ((var init) ...)
       body1 body2 ...)
     (letrec-helper
       (y ...)
       (newtemp temp ...)
       ((var init) ...)
       body1 body2 ...))))
~~~

语法`<undefined>`表示一个返回一些东西的表达式，当被存储在一个位置时，导致一个条件类型是`&assertion`的异常被抛出，如果一个读或写这个位置的尝试发生在`letrec`转换产生的赋值发生之前的话。（Scheme中没有这样的表达式定义。）

一个使用`syntax-case`和`generate-temporaries`的更简单的定义在库的第12章被给出。

`letrec*`

`letrec*`关键词可以大概根据`let`和`set!`通过`syntax-rules`定义如下：

~~~ scheme
(define-syntax letrec*
  (syntax-rules ()
    ((letrec* ((var1 init1) ...) body1 body2 ...)
     (let ((var1 <undefined>) ...)
       (set! var1 init1)
       ...
       (let () body1 body2 ...)))))
~~~

语法`<undefined>`和上面`letrec`中定义的一样。

`let-values`


使用`syntax-rules`的`let-values`（[第11.4.6小节]({{ '/chapters/11/' | relative_url }}#s11-4-6)）的下列定义采用一对帮助对象来为形参创建临时的名字。

~~~ scheme
(define-syntax let-values
  (syntax-rules ()
    ((let-values (binding ...) body1 body2 ...)
     (let-values-helper1
       ()
       (binding ...)
       body1 body2 ...))))

(define-syntax let-values-helper1
  ;; map over the bindings
  (syntax-rules ()
    ((let-values
       ((id temp) ...)
       ()
       body1 body2 ...)
     (let ((id temp) ...) body1 body2 ...))
    ((let-values
       assocs
       ((formals1 expr1) (formals2 expr2) ...)
       body1 body2 ...)
     (let-values-helper2
       formals1
       ()
       expr1
       assocs
       ((formals2 expr2) ...)
       body1 body2 ...))))

(define-syntax let-values-helper2
  ;; create temporaries for the formals
  (syntax-rules ()
    ((let-values-helper2
       ()
       temp-formals
       expr1
       assocs
       bindings
       body1 body2 ...)
     (call-with-values
       (lambda () expr1)
       (lambda temp-formals
         (let-values-helper1
           assocs
           bindings
           body1 body2 ...))))
    ((let-values-helper2
       (first . rest)
       (temp ...)
       expr1
       (assoc ...)
       bindings
       body1 body2 ...)
     (let-values-helper2
       rest
       (temp ... newtemp)
       expr1
       (assoc ... (first newtemp))
       bindings
       body1 body2 ...))
    ((let-values-helper2
       rest-formal
       (temp ...)
       expr1
       (assoc ...)
       bindings
       body1 body2 ...)
     (call-with-values
       (lambda () expr1)
       (lambda (temp ... . newtemp)
         (let-values-helper1
           (assoc ... (rest-formal newtemp))
           bindings
           body1 body2 ...))))))
~~~

`let*-values`

下列的宏根据`let`和`let-values`通过`syntax-rules`定义了`let*-values`：

~~~ scheme
(define-syntax let*-values
  (syntax-rules ()
    ((let*-values () body1 body2 ...)
     (let () body1 body2 ...))
    ((let*-values (binding1 binding2 ...)
       body1 body2 ...)
     (let-values (binding1)
       (let*-values (binding2 ...)
         body1 body2 ...)))))
~~~

`let`

`let`关键词可以根据`lambda`和`letrec`通过`syntax-rules`被定义如下：

~~~ scheme
(define-syntax \ide{let}
  (syntax-rules ()
    ((let ((name val) ...) body1 body2 ...)
     ((lambda (name ...) body1 body2 ...)
      val ...))
    ((let tag ((name val) ...) body1 body2 ...)
     ((letrec ((tag (lambda (name ...)
                      body1 body2 ...)))
        tag)
      val ...))))
~~~
