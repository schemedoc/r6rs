; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Package definitions for running the implementation in Scheme 48

(define scheme-sans-arithmetic
  (modify scheme
	  (hide number? complex? real? rational? integer?
		exact? inexact?
		zero? positive? negative? odd? even?
		max min
		+ * - /
		= < <= >= >
		abs
		quotient remainder modulo
		gcd lcm
		numerator denominator
		floor ceiling truncate round
		rationalize
		exp log sin cos tan asin acos atan
		sqrt expt
		make-rectangular make-polar
		real-part imag-part
		magnitude angle
		exact->inexact inexact->exact
		number->string string->number)))

(define-interface fixnums-interface
  (export fx ; temporary
	  fx+ fx- fx~ fx*
	  fixnum?
	  fxquotient fxremainder fxmodulo
	  fxquotient+remainder
	  fxdiv+mod fxdiv fxmod
	  fx= fx>= fx<= fx> fx<
	  fxzero? fxpositive? fxnegative? fxeven? fxodd?
	  fxmin fxmax fxabs
	  fxgcd fxlcm
	  fxbitwise-not
	  fxbitwise-and fxbitwise-ior fxbitwise-xor
	  fxarithmetic-shift
	  fixnum-width least-fixnum greatest-fixnum))

(define-structures ((fixnums fixnums-interface)
		    (fixnums-r5rs (export r5rs->fixnum
					      fixnum->r5rs)))
  (open scheme
	bitwise
	srfi-9 ; define-record-type
	(subset define-record-types (define-record-discloser)))
  (files fixnum))

(define-interface flonums-interface
  (export flonum?
	  fl+ fl- fl* fl/ fl= fl>= fl<= fl> fl<
	  flzero? flpositive? flnegative?
	  flmin flmax flabs
	  flexp fllog
	  flsin flcos fltan flasin flacos flatan1 flatan2
	  flsqrt flexpt
	  flfloor flceiling fltruncate flround
	  flinteger? 
	  flquotient flremainder flquotient+remainder
	  fldiv+mod fldiv flmod
	  flodd? fleven?
	  flonum->fixnum fixnum->flonum
	  flinf+ flinf- flnan
	  flinf+? flinf-? flnan?))

(define-structures ((flonums flonums-interface)
		    (flonums-r5rs (export r5rs->flonum flonum->r5rs)))
  (open scheme
	srfi-9 ; define-record-type
	(subset define-record-types (define-record-discloser))
	fixnums fixnums-r5rs)
  (files flonum))

(define-interface bignums-interface
  (export bignum->integer
	  fixnum->bignum
	  bignum?
	  bignum+ bignum- bignum*
	  bignum-divide
	  bignum-quotient bignum-remainder bignum-quotient+remainder
	  bignum-negate
	  bignum=
	  bignum< bignum<= bignum>= bignum>
	  bignum-positive? bignum-negative?
	  bignum-abs
	  bignum-min bignum-max
	  bignum-even? bignum-odd?
	  bignum-zero?
	  bignum->string

	  bignum-bitwise-not
	  bignum-bitwise-ior bignum-bitwise-xor bignum-bitwise-and
	  bignum-arithmetic-shift))

(define-structures ((bignums bignums-interface)
		    (bignums-r5rs (export bignum->r5rs r5rs->bignum)))
  (open scheme-sans-arithmetic
	(modify scheme (prefix r5rs:) (expose >= = - remainder quotient * +))
  	srfi-9 ; define-record-type
	(subset define-record-types (define-record-discloser))
	srfi-23 ; ERROR
	fixnums
	fixnums-r5rs)
  (files bignum
	 bigbit))

(define-interface integers-interface
  (export exact-integer?
	  integer+
	  integer-
	  integer*
	  integer-quotient integer-remainder integer-quotient+remainder
	  integer-negate
	  integer=
	  integer<

	  integer-gcd integer-lcm
	  integer-zero? integer-expt integer-even? integer-odd?
	  integer> integer>= integer<=
	  integer-positive? integer-negative?
	  integer-min integer-abs integer-max
	  integer->string

	  integer->bignum

	  integer-bitwise-not
	  integer-bitwise-ior integer-bitwise-xor integer-bitwise-and
	  integer-arithmetic-shift))

(define-structures ((integers integers-interface)
		    (integers-r5rs (export integer->r5rs r5rs->integer )))
  (open scheme-sans-arithmetic
	(modify scheme (prefix r5rs:) (expose >= <=))
	fixnums fixnums-r5rs
	bignums bignums-r5rs)
  (files integer))

(define-interface flonums-ieee-interface
  (export flsign flsignificand flexponent
	  fl-ieee-min-exponent fl-ieee-min-exponent/denormalized
	  fl-ieee-max-exponent
	  fl-ieee-mantissa-width))

