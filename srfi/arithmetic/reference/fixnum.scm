; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Fixnums in terms of R5RS

; Some of this code may not actually depend upon a two's complement
; range, but all of it depends upon the fixnum range being represented
; by exact integers in the underlying implementation.
;
; It should not depend upon any exact numbers that are outside
; the fixnum range.
;
; Hence all of this code must be written carefully to avoid
; intermediate results outside the fixnum range.
;
; Consider, for example, the definitions of *high* and *low*
; and the definitions of fixnum+/2 and fixnum*/2.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; The fixnum range is a half-open two's complement range.
;
; To use a smaller or larger range of fixnums, just change
; the following constant to some other positive even integer.
; It can't be too small, though, because the precision of bignums
; is likely to be about (* 1/4 *width* (expt 2 *width*)) bits.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define *width* 24)

(define *high*
  (let* ((i (r5rs:expt 2 (r5rs:- *width* 2)))
         (i-1 (r5rs:- i 1)))
    (r5rs:+ i i-1)))

(define *low*
  (r5rs:- (r5rs:- *high*) 1))

(define *half-width* (r5rs:quotient *width* 2))

(define *half-modulus* (r5rs:expt 2 *half-width*))

(define *half-high* (r5rs:- (r5rs:quotient *half-modulus* 2) 1))

