; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Code for loading and testing the reference implementation into
; R5RS-conforming implementations of Scheme that provide flonum
; arithmetic and exact integer arithmetic over [-2^23, 2^23-1].
;
; Before loading this file, any inlining of R5RS arithmetic
; procedures must be disabled, and SRFI 9 (Defining Record
; Types) and SRFI 23 (Error reporting mechanism) must be
; enabled.

; Define a small set of bitwise operators.
; The r5rs: procedures will be loaded soon afterwards.

; Given exact integers n and k, with k >= 0, return (* n (expt 2 k)).

(define (arithmetic-shift n k)
  (if (and (r5rs:exact? n)
           (r5rs:integer? n)
           (r5rs:exact? k)
           (r5rs:integer? k))
      (cond ((r5rs:> k 0)
             (r5rs:* n (r5rs:expt 2 k)))
            ((r5rs:= k 0)
             n)
            ((r5rs:>= n 0)
             (r5rs:quotient n (r5rs:expt 2 (r5rs:- k))))
            (else
             (let* ((q (r5rs:expt 2 (r5rs:- k)))
                    (p (r5rs:quotient (r5rs:- n) q)))
               (if (r5rs:= n (r5rs:* p k))
                   (r5rs:- p)
                   (r5rs:- -1 p)))))
      (error "illegal argument to arithmetic-shift" n k)))

; Bitwise operations on exact integers.

(define (bitwise-and i j)
  (if (and (r5rs:exact? i)
           (r5rs:integer? i)
           (r5rs:exact? j)
           (r5rs:integer? j))
      (cond ((or (r5rs:= i 0) (r5rs:= j 0))
             0)
            ((r5rs:= i -1)
             j)
            ((r5rs:= j -1)
             i)
            (else
             (let* ((i0 (if (r5rs:odd? i) 1 0))
                    (j0 (if (r5rs:odd? j) 1 0))
                    (i1 (r5rs:- i i0))
                    (j1 (r5rs:- j j0))
                    (i/2 (r5rs:quotient i1 2))
                    (j/2 (r5rs:quotient j1 2))
                    (hi (r5rs:* 2 (bitwise-and i/2 j/2)))
                    (lo (r5rs:* i0 j0)))
               (r5rs:+ hi lo))))
      (error "illegal argument to bitwise-and" i j)))

(define (bitwise-ior i j)
  (if (and (r5rs:exact? i)
           (r5rs:integer? i)
           (r5rs:exact? j)
           (r5rs:integer? j))
      (cond ((or (r5rs:= i -1) (r5rs:= j -1))
             -1)
            ((r5rs:= i 0)
             j)
            ((r5rs:= j 0)
             i)
            (else
             (let* ((i0 (if (r5rs:odd? i) 1 0))
                    (j0 (if (r5rs:odd? j) 1 0))
                    (i1 (r5rs:- i i0))
                    (j1 (r5rs:- j j0))
                    (i/2 (r5rs:quotient i1 2))
                    (j/2 (r5rs:quotient j1 2))
                    (hi (r5rs:* 2 (bitwise-ior i/2 j/2)))
                    (lo (if (r5rs:= 0 (r5rs:+ i0 j0)) 0 1)))
               (r5rs:+ hi lo))))
      (error "illegal argument to bitwise-ior" i j)))

(define (bitwise-xor i j)
  (if (and (r5rs:exact? i)
           (r5rs:integer? i)
           (r5rs:exact? j)
           (r5rs:integer? j))
      (cond ((and (r5rs:= i -1) (r5rs:= j -1))
             0)
            ((r5rs:= i 0)
             j)
            ((r5rs:= j 0)
             i)
            (else
             (let* ((i0 (if (r5rs:odd? i) 1 0))
                    (j0 (if (r5rs:odd? j) 1 0))
                    (i1 (r5rs:- i i0))
                    (j1 (r5rs:- j j0))
                    (i/2 (r5rs:quotient i1 2))
                    (j/2 (r5rs:quotient j1 2))
                    (hi (r5rs:* 2 (bitwise-xor i/2 j/2)))
                    (lo (if (r5rs:= 1 (r5rs:+ i0 j0)) 1 0)))
               (r5rs:+ hi lo))))
      (error "illegal argument to bitwise-xor" i j)))

(define (bitwise-not i)
  (if (and (r5rs:exact? i)
           (r5rs:integer? i))
      (cond ((r5rs:= i -1)
             0)
            ((r5rs:= i 0)
             -1)
            (else
             (let* ((i0 (if (r5rs:odd? i) 1 0))
                    (i1 (r5rs:- i i0))
                    (i/2 (r5rs:quotient i1 2))
                    (hi (r5rs:* 2 (bitwise-not i/2)))
                    (lo (r5rs:- 1 i0)))
               (r5rs:+ hi lo))))
      (error "illegal argument to bitwise-not" i j)))

(define (bit-count i)
  (if (and (r5rs:exact? i)
           (r5rs:integer? i))
      (cond ((r5rs:= i -1)
             0)
            ((r5rs:= i 0)
             0)
            (else
             (let* ((i0 (if (r5rs:odd? i) 1 0))
                    (i1 (r5rs:- i i0))
                    (i/2 (r5rs:quotient i1 2))
                    (hi (bit-count i/2))
                    (lo (if (r5rs:> i 0) i0 (r5rs:- 1 i0))))
               (r5rs:+ hi lo))))
      (error "illegal argument to bit-count" i j)))

; [Portable]  Load files.

(let ((load (lambda (filename)
              (display "Loading ") (display filename) (newline)
              (load filename))))
                             
(load "custom.scm")
(load "nary.scm")
(load "r5rs-arithmetic.scm")
(load "fixnum.scm")
(load "flonum.scm")
(load "bignum.scm")
(load "bigbit.scm")
(load "integer.scm")
(load "flonum-ieee.scm")
(load "ratnum.scm")
(load "rational.scm")
(load "compnum.scm")
(load "recnum.scm")
(load "rational2flonum.scm")
(load "flonum2rational.scm")
(load "bellerophon.scm")
(load "flonum2string.scm")
(load "number2string.scm")
(load "r5rs2number.scm")
(load "coercion.scm")
(load "contagion.scm")
(load "string2number.scm")
(load "arithmetic-util.scm")
(load "contagion-ex.scm")
(load "generic-ex.scm")     ; redefines define-binary, define-unary
(load "contagion-in.scm")
(load "generic-in.scm")     ; redefines define-binary, define-unary
(load "contagion-generic.scm")
(load "generic.scm")         ; redefines define-binary, define-unary

)

(define (run-tests)
  (let ((prompt-and-load (lambda (filename)
                           (display "Run the tests in ")
                           (display filename)
                           (display " ? (y or n)")
                           (newline)
                           (if (not (eq? (read) 'n))
                               (begin (load "test-prelude.scm")
                                      (load filename)
                                      (load "test-postlude.scm"))))))

    (prompt-and-load "test-fixnum-arithmetic.scm")
    (prompt-and-load "test-string2number.scm")
    (prompt-and-load "test-generic-arithmetic.scm")
    (prompt-and-load "test-generic-arithmetic-ex.scm")
    (prompt-and-load "test-generic-arithmetic-in.scm")))

(run-tests)

; [End of file]
