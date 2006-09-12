
;; Used by the alternate "generic-" libraries when
;; loaded into MzScheme.
;; This is not a real R6RS library, because it uses
;; MzScheme's `require' and `provide'.
(library (srfi-9)
  (export)
  (import)
  (require (lib "9.ss" "srfi"))
  (provide (all-from (lib "9.ss" "srfi"))))

