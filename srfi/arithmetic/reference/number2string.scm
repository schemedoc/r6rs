; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Converting numbers to strings

(define (number->string x . radix)
  (if (null? radix)
      (number2string x (r5rs->integer 10))
      (let ((radix (car radix)))
	(if (and (exact-integer? radix)
		 (integer< (r5rs->integer 1) radix)
		 (integer< radix (r5rs->integer 37)))
	    (number2string x radix)
	    (begin
	      (error "Bad radix" radix)
	      #t)))))

(define (number2string x radix)
  (cond ((fixnum? x)
	 (integer->string x radix))
	((bignum? x)
	 (bignum->string x radix))
	((flonum? x)
	 (flonum->string x radix))
	((compnum? x)
	 (compnum->string x radix))
	((ratnum? x)
	 (ratnum->string x radix))
	((recnum? x)
	 (recnum->string x radix))
	(else
	 (error "number->string: not a number: " x)
	 #t)))
