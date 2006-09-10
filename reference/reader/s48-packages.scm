(define-structure read-datums (export get-datum)
  (open (modify scheme (hide read))
	simple-signals	;warn, signal-condition, make-condition
	simple-conditions	;define-condition-type
	)
  (files read
	 syntax-info)
  (optimize auto-integrate))

(define-structure read-test (export)
  (open scheme
	srfi-6 ; basic string ports
	read-datums
	)
  (files test))
