
; Code to extract the examples from the report.  Written for R5RS by
; Richard Kelsey.

; This prints everything in INPUT-FILE that is between a "\begin{scheme}"
; and an "\end{scheme}" to the current output port.

(define (find-examples input-file)
  (call-with-input-file input-file
    (lambda (in)
      (extract-text "\\begin{scheme}"
		    "\\end{scheme}"
		    (input-port->source in)
		    (output-port->sink (current-output-port))))))

; Turning ports into sources (thunks that generate characters) and
; sinks (procedures of one argument that consume characters).

(define (input-port->source port)
  (lambda ()
    (read-char port)))

(define (output-port->sink port)
  (lambda (char)
    (write-char char port)))

; Read characters from SOURCE, passing to SINK all characters found between
; the strings BEGIN and END.

(define (extract-text begin end source sink)
  (let loop ()
    (if (find-string begin source (lambda (char) (values)))
	(if (find-string end source sink)
	    (loop)))))

; Transfer characters from SOURCE to SINK until STRING is found.
;
; We first make a circular buffer containing the first (string-length STRING)
; characters from SOURCE.  We then compare the buffer with STRING to see if
; a match is found.  If not, we pass the first character from the buffer to
; SINK and get the next item from SOURCE.  If it's a character we put it in
; the buffer, advance the buffer one character, and continue.  When we reach
; the end of SOURCE, the remaining characters in the buffer are passed to SINK.

(define (find-string string source sink)
  (let ((buffer (make-circular-buffer (string-length string) source)))
    (let loop ((buffer buffer))
      (if (buffer-match? string buffer)
	  #t
	  (begin
	    (sink (car buffer))
	    (let ((next (source)))
	      (if (char? next)
		  (begin
		    (set-car! buffer next)
		    (loop (cdr buffer)))
		  (begin
		    (set-car! buffer #f)
		    (let flush-loop ((buffer (cdr buffer)))
		      (if (car buffer)
			  (begin
			    (sink (car buffer))
			    (flush-loop (cdr buffer)))
			  #f))))))))))

; Returns a circular list of COUNT pairs containing the first COUNT
; items from SOURCE.

(define (make-circular-buffer count source)
  (let ((start (list (source))))
    (let loop ((last start) (i 1))
      (if (= i count)
	  (begin
	    (set-cdr! last start)
	    last)
	  (let ((next (list (source))))
	    (set-cdr! last next)
	    (loop next (+ i 1)))))
    start))

; Returns #T if the contents of the BUFFER, a list of characters, matches
; STRING.  This is the same as `(string=? string (list->string buffer))'
; except that it works for circular buffers.

(define (buffer-match? string buffer)
  (let loop ((buffer buffer) (i 0))
    (cond ((= i (string-length string))
	   #t)
	  ((char=? (car buffer) (string-ref string i))
	   (loop (cdr buffer) (+ i 1)))
	  (else
	   #f))))
	    
; Return a source that generates the characters from STRING.  This is only
; used for testing.

(define (string-source string)
    (let ((i 0))
      (lambda ()
        (if (= i (string-length string))
            #f
            (begin
              (set! i (+ i 1))
              (string-ref string (- i 1)))))))

