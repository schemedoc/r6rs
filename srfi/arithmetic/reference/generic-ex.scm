; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Generic exact rational arithmetic

(define (exact-number? obj)
  (or (fixnum? obj)
      (bignum? obj)
      (ratnum? obj)
      (recnum? obj)))

(define (exact-complex? obj)
  (exact-number? obj))

(define (exact-rational? obj)
  (or (fixnum? obj)
      (bignum? obj)
      (ratnum? obj)))

(define (exact-integer? obj)
  (or (fixnum? obj)
      (bignum? obj)))

(define-syntax define-binary
  (syntax-rules ()
    ((define-binary ?name ?contagion ?bignum-op ?ratnum-op ?recnum-op)
     (define (?name a b)
       (cond
	((bignum? a)
	 (if (bignum? b)
	     (?bignum-op a b)
	     (?contagion a b ?name)))
	((ratnum? a)
	 (if (ratnum? b)
	     (?ratnum-op a b)
	     (?contagion a b ?name)))
	((recnum? a)
	 (if (recnum? b)
	     (?recnum-op a b)
	     (?contagion a b ?name)))
	(else
	 (?contagion a b ?name)))))
    ((define-binary ?name ?contagion ?fixnum-op ?bignum-op ?ratnum-op ?recnum-op)
     (define (?name a b)
       (cond
	((fixnum? a)
	 (if (fixnum? b)
	     (?fixnum-op a b)
	     (?contagion a b ?name)))
	((bignum? a)
	 (if (bignum? b)
	     (?bignum-op a b)
	     (?contagion a b ?name)))
	((ratnum? a)
	 (if (ratnum? b)
	     (?ratnum-op a b)
	     (?contagion a b ?name)))
	((recnum? a)
	 (if (recnum? b)
	     (?recnum-op a b)
	     (?contagion a b ?name)))
	(else
	 (?contagion a b ?name)))))))

(define-binary exact=?/2 econtagion/ex
  fx= bignum= ratnum= recnum=)

