; Create (r6rs exceptions) library from (r6rs exceptions internal).

(library (r6rs exceptions)
  (export with-exception-handler
	  (guard :syntax)
	  raise
	  raise-continuable)
  (import (r6rs exceptions internal)))

