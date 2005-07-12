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

; DEFINE-RECORD-TYPE/EXPLICIT

(define-record-type/explicit (point make-point point?) (x y)
  (fields ((immutable x point-x) x)
          ((mutable y point-y set-point-y!) y))
  (nongenerative point-4893d957-e00b-11d9-817f-00111175eb9e))

(define-record-type/explicit (cpoint make-cpoint cpoint?) (x y c)
  (parent point x y)
  (fields ((mutable rgb cpoint-rgb cpoint-rgb-set!) (color->rgb c))))

(define (color->rgb c)
  (cons 'rgb c))

(define p1 (make-point 1 2))
(define p2 (make-cpoint 3 4 'red))

(check (point? p1) => #t)
(check (point? p2) => #t)
(check (point? (vector)) => #f)
(check (point? (cons 'a 'b)) => #f)
(check (cpoint? p1) => #f)
(check (cpoint? p2) => #t)
(check (point-x p1) => 1)
(check (point-y p1) => 2)
(check (point-x p2) => 3)
(check (point-y p2) => 4)
(check (cpoint-rgb p2) => '(rgb . red))

(set-point-y! p1 17)
(check (point-y p1) => 17)

(define-record-type/explicit (point make-point point?) (x y)
  (fields ((immutable x point-x) x)
          ((mutable y point-y set-point-y!) y))
  (nongenerative point-4893d957-e00b-11d9-817f-00111175eb9e))

(check (point? p1) => #t)

(define-record-type/explicit (ex1 make-ex1 ex1?) a
  (fields ((immutable f ex1-f) a)))

(define ex1-i1 (make-ex1 1 2 3))
(check (ex1-f ex1-i1) => '(1 2 3))

(define-record-type/explicit (ex2 make-ex2 ex2?) (a . b)
  (fields ((immutable a ex2-a) a)
	  ((immutable b ex2-b) b)))

(define ex2-i1 (make-ex2 1 2 3))
(check (ex2-a ex2-i1) => 1)
(check (ex2-b ex2-i1) => '(2 3))

; DEFINE-RECORD-TYPE/IMPLICIT

(define-record-type/implicit (point make-point point?) (x y)
  (fields ((immutable x point-x) x)
          ((mutable y point-y set-point-y!) y))
  (nongenerative point-4893d957-e00b-11d9-817f-00111175eb9e))

(define-record-type/implicit (cpoint make-cpoint cpoint?) (x y c)
  (parent point x y)
  (fields ((mutable rgb cpoint-rgb cpoint-rgb-set!) (color->rgb c))))

(define (color->rgb c)
  (cons 'rgb c))

(define p1 (make-point 1 2))
(define p2 (make-cpoint 3 4 'red))

(check (point? p1) => #t)
(check (point? p2) => #t)
(check (point? (vector)) => #f)
(check (point? (cons 'a 'b)) => #f)
(check (cpoint? p1) => #f)
(check (cpoint? p2) => #t)
(check (point-x p1) => 1)
(check (point-y p1) => 2)
(check (point-x p2) => 3)
(check (point-y p2) => 4)
(check (cpoint-rgb p2) => '(rgb . red))

(set-point-y! p1 17)
(check (point-y p1) => 17)

(define-record-type/implicit (point make-point point?) (x y)
  (fields ((immutable x point-x) x)
          ((mutable y point-y set-point-y!) y))
  (nongenerative point-4893d957-e00b-11d9-817f-00111175eb9e))

(check (point? p1) => #t)

(define-record-type/implicit (ex1 make-ex1 ex1?) a
  (fields ((immutable f ex1-f) a)))

(define ex1-i1 (make-ex1 1 2 3))
(check (ex1-f ex1-i1) => '(1 2 3))

(define-record-type/implicit (ex2 make-ex2 ex2?) (a . b)
  (fields ((immutable a ex2-a) a)
	  ((immutable b ex2-b) b)))

(define ex2-i1 (make-ex2 1 2 3))
(check (ex2-a ex2-i1) => 1)
(check (ex2-b ex2-i1) => '(2 3))

; genuine tests for DEFINE-RECORD-TYPE/IMPLICIT

(define *ex3-instance* #f)

(define-record-type/implicit ex3 (x y c)
  (parent point x y)
  (fields ((mutable rgb) (color->rgb c)))
  (init! (p) (set! *ex3-instance* p))
  sealed)

(define ex3-i1 (make-ex3 1 2 'red))
(check (ex3? ex3-i1) => #t)
(check (ex3-rgb ex3-i1) => '(rgb . red))
(ex3-rgb-set! ex3-i1 '(rgb . blue))
(check (ex3-rgb ex3-i1) => '(rgb . blue))
(check *ex3-instance* => (eq?) ex3-i1)

(newline)
(display "correct tests: ")
(display *correct-count*)
(newline)
(display "failed tests: ")
(display *failed-count*)
(newline)
