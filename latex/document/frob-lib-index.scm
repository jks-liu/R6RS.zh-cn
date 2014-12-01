; Create the source material for the composite index

(define (read-line port)
  (if (eof-object? (peek-char port))
      (peek-char port)
      (let loop ((revchars '()))
	(let ((thing (read-char port)))
	  (if (char=? #\newline thing)
	      (list->string (reverse revchars))
	      (loop (cons thing revchars)))))))

(define (parse-index-line line)
  (let* ((size (string-length line))
	 (end-body
	  (let loop ((i (- size 2)))
	    (if (char=? #\} (string-ref line i))
		i
		(loop (- i 1))))))
    (values (substring line ; without braces
		       (string-length "\\indexentry{")
		       end-body)
	    (substring line (+ end-body 1) size) ; with braces
	    )))

(define (munge-index-line line)
  (call-with-values
      (lambda ()
	(parse-index-line line))
    (lambda (body pagenr)
      (let* ((hyperpage "|hyperpage")
	     (hyperpage-size (string-length hyperpage))
	     (body-size (string-length body)))
	(string-append
	 "\\indexentry{"
	 (if (and (>= body-size hyperpage-size)
		  (string=? (substring body (- body-size hyperpage-size) body-size)
			    hyperpage))
	     (substring body 0 (- body-size hyperpage-size))
	     body)
	 "|libindexentry"
	 "}"
	 pagenr)))))

(define (frob-library-index infile outfile)
  (call-with-input-file infile
    (lambda (inport)
      (call-with-output-file outfile
	(lambda (outport)
	  (let loop ()
	    (let ((thing (read-line inport)))
	      (if (not (eof-object? thing))
		  (begin
		    (display (munge-index-line thing) outport)
		    (newline outport)
		    (loop))))))))))

(frob-library-index "r6rs-lib.idx" "r6rs-report-lib.idx")


		  