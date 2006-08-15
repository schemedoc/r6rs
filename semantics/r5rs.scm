(module r5rs mzscheme
  (require (planet "reduction-semantics.ss" ("robby" "redex.plt" 1 0))
           (planet "subst.ss" ("robby" "redex.plt" 1 0))
  
           (prefix srfi1: (lib "1.ss" "srfi"))
           (lib "plt-match.ss"))
  
  (provide lang reductions)

  (define lang
    (language (p (store ((ptr sv) ...)
                   (dw (dws ...)
                      e)))
              
              (e (e e ...)
                 (if e e e)
                 (if e e)
                 (set! x e)
                 (begin e e ...)
                 (throw x dws ... (in-hole ec e))
                 (push (x e e) e)
                 (pop e)
                 lam
                 mulam
                 v
                 x)
              
              (lam (lambda (x ...) e e ...))
              (mulam (lambda (x ... dot x) e e ...))
              
              (v fun nonfun)
              
              (fun cp      ; user functions
                   mp
                   #%cons    ; primitive functions
                   #%null?
                   #%pair?
                   #%car #%cdr #%set-car! #%set-cdr! #%list
                   #%+ #%- #%/ #%*
                   #%call/cc #%dynamic-wind
                   #%values #%call-with-values
                   #%eqv?
                   #%apply
                   #%eval)
              
              (nonfun pp
                      number
                      #%null
                      #t
                      #f
                      '(variable-except dot)
                      unspecified)

              
              (pc (store ((ptr sv) ...)
                    dc))
              (dc (dw (dws ...)
                    ec1))
              (ec hole
                  (inert ... (mark ec1) inert ...)
                  (if ec1 e e)
                  (if ec1 e)
                  (set! x ec1)
                  (begin ec e e ...)
                  ((mark #%call-with-values)
                   (cwv-mark ec*) 
                   (mark v)))
              (ec1 (hole single) ec)
              (ec* (hole multi) ec)
              (inert e (mark v))
              
              (dws (x cp cp))
              (sv v
                  (#%cons v v)
                  lam
                  mulam)
              
              (sexp (sexp ...)
                    (sexp ... dot non-sequence-sexp)
                    non-sequence-sexp)
              (non-sequence-sexp number
                                 #t
                                 #f
                                 (variable-except dot))
              (sexpc hole
                     (e ... sexpc sexp ...)
                     (if e e sexpc)
                     (if e sexpc sexp)
                     (if sexpc sexp sexp)
                     (if e sexpc)
                     (if sexpc sexp)
                     (set! x sexpc)
                     (begin e e ... sexpc sexp ...)
                     (begin sexpc sexp ...)
                     (throw x dws ... sexpc)
                     (push (x e e) sexpc)
                     (push (x e sexpc) sexp)
                     (push (x sexpc sexp) sexp)
                     (pop sexpc)
                     (lambda (x ...) sexpc sexp ...)
                     (lambda (x ...) e e ... sexpc sexp ...)
                     (lambda (x ... dot x) sexpc sexp ...)
                     (lambda (x ... dot x) e e ... sexpc sexp ...)
                     (ccons v sexpc)
                     (ccons sexpc sexp))
              
              (var (variable-except 
                    dot                         ; the . in dotted pairs
                    lambda if loc set!          ; core syntax names
                    quote begin
                    
                    ccons                       ; compile-time cons
                    mark                        ; marked expressions (superscript o)
                    
                    #%null                      ; non-function values
                    unspecified
                    pair closure
                    
                    error                       ; signal an error
                    
                    
                    #%cons #%pair? #%null? #%car #%cdr  ; list functions
                    #%set-car! #%set-cdr! #%list
                    #%+ #%- #%* #%/                          ; math functions
                    #%call/cc throw push pop #%dynamic-wind  ; call/cc functions
                    #%values #%call-with-values              ; values functions
                    
                    cwv-mark))
              
              (x (side-condition 
                  var_1
                  (and (not (prefixed-by? (term var_1) 'c))
                       (not (prefixed-by? (term var_1) 'p))
                       (not (prefixed-by? (term var_1) 'm)))))
              
              ; pair pointer
              (pp (side-condition var_pp (prefixed-by? (term var_pp) 'p)))
              ; pointer to a lambda function
              (cp (side-condition var_pp (prefixed-by? (term var_pp) 'c)))
              ; pointer to a mu-lambda function
              (mp (side-condition var_mp (prefixed-by? (term var_mp) 'm)))
              
              (ptr x pp cp mp)))

  ;; --> : one-step reduction, full term to full term. 
  (define-syntax (--> stx)
    (syntax-case stx ()
      [(_ term result) 
       #'(reduction lang term result)]))
  
  ;; /-> : one-step reduction, pc[term] to pc[term]
  (define-syntax (/-> stx)
    (syntax-case stx ()
      [(_ term result)
       #'(reduction/context lang pc term result)]))
  
  ;; *-> : one-step reduction, pc[marked application] to pc[term]
  (define-syntax (*-> stx)
    (define (src-item->result-item stx)
      (syntax-case stx (...)
        [... stx]
        [other #'(mark other)]))
    (syntax-case stx ()
      [(_ (item ...) result)
       (with-syntax ([(result-item ...) 
                      (map 
                       src-item->result-item
                       (syntax-e #'(item ...)))])
         #'((result-item ...) . /-> . result))]))
  
  ;; e-> : error reduction, pc[term] -> error
  (define-syntax (e-> stx)
    (syntax-case stx ()
      [(_ t msg) #'(reduction lang 
                              (in-hole pc t)
                              msg)]))

  ;; prims : procedure ... -> listof reductions
  (define-syntax (prims stx)
    (define (symbol-append s1)
      (lambda (s2)
        (string->symbol (string-append (symbol->string s1) (symbol->string s2)))))
    (syntax-case stx ()
      [(_ oper ...)
       (andmap identifier? (syntax->list #'(oper ...)))
       (with-syntax ([(op ...) (map (symbol-append '#%) (syntax-object->datum #'(oper ...)))])
       #'(list 
          ((op number_1 (... ...)) 
           . *-> . 
           (apply oper (term (number_1 (... ...)))))
          ...
          ((side-condition 
            ((mark op) (mark v_1) (... ...))
            (not (andmap number? (term (v_1 (... ...))))))
           . e-> .
           (term (error "attempt to apply numeric operator to non-numbers")))
          ...))]))
  
  (define Basic--syntactic--forms
    (list*
     
     ;; if
     ((side-condition 
       (if v_1 e_1 e_2)
       (not (eq? (term v_1) #f)))
      . /-> .
      (term e_1))
     ((if #f e_1 e_2) . /-> . (term e_2))
     
     ((side-condition
       (if v_1 e_1)
       (not (eq? (term v_1) #f)))
      . /-> .
      (term e_1))
     ((if #f e_1) . /-> . (term unspecified))
     
     ;; begin
     ((begin v e_1 e_2 ...) . /-> . (term (begin e_1 e_2 ...)))
     ((begin e_1) . /-> . (term e_1))

     (prims + - * /)))
     
  (define Cons--and--cons-cell--mutation
    (list
     ;; #%cons
     ((store ((ptr_1 sv_1) ...)
             (in-hole dc_1 ((mark #%cons) (mark v_car) (mark v_cdr))))
      . --> .
      (term-let ((p_i (variable-not-in (term (ptr_1 ...)) 'p)))
        (term
         (store ((ptr_1 sv_1) ... (p_i (#%cons v_car v_cdr)))
                (in-hole dc_1 p_i)))))

     ;; #%list
     (((mark #%list) (mark v_1) ...)
      . /-> .
      (term ((mark (lambda (dot l) l)) (mark v_1) ...)))
     
     ;; #%car
     ((store ((ptr_1 sv_1)
              ...
              (pp_i (#%cons v_car v_cdr))
              (ptr_i+1 sv_i+1) ...)
        (in-hole dc_1 ((mark #%car) (mark pp_i))))
      . --> .
      (term (store ((ptr_1 sv_1) 
                    ... 
                    (pp_i (#%cons v_car v_cdr)) 
                    (ptr_i+1 sv_i+1) ...)
              (in-hole dc_1 v_car))))

     ((side-condition 
       ((mark #%car) (mark v_i))
       (not (cons-v? (term v_i))))
      . e-> .
      (term (error "can't take car of non-pair")))
     
     ;; #%cdr
     ((store ((ptr_1 sv_1) 
              ...
              (pp_i (#%cons v_car v_cdr))
              (ptr_i+1 sv_i+1) ...)
        (in-hole dc_1 ((mark #%cdr) (mark pp_i))))
      . --> .

      (term (store ((ptr_1 sv_1) 
                    ... 
                    (pp_i (#%cons v_car v_cdr))
                    (ptr_i+1 sv_i+1) ...)
                   (in-hole dc_1 v_cdr))))

     ((side-condition
       ((mark #%cdr) (mark v_i))
       (not (cons-v? (term v_i))))
      . e-> .
      (term (error "can't take cdr of non-pair")))
     
     ;; #%null?
     ((#%null? #%null) . *-> . #t)
     ((side-condition
       ((mark #%null?) (mark v_i))
       (not (null-v? (term v_i))))
      . /-> .
      #f)
     
     ;; #%pair? 
     ((#%pair? pp)  . *-> . #t)
     ((side-condition
       ((mark #%pair?) (mark v_i))
       (not (prefixed-by? (term v_i) 'p)))
      . /-> . #f)
     
     ;; #%set-car!
     ((store ((ptr_1 sv_1)
              ...
              (pp_i (#%cons v_car v_cdr))
              (ptr_i+1 sv_i+1) ...)
        (in-hole dc_1 ((mark #%set-car!) (mark pp_i) (mark v_new))))
      . --> .
      (term (store ((ptr_1 sv_1) 
                    ... 
                    (pp_i (#%cons v_new v_cdr))
                    (ptr_i+1 sv_i+1) ...)
              (in-hole dc_1 unspecified))))

     
     ;; #%set-car! error
     (((mark #%set-car!)
       (mark (side-condition v_1 (not (cons-v? (term v_1)))))
       (mark v))
      . e-> .
      (term (error "can't set-car! on a non-pair")))
     
     ;; #%set-cdr!
     ((store ((ptr_1 sv_1)
              ...
              (pp_i (#%cons v_car v_cdr))
              (ptr_i+1 sv_i+1) ...)
        (in-hole dc_1 ((mark #%set-cdr!) (mark pp_i) (mark v_new))))
      . --> .
      (term (store ((ptr_1 sv_1) 
                    ... 
                    (pp_i (#%cons v_car v_new))
                    (ptr_i+1 sv_i+1) ...)
              (in-hole dc_1 unspecified))))
     
     ;; #%set-cdr! error
     (((mark #%set-cdr!)
       (mark (side-condition v_1 (not (cons-v? (term v_1)))))
       (mark v))
      . e-> .
      (term (error "can't set-cdr! on a non-pair")))))
  
  (define Functions--and--function--application
    (list
     ;; all orders of evaluation
     #;
     ((inert_1 ... e_i inert_i+1 ...)
      . /-> . 
      (term (inert_1 ... (mark e_i) inert_i+1 ...)))
     
     ;; left to right order of evaluation
     (((mark v_1) ... e_i e_i+1 ...)
      . /-> . 
      (term ((mark v_1) ... (mark e_i) e_i+1 ...)))
    
     ;; variable lookup
     ((store ((ptr_1 sv_1)
              ... 
              (x_i sv_i)
              (ptr_i+1 sv_i+1) ...)
             (in-hole dc_1 x_i))
      . --> . 
      (term
       (store ((ptr_1 sv_1) 
               ...
               (x_i sv_i)
               (ptr_i+1 sv_i+1) ...)
              (in-hole dc_1 sv_i))))
     
     ;; set!
     ((store ((ptr_1 sv_1) ... (x_i sv_i) (ptr_i+1 sv_i+1) ...)
             (in-hole dc_1 (set! x_i v_new)))
      . --> .
      (term 
       (store ((ptr_1 sv_1) ... (x_i v_new) (ptr_i+1 sv_i+1) ...)
              (in-hole dc_1 unspecified))))
    
     ;; closure introduction
     ((store ((ptr_1 sv_1) ...) (in-hole dc_1 lam_i))
      . --> . 
      (term-let ((cp_i (variable-not-in (term (ptr_1 ...)) 'c)))
        (term (store ((ptr_1 sv_1) ... (cp_i lam_i)) (in-hole dc_1 cp_i)))))
     
     ;; lambda application
     ((side-condition
       (name prog
             (store ((ptr_1 sv_1) 
                     ... 
                     (cp_i (lambda (x_arg1 ...) e_body1 e_body2 ...))
                     (ptr_i+1 sv_i+1)  ...)
                    (in-hole dc_1 ((mark cp_i) (mark v_arg1) ...))))
       (= (length (term (x_arg1 ...))) (length (term (v_arg1 ...)))))
      . --> .
      (term-let ([(x_arg2 ...) 
                  (variables-not-in 
                   (term (v_arg1 ...))
                   (term prog)
                   'b)])
        (term 
         (store ((ptr_1 sv_1) 
                 ...
                 (cp_i (lambda (x_arg1 ...) e_body1 e_body2 ...))
                 (ptr_i+1 sv_i+1) ...
                 (x_arg2 v_arg1) ...)
                (in-hole dc_1
                          (begin 
                            ,(r5rs-subst-all 
                              (term (x_arg1 ...)) 
                              (term (x_arg2 ...))
                              (term (begin e_body1 e_body2 ...)))))))))
     
     ((side-condition
       (store ((ptr sv) 
               ... 
               (cp_i (lambda (x_arg1 ...) e e ...))
               (ptr sv) ...)
              (in-hole dc ((mark cp_i) (mark v_arg1) ...)))
       (not (= (length (term (x_arg1 ...)))
               (length (term (v_arg1 ...))))))
      . --> .
      (term (error "arity mismatch")))
     
     ;; mu-closure introduction
     ((store ((ptr_1 sv_1) ...)
             (in-hole dc_1 (lambda (x_arg1 ... dot x_rest) e_1 e_2 ...)))
      . --> .
      (term-let ((mp_i (variable-not-in (term (ptr_1 ...)) 'm))
                 (cp_i (variable-not-in (term (ptr_1 ...)) 'c)))
        (term 
         (store ((ptr_1 sv_1) 
                 ... 
                 (mp_i (lambda (x_arg1 ... dot x_rest) (cp_i x_arg1 ... x_rest)))
                 (cp_i (lambda (x_arg1 ... x_rest) e_1 e_2 ...)))
                (in-hole dc_1 mp_i)))))
     
     ;; mu-lambda application
     ((side-condition
       (store ((ptr_1 sv_1)
               ... 
               (mp_i (lambda (x_arg1 ... dot x_argrest) (cp_target x_arg1 ... x_argrest)))
               (ptr_i+1 sv_i+1) ...)
              (in-hole dc_1 ((mark mp_i) (mark v_arg1) ...)))
       (>= (length (term (v_arg1 ...))) (length (term (x_arg1 ...)))))
      . --> .
      (let-values ([(named rest) 
                    (divide (term (v_arg1 ...)) (length (term (x_arg1 ...))))])
        (term-let (((v_named1 ...) named)
                   (v_rest (mkmarkedlist rest)))
          (term 
           (store ((ptr_1 sv_1)
                   ...
                   (mp_i (lambda (x_arg1 ... dot x_argrest) (cp_target x_arg1 ... x_argrest)))
                   (ptr_i+1 sv_i+1) ...)
                  (in-hole dc_1
                           ((mark cp_target) 
                            (mark v_named1) ... 
                            (mark v_rest))))))))
     
     ;; mu-lambda too few arguments case
     ((side-condition
       (store ((ptr sv) 
               ...
               (mp_i (lambda (x_arg1 ... dot x) (cp x ...)))
               (ptr sv) ...)
              (in-hole dc ((mark mp_i) (mark v_arg1) ...)))
       (< (length (term (v_arg1 ...)))
          (length (term (x_arg1 ...)))))
      . --> .
      (term (error "too few arguments")))
     
     ;; application of non-function
     (((mark nonfun) (mark v) ...) 
      . e-> . 
      (term (error "can't apply non-function")))
     
     ;; #%apply
     ((store ((ptr_1 sv_1)
              ...
              (pp_i (#%cons v_car v_cdr))
              (ptr_i+1 sv_i+1) ...)
             (in-hole dc_1 ((mark #%apply) (mark v_f) (mark v_arg1) ... (mark pp_i))))
      . --> .
      (term
       (store ((ptr_1 sv_1)
               ...
               (pp_i (#%cons v_car v_cdr))
               (ptr_i+1 sv_i+1) ...)
              (in-hole  dc_1
                        ((mark #%apply) 
                         (mark v_f) 
                         (mark v_arg1) ... 
                         (mark v_car) 
                         (mark v_cdr))))))
     
     ((#%apply v_f v_arg1 ... #%null)
      . *-> .
      (term (v_f v_arg1 ...)))
     
     ((side-condition
       ((mark #%apply) (mark v_f) (mark v_arg1) ... (mark v_last))
       (not (list-v? (term v_last))))
      . e-> .
      (term (error "apply must take a list as its last argument")))))
  
  (define (in-store? store . names)
    (andmap (λ (x) (assq x store)) names))
  
  (define Call-cc--and--dynamic-wind
    (list

     ;; #%dynamic-wind
     ((name prog 
            (store ((ptr_s sv_s) ...) 
                   (dw (dws_1 ...) 
                       (in-hole ec_1
                                ((mark #%dynamic-wind)
                                 (mark cp_1)
                                 (mark cp_2) 
                                 (mark cp_3))))))
      . --> . 
      (term-let ([d (variable-not-in (term prog) 'd)]
                 [x (variable-not-in (term prog) 'x)])
        (term 
         (store ((ptr_s sv_s) ...)
           (dw (dws_1 ...)
               (in-hole ec_1
                        (begin (cp_1)
                               (push (d cp_1 cp_3)
                                     ((lambda (x) (pop (begin (cp_3) x)))
                                      (cp_2))))))))))
     
     ;; push dynamic context
     ((store ((ptr_s sv_s) ...) (dw (dws_1 ...) (in-hole ec_1 (push dws_2 e_next))))
      . --> .
      (term (store ((ptr_s sv_s) ...) (dw (dws_2 dws_1 ...) (in-hole ec_1 e_next)))))
     
     ;; pop dynamic context
     ((store ((ptr_s sv_s) ...) (dw (dws_1 dws_2 ...) (in-hole ec_1 (pop e_next))))
      . --> .
      (term (store ((ptr_s sv_s) ...) (dw (dws_2 ...) (in-hole ec_1 e_next)))))

     ;; #%call/cc
     ((name prog (store ((ptr_s sv_s) ...) (dw (dws_1 ...) (in-hole ec_1 ((mark #%call/cc) (mark v_1))))))
      . --> .
      (term-let ([x (variable-not-in (term prog) 'x)]
                 [x_k (variable-not-in (term prog) 'xk)])
        (term (store ((ptr_s sv_s) ...) 
                     (dw (dws_1 ...) 
                         (in-hole  ec_1
                                   (v_1
                                    (lambda (dot args)
                                      (throw
                                       x_k 
                                       dws_1 ...
                                       (in-hole  ec_1
                                                 (begin x_k (#%apply #%values args))))))))))))
     
     ;; throw to a continuation
     ((store ((ptr_s sv_s) ...) (dw (dws_1 ...) (in-hole ec_1 (throw x_k dws_2 ... (in-hole ec_2 e_2)))))
      . --> .
      (term (store ((ptr_s sv_s) ...) (dw (dws_2 ...) (trim (dws_1 ...) (dws_2 ...) x_k (in-hole ec_2 e_2))))))
     
     ;; remove shared portion of path
     ((store ((ptr_s sv_s) ...) (dw (dws_1 ...) (trim (dws_2 ... (x_1 cp cp))
                                                      (dws_3 ... (x_1 cp cp))
                                                      x_k
                                                      (in-hole ec_2 e_2))))
      . -->  .
      (term (store ((ptr_s sv_s) ...) (dw (dws_1 ...) (trim (dws_2 ...) (dws_3 ...) x_k (in-hole ec_2 e_2))))))
     
     ;; build up context of before & after thunk bodies
     ((side-condition
       (store ((ptr_s sv_s) ...) (dw (dws_1 ...) (trim ((x_from cp_fb cp_fa) ...)
                                                       ((x_to cp_tb cp_ta) ...)
                                                       x_k
                                                       (in-hole ec_2 e_2))))
       (let ([from (term (x_from ...))]
             [to (term (x_to ...))])
         (or (null? from) 
             (null? to)
             (not (eq? (car (srfi1:last-pair from))
                       (car (srfi1:last-pair to)))))))
      . --> .
      (term (store ((ptr_s sv_s) ...) 
                   (dw (dws_1 ...) 
                       ,(r5rs-subst-all (list (term x_k))
                                        (list (term (begin (cp_fa) ... 
                                                           ,@(reverse (term ((cp_tb) ...)))
                                                           unspecified)))
                                        (term (in-hole ec_2 e_2)))))))))
     
  (define Multiple--values--and--call-with-values
    (list
     ;; values promotion
     ((in-named-hole multi
                     pc_1
                     v_1)
      . --> .
      (term (in-hole pc_1 ((mark #%values) (mark v_1)))))
     
     ;; values demotion
     ((in-named-hole single
                     pc_1
                     ((mark #%values) (mark v_1)))
      . --> .
      (term (in-hole pc_1 v_1)))
     
     ((in-named-hole single
                     pc_1
                     (side-condition
                      ((mark #%values) (mark v_1) ...)
                      (not (= (length (term (v_1 ...))) 1))))
      . --> .
      (term (error "context received the wrong number of values")))
     
     ; resolving call-with-values statements
     ((#%call-with-values v_vals v_fun)
      . *-> .
      (term ((mark #%call-with-values) 
             (cwv-mark (v_vals))
             (mark v_fun))))
     
     ((in-hole
       pc_1
       ((mark #%call-with-values)
        (cwv-mark ((mark #%values) (mark v_arg) ...))
        (mark v_fun)))
      . --> .
      (term (in-hole pc_1 ((mark v_fun) (mark v_arg) ...))))

     ((side-condition 
       ((mark #%call-with-values) (mark v_i) ...)
       (not (= (length (term (v_i ...))) 2)))
      . e-> .
      (term (error "arity mismatch")))))

  (define Eqv--and--equivalence
    (list
     ((#%eqv? pp_i pp_i) . *-> . #t)
     ((#%eqv? cp_i cp_i) . *-> . #t)
     ((#%eqv? number_1 number_1) . *-> . #t)
     ((#%eqv? v_1 v_1) . *-> . #t)
     ((side-condition
       ((mark #%eqv?) (mark v_1) (mark v_2))
       (not (eq? (term v_1) (term v_2))))
      . /-> . 
      #f)
     
     ((side-condition 
       ((mark #%eqv?) (mark v_1) ...)
       (not (= (length (term (v_1 ...))) 2)))
      . e-> .
      (term (error "arity mismatch")))))

  (define (reify store v)
    (let loop ([v v])
      (match v
        [`#%null '()]
        [(? number?) v]
        [(? boolean?) v]
        [`(quote ,(? symbol? s)) s]
        [(? symbol?)
         (let ([ent (assq v store)])
           (unless ent (error 'reify "free variable ~s" v))
           (match ent 
             [`(,var (#%cons ,va ,vd))
               (kons (loop va) (loop vd))]
             [else (error 'reify "variable not bound to pair ~s" v ent)]))])))
  
  (define (kons kar kdr)
    (cond
      [(or (null? kdr) (pair? kdr))
       (cons kar kdr)]
      [else (list kar 'dot kdr)]))
  
  (define Quote--and--eval
    (list
     ((store ((ptr_1 sv_1) ...)
             (in-hole dc_1 ((mark #%eval) (mark v_1))))
      . --> . 
      (term 
       (store ((ptr_1 sv_1) ...)
              (in-hole dc_1 ,(reify (term ((ptr_1 sv_1) ...)) (term v_1))))))
     
     ;; compile time quote removal
     ((store ((ptr_1 sv_1) ...) 
             (dw (dws_1 ...) (in-hole ec_1 (in-hole sexpc_1 '(sexp_1 sexp_2 ...)))))
      . --> . 
      (term 
       (store ((ptr_1 sv_1)...)
              (dw (dws_1 ...) (in-hole ec_1 (in-hole sexpc_1 (ccons 'sexp_1 '(sexp_2 ...))))))))
     
     ((store ((ptr_1 sv_1) ...) (dw (dws_1 ...) (in-hole ec_1 (in-hole sexpc_1 '()))))
      . --> . 
      (term (store ((ptr_1 sv_1) ...) (dw (dws_1 ...) (in-hole ec_1 (in-hole sexpc_1 #%null))))))
     
     ((store ((ptr_1 sv_1) ...) (dw (dws_1 ...) (in-hole ec_1 (in-hole sexpc_1 'number_1))))
      . --> . 
      (term (store ((ptr_1 sv_1) ...) (dw (dws_1 ...) (in-hole ec_1 (in-hole sexpc_1 number_1))))))
     
     ;; compile time pair allocation
     ((name exp
            (store ((ptr_1 sv_1) ...) (dw (dws_1 ...) (in-hole ec_1 (in-hole sexpc_1 (ccons v_1 v_2))))))
      . --> . 
      (term-let ([pp1 (variable-not-in (term exp) 'pp)])
        (term (store ((ptr_1 sv_1) ... (pp1 (#%cons v_1 v_2)))
                     (dw (dws_1 ...)
                         (in-hole ec_1 (in-hole sexpc_1 pp1)))))))))
  
  (define reductions (append Basic--syntactic--forms
                             Cons--and--cons-cell--mutation
                             Functions--and--function--application
                             Call-cc--and--dynamic-wind
                             Multiple--values--and--call-with-values
                             Eqv--and--equivalence
                             Quote--and--eval))
  
  
#|latex
\section{Odds and ends}

The remainder of the code implements various helpers and convenience
features that generally are not spelled out in a formal semantics document
but that must be specified to produce an executable specification. The most
notable function here is \scheme|r5rs-subst-one|, the capture-avoiding 
substitution function. It is defined using a domain-specific language for 
building capture-avoiding substitution functions that is included in
\pltreducks{}; for details see \pltreducks{} documentation within DrScheme.

|#
  (define r5rs-subst-one 
    (subst
     [`#%cons (constant)]
     [`#%null (constant)]
     [`throw (constant)]
     [`#%call/cc (constant)]
     [`mark (constant)]
     [`cwv-mark (constant)]
     [(? symbol?) (variable)]
     [(? number?) (constant)]
     [(? boolean?) (constant)]
     [`(lambda ,(xs ... 'dot last) ,b)
       (all-vars (cons last xs))
       (build (lambda (vars body) `(lambda ,(xs 'dot last) ,body)))
       (subterm xs b)]
     [`(lambda ,(xs ...) ,b)
       (all-vars xs)
       (build (lambda (vars body) `(lambda ,xs ,body)))
       (subterm xs b)]
     [`(lambda ,x ,b)
       (all-vars (list x))
       (build (lambda (vars body) `(lambda ,x ,body)))
       (subterm x b)]
     [`(set! ,x ,e)
       (all-vars '())
       (build (lambda (vars x exp) `(set! ,x ,exp)))
       (subterm '() x)
       (subterm '() e)]
     [(f args ...)
      (all-vars '())
      (build (lambda (vars f . args) `(,f ,@args)))
      (subterm '() f)
      (subterms '() args)]))
  
  (define (r5rs-subst-all params args body) (srfi1:fold r5rs-subst-one body params args))
  
  (define (variables-not-in items exp prefix)
    (cond
      [(null? items) null]
      [else 
       (let ((this (variable-not-in exp prefix)))
         (cons 
          this 
          (variables-not-in 
           (cdr items)
           (cons this exp)
           prefix)))]))
  
  ; mklist : listof term -> term
  ; makes a term representing a cons-list of the given list
  (define (mklist args)
    (srfi1:fold-right 
     (lambda (this rest) `(#%cons ,this ,rest))
     `#%null)
    args)
  
  ; mkmarkedlist : listof term -> term
  ; like mklist, but pre-marks all values in all applications
  (define (mkmarkedlist vals)
    (srfi1:fold-right
     (lambda (this rest) 
       `((mark #%cons) (mark ,this) (mark ,rest)))
     `#%null 
     vals))
  
  (define cons-v? (language->predicate lang 'pp))
  (define (null-v? v) (eq? v '#%null))
  (define (list-v? v) (or (cons-v? v) (null-v? v)))
  
  (define (prefixed-by? s prefix)
    (let* ([sym (symbol->string s)]
           [pre (symbol->string prefix)]
           [len (string-length pre)])
      (string=? (substring sym 0 len) pre)))
  
  (define (divide li n)
    (let loop ((n n)
               (li li)
               (acc '()))
      (cond
        [(zero? n) (values (reverse acc) li)]
        [else (loop (sub1 n) (cdr li) (cons (car li) acc))])))

#;
  (begin
    (require (planet "gui.ss" ("robby" "redex.plt" 1 0)))
    (define (go t) (traces lang reductions t))
    (reduction-steps-cutoff 30)
    (go '(store () (dw () (#%+ 1 2)))))  ;; (the graph produced here is indeed planar ...)
  )
