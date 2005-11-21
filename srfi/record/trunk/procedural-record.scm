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

(define-record-type :field-spec
  (make-field-spec mutable? name)
  field-spec?
  (mutable? field-spec-mutable?)
  (name field-spec-name))

(define (field-spec=? spec-1 spec-2)
  (and (eq? (field-spec-mutable? spec-1)
	    (field-spec-mutable? spec-2))
       (eq? (field-spec-name spec-1)
	    (field-spec-name spec-2))))

(define-record-type :record-type-descriptor
  (really-make-record-type-descriptor name parent uid sealed? opaque? field-specs)
  record-type-descriptor?
  (name record-type-name)
  (parent record-type-parent)
  ;; this is #f in the generative case
  (uid record-type-uid)
  (sealed? record-type-sealed?)
  (opaque? record-type-opaque?)
  (field-specs record-type-field-specs))

(define (record-type-descriptor=? rtd-1 rtd-2)
  (and (eq? (record-type-parent rtd-1) (record-type-parent rtd-2))
       (eq? (record-type-uid rtd-1) (record-type-uid rtd-2))
       (every field-spec=?
	      (record-type-field-specs rtd-1)
	      (record-type-field-specs rtd-2))))

(define (uid->record-type-descriptor uid)
  (find (lambda (rtd)
	  (eq? (record-type-uid rtd) uid))
	*nongenerative-record-types*))

(define (record-type-generative? rtd)
  (not (record-type-uid rtd)))

(define *nongenerative-record-types* '())

(define (make-record-type-descriptor name parent uid sealed? opaque? field-specs)
  (if (and parent
	   (record-type-sealed? parent))
      (error "can't extend a sealed parent class" parent))
  (if (and parent
	   (not (record-type-uid parent)) ; parent generative
	   uid)			  ; ... but this one is non-generative
      (error "a generative type can only be extended to give a generative type" parent))
  (if (not (= (length field-specs)
	      (length (delete-duplicates (map cadr field-specs)))))
      (error "duplicate field name" field-specs))
  (let ((opaque? (if parent
		     (or (record-type-opaque? parent)
			 opaque?)
		     opaque?))
	(field-specs (map parse-field-spec field-specs)))
    (let ((rtd (really-make-record-type-descriptor name parent uid sealed? opaque? field-specs)))
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
	  rtd))))

(define (parse-field-spec spec)
  (apply (lambda (mutability name)
	   (make-field-spec
	    (case mutability
	      ((mutable) #t)
	      ((immutable) #f)
	      (else (error "field spec with invalid mutability specification" spec)))
	    name))
	 spec))

(define (record-type-field-names rtd)
  (map field-spec-name (record-type-field-specs rtd)))

(define (field-count rtd)
  (let loop ((rtd rtd)
	     (count 0))
    (if (not rtd)
	count
	(loop (record-type-parent rtd)
	      (+ count (length (record-type-field-specs rtd)))))))
	 

(define (field-index rtd field)
  (+ (field-count (record-type-parent rtd))
     (cond
      ((list-index (cut eq? field <>) (record-type-field-names rtd)))
      (else
       (error "record type has no such field" rtd field)))))

(define-record-type :record
  (really-make-record rtd components)
  any-record?
  (rtd actual-record-type-descriptor)
  (components record-components))

(define (record? r)
  (and (any-record? r)
       (not (record-type-opaque? (actual-record-type-descriptor r)))))

(define (make-record rtd component-count)
  (really-make-record rtd
		      (make-vector component-count)))

; for internal purposes only
(define (record-copy r)
  (really-make-record (actual-record-type-descriptor r)
		      (vector-copy (record-components r))))

(define (vector-copy v)
  (let* ((size (vector-length v))
	 (c (make-vector size)))
    (do ((i 0 (+ 1 i)))
	((>= i size))
      (vector-set! c i (vector-ref v i)))
    c))

(define (record-type-descriptor r)
  (let ((rtd (actual-record-type-descriptor r)))
    (if (record-type-opaque? rtd)
	(error "tried to obtain record-type descriptor from object of unknown type" r)
	rtd)))

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
  (and (any-record? obj)
       (rtd-ancestor? rtd (actual-record-type-descriptor obj))))

(define (record-predicate rtd)
  (cut record-with-rtd? <> rtd))

(define (record-accessor rtd field-id)
  (let ((index (field-id-index rtd field-id)))
    (lambda (thing)
      (if (record-with-rtd? thing rtd)
	  (record-ref thing index)
	  (error "accessor applied to bad value" rtd field-id thing)))))

(define (record-mutator rtd field-id)
  (if (not (field-spec-mutable? (field-spec-ref rtd field-id)))
      (error "record-mutator called on immutable field" rtd field-id))
  (let ((index (field-id-index rtd field-id)))
    (lambda (thing val)
      (if (record-with-rtd? thing rtd)
	  (record-set! thing index val)
	  (error "mutator applied to bad value" rtd field-id thing val)))))

(define (record-updater rtd field-ids)
  (let ((indices (map (cut field-id-index rtd <>) field-ids)))
    (lambda (thing . vals)
      (if (record-with-rtd? thing rtd)
	  (let ((c (record-copy thing)))
	    (for-each (cut record-set! c <> <>)
		      indices vals)
	    c)
	  (error "updater applied to bad value" rtd field-ids thing vals)))))

; A FIELD-ID may be either an index or a symbol, which needs to refer
; to a field in RTD itself.
(define (field-id-index rtd field-id)
  (if (integer? field-id)
      (+ (field-count (record-type-parent rtd))
	 field-id)
      (field-index rtd field-id)))

(define (record-field-mutable? rtd field-id)
  (field-spec-mutable? (field-spec-ref rtd field-id)))

(define (field-spec-ref rtd field-id)
  
  (define (nth rtd index)
    (list-ref (record-type-field-specs rtd) index))
  
  (cond
   ((number? field-id)
    (nth rtd (field-index rtd field-id)))
   ((symbol? field-id)
    (let loop ((rtd rtd))
      (cond
       ((not rtd)
	(error "invalid field spec" rtd field-id))
       ((list-index (cut eq? field-id <>) (record-type-field-names rtd))
	=> (cut nth rtd <>))
       (else
	(loop (record-type-parent rtd))))))
   (else
    (error "invalid field spec" rtd field-id))))
	     
       

   

