; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Tests for R5RS-style generic arithmetic

(define (n-r5rs= a b)
  (= a (r5rs->number b)))

(check (numerical complex? 3+4i) =>  #t)
(check (numerical complex? 3) =>  #t)
(check (numerical real? 3) =>  #t)
(check (real? (numerical make-rectangular -2.5 0.0)) =>  #f)
(check (real? (numerical make-rectangular -2.5 0)) =>  #t)
(check (numerical real? -2.5) =>  #t)
(check (real? (string->number "#e1e10")) =>  #t)
(check (real? (string->number "-inf.0")) =>  #t)
(check (real? (string->number "+nan.0")) =>  #t)
(check (rational? (string->number "-inf.0")) =>  #f)
(check (rational? (string->number "+nan.0")) =>  #f)
(check (numerical rational? 6/10) =>  #t)
(check (numerical rational? 6/3) =>  #t)
(check (integer? (numerical make-rectangular 3 0)) =>  #t)
(check (numerical integer? 3.0) =>  #t)
(check (numerical integer? 8/4) =>  #t)

(check (number? (string->number "+nan.0")) =>  #t)
(check (complex? (string->number "+nan.0")) =>  #t)
(check (complex? (string->number "+inf.0")) =>  #t)
(check (real? (string->number "+nan.0")) =>  #t)
(check (real? (string->number "-inf.0")) =>  #t)
(check (rational? (string->number "+inf.0")) =>  #f)
(check (rational? (string->number "+nan.0")) =>  #f)
(check (integer? (string->number "-inf.0")) =>  #f)


(check (numerical real-valued? 3) =>  #t)
(check (real-valued? (numerical make-rectangular -2.5 0.0)) =>  #t)
(check (real-valued? (numerical make-rectangular -2.5 0)) =>  #t)
(check (numerical real-valued? -2.5) =>  #t)
(check (real-valued? (string->number "#e1e10")) =>  #t)
(check (real-valued? (string->number "-inf.0")) =>  #t)
(check (real-valued? (string->number "+nan.0")) =>  #t)
(check (rational-valued? (string->number "-inf.0")) =>  #f)
(check (rational-valued? (string->number "+nan.0")) =>  #f)
(check (numerical rational-valued? 6/10) =>  #t)
(check (rational-valued? (numerical make-rectangular 6/10 0.0)) =>  #t)
(check (rational-valued? (numerical make-rectangular 6/10 0)) =>  #t)
(check (numerical rational-valued? 6/3) =>  #t)
(check (integer-valued? (numerical make-rectangular 3 0)) =>  #t)
(check (integer-valued? (numerical make-rectangular 3 0.0)) =>  #t)
(check (numerical integer-valued? 3.0) =>  #t)
(check (integer-valued? (numerical make-rectangular 3.0 0.0)) =>  #t)
(check (numerical integer-valued? 8/4) =>  #t)

(check (numerical <= 1 2 3 4) => #t)
(check (numerical < 1 2.0 7/2 4 9999999999999999999) => #t)
(check (numerical > 1 2.0 7/2 4 9999999999999999999) => #f)
(check (numerical >= 2.0 2 3/4 0) => #t)
(check (numerical = 0.0 -0.0) => #t)
(check (= (numerical make-rectangular 4.0 0) (r5rs->number 4.0)) => #t)
(check (= (numerical make-rectangular 4.0 0.0) (r5rs->number 4.0)) => #t)
(check (= (numerical make-rectangular 4.0 0.0) (r5rs->number 4)) => #t)
(check (= (numerical make-rectangular 4.0 0.0) 
	  (numerical make-rectangular 4 2)) => #f)
(check (= (numerical make-rectangular 4 2) 
	  (numerical make-rectangular 4.0 0.0)) => #f)
(check (= (numerical make-rectangular 4 2) (r5rs->number 4.0)) => #f)
(check (= (numerical make-rectangular 1e40 0.0) (r5rs->number 1e40)) => #t)

(check (numerical zero? 3218943724243) => #f)
(check (numerical zero? 0) => #t)
(check (numerical zero? 0.0) => #t)
(check (numerical zero? -0.0) => #t)
(check (zero? (numerical make-rectangular 0.0 0.0)) => #t)

(check (numerical odd? 5) => #t)
(check (numerical odd? 9999999999989000000000001) => #t)
(check (numerical odd? 9999999999989000000000000) => #f)
(check (numerical odd? 5.0) => #t)
(check (numerical even? 5) => #f)
(check (numerical even? 9999999999989000000000001) => #f)
(check (numerical even? 9999999999989000000000000) => #t)
(check (numerical even? 5.0) => #f)

(check (numerical abs 7) ==> 7)
(check (numerical abs -7) ==> 7)
(check (numerical abs 3/4) ==> 3/4)
(check (numerical abs -3/4) ==> 3/4)
(check (numerical abs 0.7) ==> 0.7)
(check (numerical abs -0.7) ==> 0.7)

(check (numerical max 1 2 4 3 5) ==> 5)
(check (numerical max 1 2.0 3 5 4) ==> 5)
(check (numerical max 1 5 7/2 2.0 4) ==> 5)
(check (numerical min 4 1 2 3 5) ==> 1)
(check (numerical min 2.0 1 3 5 4) ==> 1)
(check (numerical min 1 5 7/2 2.0 4) ==> 1)

(check (inexact? (numerical max 3.9 4)) => #t)

(check (numerical + 3 4) ==> 7)
(check (numerical + 3) ==> 3)
(check (numerical +) ==> 0)
(check (numerical + 9999999999999 999999999999) ==> 10999999999998)
(check (numerical + 1000.0 5) ==> 1005.0)
(check (numerical * 4) ==> 4)
(check (numerical *) ==> 1)
(check (numerical * 4.0 3000) ==> 12000.0)
(check (numerical * 9999999999999 999999999999) ==> 9999999999989000000000001)

(check (numerical - 3 4) ==> -1)
(check (numerical - 3 4 5) ==> -6)
(check (numerical - 3) ==> -3)
(check (numerical / 3 4 5) ==> 3/20)
(check (numerical / 3) ==> 1/3)
(check (numerical / 1.0 2.0) ==> 0.5)

(check (numerical gcd) ==> 0)
(check (numerical lcm 32 -36) ==> 288)
(check (numerical lcm 32.0 -36) ==> 288.0)
(check (numerical lcm) ==> 1)

(check (numerical floor -4.3) ==> -5.0)
(check (numerical ceiling -4.3) ==> -4.0)
(check (numerical truncate -4.3) ==> -4.0)
(check (numerical round -4.3) ==> -4.0)

(check (numerical floor 3.5) ==> 3.0)
(check (numerical ceiling 3.5) ==> 4.0)
(check (numerical truncate 3.5) ==> 3.0)
(check (inexact? (numerical round 3.5)) => #t)

(check (numerical round 7/2) ==> 4)
(check (exact? (numerical round 7/2)) => #t)
(check (numerical round 7) ==> 7)
(check (exact? (numerical round 7)) => #t)

(check (floor flinf+) => (=) flinf+)
(check (ceiling flinf-) => (=) flinf-)

(check (sqrt flinf+) => (=) flinf+)

(check (exp flinf+) => (=) flinf+)
(check (exp flinf-) ==> 0.0)
(check (log flinf+) => (=) flinf+)
(check (numerical log 0.0) => (=)  flinf-)
(check (atan flinf-) ==> -1.5707963267948965)
(check (atan flinf+) ==> 1.5707963267948965)

(check (numerical expt 5 3) ==>  125)
(check (numerical expt 5 -3) ==>  8.0e-3)
(check (numerical expt 5 0) ==> 1)
(check (numerical expt 0 5) ==>  0)
(check (numerical expt 0 5+.0000312i) ==>  0)
(check (numerical expt 0 0) ==> 1)
(check (numerical expt 0.0 0.0) ==>  1.0)

(check (numerator (numerical / 3 -4)) ==> -3)
(check (numerical denominator 0) ==> 1)

(check (rationalize (numerical inexact->exact 0.3) (r5rs->number 1/10)) ==> 1/3)
(check (numerical rationalize 0.3 1/10) ==> #i1/3)
(check (rationalize flinf+ (r5rs->number 3)) => (=) flinf+)
(check (flnan? (rationalize flinf+ flinf+)) => #t)
(check (rationalize (r5rs->number 3) flinf+) ==> 0)

(check (numerical infinite? 5) => #f)
(check (infinite? flinf+) => #t)
(check (infinite? flinf-) => #t)
(check (nan? (string->number "+nan.0")) => #t)
(check (infinite? (string->number "+nan.0")) => #f)
(check (finite? (string->number "+nan.0")) => #f)
(check (numerical nan? 5) => #f)
(check (numerical finite? 5) => #t)

(check (angle flinf+) ==> 0.0)
(check (angle flinf-) ==> 3.141592653589793)

(check (numerical sqrt -4) ==> +2i)

(check (numerical expt 0 0) ==> 1)

(check (numerical exact->inexact 14285714285714285714285) ==> 1.4285714285714286e22)

