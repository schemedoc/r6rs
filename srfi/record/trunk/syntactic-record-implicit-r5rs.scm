; Portable part of the implementation of DEFINE-RECORD-TYPE for Records SRFI

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

(define-syntax define-type
  (syntax-rules ()
    ((define-type (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?clause ...)
     (define-type-1 ?record-name (?record-name ?constructor-name ?predicate-name)
       ?formals
       ()
       ?clause ...))
    ((define-type ?record-name
       ?formals
       ?clause ...)
     (define-type-1 ?record-name ?record-name
       ?formals
       ()
       ?clause ...))))

(define-syntax define-type-1
  (syntax-rules (fields)

    ;; find FIELDS clause
    ((define-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)
       (fields ((?mutability ?field-name ?proc-names ...) ?init-expr) ...)
       ?clause ...)
     (process-fields-clause (fields ((?mutability ?field-name ?proc-names ...) ?init-expr) ...)
			    ?record-name ?record-name-spec
			    ?formals
			    (?simple-clause ...)
			    ?clause ...))

    ;; collect all other clauses
    ((define-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)
       ?clause0
       ?clause ...)
     (define-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ... ?clause0)
       ?clause ...))

    ;; pass it on
    ((define-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...))

     (define-type-2 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)))))
