; Copyright 2006 William D Clinger.
;
; Permission to copy this software, in whole or in part, to use this
; software for any lawful purpose, and to redistribute this software
; is granted subject to the restriction that all copies made of this
; software must include this copyright notice in full.
; 
; I also request that you send me a copy of any improvements that you
; make to this software so that they may be incorporated within it to
; the benefit of the Scheme community.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This file of Larceny-dependent code implements enough of
;
; (r6rs base)
; (r6rs bytevector)
; (r6rs list)
;
; and other things to load Will Clinger's reference implementation of
;
; (r6rs unicode)
;
; which it does at the very end.

(define (larceny:error . etc)
  (display "Tried to use an unimplemented feature of R6RS.")
  (newline)
  (display "Shame on you!")
  (newline)
  (car 'larceny))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Larceny compatibility.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This shouldn't be necessary, but Larceny ships with some
; brain-dead repeat macro, and there appears to be a bug in
; Larceny's macro expander that doesn't allow that macro to
; be shadowed by a named let.  (This is probably an example
; of syntactic ambiguity created by internal definitions,
; but I don't want to take the time to verify that.)

(define repeat)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; (r6rs base)
;
; Implements only as much as is used by enumerations.sch.
;
; Except for the library syntax, the reference implementation
; uses only the R5RS-compatible procedures from this library.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-syntax library
  (syntax-rules ()
   ((library name (export x ...) (import lib ...) form ...)
    (begin form ...))))


; Given exact integers n and k, with k >= 0, return (* n (expt 2 k)).

(define (arithmetic-shift n k)
  (if (and (exact? n)
           (integer? n)
           (exact? k)
           (integer? k))
      (cond ((> k 0)
             (* n (expt 2 k)))
            ((= k 0)
             n)
            ((>= n 0)
             (quotient n (expt 2 (- k))))
            (else
             (let* ((q (expt 2 (- k)))
                    (p (quotient (- n) q)))
               (if (= n (* p k))
                   (- p)
                   (- -1 p)))))
      (error "illegal argument to arithmetic-shift" n k)))

; Bitwise operations on exact integers.

(define (bitwise-and i j)
  (if (and (exact? i)
           (integer? i)
           (exact? j)
           (integer? j))
      (cond ((or (= i 0) (= j 0))
             0)
            ((= i -1)
             j)
            ((= j -1)
             i)
            (else
             (let* ((i0 (if (odd? i) 1 0))
                    (j0 (if (odd? j) 1 0))
                    (i1 (- i i0))
                    (j1 (- j j0))
                    (i/2 (quotient i1 2))
                    (j/2 (quotient j1 2))
                    (hi (* 2 (bitwise-and i/2 j/2)))
                    (lo (* i0 j0)))
               (+ hi lo))))
      (error "illegal argument to bitwise-and" i j)))

(define (bitwise-ior i j)
  (if (and (exact? i)
           (integer? i)
           (exact? j)
           (integer? j))
      (cond ((or (= i -1) (= j -1))
             -1)
            ((= i 0)
             j)
            ((= j 0)
             i)
            (else
             (let* ((i0 (if (odd? i) 1 0))
                    (j0 (if (odd? j) 1 0))
                    (i1 (- i i0))
                    (j1 (- j j0))
                    (i/2 (quotient i1 2))
                    (j/2 (quotient j1 2))
                    (hi (* 2 (bitwise-ior i/2 j/2)))
                    (lo (if (= 0 (+ i0 j0)) 0 1)))
               (+ hi lo))))
      (error "illegal argument to bitwise-ior" i j)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; (r6rs bytevector)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; make-bytevector is already provided by Larceny
; bytevector-length is already provided by Larceny

(define bytevector-u8-ref bytevector-ref)
(define bytevector-u8-set! bytevector-set!)
(define u8-list->bytevector list->bytevector)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; (r6rs unicode)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load "unicode0.sch")
(load "unicode1.sch")
(load "unicode2.sch")
(load "unicode3.sch")
(load "unicode4.sch")
(load "unicode.sch")
