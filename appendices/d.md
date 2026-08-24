---
layout: r6rs
title: '附录D. 示例'
title_plain: '附录D. 示例 — R6RS简体中文翻译'
permalink: /appendices/d/
r6rs: true
chapter_key: appendix-d
previous_url: /appendices/c/
previous_title: '附录C. 附加材料'
next_url: /appendices/e/
next_title: '附录E. 语言的变化'
---

<!-- 由 scripts/generate_chapters.ps1 从 single-page.md 生成；正文修改请在单页源文件中进行。 -->

# 附录D. 示例 {#Ad}

本节包含一个组成`(runge-kutta)`库的示例，这个库提供一个`integrate-system`过程，其以Runge-Kutta的方法对微分方程系统

$$y_k^\prime = f_k(y_1, y_2, \ldots, y_n), \; k = 1, \ldots, n$$

求积分。

因为`(runge-kutta)`库利用了`(rnrs base (6))`库，所以其骨架如下所示：

~~~ scheme
#!r6rs
(library (runge-kutta)
  (export integrate-system
          head tail)
  (import (rnrs base))
  <library body>)
~~~

下面描述的过程定义放入<library body>那里。

参数`system-derivative`是一个函数，其接受一个系统状态（一个代表状态变量`\(y_1, \ldots, y_n\)`的向量值）且产生系统的导函数（值`\(y_1^\prime, \ldots, y_n^\prime\)`）。参数`initial-state`提供一个初始的系统状态，以及`h`是综合系统步长的一个初始猜测。

`integrate-system`的返回值是一个无限的系统状态流。

~~~ scheme
(define integrate-system
  (lambda (system-derivative initial-state h)
    (let ((next (runge-kutta-4 system-derivative h)))
      (letrec ((states
                (cons initial-state
                      (lambda ()
                        (map-streams next states)))))
        states))))
~~~

`runge-kutta-4`过程接受一个函数，`h`，其从一个系统状态产生一个系统积分。`runge-kutta-4`过程产生一个接受系统状态并产生一个新的系统状态的过程。

~~~ scheme
(define runge-kutta-4
  (lambda (f h)
    (let ((*h (scale-vector h))
          (*2 (scale-vector 2))
          (*1/2 (scale-vector (/ 1 2)))
          (*1/6 (scale-vector (/ 1 6))))
      (lambda (y)
        ;; y is a system state
        (let* ((k0 (*h (f y)))
               (k1 (*h (f (add-vectors y (*1/2 k0)))))
               (k2 (*h (f (add-vectors y (*1/2 k1)))))
               (k3 (*h (f (add-vectors y k2)))))
          (add-vectors y
            (*1/6 (add-vectors k0
                               (*2 k1)
                               (*2 k2)
                               k3))))))))

(define elementwise
  (lambda (f)
    (lambda vectors
      (generate-vector
        (vector-length (car vectors))
        (lambda (i)
          (apply f
                 (map (lambda (v) (vector-ref  v i))
                      vectors)))))))

(define generate-vector
  (lambda (size proc)
    (let ((ans (make-vector size)))
      (letrec ((loop
                (lambda (i)
                  (cond ((= i size) ans)
                        (else
                         (vector-set! ans i (proc i))
                         (loop (+ i 1)))))))
        (loop 0)))))

(define add-vectors (elementwise +))

(define scale-vector
  (lambda (s)
    (elementwise (lambda (x) (* x s)))))
~~~

`map-streams`过程和`map`类似：它将其第一个参数（一个过程）应用到其第二个参数（一个流）的所有元素上面。

~~~ scheme
(define map-streams
  (lambda (f s)
    (cons (f (head s))
          (lambda () (map-streams f (tail s))))))
~~~

无限流以点对的方式实现，其car保存流的第一个元素，其cdr交付一个产生流的其余部分的过程。

~~~ scheme
(define head car)
(define tail
  (lambda (stream) ((cdr stream))))
~~~

下列的程序展示了在对系统

$$ C {dv_C \over dt} = -i_L - {v_C \over R}$$

$$ L {di_L \over dt} = v_C$$

进行积分时使用`integrate-system`，此系统模拟了一个阻尼振荡器。

~~~ scheme
#!r6rs
(import (rnrs base)
        (rnrs io simple)
        (runge-kutta))

(define damped-oscillator
  (lambda (R L C)
    (lambda (state)
      (let ((Vc (vector-ref state 0))
            (Il (vector-ref state 1)))
        (vector (- 0 (+ (/ Vc (* R C)) (/ Il C)))
                (/ Vc L))))))

(define the-states
  (integrate-system
     (damped-oscillator 10000 1000 .001)
     '#(1 0)
     .01))

(letrec ((loop (lambda (s)
                 (newline)
                 (write (head s))
                 (loop (tail s)))))
  (loop the-states))

; （根据勘误表添加。）
(close-output-port (current-output-port))
~~~

其会像下面一样打印输出：

~~~ scheme
#(1 0)
#(0.99895054 9.994835e-6)
#(0.99780226 1.9978681e-5)
#(0.9965554 2.9950552e-5)
#(0.9952102 3.990946e-5)
#(0.99376684 4.985443e-5)
#(0.99222565 5.9784474e-5)
#(0.9905868 6.969862e-5)
#(0.9888506 7.9595884e-5)
#(0.9870173 8.94753e-5)
~~~

<!--
  勘误：D
  TEMPLATE:
`\(\)`
`\(\texttt{}\)`
更改所有的note
{:refdef .note}
*注意：*
{: refdef}


/r6rs-translation-experience/
  TODO：将逗号由中文改为英文
    改x$_1$为$x_1$

`减少'翻译成`消去`

为所有的caption加上id

-->