(define-structure flonums-ieee flonums-ieee-interface
  (open scheme
	flonums-r5rs
	integers-r5rs)
  (files flonum-ieee))

(define-interface ratnums-interface
  (export make-unreduced-ratnum
	  integer/
	  ratnum?
	  ratnum-numerator ratnum-denominator
	  ratnum* ratnum/ ratnum+ ratnum-
	  ratnum< ratnum<= ratnum>= ratnum>
	  ratnum=
	  ratnum-positive? ratnum-negative?
	  ratnum-abs
	  ratnum-min ratnum-max
	  ratnum-truncate ratnum-floor
	  ratnum->string))

(define-structures ((ratnums ratnums-interface)
		    (ratnums-r5rs (export r5rs->ratnum)))
  (open scheme-sans-arithmetic
	(modify scheme (prefix r5rs:) (expose numerator denominator))
	srfi-9				; define-record-types
	(subset define-record-types (define-record-discloser))
	srfi-23				; ERROR
	integers integers-r5rs
	)
  (files ratnum))

(define-interface rationals-interface
  (export exact-rational?
	  rational-numerator rational-denominator
	  rational* rational/ rational+ rational-
	  rational< rational=
	  rational-positive? rational-negative?
	  rational-truncate rational-floor
	  rational->string))

(define-structure rationals rationals-interface
  (open scheme-sans-arithmetic
	integers integers-r5rs
	ratnums
	srfi-23 ; ERROR
	)
  (files rational))

(define-interface compnums-interface
  (export compnum ; temporary
	  compnum?
	  make-compnum
	  make-compnum-polar
	  compnum-real compnum-imag
	  compnum+ compnum- compnum* compnum/
	  compnum= compnum-zero?
	  compnum-angle compnum-magnitude
	  compnum-exp compnum-log compnum-sqrt
	  compnum-sin compnum-cos compnum-tan
	  compnum-asin compnum-acos compnum-atan1
	  compnum->string))

(define-structures ((compnums compnums-interface)
		    (compnums-r5rs (export r5rs->compnum)))
  (open scheme-sans-arithmetic
	(modify scheme (prefix r5rs:) (expose real-part imag-part))
	srfi-9 ; define-record-types
	(subset define-record-types (define-record-discloser))
	flonums flonums-r5rs
	flonums-to-strings)
  (files compnum))

(define-interface recnums-interface
  (export make-recnum
	  recnum?
	  rectangulate ; temporary
	  recnum-real recnum-imag
	  recnum+ recnum- recnum* recnum/
	  recnum=
	  recnum->string))

(define-structures ((recnums recnums-interface)
		    (recnums-r5rs (export r5rs->recnum)))
  (open scheme-sans-arithmetic
	(modify scheme (prefix r5rs:) (expose real-part imag-part))
	srfi-9 ; define-record-types
	(subset define-record-types (define-record-discloser))
	rationals 
	integers-r5rs
	)
  (files recnum))

(define-interface rationals-to-flonums-interface
  (export rational->flonum
	  integer->flonum))

(define-structure rationals-to-flonums rationals-to-flonums-interface
  (open scheme-sans-arithmetic
	fixnums
	integers integers-r5rs
	ratnums rationals
	flonums flonums-r5rs
	srfi-23)
  (files rational2flonum))

(define-interface flonums-to-rationals-interface
  (export flonum->rational
	  flonum->integer))

(define-structure flonums-to-rationals flonums-to-rationals-interface
  (open scheme-sans-arithmetic
	fixnums
	integers integers-r5rs
	ratnums
	flonums flonums-ieee
	rationals
	rationals-to-flonums
	srfi-23)
  (files flonum2rational))

(define-structure bellerophon (export bellerophon)
  (open scheme-sans-arithmetic
	integers integers-r5rs
	flonums flonums-r5rs
	flonums-ieee
	rationals-to-flonums flonums-to-rationals
	srfi-23)
  (files bellerophon))

(define-structure flonums-to-strings (export flonum->string)
  (open scheme-sans-arithmetic
	integers integers-r5rs
	flonums flonums-r5rs
	flonums-ieee
	flonums-to-rationals)
  (files flonum2string))

(define-structure numbers-to-strings (export number->string)
  (open scheme-sans-arithmetic
	fixnums bignums flonums compnums ratnums recnums
	integers integers-r5rs
	flonums-to-strings
	srfi-23 ; error
	)
  (files number2string))

(define-structure r5rs-to-numbers (export r5rs->number)
  (open scheme
	integers-r5rs
	flonums-r5rs
	recnums-r5rs
	compnums-r5rs
	ratnums-r5rs)
  (files r5rs2number))

