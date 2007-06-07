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
; R5RS compatibility for the reference implementation of
; (r6rs bytevector).
;

; The following macro converts library forms into begin forms.

(define-syntax library
  (syntax-rules ()
   ((library name (export x ...) (import lib ...) form ...)
    (begin form ...))))

; An equally fake implementation of Larceny's bytevectors.

(define bytevector? vector?)
(define make-bytevector make-vector)
(define bytevector-length vector-length)
(define (bytevector-ref bytevector i)
  (let ((x (vector-ref bytevector i)))
    (if (< x 0)
        (+ x 256)
        x)))
(define bytevector-set! vector-set!)

(define bytevector-u8-ref bytevector-ref)
(define bytevector-u8-set! bytevector-set!)

; A fake implementation of the R6RS unspecified procedure.

(define (unspecified)
  (if #f #f))

; Given exact integers n and k, with k >= 0, return (* n (expt 2 k)).

(define (bitwise-arithmetic-shift-left n k)
  (if (and (exact? n)
           (integer? n)
           (exact? k)
           (integer? k)
           (<= 0 k))
      (cond ((> k 0)
             (* n (expt 2 k)))
            (else n))
      (error #f "illegal argument to bitwise-arithmetic-shift-left" n k)))

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
      (error #f "illegal argument to bitwise-and" i j)))

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
      (error #f "illegal argument to bitwise-ior" i j)))

; FIXME: this is a temporary hack

(define (bitwise-bit-field n i j)
  (let ((mask
         (bitwise-arithmetic-shift-left (- (expt 2 (- j i)) 1) i)))
    (quotient (bitwise-and n mask)
              (expt 2 i))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; End of compatibility hacks.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Load the files in order.

(for-each load
          '("bvec-core.sch"
            "bvec-proto.sch"
            "bvec-ieee.sch"
            "bvec-string.sch"
            "bytevector.sch"
            "bytevector-tests-r5rs.sch"))

(display "Running (basic-bytevector-tests)")
(newline)
(basic-bytevector-tests)

(display "Running (ieee-bytevector-tests)")
(newline)
(ieee-bytevector-tests)

(display "Running (string-bytevector-tests)")
(newline)
(string-bytevector-tests)

(display "Running (exhaustive-string-bytevector-tests)")
(newline)
(exhaustive-string-bytevector-tests)
