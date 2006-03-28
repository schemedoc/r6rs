
;; This readtable-based replacement for `read ' works in MzScheme
;;  version 299.103 and later.
;;
;; To use this reader, either
;; 
;;   1. Require the module and set the current readtable:
;;        > (require "r6rs-reader.ss")
;;        > (current-readtable r6rs-readtable)
;;        > '|\u03BB|
;;   2. Use `read' exported by this module:
;;       > (require "r6rs-reader.ss")
;;       > (read)
;;       '|\u03BB|
;;   3. Prefix an S-expression with #reader"r6rs-reader.ss":
;;       > #reader"r6rs-reader.ss" '|\u03B|B
;;
;; See also "r6rs-reader-test.ss".

(module r6rs-reader mzscheme
  (provide r6rs-readtable
	   (rename r6rs-read read)
	   (rename r6rs-read-syntax read-syntax))

  ;; for raise-read-[eof-]error:
  (require (lib "readerr.ss" "syntax"))

  (define hex-digits (string->list "0123456789abcdefABCDEF"))
  (define standard-delimiters (string->list ";',`()[]{}\""))
  (define special-initials (string->list "!$%&*/:<=>?^_~"))
  (define excluded-symbol-chars
    '(#\u0313 #\u0F3A #\u0F3B #\u0F3C #\u0F3D #\u1680 #\u169B #\u169C
      #\u180E #\u2000 #\u2001 #\u2002 #\u2003 #\u2004 #\u2005 #\u2006
      #\u2007 #\u2008 #\u2009 #\u200A #\u2018 #\u2019 #\u201A #\u201B
      #\u201C #\u201D #\u201E #\u201F #\u2028 #\u2029 #\u202F #\u2039
      #\u203A #\u2045 #\u2046 #\u205F #\u207D #\u207E #\u208D #\u208E
      #\u2329 #\u232A #\u23B4 #\u23B5 #\u2768 #\u2769 #\u276A #\u276B
      #\u276C #\u276D #\u276E #\u276F #\u2770 #\u2771 #\u2772 #\u2773
      #\u2774 #\u2775 #\u27C5 #\u27C6 #\u27E6 #\u27E7 #\u27E8 #\u27E9
      #\u27EA #\u27EB #\u2983 #\u2984 #\u2985 #\u2986 #\u2987 #\u2988
      #\u2989 #\u298A #\u298B #\u298C #\u298D #\u298E #\u298F #\u2990
      #\u2991 #\u2992 #\u2993 #\u2994 #\u2995 #\u2996 #\u2997 #\u2998
      #\u29D8 #\u29D9 #\u29DA #\u29DB #\u29FC #\u29FD #\u2E02 #\u2E03
      #\u2E04 #\u2E05 #\u2E09 #\u2E0A #\u2E0C #\u2E0D #\u2E1C #\u2E1D
      #\u3000 #\u3008 #\u3009 #\u300A #\u300B #\u300C #\u300D #\u300E
      #\u300F #\u3010 #\u3011 #\u3014 #\u3015 #\u3016 #\u3017 #\u3018
      #\u3019 #\u301A #\u301B #\u301D #\u301E #\u301F #\uFD3E #\uFD3F
      #\uFE17 #\uFE18 #\uFE35 #\uFE36 #\uFE37 #\uFE38 #\uFE39 #\uFE3A
      #\uFE3B #\uFE3C #\uFE3D #\uFE3E #\uFE3F #\uFE40 #\uFE41 #\uFE42
      #\uFE43 #\uFE44 #\uFE47 #\uFE48 #\uFE59 #\uFE5A #\uFE5B #\uFE5C
      #\uFE5D #\uFE5E #\uFF08 #\uFF09 #\uFF3B #\uFF3D #\uFF5B #\uFF5D
      #\uFF5F #\uFF60 #\uFF62 #\uFF63))

  (define excluded-mzscheme-ascii-symbol-chars
    ;; ASCII characters that MzScheme allows in symbols, but R5RS doesn't
    (let loop ([i 0])
      (if (= i 128) 
	  null
	  (let ([ch (integer->char i)])
	    (if (or (char-whitespace? ch)
		    (char-alphabetic? ch)
		    (char-numeric? ch)  ; mapped separately for numbers
		    (memq ch standard-delimiters)
		    (memq ch special-initials)
		    (memq ch '(#\. #\+ #\-)) ; mapped separately for numbers
		    (char=? ch #\#))
		;; Either allowed by R6RS, or not allowed by MzScheme:
		(loop (add1 i))
		;; Allowed by MzScheme but not R6RS:
		(cons ch (loop (add1 i))))))))

  ;; hex-value : char -> int
  (define (hex-value ch)
    (cond
     [(char-numeric? ch)
      (- (char->integer ch) 48)]
     [(memv ch '(#\a #\b #\c #\d #\e #\f))
      (- (char->integer ch) 87)]
     [else
      (- (char->integer ch) 55)]))

  ;; hex->char : char-list (string -> ) -> char
  ;;  Checks whether chars has 1 to 8 hex digits, and
  ;;  produces the character if so
  (define (hex->char chars raise-bad)
    (unless (<= 1 (length chars) 8)
      (raise-bad " (expected 1 to 8 hex digits after #\\x) "))
    (for-each (lambda (c) 
		(unless (memv c hex-digits)
		  (raise-bad (format " (expected hex digit, found ~a) " c))))
	      (cdr chars))
    (let loop ([n 0][chars chars])
      (if (null? chars)
	  (begin
	    (when (or (> n #x10FFFF)
		      (<= #xD800 n #xDFFF))
	      (raise-bad " (out of range character) "))
	    (integer->char n))
	  (loop (+ (* n 16) (hex-value (car chars)))
		(cdr chars)))))
  
  ;; read-delimited-string : (-> char/eof) (char -> bool) bool (char -> bool)
  ;;                         input-port .... -> string
  ;;  Reads a string or symbol
  (define (read-delimited-string read-next-char closer? 
				 all-escapes? ok-char?
				 port
				 what src line col pos)
    ;; raise-bad-eof
    ;;  Reports an unexpected EOF in a string/symbol
    (define (raise-bad-eof len)
      (raise-read-eof-error 
       (format "unexpected end-of-file in ~a" what) 
       src line col pos len))

    ;; to-hex : char int -> int
    ;;  Checks input and gets it's value as a hex digit
    (define (to-hex ch len)
      (unless (memv ch hex-digits)
	(if (eof-object? ch)
	    (raise-bad-eof len)
	    (raise-read-error 
	     (format "expected a hex digit for ~a, found: ~e" what ch)
	     src line col pos len)))
      (hex-value ch))

    ;; loop to read string/symbol characters; track the length for error reporting
    (let loop ([chars null][len 1])
      (let ([ch (read-next-char port)])
	(cond
	 ;; eof
	 [(eof-object? ch) (raise-bad-eof len)]
	 ;; closing quote or bar
	 [(closer? ch) (list->string (reverse chars))]
	 ;; escape
	 [(char=? ch #\\)
	  (let ([ch (read-char port)])
	    (cond
	     ;; eof after escape
	     [(eof-object? ch) (raise-bad-eof (add1 len))]
	     ;; hex escape
	     [(char=? #\x ch)
	      (let xloop ([len (+ len 1)]
			  [l null])
		(let ([ch (read-char port)])
		  (cond
		   [(char=? #\; ch)
		    (loop (cons (hex->char
				 (reverse l)
				 (lambda (str)
				   (raise-read-error 
				    (format "bad \\x escape in ~a~a" what str)
				    src line col pos len)))
				chars)
			  len)]
		   [(memv ch hex-digits)
		    (xloop (+ len 1) (cons ch l))]
		   [else
		    (raise-read-error 
		     "expected hex digits terminated by a semi-colon after \\x"
		     src line col pos len)])))]
	     [(not all-escapes?)
	      (raise-read-error 
	       (format "illegal escape for ~a: \\~a" what ch)
	       src line col pos (+ len 2))]
	     ;; newline escape
	     [(char=? #\newline ch)
	      ;; Eat whitespace until we find a newline...
	      (let w-loop ([len (+ len 1)])
		(let ([ch (peek-char port)])
		  (cond
		   [(eof-object? ch) (raise-bad-eof len)]
		   [(and (char-whitespace? ch)
			 (not (char=? #\newline ch))) 
		    (read-char port)
		    (w-loop (+ len 1))]
		   [else
		    (loop chars len)])))]
	     ;; space escape
	     [(char=? #\space ch)
	      (loop (cons #\space chars) (+ len 2))]
	     ;; other escapes
	     [else (let ([v (case ch
			      [(#\a) 7]
			      [(#\b) 8]
			      [(#\t) 9]
			      [(#\n) 10]
			      [(#\v) 11]
			      [(#\f) 12]
			      [(#\r) 13]
			      [(#\") 34]
			      [(#\\) 92]
			      [(#\|) 124]
			      ;; not a valid escape!
			      [else
			       (raise-read-error 
				(format "illegal escape for ~a: \\~a" what ch)
				src line col pos (+ len 2))])])
		     (loop (cons (integer->char v) chars) (+ len 2)))]))]
	 ;; other character
	 [(ok-char? ch) (loop (cons ch chars) (+ len 1))]
	 [else
	  (raise-read-error 
	   (format "illegal character for ~a: ~a" what ch)
	   src line col pos (+ len 1))]))))

  ;; read-symbol
  (define (read-symbol ch port src line col pos)
    (string->symbol (string-append
		     (string ch)
		     (read-delimited-string 
		      ;; read-next-char
		      (lambda (port)
			(let ([ch (peek-char port)])
			  (if (or (eof-object? ch)
				  (member ch standard-delimiters)
				  (char-whitespace? ch))
			      ;; Don't consume
			      ch
			      ;; Consume
			      (begin
				(read-char port)
				ch))))
		      ;; closer?
		      (lambda (ch)
			(or (member ch standard-delimiters)
			    (char-whitespace? ch)))
		      #f 
		      ;; ok-char?
		      (lambda (ch)
			(or (char-alphabetic? ch)
			    (char-numeric? ch)
			    (member ch special-initials)
			    (and (> (char->integer ch) 127)
				 (not (member ch excluded-symbol-chars)))))
		      port "symbol" src line col pos))))

  ;; read-number
  ;;  Use MzScheme's reader, then reject symbol results
  (define (read-number ch port src line col pos)
    (let ([v (read/recursive port ch #f)])
      (if (number? v)
	  v
	  (raise-read-error 
	   (format "illegal symbol: ~a" v)
	   src line col pos (string-length (symbol->string v))))))
  
  ;; read-quoted-string
  ;;  Reader macro for "
  (define (read-quoted-string ch port src line col pos)
    (read-delimited-string read-char 
			   (lambda (ch) (char=? ch #\"))
			   #t (lambda (ch) #t)
			   port 
			   "string" src line col pos))

  ;; read-character
  ;;  Reader macro for characters
  (define (read-character ch port src line col pos)

    ;; make-char-const : list-of-char len -> char
    ;;  Checks whether the character sequence names a char,
    ;;  and either reports and error or returns the character
    (define (make-char-const chars len)
      (let ([chars (reverse chars)])
	(if (null? (cdr chars))
	    ;; simple case: single character
	    (car chars)
	    ;; multi-character name:
	    (let ([name (list->string chars)])
	      ;; raise-bad-char
	      ;;  When it's not a valid character
	      (define (raise-bad-char detail)
		(raise-read-error 
		 (format "bad character constant~a: #\\~a" detail name)
		 src line col pos len))

	      ;; hex-char : int -> char
	      ;;  Checks whether chars has n hex digits, and
	      ;;  produces the character if so
	      (define (hex-char n)
		(hex->char (cdr chars)
			   (lambda (str)
			     (raise-bad-char str))))

	      ;; Check for standard names or hex, and report an error if not
	      (case (string->symbol name)
		[(nul) (integer->char 0)]
		[(alarm) (integer->char 7)]
		[(backspace) (integer->char 8)]
		[(tab) (integer->char 9)]
		[(newline linefeed) (integer->char 10)]
		[(vtab) (integer->char 11)]
		[(page) (integer->char 12)]
		[(return) (integer->char 13)]
		[(esc) (integer->char 27)]
		[(space) (integer->char 32)]
		[(delete) (integer->char 127)]
		[else
		 ;; Hex?
		 (case (car chars)
		   [(#\x)
		    (hex-char 2)]
		   [(#\u)
		    (hex-char 4)]
		   [(#\U)
		    (hex-char 8)]
		   [else
		    (raise-bad-char "")])])))))
    
    ;; read the leading character:
    (let ([ch (read-char port)])
      (when (eof-object? ch)
	(raise-read-eof-error "unexpected end-of-file after #\\"
			      src line col pos 2))
      ;; loop until delimiter:
      (let loop ([len 3][chars (list ch)])
	(let ([ch (peek-char port)])
	  (if (eof-object? ch)
	      ;; eof is a delimiter
	      (make-char-const chars len)
	      ;; otherwise, consult the current readtable to find delimiters
	      ;; in case someone extends r6rs-readtable:
	      (let-values ([(kind proc dispatch-proc) 
			    (readtable-mapping (current-readtable) ch)])
		(cond
		 [(eq? kind 'terminating-macro) 
		  ;; a terminating macro is a delimiter by definition
		  (make-char-const chars len)]
		 [(or (char-whitespace? ch)
		      (member ch standard-delimiters))
		  ;; something mapped to one of the standard delimiters is
		  ;; a delimiter
		  (make-char-const chars len)]
		 [else 
		  ;; otherwise, it's not a delimiter
		  (read-char port)
		  (loop (add1 len) (cons ch chars))])))))))

  (define (reject ch port src line col pos)
    (raise-read-error 
     (format "illegal character in input: ~a" ch)
     src line col pos 1))

  ;; r6rs-readtable
  ;;  Extends MzScheme's default reader to handle quoted symbols,
  ;;   strings, and characters:
  (define r6rs-readtable
    (apply
     make-readtable #f
     ;; Strings:
     #\" 'terminating-macro read-quoted-string
     ;; Characters:
     #\\ 'dispatch-macro read-character
     ;; Symbols:
     #f 'non-terminating-macro read-symbol
     ;; Characters not allowed in symbols:
     (append
      (apply
       append
       (map (lambda (ch)
	      (list ch 'terminating-macro reject))
	    (append
	     excluded-symbol-chars
	     excluded-mzscheme-ascii-symbol-chars)))
      (apply
       append
       (map (lambda (ch)
	      (list ch 'non-terminating-macro read-number))
	    (string->list "0123456789+-.@"))))))

  ;; r6rs-read
  ;;  Like the normal read, but uses r6rs-readtable
  (define r6rs-read
    (case-lambda
     [() (r6rs-read (current-input-port))]
     [(input) (parameterize ([current-readtable r6rs-readtable])
		(read input))]))

  ;; r6rs-read
  ;;  Like the normal read-syntax, but uses r6rs-readtable
  (define r6rs-read-syntax
    (case-lambda
     [() (r6rs-read-syntax (object-name (current-input-port)) (current-input-port))]
     [(src-v) (r6rs-read-syntax src-v (current-input-port))]
     [(src-v input) (parameterize ([current-readtable r6rs-readtable])
		      (read-syntax src-v input))])))