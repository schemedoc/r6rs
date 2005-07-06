; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Generic exact rational arithmetic

(define (exnumber? obj)
  (or (fixnum? obj)
      (bignum? obj)
      (ratnum? obj)
      (recnum? obj)))

(define (excomplex? obj)
  (exnumber? obj))

(define (exreal? obj)
  (or (fixnum? obj)
      (bignum? obj)
      (ratnum? obj)))

(define (exrational? obj)
  (exreal? obj))

(define (exinteger? obj)
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

(define-binary ex=/2 econtagion/ex
  fx= bignum= ratnum= recnum=)

(define-binary ex</2 pcontagion/ex
  fx< bignum< ratnum< (make-typo-op/2 ex< 'rational))
(define-binary ex<=/2 pcontagion/ex
  fx< bignum<= ratnum<= (make-typo-op/2 ex<= 'rational))
(define-binary ex>=/2 pcontagion/ex
  fx>= bignum>= ratnum>= (make-typo-op/2 ex>= 'rational))
(define-binary ex>/2 pcontagion/ex
  fx>= bignum> ratnum> (make-typo-op/2 ex> 'rational))

(define ex= (make-transitive-pred ex=/2))
(define ex< (make-transitive-pred ex</2))
(define ex<= (make-transitive-pred ex<=/2))
(define ex>= (make-transitive-pred ex>=/2))
(define ex> (make-transitive-pred ex>=/2))

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

(define-unary exzero? fxzero? bignum-zero? never never) 
(define-unary expositive? fxpositive? bignum-positive? ratnum-positive?
  (make-typo-op/1 expositive? 'rational))
(define-unary exnegative? fxnegative? bignum-negative? ratnum-negative?
  (make-typo-op/1 exnegative? 'rational))
(define-unary exodd? fxodd? bignum-odd?
  (make-typo-op/1 exodd? 'integer)
  (make-typo-op/1 exodd? 'integer))
(define-unary exeven? fxeven? bignum-even?
  (make-typo-op/1 exeven? 'integer)
  (make-typo-op/1 exeven? 'integer))

(define exmin (make-min/max ex<))
(define exmax (make-min/max ex>))

(define-binary ex+/2 contagion/ex
  bignum+ ratnum+ recnum+)
(define-binary ex-/2 contagion/ex
  bignum- ratnum- recnum-)
(define-binary ex*/2 contagion/ex
  bignum* ratnum* recnum*)
(define-binary ex//2 contagion/ex
  integer/ integer/ ratnum/ recnum/)

(define (ex+ . args)
  (reduce (r5rs->integer 0) ex+/2 args))
(define (ex- arg0 . args)
  (reduce (r5rs->integer 0) ex-/2 (cons arg0 args)))
(define (ex* . args)
  (reduce (r5rs->integer 1) ex*/2 args))
(define (ex/ arg0 . args)
  (reduce (r5rs->integer 1) ex//2 (cons arg0 args)))

(define-unary exabs
  fxabs bignum-abs ratnum-abs
  (make-typo-op/1 exabs 'rational))

(define-binary exquotient contagion/ex
  fxquotient
  bignum-quotient
  (make-typo-op/2 exquotient 'integer)
  (make-typo-op/2 exquotient 'integer))
  
(define-binary exremainder contagion/ex
  fxremainder
  bignum-remainder
  (make-typo-op/2 exremainder 'integer)
  (make-typo-op/2 exremainder 'integer))

(define-binary exquotient+remainder contagion/ex
  fxquotient+remainder
  bignum-quotient+remainder
  (make-typo-op/2 exquotient+remainder 'integer)
  (make-typo-op/2 exquotient+remainder 'integer))

(define (exmodulo x y)
  (if (and (exinteger? x) (exinteger? y))
      (let* ((q (exquotient x y))
	     (r (ex- x (ex* q y))))
	(cond ((exzero? r)
	       r)
	      ((exnegative? r)
	       (if (exnegative? y)
		   r
		   (ex+ r y)))
	      ((exnegative? y)
	       (ex+ r y))
	      (else
	       r)))
      (error "ex-modulo expects integral arguments" x y)))

(define (exdiv+mod x y)
  (let* ((div
	  (cond
	   ((expositive? y)
	    (let ((n (ex* (exnumerator x)
			  (exdenominator y)))
		  (d (ex* (exdenominator x)
			  (exnumerator y))))
	      (if (exnegative? n)
		  (ex- (exquotient (ex- (ex- d n) (r5rs->integer 1)) d))
		  (exquotient n d))))
	   ((exzero? y)
	    (r5rs->integer 0))
	   ((exnegative? y)
	    (let ((n (ex* (r5rs->integer -2) 
			  (exnumerator x)
			  (exdenominator y)))
		  (d (ex* (exdenominator x)
			  (ex- (exnumerator y)))))
	      (if (ex< n d)
		  (ex- (exquotient (ex- d n) (ex* 2 d)))
		  (exquotient (ex+ n d (r5rs->integer -1)) (ex* 2 d)))))))
	 (mod
	  (ex- x (ex* div y))))
    (values div mod)))

(define (exdiv x y)
  (call-with-values
      (lambda () (exdiv+mod x y))
    (lambda (d m)
      d)))

(define (exmod x y)
  (call-with-values
      (lambda () (exdiv+mod x y))
    (lambda (d m)
      m)))

(define (exgcd/2 x y)
  (if (and (exinteger? x) (exinteger? y))
      (cond ((ex< x (r5rs->integer 0)) (exgcd/2 (ex- x) y))
	    ((ex< y (r5rs->integer 0)) (exgcd/2 x (ex- y)))
	    ((ex< x y) (euclid y x))
	    (else (euclid x y)))
      (error "exgcd expects integral arguments" x y)))

(define (euclid x y)
  (if (exzero? y)
      x
      (euclid y (exremainder x y))))

(define (exlcm/2 x y)
  (let ((g (exgcd/2 x y)))
    (if (exzero? g)
	g
	(ex* (exquotient (exabs x) g)
	     (exabs y)))))

(define (exgcd . args)
  (reduce (r5rs->integer 0) exgcd/2 args))

(define (exlcm . args)
  (reduce (r5rs->integer 1) exlcm/2 args))

(define-unary exnumerator
  id id ratnum-numerator
  (make-typo-op/1 exnumerator 'rational))

(define-unary exdenominator
  one one ratnum-denominator
  (make-typo-op/1 exdenominator 'rational))

;; floor is primitive
(define-unary exfloor
  id id ratnum-floor
  (make-typo-op/1 exfloor 'rational))

(define (exceiling x)
  (ex- (exfloor (ex- x))))

(define (extruncate x)
  (if (exnegative? x)
      (exceiling x)
      (exfloor x)))

(define (exround x)
  (let* ((x+1/2 (ex+ x (r5rs->ratnum 1/2)))
	 (r (exfloor x+1/2)))
    (if (and (ex= r x+1/2)
	     (exodd? r))
	(ex- r (r5rs->integer 1))
	r)))

(define (exexpt x y)

  (define (e x y)
    (cond ((exzero? y)
	   (r5rs->integer 1))
	  ((exodd? y)
	   (ex* x (e x (ex- y (r5rs->integer 1)))))
	  (else 
	   (let ((v (e x (exquotient y (r5rs->integer 2)))))
	     (ex* v v)))))

  (cond ((exzero? x)
	 (if (exzero? y)
	     (r5rs->integer 1)
	     (r5rs->integer 0)))
	((exinteger? y)
	 (if (exnegative? y)
	     (ex/ (exexpt x (ex- y)))
	     (e x y)))
	(else
	 (error "exexpt expects integer power" y))))

(define (exmake-rectangular a b)
  (if (and (exrational? a)
	   (exrational? b))
      (rectangulate a b)
      (error "exmake-rectangular: non-rational argument" a b)))

(define-unary exreal-part id id id recnum-real) 
(define-unary eximag-part one one one recnum-imag)

(define-unary exbitwise-not fxbitwise-not bignum-bitwise-not
  (make-typo-op/1 exbitwise-not 'integer)
  (make-typo-op/1 exbitwise-not 'integer))

(define-binary exbitwise-ior/2 fxbitwise-ior bignum-bitwise-ior
  (make-typo-op/2 exbitwise-ior/2 'integer)
  (make-typo-op/2 exbitwise-ior/2 'integer))

(define-binary exbitwise-xor/2 fxbitwise-xor bignum-bitwise-xor
  (make-typo-op/2 exbitwise-xor/2 'integer)
  (make-typo-op/2 exbitwise-xor/2 'integer))

(define-binary exbitwise-and/2 fxbitwise-and bignum-bitwise-and
  (make-typo-op/2 exbitwise-and/2 'integer)
  (make-typo-op/2 exbitwise-and/2 'integer))

(define (exbitwise-ior . args)
  (reduce (r5rs->integer 0) exbitwise-ior/2 args))
(define (exbitwise-and . args)
  (reduce (r5rs->integer 1) exbitwise-and/2 args))
(define (exbitwise-xor . args)
  (reduce (r5rs->integer 1) exbitwise-xor/2 args))

(define (exarithmetic-shift a b)

  (define (fail)
    (error "exarithmetic-shift expects exact integer arguments" a b))

  (cond
   ((fixnum? a)
    (cond
     ((fixnum? b)
      (bignum-arithmetic-shift (fixnum->bignum a) (fixnum->bignum b)))
     ((bignum? b)
      (bignum-arithmetic-shift (fixnum->bignum a) b))
     (else (fail))))
   ((bignum? a)
    (cond
     ((fixnum? b)
      (bignum-arithmetic-shift a (fixnum->bignum b)))
     ((bignum? b)
      (bignum-arithmetic-shift a (fixnum->bignum b)))
     (else (fail))))))

