; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Generic inexact arithmetic

(define (innumber? obj)
  (or (flonum? obj)
      (compnum? obj)))

(define (incomplex? obj)
  (innumber? obj))

(define (inreal? obj)
  (flonum? obj))

(define (inrational? obj)
  (and (inreal? obj)
       (not (or (= obj flinf+)
		(= obj flinf-)
		(flnan? obj)))))

(define (ininteger? obj)
  (and (flonum? obj)
       (flinteger? obj)))

(define-syntax define-binary
  (syntax-rules ()
    ((define-binary ?name ?contagion ?flonum-op ?compnum-op)
     (define (?name a b)
       (cond
	((flonum? a)
	 (if (flonum? b)
	     (?flonum-op a b)
	     (?contagion a b ?name)))
	((compnum? a)
	 (if (compnum? b)
	     (?compnum-op a b)
	     (?contagion a b ?name)))
	(else
	 (?contagion a b ?name)))))))

(define-binary in=/2 econtagion/in
  fl= compnum=)

(define-binary in</2 pcontagion/in
  fl< (make-typo-op/2 in< 'real))
(define-binary in<=/2 pcontagion/in
  fl<= (make-typo-op/2 in<= 'real))
(define-binary in>=/2 pcontagion/in
  fl>= (make-typo-op/2 in>= 'real))
(define-binary in>/2 pcontagion/in
  fl> (make-typo-op/2 in> 'real))

(define in= (make-transitive-pred in=/2))
(define in< (make-transitive-pred in</2))
(define in<= (make-transitive-pred in<=/2))
(define in>= (make-transitive-pred in>=/2))
(define in> (make-transitive-pred in>=/2))

(define-syntax define-unary
  (syntax-rules ()
    ((define-unary ?name ?flonum-op ?compnum-op)
     (define (?name a)
       (cond
	((flonum? a)
	 (?flonum-op a))
	((compnum? a)
	 (?compnum-op a))
	(else
	 (error "expects an inexact argument" ?name a)))))))

(define-unary inzero? flzero? compnum-zero?) ; #### compnum case?
(define-unary inpositive? flpositive?
  (make-typo-op/1 inpositive? 'real))
(define-unary innegative? innegative?
  (make-typo-op/1 innegative? 'real))
(define-unary inodd? flodd?
  (make-typo-op/1 inodd? 'real))
(define-unary ineven? fleven?
  (make-typo-op/1 ineven? 'real))

(define inmin (make-min/max in<))
(define inmax (make-min/max in>))

(define-binary in+/2 contagion/in fl+ compnum+)
(define-binary in-/2 contagion/in fl- compnum-)
(define-binary in*/2 contagion/in fl* compnum*)
(define-binary in//2 contagion/in fl/ compnum/)

(define (in+ . args)
  (reduce (r5rs->flonum 0.0) in+/2 args))
(define (in- arg0 . args)
  (reduce (r5rs->flonum 0.0) in-/2 (cons arg0 args)))
(define (in* . args)
  (reduce (r5rs->flonum 1.0) in*/2 args))
(define (in/ arg0 . args)
  (reduce (r5rs->flonum 1.0) in//2 (cons arg0 args)))

(define-unary inabs flabs (make-typo-op/1 inabs 'real))

(define-binary inquotient contagion/in
  flquotient
  (make-typo-op/2 inquotient 'real))
  
(define-binary inremainder contagion/in
  flremainder
  (make-typo-op/2 inremainder 'real))

(define-binary inquotient+remainder contagion/in
  inquotient+remainder
  (make-typo-op/2 inquotient+remainder 'real))

; from Scheme 48

(define (inmodulo x y)
  (if (and (ininteger? x) (ininteger? y))
      (let* ((q (inquotient x y))
	     (r (in- x (in* q y))))
	(cond ((inzero? r)
	       r)
	      ((innegative? r)
	       (if (innegative? y)
		   r
		   (in+ r y)))
	      ((innegative? y)
	       (in+ r y))
	      (else
	       r)))
      (error "inmodulo expects integral arguments" x y)))

; from "Cleaning up the Tower"

(define (indiv+mod x y)
  (let* ((div
	  (cond
	   ((inpositive? y)
	    (let ((n (in* (innumerator x)
			  (indenominator y)))
		  (d (in* (indenominator x)
			  (innumerator y))))
	      (if (innegative? n)
		  (in- (inquotient (in- (in- d n) (r5rs->flonum 1)) d))
		  (inquotient n d))))
	   ((inzero? y)
	    (r5rs->flonum 0))
	   ((innegative? y)
	    (let ((n (in* (r5rs->flonum -2) 
			  (innumerator x)
			  (indenominator y)))
		  (d (in* (indenominator x)
			  (in- (innumerator y)))))
	      (if (in< n d)
		  (in- (inquotient (in- d n) (in* 2 d)))
		  (inquotient (in+ n d (r5rs->flonum -1)) (in* 2 d)))))))
	 (mod
	  (in- x (in* div y))))
    (values div mod)))

(define (indiv x y)
  (call-with-values
      (lambda () (indiv+mod x y))
    (lambda (d m)
      d)))

(define (inmod x y)
  (call-with-values
      (lambda () (indiv+mod x y))
    (lambda (d m)
      m)))

(define (ingcd/2 x y)
  (if (and (ininteger? x) (ininteger? y))
      (cond ((in< x (r5rs->flonum 0.0)) (ingcd/2 (in- x) y))
	    ((in< y (r5rs->flonum 0.0)) (ingcd/2 x (in- y)))
	    ((in< x y) (euclid y x))
	    (else (euclid x y)))
      (error "ingcd inpects integral arguments" x y)))

(define (euclid x y)
  (if (inzero? y)
      x
      (euclid y (inremainder x y))))

(define (inlcm/2 x y)
  (let ((g (ingcd/2 x y)))
    (if (inzero? g)
	g
	(in* (inquotient (inabs x) g)
	     (inabs y)))))

(define (ingcd . args)
  (reduce (r5rs->flonum 0.0) ingcd/2 args))

(define (inlcm . args)
  (reduce (r5rs->flonum 1.0) inlcm/2 args))

(define (flnumerator x)
  (integer->flonum (rational-numerator (flonum->rational x))))
(define (fldenominator x)
  (integer->flonum (rational-denominator (flonum->rational x))))

(define-unary innumerator
  flnumerator
  (make-typo-op/1 innumerator 'real))

(define-unary indenominator
  fldenominator
  (make-typo-op/1 indenominator 'real))

;; floor is primitive
(define-unary infloor
  flfloor
  (make-typo-op/1 infloor 'real))

(define (inceiling x)
  (in- (infloor (in- x))))

(define (intruncate x)
  (if (innegative? x)
      (inceiling x)
      (infloor x)))

(define (inround x)
  (let* ((x+1/2 (in+ x (r5rs->flonum 0.5)))
	 (r (infloor x+1/2)))
    (if (and (in= r x+1/2)
	     (inodd? r))
	(in- r (r5rs->flonum 1.0))
	r)))

(define-unary inexp flexp compnum-exp)
(define-unary insin flsin compnum-sin)
(define-unary incos flcos compnum-cos)
(define-unary intan fltan compnum-tan)
(define-unary inasin flasin compnum-asin)
(define-unary inacos flacos compnum-acos)
(define-unary inatan1 flatan1 compnum-atan1)

; from Larceny

(define (inlog z)
  (cond ((and (flonum? z) (flpositive? z))
	 (fllog z))
	((or (compnum? z) (innegative? z))
	 (in+ (inlog (inmagnitude z)) (in* (r5rs->compnum +1.0i) (inangle z))))
	(else
	 (fllog z))))

; Square root
; Formula for complex square root from CLtL2, p310.

(define (insqrt z)
  (cond ((and (flonum? z) (not (flnegative? z)))
	 (flsqrt z))
	((compnum? z)
	 (inexp (in/ (inlog z) (r5rs->flonum 2.0))))
	((innegative? z)
	 (inmake-rectangular (r5rs->flonum 0.0) (insqrt (in- z))))
	(else
	 (flsqrt z))))

(define (inatan z . rest)
  (if (null? rest)
      (inatan1 z)
      (let ((x z)
	    (y (car rest)))
	(cond ((and (flonum? x) (flonum? y))
	       (flatan2 x y))
	      ((not (and (flonum? x) (flonum? y)))
	       (error "ATAN: domain error: " x y)
	       #t)
	      (else
	       (flatan2 x y))))))

(define (inexpt x y)

  (define (e x y)
    (cond ((inzero? y)
	   (r5rs->flonum 1.0))
	  ((inodd? y)
	   (in* x (e x (in- y (r5rs->flonum 1.0)))))
	  (else 
	   (let ((v (e x (inquotient y (r5rs->flonum 2.0)))))
	     (in* v v)))))

  (cond ((inzero? x)
	 (if (inzero? y)
	     (r5rs->flonum 1.0)
	     (r5rs->flonum 0.0)))
	((ininteger? y)
	 (if (innegative? y)
	     (in/ (inexpt x (in- y)))
	     (e x y)))
	(else
	 (inexp (in* y (inlog x))))))


(define (inmake-rectangular a b)
  (if (and (flonum? a)
	   (flonum? b))
      (make-compnum a b)
      (error "inmake-rectangular: non-real argument" a b)))

; from Larceny

(define (inmake-polar a b)
  (if (not (and (flonum? a) (flonum? b)))
      (begin
	(error "make-polar: invalid arguments" a b)
	#t)
      (inmake-rectangular (in* a (incos b)) (in* a (insin b)))))

(define (inreal-part z)
  (cond
   ((compnum? z) (compnum-real z))
   ((flonum? z) z)
   (else
    (error "inreal-part: invalid argument" z))))

(define (inimag-part z)
  (cond
   ((compnum? z) (compnum-real z))
   ((flonum? z) (r5rs->flonum 0.0))
   (else
    (error "inimag-part: invalid argument" z))))

(define (inangle c)
  (inatan (inimag-part c) (inreal-part c)))

; NOTE: CLtL2 notes that this implementation may not be ideal for very
;       large or very small numbers.

(define (inmagnitude c)
  (let ((r (inreal-part c))
	(i (inimag-part c)))
    (insqrt (in+ (in* r r) (in* i i)))))

; end from Larceny


