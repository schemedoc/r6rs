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

(define primitive-set!
  (lambda (x v) (set-top-level-value! x v)))
(print-gensym #f)
(case-sensitive #t)
;(print-graph #t)

(define (printline)
  (printf
    "------------------------------------------------------------------\n"))

(define test-library
  (lambda (x)
    (define eval-hook 
      (lambda (x)
        (parameterize ([current-expand #%sc-expand])
          (eval x))))
    (pretty-print x)
    (let ([expanded (sc-expand-library x)])
;      (printf "=>\n")
;      (pretty-print expanded)
      (eval-hook expanded)
      (printline))))

(define error-test-library
  (lambda (x)
    (define report-string
      (lambda (dest what who msg args newlines?)
        (parameterize ([print-level 3] [print-length 6])
          (format dest "~@[~*~%~]~@(~a~)~@[ in ~a~]~@[: ~?~].~@*~@[~%~]"
            newlines?
            what
            (and who (not (eqv? who "")) who)
            (and (not (eqv? msg "")) msg)
            args))))
    ((call/cc
       (lambda (k)
         (parameterize ([error-handler
                         (lambda (who msg . args)
                           (k (lambda ()
                                (report-string (console-output-port)
                                               "Error"
                                  who msg args #t)
                                (printf "Library failed as expected.\n")
                                (printline))))])
           (test-library x)
           (lambda () (error 'error-test-library "didn't fail!"))))))))

(let ()

  (define eval-hook
    (lambda (x)
      (#%interpret x)))

  (define-record phase (name version imports import-phases visit invoke))
  ;;; phase.visit is:
  ;;;     1. a list mapping labels to bindings
  ;;;     2. a procedure that evaluates to an environment
  ;;;     3. pending: to detect circularity
  ;;; phase.invoke is:
  ;;;     1. #t meaning we already invoked the code
  ;;;     2. a procedure
  ;;;     3. pending: to detect circularity

  (define-record library (name version subst phases))

  (define all-libraries '())

  (define install-library
    (lambda (lib)
      (set! all-libraries 
        (cons
          (cons (library-name lib) lib)
          all-libraries))))

  (define ver?
    (lambda (p? spec inst)
      (cond
        [(null? spec) #t]
        [(null? inst) #f]
        [else (and (p? (car spec) (car inst))
                   (ver? p? (cdr spec) (cdr inst)))])))

  (define unit?
    (lambda (n)
       (or (and (integer? n) (exact? n) (>= n 0))
           (error 'import "invalid version number ~s" n))))

  (define version-reference-matches?
    (lambda (ref ver)
      (syntax-case ref ()
        [(p n n* ...) (and (eq? #'p '<=) (andmap uint? #'(n n* ...)))
         (ver? >= #'(n n* ...) ver)]
        [(p n n* ...) (and (eq? #'p '>=) (andmap uint? #'(n n* ...)))
         (ver? <= #'(n n* ...) ver)]
        [(a c0 c1 ...) (eq? #'a 'and)
         (andmap 
           (lambda (x) (version-reference-matches? x ver))
           #'(c0 c1 ...))]
        [(or c0 c1 ...) (eq? #'or 'or)
         (ormap 
           (lambda (x) (version-reference-matches? x ver))
           #'(c0 c1 ...))]
        [(not c) (eq? #'not 'not)
         (if (version-reference-matches #'c ver) #f #t)]
        [(n n* ...) (andmap uint? #'(n n* ...))
         (ver? = #'(n n* ...) ver)]
        [() #t]
        [_ (error 'import "invalid version spec ~s" ref)])))

  (define get-preinstalled-library 
    (lambda (id* version-reference)
      (cond
        [(assoc id* all-libraries) =>
         (lambda (p)
           (let* ([lib (cdr p)]
                  [ver (library-version lib)])
             (unless (version-reference-matches? version-reference ver)
               (error 'import 
                      "installed library ~s ~s is inappropriate for ~s"
                      id* ver version-reference))
             lib))]
        [else #f])))

  (define get-filesystem-library
    (lambda (id* version-reference)
      ;;; cannot find anything!
      #f))

  (define import-library 
    (lambda (id* version-reference)
      (or (get-preinstalled-library id* version-reference)
          (get-filesystem-library id* version-reference)
          (error 'import-library "cannot find library matching ~s ~s" 
                 id* version-reference))))
          
  (define do-library-reference
    (lambda (x)
      (syntax-case x ()
        [id 
         (symbol? #'id)
         (import-library #'(id) '())]
        [(id id* ...) 
         (andmap symbol? #'(id id* ...))
         (import-library #'(id id* ...) '())]
        [(id id* ... version-reference)
         (import-library #'(id id* ...) #'version-reference)]
        [_ (error 'import "invalid library reference ~s" x)])))

  (define do-import-set 
    (lambda (import-set)
      (syntax-case import-set (only except add-prefix rename)
        [(only import-set . _)
         (do-import-set #'import-set)]
        [(except import-set . _)
         (do-import-set #'import-set)]
        [(add-prefix import-set . _)
         (do-import-set #'import-set)]
        [(rename import-set . _)
         (do-import-set #'import-set)]
        [library-reference 
         (do-library-reference #'library-reference)])))

  (define do-import
    (lambda (import-spec)
      (syntax-case import-spec ()
        [(for import-set . _) (eq? (syntax->datum #'for) 'for)
         (do-import-set #'import-set)]
        [import-set
         (do-import-set #'import-set)])))

  (define do-visit
    (lambda (phase)
      (define re-import
        (lambda (label)
          (let f ([p* (phase-import-phases phase)])
            (cond
              [(null? p*) (error 'visit "imported label ~s missing" x)]
              [(assq label (phase-visit (car p*))) => cdr]
              [else (f (cdr p*))]))))
      (let ([visit (phase-visit phase)])
        (cond
          [(procedure? visit)
           (set-phase-visit! phase 'pending)
           (for-each
             (lambda (import)
               (let ([import-name (car import)] 
                     [import-version (cadr import)]
                     [import-phase-number (caddr import)])
                 (let ([a (assoc import-name all-libraries)])
                   (unless (pair? a)
                     (error 'visit "unknown library ~s ~s" 
                            import-name import-version))
                   (let ([lib (cdr a)])
                     (unless (library? lib)
                       (error 'visit "library ~s ~s is not installed"
                              import-name import-version))
                     (unless (equal? (library-version lib) 
                                     import-version)
                       (error 'visit "version mismatch"))
                     (let ([phases (library-phases lib)])
                       (let ([p (list-ref phases import-phase-number)])
                         (do-visit p)
                           (set-phase-import-phases! phase
                              (cons p (phase-import-phases phase)))))))))
             (phase-imports phase))
           (let ([r (visit)])
             (set-phase-visit! phase 
                (map 
                  (lambda (x)
                    (let ([b (cdr x)])
                      (cond
                        [(and (pair? b) (eq? (car b) 'imported))
                         (cons (car x) (re-import (cdr b)))]
                        [(and (pair? b) (eq? (car b) 'global)) x]
                        [else (cons (car x) ($sanitize-binding b))])))
                  r)))]
          [(eq? visit 'pending) (error 'visit "circularity")]
          [else (void)]))))

  (define do-invoke
    (lambda (lib)
      (error 'do-invoke "not yet")
      (case (library-invoke-status lib)
        [(invoked) (void)]
        [(pending) (error 'invoke "circularity for ~s" lib)]
        [else 
         (set-library-invoke-status! lib 'pending)
         (eval-hook (library-invoke-code lib))
         (set-library-invoke-status! lib 'invoked)])))


  (primitive-set! 'lm:install-library-header
     (lambda (libname)
       (cond
         [(assoc libname all-libraries)
          (error 'install-library "library ~s already exists" libname)]
         [else
          (set! all-libraries (cons (cons libname #f) all-libraries)) ])))

  (primitive-set! 'lm:get-libraries-for-import-spec
    ;;; returns a set of library records that match the shape of
    ;;; the import spec.  Raises an error if the library that's already
    ;;; installed in the system does not match the required specs.
    ;;; this function does not visit nor invoke any libraries; it merely
    ;;; installs the library info saying we have such and such libraries.
    ;;; The libraries are visited or invoked in a separate step when we need
    ;;; to build the environment.
    (lambda (import-spec*)
      (syntax-case import-spec* ()
        [(sp* ...)
         (map do-import #'(sp* ...))])))

  (primitive-set! 'lm:visit-phase! do-visit)

  (primitive-set! 'lm:phase-env
    (lambda (phase)
      (let ([r (phase-visit phase)])
        (cond
          [(procedure? r) (error 'visit-env "library not visited")]
          [(eq? r 'pending) (error 'visit-env "library visit not completed")]
          [else r]))))

  (primitive-set! 'lm:phase-name phase-name)
  (primitive-set! 'lm:phase-version phase-version)
  (primitive-set! 'lm:phase-import-phases phase-import-phases)

  (primitive-set! 'lm:invoke-phase
    (lambda (phase)
      (let ([invoke (phase-invoke phase)])
        (cond
          [(procedure? invoke)
           (set-phase-invoke! phase 'pending)
           (invoke)
           (set-phase-invoke! phase #t)]
          [(eq? invoke 'pending) 
           (error 'invoke "circularity")]
          [else (void)]))))

  (primitive-set! 'lm:library-phases library-phases)

  (primitive-set! 'lm:library-subst library-subst)

  (primitive-set! 'lm:library-name library-name)
  (primitive-set! 'lm:library-version library-version)


  (install-library
    (make-library '($implementation-core) '() '()
      (list (make-phase '($implementation-core) '() '() '() '() #t))))

  (primitive-set! 'lm:extend-implementation-core!
    (lambda (ls)
      (let ([lib (cdr (assoc '($implementation-core) all-libraries))]
            [names (map car ls)]
            [bindings (map cadr ls)]
            [labels (map caddr ls)])
        (set-library-subst! lib 
          (append (map cons names labels) (library-subst lib)))
        (for-each 
          (lambda (phase)
            (set-phase-visit! phase
              (append (map cons labels bindings) (phase-visit phase))))
          (library-phases lib)))))

  (primitive-set! 'lm:install-library
    (lambda (name version subst phases)
      (let ([lib (make-library name version subst 
                   (map (lambda (phase)
                          (let ([imports (car phase)]
                                [visit (cadr phase)]
                                [invoke (caddr phase)])
                            (make-phase name version imports '() visit invoke)))
                        phases))])
        (set! all-libraries (cons (cons name lib) all-libraries)))))

  )


