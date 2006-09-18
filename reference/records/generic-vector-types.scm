; Vector types for R6RS Records

;; Base on the SRFI implementation:
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

;; This layer:
;;  Does need to support inheritance
;;  Doesn't need to support immutability (but immutability 
;;   information is provided in case it's useful)
;;  Does need to enforce types at selectors and arity for the
;;   constructor
;;  Does need to implement generativity
;;  Does not need to implement opacity for inspection purposes,
;;   but does need to implement any sort of opacaity with respect
;;   to non-R6RS features that the implementation would like
;;   to provide (since generativity covers opacity within the
;;   bounds of R6RS); opacity is implemented here via an imported
;;   library of opaque cells

(library (implementation vector-types)
  (export make-vector-type
	  vector-type?
	  vector-type-data
	  vector-type-predicate
	  typed-vector-constructor
	  typed-vector-accessor typed-vector-mutator
	  typed-vector?
	  typed-vector-type)
  (import (r6rs)
	  (implementation opaque-cells)
	  (srfi-9))

  (define vector-key (make-string 1 #\k))

  (define-record-type :vector-type
    (really-make-vector-type supertype data field-count opaque?)
    vector-type?
    (supertype vector-type-supertype)
    (data vector-type-data)
    (field-count vector-type-field-count)
    (opaque? vector-type-opaque?))
  
  (define (make-vector-type name supertype data field-mutability opaque?)
    (really-make-vector-type supertype data (length field-mutability) opaque?))

  ;; does TYPE-1 represent an ancestor of TYPE-2?
  (define (type-ancestor? type-1 type-2)
    (let recur ((type-2 type-2))
      (or (eq? type-1 type-2)
	  (let ((super (vector-type-supertype type-2)))
	    (and super
		 (recur super))))))
  
  ;; Typed vectors
  
  (define-record-type :typed-vector
    (really-make-typed-vector type components)
    typed-vector?
    (type typed-vector-type)
    ;; the following are begging to be unboxed
    (components typed-vector-components))

  (define (vector-type-predicate type)
    (lambda (thing)
      (let ((thing (if (opaque-cell? thing)
		       (opaque-cell-ref vector-key thing)
		       thing)))
	(and (typed-vector? thing)
	     (type-ancestor? type
			     (typed-vector-type thing))))))
    
  (define (typed-vector-constructor type)
    (let ((expected (vector-type-field-count type))
	  (opacify  (if (vector-type-opaque? type)
			(lambda (v)
			  (make-opaque-cell (lambda (access-key)
					      (eq? access-key vector-key))
					    v))
			(lambda (v) v))))
      (lambda vals
	(if (= (length vals) expected)
	    (opacify (really-make-typed-vector type (list->vector vals)))
	    (contract-violation "wrong argument count to constructor" type vals)))))

  (define (ensure-has-vector-type type thing)
    (if (not (and (typed-vector? thing)
		  (type-ancestor? type
				  (typed-vector-type thing))))
	(contract-violation "invalid argument: not of type" type thing)))
  
  (define (typed-vector-accessor type index)
    (lambda (thing)
      (let ((thing (if (opaque-cell? thing)
		       (opaque-cell-ref vector-key thing)
		       thing)))
	(ensure-has-vector-type type thing)
	(vector-ref (typed-vector-components thing) index))))

  (define (typed-vector-mutator type index)
    (lambda (thing val)
      (let ((thing (if (opaque-cell? thing)
		       (opaque-cell-ref vector-key thing)
		       thing)))
	(ensure-has-vector-type type thing)
	(vector-set! (typed-vector-components thing) 
		     index
		     val)))))
