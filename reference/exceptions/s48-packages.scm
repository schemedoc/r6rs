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
  (export make-condition-type
	  condition-type?
	  make-condition
	  condition?
	  condition-has-type?
	  condition-ref
	  make-compound-condition
	  extract-condition
	  (define-condition-type :syntax)
	  (condition :syntax)
	  &condition
	  &message
	  message-condition?
	  condition-message
	  &warning
	  warning?
	  &serious
	  serious-condition?
	  &error
	  error?
	  &violation
	  violation?
	  &non-continuable
	  non-continuable?
	  &implementation-restriction
	  implementation-restriction?
	  &defect
	  defect?
	  &lexical
	  lexical-violation?
	  &syntax
	  syntax-violation?
	  &undefined
	  undefined-violation?
	  &contract
	  contract-violation?
	  &irritants
	  irritants-condition?
	  condition-irritants
	  &who
	  who-condition?
	  condition-who)
  (open scheme
	r6rs-mockup
	r6rs-exceptions-internal
	syntactic-record-types/explicit)
  (files condition))
