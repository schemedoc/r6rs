; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Fixnums in terms of R5RS

; This code is actually not constrained by a two's complement range.

(define *width* 24)

(define *low* (r5rs:- (r5rs:expt 2 (r5rs:- *width* 1))))
(define *high* (r5rs:- (r5rs:expt 2 (r5rs:- *width* 1)) 1))

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
   ((r5rs:positive? y)
    (let ((n (r5rs:* (r5rs:numerator x)
                     (r5rs:denominator y)))
          (d (r5rs:* (r5rs:denominator x)
                     (r5rs:numerator y))))
      (if (r5rs:negative? n)
          (r5rs:- (r5rs:quotient (r5rs:- (r5rs:- d n) 1) d))
          (r5rs:quotient n d))))
   ((r5rs:zero? y)
    0)
   ((r5rs:negative? y)
    (let ((n (r5rs:* -2 
                     (r5rs:numerator x)
                     (r5rs:denominator y)))
          (d (r5rs:* (r5rs:denominator x)
                     (r5rs:- (r5rs:numerator y)))))
      (if (r5rs:< n d)
          (r5rs:- (r5rs:quotient (r5rs:- d n) (r5rs:* 2 d)))
          (r5rs:quotient (r5rs:+ n d -1) (r5rs:* 2 d)))))))

(define (r5rs-mod x y)
  (r5rs:- x (r5rs:* (r5rs-div x y) y)))

(define *modulus* (r5rs:+ (r5rs:- *high* *low*) 1))

; Sebastian Egner provided this.
(define (rep x)
  (r5rs:+ *low*
          (r5rs-mod (r5rs:- x *low*) *modulus*)))

(define (make-fixnum n)
  (really-make-fixnum (rep n)))

(define r5rs->fixnum make-fixnum)

; for playing around
(define fx make-fixnum)

(define (make-fx*fx->fx fixnum-op)
  (lambda (a b)
    (make-fixnum (fixnum-op (fixnum-rep a) (fixnum-rep b)))))

(define fx+/2 (make-fx*fx->fx r5rs:+))
(define (fx+ . args)
  (reduce (make-fixnum 0) fx+/2 args))

(define fx-/2 (make-fx*fx->fx r5rs:-))
(define (fx- arg0 . args)
  (reduce (make-fixnum 0) fx-/2 (cons arg0 args)))

(define (make-fx->fx fixnum-op)
  (lambda (a)
    (make-fixnum (fixnum-op (fixnum-rep a)))))

(define fx*/2 (make-fx*fx->fx r5rs:*))
(define (fx* . args)
  (reduce (make-fixnum 1) fx*/2 args))

(define fxquotient (make-fx*fx->fx r5rs:quotient))
(define fxremainder (make-fx*fx->fx r5rs:remainder))
(define fxmodulo (make-fx*fx->fx r5rs:modulo))

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

(define fx= (make-transitive-pred (make-fx*fx->val r5rs:=)))
(define fx>= (make-transitive-pred (make-fx*fx->val r5rs:>=)))
(define fx<= (make-transitive-pred (make-fx*fx->val r5rs:<=)))
(define fx> (make-transitive-pred (make-fx*fx->val r5rs:>)))
(define fx< (make-transitive-pred (make-fx*fx->val r5rs:<)))

(define (make-fx->val fixnum-op)
  (lambda (a)
    (fixnum-op (fixnum-rep a))))

(define fxzero? (make-fx->val r5rs:zero?))
(define fxpositive? (make-fx->val r5rs:positive?))
(define fxnegative? (make-fx->val r5rs:negative?))
(define fxeven? (make-fx->val r5rs:even?))
(define fxodd? (make-fx->val r5rs:odd?))

(define fxmin (make-min/max fx<))
(define fxmax (make-min/max fx>))

(define *fx-width* (make-fixnum *width*))
(define *fx-min* (make-fixnum *low*))
(define *fx-max* (make-fixnum *high*))

(define (fixnum-width) *fx-width*)
(define (least-fixnum) *fx-min*)
(define (greatest-fixnum) *fx-max*)

; Issues:
; should the limits be thunks?
; Chez has: fx-nonpositive?, fx-nonnegative?
; SRFI 71: fx-compare?

