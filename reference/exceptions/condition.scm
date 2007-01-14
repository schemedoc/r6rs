; Reference implementation for conditions library, adapted from SRFI 35

; Copyright (C) Richard Kelsey, Michael Sperber (2002). All Rights Reserved.

; Permission is hereby granted, free of charge, to any person
; obtaining a copy of this software and associated documentation files
; (the "Software"), to deal in the Software without restriction,
; including without limitation the rights to use, copy, modify, merge,
; publish, distribute, sublicense, and/or sell copies of the Software,
; and to permit persons to whom the Software is furnished to do so,
; subject to the following conditions:

; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

(library (r6rs conditions)
  (export make-condition-type
	  condition-type?
	  make-condition
	  condition?
	  condition-has-type?
	  condition-ref
	  make-compound-condition
	  condition->list
	  (define-condition-type :syntax)
	  (condition :syntax)
	  &condition
	  &message
	  message-condition?
	  condition-message
	  &warning
	  warning?
	  &serious
	  serious-condition?
	  &error
	  error?
	  &violation
	  violation?
	  &non-continuable
	  non-continuable?
	  &implementation-restriction
	  implementation-restriction?
	  &defect
	  defect?
	  &lexical
	  lexical-violation?
	  &syntax
	  syntax-violation?
	  &undefined
	  undefined-violation?
	  &assertion
	  assertion-violation?
	  &irritants
	  irritants-condition?
	  condition-irritants
	  &who
	  who-condition?
	  condition-who)
  (import (r6rs base)
	  (r6rs records explicit)
	  (r6rs i/o ports)
	  (r6rs conditions internal))

(define-record-type (:condition-type really-make-condition-type condition-type?)
  (fields
  (immutable name condition-type-name)
  (immutable supertype condition-type-supertype)
  (immutable fields condition-type-fields)
  (immutable all-fields condition-type-all-fields)))

(define (make-condition-type name supertype fields)
  (if (not (symbol? name))
      (assertion-violation 'make-condition-type
			  "name is not a symbol"
			  name))
  (if (not (condition-type? supertype))
      (assertion-violation 'make-condition-type
			  "supertype is not a condition type"
			  supertype))
  (if (elements-in-common? (condition-type-all-fields supertype)
			   fields)
      (assertion-violation 'make-condition-type
			  "duplicate field name"
			  fields (condition-type-all-fields supertype)))
  (really-make-condition-type name
                              supertype
                              fields
                              (append (condition-type-all-fields supertype)
                                      fields)))

(define-syntax define-condition-type
  (syntax-rules ()
    ((define-condition-type ?name ?supertype ?predicate
       (?field1 ?accessor1) ...)
     (begin
       (define ?name
         (make-condition-type '?name
                              ?supertype
                              '(?field1 ...)))
       (define (?predicate thing)
         (and (condition? thing)
              (condition-has-type? thing ?name)))
       (define (?accessor1 condition)
         (condition-ref condition ?name '?field1))
       ...))))

(define (condition-subtype? subtype supertype)
  (let recur ((subtype subtype))
    (cond ((not subtype) #f)
          ((eq? subtype supertype) #t)
          (else
           (recur (condition-type-supertype subtype))))))

(define (condition-type-field-supertype condition-type field)
  (let loop ((condition-type condition-type))
    (cond ((not condition-type) #f)
          ((memq field (condition-type-fields condition-type))
           condition-type)
          (else
           (loop (condition-type-supertype condition-type))))))


(define-record-type (:simple-condition make-simple-condition simple-condition?)
  (fields
   (immutable type simple-condition-type)
   (immutable field-alist simple-condition-field-alist)))

(define-record-type (:condition really-make-condition condition?)
  (fields
   (immutable simple-conditions explode-condition)))

(define (condition->list con)
  (map list (explode-condition con)))

(define (make-condition type alist)
  (if (not (list-set-eq? (map car alist)
			 (condition-type-all-fields type)))
      (assertion-violation 'make-condition
			   "condition fields don't match condition type"
			   type
			   (condition-type-all-fields type)
			   alist))
  (really-make-condition
   (list (make-simple-condition type alist))))

(define (condition-has-type? condition type)
  (any? (lambda (simple)
	  (condition-subtype? (simple-condition-type simple) type))
	(explode-condition condition)))

(define (condition-ref condition type field)
  (let loop ((simples (explode-condition condition)))
    (if (null? simples)
	(assertion-violation 'condition-ref
			     "subtype not found"
			     condition type)
	(let ((simple (car simples)))
	  (if (condition-subtype? (simple-condition-type simple) type)
	      (cdr (assq field (simple-condition-field-alist simple)))
	      (loop (cdr simples)))))))

(define (make-compound-condition . conditions)
  (really-make-condition
   (apply append (map explode-condition conditions))))

(define-syntax condition
  (syntax-rules ()
    ((condition (?type1 (?field1 ?value1) ...) ...)
     (make-compound-condition
      (make-condition ?type1
		      (list (cons '?field1 ?value1) ...))
      ...))))

;; Utilities, defined locally to avoid having to load SRFI 1

;; (These need to come before the standard condition types below.)

(define (elements-in-common? list-1 list-2)
  (any? (lambda (element-1)
	  (memq element-1 list-2))
	list-1))

(define (list-set<=? list-1 list-2)
  (every? (lambda (element-1)
	    (memq element-1 list-2))
	  list-1))

(define (list-set-eq? list-1 list-2)
  (and (list-set<=? list-1 list-2)
       (list-set<=? list-2 list-1)))

(define (list-set-difference list-1 list-2)
  (filter (lambda (element-1)
	    (not (memq element-1 list-2)))
	  list-1))

(define (filter-map f l)
  (let loop ((l l) (r '()))
    (cond ((null? l)
	   (reverse r))
          ((f (car l))
           => (lambda (x)
                (loop (cdr l) (cons x r))))
          (else
	   (loop (cdr l) r)))))

(define (first pred list)
  (let loop ((list list))
    (cond ((null? list)
	   #f)
          ((pred (car list))
	   (car list))
          (else
	   (loop (cdr list))))))

(define (any? proc list)
  (let loop ((list list))
    (cond ((null? list)
	   #f)
          ((proc (car list))
	   #t)
          (else
	   (loop (cdr list))))))

(define (every? pred list)
  (let loop ((list list))
    (cond ((null? list)
	   #t)
          ((pred (car list))
	   (loop (cdr list)))
          (else
	   #f))))

(define (filter pred l)
  (let loop ((l l) (r '()))
    (cond ((null? l)
	   (reverse r))
          ((pred (car l))
	   (loop (cdr l) (cons (car l) r)))
          (else
	   (loop (cdr l) r)))))

;; Standard condition types

(define &condition (really-make-condition-type '&condition
                                               #f
                                               '()
                                               '()))

(define-condition-type &message &condition
  message-condition?
  (message condition-message))

(define-condition-type &warning &condition
  warning?)

(define-condition-type &serious &condition
  serious-condition?)

(define-condition-type &error &serious
  error?)

(define-condition-type &violation &serious
  violation?)

(define-condition-type &non-continuable &violation
  non-continuable?)

(define-condition-type &implementation-restriction
    &violation
  implementation-restriction?)

(define-condition-type &defect &violation
  defect?)

(define-condition-type &lexical &defect
  lexical-violation?)

(define-condition-type &syntax &violation
  syntax-violation?
  (form syntax-violation-form)
  (subform syntax-violation-subform))

(define-condition-type &undefined &defect
  undefined-violation?)

(define-condition-type &assertion &defect
  assertion-violation?)

(define-condition-type &irritants &condition
  irritants-condition?
  (irritants condition-irritants))

(define-condition-type &who &condition
  who-condition?
  (who condition-who))

(define (assertion-violation who message . irritants)
  (raise
   (condition
    (&who (who who))
    (&message (message message))
    (&irritants (irritants irritants)))))

; Completing exceptions library

(set-operate-non-continuable!
 (lambda (raise who . irritants)
   (raise
    (condition
    (&who (who who))
    (&message (message "returned from non-continuable exception"))
    (&irritants (irritants irritants))))))

(set-operate-unhandled!
 (lambda (abort cond)
   (if (serious-condition? cond)
       (abort "unhandled serious exception")
       (begin
	 (put-string (standard-error-port) "unhandled non-serious exception")
	 (if (message-condition? cond)
	     (begin
	       (put-string (standard-error-port) ": ")
	       (put-string (standard-error-port) (condition-message cond))))))))

) ; end of library form
