(module show-examples mzscheme
  
  (require (planet "gui.ss" ("robby" "redex.plt" 3 10))
           (planet "reduction-semantics.ss" ("robby" "redex.plt" 3 10))
           "r6rs.scm")
  (provide trace trace-expression
           step step-expression)

  
  
  ;; the number of steps to produce automatically (the GUI lets you produce more if you wish)
  (reduction-steps-cutoff 100)
  
  ;; the width of the boxes in the GUI (used when pretty-printing their contents)
  ;; defaults to 40 if unspecified
  (initial-char-width 60)
  
  ;; show : sexp -> void
  ;; shows the reduction sequence for its argument; any terms
  ;; that don't match the script p (p*) non-terminal are turned pink
  (define (trace x)
    (traces/pred lang 
                 reductions
                 (list x) 
                 (λ (x) 
                   (let ([m (tm x)])
                     (and m
                          (= 1 (length m)))))))
  (define tm (test-match lang p*))
  (define (trace-expression x) (trace `(store () ,x)))

  (define (step x) (stepper lang reductions x))
  (define (step-expression x) (step `(store () ,x)))

  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; example uses of the above functions
  ;; if any of the terms in the graph don't 
  ;;    match p*, they will be colored red
  ;; #; comments out an entire sexpression.
  ;; 
  
  #;
  (show '(store () (((lambda (x y) (set! x (+ x y)) x) 2 3))))

  ;; an infinite, tail-recursive loop
  #;
  (show-expression '((lambda (x) ((call/cc call/cc) x)) (call/cc call/cc)))

  ;; two infinite loops, one in left-to-right and one in right-to-left evaluation order
  ;; one goes into a non-tail infinite loop, the other's reduction graph has a cycle
  #;
  (step '(store () 
           ((call/cc call/cc) 
            (call/cc call/cc))))
          
  
  ;; demonstrates sharing
  #;
  (show-expression
   '((lambda (c)
       ((lambda (x y) 
          (set-car! x 3)
          (car y))
        c c))
     (cons 1 2)))
  
  (step  '(store () ((lambda (sx first-time?) ((lambda (k) (if first-time? (begin (set! first-time? #f) (with-exception-handler (lambda (x) (k values)) (lambda () (dynamic-wind + (lambda () (raise-continuable 1)) (lambda () (set! sx (+ sx 1))))))) sx)) (call/cc values))) 1 #t))))
