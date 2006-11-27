;;;=====================================================================
;;;
;;; Tests:
;;;
;;;   Copyright (c) 2006 Andre van Tonder
;;;
;;;   Copyright statement at http://srfi.schemers.org/srfi-process.html
;;;
;;;=====================================================================

;;; September 13, 2006

(load "macros-core.scm")

(repl 
 '( 
   
   ;; This is not strictly necessary until we need to evaluate
   ;; non-library forms further below, but let's import r6rs so
   ;; we don't forget.  By default, only the library language
   ;; (and import) would be available at the toplevel.  
   
   (import (for r6rs run expand (meta 2)))  
   
   ;;;=====================================================================
   ;;;
   ;;; LIBRARIES:
   ;;;
   ;;; The file macros-derived builds r6rs up using a sequence 
   ;;; of r6rs modules.  It constitutes a nontrivial example, 
   ;;; tutorial and test of the library system.  
   ;;; 
   ;;; Here are some further tests and examples:
   ;;;
   ;;;=====================================================================
   
   ;;;====================================================
   ;;;
   ;;; R6RS library examples.
   ;;;
   ;;;====================================================
   
   (library (stack)
     (export make push! pop! empty!)
     (import r6rs)
     
     (define (make)
       (list '()))
     
     (define (push! s v)
       (set-car! s (cons v (car s))))
     
     (define (pop! s)
       (let ((v (caar s))) (set-car! s (cdar s)) v))
     
     (define (empty! s)
       (set-car! s '()))
     )
   
   (library balloons
     (export make push pop)
     (import r6rs)
     
     (define (make w h)
       (cons w h))
     
     (define (push b amt)
       (cons (- (car b) amt) (+ (cdr b) amt)))
     
     (define (pop b)
       (display "Boom! ")
       (display (* (car b) (cdr b)))
       (newline))
     )
   
   (library party
     (export (rename (balloon:make make) (balloon:push push))
             push! make-party
             (rename (party-pop! pop!)))
     (import r6rs
             (only stack make push! pop!) ;; not empty!
             (add-prefix balloons balloon:))
     
     ;; Creates a party as a stack of balloons, starting with
     ;; two balloons
     (define (make-party)
       (let ((s (make))) ;; from stack
         (push! s (balloon:make 10 10))
         (push! s (balloon:make 12 9)) s))
     
     (define (party-pop! p)
       (balloon:pop (pop! p)))
     )
   
   (library main
     (export)
     (import r6rs party)
     (define p (make-party))
     (pop! p)                      ;; displays "Boom! 108"
     (push! p (push (make 5 5) 1))
     (pop! p))                     ;; displays "Boom! 24"
   
   (import main)
   
   ;; Macros and meta-levels
   
   (library (my-helpers id-stuff)
     (export find-dup)
     (import r6rs)
     
     (define (find-dup l)
       (and (pair? l)
            (let loop ((rest (cdr l)))
              (cond ((null? rest)
                     (find-dup (cdr l)))
                    ((bound-identifier=? (car l) (car rest))
                     (car rest))
                    (else (loop (cdr rest)))))))
     )
   
   (library (my-helpers value-stuff)
     (export mvlet)
     (import r6rs
             (for (my-helpers id-stuff) expand))
     
     (define-syntax mvlet
       (lambda (stx)
         (syntax-case stx ()
           ((_ ((id ...) expr) body0 body ...)
            (not (find-dup (syntax (id ...))))
            (syntax
             (call-with-values
              (lambda () expr)
              (lambda (id ...) body0 body ...))))))))
   
   (library let-div
     (export let-div)
     (import r6rs (my-helpers value-stuff))
     
     (define (quotient+remainder n d)
       (let ((q (quotient n d)))
         (values q (- n (* q d)))))   
     
     (define-syntax let-div
       (syntax-rules ()
         ((_ n d (q r) body0 body ...)
          (mvlet ((q r) (quotient+remainder n d))
                 body0 body ...))))
     )
   
   (import let-div)  
   
   (let-div 5 2 (q r) (+ q r))  ;==> 3   

   ;;======================================================
   ;;
   ;; Further library tests:
   ;;
   ;;======================================================
   
   ;; Test meta-level resolution for chained imports:
   
   (library foo 
     (export u)
     (import r6rs)
     (define u 1))
   
   (library bar
     (export u v)
     (import r6rs foo)
     (define-syntax v (lambda (e) (syntax u))))
   
   (library baz
     (export)
     (import (for r6rs run expand (meta 2)) 
             (for bar (meta 2)))
     (display 
      (let-syntax ((m (lambda (e)
                        (let-syntax ((n (lambda (e) (+ u (v)))))
                          (n)))))
        (m))))                       
   
   (import (for baz run))    ;==> 2
   
   ;;======================================================
   ;;
   ;; Check that export levels compose correctly:
   ;;
   ;;======================================================
   
   (library foo
     (export x y)    
     (import r6rs)
     (define x 2)
     (define y 4))
   
   (library baz
     (export y)                      ;; exports y at level 1
     (import r6rs (for foo expand)))
   
   (library bar
     (export f)
     (import (for r6rs run expand)   ;; This also implicitly imports into (meta 2) 
             (for foo expand)        ;; imports x and y at level 1
             (for baz expand))       ;; also imports y but at level expand + 1 = 2
     (define (f) 
       (let-syntax ((foo (lambda (_) 
                           (+ x                                   ;; level 1
                              y                                   ;; level 1 
                              (let-syntax ((bar (lambda (_) y)))  ;; level 2
                                (bar))))))
         (foo))))
   
   (import bar)
   (f)   ;==> 10   
   
   
   ;;======================================================
   ;;
   ;; Check that levels of reference are determined lexically:
   ;;
   ;;======================================================
   
   (library foo  
     (export f) 
     (import r6rs)
     (define (f) 1)) 
 
   (library bar 
     (export g) 
     (import r6rs 
             (for foo expand))  ;; This is the wrong level ! 
     (define-syntax g 
       (syntax-rules () 
         ((_) (f))))) 
 
   ;; This *must* be an error:
   ;; The use of f in bar cannot be satisfied
   ;; by the import of foo into the client level 0 here. 
   ;; That would violate lexical determination of
   ;; level of reference to f in bar. 
   
   ;;(library main 
   ;;  (export)   
   ;;  (import r6rs foo bar)   
   ;;  (display (g)))         
   
   ;;==> Syntax error: Attempt to use binding of f at invalid level 0 : Binding is only 
   ;;    valid at levels (1) 
   
  
   ;;=============================================================
   ;;
   ;; Importing into multiple and negative levels: 
   ;;
   ;; Negative levels are not in the r6rs draft, so this 
   ;; demonstrates a consistent extension.
   ;; See the definition of identifier-syntax in macros-derived.scm 
   ;; for a practical use of negative levels in 
   ;; this implementation.
   ;;
   ;;=============================================================
   
   (library foo 
     (export x)
     (import r6rs)
     (define x 42))
   
   (library bar
     (export get-x)
     (import r6rs
             ;; Code in (syntax ...) expressions refer to bindings
             ;; at one lower level - for example, ordinary macros
             ;; are evaluated at level expand = 1, but manipulate 
             ;; code that will run at level run = 0.
             ;; The occurrence of (syntax x) below is not in a macro
             ;; but rather at level 0.
             ;; The reference x in (syntax x) is therefore at level -1.
             ;; To make it refer to the x in foo, we need to import 
             ;; the latter at level -1.
             (for foo (meta -1)))
     (define (get-x) (syntax x)))
   
   (library baz
     (export)
     (import (for r6rs run expand (meta 2) (meta 3)) 
             (for bar expand (meta 3)))
     
     (display
      (let-syntax ((m (lambda (ignore)
                        (get-x))))
        (m)))                                    ;==> 42
     
     (display 
      (let-syntax ((m (lambda (ignore)
                        (let-syntax ((n (lambda (ignore)
                                          (let-syntax ((o (lambda (ignore)
                                                            (get-x))))
                                            (o)))))
                          (n)))))
        (m)))                                    ;==> 42
     
     ;; This should give a syntax error due to a displaced reference:
     
     ;; (display 
     ;;   (let-syntax ((m (lambda (ignore)
     ;;                     (let-syntax ((n (lambda (ignore)
     ;;                                       (get-x))))
     ;;                       (n)))))
     ;;    (m)))                    ;==> Syntax-error: Attempt to use binding of get-x at invalid level 2 
     ;;                             ;                  Binding is only valid at levels (1 3) 
     
     ) ;; baz
   
   (import baz)   ;==> 42 42
   
   ;;=============================================================
   ;;
   ;; Unspecified behaviour of free-identifier=? (technical):
   ;;
   ;; This implementation has (free-identifier=? x y) = #t  
   ;; if x and y would be equivalent as references.  
   ;; In foo1, the cons in (syntax (cons 1 2)) is at level -1
   ;; and therefore does not refer to the r6rs cons, which is
   ;; imported at level 0.  In foo2, it does refer to the
   ;; r6rs cons.
   ;;
   ;;=============================================================
   
   (library foo1
     (export helper1)
     (import r6rs)
     
     (define (helper1 e) 
       (syntax-case e ()
         ((_ k) 
          (begin
            (if (free-identifier=? (syntax k) (syntax cons))
                (begin (display 'true)
                       (syntax (cons 1 2)))
                (begin (display 'false)
                       (syntax (k 1 2)))))))))
   
   (library foo2
     (export helper2)
     (import (for r6rs (meta -1) run))
     
     (define (helper2 e) 
       (syntax-case e ()
         ((_ k) 
          (begin
            (if (free-identifier=? (syntax k) (syntax cons))
                (begin (display 'true)
                       (syntax (cons 1 2)))
                (begin (display 'false)
                       (syntax (k 1 2)))))))))
       
   (library bar
     (export test1 test2)
     (import r6rs 
             (for foo1 expand)
             (for foo2 expand))    
     
     (define-syntax test1
       (lambda (stx)
         (helper1 stx)))
     
     (define-syntax test2
       (lambda (stx)
         (helper2 stx))))
   
   (import bar)
   
   (test1 cons)   ;==> false (1 . 2)
     
   (test2 cons)   ;==> true  (1 . 2)
   

   ;;======================================================
   ;;
   ;; Eval:
   ;;
   ;;====================================================== 
   
   (eval '(+ 1 2) 
         (environment 'r6rs))   ;==> 3
   
   (library foo
     (export foo-x)
     (import r6rs)
     (define foo-x 4))
   
   (eval '(+ 1 (let-syntax ((foo (lambda (_) foo-x)))
                 (foo)))
         (environment 'r6rs '(for foo expand)))      ;==> 5
   
   (library bar 
     (export)
     (import r6rs)
     (display
      (eval '(+ 1 (let-syntax ((foo (lambda (_) foo-x)))
                    (foo)))
            (environment 'r6rs '(for foo expand)))))
   
   (import bar)   ;==> 5
     
   ;;======================================================
   ;;
   ;; General syntax-case expander tests:
   ;;
   ;;======================================================
   
   (let-syntax ((m (lambda (e) 
                     (let-syntax ((n (lambda (e) 3)))
                       (n)))))
     (m))
   
   ;; Some simple patern and template pitfalls:
   
   (syntax-case '((1 2) (3 4)) ()
     (((x ...) ...) (syntax (x ... ...))))    ;==> (1 2 3 4)
   
   ;; R6RS pattern extensions:
   
   (syntax-case '(1 2 3 4) ()
     ((x ... y z) (syntax ((x ...) y z))))    ;==> ((1 2) 3 4)
   
   (syntax-case '(1 2 3 . 4) ()
     ((x ... y . z) (syntax ((x ...) y z)))) ;==> ((1 2) 3 4)
   
   (syntax-case '#(1 2 3 4) ()
     (#(x ... y z)  (syntax (#(x ...) y z)))) ;==> (#(1 2) 3 4)
   
   ;; Wildcards:
   
   (let-syntax ((foo (syntax-rules ()
                       ((_ _ _) 'yes))))
     (foo 3 4))
   
   ;; Identifier macros:
   
   (define-syntax foo
     (lambda (e)
       (or (identifier? e)
           (syntax-error))
       40))
   
   foo             ;==> 40
   ;; (set! foo 1) ;==> Syntax error: Syntax being set! is not a variable transformer
   ;; (foo)        ;==> syntax error
   
   (define p (cons 4 5))
   (define-syntax p.car
     (make-variable-transformer
      (lambda (x)
        (syntax-case x (set!)
          ((set! _ e) (syntax (set-car! p e)))
          ((_ . rest) (syntax ((car p) . rest)))
          (_          (syntax (car p)))))))
   (set! p.car 15)
   p.car           ;==> 15
   p               ;==> (15 5)
   
   (define p (cons 4 5))
   (define-syntax p.car (identifier-syntax (car p)))
   p.car              ;==> 4
   ;;(set! p.car 15)  ;==> Syntax error: Syntax being set! is not a variable transformer
   
   (define p (cons 4 5))
   (define-syntax p.car
     (identifier-syntax
      (_          (car p))
      ((set! _ e) (set-car! p e))))
   (set! p.car 15)
   p.car           ;==> 15
   p               ;==> (15 5)
   
   ;; Check displaced identifier error:
   
   ;; (let ((x 1))
   ;;   (let-syntax ((foo (lambda (x)
   ;;                       (syntax x))))
   ;;     (foo)))
   ;;             ;==> Syntax error: Attempt to use binding of x at invalid level 0 : Binding is valid at levels (1)
    
   
   ;; Forward references for internal define-syntax works
   ;; correctly (nontrivial to implement)
   
   (let ()
     (define-syntax odd
       (syntax-rules ()
         ((odd) #t)
         ((odd x . y) (not (even . y)))))
     (define-syntax even
       (syntax-rules ()
         ((even) #f)
         ((even x . y) (not (odd . y)))))
     (odd x x x))
   ;==> #t
   
   ;; Forward reference to procedure from transformer.
   
   (let ()
     (define-syntax foo
       (syntax-rules ()
         ((_) bar)))
     (define bar 1)
     (foo))            ;==> 1
   
   ;; Stress testing expander with internal letrec-generated body,
   ;; begins, etc.
   
   (let ()
     (letrec-syntax ((foo (syntax-rules ()
                            ((_) (begin (define (x) 1)
                                        (begin
                                          (define-syntax y
                                            (syntax-rules ()
                                              ((_) (x))))
                                          (bar y))))))
                     (bar (syntax-rules ()
                            ((_ y) (begin (define (z) (baz (y)))   
                                          (z)))))
                     (baz (syntax-rules ()
                            ((baz z) z))))     
       (foo)))
   ;==> 1
   
   ;; Big stress test, including nested let-syntax and
   ;; forward reference to later define-syntax.
   
   (let ((foo /))
     (letrec-syntax ((foo (syntax-rules ()
                            ((_ z) (begin (define (x) 4)
                                          (define-syntax y
                                            (syntax-rules ()
                                              ((_) (x))))
                                          (bar z y)))))
                     (bar (syntax-rules ()
                            ((_ z y) (define (z) (baz (y))))))  
                     (baz (syntax-rules ()
                            ((baz z) z))))     
       (let-syntax ((foobar (syntax-rules ()   ;; test nested let-syntax
                              ((_ u z)
                               (define-syntax u
                                 (syntax-rules ()
                                   ((_ x y) (z x y))))))))
         (foo a)                
         (foobar gaga goo)))   ;; foobar creates forward reference to goo
     ;; from expanded transformer.
     (define-syntax goo (syntax-rules ()
                          ((_ x y) (define-syntax x
                                     (syntax-rules ()
                                       ((_) y))))))
     (gaga b (a)) 
     (foo (b)))     ;==> 1/4
   
   ;; Internal let-syntax, but in a library,
   ;; which is the same algorithm as in a lambda body.  
   
   (library test
     (export)
     (import r6rs)
     (let-syntax ((foo (syntax-rules ()
                         ((_ bar)
                          (begin
                            (define x 7)
                            (define-syntax bar
                              (syntax-rules ()
                                ((_) (display x)))))))))
       (foo baz)
       (baz)))
   
   (import test)  ;==> 7
   
   (let ((a 1)
         (b 2))
     (+ a b))     ;==> 3
   
   (define-syntax swap!
     (lambda (exp)
       (syntax-case exp ()
         ((_ a b)
          (syntax
           (let ((temp a))
             (set! a b)
             (set! b temp)))))))
   
   (let ((temp 1)
         (set! 2))
     (swap! set! temp)
     (values temp set!))   ;==> 2 1
   
   (let ((x 1))
     (let-syntax ((foo (lambda (exp) (syntax x))))
       (let ((x 2))
         (foo))))       ;==> 1
   
   ;; Testing toplevel forward references:
   
   (define (f) (g))
   (define (g) 1)
   (f)             ;==> 1
  
   ;; SRFI-93 example of expansion of internal definitions
   
   (let ()
     (define-syntax foo
       (syntax-rules ()
         ((foo x) (define x 37))))
     (foo a)
     a)                 ;==> 37
   
   ;; Secrecy of generated toplevel defines:
   
   (define x 1)
   (let-syntax ((foo (lambda (e)
                       (syntax (begin 
                                 (define x 2)
                                 x)))))
     (foo))  ;==> 2
   x         ;==> 1
   
   (case 'a
     ((b c) 'no)
     ((d a) 'yes))   ;==> yes
   
   (let ((x 1))
     (let-syntax ((foo (lambda (exp) (syntax x))))
       (let ((x 2))
         (foo))))       ;==> 1
   
   (let ((x 1))
     (let-syntax ((foo (lambda (exp) (datum->syntax (syntax y) 'x))))
       (let ((x 2))
         (foo))))       ;==> 1
   
   (let-syntax ((foo (lambda (exp)
                       (let ((id (cadr exp)))
                         (bound-identifier=? (syntax x)
                                             (syntax id))))))
     (foo x))    ;==> #f
   
   (cond (#f 1) (else 2))                 ;==> 2
   (let ((else #f)) (cond (else 2)))      ;==> unspecified
   
   (let-syntax ((m (lambda (form)
                     (syntax-case form ()
                       ((_ x) (syntax
                               (let-syntax ((n (lambda (_)
                                                 (syntax (let ((x 4)) x)))))
                                 (n))))))))
     (m z))   ;==> 4
   
   ;;;=========================================================================
   ;;
   ;; Composing macros with intentional variable capture using DATUM->SYNTAX
   ;;
   ;;;=========================================================================
   
   (define-syntax if-it
     (lambda (x)
       (syntax-case x ()
         ((k e1 e2 e3)
          (with-syntax ((it (datum->syntax (syntax k) 'it)))
            (syntax (let ((it e1))
                      (if it e2 e3))))))))
   
   (define-syntax when-it
     (lambda (x)
       (syntax-case x ()
         ((k e1 e2)
          (with-syntax ((it* (datum->syntax (syntax k) 'it)))
            (syntax (if-it e1
                           (let ((it* it)) e2)
                           (if #f #f))))))))
   
   (define-syntax my-or
     (lambda (x)
       (syntax-case x ()
         ((k e1 e2)
          (syntax (if-it e1 it e2))))))
   
   (if-it 2 it 3)    ;==> 2
   (when-it 42 it)   ;==> 42
   (my-or 2 3)       ;==> 2
   ;; (my-or #f it)   ;==> undefined identifier: it
   
   (let ((it 1)) (if-it 42 it #f))   ;==> 42
   (let ((it 1)) (when-it 42 it))    ;==> 42
   (let ((it 1)) (my-or #f it))      ;==> 1
   (let ((if-it 1)) (when-it 42 it)) ;==> 42
   
   ;;;=========================================================================
   ;;
   ;; Escaping ellipses:
   ;;
   ;;;=========================================================================
   
   (let-syntax ((m (lambda (form)
                     (syntax-case form ()
                       ((_ x ...)
                        (with-syntax ((::: (datum->syntax (syntax here) '...)))
                          (syntax
                           (let-syntax ((n (lambda (form)
                                             (syntax-case form ()
                                               ((_ x ... :::)
                                                (syntax `(x ... :::)))))))
                             (n a b c d)))))))))
     (m u v))
   
   ;;==> (a b c d)
   
   (let-syntax ((m (lambda (form)
                     (syntax-case form ()
                       ((_ x ...)
                        (syntax
                         (let-syntax ((n (lambda (form)
                                           (syntax-case form ()
                                             ((_ x ... (... ...))
                                              (syntax `(x ... (... ...))))))))
                           (n a b c d))))))))
     (m u v))
   
   ;;==> (a b c d)
   
   ;;;=========================================================================
   ;;
   ;; From R5RS:
   ;;
   ;;;=========================================================================
   
   (define-syntax or
     (syntax-rules ()
       ((or)          #f)
       ((or e)        e)
       ((or e1 e ...) (let ((temp e1))
                        (if temp temp (or e ...))))))
   
   (or #f #f 1)  ;==> 1
   
   (define-syntax or
     (lambda (form)
       (syntax-case form ()
         ((or)          (syntax #f))
         ((or e)        (syntax e))
         ((or e1 e ...) (syntax (let ((temp e1))
                                  (if temp temp (or e ...))))))))
   
   (or #f #f 1)  ;==> 1
   
   (let-syntax ((when (syntax-rules ()
                        ((when test stmt1 stmt2 ...)
                         (if test
                             (begin stmt1
                                    stmt2 ...))))))
     (let ((if #t))
       (when if (set! if 'now))
       if))                                  ;===>  now
   
   (let ((x 'outer))
     (let-syntax ((m (syntax-rules () ((m) x))))
       (let ((x 'inner))
         (m))))                              ;===>  outer
   
   (letrec-syntax
       ((my-or (syntax-rules ()
                 ((my-or) #f)
                 ((my-or e) e)
                 ((my-or e1 e2 ...)
                  (let ((temp e1))
                    (if temp
                        temp
                        (my-or e2 ...)))))))
     (let ((x #f)
           (y 7)
           (temp 8)
           (let odd?)
           (if even?))
       (my-or x
              (let temp)
              (if y)
              y)))                ;===>  7
   
   (define-syntax cond
     (syntax-rules (else =>)
       ((cond (else result1 result2 ...))
        (begin result1 result2 ...))
       ((cond (test => result))
        (let ((temp test))
          (if temp (result temp))))
       ((cond (test => result) clause1 clause2 ...)
        (let ((temp test))
          (if temp
              (result temp)
              (cond clause1 clause2 ...))))
       ((cond (test)) test)
       ((cond (test) clause1 clause2 ...)
        (let ((temp test))
          (if temp
              temp
              (cond clause1 clause2 ...))))
       ((cond (test result1 result2 ...))
        (if test (begin result1 result2 ...)))
       ((cond (test result1 result2 ...)
              clause1 clause2 ...)
        (if test
            (begin result1 result2 ...)
            (cond clause1 clause2 ...)))))
   
   (let ((=> #f))
     (cond (#t => 'ok)))                   ;===> ok
   
   (cond ('(1 2) => cdr))                  ;===> (2)
   
   (cond ((> 3 2) 'greater)
         ((< 3 2) 'less))                 ;===>  greater
   (cond ((> 3 3) 'greater)
         ((< 3 3) 'less)
         (else 'equal))                   ;===>  equal
   
   ;; Eli Barzilay
   ;; In thread:
   ;; R5RS macros...
   ;; http://groups.google.com/groups?selm=skitsdqjq3.fsf%40tulare.cs.cornell.edu
   
   (let-syntax ((foo
                 (syntax-rules ()
                   ((_ expr) (+ expr 1)))))
     (let ((+ *))
       (foo 3)))               ;==> 4
   
   ;; Al Petrofsky again
   ;; In thread:
   ;; Buggy use of begin in core:primitives cond and case macros.
   ;; http://groups.google.com/groups?selm=87bse3bznr.fsf%40radish.petrofsky.org
   
   (let-syntax ((foo (syntax-rules ()
                       ((_ var) (define var 1)))))
     (let ((x 2))
       (begin (define foo +))
       (cond (else (foo x)))
       x))                    ;==> 2
   
   ;; Al Petrofsky
   ;; In thread:
   ;; An Advanced syntax-rules Primer for the Mildly Insane
   ;; http://groups.google.com/groups?selm=87it8db0um.fsf@radish.petrofsky.org
   
   (let ((x 1))
     (let-syntax
         ((foo (syntax-rules ()
                 ((_ y) (let-syntax
                            ((bar (syntax-rules ()
                                    ((_) (let ((x 2)) y)))))
                          (bar))))))
       (foo x)))                        ;==> 1
   
   ;; another example:
   
   (let ((x 1))
     (let-syntax
         ((foo (syntax-rules ()
                 ((_ y) (let-syntax
                            ((bar (syntax-rules ()
                                    ((_ x) y))))
                          (bar 2))))))
       (foo x)))                         ;==> 1
   
   ;; Al Petrofsky
   
   (let ((a 1))
     (letrec-syntax
         ((foo (syntax-rules ()
                 ((_ b)
                  (bar a b))))
          (bar (syntax-rules ()
                 ((_ c d)
                  (cons c (let ((c 3))
                            (list d c 'c)))))))
       (let ((a 2))
         (foo a))))                ;==> (1 2 3 a)
   
   (let ((=> #f))
     (cond (#t => 'ok)))                   ;===> ok
   
   (cond ('(1 2) => cdr))                  ;===> (2)
   
   (cond ((< 3 2) 'less)
         ((> 3 2) 'greater))               ;===>  greater
   
   (cond ((> 3 3) 'greater)
         ((< 3 3) 'less)
         (else 'equal))                    ;===>  equal
   
   (define-syntax loop     ;; no change
     (lambda (x)
       (syntax-case x ()
         ((k e ...)
          (with-syntax ((break (datum->syntax (syntax k) 'break)))
            (syntax (call-with-current-continuation
                     (lambda (break)
                       (let f () e ... (f))))))))))
   
   (let ((n 3) (ls '()))
     (loop
      (if (= n 0) (break ls))
      (set! ls (cons 'a ls))
      (set! n (- n 1))))    ;==> (a a a)
   
   (let ((x '(1 3 5 7 9)))
     (do ((x x (cdr x))
          (sum 0 (+ sum (car x))))
       ((null? x) sum)))                ;==>  25
   
   (define-syntax define-structure    
     (lambda (x)
       (define gen-id
         (lambda (template-id . args)
           (datum->syntax template-id
                          (string->symbol
                           (apply string-append
                                  (map (lambda (x)
                                         (if (string? x)
                                             x
                                             (symbol->string
                                              (syntax->datum x))))
                                       args))))))
       (syntax-case x ()
         ((_ name field ...)
          (with-syntax
              ((constructor (gen-id (syntax name) "make-" (syntax name)))
               (predicate (gen-id (syntax name) (syntax name) "?"))
               ((access ...)
                (map (lambda (x) (gen-id x (syntax name) "-" x))
                     (syntax (field ...))))
               ((assign ...)
                (map (lambda (x) (gen-id x "set-" (syntax name) "-" x "!"))
                     (syntax (field ...))))
               (structure-length (+ (length (syntax (field ...))) 1))
               ((index ...) (let f ((i 1) (ids (syntax (field ...))))
                              (if (null? ids)
                                  '()
                                  (cons i (f (+ i 1) (cdr ids)))))))
            (syntax (begin
                      (define constructor
                        (lambda (field ...)
                          (vector 'name field ...)))
                      (define predicate
                        (lambda (x)
                          (and (vector? x)
                               (= (vector-length x) structure-length)
                               (eq? (vector-ref x 0) 'name))))
                      (define access (lambda (x) (vector-ref x index))) ...
                      (define assign
                        (lambda (x update)
                          (vector-set! x index update)))
                      ...)))))))
   
   (define-structure tree left right)
   (define t
     (make-tree
      (make-tree 0 1)
      (make-tree 2 3)))
   
   t                     ;==> #(tree #(tree 0 1) #(tree 2 3))
   (tree? t)             ;==> #t
   (tree-left t)         ;==>#(tree 0 1)
   (tree-right t)        ;==> #(tree 2 3)
   (set-tree-left! t 0)
   t                     ;==> #(tree 0 #(tree 2 3))
   
   ;; Quasisyntax tests:
   
   (define-syntax swap!
     (lambda (e)
       (syntax-case e ()
         ((_ a b)
          (let ((a (syntax a))
                (b (syntax b)))
            (quasisyntax
             (let ((temp ,a))
               (set! ,a ,b)
               (set! ,b temp))))))))
   
   (let ((temp 1)
         (set! 2))
     (swap! set! temp)
     (values temp set!))   ;==> 2 1
   
   (define-syntax case
     (lambda (x)
       (syntax-case x ()
         ((_ e c1 c2 ...)
          (quasisyntax
           (let ((t e))
             ,(let f ((c1    (syntax c1))
                      (cmore (syntax (c2 ...))))
                (if (null? cmore)
                    (syntax-case c1 (else)
                      ((else e1 e2 ...)    (syntax (begin e1 e2 ...)))
                      (((k ...) e1 e2 ...) (syntax (if (memv t '(k ...))
                                                       (begin e1 e2 ...)))))
                    (syntax-case c1 ()
                      (((k ...) e1 e2 ...)
                       (quasisyntax
                        (if (memv t '(k ...))
                            (begin e1 e2 ...)
                            ,(f (car cmore) (cdr cmore))))))))))))))
   
   (case 'a
     ((b c) 'no)
     ((d a) 'yes))
   
   (define-syntax let-in-order
     (lambda (form)
       (syntax-case form ()
         ((_ ((i e) ...) e0 e1 ...)
          (let f ((ies (syntax ((i e) ...)))
                  (its (syntax ())))
            (syntax-case ies ()
              (()            (quasisyntax (let ,its e0 e1 ...)))
              (((i e) . ies) (with-syntax (((t) (generate-temporaries '(t))))
                               (quasisyntax
                                (let ((t e))
                                  ,(f (syntax ies)
                                      (quasisyntax
                                       ((i t) ,@its)))))))))))))
   
   (let-in-order ((x 1)
                  (y 2))
                 (+ x y))                ;==> 3
   
   (let-syntax ((test-ellipses-over-unsyntax
                 (lambda (e)
                   (let ((a (syntax a)))
                     (with-syntax (((b ...) '(1 2 3)))
                       (quasisyntax
                        (quote ((b ,a) ...))))))))
     (test-ellipses-over-unsyntax))
   
   ;==> ((1 a) (2 a) (3 a))
   
   ;; Some tests found online (Guile?)
   
   (let-syntax ((test
                 (lambda (_)
                   (quasisyntax
                    '(list ,(+ 1 2) 4)))))
     (test))
   ;==> (list 3 4)
   
   (let-syntax ((test
                 (lambda (_)
                   (let ((name (syntax a)))
                     (quasisyntax '(list ,name ',name))))))
     (test))
   ;==> (list a 'a)
   
   (let-syntax ((test
                 (lambda (_)
                   (quasisyntax '(a ,(+ 1 2) ,@(map abs '(4 -5 6)) b)))))
     (test))
   ;==> (a 3 4 5 6 b)
   
   (let-syntax ((test
                 (lambda (_)
                   (quasisyntax '((foo ,(- 10 3)) ,@(cdr '(5)) . ,(car '(7)))))))
     (test))
   ;==> ((foo 7) . 7)
   
   (let-syntax ((test
                 (lambda (_)
                   (quasisyntax ,(+ 2 3)))))
     (test))
   ;==> 5
   
   (let-syntax ((test
                 (lambda (_)
                   (quasisyntax
                    '(a (quasisyntax (b ,(+ 1 2) ,(foo ,(+ 1 3) d) e)) f)))))
     (test))
   ;==> (a (quasisyntax (b ,(+ 1 2) ,(foo 4 d) e)) f)
   
   (let-syntax ((test
                 (lambda (_)
                   (let ((name1 (syntax x)) (name2 (syntax y)))
                     (quasisyntax
                      '(a (quasisyntax (b ,,name1 ,(syntax ,name2) d)) e))))))
     (test))
   ;==> (a (quasisyntax (b ,x ,(syntax y) d)) e)
   
   ;; Bawden's extensions:
   
   (let-syntax ((test
                 (lambda (_)
                   (quasisyntax '(a (unquote 1 2) b)))))
     (test))
   ;==> (a 1 2 b)
   
   (let-syntax ((test
                 (lambda (_)
                   (quasisyntax '(a (unquote-splicing '(1 2) '(3 4)) b)))))
     (test))
   ;==> (a 1 2 3 4 b)
   
   (let-syntax ((test
                 (lambda (_)
                   (declare (safe 2))
                   (let ((x (syntax (a b c))))
                     (quasisyntax '(quasisyntax (,,x ,@,x ,,@x ,@,@x)))))))
     (test))
   
   ;==> (quasisyntax (,(a b c) ,@(a b c) (unquote a b c) (unquote-splicing a b c)))
   ;;    which is equivalent to
   ;;    (quasisyntax (,(a b c) ,@(a b c) ,a ,b ,c ,@a ,@b ,@c)
   ;;    in the Bawden prescription
   
   )) ;; repl

