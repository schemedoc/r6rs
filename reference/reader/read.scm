; A little R6RS Scheme reader, adapted from the Scheme 48 reader.

; Copyright (c) 1993-2008 by Richard Kelsey, Jonathan Rees, and Mike Sperber
; All rights reserved.

; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
; 3. The name of the authors may not be used to endorse or promote products
;    derived from this software without specific prior written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS OR
; IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
; OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
; IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY DIRECT, INDIRECT,
; INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
; NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
; THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(library (r6rs i/o port reader)
  (export get-datum)
  (import (r6rs base)
	  (r6rs unicode)
	  (r6rs exceptions)
	  (r6rs conditions)
	  ;; imaginary library, (r6rs i/o port) without read-datum
	  (r6rs i/o port basic)
	  (r6rs bytes))

(define (get-datum port)
  (let loop ()
    (let ((form (sub-read port)))
      (cond ((not (reader-token? form))
	     form)
	    ((eq? form close-paren)
	     ;; Too many right parens.
	     (reading-error port "extraneous right parenthesis"))
	    ((eq? form close-bracket)
	     ;; Too many right brackets.
	     (reading-error port "discarding extraneous right bracket"))
	    (else
	     (reading-error port (cdr form)))))))

(define (sub-read-carefully port)
  (let ((form (sub-read port)))
    (cond ((eof-object? form)
           (reading-error port "unexpected end of file"))
	  ((reader-token? form) (reading-error port (cdr form)))
	  (else form))))

(define reader-token-marker (list 'reader-token))
(define (make-reader-token message) (cons reader-token-marker message))
(define (reader-token? form)
  (and (pair? form) (eq? (car form) reader-token-marker)))

(define close-paren (make-reader-token "unexpected right parenthesis"))
(define close-bracket (make-reader-token "unexpected right bracket"))
(define dot (make-reader-token "unexpected \" . \""))


; Main dispatch

(define *dispatch-table-limit* 128)

(define read-dispatch-vector
  (make-vector *dispatch-table-limit*
               (lambda (c port)
                 (reading-error port "illegal character read" c))))

(define read-subsequent?-vector
  (make-vector *dispatch-table-limit* #f))

(define (set-standard-syntax! char subsequent? reader)
  (vector-set! read-dispatch-vector    (char->integer char) reader)
  (vector-set! read-subsequent?-vector (char->integer char) subsequent?))

(define (sub-read port)
  (let ((c (get-char port)))
    (if (eof-object? c)
        c
	(let ((scalar-value (char->integer c)))
	  (cond
	   ((< scalar-value *dispatch-table-limit*)
	    ((vector-ref read-dispatch-vector (char->integer c))
	     c port))
	   ((constituent>127? c)
	    (sub-read-symbol c port))
	   ((char-scheme-whitespace? c)
	    (sub-read port))
	   (else
	    (reading-error port "illegal character read" c)))))))

; Usual read macros

(define (set-standard-read-macro! c subsequent? proc)
  (set-standard-syntax! c subsequent? proc))

(define (sub-read-list c port close-token)
  (let ((form (sub-read port)))
    (if (eq? form dot)
	(reading-error port
		       "missing car -- ( immediately followed by .")
	(let recur ((form form))
	  (cond ((eof-object? form)
		 (reading-error port
				"end of file inside list -- unbalanced parentheses"))
		((eq? form close-token) '())
		((eq? form dot)
		 (let* ((last-form (sub-read-carefully port))
			(another-form (sub-read port)))
		   (if (eq? another-form close-token)
		       last-form
		       (reading-error port
				      "randomness after form after dot"
				      another-form))))
		(else
		 (cons form (recur (sub-read port)))))))))

(define (sub-read-list-paren c port)
  (sub-read-list c port close-paren))
(define (sub-read-list-bracket c port)
  (sub-read-list c port close-bracket))

(set-standard-read-macro! #\( #f sub-read-list-paren)

(set-standard-read-macro! #\[ #f sub-read-list-bracket)

(set-standard-read-macro! #\) #f
  (lambda (c port)
    c port
    close-paren))

(set-standard-read-macro! #\] #f
  (lambda (c port)
    c port
    close-bracket))

(set-standard-read-macro! #\' #f
  (lambda (c port)
    c
    (list 'quote (sub-read-carefully port))))

(set-standard-read-macro! #\` #f
  (lambda (c port)
    c
    (list 'quasiquote (sub-read-carefully port))))

(set-standard-read-macro! #\, #f
  (lambda (c port)
    c
    (let* ((next (lookahead-char port))
	   ;; DO NOT beta-reduce!
	   (keyword (cond ((eof-object? next)
			   (reading-error port "end of file after ,"))
			  ((char=? next #\@)
			   (get-char port)
			   'unquote-splicing)
			  (else 'unquote))))
      (list keyword
            (sub-read-carefully port)))))

; Don't use non-R5RS char literals to avoid bootstrap circularities

(define *nul* (integer->char 0))
(define *alarm* (integer->char 7))
(define *backspace* (integer->char 8))
(define *tab* (integer->char 9))
(define *linefeed* (integer->char 10))
(define *vtab* (integer->char 11))
(define *page* (integer->char 12))
(define *return* (integer->char 13))
(define *escape* (integer->char 27))
(define *delete* (integer->char 127))

(set-standard-read-macro! #\" #f
  (lambda (c port)
    c ;ignored
    (let loop ((l '()) (i 0))
      (let ((c (get-char port)))
        (cond ((eof-object? c)
               (reading-error port "end of file within a string"))
              ((char=? c #\\)
	       (cond
		((decode-escape port)
		 => (lambda (e)
		      (loop (cons e l) (+ i 1))))
		(else (loop l i))))
              ((char=? c #\")
	       (reverse-list->string l i))
              (else
	       (loop (cons c l) (+ i 1))))))))

(define (decode-escape port)
  (let ((c (get-char port)))
    (if (eof-object? c)
	(reading-error port "end of file within a string"))
    (let ((scalar-value (char->integer c)))
      (cond
       ((or (char=? c #\\) (char=? c #\"))
	c)
       ((char=? c *linefeed*)
	(let loop ()
	  (let ((c (lookahead-char port)))
	    (cond 
	     ((eof-object? c)
	      (reading-error port "end of file within a string"))
	     ((char-scheme-whitespace? c)
	      (get-char port)
	      (loop))
	     (else #f)))))
       ((char=? c #\a) *alarm*)
       ((char=? c #\b) *backspace*)
       ((char=? c #\t) *tab*)
       ((char=? c #\n) *linefeed*)
       ((char=? c #\v) *vtab*)
       ((char=? c #\f) *page*)
       ((char=? c #\r) *return*)
       ((char=? c #\e) *escape*)
       ((char=? c #\x)
	(let ((d (decode-hex-digits port char-semicolon? "string literal")))
	  (get-char port) ; remove semicolon
	  d))
       (else
	(reading-error port
		       "invalid escaped character in string"
		       c))))))

(define (char-semicolon? c)
  (equal? c #\;))

; The \x syntax is shared between character and string literals

; This doesn't remove the delimiter from the port.
(define (decode-hex-digits port delimiter? desc)
  (let loop ((rev-digits '()))
    (let ((c (lookahead-char port)))
      (cond
       ((delimiter? c)
	(integer->char
	 (string->number (list->string (reverse rev-digits)) 16)))
       ((eof-object? c)
	(reading-error
	 port
	 (string-append "premature end of a scalar-value literal within a " desc)))
       ((not (char-hex-digit? c))
	(reading-error port
		       (string-append "invalid hex digit in a " desc)
		       c))
       (else
	(get-char port)
	(loop (cons c rev-digits)))))))

(define (char-hex-digit? c)
  (let ((scalar-value (char->integer c)))
    (or (and (>= scalar-value 48)	; #\0
	     (<= scalar-value 57))	; #\9
	(and (>= scalar-value 65)	; #\A
	     (<= scalar-value 70))	; #\F
	(and (>= scalar-value 97)	; #\a
	     (<= scalar-value 102)))))	; #\f

(set-standard-read-macro! #\; #f
  (lambda (c port)
    c ;ignored
    (gobble-line port)
    (sub-read port)))

(define (gobble-line port)
  (let loop ()
    (let ((c (get-char port)))
      (cond ((eof-object? c) c)
	    ((char=? c *linefeed*) #f)
	    (else (loop))))))

(define *sharp-macros* '())

(define (define-sharp-macro c proc)
  (set! *sharp-macros* (cons (cons c proc) *sharp-macros*)))

(set-standard-read-macro! #\# #f
  (lambda (c port)
    c ;ignored
    (let* ((c (lookahead-char port))
	   (c (if (eof-object? c)
		  (reading-error port "end of file after #")
		  (char-downcase c)))
	   (probe (assq c *sharp-macros*)))
      (if probe
	  ((cdr probe) c port)
	  (reading-error port "unknown # syntax" c)))))

(define-sharp-macro #\f
  (lambda (c port)
    (get-char port)
    (let ((c (lookahead-char port)))
      (if (not (or (eof-object? c)
		   (delimiter? c)))
	  (reading-error port "undelimited #f" c)))
    #f))

(define-sharp-macro #\t
  (lambda (c port)
    (get-char port)
    (let ((c (lookahead-char port)))
      (if (not (or (eof-object? c)
		   (delimiter? c)))
	  (reading-error port "undelimited #t" c)))
    #t))

(define-sharp-macro #\'
  (lambda (c port)
    (get-char port)
    (list 'syntax
	  (sub-read-carefully port))))

(define-sharp-macro #\`
  (lambda (c port)
    (get-char port)
    (list 'quasisyntax
	  (sub-read-carefully port))))

(define-sharp-macro #\,
  (lambda (c port)
    (get-char port)
    (let* ((next (lookahead-char port))
	   (keyword (cond ((eof-object? next)
			   (reading-error port "end of file after ,"))
			  ((char=? next #\@)
			   (get-char port)
			   'unsyntax-splicing)
			  (else 'unsyntax))))
      (list keyword
            (sub-read-carefully port)))))

(define-sharp-macro #\v
  (lambda (c port)
    (get-char port)
    (let ((next (lookahead-char port)))
      (cond
       ((eof-object? next)
	(reading-error port "end of file after #v"))
       ((not (char=? next #\u))
	(reading-error port "invalid char after #v"))
       (else
	(get-char port)
	(let ((next (lookahead-char port)))
	  (cond
	   ((eof-object? next)
	    (reading-error port "end of file after #vu"))
	   ((not (char=? next #\8))
	    (reading-error port "invalid char after #vu"))
	   (else
	    (get-char port)
	    (let ((next (lookahead-char port)))
	      (cond
	       ((eof-object? next)
		(reading-error port "end of file after #vu8"))
	       ((not (char=? next #\())
		(reading-error port "invalid char after #vu8"))
	       (else
		(get-char port)
		(let ((elts (sub-read-list-paren next port)))
		  (if (not (proper-list? elts))
		      (reading-error port "dot in #vu8(...)")
		      (cond
		       ((not-u8-list elts)
			=> (lambda (non-u8)
			     (reading-error port "non-octet in #vu8(...)" non-u8)))
		       (else
			(u8-list->bytes elts))))))))))))))))

(define-sharp-macro #\!
  (lambda (c port)
    (get-char port)
    (let ((s (sub-read-symbol (get-char port) port)))
      (case s
	((r6rs)
	 (sub-read port))
	(else
	 (reading-error port "unknown #! syntax" s))))))

(define (not-u8-list l)
  (if (null? l)
      #f
      (if (u8? (car l))
	  (not-u8-list (cdr l))
	  (car l))))

(define (u8? n)
  (and (exact? n)
       (integer? n)
       (not (negative? n))
       (<= n 255)))

(define-sharp-macro #\|
  (lambda (c port)
    (get-char port)
    (let recur ()
      (let ((next (get-char port)))
	(cond
	 ((eof-object? next)
	  (reading-error port "end of file in #| comment"))
	 ((char=? next #\|)
	  (let ((next (lookahead-char port)))
	    (cond
	     ((eof-object? next)
	      (reading-error port "end of file in #| comment"))
	     ((char=? next #\#)
	      (get-char port))
	     (else
	      (get-char port)
	      (recur)))))
	 ((char=? next #\#)
	  (let ((next (lookahead-char port)))
	    (cond
	     ((eof-object? next)
	      (reading-error port "end of file in #| comment"))
	     ((char=? next #\|)
	      (get-char port)
	      (recur)
	      (recur)))))
	 (else
	  (recur)))))
    (sub-read port)))

(define-sharp-macro #\;
  (lambda (char port)
    (get-char port)
    (sub-read-carefully port)
    (sub-read port)))

(define *char-name-table*
  (list
   (cons 'nul *nul*)
   (cons 'alarm *alarm*)
   (cons 'backspace *backspace*)
   (cons 'tab *tab*)
   (cons 'linefeed *linefeed*)
   (cons 'newline *linefeed*)
   (cons 'vtab *vtab*)
   (cons 'page *page*)
   (cons 'return *return*)
   (cons 'esc *escape*)
   (cons 'space #\space)
   (cons 'delete *delete*)))

(define-sharp-macro #\\
  (lambda (c port)
    (get-char port)
    (let ((c (lookahead-char port)))
      (cond ((eof-object? c)
	     (reading-error port "end of file after #\\"))

	    ((char=? #\x c)
	     (get-char port)
	     (if (delimiter? (lookahead-char port))
		 c
		 (decode-hex-digits port char-scalar-value-literal-delimiter? "char literal")))
	    ((char-alphabetic? c)
	     (let ((name (sub-read-carefully port)))
	       (cond ((= (string-length (symbol->string name)) 1)
		      c)
		     ((assq name *char-name-table*)
		      => cdr)
		     (else
		      (reading-error port "unknown #\\ name" name)))))

	    (else
	     (get-char port)
	     c)))))

(define (char-scalar-value-literal-delimiter? c)
  (or (eof-object? c)
      (delimiter? c)))

(define-sharp-macro #\(
  (lambda (c port)
    (get-char port)
    (let ((elts (sub-read-list-paren c port)))
      (if (proper-list? elts)
	  (list->vector elts)
	  (reading-error port "dot in #(...)")))))

(define (proper-list? x)
  (cond ((null? x) #t)
	((pair? x) (proper-list? (cdr x)))
	(else #f)))

(for-each (lambda (c)
	    (define-sharp-macro c (lambda (c port)
				    (sub-read-number #\# port))))
	  '(#\b #\o #\d #\x #\i #\e))

; Tokens

; Symbols and numbers

; We know it's a number
(define (sub-read-number c port)
  (let loop ((l (list c)) (n 1))
    (let ((c (lookahead-char port)))
      (cond
       ((not (or (eof-object? c)
		 (delimiter? c)))
	(get-char port)
	(loop (cons c l)
	      (+ n 1)))
       ((string->number (reverse-list->string l n)))
       (else
	(reading-error port "invalid number syntax" (reverse-list->string l n)))))))

; We know it's a symbol
(define (sub-read-symbol c port)
  (let loop ((l (list c)) (n 1))
    (let ((c (lookahead-char port)))
      (cond
       ((eof-object? c)
	(string->symbol (reverse-list->string l n)))
       ((let ((sv (char->integer c)))
	  (if (< sv *dispatch-table-limit*)
	       (vector-ref read-subsequent?-vector sv)
	       (or (constituent>127? c)
		   (memq (char-general-category c) '(Nd Mc Me)))))
	(get-char port)
	(loop (cons c l)
	      (+ n 1)))
       ((char=? c #\\)
	(get-char port)
	(let ((c (lookahead-char port)))
	  (cond
	   ((or (eof-object? c)
		(not (char=? #\x c)))
	    (reading-error port "invalid escape sequence in a symbol"
			   c))
	   (else
	    (get-char port)
	    (let ((d (decode-hex-digits port char-semicolon? "symbol")))
	      (get-char port)		; remove semicolon
	      (loop (cons d l) (+ n 1)))))))
       ((delimiter? c)
	(string->symbol (reverse-list->string l n)))
       (else
	(reading-error "invalid symbol syntax" (reverse-list->string l n)))))))

; We know it's a symbol, and it starts with an escape
(define (sub-read-symbol-with-initial-escape c port)
  ;(assert (char=? c #\\))
  (let ((c (peek-char port)))
    (cond
     ((or (eof-object? c)
          (not (char=? #\x c)))
      (reading-error port "invalid escape sequence in a symbol"
                     c))
     (else
      (read-char port)
      (let ((d (decode-hex-digits port char-semicolon? "symbol")))
        (read-char port)		; remove semicolon
        (sub-read-symbol d port))))))

; something starting with a +
(define (sub-read/+ c port)
  (let ((next (lookahead-char port)))
    (if (or (eof-object? next)
	    (delimiter? next))
	'+
	(sub-read-number c port))))

; something starting with a -
(define (sub-read/- c port)
  (let ((next (lookahead-char port)))
    (cond
     ((or (eof-object? next)
	  (delimiter? next))
      '-)
     ((char=? #\> next)
      (sub-read-symbol c port))
     (else
      (sub-read-number c port)))))

; something starting with a .
(define (sub-read/. c port)
  (let ((next (lookahead-char port)))
    (cond
     ((or (eof-object? next)
	  (delimiter? next))
      dot)
     ((char=? #\. next)
      (let ((next2
	     (begin (get-char port)
		    (lookahead-char port))))
	(if (or (eof-object? next2)
		(not (char=? #\. next2)))
	    (reading-error "invalid symbol syntax" (string c next next2)))
	(get-char port)
	'...))
     (else
      (sub-read-number c port)))))

(let ((sub-read-whitespace
       (lambda (c port)
         c                              ;ignored
         (sub-read port))))
  (for-each (lambda (c)
              (vector-set! read-dispatch-vector c sub-read-whitespace))
	    ;; ASCII whitespaces
            '(32 9 10 11 12 13)))

(for-each (lambda (c)
	    (set-standard-syntax! c #t sub-read-symbol))
	  (string->list
	   "!$%&*/:<=>?^_~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"))

; #\\ must not be marked as a subsequent because sub-read-symbol handles it
;    separately
(set-standard-syntax! #\\ #f sub-read-symbol-with-initial-escape)

(set-standard-syntax! #\+ #t sub-read/+)
(set-standard-syntax! #\- #t sub-read/-)

(set-standard-syntax! #\. #t sub-read/.)
	  
(for-each (lambda (c)
	    (set-standard-syntax! c #t sub-read-number))
	  (string->list "0123456789"))

(set-standard-syntax! #\@ #t
		      (lambda (c port)
			(reading-error port "illegal character read" c)))

(define (delimiter? c)
  (or (char-scheme-whitespace? c)
      (char=? c #\))
      (char=? c #\()
      (char=? c #\])
      (char=? c #\[)
      (char=? c #\")
      (char=? c #\;)))

(define (constituent>127? c)
  (memq (char-general-category c)
	'(Lu Ll Lt Lm Lo Mn Nl No Pd Pc Po Sc Sm Sk So Co)))

(define (char-scheme-whitespace? c)
  (binary-search *whitespaces* (char->integer c)))

(define *whitespaces* '#(9 10 11 12 13 32 133 160 5760 6158 8192 8193 8194 8195 8196 8197 8198 8199 8200 8201 8202 8232 8233 8239 8287 12288))

; Reader errors

(define (reading-error port message . irritants)
  (raise
   (condition
    (make-message-condition message)
    (make-i/o-port-error port)
    (make-lexical-violation)
    (make-irritants-condition (cons port irritants)))))

; returns index of value (must be number) in vector
(define (binary-search vec val)
  (let ((size (vector-length vec)))
    (let loop ((low 0)			; inclusive
	       (high size))		; exclusive
      (cond
       ((< low (- high 1))
	(let* ((pos (quotient (+ low high) 2)) ; always in
	       (at (vector-ref vec pos)))
	  (cond
	   ((= val at) pos)
	   ((< val at)
	    (loop low pos))
	   (else
	    (loop pos high)))))
       ((< low high)
	(if (= val (vector-ref vec low))
	    low
	    #f))
       (else #f)))))

; Some Scheme implementations may have better versions of these
(define (reverse-list->string l n)
  (list->string (reverse l)))

(define (make-immutable! x) x)

) ; end of library form
