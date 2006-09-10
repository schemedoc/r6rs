(define-structure r6rs-faux (export u8-list->bytes
				    bytes=?)
  (open scheme
	srfi-74 ; blobs
	)
  (begin
    (define u8-list->bytes u8-list->blob)
    (define bytes=? blob=?)))

(define-structure read-datums (export get-datum)
  (open (modify scheme (hide read))
	r6rs-faux
	simple-signals	;warn, signal-condition, make-condition
	simple-conditions	;define-condition-type
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
