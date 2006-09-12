; Reference implementation for exceptions library, adapted from SRFI 34

; Copyright (C) Richard Kelsey, Michael Sperber (2002). All Rights Reserved.

; Permission is hereby granted, free of charge, to any person
; obtaining a copy of this software and associated documentation files
; (the "Software"), to deal in the Software without restriction,
; including without limitation the rights to use, copy, modify, merge,
; publish, distribute, sublicense, and/or sell copies of the Software,
; and to permit persons to whom the Software is furnished to do so,
; subject to the following conditions:

; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

(library (r6rs exceptions internal)
  (export with-exception-handler
	  (guard :syntax)
	  raise
	  raise-continuable

	  set-operate-non-continuable!
	  set-operate-unhandled!)
  (import (r6rs base)
	  ;; This library is assumed to export a procedure `abort'
	  ;; exists that takes a message and aborts the running
	  ;; program.
	  (r6rs internal abort))


; This will be set later to avoid a circular dependency between 
; the exceptions and the conditions libraries.

; This will take
; - a raise-like procedure
; - a symbol for &who
; - a variable number of arguments for &irritants
; It should call the raise-like procedure on a suitable condition object
(define operate-non-continuable (unspecified))
(define (set-operate-non-continuable! p)
  (set! operate-non-continuable p))

; This will take
; - an abort-like procedure
; - a condition object
; It should call abort if the condition object specifies a serious condition,
; and print a message and return otherwise.
(define operate-unhandled (unspecified))
(define (set-operate-unhandled! p)
  (set! operate-unhandled p))

(define *current-exception-handlers*
  (list (lambda (condition)
          (operate-unhandled abort
			     condition))))

(define (with-exception-handler handler thunk)
  (with-exception-handlers (cons handler *current-exception-handlers*)
                           thunk))

(define (with-exception-handlers new-handlers thunk)
  (let ((previous-handlers *current-exception-handlers*))
    (dynamic-wind
      (lambda ()
        (set! *current-exception-handlers* new-handlers))
      thunk
      (lambda ()
        (set! *current-exception-handlers* previous-handlers)))))

(define (raise obj)
  (let ((handlers *current-exception-handlers*))
    (with-exception-handlers (cdr handlers)
      (lambda ()
        ((car handlers) obj)
        (operate-non-continuable raise
				 'raise
				 (car handlers)
				 obj)))))

(define (raise-continuable obj)
  (let ((handlers *current-exception-handlers*))
    (with-exception-handlers (cdr handlers)
      (lambda () 
        ((car handlers) obj)))))

(define-syntax guard
  (syntax-rules ()
    ((guard (var clause ...) e1 e2 ...)
     ((call-with-current-continuation
       (lambda (guard-k)
         (with-exception-handler
          (lambda (condition)
            ((call-with-current-continuation
               (lambda (handler-k)
                 (guard-k
                  (lambda ()
                    (let ((var condition))      ; clauses may SET! var
                      (guard-aux (handler-k (lambda ()
                                              (raise condition)))
                                 clause ...))))))))
          (lambda ()
            (call-with-values
             (lambda () e1 e2 ...)
             (lambda args
               (guard-k (lambda ()
                          (apply values args)))))))))))))

(define-syntax guard-aux
  (syntax-rules (else =>)
    ((guard-aux reraise (else result1 result2 ...))
     (begin result1 result2 ...))
    ((guard-aux reraise (test => result))
     (let ((temp test))
       (if temp 
           (result temp)
           reraise)))
    ((guard-aux reraise (test => result) clause1 clause2 ...)
     (let ((temp test))
       (if temp
           (result temp)
           (guard-aux reraise clause1 clause2 ...))))
    ((guard-aux reraise (test))
     test)
    ((guard-aux reraise (test) clause1 clause2 ...)
     (let ((temp test))
       (if temp
           temp
           (guard-aux reraise clause1 clause2 ...))))
    ((guard-aux reraise (test result1 result2 ...))
     (if test
         (begin result1 result2 ...)
         reraise))
    ((guard-aux reraise (test result1 result2 ...) clause1 clause2 ...)
     (if test
         (begin result1 result2 ...)
         (guard-aux reraise clause1 clause2 ...)))))

) ; end of library form
