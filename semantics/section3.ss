(module section3 mzscheme

  (require (planet "reduction-semantics.ss" ("robby" "redex.plt" 1 0))
           (planet "gui.ss" ("robby" "redex.plt" 1 0))
           (planet "subst.ss" ("robby" "redex.plt" 1 0))
           (lib "list.ss"))
   
  (reduction-steps-cutoff 10)
  
  (define lang
    (language (e (e e ...)
                 (apply-values e e)
                 v
                 x)
              
              (v (lambda (x ...) e)
                 values
                 number)
              
              (C1 (hole single)
                  C)
              
              (C* (hole multi)
                  C)
              
              (C (hole either)
                 (v ... C1 e ...)
                 (apply-values C1 e)
                 (apply-values v C*))
              
              (x (variable-except lambda values apply-values))))
  
  (define reductions
    (list
     
     ;; values promotion
     (reduction lang 
                (in-named-hole multi
                               C1_1
                               v_i)
                (term (in-hole C1_1 (values v_i))))
     
     ;; values demotion
     (reduction lang
                (in-named-hole single
                               C1_1
                               (values v_1))
                (term (in-hole C1_1 v_1)))
     (reduction lang
                (side-condition
                 (in-named-hole single
                                C1_1
                                (values v_1 ...))
                 (not (= (length (term (v_1 ...))) 1)))
                "wrong number of values given to context")
     
     ; application
     (reduction lang
                (side-condition 
                 (in-named-hole either
                                C1_1
                                ((lambda (x_x ...) e_body) v_arg ...))
                 (= (length (term (x_x ...))) (length (term (v_arg ...)))))
                 (term
                  (in-hole C1_1 ,(lc-subst-all (term (x_x ...)) (term (v_arg ...)) (term e_body)))))
     
     ; apply-values
     (reduction lang
                (in-named-hole either
                               C1_1
                               (apply-values v_f (values v_x ...)))
                (term (in-hole C1_1 (v_f v_x ...))))))
  
  (define lc-subst
    (subst
     [(? symbol?) (variable)]
     [(? number?) (constant)]
     [`(lambda (,@(xs ...)) ,b)
       (all-vars xs)
       (build (lambda (vars body) `(lambda ,vars ,body)))
       (subterm xs b)]
     [`(,f ,@(xs ...))
       (all-vars '())
       (build (lambda (vars f . xs) `(,f ,@xs)))
       (subterm '() f)
       (subterms '() xs)]))
  
  (define (lc-subst-all terms values body)
    (foldl lc-subst body terms values))
  
  
  (define (evaluate term)
    (let loop ([term term])
      (let ([nexts (reduce reductions term)])
        (cond
          [(null? nexts) term]
          [(null? (cdr nexts)) (loop (car nexts))]
          [else (error 'evaluate "multiple reductions from ~s\n~s" term nexts)]))))
  
  (define (test term expected)
    (let ([got (evaluate term)])
      (unless (equal? got expected)
        (error 'test "~s\n     got: ~s\nexpected: ~s" term got expected))))
  
  (define (go term) (traces lang reductions term))
  
  (test '((lambda (x) x) (values (lambda (y) y))) '(lambda (y) y))
  (test '(apply-values (lambda (x) x) (lambda (y) y)) '(lambda (y) y))
  (test '(apply-values (lambda (a b) (a b))
                       ((lambda (f) 
                          (f ((lambda (id) id) (lambda (x) (x x)))
                             (lambda (x y) x)))
                        values))
        '((lambda (x y) x) (lambda (x y) x)))
  (test '(apply-values 
          (lambda (x) x) 
          (apply-values
           (lambda (y) y)
           ((lambda (z) z) (lambda (q) q))))
        '(lambda (q) q))
  (test '(apply-values 
          (apply-values (lambda (x) (lambda (y) x)) (values (lambda (q) q)))
          (apply-values (((lambda (z) z) (lambda (a) (a a))) (lambda (m) m)) (values (lambda (p) p))))
        '(lambda (q) q))
  
  (go '((lambda (x) (x x)) 
        ((lambda (y) y) (apply-values (lambda (x) (values x)) (lambda (x) (x x)))))))