(define-structure r6rs-mockup (export unspecified
				      put-string standard-error-port
				      (library :syntax))
  (open scheme
	(subset i/o (current-error-port)))
  (begin
    (define-syntax library
      (syntax-rules (import export)
	((library ?name 
	   (export ?export-spec ...)
	   (import ?import-spec ...)
	   ?body ...)
	 (begin ?body ...))))
    (define (unspecified) (if #f #f))
    (define (put-string p s)
      (display s p))
    (define (standard-error-port)
      (current-error-port))
    ))

(define-structure r6rs-exceptions-internal
  (export with-exception-handler
	  (guard :syntax)
	  raise
	  raise-continuable

	  set-operate-non-continuable!
	  set-operate-unhandled!)
  (open scheme
	(modify srfi-23 (rename (error abort)))
	r6rs-mockup)
  (files exception-internal))

(define-structure r6rs-conditions
  (export condition
	  condition?
	  condition-predicate
	  condition-accessor
	  simple-conditions
	  define-condition-type
	  &condition
	  &message
	  make-message-condition
	  message-condition?
	  condition-message
	  &warning
	  make-warning
	  warning?
	  &serious
	  make-serious-condition
	  serious-condition?
	  &error
	  make-error
	  error?
	  &violation
	  make-violation
	  violation?
	  &non-continuable
	  make-noncontinuable
	  non-continuable?
	  &implementation-restriction
	  make-implementation-restriction
	  implementation-restriction?
	  &lexical
	  make-lexical-violation
	  lexical-violation?
	  &syntax
	  make-syntax-violation
	  syntax-violation?
	  &undefined
	  make-undefined-violation
	  undefined-violation?
	  &assertion
	  make-assertion-violation
	  assertion-violation?
	  &irritants
	  make-irritants-condition
	  irritants-condition?
	  condition-irritants
	  &who
	  make-who-condition
	  who-condition?
	  condition-who
	  
	  assertion-violation)
  (open scheme
	r6rs-mockup
	r6rs-exceptions-internal
	procedural-record-types
	syntactic-record-types/explicit
	record-reflection)
  (files condition))
