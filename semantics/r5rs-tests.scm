
(module r5rs-tests mzscheme

  (require (lib "match.ss")
           (planet "reduction-semantics.ss" ("robby" "redex.plt" 1 0))
           (prefix srfi1: (lib "1.ss" "srfi"))
           "r5rs.scm")
  
  ;; ============================================================
  ;; TESTING APPARATUS
  
  (define (expr->prog e)
    (expr->prog/store e '()))
  
  (define (expr->prog/store e store)
    `(store ,store (dw () ,e)))
  
  (define (set-equal? s1 s2)
    (define (bool x) (if x #t #f))
    (define (in-set? i s) (bool (member i s)))
    (define (subset? s1 s2)
      (andmap (lambda (x) (in-set? x s2)) s1))
    (and (subset? s1 s2)
         (subset? s2 s1)))
  
  (define (get-val expr)
    (match expr
      [`(store ,store (dw ,winds ,v)) v]
      [`(error ,message) expr]))
  
  (define-struct (exn:fail:duplicate exn:fail) (dup-term))
  
  (define (uniq lot)
    (let loop ((thelist lot))
      (cond
        [(null? thelist) lot]
        [(member (car thelist) (cdr thelist))
         (raise (make-exn:fail:duplicate 
                 "found duplicate"
                 (current-continuation-marks) 
                 (car lot)))]
        [else (loop (cdr thelist))])))
  
  (define (get-results t)
    (let ([cache (make-hash-table 'equal)])
      (let loop ([ts (list t)]
                 [acc '()])
        (let*-values ([(steps)
                       (uniq 
                        (map 
                         (lambda (e) (cons e (reduce reductions e)))
                         ts))]
                      [(finals nexts) 
                       (srfi1:partition 
                        (lambda (x) (null? (cdr x)))
                        steps)])
          (let ([acc (append acc (map car finals))]
                [nexts 
                 (srfi1:filter
                  (lambda (i)
                    (hash-table-get cache 
                                    i
                                    (lambda () 
                                      (begin
                                        (hash-table-put! cache i #f)
                                        #t))))
                  (apply append (map cdr nexts)))])
            (cond
              [(null? nexts) 
               (printf "~s states\n" (apply + (hash-table-map cache (λ (x y) 1))))
               acc]
              [else (loop nexts acc)]))))))
  
  (define (go/test t expected)
    (printf "testing ~a ... " t)
    (flush-output)
    (with-handlers
        ([exn:fail:duplicate?
          (lambda (e)
            (printf "FOUND DUPLICATE!\n----\n~s\n----\n"
                    (exn:fail:duplicate-dup-term e)))])
      (let ([results (get-results (expr->prog t))])
        (begin
          (unless (set-equal? (map get-val results) expected)
            (printf "TEST FAILED!~nexpected:~n  ~v~nreceived:~n  ~v~n~n"
                    expected
                    results))))))
  
  ;; just like go/test except that the initial term is not put in an initial context
  ;; (store * dynamic-wind stack)
  (define (go/test* t expected)
    (printf "testing ~a ... " t)
    (flush-output)
    (with-handlers
        ([exn:fail:duplicate?
          (lambda (e)
            (printf "FOUND DUPLICATE!\n----\n~s\n----\n"
                    (exn:fail:duplicate-dup-term e)))])
      (let ([results (get-results t)])
        (begin
          (unless (set-equal? (map get-val results) expected)
            (printf "TEST FAILED!~nexpected:~n  ~v~nreceived:~n  ~v~n~n"
                    expected
                    results))))))
  
  (provide go/test run-tests)
  
  (define Y '(lambda (le)
               ((lambda (f) (f f))
                (lambda (f)
                  (le (lambda (z) ((f f) z)))))))
  
  (define (run-tests)

    (go/test '(#%+) '(0))
    (go/test '(#%+ 1) '(1))
    (go/test '(#%+ 1 2) '(3))
    (go/test '(#%+ 1 2 3) '(6))
    (go/test '(#%car ((lambda (x) (#%cons x #%null)) 3)) '(3))
    (go/test '((lambda (x) x) 3) '(3))
    (go/test '((lambda (x y) (#%- x y)) 6 5) '(1))
    (go/test '((lambda () (#%+ x y z)) 3 4 5) '((error "arity mismatch")))
    (go/test '((lambda (x y z) (#%+ x y z)) 3 4 5) '(12))
    (go/test '((lambda (x1 x2 dot y) (#%car y)) 1 2 3 4) '(3))
    (go/test '((lambda (x dot y) (#%car y)) 1 2 3 4) '(2))
    (go/test '((lambda (x y dot z) x) 1) '((error "too few arguments")))
    (go/test '((lambda (dot args) (#%car (#%cdr args))) 1 2 3 4 5 6) '(2))
    (go/test '((lambda (dot args) (#%eqv? args args)) 1 2) '(#t))
    (go/test '((lambda (dot args) ((lambda (y) args) (set! args 50)))) '(50))
    (go/test '(if ((lambda (x) x) 74) ((lambda () 6)) (6 54)) '(6))
    (go/test '(if ((lambda (x) x) #f) ((lambda () 6)) (6 54)) 
             '((error "can't apply non-function")))
    (go/test '(if #t 12) '(12))
    (go/test '(if #f 12) '(unspecified))
    (go/test '(begin (if #f 12) 14) '(14))
    (go/test '((lambda (x) (if #t (set! x 45)) x) 1) '(45))
    (go/test '((lambda (x) (if #f (set! x 45)) x) 1) '(1))
;    (go/test `((,Y
;                 (lambda (length)
;                   (lambda (l)
;                     (if (#%null? l)
;                         0
;                         (#%+ (length (#%cdr l)) 1)))))
;               (#%cons 1 (#%cons 2 null)))
;             '(2))
    (go/test '(#%call/cc (lambda (k) (#%cons 1 (#%cons 2 (#%cons 3 (k 5)))))) '(5))
    (go/test '(#%call-with-values (lambda () (#%call/cc (lambda (k) (k)))) #%+) '(0))
    (go/test '(#%call-with-values (lambda () (#%call/cc (lambda (k) (k 1 2)))) #%+) '(3))
    (go/test '(if (#%null? (#%cons 1 (#%cons 2 (#%cons (lambda (x) x) #%null)))) 0 1) 
             '(1))
    (go/test '(#%null? (#%cons 1 (#%cons 2 (#%cons (lambda (x) x) #%null)))) '(#f))
    (go/test '(#%null? (#%cons 1 2)) '(#f))
    (go/test '(#%null? #%null) '(#t))
    (go/test '(#%pair? #%null) '(#f))
    (go/test '(#%pair? (#%cons 1 1)) '(#t))
    (go/test '(#%null? (#%list 1 2)) '(#f))
    (go/test '(#%pair? (#%list 1)) '(#t))
    (go/test '(#%pair? (#%list)) '(#f))
    (go/test '(#%null? (#%list)) '(#t))
    
    (go/test '(#%eval (#%list '#%+ (#%list '#%+ 1 2) 1)) '(4))
    
    (go/test '((lambda (x) ((lambda (y) x) (set! x 5))) 3) '(5))
    (go/test '(((lambda (a b ret) ((lambda (x y) ret) (set! ret a) (set! ret b)))
                (lambda () 1)
                (lambda () 3)
                5))
             '(1 3))
    (go/test '((lambda (x) ((lambda (y) (#%car (#%cdr x))) (#%set-car! (#%cdr x) 400))) 
               (#%cons 1 (#%cons 2 #%null)))
             '(400))
    (go/test '((lambda (x) ((lambda (y) (#%cdr (#%cdr x))) (#%set-cdr! (#%cdr x) 400)))
               (#%cons 1 (#%cons 2 #%null))) 
             '(400))
    (go/test '(#%call-with-values (lambda () (#%values (#%+ 1 2) (#%+ 2 3))) #%+) '(8))
    (go/test '(#%call-with-values #%* #%+) '(1))
    (go/test '((lambda (x y) (#%+ x y)) ((lambda (x) x) 3) ((lambda (x) x) 4)) 
             '(7))
    (go/test '((lambda (x) ((lambda (a b) x) (set! x (#%- x)) (set! x (#%- x)))) 1) 
             '(1))
    (go/test '(#%eqv? #t #t) '(#t))
    (go/test '(#%eqv? #t #f) '(#f))
    (go/test '(#%eqv? (lambda (x) x) (lambda (x) x)) '(#f))
    (go/test '(#%eqv? (#%cons 1 2) (#%cons 1 2)) '(#f))
    (go/test '((lambda (x) (#%eqv? x x)) (#%cons 1 2)) '(#t))
    (go/test '((lambda (x) (#%eqv? x x)) (lambda (x) x)) '(#t))
    (go/test '((lambda (x) (begin (set! x 5) (set! x 4) (set! x 3) x)) 0) '(3))
    (go/test '((lambda (x y) (x y)) #%+ 0) '(0))
    (go/test '(#%apply #%+ (#%cons 1 (#%cons 2 #%null))) '(3))
    (go/test '(#%call-with-values (lambda () (#%apply #%values (#%cons 1 (#%cons 2 #%null)))) #%+) '(3))
    (go/test '(#%call-with-values (lambda () 1) #%+) '(1))
    (go/test '(#%values 1) '(1))
    (go/test '((lambda (x) x) (#%values 1)) '(1))
    (go/test '(#%values 1 2) '((error "context received the wrong number of values")))
    (go/test '((lambda (dot args) (#%apply #%+ args)) 1 2 3 4) '(10))
    (go/test '((lambda (f) (#%eqv? (f 1) (f 1))) (lambda (dot args) (#%car args))) '(#t))
    
;; quote & eval tests
    
    (go/test '(quote 1) '(1))
    (go/test '(#%car (quote (quote 1))) '('quote))
    
    (go/test '(#%car (#%car (#%cdr (#%cdr '((x) (y) (1))))))
             '(1))
    
    (go/test '(#%eval '((lambda (x) x) 1))
             '(1))
    (go/test '(((lambda (y) (#%eval y)) '(lambda (x) x)) 1)
             '(1))
    (go/test '(#%car (#%eval '((lambda (x) x) '(1 2))))
             '(1))
    
    (go/test '((lambda (f) (#%eqv? (f) (f)))
               (lambda () '(2)))
             '(#t))
    
    (go/test '(#%eqv? '(f) '(f))
             '(#f))
    
    (go/test '((lambda (f)
                 (#%eqv? (f) (#%eval (#%cons 'quote (#%cons (f) #%null)))))
               (lambda () '(x)))
             '(#f))
#|

to read these tests, read the argument to conv-base from right to left
each corresponding set! should happen in that order.
in case of a test case failure, turn the number back into a sequence
of digits with deconv-base

|#
    
    ;; hop out one level
    (go/test* '(store ((bp 0)) (dw () ((#%dynamic-wind (lambda () (set! bp (#%+ (#%* bp 2) 0)))
                                                       (lambda () (#%call/cc (lambda (k) k)))
                                                       (lambda () (set! bp (#%+ (#%* bp 2) 1))))
                                       (lambda (y) bp))))
          (list (conv-base 2 #(1 0 1 0))))

    ;; hop out two levels
    (go/test* '(store ((x 0)) 
                 (dw () 
                     ((#%dynamic-wind 
                       (lambda () (set! x (#%+ (#%* x 5) 1)))
                       (lambda () 
                         (#%dynamic-wind
                          (lambda () (set! x (#%+ (#%* x 5) 2)))
                          (lambda () (#%call/cc (lambda (k) k)))
                          (lambda () (set! x (#%+ (#%* x 5) 3)))))
                       (lambda () (set! x (#%+ (#%* x 5) 4))))
                      (lambda (y) x))))
              (list (conv-base 5 #(4 3 2 1 4 3 2 1))))
  
    ;; don't duplicate tail
    (go/test* '(store ((x 0)) 
                 (dw () 
                     (#%dynamic-wind 
                      (lambda () (set! x (#%+ (#%* x 5) 1)))
                      (lambda () 
                        ((#%dynamic-wind (lambda () (set! x (#%+ (#%* x 5) 2)))
                                       (lambda () (#%call/cc (lambda (k) k)))
                                       (lambda () (set! x (#%+ (#%* x 5) 3))))
                         (lambda (y) x)))
                      (lambda () (set! x (#%+ (#%* x 5) 4))))))
              (list (conv-base 5 #(3 2 3 2 1))))
    
    ;; dont' duplicate tail, 2 deep
    (go/test* '(store ((x 0)) 
                 (dw () 
                     (#%dynamic-wind 
                      (lambda () (set! x (#%+ (#%* x 7) 1)))
                      (lambda () 
                        (#%dynamic-wind 
                         (lambda () (set! x (#%+ (#%* x 7) 2)))
                         (lambda () 
                           ((#%dynamic-wind (lambda () (set! x (#%+ (#%* x 7) 3)))
                                          (lambda () (#%call/cc (lambda (k) k)))
                                          (lambda () (set! x (#%+ (#%* x 7) 4))))
                            (lambda (y) x)))
                         (lambda () (set! x (#%+ (#%* x 7) 5)))))
                      (lambda () (set! x (#%+ (#%* x 7) 6))))))
              (list (conv-base 7 #(4 3 4 3 2 1))))
  
    ;; hop out and back into another one
    (go/test* '(store ((x 0)) 
                 (dw () 
                   ((lambda (ok)
                      (#%dynamic-wind (lambda () (set! x (#%+ (#%* x 5) 1)))
                                    (lambda () (ok (lambda (y) x)))
                                    (lambda () (set! x (#%+ (#%* x 5) 2)))))
                    (#%dynamic-wind (lambda () (set! x (#%+ (#%* x 5) 3)))
                                  (lambda () (#%call/cc (lambda (k) k)))
                                  (lambda () (set! x (#%+ (#%* x 5) 4)))))))
              (list  (conv-base 5 #(1 4 3 2 1 4 3))))
  
    ;; hop out one level and back in two levels
    (go/test* '(store ((x 0))
                  (dw () 
                      ((lambda (ok)
                         (#%dynamic-wind
                          (lambda () 1)
                          (lambda () 
                            (#%dynamic-wind
                             (lambda () 2)
                             (lambda () (ok (lambda (y) x)))
                             (lambda () (set! x (#%+ (#%* x 3) 1)))))
                          (lambda () (set! x (#%+ (#%* x 3) 2)))))
                       (#%call/cc (lambda (k) k)))))
                  (list (conv-base 3 #(2 1))))

    ;; hop out two levels and back in two levels
    (go/test* '(store ((x 0)) 
                 (dw () 
                   ((lambda (ok)
                      (#%dynamic-wind
                       (lambda () (set! x (#%+ (#%* x 9) 1)))
                       (lambda () 
                         (#%dynamic-wind
                          (lambda () (set! x (#%+ (#%* x 9) 2)))
                          (lambda () (ok (lambda (y) x)))
                          (lambda () (set! x (#%+ (#%* x 9) 3)))))
                       (lambda () (set! x (#%+ (#%* x 9) 4)))))
                    (#%dynamic-wind
                     (lambda () (set! x (#%+ (#%* x 9) 5)))
                     (lambda () 
                       (#%dynamic-wind
                        (lambda () (set! x (#%+ (#%* x 9) 6)))
                        (lambda () (#%call/cc (lambda (k) k)))
                        (lambda () (set! x (#%+ (#%* x 9) 7)))))
                     (lambda () (set! x (#%+ (#%* x 9) 8)))))))
              (list (conv-base 9 #(2 1 8 7 6 5 4 3 2 1 8 7 6 5)))))
  
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
      
  (run-tests))
