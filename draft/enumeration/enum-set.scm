; Copyright (c) 1993-2006 by Richard Kelsey and Jonathan Rees. See file COPYING.

; Sets over finite types.

; ,open syntactic-record-types/explicit bitwise srfi-1 srfi-23

(define-syntax define-enum-set-type
  (syntax-rules ()
    ((define-enum-set-type ?constructor-syntax ?constructor ?predicate
       ?enum-type ?enum-elements-proc ?enum-index)
     (begin
       (define <type>
	 (make-enum-set-type '?constructor-name
			     (?enum-elements-proc)
			     ?enum-index))

       (define (?predicate x)
	 (and (enum-set? x)
	      (eq? (enum-set-type x)
		   <type>)))

       (define (<constructor> elements)
	 (if (every ?enum-index elements)
	     (make-enum-set <type> (elements->mask elements ?enum-index))
	     (error "invalid set elements" ?enum-index elements)))

       (define-syntax <helper>
	 (syntax-rules ()
	   ((<helper> (?name . ?rest) ?elements)
	    (<helper> ?rest ((?enum-type ?name) . ?elements)))
	   ((<helper> () ?elements)
	    (<constructor> (list . ?elements)))))

       (define ?constructor <constructor>)

       (define-syntax ?constructor-syntax
	 (syntax-rules ()
	   ((?constructor-syntax . ?names)
	    (<helper> ?names ()))))))))


(define-record-type (enum-set-type make-enum-set-type enum-set-type?)
 (fields
   (immutable id        enum-set-type-id)
   (immutable values    enum-set-type-values)
   (immutable index-ref enum-set-type-index-ref)))

(define (enum-set-universe enum-set)
  ;; vector-copy for the lazy
  (list->vector (vector->list (enum-set-type-values (enum-set-type enum-set)))))

; The mask is settable to allow for destructive operations.  There aren't
; any such yet.

(define-record-type (enum-set make-enum-set enum-set?)
  (fields
   (immutable type enum-set-type)
   (mutable mask enum-set-mask set-enum-set-mask!)))

(define (make-set-constructor id predicate values index-ref)
  (let ((type (make-enum-set-type id predicate values index-ref)))
    (lambda elements
      (if (every predicate elements)
	  (make-enum-set type (elements->mask elements index-ref))
	  (error "invalid set elements" predicate elements)))))

(define (elements->mask elements index-ref)
  (do ((elements elements (cdr elements))
       (mask 0
	     (bitwise-ior mask
			  (arithmetic-shift 1 (index-ref (car elements))))))
      ((null? elements)
       mask)))
				  
(define (enum-set-member? element enum-set)
  (if ((enum-set-type-index-ref (enum-set-type enum-set))
       element)
      (not (= (bitwise-and (enum-set-mask enum-set)
			   (element-mask element (enum-set-type enum-set)))
	      0))
      (error "invalid arguments" enum-set-member? element enum-set)))

(define (enum-set-subset? enum-set0 enum-set1)
  (cond
   ((eq? (enum-set-type enum-set0)
	 (enum-set-type enum-set1))
    (= (bitwise-ior (enum-set-mask enum-set0)
		    (enum-set-mask enum-set1))
       (enum-set-mask enum-set1)))
   ((enum-set-universe<=? enum-set0 enum-set1)
    (enum-set-members<=? enum-set0 enum-set1))
   (else
    (error "invalid arguments" enum-set-subset? enum-set0 enum-set1))))

; #### expensive
(define (enum-set-universe<=? enum-set0 enum-set1)
  (let ((u0 (enum-set-universe enum-set0))
	(u1 (enum-set-universe enum-set1)))
    (lset<= (vector->list u0) (vector->list u1))))

(define (enum-set-members<=? enum-set0 enum-set1)
  (lset<= (enum-set->list enum-set0) (enum-set->list enum-set1)))

(define (enum-set=? enum-set0 enum-set1)
  (cond
   ((eq? (enum-set-type enum-set0)
	 (enum-set-type enum-set1))
    (= (enum-set-mask enum-set0) 
       (enum-set-mask enum-set1)))
   ((enum-set-universe=? enum-set0 enum-set1)
    (enum-set-members=? enum-set0 enum-set1))
   (else
    (error "invalid arguments" enum-set=? enum-set0 enum-set1))))

(define (enum-set-universe=? enum-set0 enum-set1)
  (let ((u0 (enum-set-universe enum-set0))
	(u1 (enum-set-universe enum-set1)))
    (lset= (vector->list u0) (vector->list u1))))

(define (enum-set-members=? enum-set0 enum-set1)
  (lset= (enum-set->list enum-set0) (enum-set->list enum-set1)))

(define (element-mask element enum-set-type)
  (arithmetic-shift 1
		    ((enum-set-type-index-ref enum-set-type) element)))

; To reduce the number of bitwise operations required we bite off two bytes
; at a time.

(define (enum-set->list enum-set)
  (let ((values (enum-set-type-values (enum-set-type enum-set))))
    (do ((i 0 (+ i 16))
	 (mask (enum-set-mask enum-set) (arithmetic-shift mask -16))
	 (elts '()
	       (do ((m (bitwise-and mask #xFFFF) (arithmetic-shift m -1))
		    (i i (+ i 1))
		    (elts elts (if (odd? m)
				   (cons (vector-ref values i)
					 elts)
				   elts)))
		   ((= m 0)
		    elts))))
	((= mask 0)
	 (reverse elts)))))

(define (enum-set-union enum-set0 enum-set1)
  (if (eq? (enum-set-type enum-set0)
	   (enum-set-type enum-set1))
      (make-enum-set (enum-set-type enum-set0)
		     (bitwise-ior (enum-set-mask enum-set0)
				  (enum-set-mask enum-set1)))
      (error "invalid arguments" enum-set-union enum-set0 enum-set1)))

(define (enum-set-intersection enum-set0 enum-set1)
  (if (eq? (enum-set-type enum-set0)
	   (enum-set-type enum-set1))
      (make-enum-set (enum-set-type enum-set0)
		     (bitwise-and (enum-set-mask enum-set0)
				  (enum-set-mask enum-set1)))
      (error "invalid arguments" enum-set-union enum-set0 enum-set1)))

(define (enum-set-complement enum-set)
  (let* ((type (enum-set-type enum-set))
	 (mask (- (arithmetic-shift 1
				    (vector-length (enum-set-type-values type)))
		  1)))
    (make-enum-set type
		   (bitwise-and (bitwise-not (enum-set-mask enum-set))
				mask))))

(define-enum-set-type color-set make-color-set color-set?
  color colors color-index)
