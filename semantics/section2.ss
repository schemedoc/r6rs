(module section2 mzscheme
  (require (planet "reduction-semantics.ss" ("robby" "redex.plt" 1 0))
           (planet "gui.ss" ("robby" "redex.plt" 1 0))
           (planet "subst.ss" ("robby" "redex.plt" 1 0))
           (lib "list.ss"))
    
  (reduction-steps-cutoff 100)
  
  (define lang
    (language
     (p (store (x v) ...) e)
     (e (set! x e)
        (e e ...)
        (begin e e ...)
        x
        v)
     (v (lambda (x ...) e)
        number
        -)
     (x (variable-except - lambda mark set! begin))
     
     (inert e (mark v))
     (pc (store ((x v) ...) ec))
     (ec (inert ... (mark ec) inert ...)
         (set! variable ec)
         (begin ec e e ...)
         hole)))
  
  (define reductions
    (list
     
     ; application
     (reduction lang
                (name prog
                  (store ((x_s v_s) ...) 
                    (side-condition
                     (in-hole ec_1 ((mark (lambda (x_1 ...) e_body)) (mark v_1) ...))
                     (= (length (term (x_1 ...)))
                        (length (term (v_1 ...)))))))
                (term-let ([(xp_1 ...) (variables-not-in (term prog) (term (x_1 ...)))])
                   (term (store ((x_s v_s) ... (xp_1 v_1) ...)
                           (in-hole ec_1 ,(substitute-all (term (x_1 ...)) 
                                                                (term (xp_1 ...))
                                                                (term e_body)))))))
     
     ; mark introduction
     (reduction lang
                (in-hole pc_1 (inert_1 ... e_i inert_i+1 ...))
                (term (in-hole pc_1 (inert_1 ... (mark e_i) inert_i+1 ...))))
     
     ; negation
     (reduction lang
                (in-hole pc_1 ((mark -) (mark number_1)))
                (term 
                 (in-hole pc_1 ,(- (term number_1)))))
     
     ; deref
     (reduction lang 
                (store
                 ((x_1 v_1) ... (x_i v_i) (x_2 v_2) ...)
                 (in-hole ec_1 x_i))
                (term
                 (store
                  ((x_1 v_1) ... (x_i v_i) (x_2 v_2) ...)
                  (in-hole ec_1 v_i))))

     ; set!
     (reduction lang
                (store ((x_1 v_1) ...
                        (x_i v_i)
                        (x_2 v_2) ...)
                 (in-hole ec_1 (set! x_i v_ip)))
                (term 
                 (store ((x_1 v_1) ...
                         (x_i v_ip)
                         (x_2 v_2) ...)
                   (in-hole ec_1 0))))
     
     ; begin
     (reduction lang
                (in-hole pc_1 (begin e_1))
                (term (in-hole pc_1 e_1)))
     (reduction lang
                (in-hole pc_1 (begin v_1 e_2 e_3 ...))
                (term (in-hole pc_1 (begin e_2 e_3 ...))))))
     
  
  
  (define (variables-not-in p xs)
    (let loop ([orig-vars xs]
               [new-vars '()])
      (cond
        [(null? orig-vars)
         (reverse new-vars)]
        [else 
         (loop (cdr orig-vars)
               (cons (variable-not-in (cons new-vars p) (car orig-vars))
                     new-vars))])))
  
  
  (define (substitute-all xs vs body)
    (foldl substitute body xs vs))
  
  (define substitute
    (plt-subst
     ['- (constant)]
     [(? symbol?) (variable)]
     [(? number?) (constant)]
     [`(lambda (,x ...) ,b)
      (all-vars x)
      (build (lambda (vars body) `(lambda ,vars ,body)))
      (subterm x b)]
     [`(set! ,x ,e)
      (all-vars '())
      (build (lambda (vars name body) `(set! ,name ,body)))
      (subterm '() x)
      (subterm '() e)]
     [`(begin ,e ,e2 ...)
      (all-vars '())
      (build (lambda (vars e1 e2) `(begin ,e1 ,@e2)))
      (subterm '() e)
      (subterms '() e2)]
     [`(,f ,x ...)
      (all-vars '())
      (build (lambda (vars f x) `(,f ,@x)))
      (subterm '() f)
      (subterms '() x)]))
  
  (define (run e) (traces lang reductions `(store () ,e)))
  (provide run)

  (traces lang reductions
   '(store ((x 1))
      ((lambda (p q) x)
       (set! x (- x))
       (set! x (- x))))))

  
  