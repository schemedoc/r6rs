; Opaque cells

(define-record-type :opaque-cell
  (make-opaque-cell key-predicate contents)
  opaque-cell?
  (key-predicate opaque-cell-key-predicate)
  (contents real-opaque-cell-ref real-opaque-cell-set!))

(define (ensure-opaque-cell-access key cell)
  (if (not ((opaque-cell-key-predicate cell) key))
      (error "access to opaque cell denied" cell key)))

(define (opaque-cell-ref key cell)
  (ensure-opaque-cell-access key cell)
  (real-opaque-cell-ref cell))

(define (opaque-cell-set! key cell val)
  (ensure-opaque-cell-access key cell)
  (real-opaque-cell-set! key val))

(define (opaque-cell-key-fits? key cell)
  (and ((opaque-cell-key-predicate cell) key) #t))
