;;;=====================================================================
;;;
;;; Derived forms:
;;;
;;;   Copyright (c) 2006 Andre van Tonder
;;;
;;;   Copyright statement at http://srfi.schemers.org/srfi-process.html
;;;
;;;=====================================================================

;;; September 13, 2006

;;;=====================================================================
;;;
;;; This file builds r6rs up using a sequence of libraries.
;;; It constitutes a nontrivial example, tutorial and test
;;; of the library system.  
;;;
;;; It is meant to be expanded by macros-core and compiled 
;;; together with the latter before using in a production system.
;;;
;;;=====================================================================

;;;=====================================================================
;;;
;;; Various of the standard macros were copied from
;;; SRFI-93 ref impl.
;;;
;;;=====================================================================

(library (core primitives)
  
  (export
   ;; Standard procedures:
   
   * + - / < <= = > >= abs acos append apply asin assoc assq assv atan 
   boolean? call-with-current-continuation call-with-input-file
   call-with-output-file call-with-values call/cc car cdr caar cadr cdar cddr
   caaar caadr cadar caddr cdaar cdadr cddar cdddr caaaar caaadr caadar caaddr cadaar
   cadadr caddar cadddr cdaaar cdaadr cdadar cdaddr cddaar cddadr cdddar cddddr
   ceiling char->integer char-alphabetic? char-ci<=? char-ci<? char-ci=? char-ci>=?
   char-ci>? char-downcase char-lower-case? char-numeric? char-ready? char-upcase
   char-upper-case? char-whitespace? char<=? char<? char=? char>=? char>? char?
   close-input-port close-output-port complex? cons cos current-input-port
   current-output-port denominator display dynamic-wind eof-object?
   eq? equal? eqv? even? exact->inexact exact? exp expt floor for-each
   gcd imag-part inexact->exact inexact? input-port? integer->char integer?
   interaction-environment lcm length list list->string
   list->vector list-ref list-tail list? log magnitude make-polar
   make-rectangular make-string make-vector map max member memq memv min modulo
   negative? newline not null-environment null? number->string number? numerator
   odd? open-input-file open-output-file output-port? pair? peek-char port?
   positive? procedure? quotient rational? rationalize read
   read-char real-part real? remainder reverse round scheme-report-environment
   set-car! set-cdr! sin sqrt string string->list string->number string->symbol
   string-append string-ci<=? string-ci<? string-ci=? string-ci>=? string-ci>?
   string-copy string-fill! string-length string-ref string-set! string<=? string<?
   string=? string>=? string>? string? substring symbol->string symbol? tan
   transcript-off transcript-on truncate unbound values vector vector->list
   vector-fill! vector-length vector-ref vector-set! vector? with-input-from-file
   with-output-to-file write write-char zero?
   
   ;; R6RS additions:
   
   unspecified
   
   ;; Additions defined in the core expander:
   
   begin if set! lambda quote
   define define-syntax let-syntax letrec-syntax make-variable-transformer
   syntax syntax-case identifier? bound-identifier=? free-identifier=?
   generate-temporaries datum->syntax syntax->datum
   syntax-warning syntax-error _ ...
   declare unsafe safe fast small debug
   
   ;; indirect-export - removed                            
   
   (rename (r6rs-eval eval) 
           (r6rs-load load)) 
   environment
   
   ;; Derived syntax defined in separate libraries below:
   
   ;; let let* letrec
   ;; case cond do else =>
   ;; with-syntax syntax-rules
   ;; quasisyntax quasiquote unquote unquote-splicing
   
   ;; For internal use in client libraries below, 
   ;; not to be re-exported to r6rs:
   
   andmap)
  
  (import
   
   ;; An extension to the r6rs import syntax, used here to make  
   ;; available the Scheme primitive procedures, as well as the 
   ;; appropriate macros and procedures defined already in 
   ;; the core expander.  This is the only place it is used.  
   
   (primitives
    
    ;; Standard procedures:
    
    (* + - / < <= = > >= abs acos append apply asin assoc assq assv atan 
       boolean? call-with-current-continuation call-with-input-file
       call-with-output-file call-with-values call/cc car cdr caar cadr cdar cddr
       caaar caadr cadar caddr cdaar cdadr cddar cdddr caaaar caaadr caadar caaddr cadaar
       cadadr caddar cadddr cdaaar cdaadr cdadar cdaddr cddaar cddadr cdddar cddddr
       ceiling char->integer char-alphabetic? char-ci<=? char-ci<? char-ci=? char-ci>=?
       char-ci>? char-downcase char-lower-case? char-numeric? char-ready? char-upcase
       char-upper-case? char-whitespace? char<=? char<? char=? char>=? char>? char?
       close-input-port close-output-port complex? cons cos current-input-port
       current-output-port denominator display dynamic-wind eof-object?
       eq? equal? eqv? even? exact->inexact exact? exp expt floor for-each
       gcd imag-part inexact->exact inexact? input-port? integer->char integer?
       interaction-environment lcm length list list->string
       list->vector list-ref list-tail list? log magnitude make-polar
       make-rectangular make-string make-vector map max member memq memv min modulo
       negative? newline not null-environment null? number->string number? numerator
       odd? open-input-file open-output-file output-port? pair? peek-char port?
       positive? procedure? quotient rational? rationalize read
       read-char real-part real? remainder reverse round scheme-report-environment
       set-car! set-cdr! sin sqrt string string->list string->number string->symbol
       string-append string-ci<=? string-ci<? string-ci=? string-ci>=? string-ci>?
       string-copy string-fill! string-length string-ref string-set! string<=? string<?
       string=? string>=? string>? string? substring symbol->string symbol? tan
       transcript-off transcript-on truncate unbound values vector vector->list
       vector-fill! vector-length vector-ref vector-set! vector? with-input-from-file
       with-output-to-file write write-char zero?
       
       ;; R6RS additions:
       
       unspecified
       
       ;; Additions defined in the core expander:
       
       begin if set! lambda quote
       define define-syntax let-syntax letrec-syntax 
       syntax syntax-case make-variable-transformer 
       identifier? bound-identifier=? free-identifier=?
       generate-temporaries datum->syntax syntax->datum
       syntax-warning syntax-error 
       _ ...
       declare unsafe safe fast small debug
       
       ;; indirect-export - removed                                        
       
       environment r6rs-eval r6rs-load                                         
       
       ;; Derived syntax defined in separate libraries below:
       
       ;; let let* letrec
       ;; and or case cond do else =>
       ;; with-syntax syntax-rules
       ;; quasisyntax quasiquote unquote unquote-splicing
       
       ;; For internal use in client libraries below,
       ;; not to be re-exported to r6rs:
       
       andmap
       )))
  
  ) ;; core:primitives


