
(library (r6rs records inspection)
  (export record-type-name
	  record-type-parent
	  record-type-sealed?
	  record-type-uid
	  record-type-generative?
	  record-type-field-names
	  record-type-opaque?
	  record-field-mutable?
	  record? record-rtd)
  (import (r6rs records private core)))
