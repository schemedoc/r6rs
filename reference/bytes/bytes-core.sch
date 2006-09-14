; Bytes objects

; Copyright (C) Michael Sperber (2005). All Rights Reserved. 
; 
; Permission is hereby granted, free of charge, to any person
; obtaining a copy of this software and associated documentation files
; (the "Software"), to deal in the Software without restriction,
; including without limitation the rights to use, copy, modify, merge,
; publish, distribute, sublicense, and/or sell copies of the Software,
; and to permit persons to whom the Software is furnished to do so,
; subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Modified for Larceny by William D Clinger, beginning 2 August 2006.
;
; This file is Larceny-specific: it uses bytevectors.
;
; Although bytes objects could be implemented as records
; that encapsulate a vector, that representation would
; require 4 to 8 times as much space as a native representation,
; and I believe most systems already have something analogous to
; Larceny's bytevectors.  It therefore seems reasonable to expect
; implementors to rewrite the core operations that are defined in
; this file.
;
; For a big-endian implementation, the other files should work
; as is once the core operations of this file are implemented.
;
; If the (native-endianness) is to be little, then some parts
; of the bytes-ieee.sch file will have to be converted.
;

(library bytes-core
  (export native-endianness
          bytes? make-bytes bytes-length bytes-u8-ref bytes-u8-set!
          bytes:div bytes:mod)
  (import (r6rs base) (r6rs r5rs) bytevectors)

; FIXME
; The purpose of the next two definitions is to make this
; reference implementation easier to load into an R5RS system:
; Just define a fake library macro and load all the files.

(define bytes:div quotient)
(define bytes:mod remainder)

; change this to the endianness of your architecture

(define (native-endianness)
  ;(cdr (assq 'arch-endianness (system-features)))
  'big)

(define bytes? bytevector?)

(define (make-bytes n . rest)
  (cond ((null? rest)
         (make-bytevector n))
        ((null? (cdr rest))
         (let ((fill (car rest)))
           (if (and ;(fixnum? fill)
                    (exact? fill)
                    (integer? fill)
                    (<= -128 fill 255))
               (do ((bv (make-bytevector n))
                    (i 0 (+ i 1)))
                   ((= i n)
                    bv)
                 (bytevector-set! bv i fill))
               (error "make-bytes" "invalid fill argument: " fill))))
        (else
	 (error "make-bytes" "invalid number of arguments"))))

(define bytes-length bytevector-length)

(define bytes-u8-ref bytevector-ref)
(define bytes-u8-set! bytevector-set!)

)
