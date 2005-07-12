(define-syntax define-record-type
  (syntax-rules (fields parent nongenerative mutable immutable init!)
    ((define-record-type (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?clause ...)
     (define-record-type-1 ?record-name (?record-name ?constructor-name ?predicate-name)
       ?formals
       ()
       values
       ?clause ...))
    ((define-record-type ?record-name
       ?formals
       ?clause ...)
     (define-record-type-1 ?record-name ?record-name
       ?formals
       ()
       values
       ?clause ...))))

(define-syntax define-record-type-1
  (syntax-rules (fields parent nongenerative mutable immutable init!)
    ;; find PARENT clause
    ((define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)
       ?init-proc
       (parent ?parent-name ?expr ...)
       ?clause ...)
     (define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ... (parent ?parent-name ?expr ...))
       ?init-proc
       ?clause ...))

    ;; find FIELDS clause
    ((define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)
       ?init-proc
       (fields ((?mutability ?field-name ?proc-names ...) ?init-expr) ...)
       ?clause ...)
     (process-fields-clause (fields ((?mutability ?field-name ?proc-names ...) ?init-expr) ...)
			    ?record-name ?record-name-spec
			    ?formals
			    (?simple-clause ...)
			    ?init-proc
			    ?clause ...))

    ;; find NONGENERATIVE clause
    ((define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)
       ?init-proc
       (nongenerative ?uid)
       ?clause ...)
     (define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ... (nongenerative ?uid))
       ?init-proc
       ?clause ...))

    ;; find INIT! clause
    ((define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)
       ?init-proc
       (init! (?param) ?expr1 ?expr ...)
       ?clause ...)
     (define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ... (nongenerative ?uid))
       (lambda (?param) ?expr1 ?expr ...)
       ?clause ...))

    ;; pass it on
    ((define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)
       ?init-proc)

     (define-record-type-2 ?record-name ?record-name-spec
       constructor-temp
       ?formals
       (?simple-clause ...)
       ?init-proc))))

(define-syntax define-constructor-with-init
  (syntax-rules ()
    ;; regular parameter list
    ((define-constructor-with-init ?constructor-name ?real-constructor-name
       (?formal ...)
       ?init-proc)
     (define (?constructor-name ?formal ...)
       (let ((r (?real-constructor-name ?formal ...)))
	 (?init-proc r)
	 r)))
    ;; with rest
    ((define-constructor-with-init ?constructor-name ?real-constructor-name
       (?formal1 . ?formals)
       ?init-proc)
     (define-constructor-with-init ?constructor-name ?real-constructor-name
       (?formal1)
       ?formals
       ?init-proc))
    ((define-constructor-with-init ?constructor-name ?real-constructor-name
      (?formal ...)
      (?formal1 . ?formals)
      ?init-proc)
     (define-constructor-with-init ?constructor-name ?real-constructor-name
       (?formal ... ?formal1)
      ?formals
      ?init-proc))
    ((define-constructor-with-init ?constructor-name ?real-constructor-name
       (?formal ...)
       ?formal-rest
       ?init-proc)
     (define (?constructor-name ?formal ... . ?formal-rest)
       (let ((r (apply ?real-constructor-name ?formal ... ?formal-rest)))
	 (?init-proc r)
	 r)))
    ;; rest only
    ((define-constructor-with-init ?constructor-name ?real-constructor-name
       ?formal
       ?init-proc)
     (define (?constructor-name . ?formal)
       (let ((r (apply ?real-constructor-name ?formal)))
	 (?init-proc r)
	 r)))))

(define-syntax define-record-type-2
  (lambda (form rename compare)
    (let* ((name-spec (caddr form))
	   (constructor-name
	    (if (pair? name-spec)
		(cadr name-spec)
		(string->symbol (string-append "make-" (symbol->string name-spec)))))
	   (predicate-name
	    (if (pair? name-spec)
		(caddr name-spec)
		(string->symbol (string-append (symbol->string name-spec) "?"))))
	   (real-constructor-name (list-ref form 3)))
      
      `(,(rename 'begin)
	(,(rename 'define-simple-record-type) (,(cadr form) ,real-constructor-name ,predicate-name)
	,(list-ref form 4)		; formals
	,@(list-ref form 5))		; simple clauses
	(,(rename 'define-constructor-with-init)
	 ,constructor-name ,real-constructor-name
	 ,(list-ref form 4)		; formals
	 ,(list-ref form 6))))))	; init-proc


(define-syntax process-fields-clause
  (lambda (form rename compare)
    (let* ((record-name (symbol->string (caddr form)))
	   (simple-fields
	    (map (lambda (clause)
		   (let ((field-spec (car clause)))
		     (cond
		      ((compare (rename 'immutable) (car field-spec))
		       (if (= (length field-spec) 3)
			   clause
			   (list
			    (list (car field-spec) (cadr field-spec)
				  (string->symbol
				   (string-append record-name "-"
						  (symbol->string (cadr field-spec)))))
			    (cadr clause))))
		      ((compare (rename 'mutable) (car field-spec))
		       (if (= (length field-spec) 4)
			   clause
			   (list
			    (list (car field-spec) (cadr field-spec)
				  (string->symbol
				   (string-append record-name "-"
						  (symbol->string (cadr field-spec))))
				  (string->symbol
				   (string-append record-name "-"
						  (symbol->string (cadr field-spec))
						  "-set!")))
			    (cadr clause)))))))
		 (cdr (cadr form))))
	   (simple-fields-clause
	    (cons (caadr form) simple-fields)))
      `(,(rename 'define-record-type-1) ,(caddr form) ,(cadddr form)
	,(list-ref form 4)
	,(append (list-ref form 5) (list simple-fields-clause))
	,(list-ref form 6)
	,@(list-tail form 7)))))

