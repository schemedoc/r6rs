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

(define make-field-spec cons)

(define field-spec-mutable? car)
(define field-spec-name cdr)

(define (field-spec=? spec-1 spec-2)
  (and (eq? (field-spec-mutable? spec-1)
	    (field-spec-mutable? spec-2))
       (eq? (field-spec-name spec-1)
	    (field-spec-name spec-2))))

(define :record-type-data (make-vector-type 'vector-type-descriptor '() #f))

(define (really-make-record-type-data uid sealed? opaque? field-specs immutable?)
  (typed-vector :record-type-data
		uid sealed? opaque? field-specs immutable?))

(define (make-record-type-data uid sealed? opaque? field-specs)
  (really-make-record-type-data 
   uid sealed? opaque? field-specs
   (and (not (any field-spec-mutable? field-specs)) #t)))

(define (record-type-data? thing)
  (has-vector-type? :record-type-data thing))

; this is #f in the generative case
(define (record-type-uid rtd)
  (typed-vector-ref :record-type-data (vector-type-data rtd) 0))
(define (record-type-sealed? rtd)
  (typed-vector-ref :record-type-data (vector-type-data rtd) 1))
(define (record-type-opaque? rtd)
  (typed-vector-ref :record-type-data (vector-type-data rtd) 2))
(define (record-type-field-specs rtd)
  (typed-vector-ref :record-type-data (vector-type-data rtd) 3))
(define (record-type-immutable? rtd)
  (typed-vector-ref :record-type-data (vector-type-data rtd) 4))

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
    (let ((rtd 
	   (make-vector-type name
			     (if parent (list parent) '())
			     (make-record-type-data uid sealed? opaque? field-specs))))
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

(define (record-type-descriptor? thing)
  (and (vector-type? thing)
       (record-type-data? (vector-type-data thing))))

(define (ensure-rtd thing)
  (if (not (record-type-descriptor? thing))
      (error "not a record-type descriptor" thing)))

(define (record-type-name rtd)
  (ensure-rtd rtd)
  (vector-type-name rtd))

(define (record-type-parent rtd)
  (ensure-rtd rtd)
  (let ((supertypes (vector-type-supertypes rtd)))
    (if (null? supertypes)
	#f
	(car supertypes))))

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

(define (record? thing)
  (and (typed-vector? thing)
       (record-type-descriptor? (typed-vector-type thing))))

(define (make-record rtd size)
  (make-typed-vector rtd size))

(define (record rtd . components)
  (apply typed-vector rtd components))

(define (record-type-descriptor rec)
  (typed-vector-type rec))

(define (record-ref rtd rec index)
  (typed-vector-ref rtd rec index))

(define (record-set! rtd rec index val)
  (typed-vector-set! rtd rec index val))

(define (make-record-immutable! r)
  (make-typed-vector-immutable! r))

; does RTD-1 represent an ancestor of RTD-2?

; This suggests the corresponding procedure in VECTOR-TYPES should be
; abstracted out.

(define (rtd-ancestor? rtd-1 rtd-2)
  (let loop ((rtd-2 rtd-2))
    (or (eq? rtd-1 rtd-2)
	(and rtd-2
	     (loop (record-type-parent rtd-2))))))

(define (record-constructor rtd)
  (let ((component-count (field-count rtd))
	(wrap (if (record-type-opaque? rtd)
		  (lambda (r)
		    (make-opaque-cell (lambda (access-key)
					(and (record-type-descriptor? access-key)
					     (rtd-ancestor? access-key rtd)))
			      r))
		  (lambda (r) r))))
    (lambda components
      (if (not (= (length components) component-count))
	  (error "wrong number of arguments to record constructor" rtd components))
      (let ((r (apply record rtd components)))
	(if (record-type-immutable? rtd)
	    (make-record-immutable! r))
	(wrap r)))))

(define (record-with-rtd? obj rtd)
  (has-vector-type? rtd obj))

(define (record-predicate rtd)
  (lambda (thing)
    (let ((thing (if (opaque-cell? thing)
		     (opaque-cell-ref rtd thing)
		     thing)))
      (record-with-rtd? thing rtd))))

(define (record-accessor rtd field-id)
  (let ((index (field-id-index rtd field-id)))
    (lambda (thing)
      (let ((thing (if (opaque-cell? thing)
		       (opaque-cell-ref rtd thing)
		       thing)))
	(record-ref rtd thing index)))))

(define (record-mutator rtd field-id)
  (if (not (field-spec-mutable? (field-spec-ref rtd field-id)))
      (error "record-mutator called on immutable field" rtd field-id))
  (let ((index (field-id-index rtd field-id)))
    (lambda (thing val)
      (let ((thing (if (opaque-cell? thing)
		     (opaque-cell-ref rtd thing)
		     thing)))
	(record-set! rtd thing index val)))))

(define (record-copy r)
  (let* ((rtd (record-type-descriptor r))
	 (size (typed-vector-length rtd r))
	 (c (make-record rtd size)))
    (do ((i 0 (+ 1 i)))
	((>= i size))
      (record-set! rtd c i (record-ref rtd r i)))
    c))

(define (record-updater rtd field-ids)
  (let ((indices (map (cut field-id-index rtd <>) field-ids)))
    (lambda (thing . vals)
      (let ((thing (if (opaque-cell? thing)
		       (opaque-cell-ref rtd thing)
		       thing)))
	(if (record-with-rtd? thing rtd)
	    (let ((c (record-copy thing)))
	      (for-each (cut record-set! rtd c <> <>)
			indices vals)
	      c)
	    (error "updater applied to bad value" rtd field-ids thing vals))))))

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
	     
       

   

