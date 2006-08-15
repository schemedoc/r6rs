#|

Note: the parenthesization of the store and the dynamic
context is not quite the same as that in the paper.

|#

(module dw mzscheme
  (require (planet "reduction-semantics.ss" ("robby" "redex.plt" 1 0))
           (planet "reduction-semantics.ss" ("robby" "redex.plt" 1 0))
           (planet "gui.ss" ("robby" "redex.plt" 1 0))
           (lib "pretty.ss")
           (lib "list.ss")
           (lib "match.ss"))

  (define lang
    (language (p ((store (x v) ...) (dw dws ...) e))
              
              (dws (x e e))
              
              ;; note: trim isn't an expression
              (e (e e ...)
                 (throw dws ... e)
                 (push (d e e) e)
                 (pop e)
                 (begin e e ...)
                 (set! x e)
                 x
                 v)
              
              (v (lambda (x ...) e)
                 +
                 *
                 call/cc
                 dynamic-wind
                 number
                 (cons v v))
              
              (P ((store (x v) ...) (dw dws ...) C))
              
              (C (v ... C e ...)
                 (begin C e e ...)
                 (set! x C)
                 hole)
              
              (x (variable-except set! begin lambda + * push pop call/cc dynamic-wind throw trim))
              (d x)))
  
  ;; top-level reduce
  (define-syntax (--> stx)
    (syntax-case stx ()
      [(_ frm to)
       (syntax (reduction lang frm (collect (term to))))]))
  
  ;; reduce in P context, and collect garbage
  (define-syntax (~~> stx)
    (syntax-case stx ()
      [(_ frm to)
       (syntax (reduction lang 
                          (in-hole P_1 frm) 
                          (collect (plug (term P_1) (term to)))))]))
  
  (define reductions
    (list

     ;; generic reductions
     (~~> ((lambda (x_1 ...) e_1) v_1 ...)
          ,(subst-all (term (x_1 ...)) (term (v_1 ...)) (term e_1)))
     
     (~~> (+ number_1 ...) ,(apply + (term (number_1 ...))))
     (~~> (* number_1 ...) ,(apply * (term (number_1 ...))))
     
     (~~> (begin v e_1 e_2 ...) (begin e_1 e_2 ...))
     (~~> (begin e_1) e_1)

     (--> ((store (x_b v_b) ... (x_1 v_1) (x_a v_a) ...)
           (dw dws_1 ...)
           (in-hole C_1 (set! x_1 v_2)))
          ((store (x_b v_b) ... (x_1 v_2) (x_a v_a) ...)
           (dw dws_1 ...)
           (in-hole C_1 0)))
     (--> ((store (x_b v_b) ... (x_1 v_1) (x_a v_a) ...)
           (dw dws_1 ...)
           (in-hole C_1 x_1))
          ((store (x_b v_b) ... (x_1 v_1) (x_a v_a) ...)
           (dw dws_1 ...)
           (in-hole C_1 v_1)))
     
     ;; dynamic-wind
     (--> (name prog 
                ((store (x_s v_s) ...) 
                 (dw dws_1 ...) 
                 (in-hole C_1
                          (dynamic-wind (lambda () e_before)
                                        (lambda () e_during)
                                        (lambda () e_after)))))
          ,(term-let ([d (variable-not-in (term prog) 'd)]
                      [x (variable-not-in (term prog) 'x)])
             (term 
              ((store (x_s v_s) ...)
               (dw dws_1 ...)
               (in-hole C_1
                        (begin e_before 
                               (push (d e_before e_after)
                                     ((lambda (x) (pop (begin e_after x)))
                                      e_during))))))))
     
     ;; push dynamic context
     (--> ((store (x_s v_s) ...) (dw dws_1 ...) (in-hole C_1 (push (d_1 e_before e_after) e_next)))
          ((store (x_s v_s) ...) (dw (d_1 e_before e_after) dws_1 ...) (in-hole C_1 e_next)))
     
     ;; pop dynamic context
     (--> ((store (x_s v_s) ...) (dw dws_1 dws_2 ...) (in-hole C_1 (pop e_next)))
          ((store (x_s v_s) ...) (dw dws_2 ...) (in-hole C_1 e_next)))

     ;; call/cc
     (--> ((store (x_s v_s) ...) (dw dws_1 ...) (in-hole C_1 (call/cc v_1)))
          ((store (x_s v_s) ...) (dw dws_1 ...) 
                                 ,(term-let ([x (variable-not-in (term C_1) 'x)])
                                    (term (in-hole C_1
                                                   (v_1 
                                                    (lambda (x)
                                                      (throw dws_1 ... (in-hole C_1 x)))))))))
     
     ;; throw to a continuation
     (--> ((store (x_s v_s) ...) (dw dws_1 ...) (in-hole C_1 (throw dws_2 ... e_1)))
          ((store (x_s v_s) ...) (dw dws_2 ...) (trim (dws_1 ...) (dws_2 ...) e_1)))
     
     ;; remove shared portion of path
     (--> ((store (x_s v_s) ...) (dw dws_1 ...) (trim (dws_2 ... (x_1 e_b e_a)) (dws_3 ... (x_1 e_b e_a)) e_1))
          ((store (x_s v_s) ...) (dw dws_1 ...) (trim (dws_2 ...) (dws_3 ...) e_1)))
     
     ;; build up context of before & after thunk bodies
     (--> (side-condition
           ((store (x_s v_s) ...) (dw dws_1 ...) (trim ((x_from e_fb e_fa) ...)
                                                       ((x_to e_tb e_ta) ...)
                                                       e_1))
           (let ([from (term (x_from ...))]
                 [to (term (x_to ...))])
             (or (null? from) 
                 (null? to)
                 (not (eq? (car (last-pair from))
                           (car (last-pair to)))))))
          ((store (x_s v_s) ...) 
           (dw dws_1 ...) 
           (begin e_fa ... ,@(reverse (term (e_tb ...))) e_1)))))

  (define (collect term)
    (define (live-vars str dw e)
      (let loop ([from (map car str)]
                 [scan (append dw (get-vars e))]
                 [to '()])
        (cond
          [(null? scan) to]
          [else
           (let* ([var (car scan)]
                  [rhs (lookup var str)])
             (if rhs
                 (let ([new-vars 
                        (filter
                         (λ (x) (memq x from))
                         (get-vars rhs))])
                   (loop (filter (λ (x) (not (memq x new-vars))) from)
                         (cdr scan)
                         (cons var to)))
                 (loop from
                       (cdr scan)
                       to)))])))
    
    (define (lookup var str)
      (let loop ([str str])
        (cond
          [(null? str) #f]
          [else (let ([fr (car str)])
                  (if (eq? (car fr) var)
                      (cadr fr)
                      (loop (cdr str))))])))
    
    (define (get-vars e)
      (let ([ht (make-hash-table)])
        (let loop ([e e])
          (cond
            [(pair? e) 
             (loop (car e)) 
             (loop (cdr e))]
            [(symbol? e)
             (hash-table-put! ht e #t)]
            [else (void)]))
        (hash-table-map ht (λ (x y) x))))
    
    (match term
      [`((store ,@(str ...)) (dw ,@(dw ...)) ,e)
        (let ([to-save (live-vars str dw e)])
          `((store ,@(filter (lambda (x) (memq (car x) to-save)) str))
            (dw ,@dw)
            ,e))]))
  
  (define subst-one 
    (subst
     [`cons (constant)]
     [`null (constant)]
     [`throw (constant)]
     [`call/cc (constant)]
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
  
  (define (subst-all params args body) (foldl subst-one body params args))
  
  (define (variables-not-in items exp prefix)
    (cond
      [(null? items) null]
      [else 
       (let ((this (variable-not-in exp prefix)))
         (cons this (variables-not-in (cdr items) (cons this exp) prefix)))]))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;;  testing code
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
  
  (define-syntax (test stx)
    (syntax-case stx ()
      [(_ term expected)
       (with-syntax ([line (syntax-line stx)])
         (syntax (test/proc term expected line)))]))
  
  (define (test/proc term expected line)
    (let ([got (evaluate term)]
          [mz-got (run-mz term)]
          [mz-expected (run-mz expected)])
      (unless (equal? got expected)
        (fprintf (current-error-port) "line ~s\n    test: ~s\n     got: ~s\nexpected: ~s\n\n"
                 line
                 term
                 got
                 expected))
      (unless (equal? mz-got mz-expected)
        (fprintf (current-error-port) "line ~s\nMZ  test: ~s\n     got: ~s\nexpected: ~s\n\n" 
                 line
                 term 
                 mz-got
                 mz-expected))))
  
  (define (run-mz term)
    (match term
      [`((store ,@(binds ...)) ,dw ,e)
        (eval `(let ,binds ,e))]))
  
  (define (show x) (traces lang reductions x))
  (reduction-steps-cutoff 40)
  (show '((store (x 0))
          (dw)
          ((dynamic-wind (lambda () (set! x (+ (* x 2) 0)))
                         (lambda () (call/cc (lambda (k) k)))
                         (lambda () (set! x (+ (* x 2) 1))))
           (lambda (y) x))))
  
  (test '((store [x 2]) (dw) x) '((store) (dw) 2))
  (test '((store [x 2]) (dw) (begin (set! x (+ x 1)) x)) '((store) (dw) 3))

  (test '((store) (dw) (+ (call/cc (lambda (k) (+ (k 1) 1))) 1))
        '((store) (dw) 2))
  (test '((store) (dw) ((call/cc (lambda (x) x)) (lambda (y) 1)))
        '((store) (dw) 1))
  (test '((store (x 0)) 
          (dw)   
          (begin
            (dynamic-wind (lambda () (set! x 1))
                          (lambda () (set! x 2))
                          (lambda () (set! x 3)))
            x))
        '((store) (dw) 3))

  (test '((store (x 0)) (dw) (dynamic-wind (lambda () (set! x (+ x 1)))
                                           (lambda () (begin (set! x (+ x 1)) x))
                                           (lambda () (set! x (+ x 1)))))
        '((store) (dw) 2))
  
#|

to read these tests, read the argument to conv-base from right to left
each corresponding set! should happen in that order.
in case of a test case failure, turn the number back into a sequence
of digits with deconv-base

|#
  
  (define (conv-base base vec)
    (let loop ([i (vector-length vec)]
               [acc 0])
      (cond
        [(zero? i) acc]
        [else (loop (- i 1)
                    (+ acc (* (expt base (- i 1))
                              (vector-ref vec (- i 1)))))])))
  
  (define (deconv-base base number)
    (list->vector
     (let loop ([i number])
       (cond
         [(zero? i) '()]
         [else (cons (modulo i base)
                     (loop (quotient i base)))]))))
      
  ;; hop out one level
  (test '((store (x 0)) (dw) ((dynamic-wind (lambda () (set! x (+ (* x 2) 0)))
                                            (lambda () (call/cc (lambda (k) k)))
                                            (lambda () (set! x (+ (* x 2) 1))))
                              (lambda (y) x)))
        `((store) (dw) ,(conv-base 2 #(1 0 1 0))))
  
  ;; hop out two levels
  (test '((store (x 0)) (dw) ((dynamic-wind 
                               (lambda () (set! x (+ (* x 5) 1)))
                               (lambda () 
                                 (dynamic-wind
                                  (lambda () (set! x (+ (* x 5) 2)))
                                  (lambda () (call/cc (lambda (k) k)))
                                  (lambda () (set! x (+ (* x 5) 3)))))
                               (lambda () (set! x (+ (* x 5) 4))))
                              (lambda (y) x)))
        `((store) (dw) ,(conv-base 5 #(4 3 2 1 4 3 2 1))))
  
  ;; don't duplicate tail
  (test '((store (x 0)) (dw) (dynamic-wind 
                              (lambda () (set! x (+ (* x 5) 1)))
                              (lambda () 
                                ((dynamic-wind (lambda () (set! x (+ (* x 5) 2)))
                                               (lambda () (call/cc (lambda (k) k)))
                                               (lambda () (set! x (+ (* x 5) 3))))
                                 (lambda (y) x)))
                              (lambda () (set! x (+ (* x 5) 4)))))
        `((store) (dw) ,(conv-base 5 #(3 2 3 2 1))))
  
  ;; dont' duplicate tail, 2 deep
  (test '((store (x 0)) (dw) (dynamic-wind 
                              (lambda () (set! x (+ (* x 7) 1)))
                              (lambda () 
                                (dynamic-wind 
                                 (lambda () (set! x (+ (* x 7) 2)))
                                 (lambda () 
                                   ((dynamic-wind (lambda () (set! x (+ (* x 7) 3)))
                                                  (lambda () (call/cc (lambda (k) k)))
                                                  (lambda () (set! x (+ (* x 7) 4))))
                                    (lambda (y) x)))
                                 (lambda () (set! x (+ (* x 7) 5)))))
                              (lambda () (set! x (+ (* x 7) 6)))))
        `((store) (dw) ,(conv-base 7 #(4 3 4 3 2 1))))
  
  ;; hop out and back into another one
  (test '((store (x 0)) (dw) ((lambda (ok)
                                (dynamic-wind (lambda () (set! x (+ (* x 5) 1)))
                                              (lambda () (ok (lambda (y) x)))
                                              (lambda () (set! x (+ (* x 5) 2)))))
                              (dynamic-wind (lambda () (set! x (+ (* x 5) 3)))
                                            (lambda () (call/cc (lambda (k) k)))
                                            (lambda () (set! x (+ (* x 5) 4))))))
        `((store) (dw) ,(conv-base 5 #(1 4 3 2 1 4 3))))
  
  ;; hop out one level and back in two levels
  (test '((store (x 0)) (dw) ((lambda (ok)
                                (dynamic-wind
                                 (lambda () 1)
                                 (lambda () 
                                   (dynamic-wind
                                    (lambda () 2)
                                    (lambda () (ok (lambda (y) x)))
                                    (lambda () (set! x (+ (* x 3) 1)))))
                                 (lambda () (set! x (+ (* x 3) 2)))))
                              (call/cc (lambda (k) k))))
        `((store) (dw) ,(conv-base 3 #(2 1))))

  ;; hop out two levels and back in two levels
  (test '((store (x 0)) (dw) ((lambda (ok)
                                (dynamic-wind
                                 (lambda () (set! x (+ (* x 9) 1)))
                                 (lambda () 
                                   (dynamic-wind
                                    (lambda () (set! x (+ (* x 9) 2)))
                                    (lambda () (ok (lambda (y) x)))
                                    (lambda () (set! x (+ (* x 9) 3)))))
                                 (lambda () (set! x (+ (* x 9) 4)))))
                              (dynamic-wind
                               (lambda () (set! x (+ (* x 9) 5)))
                               (lambda () 
                                 (dynamic-wind
                                  (lambda () (set! x (+ (* x 9) 6)))
                                  (lambda () (call/cc (lambda (k) k)))
                                  (lambda () (set! x (+ (* x 9) 7)))))
                               (lambda () (set! x (+ (* x 9) 8))))))
        `((store) (dw) ,(conv-base 9 #(2 1 8 7 6 5 4 3 2 1 8 7 6 5)))))