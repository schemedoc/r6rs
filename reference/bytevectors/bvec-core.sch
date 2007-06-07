; Bytevectors

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
; Although bytevectors could be implemented as records
; that encapsulate a vector, that representation would
; require 4 to 8 times as much space as a native representation,
; and I believe most systems already have something analogous to
; bytevectors.  It therefore seems reasonable to expect
; implementors to rewrite the core operations that are defined
; in this file.
;
; For a big-endian implementation, the other files should work
; as is once the core operations of this file are implemented.
;
; If the (native-endianness) is to be little, then some parts
; of the bytes-ieee.sch file will have to be converted.
;

(library bytevector-core
  (export native-endianness
          bytevector? make-bytevector bytevector-length
          bytevector-u8-ref bytevector-u8-set!
          bytevector:div bytevector:mod)
  (import (r6rs base) (r6rs r5rs) bytevectors)

; FIXME
; The bytevectors library that is imported above is
; assumed to export all but native-endianness,
; bytevector:div, and bytevector:mod.
; For R5RS-compatible definitions of those, see r5rs.sch.

; FIXME
; The purpose of the next two definitions is to make this
; reference implementation easier to load into an R5RS system:
; Just define a fake library macro and load all the files.

(define bytevector:div quotient)
(define bytevector:mod remainder)

; change this to the endianness of your architecture

(define (native-endianness)
  ;(cdr (assq 'arch-endianness (system-features)))
  'big)

)
