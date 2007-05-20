
(module r6rs mzscheme
  (require (planet "reduction-semantics.ss" ("robby" "redex.plt" 3))
           (lib "plt-match.ss"))
  
  (provide lang 
           reductions
           r6rs-subst-one
           r6rs-subst-many
           Var-set!d?)
  
  (provide Arithmetic
           Basic--syntactic--forms
           Cons 
           Eqv
           Procedure--application
           Apply
           Call-cc--and--dynamic-wind
           Exceptions
           Multiple--values--and--call-with-values
           Quote
           Top--level--and--Variables
           Letrec
           Underspecification
           observable)
  
  (define-syntax (metafunction-type stx)
    ;; these are only used in the figures
    #''ignore)

  (define lang
    (language
     (p* (store (sf ...) es) (uncaught-exception v) (unknown string))
     (a* (store (sf ...) (values v ...)) (uncaught-exception v) (unknown string))
     (r* (values r*v ...) exception unknown)
     (r*v  pair null 'sym sqv condition procedure)
     (sf (x v) (x bh) (pp (cons v v)))
     
     (es 'seq 'sqv '()
         (begin es es ...) (begin0 es es ...) (es es ...)
         (if es es es) (set! x es) x
         nonproc pproc
         (lambda f es es ...)
         (letrec ([x es] ...) es es ...) 
         (letrec* ([x es] ...) es es ...)
         
         ;; intermediate states
         (dw x es es es) 
         (throw x es)
         unspecified
         (handlers es ... es)
         (l! x es)
         (reinit x))
     (f (x ...)
        (x x ... dot x)
        x)
     
     (s seq () sqv sym)
     (seq (s s ...) (s s ... dot sqv) (s s ... dot sym))
     
     (p (store (sf ...) e))
     (e (begin e e ...) (begin0 e e ...)
        (e e ...) (if e e e)
        (set! x e) (handlers e ... e)
        x nonproc proc (dw x e e e)
        unspecified
        (letrec ([x e] ...) e e ...)
        (letrec* ([x e] ...) e e ...)
        (l! x es)
        (reinit x))
     (v nonproc proc)
     (nonproc pp null 'sym sqv (make-cond string))
     (sqv n #t #f)
     
     (proc uproc pproc (throw x e))
     (uproc (lambda f e e ...))
     (pproc aproc proc1 proc2 list dynamic-wind apply values)
     (proc1 null? pair? car cdr call/cc procedure? condition? raise*)
     (proc2 cons consi set-car! set-cdr! eqv? call-with-values with-exception-handler)
     (aproc + - / *)
     (raise* raise-continuable raise)
     
     ; pair pointers, both mutable and immutable
     (pp ip mp)
     (ip (variable-prefix ip))
     (mp (variable-prefix mp))
     
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
                
                letrec letrec* l! reinit
                
                procedure? condition?
                cons consi pair? null? car cdr       ; list functions
                set-car! set-cdr! list
                + - * /                          ; math functions
                call/cc throw dw dynamic-wind  ; call/cc functions
                values call-with-values              ; values functions
                apply eqv?
                
                with-exception-handler handlers
                raise-continuable raise))
         (not (pp? (term var_none)))))
     
     (n number)
     
     (P (store (sf ...) E*))
     
     (E (in-hole F (handlers proc ... E*)) (in-hole F (dw x e E* e)) F)
     (E* (hole multi) E)
     (Eo (hole single) E)
     
     (F hole (v ... Fo v ...) (if Fo e e) (set! x Fo)  
        (begin F* e e ...) (begin0 F* e e ...) 
        (begin0 (values v ...) F* e ...) (begin0 unspecified F* e ...)
        (call-with-values (lambda () F* e ...) v)
        (l! x Fo))

     (F* (hole multi) F)
     (Fo (hole single) F)
     
     ;; all of the one-layer contexts that "demand" their values, 
     ;; (maybe just "demand" it enough to ensure it is the right # of values)
     ;; which requires unspecified to blow up.
     (U (v ... hole v ...) (if hole e e) (set! x hole) 
        (call-with-values (lambda () hole) v))
        
     ;; everything except exception handler bodies
     (PG (store (sf ...) G))
     (G (in-hole F (dw x e G e))
        F)
     
     ;; everything except dw
     (H (in-hole F (handlers proc ... H)) F)
     
     (S hole (begin e e ... S es ...) (begin S es ...)
        (begin0 e e ... S es ...) (begin0 S es ...)
        (e ... S es ...) (if S es es) (if e S es) (if e e S)
        (set! x S) (handlers s ... S es ... es) (handlers s ... S)
        (throw x e) 
        (lambda f S es ...) (lambda f e e ... S es ...)
        (letrec ([x e] ... [x S] [x es] ...) es es ...)
        (letrec ([x e] ...) S es ...)
        (letrec ([x e] ...) e e ... S es ...)
        (letrec* ([x e] ... [x S] [x es] ...) es es ...)
        (letrec* ([x e] ...) S es ...)
        (letrec* ([x e] ...) e e ... S es ...))))

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
          (in-hole P_1 (raise (make-cond "arity mismatch")))
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
          (in-hole P_1 (raise (make-cond "divison by zero")))
          "6/0")
     (--> (in-hole P_1 (/))
          (in-hole P_1 (raise (make-cond "arity mismatch")))
          "6/arity")
     
     (--> (in-hole P_1 (aproc v_1 ...))
          (in-hole P_1 (raise (make-cond "arith-op applied to non-number")))
          "6ae"
          (side-condition
           (ormap (lambda (v) (not (number? v)))
                  (term (v_1 ...)))))))
  
  (define (sum-of x) (apply + x))
  (define (product-of x) (apply * x))
  
  (define Eqv
    (reduction-relation
     lang
     
     (--> (in-hole P_1 (eqv? v_1 v_1))
          (in-hole P_1 #t)
          "6eqt"
          (side-condition (not (proc? (term v_1))))
          (side-condition (not (condition? (term v_1))))
          (side-condition (not (ip? (term v_1)))))
     
     (--> (in-hole P_1 (eqv? v_1 v_2))
          (in-hole P_1 #f)
          "6eqf"
          (side-condition (not (equal? (term v_1) (term v_2))))
          (side-condition (or (not (proc? (term v_1)))
                              (not (proc? (term v_2)))))
          (side-condition (or (not (condition? (term v_1)))
                              (not (condition? (term v_2)))))
          (side-condition (or (not (ip? (term v_1)))
                              (not (ip? (term v_2))))))
     
     (--> (in-hole P_1 (eqv? ip_1 ip_2))
          (in-hole P_1 #t)
          "6eqipt")
     
     (--> (in-hole P_1 (eqv? ip_1 ip_2))
          (in-hole P_1 #f)
          "6eqipf")
     
     (--> (in-hole P_1 (eqv? (make-cond string) (make-cond string)))
          (in-hole P_1 #t)
          "6eqct")
     (--> (in-hole P_1 (eqv? (make-cond string) (make-cond string)))
          (in-hole P_1 #f)
          "6eqcf")))
  
  (define Cons
    (reduction-relation
     lang
  
     (--> (store (sf_1 ...) (in-hole E_1 (cons v_1 v_2)))
          (store (sf_1 ... (mp (cons v_1 v_2))) (in-hole E_1 mp))
          "6cons"
          (fresh mp))
     
     (--> (store (sf_1 ...) (in-hole E_1 (consi v_1 v_2)))
          (store (sf_1 ... (ip (cons v_1 v_2))) (in-hole E_1 ip))
          "6consi"
          (fresh ip))
     
     (--> (in-hole P_1 (list v_1 v_2 ...))
          (in-hole P_1 (cons v_1 (list v_2 ...)))
          "6listc")
     (--> (in-hole P_1 (list))
          (in-hole P_1 null)
          "6listn")
     
     ;; car
     (--> (store (sf_1 ... (pp_i (cons v_1 v_2)) sf_2 ...) (in-hole E_1 (car pp_i)))
          (store (sf_1 ... (pp_i (cons v_1 v_2)) sf_2 ...) (in-hole E_1 v_1))
          "6car")

     ;; cdr
     (--> (store (sf_1 ... (pp_i (cons v_1 v_2)) sf_2 ...) (in-hole E_1 (cdr pp_i)))
          (store (sf_1 ... (pp_i (cons v_1 v_2)) sf_2 ...) (in-hole E_1 v_2))
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
          (in-hole P_1 (raise (make-cond "can't take car of non-pair")))
          "6care"
          (side-condition (not (pp? (term v_i)))))
     
     (--> (in-hole P_1 (cdr v_i))
          (in-hole P_1 (raise (make-cond "can't take cdr of non-pair")))
          "6cdre"
          (side-condition (not (pp? (term v_i)))))
     
     (--> (store (sf_1 ... (mp_1 (cons v_1 v_2)) sf_2 ...) (in-hole E_1 (set-car! mp_1 v_3)))
          (store (sf_1 ... (mp_1 (cons v_3 v_2)) sf_2 ...) (in-hole E_1 unspecified))
          "6setcar")

     (--> (store (sf_1 ... (mp_1 (cons v_1 v_2)) sf_2 ...) (in-hole E_1 (set-cdr! mp_1 v_3)))
          (store (sf_1 ... (mp_1 (cons v_1 v_3)) sf_2 ...) (in-hole E_1 unspecified))
          "6setcdr")
     
     (--> (in-hole P_1 (set-car! v_1 v_2))
          (in-hole P_1 (raise (make-cond "can't set-car! on a non-pair or an immutable pair")))
          "6scare"
          (side-condition (not (mp? (term v_1)))))
     
     (--> (in-hole P_1 (set-cdr! v_1 v_2))
          (in-hole P_1 (raise (make-cond "can't set-cdr! on a non-pair or an immutable pair")))
          "6scdre"
          (side-condition (not (mp? (term v_1)))))))
  
  (define Procedure--application
    (reduction-relation
     lang
     
     (--> (in-hole P_1 (e_1 ... e_i e_i+1 ...))
          (in-hole P_1 ((lambda (x) (e_1 ... x e_i+1 ...)) e_i))
          "6mark"
          (fresh (x lifted))
          (side-condition (not (v? (term e_i))))
          (side-condition 
           (ormap (lambda (e) (not (v? e))) (term (e_1 ... e_i+1 ...)))))
     
     (--> (store (sf_1 ...) (in-hole E_1 ((lambda (x_1 x_2 ...) e_1 e_2 ...) v_1 v_2 ...)))
          (store (sf_1 ... (bp v_1))
            (in-hole E_1
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
          (in-hole P_1 (raise (make-cond "arity mismatch")))
          "6arity"
          (side-condition
           (not (= (length (term (x_1 ...)))
                   (length (term (v_1 ...)))))))
     
     (--> (in-hole P_1 ((lambda (x_1 x_2 ... dot x_r) e_1 e_2 ...) v_1 v_2 ... v_3 ...))
          (in-hole P_1 ((lambda (x_1 x_2 ... x_r) e_1 e_2 ...) v_1 v_2 ... (list v_3 ...)))
          "6μapp"
          (side-condition
           (= (length (term (x_2 ...))) (length (term (v_2 ...))))))
     
     ;; mu-lambda too few arguments case
     (--> (in-hole P_1 ((lambda (x_1 x_2 ... dot x) e e ...) v_1 ...))
          (in-hole P_1 (raise (make-cond "arity mismatch")))
          "6μarity"
          (side-condition
           (< (length (term (v_1 ...)))
              (length (term (x_1 x_2 ...))))))
     
     (--> (in-hole P_1 ((lambda x_1 e_1 e_2 ...) v_1 ...))
          (in-hole P_1 ((lambda (x_1) e_1 e_2 ...) (list v_1 ...)))
          "6μapp1")
     
     (--> (in-hole P_1 (procedure? proc)) (in-hole P_1 #t) "6proct")
     (--> (in-hole P_1 (procedure? nonproc)) (in-hole P_1 #f) "6procf")
     
     (--> (in-hole P_1 (nonproc v ...))
          (in-hole P_1 (raise (make-cond "can't call non-procedure")))
          "6appe")
     
     (--> (in-hole P_1 (proc1 v_1 ...))
          (in-hole P_1 (raise (make-cond "arity mismatch")))
          "61arity"
          (side-condition (not (= (length (term (v_1 ...))) 1))))
     (--> (in-hole P_1 (proc2 v_1 ...))
          (in-hole P_1 (raise (make-cond "arity mismatch")))
          "62arity"
          (side-condition (not (= (length (term (v_1 ...))) 2))))))
  
  (define Apply
    (reduction-relation
     lang
     
     (--> (in-hole P_1 (apply proc_1 v_1 ... null))
          (in-hole P_1 (proc_1 v_1 ...))
          "6applyf")
     
     (--> (store (sf_1 ... (pp_1 (cons v_2 v_3)) sf_2 ...) (in-hole E_1 (apply proc_1 v_1 ... pp_1)))
          (store (sf_1 ... (pp_1 (cons v_2 v_3)) sf_2 ...) (in-hole  E_1 (apply proc_1 v_1 ... v_2 v_3)))
          "6applyc"
          (side-condition (not (term (circular? (pp_1 v_3 (sf_1 ... (pp_1 (cons v_2 v_3)) sf_2 ...)))))))
     
     (--> (store (sf_1 ... (pp_1 (cons v_2 v_3)) sf_2 ...) (in-hole E_1 (apply proc_1 v_1 ... pp_1)))
          (store (sf_1 ... (pp_1 (cons v_2 v_3)) sf_2 ...) (in-hole  E_1 (raise (make-cond "apply called on circular list"))))
          "6applyce"
          (side-condition (term (circular? (pp_1 v_3 (sf_1 ... (pp_1 (cons v_2 v_3)) sf_2 ...))))))
     
     (--> (in-hole P_1 (apply nonproc v ...))
          (in-hole P_1 (raise (make-cond "can't apply non-procedure")))
          "6applynf")
     
     (--> (in-hole P_1 (apply proc v_1 ... v_2))
          (in-hole P_1 (raise (make-cond "apply's last argument non-list")))
          "6applye"
          (side-condition (not (list-v? (term v_2)))))
     
     (--> (in-hole P_1 (apply)) (in-hole P_1 (raise (make-cond "arity mismatch"))) "6apparity0")
     (--> (in-hole P_1 (apply v)) (in-hole P_1 (raise (make-cond "arity mismatch"))) "6apparity1")))
  
  ;; circular? : pp val store -> boolean
  ;; returns #t if pp is reachable via val in the store
  (metafunction-type circular? (-> pp val (sf ...) boolean))
  (define-metafunction circular?
    lang
    [(pp_1 pp_2 (sf_1 ... (pp_2 (cons v_1 pp_1)) sf_2 ...))
     #t]
    [(pp_1 pp_2 (sf_1 ... (pp_2 (cons v_1 v_2)) sf_2 ...))
     (circular? (pp_1 v_2 (sf_1 ... (pp_2 (cons v_1 v_2)) sf_2 ...)))]
    [(pp_1 v_1 (sf_1 ...))
     #f]) ;; otherwise
  
  ;; Var-set!d? : e -> boolean
  (metafunction-type Var-set!d? (-> x e boolean))
  (define-metafunction Var-set!d?
    lang
    [(x_1 (set! x_1 e)) #t]
    [(x_1 (set! x_2 e_1))
     (Var-set!d? (x_1 e_1))]
    
    [(x_1 (begin e_1 e_2 e_3 ...))
     ,(or (term (Var-set!d? (x_1 e_1)))
          (term (Var-set!d? (x_1 (begin e_2 e_3 ...)))))]
    [(x_1 (begin e_1))
     (Var-set!d? (x_1 e_1))]
    
    [(x_1 (e_1 e_2 ...)) 
     (Var-set!d? (x_1 (begin e_1 e_2 ...)))]
    [(x_1 (if e_1 e_2 e_3))
     ,(or (term (Var-set!d? (x_1 e_1)))
          (term (Var-set!d? (x_1 e_2)))
          (term (Var-set!d? (x_1 e_3))))]
    
    [(x_1 (begin0 e_1 e_2 ...))
     (Var-set!d? (x_1 (begin e_1 e_2 ...)))]
    
    [(x_1 (lambda (x ... x_1 x ...) e e ...)) #f]
    [(x_1 (lambda (x ... x_1 x ... dot x) e e ...)) #f]
    [(x_1 (lambda (x ... dot x_1) e e ...)) #f]
    [(x_1 (lambda x_1 e e ...)) #f]
    [(x_1 (lambda f e_1 e_2 ...))
     (Var-set!d? (x_1 (begin e_1 e_2 ...)))]
    
    [(x_1 (letrec ([x e] ... [x_1 e] [x e] ...) e e ...)) #f]
    [(x_1 (letrec ([x_2 e_1] ...) e_2 e_3 ...))
     (Var-set!d? (x_1 (begin e_1 ... e_2 e_3 ...)))]
    [(x_1 (letrec* ([x_2 e_2] ...) e_3 e_4 ...))
     (Var-set!d? (x_1 (letrec ([x_2 e_2] ...) e_3 e_4 ...)))]
    
    [(x_1 (l! x_1 e)) #t]
    [(x_1 (l! x_2 e_1)) 
     (Var-set!d? (x_1 e_1))]
    [(x_1 (reinit x_1)) #t]
    [(x_1 (reinit x_2)) #f]
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
     (--> (in-hole P_1 (dynamic-wind proc_1 proc_2 proc_3))
          (in-hole P_1 
                   (begin (proc_1)
                          (begin0
                            (dw x (proc_1) (proc_2) (proc_3))
                            (proc_3))))
          "6wind"
          (fresh x))
     (--> (in-hole P_1 (dynamic-wind v_1 v_2 v_3))
          (in-hole P_1 (raise (make-cond "dynamic-wind expects procs")))
          "6winde"
          (side-condition (or (not (proc? (term v_1)))
                              (not (proc? (term v_2)))
                              (not (proc? (term v_3))))))
     
     (--> (in-hole P_1 (dynamic-wind v_1 ...))
          (in-hole P_1 (raise (make-cond "arity mismatch")))
          "6dwarity"
          (side-condition (not (= (length (term (v_1 ...))) 3))))
     
     (--> (in-hole P_1 (dw x e (values v_1 ...) e))
          (in-hole P_1 (values v_1 ...))
          "6dwdone")
     
     (--> (store (sf_1 ...) (in-hole E_1 (call/cc v_1)))
          (store (sf_1 ...) (in-hole E_1 (v_1 (throw x (in-hole E_1 x)))))
          "6call/cc"
          (fresh x))
     
     (--> (store (sf_1 ...) (in-hole E_1 ((throw x_1 (in-hole E_2 x_1)) v_1 ...)))
          (store (sf_1 ...) (in-hole (Trim (E_1 E_2)) (values v_1 ...)))
          "6throw")))
  
  (metafunction-type pRe (-> E E))
  (define-metafunction pRe
    lang
    [(in-hole H_1 (dw x_1 e_1 E_1 e_2)) 
     (in-hole H_1
              (begin e_1 
                     (dw x_1 e_1 (pRe E_1) e_2)))]
    [H_1 H_1])
  
  (metafunction-type poSt (-> E E))
  (define-metafunction poSt
    lang
    [(in-hole E_1 (dw x_1 e_1 H_2 e_2))
     (in-hole (poSt E_1) (begin0 (dw x_1 e_1 hole e_2) e_2))]
    [H_1 hole])
  
  (metafunction-type Trim (-> E E E))
  (define-metafunction Trim
    lang
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
     
     (--> (in-hole PG_1 (with-exception-handler proc_1 proc_2))
          (in-hole PG_1 (handlers proc_1 (proc_2)))
          "6xwh1")
     
     (--> (in-hole PG_1 (with-exception-handler v_1 v_2))
          (in-hole PG_1 (raise (make-cond "with-exception-handler expects procs")))
          "6xwh1e"
          (side-condition (or (not (proc? (term v_1)))
                              (not (proc? (term v_2))))))
     
     (--> (in-hole P_1 (handlers proc_1 ... (in-hole G_1 (with-exception-handler proc_2 proc_3))))
          (in-hole P_1 (handlers proc_1 ... (in-hole G_1 (handlers proc_1 ... proc_2 (proc_3)))))
          "6xwhn")
     
     (--> (in-hole P_1 (handlers proc_1 ... (in-hole G_1 (with-exception-handler v_1 v_2))))
          (in-hole P_1 (handlers proc_1 ... (in-hole G_1 (raise (make-cond "with-exception-handler expects procs")))))
          "6xwhne"
          (side-condition (or (not (proc? (term v_1)))
                              (not (proc? (term v_2))))))
     
     (--> (in-hole P_1 (handlers proc_1 ... proc_2 (in-hole G_1 (raise-continuable v_1))))
          (in-hole P_1 (handlers proc_1 ... proc_2 (in-hole G_1 (handlers proc_1 ... (proc_2 v_1)))))
          "6xrc")
     
     (--> (in-hole P_1 (handlers 
                        proc_1 ... proc_2
                        (in-hole G_1 (raise v_1))))
          (in-hole P_1 (handlers 
                        proc_1 ... proc_2 
                        (in-hole G_1 
                                 (handlers proc_1 ... 
                                           (begin (proc_2 v_1)
                                                  (raise (make-cond "handler returned")))))))
          "6xr")
     
     (--> (in-hole P_1 (condition? (make-cond string)))
          (in-hole P_1 #t)
          "6ct")
     
     (--> (in-hole P_1 (condition? v_1))
          (in-hole P_1 #f)
          "6cf"
          (side-condition (not (condition? (term v_1)))))
     
     (--> (in-hole P_1 (handlers proc_1 ... (values v_1 ...)))
          (in-hole P_1 (values v_1 ...))
          "6xdone")))

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
     
     (--> (in-hole P_1 (call-with-values v_1 v_2))
          (in-hole P_1 (call-with-values (lambda () (v_1)) v_2))
          "6cwvw"
          (side-condition (not (lambda-null? (term v_1)))))))
  
  (define Letrec
    (reduction-relation
     lang
     (--> (store (sf_1 ...) (in-hole E_1 (letrec ([x_1 e_1] ...) e_2 e_3 ...)))
          (store (sf_1 ... (lx bh) ... (ri #f) ...)
            (in-hole E_1 
                     ((lambda (x_1 ...) 
                        (l! lx x_1) ...
                        (r6rs-subst-many ((x_1 lx) ... e_2))
                        (r6rs-subst-many ((x_1 lx) ... e_3)) ...)
                      (begin0
                        (r6rs-subst-many ((x_1 lx) ... e_1))
                        (reinit ri))
                      ...)))
          "6letrec"
          (fresh ((lx ...) 
                  (x_1 ...)
                  ,(map (λ (x) (string->symbol (format "lx-~a" x))) (term (x_1 ...)))))
          (fresh ((ri ...) 
                  (x_1 ...)
                  ,(map (λ (x) (string->symbol (format "ri-~a" x))) (term (x_1 ...))))))
     (--> (store (sf_1 ...) (in-hole E_1 (letrec* ([x_1 e_1] ...) e_2 e_3 ...)))
          (store (sf_1 ... (lx bh) ... (ri #f) ...)
            (in-hole E_1 
                     (r6rs-subst-many 
                      ((x_1 lx) ...
                       (begin
                         (begin
                           (l! lx e_1)
                           (reinit ri)) 
                         ...
                         e_2
                         e_3 ...)))))
          "6letrec*"
          (fresh ((lx ...)
                  (x_1 ...)
                  ,(map (λ (x) (string->symbol (format "lx-~a" x))) (term (x_1 ...)))))
          (fresh ((ri ...) 
                  (x_1 ...)
                  ,(map (λ (x) (string->symbol (format "ri-~a" x))) (term (x_1 ...))))))
     (--> (store (sf_1 ... (x_1 #f) sf_2 ...) (in-hole E_1 (reinit x_1)))
          (store (sf_1 ... (x_1 #t) sf_2 ...) (in-hole E_1 'ignore))
          "6init")
    (--> (store (sf_1 ... (x_1 #t) sf_2 ...) (in-hole E_1 (reinit x_1)))
         (store (sf_1 ... (x_1 #t) sf_2 ...) (in-hole E_1 'ignore))
         "6reinit")
    (--> (store (sf_1 ... (x_1 #t) sf_2 ...) (in-hole E_1 (reinit x_1)))
         (store (sf_1 ... (x_1 #t) sf_2 ...) (in-hole E_1 (raise (make-cond "reinvoked continuation of letrec init"))))
         "6reinite")
     (--> (store (sf_1 ... (x_1 bh) sf_2 ...) (in-hole E_1 (l! x_1 v_2)))
          (store (sf_1 ... (x_1 v_2) sf_2 ...) (in-hole E_1 unspecified))
          "6initdt")
     (--> (store (sf_1 ... (x_1 v_1) sf_2 ...) (in-hole E_1 (l! x_1 v_2)))
          (store (sf_1 ... (x_1 v_2) sf_2 ...) (in-hole E_1 unspecified))
          "6initv")
     (--> (store (sf_1 ... (x_1 bh) sf_2 ...) (in-hole E_1 (set! x_1 v_1)))
          (store (sf_1 ... (x_1 v_1) sf_2 ...) (in-hole E_1 unspecified))
          "6setdt")
     (--> (store (sf_1 ... (x_1 bh) sf_2 ...) (in-hole E_1 (set! x_1 v_1)))
          (store (sf_1 ... (x_1 bh) sf_2 ...) (in-hole E_1 (raise (make-cond "letrec variable touched"))))
          "6setdte")
     (--> (store (sf_1 ... (x_1 bh) sf_2 ...) (in-hole E_1 x_1))
          (store (sf_1 ... (x_1 bh) sf_2 ...) (in-hole E_1 (raise (make-cond "letrec variable touched"))))
          "6dt")))
  
  (define Underspecification
    (reduction-relation
     lang
     (--> (in-hole P (eqv? proc proc))
          (unknown "equivalence of procedures")
          "6ueqv")
     (--> (in-named-hole single P (values v_1 ...))
          (unknown ,(format "context expected one value, received ~a" (length (term (v_1 ...)))))
          "6uval"
          (side-condition (not (= (length (term (v_1 ...))) 1))))
     (--> (in-hole P (in-hole U unspecified))
          (unknown "unspecified result")
          "6udemand")
     (--> (store (sf ...) unspecified)
          (unknown "unspecified result")
          "6udemandtl")
     
     (--> (in-hole P_1 (begin unspecified e_1 e_2 ...))
          (in-hole P_1 (begin e_1 e_2 ...))
          "6ubegin")
     (--> (in-hole P_1 (handlers v ... unspecified))
          (in-hole P_1 unspecified)
          "6uhandlers")
     (--> (in-hole P_1 (dw x e unspecified e))
          (in-hole P_1 unspecified)
          "6udw")
     (--> (in-hole P_1 (begin0 (values v_1 ...) unspecified e_1 ...))
          (in-hole P_1 (begin0 (values v_1 ...) e_1 ...))
          "6ubegin0")
     (--> (in-hole P_1 (begin0 unspecified (values v_2 ...) e_2 ...))
          (in-hole P_1 (begin0 unspecified e_2 ...))
          "6ubegin0u")
     (--> (in-hole P_1 (begin0 unspecified unspecified e_2 ...))
          (in-hole P_1 (begin0 unspecified e_2 ...))
          "6ubegin0uu")))
  
  (define Quote
    (reduction-relation
     lang
     ;; compile time quote removal
     (--> (store (sf_1 ...) (in-hole S_1 'seq_1))
          (store (sf_1 ...) ((lambda (qp) (in-hole S_1 qp)) (Qtoc seq_1)))
          "6qcons"
          (fresh qp))
     (--> (store (sf_1 ...) (in-hole S_1 'seq_1))
          (store (sf_1 ...) ((lambda (qp) (in-hole S_1 qp)) (Qtoic seq_1)))
          "6qconsi"
          (fresh qp))
     (--> (store (sf_1 ...) (in-hole S_1 'sqv_1))
          (store (sf_1 ...) (in-hole S_1 sqv_1))
          "6sqv")
     (--> (store (sf_1 ...) (in-hole S_1 '()))
          (store (sf_1 ...) (in-hole S_1 null))
          "6eseq")))
  
  (metafunction-type Qtoc (-> seq e))
  (define-metafunction Qtoc
    lang
    [() null]
    [(s_1 s_2 ...) (cons (Qtoc s_1) (Qtoc (s_2 ...)))]
    [(s_1 dot sqv_1) (cons (Qtoc s_1) sqv_1)]
    [(s_1 s_2 s_3 ... dot sqv_1) (cons (Qtoc s_1) (Qtoc (s_2 s_3 ... dot sqv_1)))]
    [(s_1 dot sym_1) (cons (Qtoc s_1) 'sym_1)]
    [(s_1 s_2 s_3 ... dot sym_1) (cons (Qtoc s_1) (Qtoc (s_2 s_3 ... dot sym_1)))]
    [sym_1 'sym_1]
    [sqv_1 sqv_1])
  
  (metafunction-type Qtoic (-> seq e))
  (define-metafunction Qtoic 
    lang
    [() null]
    [(s_1 s_2 ...) (consi (Qtoic s_1) (Qtoic (s_2 ...)))]
    [(s_1 dot sqv_1) (consi (Qtoic s_1) sqv_1)]
    [(s_1 s_2 s_3 ... dot sqv_1) (consi (Qtoic s_1) (Qtoic (s_2 s_3 ... dot sqv_1)))]
    [(s_1 dot sym_1) (consi (Qtoic s_1) 'sym_1)]
    [(s_1 s_2 s_3 ... dot sym_1) (consi (Qtoic s_1) (Qtoic (s_2 s_3 ... dot sym_1)))]
    [sym_1 'sym_1]
    [sqv_1 sqv_1])
  
  (define Top--level--and--Variables
    (reduction-relation
     lang
     
     ;; variable lookup
     (--> (store (sf_1 ... (x_1 v_1) sf_2 ...) (in-hole E_1 x_1))
          (store (sf_1 ... (x_1 v_1) sf_2 ...) (in-hole E_1 v_1))
          "6var")
     
     ;; set!
     (--> (store (sf_1 ... (x_1 v_1) sf_2 ...) (in-hole E_1 (set! x_1 v_2)))
          (store (sf_1 ... (x_1 v_2) sf_2 ...) (in-hole E_1 unspecified))
          "6set")))
  
  (define reductions
    (union-reduction-relations
     Arithmetic
     Basic--syntactic--forms
     Cons 
     Eqv
     Procedure--application
     Apply
     Call-cc--and--dynamic-wind
     Exceptions
     Multiple--values--and--call-with-values
     Quote
     Top--level--and--Variables
     Letrec
     Underspecification))
  
  (define-metafunction r6rs-subst-one
    lang

    ;; variable cases
    [(variable_1 e_1 variable_1) e_1]
    [(variable_1 e_1 variable_2) variable_2]
    
    ;; dont substitute inside quoted expressions
    [(variable_1 e_1 'any_1) 'any_1]
    
    ;; when the lambda binds the variable, stop stubstituting
    [(variable_1 e (lambda (variable_2 ... variable_1 variable_3 ...) e_2 e_3 ...))
     (lambda (variable_2 ... variable_1 variable_3 ...) e_2 e_3 ...)]
    [(variable_1 e (lambda (variable_2 ... dot variable_1) e_2 e_3 ...))
     (lambda (variable_2 ... dot variable_1) e_2 e_3 ...)]
    [(variable_1 e (lambda (variable_2 ... variable_1 variable_3 ... dot variable_4) e_2 e_3 ...))
     (lambda (variable_2 ... variable_1 variable_3 ... dot variable_4) e_2 e_3 ...)]
    [(variable_1 e (lambda variable_1 e_2 e_3 ...))
     (lambda variable_1 e_2 e_3 ...)]
    
    ;; next 3 cases: we know no capture can occur, so we just recur
    [(variable_1 e_1 (lambda (variable_2 ...) e_2 e_3 ...))
     (lambda (variable_2 ...) 
       (r6rs-subst-one (variable_1 e_1 e_2))
       (r6rs-subst-one (variable_1 e_1 e_3)) ...)
     (side-condition (andmap (λ (x) (equal? (variable-not-in (term e_1) x) x))
                             (term (variable_2 ...))))]
    [(variable_1 e_1 (lambda (variable_2 ... dot variable_3) e_2 e_3 ...))
     (lambda (variable_2 ...) 
       (r6rs-subst-one (variable_1 e_1 e_2))
       (r6rs-subst-one (variable_1 e_1 e_3)) ...)
     (side-condition (andmap (λ (x) (equal? (variable-not-in (term e_1) x) x))
                             (term (variable_2 ... variable_3))))]
    [(variable_1 e_1 (lambda variable_2 e_2 e_3 ...))
     (lambda variable_2
       (r6rs-subst-one (variable_1 e_1 e_2))
       (r6rs-subst-one (variable_1 e_1 e_3)) ...)
     (side-condition (equal? (variable-not-in (term e_1) (term variable_2)) 
                             (term variable_2)))]
    
    ;; capture avoiding cases
    [(variable_1 e_1 (lambda (variable_2 ... dot variable_3) e_2 e_3 ...))
     ,(term-let ([(variable_new ... variable_new_dot) (variables-not-in (term (variable_1 e_1 e_2 e_3 ...))
                                                                        (term (variable_2 ... variable_3)))])
        (term (lambda (variable_new ... dot variable_new_dot) 
                (r6rs-subst-one (variable_1 
                                 e_1
                                 (r6rs-subst-many ((variable_2 variable_new) ... (variable_3 variable_new_dot) e_2))))
                (r6rs-subst-one (variable_1 
                                 e_1
                                 (r6rs-subst-many ((variable_2 variable_new) ... (variable_3 variable_new_dot) e_3))))
                ...)))]
    [(variable_1 e_1 (lambda (variable_2 ...) e_2 e_3 ...))
     ,(term-let ([(variable_new ...) (variables-not-in (term (variable_1 e_1 e_2 e_3 ...))
                                                       (term (variable_2 ...)))])
        (term (lambda (variable_new ...) 
                (r6rs-subst-one (variable_1 e_1 (r6rs-subst-many ((variable_2 variable_new) ... e_2))))
                (r6rs-subst-one (variable_1 e_1 (r6rs-subst-many ((variable_2 variable_new) ... e_3)))) ...)))]
    [(variable_1 e_1 (lambda variable_2 e_2 e_3 ...))
     ,(term-let ([variable_new (variable-not-in (term (variable_1 e_1 e_2 e_3 ...))
                                                (term variable_2))])
        (term (lambda variable_new
                (r6rs-subst-one (variable_1 e_1 (r6rs-subst-one (variable_2 variable_new e_2))))
                (r6rs-subst-one (variable_1 e_1 (r6rs-subst-one (variable_2 variable_new e_3)))) ...)))]
    
    ;; last two cases cover all other expressions -- they don't have any variables, 
    ;; so we don't care about their structure. 
    [(variable_1 e_1 (any_1 ...)) ((r6rs-subst-one (variable_1 e_1 any_1)) ...)]
    [(variable_1 e_1 any_1) any_1])
  
  (define-metafunction r6rs-subst-many
    lang
    [((variable_1 e_1) (variable_2 e_2) ... e_3) 
     (r6rs-subst-one (variable_1 e_1 (r6rs-subst-many ((variable_2 e_2) ... e_3))))]
    [(e_1) e_1])
  
  (metafunction-type observable (-> a* r*))
  (define-metafunction observable
    lang
    [(store (sf ...) (values v_1 ...))
     (values (observable-value v_1) ...)]
    [(uncaught-exception v)
     exception]
    [(unknown string)
     unknown])
  
  (metafunction-type observable-value (-> v r*v))
  (define-metafunction observable-value
    lang
    [pp_1 pair]
    [null null]
    ['sym_1 'sym_1]
    [sqv_1 sqv_1]
    [(make-cond string) condition]
    [proc procedure])
  
  (define condition? (test-match lang (make-cond string)))
  (define v? (test-match lang v))
  (define proc? (test-match lang proc))
  (define null-v? (test-match lang null))
  (define lambda-null? (test-match lang (lambda () e)))
  (define pp? (test-match lang pp))
  (define mp? (test-match lang mp))
  (define ip? (test-match lang ip))
  (define es? (test-match lang es))
  (define (list-v? v) (or (pp? v) (null-v? v))))
