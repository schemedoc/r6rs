; Reference implementation for conditions library

; Copyright (C) Michael Sperber (2007). All Rights Reserved.

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
  (export condition
	  condition?
	  simple-conditions
	  condition-predicate
	  condition-accessor
	  define-condition-type
	  &condition
	  &message
	  make-message-condition
	  message-condition?
	  condition-message
	  &warning
	  make-warning
	  warning?
	  &serious
	  make-serious-condition
	  serious-condition?
	  &error
	  make-error
	  error?
	  &violation
	  make-violation
	  violation?
	  &non-continuable
	  make-noncontinuable
	  non-continuable?
	  &implementation-restriction
	  make-implementation-restriction
	  implementation-restriction?
	  &lexical
	  make-lexical-violation
	  lexical-violation?
	  &syntax
	  make-syntax-violation
	  syntax-violation?
	  &undefined
	  make-undefined-violation
	  undefined-violation?
	  &assertion
	  make-assertion-violation
	  assertion-violation?
	  &irritants
	  make-irritants-condition
	  irritants-condition?
	  condition-irritants
	  &who
	  make-who-condition
	  who-condition?
	  condition-who

	  assertion-violation)
  (import (r6rs base)
	  (r6rs records explicit)
	  (r6rs i/o ports)
	  (r6rs conditions internal))

(define-record-type (&condition make-simple-condition simple-condition?))

(define-record-type (:compound-condition make-compound-condition compound-condition?)
  (fields
   (immutable components explode-condition)))

(define (simple-conditions con)
  (cond
   ((simple-condition? con)
    (list con))
   ((compound-condition? con)
    (map list (explode-condition con)))
   (else
    (assertion-violation 'simple-conditions
			 "not a condition"
			 con))))

(define (condition? thing)
  (or (simple-condition? thing)
      (compound-condition? thing)))

(define (condition . components)
  (make-compound-condition
   (apply append
	  (map (lambda (component)
		 (cond
		  ((simple-condition? component)
		   (list component))
		  ((compound-condition? component)
		   (explode-condition component))
		  (else
		   (assertion-violation? 'condition
					 "component wasn't a condition"
					 component))))
	       components))))

  ;; does RTD-1 represent an ancestor of RTD-2?
(define (rtd-ancestor? rtd-1 rtd-2)
  (let loop ((rtd-2 rtd-2))
    (or (eq? rtd-1 rtd-2)
	(and rtd-2
	     (loop (record-type-parent rtd-2))))))

(define (condition-predicate rtd)
  (if (not (rtd-ancestor? (record-type-descriptor &condition)
			  rtd))
      (assertion-violation? 'condition-predicate
			    "not a subtype of &condition"
			    rtd))
  (let ((simple-pred (record-predicate rtd)))
    (lambda (con)
      (cond
       ((simple-condition? con)
	(simple-pred condition))
       ((compound-condition? con)
	(any? simple-pred (explode-condition con)))
       (else #f)))))

(define (condition-accessor rtd simple-access)
  (if (not (rtd-ancestor? (record-type-descriptor &condition)
			  rtd))
      (assertion-violation? 'condition-predicate
			    "not a subtype of :simple-condition"
			    rtd))
  (let ((simple-pred (record-predicate rtd)))
    (lambda (con)
    (cond
     ((simple-condition? con)
      (simple-access con))
     ((compound-condition? con)
      (cond
       ((first simple-pred (explode-condition con))
	=> simple-access)
       (else
	(assertion-violation? '<condition-accessor>
			      "condition isn't of type"
			      con rtd))))
     (else
      (assertion-violation? '<condition-accessor>
			    "condition isn't of type"
			    con rtd))))))

(define-syntax define-condition-type
  (syntax-rules ()
    ((define-condition-type ?name ?supertype ?constructor ?predicate
       (?field1 ?accessor1) ...)
     (define-condition-type-helper
       ?name ?supertype ?constructor ?predicate
       ((?field1 ?accessor1) ...)
       ()))))

(define-syntax define-condition-type-helper
  (syntax-rules ()
    ((define-condition-type-helper
       ?name ?supertype ?constructor ?predicate
       ((?field1 ?accessor1) ?rest ...)
       (?spec1 ...))
     (define-condition-type-helper
       ?name ?supertype ?constructor ?predicate
       (?rest ...)
       (?spec1 ... (?field1 ?accessor1 temp-condition-accessor))))
    ((define-condition-type-helper
       ?name ?supertype ?constructor ?predicate
       ()
       ((?field1 ?accessor1 ?condition-accessor1) ...))
     (begin
       (define-record-type (?name ?constructor record-predicate)
	 (parent ?supertype)
	 (fields
	  (immutable ?field1 ?accessor1) ...))
       
       (define ?predicate (condition-predicate (record-type-descriptor ?name)))

       (define ?condition-accessor1
	 (condition-accessor (record-type-descriptor ?name)
			     ?accessor1))
       ...))))
       
;; Utilities, defined locally to avoid having to load SRFI 1

;; (These need to come before the standard condition types below.)

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

;; Standard condition types

(define-condition-type &message &condition 
  make-message-condition message-condition?
  (message condition-message))

(define-condition-type &warning &condition
  make-warning warning?)

(define-condition-type &serious &condition
  make-serious-condition serious-condition?)

(define-condition-type &error &serious
  make-error error?)

(define-condition-type &violation &serious
  make-violation violation?)

(define-condition-type &non-continuable &violation
  make-noncontinuable non-continuable?)

(define-condition-type &implementation-restriction &violation
  make-implementation-restriction implementation-restriction?)

(define-condition-type &lexical &violation
  make-lexical-violation lexical-violation?)

(define-condition-type &syntax &violation
  make-syntax-violation syntax-violation?
  (form syntax-violation-form)
  (subform syntax-violation-subform))

(define-condition-type &undefined &violation
  make-undefined-violation undefined-violation?)

(define-condition-type &assertion &violation
  make-assertion-violation assertion-violation?)

(define-condition-type &irritants &condition
  make-irritants-condition irritants-condition?
  (irritants condition-irritants))

(define-condition-type &who &condition
  make-who-condition who-condition?
  (who condition-who))

(define (assertion-violation who message . irritants)
  (raise
   (condition
    (make-assertion-violation)
    (make-who-condition who)
    (make-message-condition message)
    (make-irritants-condition irritants))))

; Completing exceptions library

(set-operate-non-continuable!
 (lambda (raise who . irritants)
   (raise
    (condition
     (make-who-condition who)
     (make-message-condition "returned from non-continuable exception")
     (make-irritants-condition irritants)))))

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
