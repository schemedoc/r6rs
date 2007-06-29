
(library (srfi-9)
  (export define-record-type)
  (import (rnrs)
          (implementation make-struct-type))

  (define-syntax define-values
    (lambda (stx)
      (syntax-case stx ()
	[(_ (id ...) expr)
	 (with-syntax ([(tmp ...) (generate-temporaries (syntax (id ...)))])
	   (syntax
	    (begin
	      (define id 'unspecified) ...
	      (define hack
		(call-with-values (lambda () expr)
		  (lambda (tmp ...)
		    (set! id tmp) ...))))))])))
	
  (define-syntax define-record-type
	  
    (let ()
      (define (filter-map proc l)
	(if (null? l)
	    '()
	    (let ((result (proc (car l))))
	      (if result
		  (cons result (filter-map proc (cdr l)))
		  (filter-map proc (cdr l))))))
	    
	    
      (define (syntax-member? thing stuff)
	(cond
	 ((null? stuff) #f)
	 ((free-identifier=? thing (car stuff)) #t)
	 (else (syntax-member? thing (cdr stuff)))))
	    
      (lambda (x)
	(syntax-case x ()
	  ((_ type
	      (constructor constructor-tag ...)
	      predicate
	      (field-tag accessor more ...) ...)
			    
			    
	   (with-syntax
	       ((number-of-fields (length (syntax (field-tag ...))))
		((modifier ...)
		 (filter-map (lambda (descriptor)
			       (syntax-case descriptor ()
				 ((field-tag accessor) #f)
				 ((field-tag accessor modifier)
				  (syntax modifier))))
			     (syntax ((field-tag accessor more ...) ...))))
		((constructor-arg ...)
		 (map (lambda (field-tag)
			(if (syntax-member? field-tag
					    (syntax (constructor-tag ...)))
			    field-tag
			    (syntax (void))))
		      (syntax (field-tag ...))))
		(generic-access (syntax generic-access))
		(generic-mutate (syntax generic-mutate)))
	     (with-syntax
		 (((accessor-proc ...)
		   (let loop ((i 0)
			      (fields (syntax (field-tag ...))))
		     (if (null? fields)
			 '()
			 (cons (with-syntax
				   ((i i))
				 (syntax
				  (lambda (s)
				    (generic-access s i)))) 
			       (loop (+ 1 i)
				     (cdr fields))))))
		  ((modifier-proc ...)
		   (let loop ((i 0)
			      (descriptors
			       (syntax ((field-tag accessor more ...) ...))))
		     (if (null? descriptors)
			 '()
			 (syntax-case (car descriptors) ()
			   ((field-tag accessor)
			    (loop (+ 1 i)
				  (cdr descriptors)))
			   ((field-tag accessor modifier)
			    (cons (with-syntax
				      ((i i))
				    (syntax
				     (lambda (s v)
				       (generic-mutate s i v))))
				  (loop (+ 1 i)
					(cdr descriptors)))))))))
	       (syntax
		(define-values (constructor
				predicate
				accessor ...
				modifier ...)
		  (call-with-values 
		      (lambda () 
			(make-struct-type 'type number-of-fields))
		      (lambda (type-descriptor
			       full-constructor
			       predicate
			       generic-access
			       generic-mutate)
			(values (lambda (constructor-tag ...)
				  (full-constructor constructor-arg ...))
				predicate
				accessor-proc ...
				modifier-proc ...)))))))))))))
