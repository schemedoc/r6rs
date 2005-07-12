; Implementation of simple syntactic layer for Records SRFI

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

(define-record-type :record-type
  (make-record-type rtd)
  record-type?
  (rtd real-record-type-rtd))

(define-syntax record-type-rtd
  (syntax-rules ()
    ((record-type-rtd ?record-name)
     (real-record-type-rtd ?record-name))))

(define-syntax define-simple-record-type
  (syntax-rules (fields parent nongenerative mutable immutable)
    ((define-simple-record-type (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?clause ...)
     (define-simple-record-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       #f ()  ; parent rtd, parent init exprs
       "fields-unspecified"
       #f ; nongenerative uid
       ?clause ...))))

(define-syntax define-simple-record-type-1
  (syntax-rules (fields parent nongenerative mutable immutable)
    ;; find PARENT clause
    ((define-simple-record-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent-rtd ?parent-init-exprs ?fields-clause ?nongenerative-clause
       (parent ?parent-name ?expr ...)
       ?clause ...)
     (define-simple-record-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       (record-type-rtd ?parent-name) (?expr ...) ?fields-clause ?nongenerative-uid
       ?clause ...))

    ;; find FIELDS clause
    ((define-simple-record-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent-rtd ?parent-init-exprs ?fields-clause ?nongenerative-uid
       (fields (?field-spec ?init-expr) ...)
       ?clause ...)
     (define-simple-record-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent-rtd ?parent-init-exprs (fields (?field-spec ?init-expr) ...) ?nongenerative-uid
       ?clause ...))

    ;; find NONGENERATIVE clause
    ((define-simple-record-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent-rtd ?parent-init-exprs ?fields-clause ?nongenerative-uid
       (nongenerative ?uid)
       ?clause ...)
     (define-simple-record-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent-rtd ?parent-init-exprs  ?fields-clause ?uid
       ?clause ...))

    ;; generate code
    ((define-simple-record-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent-rtd (?parent-init-expr ...)
       (fields ((?mutability ?field-name ?procs ...) ?init-expr) ...)
       ?nongenerative-uid)

     (begin
       ;; where we need LETREC* semantics if this is to work internally
       (define $rtd
	 (make-record-type-descriptor '?record-name
				      ?parent-rtd
				      '?nongenerative-uid
				      '(?field-name ...)))

       (define ?record-name (make-record-type $rtd))

       (define ?constructor-name
	 (let ((make (record-constructor $rtd)))
	   (lambda ?formals
	     (make ?parent-init-expr ... ?init-expr ...))))
       
       (define ?predicate-name
	 (record-predicate $rtd))

       (define-record-field $rtd (?mutability ?field-name ?procs ...) ?init-expr)
       ...))))

(define-syntax define-record-field
  (syntax-rules (mutable immutable)
    ((define-record-field ?rtd
       (immutable ?field-name ?accessor-name) ?init-expr)
     (define ?accessor-name (record-accessor ?rtd '?field-name)))
    ((define-record-field ?rtd
       (mutable ?field-name ?accessor-name ?mutator-name) ?init-expr)
     (begin
       (define ?accessor-name (record-accessor ?rtd '?field-name))
       (define ?mutator-name (record-mutator ?rtd '?field-name))))))