(define-binary exact<?/2 pcontagion/ex
  fx< bignum< ratnum< (make-typo-op/2 exact<? 'rational))
(define-binary exact<=?/2 pcontagion/ex
  fx< bignum<= ratnum<= (make-typo-op/2 exact<=? 'rational))
(define-binary exact>=?/2 pcontagion/ex
  fx>= bignum>= ratnum>= (make-typo-op/2 exact>=? 'rational))
(define-binary exact>?/2 pcontagion/ex
  fx>= bignum> ratnum> (make-typo-op/2 exact>? 'rational))

(define exact=? (make-transitive-pred exact=?/2))
(define exact<? (make-transitive-pred exact<?/2))
(define exact<=? (make-transitive-pred exact<=?/2))
(define exact>=? (make-transitive-pred exact>=?/2))
(define exact>? (make-transitive-pred exact>=?/2))

(define-syntax define-unary
  (syntax-rules ()
    ((define-unary ?name ?fixnum-op ?bignum-op ?ratnum-op ?recnum-op)
     (define (?name a)
       (cond
	((fixnum? a)
	 (?fixnum-op a))
	((bignum? a)
	 (?bignum-op a))
	((ratnum? a)
	 (?ratnum-op a))
	((recnum? a)
	 (?recnum-op a))
	(else
	 (error "expects an exact argument" ?name a)))))))

(define-unary exact-zero? fxzero? bignum-zero? never never) 
(define-unary exact-positive? fxpositive? bignum-positive? ratnum-positive?
  (make-typo-op/1 exact-positive? 'rational))
(define-unary exact-negative? fxnegative? bignum-negative? ratnum-negative?
  (make-typo-op/1 exact-negative? 'rational))
(define-unary exact-odd? fxodd? bignum-odd?
  (make-typo-op/1 exact-odd? 'integer)
  (make-typo-op/1 exact-odd? 'integer))
(define-unary exact-even? fxeven? bignum-even?
  (make-typo-op/1 exact-even? 'integer)
  (make-typo-op/1 exact-even? 'integer))

(define exact-min (make-min/max exact<?))
(define exact-max (make-min/max exact>?))

(define-binary exact+/2 contagion/ex
  bignum+ ratnum+ recnum+)
(define-binary exact-/2 contagion/ex
  bignum- ratnum- recnum-)
(define-binary exact*/2 contagion/ex
  bignum* ratnum* recnum*)
(define-binary exact//2 contagion/ex
  integer/ integer/ ratnum/ recnum/)

(define (exact+ . args)
  (reduce (r5rs->integer 0) exact+/2 args))
(define (exact- arg0 . args)
  (reduce (r5rs->integer 0) exact-/2 (cons arg0 args)))
(define (exact* . args)
  (reduce (r5rs->integer 1) exact*/2 args))
(define (exact/ arg0 . args)
  (reduce (r5rs->integer 1) exact//2 (cons arg0 args)))

;; ABS is evil ...
(define *minus-least-fixnum* (bignum-negate (fixnum->bignum (least-fixnum))))

(define (fx-abs x)
  (cond
   ((fxnegative? x)
    (if (fx= x (least-fixnum))
	*minus-least-fixnum*
	(fx- x)))
   (else x)))

(define-unary exact-abs
  fx-abs bignum-abs ratnum-abs
  (make-typo-op/1 exact-abs 'rational))

(define-binary exact-quotient contagion/ex
  fxquotient
  bignum-quotient
  (make-typo-op/2 exact-quotient 'integer)
  (make-typo-op/2 exact-quotient 'integer))
  
(define-binary exact-remainder contagion/ex
  fxremainder
  bignum-remainder
  (make-typo-op/2 exact-remainder 'integer)
  (make-typo-op/2 exact-remainder 'integer))

(define-binary exact-quotient+remainder contagion/ex
  fxquotient+remainder
  bignum-quotient+remainder
  (make-typo-op/2 exact-quotient+remainder 'integer)
  (make-typo-op/2 exact-quotient+remainder 'integer))

(define (exact-modulo x y)
  (if (and (exact-integer? x) (exact-integer? y))
      (let* ((q (exact-quotient x y))
	     (r (exact- x (exact* q y))))
	(cond ((exact-zero? r)
	       r)
	      ((exact-negative? r)
	       (if (exact-negative? y)
		   r
		   (exact+ r y)))
	      ((exact-negative? y)
	       (exact+ r y))
	      (else
	       r)))
      (error "exact-modulo expects integral arguments" x y)))

(define (exact-div+mod x y)
  (let* ((div
	  (cond
	   ((exact-positive? y)
	    (let ((n (exact* (exact-numerator x)
			     (exact-denominator y)))
		  (d (exact* (exact-denominator x)
			     (exact-numerator y))))
	      (if (exact-negative? n)
		  (exact- (exact-quotient (exact- (exact- d n) (r5rs->integer 1)) d))
		  (exact-quotient n d))))
	   ((exact-zero? y)
	    (r5rs->integer 0))
	   ((exact-negative? y)
	    (let ((n (exact* (r5rs->integer -2) 
			     (exact-numerator x)
			     (exact-denominator y)))
		  (d (exact* (exact-denominator x)
			     (exact- (exact-numerator y)))))
	      (if (exact<? n d)
		  (exact- (exact-quotient (exact- d n) (exact* 2 d)))
		  (exact-quotient (exact+ n d (r5rs->integer -1)) (exact* 2 d)))))))
	 (mod
	  (exact- x (exact* div y))))
    (values div mod)))

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

(define (exact-gcd/2 x y)
  (if (and (exact-integer? x) (exact-integer? y))
      (cond ((exact<? x (r5rs->integer 0)) (exact-gcd/2 (exact- x) y))
	    ((exact<? y (r5rs->integer 0)) (exact-gcd/2 x (exact- y)))
	    ((exact<? x y) (euclid y x))
	    (else (euclid x y)))
      (error "exgcd expects integral arguments" x y)))

(define (euclid x y)
  (if (exact-zero? y)
      x
      (euclid y (exact-remainder x y))))

(define (exact-lcm/2 x y)
  (let ((g (exact-gcd/2 x y)))
    (if (exact-zero? g)
	g
	(exact* (exact-quotient (exact-abs x) g)
		(exact-abs y)))))

(define (exact-gcd . args)
  (reduce (r5rs->integer 0) exact-gcd/2 args))

(define (exact-lcm . args)
  (reduce (r5rs->integer 1) exact-lcm/2 args))

(define-unary exact-numerator
  id id ratnum-numerator
  (make-typo-op/1 exact-numerator 'rational))

(define-unary exact-denominator
  one one ratnum-denominator
  (make-typo-op/1 exact-denominator 'rational))

;; floor is primitive
(define-unary exact-floor
  id id ratnum-floor
  (make-typo-op/1 exact-floor 'rational))

(define (exact-ceiling x)
  (exact- (exact-floor (exact- x))))

(define (exact-truncate x)
  (if (exact-negative? x)
      (exact-ceiling x)
      (exact-floor x)))

(define (exact-round x)
  (let* ((x+1/2 (exact+ x (r5rs->ratnum 1/2)))
	 (r (exact-floor x+1/2)))
    (if (and (exact=? r x+1/2)
	     (exact-odd? r))
	(exact- r (r5rs->integer 1))
	r)))

(define (exact-expt x y)

  (define (e x y)
    (cond ((exact-zero? y)
	   (r5rs->integer 1))
	  ((exact-odd? y)
	   (exact* x (e x (exact- y (r5rs->integer 1)))))
	  (else 
	   (let ((v (e x (exact-quotient y (r5rs->integer 2)))))
	     (exact* v v)))))

  (cond ((exact-zero? x)
	 (if (exact-zero? y)
	     (r5rs->integer 1)
	     (r5rs->integer 0)))
	((exact-integer? y)
	 (if (exact-negative? y)
	     (exact/ (exact-expt x (exact- y)))
	     (e x y)))
	(else
	 (error "exact-expt expects integer power" y))))

(define (exact-make-rectangular a b)
  (if (and (exact-rational? a)
	   (exact-rational? b))
      (rectangulate a b)
      (error "exact-make-rectangular: non-rational argument" a b)))

(define-unary exact-real-part id id id recnum-real) 
(define-unary exact-imag-part one one one recnum-imag)


