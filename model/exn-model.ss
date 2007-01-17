#|

This shows a small model of the r6 exceptions. Works like call-by-need! :)

|#

(module exn-model mzscheme
  (require "redex-gui.scm"
           "redex.scm"
           (lib "plt-match.ss"))
  
  (define lang
    (language
     (e (e e ...) x v)
     (v raise-continuable
        with-exception-handler
        (lambda (x ...) e)
        +
        number)
     (x (variable-except raise-continuable
                         with-exception-handler
                         lambda
                         +))
     
     (E (in-hole F (with-exception-handler (lambda (x) e) (lambda () E)))
        F)
     
     (F hole
        (v ... F e ...)
        (with-exception-handler
         (lambda (x) F)
         (lambda () (in-hole F (raise-continuable v)))))))
  
  (define red-rel
    (reduction-relation
     lang
     (--> (in-hole E_1 ((lambda (x_1 x_2 ...) e_1) v_1 v_2 ...))
          (in-hole E_1 ((lambda (x_2 ...) ,(subst-one (term x_1) (term v_1) (term e_1))) 
                        v_2 ...)))
     (--> (in-hole E_1 ((lambda () e_1)))
          (in-hole E_1 e_1))
     
     (--> (in-hole E_1 (+ number_1 ...))
          (in-hole E_1 ,(apply + (term (number_1 ...)))))
     
     (--> (in-hole E_1 (with-exception-handler 
                        (lambda (x_1) v_1)
                        (lambda () (in-hole F_1 (raise-continuable v_2)))))
          (in-hole E_1 (with-exception-handler
                        (lambda (x_1) v_1)
                        (lambda () (in-hole F_1 v_1)))))
  
     (--> (in-hole E_1 (with-exception-handler
                        (lambda (x_1) (in-hole E_2 x_1))
                        (lambda () (in-hole F_1 (raise-continuable v_1)))))
          (in-hole E_1 (with-exception-handler
                        (lambda (x_1) (in-hole E_2 v_1))
                        (lambda () (in-hole F_1 (raise-continuable v_1))))))
     
     (--> (in-hole E_1 (with-exception-handler 
                        (lambda (x_1) e)
                        (lambda () v_1)))
          (in-hole E_1 v_1))))
  
  (define subst-one 
    (subst
     [(? symbol?) (variable)]
     [(? number?) (constant)]
     [(? boolean?) (constant)]
     [`(lambda ,(xs ...) ,@(bs ...))
       (all-vars xs)
       (build (lambda (vars . bodies) `(lambda ,xs ,@bodies)))
       (subterms xs bs)]
     [(f args ...)
      (all-vars '())
      (build (lambda (vars f . args) `(,f ,@args)))
      (subterm '() f)
      (subterms '() args)]))
  
  (traces lang red-rel
          '(+ 1 (with-exception-handler
                 (lambda (x) (+ 2 x))
                 (lambda () (+ 3 (raise-continuable (+ 2 2))))))))

