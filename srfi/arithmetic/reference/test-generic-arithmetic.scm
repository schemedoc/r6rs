; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Tests for R5RS-style generic arithmetic

(check (numerical complex? 3+4i) => #t)
(check (numerical complex? 3) => #t)
(check (numerical real? 3) => #t)
(check (numerical real? -2.5+0i) => #t)
(check (real? (numerical make-rectangular -2.5 0.0)) => #f)
(check (real? (string->number "#e1e10")) => #t) ; Scheme 48 barfs on this literal
(check (numerical rational? 6/10) => #t)
(check (numerical rational? 6/3) => #t)
(check (numerical integer? 3+0i) => #t)
(check (integer? (numerical make-rectangular 3 0.0)) => #f)
(check (numerical integer? 3.0) => #t)
(check (numerical integer? 8/4) => #t)

(check (numerical <= 1 2 3 4) => #t)
(check (numerical < 1 2.0 7/2 4 9999999999999999999) => #t)
(check (numerical > 1 2.0 7/2 4 9999999999999999999) => #f)
(check (numerical >= 2.0 2 3/4 0) => #t)
(check (numerical = 0.0 -0.0) => #t)
(check (= (numerical make-rectangular 4.0 0) (r5rs->number 4.0)) => #t)
(check (= (numerical make-rectangular 4.0 0.0) (r5rs->number 4.0)) => #t)

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

(check (numerical + 3 4) ==> 7)
(check (numerical + 3) ==> 3)
(check (numerical +) ==> 0)
(check (numerical * 4) ==> 4)
(check (numerical *) ==> 1)

(check (numerical + 9999999999999 999999999999) ==> 10999999999998)
(check (numerical + 1000.0 5) ==> 1005.0)


(check (numerical - 3 4) ==> -1)
(check (numerical - 3 4 5) ==> -6)
(check (numerical - 3) ==> -3)
(check (numerical / 3 4 5) ==> 3/20)
(check (numerical / 3) ==> 1/3)

(check (numerical * 4.0 3000) ==> 12000.0)
(check (numerical * 9999999999999 999999999999) ==> 9999999999989000000000001)

(check (numerical gcd) ==> 0)
(check (numerical lcm 32 -36) ==> 288)
(check (numerical lcm 32.0 -36) ==> 288.0)
(check (numerical lcm) ==> 1)

(check (numerical exact->inexact 14285714285714285714285) ==> 1.4285714285714286e22)
