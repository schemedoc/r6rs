; This file of Larceny-dependent code implements enough of
;
; SRFI-76 (R6RS Records)
; SRFI-77 (Preliminary Proposal for R6RS Arithmetic)
;
; and other things to support Will Clinger's reference implementation of
;
; Finite sets of symbols, and their use as enumeration types.

(define (larceny:error . etc)
  (display "Tried to use an unimplemented feature of R6RS.")
  (newline)
  (display "Shame on you!")
  (newline)
  (car 'larceny))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SRFI-76 (R6RS Records)
;
; Implements only as much as is used by enumerations.sch.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (make-record-type-descriptor name parent uid sealed? opaque? fields)
  (if (or parent uid sealed? opaque?)
      (larceny:error)
      (make-record-type name (map cadr fields))))

(define (make-record-constructor-descriptor rtd parent-something protocol)
  (if parent-something
      (larceny:error)
      (protocol (record-constructor rtd))))

; Larceny's record-constructor and record-predicate procedures
; are compatible with SRFI-76, but Larceny's record-accessor is not.

(define larceny:record-accessor record-accessor)

(define (record-accessor rtd k)
  (if (and (number? k) (integer? k) (exact? k) (>= k 0))
      (let ((field-names (record-type-field-names rtd)))
        (larceny:record-accessor rtd (list-ref field-names k)))
      (larceny:record-accessor rtd k)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SRFI-77 (Preliminary Proposal for R6RS Arithmetic)
;
; Implements only as much as is used by enumerations.sch.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Define a small set of bitwise operators.

; Given exact integers n and k, with k >= 0, return (* n (expt 2 k)).

(define (arithmetic-shift n k)
  (if (and (exact? n)
           (integer? n)
           (exact? k)
           (integer? k))
      (cond ((> k 0)
             (* n (expt 2 k)))
            ((= k 0)
             n)
            ((>= n 0)
             (quotient n (expt 2 (- k))))
            (else
             (let* ((q (expt 2 (- k)))
                    (p (quotient (- n) q)))
               (if (= n (* p k))
                   (- p)
                   (- -1 p)))))
      (error "illegal argument to arithmetic-shift" n k)))

; Bitwise operations on exact integers.

(define (bitwise-and i j)
  (if (and (exact? i)
           (integer? i)
           (exact? j)
           (integer? j))
      (cond ((or (= i 0) (= j 0))
             0)
            ((= i -1)
             j)
            ((= j -1)
             i)
            (else
             (let* ((i0 (if (odd? i) 1 0))
                    (j0 (if (odd? j) 1 0))
                    (i1 (- i i0))
                    (j1 (- j j0))
                    (i/2 (quotient i1 2))
                    (j/2 (quotient j1 2))
                    (hi (* 2 (bitwise-and i/2 j/2)))
                    (lo (* i0 j0)))
               (+ hi lo))))
      (error "illegal argument to bitwise-and" i j)))

(define (bitwise-ior i j)
  (if (and (exact? i)
           (integer? i)
           (exact? j)
           (integer? j))
      (cond ((or (= i -1) (= j -1))
             -1)
            ((= i 0)
             j)
            ((= j 0)
             i)
            (else
             (let* ((i0 (if (odd? i) 1 0))
                    (j0 (if (odd? j) 1 0))
                    (i1 (- i i0))
                    (j1 (- j j0))
                    (i/2 (quotient i1 2))
                    (j/2 (quotient j1 2))
                    (hi (* 2 (bitwise-ior i/2 j/2)))
                    (lo (if (= 0 (+ i0 j0)) 0 1)))
               (+ hi lo))))
      (error "illegal argument to bitwise-ior" i j)))

(define (bitwise-xor i j)
  (if (and (exact? i)
           (integer? i)
           (exact? j)
           (integer? j))
      (cond ((and (= i -1) (= j -1))
             0)
            ((= i 0)
             j)
            ((= j 0)
             i)
            (else
             (let* ((i0 (if (odd? i) 1 0))
                    (j0 (if (odd? j) 1 0))
                    (i1 (- i i0))
                    (j1 (- j j0))
                    (i/2 (quotient i1 2))
                    (j/2 (quotient j1 2))
                    (hi (* 2 (bitwise-xor i/2 j/2)))
                    (lo (if (= 1 (+ i0 j0)) 1 0)))
               (+ hi lo))))
      (error "illegal argument to bitwise-xor" i j)))

(define (bitwise-not i)
  (if (and (exact? i)
           (integer? i))
      (cond ((= i -1)
             0)
            ((= i 0)
             -1)
            (else
             (let* ((i0 (if (odd? i) 1 0))
                    (i1 (- i i0))
                    (i/2 (quotient i1 2))
                    (hi (* 2 (bitwise-not i/2)))
                    (lo (- 1 i0)))
               (+ hi lo))))
      (error "illegal argument to bitwise-not" i j)))

(define (bit-count i)
  (if (and (exact? i)
           (integer? i))
      (cond ((= i -1)
             0)
            ((= i 0)
             0)
            (else
             (let* ((i0 (if (odd? i) 1 0))
                    (i1 (- i i0))
                    (i/2 (quotient i1 2))
                    (hi (bit-count i/2))
                    (lo (if (> i 0) i0 (- 1 i0))))
               (+ hi lo))))
      (error "illegal argument to bit-count" i j)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Exact operations.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define exact-not bitwise-not)
(define exact-and bitwise-and)
(define exact-ior bitwise-ior)
(define exact-xor bitwise-xor)

(define exact-zero? zero?)

(define exact-arithmetic-shift-left arithmetic-shift)

(define (exact-first-bit-set n)
  (cond ((or (not (number? n)) (not (exact? n)) (not (integer? n)))
         (error "Please don't pass this to exact-first-bit-set" n))
        ((negative? n)
         (larceny:error))
        ((zero? n)
         -1)
        (else
         (do ((n n (quotient n 2))
              (i 0 (+ i 1)))
             ((odd? n) i)))))

; From generic-ex.scm

(define (exact-if ei1 ei2 ei3)
  (exact-ior (exact-and ei1 ei2)
             (exact-and (exact-not ei1) ei3)))

(define (exact-copy-bit ei1 ei2 ei3)
  (let* ((mask (exact-arithmetic-shift-left 1 ei2)))
    (exact-if mask
              (exact-arithmetic-shift-left ei3 ei2)
              ei1)))

; Simplified from generic-ex.scm

(define (exact-div+mod x y)
  (cond ((or (not (and (exact? x) (number? x)))
             (not (and (exact? y) (number? y))))
         (error "illegal arguments to exact-div+mod" x y))
        ((zero? y)
         (error "exact division by zero" x y))
        (else
         ; FIXME: this isn't very efficient
         (let* ((n (* (numerator x)
                      (denominator y)))
                (d (* (denominator x)
                      (numerator y)))
                (q (quotient n d))
                (m (- x (* q y))))
           ; x = xn/xd
           ; y = yn/yd
           ; n = xn*yd
           ; d = xd*yn
           ; x/y = (xn*yd)/(xd*yn) = n/d
           (if (negative? m)
               (if (positive? y)
                   (values (- q 1)
                           (+ m y))
                   (values (+ q 1)
                           (- m y)))                   
               (values q m))))))

(define (exact-div x y)
  (call-with-values
   (lambda () (exact-div+mod x y))
   (lambda (d m)
     d)))

(define (exact-mod x y)
  (call-with-values
   (lambda () (exact-div+mod x y))
   (lambda (d m)
     m)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Fixnum operations.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define fixnum-mod exact-mod)

(define fixnum= =)
(define fixnum< <)
(define fixnum> >)
(define fixnum<= <=)
(define fixnum>= >=)

(define fixnum+ +)
(define fixnum- -)

(define fixnum-not bitwise-not)
(define fixnum-and bitwise-and)
(define fixnum-ior bitwise-ior)
(define fixnum-xor bitwise-xor)

(define fixnum-arithmetic-shift-left arithmetic-shift)

(define (fixnum-width) 30)

(define fixnum-first-bit-set exact-first-bit-set)
(define fixnum-copy-bit exact-copy-bit)
