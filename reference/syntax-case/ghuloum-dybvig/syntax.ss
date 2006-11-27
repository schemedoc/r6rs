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

;;; September 13, 2006

#| ------------------------------------------------------------------------
Acknowledgements:

This code is derived from the portable implementation of syntax-case
extracted from Chez Scheme Version 7.0 (Sep 02, 2005), written by Kent
Dybvig, Oscar Waddell, Bob Hieb, Carl Bruggeman.

The current version, including support for libraries, was created by
Aziz Ghuloum and Kent Dybvig.
|#

#| ------------------------------------------------------------------------

TODO:
 - remove Chez Scheme dependencies where possible; document remainder

 - use R6RS exception/condition facilities rather than
   implementation-dependent error hook

 - use and define let-values instead of using an internally
   defined and simplified version

 - use R6RS records in place of vector-based structures

 - use R6RS (unspecified) instead of (void)

 - add support for declarations, case-lambda, quasisyntax, unsyntax,
   unsyntax-splicing, and any other new R6RS forms
|#

; -------------------------------------------------------------------------

(let ()
 ;; target implementation customization
  (begin
    (define eval-hook 
      (lambda (x)
        (parameterize ([current-expand #%sc-expand])
          (eval x))))

    (define error-hook (lambda (who why what) (error who "~a ~s" why what)))

    (define gensym-hook
      (let ([counter -1])
        (lambda (str)
          (set! counter (add1 counter))
          (gensym (string-append str "#" (number->string counter))))))

    (define generate-export-label
      (lambda (x)
        (gensym-hook (symbol->string x))))

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

    (define-syntax primitive-extend!
      (syntax-rules ()
        [(_ 'name value)
         (set-top-level-value! 'name
           (rec name
             value))]))

    (define build-application
      (lambda (src proc-expr arg-expr*)
        (cons proc-expr arg-expr*)))

    (define build-binding
      (lambda (type expr)
        `(cons ',type ,expr)))

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

    (define build-library
      (lambda (src libname libversion subst phases)
        `(lm:install-library ',libname ',libversion ',subst 
            (list . ,phases))))

    (define build-library-phase
      (lambda (req visit-code invoke-code)
        `(list ',req
               (lambda () ,visit-code)
               (lambda () ,invoke-code))))

    (define build-primref
      (lambda (src name) name))

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
      (lambda (src sym)
        (gensym-hook (symbol->string sym))))

    (define self-evaluating?
      (lambda (x)
        (or (boolean? x) (number? x) (string? x) (char? x))))

    )

 ;; generic procedures and syntax used within expander code only
   (define cdr-or-null
    (lambda (x)
      (cond
        [(null? x) '()]
        [else (cdr x)])))

  (define car-or-null
    (lambda (x)
      (cond
        [(null? x) '()]
        [else (car x)])))


  (define andmap
    (lambda (f ls . more)
      (let andmap ([ls ls] [more more] [a #t])
        (if (null? ls)
            a
            (let ([a (apply f (car ls) (map car more))])
              (and a (andmap (cdr ls) (map cdr more) a)))))))

  (define partition
    (lambda (pred ls)
      (let f ([ls ls])
        (if (null? ls)
           (values '() '())
            (let-values ([(ls1 ls2) (f (cdr ls))])
              (if (pred (car ls))
                  (values (cons (car ls) ls1) ls2)
                  (values ls1 (cons (car ls) ls2))))))))

  (define filter
    (lambda (pred ls)
      (cond
        [(null? ls) '()]
        [(pred (car ls))
         (cons (car ls) (filter pred (cdr ls)))]
        [else (filter pred (cdr ls))])))

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

  (define cte-lookup
    (lambda (cte sym)
      (cond
        [(assq sym cte) => cdr]
        [else (error-hook 'cte-lookup "undefined identifier ~s" sym)])))

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
  (define empty-subst* '(barrier))

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

 ;; local labels must be comparable with "eq?" and distinct from symbols,
 ;; which are used for library labels

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
 ;;               (global . sym)               global (or library) variable
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

  (define sanitize-binding
    (lambda (b)
      (cond
        [(procedure? b)
         (make-binding 'macro b)]
        [(and (pair? b) 
              (memq (car b) '(macro!))
              (procedure? (cdr b)))
         b]
        [else (error #f "invalid transformer ~s" b)])))

  (define eval-transformer
    (lambda (x)
      (sanitize-binding (eval-hook x))))

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
          (cond
            [(null? subst*) sym]
            [(eq? (car subst*) 'shift)
             (search (cdr subst*) (cdr mark*))]
            [(eq? (car subst*) 'barrier)
             #f]
            [else
             (let ([subst (car subst*)])
               (let search-rib ([sym* (rib-sym* subst)] [i 0])
                 (cond
                   [(null? sym*) (search (cdr subst*) mark*)]
                   [(and (eq? (car sym*) sym)
                         (same-marks? mark* (list-ref (rib-mark** subst) i)))
                    (list-ref (rib-label* subst) i)]
                   [else (search-rib (cdr sym*) (+ i 1))])))])))))

  (define inside-library (make-parameter #f))

  (define-structure (mlevel libspec phases nums r next))

  (define imported-lookup
    (lambda (x phases)
      (define lookup 
        (lambda (x phase)
          (cond
            [(assq x (lm:phase-env phase)) => cdr]
            [else #f])))
      (if (null? phases)
          (make-binding 'displaced-lexical #f)
          (or (lookup x (car phases))
              (imported-lookup x
                (append (lm:phase-import-phases (car phases))
                        (cdr phases)))))))

  (define label->binding
    (lambda (id x r m)
      (cond
        [(assq x r) => cdr]
        [(symbol? x)
         (if (inside-library)
             (begin
               ;(printf "ID=~s\n" id)
               ;(printf "R=~s\n" r)
               ;(printf "X=~s\n" x)
               (imported-lookup x (mlevel-phases m)))
             (global-lookup x))]
        [(pair? x) (label->binding id (car x) r m)]
        [else (make-binding 'displaced-lexical #f)])))

 ;; identifier comparisons

  (define free-id=?
    (lambda (i j)
      (let ([t0 (id->label i)] [t1 (id->label j)])
        (if (or t0 t1)
            (or (eq? t0 t1)
                (and (pair? t0) (pair? t1)
                     (eq? (cdr t0) (cdr t1))))
            (eq? (id->sym i) (id->sym j))))))

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

   ;; syntax-type returns three values: type, value, and kwd:
   ;;
   ;;    type                   value         kwd   explanation
   ;;    -------------------------------------------------------------------
   ;;    begin                  #f            id    begin expression
   ;;    call                   #f            #f    procedure call
   ;;    constant               datum         #f    self-evaluating datum
   ;;    core                   procedure     id    core form (including singleton)
   ;;    define                 #f            id    variable definition
   ;;    define-syntax          #f            id    syntax definition
   ;;    displaced-lexical      #f            #f    displaced lexical identifier
   ;;    global                 sym           #f    global (or library) variable
   ;;    lexical                name          #f    lexical variable reference
   ;;    local-syntax           rec?          id    syntax definition
   ;;    macro                  procedure     id    transformer
   ;;    macro!                 procedure     id    set!-aware transformer
   ;;    syntax                 level         #f    pattern variable
   ;;    other                  #f            #f    anything else
   ;;
   ;; kwd is the identifier used to identify the form, if any.

    (define syntax-type
      (lambda (e r m)
        (syntax-case e ()
          [id
           (id? #'id)
           (let* ([label (id->label #'id)]
                  [b (label->binding #'id label r m)]
                  [type (binding-type b)])
             (case type
               [(macro macro!) (values type (binding-value b) #'id)]
               [(lexical global core-primitive syntax displaced-lexical)
                (values type (binding-value b) #f)]
               [else (values 'other #f #f)]))]
          [(id . rest)
           (if (id? #'id)
               (let* ([label (id->label #'id)]
                      [b (label->binding #'id label r m)]
                      [type (binding-type b)])
                 (case type
                   [(macro macro! core begin define define-syntax local-syntax meta)
                    (values type (binding-value b) #'id)]
                   [else (values 'call #f #f)]))
               (values 'call #f #f))]
          [_ (let ([d (strip e '())])
               (if (self-evaluating? d)
                   (values 'constant d #f)
                   (values 'other #f #f)))])))

    (define next-meta
      (lambda (m)
        (or (mlevel-next m)
            (let ([n (make-mlevel (mlevel-libspec m) '() '() '() #f)])
              (set-mlevel-next! m n)
              n))))


    (define chi-library
      (lambda (e)

        (define-structure (library-binding type id label rhs exported))

        (define create-library-binding
          (lambda (type id label rhs)
            (make-library-binding type id label rhs #f)))
  
        (define process-import-spec*
          (lambda (import-spec* lib* m)
            ; need to check for duplicate imports (same name)
            ; but not complain if labels are the same
            (apply append 
              (map (lambda (spec lib)
                     (process-import-spec spec lib m))
                   import-spec* lib*))))

        (define extend-meta!
          (lambda (m phases labels)
            (unless (null? phases)
              (let f ([i 0] [m m] [p (car phases)] [p* (cdr phases)])
                (unless (memq p (mlevel-phases m))
                  (lm:visit-phase! p)
                  (set-mlevel-nums! m (cons i (mlevel-nums m)))
                  (set-mlevel-phases! m (cons p (mlevel-phases m))))
                (for-each
                  (lambda (x)
                    (let ([label (car x)] [binding (cdr x)])
                      (when (memq label labels)
                        (set-mlevel-r! m 
                          (cons x (mlevel-r m))))))
                 (lm:phase-env p))
                (unless (null? p*)
                  (f (add1 i) (next-meta m) (car p*) (cdr p*)))))))

        (define process-import-spec
          (lambda (import-spec lib m)
             (syntax-case import-spec ()
                [(for import-set phase* ...) (eq? (syntax->datum #'for) 'for)
                 (let* ([s (process-import-set 
                              #'import-set
                              (lm:library-subst lib))]
                        [labels (map cdr s)])
                   (for-each
                     (lambda (phase)
                       (syntax-case phase ()
                         [(meta n) (eq? (syntax->datum #'meta) 'meta)
                          (let ([n (syntax->datum #'n)])
                            (unless (>= n 0)
                              (syntax-error import-spec "invalid import spec"))
                            (let f ([m m] [n n])
                              (if (zero? n)
                                  (extend-meta! m 
                                    (lm:library-phases lib)
                                    labels)
                                  (f (next-meta m) (- n 1)))))]
                          [p (eq? (syntax->datum #'p) 'run)
                           (extend-meta! m (lm:library-phases lib) labels)]
                          [p (eq? (syntax->datum #'p) 'expand)
                           (extend-meta! (next-meta m) (lm:library-phases lib) labels)]
                          [_ (syntax-error import-spec "invalid import spec")]))
                      #'(phase* ...))
                   s)]
                [import-set
                 (process-import-spec `(for ,#'import-set run) lib m)])))

        (define process-import-set
          (lambda (import-set base)
            (syntax-case import-set ()
              [(only import-set id* ...) 
               (and (eq? (syntax->datum #'only) 'only) 
                    (andmap id? #'(id* ...)))
               (filter (lambda (x) (memq (car x) (syntax->datum #'(id* ...))))
                 (process-import-set #'import-set base))]
              [(except import-set id* ...)
               (and (eq? (syntax->datum #'except) 'except) 
                    (andmap id? #'(id* ...)))
               (filter (lambda (x) (not (memq (car x) (syntax->datum #'(id* ...))))) 
                  (process-import-set #'import-set base))]
              [(add-prefix import-set id)
               (and (eq? (syntax->datum #'add-prefix) 'add-prefix) (id? #'id))
               (map (lambda (x) 
                      (cons (string->symbol
                              (string-append 
                                (symbol->string (id->sym #'id)) 
                                (symbol->string (car x))))
                          (cdr x)))
                   (process-import-set #'import-set base))]
              [(rename import-set ([from to] ...)) 
               (and (eq? (syntax->datum #'rename) 'rename)
                    (andmap id? #'(from ...))
                    (andmap id? #'(to ...)))
               ;;; FIXME: check that all from ... are already in the set
               (let ([s (syntax->datum #'([from . to] ...))])
                 (map (lambda (x)
                        (cond
                          [(assq (car x) s) => (lambda (p) (cons (cdr p) (cdr x)))]
                          [else x]))
                   (process-import-set #'import-set base)))]
              [library-reference base])))

        (define process-exports 
          (lambda (export-spec*) 
            (syntax-case export-spec* ()
              [(id* ...) (andmap id? #'(id* ...)) #'(id* ...)]
              [_ (syntax-error export-spec* "invalid exports")])))
  
       (define parse-meta
          (lambda (x)
            (syntax-case x ()
              [(_ . x*) #'(x*)])))

        (define process-body
          (lambda (e* m r*)
            (define return
              (lambda (r mr* binding* mbinding* init* minit* kwd*)
                (let ([id* (map library-binding-id binding*)])
                  (unless (valid-bound-ids? id*)
                    (invalid-ids-error id* e* "locally defined identifier")))
                (values (cons r mr*)
                        (cons binding* mbinding*)
                        (cons init* minit*)
                        kwd*)))
            (let ([rib (make-empty-rib)])
              (let parse ([e* (map (lambda (e) (add-subst rib e)) e*)]
                          [r (car-or-null r*)] [mr* (cdr-or-null r*)]
                          [binding* '()] [mbinding* '()] 
                          [init* '()] [minit* '()] [kwd* '()])
                (if (null? e*)
                    (return r mr* binding* mbinding* init* minit* kwd*)
                    (let ([e (car e*)])
                      (let-values ([(type value kwd) (syntax-type e r m)])
                        (let ([kwd* (cons kwd kwd*)]) 
                          (case type
                            [(define)
                             (unless (null? init*)
                               (error #f "invalid context for definition"))
                             (let-values ([(id rhs) (parse-define e)])
                               (when (bound-id-member? id kwd*)
                                 (syntax-error id "undefined identifier"))
                               (let ([label (generate-export-label (id->sym id))])
                                 (extend-rib! rib id label)
                                 (parse (cdr e*) r mr*
                                   (cons (create-library-binding type id label rhs) binding*)
                                   mbinding* init* minit* kwd*)))]
                            [(define-syntax)
                             (unless (null? init*)
                               (error #f "invalid context for define-syntax"))
                             (let-values ([(id rhs) (parse-define-syntax e)])
                               (when (bound-id-member? id kwd*)
                                 (syntax-error id "undefined identifier"))
                               (let ([label (generate-export-label (id->sym id))])
                                 (let ([expanded-rhs 
                                        (chi rhs
                                             (car-or-null mr*)
                                             (cdr-or-null mr*)
                                             (next-meta m))])
                                   (extend-rib! rib id label) ; must be after chi on rhs
                                   (for-each 
                                     lm:invoke-phase 
                                     (mlevel-phases (next-meta m)))
                                   (let ([b (eval-transformer expanded-rhs)])
                                     (parse (cdr e*)
                                       (extend-env label b r) mr*
                                       (cons (create-library-binding type id label expanded-rhs)
                                             binding*)
                                       mbinding* init* minit*
                                       kwd*)))))]
                            [(begin)
                             (parse (append (parse-begin e #t) (cdr e*))
                                r mr* binding* mbinding* init* minit* kwd*)]
                            [(macro macro!) ; why are we adding rib again?
                             (parse (cons (add-subst rib (chi-macro value e)) (cdr e*))
                                r mr* binding* mbinding* init* minit* kwd*) ]
                            [(local-syntax)
                             (let-values ([(new-e* r)
                                           (chi-local-syntax value e r mr* m)])
                               (parse (append new-e* (cdr e*)) 
                                  r mr* binding* mbinding* init* minit* kwd*))]
                            [(meta) 
                             (let-values ([(mr* mbinding* minit* kwd*)
                                           (parse (parse-meta e) 
                                                  (car-or-null mr*)
                                                  (cdr-or-null mr*)
                                                  (car-or-null mbinding*)
                                                  (cdr-or-null mbinding*)
                                                  (car-or-null minit*)
                                                  (cdr-or-null minit*)
                                                  kwd*)])
                               (parse (cdr e*) r mr* binding* mbinding* init* minit* kwd*))] 
                            [else 
                             (return r mr* binding* mbinding*
                                     (append init* e*)
                                     minit* kwd*)]
                            )))))))))

        (define chi-residual*
          (lambda (m r* binding** init**)
            (if (and (null? r*) (null? binding**) (null? init**))
                '()
                (cons
                  (chi-residual m 
                     (car-or-null r*)
                     (cdr-or-null r*) 
                     (car-or-null binding**)
                     (car-or-null init**))
                  (chi-residual* (next-meta m)
                     (cdr-or-null r*)
                     (cdr-or-null binding**)
                     (cdr-or-null init**))))))

        (define inverse-lookup
          (lambda (x ls)
            (cond
              [(null? ls) #f]
              [(eq? x (cdar ls)) (caar ls)]
              [else (inverse-lookup x (cdr ls))])))

        (define chi-residual
          (lambda (m r mr* binding* init*)
             (let-values ([(var-binding* kwd-binding*)
                           (partition
                             (lambda (x) (eq? (library-binding-type x) 'define))
                             binding*)])
               (let ([kwd-rhs*   (map library-binding-rhs kwd-binding*)]
                     [kwd-label* (map library-binding-label kwd-binding*)]
                     [var-rhs*   (map library-binding-rhs var-binding*)]
                     [var-label* (map library-binding-label var-binding*)]
                     [var-lhs* 
                      (map (lambda (lb) (gen-var (library-binding-id lb))) var-binding*)])
                 (let* ([lexical-r 
                         (map 
                           (lambda (label lhs)
                             (cons label (make-binding 'lexical lhs)))
                           var-label* var-lhs*)]
                        [full-r (append lexical-r r)]
                        [var-rhs*
                         (map (lambda (x) (chi x full-r mr* m)) var-rhs*)]
                        [init*
                         (map (lambda (x) (chi x full-r mr* m)) init*)])
                   (build-library-phase
                      (map 
                         (lambda (x i)
                           `(,(lm:phase-name x) ,(lm:phase-version x) ,i))
                         (mlevel-phases m)
                         (mlevel-nums m))
                      (if (and (null? kwd-label*)
                               (null? var-label*)
                               (null? (mlevel-r m)))
                          (build-data no-source '())
                          (build-application no-source
                            (build-primref no-source 'list*)
                            (append 
                              (map (lambda (lhs rhs)
                                     (build-application no-source
                                       (build-primref no-source 'cons)
                                       `(,(build-data no-source lhs) ,rhs)))
                                   kwd-label* kwd-rhs*)
                              (list
                                (build-data no-source
                                  (append
                                    (map (lambda (x)
                                           (cons x (make-binding 'global x)))
                                         var-label*)
                                    (map (lambda (x)
                                           (cons
                                             (inverse-lookup (cdr x) r)
                                             (cons 'imported (car x))))
                                         (mlevel-r m))))))))
                      ;;; invoke-code
                      (if (and (null? init*) (null? var-label*))
                          (build-application no-source
                            (build-primref no-source 'void) '())
                          (build-letrec* no-source
                            var-lhs* var-rhs*
                            (build-sequence no-source
                                  `(,@(map
                                        (lambda (label var-lhs)
                                           (build-global-assignment
                                             no-source label
                                             (build-lexical-reference no-source var-lhs)))
                                        var-label* var-lhs*)
                                    ,@init*))))))))))


        (define make-initial-env
          (lambda (import-labels new-labels m)
            (let ([a (map cons import-labels new-labels)])
              (let f ([m m])
                (if m 
                    (cons
                       (map (lambda (x)
                              (cond
                                [(assq (car x) a) =>
                                 (lambda (p)
                                   (cons (cdr p) (cdr x)))]
                                [else cannot-happen]))
                            (mlevel-r m))
                       (f (mlevel-next m)))
                    '())))))

        (define make-exports-subst
          (lambda (export-list local-binding** imported-subst)
            (define local-export
              (lambda (x)
                (let f ([b** local-binding**])
                  (and (pair? b**)
                       (or (let f ([b* (car b**)])
                             (and (pair? b*)
                                  (let ([b (car b*)])
                                    (if (eq? (id->sym (library-binding-id b)) x)
                                        (cons x (library-binding-label b))
                                        (f (cdr b*))))))
                           (f (cdr b**)))))))
            (map
              (lambda (x) 
                (or (local-export x)
                    (assq x imported-subst)
                    (error 'export "~s is unexportable because it is unbound" x)))
              export-list)))

        (let-values ([(libname version import-spec* export-spec* b*)
                      (parse-library e)])
          (let ([export* (process-exports export-spec*)]
                [m (make-mlevel (cons (syntax->datum libname)
                                      (syntax->datum version))
                                '() '() '() #f)])
            (lm:install-library-header (syntax->datum libname)) 
            (let* ([lib* (lm:get-libraries-for-import-spec 
                           (syntax->datum import-spec*))]
                   [import-subst* (process-import-spec* import-spec* lib* m)]
                   [import-names (map car import-subst*)]
                   [import-labels (map cdr import-subst*)]
                   [my-labels (map generate-export-label import-labels)]
                   [composite-labels (map cons my-labels import-labels)]
                   [new-marks* (map (lambda (x) top-mark*) import-labels)])
              (let-values ([(r* binding** init** kwd*-ignored)
                            (process-body
                              (map (lambda (x)
                                     (make-syntax-object
                                       (syntax->datum x)
                                       top-mark*
                                       (list
                                         (make-rib import-names new-marks*
                                                   composite-labels))))
                                   b*)
                              m
                              (make-initial-env import-labels my-labels m))])
                (build-library no-source
                  (syntax->datum libname) (syntax->datum version)
                  (make-exports-subst
                     (syntax->datum export*)
                     binding**
                     (map cons import-names my-labels))
                  (chi-residual* m r* (map reverse binding**) init**))))))))

    (define parse-library
      (lambda (e)
        (syntax-case e ()
          [(_ (id ...) (export export-spec ...) (import import-spec ...) b ...)
           (and (eq? 'export (syntax->datum #'export))
                (eq? 'import (syntax->datum #'import)) 
                (andmap identifier? #'(id ...)))
           (values #'(id ...) '() #'(import-spec ...) #'(export-spec ...) #'(b ...))]
          [(_ (id ... (sv ...)) (export export-spec ...) (import import-spec ...) b ...)
           (and (eq? 'export (syntax->datum #'export))
                (eq? 'import (syntax->datum #'import)) 
             (andmap identifier? #'(id ...))
                (andmap 
                  (lambda (n) (and (exact? n) (integer? n) (nonnegative? n)))
                  #'(sv ...)))
           (values #'(id ...) #'(sv ...) #'(import-spec ...) #'(export-spec ...) #'(b ...))]
          [(_ id (export export-spec ...) (import import-spec ...) b ...)
           (and (eq? 'export (syntax->datum #'export))
                (eq? 'import (syntax->datum #'import)) 
                (identifier? #'id))
           (values #'(id) #'() #'(import-spec ...) #'(export-spec ...) #'(b ...))]
          [_ (syntax-error e "invalid library syntax")])))

    (define parse-import-spec
      (lambda (e)
        (syntax-case e ()
          [(id ...)
           (andmap identifier? #'(id ...))
           (values (syntax->datum #'(id ...)) '() #f)]
          [(id ... (sv ...))
           (and (andmap identifier? #'(id ...))
                (andmap (lambda (n) (and (exact? n) (integer? n) (nonnegative? n))) #'(sv ...)))
           (values (syntax->datum #'(id ...)) (syntax->datum #'(sv ...)) #f)])))

   ;; in the chi functions, r is the environment used for references in
   ;; run-time code, and mr is the environment used for references in
   ;; meta (transformer) code

    (define chi
      (lambda (e r mr* m)
        (let-values ([(type value kwd) (syntax-type e r m)])
          (case type
            [(lexical) (build-lexical-reference (source e) value)]
            [(global) (build-global-reference (source e) value)]
            [(core-primitive) (build-primref (source e) value)]
            [(core) 
             (let ([transformer value])
               (transformer e r mr* m))]
            [(constant) (build-data (source e) value)]
            [(call) (chi-application e r mr* m)]
            [(begin)
             (build-sequence (source e) (chi-exprs (parse-begin e #f) r mr* m))]
            [(macro macro!)
             (chi (chi-macro value e) r mr* m)]
            [(local-syntax)
             (let-values ([(e* r) (chi-local-syntax value e r mr* m)])
               (build-sequence (source e) (chi-exprs e* r mr* m)))]
            [(define)
             (parse-define e)
             (syntax-error e "invalid context for definition")]
            [(define-syntax)
             (parse-define-syntax e)
             (syntax-error e "invalid context for definition")]
            [(meta)
             (syntax-error e "invalid context for meta")]
            [(syntax)
             (syntax-error e "reference to pattern variable outside syntax form")]
            [(displaced-lexical) (displaced-lexical-error e)]
            [else (syntax-error e)]))))

    (define chi-exprs
      (lambda (x* r mr* m)
        (map (lambda (x) (chi x r mr* m)) x*)))

    (define chi-application
      (lambda (e r mr* m)
        (syntax-case e ()
          [(e0 e1 ...)
           (build-application (source e)
             (chi #'e0 r mr* m)
             (chi-exprs #'(e1 ...) r mr* m))])))

    (define chi-macro
      (lambda (p e)
        (let ([s (p (add-mark anti-mark e))])
          (add-mark (gen-mark) s))))


   ;; when processing a lambda or letrec body, before the body forms are
   ;; processed, a new rib is created and added to the substs for each
   ;; body form.  this rib is augmented (destructively) each time a
   ;; definition is found in the left-to-right processing of the body forms.

    (define chi-body
      (lambda (outer-e e* r mr* m)
        (let ([rib (make-empty-rib)])
          (let parse ([e* (map (lambda (e) (add-subst rib e)) e*)] [r r]
                      [id* '()] [var* '()] [rhs* '()] [kwd* '()])
            (if (null? e*)
                (syntax-error outer-e "no expressions in body")
                (let ([e (car e*)])
                  (let-values ([(type value kwd) (syntax-type e r m)])
                    (let ([kwd* (cons kwd kwd*)])
                      (case type
                        [(define)
                         (let-values ([(id rhs) (parse-define e)])
                           (when (bound-id-member? id kwd*)
                             (syntax-error id "undefined identifier"))
                           (let ([label (gen-label)] [var (gen-var id)])
                             (extend-rib! rib id label)
                             (parse (cdr e*)
                               (extend-env label (make-binding 'lexical var) r)
                               (cons id id*)
                               (cons var var*)
                               (cons rhs rhs*)
                               kwd*)))]
                        [(define-syntax)
                         (let-values ([(id rhs) (parse-define-syntax e)])
                           (when (bound-id-member? id kwd*)
                             (syntax-error id "undefined identifier"))
                           (let ([label (gen-label)])
                             (let ([expanded-rhs 
                                    (chi rhs
                                         (car-or-null mr*)
                                         (cdr-or-null mr*)
                                         (next-meta m))])
                               (extend-rib! rib id label) ; must be after chi on rhs
                               (for-each 
                                 lm:invoke-phase 
                                 (mlevel-phases (next-meta m)))
                               (let ([b (eval-transformer expanded-rhs)])
                                 (parse (cdr e*)
                                   (extend-env label b r)
                                   (cons id id*) var* rhs* kwd*)))))]
                        [(begin)
                         (parse (append (parse-begin e #t) (cdr e*))
                           r id* var* rhs* kwd*)]
                        [(macro macro!) 
                         (parse (cons (add-subst rib (chi-macro value e)) (cdr e*))
                           r id* var* rhs* kwd*)]
                        [(local-syntax)
                         (let-values ([(new-e* r)
                                       (chi-local-syntax value e r mr* m)])
                           (parse (append new-e* (cdr e*)) r id* var* rhs* kwd*))]
                        [(meta)
                         (syntax-error e "invalid context for meta")]
                        [else
                         (unless (valid-bound-ids? id*)
                           (invalid-ids-error id* outer-e "locally defined identifier"))
                         (build-letrec* no-source
                           (reverse var*) (chi-exprs (reverse rhs*) r mr* m)
                           (build-sequence no-source
                             (chi-exprs e* r mr* m)))])))))))))

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
      (lambda (rec? e r mr* m)
        (syntax-case e ()
          [(_ ((id rhs) ...) e1 e2 ...)
           (let ([id* #'(id ...)]
                 [rhs* #'(rhs ...)])
             (unless (valid-bound-ids? id*)
               (invalid-ids-error id* e "keyword"))
             (let* ([label* (map (lambda (x) (gen-label)) id*)]
                    [rib (make-full-rib id* label*)]
                    [b* (map (lambda (rhs)
                               (eval-transformer
                                 (chi rhs 
                                      (car-or-null mr*)
                                      (cdr-or-null mr*)
                                      (next-meta m))))
                             (if rec?
                                 (map (lambda (x) (add-subst rib x)) rhs*)
                                 rhs*))])
               (values
                 (map (lambda (e) (add-subst rib e)) #'(e1 e2 ...))
                 (extend-env* label* b* r))))])))

    (define ellipsis?
      (lambda (x)
        (and (id? x)
             (free-id=? x (syntax-object '... empty-subst* null-env)))))

   ;;; CORE
   ;; core transformers

    (define core-quote
      (lambda (e r mr* m)
        (syntax-case e ()
          [(_ e) (build-data (source #'e) (strip #'e '()))])))

    (define core-lambda 
      (lambda (e r mr* m)
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
                  mr*
                  m)))))
        (syntax-case e ()
          [(_ (var ...) e1 e2 ...) (help #'(var ...) #f #'(e1 e2 ...))]
          [(_ (var ... . rvar) e1 e2 ...) (help `(,@#'(var ...) ,#'rvar) #t #'(e1 e2 ...))]
          [(_ var e1 e2 ...) (help `(,#'var) #t #'(e1 e2 ...))])))

    (define core-letrec
      (lambda (e r mr* m)
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
                   (map (lambda (e) (chi (add-subst rib e) r mr* m)) rhs*)
                   (chi-body e (map (lambda (e) (add-subst rib e)) e*) r mr* m)))))])))

    (define core-letrec*
      (lambda (e r mr* m)
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
                   (map (lambda (e) (chi (add-subst rib e) r mr* m)) rhs*)
                   (chi-body e (map (lambda (e) (add-subst rib e)) e*) r mr* m)))))])))

    (define core-set!
      (lambda (e r mr* m)
        (syntax-case e ()
          [(_ id rhs)
           (id? #'id)
           (let ([b (label->binding #'id (id->label #'id) r m)])
             (case (binding-type b)
               [(macro!) (chi (chi-macro (binding-value b) e) r mr* m)]
               [(lexical)
                (build-lexical-assignment (source e)
                  (binding-value b)
                  (chi #'rhs r mr* m))]
               [(global)
                (build-global-assignment (source e)
                  (binding-value b)
                  (chi #'rhs r mr* m))]
               [(displaced-lexical) (displaced-lexical-error #'id)]
               [else (syntax-error e)]))])))

    (define core-if
      (lambda (e r mr* m)
        (syntax-case e ()
          [(_ test then)
           (build-conditional (source e)
             (chi #'test r mr* m)
             (chi #'then r mr* m))]
          [(_ test then else)
           (build-conditional (source e)
             (chi #'test r mr* m)
             (chi #'then r mr* m)
             (chi #'else r mr* m))])))

    (define core-syntax-case
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
                  [(free-id=? p (syntax-object '_ empty-subst* null-env))
                   (values '_ ids)]
                  [else (values 'any (cons (cons p n) ids))])))
            (cvt pattern 0 '())))
         
        (define build-dispatch-call
          (lambda (pvars expr y r mr* m)
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
                           mr*
                           m))
                    y))))))
        
        (define gen-clause
          (lambda (x keys clauses r mr* m pat fender expr)
            (let-values ([(p pvars) (convert-pattern pat keys)])
              (cond
                [(not (distinct-bound-ids? (map car pvars)))
                 (invalid-ids-error (map car pvars) pat "pattern variable")]
                [(not (andmap (lambda (x) (not (ellipsis? (car x)))) pvars))
                 (syntax-error pat "misplaced ellipsis in syntax-case pattern")]
                [else
                 (let ([y (gen-var 'tmp)])
                   (build-application no-source
                     (build-lambda no-source (list y) #f
                       (build-conditional no-source
                         (syntax-case fender ()
                           [#t y]
                           [_ (build-conditional no-source
                                (build-lexical-reference no-source y)
                                (build-dispatch-call pvars fender y r mr* m)
                                (build-data no-source #f))])
                         (build-dispatch-call pvars expr
                           (build-lexical-reference no-source y)
                           r mr* m)
                         (gen-syntax-case x keys clauses r mr* m)))
                     (list
                       (build-application no-source
                         (build-primref no-source '$syntax-dispatch)
                         (list
                           (build-lexical-reference no-source x)
                           (build-data no-source p))))))]))))
         
        (define gen-syntax-case
          (lambda (x keys clauses r mr* m)
            (if (null? clauses)
                (build-application no-source
                  (build-primref no-source 'syntax-error)
                  (list (build-lexical-reference no-source x)))
                (syntax-case (car clauses) ()
                  [(pat expr)
                   (if (and (id? #'pat)
                            (not (bound-id-member? #'pat keys))
                            (not (ellipsis? #'pat)))
                       (if (free-identifier=? #'pat
                             (syntax-object '_ empty-subst* null-env))
                           (chi #'expr r mr* m)
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
                                      mr*
                                      m))
                               (list (build-lexical-reference no-source x)))))
                       (gen-clause x keys (cdr clauses) r mr* m #'pat #t #'expr))]
                  [(pat fender expr)
                   (gen-clause x keys (cdr clauses) r mr* m #'pat #'fender #'expr)]
                  [_ (syntax-error (car clauses) "invalid syntax-case clause")]))))
        
        (lambda (e r mr* m)
          (syntax-case e ()
            [(_ expr (key ...) clauses ...)
             (if (andmap (lambda (x) (and (id? x) (not (ellipsis? x)))) #'(key ...))
                 (let ([x (gen-var 'tmp)]) ; FOO
                   (build-application (source e)
                     (build-lambda no-source (list x) #f
                       (gen-syntax-case x #'(key ...) #'(clauses ...) r mr* m))
                     (list (chi #'expr r mr* m))))
                 (syntax-error e "invalid literals list in"))]))))

    (define core-syntax
      (let ()
        (define gen-syntax
          (lambda (src e r m maps ellipsis? vec?)
            (if (id? e)
                (let ([label (id->label e)])
                  (let ([b (label->binding e label r m)])
                    (if (eq? (binding-type b) 'syntax)
                        (let-values ([(var maps)
                                      (let ([var.lev (binding-value b)])
                                        (gen-ref src (car var.lev) (cdr var.lev) maps))])
                          (values `(ref ,var) maps))
                        (if (ellipsis? e)
                            (syntax-error src "misplaced ellipsis in syntax form")
                            (begin
                              (values `(quote ,e) maps))))))
                (syntax-case e ()
                  [(dots e)
                   (ellipsis? #'dots)
                   (if vec?
                       (syntax-error src "misplaced ellipsis in syntax form")
                       (gen-syntax src #'e r m maps (lambda (x) #f) #f))]
                  [(x dots . y)
                   (ellipsis? #'dots)
                   (let f ([y #'y]
                           [k (lambda (maps)
                                (let-values ([(x maps)
                                              (gen-syntax src #'x r m
                                                (cons '() maps) ellipsis? #f)])
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
                       [_ (let-values ([(y maps) (gen-syntax src y r m maps ellipsis? vec?)])
                            (let-values ([(x maps) (k maps)])
                              (values (gen-append x y) maps)))]))]
                  [(x . y)
                   (let-values ([(xnew maps) (gen-syntax src #'x r m maps ellipsis? #f)])
                     (let-values ([(ynew maps) (gen-syntax src #'y r m maps ellipsis? vec?)])
                       (values (gen-cons e #'x #'y xnew ynew) maps)))]
                  [#(x1 x2 ...)
                   (let ([ls #'(x1 x2 ...)])
                     (let-values ([(lsnew maps) (gen-syntax src ls r m maps ellipsis? #t)])
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
                         (let ([inner-var (gen-var 'tmp)])
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
        (lambda (e r mr* m)
          (syntax-case e ()
            [(_ x)
             (let-values ([(e maps) (gen-syntax e #'x r m '() ellipsis? #f)])
               (regen e))]))))

  
    ;;;; EXTEND
   ;; expander entry point

    (primitive-extend! 'sc-expand
      (lambda (x) 
        (parameterize ([inside-library #f])
          (chi (syntax-object x top-mark* top-subst*)
               '() ; r
               '() ; mr*
               (make-mlevel '() '() '() '() #f)))))

    (primitive-extend! 'sc-expand-library
      (lambda (x)
        (parameterize ([inside-library #t])
          (chi-library (syntax-object x top-mark* top-subst*)))))

    (global-extend 'begin 'begin #f)
    (global-extend 'meta 'meta #f)
    (global-extend 'define 'define #f)
    (global-extend 'define-syntax 'define-syntax #f)
    (global-extend 'local-syntax 'letrec-syntax #t)
    (global-extend 'local-syntax 'let-syntax #f)
    (global-extend 'core 'quote core-quote)
    (global-extend 'core 'lambda core-lambda)
    (global-extend 'core 'letrec core-letrec)
    (global-extend 'core 'letrec* core-letrec*)
    (global-extend 'core 'set! core-set!)
    (global-extend 'core 'if core-if)
    (global-extend 'core 'syntax-case core-syntax-case)
    (global-extend 'core 'syntax core-syntax)

    (lm:extend-implementation-core!
      `([begin         (begin . #f)               #{$begin $begin}]
        [meta          (meta . #f)                #{$meta $meta}]
        [define        (define . #f)              #{$define $define}]
        [define-syntax (define-syntax . #f)       #{$define-syntax $define-syntax}]
        [let-syntax    (local-syntax . #f)        #{$let-syntax $let-syntax}]
        [letrec-syntax (local-syntax . #t)        #{$letrec-syntax $letrec-syntax}]
        [quote         (core . ,core-quote)       #{$quote $quote}]
        [lambda        (core . ,core-lambda)      #{$lambda $lambda}]
        [letrec        (core . ,core-letrec)      #{$letrec $letrec}]
        [letrec*       (core . ,core-letrec*)     #{$letrec* $letrec*}]
        [set!          (core . ,core-set!)        #{$set! $set!}]
        [if            (core . ,core-if)          #{$if $if}]
        [syntax-case   (core . ,core-syntax-case) #{$syntax-case $syntax-case}]
        [syntax        (core . ,core-syntax)      #{$syntax $syntax}]

        ;[display (core-primitive . display) #{$display $display}]
        ;[+ (core-primitive . +) #{$+ $+}]
        ;[integer? (core-primitive . integer?) #{$integer? $integer?}]
        ;[cons    (core-primitive . cons)    #{$cons $cons}]
        ;[identifier?    (core-primitive . identifier?)    #{$identifier? $identifier?}]
        ;[free-identifier=?    (core-primitive . free-identifier=?) #{$free-identifier=? $free-identifier=?}]
         

[make-parameter  (core-primitive . make-parameter) #{$make-parameter $make-parameter}]
[nonpositive?  (core-primitive . nonpositive?) #{$nonpositive? $nonpositive?}]
[scheme-environment  (core-primitive . scheme-environment) #{$scheme-environment $scheme-environment}]
[for-each  (core-primitive . for-each) #{$for-each $for-each}]
[char-numeric?  (core-primitive . char-numeric?) #{$char-numeric? $char-numeric?}]
[error-handler  (core-primitive . error-handler) #{$error-handler $error-handler}]
[magnitude  (core-primitive . magnitude) #{$magnitude $magnitude}]
[source-directories  (core-primitive . source-directories) #{$source-directories $source-directories}]
[sstats-gc-bytes  (core-primitive . sstats-gc-bytes) #{$sstats-gc-bytes $sstats-gc-bytes}]
[pretty-maximum-lines  (core-primitive . pretty-maximum-lines) #{$pretty-maximum-lines $pretty-maximum-lines}]
[set-sstats-bytes!  (core-primitive . set-sstats-bytes!) #{$set-sstats-bytes! $set-sstats-bytes!}]
[statistics  (core-primitive . statistics) #{$statistics $statistics}]
[hash-table?  (core-primitive . hash-table?) #{$hash-table? $hash-table?}]
[open-input-output-file  (core-primitive . open-input-output-file) #{$open-input-output-file $open-input-output-file}]
[open-output-file  (core-primitive . open-output-file) #{$open-output-file $open-output-file}]
[enable-interrupts  (core-primitive . enable-interrupts) #{$enable-interrupts $enable-interrupts}]
[waiter-prompt-string  (core-primitive . waiter-prompt-string) #{$waiter-prompt-string $waiter-prompt-string}]
[variable-expander  (core-primitive . variable-expander) #{$variable-expander $variable-expander}]
[char-upcase  (core-primitive . char-upcase) #{$char-upcase $char-upcase}]
[fxabs  (core-primitive . fxabs) #{$fxabs $fxabs}]
[unbox  (core-primitive . unbox) #{$unbox $unbox}]
[*  (core-primitive . *) #{$* $*}]
[+  (core-primitive . +) #{$+ $+}]
[with-output-to-string  (core-primitive . with-output-to-string) #{$with-output-to-string $with-output-to-string}]
[-  (core-primitive . -) #{$- $-}]
[logxor  (core-primitive . logxor) #{$logxor $logxor}]
[/  (core-primitive . /) #{$/ $/}]
[mark-port-closed!  (core-primitive . mark-port-closed!) #{$mark-port-closed! $mark-port-closed!}]
[eps-expand-once  (core-primitive . eps-expand-once) #{$eps-expand-once $eps-expand-once}]
[compile-profile  (core-primitive . compile-profile) #{$compile-profile $compile-profile}]
[record-reader  (core-primitive . record-reader) #{$record-reader $record-reader}]
[open-input-string  (core-primitive . open-input-string) #{$open-input-string $open-input-string}]
[compile  (core-primitive . compile) #{$compile $compile}]
[andmap  (core-primitive . andmap) #{$andmap $andmap}]
[<  (core-primitive . <) #{$< $<}]
[=  (core-primitive . =) #{$= $=}]
[call-with-values  (core-primitive . call-with-values) #{$call-with-values $call-with-values}]
[>  (core-primitive . >) #{$> $>}]
[make-boot-header  (core-primitive . make-boot-header) #{$make-boot-header $make-boot-header}]
[substq  (core-primitive . substq) #{$substq $substq}]
[subst  (core-primitive . subst) #{$subst $subst}]
[close-input-port  (core-primitive . close-input-port) #{$close-input-port $close-input-port}]
[substv  (core-primitive . substv) #{$substv $substv}]
[char-lower-case?  (core-primitive . char-lower-case?) #{$char-lower-case? $char-lower-case?}]
[compile-interpret-simple  (core-primitive . compile-interpret-simple) #{$compile-interpret-simple $compile-interpret-simple}]
[char->integer  (core-primitive . char->integer) #{$char->integer $char->integer}]
[expand  (core-primitive . expand) #{$expand $expand}]
[with-input-from-string  (core-primitive . with-input-from-string) #{$with-input-from-string $with-input-from-string}]
[collect-maximum-generation  (core-primitive . collect-maximum-generation) #{$collect-maximum-generation $collect-maximum-generation}]
[exit-handler  (core-primitive . exit-handler) #{$exit-handler $exit-handler}]
[process  (core-primitive . process) #{$process $process}]
[close-output-port  (core-primitive . close-output-port) #{$close-output-port $close-output-port}]
[visit  (core-primitive . visit) #{$visit $visit}]
[decode-float  (core-primitive . decode-float) #{$decode-float $decode-float}]
[reverse  (core-primitive . reverse) #{$reverse $reverse}]
[weak-cons  (core-primitive . weak-cons) #{$weak-cons $weak-cons}]
[number?  (core-primitive . number?) #{$number? $number?}]
[interpret  (core-primitive . interpret) #{$interpret $interpret}]
[make-input/output-port  (core-primitive . make-input/output-port) #{$make-input/output-port $make-input/output-port}]
[eval-syntax-expanders-when  (core-primitive . eval-syntax-expanders-when) #{$eval-syntax-expanders-when $eval-syntax-expanders-when}]
[eps-expand  (core-primitive . eps-expand) #{$eps-expand $eps-expand}]
[flush-output-port  (core-primitive . flush-output-port) #{$flush-output-port $flush-output-port}]
[fxmax  (core-primitive . fxmax) #{$fxmax $fxmax}]
[dynamic-wind  (core-primitive . dynamic-wind) #{$dynamic-wind $dynamic-wind}]
[vector-set!  (core-primitive . vector-set!) #{$vector-set! $vector-set!}]
[cflonum?  (core-primitive . cflonum?) #{$cflonum? $cflonum?}]
[make-output-port  (core-primitive . make-output-port) #{$make-output-port $make-output-port}]
[symbol->string  (core-primitive . symbol->string) #{$symbol->string $symbol->string}]
[fxmin  (core-primitive . fxmin) #{$fxmin $fxmin}]
[caaar  (core-primitive . caaar) #{$caaar $caaar}]
[modulo  (core-primitive . modulo) #{$modulo $modulo}]
[machine-type  (core-primitive . machine-type) #{$machine-type $machine-type}]
[caadr  (core-primitive . caadr) #{$caadr $caadr}]
[nonnegative?  (core-primitive . nonnegative?) #{$nonnegative? $nonnegative?}]
[list-tail  (core-primitive . list-tail) #{$list-tail $list-tail}]
[string?  (core-primitive . string?) #{$string? $string?}]
[gensym  (core-primitive . gensym) #{$gensym $gensym}]
[inspect/object  (core-primitive . inspect/object) #{$inspect/object $inspect/object}]
[string<?  (core-primitive . string<?) #{$string<? $string<?}]
[cadar  (core-primitive . cadar) #{$cadar $cadar}]
[string=?  (core-primitive . string=?) #{$string=? $string=?}]
[ceiling  (core-primitive . ceiling) #{$ceiling $ceiling}]
[record-type-symbol  (core-primitive . record-type-symbol) #{$record-type-symbol $record-type-symbol}]
[with-output-to-file  (core-primitive . with-output-to-file) #{$with-output-to-file $with-output-to-file}]
[getenv  (core-primitive . getenv) #{$getenv $getenv}]
[string>?  (core-primitive . string>?) #{$string>? $string>?}]
[ratnum?  (core-primitive . ratnum?) #{$ratnum? $ratnum?}]
[add1  (core-primitive . add1) #{$add1 $add1}]
[rationalize  (core-primitive . rationalize) #{$rationalize $rationalize}]
[caddr  (core-primitive . caddr) #{$caddr $caddr}]
[console-output-port  (core-primitive . console-output-port) #{$console-output-port $console-output-port}]
[1+  (core-primitive . 1+) #{$1+ $1+}]
[port-input-buffer  (core-primitive . port-input-buffer) #{$port-input-buffer $port-input-buffer}]
[1-  (core-primitive . 1-) #{$1- $1-}]
[read-token  (core-primitive . read-token) #{$read-token $read-token}]
[port-input-size  (core-primitive . port-input-size) #{$port-input-size $port-input-size}]
[abort  (core-primitive . abort) #{$abort $abort}]
[getprop  (core-primitive . getprop) #{$getprop $getprop}]
[disable-interrupts  (core-primitive . disable-interrupts) #{$disable-interrupts $disable-interrupts}]
[hash-table-for-each  (core-primitive . hash-table-for-each) #{$hash-table-for-each $hash-table-for-each}]
[port-handler  (core-primitive . port-handler) #{$port-handler $port-handler}]
[fxsll  (core-primitive . fxsll) #{$fxsll $fxsll}]
[revisit  (core-primitive . revisit) #{$revisit $revisit}]
[acosh  (core-primitive . acosh) #{$acosh $acosh}]
[fxsra  (core-primitive . fxsra) #{$fxsra $fxsra}]
[literal-identifier=?  (core-primitive . literal-identifier=?) #{$literal-identifier=? $literal-identifier=?}]
[printf  (core-primitive . printf) #{$printf $printf}]
[case-sensitive  (core-primitive . case-sensitive) #{$case-sensitive $case-sensitive}]
[cp0-outer-unroll-limit  (core-primitive . cp0-outer-unroll-limit) #{$cp0-outer-unroll-limit $cp0-outer-unroll-limit}]
[write-char  (core-primitive . write-char) #{$write-char $write-char}]
[sc-expand  (core-primitive . sc-expand) #{$sc-expand $sc-expand}]
[string-ci<?  (core-primitive . string-ci<?) #{$string-ci<? $string-ci<?}]
[fxsrl  (core-primitive . fxsrl) #{$fxsrl $fxsrl}]
[string-ci=?  (core-primitive . string-ci=?) #{$string-ci=? $string-ci=?}]
[heap-reserve-ratio  (core-primitive . heap-reserve-ratio) #{$heap-reserve-ratio $heap-reserve-ratio}]
[string-ci>?  (core-primitive . string-ci>?) #{$string-ci>? $string-ci>?}]
[sstats-difference  (core-primitive . sstats-difference) #{$sstats-difference $sstats-difference}]
[datum->syntax-object  (core-primitive . datum->syntax-object) #{$datum->syntax-object $datum->syntax-object}]
[merge  (core-primitive . merge) #{$merge $merge}]
[cdaar  (core-primitive . cdaar) #{$cdaar $cdaar}]
[unlock-object  (core-primitive . unlock-object) #{$unlock-object $unlock-object}]
[fxzero?  (core-primitive . fxzero?) #{$fxzero? $fxzero?}]
[current-eval  (core-primitive . current-eval) #{$current-eval $current-eval}]
[<=  (core-primitive . <=) #{$<= $<=}]
[cdadr  (core-primitive . cdadr) #{$cdadr $cdadr}]
[>=  (core-primitive . >=) #{$>= $>=}]
[list*  (core-primitive . list*) #{$list* $list*}]
[fxodd?  (core-primitive . fxodd?) #{$fxodd? $fxodd?}]
[generate-temporaries  (core-primitive . generate-temporaries) #{$generate-temporaries $generate-temporaries}]
[call-with-output-file  (core-primitive . call-with-output-file) #{$call-with-output-file $call-with-output-file}]
[console-input-port  (core-primitive . console-input-port) #{$console-input-port $console-input-port}]
[cp0-polyvariant  (core-primitive . cp0-polyvariant) #{$cp0-polyvariant $cp0-polyvariant}]
[sstats-print  (core-primitive . sstats-print) #{$sstats-print $sstats-print}]
[length  (core-primitive . length) #{$length $length}]
[cddar  (core-primitive . cddar) #{$cddar $cddar}]
[record-type-field-names  (core-primitive . record-type-field-names) #{$record-type-field-names $record-type-field-names}]
[trace-print  (core-primitive . trace-print) #{$trace-print $trace-print}]
[list?  (core-primitive . list?) #{$list? $list?}]
[caar  (core-primitive . caar) #{$caar $caar}]
[cdddr  (core-primitive . cdddr) #{$cdddr $cdddr}]
[zero?  (core-primitive . zero?) #{$zero? $zero?}]
[cfl*  (core-primitive . cfl*) #{$cfl* $cfl*}]
[cfl+  (core-primitive . cfl+) #{$cfl+ $cfl+}]
[acos  (core-primitive . acos) #{$acos $acos}]
[cadr  (core-primitive . cadr) #{$cadr $cadr}]
[cfl-  (core-primitive . cfl-) #{$cfl- $cfl-}]
[pretty-print  (core-primitive . pretty-print) #{$pretty-print $pretty-print}]
[pair?  (core-primitive . pair?) #{$pair? $pair?}]
[cfl/  (core-primitive . cfl/) #{$cfl/ $cfl/}]
[expt-mod  (core-primitive . expt-mod) #{$expt-mod $expt-mod}]
[fl<=  (core-primitive . fl<=) #{$fl<= $fl<=}]
[foreign-entry?  (core-primitive . foreign-entry?) #{$foreign-entry? $foreign-entry?}]
[mkdir  (core-primitive . mkdir) #{$mkdir $mkdir}]
[caaaar  (core-primitive . caaaar) #{$caaaar $caaaar}]
[record-predicate  (core-primitive . record-predicate) #{$record-predicate $record-predicate}]
[apropos  (core-primitive . apropos) #{$apropos $apropos}]
[fl>=  (core-primitive . fl>=) #{$fl>= $fl>=}]
[weak-pair?  (core-primitive . weak-pair?) #{$weak-pair? $weak-pair?}]
[string  (core-primitive . string) #{$string $string}]
[identifier?  (core-primitive . identifier?) #{$identifier? $identifier?}]
[register-signal-handler  (core-primitive . register-signal-handler) #{$register-signal-handler $register-signal-handler}]
[cfl=  (core-primitive . cfl=) #{$cfl= $cfl=}]
[print-graph  (core-primitive . print-graph) #{$print-graph $print-graph}]
[cdar  (core-primitive . cdar) #{$cdar $cdar}]
[caaadr  (core-primitive . caaadr) #{$caaadr $caaadr}]
[remove-hash-table!  (core-primitive . remove-hash-table!) #{$remove-hash-table! $remove-hash-table!}]
[cddr  (core-primitive . cddr) #{$cddr $cddr}]
[caadar  (core-primitive . caadar) #{$caadar $caadar}]
[rational?  (core-primitive . rational?) #{$rational? $rational?}]
[set-sstats-cpu!  (core-primitive . set-sstats-cpu!) #{$set-sstats-cpu! $set-sstats-cpu!}]
[caaddr  (core-primitive . caaddr) #{$caaddr $caaddr}]
[char-  (core-primitive . char-) #{$char- $char-}]
[fxlogor  (core-primitive . fxlogor) #{$fxlogor $fxlogor}]
[isqrt  (core-primitive . isqrt) #{$isqrt $isqrt}]
[top-level-bound?  (core-primitive . top-level-bound?) #{$top-level-bound? $top-level-bound?}]
[scheme-script  (core-primitive . scheme-script) #{$scheme-script $scheme-script}]
[char?  (core-primitive . char?) #{$char? $char?}]
[fx1+  (core-primitive . fx1+) #{$fx1+ $fx1+}]
[port-output-index  (core-primitive . port-output-index) #{$port-output-index $port-output-index}]
[fx1-  (core-primitive . fx1-) #{$fx1- $fx1-}]
[record-type-interfaces  (core-primitive . record-type-interfaces) #{$record-type-interfaces $record-type-interfaces}]
[char-ready?  (core-primitive . char-ready?) #{$char-ready? $char-ready?}]
[transcript-on  (core-primitive . transcript-on) #{$transcript-on $transcript-on}]
[flonum->fixnum  (core-primitive . flonum->fixnum) #{$flonum->fixnum $flonum->fixnum}]
[fixnum->flonum  (core-primitive . fixnum->flonum) #{$fixnum->flonum $fixnum->flonum}]
[abs  (core-primitive . abs) #{$abs $abs}]
[fl*  (core-primitive . fl*) #{$fl* $fl*}]
[fl+  (core-primitive . fl+) #{$fl+ $fl+}]
[collect-generation-radix  (core-primitive . collect-generation-radix) #{$collect-generation-radix $collect-generation-radix}]
[fl-  (core-primitive . fl-) #{$fl- $fl-}]
[write  (core-primitive . write) #{$write $write}]
[file-exists?  (core-primitive . file-exists?) #{$file-exists? $file-exists?}]
[random-seed  (core-primitive . random-seed) #{$random-seed $random-seed}]
[fl/  (core-primitive . fl/) #{$fl/ $fl/}]
[newline  (core-primitive . newline) #{$newline $newline}]
[logor  (core-primitive . logor) #{$logor $logor}]
[random  (core-primitive . random) #{$random $random}]
[car  (core-primitive . car) #{$car $car}]
[string<=?  (core-primitive . string<=?) #{$string<=? $string<=?}]
[scheme-report-environment  (core-primitive . scheme-report-environment) #{$scheme-report-environment $scheme-report-environment}]
[unread-char  (core-primitive . unread-char) #{$unread-char $unread-char}]
[syntax-error  (core-primitive . syntax-error) #{$syntax-error $syntax-error}]
[cadaar  (core-primitive . cadaar) #{$cadaar $cadaar}]
[fl<  (core-primitive . fl<) #{$fl< $fl<}]
[fl=  (core-primitive . fl=) #{$fl= $fl=}]
[pretty-initial-indent  (core-primitive . pretty-initial-indent) #{$pretty-initial-indent $pretty-initial-indent}]
[bytes-allocated  (core-primitive . bytes-allocated) #{$bytes-allocated $bytes-allocated}]
[fl>  (core-primitive . fl>) #{$fl> $fl>}]
[cdr  (core-primitive . cdr) #{$cdr $cdr}]
[keyboard-interrupt-handler  (core-primitive . keyboard-interrupt-handler) #{$keyboard-interrupt-handler $keyboard-interrupt-handler}]
[cpu-time  (core-primitive . cpu-time) #{$cpu-time $cpu-time}]
[cadadr  (core-primitive . cadadr) #{$cadadr $cadadr}]
[eq?  (core-primitive . eq?) #{$eq? $eq?}]
[bignum?  (core-primitive . bignum?) #{$bignum? $bignum?}]
[compile-compressed  (core-primitive . compile-compressed) #{$compile-compressed $compile-compressed}]
[sstats-bytes  (core-primitive . sstats-bytes) #{$sstats-bytes $sstats-bytes}]
[atan  (core-primitive . atan) #{$atan $atan}]
[string>=?  (core-primitive . string>=?) #{$string>=? $string>=?}]
[box?  (core-primitive . box?) #{$box? $box?}]
[fx*  (core-primitive . fx*) #{$fx* $fx*}]
[fx+  (core-primitive . fx+) #{$fx+ $fx+}]
[ash  (core-primitive . ash) #{$ash $ash}]
[fx-  (core-primitive . fx-) #{$fx- $fx-}]
[truncate-file  (core-primitive . truncate-file) #{$truncate-file $truncate-file}]
[gcd  (core-primitive . gcd) #{$gcd $gcd}]
[eof-object?  (core-primitive . eof-object?) #{$eof-object? $eof-object?}]
[fx/  (core-primitive . fx/) #{$fx/ $fx/}]
[fx<=  (core-primitive . fx<=) #{$fx<= $fx<=}]
[caddar  (core-primitive . caddar) #{$caddar $caddar}]
[member  (core-primitive . member) #{$member $member}]
[new-cafe  (core-primitive . new-cafe) #{$new-cafe $new-cafe}]
[asin  (core-primitive . asin) #{$asin $asin}]
[cd  (core-primitive . cd) #{$cd $cd}]
[read-char  (core-primitive . read-char) #{$read-char $read-char}]
[list->string  (core-primitive . list->string) #{$list->string $list->string}]
[fx>=  (core-primitive . fx>=) #{$fx>= $fx>=}]
[debug  (core-primitive . debug) #{$debug $debug}]
[transcript-cafe  (core-primitive . transcript-cafe) #{$transcript-cafe $transcript-cafe}]
[box  (core-primitive . box) #{$box $box}]
[cadddr  (core-primitive . cadddr) #{$cadddr $cadddr}]
[fx<  (core-primitive . fx<) #{$fx< $fx<}]
[fx=  (core-primitive . fx=) #{$fx= $fx=}]
[cos  (core-primitive . cos) #{$cos $cos}]
[fx>  (core-primitive . fx>) #{$fx> $fx>}]
[values  (core-primitive . values) #{$values $values}]
[angle  (core-primitive . angle) #{$angle $angle}]
[list-ref  (core-primitive . list-ref) #{$list-ref $list-ref}]
[profile-clear  (core-primitive . profile-clear) #{$profile-clear $profile-clear}]
[assq  (core-primitive . assq) #{$assq $assq}]
[string-length  (core-primitive . string-length) #{$string-length $string-length}]
[cons  (core-primitive . cons) #{$cons $cons}]
[assv  (core-primitive . assv) #{$assv $assv}]
[substq!  (core-primitive . substq!) #{$substq! $substq!}]
[cfl-magnitude-squared  (core-primitive . cfl-magnitude-squared) #{$cfl-magnitude-squared $cfl-magnitude-squared}]
[vector-ref  (core-primitive . vector-ref) #{$vector-ref $vector-ref}]
[cosh  (core-primitive . cosh) #{$cosh $cosh}]
[char-downcase  (core-primitive . char-downcase) #{$char-downcase $char-downcase}]
[print-gensym  (core-primitive . print-gensym) #{$print-gensym $print-gensym}]
[lcm  (core-primitive . lcm) #{$lcm $lcm}]
[number->string  (core-primitive . number->string) #{$number->string $number->string}]
[exp  (core-primitive . exp) #{$exp $exp}]
[map  (core-primitive . map) #{$map $map}]
[substv!  (core-primitive . substv!) #{$substv! $substv!}]
[set-timer  (core-primitive . set-timer) #{$set-timer $set-timer}]
[bwp-object?  (core-primitive . bwp-object?) #{$bwp-object? $bwp-object?}]
[sstats-gc-real  (core-primitive . sstats-gc-real) #{$sstats-gc-real $sstats-gc-real}]
[max  (core-primitive . max) #{$max $max}]
[real?  (core-primitive . real?) #{$real? $real?}]
[break-handler  (core-primitive . break-handler) #{$break-handler $break-handler}]
[min  (core-primitive . min) #{$min $min}]
[cp0-inner-unroll-limit  (core-primitive . cp0-inner-unroll-limit) #{$cp0-inner-unroll-limit $cp0-inner-unroll-limit}]
[most-positive-fixnum  (core-primitive . most-positive-fixnum) #{$most-positive-fixnum $most-positive-fixnum}]
[log  (core-primitive . log) #{$log $log}]
[gensym-count  (core-primitive . gensym-count) #{$gensym-count $gensym-count}]
[chmod  (core-primitive . chmod) #{$chmod $chmod}]
[eqv?  (core-primitive . eqv?) #{$eqv? $eqv?}]
[fllp  (core-primitive . fllp) #{$fllp $fllp}]
[record-field-accessible?  (core-primitive . record-field-accessible?) #{$record-field-accessible? $record-field-accessible?}]
[set-sstats-gc-count!  (core-primitive . set-sstats-gc-count!) #{$set-sstats-gc-count! $set-sstats-gc-count!}]
[make-engine  (core-primitive . make-engine) #{$make-engine $make-engine}]
[append  (core-primitive . append) #{$append $append}]
[foreign-callable-entry-point  (core-primitive . foreign-callable-entry-point) #{$foreign-callable-entry-point $foreign-callable-entry-point}]
[record-field-mutable?  (core-primitive . record-field-mutable?) #{$record-field-mutable? $record-field-mutable?}]
[set-port-output-size!  (core-primitive . set-port-output-size!) #{$set-port-output-size! $set-port-output-size!}]
[set-port-output-index!  (core-primitive . set-port-output-index!) #{$set-port-output-index! $set-port-output-index!}]
[record-type-field-decls  (core-primitive . record-type-field-decls) #{$record-type-field-decls $record-type-field-decls}]
[string-copy  (core-primitive . string-copy) #{$string-copy $string-copy}]
[call-with-current-continuation  (core-primitive . call-with-current-continuation) #{$call-with-current-continuation $call-with-current-continuation}]
[merge!  (core-primitive . merge!) #{$merge! $merge!}]
[collect-notify  (core-primitive . collect-notify) #{$collect-notify $collect-notify}]
[open-output-string  (core-primitive . open-output-string) #{$open-output-string $open-output-string}]
[make-polar  (core-primitive . make-polar) #{$make-polar $make-polar}]
[string->list  (core-primitive . string->list) #{$string->list $string->list}]
[string->symbol  (core-primitive . string->symbol) #{$string->symbol $string->symbol}]
[not  (core-primitive . not) #{$not $not}]
[syntax-object->datum  (core-primitive . syntax-object->datum) #{$syntax-object->datum $syntax-object->datum}]
[eval  (core-primitive . eval) #{$eval $eval}]
[print-level  (core-primitive . print-level) #{$print-level $print-level}]
[vector  (core-primitive . vector) #{$vector $vector}]
[tan  (core-primitive . tan) #{$tan $tan}]
[last-pair  (core-primitive . last-pair) #{$last-pair $last-pair}]
[transcript-off  (core-primitive . transcript-off) #{$transcript-off $transcript-off}]
[generate-interrupt-trap  (core-primitive . generate-interrupt-trap) #{$generate-interrupt-trap $generate-interrupt-trap}]
[put-hash-table!  (core-primitive . put-hash-table!) #{$put-hash-table! $put-hash-table!}]
[sin  (core-primitive . sin) #{$sin $sin}]
[char-ci<?  (core-primitive . char-ci<?) #{$char-ci<? $char-ci<?}]
[application-expander  (core-primitive . application-expander) #{$application-expander $application-expander}]
[conjugate  (core-primitive . conjugate) #{$conjugate $conjugate}]
[char-ci=?  (core-primitive . char-ci=?) #{$char-ci=? $char-ci=?}]
[cdaaar  (core-primitive . cdaaar) #{$cdaaar $cdaaar}]
[set-port-input-size!  (core-primitive . set-port-input-size!) #{$set-port-input-size! $set-port-input-size!}]
[atanh  (core-primitive . atanh) #{$atanh $atanh}]
[char-ci>?  (core-primitive . char-ci>?) #{$char-ci>? $char-ci>?}]
[make-rectangular  (core-primitive . make-rectangular) #{$make-rectangular $make-rectangular}]
[print-length  (core-primitive . print-length) #{$print-length $print-length}]
[set-sstats-gc-cpu!  (core-primitive . set-sstats-gc-cpu!) #{$set-sstats-gc-cpu! $set-sstats-gc-cpu!}]
[cdaadr  (core-primitive . cdaadr) #{$cdaadr $cdaadr}]
[with-source-path  (core-primitive . with-source-path) #{$with-source-path $with-source-path}]
[fxlogand  (core-primitive . fxlogand) #{$fxlogand $fxlogand}]
[environment-symbols  (core-primitive . environment-symbols) #{$environment-symbols $environment-symbols}]
[remq!  (core-primitive . remq!) #{$remq! $remq!}]
[exit  (core-primitive . exit) #{$exit $exit}]
[cdadar  (core-primitive . cdadar) #{$cdadar $cdadar}]
[file-position  (core-primitive . file-position) #{$file-position $file-position}]
[fxpositive?  (core-primitive . fxpositive?) #{$fxpositive? $fxpositive?}]
[break  (core-primitive . break) #{$break $break}]
[hash-table-map  (core-primitive . hash-table-map) #{$hash-table-map $hash-table-map}]
[ieee-environment  (core-primitive . ieee-environment) #{$ieee-environment $ieee-environment}]
[cdaddr  (core-primitive . cdaddr) #{$cdaddr $cdaddr}]
[remv!  (core-primitive . remv!) #{$remv! $remv!}]
[apply  (core-primitive . apply) #{$apply $apply}]
[positive?  (core-primitive . positive?) #{$positive? $positive?}]
[remove!  (core-primitive . remove!) #{$remove! $remove!}]
[generate-inspector-information  (core-primitive . generate-inspector-information) #{$generate-inspector-information $generate-inspector-information}]
[integer->char  (core-primitive . integer->char) #{$integer->char $integer->char}]
[asinh  (core-primitive . asinh) #{$asinh $asinh}]
[expt  (core-primitive . expt) #{$expt $expt}]
[fxremainder  (core-primitive . fxremainder) #{$fxremainder $fxremainder}]
[odd?  (core-primitive . odd?) #{$odd? $odd?}]
[gensym-prefix  (core-primitive . gensym-prefix) #{$gensym-prefix $gensym-prefix}]
[file-length  (core-primitive . file-length) #{$file-length $file-length}]
[make-list  (core-primitive . make-list) #{$make-list $make-list}]
[record-type-descriptor  (core-primitive . record-type-descriptor) #{$record-type-descriptor $record-type-descriptor}]
[pretty-standard-indent  (core-primitive . pretty-standard-indent) #{$pretty-standard-indent $pretty-standard-indent}]
[compile-script  (core-primitive . compile-script) #{$compile-script $compile-script}]
[remainder  (core-primitive . remainder) #{$remainder $remainder}]
[string-fill!  (core-primitive . string-fill!) #{$string-fill! $string-fill!}]
[output-port?  (core-primitive . output-port?) #{$output-port? $output-port?}]
[delete-file  (core-primitive . delete-file) #{$delete-file $delete-file}]
[boolean?  (core-primitive . boolean?) #{$boolean? $boolean?}]
[gensym->unique-string  (core-primitive . gensym->unique-string) #{$gensym->unique-string $gensym->unique-string}]
[equal?  (core-primitive . equal?) #{$equal? $equal?}]
[compile-file  (core-primitive . compile-file) #{$compile-file $compile-file}]
[port-closed?  (core-primitive . port-closed?) #{$port-closed? $port-closed?}]
[set-port-input-index!  (core-primitive . set-port-input-index!) #{$set-port-input-index! $set-port-input-index!}]
[make-hash-table  (core-primitive . make-hash-table) #{$make-hash-table $make-hash-table}]
[set-car!  (core-primitive . set-car!) #{$set-car! $set-car!}]
[char-whitespace?  (core-primitive . char-whitespace?) #{$char-whitespace? $char-whitespace?}]
[memq  (core-primitive . memq) #{$memq $memq}]
[cddaar  (core-primitive . cddaar) #{$cddaar $cddaar}]
[warning  (core-primitive . warning) #{$warning $warning}]
[make-sstats  (core-primitive . make-sstats) #{$make-sstats $make-sstats}]
[atom?  (core-primitive . atom?) #{$atom? $atom?}]
[memv  (core-primitive . memv) #{$memv $memv}]
[internal-defines-as-letrec*  (core-primitive . internal-defines-as-letrec*) #{$internal-defines-as-letrec* $internal-defines-as-letrec*}]
[list->vector  (core-primitive . list->vector) #{$list->vector $list->vector}]
[display-string  (core-primitive . display-string) #{$display-string $display-string}]
[suppress-greeting  (core-primitive . suppress-greeting) #{$suppress-greeting $suppress-greeting}]
[cddadr  (core-primitive . cddadr) #{$cddadr $cddadr}]
[cp0-effort-limit  (core-primitive . cp0-effort-limit) #{$cp0-effort-limit $cp0-effort-limit}]
[inspect  (core-primitive . inspect) #{$inspect $inspect}]
[load  (core-primitive . load) #{$load $load}]
[most-negative-fixnum  (core-primitive . most-negative-fixnum) #{$most-negative-fixnum $most-negative-fixnum}]
[set-cdr!  (core-primitive . set-cdr!) #{$set-cdr! $set-cdr!}]
[bound-identifier=?  (core-primitive . bound-identifier=?) #{$bound-identifier=? $bound-identifier=?}]
[cfl-conjugate  (core-primitive . cfl-conjugate) #{$cfl-conjugate $cfl-conjugate}]
[vector->list  (core-primitive . vector->list) #{$vector->list $vector->list}]
[port-input-index  (core-primitive . port-input-index) #{$port-input-index $port-input-index}]
[reset-handler  (core-primitive . reset-handler) #{$reset-handler $reset-handler}]
[define-top-level-value  (core-primitive . define-top-level-value) #{$define-top-level-value $define-top-level-value}]
[cdddar  (core-primitive . cdddar) #{$cdddar $cdddar}]
[fasl-write  (core-primitive . fasl-write) #{$fasl-write $fasl-write}]
[list  (core-primitive . list) #{$list $list}]
[run-cp0  (core-primitive . run-cp0) #{$run-cp0 $run-cp0}]
[string-ref  (core-primitive . string-ref) #{$string-ref $string-ref}]
[fl-make-rectangular  (core-primitive . fl-make-rectangular) #{$fl-make-rectangular $fl-make-rectangular}]
[cddddr  (core-primitive . cddddr) #{$cddddr $cddddr}]
[fxnonpositive?  (core-primitive . fxnonpositive?) #{$fxnonpositive? $fxnonpositive?}]
[command-line-arguments  (core-primitive . command-line-arguments) #{$command-line-arguments $command-line-arguments}]
[lock-object  (core-primitive . lock-object) #{$lock-object $lock-object}]
[record-type-name  (core-primitive . record-type-name) #{$record-type-name $record-type-name}]
[reset  (core-primitive . reset) #{$reset $reset}]
[abort-handler  (core-primitive . abort-handler) #{$abort-handler $abort-handler}]
[-1+  (core-primitive . -1+) #{$-1+ $-1+}]
[string-append  (core-primitive . string-append) #{$string-append $string-append}]
[engine-return  (core-primitive . engine-return) #{$engine-return $engine-return}]
[assoc  (core-primitive . assoc) #{$assoc $assoc}]
[record-type-parent  (core-primitive . record-type-parent) #{$record-type-parent $record-type-parent}]
[exact?  (core-primitive . exact?) #{$exact? $exact?}]
[null?  (core-primitive . null?) #{$null? $null?}]
[date-and-time  (core-primitive . date-and-time) #{$date-and-time $date-and-time}]
[remprop  (core-primitive . remprop) #{$remprop $remprop}]
[record-writer  (core-primitive . record-writer) #{$record-writer $record-writer}]
[putenv  (core-primitive . putenv) #{$putenv $putenv}]
[substring  (core-primitive . substring) #{$substring $substring}]
[top-level-value  (core-primitive . top-level-value) #{$top-level-value $top-level-value}]
[pretty-file  (core-primitive . pretty-file) #{$pretty-file $pretty-file}]
[inexact->exact  (core-primitive . inexact->exact) #{$inexact->exact $inexact->exact}]
[putprop  (core-primitive . putprop) #{$putprop $putprop}]
[environment?  (core-primitive . environment?) #{$environment? $environment?}]
[subset-mode  (core-primitive . subset-mode) #{$subset-mode $subset-mode}]
[make-string  (core-primitive . make-string) #{$make-string $make-string}]
[inexact?  (core-primitive . inexact?) #{$inexact? $inexact?}]
[fixnum?  (core-primitive . fixnum?) #{$fixnum? $fixnum?}]
[flonum?  (core-primitive . flonum?) #{$flonum? $flonum?}]
[make-guardian  (core-primitive . make-guardian) #{$make-guardian $make-guardian}]
[fxlognot  (core-primitive . fxlognot) #{$fxlognot $fxlognot}]
[real-part  (core-primitive . real-part) #{$real-part $real-part}]
[ormap  (core-primitive . ormap) #{$ormap $ormap}]
[scheme-start  (core-primitive . scheme-start) #{$scheme-start $scheme-start}]
[record-constructor  (core-primitive . record-constructor) #{$record-constructor $record-constructor}]
[flabs  (core-primitive . flabs) #{$flabs $flabs}]
[waiter-prompt-and-read  (core-primitive . waiter-prompt-and-read) #{$waiter-prompt-and-read $waiter-prompt-and-read}]
[read  (core-primitive . read) #{$read $read}]
[waiter-write  (core-primitive . waiter-write) #{$waiter-write $waiter-write}]
[current-directory  (core-primitive . current-directory) #{$current-directory $current-directory}]
[block-read  (core-primitive . block-read) #{$block-read $block-read}]
[remove-foreign-entry  (core-primitive . remove-foreign-entry) #{$remove-foreign-entry $remove-foreign-entry}]
[set-box!  (core-primitive . set-box!) #{$set-box! $set-box!}]
[oblist  (core-primitive . oblist) #{$oblist $oblist}]
[record-field-mutator  (core-primitive . record-field-mutator) #{$record-field-mutator $record-field-mutator}]
[append!  (core-primitive . append!) #{$append! $append!}]
[vector-fill!  (core-primitive . vector-fill!) #{$vector-fill! $vector-fill!}]
[format  (core-primitive . format) #{$format $format}]
[free-identifier=?  (core-primitive . free-identifier=?) #{$free-identifier=? $free-identifier=?}]
[get-hash-table  (core-primitive . get-hash-table) #{$get-hash-table $get-hash-table}]
[quotient  (core-primitive . quotient) #{$quotient $quotient}]
[fxnegative?  (core-primitive . fxnegative?) #{$fxnegative? $fxnegative?}]
[thread?  (core-primitive . thread?) #{$thread? $thread?}]
[port?  (core-primitive . port?) #{$port? $port?}]
[remq  (core-primitive . remq) #{$remq $remq}]
[set-sstats-real!  (core-primitive . set-sstats-real!) #{$set-sstats-real! $set-sstats-real!}]
[fxquotient  (core-primitive . fxquotient) #{$fxquotient $fxquotient}]
[negative?  (core-primitive . negative?) #{$negative? $negative?}]
[print-radix  (core-primitive . print-radix) #{$print-radix $print-radix}]
[remv  (core-primitive . remv) #{$remv $remv}]
[record?  (core-primitive . record?) #{$record? $record?}]
[apropos-list  (core-primitive . apropos-list) #{$apropos-list $apropos-list}]
[string-set!  (core-primitive . string-set!) #{$string-set! $string-set!}]
[tanh  (core-primitive . tanh) #{$tanh $tanh}]
[port-name  (core-primitive . port-name) #{$port-name $port-name}]
[print-record  (core-primitive . print-record) #{$print-record $print-record}]
[procedure?  (core-primitive . procedure?) #{$procedure? $procedure?}]
[fprintf  (core-primitive . fprintf) #{$fprintf $fprintf}]
[remove  (core-primitive . remove) #{$remove $remove}]
[record-type-descriptor?  (core-primitive . record-type-descriptor?) #{$record-type-descriptor? $record-type-descriptor?}]
[fxlogxor  (core-primitive . fxlogxor) #{$fxlogxor $fxlogxor}]
[timer-interrupt-handler  (core-primitive . timer-interrupt-handler) #{$timer-interrupt-handler $timer-interrupt-handler}]
[char-upper-case?  (core-primitive . char-upper-case?) #{$char-upper-case? $char-upper-case?}]
[record-field-accessor  (core-primitive . record-field-accessor) #{$record-field-accessor $record-field-accessor}]
[close-port  (core-primitive . close-port) #{$close-port $close-port}]
[cfl-real-part  (core-primitive . cfl-real-part) #{$cfl-real-part $cfl-real-part}]
[imag-part  (core-primitive . imag-part) #{$imag-part $imag-part}]
[gensym?  (core-primitive . gensym?) #{$gensym? $gensym?}]
[current-input-port  (core-primitive . current-input-port) #{$current-input-port $current-input-port}]
[syntax-match?  (core-primitive . syntax-match?) #{$syntax-match? $syntax-match?}]
[system  (core-primitive . system) #{$system $system}]
[copy-environment  (core-primitive . copy-environment) #{$copy-environment $copy-environment}]
[sinh  (core-primitive . sinh) #{$sinh $sinh}]
[string-ci<=?  (core-primitive . string-ci<=?) #{$string-ci<=? $string-ci<=?}]
[collect  (core-primitive . collect) #{$collect $collect}]
[logand  (core-primitive . logand) #{$logand $logand}]
[display  (core-primitive . display) #{$display $display}]
[port-output-buffer  (core-primitive . port-output-buffer) #{$port-output-buffer $port-output-buffer}]
[symbol?  (core-primitive . symbol?) #{$symbol? $symbol?}]
[denominator  (core-primitive . denominator) #{$denominator $denominator}]
[sub1  (core-primitive . sub1) #{$sub1 $sub1}]
[string-ci>=?  (core-primitive . string-ci>=?) #{$string-ci>=? $string-ci>=?}]
[block-write  (core-primitive . block-write) #{$block-write $block-write}]
[fxnonnegative?  (core-primitive . fxnonnegative?) #{$fxnonnegative? $fxnonnegative?}]
[vector?  (core-primitive . vector?) #{$vector? $vector?}]
[vector-length  (core-primitive . vector-length) #{$vector-length $vector-length}]
[char<=?  (core-primitive . char<=?) #{$char<=? $char<=?}]
[current-output-port  (core-primitive . current-output-port) #{$current-output-port $current-output-port}]
[integer-length  (core-primitive . integer-length) #{$integer-length $integer-length}]
[collect-request-handler  (core-primitive . collect-request-handler) #{$collect-request-handler $collect-request-handler}]
[clear-output-port  (core-primitive . clear-output-port) #{$clear-output-port $clear-output-port}]
[real-time  (core-primitive . real-time) #{$real-time $real-time}]
[with-input-from-file  (core-primitive . with-input-from-file) #{$with-input-from-file $with-input-from-file}]
[sstats-gc-count  (core-primitive . sstats-gc-count) #{$sstats-gc-count $sstats-gc-count}]
[char<?  (core-primitive . char<?) #{$char<? $char<?}]
[char>=?  (core-primitive . char>=?) #{$char>=? $char>=?}]
[char=?  (core-primitive . char=?) #{$char=? $char=?}]
[print-vector-length  (core-primitive . print-vector-length) #{$print-vector-length $print-vector-length}]
[char>?  (core-primitive . char>?) #{$char>? $char>?}]
[trace-output-port  (core-primitive . trace-output-port) #{$trace-output-port $trace-output-port}]
[floor  (core-primitive . floor) #{$floor $floor}]
[call-with-input-file  (core-primitive . call-with-input-file) #{$call-with-input-file $call-with-input-file}]
[list-copy  (core-primitive . list-copy) #{$list-copy $list-copy}]
[constant-expander  (core-primitive . constant-expander) #{$constant-expander $constant-expander}]
[peek-char  (core-primitive . peek-char) #{$peek-char $peek-char}]
[vector-copy  (core-primitive . vector-copy) #{$vector-copy $vector-copy}]
[fxeven?  (core-primitive . fxeven?) #{$fxeven? $fxeven?}]
[fasl-file  (core-primitive . fasl-file) #{$fasl-file $fasl-file}]
[property-list  (core-primitive . property-list) #{$property-list $property-list}]
[optimize-level  (core-primitive . optimize-level) #{$optimize-level $optimize-level}]
[complex?  (core-primitive . complex?) #{$complex? $complex?}]
[sort  (core-primitive . sort) #{$sort $sort}]
[null-environment  (core-primitive . null-environment) #{$null-environment $null-environment}]
[pretty-line-length  (core-primitive . pretty-line-length) #{$pretty-line-length $pretty-line-length}]
[get-output-string  (core-primitive . get-output-string) #{$get-output-string $get-output-string}]
[call/cc  (core-primitive . call/cc) #{$call/cc $call/cc}]
[pretty-one-line-limit  (core-primitive . pretty-one-line-limit) #{$pretty-one-line-limit $pretty-one-line-limit}]
[numerator  (core-primitive . numerator) #{$numerator $numerator}]
[cfl-imag-part  (core-primitive . cfl-imag-part) #{$cfl-imag-part $cfl-imag-part}]
[substring-fill!  (core-primitive . substring-fill!) #{$substring-fill! $substring-fill!}]
[truncate  (core-primitive . truncate) #{$truncate $truncate}]
[sqrt  (core-primitive . sqrt) #{$sqrt $sqrt}]
[set-sstats-gc-real!  (core-primitive . set-sstats-gc-real!) #{$set-sstats-gc-real! $set-sstats-gc-real!}]
[fxmodulo  (core-primitive . fxmodulo) #{$fxmodulo $fxmodulo}]
[sstats-gc-cpu  (core-primitive . sstats-gc-cpu) #{$sstats-gc-cpu $sstats-gc-cpu}]
[char-ci<=?  (core-primitive . char-ci<=?) #{$char-ci<=? $char-ci<=?}]
[make-vector  (core-primitive . make-vector) #{$make-vector $make-vector}]
[interaction-environment  (core-primitive . interaction-environment) #{$interaction-environment $interaction-environment}]
[even?  (core-primitive . even?) #{$even? $even?}]
[make-input-port  (core-primitive . make-input-port) #{$make-input-port $make-input-port}]
[magnitude-squared  (core-primitive . magnitude-squared) #{$magnitude-squared $magnitude-squared}]
[engine-block  (core-primitive . engine-block) #{$engine-block $engine-block}]
[cp0-score-limit  (core-primitive . cp0-score-limit) #{$cp0-score-limit $cp0-score-limit}]
[void  (core-primitive . void) #{$void $void}]
[char-ci>=?  (core-primitive . char-ci>=?) #{$char-ci>=? $char-ci>=?}]
[force  (core-primitive . force) #{$force $force}]
[display-statistics  (core-primitive . display-statistics) #{$display-statistics $display-statistics}]
[collect-trip-bytes  (core-primitive . collect-trip-bytes) #{$collect-trip-bytes $collect-trip-bytes}]
[current-expand  (core-primitive . current-expand) #{$current-expand $current-expand}]
[call/1cc  (core-primitive . call/1cc) #{$call/1cc $call/1cc}]
[char-alphabetic?  (core-primitive . char-alphabetic?) #{$char-alphabetic? $char-alphabetic?}]
[port-output-size  (core-primitive . port-output-size) #{$port-output-size $port-output-size}]
[sstats-real  (core-primitive . sstats-real) #{$sstats-real $sstats-real}]
[input-port?  (core-primitive . input-port?) #{$input-port? $input-port?}]
[string->number  (core-primitive . string->number) #{$string->number $string->number}]
[load-shared-object  (core-primitive . load-shared-object) #{$load-shared-object $load-shared-object}]
[char-name  (core-primitive . char-name) #{$char-name $char-name}]
[set-sstats-gc-bytes!  (core-primitive . set-sstats-gc-bytes!) #{$set-sstats-gc-bytes! $set-sstats-gc-bytes!}]
[lognot  (core-primitive . lognot) #{$lognot $lognot}]
[print-brackets  (core-primitive . print-brackets) #{$print-brackets $print-brackets}]
[warning-handler  (core-primitive . warning-handler) #{$warning-handler $warning-handler}]
[sstats-cpu  (core-primitive . sstats-cpu) #{$sstats-cpu $sstats-cpu}]
[round  (core-primitive . round) #{$round $round}]
[compile-port  (core-primitive . compile-port) #{$compile-port $compile-port}]
[open-input-file  (core-primitive . open-input-file) #{$open-input-file $open-input-file}]
[sort!  (core-primitive . sort!) #{$sort! $sort!}]
[sstats?  (core-primitive . sstats?) #{$sstats? $sstats?}]
[install-expander  (core-primitive . install-expander) #{$install-expander $install-expander}]
[make-record-type  (core-primitive . make-record-type) #{$make-record-type $make-record-type}]
[error  (core-primitive . error) #{$error $error}]
[integer?  (core-primitive . integer?) #{$integer? $integer?}]
[set-top-level-value!  (core-primitive . set-top-level-value!) #{$set-top-level-value! $set-top-level-value!}]
[reverse!  (core-primitive . reverse!) #{$reverse! $reverse!}]
[clear-input-port  (core-primitive . clear-input-port) #{$clear-input-port $clear-input-port}]
[subst!  (core-primitive . subst!) #{$subst! $subst!}]
[exact->inexact  (core-primitive . exact->inexact) #{$exact->inexact $exact->inexact}]

        ))
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

  (primitive-extend! '$syntax-dispatch
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

  (primitive-extend! '$sanitize-binding sanitize-binding)

 ;; other $implementation-core primitives

  (let ()
    (define arg-check
      (lambda (pred? x who)
        (unless (pred? x)
          (error-hook who "invalid argument" x))))

    (primitive-extend! 'identifier?
      (lambda (x)
        (id? x)))

    (primitive-extend! 'datum->syntax
      (lambda (id datum)
        (arg-check id? id 'datum->syntax)
        (make-syntax-object datum
          (syntax-object-mark* id)
          (syntax-object-subst* id))))

    (primitive-extend! 'syntax->datum
      (lambda (x)
        (strip x '())))

    (primitive-extend! 'generate-temporaries
      (lambda (ls)
        (arg-check list? ls 'generate-temporaries)
        (map (lambda (x)
               (make-syntax-object (gensym-hook "t") top-mark* top-subst*))
             ls)))

    (primitive-extend! 'free-identifier=?
      (lambda (x y)
         (arg-check id? x 'free-identifier=?)
         (arg-check id? y 'free-identifier=?)
         (free-id=? x y)))

    (primitive-extend! 'bound-identifier=?
      (lambda (x y)
         (arg-check id? x 'bound-identifier=?)
         (arg-check id? y 'bound-identifier=?)
         (bound-id=? x y)))

   ;; syntax-error is used to generate syntax error messages
    (primitive-extend! 'syntax-error
      (lambda (object . messages)
        (for-each (lambda (x) (arg-check string? x 'syntax-error)) messages)
        (let ([message (if (null? messages)
                           "invalid syntax"
                           (apply string-append messages))])
          (error-hook #f message (strip object '())))))

    (primitive-extend! 'make-variable-transformer
      (lambda (p)
        (arg-check procedure? p 'make-variable-transformer)
        (make-binding 'macro! p)))
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