(define *half-low* (r5rs:- (r5rs:quotient *half-modulus* 2)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Defining a fixnum as a record helps to catch certain kinds of
; errors but interferes with debugging.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(begin

; SRFI 9
;
; This defines :fixnum to be a record type with
;     really-make-fixnum -- a unary constructor of instances
;     fixnum? -- a predicate true only of instances
;     fixnum-rep -- an accessor for the representative field

(define-record-type :fixnum
  (really-make-fixnum representative)
  fixnum?
  (representative fixnum-rep))

(define fixnum->r5rs fixnum-rep)

; Scheme 48 extension; comment out if not available
; (For portability, the r5rs.sch file defines
; define-record-discloser as a stub.)

(define-record-discloser :fixnum
  (lambda (r)
    (list 'fixnum (fixnum-rep r))))

)

'
(begin
(define (really-make-fixnum x) x)
(define (fixnum? x)
  (and (r5rs:number? x)
       (r5rs:exact? x)
       (r5rs:integer? x)
       (r5rs:<= *low* x *high*)))
(define (fixnum-rep x)
  (if (fixnum? x) x (error "bad argument to fixnum-rep" x)))
(define fixnum->r5rs fixnum-rep)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Basic subprimitives, from which the basic primitives are defined.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (make-fixnum n)
  (if (r5rs:<= *low* n *high*)
      (really-make-fixnum n)
      (error "argument to make-fixnum is out of range" n)))

(define r5rs->fixnum make-fixnum)

; for playing around
(define fx make-fixnum)

; See "Cleaning up the Tower"
; This version of div has been cleaned up to match the
; semantics of fixnum-div in the current draft of SRFI 77.
; Note that it returns *low* when *low* is divided by -1.

(define (r5rs-fixnum-div x y)
  (if (not (and (r5rs:<= *low* x *high*)
                (r5rs:<= *low* y *high*)))
      (error "non-fixnum arguments to r5rs-fixnum-div" x y)
      (cond ((r5rs:positive? y)
             (if (r5rs:>= x 0)
                 (r5rs:quotient x y)
                 (let ((z (r5rs:quotient x y)))
                   (if (r5rs:= x (r5rs:* y z))
                       z
                       (r5rs:- z 1)))))
            ((r5rs:zero? y)
             (error "zero divisor (fixnum-div)" x y))
            ((r5rs:= y -1)
             ; Can't negate *low*, which is its own additive inverse.
             (if (r5rs:= x *low*)
                 x
                 (r5rs:- x)))
            ((r5rs:= y *low*)
             ; Can't negate *low*, which is its own additive inverse.
             (if (r5rs:= x *low*)
                 1
                 0))
            (else
             (r5rs:- (r5rs-fixnum-div x (r5rs:- y)))))))

(define (r5rs-fixnum-mod x y)
  (if (r5rs:= y -1)
      0
      (r5rs:- x (r5rs:* (r5rs-fixnum-div x y) y))))

; Given two fixnums and their fixnum sum, returns the carry.

(define (fixnum-carry x y x+y)
  (if (fixnum-negative? x)
      (if (fixnum-negative? y)
          ; Both x and y are negative, so x+y should be negative.
          (if (fixnum-negative? x+y)
              (make-fixnum 0)
              (make-fixnum -1))
          (make-fixnum 0))
      (if (fixnum-negative? y)
          (make-fixnum 0)
          ; Both x and y are non-negative, so x+y should be non-negative.
          (if (fixnum-negative? x+y)
              (make-fixnum 1)
              (make-fixnum 0)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Basic primitives, from which the rest are defined.
;
; These basic primitives are more easily and more appropriately
; written in assembly language than in Scheme.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (fixnum-div+mod x y)
  (let* ((a (fixnum-rep x))
         (b (fixnum-rep y))
         (d (r5rs-fixnum-div a b))
	 (m (if (r5rs:= b -1)
                0
                (r5rs:- a (r5rs:* d b)))))
    (values (make-fixnum d) (make-fixnum m))))

(define (fixnum-div0+mod0 x y)
  (call-with-values
   (lambda () (fixnum-div+mod x y))
   (lambda (d m)
     (let ((y/2 (fixnum-div y (make-fixnum 2))))
       (cond ((fixnum-positive? y/2)
              (if (fixnum>= m y/2)
                  (if (and (fixnum= m y/2)
                           (fixnum-odd? y))
                      (values d m)
                      (values (fixnum+ d (make-fixnum 1))
                              (fixnum- m y)))
                  (values d m)))
             (else
              (let ((y/2abs (fixnum- y/2)))
                (if (fixnum>= m y/2abs)
                    (if (and (fixnum= m y/2abs)
                             (fixnum-odd? y))
                        (values d m)
                        (values (fixnum- d (make-fixnum 1))
                                (fixnum+ m y)))
                    (values d m)))))))))

(define (fixnum+/2 x y)
  (let* ((a (fixnum-rep x))
         (b (fixnum-rep y)))
    (if (r5rs:>= a 0)
        (if (r5rs:>= b 0)
            (let* ((b- (r5rs:+ b *low*))
                   (c (r5rs:+ a b-)))
              (if (r5rs:< c 0)
                  (make-fixnum (r5rs:+ a b))
                  (make-fixnum (r5rs:+ c *low*))))
            (make-fixnum (r5rs:+ a b)))
        (if (r5rs:< b 0)
            (let* ((b+ (r5rs:- b *low*))
                   (c (r5rs:+ a b+)))
              (if (r5rs:>= c 0)
                  (make-fixnum (r5rs:+ a b))
                  (make-fixnum (r5rs:- c *low*))))
            (make-fixnum (r5rs:+ a b))))))

(define (fixnum-/2 x y)
  (let ((b (fixnum-rep y)))
    (if (r5rs:= b *low*)
        (fixnum+/2 x y)
        (fixnum+/2 x (make-fixnum (r5rs:- b))))))

; (a * m + b) * (c * m + d)
; = (a * c) * m^2 + (a * d + b * c) * m + b * d

(define (fixnum*/2 x y)
  (call-with-values
   (lambda () (fixnum-div0+mod0 x (make-fixnum *half-modulus*)))
   (lambda (a b)
     (call-with-values
      (lambda () (fixnum-div0+mod0 y (make-fixnum *half-modulus*)))
      (lambda (c d)
        (let* ((a (fixnum-rep a))
               (b (fixnum-rep b))
               (c (fixnum-rep c))
               (d (fixnum-rep d))
               (a*d (r5rs:* a d))
               (b*c (r5rs:* b c))
               (b*d (r5rs:* b d))
               (a*d+b*c (fixnum+/2 (make-fixnum a*d) (make-fixnum b*c)))
               (hibits (fixnum-rep
                        (fixnum-mod a*d+b*c (make-fixnum *half-modulus*))))
               (hibits (if (r5rs:> hibits *half-high*)
                           (r5rs:- hibits *half-modulus*)
                           hibits))
               (hi (make-fixnum (r5rs:* hibits *half-modulus*)))
               (lo (make-fixnum b*d)))
        (fixnum+/2 hi lo)))))))

; Operations with carry

(define (fixnum+/carry x y c)
  (let* ((x+y (fixnum+/2 x y))
         (x+y+c (fixnum+/2 x+y c)))
    (values x+y+c
            (fixnum+/2 (fixnum-carry x y x+y)
                       (fixnum-carry x+y c x+y+c)))))

(define (fixnum-/carry x y c)
  (if (fixnum> y (least-fixnum))
      (if (fixnum> c (least-fixnum))
          ; This tail call is the usual case.
          (fixnum+/carry x (fixnum- y) (fixnum- c))
          ; c is the least fixnum
          (call-with-values
           (lambda () (fixnum+/carry x (fixnum- y) c))
           (lambda (x+y+c carry)
             (values x+y+c (fixnum+/2 carry (make-fixnum 1))))))
      (if (fixnum> c (least-fixnum))
          ; y is the least fixnum
          (call-with-values
           (lambda () (fixnum+/carry x y (fixnum- c)))
           (lambda (x+y+c carry)
             (values x+y+c (fixnum+/2 carry (make-fixnum 1)))))
          ; Both y and c are the least fixnum.
          (call-with-values
           (lambda () (fixnum+/carry x y c))
           (lambda (x+y+c carry)
             (values x+y+c (fixnum+/2 carry (make-fixnum 2))))))))

; fixnum*/carry is almost the same as fixnum*/2
;
; (a * m + b) * (c * m + d)
; = (a * c) * m^2 + (a * d + b * c) * m + b * d

(define (fixnum*/carry x y z)
  (call-with-values
   (lambda () (fixnum-div0+mod0 x (make-fixnum *half-modulus*)))
   (lambda (a b)
     (call-with-values
      (lambda () (fixnum-div0+mod0 y (make-fixnum *half-modulus*)))
      (lambda (c d)
        (let* ((a*c (fixnum*/2 a c))
               (a*d (fixnum*/2 a d))
               (b*c (fixnum*/2 b c))
               (b*d (fixnum*/2 b d))
               (a*d+b*c (fixnum+/2 a*d b*c))
               (carry1 (fixnum-carry a*d b*c a*d+b*c)))
          (call-with-values
           (lambda () (fixnum-div0+mod0 a*d+b*c (make-fixnum *half-modulus*)))
           (lambda (carry2 hibits)
             (let* ((hi (fixnum*/2 hibits (make-fixnum *half-modulus*)))
                    (product0 (fixnum+/2 hi b*d))
                    (carry3 (fixnum-carry hi b*d product0))
                    (result0 (fixnum+/2 product0 z))
                    (carry4 (fixnum-carry product0 z result0)))
               '
               (begin
                (write (list (list x y z)
                            ;(list a b c d)
                             (list a*c a*d b*c b*d)
                             (list carry1 a*d+b*c)
                             (list carry2 hibits)
                             hi
                             (list carry3 product0)
                             (list carry4 result0)))
                (newline))
               (values
                result0
                (fixnum+/2 a*c
                           (fixnum+/2 (fixnum+/2 carry1 carry2)
                                      (fixnum+/2 carry3 carry4)))))))))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; For making derived procedures.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (make-fixnum*fixnum->fixnum fixnum-op)
  (lambda (a b)
    (make-fixnum (fixnum-op (fixnum-rep a) (fixnum-rep b)))))

(define (make-fixnum->fixnum fixnum-op)
  (lambda (a)
    (make-fixnum (fixnum-op (fixnum-rep a)))))

(define (make-fixnum*fixnum->val fixnum-op)
  (lambda (a b)
    (fixnum-op (fixnum-rep a) (fixnum-rep b))))

(define (make-fixnum->val fixnum-op)
  (lambda (a)
    (fixnum-op (fixnum-rep a))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Derived procedures.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (fixnum+ . args)
  (reduce (make-fixnum 0) fixnum+/2 args))

(define (fixnum- arg0 . args)
  (if (null? args)
      (fixnum-/2 (make-fixnum 0) arg0)
      ;FIXME: the definition of reduce in nary.scm is bonkers
      (do ((result arg0 (fixnum-/2 result (car args)))
           (args args (cdr args)))
          ((null? args) result))))

(define (fixnum* . args)
  (reduce (make-fixnum 1) fixnum*/2 args))

;FIXME: these should go away

(define fixnum-quotient (make-fixnum*fixnum->fixnum r5rs:quotient))
(define fixnum-remainder (make-fixnum*fixnum->fixnum r5rs:remainder))
(define fixnum-modulo (make-fixnum*fixnum->fixnum r5rs:modulo))

(define (fixnum-quotient+remainder a b)
  (values (fixnum-quotient a b)
	  (fixnum-remainder a b)))

(define (fixnum-div x y)
  (call-with-values
   (lambda () (fixnum-div+mod x y))
   (lambda (d m)
     d)))

(define (fixnum-mod x y)
  (call-with-values
   (lambda () (fixnum-div+mod x y))
   (lambda (d m)
     m)))

(define (fixnum-div0 x y)
  (call-with-values
   (lambda () (fixnum-div0+mod0 x y))
   (lambda (d m) d)))

(define (fixnum-mod0 x y)
  (call-with-values
   (lambda () (fixnum-div0+mod0 x y))
   (lambda (d m) m)))

(define fixnum= (make-transitive-pred (make-fixnum*fixnum->val r5rs:=)))
(define fixnum>= (make-transitive-pred (make-fixnum*fixnum->val r5rs:>=)))
(define fixnum<= (make-transitive-pred (make-fixnum*fixnum->val r5rs:<=)))
(define fixnum> (make-transitive-pred (make-fixnum*fixnum->val r5rs:>)))
(define fixnum< (make-transitive-pred (make-fixnum*fixnum->val r5rs:<)))

(define fixnum-zero? (make-fixnum->val r5rs:zero?))
(define fixnum-positive? (make-fixnum->val r5rs:positive?))
(define fixnum-negative? (make-fixnum->val r5rs:negative?))
(define fixnum-even? (make-fixnum->val r5rs:even?))
(define fixnum-odd? (make-fixnum->val r5rs:odd?))

(define fixnum-min (make-min/max fixnum<))
(define fixnum-max (make-min/max fixnum>))

(define *fixnum-width* (make-fixnum *width*))
(define *fixnum-min* (make-fixnum *low*))
(define *fixnum-max* (make-fixnum *high*))

(define (fixnum-width) *fixnum-width*)
(define (least-fixnum) *fixnum-min*)
(define (greatest-fixnum) *fixnum-max*)

; See r5rs.sch for definitions of
; arithmetic-shift, bitwise-and, bitwise-ior, bitwise-xor, 
; bitwise-not, and bit-count.

(define fixnum-not (make-fixnum->fixnum bitwise-not))

(define fixnum-and/2 (make-fixnum*fixnum->fixnum bitwise-and))
(define (fixnum-and . args)
  (reduce (make-fixnum -1)
	  fixnum-and/2
	  args))

(define fixnum-ior/2 (make-fixnum*fixnum->fixnum bitwise-ior))
(define (fixnum-ior . args)
  (reduce (make-fixnum 0)
	  fixnum-ior/2
	  args))

(define fixnum-xor/2 (make-fixnum*fixnum->fixnum bitwise-xor))
(define (fixnum-xor . args)
  (reduce (make-fixnum 0)
	  fixnum-xor/2
	  args))

(define (fixnum-if x y z)
  (fixnum-ior (fixnum-and x y)
              (fixnum-and (fixnum-not x) y)))

(define fixnum-bit-count (make-fixnum->fixnum bit-count))

(define (fixnum-length x)
  (do ((result 0 (+ result 1))
       (bits (if (fixnum-negative? x)
                 (fixnum- x)
                 x)
             (fixnum-logical-shift-right bits 1)))
      ((fixnum-zero? bits)
       result)))

(define (fixnum-first-bit-set x) ...) ; FIXME

(define (fixnum-bit-set? x y) ...) ;FIXME

(define (fixnum-copy-bit x y z) ...) ;FIXME

(define (fixnum-bit-field x y z) ...) ;FIXME

(define (fixnum-copy-bit-field x y z w) ...) ;FIXME

(define fixnum-arithmetic-shift-left
  (make-fixnum*fixnum->fixnum arithmetic-shift))

(define (fixnum-logical-shift-left fixnum1 fixnum2)
  (cond
   ((fixnum-negative? fixnum2)
    (error "negative shift argument to fixnum-logical-shift-left"
           fixnum1 fixnum2))
   ((fixnum-zero? fixnum2) fixnum1)
   ((fixnum> fixnum2 *fixnum-width*) (make-fixnum 0))
   (else
    (fixnum-and/2 (fixnum-arithmetic-shift-left
                   (fixnum-and/2 fixnum1 *fixnum-max*)
                   fixnum2)
                  *fixnum-max*))))

(define (fixnum-logical-shift-right fixnum1 fixnum2)
  (cond
   ((fixnum-negative? fixnum2)
    (error "negative shift argument to fixnum-logical-shift-left"
           fixnum1 fixnum2))
   ((fixnum-zero? fixnum2) fixnum1)
   ((fixnum-positive? fixnum1)
    (fixnum-arithmetic-shift-left fixnum1 (fixnum- fixnum2)))
   ((fixnum> fixnum2 *fixnum-width*) (make-fixnum 0))
   (else
    (fixnum-ior/2
     (fixnum-arithmetic-shift-left (fixnum-and/2 fixnum1 *fixnum-max*)
                                   (fixnum- fixnum2))
     (fixnum-logical-shift-left (make-fixnum 1)
                                (fixnum- *fixnum-width*
                                         fixnum2
                                         (make-fixnum 1)))))))

; The fx operations signal an error instead of returning a value
; that might depend upon the fixnum precision.

; Some of the fx operations are the same as the fixnum operations.

(define fx= fixnum=)
(define fx> fixnum>)
(define fx< fixnum<)
(define fx>= fixnum>=)
(define fx<= fixnum<=)

(define fxzero? fixnum-zero?)
(define fxpositive? fixnum-positive?)
(define fxnegative? fixnum-negative?)

(define fxodd? fixnum-odd?)
(define fxeven? fixnum-even?)

(define fxmax fixnum-max)
(define fxmin fixnum-min)

(define (fx+ x y)
  (let ((z (fixnum+ x y)))
    (if (fixnum-positive? x)
        (if (fixnum-positive? y)
            (if (fixnum-positive? z)
                z
                (error "fixnum overflow in fx+" x y))
            z)
        (if (fixnum-negative? y)
            (if (fixnum-negative? z)
                z
                (error "fixnum overflow in fx+" x y))
            z))))

(define (fx- x . rest)
  (if (null? rest)
      (fx- (make-fixnum 0) x)
      (let* ((y (car rest))
             (z (fixnum- x y)))
        (if (fixnum-positive? x)
            (if (fixnum-negative? y)
                (if (fixnum-positive? z)
                    z
                    (error "fixnum overflow in fx-" x y))
                z)
            (if (fixnum-positive? y)
                (if (fixnum-negative? z)
                    z
                    (error "fixnum overflow in fx-" x y))
                z)))))

(define (fx* x y)
  (call-with-values
   (lambda () (fixnum*/carry x y (make-fixnum 0)))
   (lambda (result carry)
     (if (fixnum-zero? carry)
         result
         (error "fixnum overflow in fx*" x y)))))

(define (fxdiv+mod x y)
  (if (and (fixnum= x (least-fixnum))
           (fixnum= y (make-fixnum -1)))
      (error "fixnum overflow in fxdiv+mod" x y)
      (fixnum-div+mod x y)))

(define (fxdiv x y)
  (if (and (fixnum= x (least-fixnum))
           (fixnum= y (make-fixnum -1)))
      (error "fixnum overflow in fxdiv" x y)
      (fixnum-div x y)))

(define fxmod fixnum-mod)

(define (fxdiv0+mod0 x y)
  (if (and (fixnum= x (least-fixnum))
           (fixnum= y (make-fixnum -1)))
      (error "fixnum overflow in fxdiv0+mod0" x y)
      (fixnum-div0+mod0 x y)))

(define (fxdiv0 x y)
  (if (and (fixnum= x (least-fixnum))
           (fixnum= y (make-fixnum -1)))
      (error "fixnum overflow in fxdiv0" x y)
      (fixnum-div0 x y)))

(define fxmod0 fixnum-mod0)

(define fxnot fixnum-not)
(define fxand fixnum-and)
(define fxior fixnum-ior)
(define fxxor fixnum-xor)

(define fxif fixnum-if)

(define fxbit-count fixnum-bit-count)
(define fxfirst-bit-set fixnum-first-bit-set)

(define (fxbit-set? x y)
  (if (or (fixnum< y (make-fixnum 0))
          (fixnum>= y (fixnum-width)))
      (error "second argument to fxbit-set! is out of range" x y)
      (fixnum-bit-set? x y)))

(define (fxcopy-bit x y z)
  (if (or (fixnum< y (make-fixnum 0))
          (fixnum>= y (fixnum-width))
          (fixnum< z (make-fixnum 0))
          (fixnum> z (make-fixnum 1)))
      (error "illegal argument(s) to fxcopy-bit" x y z)
      (fixnum-copy-bit x y z)))

(define (fxbit-field x y z)
  (if (or (fixnum< y (make-fixnum 0))
          (fixnum< z (make-fixnum 0))
          (fixnum> y z))
      (error "illegal argument(s) to fxbit-field" x y z)
      (fixnum-bit-field x y z)))

(define (fxcopy-bit-field x y z w)
  (if (or (fixnum< y (make-fixnum 0))
          (fixnum< z (make-fixnum 0))
          (fixnum> y (fixnum-width))
          (fixnum> z (fixnum-width)))
      (error "illegal argument(s) to fxcopy-bit-field" x y z w)
      (fixnum-copy-bit-field x y z w)))

(define (fxarithmetic-shift x y)
  (if (or (fixnum< y (fixnum- (fixnum-width)))
          (fixnum> y (fixnum-width)))
      (error "illegal second argument to fxarithmetic-shift" x y)
      (let ((z (fixnum-arithmetic-shift x y)))
        (if (fixnum= x (fixnum-arithmetic-shift z (fixnum- y)))
            z
            (error "fixnum overflow in fxarithmetic-shift" x y)))))

(define (fxarithmetic-shift-left x y)
  (if (fixnum< y (make-fixnum 0))
      (error "negative second argument to fxarithmetic-shift-left" x y)
      (fxarithmetic-shift x y)))

(define (fxarithmetic-shift-right x y)
  (if (fixnum< y (make-fixnum 0))
      (error "negative second argument to fxarithmetic-shift-right" x y)
      (fxarithmetic-shift x (fixnum- y))))



