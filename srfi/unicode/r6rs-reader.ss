
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
  (define special-subsequents (string->list "+-@."))
  (define excluded-symbol-chars
    '(#\U80 #\U81 #\U82 #\U83 #\U84 #\U85 #\U86 #\U87 #\U88 #\U89
      #\U8A #\U8B #\U8C #\U8D #\U8E #\U8F #\U90 #\U91 #\U92 #\U93
      #\U94 #\U95 #\U96 #\U97 #\U98 #\U99 #\U9A #\U9B #\U9C #\U9D
      #\U9E #\U9F #\UA0 #\UAB #\UAD #\UBB #\U600 #\U601 #\U602 #\U603
      #\U6DD #\U70F #\UF3A #\UF3B #\UF3C #\UF3D #\U1680 #\U169B
      #\U169C #\U17B4 #\U17B5 #\U180E #\U2000 #\U2001 #\U2002 #\U2003
      #\U2004 #\U2005 #\U2006 #\U2007 #\U2008 #\U2009 #\U200A #\U200B
      #\U200C #\U200D #\U200E #\U200F #\U2018 #\U2019 #\U201A #\U201B
      #\U201C #\U201D #\U201E #\U201F #\U2028 #\U2029 #\U202A #\U202B
      #\U202C #\U202D #\U202E #\U202F #\U2039 #\U203A #\U2045 #\U2046
      #\U205F #\U2060 #\U2061 #\U2062 #\U2063 #\U206A #\U206B #\U206C
      #\U206D #\U206E #\U206F #\U207D #\U207E #\U208D #\U208E #\U2329
      #\U232A #\U23B4 #\U23B5 #\U2768 #\U2769 #\U276A #\U276B #\U276C
      #\U276D #\U276E #\U276F #\U2770 #\U2771 #\U2772 #\U2773 #\U2774
      #\U2775 #\U27C5 #\U27C6 #\U27E6 #\U27E7 #\U27E8 #\U27E9 #\U27EA
      #\U27EB #\U2983 #\U2984 #\U2985 #\U2986 #\U2987 #\U2988 #\U2989
      #\U298A #\U298B #\U298C #\U298D #\U298E #\U298F #\U2990 #\U2991
      #\U2992 #\U2993 #\U2994 #\U2995 #\U2996 #\U2997 #\U2998 #\U29D8
      #\U29D9 #\U29DA #\U29DB #\U29FC #\U29FD #\U2E02 #\U2E03 #\U2E04
      #\U2E05 #\U2E09 #\U2E0A #\U2E0C #\U2E0D #\U2E1C #\U2E1D #\U3000
      #\U3008 #\U3009 #\U300A #\U300B #\U300C #\U300D #\U300E #\U300F
      #\U3010 #\U3011 #\U3014 #\U3015 #\U3016 #\U3017 #\U3018 #\U3019
      #\U301A #\U301B #\U301D #\U301E #\U301F #\UFD3E #\UFD3F #\UFE17
      #\UFE18 #\UFE35 #\UFE36 #\UFE37 #\UFE38 #\UFE39 #\UFE3A #\UFE3B
      #\UFE3C #\UFE3D #\UFE3E #\UFE3F #\UFE40 #\UFE41 #\UFE42 #\UFE43
      #\UFE44 #\UFE47 #\UFE48 #\UFE59 #\UFE5A #\UFE5B #\UFE5C #\UFE5D
      #\UFE5E #\UFEFF #\UFF08 #\UFF09 #\UFF3B #\UFF3D #\UFF5B #\UFF5D
      #\UFF5F #\UFF60 #\UFF62 #\UFF63 #\UFFF9 #\UFFFA #\UFFFB #\U1D173
      #\U1D174 #\U1D175 #\U1D176 #\U1D177 #\U1D178 #\U1D179 #\U1D17A
      #\UE0001 #\UE0020 #\UE0021 #\UE0022 #\UE0023 #\UE0024 #\UE0025
      #\UE0026 #\UE0027 #\UE0028 #\UE0029 #\UE002A #\UE002B #\UE002C
      #\UE002D #\UE002E #\UE002F #\UE0030 #\UE0031 #\UE0032 #\UE0033
      #\UE0034 #\UE0035 #\UE0036 #\UE0037 #\UE0038 #\UE0039 #\UE003A
      #\UE003B #\UE003C #\UE003D #\UE003E #\UE003F #\UE0040 #\UE0041
      #\UE0042 #\UE0043 #\UE0044 #\UE0045 #\UE0046 #\UE0047 #\UE0048
      #\UE0049 #\UE004A #\UE004B #\UE004C #\UE004D #\UE004E #\UE004F
      #\UE0050 #\UE0051 #\UE0052 #\UE0053 #\UE0054 #\UE0055 #\UE0056
      #\UE0057 #\UE0058 #\UE0059 #\UE005A #\UE005B #\UE005C #\UE005D
      #\UE005E #\UE005F #\UE0060 #\UE0061 #\UE0062 #\UE0063 #\UE0064
      #\UE0065 #\UE0066 #\UE0067 #\UE0068 #\UE0069 #\UE006A #\UE006B
      #\UE006C #\UE006D #\UE006E #\UE006F #\UE0070 #\UE0071 #\UE0072
      #\UE0073 #\UE0074 #\UE0075 #\UE0076 #\UE0077 #\UE0078 #\UE0079
      #\UE007A #\UE007B #\UE007C #\UE007D #\UE007E #\UE007F))

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
		    (char=? ch #\#)
		    (char=? ch #\\))
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
	      chars)
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
  (define (read-delimited-string init-ch read-next-char closer? 
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
    (let loop ([chars null][len (if init-ch 0 1)][init-ch init-ch])
      (let ([ch (or init-ch (read-next-char port))])
	(cond
	 ;; closing quote or delimiter
	 [(closer? ch) (list->string (reverse chars))]
	 ;; eof
	 [(eof-object? ch) (raise-bad-eof len)]
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
			  len
			  #f)]
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
		    (loop chars len #f)])))]
	     ;; space escape
	     [(char=? #\space ch)
	      (loop (cons #\space chars) (+ len 2) #f)]
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
		     (loop (cons (integer->char v) chars) (+ len 2) #f))]))]
	 ;; other character
	 [(ok-char? ch) (loop (cons ch chars) (+ len 1) #f)]
	 [else
	  (raise-read-error 
	   (format "illegal character for ~a: ~a" what ch)
	   src line col pos (+ len 1))]))))

  ;; read-symbol
  (define (read-symbol ch port src line col pos)
    (string->symbol (string-append
		     (read-delimited-string 
		      ch
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
			(or (eof-object? ch)
			    (member ch standard-delimiters)
			    (char-whitespace? ch)))
		      #f 
		      ;; ok-char?
		      (lambda (ch)
			(or (char-alphabetic? ch)
			    (char-numeric? ch)
			    (member ch special-initials)
			    (member ch special-subsequents)
			    (and (> (char->integer ch) 127)
				 (not (member ch excluded-symbol-chars)))))
		      port "symbol" src line col pos))))

  ;; read-number
  (define (read-number ch port src line col pos)
    (let loop ([l (list ch)]
	       [len 1])
      (let ([ch (peek-char port)])
	(cond
	 [(or (eof-object? ch)
	      (char-whitespace? ch)
	      (memv ch standard-delimiters))
	  (let* ([s (list->string (reverse l))]
		 [n (string->number s)])
	    (if n
		n
		(let ([sym (string->symbol s)])
		  (case sym
		    [(+ - ...)
		     ;; A peculiar-identifier
		     sym]
		    [else
		     (raise-read-error 
		      (format "illegal symbol: ~a" s)
		      src line col pos len)]))))]
	 [else
	  (loop (cons (read-char port) l) (+ len 1))]))))
	 
  ;; read-quoted-string
  ;;  Reader macro for "
  (define (read-quoted-string ch port src line col pos)
    (read-delimited-string #f read-char
			   ;; closer?
			   (lambda (ch) (and (char? ch) (char=? ch #\")))
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
     #\\ 'non-terminating-macro read-symbol
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