#|
Copyright (c) 2006 Cadence Research Systems

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


#| ------------------------------------------------------------------------
Acknowledgements:

This code is derived from the portable implementation of syntax-case
extracted from Chez Scheme Version 7.0 (Sep 02, 2005), written by Kent
Dybvig, Oscar Waddell, Bob Hieb, and Carl Bruggeman.
|#

#| ------------------------------------------------------------------------
Compatibility notes:

 - makes use of #'x abbreviation for (syntax x)

 - makes use of [ ] alternative for ( )

 - bodies with internal variable definitions expand into letrec*

 - the quasiquote transformer supports Alan Bawden's PEPM '99 nested
   quasiquote extensions

 - implements (define id) syntax

 - implements when and unless

 - implements fresh-syntax form mentioned in SRFI issues section

 - should use R6RS exception/condition facilities rather than
   implementation-dependent error hook

 - should use and define when, unless, and let-values instead of
   using internally defined when, unless, and (simplified) let-values.

 - should support R6RS libraries

 - should use R6RS records in place of vector-based structures

 - should use R6RS (unspecified) instead of (void)

 - should add support for R6RS case-lambda
|#

#| ------------------------------------------------------------------------
Porting notes:

To port this code to a new Scheme implementation, load syntax.pp (the
expanded version of syntax.ss), and register sc-expand as the current
expander (how this is done depends upon the implementation of Scheme). 
The hooks and constructors defined toward the beginning of the code below
should also be changed to accommodate the requirements of the Scheme
implementation.
|#

; -------------------------------------------------------------------------

