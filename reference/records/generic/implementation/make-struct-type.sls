
;; For implementing SRFI-9 in terms of SRFI-9....

(library (implementation make-struct-type)
  (export make-struct-type)
  (import (rnrs)
          (primitives (rec? make-rec rec-tag rec-vec)))

  (define (make-struct-type name count)
    (values #f
            (lambda args (make-rec name (list->vector args)))
            (lambda (r) (and (rec? r) (eq? (rec-tag r) name)))
            (lambda (r pos) (vector-ref (rec-vec r) pos))
            (lambda (r pos val) (vector-set! (rec-vec r) pos val)))))
