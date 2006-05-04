(define-syntax define-enum-type
  (syntax-rules ()
    ((define-enum-type ?macro ?type
       ?predicate
       ?elements
       ?enum-name ?name->enum
       ?enum-index
       (?instance ...))
     (define-enum-type-1
       (?instance ...) () 0
       ?macro ?type
       ?predicate
       ?elements
       ?enum-name ?name->enum
       ?enum-index))))

(define (vector-find vec pred)
  (let ((size (vector-length vec)))
    (let loop ((i 0))
      (if (>= i size)
	  #f
	  (let ((val (vector-ref vec i)))
	    (if (pred val)
		val
		(loop (+ 1 i))))))))

(define-syntax define-enum-type-1
  (syntax-rules ()
    ((define-enum-type-1
       () ((?instance ?instance-id ?instance-index) ...) ?index
       ?macro ?type
       ?predicate
       ?elements
       ?enum-name ?name->enum
       ?enum-index)
     (begin
       (define-record-type (?type make-enum ?predicate)
	 (fields
	  (immutable index ?enum-index)
	  (immutable name ?enum-name)))

       (define ?instance-id
	 (make-enum ?instance-index '?instance))
       ...

       (define ?elements
	 (vector ?instance-id ...))

       (define-syntax ?macro
	 (syntax-rules (?instance ...)
	   ((?macro ?instance) ?instance-id)
	   ...))

       (define (?name->enum name)
	 (vector-find ?elements
		      (lambda (instance)
			(eq? name (?enum-name instance)))))))

    ((define-enum-type-1
       (?instance1 ?instance ...) (?info ...) ?index
       ?macro ?type
       ?predicate
       ?elements
       ?enum-name ?name->enum
       ?enum-index)
     (define-enum-type-1
       (?instance ...) (?info ... (?instance1 temp ?index)) (+ 1 ?index)
       ?macro ?type
       ?predicate
       ?elements
       ?enum-name ?name->enum
       ?enum-index))))

(define-enum-type color :color
  color?
  colors
  color-name name->color
  color-index
  (black white purple maroon))
