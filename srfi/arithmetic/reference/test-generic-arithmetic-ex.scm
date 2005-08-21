; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Tests for exact generic arithmetic

(define (n-r5rs= a b)
  (ex= a (r5rs->number b)))

(check (numerical excomplex? 3+4i) =>  #t)
(check (numerical excomplex? 3) =>  #t)
(check (numerical exrational? 6/10) =>  #t)
(check (numerical exrational? 6/3) =>  #t)
(check (exinteger? (numerical exmake-rectangular 3 0)) =>  #t)
(check (numerical exinteger? 3.0) =>  #f)
(check (numerical exinteger? 8/4) =>  #t)

(check (numerical ex<= 1 2 3 4) => #t)
(check (numerical ex< 1 2 7/2 4 9999999999999999999) => #t)
(check (numerical ex> 1 2 7/2 4 9999999999999999999) => #f)
(check (numerical ex>= 2 2 3/4 0) => #t)
(check (numerical ex= 0 -0) => #t)
(check (ex= (numerical exmake-rectangular 4 0) (r5rs->number 4)) => #t)
(check (ex= (numerical exmake-rectangular 4 0) 
	    (numerical exmake-rectangular 4 2)) => #f)
(check (ex= (numerical exmake-rectangular 4 2) 
	    (numerical exmake-rectangular 4 0)) => #f)
(check (ex= (numerical exmake-rectangular 4 2) (r5rs->number 4)) => #f)
(check (ex= (numerical exmake-rectangular #e1e40 0) (r5rs->number #e1e40)) => #t)

(check (numerical exzero? 3218943724243) => #f)
(check (numerical exzero? 0) => #t)
(check (exzero? (numerical exmake-rectangular 0 0)) => #t)

(check (numerical exodd? 5) => #t)
(check (numerical exodd? 9999999999989000000000001) => #t)
(check (numerical exodd? 9999999999989000000000000) => #f)
(check (numerical exeven? 5) => #f)
(check (numerical exeven? 9999999999989000000000001) => #f)
(check (numerical exeven? 9999999999989000000000000) => #t)

(check (numerical exabs 7) ==> 7)
(check (numerical exabs -7) ==> 7)
(check (numerical exabs 3/4) ==> 3/4)
(check (numerical exabs -3/4) ==> 3/4)

(check (numerical exmax 1 2 4 3 5) ==> 5)
(check (numerical exmax 1 2 3 5 4) ==> 5)
(check (numerical exmax 1 5 7/2 2 4) ==> 5)
(check (numerical exmin 4 1 2 3 5) ==> 1)
(check (numerical exmin 2 1 3 5 4) ==> 1)
(check (numerical exmin 1 5 7/2 2 4) ==> 1)

(check (numerical ex+ 3 4) ==> 7)
(check (numerical ex+ 3) ==> 3)
(check (numerical ex+) ==> 0)
(check (numerical ex+ 9999999999999 999999999999) ==> 10999999999998)
(check (numerical ex+ 1000 5) ==> 1005)
(check (numerical ex* 4) ==> 4)
(check (numerical ex*) ==> 1)
(check (numerical ex* 4 3000) ==> 12000)
(check (numerical ex* 9999999999999 999999999999) ==> 9999999999989000000000001)

(check (numerical ex- 3 4) ==> -1)
(check (numerical ex- 3 4 5) ==> -6)
(check (numerical ex- 3) ==> -3)
(check (numerical ex/ 3 4 5) ==> 3/20)
(check (numerical ex/ 3) ==> 1/3)
(check (numerical ex/ 1 2) ==> 1/2)

(check (numerical exgcd) ==> 0)
(check (numerical exlcm 32 -36) ==> 288)
(check (numerical exlcm) ==> 1)

(check (numerical exfloor #e-4.3) ==> -5)
(check (numerical exceiling #e-4.3) ==> -4)
(check (numerical extruncate #e-4.3) ==> -4)
(check (numerical exround #e-4.3) ==> -4)

(check (numerical exfloor #e3.5) ==> 3)
(check (numerical exceiling #e3.5) ==> 4)
(check (numerical extruncate #e3.5) ==> 3)

(check (numerical exround 7/2) ==> 4)
(check (numerical exround 7) ==> 7)

(check (numerical exexpt 5 3) ==>  125)
(check (numerical exexpt 3 123) ==> 48519278097689642681155855396759336072749841943521979872827)
(check (numerical exexpt 5 0) ==> 1)
(check (numerical exexpt 0 5) ==>  0)
(check (numerical exexpt 0 0) ==> 1)

(check (exnumerator (numerical ex/ 3 -4)) ==> -3)
(check (numerical exdenominator 0) ==> 1)

