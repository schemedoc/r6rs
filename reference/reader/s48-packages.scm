(define-structure read-datums (export get-datum)
  (open (modify scheme (hide read))
	simple-signals	;warn, signal-condition, make-condition
	simple-conditions	;define-condition-type
	)
  (files read
	 syntax-info)
  (optimize auto-integrate))