; these are built into Scheme 48
; check SRFI 60 for a reference implementation
(define fxarithmetic-shift-left (make-fx*fx->fx arithmetic-shift))
(define fxbitwise-not (make-fx->fx bitwise-not))
(define fxbit-count (make-fx->fx bit-count))

(define fxbitwise-and/2 (make-fx*fx->fx bitwise-and))
(define (fxbitwise-and . args)
  (reduce (make-fixnum -1)
	  fxbitwise-and/2
	  args))

(define fxbitwise-ior/2 (make-fx*fx->fx bitwise-ior))
(define (fxbitwise-ior . args)
  (reduce (make-fixnum 0)
	  fxbitwise-ior/2
	  args))

(define fxbitwise-xor/2 (make-fx*fx->fx bitwise-xor))
(define (fxbitwise-xor . args)
  (reduce (make-fixnum 0)
	  fxbitwise-xor/2
	  args))

(define (fxlogical-shift-left fx1 fx2)
  (cond
   ((fxnegative? fx2)
    (error "negative shift argument to fxlogical-shift-left" fx1 fx2))
   ((fxzero? fx2) fx1)
   ((fx> fx2 *fx-width*) (make-fixnum 0))
   (else
    (fxbitwise-and/2 (fxarithmetic-shift-left (fxbitwise-and/2 fx1 *fx-max*) fx2)
		     *fx-max*))))

(define (fxlogical-shift-right fx1 fx2)
  (cond
   ((fxnegative? fx2)
    (error "negative shift argument to fxlogical-shift-left" fx1 fx2))
   ((fxzero? fx2) fx1)
   ((fxpositive? fx1)
    (fxarithmetic-shift-left fx1 (fx- fx2)))
   ((fx> fx2 *fx-width*) (make-fixnum 0))
   (else
    (fxbitwise-ior/2
     (fxarithmetic-shift-left (fxbitwise-and/2 fx1 *fx-max*) (fx- fx2))
     (fxlogical-shift-left (make-fixnum 1)
			   (fx- *fx-width* fx2 (make-fixnum 1)))))))

; Operations with carry

(define *carry-modulus* (r5rs:+ *high* 1))

(define (make-nnfx*nnfx*carry->fx fixnum-op)
  (lambda (x y c)
    (let ((xr (fixnum-rep x))
	  (yr (fixnum-rep y))
	  (cr (fixnum-rep c)))
      (if (or (r5rs:negative? xr) (r5rs:negative? yr))
	  (error "negative argument to fx+-with-carry" xr yr))
      (if (or (r5rs:< cr 0)
	      (r5rs:> cr 1))
	  (error "invalid carry" cr))
      (fixnum-op xr yr cr))))

(define fx+/carry
  (make-nnfx*nnfx*carry->fx
   (lambda (xr yr cr)
     (let ((sum (r5rs:+ xr yr cr)))
       (values (make-fixnum (r5rs-mod sum *carry-modulus*))
	       (make-fixnum (r5rs-div sum *carry-modulus*)))))))

(define fx-/carry
  (make-nnfx*nnfx*carry->fx
   (lambda (xr yr br)
     (let ((difference (r5rs:- (r5rs:- xr yr) br)))
       (values (make-fixnum (r5rs-mod difference *carry-modulus*))
	       (make-fixnum (r5rs:-
                             (r5rs-div difference *carry-modulus*))))))))

(define (fx*/carry x y z c)
  (let ((xr (fixnum-rep x))
	(yr (fixnum-rep y))
	(zr (fixnum-rep z))
	(cr (fixnum-rep c)))
    (if (or (r5rs:negative? xr) (r5rs:negative? yr))
	(error "negative argument to fx+-with-carry" xr yr))
    (if (or (r5rs:< zr 0)
	    (r5rs:> zr 1))
	(error "invalid carry" zr))
    (if (or (r5rs:< cr 0)
	    (r5rs:> cr 1))
	(error "invalid carry" cr))
    (let ((result (r5rs:+ (r5rs:* xr yr) zr cr)))
      (values (make-fixnum (r5rs-mod result *carry-modulus*))
	      (make-fixnum (r5rs-div result *carry-modulus*))))))

