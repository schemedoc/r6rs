; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Contagion for exact arithmetic as preferred by Mike

(define (oops a b retry)
  (error "INTERNAL ERROR in contagion: same-representation arithmetic"
         a b retry)
  #t)

; One matrix should do

(define cmatrix (make-contagion-matrix))

(define-contagion cmatrix fix fix fixnum->bignum fixnum->bignum)
(define-contagion cmatrix fix big fixnum->bignum id)
(define-contagion cmatrix fix rat fixnum->ratnum id)
(define-contagion cmatrix fix rec fixnum->recnum id)
(define-contagion cmatrix fix flo fixnum->ratnum flonum->rational)
(define-contagion cmatrix fix comp fixnum->recnum compnum->recnum)

(define-contagion cmatrix big big oops)
(define-contagion cmatrix big rat bignum->ratnum id)
(define-contagion cmatrix big rec bignum->recnum id)
(define-contagion cmatrix big flo bignum->ratnum flonum->rational)
(define-contagion cmatrix big comp bignum->recnum compnum->recnum)

(define-contagion cmatrix rat rat oops)
(define-contagion cmatrix rat rec ratnum->recnum id)
(define-contagion cmatrix rat flo id flonum->rational)
(define-contagion cmatrix rat comp ratnum->recnum compnum->recnum)

(define-contagion cmatrix rec rec oops)
(define-contagion cmatrix rec flo id flonum->recnum)
(define-contagion cmatrix rec comp id compnum->recnum)

(define-contagion cmatrix flo flo flonum->rational flonum->rational)
(define-contagion cmatrix flo comp flonum->recnum compnum->recnum)

(define-contagion cmatrix comp comp compnum->recnum)

(define contagion/mike (lambda (a b retry)
			 (do-contagion cmatrix a b retry)))

(define econtagion/mike (lambda (a b retry)
			  (do-contagion cmatrix a b retry)))

(define pcontagion/mike (lambda (a b retry)
			  (do-contagion cmatrix a b retry)))