(let ()
 ;; target implementation customization
  (begin
    (define eval-hook (lambda (x) (eval x)))

    (define error-hook (lambda (who why what) (error who "~a ~s" why what)))

    (define gensym-hook gensym)

    (define no-source #f)
    (define annotation? (lambda (x) #f))
    (define annotation-expression (lambda (x) x))
    (define annotation-source (lambda (x) no-source))
    (define strip-annotation (lambda (x) x))

    (define globals '())

    (define global-extend
      (lambda (type sym value)
        (set! globals (cons (cons sym (make-binding type value)) globals))))

    (define global-lookup
      (lambda (sym)
        (cond
          [(assq sym globals) => cdr]
          [else (cons 'global sym)])))

    (define build-application
      (lambda (src proc-expr arg-expr*)
        (cons proc-expr arg-expr*)))

    (define-syntax build-conditional
      (syntax-rules ()
        [(_ src test-expr then-expr else-expr)
         `(if ,test-expr ,then-expr ,else-expr)]
        [(_ src test-expr then-expr)
         `(if ,test-expr ,then-expr (void))]))

    (define build-global-reference
      (lambda (src var)
         var))

    (define build-lexical-reference
      (lambda (src var)
         var))

    (define build-lexical-assignment
      (lambda (src var expr)
        `(set! ,var ,expr)))

    (define build-global-assignment
      (lambda (src var expr)
        `(set! ,var ,expr)))

    (define build-lambda
      (lambda (src var* rest? expr)
        `(lambda
           ,(if rest?
                (let f ([var (car var*)] [var* (cdr var*)])
                  (if (pair? var*)
                      (cons var (f (car var*) (cdr var*)))
                      var))
                var*)
           ,expr)))

    (define build-primref
      (lambda (src name)
        name))

    (define build-data
      (lambda (src datum)
        `(quote ,datum)))

    (define build-sequence
      (lambda (src expr*)
        (let loop ([expr* expr*])
          (if (null? (cdr expr*))
              (car expr*)
              `(begin ,@expr*)))))

    (define build-letrec
      (lambda (src var* rhs-expr* body-expr)
        (if (null? var*)
            body-expr
            `(letrec ,(map list var* rhs-expr*) ,body-expr))))

    (define build-letrec*
      (lambda (src var* rhs-expr* body-expr)
        (if (null? var*)
            body-expr
            `(letrec* ,(map list var* rhs-expr*) ,body-expr))))

    (define build-lexical-var
      (lambda (src id)
        (gensym)))

    (define self-evaluating?
      (lambda (x)
        (or (boolean? x) (number? x) (string? x) (char? x))))
  )

 ;; generic procedures and syntax used within expander code only

  (define andmap
    (lambda (f ls . more)
      (let andmap ([ls ls] [more more] [a #t])
        (if (null? ls)
            a
            (let ([a (apply f (car ls) (map car more))])
              (and a (andmap (cdr ls) (map cdr more) a)))))))

  (define-syntax define-structure
    (lambda (x)
      (define construct-name
        (lambda (template-identifier . arg*)
          (datum->syntax
            template-identifier
            (string->symbol
              (apply
                string-append
                (map (lambda (x)
                       (if (string? x)
                           x
                           (symbol->string (syntax->datum x))))
                     arg*))))))
      (syntax-case x ()
        [(_ (name id ...))
         (let ([id* #'(id ...)])
           (with-syntax ([constructor (construct-name #'name "make-" #'name)]
                         [predicate (construct-name #'name #'name "?")]
                         [(access ...) (map (lambda (x)
                                              (construct-name x #'name "-" x))
                                            id*)]
                         [(assign ...) (map (lambda (x)
                                              (construct-name x "set-" #'name "-" x "!"))
                                            id*)]
                         [structure-length (+ (length id*) 1)]
                         [(index ...) (let f ([i 1] [id* id*])
                                        (if (null? id*)
                                            '()
                                            (cons i (f (+ i 1) (cdr id*)))))])
             #'(begin
                 (define constructor
                   (lambda (id ...)
                     (vector 'name id ... )))
                 (define predicate
                   (lambda (x)
                     (and (vector? x)
                          (= (vector-length x) structure-length)
                          (eq? (vector-ref x 0) 'name))))
                 (define access
                   (lambda (x)
                     (vector-ref x index)))
                 ...
                 (define assign
                   (lambda (x update)
                     (vector-set! x index update)))
                 ...)))])))

  (define-syntax let-values ; single-clause version
    (syntax-rules ()
      ((_ ((formals expr)) form1 form2 ...)
       (call-with-values (lambda () expr) (lambda formals form1 form2 ...)))))

 ;; start of expander-specific code

 ;; syntax objects consist of an expression and a wrap comprised of a
 ;; list of marks and list of substitutions.

  (define-structure (syntax-object expression mark* subst*))

 ;; strip strips away syntax-object and annotation wrappers

  (define strip
    (lambda (x m*)
      (if (top-marked? m*)
          (strip-annotation x)
          (let f ([x x])
            (cond
              [(syntax-object? x)
               (strip (syntax-object-expression x) (syntax-object-mark* x))]
              [(pair? x)
               (let ([a (f (car x))] [d (f (cdr x))])
                 (if (and (eq? a (car x)) (eq? d (cdr x))) x (cons a d)))]
              [(vector? x)
               (let ([old (vector->list x)])
                 (let ([new (map f old)])
                   (if (andmap eq? old new) x (list->vector new))))]
              [else x])))))


 ;; source returns the source, if any, associated with a syntax object

  (define source
    (lambda (e)
      (if (syntax-object? e)
          (source (syntax-object-expression e))
          (if (annotation? e)
              (annotation-source e)
              no-source))))

 ;; unannotate removes top level of annotation, if any

  (define unannotate
    (lambda (x)
      (if (annotation? x)
          (annotation-expression x)
          x)))

 ;; compile-time environments

 ;; wrap and environment comprise two level mapping.
 ;;
 ;;   <wrap> : id --> label
 ;;   <environment> : label --> <binding>

 ;; marks must be comparable with "eq?" and distinct from pairs and
 ;; the symbol top.

  (define top-mark* '(top))

  (define top-marked?
    (lambda (m*)
      (memq (car top-mark*) m*)))

  (define gen-mark (lambda () (string #\m)))

  (define anti-mark #f)

  (define add-mark
    (lambda (m e)
      (syntax-object e (list m) '(shift))))

  (define same-marks?
    (lambda (x y)
      (or (eq? x y)
          (and (and (not (null? x)) (not (null? y)))
               (eq? (car x) (car y))
               (same-marks? (cdr x) (cdr y))))))

 ;; substs are ribs or the special subst shift.  a shift is added into
 ;; a subst list whenever a mark is added.  its presence tells the lookup
 ;; routine (id->label) to shift (cdr) the marks
 ;;
 ;; <subst> ::= <rib> | shift
 ;; <rib>   ::= #((<sym> ...) ((<mark> ...) ...) (<label> ...))

  (define top-subst* '())

  (define add-subst
    (lambda (subst e)
      (if subst
          (syntax-object e '() (list subst))
          e)))

  (define join-wraps
    (lambda (m1* s1* e)
      (define cancel
        (lambda (ls1 ls2)
          (let f ([x (car ls1)] [ls1 (cdr ls1)])
            (if (null? ls1)
                (cdr ls2)
                (cons x (f (car ls1) (cdr ls1)))))))
      (let ([m2* (syntax-object-mark* e)] [s2* (syntax-object-subst* e)])
        (if (and (not (null? m1*)) (not (null? m2*)) (eq? (car m2*) anti-mark))
           ; cancel mark, anti-mark, and corresponding shifts
            (values (cancel m1* m2*) (cancel s1* s2*))
            (values (append m1* m2*) (append s1* s2*))))))

  (define syntax-object
    (lambda (e m* s*)
      (if (syntax-object? e)
          (let-values ([(m* s*) (join-wraps m* s* e)])
            (make-syntax-object (syntax-object-expression e) m* s*))
          (make-syntax-object e m* s*))))

  (define-structure (rib sym* mark** label*))

 ;; make-empty-rib and extend-rib! maintain ribs for lambda
 ;; and letrec bodies, for which ribs are built incrementally

  (define make-empty-rib
    (lambda ()
      (make-rib '() '() '())))

  (define extend-rib!
    (lambda (rib id label)
      (set-rib-sym*! rib (cons (id->sym id) (rib-sym* rib)))
      (set-rib-mark**! rib (cons (syntax-object-mark* id) (rib-mark** rib)))
      (set-rib-label*! rib (cons label (rib-label* rib)))))

 ;; make-full-rib is for lambda formals and the lhs variables of
 ;; various local binding constructs, like letrec or let-syntax.  it
 ;; returns a full rib or #f, if no rib is necessary

  (define make-full-rib
    (lambda (id* label*)
      (and (not (null? id*))
        (let-values ([(sym* mark**)
                      (let f ([id* id*])
                        (if (null? id*)
                            (values '() '())
                            (let-values ([(sym* mark**) (f (cdr id*))])
                              (values
                                (cons (id->sym (car id*)) sym*)
                                (cons (syntax-object-mark* (car id*)) mark**)))))])
          (make-rib sym* mark** label*)))))

 ;; labels must be comparable with "eq?" and distinct from symbols and pairs.

  (define gen-label (lambda () (string #\i)))

 ;; an environment is represented as a simple list of associations from
 ;; labels to bindings.

 ;; <environment> ::= ((<label> . <binding>)*)

 ;; identifier bindings include a type and a value

 ;; <binding> ::= (macro . <procedure>)        macro keyword
 ;;               (macro! . <procedure>)       set!-aware macro keyword
 ;;               (core . <procedure>)         core keyword
 ;;               (begin . #f)                 begin keyword
 ;;               (define . #f)                define keyword
 ;;               (define-syntax . #f)         define-syntax keyword
 ;;               (global . sym)               global variable
 ;;               (local-syntax . <rec?>)      let-syntax/letrec-syntax keyword
 ;;               (syntax . (<var> . <level>)) pattern variable
 ;;               (lexical . <var>)            lexical variable
 ;;               (displaced-lexical . #f)     label not found in store
 ;; <level>   ::= <nonnegative integer>
 ;; <var>     ::= variable returned by build-lexical-var
 ;; <rec>     ::= <boolean>

 ;; a macro is a user-defined syntactic form.  a core is a system-defined
 ;; syntactic form.  begin, define, define-syntax, let-syntax,
 ;; and letrec-syntax are treated specially since they can denote valid
 ;; internal definitions.

 ;; a pattern variable is a variable introduced by syntax-case and can
 ;; be referenced only within a syntax form.

 ;; a lexical variable is a lambda- or letrec-bound variable.

 ;; a displaced-lexical is a lexical identifier removed from its scope by
 ;; the return of a syntax object containing the identifier.  a displaced
 ;; lexical can also appear when a letrec-syntax-bound keyword is
 ;; referenced on the rhs of one of the letrec-syntax clauses.  a
 ;; displaced lexical should never occur with properly written macros.

  (define make-binding cons)
  (define binding-type car)
  (define binding-value cdr)

  (define null-env '())

  (define extend-env
    (lambda (label binding r)
      (cons (cons label binding) r)))

  (define extend-env*
    (lambda (label* binding* r)
      (if (null? label*)
          r
          (extend-env* (cdr label*) (cdr binding*)
            (extend-env (car label*) (car binding*) r)))))

  (define extend-var-env*
    ; variant of extend-env* that forms "lexical" bindings
    (lambda (label* var* r)
      (if (null? label*)
          r
          (extend-var-env* (cdr label*) (cdr var*)
            (extend-env (car label*) (make-binding 'lexical (car var*)) r)))))

  (define displaced-lexical-error
    (lambda (id)
      (syntax-error id "identifier out of context")))

  (define eval-transformer
    (lambda (x)
      (let ([x (eval-hook x)])
        (cond
          [(procedure? x) (make-binding 'macro x)]
          [(and (pair? x) (eq? (car x) 'macro!) (procedure? (cdr x))) x]
          [else (syntax-error b "invalid transformer")]))))

  (define id?
    (lambda (x)
      (if (syntax-object? x)
          (id? (syntax-object-expression x))
          (symbol? (unannotate x)))))

  (define id->sym
    (lambda (x)
      (if (syntax-object? x)
          (id->sym (syntax-object-expression x))
          (unannotate x))))

 ;; lexical variables

  (define gen-var
    (lambda (id)
      (build-lexical-var (source id) (id->sym id))))

 ;; looking up local bindings

  (define id->label
    (lambda (id)
      (let ([sym (id->sym id)])
        (let search ([subst* (syntax-object-subst* id)]
                     [mark* (syntax-object-mark* id)])
          (if (null? subst*)
              sym
              (let ([subst (car subst*)])
                (if (eq? subst 'shift)
                    (search (cdr subst*) (cdr mark*))
                    (let search-rib ([sym* (rib-sym* subst)] [i 0])
                      (cond
                        [(null? sym*) (search (cdr subst*) mark*)]
                        [(and (eq? (car sym*) sym)
                              (same-marks? mark* (list-ref (rib-mark** subst) i)))
                         (list-ref (rib-label* subst) i)]
                        [else (search-rib (cdr sym*) (+ i 1))])))))))))

  (define label->binding
    (lambda (x r)
      (cond
        [(symbol? x) (global-lookup x)]
        [(assq x r) => cdr]
        [else (make-binding 'displaced-lexical #f)])))

 ;; identifier comparisons

  (define free-id=?
    (lambda (i j)
      (eq? (id->label i) (id->label j))))

  (define bound-id=?
    (lambda (i j)
      (and (eq? (id->sym i) (id->sym j))
           (same-marks? (syntax-object-mark* i) (syntax-object-mark* j)))))

  (define bound-id-member?
    (lambda (x list)
      (and (not (null? list))
           (or (bound-id=? x (car list))
               (bound-id-member? x (cdr list))))))

 ;; bound-id error-checking helpers

  (define valid-bound-ids?
    (lambda (id*)
       (and (let all-ids? ([id* id*])
              (or (null? id*)
                  (and (id? (car id*))
                       (all-ids? (cdr id*)))))
            (distinct-bound-ids? id*))))

  (define distinct-bound-ids?
    (lambda (id*)
      (let distinct? ([id* id*])
        (or (null? id*)
            (and (not (bound-id-member? (car id*) (cdr id*)))
                 (distinct? (cdr id*)))))))

  (define invalid-ids-error
    (lambda (id* e class)
      (let find ([id* id*] [ok* '()])
        (if (null? id*)
            (syntax-error e) ; shouldn't happen
            (if (id? (car id*))
                (if (bound-id-member? (car id*) ok*)
                    (syntax-error (car id*) "duplicate " class)
                    (find (cdr id*) (cons (car id*) ok*)))
                (syntax-error (car id*) "invalid " class))))))

  (let () ; core expander and transformers

   ;; syntax-type returns two values: type and value:
   ;;
   ;;    type                   value         explanation
   ;;    -------------------------------------------------------------------
   ;;    begin                  #f            begin expression
   ;;    call                   #f            any other call
   ;;    constant               datum         self-evaluating datum
   ;;    core                   procedure     core form (including singleton)
   ;;    define                 #f            variable definition
   ;;    define-syntax          #f            syntax definition
   ;;    displaced-lexical      #f            displaced lexical identifier
   ;;    global                 sym           global variable
   ;;    lexical                name          lexical variable reference
   ;;    local-syntax           rec?          syntax definition
   ;;    macro                  procedure     transformer
   ;;    macro!                 procedure     set!-aware transformer
   ;;    syntax                 level         pattern variable
   ;;    other                  #f            anything else

    (define syntax-type
      (lambda (e r)
        (syntax-case e ()
          [id
           (id? #'id)
           (let* ([label (id->label #'id)]
                  [b (label->binding label r)]
                  [type (binding-type b)])
             (case type
               [(macro macro!) (values type (binding-value b) #'id)]
               [(lexical global syntax displaced-lexical)
                (values type (binding-value b) #f)]
               [else (values 'other #f #f)]))]
          [(id . rest)
           (if (id? #'id)
               (let* ([label (id->label #'id)]
                      [b (label->binding label r)]
                      [type (binding-type b)])
                 (case type
                   [(macro macro! core begin define define-syntax local-syntax)
                    (values type (binding-value b) #'id)]
                   [else (values 'call #f #f)]))
               (values 'call #f #f))]
          [_ (let ([d (strip e '())])
               (if (self-evaluating? d)
                   (values 'constant d #f)
                   (values 'other #f #f)))])))

   ;; in the chi functions, r is the environment used for references in
   ;; run-time code, and mr is the environment used for references in
   ;; meta (transformer) code

    (define chi
      (lambda (e r mr)
        (let-values ([(type value kwd) (syntax-type e r)])
          (case type
            [(lexical) (build-lexical-reference (source e) value)]
            [(global) (build-global-reference (source e) value)]
            [(core) (value e r mr)]
            [(constant) (build-data (source e) value)]
            [(call) (chi-application e r mr)]
            [(begin)
             (build-sequence (source e) (chi-exprs (parse-begin e #f) r mr))]
            [(macro macro!) (chi (chi-macro value e) r mr)]
            [(local-syntax)
             (let-values ([(e* r mr) (chi-local-syntax value e r mr)])
               (build-sequence (source e) (chi-exprs e* r mr)))]
            [(define)
             (parse-define e)
             (syntax-error e "invalid context for definition")]
            [(define-syntax)
             (parse-define-syntax e)
             (syntax-error e "invalid context for definition")]
            [(syntax)
             (syntax-error e "reference to pattern variable outside syntax form")]
            [(displaced-lexical) (displaced-lexical-error e)]
            [else (syntax-error e)]))))

    (define chi-exprs
      (lambda (x* r mr)
        (map (lambda (x) (chi x r mr)) x*)))

    (define chi-application
      (lambda (e r mr)
        (syntax-case e ()
          [(e0 e1 ...)
           (build-application (source e)
             (chi #'e0 r mr)
             (chi-exprs #'(e1 ...) r mr))])))

    (define chi-macro
      (lambda (p e)
        (add-mark (gen-mark) (p (add-mark anti-mark e)))))

   ;; when processing a lambda or letrec body, before the body forms are
   ;; processed, a new rib is created and added to the substs for each
   ;; body form.  this rib is augmented (destructively) each time a
   ;; definition is found in the left-to-right processing of the body forms.

    (define chi-body
      (lambda (outer-e e* r mr)
        (let ([rib (make-empty-rib)])
          (let parse ([e* (map (lambda (e) (add-subst rib e)) e*)] [r r] [mr mr]
                      [id* '()] [var* '()] [rhs* '()] [kwd* '()])
            (if (null? e*)
                (syntax-error outer-e "no expressions in body")
                (let ([e (car e*)])
                  (let-values ([(type value kwd) (syntax-type e r)])
                    (let ([kwd* (cons kwd kwd*)])
                      (case type
                        [(define)
                         (let-values ([(id rhs) (parse-define e)])
                           (when (bound-id-member? id kwd*)
                             (syntax-error id "undefined identifier"))
                           (let ([label (gen-label)] [var (gen-var id)])
                             (extend-rib! rib id label)
                             (parse (cdr e*)
                              ; add only to run-time environment
                               (extend-env label (make-binding 'lexical var) r)
                               mr
                               (cons id id*)
                               (cons var var*)
                               (cons rhs rhs*)
                               kwd*)))]
                        [(define-syntax)
                         (let-values ([(id rhs) (parse-define-syntax e)])
                           (when (bound-id-member? id kwd*)
                             (syntax-error id "undefined identifier"))
                           (let ([label (gen-label)])
                             (extend-rib! rib id label)
                             (let ([b (eval-transformer (chi rhs mr mr))])
                               (parse (cdr e*)
                                ; add to both run-time and meta environments
                                 (extend-env label b r)
                                 (extend-env label b mr)
                                 (cons id id*) var* rhs* kwd*))))]
                        [(begin)
                         (parse (append (parse-begin e #t) (cdr e*))
                           r mr id* var* rhs* kwd*)]
                        [(macro macro!)
                         (parse (cons (add-subst rib (chi-macro value e)) (cdr e*))
                           r mr id* var* rhs* kwd*)]
                        [(local-syntax)
                         (let-values ([(new-e* r mr) (chi-local-syntax value e r mr)])
                           (parse (append new-e* (cdr e*)) r mr id* var* rhs* kwd*))]
                        [else
                         (unless (valid-bound-ids? id*)
                           (invalid-ids-error id* outer-e "locally defined identifier"))
                         (build-letrec* no-source
                           (reverse var*) (chi-exprs (reverse rhs*) r mr)
                           (build-sequence no-source
                             (chi-exprs (cons e (cdr e*)) r mr)))])))))))))

    (define parse-define
      (lambda (e)
        (define valid-args?
          (lambda (args)
            (valid-bound-ids?
              (syntax-case args ()
                [(id ...) #'(id ...)]
                [(id ... . r) #'(id ... r)]
                [id #'(id)]))))
        (syntax-case e ()
          [(_ name e) (id? #'name) (values #'name #'e)]
          [(_ (name . args) e1 e2 ...)
           (and (id? #'name) (valid-args? #'args))
           (values #'name #'(lambda args e1 e2 ...))]
          [(_ name) (id? #'name) (values #'name #'(void))])))

    (define parse-define-syntax
      (lambda (e)
        (syntax-case e ()
          [(_ name rhs) (id? #'name) (values #'name #'rhs)])))

    (define parse-begin
      (lambda (e empty-okay?)
        (syntax-case e ()
          [(_) empty-okay? '()]
          [(_ e1 e2 ...) #'(e1 e2 ...)])))

    (define chi-local-syntax
      (lambda (rec? e r mr)
        (syntax-case e ()
          [(_ ((id rhs) ...) e1 e2 ...)
           (let ([id* #'(id ...)]
                 [rhs* #'(rhs ...)])
             (unless (valid-bound-ids? id*)
               (invalid-ids-error id* e "keyword"))
             (let* ([label* (map (lambda (x) (gen-label)) id*)]
                    [rib (make-full-rib id* label*)]
                    [b* (map (lambda (x) (eval-transformer (chi x mr mr)))
                             (if rec?
                                 (map (lambda (x) (add-subst rib x)) rhs*)
                                 rhs*))])
               (values
                 (map (lambda (e) (add-subst rib e)) #'(e1 e2 ...))
                 (extend-env* label* b* r)
                 (extend-env* label* b* mr))))])))

    (define ellipsis?
      (lambda (x)
        (and (id? x) (free-id=? x #'(... ...)))))

   ;; expander entry point

    (set! sc-expand
      (lambda (x)
        (chi (syntax-object x top-mark* top-subst*) null-env null-env)))

   ;; core transformers

    (global-extend 'begin 'begin #f)
    (global-extend 'define 'define #f)
    (global-extend 'define-syntax 'define-syntax #f)
    (global-extend 'local-syntax 'letrec-syntax #t)
    (global-extend 'local-syntax 'let-syntax #f)

    (global-extend 'core 'quote
      (lambda (e r mr)
        (syntax-case e ()
          [(_ e) (build-data (source #'e) (strip #'e '()))])))

    (global-extend 'core 'lambda
      (lambda (e r mr)
        (define help
          (lambda (var* rest? e*)
            (unless (valid-bound-ids? var*)
              (invalid-ids-error var* e "parameter"))
            (let ([label* (map (lambda (x) (gen-label)) var*)]
                  [new-var* (map gen-var var*)])
              (build-lambda (source e) new-var* rest?
                (chi-body e
                  (let ([rib (make-full-rib var* label*)])
                    (map (lambda (e) (add-subst rib e)) e*))
                  (extend-var-env* label* new-var* r)
                  mr)))))
        (syntax-case e ()
          [(_ (var ...) e1 e2 ...) (help #'(var ...) #f #'(e1 e2 ...))]
          [(_ (var ... . rvar) e1 e2 ...) (help `(,@#'(var ...) ,#'rvar) #t #'(e1 e2 ...))]
          [(_ var e1 e2 ...) (help `(,#'var) #t #'(e1 e2 ...))])))

    (global-extend 'core 'letrec
      (lambda (e r mr)
        (syntax-case e ()
          [(_ ((var rhs) ...) e1 e2 ...)
           (let ([var* #'(var ...)] [rhs* #'(rhs ...)] [e* #'(e1 e2 ...)])
             (unless (valid-bound-ids? var*)
               (invalid-ids-error var* e "bound variable"))
             (let ([label* (map (lambda (x) (gen-label)) var*)]
                   [new-var* (map gen-var var*)])
               (let ([r (extend-var-env* label* new-var* r)]
                     [rib (make-full-rib var* label*)])
                 (build-letrec (source e)
                   new-var*
                   (map (lambda (e) (chi (add-subst rib e) r mr)) rhs*)
                   (chi-body e (map (lambda (e) (add-subst rib e)) e*) r mr)))))])))

    (global-extend 'core 'letrec*
      (lambda (e r mr)
        (syntax-case e ()
          [(_ ((var rhs) ...) e1 e2 ...)
           (let ([var* #'(var ...)] [rhs* #'(rhs ...)] [e* #'(e1 e2 ...)])
             (unless (valid-bound-ids? var*)
               (invalid-ids-error var* e "bound variable"))
             (let ([label* (map (lambda (x) (gen-label)) var*)]
                   [new-var* (map gen-var var*)])
               (let ([r (extend-var-env* label* new-var* r)]
                     [rib (make-full-rib var* label*)])
                 (build-letrec* (source e)
                   new-var*
                   (map (lambda (e) (chi (add-subst rib e) r mr)) rhs*)
                   (chi-body e (map (lambda (e) (add-subst rib e)) e*) r mr)))))])))

    (global-extend 'core 'set!
      (lambda (e r mr)
        (syntax-case e ()
          [(_ id rhs)
           (id? #'id)
           (let ([b (label->binding (id->label #'id) r)])
             (case (binding-type b)
               [(macro!) (chi (chi-macro (binding-value b) e) r mr)]
               [(lexical)
                (build-lexical-assignment (source e)
                  (binding-value b)
                  (chi #'rhs r mr))]
               [(global)
                (build-global-assignment (source e)
                  (binding-value b)
                  (chi #'rhs r mr))]
               [(displaced-lexical) (displaced-lexical-error #'id)]
               [else (syntax-error e)]))])))

    (global-extend 'core 'if
      (lambda (e r mr)
        (syntax-case e ()
          [(_ test then)
           (build-conditional (source e)
             (chi #'test r mr)
             (chi #'then r mr))]
          [(_ test then else)
           (build-conditional (source e)
             (chi #'test r mr)
             (chi #'then r mr)
             (chi #'else r mr))])))

    (global-extend 'core 'syntax-case
      (let ()
        (define convert-pattern
         ; returns syntax-dispatch pattern & ids
          (lambda (pattern keys)
            (define cvt*
              (lambda (p* n ids)
                (if (null? p*)
                    (values '() ids)
                    (let-values ([(y ids) (cvt* (cdr p*) n ids)])
                      (let-values ([(x ids) (cvt (car p*) n ids)])
                        (values (cons x y) ids))))))
            (define cvt
              (lambda (p n ids)
                (cond
                  [(not (id? p))
                   (syntax-case p ()
                     [(x dots)
                      (ellipsis? #'dots)
                      (let-values ([(p ids) (cvt #'x (+ n 1) ids)])
                        (values
                          (if (eq? p 'any) 'each-any (vector 'each p))
                          ids))]
                     [(x dots y ... . z)
                      (ellipsis? #'dots)
                      (let-values ([(z ids) (cvt #'z n ids)])
                        (let-values ([(y ids) (cvt* #'(y ...) n ids)])
                          (let-values ([(x ids) (cvt #'x (+ n 1) ids)])
                            (values `#(each+ ,x ,(reverse y) ,z) ids))))]
                     [(x . y)
                      (let-values ([(y ids) (cvt #'y n ids)])
                        (let-values ([(x ids) (cvt #'x n ids)])
                          (values (cons x y) ids)))]
                     [() (values '() ids)]
                     [#(x ...)
                      (let-values ([(p ids) (cvt #'(x ...) n ids)])
                        (values (vector 'vector p) ids))]
                     [x (values (vector 'atom (strip p '())) ids)])]
                  [(bound-id-member? p keys)
                   (values (vector 'free-id p) ids)]
                  [(free-id=? p #'_) (values '_ ids)]
                  [else (values 'any (cons (cons p n) ids))])))
            (cvt pattern 0 '())))

        (define build-dispatch-call
          (lambda (pvars expr y r mr)
            (let ([ids (map car pvars)] [levels (map cdr pvars)])
              (let ([labels (map (lambda (x) (gen-label)) ids)]
                    [new-vars (map gen-var ids)])
                (build-application no-source
                  (build-primref no-source 'apply)
                  (list
                    (build-lambda no-source new-vars #f
                      (chi (add-subst (make-full-rib ids labels) expr)
                           (extend-env*
                             labels
                             (map (lambda (var level)
                                    (make-binding 'syntax `(,var . ,level)))
                                  new-vars
                                  (map cdr pvars))
                             r)
                           mr))
                    y))))))

        (define gen-clause
          (lambda (x keys clauses r mr pat fender expr)
            (let-values ([(p pvars) (convert-pattern pat keys)])
              (cond
                [(not (distinct-bound-ids? (map car pvars)))
                 (invalid-ids-error (map car pvars) pat "pattern variable")]
                [(not (andmap (lambda (x) (not (ellipsis? (car x)))) pvars))
                 (syntax-error pat "misplaced ellipsis in syntax-case pattern")]
                [else
                 (let ([y (gen-var #'tmp)])
                   (build-application no-source
                     (build-lambda no-source (list y) #f
                       (build-conditional no-source
                         (syntax-case fender ()
                           [#t y]
                           [_ (build-conditional no-source
                                (build-lexical-reference no-source y)
                                (build-dispatch-call pvars fender y r mr)
                                (build-data no-source #f))])
                         (build-dispatch-call pvars expr
                           (build-lexical-reference no-source y)
                           r mr)
                         (gen-syntax-case x keys clauses r mr)))
                     (list
                       (build-application no-source
                         (build-primref no-source '$syntax-dispatch)
                         (list
                           (build-lexical-reference no-source x)
                           (build-data no-source p))))))]))))

        (define gen-syntax-case
          (lambda (x keys clauses r mr)
            (if (null? clauses)
                (build-application no-source
                  (build-primref no-source 'syntax-error)
                  (list (build-lexical-reference no-source x)))
                (syntax-case (car clauses) ()
                  [(pat expr)
                   (if (and (id? #'pat)
                            (not (bound-id-member? #'pat keys))
                            (not (ellipsis? #'pat)))
                       (if (free-identifier=? #'pat #'_)
                           (chi #'expr r mr)
                           (let ([label (gen-label)] [var (gen-var #'pat)])
                             (build-application no-source
                               (build-lambda no-source (list var) #f
                                 (chi (add-subst
                                        (make-full-rib (list #'pat) (list label))
                                        #'expr)
                                      (extend-env
                                        label
                                        (make-binding 'syntax `(,var . 0))
                                        r)
                                      mr))
                               (list (build-lexical-reference no-source x)))))
                       (gen-clause x keys (cdr clauses) r mr #'pat #t #'expr))]
                  [(pat fender expr)
                   (gen-clause x keys (cdr clauses) r mr #'pat #'fender #'expr)]
                  [_ (syntax-error (car clauses) "invalid syntax-case clause")]))))

        (lambda (e r mr)
          (syntax-case e ()
            [(_ expr (key ...) m ...)
             (if (andmap (lambda (x) (and (id? x) (not (ellipsis? x)))) #'(key ...))
                 (let ([x (gen-var #'tmp)])
                   (build-application (source e)
                     (build-lambda no-source (list x) #f
                       (gen-syntax-case x #'(key ...) #'(m ...) r mr))
                     (list (chi #'expr r mr))))
                 (syntax-error e "invalid literals list in"))]))))

    (let ()
      (define gen-syntax
        (lambda (src e r maps ellipsis? vec? fm)
          (if (id? e)
              (let ([label (id->label e)])
                (let ([b (label->binding label r)])
                  (if (eq? (binding-type b) 'syntax)
                      (let-values ([(var maps)
                                    (let ([var.lev (binding-value b)])
                                      (gen-ref src (car var.lev) (cdr var.lev) maps))])
                        (values `(ref ,var) maps))
                      (if (ellipsis? e)
                          (syntax-error src "misplaced ellipsis in syntax form")
                          (values
                            `(quote ,(if fm (add-mark anti-mark (add-mark fm e)) e))
                            maps)))))
              (syntax-case e ()
                [(dots e)
                 (ellipsis? #'dots)
                 (if vec?
                     (syntax-error src "misplaced ellipsis in syntax form")
                     (gen-syntax src #'e r maps (lambda (x) #f) #f fm))]
                [(x dots . y)
                 (ellipsis? #'dots)
                 (let f ([y #'y]
                         [k (lambda (maps)
                              (let-values ([(x maps)
                                            (gen-syntax src #'x r
                                              (cons '() maps) ellipsis? #f fm)])
                                (if (null? (car maps))
                                    (syntax-error src "extra ellipsis in syntax form")
                                    (values (gen-map x (car maps)) (cdr maps)))))])
                   (syntax-case y ()
                     [() (k maps)]
                     [(dots . y)
                      (ellipsis? #'dots)
                      (f #'y
                         (lambda (maps)
                           (let-values ([(x maps) (k (cons '() maps))])
                             (if (null? (car maps))
                                 (syntax-error src "extra ellipsis in syntax form")
                                 (values (gen-mappend x (car maps)) (cdr maps))))))]
                     [_ (let-values ([(y maps) (gen-syntax src y r maps ellipsis? vec? fm)])
                          (let-values ([(x maps) (k maps)])
                            (values (gen-append x y) maps)))]))]
                [(x . y)
                 (let-values ([(xnew maps) (gen-syntax src #'x r maps ellipsis? #f fm)])
                   (let-values ([(ynew maps) (gen-syntax src #'y r maps ellipsis? vec? fm)])
                     (values (gen-cons e #'x #'y xnew ynew) maps)))]
                [#(x1 x2 ...)
                 (let ([ls #'(x1 x2 ...)])
                   (let-values ([(lsnew maps) (gen-syntax src ls r maps ellipsis? #t fm)])
                     (values (gen-vector e ls lsnew) maps)))]
                [() vec? (values '(quote ()) maps)]
                [_ (values `(quote ,e) maps)]))))
      (define gen-ref
        (lambda (src var level maps)
          (if (= level 0)
              (values var maps)
              (if (null? maps)
                  (syntax-error src "missing ellipsis in syntax form")
                  (let-values ([(outer-var outer-maps)
                                (gen-ref src var (- level 1) (cdr maps))])
                    (cond
                      [(assq outer-var (car maps)) =>
                       (lambda (b) (values (cdr b) maps))]
                      [else
                       (let ([inner-var (gen-var #'tmp)])
                         (values
                           inner-var
                           (cons
                             (cons (cons outer-var inner-var) (car maps))
                             outer-maps)))]))))))
      (define gen-append
        (lambda (x y)
          (if (equal? y '(quote ())) x `(append ,x ,y))))
      (define gen-mappend
        (lambda (e map-env)
          `(apply (primitive append) ,(gen-map e map-env))))
      (define gen-map
        (lambda (e map-env)
          (let ([formals (map cdr map-env)]
                [actuals (map (lambda (x) `(ref ,(car x))) map-env)])
            (cond
             ; identity map equivalence:
             ; (map (lambda (x) x) y) == y
              [(eq? (car e) 'ref)
               (car actuals)]
             ; eta map equivalence:
             ; (map (lambda (x ...) (f x ...)) y ...) == (map f y ...)
              [(andmap
                 (lambda (x) (and (eq? (car x) 'ref) (memq (cadr x) formals)))
                 (cdr e))
               `(map (primitive ,(car e))
                     ,@(map (let ([r (map cons formals actuals)])
                              (lambda (x) (cdr (assq (cadr x) r))))
                            (cdr e)))]
              [else `(map (lambda ,formals ,e) ,@actuals)]))))
      (define gen-cons
        (lambda (e x y xnew ynew)
          (case (car ynew)
            [(quote)
             (if (eq? (car xnew) 'quote)
                 (let ([xnew (cadr xnew)] [ynew (cadr ynew)])
                   (if (and (eq? xnew x) (eq? ynew y))
                       `(quote ,e)
                       `(quote (,xnew . ,ynew))))
                 (if (eq? (cadr ynew) '())
                     `(list ,xnew)
                     `(cons ,xnew ,ynew)))]
            [(list) `(list ,xnew ,@(cdr ynew))]
            [else `(cons ,xnew ,ynew)])))
      (define gen-vector
        (lambda (e ls lsnew)
          (cond
            [(eq? (car lsnew) 'quote)
             (if (eq? (cadr lsnew) ls)
                 `(quote ,e)
                 `(quote #(,@(cadr lsnew))))]
            [(eq? (car lsnew) 'list) `(vector ,@(cdr lsnew))]
            [else `(list->vector ,lsnew)])))
      (define regen
        (lambda (x)
          (case (car x)
            [(ref) (build-lexical-reference no-source (cadr x))]
            [(primitive) (build-primref no-source (cadr x))]
            [(quote) (build-data no-source (cadr x))]
            [(lambda) (build-lambda no-source (cadr x) #f (regen (caddr x)))]
            [(map)
             (let ([ls (map regen (cdr x))])
               (build-application no-source
                 (build-primref no-source 'map)
                 ls))]
            [else
             (build-application no-source
               (build-primref no-source (car x))
               (map regen (cdr x)))])))
      (global-extend 'core 'syntax
        (lambda (e r mr)
          (syntax-case e ()
            [(_ x)
             (let-values ([(e maps) (gen-syntax e #'x r '() ellipsis? #f #f)])
               (regen e))])))
      (global-extend 'core 'fresh-syntax
        (lambda (e r mr)
          (syntax-case e ()
            [(_ x)
             (let-values ([(e maps) (gen-syntax e #'x r '() ellipsis? #f (gen-mark))])
               (regen e))]))))
  )

 ;; syntax dispatcher (used by syntax-case output)

 ;; $syntax-dispatch expects an expression and a pattern.  If the expression
 ;; matches the pattern a list of the matching expressions for each
 ;; "any" is returned.  Otherwise, #f is returned.  (This use of #f will
 ;; not work on r4rs implementations that violate the ieee requirement
 ;; that #f and () be distinct.)

 ;; The expression is matched with the pattern as follows:

 ;; p in pattern:                        matches:
 ;;   ()                                 empty list
 ;;   _                                  anything (no binding created)
 ;;   any                                anything
 ;;   (p1 . p2)                          pair
 ;;   #(free-id <key>)                   <key> with free-identifier=?
 ;;   each-any                           any proper list
 ;;   #(each p)                          (p*)
 ;;   #(each+ p1 (p2_1 ...p2_n) p3)      (p1* (p2_n ... p2_1) . p3)
 ;;   #(vector p)                        #(x ...) if p matches (x ...)
 ;;   #(atom <object>)                   <object> with "equal?"

  (set! $syntax-dispatch
    (lambda (e p)
      (define match-each
        (lambda (e p m* s*)
          (cond
            [(pair? e)
             (let ([first (match (car e) p m* s* '())])
               (and first
                    (let ([rest (match-each (cdr e) p m* s*)])
                      (and rest (cons first rest)))))]
            [(null? e) '()]
            [(syntax-object? e)
             (let-values ([(m* s*) (join-wraps m* s* e)])
               (match-each (syntax-object-expression e) p m* s*))]
            [(annotation? e)
             (match-each (annotation-expression e) p m* s*)]
            [else #f])))
      (define match-each+
        (lambda (e x-pat y-pat z-pat m* s* r)
          (let f ([e e] [m* m*] [s* s*])
            (cond
              [(pair? e)
               (let-values ([(xr* y-pat r) (f (cdr e) m* s*)])
                 (if r
                     (if (null? y-pat)
                         (let ([xr (match (car e) x-pat m* s* '())])
                           (if xr
                               (values (cons xr xr*) y-pat r)
                               (values #f #f #f)))
                         (values
                           '()
                           (cdr y-pat)
                           (match (car e) (car y-pat) m* s* r)))
                     (values #f #f #f)))]
              [(syntax-object? e)
               (let-values ([(m* s*) (join-wraps m* s* e)])
                 (f (syntax-object-expression e) m* s*))]
              [(annotation? e) (f (annotation-expression e) m* s*)]
              [else (values '() y-pat (match e z-pat m* s* r))]))))
      (define match-each-any
        (lambda (e m* s*)
          (cond
            [(pair? e)
             (let ([l (match-each-any (cdr e) m* s*)])
               (and l (cons (syntax-object (car e) m* s*) l)))]
            [(null? e) '()]
            [(syntax-object? e)
             (let-values ([(m* s*) (join-wraps m* s* e)])
               (match-each-any (syntax-object-expression e) m* s*))]
            [(annotation? e)
             (match-each-any (annotation-expression e) m* s*)]
            [else #f])))
      (define match-empty
        (lambda (p r)
          (cond
            [(null? p) r]
            [(eq? p '_) r]
            [(eq? p 'any) (cons '() r)]
            [(pair? p) (match-empty (car p) (match-empty (cdr p) r))]
            [(eq? p 'each-any) (cons '() r)]
            [else
             (case (vector-ref p 0)
               [(each) (match-empty (vector-ref p 1) r)]
               [(each+)
                (match-empty
                  (vector-ref p 1)
                  (match-empty
                    (reverse (vector-ref p 2))
                    (match-empty (vector-ref p 3) r)))]
               [(free-id atom) r]
               [(vector) (match-empty (vector-ref p 1) r)]
               [else (error-hook '$syntax-dispatch "invalid pattern" p)])])))
      (define combine
        (lambda (r* r)
          (if (null? (car r*))
              r
              (cons (map car r*) (combine (map cdr r*) r)))))
      (define match*
        (lambda (e p m* s* r)
          (cond
            [(null? p) (and (null? e) r)]
            [(pair? p)
             (and (pair? e)
                  (match (car e) (car p) m* s*
                    (match (cdr e) (cdr p) m* s* r)))]
            [(eq? p 'each-any)
             (let ([l (match-each-any e m* s*)]) (and l (cons l r)))]
            [else
             (case (vector-ref p 0)
               [(each)
                (if (null? e)
                    (match-empty (vector-ref p 1) r)
                    (let ([r* (match-each e (vector-ref p 1) m* s*)])
                      (and r* (combine r* r))))]
               [(free-id)
                (and (symbol? e)
                     (free-id=? (syntax-object e m* s*) (vector-ref p 1))
                     r)]
               [(each+)
                (let-values ([(xr* y-pat r)
                              (match-each+ e (vector-ref p 1)
                                (vector-ref p 2) (vector-ref p 3) m* s* r)])
                  (and r
                       (null? y-pat)
                       (if (null? xr*)
                           (match-empty (vector-ref p 1) r)
                           (combine xr* r))))]
               [(atom) (and (equal? (vector-ref p 1) (strip e m*)) r)]
               [(vector)
                (and (vector? e)
                     (match (vector->list e) (vector-ref p 1) m* s* r))]
               [else (error-hook '$syntax-dispatch "invalid pattern" p)])])))
      (define match
        (lambda (e p m* s* r)
          (cond
            [(not r) #f]
            [(eq? p '_) r]
            [(eq? p 'any) (cons (syntax-object e m* s*) r)]
            [(syntax-object? e)
             (let-values ([(m* s*) (join-wraps m* s* e)])
               (match (syntax-object-expression e) p m* s* r))]
            [else (match* (unannotate e) p m* s* r)])))
      (match e p '() '() '())))

 ;; other exported routines

  (let ()
    (define arg-check
      (lambda (pred? x who)
        (unless (pred? x)
          (error-hook who "invalid argument" x))))

    (set! identifier?
      (lambda (x)
        (id? x)))

    (set! datum->syntax
      (lambda (id datum)
        (arg-check id? id 'datum->syntax)
        (make-syntax-object datum
          (syntax-object-mark* id)
          (syntax-object-subst* id))))

    (set! syntax->datum
      (lambda (x)
        (strip x '())))

    (set! generate-temporaries
      (lambda (ls)
        (arg-check list? ls 'generate-temporaries)
        (map (lambda (x)
               (make-syntax-object (gensym-hook) top-mark* top-subst*))
             ls)))

    (set! free-identifier=?
      (lambda (x y)
         (arg-check id? x 'free-identifier=?)
         (arg-check id? y 'free-identifier=?)
         (free-id=? x y)))

    (set! bound-identifier=?
      (lambda (x y)
         (arg-check id? x 'bound-identifier=?)
         (arg-check id? y 'bound-identifier=?)
         (bound-id=? x y)))

   ;; syntax-error is used to generate syntax error messages
    (set! syntax-error
      (lambda (object . messages)
        (for-each (lambda (x) (arg-check string? x 'syntax-error)) messages)
        (let ([message (if (null? messages)
                           "invalid syntax"
                           (apply string-append messages))])
          (error-hook #f message (strip object '())))))

    (set! make-variable-transformer
      (lambda (p)
        (arg-check procedure? p 'make-variable-transformer)
        (cons 'macro! p)))
  )

 ;; derived forms

  (global-extend 'macro 'with-syntax
    (lambda (x)
      (syntax-case x ()
        [(_ () e1 e2 ...) #'(begin e1 e2 ...)]
        [(_ ((out in)) e1 e2 ...)
         #'(syntax-case in () [out (begin e1 e2 ...)])]
        [(_ ((out in) ...) e1 e2 ...)
         #'(syntax-case (list in ...) ()
             [(out ...) (begin e1 e2 ...)])])))

  (global-extend 'macro 'syntax-rules
    (lambda (x)
      (define clause
        (lambda (y)
          (syntax-case y ()
            (((keyword . pattern) template)
             #'((dummy . pattern) #'template))
            (((keyword . pattern) fender template)
             #'((dummy . pattern) fender #'template))
            (_ (syntax-error x)))))
      (syntax-case x ()
        ((_ (k ...) cl ...)
         (andmap identifier? #'(k ...))
         (with-syntax (((cl ...) (map clause #'(cl ...))))
           #'(lambda (x) (syntax-case x (k ...) cl ...)))))))

  (global-extend 'macro 'or
    (lambda (x)
      (syntax-case x ()
        [(_) #'#f]
        [(_ e) #'e]
        [(_ e1 e2 e3 ...)
         #'(let ([t e1]) (if t t (or e2 e3 ...)))])))

  (global-extend 'macro 'and
    (lambda (x)
      (syntax-case x ()
        [(_ e1 e2 e3 ...) #'(if e1 (and e2 e3 ...) #f)]
        [(_ e) #'e]
        [(_) #'#t])))

  (global-extend 'macro 'let
    (lambda (x)
      (syntax-case x ()
        [(_ ((x v) ...) e1 e2 ...)
         (andmap identifier? #'(x ...))
         #'((lambda (x ...) e1 e2 ...) v ...)]
        [(_ f ((x v) ...) e1 e2 ...)
         (andmap identifier? #'(f x ...))
         #'((letrec ([f (lambda (x ...) e1 e2 ...)]) f) v ...)])))

  (global-extend 'macro 'let*
    (lambda (x)
      (syntax-case x ()
        [(_ () e1 e2 ...) #'(let () e1 e2 ...)]
        [(_ ([x v] ...) e1 e2 ...)
         (andmap identifier? #'(x ...))
         (let f ([bindings #'([x v] ...)])
           (syntax-case bindings ()
             [([x v]) #'(let ([x v]) e1 e2 ...)]
             [([x v] . rest)
              (with-syntax ([body (f #'rest)])
                #'(let ([x v]) body))]))])))

  (global-extend 'macro 'cond
    (lambda (x)
      (syntax-case x ()
        [(_ c1 c2 ...)
         (let f ([c1 #'c1] [c2* #'(c2 ...)])
           (syntax-case c2* ()
             [()
              (syntax-case c1 (else =>)
                [(else e1 e2 ...) #'(begin e1 e2 ...)]
                [(e0) #'(let ([t e0]) (if t t))]
                [(e0 => e1) #'(let ([t e0]) (if t (e1 t)))]
                [(e0 e1 e2 ...) #'(if e0 (begin e1 e2 ...))]
                [_ (syntax-error x)])]
             [(c2 c3 ...)
              (with-syntax ([rest (f #'c2 #'(c3 ...))])
                (syntax-case c1 (else =>)
                  [(e0) #'(let ([t e0]) (if t t rest))]
                  [(e0 => e1) #'(let ([t e0]) (if t (e1 t) rest))]
                  [(e0 e1 e2 ...) #'(if e0 (begin e1 e2 ...) rest)]
                  [_ (syntax-error x)]))]))])))

  (global-extend 'macro 'do
    (lambda (orig-x)
      (syntax-case orig-x ()
        ((_ ((var init . step) ...) (e0 e1 ...) c ...)
         (with-syntax (((step ...)
                        (map (lambda (v s)
                               (syntax-case s ()
                                 [() v]
                                 [(e) #'e]
                                 [_ (syntax-error orig-x)]))
                             #'(var ...)
                             #'(step ...))))
            (syntax-case #'(e1 ...) ()
              (() #'(let do ((var init) ...)
                      (if (not e0)
                          (begin c ... (do step ...)))))
              ((e1 e2 ...)
               #'(let do ((var init) ...)
                   (if e0
                       (begin e1 e2 ...)
                       (begin c ... (do step ...)))))))))))

  (global-extend 'macro 'quasiquote
    (let ()
      (define quasilist*
        (lambda (x y)
          (let f ([x x])
            (if (null? x) y (quasicons (car x) (f (cdr x)))))))
      (define quasicons
        (lambda (x y)
          (with-syntax ([x x] [y y])
            (syntax-case #'y (quote list?)
              [(quote dy)
               (syntax-case #'x (quote)
                 [(quote dx) #'(quote (dx . dy))]
                 [_ (if (null? #'dy) #'(list x) #'(cons x y))])]
              [(list? . stuff)
               #'(list x . stuff)]
              [_ #'(cons x y)]))))
      (define quasiappend
        (lambda (x y)
          (let ([ls (let f ([x x])
                      (if (null? x)
                          (syntax-case y (quote)
                            [(quote ()) '()]
                            [_ (list y)])
                          (syntax-case (car x) (quote)
                            [(quote ()) (f (cdr x))]
                            [_ (cons (car x) (f (cdr x)))])))])
            (cond
              [(null? ls) #'(quote ())]
              [(null? (cdr ls)) (car ls)]
              [else (with-syntax ([(p ...) ls]) #'(append p ...))]))))
      (define quasivector
        (lambda (x)
          (with-syntax ([pat-x x])
            (syntax-case #'pat-x (quote)
              [(quote (x ...)) #'(quote #(x ...))]
              [_ (let f ([x x] [k (lambda (ls) `(,#'vector ,@ls))])
                   (syntax-case x (quote list? cons)
                     [(quote (x ...))
                      (k #'((quote x) ...))]
                     [(list? x ...)
                      (k #'(x ...))]
                     [(cons x y)
                      (f #'y (lambda (ls) (k (cons #'x ls))))]
                     [_ #'(list->vector pat-x)]))]))))
      (define vquasi
        (lambda (p lev)
          (syntax-case p ()
            [(p . q)
             (syntax-case #'p ,unquote-splicing
               [(unquote p ...)
                (if (= lev 0)
                    (quasilist* #'(p ...) (vquasi #'q lev))
                    (quasicons
                      (quasicons #'(quote unquote) (quasi #'(p ...) (- lev 1)))
                      (vquasi #'q lev)))]
               [(unquote-splicing p ...)
                (if (= lev 0)
                    (quasiappend #'(p ...) (vquasi #'q lev))
                    (quasicons
                      (quasicons
                        #'(quote unquote-splicing)
                        (quasi #'(p ...) (- lev 1)))
                      (vquasi #'q lev)))]
               [p (quasicons (quasi #'p lev) (vquasi #'q lev))])]
            [() #'(quote ())])))
      (define quasi
        (lambda (p lev)
          (syntax-case p (unquote unquote-splicing quasiquote)
            [(unquote p)
             (if (= lev 0)
                 #'p
                 (quasicons #'(quote unquote) (quasi #'(p) (- lev 1))))]
            [((unquote p ...) . q)
             (if (= lev 0)
                 (quasilist* #'(p ...) (quasi #'q lev))
                 (quasicons
                   (quasicons #'(quote unquote) (quasi #'(p ...) (- lev 1)))
                   (quasi #'q lev)))]
            [((unquote-splicing p ...) . q)
             (if (= lev 0)
                 (quasiappend #'(p ...) (quasi #'q lev))
                 (quasicons
                   (quasicons
                     #'(quote unquote-splicing)
                     (quasi #'(p ...) (- lev 1)))
                   (quasi #'q lev)))]
            [(quasiquote p) (quasicons #'(quote quasiquote) (quasi #'(p) (+ lev 1)))]
            [(p . q) (quasicons (quasi #'p lev) (quasi #'q lev))]
            [#(x ...) (quasivector (vquasi #'(x ...) lev))]
            [p #'(quote p)])))
      (lambda (x)
        (syntax-case x ()
          [(_ e) (quasi #'e 0)]))))

  (global-extend 'macro 'unquote
    (lambda (x)
      (syntax-case x ()
        [(_ e ...)
         (syntax-error x "expression not valid outside of quasiquote")])))

  (global-extend 'macro 'unquote-splicing
    (lambda (x)
      (syntax-case x ()
        [(_ e ...)
         (syntax-error x "expression not valid outside of quasiquote")])))

  (global-extend 'macro 'case
    (syntax-rules (else)
      [(_ e0 [(k ...) e1 e2 ...] ... [else else-e1 else-e2 ...])
       (let ([t e0])
         (cond
           [(memv t '(k ...)) e1 e2 ...]
           ...
           [else else-e1 else-e2 ...]))]
      [(_ e0 [(ka ...) e1a e2a ...] [(kb ...) e1b e2b ...] ...)
       (let ([t e0])
         (cond
           [(memv t '(ka ...)) e1a e2a ...]
           [(memv t '(kb ...)) e1b e2b ...]
           ...))]))

  (global-extend 'macro 'identifier-syntax
    (syntax-rules (set!)
      [(_ e)
       (lambda (x)
         (syntax-case x ()
           [id (identifier? #'id) #'e]
           [(id x (... ...)) #'(e x (... ...))]))]
      [(_ (id exp1) ((set! var rhs) exp2))
       (and (identifier? #'id) (identifier? #'var))
       (make-variable-transformer
         (lambda (x)
           (syntax-case x (set!)
             [(set! var rhs) #'exp2]
             [(id x (... ...)) #'(exp1 x (... ...))]
             [id (identifier? #'id) #'exp1])))]))

  (global-extend 'macro 'when
    (syntax-rules ()
      [(_ test e1 e2 ...) (if test (begin e1 e2 ...))]))

  (global-extend 'macro 'unless
    (syntax-rules ()
      [(_ test e1 e2 ...) (when (not test) (begin e1 e2 ...))]))
)
