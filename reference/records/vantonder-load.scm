

;; Something like this might get you started:
; (load/cd "../syntax-case/vantonder/expander.scm")
; ($ex:expand-file "../syntax-case/vantonder/standard-libraries.scm" "standard-libraries.exp")
; (load "standard-libraries.exp")

;; Needed by srfi_9.sls:
(define-record-type rec
  (make-rec tag vec)
  rec?
  (tag rec-tag)
  (vec rec-vec))

;; Helper to expand and load:
(define (r6rs-load f)
  (display f) (newline)
  ($ex:expand-file f "tmp.exp")
  (load "tmp.exp"))

(r6rs-load "generic/implementation/make-struct-type.sls")
(r6rs-load "generic/implementation/srfi_9.sls")

(r6rs-load "generic/implementation/opaque-cells.sls")
(r6rs-load "generic/implementation/vector-types.sls")

(r6rs-load "rnrs/records/private/core.sls")
(r6rs-load "rnrs/records/procedural-6.sls")
(r6rs-load "rnrs/records/inspection-6.sls")
(r6rs-load "rnrs/records/private/explicit.sls")
(r6rs-load "rnrs/records/syntactic-6.sls")

(r6rs-load "example.scm")
