#|

immutability: would somehow have to have Qtoc function produce a store, either with identifiers that mean mutable, or with identifiers that mean immutable. not sure how to do that nicely. it would have to produce two "values", but then how to destructure them in the rule?

|#

(module r6rs mzscheme
  (require (planet "reduction-semantics.ss" ("robby" "redex.plt" 3))
           (lib "plt-match.ss"))
  
  (provide lang 
           reductions
           r6rs-subst-one
           Var-set!d?)
  
  (provide Arithmetic
           Basic--syntactic--forms
           Cons 
           Cons-cell--mutation
           Procedure--application
           Apply
           Call-cc--and--dynamic-wind
           Exceptions
           Multiple--values--and--call-with-values
           Quote
           Top--level--and--Variables
           Underspecification
           observable)

  (define lang
    (language
     (p* (store (sf ...) (ds ...)) (uncaught-exception v) (unknown string))
     (a* (store (sf ...) ((values v ...))) (uncaught-exception v) (unknown string))
     (r* (values r*v ...) exception unknown)
     (r*v  unspecified pair null 'sym sqv condition procedure)
     (sf (x v) (pp (cons v v)))
     (ds (define x es) (beginF ds ...) es)
     
     (es 'snv (begin es es ...) (begin0 es es ...) (es es ...)
         (if es es es) (set! x es) x
         nonproc pproc
         (dw x es es es) (throw x (d d ...))
         (handlers es ... es)
         (lambda (x ...) 
           es
           es ...)
         (lambda (x ... dot x)
           es
           es ...))
     
     (s snv sym)
     (snv (s ...) (s ... dot sqv) (s ... dot sym) sqv)
     
     (p (store (sf ...) (d ...)))
     (d (define x e) (beginF d ...) e)
     (e (begin e e ...) (begin0 e e ...)
        (e e ...) (if e e e)
        (set! x e) (handlers e ... e)
        x nonproc proc (dw x e e e))
     (v (unspecified) nonproc proc)
     (nonproc pp null 'sym sqv (condition string))
     (sqv n #t #f)
     
     (proc uproc pproc (throw x (d d ...)))
     (uproc (lambda (x ...) e e ...) (lambda (x ... dot x) e e ...))
     (pproc aproc proc1 proc2 list dynamic-wind apply values unspecified)
     (proc1 null? pair? car cdr call/cc procedure? condition? unspecified? raise*)
     (proc2 cons set-car! set-cdr! eqv? call-with-values with-exception-handler)
     (aproc + - / *)
     (raise* raise-continuable raise)
     
     (sym (variable-except dot))
     
     (x (side-condition 
         (name var_none
               (variable-except 
                dot                         ; the . in dotted pairs
                lambda if loc set!          ; core syntax names
                quote
                begin begin0
                
                null                      ; non-function values
                unspecified
                pair closure
                
                error                       ; signal an error
                
                beginF define               ; top-level stuff
                
                procedure? unspecified? condition?
                cons pair? null? car cdr       ; list functions
                set-car! set-cdr! list
                + - * /                          ; math functions
                call/cc throw dw dynamic-wind  ; call/cc functions
                values call-with-values              ; values functions
                apply eqv?
                
                with-exception-handler handlers
                raise-continuable raise))
         (not (pp? (term var_none)))))
     
     ; pair pointer
     (pp (variable-prefix pp))
     
     (n number)
     
     (P (store (sf ...) W))
     (W (D d ...))
     (D (define x Eo) E*)
     
     (E (in-hole F (handlers v ... E*)) (in-hole F (dw x e E* e)) F)
     (E* (hole multi) E)
     (Eo (hole single) E)
     
     (F hole (v ... Fo v ...) (if Fo e e) (set! x Fo) 
        (begin F* e e ...) (begin0 F* e e ...) (begin0 (values v ...) F* e ...)
        (call-with-values (lambda () F* e ...) v))
     (F* (hole multi) F)
     (Fo (hole single) F)
     
     ;; everything except exception handler bodies
     (PG (store (sf ...) ((define x G) d ...)) (store (sf ...) (G d ...)))
     (G (in-hole F (dw x e G e)) F)
     
     ;; everything except dw
     (H (in-hole F (handlers v ... H)) F)
     
     (SD S (define x S) (beginF d ... SD ds ...))
     (S hole (begin e e ... S es ...) (begin S es ...)
        (begin0 e e ... S es ...) (begin0 S es ...)
        (e ... S es ...) (if S es es) (if e S es) (if e e S)
        (set! x S) (handlers s ... S es ... es) (handlers s ... S)
        (throw x (e e ...)) (lambda (x ...) S es ...) (lambda (x ...) e e ... S es ...)
        (lambda (x ... dot x) S es ...) (lambda (x ... dot x) e e ... S es ...))))

  (define Basic--syntactic--forms
    (reduction-relation
     lang
     ;; if
     (--> (in-hole P_1 (if v_1 e_1 e_2)) (in-hole P_1 e_1) "6if3t"
          (side-condition (not (eq? (term v_1) #f))))
     (--> (in-hole P_1 (if #f e_1 e_2))
          (in-hole P_1 e_2)
          "6if3f")
     
     ;; begin
     (--> (in-hole P_1 (begin (values v ...) e_1 e_2 ...))
          (in-hole P_1 (begin e_1 e_2 ...))
          "6beginc")
     (--> (in-hole P_1 (begin e_1)) (in-hole P_1 e_1) "6begind")
     
     ;; begin0
     (--> (in-hole P_1 (begin0 (values v_1 ...) (values v_2 ...) e_2 ...))
          (in-hole P_1 (begin0 (values v_1 ...) e_2 ...))
          "6begin0n")
     (--> (in-hole P_1 (begin0 e_1)) (in-hole P_1 e_1) "6begin01")))
  
  (define Arithmetic
    (reduction-relation
     lang
     ;; primitives for numbers
     (--> (in-hole P_1 (+)) (in-hole P_1 0) "6+0")
     (--> (in-hole P_1 (+ n_1 n_2 ...)) (in-hole P_1 ,(sum-of (term (n_1 n_2 ...)))) "6+")
     
     (--> (in-hole P_1 (- n_1)) (in-hole P_1 ,(- (term n_1))) "6u-")
     (--> (in-hole P_1 (- n_1 n_2 n_3 ...)) 
          (in-hole P_1 ,(- (term n_1) (sum-of (term (n_2 n_3 ...)))))
          "6-")
     (--> (in-hole P_1 (-))
          (in-hole P_1 (raise (condition "arity mismatch")))
          "6-arity")
     
     (--> (in-hole P_1 (*)) (in-hole P_1 1) "6*1")
     (--> (in-hole P_1 (* n_1 n_2 ...)) (in-hole P_1 ,(product-of (term (n_1 n_2 ...)))) "6*")
     
     (--> (in-hole P_1 (/ n_1)) (in-hole P_1 (/ 1 n_1))
          "6u/")
     (--> (in-hole P_1 (/ n_1 n_2 n_3 ...))
          (in-hole P_1 ,(/ (term n_1) (product-of (term (n_2 n_3 ...)))))
          "6/"
          (side-condition (not (member 0 (term (n_2 n_3 ...))))))
     (--> (in-hole P_1 (/ n n ... 0 n ...))
          (in-hole P_1 (raise (condition "divison by zero")))
          "6/0")
     (--> (in-hole P_1 (/))
          (in-hole P_1 (raise (condition "arity mismatch")))
          "6/arity")
     
     (--> (in-hole P_1 (aproc v_1 ...))
          (in-hole P_1 (raise (condition "arith-op applied to non-number")))
          "6ae"
          (side-condition
           (ormap (lambda (v) (not (number? v)))
                  (term (v_1 ...)))))))
  
  (define (sum-of x) (apply + x))
  (define (product-of x) (apply * x))
  
  (define Cons-cell--mutation
    (reduction-relation
     lang
     
     (--> (store (sf_1 ... (pp_1 (cons v_1 v_2)) sf_2 ...)
                 (in-hole W_1 (set-car! pp_1 v_3)))
          (store (sf_1 ... (pp_1 (cons v_3 v_2)) sf_2 ...)
                 (in-hole W_1 (unspecified)))
          "6setcar")

     (--> (store (sf_1
                  ...
                  (pp_1 (cons v_1 v_2))
                  sf_2 ...)
                 (in-hole W_1 (set-cdr! pp_1 v_3)))
          (store (sf_1 
                  ... 
                  (pp_1 (cons v_1 v_3))
                  sf_2 ...)
                 (in-hole W_1 (unspecified)))
          "6setcdr")
     
     (--> (in-hole P_1 (set-car! v_1 v_2))
          (in-hole P_1 (raise (condition "can't set-car! on a non-pair")))
          "6scare"
          (side-condition (not (pp? (term v_1)))))
     
     (--> (in-hole P_1 (set-cdr! v_1 v_2))
          (in-hole P_1 (raise (condition "can't set-cdr! on a non-pair")))
          "6scdre"
          (side-condition (not (pp? (term v_1)))))
     
     (--> (in-hole P_1 (eqv? v_1 v_1))
          (in-hole P_1 #t)
          "6eqt"
          (side-condition (not (proc? (term v_1))))
          (side-condition (not (condition? (term v_1)))))
     
     
     (--> (in-hole P_1 (eqv? v_1 v_2))
          (in-hole P_1 #f)
          "6eqf"
          (side-condition (not (proc? (term v_1))))
          (side-condition (not (proc? (term v_2))))
          (side-condition (not (condition? (term v_1))))
          (side-condition (not (condition? (term v_2))))
          (side-condition (not (equal? (term v_1) (term v_2)))))))
  
  (define Cons
    (reduction-relation
     lang
  
     (--> (store (sf_1 ...)
                 (in-hole W_1 (cons v_1 v_2)))
          (store (sf_1 ... (pp (cons v_1 v_2)))
                 (in-hole W_1 pp))
          "6cons"
          (fresh pp))
     
     (--> (in-hole P_1 (list v_1 v_2 ...))
          (in-hole P_1 (cons v_1 (list v_2 ...)))
          "6listc")
     (--> (in-hole P_1 (list))
          (in-hole P_1 null)
          "6listn")
     
     ;; car
     (--> (store (sf_1 ... (pp_i (cons v_1 v_2)) sf_2 ...)
                 (in-hole W_1 (car pp_i)))
          (store (sf_1 ... (pp_i (cons v_1 v_2)) sf_2 ...)
                 (in-hole W_1 v_1))
          "6car")

     ;; cdr
     (--> (store (sf_1 ... (pp_i (cons v_1 v_2)) sf_2 ...)
                 (in-hole W_1 (cdr pp_i)))
          (store (sf_1 ... (pp_i (cons v_1 v_2)) sf_2 ...)
                 (in-hole W_1 v_2))
          "6cdr")

     ;; null?
     (--> (in-hole P_1 (null? null))
          (in-hole P_1 #t)
          "6null?t")
     (--> (in-hole P_1 (null? v_1))
          (in-hole P_1 #f)
          "6null?f"
          (side-condition (not (null-v? (term v_1)))))
     
     (--> (in-hole P_1 (pair? pp))
          (in-hole P_1 #t)
          "6pair?t")
     (--> (in-hole P_1 (pair? v_1))
          (in-hole P_1 #f)
          "6pair?f"
          (side-condition (not (pp? (term v_1)))))
     
     (--> (in-hole P_1 (car v_i))
          (in-hole P_1 (raise (condition "can't take car of non-pair")))
          "6care"
          (side-condition (not (pp? (term v_i)))))
     
     (--> (in-hole P_1 (cdr v_i))
          (in-hole P_1 (raise (condition "can't take cdr of non-pair")))
          "6cdre"
          (side-condition (not (pp? (term v_i)))))))
  
  (define Procedure--application
    (reduction-relation
     lang
     
     (--> (in-hole P_1 (e_1 ... e_i e_i+1 ...))
          (in-hole P_1 ((lambda (x) (e_1 ... x e_i+1 ...)) e_i))
          "6mark"
          (fresh x)
          (side-condition (not (v? (term e_i))))
          (side-condition 
           (ormap (lambda (e) (not (v? e))) (term (e_1 ... e_i+1 ...)))))
     
     (--> (store (sf_1 ...) (in-hole W_1 ((lambda (x_1 x_2 ...) e_1 e_2 ...) v_1 v_2 ...)))
          (store (sf_1 ... (bp v_1))
                 (in-hole W_1
                          ((r6rs-subst-one (x_1 bp (lambda (x_2 ...) e_1 e_2 ...)))
                            v_2 ...)))
          "6appN!"
          (fresh bp)
          (side-condition
           (and (= (length (term (x_2 ...))) 
                   (length (term (v_2 ...))))
                (term (Var-set!d? (x_1 (lambda (x_2 ...) e_1 e_2 ...)))))))
     
     (--> (in-hole P_1 ((lambda (x_1 x_2 ...) e_1 e_2 ...) v_1 v_2 ...))
          (in-hole P_1 ((r6rs-subst-one (x_1 v_1 (lambda (x_2 ...) e_1 e_2 ...))) v_2 ...))
          "6appN"
          (side-condition
           (and (= (length (term (x_2 ...))) 
                   (length (term (v_2 ...))))
                (not (term (Var-set!d? (x_1 (lambda (x_2 ...) e_1 e_2 ...))))))))
     
     (--> (in-hole P_1 ((lambda () e_1 e_2 ...)))
          (in-hole P_1 (begin e_1 e_2 ...))
          "6app0")
     
     (--> (in-hole P_1 ((lambda (x_1 ...) e e ...) v_1 ...))
          (in-hole P_1 (raise (condition "arity mismatch")))
          "6arity"
          (side-condition
           (not (= (length (term (x_1 ...)))
                   (length (term (v_1 ...)))))))
     
     (--> (in-hole P_1 ((lambda (x_1 ... dot x_r) e_1 e_2 ...) v_1 ... v_2 ...))
          (in-hole P_1 ((lambda (x_1 ... x_r) e_1 e_2 ...) v_1 ... (list v_2 ...)))
          "6μapp"
          (side-condition
           (= (length (term (v_1 ...))) (length (term (x_1 ...))))))
     
     ;; mu-lambda too few arguments case
     (--> (in-hole P_1 ((lambda (x_1 ... dot x) e e ...) v_1 ...))
          (in-hole P_1 (raise (condition "arity mismatch")))
          "6μarity"
          (side-condition
           (< (length (term (v_1 ...)))
              (length (term (x_1 ...))))))
     
     (--> (in-hole P_1 (procedure? proc)) (in-hole P_1 #t) "6proct")
     (--> (in-hole P_1 (procedure? nonproc)) (in-hole P_1 #f) "6procf")
     (--> (in-hole P_1 (procedure? (unspecified))) (in-hole P_1 #f) "6procu")
     
     (--> (in-hole P_1 (nonproc v ...))
          (in-hole P_1 (raise (condition "can't call non-procedure")))
          "6appe")
     
     (--> (in-hole P_1 ((unspecified) v ...))
          (in-hole P_1 (raise (condition "can't call non-procedure")))
          "6appun")
     
     (--> (in-hole P_1 (proc1 v_1 ...))
          (in-hole P_1 (raise (condition "arity mismatch")))
          "61arity"
          (side-condition (not (= (length (term (v_1 ...))) 1))))
     (--> (in-hole P_1 (proc2 v_1 ...))
          (in-hole P_1 (raise (condition "arity mismatch")))
          "62arity"
          (side-condition (not (= (length (term (v_1 ...))) 2))))
     (--> (in-hole P_1 (unspecified v_1 v_2 ...))
          (in-hole P_1 (raise (condition "arity mismatch")))
          "6unarity")))
  
  (define Apply
    (reduction-relation
     lang
     
     (--> (in-hole P_1 (apply proc_1 v_1 ... null))
          (in-hole P_1 (proc_1 v_1 ...))
          "6applyf")
     
     (--> (store (sf_1
                  ...
                  (pp_i (cons v_2 v_3))
                  sf_2 ...)
                 (in-hole W_1 (apply proc_1 v_1 ... pp_i)))
          (store (sf_1
                  ...
                  (pp_i (cons v_2 v_3))
                  sf_2 ...)
                 (in-hole  W_1
                           (apply proc_1 v_1 ... v_2 v_3)))
          "6applyc")
     
     
     (--> (in-hole P_1 (apply nonproc v ...))
          (in-hole P_1 (raise (condition "can't apply non-procedure")))
          "6applynf")
     
     (--> (in-hole P_1 (apply (unspecified) v ...))
          (in-hole P_1 (raise (condition "can't apply non-procedure")))
          "6applyun")
     
     (--> (in-hole P_1 (apply proc v_1 ... v_2))
          (in-hole P_1 (raise (condition "apply's last argument non-list")))
          "6applye"
          (side-condition (not (list-v? (term v_2)))))
     
     (--> (in-hole P_1 (apply)) (in-hole P_1 (raise (condition "arity mismatch"))) "6apparity0")
     (--> (in-hole P_1 (apply v)) (in-hole P_1 (raise (condition "arity mismatch"))) "6apparity1")))
  
  ;; Var-set!d? : e -> boolean
  (define-metafunction Var-set!d?
    lang
    [(x_1 (e_1 e_2 e_3 ...)) 
     ,(or (term (Var-set!d? (x_1 e_1)))
          (term (Var-set!d? (x_1 (e_2 e_3 ...)))))]
    [(x_1 (e_1)) 
     (Var-set!d? (x_1 e_1))]
    [(x_1 (if e_1 e_2 e_3))
     ,(or (term (Var-set!d? (x_1 e_1)))
          (term (Var-set!d? (x_1 e_2)))
          (term (Var-set!d? (x_1 e_3))))]
    [(x_1 (set! x_1 e)) #t]
    [(side-condition (x_1 (set! x_2 e_1))
                     (not (eq? (term x_1) (term x_2))))
     (Var-set!d? (x_1 e_1))]
    [(x_1 (begin e_1 e_2 e_3 ...))
     ,(or (term (Var-set!d? (x_1 e_1)))
          (term (Var-set!d? (x_1 (begin e_2 e_3 ...)))))]
    [(x_1 (begin e_1))
     (Var-set!d? (x_1 e_1))]
    [(x_1 (begin0 e_1 e_2 e_3 ...))
     ,(or (term (Var-set!d? (x_1 e_1)))
          (term (Var-set!d? (x_1 (begin0 e_2 e_3 ...)))))]
    [(x_1 (begin0 e_1))
     (Var-set!d? (x_1 e_1))]
    [(x_1 (lambda (x ... x_1 x ...) e e ...)) #f]
    [(side-condition (x_1 (lambda (x_2 ...) e_1 e_2 ...)) 
                     (not (memq (term x_1) (term (x_2  ...)))))
     (Var-set!d? (x_1 (begin e_1 e_2 ...)))]
    [(x_1 (lambda (x ... x_1 x ... dot x) e e ...)) #f]
    [(x_1 (lambda (x ... dot x_1) e e ...)) #f]
    [(side-condition (x_1 (lambda (x_2 ... dot x_3) e_1 e_2 ...)) 
                     (not (memq (term x_1) (term (x_2 ... x_3)))))
     (Var-set!d? (x_1 (begin e_1 e_2 ...)))]
    [(x_1 x_2) #f]
    [(x_1 v) #f]
    [(x_1 (dw x_2 e_1 e_2 e_3))
     ,(or (term (Var-set!d? (x_1 e_1)))
          (term (Var-set!d? (x_1 e_2)))
          (term (Var-set!d? (x_1 e_3))))]
    [(x_1 hole) #f]
    [(x_1 (hole single)) #f]
    [(x_1 (hole multi)) #f])
     
     
  (define Call-cc--and--dynamic-wind
    (reduction-relation
     lang
     (--> (in-hole P_1 (dynamic-wind v_1 v_2 v_3))
          (in-hole P_1 
                   (begin (v_1)
                          (begin0
                            (dw x (v_1) (v_2) (v_3))
                            (v_3))))
          "6wind"
          (fresh x)
          (side-condition 
           (and (term (A_0 v_1))
                (term (A_0 v_2))
                (term (A_0 v_3)))))
     
     (--> (in-hole P_1 (dynamic-wind v_1 v_2 v_3))
          (in-hole P_1 (raise (condition "dynamic-wind expects arity 0 procs")))
          "6dwerr"
          (side-condition 
           (or (not (term (A_0 v_1)))
               (not (term (A_0 v_2)))
               (not (term (A_0 v_3))))))
     
     (--> (in-hole P_1 (dynamic-wind v_1 ...))
          (in-hole P_1 (raise (condition "arity mismatch")))
          "6dwarity"
          (side-condition (not (= (length (term (v_1 ...))) 3))))
     
     (--> (in-hole P_1 (dw x e (values v_1 ...) e))
          (in-hole P_1 (values v_1 ...))
          "6dwdone")
     
     (--> (store (sf_1 ...) (in-hole W_1 (call/cc v_1)))
          (store (sf_1 ...) (in-hole W_1 (v_1 (throw x (in-hole W_1 x)))))
          "6call/cc"
          (fresh x))
     
     (--> (store (sf_1 ...) ((in-hole D_1 ((throw x_1 ((in-hole D_2 x_1) d_1 ...)) v_1 ...)) d_2 ...))
           (store (sf_1 ...) 
                  ((in-hole (Trim (D_1 D_2)) (values v_1 ...))
                  d_1 ...))
          "6throw")))
  
  (define-metafunction pRe
    lang
    [(in-hole H_1 (dw x_1 e_1 E_1 e_2)) 
     (in-hole H_1
              (begin e_1 
                     (dw x_1 e_1 (pRe E_1) e_2)))]
    [H_1 H_1])
  
  (define-metafunction poSt
    lang
    [(in-hole E_1 (dw x_1 e_1 H_2 e_2))
     (in-hole (poSt E_1) (begin0 (dw x_1 e_1 hole e_2) e_2))]
    [H_1 hole])
  
  (define-metafunction Trim
    lang
    [((define x_1 E_1) (define x_2 E_2))
     (define x_2 (Trim (E_1 E_2)))]
    [(E_1 (define x_2 E_2))
     (define x_2 (Trim (E_1 E_2)))]
    [((define x_1 E_1) E_2)
     (Trim (E_1 E_2))]
    [((in-hole H_1 (dw x_1 e_1 E_1 e_2))
      (in-hole H_2 (dw x_1 e_3 E_2 e_4)))
     (in-hole H_2 (dw x_1 e_3 (Trim (E_1 E_2)) e_4))]
    [(E_1 E_2)
     (begin (in-hole (poSt E_1) 1)
            (pRe E_2))])

  (define Exceptions
    (reduction-relation
     lang
     
     (--> (in-hole PG (raise* v_1))
          (uncaught-exception v_1)
          "6xunee")
     
     (--> (in-hole P (handlers (in-hole G (raise* v_1))))
          (uncaught-exception v_1)
          "6xuneh")
     
     (--> (in-hole PG_1 (with-exception-handler v_1 v_2))
          (in-hole PG_1 (handlers v_1 (v_2)))
          "6xweh1"
          (side-condition (term (A_1 v_1)))
          (side-condition (term (A_0 v_2))))
     
     (--> (in-hole P_1 (handlers v_1 ... (in-hole G_1 (with-exception-handler v_2 v_3))))
          (in-hole P_1 (handlers v_1 ... (in-hole G_1 (handlers v_1 ... v_2 (v_3)))))
          "6xwehn"
          (side-condition (term (A_1 v_2)))
          (side-condition (term (A_0 v_3))))
     
     (--> (in-hole P_1 (handlers v_1 ... v_2 (in-hole G_1 (raise-continuable v_3))))
          (in-hole P_1 (handlers v_1 ... v_2 (in-hole G_1 (handlers v_1 ... (v_2 v_3)))))
          "6xraisec")
     
     (--> (in-hole P_1 (handlers 
                        v_1 ... v_2
                        (in-hole G_1 (raise v_3))))
          (in-hole P_1 (handlers 
                        v_1 ... v_2 
                        (in-hole G_1 
                                 (begin (handlers v_1 ... (v_2 v_3))
                                        (raise (condition "handler returned"))))))
          "6xraise")
     
     (--> (in-hole P_1 (condition? (condition string)))
          (in-hole P_1 #t)
          "6ct")
     
     (--> (in-hole P_1 (condition? v_1))
          (in-hole P_1 #f)
          "6cf"
          (side-condition (not (condition? (term v_1)))))
     
     (--> (in-hole P_1 (handlers v_1 ... (values v_3 ...)))
          (in-hole P_1 (values v_3 ...))
          "6xdone")
     
     (--> (in-hole P_1 (with-exception-handler v_1 v_2))
          (in-hole P_1 (raise (condition "with-exception-handler bad argument")))
          "6weherr"
          (side-condition 
           (or (not (term (A_1 v_1)))
               (not (term (A_0 v_2))))))))

  (define-metafunction A_0
    lang
    [nonproc #f]
    [(unspecified) #f]
    [(lambda () e e ...) #t]
    [(lambda (x x ...) e e ...) #f]
    [(lambda (dot x) e e ...) #t]
    [(lambda (x x ... dot x) e e ...) #f]
    [+ #t]
    [* #t]
    [/ #f]
    [- #f]
    [proc1 #f]
    [proc2 #f]
    [list #t]
    [dynamic-wind #f]     
    [apply #f]
    [values #t]
    [(throw x (d d ...)) #t])
  
  (define-metafunction A_1
    lang
    [nonproc #f]
    [(unspecified) #f]
    [(lambda () e e ...) #f]
    [(lambda (x) e e ...) #t]
    [(lambda (x y z ...) e e ...) #f]
    [(lambda (dot x) e e ...) #t]
    [(lambda (x dot x) e e ...) #t]
    [(lambda (x x x ... dot x) e e ...) #f]
    [+ #t]
    [* #t]
    [/ #t]
    [- #t]
    [proc1 #t]
    [proc2 #f]
    [list #t]
    [dynamic-wind #f]
    [apply #f]
    [values #t]
    [(throw x (d d ...)) #t])
  
  (define Multiple--values--and--call-with-values
    (reduction-relation
     lang
     ;; values promotion
     (--> (in-named-hole multi P_1 v_1)
          (in-hole P_1 (values v_1))
          "6promote")
     
     ;; values demotion
     (--> (in-named-hole single P_1 (values v_1))
          (in-hole P_1 v_1)
          "6demote")
     
     ; resolving call-with-values statements
     (--> (in-hole P_1 (call-with-values (lambda () (values v_2 ...)) v_1))
          (in-hole P_1 (v_1 v_2 ...))
          "6cwvd")
     
     (--> (in-hole P_1 (call-with-values (lambda () (values v_1 ...) e_1 e_2 ...) v_2))
          (in-hole P_1 (call-with-values (lambda () e_1 e_2 ...) v_2))
          "6cwvc")
     
     (--> (in-hole P_1 (call-with-values v_1 v_2))
          (in-hole P_1 (call-with-values (lambda () (v_1)) v_2))
          "6cwvw"
          (side-condition (not (lambda-null? (term v_1)))))))
  
  
  (define Underspecification
    (reduction-relation
     lang
     (--> (in-hole P (eqv? proc proc))
          (unknown "equivalence of procedures")
          "6ueqv")
     (--> (in-hole P (eqv? v_1 v_2))
          (unknown "equivalence of conditions")
          "6ueqc"
          (side-condition (or (condition? (term v_1))
                              (condition? (term v_2)))))
     (--> (in-named-hole single P (values v_1 ...))
          (unknown ,(format "context expected one value, received ~a" (length (term (v_1 ...)))))
          "6uval"
          (side-condition (not (= (length (term (v_1 ...))) 1))))))
  
  (define Quote
    (reduction-relation
     lang
     ;; compile time quote removal
     (--> (store (sf_1 ...) 
                 (d_1
                  ...
                  (in-hole SD_1 'snv_1)
                  ds_1 ...))
          (store (sf_1 ...)
                 ((define qp (Qtoc snv_1))
                  d_1
                  ...
                  (in-hole SD_1 qp)
                  ds_1 ...))
          "6qcons"
          (fresh qp))))
  
  (define-metafunction Qtoc
    lang
    [() null]
    [(s_1 s_2 ...) (cons (Qtoc s_1) (Qtoc (s_2 ...)))]
    [(s_1 dot sqv_1) (cons (Qtoc s_1) sqv_1)]
    [(dot sqv_1) sqv_1]
    [(s_1 s_2 s_3 ... dot sqv_1) (cons (Qtoc s_1) (Qtoc (s_2 s_3 ... dot sqv_1)))]
    [(s_1 dot sym_1) (cons (Qtoc s_1) 'sym_1)]
    [(dot sym_1) 'sym_1]
    [(s_1 s_2 s_3 ... dot sym_1) (cons (Qtoc s_1) (Qtoc (s_2 s_3 ... dot sym_1)))]
    [sym_1 'sym_1]
    [sqv_1 sqv_1])
  
  (define Top--level--and--Variables
    (reduction-relation
     lang
     
     (--> (store (sf_1 ...) ((define x_1 v_1) d_1 ...))
          (store (sf_1 ... (x_1 v_1)) (d_1 ...))
          "6def"
          (side-condition (not (memq (term x_1) (map car (term (sf_1 ...)))))))

           
     ;; need redef in order to handle continuation jumps.
     (--> (store (sf_1 ... (x_1 v_1) sf_2 ...) ((define x_1 v_2) d_1 ...))
          (store (sf_1 ... (x_1 v_2) sf_2 ...) (d_1 ...))
          "6redef")

     ;; drop values (except the last one)
     (--> (store (sf_1 ...) ((values v_1 ...) d_1 d_2 ...))
          (store (sf_1 ...) (d_1 d_2 ...))
          "6valdrop")
     
     ;; if there are no expressions, make one up
     (--> (store (sf_1 ...) ())
          (store (sf_1 ...) ((values (unspecified))))
          "6valadd")

     ;; splice out begin
     (--> (store (sf_1 ...) ((beginF d_1 ...)  d_2 ...))
          (store (sf_1 ...) (d_1 ... d_2 ...))
          "6beginF")
    
     ;; variable lookup
     (--> (store (sf_1
                  ...
                  (x_1 v_1)
                  sf_2 ...)
                 (in-hole W_1 x_1))
          (store (sf_1
                  ...
                  (x_1 v_1)
                  sf_2 ...)
                 (in-hole W_1 v_1))
          "6var")
     
     ;; set!
     (--> (store (sf_1
                  ...
                  (x_1 v_1)
                  sf_2 ...)
                 (in-hole W_1 (set! x_1 v_2)))
          (store (sf_1
                  ...
                  (x_1 v_2)
                  sf_2 ...)
                 (in-hole W_1 (unspecified)))
          "6set")
     
     (--> (store (sf_1 ...) ((in-hole D_1 (set! x_1 v_2)) d_1 ... (define x_1 e_1) d_2 ...))
          (store (sf_1 ... (x_1 v_2)) ((in-hole D_1 (unspecified)) d_1 ... (define x_1 e_1) d_2 ...))
          "6setd"
          (side-condition (not (memq (term x_1) (map car (term (sf_1 ...)))))))
     
     (--> (store (sf_1 ...) ((in-hole D_1 x_1) d_1 ...))
          (store (sf_1 ...) ((in-hole D_1 (raise (condition ,(format "reference to undefined identifier: ~a" (term x_1)))))
                             d_1 ...))
          "6refu"
          (side-condition 
           (not (memq (term x_1) (map car (term (sf_1 ...)))))))
     
     (--> (store (sf_1 ...) ((in-hole D_1 (set! x_1 v_2)) d_1 ...))
          (store (sf_1 ...) ((in-hole D_1 (raise (condition ,(format "set!: cannot set undefined identifier: ~a" (term x_1)))))
                             d_1 ...))
          "6setu"
          (side-condition 
           (and (not (memq (term x_1) (map car (term (sf_1 ...)))))
                (not (defines? (term x_1) (term (d_1 ...)))))))
     
     (--> (in-hole P_1 (unspecified? (unspecified)))
          (in-hole P_1 #t)
          "6unspec?t")
     (--> (in-hole P_1 (unspecified? v_1))
          (in-hole P_1 #f)
          "6unspec?f"
          (side-condition (not (unspec? (term v_1)))))))
  
  (define (defines? var defs)
    (ormap (lambda (def) 
             (match def
               [`(define ,x ,e)
                 (eq? x var)]
               [else #f]))
           defs))
  
  (define reductions
    (union-reduction-relations
     Arithmetic
     Basic--syntactic--forms
     Cons 
     Cons-cell--mutation
     Procedure--application
     Apply
     Call-cc--and--dynamic-wind
     Exceptions
     Multiple--values--and--call-with-values
     Quote
     Top--level--and--Variables
     Underspecification))
  
  (define-metafunction r6rs-subst-one
    lang
    [(variable_1 e_1 variable_1) e_1]
    [(variable_1 e_1 variable_2) variable_2]
    [(variable_1 e_1 'any_1) 'any_1]
    [(variable_1 e (lambda (variable_2 ... dot variable_1) e_2 e_3 ...))
     (lambda (variable_2 ... dot variable_1) e_2 e_3 ...)]
    [(variable_1 e (lambda (variable_2 ... variable_1 variable_3 ... dot variable_4) e_2 e_3 ...))
     (lambda (variable_2 ... variable_1 variable_3 ... dot variable_4) e_2 e_3 ...)]
    [(variable_1 variable_2 (lambda (variable_3 ... dot variable_4) e_1 e_2 ...))
     (lambda (variable_3 ... dot variable_4) 
       (r6rs-subst-one (variable_1 variable_2 e_1))
       (r6rs-subst-one (variable_1 variable_2 e_2)) ...)]
    [(variable_1 e_1 (lambda (variable_2 ... dot variable_3) e_2 e_3 ...))
     ,(term-let ([(variable_new ... variable_new_dot) (variables-not-in (term e_1) (term (variable_2 ... variable_3)))])
        (term (lambda (variable_new ... dot variable_new_dot) 
                (r6rs-subst-one (variable_1 
                                 e_1
                                 (r6rs-subst-many ((variable_2 variable_new) ... (variable_new_dot variable_3) e_2))))
                (r6rs-subst-one (variable_1 
                                 e_1
                                 (r6rs-subst-many ((variable_2 variable_new) ... (variable_new_dot variable_3) e_3))))
                ...)))]
    [(variable_1 e_1 (lambda (variable_2 ... variable_1 variable_3 ...) e_2 e_3 ...))
     (lambda (variable_2 ... variable_1 variable_3 ...) e_2 e_3 ...)]
    [(variable_1 variable_2 (lambda (variable_3 ...) e_1 e_2 ...))
     (lambda (variable_3 ...) 
       (r6rs-subst-one (variable_1 variable_2 e_1))
       (r6rs-subst-one (variable_1 variable_2 e_2)) ...)]
    [(variable_1 e_1 (lambda (variable_2 ...) e_2 e_3 ...))
     ,(term-let ([(variable_new ...) (variables-not-in (term e_1) (term (variable_2 ...)))])
        (term (lambda (variable_new ...) 
                (r6rs-subst-one (variable_1 e_1 (r6rs-subst-many ((variable_2 variable_new) ... e_2))))
                (r6rs-subst-one (variable_1 e_1 (r6rs-subst-many ((variable_2 variable_new) ... e_3)))) ...)))]
    
    ;; last two cases cover all other expressions -- they don't have any variables, 
    ;; so we don't care about their structure. 
    [(variable_1 e_1 (any_1 ...)) ((r6rs-subst-one (variable_1 e_1 any_1)) ...)]
    [(variable_1 e_1 any_1) any_1])
  
  (define-metafunction r6rs-subst-many
    lang
    [((variable_1 e_1) (variable_2 e_2) ... e_3) 
     (r6rs-subst-one (variable_1 e_1 (r6rs-subst-many ((variable_2 e_2) ... e_3))))]
    [(e_1) e_1])
  
  (define-metafunction observable
    lang
    [(store (sf ...) ((values v_1 ...))) 
     (values (observable-value v_1) ...)]
    [(uncaught-exception v)
     exception]
    [(unknown string)
     unknown])
  
  (define-metafunction observable-value
    lang
    [(unspecified) unspecified]
    [pp_1 pair]
    [null null]
    ['sym_1 'sym_1]
    [sqv_1 sqv_1]
    [(condition string) condition]
    [proc procedure])
  
  (define unspec? (test-match lang (unspecified)))
  (define condition? (test-match lang (condition string)))
  (define v? (test-match lang v))
  (define proc? (test-match lang proc))
  (define null-v? (test-match lang null))
  (define lambda-null? (test-match lang (lambda () e)))
  (define lambda-one? (test-match lang (lambda (x) e)))
  (define pp? (test-match lang pp))
  (define es? (test-match lang es))
  (define ds? (test-match lang ds))
  (define (list-v? v) (or (pp? v) (null-v? v))))
