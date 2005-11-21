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

; ASSQ at the syntax level
(define-syntax define-alist-extractor
  (syntax-rules ()
    ((define-alist-extractor ?name ?tag ?default)
     (define-syntax ?name
       (syntax-rules (?tag)
	 ((?name ())
	  ?default)
	 ((?name ((?tag ?val) . ?rest))
	  ?val)
	 ((?name ((?another-tag ?val) . ?rest))
	  (?name ?rest)))))))

(define-alist-extractor extract-parent-name parent-name #f)
(define-alist-extractor extract-parent-rtd parent-rtd #f)
(define-alist-extractor extract-sealed sealed #f)
(define-alist-extractor extract-opaque opaque #t)
(define-alist-extractor extract-nongenerative nongenerative #f)
(define-alist-extractor extract-init! init! values)

(define-syntax define-type
  (syntax-rules ()
    ((define-type (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ()				; prop alist
       ?formals
       ()				; parent init exprs
       ()				; constructor lets
       ()				; fields
       ?clause ...))))

(define-syntax define-type-1
  (syntax-rules (parent sealed nongenerative init! opaque fields let)
    ;; find PARENT clause
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       ?fields-clause
       (parent ?parent-name ?expr ...)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ((parent-name ?parent-name) (parent-rtd (type-descriptor ?parent-name)) . ?props)
       ?formals
       (?expr ...)        
       ?constructor-lets ?fields-clause
       ?clause ...))

    ;; find LET clause
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       (?constructor-let ...)
       ?field-specs
       (let ?bindings)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       (?bindings ?constructor-let ...)
       ?field-specs
       ?clause ...))

    ;; find SEALED clause
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       ?field-specs
       (sealed #t)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ((sealed #t) . ?props)
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       ?field-specs
       ?clause ...))
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       ?field-specs
       (sealed #f)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ((sealed #f) . ?props)
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       ?field-specs
       ?clause ...))

    ;; find OPAQUE clause
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       ?field-specs
       (opaque #t)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ((opaque #t) . ?props)
       ?formals
       ?parent-init-exprs 
       ?constructor-lets
       ?field-specs
       ?clause ...))
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       ?field-specs
       (opaque #f)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ((opaque #f) . ?props)
       ?formals
       ?parent-init-exprs 
       ?constructor-lets
       ?field-specs
       ?clause ...))

    ;; parse FIELDS clause

    ;; base case
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       (?field-spec ...)
       (fields)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       (?field-spec ...)
       ?clause ...))

    ;; missing init expression
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       (?field-spec ...)
       (fields (?field-name ?procs) ?rest ...)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       (?field-spec ...)
       (fields (?field-name ?procs ?field-name) ?rest ...)
       ?clause ...))
     
     ;; complete spec
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       (?field-spec ...)
       (fields (?field-name (?accessor) ?init) ?rest ...)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       (?field-spec ... (immutable ?field-name (?accessor) ?init)) 
       (fields ?rest ...)
       ?clause ...))

    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       (?field-spec ...)
       (fields (?field-name (?accessor ?mutator) ?init) ?rest ...)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       (?field-spec ... (mutable ?field-name (?accessor ?mutator) ?init))
       (fields ?rest ...)
       ?clause ...))

    ;; find NONGENERATIVE clause
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       ?field-specs
       (nongenerative ?uid)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ((nongenerative '?uid) . ?props)
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       ?field-specs
       ?clause ...))

    ;; find INIT! clause
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       ?field-specs
       (init! (?r) ?body)
       ?clause ...)
     (define-type-1 (?record-name ?constructor-name ?predicate-name)
       ((init! (lambda (?r) ?body)) . ?props)
       ?formals
       ?parent-init-exprs
       ?constructor-lets
       ?field-specs
       ?clause ...))

    ;; generate code
    ((define-type-1 (?record-name ?constructor-name ?predicate-name)
       ?props
       ?formals
       (?parent-init-expr ...)
       ?constructor-lets
       ((?mutability ?field-name ?procs ?init-expr) ...))

     (begin
       ;; where we need LETREC* semantics if this is to work internally
       (define $rtd
	 (make-record-type-descriptor '?record-name
				      (extract-parent-rtd ?props)
				      (extract-nongenerative ?props)
				      (extract-sealed ?props)
				      (extract-opaque ?props)
				      '((?mutability ?field-name) ...)))

       (define $args-proc
	 (if (extract-parent-rtd ?props)
	     (let ((parent-args-proc (record-type-args-proc (extract-parent-name ?props))))
	       (lambda (child-field-values . ?formals)
		 (letify ?constructor-lets
			 (parent-args-proc
			  (do-append (?init-expr ...) child-field-values)
			  ?parent-init-expr ...))))
	     (lambda (child-field-values . ?formals)
	       (letify ?constructor-lets
		       (do-append (?init-expr ...) child-field-values)))))

       (define ?record-name (make-record-type $rtd $args-proc))

       (define ?constructor-name
	 (let ((make (record-constructor $rtd)))
	   (if (extract-parent-rtd ?props)
	       (let ((parent-args-proc (record-type-args-proc (extract-parent-name ?props))))
		 (lambda ?formals
		   (letify ?constructor-lets
			   (let ((r (apply make (parent-args-proc (list ?init-expr ...)
								  ?parent-init-expr ...))))
			     ((extract-init! ?props) r)
			     r))))
	       (lambda ?formals
		 (letify ?constructor-lets
			 (let ((r (make ?parent-init-expr ... ?init-expr ... )))
			   ((extract-init! ?props) r)
			   r))))))
       
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

; the innermost let comes first
(define-syntax letify
  (syntax-rules ()
    ((letify () ?exp) ?exp)
    ((letify (?bindings1 ?rest ...) ?exp)
     (letify (?rest ...)
	     (let ?bindings1 ?exp)))))
     