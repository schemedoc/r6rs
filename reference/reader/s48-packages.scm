(define-structure read-datums (export read)
  (open scheme-level-1
	number-i/o
	(subset i/o-internal (input-port-option))
	ascii		;for dispatch table
	unicode
	simple-signals	;warn, signal-condition, make-condition
	simple-conditions	;define-condition-type
	primitives	;make-immutable!
	silly)		;reverse-list->string
  (files read
	 syntax-info)
  (optimize auto-integrate))
