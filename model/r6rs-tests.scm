(module r6rs-tests mzscheme
  (require (lib "match.ss")
           (lib "list.ss")
           (lib "etc.ss")
           (planet "reduction-semantics.ss" ("robby" "redex.plt" 3))
           "test.scm"
           "r6rs.scm")
  
  ;; ============================================================
  ;; TESTING APPARATUS
  
  (define-struct r6test (test expected))
  
  (define (make-r6test/v t expected) 
    (make-r6test `(store () ,t)
                 (list `(store () (values ,expected)))))
  (define (make-r6test/e t err)
    (make-r6test `(store () ,t)
                 (list `(uncaught-exception (condition ,err)))))
  
  (define (run-a-test test verbose?)
    (unless verbose?
      (printf ".") 
      (flush-output))
    (let ([t (r6test-test test)]
          [expected (r6test-expected test)])
      (set! test-count (+ test-count 1))
      (when verbose? (printf "testing ~s ... " t))
      (flush-output)
      (with-handlers ([exn:fail:duplicate?
                       (lambda (e)
                         (set! failed-tests (+ failed-tests 1))
                         (unless verbose? 
                           (printf "\ntesting ~s ... " t))
                         (raise e))])
        (let* ([results (evaluate reductions
                                  t
                                  (or verbose? 'dots)
                                  (verify-p* t))]
               [rewritten-results (remove-duplicates (map rewrite-actual results))])
          (for-each (verify-a* t) results)
          (unless (set-same? expected rewritten-results equal?)
	    (set! failed-tests (+ failed-tests 1))
            (unless verbose? 
              (printf "\ntesting ~s ... " t))
	    (printf "TEST FAILED!~nexpected:~a\nrewritten-received:~a\nreceived:~a\n\n"
		    (combine-in-lines expected)
		    (combine-in-lines rewritten-results)
                    (combine-in-lines results)))))))
  
  (define p*-pattern (test-match lang p*))
  (define a*-pattern (test-match lang a*))
  (define r*-pattern (test-match lang r*))
  (define verified-terms 0)
  (define ((verify-p* orig) sexp)
    (let ([m (p*-pattern sexp)])
      (unless (and m
                   (= 1 (length m)))
        (newline)
        (error 'verify-p* "matched ~a times\n ~s\norig\n ~s" 
               (if m
                   (length m)
                   "0")
               sexp orig))
      (set! verified-terms (+ verified-terms 1))))
  
  (define ((verify-a* orig-sexp) sexp)
    (unless (a*-pattern sexp)
      (newline) 
      (error 'verify-a* "didn't match ~s\noriginal term ~s" sexp orig-sexp))
    
    ;; verify that observable is defined for this value
    (let ([candidate-r* (term-let ((sexp sexp))
                          (term (observable sexp)))])
      (unless (r*-pattern candidate-r*)
        (error 'verify-a* "observable of ~s is ~s, but isn't an r*\noriginal term ~s"
               sexp
               candidate-r*
               orig-sexp))))
  
  (define (remove-duplicates lst)
    (let ([ht (make-hash-table 'equal)])
      (for-each (λ (x) (hash-table-put! ht x #t)) lst)
      (hash-table-map ht (λ (x y) x))))
  
  (define (combine-in-lines strs) (apply string-append (map (λ (x) (format "\n  ~s" x)) strs)))
  
  (define (rewrite-actual actual)
    (match actual
      [`(unknown ,str) actual]
      [`(uncaught-exception ,v) actual]
      [`(store ,@(xs ...)) 
       (let loop ([actual actual])
         (subst-:-vars actual))]
      [_
       (error 'rewrite-actual "unknown actual ~s\n" actual)]))
  
  (define (subst-:-vars exp)
    (match exp
      [`(store ,str ,exps ...)
       (let* ([pp-var? (λ (x) (regexp-match #rx"^[qp]p" (format "~a" (car x))))]
              [pp-bindings (filter pp-var? str)]
              [with-out-pp (fp-sub pp-bindings `(store ,(filter (λ (x) (not (pp-var? x))) str) ,@exps))]
              [with-out-app-vars (remove-unassigned-app-vars with-out-pp)]
              [without-lxri-vars (remove-unused-lxri-vars with-out-app-vars)])
         without-lxri-vars)]
      [`(unknown ,string) string]
      [_ (error 'subst-:-vars "unknown exp ~s" exp)]))
  
  (define (is-lxri-var? x) (regexp-match #rx"^lxri" (symbol->string x)))
  
  (define (remove-unused-lxri-vars exp)
    (match exp
      [`(store ,str ,exps ...)
       (let ([lxri-vars (filter is-lxri-var? (map car str))]
             [str-without-lxri-binders 
              (filter (λ (binding) (not (is-lxri-var? (car binding)))) str)])
         `(store ,(filter (λ (binding) 
                            (cond
                              [(is-lxri-var? (car binding)) 
                               (not (not-in (car binding) (cons str-without-lxri-binders exps)))]
                              [else #t]))
                          str)
            ,@exps))]))
  
  (define (remove-unassigned-app-vars term)
    (match term 
      [`(store ,bindings ,body)
       (let* ([binding-rhss (map cadr bindings)]
              [bindings-to-sub 
               (filter (λ (binding) (not (appears-in-set? (car binding) body)))
                       (filter (λ (binding) (regexp-match #rx"^bp" (format "~a" (car binding)))) bindings))]
              [vars-to-sub (map car bindings-to-sub)])
         `(store ,(filter (λ (binding) (not (memq (car binding) vars-to-sub))) bindings)
            ,(r6-all bindings-to-sub body)))]))
  
  (define (not-in var e)
    (cond
      [(pair? e) (and (not-in var (car e))
                      (not-in var (cdr e)))]
      [else (not (eq? var e))]))
  
  (define (appears-in-set? x e)
    (let loop ([e e])
      (match e
        [`(set! ,x2 ,e2) (or (eq? x x2)
                             (loop e2))]
        [else
         (and (list? e) 
              (ormap loop e))])))
           
  
  (define (fp-sub bindings term)
    (let loop ([term term])
      (let ([next (do-one-subst bindings term)])
        (cond 
          [(equal? term next) next]
          [else (loop next)]))))
  
  (define (r6-all sub-vars body)
    (term-let ([(sub-vars ...) sub-vars]
               [body body])
      (term (r6rs-subst-many (sub-vars ... body)))))
  
  (define (do-one-subst sub-vars term)
    (match term
      [`(store ,str ,exps ...)
       (let* ([keep-vars 
               (map (λ (pr)
                      `(,(car pr)
                        ,(r6-all sub-vars (cadr pr))))
                    str)])
         `(store ,keep-vars ,@(r6-all sub-vars exps)))]))
  
  (define test-count 0)
  (define failed-tests 0)
  
  (define arithmetic-tests
    (list
     (make-r6test/v '(+) 0)
     (make-r6test/v '(+ 1) 1)
     (make-r6test/v '(+ 1 2) 3)
     (make-r6test/v '(+ 1 2 3) 6)
     
     (make-r6test/v '(- 1) -1)
     (make-r6test/v '(- 1 2) -1)
     (make-r6test/v '(- 1 2 3) -4)
     
     (make-r6test/v '(*) 1)
     (make-r6test/v '(* 2) 2)
     (make-r6test/v '(* 2 3) 6)
     (make-r6test/v '(* 2 3 4) 24)
     
     (make-r6test/v '(/ 2) 1/2)
     (make-r6test/v '(/ 1 2) 1/2)
     (make-r6test/v '(/ 1 2 3) 1/6)
     
     (make-r6test/e '(/ #f) "arith-op applied to non-number")
     
     (make-r6test/e '(/ 1 2 3 4 5 0 6) "divison by zero")
     (make-r6test/e '(/ 0) "divison by zero")
     
     (make-r6test '(store () ((lambda (x) (+ x x)) #f))
                  (list '(uncaught-exception (condition "arith-op applied to non-number"))))))
  
  (define assignment-results-tests
    (list
     ;; begin
     (make-r6test/v '((lambda (x) (begin x (set! x 2) x)) 3)
                    2)
     (make-r6test '(store () (letrec ([x 1]) (begin 2 (set! x 2))))
                  (list '(unknown "unspecified result")))

     ;; begin0 
     (make-r6test/v '((lambda (x) (begin0 x (set! x 2))) 3)
                    3)
     (make-r6test '(store () (letrec ([x 1]) (begin0 (set! x 2) 2 3)))
                  (list '(unknown "unspecified result")))
     (make-r6test/v '((lambda (x) (begin (begin0 (set! x 1) (set! x 2)) x)) 3)
                    2)
     
     
     ;; application
     (make-r6test '(store () (letrec ([x 1]) ((lambda (x) 1) (set! x 2))))
                  (list '(unknown "unspecified result")))
     (make-r6test '(store () (letrec ([x 1]) ((set! x 2) 2)))
                  (list '(unknown "unspecified result")))
     
     ;; if
     (make-r6test '(store () (letrec ([x 1]) (if (set! x 2) 2 3)))
                  (list '(unknown "unspecified result")))
     
     ;; set!
     (make-r6test '(store () (letrec ([x 1]) (set! x (set! x 2))))
                  (list '(unknown "unspecified result")))
     
     (make-r6test '(store () (letrec ([x '(1)]) (set! x (set-car! x 2))))
                  (list '(unknown "unspecified result")))
     
     ;; handlers
     (make-r6test '(store () (letrec ([x 1]) (with-exception-handler (lambda (e) (set! x 2)) (lambda () (car 'x)))))
                  (list '(uncaught-exception (condition "handler returned"))))
     
     ;; call with values
     (make-r6test '(store () (letrec ([x 1]) (call-with-values (lambda () (set! x 2)) +)))
                  (list '(unknown "unspecified result")))
     
     ;; dynamic-wind
     (make-r6test/v '((lambda (x) (dynamic-wind (lambda () (set! x 0)) (lambda () x) (lambda () (set! x 2)))) 1)
                    0)
     (make-r6test '(store () (letrec ([x 1]) (dynamic-wind (lambda () 0) (lambda () (set! x 2)) (lambda () 1))))
                  (list '(unknown "unspecified result")))
     (make-r6test '(store () (letrec ([x 1]) (begin (dynamic-wind (lambda () 0) (lambda () (set! x 2)) (lambda () 1)) 5)))
                  (list '(store ((lx-x 2)) (values 5))))))
  
  (define basic-form-tests
    (list
     
     (make-r6test/e '((lambda (x y) x) (lambda (x) x))
                    "arity mismatch")
     
     (make-r6test/v '(if #t 12 13) 12)
     (make-r6test/v '(if #f 12 13) 13)
     (make-r6test/v '(begin (if #f 12 14) 14) 14)
     (make-r6test/v '((lambda (x) (if #t (set! x 45) 'x) x) 1) 45)
     (make-r6test/v '((lambda (x) (if #f (set! x 45) 'z) x) 1) 1)
     
     ;; begin0 tests
     (make-r6test/v '(begin0 (+ 1 1))
                    2)
     (make-r6test/v '(begin0 (+ 1 1) (+ 2 3))
                    2)
     (make-r6test/v '((lambda (x) (begin0 x (set! x 4))) 2)
                    2)
     (make-r6test/v '(((lambda (x) (begin0 (lambda () x) (set! x (+ x 1)) (set! x (+ x 1)) (set! x (+ x 1))))
                       2))
                    5)))
  
  (define pair-tests
    (list
     (make-r6test/v '(if (null? (cons 1 (cons 2 (cons (lambda (x) x) null)))) 0 1) 
                    1)
     (make-r6test/v '(null? (cons 1 (cons 2 (cons (lambda (x) x) null)))) #f)
     (make-r6test/v '(null? (cons 1 2)) #f)
     (make-r6test/v '(null? null) #t)
     (make-r6test/v '(pair? null) #f)
     (make-r6test/v '(pair? (cons 1 1)) #t)
     (make-r6test/v '(null? (list 1 2)) #f)
     (make-r6test/v '(pair? (list 1)) #t)
     (make-r6test/v '(pair? (list)) #f)
     (make-r6test/v '(null? (list)) #t)
     
     (make-r6test/v '((lambda (x) ((lambda (y) (car (cdr x))) (begin (set-car! (cdr x) 400) 11))) 
                      (cons 1 (cons 2 null)))
                    400)
     (make-r6test/v '((lambda (x) ((lambda (y) (cdr (cdr x))) (begin (set-cdr! (cdr x) 400) 12)))
                      (cons 1 (cons 2 null))) 
                    400)
     (make-r6test '(store ()
                     (letrec ([first-time? #t]
                              [f (lambda (dot y) (if first-time?
                                                     (begin
                                                       (set! first-time? #f)
                                                       (set-car! y 2))
                                                     (car y)))]
                              [g (lambda () (apply f '(1)))])
                       (g)
                       (g)))
                  (list '(store ((lx-first-time? #f)
                                 (lx-f (lambda (dot y) (if lx-first-time?
                                                           (begin
                                                             (set! lx-first-time? #f)
                                                             (set-car! y 2))
                                                           (car y))))
                                 (lx-g (lambda () (apply lx-f (cons 1 null)))))
                           (values 1))))))
  
  (define quote-tests
    (list
     (make-r6test/v ''#f #f)
     (make-r6test/v ''#t #t)
     (make-r6test/v ''1 1)
     (make-r6test/v ''x ''x)
     (make-r6test/v ''null ''null)
     (make-r6test/v '(null? 'null) #f)
     (make-r6test/v ''unspecified ''unspecified)
     (make-r6test/v '((lambda (x) (eqv? 'x 1)) 1) #f)
     (make-r6test/v ''(dot 1) 1)
     (make-r6test/v ''(dot x) ''x)))
  
  (define eqv-tests
    (list
     (make-r6test '(store () (eqv? (lambda (x) x) (lambda (x) x)))
                  (list '(unknown "equivalence of procedures")))
     (make-r6test '(store () (eqv? (lambda (x) x) (lambda (x) x)))
                  (list '(unknown "equivalence of procedures")))
     
     (make-r6test/v '(eqv? (cons 1 2) (cons 1 2)) #f)
     (make-r6test/v '((lambda (x) (eqv? x x)) (cons 1 2)) #t)
     (make-r6test '(store () ((lambda (x) (eqv? x x)) (lambda (x) x)))
                  (list '(unknown "equivalence of procedures")))
     
     (make-r6test '(store () (apply apply values '(())))
                  (list '(store () (values))))
     
     (make-r6test/v '(eqv? #t #t) #t)
     (make-r6test/v '(eqv? #t #f) #f)))
  
  (define err-tests
    (list
     
     (make-r6test/e '(call-with-values (lambda (x) x) (lambda (y) y))
                    "arity mismatch")
     (make-r6test/e '(/) "arity mismatch")
     (make-r6test/e '(-) "arity mismatch")
     (make-r6test/e '(cons) "arity mismatch")
     (make-r6test/e '(null?) "arity mismatch")
     (make-r6test/e '(pair?) "arity mismatch")
     (make-r6test/e '(car) "arity mismatch")
     (make-r6test/e '(cdr) "arity mismatch")
     (make-r6test/e '(set-car!) "arity mismatch")
     (make-r6test/e '(set-cdr!) "arity mismatch")
     (make-r6test/e '(call/cc) "arity mismatch")
     (make-r6test/e '(eqv?) "arity mismatch")
     (make-r6test/e '(apply) "arity mismatch")
     (make-r6test/e '(apply values) "arity mismatch")
     (make-r6test/e '(call-with-values) "arity mismatch")
     
     (make-r6test/e '(dynamic-wind 1) "arity mismatch")
     
     (make-r6test/e '(apply 1 2) "can't apply non-procedure")
     (make-r6test/e '(apply 1 null) "can't apply non-procedure")
     (make-r6test/e '(apply values 2) "apply's last argument non-list")
     (make-r6test/e '(car 1) "can't take car of non-pair")
     (make-r6test/e '(cdr 1) "can't take cdr of non-pair")
     (make-r6test/e '(set-car! 2 1) "can't set-car! on a non-pair")
     (make-r6test/e '(set-cdr! 1 2) "can't set-cdr! on a non-pair")
     
     (make-r6test/e '(call/cc 1) "can't call non-procedure")
     (make-r6test/e '(call-with-values 1 2) "can't call non-procedure")))
  
  (define r5-tests
    (list
     
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;
     ;; tests from R5RS
     ;;
     
     ; ----
     ; 4.1.3
     (make-r6test/v '(+ 3 4) 7)
     (make-r6test/v '((if #f + *) 3 4) 12)
     
     
     ; ----
     ; 4.1.4
     (make-r6test/v '(lambda (x) (+ x x)) '(lambda (x) (+ x x)))
     (make-r6test/v '((lambda (x) (+ x x)) 4) 8)
     
     (make-r6test '(store ()
                     (letrec* ([reverse-subtract
                                (lambda (x y) (- y x))])
                       (reverse-subtract 7 10)))
                  (list
                   '(store ((lx-reverse-subtract (lambda (x y) (- y x))))
                      (values 3))))
     
     (make-r6test '(store ()
                     (letrec* ([add4
                                ((lambda (x)
                                   (lambda (y)
                                     (+ x y)))
                                 4)])
                       (add4 6)))
                  (list
                   '(store ((lx-add4 (lambda (y) (+ 4 y))))
                      (values 10))))
     
     (make-r6test/v '((lambda (dot x) x) 3 4 5 6)
                    '(cons 3 (cons 4 (cons 5 (cons 6 null)))))
     (make-r6test/v '((lambda (x y dot z) z) 3 4 5 6)
                    '(cons 5 (cons 6 null)))
     
     ; ----
     ; 4.2.2 
     
     (make-r6test '(store ()
                     (letrec* ([even?
                                (lambda (n)
                                  (if (eqv? 0 n)
                                      #t
                                      (odd? (- n 1))))]
                               [odd?
                                (lambda (n)
                                  (if (eqv? 0 n)
                                      #f
                                      (even? (- n 1))))])
                       ;; using 88 here runs, but isn't really much more useful
                       ;; for testing purposes (it also takes > 1000 reductions)
                       (even? 2)))
                  (list
                   '(store ((lx-even?
                             (lambda (n)
                               (if (eqv? 0 n)
                                   #t
                                   (lx-odd? (- n 1)))))
                            (lx-odd?
                             (lambda (n)
                               (if (eqv? 0 n)
                                   #f
                                   (lx-even? (- n 1))))))
                      
                      (values #t))))
     
     ; ----
     ; 4.2.3
     (make-r6test '(store () (letrec* ([x 0]) (begin (set! x 5) (+ x 1))))
                  (list '(store ((lx-x 5)) (values 6))))
     
     
     ; ----
     ; 5.2.1
     
     (make-r6test '(store () 
                     (letrec* ([add3 (lambda (x) (+ x 3))])
                       (add3 3)))
                  (list '(store ((lx-add3 (lambda (x) (+ x 3)))) (values 6))))
     (make-r6test '(store () (letrec* ((first car))
                               (first '(1 2))))
                  (list '(store ((lx-first car)) (values 1))))
     
     
     ; ----
     ; 6.1
     
     (make-r6test/v '(eqv? 'a 'a) #t)
     (make-r6test/v '(eqv? 'a 'b) #f)
     (make-r6test/v '(eqv? 2 2) #t)
     (make-r6test/v '(eqv? '() '()) #t)
     (make-r6test/v '(eqv? 100000000 100000000) #t)
     (make-r6test/v '(eqv? (cons 1 2) (cons 1 2)) #f)
     (make-r6test '(store () (eqv? (lambda () 1) (lambda () 2)))
                  (list '(unknown "equivalence of procedures")))
     (make-r6test/v '(eqv? #f 'nil) #f)
     (make-r6test/v '(eqv? #f '()) #f)
     (make-r6test '(store () ((lambda (p) (eqv? p p)) (lambda (x) x)))
                  (list '(unknown "equivalence of procedures")))
     
     (make-r6test 
      '(store () 
         (define gen-counter
           (lambda ()
             ((lambda (n) 
                (lambda () (set! n (+ n 1)) n))
              0)))
         ((lambda (g) (eqv? g g))
          (gen-counter)))
      (list '(unknown "equivalence of procedures")))
     
     (make-r6test 
      '(store () 
         (define gen-counter
           (lambda ()
             ((lambda (n) 
                (lambda () (set! n (+ n 1)) n))
              0)))
         (eqv? (gen-counter) (gen-counter)))
      (list '(unknown "equivalence of procedures")))
     
     
     
     ; ----
     ; 6.3.2
     
     (make-r6test '(store ()
                     (define x (list 'a 'b 'c))
                     (define y x)
                     y)
                  (list
                   '(store ((x (cons 'a (cons 'b (cons 'c null))))
                            (y (cons 'a (cons 'b (cons 'c null)))))
                      (values (cons 'a (cons 'b (cons 'c null)))))))
     
     (make-r6test '(store ()
                     (define x (list 'a 'b 'c))
                     (define y x)
                     (set-cdr! x 4)
                     x)
                  (list
                   '(store ((x (cons 'a 4))
                            (y (cons 'a 4)))
                      (values (cons 'a 4)))))
     
     (make-r6test '(store ()
                     (define x (list 'a 'b 'c))
                     (define y x)
                     (set-cdr! x 4)
                     (eqv? x y))
                  (list
                   '(store ((x (cons 'a 4))
                            (y (cons 'a 4)))
                      (values #t))))
     
     (make-r6test '(store ()
                     (define x (list 'a 'b 'c))
                     (define y x)
                     (set-cdr! x 4)
                     y)
                  (list
                   '(store ((x (cons 'a 4))
                            (y (cons 'a 4)))
                      (values (cons 'a 4)))))
     
     ; ----
     ; 6.4
     (make-r6test/v '(apply + (list 3 4)) 7)
     
     (make-r6test
      '(store ()
         (define compose
           (lambda (f g)
             (lambda (dot args)
               (f (apply g args)))))
         
         (define sqrt (lambda (x) (if (eqv? x 900) 30 #f)))
         
         ((compose sqrt *) 12 75))
      (list '(store ((compose (lambda (f g)
                                (lambda (dot args)
                                  (f (apply g args)))))
                     (sqrt (lambda (x) (if (eqv? x 900) 30 #f))))
               (values 30))))))
  
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
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; app tests
  ;;
  
  (define app-tests
    (list 
     (make-r6test/v '((lambda () 1)) 1)
     (make-r6test/v '(((lambda (x) (lambda (x) x)) 1) 2) 2)
     (make-r6test/v '(((lambda (x) (lambda (x dot y) x)) 1) 2) 2)
     (make-r6test/v '(((lambda (x) (lambda (y dot x) (car x))) 1) 2 3) 3)
     (make-r6test/e '((lambda (x y) x) 1) "arity mismatch")
     (make-r6test/v '(car ((lambda (x) (cons x null)) 3)) 3)
     (make-r6test/v '((lambda (x) x) 3) 3)
     (make-r6test/v '((lambda (x y) (- x y)) 6 5) 1)
     (make-r6test/e '((lambda () (+ x y z)) 3 4 5)
                    "arity mismatch")
     (make-r6test/v '((lambda (x y z) (+ x y z)) 3 4 5) 12)
     (make-r6test/v '((lambda (x y) (+ x y)) (+ 1 2) (+ 3 4)) 10)
     (make-r6test/v '((lambda (x1 x2 dot y) (car y)) 1 2 3 4) 3)
     (make-r6test/v '((lambda (x dot y) (car y)) 1 2 3 4) 2)
     (make-r6test/v '((lambda (x dot y) x) 1) 1)
     (make-r6test/e '((lambda (x y dot z) x) 1)
                    "arity mismatch")
     (make-r6test/v '((lambda (dot args) (car (cdr args))) 1 2 3 4 5 6) 2)
     (make-r6test/v '((lambda (dot args) (eqv? args args)) 1 2) #t)
     (make-r6test/v '((lambda (dot args) ((lambda (y) args) (begin (set! args 50) 123)))) 50)
     (make-r6test '(store () ((lambda (dot args) ((lambda (y) args) (set! args 50)))))
                  (list '(unknown "unspecified result")))
     (make-r6test/v '(if ((lambda (x) x) 74) ((lambda () 6)) (6 54)) 6)
     (make-r6test/e '(1 1) "can't call non-procedure")
     (make-r6test/e '(if ((lambda (x) x) #f) ((lambda () 6)) (6 54))
                    "can't call non-procedure")
     
     (make-r6test '(store () (- 1))
                  (list '(store () (values -1))))
     
     (make-r6test '(store () (- (- 1)))
                  (list '(store () (values 1))))
     
     (make-r6test '(store ((x 1)) (begin (set! x (begin (set! x (- x)) (- x))) x))
                  (list '(store ((x 1)) (values 1))))
     
     (make-r6test '(store ((x 1))
                     ((lambda (p q) x)
                      (begin (set! x (- x)) 1)
                      (begin (set! x (- x)) 1)))
                  (list '(store ((x 1))
                           (values 1))))
     
     (make-r6test '(store ((x 1))
                     ((lambda (p q) 1)
                      (begin (set! x 5) 1)
                      (begin (set! x 6) 2)))
                  (list '(store ((x 5)) (values 1))
                        '(store ((x 6)) (values 1))))
     
     (make-r6test/v '(call/cc
                      (lambda (k)
                        (with-exception-handler
                         (lambda (e) (k e))
                         (lambda () (apply (lambda (x y) x) 1 null)))))
                    '(condition "arity mismatch"))
     
     (make-r6test/v '((lambda (x) ((lambda (y) x) (begin (set! x 5) 'whatever))) 3) 5)
     (make-r6test '(store ()
                     (((lambda (a b ret) ((lambda (x y) ret) (begin (set! ret a) #f)
                                                             (begin (set! ret b) #t)))
                       (lambda () 1)
                       (lambda () 3)
                       5)))
                  '((store () (values 1))
                    (store () (values 3))))
     
     (make-r6test/v (let ([Y '(lambda (le)
                                ((lambda (f) (f f))
                                 (lambda (f)
                                   (le (lambda (z) ((f f) z))))))])
                      `((,Y
                         (lambda (length)
                           (lambda (l)
                             (if (null? l)
                                 0
                                 (+ (length (cdr l)) 1)))))
                        (cons 1 null)))
                    1)
     (make-r6test/v '((lambda (x y) (+ x y)) ((lambda (x) x) 3) ((lambda (x) x) 4)) 
                    7)
     (make-r6test/v '((lambda (x) ((lambda (a b) x) (begin (set! x (- x)) 'x)
                                                    (begin (set! x (- x)) 'y))) 
                      1)
                    1)
     
     (make-r6test/v '((lambda (x) (begin (set! x 5) (set! x 4) (set! x 3) x)) 0) 3)
     (make-r6test/v '((lambda (x y) (x y)) + 0) 0)
     (make-r6test/v '(apply + (cons 1 (cons 2 null))) 3)
     
     ;; app
     (make-r6test/v '((lambda (dot args) (apply + args)) 1 2 3 4) 10)
     (make-r6test/v '((lambda (f) (eqv? (f 1) (f 1))) (lambda (dot args) (car args))) #t)
     (make-r6test '(store () 
                     (define length
                       (lambda (l)
                         (if (null? l)
                             0
                             (+ 1 (length (cdr l))))))
                     (length (list 1 2 3)))
                  (list '(store ((length
                                  (lambda (l)
                                    (if (null? l)
                                        0
                                        (+ 1 (length (cdr l)))))))
                           (values 3))))
     (make-r6test '(store () ((lambda (x) 
                                (set! x (x 
                                         (begin (set! x +) 4)
                                         (begin (set! x *) 2)))
                                x)
                              /))
                  (list '(store () (values 2))
                        '(store () (values 6))
                        '(store () (values 8))))
     
     (make-r6test '(store () ((lambda (x) 
                                (set! x (x 
                                         (begin (set! x +) 12)
                                         (begin (set! x *) 2)
                                         (begin (set! x -) 2)))
                                x)
                              /))
                  (list '(store () (values 3))
                        '(store () (values 16))
                        '(store () (values 8))
                        '(store () (values 48))))
     
     (make-r6test '(store () 
                     ((lambda (x) 
                        (set! x (x (begin (set! x *) 2)))
                        x)
                      /))
                  (list '(store () (values 2))
                        '(store () (values 1/2))))
     
     ;; test non-determinism in spec (a single application can go two different ways
     ;; at two different times)
     (make-r6test '(store ()  
                     (define x null)
                     (define twice (lambda (f) (f) (f)))
                     (twice
                      (lambda ()
                        ((lambda (p q) 1)
                         (begin (set! x (cons 1 x)) 'foo)
                         (begin (set! x (cons 2 x)) 'bar)))))
                  (list
                   '(store ((x (cons 1 (cons 2 (cons 1 (cons 2 null)))))
                            (twice (lambda (f) (f) (f))))
                      (values 1))
                   '(store ((x (cons 2 (cons 1 (cons 1 (cons 2 null)))))
                            (twice (lambda (f) (f) (f))))
                      (values 1))
                   '(store ((x (cons 1 (cons 2 (cons 2 (cons 1 null)))))
                            (twice (lambda (f) (f) (f))))
                      (values 1))
                   '(store ((x (cons 2 (cons 1 (cons 2 (cons 1 null)))))
                            (twice (lambda (f) (f) (f))))
                      (values 1))))
     
     (make-r6test/v '(condition? (condition "xyz")) #t)
     (make-r6test/v '(condition? 1) #f)
     (make-r6test/v '(procedure?
                      (call/cc
                       (lambda (k)
                         (with-exception-handler k (lambda () x)))))
                    #f)
     (make-r6test/v '(condition?
                      (call/cc
                       (lambda (k)
                         (with-exception-handler k (lambda () x)))))
                    #t)
     
     ;; test capture avoiding substitution
     (make-r6test '(store () 
                     (define x 1) 
                     (((lambda (f) (lambda (x) (+ x (f))))
                       (lambda () x))
                      2))
                  (list '(store ((x 1)) (values 3))))
     
     (make-r6test '(store ()
                     (((lambda (x1) (lambda (x) x))
                       3)
                      4))
                  (list '(store () (values 4))))
     (make-r6test '(store ()
                     (((lambda (x)
                         (lambda (dot args) (car args)))
                       1)
                      2))
                  (list '(store () (values 2))))
     
     (make-r6test '(store () 
                     (define x 1) 
                     (((lambda (f) (lambda (y dot x) (f)))
                       (lambda () x))
                      2))
                  (list '(store ((x 1)) (values 1))))
     
     (make-r6test/v '((lambda (x y dot z) (set! z (cons x z)) (set! z (cons y z)) (apply + z))
                      1 2 3 4)
                    '10)
     
     (make-r6test '(store () 
                     (define g (lambda (x) x))
                     (define f (lambda (x) (g 1)))
                     (((lambda (x) (lambda (g) (g x))) f)
                      (lambda (x) 17)))
                  (list '(store ((g (lambda (x) x))
                                 (f (lambda (x) (g 1))))
                           (values 17))))))
  
  (define mv-tests
    (list
     (make-r6test
      '(store () ((lambda (x) x) (values (lambda (y) y))))
      (list '(store () (values (lambda (y) y)))))
     (make-r6test
      '(store () (call-with-values (lambda () (lambda (y) y)) (lambda (x) x)))
      (list '(store () (values (lambda (y) y)))))
     (make-r6test
      '(store () (call-with-values 
                  (lambda ()
                    (call-with-values
                     (lambda () ((lambda (z) z) (lambda (q) q)))
                     (lambda (y) y))) 
                  (lambda (x) x)))
      (list '(store () (values (lambda (q) q)))))
     (make-r6test
      '(store () (call-with-values 
                  (lambda ()
                    (call-with-values (lambda () (values (lambda (p) p)))
                                      (((lambda (z) z) (lambda (a) (a a))) (lambda (m) m))))
                  (call-with-values (lambda () (values (lambda (q) q))) (lambda (x) (lambda (y) x)))))
      (list '(store () (values (lambda (q) q)))))
     
     
     (make-r6test
      '(store () ((lambda (x) x) call-with-values))
      (list '(store () (values call-with-values))))
     (make-r6test
      '(store () (values))
      (list '(store () (values))))
     (make-r6test
      '(store () (values (lambda (x) x)))
      (list '(store () (values (lambda (x) x)))))
     (make-r6test
      '(store () (values (lambda (x) x) (lambda (q) q)))
      (list '(store () (values (lambda (x) x) (lambda (q) q)))))
     
     (make-r6test
      '(store () (call-with-values (values values) (lambda () (lambda (x) x))))
      (list '(store () (values (lambda (x) x)))))
     (make-r6test
      '(store () ((lambda (x) x) (values (lambda (y) y))))
      (list '(store () (values (lambda (y) y)))))
     (make-r6test
      '(store () (call-with-values (lambda () (lambda (y) y)) (lambda (x) x)))
      (list '(store () (values (lambda (y) y)))))
     
     (make-r6test
      '(store () 
         (call-with-values 
          (lambda ()
            (call-with-values
             (lambda ()
               ((lambda (z) z) (lambda (q) q)))
             (lambda (y) y)))
          (lambda (x) x)))
      (list '(store () (values (lambda (q) q)))))
     
     (make-r6test
      '(store () 
         (call-with-values 
          (lambda ()
            (call-with-values (lambda ()
                                (values (lambda (p) p)))
                              (((lambda (x) x) (lambda (x) (x x))) (lambda (m) m))))
          (call-with-values (lambda () (values (lambda (q) q))) 
                            (lambda (x) (lambda (y) x)))))
      (list '(store () (values (lambda (q) q)))))
     
     (make-r6test
      '(store () (call-with-values (lambda () (values values values)) call-with-values))
      (list '(store () (values))))
     
     (make-r6test
      '(store () ((lambda (x y) x) (values (lambda (z) z) (lambda (q) q))))
      (list '(unknown "context expected one value, received 2")))
     
     (make-r6test
      '(store () (begin (if #t 1 2) 3))
      (list '(store () (values 3))))
     
     
     (make-r6test
      '(store () ((if (values 1 2 3 4 5 6 7 8 9 10) 11 12)))
      (list '(unknown "context expected one value, received 10")))
     
     
     (make-r6test
      '(store () (if (begin 1 2) 1 2))
      (list '(store () (values 1))))
     
     (make-r6test
      '(store () ((lambda (x) (begin (set! x (begin 1 2)) x)) 1))
      (list '(store () (values 2))))
     
     (make-r6test/v '(call/cc (lambda (k) (cons 1 (cons 2 (cons 3 (k 5)))))) 5)
     (make-r6test/v '(call-with-values (lambda () (call/cc (lambda (k) (k)))) +) 0)
     (make-r6test/v '(call-with-values (lambda () (call/cc (lambda (k) (k 1 2)))) +) 3)
     (make-r6test/v '((call/cc values) values) 'values)
     (make-r6test '(store () (define x ((lambda () (values 1 2 3)))))
                  (list '(unknown "context expected one value, received 3")))
     (make-r6test '(store ()
                     (define x 0)
                     (define f
                       (lambda ()
                         (set! x (+ x 1))
                         (values x x)))
                     (call-with-values f (lambda (x y) x))
                     (call-with-values f (lambda (x y) x)))
                  (list
                   '(store ((x 2)
                            (f (lambda ()
                                 (set! x (+ x 1))
                                 (values x x))))
                      (values 2))))
     (make-r6test/v '((lambda (x) (call-with-values x (lambda (x y) x)))
                      (lambda () (values (+ 1 2) 2)))
                    3)
     
     (make-r6test/v '((if #t call-with-values +) (lambda () (+ 1 1)) (lambda (x) x))
                    2)
     
     (make-r6test/v '(call-with-values (lambda () (values (+ 1 2) (+ 2 3))) +) 8)
     (make-r6test/v '(call-with-values * +) 1)
     (make-r6test/v '(call-with-values (lambda () (apply values (cons 1 (cons 2 null)))) +) 3)
     (make-r6test/v '(call-with-values (lambda () 1) +) 1)
     
     (make-r6test/e
      '(call-with-values (lambda ()
                           ((lambda (f) 
                              (f ((lambda (id) id) (lambda (x) (x x)))
                                 (lambda (x y) x)))
                            values))
                         (lambda (a b) (a b)))
      "arity mismatch")
     
     (make-r6test/v '((lambda (x) x) (values 1)) 1)
     (make-r6test '(store () (values 1 2))
                  (list '(store () (values 1 2))))
     (make-r6test '(store () ((lambda (x) (values x x x)) 1) 1)
                  (list '(store () (values 1))))
     
     (make-r6test/v '(begin (values) 1) 1)
     (make-r6test/v '(+ 1 (begin (values 1 2 3) 1)) 2)))
  
  (define dw-tests
    (list 
     
     ;; an infinite loop that produces a finite (circular) reduction graph
     (make-r6test
      '(store ()
         ((lambda (x) ((call/cc call/cc) x)) (call/cc call/cc)))
      (list))
     
     ;; next examples is one a continuation example that mz gets wrong
     (make-r6test 
      '(store ()
         ((lambda (count)
            ((lambda (first-time? k)
               (if first-time?
                   (begin
                     (set! first-time? #f)
                     (set! count (+ count 1))
                     (k values))
                   1234))
             #t
             (call/cc values))
            count)
          0))
      (list '(store () (values 2))))
     
     (make-r6test
      '(store ([x 2]) x)
      (list '(store ((x 2)) (values 2))))
     (make-r6test
      '(store ([x 2]) (begin (set! x (+ x 1)) x))
      (list '(store ((x 3)) (values 3))))
     
     (make-r6test
      '(store () (begin ((lambda (x) (+ x x)) 1) 2))
      (list '(store () (values 2))))
     
     (make-r6test
      '(store () (+ (call/cc (lambda (k) (+ (k 1) 1))) 1))
      (list '(store () (values 2))))
     (make-r6test
      '(store () ((call/cc (lambda (x) x)) (lambda (y) 1)))
      (list '(store () (values 1))))
     
     (make-r6test
      '(store ((x 0))
         (begin
           (dynamic-wind (lambda () (set! x 1))
                         (lambda () (begin (set! x 2) 'whatever))
                         (lambda () (set! x 3)))
           x))
      (list '(store ((x 3)) (values 3))))
     
     
     (make-r6test
      '(store ((x 0)) (dynamic-wind (lambda () (set! x (+ x 1)))
                                    (lambda () (begin (set! x (+ x 1)) x))
                                    (lambda () (set! x (+ x 1)))))
      (list '(store ((x 3)) (values 2))))
     
     ;; dynamic wind and multiple values
     (make-r6test '(store () (dynamic-wind values (lambda () (values 1 2)) values))
                  (list '(store () (values 1 2))))
     
     ;; dynamic-wind given non-lambda procedure values
     (make-r6test '(store () (dynamic-wind values values values))
                  (list '(store () (values))))
     (make-r6test '(store () (dynamic-wind values (lambda (dot x) x) values))
                  (list '(store () (values null))))
     
     
     (make-r6test/e '(dynamic-wind 1 1 1) "dynamic-wind expects arity 0 procs")
     
     ;; make sure that dynamic wind signals non-proc errors directly
     ;; instead of calling procedures
     (make-r6test/e '(dynamic-wind (lambda () (car 1)) 1 2)
                    "dynamic-wind expects arity 0 procs")
     (make-r6test/e '(dynamic-wind (lambda () (car 1)) (lambda (x) x) (lambda (y) y))
                    "dynamic-wind expects arity 0 procs")
     
     (make-r6test/e '(dynamic-wind (lambda () (car 1)) (lambda (x dot y) x) (lambda () 1))
                    "dynamic-wind expects arity 0 procs")
     (make-r6test/v '(dynamic-wind + (lambda (dot y) 2) *)
                    2)
     (make-r6test/v '(dynamic-wind values list (lambda (dot y) y))
                    'null)
     
     
     (make-r6test ; "in thunk isn't really in"
      '(store ((n 0))
         
         (begin
           (call/cc
            (lambda (k)
              (dynamic-wind
               (lambda () (begin
                            (set! n (+ n 1))
                            (k 11)))
               +
               (lambda () (set! n (+ n 1))))))
           n))
      (list '(store ((n 1)) (values 1))))
     
     (make-r6test ; "out thunk is really out"
      '(store ((n 0)
               (do-jump? #t)
               (k-out #f))
         
         (begin
           (call/cc
            (lambda (k)
              (dynamic-wind
               (lambda () (set! n (+ n 1)))
               +
               (lambda ()
                 (begin
                   (set! n (+ n 1))
                   (call/cc (lambda (k) (set! k-out k))))))))
           (if do-jump?
               (begin
                 (set! do-jump? #f)
                 (k-out 0))
               11)
           (set! k-out #f)
           n))
      (list '(store ((n 2) (do-jump? #f) (k-out #f)) (values 2))))
     
     (make-r6test ; "out thunk is really out during trimming"
      '(store ((n 0)
               (do-jump? #t)
               (k-out #f))
         
         (begin
           (call/cc
            (lambda (k)
              (dynamic-wind
               (lambda () (set! n (+ n 1)))
               +
               (lambda ()
                 (begin
                   (set! n (+ n 1))
                   (call/cc (lambda (k) (set! k-out k))))))))
           (if do-jump?
               (begin
                 (set! do-jump? #f)
                 (k-out 0))
               11)
           (set! k-out #f)
           n))
      (list '(store ((n 2) (do-jump? #f) (k-out #f)) (values 2))))
     
     (make-r6test ; "jumping during the results of trimming, pre-thunk"
      '(store ((pre-count 0)
               (pre-jump? #f)
               (after-jump? #t)
               (grab? #t)
               (the-k #f))
         
         (begin
           (dynamic-wind
            (lambda ()
              (begin
                (set! pre-count (+ pre-count 1))
                (if pre-jump?
                    (begin
                      (set! pre-jump? #f)
                      (set! after-jump? #f)
                      (the-k 999))
                    999)))
            (lambda () 
              (if grab?
                  (call/cc
                   (lambda (k)
                     (begin
                       (set! grab? #f)
                       (set! the-k k)
                       'ignoreme)))
                  999))
            +)
           (if after-jump?
               (begin
                 (set! pre-jump? #t)
                 (the-k 999))
               999)
           (set! the-k #f) ;; just to make testing simpler
           pre-count))
      (list '(store ((pre-count 3) (pre-jump? #f) (after-jump? #f) (grab? #f) (the-k #f)) (values 3))))
     
     (make-r6test ; "jumping during the results of trimming, post-thunk"
      '(store ((post-count 0)
               (post-jump? #t)
               (jump-main? #t)
               (grab? #t)
               (the-k #f))
         
         (begin
           (if grab?
               (call/cc
                (lambda (k)
                  (begin
                    (set! grab? #f)
                    (set! the-k k))))
               999)
           (dynamic-wind
            +
            (lambda () 
              (if jump-main?
                  (begin
                    (set! jump-main? #f)
                    (the-k 999))
                  999))
            (lambda () 
              (begin
                (set! post-count (+ post-count 1))
                (if post-jump?
                    (begin
                      (set! post-jump? #f)
                      (the-k 999))
                    999))))
           (set! the-k #f) ;; just to make testing simpler
           post-count))
      (list '(store ((post-count 2) (post-jump? #f) (jump-main? #f) (grab? #f) (the-k #f)) (values 2))))
     
     (make-r6test ; "dynamic-wind gets a continuation"
      '(store () (call/cc (lambda (k) (dynamic-wind + k +))))
      (list '(store () (values))))
     
     #|

to read the following tests, read the argument to conv-base from right to left
each corresponding set! should happen in that order.
in case of a test case failure, turn the number back into a sequence
of digits with deconv-base

|#
     
     (make-r6test ; "hop out one level"
      '(store ((x 0)
               (one 0)
               (two 0)
               (three 0)) 
         
         (begin
           (set! one (lambda () (set! x (+ (* x 2) 0))))
           (set! two (lambda () (call/cc (lambda (k) k))))
           (set! three (lambda () (set! x (+ (* x 2) 1))))
           ((dynamic-wind one two three)
            (lambda (y) x))))
      (list (let ([final-x (conv-base 2 #(1 0 1 0))])
              `(store ((x ,final-x)
                       (one (lambda () (set! x (+ (* x 2) 0))))
                       (two (lambda () (call/cc (lambda (k) k))))
                       (three (lambda () (set! x (+ (* x 2) 1)))))
                 (values ,final-x)))))
     
     (make-r6test ;"hop out two levels"
      '(store ((x 0)
               (one 0)
               (two 0)
               (three 0)
               (four 0))
         
         (begin
           (set! one   (lambda () (set! x (+ (* x 5) 1))))
           (set! two   (lambda () (set! x (+ (* x 5) 2))))
           (set! three (lambda () (set! x (+ (* x 5) 3))))
           (set! four  (lambda () (set! x (+ (* x 5) 4))))
           ((dynamic-wind 
             one
             (lambda () 
               (dynamic-wind
                two
                (lambda () (call/cc (lambda (k) k)))
                three))
             four)
            (lambda (y) x))))
      (list 
       (let ([final-x (conv-base 5 #(4 3 2 1 4 3 2 1))])
         `(store ((x ,final-x)
                  (one   (lambda () (set! x (+ (* x 5) 1))))
                  (two   (lambda () (set! x (+ (* x 5) 2))))
                  (three (lambda () (set! x (+ (* x 5) 3))))
                  (four  (lambda () (set! x (+ (* x 5) 4)))))
            (values ,final-x)))))
     
     (make-r6test ; "don't duplicate tail"
      '(store ((x 0)
               (one 0)
               (two 0)
               (three 0)
               (four 0))
         
         (begin
           (set! one (lambda () (set! x (+ (* x 5) 1))))
           (set! two (lambda () (set! x (+ (* x 5) 2))))
           (set! three (lambda () (set! x (+ (* x 5) 3))))
           (set! four (lambda () (set! x (+ (* x 5) 4))))
           (dynamic-wind 
            one
            (lambda () 
              ((dynamic-wind two
                             (lambda () (call/cc (lambda (k) k)))
                             three)
               (lambda (y) x)))
            four)))
      (list `(store ((x ,(conv-base 5 #(4 3 2 3 2 1)))
                     (one (lambda () (set! x (+ (* x 5) 1))))
                     (two (lambda () (set! x (+ (* x 5) 2))))
                     (three (lambda () (set! x (+ (* x 5) 3))))
                     (four (lambda () (set! x (+ (* x 5) 4)))))
               
               (values ,(conv-base 5 #(3 2 3 2 1))))))
     
     (make-r6test ; "dont' duplicate tail, 2 deep"
      '(store ((x 0)
               (one 0)
               (two 0)
               (three 0)
               (four 0)
               (five 0)
               (six 0))
         
         (begin
           (set! one (lambda () (set! x (+ (* x 7) 1))))
           (set! two (lambda () (set! x (+ (* x 7) 2))))
           (set! three (lambda () (set! x (+ (* x 7) 3))))
           (set! four (lambda () (set! x (+ (* x 7) 4))))
           (set! five (lambda () (set! x (+ (* x 7) 5))))
           (set! six (lambda () (set! x (+ (* x 7) 6))))
           (dynamic-wind 
            one
            (lambda () 
              (dynamic-wind 
               two
               (lambda () 
                 ((dynamic-wind three
                                (lambda () (call/cc (lambda (k) k)))
                                four)
                  (lambda (y) x)))
               five))
            six)))
      
      (list `(store ((x ,(conv-base 7 #(6 5 4 3 4 3 2 1)))
                     (one (lambda () (set! x (+ (* x 7) 1))))
                     (two (lambda () (set! x (+ (* x 7) 2))))
                     (three (lambda () (set! x (+ (* x 7) 3))))
                     (four (lambda () (set! x (+ (* x 7) 4))))
                     (five (lambda () (set! x (+ (* x 7) 5))))
                     (six (lambda () (set! x (+ (* x 7) 6)))))
               (values ,(conv-base 7 #(4 3 4 3 2 1))))))
     
     (make-r6test ; "hop out and back into another one"
      '(store ((x 0)
               (one 0)
               (two 0)
               (three 0)
               (four 0))
         
         (begin
           (set! one (lambda () (set! x (+ (* x 5) 1))))
           (set! two (lambda () (set! x (+ (* x 5) 2))))
           (set! three (lambda () (set! x (+ (* x 5) 3))))
           (set! four (lambda () (set! x (+ (* x 5) 4))))
           ((lambda (ok)
              (dynamic-wind one
                            (lambda () (ok (lambda (y) x)))
                            two))
            (dynamic-wind three
                          (lambda () (call/cc (lambda (k) k)))
                          four))))
      (list `(store ((x ,(conv-base 5 #(2 1 4 3 2 1 4 3)))
                     (one (lambda () (set! x (+ (* x 5) 1))))
                     (two (lambda () (set! x (+ (* x 5) 2))))
                     (three (lambda () (set! x (+ (* x 5) 3))))
                     (four (lambda () (set! x (+ (* x 5) 4)))))
               (values ,(conv-base 5 #(1 4 3 2 1 4 3))))))
     
     (make-r6test ; "hop out one level and back in two levels"
      '(store ((x 0)
               (one 0)
               (two 0)
               (three 0)
               (four 0))
         
         (begin
           (set! one (lambda () (set! x (+ (* x 5) 1))))
           (set! two (lambda () (set! x (+ (* x 5) 2))))
           (set! three (lambda () (set! x (+ (* x 5) 3))))
           (set! four (lambda () (set! x (+ (* x 5) 4))))
           ((lambda (ok)
              (dynamic-wind
               one
               (lambda ()
                 (dynamic-wind
                  two
                  (lambda () (ok (lambda (y) x)))
                  three))
               four))
            (call/cc (lambda (k) k)))))
      (list `(store ((x ,(conv-base 5 #(4 3 2 1 4 3 2 1)))
                     (one (lambda () (set! x (+ (* x 5) 1))))
                     (two (lambda () (set! x (+ (* x 5) 2))))
                     (three (lambda () (set! x (+ (* x 5) 3))))
                     (four (lambda () (set! x (+ (* x 5) 4)))))
               (values ,(conv-base 5 #(2 1 4 3 2 1))))))
     
     (make-r6test ; "hop out two levels and back in two levels"
      '(store ((x 0)
               (one 0)
               (two 0)
               (three 0)
               (four 0)
               (five 0)
               (six 0)
               (seven 0)
               (eight 0))
         
         (begin
           (set! one (lambda () (set! x (+ (* x 9) 1))))
           (set! two (lambda () (set! x (+ (* x 9) 2))))
           (set! three (lambda () (set! x (+ (* x 9) 3))))
           (set! four (lambda () (set! x (+ (* x 9) 4))))
           (set! five (lambda () (set! x (+ (* x 9) 5))))
           (set! six (lambda () (set! x (+ (* x 9) 6))))
           (set! seven (lambda () (set! x (+ (* x 9) 7))))
           (set! eight (lambda () (set! x (+ (* x 9) 8))))
           ((lambda (ok)
              (dynamic-wind
               one
               (lambda () 
                 (dynamic-wind
                  two
                  (lambda () (ok (lambda (y) x)))
                  three))
               four))
            (dynamic-wind
             five
             (lambda () 
               (dynamic-wind
                six
                (lambda () (call/cc (lambda (k) k)))
                seven))
             eight))))
      (list `(store ((x ,(conv-base 9 #(4 3 2 1 8 7 6 5 4 3 2 1 8 7 6 5)))
                     (one (lambda () (set! x (+ (* x 9) 1))))
                     (two (lambda () (set! x (+ (* x 9) 2))))
                     (three (lambda () (set! x (+ (* x 9) 3))))
                     (four (lambda () (set! x (+ (* x 9) 4))))
                     (five (lambda () (set! x (+ (* x 9) 5))))
                     (six (lambda () (set! x (+ (* x 9) 6))))
                     (seven (lambda () (set! x (+ (* x 9) 7))))
                     (eight (lambda () (set! x (+ (* x 9) 8)))))
               (values ,(conv-base 9 #(2 1 8 7 6 5 4 3 2 1 8 7 6 5))))))))
  
  (define tl-tests
    (list 
     
     (make-r6test ;"Basic define 1"
      '(store () (define x 1) (set! x 2) 12)
      (list '(store ((x 2)) (values 12))))
     
     (make-r6test ;"Basic define 2"
      '(store () (define x 1) (define y x) 131)
      (list '(store ((x 1) (y 1)) (values 131))))
     
     (make-r6test ; "Basic define 3"
      '(store () (define x 1) (define y (+ x x)) 'ha)
      (list '(store ((x 1) (y 2)) (values 'ha))))
     
     (make-r6test ; "Basic fn app 1"
      '(store () (lambda (x) x) 1)
      (list '(store () (values 1))))
     
     (make-r6test ; "top-level call/cc 1"
      '(store () (define k (call/cc (lambda (x) x)))
         (define y (if (procedure? k)
                       (k 1)
                       k))
         123)
      (list '(store ((k 1) (y 1)) (values 123))))
     
     (make-r6test ; "top-level call/cc 2" 
      '(store () 
         (define x 1)
         (define k (call/cc (lambda (x) x)))
         (define y 1)
         (set! x 2)
         (set! y 2)
         (if (procedure? k)
             (k 1)
             1234))
      (list '(store ((x 2)
                     (k 1)
                     (y 2)) 
               
               (values 1234))))
     
     (make-r6test ; "top-level call/cc D->E" 
      '(store () 
         (define x (call/cc values))
         (x values))
      (list '(store ((x values))
               (values values))))
     
     (make-r6test ; "top-level call/cc D->D" 
      '(store () 
         (define x (call/cc values))
         (define y (x (lambda (x) x)))
         123)
      (list '(store ((x (lambda (x) x))
                     (y (lambda (x) x)))
               (values 123))))
     
     (make-r6test ; "top-level call/cc E->E" 
      '(store () 
         (define x #f)
         (define y #f)
         (set! y (* 2 (call/cc (lambda (k) (set! x k) 2))))
         (if (procedure? x)
             ((lambda (y)
                (set! x 3)
                (y 17))
              x)
             1234))
      (list '(store ((x 3)
                     (y 34))
               (values 1234))))
     
     (make-r6test ; "top-level call/cc E->D" 
      '(store () 
         (define z (call/cc values))
         (define x #f)
         (define y (if (procedure? x)
                       (x 2)
                       x))
         (call/cc (lambda (k) (set! x k)))
         (z values)
         (set! x 17)
         123)
      (list '(store ((z values)
                     (x 17)
                     (y #f))
               (values 123))))
     
     (make-r6test ; "call/cc treated as a value"
      '(store () (define x (((lambda (x) call/cc) call/cc) (lambda (k) (k 1)))) 123)
      (list '(store ((x 1)) (values 123))))
     
     
     ;; test recursive definitions
     (make-r6test ; "self-referential defs 1"
      '(store () 
         
         (define f
           (lambda (x y)
             (x (lambda () (f y x)))))
         (f (lambda (fc) (fc))
            (lambda (fc) 1)))
      (list '(store ((f
                      (lambda (x y)
                        (x (lambda () (f y x)))))) 
               
               (values 1))))
     
     (make-r6test ; "begin w/set! following continuation grab"
      '(store () 
         (define count 0)
         (define k (call/cc (lambda (x) x)))
         (define dummy (begin (set! count (+ count 1)) 123))
         (k (lambda (x) x)))
      (list '(store ((count 2)
                     (k (lambda (x) x))
                     (dummy 123))
               
               (values (lambda (x) x)))))
     
     (make-r6test ; "inner define becomes top-level"
      '(store () 
         (define count 0)
         (define x 1)
         (define k 0)
         ((lambda (ignore) 
            (begin ((call/cc (lambda (k1) 
                               (begin
                                 (set! k k1)
                                 (lambda (x) x))))
                    1)
                   (set! x (+ x 1))))
          0)
         (if (eqv? count 0)
             (begin
               (set! count 1)
               (k (lambda (x) (call/cc (lambda (k2)
                                         (begin (set! k k2)
                                                (lambda (x) x)))))))
             1234)
         (if (eqv? count 1)
             (begin
               (set! count 2)
               (k (lambda (x) x)))
             (set! k 11))
         123)
      (list '(store 
                 ((count 2)
                  (x 4)
                  (k 11)) 
               (values 123))))
     
     (make-r6test ; "ref to a var before filled in"
      '(store ()
         (define y x)
         (define x 1)
         x)
      (list '(uncaught-exception (condition "reference to undefined identifier: x"))))
     
     (make-r6test ; "ref to a var before filled in"
      '(store () x)
      (list '(uncaught-exception (condition "reference to undefined identifier: x"))))
     
     (make-r6test ; "ref to a var before filled in"
      '(store () (set! x 2))
      (list '(uncaught-exception (condition "set!: cannot set undefined identifier: x"))))
     
     (make-r6test ; "bang a var before filled in"
      '(store ()
         (define y (begin (set! x 2) 123))
         (define x (+ x 1))
         x)
      (list '(store ((x 3) (y 123)) (values 3))))
     
     (make-r6test ; "make sure all locations are allocated up front, rather than one at a time"
      '(store
           () 
         (define first-time? #t)
         (define x (call/cc values))
         (define y (call/cc 
                    (lambda (k) 
                      (with-exception-handler 
                       (lambda (x) (k 1))
                       (lambda () (+ y 1))))))
         (if first-time? 
             (begin (set! first-time? #f) (x values))
             1234)
         (set! x (quote x))
         y)
      (list '(store ((first-time? #f) (x 'x) (y 2)) (values 2))))
     
     (make-r6test '(store ()  
                     (define x1 2)
                     ((if + + +) x1))
                  (list '(store ((x1 2)) (values 2))))
     
     ;; testing implicit begin & substitution
     (make-r6test/v '(((lambda (x) x (lambda () x x)) 1)) 1)
     (make-r6test '(store ()
                     (define q 1)
                     (((lambda (x) (lambda (q dot y) (x))) (lambda (dot x) q)) 2))
                  (list '(store ((q 1)) (values 1))))
     
     ;; sexp contexts for the top-level
     (make-r6test '(store () (define x '2) '(define x '1) x)
                  (list '(store ((x 2)) (values 2))))
     
     (make-r6test '(store () 
                     (define k #f)
                     (define x 0)
                     (define first-time? #t)
                     (set! x (+ 1 (call/cc (lambda (k2) (set! k k2) 1))))
                     (if first-time? 
                         (begin (set! first-time? #f)
                                (k 3))
                         (begin (set! k #f)
                                x)))
                  (list '(store ((k #f)
                                 (x 4)
                                 (first-time? #f))
                           (values 4))))))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; exception tests
  ;;
  
  (define exn-tests
    (list
     (make-r6test/v '(with-exception-handler (lambda (x) 1) (lambda () 2))
                    2)
     (make-r6test/v '(with-exception-handler (lambda (x) 1) (lambda () (raise-continuable 2)))
                    1)
     (make-r6test/v '(with-exception-handler (lambda (x) x) (lambda () (raise-continuable 2)))
                    2)
     (make-r6test/v '(with-exception-handler values (lambda () (raise-continuable 2)))
                    2)
     (make-r6test '(store () (with-exception-handler (lambda (x) x) values))
                  (list '(store () (values))))
     (make-r6test '(store () (with-exception-handler (lambda (x) (values x x)) (lambda () (raise-continuable 1))))
                  (list '(store () (values 1 1))))
     (make-r6test/v '(+ 1 (with-exception-handler
                           (lambda (x) (+ 2 x))
                           (lambda () (+ 3 (raise-continuable (+ 2 2))))))
                    10)
     
     (make-r6test '(store ()
                     (with-exception-handler
                      (lambda (x)
                        (with-exception-handler
                         (lambda (y) (eqv? x y))
                         (lambda () (car 1))))
                      (lambda () (car 1))))
                  (list '(unknown "equivalence of conditions")))
     
     ;; nested handlers
     (make-r6test/v '(with-exception-handler
                      (lambda (x) (+ 2 x))
                      (lambda ()
                        (with-exception-handler
                         (lambda (x) (+ 3 x))
                         (lambda () (raise-continuable 1)))))
                    4)
     
     (make-r6test/v '(with-exception-handler
                      (lambda (y) (with-exception-handler
                                   (lambda (x) (+ 3 x y))
                                   (lambda () (raise-continuable 1))))
                      (lambda () (raise-continuable 17)))
                    21)
     
     (make-r6test/v '(with-exception-handler
                      values
                      (lambda ()
                        (with-exception-handler
                         (lambda (y) (raise-continuable y))
                         (lambda () (raise-continuable 1)))))
                    1)
     
     (make-r6test '(store ()
                     (with-exception-handler 
                      (lambda (y) (raise-continuable y))
                      (lambda () (raise 2))))
                  (list '(uncaught-exception 2)))
     
     (make-r6test '(store ()
                     (with-exception-handler 
                      (lambda (y) (raise y))
                      (lambda () (raise-continuable 2))))
                  (list '(uncaught-exception 2)))
     
     (make-r6test '(store () (raise 2))
                  (list '(uncaught-exception 2)))
     
     (make-r6test '(store () (raise-continuable 2))
                  (list '(uncaught-exception 2)))
     
     (make-r6test '(store () (letrec* ([w 3]
                                       [x (+ 1 (raise-continuable 2))]
                                       [y 2])
                               1))
                  (list '(uncaught-exception 2)))
     
     (make-r6test '(store ()
                     (with-exception-handler
                      (lambda (x) x)
                      (lambda () (raise 2))))
                  (list '(uncaught-exception (condition "handler returned"))))
     
     (make-r6test/e '((lambda (c e)
                        (with-exception-handler
                         (lambda (x) (if (eqv? c 0)
                                         (set! c 1)
                                         (if (eqv? c 1)
                                             (begin (set! c 2)
                                                    (set! e x))
                                             (raise e))))
                         (lambda () (raise 2))))
                      0 #f)
                    "handler returned")
     
     (make-r6test '(store () (with-exception-handler (lambda (x) (eqv? x 2)) (lambda () (car 1))))
                  (list '(unknown "equivalence of conditions")))
     
     (make-r6test/v '((lambda (sx first-time?)
                        ((lambda (k)
                           (if first-time?
                               (begin
                                 (set! first-time? #f)
                                 (with-exception-handler
                                  (lambda (x) (k values))
                                  (lambda ()
                                    (dynamic-wind
                                     +
                                     (lambda () (raise-continuable 1))
                                     (lambda () (set! sx (+ sx 1)))))))
                               sx))
                         (call/cc values)))
                      1 #t)
                    2)
     
     (make-r6test/v '(with-exception-handler
                      (lambda (x) (begin (set! x (+ x 1)) x))
                      (lambda ()
                        (raise-continuable 1)))
                    2)
     
     (make-r6test/v '(call/cc
                      (lambda (k)
                        (with-exception-handler
                         (lambda (x) (set! x (+ x 1)) (k x))
                         (lambda ()
                           (raise 1)))))
                    2)
     
     (make-r6test/v '(with-exception-handler
                      (lambda (x) 2)
                      (lambda ()
                        (dynamic-wind
                         +
                         (lambda () (raise-continuable 1))
                         +)))
                    2)
     
     (make-r6test '(store ()
                     (with-exception-handler
                      (lambda (x) (raise (+ x 1)))
                      (lambda ()
                        (dynamic-wind
                         +
                         (lambda () (raise 1))
                         +))))
                  (list '(uncaught-exception 2)))
     
     (make-r6test/v '(with-exception-handler
                      (lambda (x) x)
                      (lambda ()
                        (dynamic-wind
                         +
                         (lambda () (raise-continuable 1))
                         +)))
                    1)
     
     (make-r6test/v '(with-exception-handler
                      (lambda (x) (begin (set! x 2) x))
                      (lambda ()
                        (dynamic-wind
                         +
                         (lambda () (raise-continuable 1))
                         +)))
                    2)
     
     (make-r6test/v '(with-exception-handler
                      (lambda (x) (with-exception-handler
                                   (lambda (x) x)
                                   (lambda () (raise-continuable 1))))
                      (lambda () (raise-continuable 2)))
                    1)
     
     (make-r6test/v '(with-exception-handler
                      (lambda (y) 
                        (with-exception-handler
                         (lambda (x) y)
                         (lambda ()
                           (raise-continuable 1))))
                      (lambda ()
                        (raise-continuable 2)))
                    2)
     
     (make-r6test/v '(with-exception-handler
                      (lambda (y) 
                        (with-exception-handler
                         (lambda (x) x)
                         (lambda ()
                           (raise-continuable 1))))
                      (lambda ()
                        (raise-continuable 2)))
                    1)
     
     (make-r6test/e '(with-exception-handler 2 +)
                    "with-exception-handler bad argument")
     (make-r6test/e '(with-exception-handler + 2)
                    "with-exception-handler bad argument")
     (make-r6test/e '(with-exception-handler 1 2)
                    "with-exception-handler bad argument")
     
     (make-r6test/v '((lambda (y)
                        (with-exception-handler
                         (lambda (x) (set! y (+ x y)))
                         (lambda ()
                           (raise-continuable 1)
                           (raise-continuable 2)
                           y)))
                      0)
                    3)
     
     (make-r6test '(store ()
                     (with-exception-handler
                      (lambda (x) (raise x))
                      (lambda () (raise 1))))
                  (list '(uncaught-exception 1)))
     
     (make-r6test 
      '(store ()
         (letrec* ([k #f]
                   [ans #f]
                   [first-time? #t])
           (with-exception-handler
            (lambda (x)
              (begin
                (call/cc (lambda (k2) (set! k k2)))
                (set! x (+ x 1))
                (set! ans x)))
            (lambda ()
              (raise-continuable 1)))
           (if first-time?
               (begin
                 (set! first-time? #f)
                 (k 1))
               (set! k #f))
           ans))
      (list '(store ((lx-k #f) (lx-ans 3) (lx-first-time? #f))
               (values 3))))
     
     ;; test trimming function in the presence of exceptions when trimming handlers
     ;; this test belongs in the dw section. have to move it there after changing its syntax
     (make-r6test '(store ()
                     (letrec* ((phase 0)
                               (k #f)
                               (l '()))
                       (with-exception-handler
                        (lambda (x) (if (eqv? phase 0)
                                        (begin
                                          (set! phase 1)
                                          (call/cc (lambda (k2) (begin (set! k k2) 'whatever))))
                                        (if (eqv? phase 1)
                                            (begin
                                              (set! phase 2)
                                              (k 1))
                                            1234)))
                        (lambda ()
                          (dynamic-wind 
                           (lambda () (set! l (cons 1 l)))
                           (lambda () 
                             (dynamic-wind 
                              (lambda () (set! l (cons 2 l)))
                              (lambda () (raise-continuable 1))
                              (lambda () (set! l (cons 3 l))))
                             (dynamic-wind 
                              (lambda () (set! l (cons 4 l)))
                              (lambda () (raise-continuable 1))
                              (lambda () (set! l (cons 5 l)))))
                           (lambda () (set! l (cons 6 l))))))
                       (set! k #f)
                       (apply values l)))
                  (list '(store ((lx-phase 2) 
                                 (lx-k #f)
                                 (lx-l (cons 6 (cons 5 (cons 4 (cons 3 (cons 2 (cons 5 (cons 4 (cons 3 (cons 2 (cons 1 null))))))))))))
                           (values 6 5 4 3 2 5 4 3 2 1))))))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; letrec tests
  ;;
  
  (define letrec-tests
    (list 
     (make-r6test '(store () (letrec ([x 1] [y 2]) (+ x y)))
                  (list '(store ((lx-x 1) (lx-y 2)) (values 3))))
     (make-r6test '(store ()
                     (letrec ([flip (lambda (x) (if x (flop #f) #t))]
                              [flop (lambda (x) (if x (flip x) x))])
                       (begin0 (flop #t)
                               (set! flip 1)
                               (set! flop 2))))
                  (list '(store ((lx-flip 1)
                                 (lx-flop 2))
                           (values #f))))
     (make-r6test '(store () (letrec ([x (begin (set! x 1) 2)]) x))
                  (list '(store ((lx-x 2)) (values 2))
                        '(uncaught-exception (condition "letrec variable touched"))))
     (make-r6test '(store ()
                     (letrec ([x (begin (set! y 2) 5)]
                              [y (begin (set! x 3) 7)])
                       (* x y)))
                  (list '(store ((lx-x 5) (lx-y 7)) (values 35))
                        '(uncaught-exception (condition "letrec variable touched"))))
     (make-r6test '(store () (letrec ([x x]) x))
                  (list '(uncaught-exception (condition "letrec variable touched"))))
     (make-r6test '(store () (letrec ([x y] [y x]) x))
                  (list '(uncaught-exception (condition "letrec variable touched"))))
     (make-r6test '(store () (letrec ([x 1] [y x]) y))
                  (list '(uncaught-exception (condition "letrec variable touched"))))
     
     (make-r6test '(store () (letrec ([x 1] [y 2]) (set! x 3) (set! y 4) (+ x y)))
                  (list '(store ((lx-x 3) (lx-y 4)) (values 7))))
     
     (make-r6test '(store () (letrec* ([x 1] [y 2]) (+ x y)))
                  (list '(store ((lx-x 1) (lx-y 2)) (values 3))))
     (make-r6test '(store ()
                     (letrec* ([flip (lambda (x) (if x (flop #f) #t))]
                               [flop (lambda (x) (if x (flip x) x))])
                              (begin0 (flop #t)
                                      (set! flip 1)
                                      (set! flop 2))))
                  (list '(store ((lx-flip 1) (lx-flop 2)) (values #f))))
     (make-r6test '(store () (letrec* ([x (begin (set! x 1) 2)]) x))
                  (list '(store ((lx-x 2)) (values 2))
                        '(uncaught-exception (condition "letrec variable touched"))))
     (make-r6test '(store ()
                     (letrec* ([x (begin (set! y 2) 5)]
                               [y (begin (set! x 3) 7)])
                              (* x y)))
                  (list '(store ((lx-x 3) (lx-y 7)) (values 21))
                        '(uncaught-exception (condition "letrec variable touched"))))
     (make-r6test '(store () (letrec* ([x x]) x))
                  (list '(uncaught-exception (condition "letrec variable touched"))))
     (make-r6test '(store () (letrec* ([x y] [y x]) x))
                  (list '(uncaught-exception (condition "letrec variable touched"))))
     (make-r6test '(store () (letrec* ([x 1] [y x]) y))
                  (list '(store ((lx-x 1) (lx-y 1)) (values 1))))
     
     (make-r6test '(store () ((lambda (x y) (letrec ([q (begin (set! x 2) 23)]) (begin (set! y 3) (* x y))))
                              5 7))
                  (list '(store ((lx-q 23)) (values 6))))
     (make-r6test '(store () ((lambda (x y) (letrec* ([q (begin (set! x 2) 23)]) (begin (set! y 3) (* x y))))
                              5 7))
                  (list '(store ((lx-q 23)) (values 6))))
     (make-r6test '(store () (letrec* ([x 1] [y 2]) (set! x 3) (set! y 4) (+ x y)))
                  (list '(store ((lx-x 3) (lx-y 4)) (values 7))))
     
     
     (make-r6test '(store ()
                     (letrec* ([k (call/cc (lambda (x) x))])
                       (k (lambda (x) x))
                       (k 2)))
                  (list '(uncaught-exception (condition "reinvoked continuation of letrec init"))
                        '(store ((lx-k (lambda (x) x))) (values 2))))
     (make-r6test '(store ()
                     (letrec ([k (call/cc (lambda (x) x))])
                       (k (lambda (x) x))
                       (k 2)))
                  (list '(uncaught-exception (condition "reinvoked continuation of letrec init"))
                        '(store ((lx-k (lambda (x2) x2))) (values 2))))
     
     (make-r6test '(store ()
                     ((lambda (flag)
                        (letrec* ([k
                                   ((lambda (k)
                                      (if flag
                                          'nothing-doing
                                          (car 'not-a-pair))
                                      k) 
                                    (call/cc (lambda (x) x)))])
                          (set! flag #f)
                          (k (lambda (x) x))
                          (k 2)))
                      #t))
                  (list '(uncaught-exception (condition "can't take car of non-pair"))))
     (make-r6test '(store ()
                     ((lambda (flag)
                        (letrec ([k
                                  ((lambda (k)
                                     (if flag
                                         'nothing-doing
                                         (car 'not-a-pair))
                                     k) 
                                   (call/cc (lambda (x) x)))])
                          (set! flag #f)
                          (k (lambda (x) x))
                          (k 2)))
                      #t))
                  (list '(uncaught-exception (condition "can't take car of non-pair"))))
     
     
     (make-r6test '(store ()
                     ((lambda (flag)
                        (letrec ([k (call/cc (lambda (x) x))]
                                 [x (if flag
                                        'nothing-doing
                                        (car 'not-a-pair))])
                          (set! flag #f)
                          (k (lambda (x) x))
                          (k 2)))
                      #t))
                  (list '(uncaught-exception (condition "reinvoked continuation of letrec init"))
                        '(uncaught-exception (condition "can't take car of non-pair"))
                        '(store ((lx-k (lambda (x2) x2)) (lx-x 'nothing-doing)) (values 2))))
     
     (make-r6test '(store ()
                     ((lambda (flag)
                        (letrec* ([k (call/cc (lambda (x) x))]
                                  [x (if flag
                                         'nothing-doing
                                         (car 'not-a-pair))])
                          (set! flag #f)
                          (k (lambda (x) x))
                          (k 2)))
                      #t))
                  (list '(uncaught-exception (condition "reinvoked continuation of letrec init"))
                        '(uncaught-exception (condition "can't take car of non-pair"))))
     ))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; testing functions
  ;;
  
  
  (define-syntax (test-fn stx)
    (syntax-case stx ()
      [(_ test-case expected)
       (with-syntax ([line (syntax-line stx)])
         (syntax (test-fn/proc (λ () test-case) expected line)))]))
  
  (define (test-fn/proc tc expected line)
    (let ([got (tc)])
      (unless (equal? got expected)
        (set! failed-tests (+ failed-tests 1))
        (fprintf (current-error-port)
                 "line ~s failed\nexpected ~s\n     got ~s\n"
                 line
                 expected
                 got))))
  
  
  (define (test-fns)
    (begin
      (test-fn (term (Var-set!d? (x (set! x 1)))) #t)
      (test-fn (term (Var-set!d? (x (set! y 1)))) #f)
      (test-fn (term (Var-set!d? (x (lambda (x) (set! x 2))))) #f)
      (test-fn (term (Var-set!d? (x (lambda (z dot x) (set! x 2))))) #f)
      (test-fn (term (Var-set!d? (x (lambda (x dot z) (set! x 2))))) #f)
      (test-fn (term (Var-set!d? (x (lambda (y) (set! x 2))))) #t)
      (test-fn (term (Var-set!d? (x 
                                  (if (begin (set! x 2))
                                      1
                                      2))))
               #t)
      (test-fn (term (Var-set!d? (x (begin0 (begin (begin0 1 2) 3) 4))))
               #f)
      (test-fn (term (Var-set!d? (x (dw x1 1 2 3)))) #f)
      (test-fn (term (Var-set!d? (y (throw x ((set! x 2)))))) #f)))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; all of the tests
  ;;
  
  (define the-sets 
    (list (list "letrec" letrec-tests)
          (list "app" app-tests)
          (list "unspec" assignment-results-tests)
          (list "quote" quote-tests)
          (list "arith" arithmetic-tests)
          (list "basic" basic-form-tests)
          (list "pair" pair-tests)
          (list "eqv" eqv-tests)
          (list "err" err-tests)
          (list "tl" tl-tests)
          (list "dw" dw-tests)
          (list "exn" exn-tests)
          (list "r5" r5-tests)
          (list "mv" mv-tests)))
  
  (define the-tests (apply append (map cadr the-sets)))
  
  (define run-tests
    (opt-lambda ([verbose? #f])
      (time
       (let ()
         (define first? #t)
         (define (run-a-set name set)
           (unless first?
             (if verbose?
                 (printf "\n\n")
                 (printf "\n")))
           (if verbose?
               (printf "~a\n~a tests\n\n" 
                       (apply string (build-list 60 (λ (i) #\-)))
                       name)
               (begin (printf "~a tests " name)
                      (flush-output)))
           (set! first? #f)
           (for-each (λ (x) (run-a-test x verbose?)) set))
         
         (set! failed-tests 0)
         (set! verified-terms 0)
         (test-fns)
         (for-each (λ (set) (apply run-a-set set)) the-sets)
         (unless verbose? (printf "\n"))
         
         (if (= 0 failed-tests)
             (printf "~a tests, all passed\n" test-count)
             (printf "~a tests, ~a tests failed\n" test-count failed-tests))
         (printf "verified that ~a terms are p*\n" verified-terms)))
      (collect-garbage) (collect-garbage) (collect-garbage)
      (printf "mem ~s\n" (current-memory-use))))
  
  (provide run-tests
           the-tests
           
           ;; the test and the expected are not compared with equal?.
           ;; instead, the result of running the test is first simplified
           ;; by substituting all of the variables with a colon in their
           ;; names thru the term, and then the results from the test are
           ;; compared with equal? to the elements of `expected'
           (struct r6test (test            ;; p (from the r6 grammar) [the test]
                           expected))))    ;; (list-of p)

