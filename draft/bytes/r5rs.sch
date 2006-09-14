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
; (r6rs bytes).
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
(define (bytevector-ref bytes i)
  (let ((x (vector-ref bytes i)))
    (if (< x 0)
        (+ x 256)
        x)))
(define bytevector-set! vector-set!)

; A fake implementation of the R6RS unspecified procedure.

(define (unspecified)
  (if #f #f))

; Load the files in order.

(for-each load
          '("bytes-core.sch"
            "bytes-proto.sch"
            "bytes-ieee.sch"
            "bytes.sch"
            "bytes-tests.sch"))

(display "Running (basic-bytes-tests)")
(newline)
(basic-bytes-tests)

(display "Running (ieee-bytes-tests)")
(newline)
(ieee-bytes-tests)
