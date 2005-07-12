; Implementation of procedural layer for Records SRFI

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

(define-record-type :record-type-descriptor
  (really-make-record-type-descriptor name parent sealed? uid fields)
  record-type-descriptor?
  (name record-type-name)
  (parent record-type-parent)
  (sealed? record-type-sealed?)
  ;; this is #f in the generative case
  (uid record-type-uid)
  (fields record-type-field-names))

(define (record-type-descriptor=? rtd-1 rtd-2)
  (and (eq? (record-type-name rtd-1) (record-type-name rtd-2))
       (eq? (record-type-parent rtd-1) (record-type-parent rtd-2))
       (eq? (record-type-uid rtd-1) (record-type-uid rtd-2))
       (equal? (record-type-field-names rtd-1)
	       (record-type-field-names rtd-2))))

(define (uid->record-type-descriptor uid)
  (find (lambda (rtd)
	  (eq? (record-type-uid rtd) uid))
	*nongenerative-record-types*))

(define *nongenerative-record-types* '())

(define (make-record-type-descriptor name parent sealed? uid fields)
  (if (and parent
	   (record-type-sealed? parent))
      (error "can't extend a sealed parent class" parent))
  (let ((rtd (really-make-record-type-descriptor name parent sealed? uid fields)))
    (if uid
	(cond
	 ((uid->record-type-descriptor uid)
	  => (lambda (old-rtd)
	       (if (record-type-descriptor=? rtd old-rtd)
		   old-rtd
		   (error "mismatched nongenerative record types with identical uids"
			  old-rtd rtd))))
	 (else
	  (set! *nongenerative-record-types* 
		(cons rtd *nongenerative-record-types*))
	  rtd))
	rtd)))

(define (field-count rtd)
  (let loop ((rtd rtd)
	     (count 0))
    (if (not rtd)
	count
	(loop (record-type-parent rtd)
	      (+ count (length (record-type-field-names rtd)))))))
	 

(define (field-index rtd field)
  (+ (field-count (record-type-parent rtd))
     (cond
      ((list-index (cut eq? field <>) (record-type-field-names rtd)))
      (else
       (error "record type has no such field" rtd field)))))

(define-record-type :record
  (really-make-record rtd components)
  record?
  (rtd record-type-descriptor)
  (components record-components))

(define (make-record rtd component-count)
  (really-make-record rtd
		      (make-vector component-count)))

(define (record-ref record index)
  (vector-ref (record-components record) index))

(define (record-set! record index val)
  (vector-set! (record-components record) index val))

(define (record-constructor rtd)
    (let ((component-count (field-count rtd)))
      (lambda components
	(if (not (= (length components) component-count))
	    (error "wrong number of arguments to record constructor" rtd components))
	(let ((r (make-record rtd component-count)))
	  (let loop ((i 0)
		     (components components))
	    (if (not (null? components))
		(begin
		  (record-set! r i (car components))
		  (loop (+ 1 i) (cdr components)))))
	  r))))

; does RTD-1 represent an ancestor of RTD-2?
(define (rtd-ancestor? rtd-1 rtd-2)
  (let loop ((rtd-2 rtd-2))
    (or (eq? rtd-1 rtd-2)
	(and rtd-2
	     (loop (record-type-parent rtd-2))))))

(define (record-with-rtd? obj rtd)
  (and (record? obj)
       (rtd-ancestor? rtd (record-type-descriptor obj))))

(define (record-predicate rtd)
  (cut record-with-rtd? <> rtd))

(define (record-accessor rtd field-id)
  (let ((index (field-id-index rtd field-id)))
    (lambda (thing)
      (if (record-with-rtd? thing rtd)
	  (record-ref thing index)
	  (error "accessor applied to bad value" rtd field-id thing)))))

(define (record-mutator rtd field-id)
  (let ((index (field-id-index rtd field-id)))
    (lambda (thing val)
      (if (record-with-rtd? thing rtd)
	  (record-set! thing index val)
	  (error "mutator applied to bad value" rtd field-id thing val)))))

; A FIELD-ID may be either an index or a symbol, which needs to refer
; to a field in RTD itself.
(define (field-id-index rtd field-id)
  (if (integer? field-id)
      field-id
      (field-index rtd field-id)))

; dummy implementation
(define (record-field-accessible? rtd field-id)
  (field-id-index rtd field-id) ; for error checking
  #t)

; dummy implementation
(define (record-field-mutable? rtd field-id)
  (field-id-index rtd field-id) ; for error checking
  #t)

