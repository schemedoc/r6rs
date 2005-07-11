; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Tests for inexact arithmetic

(define (n-r5rs= a b)
  (in= a (r5rs->number b)))

(check (numerical incomplex? 3.0+4i) =>  #t)
(check (numerical incomplex? 3) =>  #f)
(check (numerical inreal? 3) =>  #f)
(check (inreal? (numerical inmake-rectangular -2.5 0.0)) =>  #f)
(check (numerical inreal? -2.5) =>  #t)
(check (inreal? (string->number "#e1e10")) =>  #f)
(check (inreal? (string->number "-inf.0")) =>  #t)
(check (inreal? (string->number "+nan.0")) =>  #t)
(check (inrational? (string->number "-inf.0")) =>  #f)
(check (inrational? (string->number "+nan.0")) =>  #f)
(check (numerical inrational? 6/10) =>  #f)
(check (numerical inrational? #i6/3) =>  #t)
(check (ininteger? (numerical inmake-rectangular 3.0 0.0)) =>  #f)
(check (numerical ininteger? 3.0) =>  #t)
(check (numerical ininteger? #i8/4) =>  #t)

(check (innumber? (string->number "+nan.0")) =>  #t)
(check (incomplex? (string->number "+nan.0")) =>  #t)
(check (incomplex? (string->number "+inf.0")) =>  #t)
(check (inreal? (string->number "+nan.0")) =>  #t)
(check (inreal? (string->number "-inf.0")) =>  #t)
(check (inrational? (string->number "+inf.0")) =>  #f)
(check (inrational? (string->number "+nan.0")) =>  #f)
(check (ininteger? (string->number "-inf.0")) =>  #f)

(check (numerical in<= 1.0 2.0 3.0 4.0) => #t)
(check (numerical in< 1.0 2.0 #i7/2 #i4 9999999999999999999.0) => #t)
(check (numerical in> 1.0 2.0 #i7/2 #i4 9999999999999999999.0) => #f)
(check (numerical in>= 2.0 2.0 #i3/4 0.0) => #t)
(check (numerical in= 0.0 -0.0) => #t)
(check (in= (numerical inmake-rectangular 4.0 0.0) (r5rs->number 4.0)) => #t)
(check (in= (numerical inmake-rectangular 4.0 0.0) 
	    (numerical inmake-rectangular 4.0 2.0)) => #f)
(check (in= (numerical inmake-rectangular 4.0 2.0) (r5rs->number 4.0)) => #f)
(check (in= (numerical inmake-rectangular 1e40 0.0) (r5rs->number 1e40)) => #t)

(check (numerical inzero? 3218943724243.0) => #f)
(check (numerical inzero? 0.0) => #t)
(check (numerical inzero? -0.0) => #t)
(check (inzero? (numerical inmake-rectangular 0.0 0.0)) => #t)

(check (numerical inodd? 5.0) => #t)
(check (numerical inodd? 5.0) => #t)
(check (numerical ineven? 5.0) => #f)
(check (numerical ineven? 5.0) => #f)
(check (numerical inodd? -5.0) => #t)
(check (numerical inodd? -5.0) => #t)
(check (numerical ineven? -5.0) => #f)
(check (numerical ineven? -5.0) => #f)

(check (numerical inabs 7.0) ==> 7.0)
(check (numerical inabs -7.0) ==> 7.0)
(check (numerical inabs 0.7) ==> 0.7)
(check (numerical inabs -0.7) ==> 0.7)

(check (numerical inmax 1.0 2.0 4.0 3.0 5.0) ==> 5.0)
(check (numerical inmax 1.0 2.0 3.0 5.0 4.0) ==> 5.0)
(check (numerical inmax 1.0 5.0 #i7/2 2.0 4.0) ==> 5.0)
(check (numerical inmin 4.0 1.0 2.0 3.0 5.0) ==> 1.0)
(check (numerical inmin 2.0 1.0 3.0 5.0 4.0) ==> 1.0)
(check (numerical inmin 1.0 5.0 #i7/2 2.0 4.0) ==> 1.0)

(check (numerical in+ 3.0 4.0) ==> 7.0)
(check (numerical in+ 3.0) ==> 3.0)
(check (numerical in+) ==> 0.0)
(check (numerical in+ 9999999999999.0 999999999999.0) ==> 10999999999998.0)
(check (numerical in+ 1000.0 5.0) ==> 1005.0)
(check (numerical in* 4.0) ==> 4.0)
(check (numerical in*) ==> 1.0)
(check (numerical in* 4.0 3000.0) ==> 12000.0)
(check (numerical in* 9999999999999.0 999999999999.0) ==> 9999999999989000000000001.0)

(check (numerical in- 3.0 4.0) ==> -1.0)
(check (numerical in- 3.0 4.0 5.0) ==> -6.0)
(check (numerical in- 3.0) ==> -3.0)
(check (numerical in/ 3.0 4.0 5.0) ==> #i3/20)
(check (numerical in/ 3.0) ==> #i1/3)
(check (numerical in/ 1.0 2.0) ==> 0.5)

(check (numerical ingcd) ==> 0.0)
(check (numerical inlcm 32.0 -36.0) ==> 288.0)
(check (numerical inlcm) ==> 1.0)

(check (numerical infloor -4.3) ==> -5.0)
(check (numerical inceiling -4.3) ==> -4.0)
(check (numerical intruncate -4.3) ==> -4.0)
(check (numerical inround -4.3) ==> -4.0)

(check (numerical infloor 3.5) ==> 3.0)
(check (numerical inceiling 3.5) ==> 4.0)
(check (numerical intruncate 3.5) ==> 3.0)
(check (numerical inround 7.0) ==> 7.0)

(check (infloor flinf+) => (in=) flinf+)
(check (inceiling flinf-) => (in=) flinf-)

(check (insqrt flinf+) => (in=) flinf+)

(check (inexp flinf+) => (in=) flinf+)
(check (inexp flinf-) ==> 0.0)
(check (inlog flinf+) => (in=) flinf+)
(check (numerical inlog 0.0) => (in=)  flinf-)
(check (inatan flinf-) ==> -1.5707963267948965)
(check (inatan flinf+) ==> 1.5707963267948965)

(check (numerical inexpt 5.0 3.0) ==>  125.0)
(check (numerical inexpt 5.0 -3.0) ==>  8.0e-3)
(check (numerical inexpt 5.0 0.0) ==> 1.0)
(check (numerical inexpt 0.0 5.0) ==>  0.0)
(check (numerical inexpt 0.0 5+.0000312i) ==>  0.0)
(check (numerical inexpt 0.0 0.0) ==>  1.0)

(check (innumerator (numerical in/ 3.0 -4.0)) ==> -3.0)
(check (numerical indenominator 0.0) ==> 1.0)

(check (inangle flinf+) ==> 0.0)
(check (inangle flinf-) ==> 3.141592653589793)

(check (numerical insqrt -4.0) ==> +2.0i)

