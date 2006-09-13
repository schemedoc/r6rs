; Synonyms for all R5RS arithmetic operations that might be used
; by the reference implementation.

(define r5rs:eqv? eqv?)
(define r5rs:number? number?)
(define r5rs:complex? complex?)
(define r5rs:real? real?)
(define r5rs:rational? rational?)
(define r5rs:integer? integer?)

(define r5rs:exact? exact?)
(define r5rs:inexact? inexact?)

(define r5rs:= =)
(define r5rs:< <)
(define r5rs:> >)
(define r5rs:<= <=)
(define r5rs:>= >=)

(define r5rs:zero? zero?)
(define r5rs:positive? positive?)
(define r5rs:negative? negative?)
(define r5rs:odd? odd?)
(define r5rs:even? even?)

(define r5rs:max max)
(define r5rs:min min)

(define r5rs:+ +)
(define r5rs:* *)
(define r5rs:- -)
(define r5rs:/ /)

(define r5rs:abs abs)

(define r5rs:quotient quotient)
(define r5rs:remainder remainder)
(define r5rs:modulo modulo)

(define r5rs:gcd gcd)
(define r5rs:lcm lcm)

(define r5rs:numerator numerator)
(define r5rs:denominator denominator)

(define r5rs:floor floor)
(define r5rs:ceiling ceiling)
(define r5rs:truncate truncate)
(define r5rs:round round)

(define r5rs:rationalize rationalize)

(define r5rs:exp exp)
(define r5rs:log log)
(define r5rs:sin sin)
(define r5rs:cos cos)
(define r5rs:tan tan)
(define r5rs:asin asin)
(define r5rs:acos acos)
(define r5rs:atan atan)

(define r5rs:sqrt sqrt)
(define r5rs:expt expt)

(define r5rs:make-rectangular make-rectangular)
(define r5rs:make-polar make-polar)
(define r5rs:real-part real-part)
(define r5rs:imag-part imag-part)
(define r5rs:magnitude magnitude)
(define r5rs:angle angle)

(define r5rs:exact->inexact exact->inexact)
(define r5rs:inexact->exact inexact->exact)

(define r5rs:number->string number->string)
(define r5rs:string->number string->number)