(define-interface contagion-utils-interface
  (export fixnum->ratnum fixnum->recnum fixnum->compnum
	  bignum->ratnum bignum->recnum bignum->compnum 
	  ratnum->recnum ratnum->flonum ratnum->compnum 
	  recnum->compnum 
	  flonum->compnum
	  compnum->bignum
	  compnum->integer
	  flonum->recnum
	  flonum->bignum
	  bignum->flonum
	  compnum->recnum
	  exact-integer?
	  compnum-float?
	  recnum-integral?
	  compnum-integral?
	  id
	  do-contagion
	  make-contagion-matrix
	  (define-contagion :syntax)
	  (numtype-enum :syntax)
	  ))

(define-structure contagion-utils contagion-utils-interface
  (open scheme-sans-arithmetic
	fixnums
	bignums
	ratnums
	recnums
	flonums
	compnums
	rationals-to-flonums flonums-to-rationals
	integers integers-r5rs
	flonums-r5rs
	srfi-23 ; error
	)
  (files coercion
	 contagion))

(define-structure strings-to-numbers (export string->number)
  (open scheme-sans-arithmetic
	fixnums bignums ratnums flonums flonums-r5rs
	recnums recnums-r5rs
	compnums
	integers integers-r5rs
	rationals
	bellerophon
	contagion-utils
	rationals-to-flonums flonums-to-rationals
	srfi-23 ; error
	)
  (files string2number))

(define-interface arithmetic-utils-interface
  (export make-transitive-pred
	  make-typo-op/2 make-typo-op/1
	  make-min/max
	  reduce
	  never id one one/flo))

(define-structure arithmetic-utils arithmetic-utils-interface
  (open scheme-sans-arithmetic
	integers-r5rs
	flonums-r5rs
	srfi-23 ; error
	)
  (files arithmetic-util))

(define-interface generic-arithmetic/ex-interface
  (export exnumber? excomplex? exrational? exinteger?
	  ex= ex< ex<= ex>= ex>
	  exzero? expositive? exnegative?
	  exodd? exeven?
	  exmin exmax
	  ex+ ex- ex* ex/
	  exabs
	  exquotient exremainder exquotient+remainder
	  exdiv exmod exdiv+mod
	  exmodulo
	  exgcd exlcm
	  exnumerator exdenominator
	  exfloor exceiling extruncate exround
	  exmake-rectangular
	  exremainder eximag-part
	  exexpt))

(define-structure generic-arithmetic/ex generic-arithmetic/ex-interface
  (open scheme-sans-arithmetic
	integers-r5rs
	fixnums
	bignums
	ratnums ratnums-r5rs
	recnums
	contagion-utils
	arithmetic-utils
	srfi-23 ; error
	)
  (files contagion-ex
	 generic-ex))

(define-interface generic-arithmetic/in-interface
  (export innumber? incomplex? inreal? inrational? ininteger?
	  in= in< in<= in>= in>
	  inzero? inpositive? innegative? innan?
	  inodd? ineven?
	  inmin inmax
	  in+ in- in* in/
	  inabs
	  inquotient inremainder inquotient+remainder
	  indiv+mod indiv inmod
	  inmodulo
	  ingcd inlcm
	  innumerator indenominator
	  infloor inceiling intruncate inround
	  inexp insqrt inlog
	  insin incos intan inasin inacos inatan
	  inmake-rectangular inmake-polar
	  inreal-part inimag-part
	  inmagnitude inangle
	  inexpt))

(define-structure generic-arithmetic/in generic-arithmetic/in-interface
  (open scheme-sans-arithmetic

	;; all this just to implement innumerator and indenominator:
	rationals-to-flonums flonums-to-rationals
	(subset rationals (rational-numerator rational-denominator))

	flonums flonums-r5rs
	compnums compnums-r5rs
	contagion-utils
	arithmetic-utils
	srfi-23 ; error
	)
  (files contagion-in
	 generic-in))

(define-structure generic-arithmetic/ex generic-arithmetic/ex-interface
  (open scheme-sans-arithmetic
	integers-r5rs
	fixnums
	bignums
	ratnums ratnums-r5rs
	recnums
	contagion-utils
	arithmetic-utils
	srfi-23 ; error
	)
  (files contagion-ex
	 generic-ex))

(define-interface generic-arithmetic/will-interface
  (export number? complex? real? rational? integer?
	  exact? inexact?
	  = < > <= >=
	  zero? positive? negative? odd? even? nan?
	  max min
	  + * - /
	  abs
	  quotient remainder quotient+remainder modulo
	  gcd lcm
	  numerator denominator
	  floor ceiling truncate round
	  exp log sin cos tan asin acos atan
	  sqrt expt
	  make-rectangular make-polar real-part imag-part magnitude angle
	  exact->inexact inexact->exact number->flonum
	  bitwise-not
	  bitwise-ior bitwise-and bitwise-xor
	  arithmetic-shift
	  rationalize))

