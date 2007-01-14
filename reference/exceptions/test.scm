; The CHECK macro is essentially stolen from Sebastian Egner's SRFIs.

(define *correct-count* 0)
(define *failed-count* 0)

(define-syntax check
  (syntax-rules (=>)
    ((check ec => desired-result)
     (check ec => (equal?) desired-result))
    ((check ec => (equal?) desired-result)
     (begin
       (newline)
       (write (quote ec))
       (newline)
       (let ((actual-result ec))
         (display "  => ")
         (write actual-result)
         (if (equal? actual-result desired-result)
             (begin
               (display " ; correct")
               (set! *correct-count* (+ *correct-count* 1)) )
             (begin
               (display " ; *** failed ***, desired result:")
               (newline)
               (display "  => ")
               (write desired-result)
               (set! *failed-count* (+ *failed-count* 1)) ))
         (newline) )))))

(define-condition-type &c &condition
  c?
  (x c-x))

(define-condition-type &c1 &c
  c1?
  (a c1-a))

(define-condition-type &c2 &c
  c2?
  (b c2-b))



(define v1
  (make-condition &c1
    (list (cons 'x "V1")
          (cons 'a "a1"))))

(check (c? v1) => #t)
(check (c1? v1) => #t)
(check (c2? v1) => #f)
(check (c-x v1) => "V1")
(check (c1-a v1) => "a1")



(define v2 (condition (&c2
                        (x "V2")
                        (b "b2"))))

(check (c? v2) => #t)
(check (c1? v2) => #f)
(check (c2? v2) => #t)
(check (c-x v2) => "V2")
(check (c2-b v2) => "b2")



(define v3 (condition (&c1
                       (x "V3/1")
                       (a "a3"))
                      (&c2
		       (x "V3/2")
                       (b "b3"))))

(check (c? v3) => #t)
(check (c1? v3) => #t)
(check (c2? v3) => #t)
(check (c-x v3) => "V3/1")
(check (c1-a v3) => "a3")
(check (c2-b v3) => "b3")



(define v4 (make-compound-condition v1 v2))

(check (c? v4) => #t)
(check (c1? v4) => #t)
(check (c2? v4) => #t)
(check (c-x v4) => "V1")
(check (c1-a v4) => "a1")
(check (c2-b v4) => "b2")



(define v5 (make-compound-condition v2 v3))

(check (c? v5) => #t)
(check (c1? v5) => #t)
(check (c2? v5) => #t)
(check (c-x v5) => "V2")
(check (c1-a v5) => "a3")
(check (c2-b v5) => "b2")

(newline)
(display "correct tests: ")
(display *correct-count*)
(newline)
(display "failed tests: ")
(display *failed-count*)
(newline)
