; Scheme 48 package definitions for Records SRFI

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

(define-interface procedural-record-types-interface
  (export make-record-type-descriptor
	  record-type-descriptor?
	  record-constructor record-predicate
	  record-accessor record-mutator))

(define-interface record-reflection-interface
  (export record-type-name
	  record-type-parent
	  record-type-sealed?
	  record-type-uid
	  record-type-generative?
	  record-type-field-names
	  record-type-opaque?
	  record-field-mutable?

	  record? record-type-descriptor))

(define-structures ((procedural-record-types procedural-record-types-interface)
		    (record-reflection record-reflection-interface))
  (open scheme
	(subset srfi-1 (list-index find every))
	srfi-9 ; DEFINE-RECORD-TYPE
	srfi-23 ; ERROR
	srfi-26 ; CUT
	)
  (files procedural-record))

(define-interface syntactic-record-types/explicit-interface
  (export (define-type :syntax)
	  (type-descriptor :syntax)))

(define-structure syntactic-record-types/explicit syntactic-record-types/explicit-interface
  (open scheme
	srfi-9 ; DEFINE-RECORD-TYPE
	procedural-record-types)
  (files syntactic-record-explicit))

(define-interface syntactic-record-types/implicit-interface
  (export (define-type :syntax)
	  (type-descriptor :syntax)))

(define-structure syntactic-record-types/implicit syntactic-record-types/implicit-interface
  (open scheme
	(modify syntactic-record-types/explicit
		(rename (define-type define-type/explicit))))
  (files syntactic-record-implicit-r5rs
	 syntactic-record-implicit-s48))