(define-structure generic-arithmetic/will generic-arithmetic/will-interface
  (open scheme-sans-arithmetic
	integers-r5rs
	fixnums
	bignums
	ratnums ratnums-r5rs
	recnums
	flonums flonums-r5rs
	compnums compnums-r5rs
	rationals-to-flonums flonums-to-rationals
	contagion-utils
	arithmetic-utils
	srfi-23 ; error
	)
  (files contagion-will
	 generic-will))

(define-interface generic-arithmetic/mike-interface
  (export number? complex? real? rational? integer?
	  exact? inexact?
	  = < > <= >=
	  zero? positive? negative? odd? even?
	  max min
	  + * - /
	  abs
	  quotient remainder quotient+remainder modulo
	  gcd lcm
	  numerator denominator
	  floor ceiling truncate round
	  expt
	  make-rectangular real-part imag-part
	  exact->inexact inexact->exact number->flonum
	  bitwise-not
	  bitwise-ior bitwise-and bitwise-xor
	  arithmetic-shift
	  rationalize))

(define-structure generic-arithmetic/mike generic-arithmetic/mike-interface
  (open scheme-sans-arithmetic
	integers-r5rs
	fixnums
	bignums
	ratnums ratnums-r5rs
	recnums
	flonums flonums-r5rs
	compnums compnums-r5rs
	rationals-to-flonums flonums-to-rationals
	generic-arithmetic/in
	contagion-utils
	arithmetic-utils
	srfi-23 ; error
	)
  (files contagion-mike
	 generic-mike))

; Putting it all together

(define-structure r6rs/will (compound-interface (interface-of scheme-sans-arithmetic)
						fixnums-interface flonums-interface
						generic-arithmetic/ex-interface
						generic-arithmetic/in-interface
						generic-arithmetic/will-interface
						(interface-of strings-to-numbers)
						(interface-of numbers-to-strings)
						(interface-of r5rs-to-numbers))
  (open scheme-sans-arithmetic
	fixnums flonums
	generic-arithmetic/ex
	generic-arithmetic/in
	generic-arithmetic/will
	strings-to-numbers numbers-to-strings
	r5rs-to-numbers))

(define-structure r6rs/mike (compound-interface (interface-of scheme-sans-arithmetic)
						fixnums-interface flonums-interface
						generic-arithmetic/ex-interface
						generic-arithmetic/in-interface
						generic-arithmetic/mike-interface
						(interface-of strings-to-numbers)
						(interface-of numbers-to-strings)
						(interface-of r5rs-to-numbers))
  (open scheme-sans-arithmetic
	fixnums flonums
	generic-arithmetic/ex
	generic-arithmetic/in
	generic-arithmetic/mike
	strings-to-numbers numbers-to-strings
	r5rs-to-numbers))

; Test suites

(define-structure test-strings-to-numbers (export)
  (open scheme-sans-arithmetic
	(modify scheme (prefix r5rs:) (expose +))
	(subset generic-arithmetic/will (=))
	r5rs-to-numbers
	strings-to-numbers numbers-to-strings)
  (files test-prelude
	 test-string2number
	 test-postlude))

(define-structure test-generic-arithmetic/will (export)
  (open scheme-sans-arithmetic
	(modify scheme (prefix r5rs:) (expose +))
	(subset flonums (flinf+ flinf- flnan flnan?))
	r5rs-to-numbers
	strings-to-numbers
	generic-arithmetic/will)
  (files test-prelude
	 test-generic-arithmetic-will
	 test-postlude))

(define-structure test-generic-arithmetic/mike (export)
  (open scheme-sans-arithmetic
	(modify scheme (prefix r5rs:) (expose +))
	(subset flonums (flinf+ flinf- flnan flnan?))
	r5rs-to-numbers
	strings-to-numbers
	generic-arithmetic/mike)
  (files test-prelude
	 test-generic-arithmetic-mike
	 test-postlude))

(define-structure test-generic-arithmetic/ex (export)
  (open scheme-sans-arithmetic
	(modify scheme (prefix r5rs:) (expose +))
	r5rs-to-numbers
	strings-to-numbers
	generic-arithmetic/ex)
  (files test-prelude
	 test-generic-arithmetic-ex
	 test-postlude))

(define-structure test-generic-arithmetic/in (export)
  (open scheme-sans-arithmetic
	(modify scheme (prefix r5rs:) (expose +))
	(subset flonums (flinf+ flinf- flnan flnan?))
	r5rs-to-numbers
	strings-to-numbers
	generic-arithmetic/in)
  (files test-prelude
	 test-generic-arithmetic-in
	 test-postlude))