(library (core with-syntax)
  (export with-syntax)
  (import (for (core primitives) run expand))
  
  (define-syntax with-syntax
    (lambda (x)
      (syntax-case x ()
        ((_ () e1 e2 ...)             (syntax (begin e1 e2 ...)))
        ((_ ((out in)) e1 e2 ...)     (syntax (syntax-case in ()
                                                (out (begin e1 e2 ...)))))
        ((_ ((out in) ...) e1 e2 ...) (syntax (syntax-case (list in ...) ()
                                                ((out ...) (begin e1 e2 ...))))))))
  )

(library (core syntax-rules)
  (export syntax-rules)
  (import (for (core primitives)  run expand) 
          (for (core with-syntax) expand))
  
  (define-syntax syntax-rules
    (lambda (x)
      (define clause
        (lambda (y)
          (syntax-case y ()
            (((keyword . pattern) template)
             (syntax ((dummy . pattern) (syntax template))))
            (((keyword . pattern) fender template)
             (syntax ((dummy . pattern) fender (syntax template))))
            (_
             (syntax-error x)))))
      (syntax-case x ()
        ((_ (k ...) cl ...)
         (andmap identifier? (syntax (k ...)))
         (with-syntax (((cl ...) (map clause (syntax (cl ...)))))
           (syntax
            (lambda (x) (syntax-case x (k ...) cl ...))))))))
  )

