(module mz-r6-exns mzscheme
  (provide (rename -raise raise)
           with-exception-handler
           raise-continuable)
  (provide (all-from-except mzscheme raise))
  
  (define *current-exception-handlers*
    (list (lambda (condition)
            (error "unhandled exception" condition))))
  
  (define (with-exception-handler handler thunk)
    (with-exception-handlers (cons handler *current-exception-handlers*)
                             thunk))
  
  (define (with-exception-handlers new-handlers thunk)
    (let ((previous-handlers *current-exception-handlers*))
      (dynamic-wind
       (lambda ()
         (set! *current-exception-handlers* new-handlers))
       thunk
       (lambda ()
         (set! *current-exception-handlers* previous-handlers)))))
  
  (define (-raise obj)
    (let ((handlers *current-exception-handlers*))
      (with-exception-handlers (cdr handlers)
                               (lambda ()
                                 ((car handlers) obj)
                                 (error "handler returned"
                                        (car handlers)
                                        obj)))))
  
  (define (raise-continuable obj)
    (let ((handlers *current-exception-handlers*))
      (with-exception-handlers (cdr handlers)
                               (lambda ()
                                 ((car handlers) obj))))))


(module test mz-r6-exns
  (printf "~s\n"
          ((lambda (sx first-time?)
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
           1 #t)))

(module test2 mz-r6-exns
  (printf "~s\n"
          (+ 1 (with-exception-handler
                (lambda (x) (+ 2 x))
                (lambda () (+ 3 (raise-continuable (+ 2 2))))))))

(module test3 mz-r6-exns
  (printf "~s\n"
          ((lambda (count) 
             (with-exception-handler 
              (lambda (x) 
                (if (eqv? count 0) 
                    (begin (set! count 1)
                           (raise-continuable 2))
                    (lambda () x)))
              (lambda () ((raise-continuable 1)))))
           0)))

(module test4 mz-r6-exns
  (define k #f)
  (define ans #f)
  (define first-time? #t)
  (with-exception-handler
   (lambda (x) (begin (call/cc (lambda (k2) (set! k k2)))
                      (set! x (+ x 1))
                      (set! ans x)))
   (lambda () (raise-continuable 1)))
  (if first-time?
      (begin
        (set! first-time? #f)
        (k 1)))
  (printf "ans ~s\n" ans))

(module test5 mz-r6-exns
  (define y 0)
  (with-exception-handler
   (lambda (x) (set! y (+ x y)))
   (lambda ()
     (raise-continuable 1)
     (raise-continuable 2)))
  (printf "~s\n" y))

(module test6 mz-r6-exns
  (define phase 0)
  (define k #f)
  (define l '())
  (with-exception-handler
   (lambda (x) (if (eqv? phase 0)
                   (begin
                     (set! phase 1)
                     (call/cc (lambda (k2) (set! k k2))))
                   (if (eqv? phase 1)
                       (begin
                         (set! phase 2)
                         (k 1)))))
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
  (printf "~s\n" l))

(require test5)
