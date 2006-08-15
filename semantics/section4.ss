(module section4 mzscheme

  (require (planet "reduction-semantics.ss" ("robby" "redex.plt" 1 0))
           (planet "gui.ss" ("robby" "redex.plt" 1 0))
           (planet "subst.ss" ("robby" "redex.plt" 1 0))
           (prefix srfi1: (lib "1.ss" "srfi"))
           (lib "match.ss"))
  
  (provide lang reductions)

  (define lang
    (language (s (s ...)
                 (s ... dot symbol-name)
                 (s ... dot number)
                 symbol-name
                 number)
              
              ;; compilation context
              (S (e ... S s ...)
                 (lambda (x ...) S)
                 (ccons v S)
                 (ccons S s)
                 hole)
              
              (e (e e ...)
                 v
                 x)
              
              ;; evaluation context
              (E hole
                 (v ... E e ...))

              (v (lambda (x ...) e)
                 'symbol-name
                 pp
                 null
                 number
                 prim
                 #t
                 #f)
              
              (prim eval cons car cdr eqv?)
              
              (sf (pp (cons v v)))
              
              (symbol-name (variable-except dot))
              
              (x (side-condition (name x (variable-except 
                                          lambda dot loc    ; core syntax names
                                          
                                          null
                                          
                                          cons car cdr  ; list functions
                                          quote
                                          eqv?
                                          eval ccons))
                                 (not (prefixed-by? (term x) 'pp))))
              
              ; pair pointer
              (pp (side-condition variable_p (prefixed-by? (term variable_p) 'pp)))))
  
  ;; --> : one-step reduction, full term to full term. 
  (define-syntax (--> stx)
    (syntax-case stx ()
      [(_ pat result) 
       #'(reduction lang pat (term result))]))
  
  (define reductions
    (list
     ;; compile time quote removal
     ((store (sf_1 ...) (in-hole S_1 '(s_1 s_2 ...)))
      . --> . 
      (store (sf_1 ...) (in-hole S_1 (ccons 's_1 '(s_2 ...)))))
     
     ((store (sf_1 ...) (in-hole S_1 '()))
      . --> . 
      (store (sf_1 ...) (in-hole S_1 null))) ;; should be #%null
     
     ((store (sf_1 ...) (in-hole S_1 'number_1))
      . --> . 
      (store (sf_1 ...) (in-hole S_1 number_1)))

     ;; compile time pair allocation
     ((name exp
            (store (sf_1 ...) (in-hole S_1 (ccons v_1 v_2))))
      . --> . 
      ,(term-let ([pp1 (variable-not-in (term exp) 'pp)])
         (term (store (sf_1 ... (pp1 (cons v_1 v_2))) 
                      (in-hole S_1 pp1)))))
     
     
     ;; eval
     ((store (sf_1 ...) (in-hole E_1 (eval v_1)))
      . --> . 
      (store (sf_1 ...) (in-hole E_1 ,((current-reify) (term (sf_1 ...)) (term v_1)))))
     
     ;; cons
     ((name prog (store (sf_1 ...) (in-hole E_1 (cons v_car v_cdr))))
      . --> .
      ,(term-let ((p_i (variable-not-in (term prog) 'pp)))
         (term
          (store (sf_1 ... (p_i (cons v_car v_cdr)))
                 (in-hole E_1 p_i)))))
     
     ;; car
     ((store (sf_1 ... (pp_i (cons v_car v_cdr)) sf_2 ...)
             (in-hole E_1 (car pp_i)))
      . --> .
      (store (sf_1 ... (pp_i (cons v_car v_cdr)) sf_2 ...)
             (in-hole E_1 v_car)))
     
     ;; cdr
     ((store (sf_1 ... (pp_i (cons v_car v_cdr)) sf_2 ...)
             (in-hole E_1 (cdr pp_i)))
      . --> .
      (store (sf_1 ... (pp_i (cons v_car v_cdr)) sf_2 ...) (in-hole E_1 v_cdr)))
     
     ;; eqv?
     ((store (sf_1 ...) (in-hole E_1 (eqv? pp_1 pp_1)))
      . --> .
      (store (sf_1 ...) (in-hole E_1 #t)))
     
    ((side-condition 
      (store (sf_1 ...) (in-hole E_1 (eqv? pp_1 pp_2)))
      (not (eq? (term pp_1) (term pp_2))))
      . --> .
      (store (sf_1 ...) (in-hole E_1 #f)))
     
     ;; application
     ((side-condition
       (store (sf_1 ...)
              (in-hole E_1 ((lambda (x_arg1 ...) e_body) v_arg1 ...)))
       (= (length (term (x_arg1 ...))) (length (term (v_arg1 ...)))))
      . --> .
      (store (sf_1 ...)
             (in-hole E_1
                      ,(r5rs-subst-all 
                        (term (x_arg1 ...)) 
                        (term (v_arg1 ...))
                        (term e_body)))))))

  (define (reify/compile store v)
    (let loop ([v v])
      (match v
        [`null '()]
        [(? number?) v]
        [`(quote ,(? symbol? s)) s]
        [(? symbol?)
         (let ([ent (assq v store)])
           (unless ent (error 'reify "free variable ~s" v))
           (match ent 
             [`(,var (lambda ,args ,body))
               var]
             [`(,var (cons ,va ,vd))
               (kons (loop va) (loop vd))]))])))
  
  (define (reify/share store v)
    (let loop ([v v])
      (match v
        [`null '()]
        [(? number?) v]
        [`(quote ,s) s]
        [(? symbol?)
         (let ([ent (assq v store)])
           (unless ent (error 'reify "free variable ~s" v))
           (match ent 
             [`(,var (cons 'quote ,vd))
               (let ([ent (assq vd store)])
                 (match ent
                   [`(,var (cons ,va null))
                     va]
                   [else (kons (loop 'quote) (loop vd))]))]
             [`(,var (cons ,va ,vd))
               (kons (loop va) (loop vd))]))])))
  
  (define current-reify (make-parameter reify/compile))
  
  (define (kons kar kdr)
    (cond
      [(or (null? kdr) (pair? kdr))
       (cons kar kdr)]
      [else (list kar 'dot kdr)]))
  
  (define prim? (let ([cp (compile-pattern lang 'prim)]) (λ (x) (and (match-pattern cp x) #t))))
  
  (define r5rs-subst-one 
    (subst
     [`cons (constant)]
     [`null (constant)]
     [`abort (constant)]
     [`call/cc (constant)]
     [`mark (constant)]
     [`cwv-mark (constant)]
     [(? symbol?) (variable)]
     [(? number?) (constant)]
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
  
  (define (prefixed-by? s prefix) (and (regexp-match (format "^~a" prefix) (symbol->string s)) #t))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; tests 
  ;;
  
  (define (evaluate term)
    (let loop ([term term])
      (let ([nexts (reduce reductions term)])
        (cond
          [(null? nexts) term]
          [(null? (cdr nexts)) (loop (car nexts))]
          [else 
           (printf "multiple reductions, starting with\n~s\n\n" term)
           (for-each (lambda (t) (printf "~s\n" t)) nexts)
           (error 'evaluate)]))))
  
  (define (run-mz term)
    (match term
      [`(store ,binds ,e)
        (eval `(let ,binds ,e))]))
  
  (define-syntax (test stx)
    (syntax-case stx ()
      [(_ term expected)
       (with-syntax ([line (syntax-line stx)])
         (syntax (test/proc term expected line #t)))]
      [(_ term expected show-mz?)
       (with-syntax ([line (syntax-line stx)])
         (syntax (test/proc term expected line show-mz?)))]))
  
  (define (test/proc term expected line show-mz?)
    (let ([got (evaluate term)]
          [mz-got (run-mz term)]
          [mz-expected (run-mz `(store () ,expected))])
      (match got
        [`(store ,str ,got-exp)
          (unless (equal? got-exp expected)
            (fprintf (current-error-port) "line ~s\n    test: ~s\n     got: ~s\nexpected: ~s\n\n"
                     line
                     term
                     got
                     expected))])
      (when show-mz?
        (unless (equal? mz-got mz-expected)
          (fprintf (current-error-port) "line ~s\nMZ  test: ~s\n     got: ~s\nexpected: ~s\n\n" 
                   line
                   term 
                   mz-got
                   mz-expected)))))

  (test '(store () (car (car (cdr (cdr '((x) (y) (1)))))))
        '1)
  
  (test '(store () (eval '((lambda (x) x) 1)))
        '1)
  (test '(store () (((lambda (y) (eval y)) '(lambda (x) x)) 1))
        '1)
  (test '(store () (car (eval '((lambda (x) x) '(1 2)))))
        '1)
  
  (test '(store () ((lambda (f) (eqv? (f) (f)))
                    (lambda () '(2))))
        '#t)
  
  (test '(store () (eqv? '(f) '(f)))
        '#f)
  
  (test '(store () ((lambda (f)
                      (eqv? (f) (eval (cons (cons 'lambda 
                                                  (cons null 
                                                        (cons (cons 'quote (cons (f) null)) null)))
                                            null))))
                    (lambda () '(x))))
        #f)
  
  (let ([exp
         '(store () ((lambda (f)
                       (eqv? (f) (eval (cons 'quote (cons (f) null)))))
                     (lambda () '(x))))])
    (parameterize ([current-reify reify/share])
      (test exp #t #f)) ;; last #f means don't run MZ test
    (parameterize ([current-reify reify/compile])
      (test exp #f)))

  (define (show x) (traces lang reductions x))

  (show '(store () ((lambda (f) (eqv? (f) (f)))
                    (lambda () '(x))))))
