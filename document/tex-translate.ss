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
  
  (define (translate file)
    (let ((r (with-input-from-file file read)))
      (initialize-metafunctions/matches r)
      (tex-translate r)))
  
  (define nonterminals-break-before
    '(P var sym p* p v
        E F PG H SD))
  
  (define otherwise-metafunctions '(pRe poSt Trim))
  
  (define combine-metafunction-names '(pRe poSt Trim))
  
  (define metafunctions-to-skip '(r6rs-subst-one r6rs-subst-many))

  (define (side-condition-below? x)
    (member x '("6appN!" "6refu" "6setu" "6xref" "6xset" 
                         "6letrec"
                         "6letrec*")))
  
  (define (two-line-name? x) (not (one-line-name? x)))
  
  (define (one-line-name? x)
    (memq x '(Eqv--and--equivalence
              Underspecification
              Basic--syntactic--forms
              Arithmetic)))
  
  ;; tex-translate : sexp -> void
  (define (tex-translate exp)
    (let ([names/clauses '()])
      (let loop ([exp exp])
        (fmatch exp
                [`(module ,_ ,_ ,body ...)
                  (for-each loop body)]
                [`(define ,lang (language ,productions ...))
                  (print-language productions)]
                [`(define-metafunction ,name ,lang ,clauses ...)
                 (unless (member name metafunctions-to-skip) 
                   (if (member name combine-metafunction-names)
                       (set! names/clauses
                             (cons (list name clauses) 
                                   names/clauses))
                       (print-metafunction name clauses)))]
                [`(define ,name (reduction-relation ,lang ,r ...))
                  (print-reductions name r (one-line-name? name))]
                [else (void)]))
      (print-metafunctions names/clauses)))

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
    (let ((v (ormap (lambda (l) (if (not (and (list? l) (= (length l) 2)))
                               l
                               #f))
                    r)))
      (when v
        (error 'check "not a list with two elements: ~s" v))
      r))
  
  (define (print-something reduction-translate name reductions start end)
    (let ((n (format "~a-~a.tex" filename-prefix (regexp-replace* #rx"[?*]" (format "~a" name) "_"))))
      (fprintf (current-error-port) "Writing file ~a ...\n" n)
      (with-output-to-file n
        (lambda () 
          (let* ([rules (check (map/last reduction-translate reductions))]
                 [boxes (apply append (map car rules))]
                 [reductions (apply append (map cadr rules))])
            (for-each display boxes) 
            (printf "~a\n" start)
            (for-each display reductions)
            (printf "~a\n" end)))
        'truncate)))
  
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
        (list '() '())]
      [`((/-> ,a ,b) ,c)
        ;; skip defn of /->
        (list '() '())] 
      [_ 
       (fprintf (current-error-port) "WARNING: reduction translate on wrong thing ~s\n" r)
       (list '() 
             '())]))
  
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
  (define (metafunction-name? x) (memq x metafunction-names))
  (define (translate-mf-name name)
    (case name
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
    (print-something (lambda (x last-one?) 
                       (fmatch x
                               [`(,left ,right) (p-case name left right 
                                                        (and last-one? (memq name otherwise-metafunctions)))]
                               [else (error 'print-metafunction "mismatch ~s" x)]))
                     name
                     clauses
                     "\\begin{displaymath}\n\\begin{array}{lcl}"
                     "\\end{array}\n\\end{displaymath}"))
  
  (define (print-metafunctions names/clauses)
    (let ([names/spread-out
           (apply
            append
            (map (lambda (name/clauses)
                   (if (eq? 'blank name/clauses)
                       (list 'blank)
                       (let ([name (car name/clauses)])
                         (map/last (lambda (clause last-one?) (list name clause last-one?))
                                   (cadr name/clauses)))))
                 (add-between 'blank names/clauses)))])
      (print-something (lambda (name/clause really-the-last-one?) 
                         (if (eq? name/clause 'blank)
                             (list '() (list "\\\\"))
                             (let ([name (list-ref name/clause 0)]
                                   [clause (list-ref name/clause 1)]
                                   [last-one? (list-ref name/clause 2)])
                               (fmatch clause
                                       [`(,left ,right) (p-case name left right
                                                                (and last-one? (memq name otherwise-metafunctions)))]
                                       [else (error 'print-metafunctions "mismatch ~s" name)]))))
                       (apply string-append (map symbol->string (map car names/clauses)))
                       names/spread-out
                       "\\begin{displaymath}\n\\begin{array}{lcl}"
                       "\\end{array}\n\\end{displaymath}")))
  
  (define (add-between x lst)
    (cond
      [(null? lst) null]
      [else (let loop ([fst (car lst)]
                       [next (cdr lst)])
              (cond
                [(null? next) (list fst)]
                [else (list* fst x (loop (car next) (cdr next)))]))]))
  
  (define (p-case name lhs rhs show-otherwise?)
    (let*-values ([(l l-cl) (pattern->tex lhs)]
                  [(r r-cl) (pattern->tex rhs)])
      (let* ([cl (append l-cl r-cl)]
             [lboxname (format "lhsbox~a" (next))]
             [arrowboxname (format "arrowbox~a" (next))]
             [rboxname (format "rhsbox~a" (next))]
             [lbox-height (count-lines l)]
             [rbox-height (count-lines r)]
             [biggest-height (max rbox-height lbox-height)]
             [side-conditions
              (if (null? cl)
                  #f
                  (format "(~a)" (string-join cl ", ")))])
        (list
         (list (setup-tex lboxname l biggest-height #f)
               (setup-tex rboxname r biggest-height #f))
         (list 
          (cond
            [side-conditions
             (format
              "~a \\llbracket ~a \\rrbracket & = &\n~a \\\\\n\\multicolumn{3}{l}{\\hbox to .2in{} ~a}\\\\\n"
              (translate-mf-name name)
              (inline-tex lboxname l biggest-height #f)
              (inline-tex rboxname r biggest-height #f)
              side-conditions)]
            [else
             (format
              "~a \\llbracket ~a \\rrbracket & = &\n~a ~a\\\\\n"
              (translate-mf-name name)
              (inline-tex lboxname l biggest-height #f)
              (inline-tex rboxname r biggest-height #f)
              (if show-otherwise?
                  "~ ~ ~ ~ ~ ~ ~ \\mbox{\\textrm{(otherwise)}}"
                  ""))]))))))
  
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
        [(pp) (show-rewritten-nt lhs "\\textrm{[pair pointers]}")]
        [(sym) (show-rewritten-nt lhs "\\textrm{[variables except \\sy{dot}]}")]
        [(x)  (show-rewritten-nt lhs "\\textrm{[variables except \\sy{dot} and keywords]}")]
        [(n)  (show-rewritten-nt lhs "\\textrm{[numbers]}")]
        
        [else
         (let ([max-line-length
                (case nonterm
                  [(e) 60]
                  [(es) 65]
                  [(a*) 90]
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
  
  (define num->str
    (let ((chars (string->list "abcdefghijklmnopqrstuvwxyz")))
      (lambda (n)
        (let loop ((n n)
                   (acc '()))
          (cond
            [(< n 26)
             (list->string (reverse (cons (list-ref chars n) acc)))]
            [else
             (loop (quotient n 26)
                   (cons (list-ref chars (modulo n 26)) acc))])))))
                 
  (define next 
    (let ((i 0)) 
      (lambda ()
        (begin0 (num->str i) (set! i (add1 i))))))
  
  (define (count-lines str)
    (add1 (length (regexp-match* "\n." str))))
  
  (define (p-rule arrow lwrap rwrap)
    (opt-lambda (lhs rhs raw-name left-right? [extra-side-conditions '()])
      (let*-values ([(l l-cl) (pattern->tex* (lwrap lhs) left-right?)]
                    [(r r-cl) (pattern->tex* (rwrap rhs) left-right?)])
        (let* ([arrow-tex 
		(case arrow
		 ((-->) "\\rightarrow")
		 ((*->) "\\ovserset{\\rightarrow}{\ast}"))]
               [name (format "\\rulename{~a}" (quote-tex-specials raw-name))]
               [cl (append extra-side-conditions l-cl r-cl)]
               [lboxname (format "lhsbox~a" (next))]
               [arrowboxname (format "arrowbox~a" (next))]
               [rboxname (format "rhsbox~a" (next))]
               [nboxname (format "namebox~a" (next))]
               [lbox-height (count-lines l)]
               [rbox-height (count-lines r)]
               [biggest-height (max rbox-height lbox-height)]
               [left-biggest-height (if left-right? biggest-height lbox-height)]
               [right-biggest-height (if left-right? biggest-height rbox-height)]
               [name-biggest-height (if left-right? biggest-height left-biggest-height)]
               [arrow-biggest-height (if left-right? biggest-height left-biggest-height)]
               [extra-inlined-arrow? (and (not left-right?) (not (= 1 left-biggest-height)))]
               [side-conditions
                (if (null? cl)
                    #f
                    (format "(~a)" (string-join cl ", ")))])
          (list
           (list (setup-tex lboxname l left-biggest-height extra-inlined-arrow?)
                 (setup-tex arrowboxname arrow-tex arrow-biggest-height #f)
                 (setup-tex rboxname r right-biggest-height #f)
                 (setup-tex nboxname name name-biggest-height #f))
           (list 
            (cond
              [side-conditions
               (format
                (if left-right?
                    "\\onelinescruleA\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n"
                    (if (side-condition-below? raw-name)
                        "\\twolinescruleB\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n"
                        "\\twolinescruleA\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n"))
                (inline-tex lboxname l left-biggest-height extra-inlined-arrow?)
                (inline-tex rboxname r right-biggest-height #f)
                (inline-tex nboxname name name-biggest-height #f)
                side-conditions
                (if extra-inlined-arrow?
                    ""
                    (inline-tex arrowboxname arrow-tex arrow-biggest-height #f)))]
              [else
               (format 
                (if left-right?
                    "\\onelineruleA\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n"
                    "\\twolineruleA\n  {~a}\n  {~a}\n  {~a}\n  {~a}\n\n")
                (inline-tex lboxname l left-biggest-height extra-inlined-arrow?)
                (inline-tex rboxname r right-biggest-height #f)
                (inline-tex nboxname name name-biggest-height #f)
                (if extra-inlined-arrow?
                    ""
                    (inline-tex arrowboxname arrow-tex arrow-biggest-height #f)))])))))))
  
  (define (quote-tex-specials name)
    (let ([ans (regexp-replace*
		#rx"~"
		(regexp-replace*
		 #rx"¼"
		 (regexp-replace*
		  #rx"[#]"
		  name
                 "\\\\#")
		 "\\\\mu")
		"\\\\~{}")])
      ; (fprintf (current-error-port) "~s -> ~s\n" name ans)
      ans))
  
  (define (setup-tex boxname str biggest-height arrow?)
    (cond
      [(= 1 biggest-height) ""]
      [else
       (error 'setup-tex "cannot handle multiline stuff ~s"
              (list boxname str biggest-height arrow?))
       (let ([height (count-lines str)])
         (boxstr boxname str (- biggest-height height) arrow?))]))
  
  (define (inline-tex boxname str biggest-height arrow?)
    (cond
      [(= 1 biggest-height) (format "~a~a" 
                                    str 
                                    (if arrow? " \\rightarrow" ""))]
      [else
       (let ([height (count-lines str)])
         (format "\\usebox{\\~a}" boxname))]))
    
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
      (string-append (do-pretty-format hole)
                     "\\["
                     (do-pretty-format exp)
                     "\\]")))
  
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
	  (display "()" o))
	 ((string? p)
	  (display "\\textrm{``" o)
	  (display (quote-tex-specials p) o)
	  (display "''}" o))
	 ((list? p)
	  (case (car p)
	    ((quote)
	     (display "'" o)
	     (loop (cadr p)))
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
	     (display "[" o)
	     (loop (caddr p))
	     (display "]" o))
	    ((Qtoc)
	     (display "\\mathscr{Q}\\llbracket" o)
	     (loop (cadr p))
	     (display "\\rrbracket" o))
	    ((Trim)
	     (display "\\mathscr{T}\\llbracket" o)
	     (loop (cadr p))
	     (display "\\rrbracket" o))
	    ((pRe)
	     (display "\\mathscr{R}\\llbracket" o)
	     (loop (cadr p))
	     (display "\\rrbracket" o))
	    ((poSt)
	     (display "\\mathscr{S}\\llbracket" o)
	     (loop (cadr p))
	     (display "\\rrbracket" o))
            [(observable)
             (display "\\mathscr{O}\\llbracket{}" o)
             (loop (cadr p))
             (display "\\rrbracket{}" o)]
            [(observable-value)
             (display "\\mathscr{O}_v\\llbracket{}" o)
             (loop (cadr p))
             (display "\\rrbracket{}" o)]
            (else
	     (display "(" o)
	     (loop (car p))
	     (for-each (lambda (el)
			 (display "~" o)
			 (loop el))
		       (cdr p))
	     (display ")" o))))
	 ((pair? p)
	  (display "(" o)
	  (loop (car p))
	  (display " . " o)
	  (loop (cdr p))
	  (display ")" o))))
      (close-output-port o)
      (get-output-string o)))

  (define (format-symbol op)
    (let ((command
	   (case op
	     ((language
	       name subst reduction reduction/context red term apply-values store dot ccons throw push pop trim dw mark condition handlers
	       define beginF throw lambda set! if begin0 quote begin letrec letrec* reinit l!)
	      "\\sy")
	     ((cons unspecified null list dynamic-wind apply values null? pair? car cdr call/cc procedure? condition? unspecified? set-car! set-cdr! eqv? call-with-values with-exception-handler raise-continuable raise)
	      "\\va")
	     (else
	      "\\nt")))
	  (o (open-output-string)))
      (parameterize ((current-output-port o))
	  (d-var op command))
      (close-output-port o)
      (get-output-string o)))

  (define (truncate-string str)
    str)
  
  ;; pattern->tex : pattern -> (values string (listof string))
  ;; given a pattern, returns a string representation and some strings of side constraints
  (define (pattern->tex pat)
    (pattern->tex* pat #t))
  
  (define (pattern->tex* pat left-to-right?)
    (let ((side-conds (get-side-conditions pat))
          (s (open-output-string)))
      (parameterize ((current-output-port s))
        (pattern->tex/int pat left-to-right?)
        (values (truncate-string (get-output-string s)) 
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
        (let ([scs (map format-side-cond sc)])
          (for-each (lambda (x) 
                      (unless (= 1 (length x))
                        (error 'format-side-cond "or with and inside: ~s" sc)))
                    scs)
          (let loop ([lst (cdr scs)]
                     [strs (list (car (car scs)))])
            (cond
              [(null? lst) (list (apply string-append (reverse strs)))]
              [else (loop (cdr lst)
                          (list* (car (car lst)) 
                                 "\\textrm{ or }" 
                                 strs))])))]
      [`(fresh ,xs)
        (list (format "~a \\textrm{ fresh}" (string-join (map (lambda (x) (format "~a" (gps x))) xs) ", ")))]
      [`(fresh ,(? symbol? x) ,'...)
        (list (format "~a \\cdots \\textrm{ fresh}" (gps x)))]
      [`(freshS ,xs)        
        (list (format "~a \\cdots \\textrm{ fresh}" (string-join (map (lambda (x) (format "~a" (gps x))) xs) ", ")))]
      [`(not (eq? (term ,t1) (term ,t2)))
        (list (format "~a \\neq ~a" (gps t1) (gps t2)))] 
      [`(not (eq? (term ,t1) #f))
        (list (format "~a \\neq \\semfalse{}" (gps t1)))]
      [`(not (uproc? (term ,v)))
       (list (format "~a \\not\\in \\nt{uproc}" (gps v)))]
      [`(not (proc? (term ,v)))
       (list (format "~a \\not\\in \\nt{proc}" (gps v)))]
      [`(not (pp? (term ,v)))
        (list (format "~a \\not\\in \\nt{pp}" (gps v)))]
      [`(not (null-v? (term ,v)))
        (list (format "~a \\neq \\nt{null}" (gps v)))]
      [`(not (prefixed-by? (term ,v) (quote p:)))
        (list (format "~a \\not\\in \\nt{pp}" (gps v)))]
      [`(= (length (term (,arg1 ,dots))) (length (term (,arg2 ,dots))))
        (list (arglen-str "=" arg1 arg2))]
      [`(not (= (length (term (,arg1 ,dots))) (length (term (,arg2 ,dots)))))
        (list (arglen-str "\\neq" arg1 arg2))]
      [`(< (length (term (,arg1 ,dots))) (length (term (,arg2 ,dots))))
        (list (arglen-str "<" arg1 arg2))]
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
      
      [`(term (,(? metafunction-name? mf) ,arg))
        (list (format "~a \\llbracket ~a \\rrbracket"
                      (translate-mf-name mf)
                      (gps arg)))]
      [`(not (term (,(? metafunction-name? mf) ,arg)))
        (list (format "! ~a \\llbracket ~a \\rrbracket"
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
       (list (format "\\verbatim|~s|" sc))]))
  
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
        [`(r6rs-subst-one (term ,x) (term ,v) ,e)
          (d "{ ")
          (pattern->tex/int x lr?)
          (d " s-> ")
          (pattern->tex/int v lr?)
          (d " }")
          (loop e)]
        [`(or ,arg1 ,args ...)
          (loop arg1)
          (for-each
           (lambda (x) 
             (d "\\textrm{ or }")
             (loop x))
           args)]
        [`(,(? metafunction-name? mf) ,arg)
          (d (translate-mf-name mf))
          (d " \\llbracket ")
          (loop arg)
          (d " \\rrbracket ")]
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
    (d " \\gopen ")
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
    (d " \\gclose "))
    
  (define (pattern->tex/int orig-pat lr?)
    (define d display)
    (define (loop pat)
      (fmatch pat
        
        [(list 'begin (list 'unquote `(r6rs-subst-all (term (,x ,dots1)) (term (,v ,dots2)) ,e)))
         (loop e)
         (d "[")
         (loop x)
         (d " \\mapsto")
         (loop v)
         (d " \\ldots])")]
        
        [(list 'unquote e) (rhs->tex/int e lr?)]
            
        [`(store ,s (dw ,dw (in-hole ,c (,v (lambda (dot ,x1) (throw ,name ,stack ,'... ,e)))) ,defn ,'...))
          (d "(\\sy{store}~") (loop s) (d "~(\\sy{dw}~") (loop dw) (d "\n")
          (d "  ") (loop c) (d "[(") (loop v) (d "~(\\sy{lambda}~(\\sy{dot}~") (loop x1) (d ")\n")
          (d "         (\\sy{throw}~") (loop name) (d " ") (loop stack) (d "~\\cdots\n")
          (d "           ") (loop e) (d ")))]\n")
          (d "  ") (loop defn) (d "\\cdots))")]
        
        [(list 'unquote-splicing expr) (rhs->tex/int expr lr?)]
        
        [`(,e0 
            (cwv-mark ,e1)
            ,e2)
          (d "(") (loop e0) (d "\n")
          (d "   ") (loop `(cwv-mark ,e1)) (d "\n")
          (d "   ") (loop e2) (d ")")]
        
        
        [`(store (,item1 ,item2 ,item3 ,item4) ,body) 
          (begin (d "(\\sy{store}~(") (loop item1) (d "~") (loop item2) (d "\n")
                 (d "        ") (loop item3) (d "\n")
                 (d "        ") (loop item4) (d ")\n")
                 (d "  ") (loop body) (d ")"))]
        
        
        
        [`(store (,item1 ,item2 (,item3-name (lambda ,@(list lambda-body ...))) ,item4 ,item5) ,body)
          (let ([item3 `(,item3-name (lambda ,@lambda-body))])
            (begin (d "(\\sy{store}~") (loop `(,item1 ,item2 ,item3 ,item4 ,item5)) (d "\n")
                   (d "  ") (loop body) (d ")")))]
        
        [`(store (,item1 ,item2 ,item3 ,item4 ,item5) ,body)
          (if lr?
              (begin (d "(\\sy{store}~(") (loop item1) (d " ") (loop item2) (d "\n")
                     (d "        ") (loop item3) (d "\n")
                     (d "        ") (loop item4) (d "~") (loop item5) (d ")\n ")
                     (loop body) (d ")"))
              (begin (d "(\\sy{store}~") (loop `(,item1 ,item2 ,item3 ,item4 ,item5)) (d "~")
                     (loop body) (d ")")))]
        
        [`(store (,item1 ,item2 ,item3 ,item4 ,item5 ,item6 ,item7) ,body)
          (if (or #t lr?)
              (begin (d "(\\sy{{store}~(") (loop item1) (d "~") (loop item2) (d "\n")
                     (d "        ") (loop item3) (d "\n")
                     (d "        ") (loop item4) (d "~") (loop item5) (d "\n")
                     (d "        ") (loop item6) (d "~") (loop item7) (d ")\n")
                     (d " ") (loop body) (d ")"))
              (begin (d "(\\sy{store} ") (loop `(,item1 ,item2 ,item3 ,item4 ,item5 ,item6 ,item7)) (d "\n  ")
                     (loop body) (d ")")))]
        [`(store ,store ,body)
         (begin (d "(\\sy{store}~") (loop store) (d "~") (loop body) (d ")"))]
        
        [`(term ,p) (error 'pattern->tex/int "found term inside a pattern ~s, ~s" orig-pat p)]
        [`(side-condition ,p ,_) (loop p)]
        [`(name ,_ ,p) (loop p)]
        [`(in-hole ,hole ,exp)
          (begin (loop hole) (d "[") (loop exp) (d "]"))]
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
         (display (do-pretty-format pat))]
        [`(,(? (lambda (x) (memq x '(unknown error))) lab) ,s)
          (printf "\\mbox{\\textbf{~a:} ~a}" lab (quote-tex-specials s))]
        [`(,(? metafunction-name? mf) ,arg)
          (d (translate-mf-name mf))
          (d " \\llbracket ")
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

  (define ((sreg reg) x) 
    (fprintf (current-error-port) "comparing ~s and ~s, ~s\n" reg x (regexp-match reg (symbol->string x)))
    (regexp-match reg (symbol->string x)))
  
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
	 (let ([str (symbol->string x)])
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

  (translate "../model/r6rs.scm"))