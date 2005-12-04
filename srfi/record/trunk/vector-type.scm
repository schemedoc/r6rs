; Vector types

(define-record-type :vector-type
  (make-vector-type name supertypes data)
  vector-type?
  (name vector-type-name)
  (supertypes vector-type-supertypes)
  (data vector-type-data))

; does TYPE-1 represent an ancestor of TYPE-2?
(define (type-ancestor? type-1 type-2)
  (let recur ((type-2 type-2))
    (or (eq? type-1 type-2)
	(let loop ((supers (vector-type-supertypes type-2)))
	  (if (null? supers)
	      #f
	      (or (recur (car supers))
		  (loop (cdr supers))))))))

; Typed vectors

(define-record-type :typed-vector
  (really-make-typed-vector type immutable? components)
  typed-vector?
  (type typed-vector-type)
  ;; the following are begging to be unboxed
  (immutable? typed-vector-immutable? set-typed-vector-immutable?!)
  (components typed-vector-components))

(define (has-vector-type? type thing)
  (and (typed-vector? thing)
       (type-ancestor? type
		      (typed-vector-type thing))))

(define (make-typed-vector type size)
  (really-make-typed-vector type #f (make-vector size)))

(define (typed-vector type . vals)
  (really-make-typed-vector type #f (list->vector vals)))

(define (ensure-has-vector-type type typed-vector)
  (if (not (has-vector-type? type typed-vector))
      (error "invalid argument: not of type" type typed-vector)))

(define (typed-vector-length type typed-vector)
  (ensure-has-vector-type type typed-vector)
  (vector-length (typed-vector-components typed-vector)))

(define (typed-vector-ref type typed-vector index)
  (ensure-has-vector-type type typed-vector)
  (vector-ref (typed-vector-components typed-vector) index))

(define (typed-vector-set! type typed-vector index val)
  (ensure-has-vector-type type typed-vector)
  (if (typed-vector-immutable? typed-vector)
      (error "typed vector immutable" typed-vector))
  (vector-set! (typed-vector-components typed-vector)
	       index
	       val))

(define (make-typed-vector-immutable! typed-vector)
  (set-typed-vector-immutable?! typed-vector #t))
