; The CHECK macro is essentially stolen from Sebastian Egner's SRFIs.

(define *correct-count* 0)
(define *failed-count* 0)

(define-syntax check
  (syntax-rules (=>)
    ((check ec => desired-result)
     (check ec => (equal?) desired-result))
    ((check ec => (equal?) desired-result)
     (begin
       (newline)
       (write (quote ec))
       (newline)
       (let ((actual-result ec))
         (display "  => ")
         (write actual-result)
         (if (equal? actual-result desired-result)
             (begin
               (display " ; correct")
               (set! *correct-count* (+ *correct-count* 1)) )
             (begin
               (display " ; *** failed ***, desired result:")
               (newline)
               (display "  => ")
               (write desired-result)
               (set! *failed-count* (+ *failed-count* 1)) ))
         (newline) )))))

(check
 (get-datum (open-input-string "(1 2 3)")) => '(1 2 3))
(check
 (get-datum (open-input-string "foo")) => 'foo)
(check
 (get-datum (open-input-string "fOo")) => (string->symbol "fOo"))
(check
 (get-datum (open-input-string "[1 2 3]")) => '(1 2 3))
(check
 (get-datum (open-input-string "#\\linefeed")) => (integer->char 10))

(newline)
(display "correct tests: ")
(display *correct-count*)
(newline)
(display "failed tests: ")
(display *failed-count*)
(newline)
