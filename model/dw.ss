(module dw mzscheme 
  (provide dw)
  
  (define-syntax (dw stx)
    (syntax-case stx ()
      [(_ a b c) (syntax (dw/proc (λ () a) (λ () b) (λ () c)))]))
  
  ;; is this right?!? ....
  (define (dw/proc t1 t2 t3)
    (let ([first-time? #f]
          [jump-out? #f])
      (dynamic-wind
       (λ ()
         (cond
           [first-time?
            (set! first-time? #f)]
           [else
            (t1)]))
       (λ ()
         (t2)
         (set! jump-out? #f))
       (λ ()
         (cond
           [jump-out? 
            (t3)]
           [else (void)]))))))