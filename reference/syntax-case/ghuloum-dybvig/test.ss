#|
Copyright (c) 2006 Aziz Ghuloum and Kent Dybvig

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE. 
|#

;;; September 13, 2006

(test-library '
  (library (bar0)
    (export f)
    (import (for $implementation-core run))
    (define f 12)
    (define g 13)))

(test-library '
  (library (bar1)
    (export f mydisplay)
    (import (for (rename $implementation-core ([display mydisplay])) run))
    (define f 12)
    (define g (lambda () f))
    (mydisplay f)))


(test-library '
  (library (bar2)
    (export f mydisplay letrec)
    (import (for (rename $implementation-core ([display mydisplay])) run))
    (define f (lambda (x) x))
    (define g 13)
    (mydisplay (f 0))))


(test-library '
  (library (bar3)
    (export foo bar)
    (import (for $implementation-core expand run))
    (define-syntax foo
      (lambda (x) 
        (syntax-case x ()
          [_ '12])))
    (define bar (foo 7))))

(test-library '
  (library (bar4)
    (export foo)
    (import 
      (for (only $implementation-core define-syntax) run)
      (for $implementation-core expand))
    (define-syntax foo
      (lambda (x) 
        (syntax-case x ()
          [_ '12])))))

(test-library '
  (library (bar5)
    (export foo)
    (import (for (only $implementation-core meta) run)
            (for $implementation-core expand))
    (meta define foo
      (lambda (x) x))))

(test-library '
  (library (bar6)
    (export id-syn)
    (import (for $implementation-core (meta 2) expand run))
    (meta define-syntax id-syn
      (lambda (x)
        (syntax-case x ()
          [(_ id) 
           (cons 'macro!
             (lambda (x) 
               (syntax-case x ()
                 [(_ foo) #'id])))])))))


(error-test-library ' ;;; cons out of phase
  (library (bar7)
    (export)
    (import (for $implementation-core expand))
    cons))

(error-test-library ' ;;; cons out of phase
  (library (bar8)
    (export)
    (import (for $implementation-core run))
    (define-syntax foo cons)))


(test-library '
  (library (M0)
    (export mydisplay)
    (import (for (rename $implementation-core ([display mydisplay])) run))
    (mydisplay 1)))

(test-library '
  (library (M1)
    (export mydisplay)
    (import (for M0 run))
    (mydisplay 10)))

(test-library '
  (library (M1^)
    (export f)
    (import (for M0 run)
            (for $implementation-core run expand))
    (define-syntax f
      (lambda (x)
        (syntax-case x ()
          [(_ t) #'(mydisplay t)])))
    (f 17)))

(test-library '
  (library (M1^^)
    (export)
    (import (for M1^ run))
    (f 12)))

(test-library '
  (library (M2)
    (export macro)
    (import (for (only $implementation-core define-syntax) run)
            (for $implementation-core expand))
    (define-syntax macro
      (lambda (x)
        (syntax-case x ()
          [(_ f) #'(display f)])))))

(error-test-library ' ; display should be out of phase
  (library (M3)
    (export)
    (import (for M2 run))
    (macro 12)))


(error-test-library ' ; display should be out of phase
  (library (M4)
    (export)
    (import (for M2 run)
            (for $implementation-core run))
    (macro 12)))


(test-library '
  (library (M5)
    (export mac mydisplay)
    (import (for (rename (only $implementation-core define define-syntax
                               display cons)
                         ([display mydisplay]))
                 run)
            (for $implementation-core expand))
    (define foo 12)
    (define-syntax mac
      (lambda (x)
        (syntax-case x ()
          [(_ arg) #'(mydisplay (cons foo arg))])))
    (mac "foo")))


(test-library ' 
  (library (M6)
    (export)
    (import (for M5 run))
    (mac 12)
    (mydisplay 17)))

; test macro-generating macros
(test-library '
  (library (MGM1)
    (export mgm)
    (import (for $implementation-core expand run))
    (define-syntax mgm
      (lambda (x)
        (syntax-case x ()
          [(_ k) #'(define-syntax k (lambda (x) #'(display '(a b c))))])))))

(test-library '
  (library (MGM2)
    (export foo)
    (import (for MGM1 run))
    (mgm foo)))

(test-library '
  (library (MGM3)
    (export)
    (import (for MGM2 run))
    foo))

(test-library '
  (library (core derived)
    (export or let)
    (import (for $implementation-core expand run))
    (define-syntax let
      (lambda (x)
        (syntax-case x ()
          [(_ ((x v) ...) e1 e2 ...)
           #'((lambda (x ...) e1 e2 ...) v ...)]
          [(_ f ((x v) ...) e1 e2 ...)
           #'((letrec ([f (lambda (x ...) e1 e2 ...)]) f) v ...)])))
    (define-syntax or
      (lambda (x)
        (syntax-case x ()
          [(_) #'#f]
          [(_ e) #'e]
          [(_ e1 e2 e3 ...)
           #'(let ([t e1]) (if t t (or e2 e3 ...)))])))))

(test-library '
   (library (core identifier-syntax)
      (export identifier-syntax)
      (import (for $implementation-core expand run)
              (for (core derived) expand run)) ; contains "or"

      (define-syntax identifier-syntax
        (lambda (x)
          (syntax-case x (set!)
            ((_ e)
             (syntax (lambda (x)
                       (syntax-case x ()
                         (id (identifier? (syntax id))

                          ;; This OR is at level -1
                          (syntax (or e)))

                         ((_ x (... ...))
                          (syntax (e x (... ...)))))))))))))

(test-library '
   (library (core identifier-syntax2)
      (export identifier-syntax)
      (import (for $implementation-core expand run (meta 2))
              (for (core derived) run)) ; contains "or"

      (meta define-syntax identifier-syntax
        (lambda (x)
          (syntax-case x (set!)
            ((_ e)
             (syntax (lambda (x)
                       (syntax-case x ()
                         (id (identifier? (syntax id))

                          ;; This OR is at level -1
                          (syntax (or e)))

                         ((_ x (... ...))
                          (syntax (e x (... ...))))
                         )))))))))

(test-library '
  (library (test-idsyn)
    (export)
    (import (for $implementation-core run)
            (for (core identifier-syntax2) run))
    (define-syntax a (identifier-syntax 3))
    a))

(test-library '
  (library (L1)
    (export k)
    (import (for $implementation-core expand run))
    (define-syntax k
      (lambda (x)
        (syntax-case x ()
          [(_ a) (free-identifier=? #'a #'cons)])))))

(test-library '
  (library (L2)
    (export k)
    (import (for $implementation-core (meta 17))
            (for L1 run))
    (k cons)
    (k foo)))

(test-library '
  (library (foo)
    (export f)
    (import (for $implementation-core run))
    (define f (lambda () 1))))

(test-library '
  (library (bar)
    (export g)
    (import (for $implementation-core run expand)
            (for foo expand))
    (define-syntax g
      (lambda (x)
        (syntax-case x ()
          ((_) #'(f)))))))

(error-test-library '
  (library (main) ; f out of context
    (export)
    (import (for $implementation-core run)
            (for foo run)
            (for bar run))
    (g)))


(test-library '
  (library (X0)
    (export f)
    (import (for $implementation-core run))
    (define f 0)
    f))

(test-library '
  (library (X1)
    (export f)
    (import X0)
    f))

(test-library '
  (library (X2)
    (export f)
    (import X1)
    f))

(test-library '
  (library (X3)
    (export f)
    (import X2)
    f))


(test-library '
  (library (hmmm)
    (export)
    (import (for $implementation-core run expand))
    (define-syntax foo
      (lambda (x)
        (syntax-case x ()
          [(_)
           #'(define bar 1)])))
    (foo)
    (foo)))

;;; example from the email exchange with Andre
;;; every library imports and exports ONLY the things needed.
;;; the first library is a helper that defines the macro integer-syntax
;;; the secons library imports nothing from the helper for run and
;;; integer-syntax only for expand.  It also exports integer-syntax.
;;; the third library uses integer-syntax
(test-library '
  (library (syntax-with-runtime-type-predicate-insertions-helper)
    (export integer-syntax)
    (import 
      (for (only $implementation-core define-syntax syntax if integer? display) run)
      (for (only (core derived) let) run)
      (for (only $implementation-core lambda syntax-case syntax) expand))
    (define-syntax integer-syntax
      (lambda (stx)
        (syntax-case stx ()
          ((_ template)
           #'(syntax
               (let ((v template))
                  (if (integer? v)
                      v
                      (display "Type error - not an integer"))))))))))


(test-library '
  (library (syntax-with-runtime-type-predicate-insertions)
     (export integer-syntax)
     (import 
       (for (only syntax-with-runtime-type-predicate-insertions-helper) run)
       (for (only syntax-with-runtime-type-predicate-insertions-helper integer-syntax) expand))))

(test-library '
  (library (syntax-with-runtime-type-predicate-insertions-client)
     (export)
     (import (for (only $implementation-core let-syntax +) run)
             (for (only $implementation-core lambda) expand)
             syntax-with-runtime-type-predicate-insertions)
     (let-syntax ((foo (lambda (stx) (integer-syntax (+ 1 2)))))
       (foo))))


;;; now doing the same using meta:
(test-library '
   (library (meta-syntax-with-runtime-type-predicate-insertions)
     (export integer-syntax)
     (import 
       (for $implementation-core run expand (meta 2)) 
       (for (core derived) run))

     (meta define-syntax integer-syntax
       (lambda (stx)
         (syntax-case stx ()
           ((_ template)
            #'#'(let ((v template))
                   (if (integer? v)
                       v
                       (display "Type error - not an integer")))))))))

(test-library '
  (library meta-syntax-with-runtime-type-predicate-insertions-client
     (export)
     (import (for (only $implementation-core let-syntax +) run)
             (for (only $implementation-core lambda) expand)
             meta-syntax-with-runtime-type-predicate-insertions)
     (let-syntax ((foo (lambda (stx) (integer-syntax (+ 1 2)))))
       (foo))))

(test-library '
  (library DEF-STX
    (export)
    (import (for $implementation-core run expand))
    (define t
      (lambda (x)
        (define-syntax q
          (lambda (stx)
            (syntax-case stx ()
              [(_ t) #'(+ t x)])))
        ((lambda (x) (q x)) 12)))))

(test-library '
  (library LET-STX
    (export)
    (import (for $implementation-core run expand))
    (define t
      (lambda (x)
        (let-syntax ([q
                      (lambda (stx)
                        (syntax-case stx ()
                          [(_ t) #'(+ t x)]))])
          ((lambda (x) (q x)) 12))))))


(error-test-library '
  (library FAIL-NO-EXPORT
    (export f)
    (import)))


(printf "Passed all tests.\n")
;(exit)
