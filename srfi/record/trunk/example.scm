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

; explicit naming

(define-type (point make-point point?) (x y)
  (fields (x (point-x))
          (y (point-y set-point-y!) y))
  (opaque #f)
  (updater update-x x)
  (updater update-yx y x)
  (nongenerative point-4893d957-e00b-11d9-817f-00111175eb9e))

(define-type (cpoint make-cpoint cpoint?) (x y c)
  (parent point x y)
  (fields (rgb (cpoint-rgb cpoint-rgb-set!) (color->rgb c))))

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

(check (record-type-descriptor p1) => (type-descriptor point))

(check (point-x (update-x p1 5)) => 5)
(check (point-y (update-x p1 5)) => 2)

(check (point-x (update-yx p1 17 24)) => 24)
(check (point-y (update-yx p1 17 24)) => 17)

(define-type (point make-point point?) (x y)
  (fields (x (point-x))
          (y (point-y set-point-y!) y))
  (nongenerative point-4893d957-e00b-11d9-817f-00111175eb9e))

(check (point? p1) => #t)

(define-type (ex1 make-ex1 ex1?) a
  (fields (f (ex1-f) a)))

(define ex1-i1 (make-ex1 1 2 3))
(check (ex1-f ex1-i1) => '(1 2 3))

(define-type (ex2 make-ex2 ex2?) (a . b)
  (fields (a (ex2-a) a)
	  (b (ex2-b) b)))

(define ex2-i1 (make-ex2 1 2 3))
(check (ex2-a ex2-i1) => 1)
(check (ex2-b ex2-i1) => '(2 3))

; implicit naming

(define *ex3-instance* #f)

(define-type ex3 (x y t)
  (parent cpoint x y 'red)
  (fields 
   (thickness mutable t))
  (init! (p) (set! *ex3-instance* p))
  (sealed #t) (opaque #t))

(define ex3-i1 (make-ex3 1 2 17))
(check (ex3? ex3-i1) => #t)
(check (cpoint-rgb ex3-i1) => '(rgb . red))
(check (ex3-thickness ex3-i1) => 17)
(ex3-thickness-set! ex3-i1 18)
(check (ex3-thickness ex3-i1) => 18)
(check *ex3-instance* => (eq?) ex3-i1)

(check (record? ex3-i1) => #f)

; fancy constructor

(define-type (unit-vector make-unit-vector unit-vector?) (x y z)
  (let ((length (+ (* x x) (* y y) (* z z)))))
  (fields (x (unit-vector-x) (/ x length))
	  (y (unit-vector-y) (/ y length))
	  (z (unit-vector-z) (/ z length))))

(newline)
(display "correct tests: ")
(display *correct-count*)
(newline)
(display "failed tests: ")
(display *failed-count*)
(newline)
