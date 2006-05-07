(define-syntax define-enum-type
  (syntax-rules ()
    ((define-enum-type ?type-name ?elements-name
       ?predicate-name
       ?index-accessor
       (?symbol ...))
     (begin
       (define-syntax ?type-name
	 (syntax-rules (?symbol ...)
	   ((?type-name ?symbol) '?symbol)
	   ...))

       (define (?elements-name)
	 (list->vector '(?symbol ...)))
       
       (define (?predicate-name thing)
	 (case thing
	   ((?symbol ...) #t)
	   (else #f)))

       (define-index-accessor ?index-accessor () 0 (?symbol ...))))))

(define-syntax define-index-accessor 
  (syntax-rules ()
    ((define-index-accessor ?index-accessor (?clause ...) ?index ())
     (define (?index-accessor thing)
       (case thing
	 ?clause ...
	 (else #f))))
    ((define-index-accessor ?index-accessor (?clause ...) ?index (?symbol . ?rest))
     (define-index-accessor ?index-accessor
       (?clause ... ((?symbol) ?index))
       (+ ?index 1)
       ?rest))))

(define-enum-type color
  colors
  color?
  color-index
  (black white purple maroon))
