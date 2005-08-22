; Implementation of explicit-naming syntactic layer for Records SRFI

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
  (make-record-type rtd args-proc)
  record-type?
  (rtd real-record-type-rtd)
  ;; Accepts arguments to this record type's constructor.  Returns
  ;; list of field values for this record type.
  (args-proc record-type-args-proc))

(define-syntax type-descriptor
  (syntax-rules ()
    ((type-descriptor ?record-name)
     (real-record-type-rtd ?record-name))))

(define-syntax define-type
  (syntax-rules ()
    ((define-type (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       #f #f ()		       ; parent, parent rtd, parent init exprs
       #f				; sealed?
       #f				; opaque?
       ()				; fields
       #f				; nongenerative uid
       values				; INIT! proc
       ?clause ...))))

(define-syntax define-type-1
  (syntax-rules (parent sealed nongenerative init! opaque fields)
    ;; find PARENT clause
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? ?fields-clause ?nongenerative-uid ?init-proc
       (parent ?parent-name ?expr ...)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent-name (type-descriptor ?parent-name)
       (?expr ...) ?sealed? ?opaque? ?fields-clause ?nongenerative-uid ?init-proc
       ?clause ...))

    ;; find SEALED clause
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? ?field-specs ?nongenerative-uid ?init-proc
       (sealed)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       #t ?opaque? ?field-specs ?nongenerative-uid ?init-proc
       ?clause ...))

    ;; find OPAQUE clause
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? ?field-specs ?nongenerative-uid ?init-proc
       (opaque)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs 
       ?sealed? #t ?field-specs ?nongenerative-uid ?init-proc
       ?clause ...))

    ;; parse FIELDS clause

    ;; base case
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? (?field-spec ...) ?nongenerative-uid  ?init-proc
       (fields)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? (?field-spec ...) ?nongenerative-uid  ?init-proc
       ?clause ...))

    ;; missing init expression
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? (?field-spec ...) ?nongenerative-uid  ?init-proc
       (fields (?field-name ?procs) ?rest ...)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? (?field-spec ...) ?nongenerative-uid  ?init-proc
       (fields (?field-name ?procs ?field-name) ?rest ...)
       ?clause ...))
     
     ;; complete spec
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? (?field-spec ...) ?nongenerative-uid  ?init-proc
       (fields (?field-name (?accessor) ?init) ?rest ...)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque?
       (?field-spec ... (immutable ?field-name (?accessor) ?init)) 
       ?nongenerative-uid  ?init-proc
       (fields ?rest ...)
       ?clause ...))

    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? (?field-spec ...) ?nongenerative-uid  ?init-proc
       (fields (?field-name (?accessor ?mutator) ?init) ?rest ...)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque?
       (?field-spec ... (mutable ?field-name (?accessor ?mutator) ?init))
       ?nongenerative-uid  ?init-proc
       (fields ?rest ...)
       ?clause ...))

    ;; find NONGENERATIVE clause
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? ?field-specs ?nongenerative-uid  ?init-proc
       (nongenerative ?uid)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? ?field-specs ?uid
       ?init-proc
       ?clause ...))

    ;; find INIT! clause
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? ?field-specs ?nongenerative-uid  ?init-proc
       (init! (?r) ?body)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd ?parent-init-exprs
       ?sealed? ?opaque? ?field-specs ?nongenerative-uid
       (lambda (?r) ?body)
       ?clause ...))

    ;; generate code
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?parent ?parent-rtd (?parent-init-expr ...)
       ?sealed? ?opaque?
       ((?mutability ?field-name ?procs ?init-expr) ...)
       ?nongenerative-uid
       ?init-proc)

     (begin
       ;; where we need LETREC* semantics if this is to work internally
       (define $rtd
	 (make-record-type-descriptor '?record-name
				      ?parent-rtd
				      '?nongenerative-uid
				      ?sealed?
				      ?opaque?
				      '((?mutability ?field-name) ...)))

       (define $args-proc
	 (if ?parent-rtd
	     (let ((parent-args-proc (record-type-args-proc ?parent)))
	       (lambda (child-field-values . ?formals)
		 (parent-args-proc
		  (do-append (?init-expr ...) child-field-values)
		  ?parent-init-expr ...)))
	     (lambda (child-field-values . ?formals)
	       (do-append (?init-expr ...) child-field-values))))

       (define ?record-name (make-record-type $rtd $args-proc))

       (define ?constructor-name
	 (let ((make (record-constructor $rtd)))
	   (if ?parent-rtd
	       (let ((parent-args-proc (record-type-args-proc ?parent)))
		 (lambda ?formals
		   (let ((r (apply make (parent-args-proc (list ?init-expr ...)
							  ?parent-init-expr ...))))
		     (?init-proc r)
		     r)))
	       (lambda ?formals
		 (let ((r (make ?parent-init-expr ... ?init-expr ... )))
		   (?init-proc r)
		   r)))))
       
       (define ?predicate-name
	 (record-predicate $rtd))

       (define-record-field $rtd ?field-name ?procs)
       ...))))

(define-syntax define-record-field
  (syntax-rules ()
    ((define-record-field ?rtd
       ?field-name (?accessor-name))
     (define ?accessor-name (record-accessor ?rtd '?field-name)))
    ((define-record-field ?rtd
       ?field-name (?accessor-name ?mutator-name))
     (begin
       (define ?accessor-name (record-accessor ?rtd '?field-name))
       (define ?mutator-name (record-mutator ?rtd '?field-name))))))

(define-syntax do-append
  (syntax-rules ()
    ((do-append (?elem1 ?elems ...) ?tail)
     (cons ?elem1 (do-append (?elems ...) ?tail)))
    ((do-append () ?tail) ?tail)))
