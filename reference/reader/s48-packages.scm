(define-structure r6rs-faux (export u8-list->bytes
				    bytes=?
				    &i/o-read &i/o-port &lexical
				    get-char lookahead-char
				    (library :syntax))
  (open scheme
	srfi-74 ; blobs
	conditions
	)
  (begin
    (define u8-list->bytes u8-list->blob)
    (define bytes=? blob=?)

    (define-condition-type &violation &serious
      violation?)
    (define-condition-type &defect &violation
      defect?)
    (define-condition-type &lexical &defect
      lexical-violation?)
    
    (define-condition-type &i/o &error
      i/o-error?)

    (define-condition-type &i/o-read &i/o
      i/o-read-error?)

    (define-condition-type &i/o-port &i/o
      i/o-port-error?
      (port i/o-error-port))

    (define (get-char port)
      (read-char port))

    (define (lookahead-char port)
      (peek-char port))

    (define-syntax library
      (syntax-rules (import export)
	((library ?name 
	   (export ?export-spec ...)
	   (import ?import-spec ...)
	   ?body ...)
	 (begin ?body ...))))
		  
    ))

(define-structure read-datums (export get-datum)
  (open (modify scheme (hide read))
	r6rs-faux
	conditions exceptions
	)
  (files read
	 syntax-info)
  (optimize auto-integrate))

(define-structure read-test (export)
  (open scheme
	srfi-6 ; basic string ports
	r6rs-faux
	read-datums
	)
  (files test))
