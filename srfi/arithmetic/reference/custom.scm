; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Various parameters for customizing the behavior of the reference
; implementation

; fixnum width
(define *width* 24)
; fixnums are records of R5RS numbers rather than numbers
(define *fixnums-are-records* #t)
; flonums are records of R5RS numbers rather than numbers
(define *flonums-are-records* #t)
