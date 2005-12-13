; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Fixnums in terms of R5RS

; This code is actually not constrained by a two's complement range.

(define *width* 24)

(define *low* (- (expt 2 (- *width* 1))))
(define *high* (- (expt 2 (- *width* 1)) 1))

; SRFI 9
(define-record-type :fixnum
  (really-make-fixnum representative)
  fixnum?
  (representative fixnum-rep))

(define fixnum->r5rs fixnum-rep)

; Scheme 48 extension; comment out if not available
(define-record-discloser :fixnum
  (lambda (r)
    (list 'fx (fixnum-rep r))))

; See "Cleaning up the Tower"

(define (r5rs-div x y)
  (cond
   ((positive? y)
    (let ((n (* (numerator x)
                (denominator y)))
          (d (* (denominator x)
                (numerator y))))
      (if (negative? n)
          (- (quotient (- (- d n) 1) d))
          (quotient n d))))
   ((zero? y)
    0)
   ((negative? y)
    (let ((n (* -2 
                (numerator x)
                (denominator y)))
          (d (* (denominator x)
                (- (numerator y)))))
      (if (< n d)
          (- (quotient (- d n) (* 2 d)))
          (quotient (+ n d -1) (* 2 d)))))))

(define (r5rs-mod x y)
  (- x (* (r5rs-div x y) y)))

(define *modulus* (- *high* *low*))

; Sebastian Egner provided this.
(define (rep x)
  (+ *low*
     (r5rs-mod (- x *low*) *modulus*)))

(define (make-fixnum n)
  (really-make-fixnum (rep n)))

(define r5rs->fixnum make-fixnum)

; for playing around
(define fx make-fixnum)

(define (make-fx*fx->fx fixnum-op)
  (lambda (a b)
    (make-fixnum (fixnum-op (fixnum-rep a) (fixnum-rep b)))))

(define fx+/2 (make-fx*fx->fx +))
(define (fx+ . args)
  (reduce (make-fixnum 0) fx+/2 args))

(define fx-/2 (make-fx*fx->fx -))
(define (fx- arg0 . args)
  (reduce (make-fixnum 0) fx-/2 (cons arg0 args)))

(define (make-fx->fx fixnum-op)
  (lambda (a)
    (make-fixnum (fixnum-op (fixnum-rep a)))))

(define fx*/2 (make-fx*fx->fx *))
(define (fx* . args)
  (reduce (make-fixnum 1) fx*/2 args))

(define fxquotient (make-fx*fx->fx quotient))
(define fxremainder (make-fx*fx->fx remainder))
(define fxmodulo (make-fx*fx->fx modulo))

(define (fxquotient+remainder a b)
  (values (fxquotient a b)
	  (fxremainder a b)))

(define (fxdiv+mod x y)
  (let* ((div
	  (cond
	   ((fxpositive? y)
	    (let ((n x)
		  (d y))
	      (if (fxnegative? n)
		  (fx- (fxquotient (fx- (fx- d n) (r5rs->fixnum 1)) d))
		  (fxquotient n d))))
	   ((fxzero? y)
	    (r5rs->fixnum 0))
	   ((fxnegative? y)
	    (let ((n (fx* (r5rs->fixnum -2) x))
		  (d (fx- y)))
	      (if (fx< n d)
		  (fx- (fxquotient (fx- d n) (fx* (r5rs->fixnum 2) d)))
		  (fxquotient (fx+ n (fx+ d (r5rs->fixnum -1)))
			      (fx* (r5rs->fixnum 2) d)))))))
	 (mod
	  (fx- x (fx* div y))))
    (values div mod)))

(define (fxdiv x y)
  (call-with-values
      (lambda () (fxdiv+mod x y))
    (lambda (d m)
      d)))

(define (fxmod x y)
  (call-with-values
      (lambda () (fxdiv+mod x y))
    (lambda (d m)
      m)))

(define (make-fx*fx->val fixnum-op)
  (lambda (a b)
    (fixnum-op (fixnum-rep a) (fixnum-rep b))))

(define fx= (make-transitive-pred (make-fx*fx->val =)))
(define fx>= (make-transitive-pred (make-fx*fx->val >=)))
(define fx<= (make-transitive-pred (make-fx*fx->val <=)))
(define fx> (make-transitive-pred (make-fx*fx->val >)))
(define fx< (make-transitive-pred (make-fx*fx->val <)))

(define (make-fx->val fixnum-op)
  (lambda (a)
    (fixnum-op (fixnum-rep a))))

(define fxzero? (make-fx->val zero?))
(define fxpositive? (make-fx->val positive?))
(define fxnegative? (make-fx->val negative?))
(define fxeven? (make-fx->val even?))
(define fxodd? (make-fx->val odd?))

(define fxmin (make-min/max fx<))
(define fxmax (make-min/max fx>))

(define *fx-width* (make-fixnum *width*))
(define *fx-min* (make-fixnum *low*))
(define *fx-max* (make-fixnum (- *high* 1)))

(define (fixnum-width) *fx-width*)
(define (least-fixnum) *fx-min*)
(define (greatest-fixnum) *fx-max*)

; Issues:
; should the limits be thunks?
; Chez has: fx-nonpositive?, fx-nonnegative?
; SRFI 71: fx-compare?

; these are built into Scheme 48
; check SRFI 60 for a reference implementation
(define fxarithmetic-shift (make-fx*fx->fx arithmetic-shift))
(define fxbitwise-not (make-fx->fx bitwise-not))
(define fxbit-count (make-fx->fx bit-count))
(define fxbitwise-and (make-fx*fx->fx bitwise-and))
(define fxbitwise-ior (make-fx*fx->fx bitwise-ior))
(define fxbitwise-xor (make-fx*fx->fx bitwise-xor))
