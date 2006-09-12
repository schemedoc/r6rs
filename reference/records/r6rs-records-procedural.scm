
(library (r6rs records procedural)
  (export make-record-type-descriptor
	  record-type-descriptor?
	  make-record-constructor-descriptor record-constructor
	  record-predicate
	  record-accessor record-mutator)
  (import (r6rs records private core)))

