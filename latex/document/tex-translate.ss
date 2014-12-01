(module tex-translate mzscheme
  (require (lib "plt-match.ss")
           (lib "pretty.ss")
           (lib "list.ss")
           (lib "etc.ss")
           (lib "string.ss"))
  
  (define-syntax (fmatch stx)
    (syntax-case stx ()
      [(_ arg a b c ...)
       (identifier? (syntax arg))
       (syntax
	(let ([f (lambda () (fmatch arg b c ...))])
	  (match arg
	    a
	    [else (f)])))]
      [(_ arg a)
       (syntax (match arg a))]))
  
  (define filename-prefix "r6-fig")
  
  (define latex-negation "\\ensuremath{\\neg}")
  
  (define (translate file)
    (let ((r (with-input-from-file file read)))
      (initialize-metafunctions/matches r)
      (tex-translate r)))
  
  (define nonterminals-break-before
    '(P var pp sym p* p v
        E F PG S))
  
  (define flatten-args-metafunctions '(Var-set!d? circular? Trim))
  
  (define otherwise-metafunctions '(pRe poSt Trim reachable))
  
  (define combine-metafunction-names '((Trim pRe poSt) (Qtoc Qtoic)))
  
  (define metafunctions-to-skip '(r6rs-subst-one r6rs-subst-many))

  (define relation-as-metafunction '(Var-set!d? circular?))
  
  (define two-line-metafunctions '(observable))
  
  (define (side-condition-below? x)
    (member x '("6appN!" "6refu" "6setu" "6xref" "6xset" 
                         "6letrec" "6letrec*"
                         "6applyc" "6applyce")))
  
  (define (two-line-name? x) (not (one-line-name? x)))
  
  (define (one-line-name? x)
    (memq x '(Eqv--and--equivalence
              Underspecification
              Basic--syntactic--forms
              Arithmetic)))
  
  ;; tex-translate : sexp -> void
  (define (tex-translate exp)
    (let ([names/clauses combine-metafunction-names])
      (let loop ([exp exp])
        (fmatch exp
                [`(module ,_ ,_ ,body ...)
                 (for-each loop body)]
                [`(define ,lang (language ,productions ...))
                 (print-language productions)]
                [`(metafunction-type ,name ,type)
                 (unless (member name metafunctions-to-skip) 
                   (set! metafunction-types (cons (list name type) metafunction-types)))]
                [`(define-metafunction ,name ,lang ,clauses ...)
                 (unless (member name metafunctions-to-skip) 
                   (let ([in (ormap (λ (x) (member name x)) names/clauses)])
                     (if in
                         (set! names/clauses (replace-in-list name names/clauses (list name clauses)))
                         (print-metafunction name clauses))))]
                [`(define ,name (reduction-relation ,lang ,r ...))
                 (print-reductions name r (one-line-name? name))]
                [else (void)]))
      (for-each print-metafunctions names/clauses)))
  
  (define (replace-in-list sym lst new-thing)
    (map (λ (l)
           (map (λ (s) (if (eq? sym s)
                           new-thing
                           s))
                l))
         lst))

  (define (print-language productions)
    (let loop ([productions productions]
               [acc null])
      (cond
        [(equal? (car (car productions)) 'P)
         (print-partial-language (format "~a-grammar-parti.tex" filename-prefix) (reverse acc))
         (print-partial-language (format "~a-grammar-partii.tex" filename-prefix) productions)]
        [else
         (loop (cdr productions)
               (cons (car productions) acc))])))
  
  (define (print-partial-language n productions)
    (fprintf (current-error-port) "Writing file ~a ...\n" n)
    (with-output-to-file n
      (lambda ()
        (display "\\begin{center}\n")
        (display "\\begin{displaymath}\n")
        (display "\\begin{array}{lr@{}ll}\n")
        (for-each typeset-production productions)
        (display "\\end{array}\n")
        (display "\\end{displaymath}\n")
        (display "\\end{center}\n"))
      'truncate))
  
  (define (check r)
    (let ((v (ormap (lambda (l) (if (and (list? l) (andmap string? l))
                                    #f
                                    l))
                    r)))
      (when v
        (error 'check "not a list of strings: ~s" v))
      r))
  
  (define current-filename #f)
  
  (define (print-something reduction-translate name reductions start end)
    (let ((n (format "~a-~a.tex" filename-prefix (regexp-replace* #rx"[?*]" (format "~a" name) "_"))))
      (fprintf (current-error-port) "Writing file ~a ...\n" n)
      (set! current-filename name)
      (with-output-to-file n
        (lambda () 
          (let* ([rules (check (map/last reduction-translate reductions))]
                 [reductions (apply append rules)])
            (printf "~a\n" start)
            (for-each display reductions)
            (printf "~a\n" end)))
        'truncate)
      (set! current-filename #f)))
  
  (define (map/last f lst)
    (let loop ([lst lst])
      (cond
        [(null? lst) '()]
        [(null? (cdr lst)) (list (f (car lst) #t))]
        [else (cons (f (car lst) #f) (loop (cdr lst)))])))
  
  (define (print-reductions name reductions left-right?)
    (print-something (lambda (r last-one?) (reduction-translate r left-right?))
                     name
                     reductions
                     "\\begin{displaymath}\n\\begin{array}{l@{}l@{}lr}"
                     "\\end{array}\n\\end{displaymath}"))
  
  (define (reduction-translate r left-right?)
    (fmatch r
      ;; normal rules
      [`(--> ,lhs ,rhs ,name ,extras ...)
        (print-->reduction lhs rhs name left-right? (extras->side-conditions extras))]
      [`(/-> ,lhs ,rhs ,name , extras ...)
        (print/->reduction lhs rhs name left-right? (extras->side-conditions extras))]
      [`where
       ;; skip where
       '()]
      [`((/-> ,a ,b) ,c)
        ;; skip defn of /->
        '()] 
      [_ 
       (fprintf (current-error-port) "WARNING: reduction translate on wrong thing ~s\n" r)
       '()]))
  
  (define (extras->side-conditions extras)
    (let loop ([extras extras])
      (cond
        [(null? extras) null]
        [else 
         (match (car extras)
           [`(fresh ((,(? symbol? var) ,'...)
                     (,(? symbol?) ,'...)))
            (append (format-side-cond `(fresh ,var ...)) (loop (cdr extras)))]
           [`(fresh ((,(? symbol? var) ,'...)
                     (,(? symbol?) ,'...)
                     ,whatever))
            (append (format-side-cond `(fresh ,var ...)) (loop (cdr extras)))]
           [`(fresh (,(? symbol? var) ,whatever))
            (append (format-side-cond `(fresh (,var))) (loop (cdr extras)))]
           [`(fresh ,(? symbol? vars) ...)
             (append (format-side-cond `(fresh ,vars)) (loop (cdr extras)))]
           [`(side-condition ,sc ...)
             (append (apply append (map format-side-cond sc))
                     (loop (cdr extras)))]
           [else
            (error 'extras->side-conditions "unknown extra ~s" (car extras))])])))
             
                 
 
  ;; ============================================================
  ;; METAFUNCTION PRINTING
  ;; ============================================================
  
  (define metafunction-names '())
  (define metafunction-types '())
  
  (define (metafunction-name? x) (memq x metafunction-names))
  (define (translate-mf-name name)
    (case name
      [(Qtoc) "\\mathscr{Q}_{i}"]
      [(Qtoic) "\\mathscr{Q}_{m}"]
      [(A_0) "\\mathscr{A}_{0}"]
      [(A_1) "\\mathscr{A}_{1}"]
      [(observable-value) "\\mathscr{O}_{v}"]
      [else
       (let ([char
              (let loop ([chars (string->list (format "~a" name))])
                (cond
                  [(null? chars) (char-upcase (car (string->list (format "~a" name))))]
                  [else
                   (if (char-upper-case? (car chars))
                       (car chars)
                       (loop (cdr chars)))]))])
         (format "\\mathscr{~a}" char))]))
  
  (define test-matches '())
  
  (define (initialize-metafunctions/matches exp)
    (fmatch exp
      [`(module ,_ ,_ ,body ...)
        (for-each 
         (lambda (x)
           (fmatch x
             [`(define-metafunction ,name ,lang ,clauses ...)
               (set! metafunction-names (cons name metafunction-names))]
             [`(define ,name (test-match ,lang ,pat))
               (set! test-matches (cons (list name pat) test-matches))]
             [else (void)]))
         body)]))
  
  (define (print-metafunction name clauses)
    (let ([flatten-lhs? (memq name flatten-args-metafunctions)])
      (cond
        [(memq name two-line-metafunctions)
         (print-something
          (lambda (x last-one?) 
            (match x
              [`(,left ,right) 
               (p-twoline-case name 
                               left
                               right 
                               (and last-one? (memq name otherwise-metafunctions)))]
              [else (error 'print-metafunction "mismatch ~s" x)]))
          name
          clauses
          (string-append
           "\\begin{displaymath}\n\\begin{array}{l@{}l}\n"
           (metafunction-type-line name 2))
          "\\end{array}\n\\end{displaymath}")]
        [(memq name relation-as-metafunction)
         (print-something
          (lambda (x last-one?) 
            (match x
              [`(,left #f) 
               ;; a relation skips those!
               (list)]
              
              [`(,left #t)
               (p-rel-case name 
                           left
                           #f
                           #f
                           flatten-lhs?)]
              [`(,left ,right) 
               (p-rel-case name 
                           left
                           right 
                           #f
                           flatten-lhs?)]
              [`(,left #t (side-condition ,sc))
               (p-rel-case name 
                           left
                           #f
                           sc
                           flatten-lhs?)]
              [`(,left ,right (side-condition ,sc))
               (p-rel-case name 
                           left
                           right
                           sc
                           flatten-lhs?)]
              [else (error 'print-metafunction "mismatch ~s" x)]))
          name
          clauses
          (string-append
           "\\begin{displaymath}\n\\begin{array}{lc@{~}l}\n"
           (metafunction-type-line name 3))
          "\\end{array}\n\\end{displaymath}")]
        [else
         (print-something 
          (cond
            [flatten-lhs?
             (lambda (x last-one?) 
               (match x
                 [`(,left ,right) 
                  (p-flatten-case name 
                                  left
                                  right 
                                  (and last-one? (memq name otherwise-metafunctions)))]
                 [else (error 'print-metafunction "mismatch ~s" x)]))]
            [else
             (lambda (x last-one?) 
               (match x
                 [`(,left ,right) 
                  (p-case name left right 
                          (and last-one? (memq name otherwise-metafunctions)))]
                 [else (error 'print-metafunction "mismatch ~s" x)]))])
          name
          clauses
          (string-append
           "\\begin{displaymath}\n\\begin{array}{lcl}\n"
           (metafunction-type-line name 3))
          "\\end{array}\n\\end{displaymath}")])))
  
  (define (print-metafunctions names/clauses)
    (let ([names/spread-out
           (apply
            append
            (map (lambda (name/clauses)
                   (if (eq? 'blank name/clauses)
                       (list 'blank)
                       (let ([name (car name/clauses)])
                         (cons 
                          name
                          (map/last (lambda (clause last-one?) (list name clause last-one?))
                                    (cadr name/clauses))))))
                 (add-between 'blank names/clauses)))])
      (print-something (lambda (name/clause really-the-last-one?) 
                         (cond
                           [(eq? name/clause 'blank)
                            (list "\\\\")]
                           [(symbol? name/clause)
                            (list (metafunction-type-line name/clause 3))]
                           [else
                            (let ([name (list-ref name/clause 0)]
                                  [clause (list-ref name/clause 1)]
                                  [last-one? (list-ref name/clause 2)])
                              (fmatch clause
                                      [`(,left ,right) 
                                       (if (memq name flatten-args-metafunctions)
                                           (p-flatten-case name
                                                           left
                                                           right
                                                           (and last-one? (memq name otherwise-metafunctions)))
                                           (p-case name left right
                                                   (and last-one? (memq name otherwise-metafunctions))))]
                                      [else (error 'print-metafunctions "mismatch ~s" name)]))]))
                       (apply string-append (map symbol->string (map car names/clauses)))
                       names/spread-out
                       "\\begin{displaymath}\n\\begin{array}{lcl}"
                       "\\end{array}\n\\end{displaymath}")))
  
  (define (metafunction-type-line name cols)
    (let ([type-pr (assoc name metafunction-types)])
      (unless type-pr 
        (error 'metafunction-type "cannot find type for ~s" name))
      (let ([type (cadr type-pr)])
        (cond
          [(eq? (car type) '->)
           (let* ([doms (cdr (all-but-last type))]
                  [rng (car (last-pair type))])
             (format "\\multicolumn{~a}{l}{~a : ~a \\rightarrow ~a}\\\\" 
                     cols
                     (translate-mf-name name)
                     (apply string-append (add-between " \\times " (map format-nonterm doms)))
                     (format-nonterm rng)))]
          [else
           (format "\\multicolumn{~a}{l}{~a \\in 2^{~a}}\\\\" 
                   cols
                   (translate-mf-name name)
                   (apply string-append (add-between " \\times " (map format-nonterm type))))]))))
  
  (define (add-between x lst)
    (cond
      [(null? lst) null]
      [else (let loop ([fst (car lst)]
                       [next (cdr lst)])
              (cond
                [(null? next) (list fst)]
                [else (list* fst x (loop (car next) (cdr next)))]))]))
  
  (define (p-flatten-case name lhs rhs show-otherwise?)
    (let ([ls (map (λ (x) (let-values ([(a b) (pattern->tex x)])
                            (unless (null? b)
                              (error 'p-flatten-case "found side conditions, but don't support them here"))
                            a))
                   lhs)])
      (let-values ([(r cl) (pattern->tex rhs)])
        (let ([side-conditions
               (if (null? cl)
                   #f
                   (format "(~a)" (string-join cl ", ")))])
          (list 
           (cond
             [side-conditions
              (format
               "~a \\llbracket ~a \\rrbracket & = &\n~a \\\\\n\\multicolumn{3}{l}{\\hbox to .2in{} ~a}\\\\\n"
               (translate-mf-name name)
               (apply string-append (add-between ", " (map (λ (l) (inline-tex l #f)) ls)))
               (inline-tex r #f)
               side-conditions)]
             [else
              (format
               "~a \\llbracket ~a \\rrbracket & = &\n~a ~a\\\\\n"
               (translate-mf-name name)
               (apply string-append (add-between ", " (map (λ (l) (inline-tex l #f)) ls)))
               (inline-tex r #f)
               (if show-otherwise?
                   "~ ~ ~ ~ ~ ~ ~ \\mbox{\\textrm{(otherwise)}}"
                   ""))]))))))
  
  (define (p-case name lhs rhs show-otherwise?)
    (let*-values ([(l l-cl) (pattern->tex lhs)]
                  [(r r-cl) (pattern->tex rhs)])
      (let* ([cl (append l-cl r-cl)]
             [side-conditions
              (if (null? cl)
                  #f
                  (format "(~a)" (string-join cl ", ")))])
        (list 
         (cond
           [side-conditions
            (format
             "~a \\llbracket ~a \\rrbracket & = &\n~a \\\\\n\\multicolumn{3}{l}{\\hbox to .2in{} ~a}\\\\\n"
             (translate-mf-name name)
             (inline-tex l #f)
             (inline-tex r #f)
             side-conditions)]
           [else
            (format
             "~a \\llbracket ~a \\rrbracket & = &\n~a ~a\\\\\n"
             (translate-mf-name name)
             (inline-tex l #f)
             (inline-tex r #f)
             (if show-otherwise?
                 "~ ~ ~ ~ ~ ~ ~ \\mbox{\\textrm{(otherwise)}}"
                 ""))])))))
  
  (define (p-rel-case name lhs rhs side-condition flatten-lhs?)
    (let*-values ([(l) (map (λ (x) (let-values ([(a b) (pattern->tex x)]) 
                                     (unless (null? b)
                                       (error 'p-rel-case "found side conditions, but don't support them here"))
                                     a))
                            (if flatten-lhs?
                                lhs
                                (list lhs)))]
                  [(r r-cl) (pattern->tex rhs)])
      (unless (null? r-cl)
        (error 'p-rel-case "don't use side-conditions in patterns for metafunction-as-relations"))
      (let ([side-cond-tex
             (and side-condition 
                  (apply string-append
                         (add-between
                          "\\textrm{~and~}"
                          (format-side-cond side-condition))))]
            [l-tex (apply string-append (add-between ", " (map (λ (x) (inline-tex x #f)) l)))])
        (list 
         (cond
           [(and side-cond-tex rhs)
            (format
             "~a \\llbracket ~a \\rrbracket & \\textrm{if} &\n~a \\textrm{~~and~~} ~a\\\\\n"
             (translate-mf-name name)
             l-tex
             (inline-tex r #f)
             side-cond-tex)]
           [side-cond-tex
            (format
             "~a \\llbracket ~a \\rrbracket & \\textrm{if} &\n~a\\\\\n"
             (translate-mf-name name)
             l-tex
             side-cond-tex)]
           [rhs
            (format
             "~a \\llbracket ~a \\rrbracket & \\textrm{if} &\n~a\\\\\n"
             (translate-mf-name name)
             l-tex
             (inline-tex r #f))]
           [else
            (format
             "~a \\llbracket ~a \\rrbracket \\\\\n"
             (translate-mf-name name)
             l-tex)])))))
  
  (define (p-twoline-case name lhs rhs show-otherwise?)
    (let*-values ([(l l-cl) (pattern->tex lhs)]
                  [(r r-cl) (pattern->tex rhs)])
      (let* ([cl (append l-cl r-cl)]
             [side-conditions
              (if (null? cl)
                  #f
                  (format "(~a)" (string-join cl ", ")))])
        (list 
         (cond
           [side-conditions
            (format
             "~a \\llbracket & ~a \\rrbracket = \\\\ \n& ~a \\\\\n\\multicolumn{2}{l}{\\hbox to .2in{} ~a}\\extrasptermn"
             (translate-mf-name name)
             (inline-tex l #f)
             (inline-tex r #f)
             side-conditions)]
           [else
            (format
             "~a \\llbracket & ~a \\rrbracket = \\\\ \n& ~a ~a\\extraspterm\n"
             (translate-mf-name name)
             (inline-tex l #f)
             (inline-tex r #f)
             (if show-otherwise?
                 "~ ~ ~ ~ ~ ~ ~ \\mbox{\\textrm{(otherwise)}}"
                 ""))])))))
  
  (define TEX-NEWLINE "\\\\\n")
  ;; ============================================================
  ;; LANGUAGE NONTERMINAL PRINTING
  ;; ============================================================
  
  (define (prod->string p)
    (fmatch p
      [`(hole multi)             "\\holes"]
      [`(hole single)            "\\holeone"]
      [`(error string)           (format "\\textbf{error: } \\textit{error message}")]
      [`(unknown string)           (format "\\textbf{unknown: } \\textit{description}")]
      [`(uncaught-exception v)           (format "\\textbf{uncaught exception: } \\nt{v}")]
      [_                         (do-pretty-format p)]))
  
  (define (show-rewritten-nt lhs str) (display (string-append lhs " " str " " TEX-NEWLINE)))
  
  (define (typeset-production p)
    (let* ([nonterm    (car p)]
           [lhs        (format "~a & ::=~~~~ & " (format-nonterm nonterm))])
      
      (when (memq nonterm nonterminals-break-before)
        (display TEX-NEWLINE))
      
      (case nonterm        
        [(ip) (show-rewritten-nt lhs "\\textrm{[immutable pair pointers]}")]
        [(mp) (show-rewritten-nt lhs "\\textrm{[mutable pair pointers]}")]
        [(sym) (show-rewritten-nt lhs "\\textrm{[variables except \\sy{dot}]}")]
        [(x)  (show-rewritten-nt lhs "\\textrm{[variables except \\sy{dot} and keywords]}")]
        [(n)  (show-rewritten-nt lhs "\\textrm{[numbers]}")]
        
        [else
         (let ([max-line-length
                (case nonterm
                  [(e) 60]
                  [(es) 65]
                  [(a*) 90]
                  [(S) 75]
                  [(U) 90]
                  [else 70])])
           (printf "~a & ::=~~~~& " (format-nonterm nonterm))
           (let loop ([prods (map prod->string (cdr p))]
                      [sizes (map prod->size (cdr p))]
                      [line-length 0]
                      [needs-bar-before #f]
                      [beginning-of-line? #t])
             (cond
               [(null? prods)
                (display "\\\\\n")]
               [else
                (let ([first (car prods)]
                      [new-length (+ (car sizes) line-length)])
                  (cond
                    [(or (<= new-length max-line-length)
                         (and (not (<= new-length max-line-length))
                              beginning-of-line?))
                     (when needs-bar-before
                       (display "~~\\mid~~"))
                     (display (car prods))
                     (loop (cdr prods)
                           (cdr sizes)
                           (+ (car sizes) line-length)
                           #t
                           #f)]
                    [else
                     (printf "\\\\\n")
                     (display "&\\mid~~~~&\n")
                     (loop prods sizes 0 #f #t)]))])))])))
  
  (define (prod->size p) (string-length (format "~s" p)))
  
  ;; ============================================================
  ;; REDUCTION RULE PRINTING
  ;; ============================================================
  
  (define (count-lines str)
    (add1 (length (regexp-match* "\n." str))))
  
  (define (p-rule arrow lwrap rwrap)
    (opt-lambda (lhs rhs raw-name left-right? [extra-side-conditions '()])
      (record-index-entries raw-name lhs)
      ;(record-index-entries raw-name rhs) ;; right-hand side has too much junk. Only index left-hand side stuff
      (let*-values ([(l l-cl) (pattern->tex* (lwrap lhs) left-right?)]
                    [(r r-cl) (pattern->tex* (rwrap rhs) left-right?)])
        (let* ([arrow-tex 
		(case arrow
                  ((-->) "\\rightarrow")
                  ((*->) "\\ovserset{\\rightarrow}{\ast}"))]
               [name (format "\\rulename{~a}" (quote-tex-specials raw-name))]
               [cl (append extra-side-conditions l-cl r-cl)]
               [lbox-height (count-lines l)]
               [rbox-height (count-lines r)]
               [extra-inlined-arrow? #f]
               [side-conditions
                (if (null? cl)
                    #f
                    (format "(~a)" (string-join cl ", ")))])
          (list
           (cond
             [(and side-conditions (= 2 rbox-height))
              (let ([lines (regexp-split #rx"\n" r)])
                (format
                 "\\threelinescruleB\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n"
                 (inline-tex l extra-inlined-arrow?)
                 (list-ref lines 0)
                 (list-ref lines 1)
                 (inline-tex name #f)
                 side-conditions
                 (if extra-inlined-arrow?
                     ""
                     (inline-tex arrow-tex #f))))]
             [(= 2 rbox-height)
              (let ([lines (regexp-split #rx"\n" r)])
                (format
                 "\\threelinescruleA\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n"
                 (inline-tex l extra-inlined-arrow?)
                 (list-ref lines 0)
                 (list-ref lines 1)
                 (inline-tex name #f)
                 (if extra-inlined-arrow?
                     ""
                     (inline-tex arrow-tex #f))))]
             [(= 3 rbox-height)
              (unless side-conditions
                (error 'tex-translate "three line rules without side-conditions aren't supported"))
              (let ([lines (regexp-split #rx"\n" r)])
                (format
                 "\\fourlinescruleB\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n"
                 (inline-tex l extra-inlined-arrow?)
                 (list-ref lines 0)
                 (list-ref lines 1)
                 (list-ref lines 2)
                 (inline-tex name #f)
                 side-conditions
                 (if extra-inlined-arrow?
                     ""
                     (inline-tex arrow-tex #f))))]
             [side-conditions
              (format
               (if left-right?
                   "\\onelinescruleA\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n"
                   (if (side-condition-below? raw-name)
                       "\\twolinescruleB\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n"
                       "\\twolinescruleA\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n"))
               (inline-tex l extra-inlined-arrow?)
               (inline-tex r #f)
               (inline-tex name #f)
               side-conditions
               (if extra-inlined-arrow?
                   ""
                   (inline-tex arrow-tex #f)))]
             [else
              (format 
               (if left-right?
                   "\\onelineruleA\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n"
                   "\\twolineruleA\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n")
               (inline-tex l extra-inlined-arrow?)
               (inline-tex r #f)
               (inline-tex name #f)
               (if extra-inlined-arrow?
                   ""
                   (inline-tex arrow-tex #f)))]))))))
  
  (define (quote-tex-specials name)
    (let ([ans (regexp-replace*
		#rx"~"
		(regexp-replace*
		 #rx"μ"
		 (regexp-replace*
		  #rx"[#]"
		  name
                 "\\\\#")
		 "\\\\ensuremath{\\\\mu}")
		"\\\\~{}")])
      ; (fprintf (current-error-port) "~s -> ~s\n" name ans)
      ans))
  
  (define (inline-tex str arrow?)
    (format "~a~a" 
            str 
            (if arrow? " \\rightarrow" "")))
    
  ;; add-newlines : nat str -> str
  ;; adds Scheme newlines to a string destined for a Scheme context
  (define (add-newlines n str)
    (let ((s (open-output-string)))
      (display str s)
      (let loop ((n n))
        (cond
          [(= n 0) (void)]
          [else (display "\n--relax" s)
                (loop (sub1 n))]))
      (begin0
        (get-output-string s)
        (close-output-port s))))
    
  (define (boxstr name code n arrow?)
    (string-append
     (format "\\newsavebox{\\~a}\n" name)
     (format "\\sbox{\\~a}{%\n\\begin{schemebox}\n~a~a\\end{schemebox}}\n" 
             name
             (add-newlines n code)
             (if arrow? " \\rightarrow" ""))))
 
  (define print-->reduction
    (p-rule '--> (lambda (x) x) (lambda (x) x)))
     
  (define print/->reduction
    (p-rule '--> (lambda (x) `(in-hole* hole P_none ,x)) (lambda (x) `(in-hole* hole P_none ,x))))

  (define print*->reduction
    (p-rule '*-> (lambda (x) x) (lambda (x) x)))
  
  (pretty-print-columns 50)
  
  (define (p n) (fprintf (current-error-port) "~a\n" n))
  (pretty-print-size-hook
   (let ((ppsh (pretty-print-size-hook)))
     (lambda (item display? port)
       (fmatch item
         [(and (? symbol?) (? (lambda (x) (regexp-match "(.*)_(.*)" (symbol->string x)))))
          (let-values ([(_ name subscript) (apply values (regexp-match "(.*)_(.*)" (symbol->string item)))])
            (+ (string-length name) (string-length subscript)))]
         [`(mark ,v)
           (+ (string-length (format "~a" v)) 1)]
         [`(in-hole ,hole ,exp)
           (string-length (format-hole hole exp))]
         [`(in-hole* ,_ ,hole ,exp)
           (string-length (format-hole hole exp))]
         [(list 'comma x)
          (fprintf (current-error-port) "WARNING: found comma ~s\n" item)
          (ppsh item display? port)]
         [_ (ppsh item display? port)]))))
  
  (define (pretty-inf v port)
    (parameterize ([pretty-print-columns 'infinity])
      (pretty-print v port)))
  
  (pretty-print-print-hook
   (let ((ppph (pretty-print-print-hook)))
     (lambda (item display? port)
       (fmatch item
         [(and (? symbol?) (? (lambda (x) (regexp-match #rx"(.*)_(.*)" (symbol->string x)))))
          (let-values ([(_ name subscript) (apply values (regexp-match #rx"(.*)_(.*)" (symbol->string item)))])
            (fprintf port "~a_{~a}" name subscript))]
         [`(mark ,v) 
           (pretty-inf v port)
           (display "\\umrk" port)]
         [`(in-hole ,hole ,exp)
           (display (format-hole hole exp) port)]
         [`(in-hole* ,_ ,hole ,exp)
           (display (format-hole hole exp) port)]
         [else (ppph item display? port)]))))
  
  (define (format-hole hole exp)
    (parameterize ([pretty-print-columns 'infinity])
      (if (memq exp '(hole hole-here))
          (do-pretty-format hole)
          (string-append (do-pretty-format hole)
                         "\\["
                         (do-pretty-format exp)
                         "\\]"))))
  
  (define (do-pretty-format p)
    (let ((o (open-output-string)))
      (let loop ((p p))
        (cond
	 ((eq? '... p)
	  (display "\\cdots" o))
	 ((eqv? #t p)
	  (display "\\semtrue{}" o))
	 ((eqv? #f p)
	  (display "\\semfalse{}" o))
	 ((symbol? p)
	  (display (format-symbol p) o))
	 ((number? p)
	  (display p o))
	 ((null? p)
	  (display "\\texttt{()}" o))
	 ((string? p)
	  (display "\\textrm{``" o)
	  (display (quote-tex-specials p) o)
	  (display "''}" o))
	 ((list? p)
	  (case (car p)
	    [(hole)
             (case (list-ref p 1)
               [(multi) (display "\\holes{}" o)]
               [(single) (display "\\holeone{}" o)])]
            [(quote)
	     (display "'" o)
	     (loop (cadr p))]
            [(unquote)
             (let ([unquoted (cadr p)])
               (if (and (list? unquoted)
                        (= 3 (length unquoted))
                        (eq? (car unquoted) 'format))
                   (begin
                     (display "\\mbox{``" o)
                     (display (regexp-replace "~a" (list-ref unquoted 1) "") o)
                     (display "}" o)
                     (loop (list-ref unquoted 2))
                     (display "\\mbox{''}" o))
                   (loop unquoted)))]
            ((term)
	     (loop (cadr p)))
	    ((r6rs-subst-one)
             (let* ([args (cadr p)]
                    [var-arg (car args)]
                    [becomes-arg (cadr args)]
                    [exp-arg (caddr args)])
               (display "\\{" o)
               (loop var-arg)
               (display "\\mapsto " o)
               (loop becomes-arg)
               (display "\\}" o)
               (loop exp-arg)
               (display "" o)))
            ((r6rs-subst-many)
             (let* ([args (cadr p)]
                    [var-arg (caar args)]
                    [becomes-arg (cadar args)]
                    [dots (cadr args)]
                    [exp-arg (caddr args)])
               (unless (eq? '... dots)
                 (error 'tex-translate.ss "cannot handle use of r6rs-subst-many"))
               (display "\\{" o)
               (loop var-arg)
               (display " \\mapsto " o)
               (loop becomes-arg)
               (display "\\cdots \\}" o)
               (loop exp-arg)
               (display "" o)))
	    ((in-hole)
	     (loop (cadr p))
             (unless (memq (caddr p) '(hole hole-here))
               (display "[" o)
               (loop (caddr p))
               (display "]" o)))
            (else
	     (cond
               [(memq (car p) flatten-args-metafunctions)
                (display (translate-mf-name (car p)) o)
                (display "\\llbracket{}" o)
                (let ([lst (cadr p)])
                  (cond
                    [(null? lst) (void)]
                    [else
                     (loop (car lst))
                     (let i-loop ([lst (cdr lst)])
                       (cond
                         [(null? lst) (void)]
                         [else 
                          (display ", " o)
                          (loop (car lst))
                          (i-loop (cdr lst))]))]))
                (display "\\rrbracket" o)]
               [(metafunction-name? (car p))
                (display (translate-mf-name (car p)) o)
                (display "\\llbracket{}" o)
                (loop (cadr p))
                (display "\\rrbracket" o)]
               [else
                (display "\\texttt{(}" o)
                (loop (car p))
                (for-each (lambda (el)
                            (display "~" o)
                            (loop el))
                          (cdr p))
                (display "\\texttt{)}" o)]))))
	 ((pair? p)
	  (display "\\texttt{(}" o)
	  (loop (car p))
	  (display " \\texttt{.} " o)
	  (loop (cdr p))
	  (display "\\texttt{)}" o))))
      (close-output-port o)
      (get-output-string o)))

  (define (format-symbol op)
    (let ([command (format "\\~a" (categorize-symbol op))]
	  [o (open-output-string)])
      (parameterize ((current-output-port o))
        (d-var op command))
      (close-output-port o)
      (get-output-string o)))
  
  (define (categorize-symbol op)
    (case op
      [(language
        name subst reduction reduction/context red term apply-values store dot consi throw push pop trim dw mark condition make-cond handlers
        define beginF throw lambda set! if begin0 quote begin letrec letrec* reinit l! bh)
       'sy]
      [(cons unspecified null list dynamic-wind apply values null? pair? car cdr call/cc procedure? condition? unspecified? set-car! set-cdr! eqv? call-with-values with-exception-handler raise-continuable raise + * - /)
       'va]
      [else 'nt]))

  ;; pattern->tex : pattern -> (values string (listof string))
  ;; given a pattern, returns a string representation and some strings of side constraints
  (define (pattern->tex pat)
    (pattern->tex* pat #t))
  
  (define (pattern->tex* pat left-to-right?)
    (let ((side-conds (get-side-conditions pat))
          (s (open-output-string)))
      (parameterize ((current-output-port s))
        (pattern->tex/int pat left-to-right?)
        (values (get-output-string s) 
                (apply append (map format-side-cond side-conds))))))
  
  (define (getpatstr pat lr?)
    (let ((s (open-output-string)))
      (parameterize ((current-output-port s))
        (pattern->tex/int pat lr?)
        (close-output-port s)
        (get-output-string s))))
  
  (define (getrhsstr rhs lr?)
    (let ((s (open-output-string)))
      (parameterize ((current-output-port s))
        (rhs->tex/int rhs lr?)
        (close-output-port s)
        (get-output-string s))))
 
  ;; format-side-cond : side-condition -> (listof string[tex-code])
  (define (format-side-cond sc)
    (define (gps v) (getpatstr v #t))
    (fmatch sc
      [`(and ,@(list sc ...))
        (apply append (map format-side-cond sc))]
      [`(or ,sc ...)
       (let* ([scs (map format-side-cond sc)]
              [single-lines
               (map (λ (x) (if (null? (cdr x))
                               (car x)
                               (apply string-append (add-between " \\textrm{ and }" x))))
                    scs)])
         (let loop ([lst (cdr single-lines)]
                    [strs (list (car single-lines))])
           (cond
             [(null? lst) (list (apply string-append (reverse strs)))]
             [else (loop (cdr lst)
                         (list* (car lst) 
                                "\\textrm{ or }" 
                                strs))])))]
      [`(fresh ,xs)
        (list (format "~a \\textrm{ fresh}" (string-join (map (lambda (x) (format "~a" (gps x))) xs) ", ")))]
      [`(fresh ,(? symbol? x) ,'...)
        (list (format "~a \\cdots \\textrm{ fresh}" (gps x)))]
      [`(freshS ,xs)        
        (list (format "~a \\cdots \\textrm{ fresh}" (string-join (map (lambda (x) (format "~a" (gps x))) xs) ", ")))]
      [`(not (,(? (λ (x) (memq x '(equal? eq?)))) (term ,t1) (term ,t2)))
        (list (format "~a \\neq ~a" (gps t1) (gps t2)))]
      [`(,(? (λ (x) (memq x '(equal? eq?)))) (term ,t1) (term ,t2))
        (list (format "~a = ~a" (gps t1) (gps t2)))]
      [`(not (eq? (term ,t1) #f))
        (list (format "~a \\neq \\semfalse{}" (gps t1)))]
      [`(not (null-v? (term ,v)))
        (list (format "~a \\neq \\va{null}" (gps v)))]
      [`(not (prefixed-by? (term ,v) (quote p:)))
        (list (format "~a \\not\\in \\nt{pp}" (gps v)))]
      [`(not (condition? (term ,v)))
        (list (format "~a \\neq (\\sy{make\\mbox{\\texttt{-}}cond}~~\\nt{string})" (gps v)))]
      [`(not (lambda-null? (term ,v)))
       (list (format "~a \\neq \\texttt{(lambda}~~\\texttt{()}~~\\nt{e}\\texttt{)}" v))]
      [`(not (,(? (λ (x) 
                    (and (symbol? x) 
                         (regexp-match #rx"\\?$" (symbol->string x))))
                  sym)
              (term ,v)))
        (list (format "~a \\not\\in \\nt{~a}"
                      (gps v)
                      (regexp-replace ".$" (symbol->string sym) "")))]
      [`(= (length (term (,arg1 ,dots))) (length (term (,arg2 ,dots))))
        (list (arglen-str "=" arg1 arg2))]
      [`(not (= (length (term (,arg1 ,dots))) (length (term (,arg2 ,dots)))))
        (list (arglen-str "\\neq" arg1 arg2))]
      [`(< (length (term (,arg1 ,dots))) (length (term (,arg2 ,dots))))
        (list (arglen-str "<" arg1 arg2))]
      [`(< (length (term (,arg1 ,dots))) (length (term (,arg2 ,arg3 ,dots))))
        (list (string-append (arglen-str "<" arg1 arg3) " + 1"))]
      [`(>= (length (term (,arg1 ,dots))) (length (term (,arg2 ,dots))))
        (list (arglen-str "\\geq" arg1 arg2))]
      [`(not (= (length (term (,v ,_))) ,(? number? n)))
        (list (format "\\#~a \\neq ~a" (gps v) n))]
      [`(not (list-v? (term ,v_last)))
        (list (format "~a \\not\\in \\nt{pp}" (gps v_last))
              (format "~a \\neq \\nt{null}" (gps v_last)))]
      [`(not (memq (term ,x) (term (,xs ,_))))
        (list (format "~a \\not\\in \\{ ~a \\cdots \\}" (gps x) (gps xs)))]
      [`(not (memq (term ,x) (term (,xs ,_ ,y))))
       (list (format "~a \\not\\in \\{ ~a \\cdots ~a \\}" (gps x) (gps xs) (gps y)))]
      [`(not (memq (term ,x) (map car (term (,xs ,_)))))
        (list (format "~a \\not\\in \\dom(~a \\cdots)" (gps x) (gps xs)))]
      [`(not (defines? (term ,x) (term (,d ,'...))))
        (list (format "~a \\textrm{ not defined by } ~a \\cdots" (gps x) (gps d)))]
      [`(not (equal? (term ,v) (term ,q)))
        (list (format "~a \\neq ~a" (gps v) (gps q)))]
      [`(not (number? (term ,v)))
        (list (format "~a \\texrm{ is not a number}" (gps v)))]
      [`(not (number? ,(? symbol? exp)))
        (list (format "~a \\textrm{ is not a number}" exp))]
      [`(not (v? (term ,v)))
        (list (format "~a \\not\\in \\nt{v}" (gps v)))]
      [`(not (v? ,(? symbol? v)))
        (list (format "~a \\not\\in \\nt{v}" v))]
      [`(or (nonproc? (term ,vs)) ..2)
        (let ([v1 (car vs)]
              [vs (all-but-last (cdr vs))]
              [vn (car (last-pair vs))])
          (list (apply string-append
                       (format "~a \\in \\nt{nonproc}" (gps v1))
                       (append
                        (map (lambda (x) (format ", ~a \\in \\nt{nonproc}" (gps x)))
                             vs)
                        (list (format "\\textrm{, or} ~a \\in \\nt{nonproc}" (gps vn)))))))]
      [`(not (member 0 (term (,v1 ,vs ,'...))))
        (list (format "0\\not\\in \\{ ~a, ~a, \\ldots \\}" (gps v1) (gps vs)))]
      [`(member 0 (term (,v1 ,vs ,'...)))
        (list (format "0\\in \\{ ~a, ~a, \\ldots \\}" (gps v1) (gps vs)))]
      [`(not (ds? ,exp))
        (list (format "a \\not\\in \\nt{ds}" (getrhsstr exp #t)))]
      [`(not (es? ,exp))
        (list (format "~a \\not\\in \\nt{es}" (getrhsstr exp #t)))]
      [`(ds? ,exp)
        (list (format "~a \\in \\nt{ds}" (getrhsstr exp #t)))]
      [`(es? ,exp)
        (list (format "~a \\in \\nt{es}" (getrhsstr exp #t)))]
      [`(proc? ,exp)
        (list (format "~a \\in \\nt{proc}" (getrhsstr exp #t)))]
      [`(not (,(? (lambda (x) (assoc x test-matches)) func) (term ,t)))
       (let ([test-match (assoc func test-matches)])
         (list (format "~a \\neq ~a"
                       (gps t)
                       (gps (cadr test-match)))))]
      [`(,(? (lambda (x) (assoc x test-matches)) func) (term ,t))
       (let ([test-match (assoc func test-matches)])
         (list (format "~a = ~a"
                       (gps t)
                       (gps (cadr test-match)))))]
      
      [`(term (,(? (λ (x) (memq x flatten-args-metafunctions)) name) ,args))
       (list (format "~a \\llbracket ~a \\rrbracket"
                     (translate-mf-name name)
                     (apply string-append (add-between ", " (map gps args)))))]
      [`(not (term (,(? (λ (x) (memq x flatten-args-metafunctions)) name) ,args)))
       (list (format "~a ~a \\llbracket ~a \\rrbracket"
                     latex-negation
                     (translate-mf-name name)
                     (apply string-append (add-between ", " (map gps args)))))]
      [`(term (,(? metafunction-name? mf) ,arg))
        (list (format "~a \\llbracket ~a \\rrbracket"
                      (translate-mf-name mf)
                      (gps arg)))]
      [`(not (term (,(? metafunction-name? mf) ,arg)))
        (list (format "~a ~a \\llbracket ~a \\rrbracket"
                      latex-negation
                      (translate-mf-name mf)
                      (gps arg)))]
      [`(> (length (term (e_1 ,dots e_i e_i+1 ,dots))) 2)
        (list (format "at least three sub-expressions"))]
      [`(ormap (lambda (,x) ,e) (term (,a ...)))
        (let* ([set-content
                (apply 
                 string-append
                 (let loop ([terms a])
                   (cond
                     [(null? terms) null]
                     [else (list* (gps (car terms)) 
                                  " " 
                                  (loop (cdr terms)))])))]
               [boilerplate (format "\\exists ~a \\in ~a \\textrm{ s.t. } "
                                    x 
                                    set-content)]
               [condition (format-side-cond e)])
          (unless (null? (cdr condition))
            (error 'format-side-cond "too many condition in ~s" e))
          (list (string-append boilerplate (car condition))))]
      [_ 
       (fprintf (current-error-port) "unknown side-condition: ~s\n" sc)
       (list (format "\\verb|~s|" sc))]))
  
  (define (all-but-last l)
    (cond
      [(null? l) '()]
      [(null? (cdr l)) '()]
      [else (cons (car l) (all-but-last (cdr l)))]))
  
  (define (arglen-str op arg1 arg2)
    (format 
     "\\# ~a ~a \\# ~a"
     (getpatstr arg1 #t)
     op
     (getpatstr arg2 #t)))
  
     
  (define (get-side-conditions p)
    (fmatch p
      [`(side-condition ,pat ,cond)
        (cons cond (get-side-conditions pat))]
      [`(term-let ([,xs (variable-not-in ,_ ...)] ...)
          ,e)
        (cons `(fresh ,xs) (get-side-conditions e))]
      [`(term-let ([(,xs ,dots) (variables-not-in ,_ ...)] ...)
          ,e)
        (cons `(freshS ,xs) (get-side-conditions e))]
      [`(,e ...)
        (apply append (map get-side-conditions e))]
      [_ '()]))
 
  (define (string-join l j)
    (let loop ((l l)
               (acc '()))
      (cond
        [(null? l) (apply string-append (reverse acc))]
        [(null? (cdr l)) (loop '() (cons (car l) acc))]
        [else (loop (cdr l) (cons j (cons (car l) acc)))])))
  
  (define (holename->tex h)
    (fmatch h
      ['single "\\circ"]
      ['multi "\\star"]
      [_ ""]))
  
  (define (for-each/space f l)
    (cond
      [(null? l) (void)]
      [(null? (cdr l)) 
       (f (car l))]
      [else
       (begin (f (car l))
              (printf " ")
              (for-each/space f (cdr l)))]))
  
  (define (rhs->tex/int pat lr?)
    (define d display)
    (define (loop pat)
      (fmatch pat
        [`(reify ,str ,v) 
          (d "Rcal \\llbracket")
          (loop str)
          (d ", ")
          (loop v)
          (d " \\rbracket")] ;; watch out! there needs to be a space before "rb" ...
        
        [`(term ,p) (pattern->tex/int p lr?)]
        [`(term-let ,stuff ,pat) (loop pat)]
        [`(,(? (lambda (x) (memq x '(product-of sum-of - / + *)))) ,@(list x ...)) (arith-exp->tex/int pat)]
        [`(trim ,a ,b)
          (d "TRIM$($")
          (loop a)
          (d " , ")
          (loop b)
          (d "$)$")]
        [`(or ,arg1 ,args ...)
          (loop arg1)
          (for-each
           (lambda (x) 
             (d "\\textrm{ or }")
             (loop x))
           args)]
        
        [`(,(? (λ (x) (memq x flatten-args-metafunctions)) name) ,arg)
         (error 'flatten-args-metafunction "1")]
        [`(,(? metafunction-name? mf) ,arg)
         (d (translate-mf-name mf))
         (d " \\llbracket{}")
         (loop arg)
         (d " \\rrbracket{}")]
        [`(format "context expected one value, received ~a" (length ,arg))
          (d "``context expected one value, received #")
          (loop arg)
          (d "''")]
        [`(format ,str (+ (length (term (,v ,'...))) 1))
          (d "``")
          (d (regexp-replace #rx"~a" str "# "))
          (pattern->tex/int v lr?)
          (printf "+1")
          (d "''")]
        [`(format ,str ,next-arg)
          (let ([m (regexp-match #rx"^([^:]*):" str)])
            (unless m 
              (error 'pattern->tex/int "error regexp match failed ~s" str))
            (printf "``~a " (quote-tex-specials (cadr m)))
            (rhs->tex/int next-arg lr?)
            (d "''"))]
        [_ (error 'rhs->tex/int "unknown rhs: ~s\n" pat)]))

    (loop pat))
  
  (define (arith-exp->tex/int pat)
    (define d display)
    (d " \\gopen~")
    (let loop ([pat pat])
      (fmatch pat
        [`(term ,(? symbol? a))
          (d (format "~a" a))]
        [`(,(? (lambda (x) (memq x '(sum-of product-of)))) (term (,(? symbol? fst) ,(? symbol? rst) ,'...)))
          (d (format "\\~a \\{" (if (eq? (car pat) 'sum-of)
                                      "Sigma"
                                      "Pi")))
          (d-var fst)
          (d ", ")
          (d-var rst)
          (d "\\cdots \\}")]
        [`(- (term ,(? symbol? a)))
          (d "- ")
          (d-var a)]
        [`(/ (term ,(? symbol? a)))
          (d "1 / ")
          (d-var a)]
        [`(,(? (lambda (x) (memq x '(+ * - /))))  ,arg1 ,args ...)
          (loop arg1)
          (for-each (lambda (arg) 
                      (d " ")
                      (d (car pat))
                      (d " ")
                      (loop arg))
                    args)]
        [else (error 'arith-exp->tex/int "unknown pattern ~s" pat)]))
    (d "~\\gclose "))
    
  (define (pattern->tex/int orig-pat lr?)
    (define d display)
    (define (loop-eles lst)
      (cond
        [(null? (cdr lst)) (loop (car lst))]
        [else (loop (car lst))
              (d " ")
              (loop-eles (cdr lst))]))
    (define (loop pat)
      (fmatch pat
        
        [(list 'unquote e) (rhs->tex/int e lr?)]
        [(list 'quote (? (λ (x) (and (symbol? x) (eq? 'nt (categorize-symbol x)))) s))
         (d "\\sy{'}") (d s)]
        [(list 'quote e)
         (d "\\sy{'") (d (format "~s" e)) (d "}")]
        [(list 'unquote-splicing expr) (rhs->tex/int expr lr?)]

        [`(store (,sf1 ,sf2 ,sf3 ,sf4 (ri #f) ,sf6) (in-hole ,e ((lambda ,bodies ...) ,args ...)))
         (let ([store `(,sf1 ,sf2 ,sf3 ,sf4 (ri #f) ,sf6)]
               [func `(lambda ,@bodies)])
           (d "\\texttt{(}\\sy{store}~") (loop store) (d "\n")
           (d "~~~") (loop e) (d "[\\texttt{(}") (loop func) (d "\n")
           (d "~~~\\hphantom{") (loop e) (d "[\\texttt{(}}") (loop-eles args) (d "\\texttt{)])}"))]
        
        [`(in-hole ,p (handlers ,h1 ,h2 ,h3 (in-hole ,g (handlers ,h1 ,h2 (begin ,begin-args ...)))))
         (let ([snd-line `(in-hole ,g (handlers ,h1 ,h2 (begin ,@begin-args)))]
               [first-line-prefix
                (λ () 
                  (loop p) 
                  (d "[\\texttt{(}"))])
           (first-line-prefix) (loop 'handlers) (d "~") (loop h1) (d "~") (loop h2) (d "~") (loop h3) 
           (d "\n")
           
           (d "\\hphantom{") 
           (first-line-prefix)
           (d "}")
           (loop snd-line)
           (d "\\texttt{)}]"))]
        
        [`(term ,p) (error 'pattern->tex/int "found term inside a pattern ~s, ~s" orig-pat p)]
        [`(side-condition ,p ,_) (loop p)]
        [`(name ,_ ,p) (loop p)]
        [`(in-hole ,hole ,exp)
          (begin (loop hole) 
                 (unless (memq exp '(hole hole-here))
                   (d "[")
                   (loop exp)
                   (d "]")))]
        [`(in-hole* ,_ ,hole ,exp) 
          (begin (loop hole) (d "[") (loop exp) (d "]"))]
        [`(in-named-hole ,holename ,context ,exp)
          (loop `(in-hole ,context ,exp)) (d (format "_{~a}" (holename->tex holename)))]
        [`(uncaught-exception ,e)
          (printf "\\textbf{uncaught exception: }")
          (loop e)]
        [`(unknown (,uq (format ,str (length (term (,v ,'...))))))
          (printf "\\mbox{\\textbf{unknown: }")
          (printf (regexp-replace #rx"~a" str "\\\\#"))
          (printf "}")
          (loop v)]
        [`(unknown string)
         (printf "\\textbf{unknown: } \\textit{description}")]
        [`(,(? (lambda (x) (memq x '(unknown error))) lab) ,s)
          (printf "\\mbox{\\textbf{~a:} ~a}" lab (quote-tex-specials s))]
        [`(,(or 'r6rs-subst-many 'r6rs-subst-one) ,arg)
         (d (do-pretty-format pat))]
        [`(,(? (λ (x) (memq x flatten-args-metafunctions)) name) (,arg1 ,args ...))
         (d (translate-mf-name name))
         (d " \\llbracket{}")
         (loop arg1)
         (for-each (λ (arg)
                     (d ", ")
                     (loop arg))
                   args)
         (d " \\rrbracket ")]
        [`(,(? metafunction-name? mf) ,arg)
         (d (translate-mf-name mf))
         (d " \\llbracket{}")
         (loop arg)
         (d " \\rrbracket ")]
        ['x_1 (d "x_1")]
        ['x_2 (d "x_2")]
        ['ptr_1 (d "\\nt{ptr}_i")]
        ['ptr_i+1 (d "\\nt{ptr}_{i+1}")]
        ['sv_1 (d "\\nt{sv}_1")]
        ['sv_i+1 (d "\\nt{sv}_{i+1}")]
        ['mp_i (d "\\nt{mp}_i")]
        ['cp_i (d "\\nt{cp}_i")]
        ['cp_1 (d "\\nt{cp}_1")]
        ['cp_2 (d "\\nt{cp}_2")]
        ['cp_3 (d "\\nt{cp}_3")]
        ['pp_i (d "\\nt{pp}_i")]
        ['v_1 (d "v_1")]
        ['v_2 (d "v_2")]
        ['v_car (d "v_{\\nt{car}}")]
        ['v_cdr (d "v_{\\nt{cdr}}")]
        [_ 
	 (d (do-pretty-format pat))]))

    (loop orig-pat))

  (define (flatten-loop loop bodies)
    (cond
      [(null? bodies) (void)]
      [(null? (cdr bodies)) (loop (car bodies))]
      [else 
       (loop (car bodies))
       (display " ")
       (flatten-loop loop (cdr bodies))]))

  (define (format-nonterm n)
    (case n
      [(p*) "\\mathcal{P}"]
      [(a*) "\\mathcal{A}"]
      [(r*) "\\mathcal{R}"]
      [(r*v) "\\ensuremath{\\mathcal{R}_v}"]
      [else
       (do-pretty-format n)]))

  ;; #### merge with format-symbol
  (define d-var
    (opt-lambda (x (command "\\nt"))
      (case x
	[(beginF)
	 (display "\\beginF")]
	[(Eo)
	 (display "\\Eo")]
	[(E*)
	 (display "\\Estar")]
	[(Fo)
	 (display "\\Fo")]
	[(F*)
	 (display "\\Fstar")]
	[(Io)
	 (display "\\Io")]
	[(I*)
	 (display "\\Istar")]
        [(hole)
	 (display "\\hole")]
        [(hole-here)
	 (display "\\hole")]
        [(exception) (display "\\sy{exception}")]
        [(unknown) (display "\\sy{unknown}")]
        [(procedure) (display "\\sy{procedure}")]
        [(pair) (display "\\sy{pair}")]
        [(r*v) (display (format-nonterm 'r*v))]
        ['x_1 (display "x_1")]
	['x_2 (display "x_2")]
	['ptr_1 (display "\\nt{ptr}_i")]
	['ptr_i+1 (display "\\nt{ptr}_{i+1}")]
	['sv_1 (display "\\nt{sv}_1")]
	['sv_i+1 (display "\\nt{sv}_{i+1}")]
	['mp_i (display "\\nt{mp}_i")]
	['cp_i (display "\\nt{cp}_i")]
	['cp_1 (display "\\nt{cp}_1")]
	['cp_2 (display "\\nt{cp}_2")]
	['cp_3 (display "\\nt{cp}_3")]
	['pp_i (display "\\nt{pp}_i")]
	['v_1 (display "v_1")]
	['v_2 (display "v_2")]
	['v_car (display "v_{\\nt{car}}")]
	['v_cdr (display "v_{\\nt{cdr}}")]
	[else
	 (let ([str (regexp-replace* #rx"[-*/+?!]"
                                     (symbol->string x)
                                     "\\\\mbox{\\\\texttt{\\0}}")])
	   (cond
             [(regexp-match #rx"^([^_]*)_none$" str)
              =>
              (lambda (m)
                (let ([name (cadr m)])
                  (printf "~a{~a}" command name)))]
             [(regexp-match #rx"^([^_]*)_([^_]*)$" str)
              =>
              (lambda (m)
                (let-values ([(_ name subscript) (apply values m)])
                  (printf "~a{~a}_{~a}" command name subscript)))]
             [else 
              (printf "~a{~a}" command str)]))])))
  
  (define only-once-ht (make-hash-table))
  (define (only-once x exp)
    (let/ec k
      (let ([last-time (hash-table-get only-once-ht
                                       x 
                                       (lambda () 
                                         (hash-table-put! only-once-ht x exp)
                                         (k (void))))])
        (error 'only-once "found ~s pattern twice:\n~s\n~s" last-time exp))))
  
  

  ;; ============================================================
  ;; MISC HELPERS
  ;; ============================================================

  
  (define (to-tex-symbol sym)
    (symbol->string sym))
  (define (vals->list f) (lambda (x) (call-with-values (lambda () (f x)) (lambda a a))))
  
  (define (mark tex)
    (format "~a^{\\mrk}" tex))

  ;; ============================================================
  ;; INDEX
  ;; ============================================================
  
  (define (record-index-entries raw-name term)
    (let ([table (make-hash-table 'equal)])
      (extract-names term
                     (λ (id)
                       (hash-table-put! table id #t)))
      (hash-table-for-each
       table
       (λ (id _)
         (printf "\\semanticsindex{~a}{~a}\n"
                 id
                 (quote-tex-specials raw-name))))))
  
  (define ignore-in-index '(l! make-cond reinit handlers unspecified))
  
  (define (extract-names term f)
    (define (q-loop term)
      (fmatch term
        [`(in-hole ,a ,b) (q-loop b)]
        [`(,'quote ,a) (void)]
        [`(store ,s ,exp) (q-loop exp)]
        [`(,'unquote ,e) (unq-loop exp)]
        [(? symbol?) 
         (unless (regexp-match #rx"_" (symbol->string term))
           (unless (eq? 'nt (categorize-symbol term))
             (unless (memq term ignore-in-index)
               (f term))))]
        [(? list?) (for-each q-loop term)]
        [else (void)]))
    (define (unq-loop term)
      (match term
        [`(,'term ,e) (q-loop e)]
        [(? list?) (for-each unq-loop term)]
        [else (void)]))
    
    (q-loop term))
 
  ;; ============================================================
  ;; GO
  ;; ============================================================
  
  (translate "../model/r6rs.scm"))
  