(library (core let)
  (export let letrec letrec*)
  (import (for (core primitives)  run expand) 
          (for (core with-syntax) expand))
  
  (define-syntax let
    (lambda (x)
      (syntax-case x ()
        ((_ ((x v) ...) e1 e2 ...)
         (andmap identifier? (syntax (x ...)))
         (syntax ((lambda (x ...) e1 e2 ...) v ...)))
        ((_ f ((x v) ...) e1 e2 ...)
         (andmap identifier? (syntax (f x ...)))
         (syntax ((letrec ((f (lambda (x ...) e1 e2 ...))) f) v ...))))))
  
  (define-syntax letrec
    (lambda (x)
      (syntax-case x ()
        ((_ ((i v) ...) e1 e2 ...)
         (with-syntax (((t ...) (generate-temporaries (syntax (i ...)))))
           (syntax (let ((i (unspecified)) ...)
                     (let ((t v) ...)
                       (set! i t) ...
                       (let () e1 e2 ...)))))))))
  
  (define-syntax letrec*
    (lambda (x)
      (syntax-case x ()
        ((_ ((i v) ...) e1 e2 ...)
         (syntax (let ()
                   (define i v) ...
                   (let () e1 e2 ...)))))))
  
  ) ; let

(library (core derived)
  (export and or let* cond case do else =>)   
  (import (for (core primitives)   run expand) 
          (for (core let)          run expand)
          (for (core with-syntax)  expand)
          (for (core syntax-rules) expand)) 
  
  (define-syntax and
    (syntax-rules ()
      ((and) #t)
      ((and test) test)
      ((and test1 test2 ...)
       (if test1 (and test2 ...) #f))))
  
  (define-syntax or
    (syntax-rules ()
      ((or) #f)
      ((or test) test)
      ((or test1 test2 ...)
       (let ((x test1))
         (if x x (or test2 ...))))))
  
  (define-syntax let*
    (lambda (x)
      (syntax-case x ()
        ((_ () e1 e2 ...)
         (syntax (let () e1 e2 ...)))
        ((_ ((x v) ...) e1 e2 ...)
         (andmap identifier? (syntax (x ...)))
         (let f ((bindings (syntax ((x v) ...))))
           (syntax-case bindings ()
             (((x v))        (syntax (let ((x v)) e1 e2 ...)))
             (((x v) . rest) (with-syntax ((body (f (syntax rest))))
                               (syntax (let ((x v)) body))))))))))
  
  (define-syntax cond
    (lambda (x)
      (syntax-case x ()
        ((_ c1 c2 ...)
         (let f ((c1  (syntax c1))
                 (c2* (syntax (c2 ...))))
           (syntax-case c2* ()
             (()
              (syntax-case c1 (else =>)
                ((else e1 e2 ...) (syntax (begin e1 e2 ...)))
                ((e0)             (syntax (let ((t e0)) (if t t))))
                ((e0 => e1)       (syntax (let ((t e0)) (if t (e1 t)))))
                ((e0 e1 e2 ...)   (syntax (if e0 (begin e1 e2 ...))))
                (_                (syntax-error x))))
             ((c2 c3 ...)
              (with-syntax ((rest (f (syntax c2)
                                     (syntax (c3 ...)))))
                (syntax-case c1 (else =>)
                  ((e0)           (syntax (let ((t e0)) (if t t rest))))
                  ((e0 => e1)     (syntax (let ((t e0)) (if t (e1 t) rest))))
                  ((e0 e1 e2 ...) (syntax (if e0 (begin e1 e2 ...) rest)))
                  (_              (syntax-error x)))))))))))
  
  (define-syntax case
    (lambda (x)
      (syntax-case x ()
        ((_ e c1 c2 ...)
         (with-syntax ((body
                        (let f ((c1 (syntax c1))
                                (cmore (syntax (c2 ...))))
                          (if (null? cmore)
                              (syntax-case c1 (else)
                                ((else e1 e2 ...)    (syntax (begin e1 e2 ...)))
                                (((k ...) e1 e2 ...) (syntax (if (memv t '(k ...))
                                                                 (begin e1 e2 ...)))))
                              (with-syntax ((rest (f (car cmore) (cdr cmore))))
                                (syntax-case c1 ()
                                  (((k ...) e1 e2 ...)
                                   (syntax (if (memv t '(k ...))
                                               (begin e1 e2 ...)
                                               rest)))))))))
           (syntax (let ((t e)) body)))))))
  
  (define-syntax =>
    (lambda (x)
      (syntax-error)))
  
  (define-syntax else
    (lambda (x)
      (syntax-error)))
  
  (define-syntax do
    (lambda (orig-x)
      (syntax-case orig-x ()
        ((_ ((var init . step) ...) (e0 e1 ...) c ...)
         (with-syntax (((step ...)
                        (map (lambda (v s)
                               (syntax-case s ()
                                 (()  v)
                                 ((e) (syntax e))
                                 (_   (syntax-error orig-x))))
                             (syntax (var ...))
                             (syntax (step ...)))))
           (syntax-case (syntax (e1 ...)) ()
             (()          (syntax (let do ((var init) ...)
                                    (if (not e0)
                                        (begin c ... (do step ...))))))
             ((e1 e2 ...) (syntax (let do ((var init) ...)
                                    (if e0
                                        (begin e1 e2 ...)
                                        (begin c ... (do step ...)))))))))))) 
  ) ; derived

(library (core identifier-syntax)
  (export identifier-syntax)
  (import (for (core primitives)  expand run (meta -1))  ; since generated macro contains (syntax set!) at level 0
          (for (core with-syntax) expand)                ;                   => set! is at level -1 
          (for (core derived)     expand))               ; for and  
  
  (define-syntax identifier-syntax
    (lambda (x)
      (syntax-case x (set!)
        ((_ e)
         (syntax (lambda (x)
                   (syntax-case x ()
                     (id (identifier? (syntax id)) (syntax e))
                     ((_ x (... ...))              (syntax (e x (... ...))))))))
        ((_ (id exp1) 
            ((set! var val) exp2))
         (and (identifier? (syntax id)) 
              (identifier? (syntax var)))
         (syntax 
          (make-variable-transformer
           (lambda (x)
             (syntax-case x (set!)
               ((set! var val)               (syntax exp2))
               ((id x (... ...))             (syntax (exp1 x (... ...))))
               (id (identifier? (syntax id)) (syntax exp1))))))))))
  )

;;;=========================================================
;;;
;;; Quasisyntax in terms of syntax-case.
;;;
;;;=========================================================
;;;
;;; To make nested unquote-splicing behave in a useful way,
;;; the R5RS-compatible extension of quasiquote in appendix B
;;; of the following paper is here ported to quasisyntax:
;;;
;;; Alan Bawden - Quasiquotation in Lisp
;;; http://citeseer.ist.psu.edu/bawden99quasiquotation.html
;;;
;;; The algorithm converts a quasisyntax expression to an
;;; equivalent with-syntax expression.
;;; For example:
;;;
;;; (quasisyntax (set! ,a ,b))
;;;   ==> (with-syntax ((t0 a)
;;;                     (t1 b))
;;;         (syntax (set! t0 t1)))
;;;
;;; (quasisyntax (list ,@args))
;;;   ==> (with-syntax (((t ...) args))
;;;         (syntax (list t ...)))
;;;
;;; Note that quasisyntax is expanded first, before any
;;; ellipses act.  For example:
;;;
;;; (quasisyntax (f ((b ,a) ...))
;;;   ==> (with-syntax ((t a))
;;;         (syntax (f ((b t) ...))))
;;;
;;; so that
;;;
;;; (let-syntax ((test-ellipses-over-unsyntax
;;;               (lambda (e)
;;;                 (let ((a (syntax a)))
;;;                   (with-syntax (((b ...) (syntax (1 2 3))))
;;;                     (quasisyntax
;;;                      (quote ((b ,a) ...))))))))
;;;   (test-ellipses-over-unsyntax))
;;;
;;;     ==> ((1 a) (2 a) (3 a))

;; Unquote and unquote-syntax are shared by quasiquote
;; below, so we factor it out.

(library (core unquoting)
  (export unquote unquote-splicing)
  (import (for (core primitives) run expand))
  
  (define-syntax unquote
    (lambda (e)
      (syntax-error)))
  
  (define-syntax unquote-splicing
    (lambda (e)
      (syntax-error)))
  )
  
(library (core quasisyntax)
  (export quasisyntax unquote unquote-splicing) 
  (import (for (core primitives)  run expand) 
          (for (core let)         run expand) 
          (for (core derived)     run expand)
          (for (core unquoting)   run)              ;; unquote(-splicing) will only be exported at 0
          (for (core with-syntax) run expand))      ;; with-syntax needed at run since we expand to it
  
  (define-syntax quasisyntax
    (lambda (e)
      
      ;; Expand returns a list of the form
      ;;    [template[t/e, ...] (replacement ...)]
      ;; Here template[t/e ...] denotes the original template
      ;; with unquoted expressions e replaced by fresh
      ;; variables t, followed by the appropriate ellipses
      ;; if e is also spliced.
      ;; The second part of the return value is the list of
      ;; replacements, each of the form (t e) if e is just
      ;; unquoted, or ((t ...) e) if e is also spliced.
      ;; This will be the list of bindings of the resulting
      ;; with-syntax expression.
      
      (define (expand x level)
        (with-syntax ((::: (datum->syntax (syntax here) '...)))
          (syntax-case x (quasisyntax unquote unquote-splicing)
            ((quasisyntax e)
             (with-syntax (((k _)     x) ;; original identifier must be copied
                           ([e* reps] (expand (syntax e) (+ level 1))))
               (syntax [(k e*) reps])))                                  
            ((unquote e)
             (= level 0)
             (with-syntax (((t) (generate-temporaries '(t))))
               (syntax [t ((t e))])))
            (((unquote e ...) . r)
             (= level 0)
             (with-syntax (([r* (rep ...)] (expand (syntax r) 0))
                           ((t ...)        (generate-temporaries (syntax (e ...)))))
               (syntax [(t ... . r*)
                        ((t e) ... rep ...)])))
            (((unquote-splicing e ...) . r)
             (= level 0)
             (with-syntax (([r* (rep ...)] (expand (syntax r) 0))
                           ((t ...)        (generate-temporaries (syntax (e ...)))))
               (with-syntax ((((t ...) ...) (syntax ((t :::) ...))))
                 (syntax [(t ... ... . r*)
                          (((t ...) e) ... rep ...)]))))
            ((k . r)
             (and (> level 0)
                  (identifier? (syntax k))
                  (or (free-identifier=? (syntax k) (syntax unquote))
                      (free-identifier=? (syntax k) (syntax unquote-splicing))))
             (with-syntax (([r* reps] (expand (syntax r) (- level 1))))
               (syntax [(k . r*) reps])))
            ((h . t)
             (with-syntax (([h* (rep1 ...)] (expand (syntax h) level))
                           ([t* (rep2 ...)] (expand (syntax t) level)))
               (syntax [(h* . t*)
                        (rep1 ... rep2 ...)])))
            (#(e ...)                                                               
             (with-syntax (([(e* ...) reps]
                            (expand (vector->list (syntax #(e ...))) level)))
               (syntax [#(e* ...) reps])))
            (other
             (syntax [other ()])))))
      
      (syntax-case e ()
        ((_ template)
         (with-syntax (([template* replacements] (expand (syntax template) 0)))
           (syntax
            (with-syntax replacements (syntax template*))))))))
  )

;; Since unquote(-syntax) are used at run and expand, but
;; should only be exported for expand, we need a helper library 
;; here.

(library (core quasiquote helper)
  (export quasiquote)
  (import (for (core primitives)  run expand) 
          (for (core let)         run expand) 
          (for (core derived)     run expand) 
          (for (core with-syntax) expand)
          (for (core unquoting)   run expand)  
          (for (core quasisyntax) expand))
  
  ;; Unoptimized.  See Dybvig source for optimized version.
  
  (define-syntax quasiquote
    (lambda (s)
      (define (qq-expand x level)
        (syntax-case x (quasiquote unquote unquote-splicing)
          (`x                             (quasisyntax (list 'quasiquote
                                                             ,(qq-expand (syntax x) (+ level 1)))))
          (,x (> level 0)                 (quasisyntax (cons 'unquote
                                                             ,(qq-expand (syntax x) (- level 1)))))
          (,@x (> level 0)                (quasisyntax (cons 'unquote-splicing
                                                             ,(qq-expand (syntax x) (- level 1)))))
          (,x (= level 0)                 x)
          
          (((unquote x ...) . y)
           (= level 0)                    (quasisyntax (append (list x ...)
                                                               ,(qq-expand (syntax y) 0))))
          (((unquote-splicing x ...) . y)
           (= level 0)                    (quasisyntax (append (append x ...)
                                                               ,(qq-expand (syntax y) 0))))
          ((x . y)                        (quasisyntax (cons  ,(qq-expand (syntax x) level)
                                                              ,(qq-expand (syntax y) level))))
          (#(x ...)                       (quasisyntax (list->vector ,(qq-expand (syntax (x ...))    
                                                                                 level))))
          (x  (syntax 'x))))
      (syntax-case s ()
        ((_ x) (qq-expand (syntax x) 0)))))
  )

;; Composes previous so unquote(-splicing) only exported at level 0.

(library (core quasiquote)
  (export quasiquote unquote unquote-splicing)
  (import (core quasiquote helper)
          (core unquoting)))
          

(library (r6rs)         
  
  (export 
   
   ;; Standard primitives:
     
   * + - / < <= = > >= abs acos append apply asin assoc assq assv atan 
   boolean? call-with-current-continuation call-with-input-file
   call-with-output-file call-with-values call/cc car cdr caar cadr cdar cddr
   caaar caadr cadar caddr cdaar cdadr cddar cdddr caaaar caaadr caadar caaddr cadaar
   cadadr caddar cadddr cdaaar cdaadr cdadar cdaddr cddaar cddadr cdddar cddddr
   ceiling char->integer char-alphabetic? char-ci<=? char-ci<? char-ci=? char-ci>=?
   char-ci>? char-downcase char-lower-case? char-numeric? char-ready? char-upcase
   char-upper-case? char-whitespace? char<=? char<? char=? char>=? char>? char?
   close-input-port close-output-port complex? cons cos current-input-port
   current-output-port denominator display dynamic-wind eof-object?
   eq? equal? eqv? even? exact->inexact exact? exp expt floor for-each
   gcd imag-part inexact->exact inexact? input-port? integer->char integer?
   interaction-environment lcm length list list->string
   list->vector list-ref list-tail list? log magnitude make-polar
   make-rectangular make-string make-vector map max member memq memv min modulo
   negative? newline not null-environment null? number->string number? numerator
   odd? open-input-file open-output-file output-port? pair? peek-char port?
   positive? procedure? quotient rational? rationalize read
   read-char real-part real? remainder reverse round scheme-report-environment
   set-car! set-cdr! sin sqrt string string->list string->number string->symbol
   string-append string-ci<=? string-ci<? string-ci=? string-ci>=? string-ci>?
   string-copy string-fill! string-length string-ref string-set! string<=? string<?
   string=? string>=? string>? string? substring symbol->string symbol? tan
   transcript-off transcript-on truncate unbound values vector vector->list
   vector-fill! vector-length vector-ref vector-set! vector? with-input-from-file 
   with-output-to-file write write-char zero?
   
   ;; R6RS additions:
   
   unspecified
   
   ;; Additions defined in the core expander:
   
   begin if set! lambda quote
   define define-syntax let-syntax letrec-syntax make-variable-transformer
   syntax syntax-case identifier? bound-identifier=? free-identifier=?
   generate-temporaries datum->syntax syntax->datum 
   syntax-warning syntax-error _ ...
   declare unsafe safe fast small debug
   
   ;; indirect-export - removed
   
   load eval environment
   
   ;; Derived syntax:
   
   let let* letrec letrec*
   and or case cond do else =>
   with-syntax syntax-rules identifier-syntax
   quasisyntax quasiquote unquote unquote-splicing)
  
  (import (for (core primitives)        run expand)
          (for (core let)               run expand)             
          (for (core derived)           run expand)                
          (for (core with-syntax)       run expand)           
          (for (core syntax-rules)      run expand)          
          (for (core identifier-syntax) run expand)      
          (for (core quasisyntax)       run expand)        
          (for (core quasiquote)        run expand))    
  
  ) ;; r6rs


