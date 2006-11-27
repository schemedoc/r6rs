;;;===============================================================================
;;;
;;; R6RS Macros and R6RS libraries:
;;;
;;;   Copyright (c) 2006 Andre van Tonder
;;;
;;;   Copyright statement at http://srfi.schemers.org/srfi-process.html
;;;
;;;===============================================================================

;;; September 13, 2006

;;;==========================================================================       
;;;
;;; PORTABILITY:
;;; ------------
;;;
;;; Tested on MzScheme and Petite Chez 
;;;    (for the latter, simply change define-struct -> define-record).
;;;
;;; ---------------------------------------------------
;;; TO RUN: SIMPLY EXECUTE MACROS-TEST.SCM IN THE REPL.
;;; ---------------------------------------------------
;;;
;;; Uses following non-r5rs constructs, which should be simple
;;; to adapt to your r5rs implementation of choice:
;;;
;;;   * define-struct
;;;   * parameterize
;;;   * let-values
;;;
;;;==========================================================================   

;;;==========================================================================  
;;; 
;;; COMPATIBILITY WITH R6RS:
;;; ------------------------
;;;
;;; LIBRARIES:
;;;    
;;;    * TODO        : Currently <library reference> must be = <library name>.  
;;;                    Version matching is not yet implemented.   
;;;    * TODO        : Exceptions are not yet raised if exported variables are set!
;;;    * PERMITTED   : A visit at one phase is a visit at all phases, and 
;;;                    an invoke at one phase is an invoke at all phases
;;;    * PERMITTED   : Expansion of library form is started by removing all 
;;;                    library bindings above phase 0
;;;    * UNSPECIFIED : A syntax violation is raised if a binding is used outside 
;;;                    its declared levels.  This probably shouldn't be optional
;;;                    as it currently stands in the draft.  
;;;    * UNSPECIFIED : The phases available for an identifier are lexically
;;;                    determined from the identifier's source occurrence
;;;                    (see examples in maccros-test.scm)
;;;    * UNSPECIFIED : Free-identifier=? is sensitive to levels, so it will give #t
;;;                    if and only if its arguments are interchangeable as references
;;;                    (not currently clear from specification).
;;;    * EXTENSION   : Negative import levels are allowed.  For semantics, see below.
;;;                    For examples, see identifier-syntax in macros-derived.scm
;;;                    and various in macros-test.scm.
;;;
;;; SYNTAX-CASE:
;;;
;;; Currently, the r6rs syntax-case srfi is implemented, so any differences
;;; that may have been made between the srfi and the draft are not 
;;; incorporated.  
;;;
;;;    * UNOBSERVABLE : We use a renaming algorithm instead of the mark/antimark
;;;                     algorithm described in the srfi.  The difference should not 
;;;                     be observable for correct macros.
;;;    * UNSPECIFIED  : A wrapped syntax object is the same as an unwrapped syntax object,
;;;                     and can be treated as unwrapped without an exception being raised.
;;;    * EXTENSION    : Quasisyntax is implemented with unquote/unquote-splicing. 
;;;    * EXTENSION    : Syntax-error
;;;
;;;==========================================================================  

;;;==========================================================================       
;;;
;;; SEMANTICS OF NEGATIVE LEVELS:
;;; -----------------------------
;;;
;;; The implementation allows libraries to be imported at 
;;; negative meta-level (an extension to the draft).  
;;; 
;;; However, when there are no negative level imports in a program, 
;;; THE SEMANTICS COINCIDE WITH THAT DESCRIBED IN THE R6RS DRAFT.
;;;
;;; The full semantics implemented here, which is equivalent to R6RS when there
;;; are no negative levels, is as follows:
;;;
;;; To visit a library at level n: [ONLY FIRST BULLET IS NEW]
;;;
;;;    * If n < 0  : Do nothing
;;;    * If n >= 0 : * Visit at level (n + k) any library that is imported by
;;;                    this library for (meta k) and that has not yet been visited
;;;                    at level (n + k).
;;;                  * For each k >= 1, invoke at level (n + k) any library that is 
;;;                    imported by this library for .... (meta k), and that has not 
;;;                    yet been invoked at level (n + k).
;;;                  * Evaluate all syntax definitions in the library.
;;;
;;; To invoke a library at level n: [ONLY FIRST AND LAST BULLETS ARE NEW]
;;;
;;;    * If n < 0  : Do nothing.
;;;    * If n >= 0 : * Invoke at level (n + k) any library that is imported by this 
;;;                    library for (meta k), and that has not yet been invoked
;;;                    at level (n + k).
;;;                  * If n = 0: Evaluate all variable definitions and expressions in
;;;                              the library.
;;;                  * If n > 0: Do nothing
;;;
;;; Runtime execution of a library happens in a fresh environment but is
;;; otherwise the same as invoking it at level 0.
;;;
;;; Fresh environments are created at the start of each
;;; of the two times (expansion and execution), and not for each of
;;; the possibly many meta-levels.  During expansion, every binding
;;; is shared only between whichever levels it is imported into.
;;; A syntax violation is raised if a binding is used outside 
;;; its declared levels.  
;;;
;;;==========================================================================


;;;==========================================================================
;;;
;;; Hooks:
;;;
;;;==========================================================================

;; This generate-name will work on most Schemes,     
;; BUT ONLY for whole-program expansion or continuous REPL sessions.
;; 
;; Before any incremental compilation is attempted, it is essential 
;; that this be redone to generate a symbol that
;;
;; - is read-write invariant,
;; - has a globally unique external representation.
;; 
;; I believe the Chez gensym does this and can therefore be used  
;; to attain reliable incremental and separate compilation.  
;; On other systems, given access to the current seconds, a good approximation 
;; to a reliable /single/ machine unique identifier may be obtained by 
;; defining the seed to be
;;
;;   (* (current-seconds) integer-larger-than-machine-cycles-per-second)).
;;
;; To make it globally unique, a machine id should then be incorporated.

(define (seed) 0)

(define generate-name                            
  (let ((count (seed)))
    (lambda (symbol)
      (set! count (+ 1 count))
      (string->symbol
       (string-append (symbol->string symbol)
                      "|"
                      (number->string count))))))

;; Make-free-name is used to generate user program toplevel 
;; names.  
;;
;; The results of make-free-name must be disjoint from:
;;
;;  - the results of generate-name
;;  - all primitive and system bindings, including those
;;    defined in this expander.
;;  - all symbols that may appear in user programs.
;; 
;; This is essential to ensure that there is no interference between 
;; user and system namespaces, and to ensure the integrity of expanded
;; code generated by this expander.  
;;
;; This default implementation is pretty much the best we can do in r5rs
;; but not quite robust for the following reason.  While it is unlikely
;; that the character "|" will appear in hand-typed symbols in user programs,
;; it should be noted that if they do (which becomes possible in R6RS), or
;; if a program contains machine-generated symbols such as uuids,
;; the expanded code may be defective.  

(define (make-free-name symbol level)
  (string->symbol
   (string-append "top|"
                  (symbol->string symbol)
                  "|"
                  (number->string level))))

;; This transforms to the equivalent of letrec*, which will be 
;; correct but host compiler may already have a native letrec* 
;; with special optimizations and error checks, in which case 
;; you should just construct that. 
;; Each def must be of the form (symbol . expression)

(define (build-primitive-lambda formals defs exps)
  `(lambda ,formals
     ((lambda ,(map car defs)
        ,@(map (lambda (def) `(set! ,(car def) ,(cdr def)))
               defs)
        ,@exps)
      ,@(map (lambda (def) `(unspecified))
             defs))))

;;;==========================================================================
;;;
;;; End of hooks:
;;;
;;;==========================================================================


;;;==========================================================================
;;;
;;; Identifiers:
;;;
;;;==========================================================================

;; Name:                    The symbolic name of the identifier in the source.
;; Colour:                  See below for the colour data type.
;; Transformer-environment: The transformer environment is defined as the lexical
;;                          bindings valid during expansion (not execution) of the
;;                          |syntax| expression introducing the identifier.
;;                          Maps symbolic names of like-coloured identifiers
;;                          to their binding names (also symbols) in this  
;;                          environment.
;;                          If it were not for datum->syntax, only the
;;                          binding of the containing identifier would be needed.  
;;                          However, datum->syntax requires that we save the bindings 
;;                          of all like-coloured identifiers. 
;;                          The transformer environment may have been reflected, i.e.,      
;;                          converted to a key that provides a concise representation 
;;                          for inclusion in object code and allows destructive 
;;                          retrospective updating of its bindings, needed for correct 
;;                          expansion of bodies.
;;                          See the procedures binding-name, datum->syntax and
;;                          syntax-reflect for further clarification.
;; Level-correction:        Integer that keeps track of shifts in meta-levels that may  
;;                          occur when importing libraries.

(define-struct identifier (name
                           colours
                           transformer-env
                           level-correction))    

(define (bound-identifier=? x y)
  (check x identifier? 'bound-identifier=?)
  (check y identifier? 'bound-identifier=?)
  (and (eq? (identifier-name x)
            (identifier-name y))
       (colours=? (identifier-colours x)
                  (identifier-colours y))))

(define (free-identifier=? x y)
  (check x identifier? 'free-identifier=?)
  (check y identifier? 'free-identifier=?)
  (eq? (binding-name x)
       (binding-name y))) 

;; The meta-level for the current expansion step:

(define *level* (make-parameter 0))

(define (correct-level id)
  (- (*level*)
     (identifier-level-correction id)))

;; A lexical or toplevel binding is of the form
;;
;;    (<binding symbol> . <levels>)
;;
;; where <binding symbol> is the denotation and
;;
;;    <levels> ::= (<uinteger> ...)
;;
;; lists the meta-levels at which the binding
;; is valid.

(define make-binding   cons)
(define binding-symbol car)
(define binding-levels cdr)
         
;; Returns binding name of id if bound at the appropriate level.
;; If unbound or binding invalid at appropriate level (displaced),
;; returns a free name that incorporates the level. 
;; If checked-use? is #t, throws syntax error if displaced.  
  
(define (resolve-binding-name id checked-use?)
  (let ((probe (lookup-binding id))
        (level (correct-level id)))
    (if probe
        (let ((binding (cdr probe)))
          (if (memv level (binding-levels binding))
              (binding-symbol binding)
              (if checked-use?
                  (syntax-error "Attempt to use binding of" id "at invalid level" level
                                ": Binding is only valid at levels" (binding-levels binding))
                  (free-name id level))))
        (begin
          (if checked-use?
              (syntax-warning "Reference to unbound identifier" id))
          (free-name id level)))))  

(define (lookup-binding id)
  (or (lookup-usage-env id)           
      (lookup-transformer-env id)))

(define (free-name id level)
  (make-free-name (identifier-name id) level))

;; For uses:

(define (checked-binding-name id)
  (resolve-binding-name id #t))

;; For non-uses, such as free-identifier? predicates.

(define (binding-name id)
  (resolve-binding-name id #f))

;; Generates a local binding entry at the current meta-level,
;; that can be added to the usage environment.
;; Returns
;;   (<identifier> . <binding>)

(define (add-local-binding id)    
  (cons id
        (make-binding (generate-name (identifier-name id))   
                      (list (correct-level id)))))

;; Toplevel binding forms use as binding name the free name 
;; if the identifier has no colour (was present in the source)
;; so that source-level forward references will work.
;; Otherwise a fresh identifier is generated.  
;; This causes binding names in macro-generated toplevel
;; defines and define-syntaxes to be fresh each time.
;; Returns
;;   (<identifier> . <binding>)

(define (add-toplevel-binding id)
  (cons id
        (let ((level (correct-level id)))
          (make-binding (if (colours=? (identifier-colours id) no-colours) 
                            (free-name id level)                 
                            (generate-name (identifier-name id)))
                        (list level)))))

;;;=========================================================================
;;;
;;; Syntax-reflect and syntax-reify:
;;;
;;; This is the basic building block of the implicit renaming mechanism for
;;; maintaining hygiene.  Syntax-reflect generates the expanded code for 
;;; (syntax id), including the expand-time (transformer) environment in the
;;; external representation.  It expands to syntax-reify, which performs 
;;; the implicit renaming via add-colour when this expanded code is 
;;; eventually run. 
;;; The level computations perform the adjustment of levels in the presence
;;; of libraries, where meta-levels may be shifted.    
;;;
;;;=========================================================================

(define (syntax-reflect id)                     
  `(syntax-reify ',(identifier-name id)                            
                 ',(identifier-colours id)
                 
                 ;; We reflect the result of capture-transformer-environment
                 ;; even if it is already a reflected environment
                 ;; to ensure that no two reflected identifiers will share
                 ;; an entry in the table of reflected environments.
                 ;; This is essential for consistency given that reflected
                 ;; transformer environments of individual identifiers may
                 ;; be destructively updated during expansion of bodies to make
                 ;; forward references from transformer right hand sides to
                 ;; later definitions work correctly.  See scan-body.
                 
                 ',(reflect-env (capture-transformer-env id)
                                (identifier-colours id))
                 
                 ;; the transformer-expand-time corrected level
                 
                 ,(- (*level*) (identifier-level-correction id) 1))) 

(define (syntax-reify name colours transformer-env expand-time-corrected-level)
  (make-identifier name 
                   (add-colour (*current-colour*) colours)
                   (reify-env transformer-env)
                   ;; the transformer-runtime level-correction
                   (- (*level*) expand-time-corrected-level)))

;;;=====================================================================
;;;
;;; Capture and sexp <-> syntax conversions:
;;;
;;;=====================================================================

(define (datum->syntax tid datum)
  (check tid identifier? 'datum->syntax)
  (sexp-map (lambda (leaf)
              (cond ((const? leaf)  leaf)
                    ((symbol? leaf) (make-identifier leaf
                                                     (identifier-colours tid)
                                                     (identifier-transformer-env tid)
                                                     (identifier-level-correction tid)))
                    (else (syntax-error "Datum->syntax: Invalid datum:" leaf))))
            datum))

(define (syntax->datum exp)
  (sexp-map (lambda (leaf)
              (cond ((const? leaf)      leaf)
                    ((identifier? leaf) (identifier-name leaf))
                    (else 
                     (syntax-error "Syntax->datum: Invalid syntax object:" leaf))))
            exp))

;; Fresh identifiers:

(define (generate-temporaries ls)
  (check ls list? 'generate-temporaries)
  (map (lambda (ignore)
         (rename (generate-name 'gen)))      
       ls))

;; For use internally as in the explicit renaming system.

(define (rename symbol)    
  (make-identifier symbol
                   (list (*current-colour*))
                   (list (cons symbol 
                               (make-binding symbol '(0))))
                   (*level*)))

;;;=======================================================================
;;;
;;; Colours:
;;;
;;;=======================================================================

;; <colour> ::= <globally unique symbol>  

(define (generate-colour)
  (generate-name 'col))

(define no-colours '())

(define (add-colour c cs)        
  (cons c cs))

(define (colours=? c1s c2s)
  (equal? c1s c2s))

(define *current-colour* (make-parameter no-colours))                        

;;;=======================================================================
;;;
;;; Environments:
;;;
;;;=======================================================================

;; An environment is either a reflected 
;; environment (a symbol index into a table of environments) or an
;; association list, possibly improper, whose tail may be a reflected
;; environment.
;;
;; <environment> ::= ()
;;                |  <reflected-env-key> 
;;                |  ((<symbolic-name> . <binding>) . <environment>)
;;
;; <reflected-env-key> ::= <globally unique symbolic key>

;; The table of reflected environments is of the form 
;;
;; ((<reflected-env-key> <environment> <colour>) ...)  

;; Note: A lot more sharing is possible if object code sizes
;;       becomes a problem, but the current implementation seems
;;       good enough so far.

(define *reflected-envs* (make-parameter '()))

;; Returns a single-symbol representation of an environment 
;; that can be included in object code.

(define (reflect-env env colour)  
  (let ((key (generate-name 'env)))                 
    (*reflected-envs*
     (alist-cons key
                 (list env 
                       colour)
                 (*reflected-envs*)))
    key)) 

;; The inverse of the above.

(define (reify-env reflected-env)
  (cond ((alist-ref reflected-env (*reflected-envs*))             
         => (lambda (probe)
              (if (symbol? (car probe))
                  (reify-env (car probe))
                  (car probe))))                        
        (else (error "Internal error in reify-env: Environment"                    
                     reflected-env
                     "not in table"
                     (map car (*reflected-envs*))))))

;; Returns (<name> . <binding>) 

(define (env-lookup name env)
  (cond ((null? env) #f)
        ((pair? env) 
         (if (eq? name (caar env))
             (car env)
             (env-lookup name (cdr env))))
        (else 
         (env-lookup name (reify-env env)))))

;; Adds new entries to the reflected environment table.

(define (extend-reflected-envs! entries)
  (*reflected-envs* 
   (append entries (*reflected-envs*))))

;; Updates reflected environments of the same 
;; colour as id by adding the current usage-env binding of 
;; id, which must exist, to them.  
;; This is done for all environments created more recently than 
;; stop-mark, which points into the table of reflected environments 
;; of the above format
;;
;; ((<reflected-env> <transformer-env> <colours>) ...)
;;
;; This is used (see scan-body) to ensure that forward references to
;; this identifier from preceding transformers in a body will
;; work correctly, allowing mutual recursion among
;; transformers as in the even/odd example.  

(define (update-reflected-envs! id stop-mark)
  (let loop ((start (*reflected-envs*)))
    (if (not (eq? start stop-mark))
        (let ((entry (cdar start)))   
          (if (colours=? (identifier-colours id)           
                         (cadr entry))
              (set-car! entry
                        (alist-cons (identifier-name id)
                                    (cdr (lookup-usage-env id))
                                    (car entry))))
          (loop (cdr start))))))  

;; Returns a mark delimiting the environments currently present
;; in the reflected environment table.  

(define (current-reflected-envs-mark)
  (*reflected-envs*))

;; Returns only relevant reflected environments for
;; inclusion in object library.  
;; This avoids exponentially growing object code when
;; imports are chained.
;;
;; Optimization - If there is only one transformer environment, that
;;                represents the initial imports, it means that no
;;                additional environments have been reflected.  In
;;                other words, there are no syntax expressions.
;;                Since the initial imports is usually large, it
;;                saves a lot of space if we leave it out in this
;;                case.  

(define (compress-reflected-envs stop-mark)
  (let ((result
         (let loop ((tenvs (*reflected-envs*))
                    (entries '()))
           (if (eq? tenvs stop-mark)
               entries
               (loop (cdr tenvs)
                     (cons (car tenvs)
                           entries))))))
    (if (= 1 (length result))
        '()
        result)))

;;;=========================================================================
;;;
;;; Transformer environments:
;;;
;;;=========================================================================

;; A transformer environment is an environment of
;; attached to an identifier. 

;; Looks up the binding, if any, of an identifier in its
;; attached transformer environment.
;; Returns
;;    (<symbolic name> . <binding>) | #f


(define (lookup-transformer-env id)    
  (env-lookup (identifier-name id)
              (identifier-transformer-env id)))

;; Captures the transformer environment of the identifier id by copying
;; like-colored entries from the usage-env valid during expansion
;; of (syntax id).  Only like-colored entries are needed to make 
;; datum->syntax possible.

;; Optimization:  Although not strictly necessary, a big performance gain is
;;                achieved by looking up the binding at transformer-expand-time
;;                and putting it in front, as we do here.  This makes
;;                references super-fast.  

(define (capture-transformer-env id)                  
  (let* ((rest (append (usage-env->env (identifier-colours id))
                       (identifier-transformer-env id)))
         (first (env-lookup (identifier-name id) rest)))  ; +++
    (if first                                             ; +++
        (cons first rest)                                 ; +++
        rest)))

;;;=========================================================================
;;;
;;; Usage environment: 
;;;
;;;=========================================================================

;; The usage environment contains the bindings visible
;; during the current expansion step.  It gets extended
;; during expansion of binding forms and is used to
;; map <identifier> -> <binding>, where the mapping
;; is keyed via bound-identifier=?, i.e., two identifiers
;; are equivalent for the purpose of the mapping if they
;; have the same symbolic name and colours.  
;;
;; It is implemented internally as an alist of the form
;;
;;   ((<colours> . <env>) ...)
;;
;; where each <env> is an alist of the form
;;
;;   ((<symbolic name> . <binding>) ...)

(define (usage-env->env colours)
  (cond ((assoc= colours (*usage-env*) colours=?) => cdr)
        (else '())))

;; Lookup-usage-env :: <identifier> -> (<name> . <binding>) | #f

(define (lookup-usage-env id)
  (cond ((usage-env->env (identifier-colours id))
         => (lambda (env)
              (assq (identifier-name id) env)))
        (else #f)))

;; Here <entry> ::= (<id> . <binding>)
;; Returns an extended usage environment built
;; from the current usage-env.
;; Not imperative.

(define (extend-usage-env entry)
  (extend-uenv entry (*usage-env*)))

(define (extend-uenv entry uenv)
  (let* ((name    (identifier-name    (car entry)))
         (colours (identifier-colours (car entry)))
         (binding (cons name (cdr entry))))
    (let loop ((uenv uenv))
      (cond ((null? uenv)
             (list (cons colours
                         (list binding))))
            ((colours=? colours (caar uenv))
             (cons (cons colours
                         (cons binding
                               (cdar uenv)))
                   (cdr uenv)))
            (else
             (cons (car uenv)
                   (loop (cdr uenv))))))))

(define (extend-usage-env* entries)
  (let loop ((entries entries)
             (uenv    (*usage-env*)))
    (if (null? entries)
        uenv
        (loop (cdr entries)
              (extend-uenv (car entries) uenv)))))

(define *usage-env* (make-parameter '()))

;;;=========================================================================
;;;
;;; Macros:
;;;
;;;=========================================================================

;; Expanders are system macros that fully expand
;; their arguments to core Scheme, while
;; transformers and variable transformers are 
;; user macros.  

;; <macro> ::= <expander> | <transformer> | <variable transformer>

(define-struct expander             (proc))
(define-struct transformer          (proc))
(define-struct variable-transformer (proc))

(define (make-macro proc-or-macro)
  (if (procedure? proc-or-macro)
      (make-transformer proc-or-macro)
      proc-or-macro))

(define *macros* (make-parameter '()))

(define (register-macro! name macro)
  (*macros* (extend-macros (cons name macro))))

(define (extend-macros entry)
  (cons entry (*macros*)))

(define (extend-macros* entries)
  (append entries (*macros*)))

;; Returns <macro> | #f

(define (syntax-use t)            
  (let ((key (if (pair? t)
                 (car t)
                 t)))
    (and (identifier? key)
         (alist-ref (binding-name key) (*macros*)))))

;;;=========================================================================
;;;
;;; Expander dispatch:
;;;
;;;=========================================================================

;; Transformers are user-defined macros.
;; Expanders are system macros that fully expand
;; their arguments to core Scheme.

(define (expand t)
  (stacktrace t
              (lambda ()
                (cond ((syntax-use t) => (lambda (macro) 
                                           (parameterize ((*current-colour* (generate-colour)))
                                             (cond
                                               ((expander? macro)             
                                                ((expander-proc macro) t))
                                               ((transformer? macro)          
                                                (expand ((transformer-proc macro) t)))
                                               ((variable-transformer? macro) 
                                                (expand ((variable-transformer-proc macro) t)))
                                               (else 
                                                (syntax-error "Internal error: Invalid transformer" macro))))))
                      ((identifier? t)   (checked-binding-name t))
                      ((list? t)         (map expand t))
                      ((const? t)        t)
                      (else              (syntax-error "Invalid syntax object:" t))))))

;; Only expands while t is a user macro invocation.
;; Used by expand-lambda to detect internal definitions.

(define (head-expand t)
  (stacktrace t
              (lambda ()
                (cond
                  ((syntax-use t) => (lambda (macro)
                                       (parameterize ((*current-colour* (generate-colour)))
                                         (cond
                                           ((expander? macro) t)  
                                           ((transformer? macro)          
                                            (head-expand ((transformer-proc macro) t)))
                                           ((variable-transformer? macro) 
                                            (head-expand ((variable-transformer-proc macro) t)))
                                           (else 
                                            (syntax-error "Internal error: Invalid transformer" macro))))))
                  (else t)))))

(define (const? t)
  (or (null?    t)
      (boolean? t)
      (number?  t)
      (string?  t)
      (char?    t)))

;;;=========================================================================
;;;
;;; Quote, if, set!, begin:
;;;
;;;=========================================================================

(define (expand-quote exp)
  (or (and (list? exp)
           (= (length exp) 2))
      (syntax-error))
  (syntax->datum exp))

(define (expand-if exp)
  (or (and (list? exp)
           (<= 3 (length exp) 4))
      (syntax-error))
  `(if ,(expand (cadr exp))
       ,(expand (caddr exp))
       ,@(if (= (length exp) 4)
             (list (expand (cadddr exp)))
             `())))

(define (expand-set! exp)
  (or (and (list? exp)
           (= (length exp) 3)
           (identifier? (cadr exp)))
      (syntax-error))
  (cond ((syntax-use (cadr exp)) => (lambda (macro)
                                      (if (variable-transformer? macro)
                                          (expand ((variable-transformer-proc macro) exp))
                                          (syntax-error "Syntax being set! is not a variable transformer."))))
        (else `(set! ,(checked-binding-name (cadr exp))    
                     ,(expand (caddr exp))))))

(define (expand-begin exp)
  (or (list? exp)
      (syntax-error))
  ;; map-in-order is correct for toplevel begin,
  ;; where syntax definitions affect subsequent
  ;; expansion.
  `(begin ,@(map-in-order expand (cdr exp))))

;;;=========================================================================
;;;
;;; Lambda:
;;;
;;;=========================================================================

;; The expansion algorithm is as in the R6Rs SRFI.
;; Here we expand internal definitions to a specific normalized
;; internal definitions in the host Scheme, but we should
;; probably expand to letrec* for R6RS.

(define (expand-lambda exp)
  (if (and (pair?    exp)
           (pair?    (cdr exp))
           (formals? (cadr exp))
           (list?    (cddr exp)))
      (let ((formals (cadr exp))
            (body    (cddr exp)))
        (scan-body formals 
                   '()
                   body
                   (lambda (formals definitions syntax-definitions declarations ignore-indirects exps)
                     (if (null? exps)
                         (syntax-error "Lambda: Empty body."))
                     (build-primitive-lambda formals definitions exps))))
      (syntax-error "Invalid lambda syntax:" exp)))

(define (formals? s)
  (or (null? s)
      (identifier? s)
      (and (pair? s)
           (identifier? (car s))
           (formals? (cdr s))
           (not (dotted-member? (car s)
                                (cdr s)
                                bound-identifier=?)))))

;;;=========================================================================
;;;
;;; Bodies:  This is used for lambda and library bodies.
;;;          May be used for any additional binding forms in host Scheme
;;;          that do not expand to lambda or library forms.  
;;;
;;;=========================================================================

;; R6RS splicing of internal let-syntax and letrec-syntax (and only
;; this) requires that we control the bindings visible in each
;; expression of the body separately.  This is done by attaching
;; any extra bindings that should be visible in the expression
;; (over and above the usual bindings) to the expression.
;; We call the resulting data structure a rib (stealing some
;; vocabulary from psyntax, though the present structure
;; is a bit different from what psyntax has).

(define (make-rib usage-diff macros-diff exp)
  (list usage-diff macros-diff exp))

(define rib-usage-diff        car)
(define rib-macros-diff cadr)
(define rib-exp               caddr)

(define (add-ribs body)
  (map (lambda (e)
         (make-rib '() '() e))
       body))

;; Makes the additional bindings visible and then applies the operation
;; to the expression in the rib.  Here the global fluid parameters become
;; a bit inelegant, and I may convert them to ordinary arguments in
;; future.  

(define (do-rib operation rb . args)   
  (parameterize ((*usage-env* 
                  (extend-usage-env* (rib-usage-diff rb)))
                 (*macros* 
                  (extend-macros* (rib-macros-diff rb)))) 
    (apply operation (rib-exp rb) args)))

;; Copy bindings from rb to expression exp.  

(define (copy-rib rb exp)
  (make-rib (rib-usage-diff rb)
            (rib-macros-diff rb)
            exp))

;; Here we expand the first non-definition atomically in case expansion
;; relies on side effects.  This is important in a procedural macro
;; system.  So that the first non-definition will be expanded correctly,
;; definition-bound identifiers are bound as soon as they are
;; encountered.
;; The continuation k is evaluated in the body environment.  This is
;; used example by expand-library to obtain the correct bindings of
;; exported identifiers.  

(define (scan-body formals already-bound exps k)
  
  (define (expand-defs defs)
    (map (lambda (def)
           (cons (car def)
                 (do-rib expand (cdr def))))
         defs))
  
  (define (expand-indirects indirs)
    (map (lambda (indir-rib)
           (do-rib (lambda (indir)
                     (map checked-binding-name indir))
                   indir-rib))
         indirs))
  
  (parameterize ((*usage-env* 
                  (extend-usage-env* (map add-local-binding (flatten formals)))))
    
    (let ((formals (dotted-map binding-name formals))) 
      
      ;; Used below for retroactively updating reflected transformer 
      ;; environments created for expanded syntax expressions in this
      ;; body, so forward references in syntax forms will work.
      (let ((initial-envs-mark (current-reflected-envs-mark)))
        
        (let loop ((rbs           (add-ribs exps))
                   (defs          '())
                   (syntax-defs   '())
                   (decls         '())
                   (indirs        '())
                   (already-bound already-bound))
          (if (null? rbs)
              (k formals 
                 (expand-defs (reverse defs))
                 (reverse syntax-defs)
                 (reverse decls)
                 (expand-indirects indirs)
                 '())
              (let* ((rb  (copy-rib (car rbs) (do-rib head-expand (car rbs))))
                     (rbs (cdr rbs)))
                (cond ((do-rib declare? rb)
                       (if (and (null? defs)
                                (null? syntax-defs))
                           (loop rbs
                                 defs
                                 syntax-defs
                                 (cons (do-rib parse-declaration rb)
                                       decls)
                                 indirs
                                 already-bound)
                           (syntax-error "Declarations may not follow definitions" exps)))
                      ((do-rib indirect-export? rb)
                       (loop rbs
                             defs 
                             syntax-defs
                             decls
                             (append (map (lambda (indir)
                                            (copy-rib rb indir))
                                          (do-rib parse-indirect rb)) 
                                     indirs)
                             already-bound))
                      ((do-rib define? rb)     
                       (let-values (((id rhs) (do-rib parse-definition rb)))
                         (if (member=? id already-bound bound-identifier=?)
                             (syntax-error "Duplicate binding of :" id))
                         (parameterize ((*usage-env*
                                         (extend-usage-env (add-local-binding id))))
                           ;; Retroactively update reflected transformer environments
                           ;; created for already expanded syntax expressions in
                           ;; preceding syntax definitions in the same body,
                           ;; for identifiers whose colour is the same as id's.
                           ;; The body was started at 
                           ;; initial-envs-mark.
                           ;; This is necessary so that forward references to
                           ;; this definition in preceding macros will
                           ;; work correctly, allowing mutual recursion among
                           ;; definitions and macros.
                           (update-reflected-envs! id  
                                                   initial-envs-mark)
                           (loop rbs                            
                                 (cons (cons (binding-name id) (copy-rib rb rhs)) 
                                       defs)
                                 syntax-defs
                                 decls
                                 indirs
                                 (cons id already-bound)))))
                      ((do-rib define-syntax? rb)   
                       (let-values (((id rhs) (do-rib parse-definition rb)))
                         (if (member=? id already-bound bound-identifier=?)
                             (syntax-error "Duplicate binding of :" id))
                         (parameterize ((*usage-env*
                                         (extend-usage-env (add-local-binding id))))
                           ;; Retroactively update transformer environments
                           ;; as above. 
                           (update-reflected-envs! id  
                                                   initial-envs-mark)
                           (let ((rhs (parameterize ((*level* (+ 1 (*level*))))
                                        (do-rib expand (copy-rib rb rhs)))))
                             (parameterize ((*macros*
                                             (extend-macros
                                              (cons (binding-name id)
                                                    (make-macro (eval rhs))))))
                               (loop rbs 
                                     defs
                                     (cons (cons (binding-name id) rhs) 
                                           syntax-defs)
                                     decls
                                     indirs
                                     (cons id already-bound)))))))      
                      ((do-rib begin? rb)
                       (loop (append (map (lambda (exp)
                                            (copy-rib rb exp))
                                          (cdr (rib-exp rb)))
                                     rbs)
                             defs
                             syntax-defs
                             decls
                             indirs
                             already-bound))
                      ((do-rib local-syntax? rb)
                       => (lambda (type)
                            (let-values (((formals exps body) (do-rib scan-local-syntax rb)))
                              (let* ((bindings   (map add-local-binding formals))
                                     (usage-diff (append bindings (rib-usage-diff rb)))
                                     (rhs-env    (extend-usage-env* usage-diff)) 
                                     (macros
                                      (map (lambda (exp)
                                             (eval (do-rib (lambda (rb)
                                                             (parameterize ((*level* (+ 1 (*level*))))
                                                               (case type
                                                                 ((let-syntax) (expand rb))
                                                                 ((letrec-syntax)
                                                                  (parameterize ((*usage-env* rhs-env))
                                                                    (expand rb))))))
                                                           (copy-rib rb exp))))
                                           exps))
                                     (macros-diff
                                      (append (map (lambda (binding macro)
                                                     (cons (binding-symbol (cdr binding))
                                                           (make-macro macro)))
                                                   bindings
                                                   macros)
                                              (rib-macros-diff rb))))
                                (loop (cons (make-rib usage-diff
                                                      macros-diff
                                                      `(,(rename 'begin) . ,body))
                                            rbs)
                                      defs
                                      syntax-defs
                                      decls
                                      indirs
                                      already-bound)))))
                      (else
                       (k formals 
                          (expand-defs (reverse defs))
                          (reverse syntax-defs)
                          (reverse decls)
                          (expand-indirects indirs)
                          (cons (do-rib expand rb)
                                (map (lambda (rb)
                                       (do-rib expand rb))    
                                     rbs))))))))))))

(define (make-operator-predicate name)
  (let ((p? (make-free-predicate name)))
    (lambda (t)
      (and (pair? t)
           (p? (car t))))))

;; Internal version of free-identifier=? 
;; that avoids having to create a special
;; identifier for literal.

(define (make-free-predicate name)
  (lambda (t)
    (and (identifier? t)
         (eq? name (binding-name t)))))

(define declare?         (make-operator-predicate 'declare))
(define define?          (make-operator-predicate 'define))
(define define-syntax?   (make-operator-predicate 'define-syntax))
(define indirect-export? (make-operator-predicate 'indirect-export))
(define begin?           (make-operator-predicate 'begin))

(define local-syntax?
  (let ((let-syntax?    (make-operator-predicate 'let-syntax))
        (letrec-syntax? (make-operator-predicate 'letrec-syntax)))
    (lambda (t)
      (cond ((let-syntax? t)    'let-syntax)
            ((letrec-syntax? t) 'letrec-syntax)
            (else #f)))))

(define (parse-definition t)        
  (or (and (pair? t)
           (pair? (cdr t)))
      (syntax-error t))
  (let ((k    (car t))
        (head (cadr t))
        (body (cddr t)))
    (cond ((and (identifier? head)
                (list? body)
                (<= (length body) 1))
           (values head (if (null? body)
                            `(,(rename 'unspecified))
                            (car body))))
          ((and (pair? head)
                (identifier? (car head))
                (formals? (cdr head)))
           (values (car head)
                   `(,(rename 'lambda) ,(cdr head) . ,body)))
          (else (syntax-error t)))))

(define (parse-declaration t) 
  (define unsafe? (make-free-predicate 'unsafe))
  (define safe?   (make-free-predicate 'safe))
  (define fast?   (make-free-predicate 'fast))
  (define small?  (make-free-predicate 'small))
  (define debug?  (make-free-predicate 'debug))
  (define (quality? t)
    (or (safe? t)
        (fast? t)
        (small? t)
        (debug? t)))
  (define (priority? t)
    (and (integer? t)
         (<= 0 t 3)))
  (if (and (list? t)
           (= (length t) 2)
           (or (unsafe? (cadr t))
               (quality? (cadr t))
               (and (list? (cadr t))
                    (= (length t) 2)
                    (and (quality? (car (cadr t)))
                         (priority? (cadr (cadr t)))))))
      ;; Cannot just do syntax->datum.
      (if (list? (cadr t))
          (cons (checked-binding-name (car (cadr t)))
                (cdr (cadr t)))
          (checked-binding-name (cadr t)))
      (syntax-error t)))

(define (parse-indirect t)
  (if (and (list? t)
           (andmap (lambda (spec)
                     (and (list? spec)
                          (not (null? spec))
                          (andmap identifier? spec)))
                   (cdr t)))
      (cdr t)
      (syntax-error t)))


;;;=========================================================================
;;;
;;; Toplevel let(rec)-syntax:
;;;
;;;=========================================================================

(define (expand-let-syntax t)
  (expand-local-syntax t 'let-syntax))

(define (expand-letrec-syntax t)
  (expand-local-syntax t 'letrec-syntax))

(define (expand-local-syntax t type)
  (let-values (((formals exps body) (scan-local-syntax t)))                
    (let* ((bindings (map add-local-binding formals))
           (new-env  (extend-usage-env* bindings))       
           (procs    (map (lambda (exp)
                            (eval (parameterize ((*level* (+ 1 (*level*))))
                                    (case type
                                      ((let-syntax) (expand exp))
                                      ((letrec-syntax)
                                       (parameterize ((*usage-env* new-env))
                                         (expand exp)))))))
                          exps)))
      (parameterize ((*usage-env* new-env)
                     (*macros*
                      (extend-macros*
                       (map (lambda (binding macro)
                              (cons (binding-symbol (cdr binding))                       
                                    (make-macro macro)))
                            bindings
                            procs))))
        ;; Map-in-order is correct for toplevel local 
        ;; syntax, since splicing occurs and body may 
        ;; contain syntax definitions affecting subsequent
        ;; expansion.  
        `(begin ,@(map-in-order expand body))))))

(define (scan-local-syntax t)            
  (or (and (pair? t)
           (pair? (cdr t))
           (list? (cadr t))
           (list? (cddr t))
           (every? (lambda (binding)
                     (and (pair? binding)
                          (identifier? (car binding))
                          (pair? (cdr binding))
                          (null? (cddr binding))))
                   (cadr t)))
      (syntax-error))
  (let ((formals (map car (cadr t)))
        (exps    (map cadr (cadr t)))
        (body    (cddr t)))
    (or (formals? formals)
        (syntax-error))
    (values formals
            exps
            body)))

;;;=========================================================================
;;;
;;; Toplevel definitions:
;;;
;;;=========================================================================

(define (expand-define-syntax t)
  (let-values (((id exp) (parse-definition t)))
    ;; This line makes a difference for macro-generated defines.
    (*usage-env* (extend-usage-env (add-toplevel-binding id)))         
    (register-macro! (binding-name id)
                     (make-macro (eval (parameterize ((*level* (+ 1 (*level*))))
                                         (expand exp)))))))

(define (expand-define t)
  (let-values (((id exp) (parse-definition t)))
    ;; This line makes a difference for macro-generated defines
    (*usage-env* (extend-usage-env (add-toplevel-binding id)))
    ;; Since expander searches macro table
    ;; before the usage-env, we have to remove from the
    ;; former when a toplevel redefinition takes place.
    (*macros* (alist-delete (binding-name id) 
                            (*macros*)))
    `(define ,(binding-name id)
       ,(expand exp))))

;;;=========================================================================
;;;
;;; Syntax-case:
;;;
;;;=========================================================================

(define (expand-syntax-case exp)
  (if (and (list? exp)
           (>= (length exp) 3))
      (let ((literals (caddr exp))
            (clauses (cdddr exp)))
        (if (and (list? literals)
                 (every? identifier? literals))
            (let ((input (generate-name 'input)))
              `(let ((,input ,(expand (cadr exp))))
                 ,(process-clauses clauses input literals)))
            (syntax-error)))
      (syntax-error)))

(define *pattern-env* (make-parameter '()))

(define (process-clauses clauses input literals)
  
  (define (process-match input pattern sk fk)
    (cond 
      ((not (symbol? input)) (let ((temp (generate-name 'temp)))
                               `(let ((,temp ,input))
                                  ,(process-match temp pattern sk fk))))
      ((ellipses? pattern)   (syntax-error "Invalid pattern"))
      ((null? pattern)       `(if (null? ,input) ,sk ,fk))
      ((const? pattern)      `(if (equal? ,input ',pattern) ,sk ,fk))
      ((wildcard? pattern)   sk)
      ((identifier? pattern) (if (member=? pattern literals bound-identifier=?)
                                 `(if (and (identifier? ,input)
                                           (free-identifier=? ,input ,(syntax-reflect pattern)))
                                      ,sk
                                      ,fk)
                                 `(let ((,(binding-name pattern) ,input)) ,sk)))     
      ((segment-pattern? pattern)          
       (let ((tail-pattern (cddr pattern)))
         (if (null? tail-pattern)
             (let ((mapped-pvars (map binding-name (map car (pattern-vars (car pattern) 0)))))
               `(if (list? ,input)
                    ,(if (identifier? (car pattern))                     ; +++
                         `(let ((,(binding-name (car pattern)) ,input))  ; +++
                            ,sk)                                         ; +++
                         `(let ((columns (map-while (lambda (,input)
                                                      ,(process-match input
                                                                      (car pattern)
                                                                      `(list ,@mapped-pvars)
                                                                      #f))  
                                                    ,input)))
                            (if columns
                                (apply (lambda ,mapped-pvars ,sk)
                                       (if (null? columns)
                                           ',(map (lambda (ignore) '()) mapped-pvars)
                                           (apply map list columns)))
                                ,fk)))
                    ,fk))
             (let ((tail-length (dotted-length tail-pattern)))
               `(if (>= (dotted-length ,input) ,tail-length) 
                    ,(process-match `(dotted-butlast ,input ,tail-length) 
                                    `(,(car pattern) ,(cadr pattern))
                                    (process-match `(dotted-last ,input ,tail-length)
                                                   (cddr pattern)
                                                   sk
                                                   fk)
                                    fk)
                    ,fk)))))   
      ((pair? pattern)   `(if (pair? ,input)
                              ,(process-match `(car ,input)
                                              (car pattern)
                                              (process-match `(cdr ,input) (cdr pattern) sk fk)
                                              fk)
                              ,fk))
      ((vector? pattern) `(if (vector? ,input)
                              ,(process-match `(vector->list ,input)
                                              (vector->list pattern) 
                                              sk
                                              fk)
                              ,fk)) 
      (else (syntax-error))))
            
  (define (pattern-vars pattern level)     
    (cond 
      ((identifier? pattern)      (if (or (wildcard? pattern) 
                                          (member=? pattern literals bound-identifier=?))
                                      '()
                                      (list (cons pattern level)))) 
      ((segment-pattern? pattern) (append (pattern-vars (car pattern) (+ level 1))
                                          (pattern-vars (cddr pattern) level)))
      ((pair? pattern)            (append (pattern-vars (car pattern) level)
                                          (pattern-vars (cdr pattern) level)))
      ((vector? pattern)          (pattern-vars (vector->list pattern) level))
      (else                       '())))
  
  (define (process-clause clause input fk)
    (or (and (list? clause)
             (>= (length clause) 2))
        (syntax-error))
    (let* ((pattern  (car clause))
           (template (cdr clause))
           (pvars    (pattern-vars pattern 0)))
      (or (unique=? (map car pvars) bound-identifier=?)
          (syntax-error "Repeated pattern variable in" pattern))
      (parameterize ((*pattern-env* (append pvars (*pattern-env*)))
                     (*usage-env*
                      (extend-usage-env*
                       (map add-local-binding (map car pvars)))))
        (process-match input
                       pattern
                       (cond ((null? (cdr template))
                              (expand (car template)))
                             ((null? (cddr template))
                              `(if ,(expand (car template))
                                   ,(expand (cadr template))
                                   ,fk))   
                             (else (syntax-error)))
                       fk))))

  ;; process-clauses
  
  (if (null? clauses)
      `(syntax-error ,input)
      (let ((fail  (generate-name 'fail)))
        `(let ((,fail (lambda () ,(process-clauses (cdr clauses) input literals))))
           ,(process-clause (car clauses) input `(,fail))))))

(define wildcard? (make-free-predicate '_))

;; Ellipsis utilities:

(define ellipses? (make-free-predicate '...))

(define (segment-pattern? pattern)
  (and (segment-template? pattern)
       (or (andmap (lambda (p) 
                     (not (ellipses? p)))
                   (flatten (cddr pattern)))
           (syntax-error "Invalid segment pattern" pattern))))

(define (segment-template? pattern)
  (and (pair? pattern)
       (pair? (cdr pattern))
       (identifier? (cadr pattern))
       (ellipses? (cadr pattern))))

;; Count the number of `...'s in PATTERN.

(define (segment-depth pattern)
  (if (segment-template? pattern)
      (+ 1 (segment-depth (cdr pattern)))
      0))

;; Get whatever is after the `...'s in PATTERN.

(define (segment-tail pattern)
  (let loop ((pattern (cdr pattern)))
    (if (and (pair? pattern)
             (identifier? (car pattern))
             (ellipses? (car pattern)))   
        (loop (cdr pattern))
        pattern)))

;; Ellipses-quote:

(define (ellipses-quote? template)
  (and (pair? template)
       (ellipses? (car template))
       (pair? (cdr template))
       (null? (cddr template))))


;;;=========================================================================
;;;
;;; Syntax:
;;;
;;;=========================================================================

(define (expand-syntax form) 
  (or (and (pair? form)
           (pair? (cdr form))
           (null? (cddr form)))
      (syntax-error))
  (process-template (cadr form) 0 (*pattern-env*) #f))

(define (process-template template dim env quote-ellipses)
  (cond ((and (ellipses? template)
              (not quote-ellipses))
         (syntax-error "Invalid occurrence of ellipses in syntax template" template))
        ((identifier? template)
         (let ((probe (assoc= template env bound-identifier=?)))
           (if probe
               (if (<= (cdr probe) dim)
                   (checked-binding-name template)
                   (syntax-error "Syntax-case: Template dimension error (too few ...'s?):"
                                 template))
               (syntax-reflect template))))
        ((ellipses-quote? template)
         (process-template (cadr template) dim env #t))
        ((and (segment-template? template)
              (not quote-ellipses))
         (let* ((depth (segment-depth template))
                (seg-dim (+ dim depth))
                (vars
                 (map checked-binding-name
                      (free-meta-variables (car template) seg-dim env '()))))
           (if (null? vars)
               (syntax-error "too many ...'s:" template)
               (let* ((x (process-template (car template) seg-dim env quote-ellipses))
                      (gen (if (equal? (list x) vars)   ; +++
                               x                        ; +++
                               `(map (lambda ,vars ,x)
                                     ,@vars)))
                      (gen (do ((d depth (- d 1))
                                (gen gen `(apply append ,gen)))
                             ((= d 1)
                              gen))))
                 (if (null? (segment-tail template))   
                     gen                              ; +++
                     `(append ,gen ,(process-template (segment-tail template) dim env quote-ellipses)))))))
        ((pair? template)
         `(cons ,(process-template (car template) dim env quote-ellipses)
                ,(process-template (cdr template) dim env quote-ellipses)))
        ((vector? template)
         `(list->vector ,(process-template (vector->list template) dim env quote-ellipses)))
        (else
         `(quote ,(expand template)))))

;; Return a list of meta-variables of given higher dim

(define (free-meta-variables template dim env free)
  (cond ((identifier? template)
         (if (and (not (member=? template free bound-identifier=?))
                  (let ((probe (assoc= template env bound-identifier=?)))
                    (and probe (>= (cdr probe) dim))))
             (cons template free)
             free))
        ((segment-template? template)
         (free-meta-variables (car template) dim env
                              (free-meta-variables (cddr template) dim env free)))
        ((pair? template)
         (free-meta-variables (car template) dim env
                              (free-meta-variables (cdr template) dim env free)))
        (else free)))

;;;==========================================================================       
;;;
;;; Libraries:
;;;
;;; A simple semantics that makes static resolution of imports
;;; possible is to require a single expand-time environment 
;;; and simplified rules implying that:
;;;
;;;  - each imported library is visited exactly once, and
;;;    invoked at most once, during expansion.
;;;
;;; The implementation allows libraries to be imported also at 
;;; negative meta-level.  However, when there are no negative level
;;; imports in a program, the semantics reduces to the following very 
;;; simple rules, which I describe first.  The case where negative imports
;;; are allowed is decribed below:
;;;
;;; More precisely, to visit a library in the absence of negative levels:
;;;
;;;     * Visit any library that is imported by
;;;       this library and that has not yet been visited.
;;;     * For each k >= 1, invoke any library that is imported       
;;;       by this library for .... (meta k), and that has not yet been
;;;       invoked.
;;;     * Evaluate all syntax definitions in the library.
;;;
;;; To invoke a library in the absence of negative meta levels:
;;;
;;;     * Invoke any library that is imported by this library
;;;       for run, and that has not yet been invoked.
;;;     * Evaluate all variable definitions and expressions in
;;;       the library.
;;;
;;; The full semantics implemented here, which is equivalent to the above when there
;;; are no negative levels, is as follows:
;;;
;;; To visit a library at level n:
;;;
;;;    * If n < 0  : Do nothing
;;;    * If n >= 0 : * Visit at level (n + k) any library that is imported by
;;;                    this library for (meta k) and that has not yet been visited
;;;                    for /any/ level.
;;;                  * For each k >= 1, invoke at level (n + k) any library that is 
;;;                    imported by this library for .... (meta k), and that has not 
;;;                    yet been invoked for /any/ level.
;;;                  * Evaluate all syntax definitions in the library.
;;;
;;; To invoke a library at level n:
;;;
;;;    * If n < 0  : Do nothing.
;;;    * If n >= 0 : * Invoke at level (n + k) any library that is imported by this 
;;;                    library for (meta k), and that has not yet been invoked
;;;                    for /any/ level.
;;;                  * If n = 0: Evaluate all variable definitions and expressions in
;;;                              the library.
;;;                  * If n > 0: Do nothing
;;;
;;; Runtime execution of a library happens in a fresh environment but is
;;; otherwise the same as invoking it.
;;;
;;; This therefore assigns separate environments to each
;;; of the two phases (expansion and execution), and not to each of
;;; the possibly many meta-levels.  In each of the two phases, bindings
;;; are shared between whichever levels they are imported into.  
;;;
;;;==========================================================================

(define (expand-library t)     
  (or (and (list? t)              
           (>= (length t) 4))       
      (syntax-error "Invalid number of clauses in library spec"))
  
  (let ((keyword (car t))
        (name    (scan-library-name (cadr t))))                
    
    (let-values (((exports)                    (scan-exports (caddr t)))
                 ((imported-libraries imports) (scan-imports (cadddr t))))
      
      ;; Make sure we start with a clean compilation environment,
      ;; and that we restore any global state afterwards.
      ;; Make sure macros registered when visiting
      ;; imported libraries are removed once we are done.
      ;; We do not restore *visited* and *invoked* in case
      ;; libraries are redefined. 
      
      (*visited* '())
      (*invoked* '())
      
      (parameterize ((*reflected-envs* '())  
                     (*usage-env*      '())
                     (*visited*        '())
                     (*invoked*        '())
                     (*macros*         (*macros*)))               
        
        (visit-imports imported-libraries 0)
        
        ;; Obtain a mark so that we know which reflected environments
        ;; are created for use by this library and should be included
        ;; in the object code.
        
        (let ((reflected-envs-after-imports (*reflected-envs*)))
          
          ;; This step does the actual import by annotating identifiers
          ;; in the export clause and the body with new transformer environments
          ;; containing the imported bindings.  
          
          (let ((exports-body (reannotate-library (cons exports (cddddr t)) keyword imports)))  
            
            (let ((exports (car exports-body))
                  (body    (cdr exports-body)))
              
              (scan-body '()
                         ;; Already-bound list, to enforce no rebinding of imports.
                         (map (lambda (import)
                                (datum->syntax keyword (car import)))
                              imports)
                         body
                         (lambda (ignore-formals definitions syntax-definitions declarations indirects exps)
                           
                           ;; This has to be done here, when all bindings are
                           ;; established.
                           
                           (let* ((exports (map (lambda (entry)
                                                  (cons (identifier-name (car entry))
                                                        (let ((probe (lookup-binding (cadr entry))))
                                                          (if probe 
                                                              (cdr probe)
                                                              (syntax-error "Unbound export" entry)))))
                                                exports))
                                  (all-exports (apply append
                                                      (map cadr exports)
                                                      ;; Also indirectly exported names:
                                                      (map (let ((exported-names (map cadr exports)))
                                                             (lambda (indir)
                                                               (if (memq (car indir) exported-names)
                                                                   (cdr indir)
                                                                   '())))
                                                           indirects))) 
                                  
                                  ;; This is what we should have to enforce indirect-export,
                                  ;; but enforcement has been removed:
                                  
                                  ;; (exported-def? (lambda (def) (memq (car def) all-exports)))
                                  
                                  (exported-def? (lambda (def) #t))
                                  (exported-definitions (filter exported-def? definitions))
                                  (local-definitions    (filter (lambda (def)
                                                                  (not (exported-def? def)))
                                                                definitions))
                                  (expanded-library
                                   `(begin
                                      
                                      ;; Procedure to be invoked when visiting:
                                      ;; This is separated from the runtime code 
                                      ;; below so that it can be left out from the  
                                      ;; runtime object image if desired.  
                                      
                                      (define (,(name-for-visit name) message)
                                        (case message
                                          ((imported-libraries) ',imported-libraries)
                                          ((exports) ',exports)
                                          ((visit)
                                           (extend-reflected-envs! 
                                            ',(compress-reflected-envs reflected-envs-after-imports))
                                           ,@(map (lambda (def)
                                                    `(register-macro! ',(car def) (make-macro ,(cdr def)))) 
                                                  (filter exported-def? syntax-definitions)))
                                          (else
                                           (error "Invalid operation" message "on library" ',name))))
                                      
                                      ;; This is the runtime code.
                                      
                                      ,@(map (lambda (def)
                                               `(define ,(car def) (unspecified)))
                                             exported-definitions)
                                      
                                      (define (,(name-for-invoke name) message)
                                        (case message
                                          ((imported-libraries) ',imported-libraries)
                                          ((invoke)
                                           ;; Reproduce letrec* semantics remembering
                                           ;; that some of the variables are outside.
                                           ,@(map (lambda (def)
                                                    `(set! ,(car def) (unspecified)))
                                                  exported-definitions)
                                           ((lambda ,(map car local-definitions)
                                              ,@(map (lambda (def) 
                                                       `(set! ,(car def) ,(cdr def)))
                                                     definitions)
                                              ,@(if (null? exps) 
                                                    `((unspecified))
                                                    exps))
                                            ,@(map (lambda (ignore) `(unspecified))
                                                   local-definitions)))
                                          (else
                                           (error "Invalid operation" message "on library" ',name)))))))
                             
                             ;; Make library available and
                             ;; include in object code:
                             
                             (eval expanded-library)
                             expanded-library))))))))))

;; To maintain hygiene with possible macro-generated libraries,
;; we maintain existing colours of identifiers.
;; Only identifiers that have the same colours as the
;; library keyword are bound by imports.

(define (reannotate-library stx keyword imports)
  (let ((shared-env
         
         ;; Space-optimization - we reflect to ensure
         ;; tail-sharing of imported bindings, which
         ;; is typically a large list, in the object
         ;; library.
         ;; This sharing is okay for source-level
         ;; identifiers, since the only reflected
         ;; environments that can be destructively
         ;; modified are created during expansion
         ;; of syntax expressions in trsansformer
         ;; right hand sides in bodies.  
         
         (reflect-env imports (identifier-colours keyword))))
    
    (sexp-map (lambda (leaf)
                (cond ((const? leaf) leaf)
                      ((identifier? leaf) 
                       (make-identifier (identifier-name leaf)                    
                                        (identifier-colours leaf)
                                        (if (colours=? (identifier-colours keyword)
                                                       (identifier-colours leaf))
                                            shared-env
                                            '())                   
                                        (identifier-level-correction leaf)))
                      (else
                       (syntax-error "Invalid syntax object:" leaf))))
              stx)))


(define *visited* (make-parameter '()))
(define *invoked* (make-parameter '()))

(define (visit-imports imports level)
  (if (or (< level 0)
          (null? imports))
      (unspecified)
      (let* ((import (car imports))
             (name   (car import))
             (levels (cdr import)))
        (if (null? levels)
            (visit-imports (cdr imports) level)
            (let* ((level+ (+ level (car levels))))
              (if (>= level+ 1)
                  (invoke name level+))
              (visit name level+)
              (visit-imports (cons (cons name (cdr levels))
                                   (cdr imports))
                             level))))))

(define (visit name level)
  (if (or (< level 0)
          (memq name (*visited*)))
      (unspecified)
      (let ((imports (eval `(,(name-for-visit name) 'imported-libraries))))  
        (visit-imports imports level)
        (cond ((memq name (*visited*))  
               (syntax-error "Cyclic library dependency of" name "on" (*visited*)))
              (else
               (eval `(,(name-for-visit name) 'visit))
               (*visited* (cons name (*visited*))))))))

(define (invoke-imports imports level)
  (if (or (< level 0) 
          (null? imports))
      (unspecified)
      (let* ((import (car imports))
             (name   (car import))
             (levels (cdr import)))
        (if (null? levels) 
            (invoke-imports (cdr imports) level)
            (begin 
              (invoke name (+ level (car levels))) 
              (invoke-imports (cons (cons name (cdr levels))
                                    (cdr imports))
                              level))))))

;; TODO - it may be better to compile this into module code, so that  
;; invocations of EVAL at runtime are avoided and we simply have 
;; ordinary function calls from within the module.

(define (invoke name level)
  (if (or (< level 0)
          (memq name (*invoked*)))
      (unspecified)
      (let ((imports (eval `(,(name-for-invoke name) 'imported-libraries))))  
        (invoke-imports imports level)
        (cond ((memq name (*invoked*))  
               (syntax-error "Cyclic library dependency of" name "on" (*invoked*)))
              (else
               (eval `(,(name-for-invoke name) 'invoke))
               (*invoked* (cons name (*invoked*)))))))) 

;; Returns ((<rename-identifier> <identifier> <level> ...) ...)

(define (scan-exports clause) 
  (and (pair? clause)
       (export? (car clause)) 
       (list?   (cdr clause))) 
  (let ((exports (apply append 
                        (map scan-export-spec (cdr clause)))))
    (or (unique=? exports 
                  (lambda (x y) (eq? (identifier-name (car x))
                                     (identifier-name (car y)))))
        (syntax-error "Duplicate export in" clause))
    exports))

;; Prior version that had FOR exports:

;;(define (scan-export-spec spec)
;;  (let ((levels (scan-levels spec))
;;        (export-sets (if (for-spec? spec) 
;;                         (cadr spec) 
;;                         (list spec))))
;;    (map (lambda (rename-pair)
;;           (cons (car rename-pair)
;;                 (cons (cdr rename-pair)
;;                       levels)))
;;         (apply append (map scan-export-set export-sets)))))

(define (scan-export-spec spec)
  (let ((levels `(0))               ;; Will be ignored in current implementation, but keep data   
        (export-sets (list spec)))  ;; structures and interfaces same in case FOR exports return.
    (map (lambda (rename-pair)
           (cons (car rename-pair)
                 (cons (cdr rename-pair)
                       levels)))
         (apply append (map scan-export-set export-sets)))))
           
(define (scan-export-set set)
  (cond ((identifier? set)
         (list (cons set set)))
        ((rename-export-set? set)
         (map (lambda (entry)
                (cons (cadr entry)
                      (car entry)))
              (cdr set)))
        (else
         (syntax-error "Invalid export set" set))))

(define (scan-levels spec) 
  (cond ((for-spec? spec) 
         (let ((levels
                (map (lambda (level)
                       (cond ((run? level)       0)
                             ((expand? level)    1)
                             ((meta-spec? level) (cadr level))
                             (else (syntax-error "Invalid level" level "in for spec" spec))))    ;;;;;;; factor
                     (cddr spec))))
           (if (unique=? levels =)
               levels
               (syntax-error "Repeated level in for spec" spec))))
        (else '(0))))

;; Returns (values ((<library name> <level> ...) ....)
;;                 ((<local name> . <binding>) ...))
;; with no repeats.  

(define (scan-imports clause)
  (or (and (pair? clause)
           (import? (car clause)) 
           (list?   (cdr clause)))
      (syntax-error "Invalid import clause" clause))
  (scan-import-specs (cdr clause)))

(define (scan-import-specs specs)
  (let loop ((specs specs)
             (imported-libraries '())
             (imports '()))
    (if (null? specs)
        (begin  
          (or (unique=? imported-libraries 
                        (lambda (x y) (eq? (car x) (car y))))
              (syntax-error "Library imported more than once in" imported-libraries))
          (values imported-libraries 
                  (unify-imports imports)))
        (let-values (((library-name levels more-imports)
                      (scan-import-spec (car specs))))
          (loop (cdr specs)
                (if library-name
                    (cons (cons library-name levels)
                          imported-libraries)
                    ;; library-name = #f if primitives spec
                    imported-libraries)
                (append more-imports imports))))))

;; Returns (values <library name> | #f
;;                 (<level> ...)
;;                 ((<local name> . <binding>) ...)  
;; where <level> ::= <uinteger>
;; #f is returned for library name in case of primitives set.  

(define (scan-import-spec spec)
  (let ((levels (scan-levels spec)))
    (let loop ((import-set (if (for-spec? spec) 
                               (cadr spec) 
                               spec))
               (renamer (lambda (x) x)))
      
      ;; Extension for importing unadorned primitives:
      
      (cond ((primitive-set? import-set)
             (values #f
                     levels 
                     ;; renamer will return <symbol> | #f
                     (filter car
                             (map (lambda (name)
                                    (cons name
                                          (make-binding name levels)))
                                  (syntax->datum (cadr import-set))))))
            ((and (list? import-set)
                  (>= (length import-set) 2)
                  (or (only-set? import-set)
                      (except-set? import-set)
                      (add-prefix-set? import-set)
                      (rename-set? import-set)))
             (loop (cadr import-set)
                   (compose renamer 
                            ;; Remember to correctly propagate if x is #f
                            (lambda (x)
                              (cond
                                ((only-set? import-set)
                                 (and (memq x (syntax->datum (cddr import-set)))
                                      x)) 
                                ((except-set? import-set)
                                 (and (not (memq x (syntax->datum (cddr import-set))))
                                      x)) 
                                ((add-prefix-set? import-set)
                                 (and x
                                      (string->symbol
                                       (string-append (symbol->string (syntax->datum (caddr import-set)))
                                                      (symbol->string x)))))
                                ((rename-set? import-set)
                                 (let ((renames (syntax->datum (cddr import-set))))
                                   (cond ((assq x renames) => cadr)
                                         (else x)))) 
                                (else (syntax-error "Invalid import set" import-set))))))) 
            ;; This has to be last or there could be ambiguity
            ;; if the parentheses shorthand for libraries is allowed.
            ((library-ref? import-set)
             (let* ((library-name (library-ref->symbol import-set))
                    (exports (eval `(,(name-for-visit library-name) 'exports))))
               (let* ((imports 
                       ;; renamer will return <symbol> | #f
                       (filter car
                               (map (lambda (export)
                                      (cons (renamer (car export))         
                                            (make-binding (binding-symbol (cdr export))
                                                          (compose-levels levels 
                                                                          (binding-levels (cdr export))))))
                                    exports)))
                      (all-import-levels (apply unionv
                                                (map (lambda (import)
                                                       (binding-levels (cdr import)))
                                                     imports))))
               (values library-name
                       levels
                       imports))))
            (else (syntax-error "Invalid import set" import-set))))))

(define (compose-levels levels levels*)
  (apply unionv 
         (map (lambda (level)
                (map (lambda (level*)
                       (+ level level*))
                     levels*))
              levels)))
 
;; Argument is of the form ((<local name> <binding>) ...)
;; where combinations (<local name> (binding-symbol <binding>)) may be repeated.
;; Return value is of the same format but with no repeats and
;; where union of (binding-levels <binding>)s has been taken for any original repeats.
;; An error is signaled if same <local> occurs with <binding>s
;; whose (binding-symbol <binding>)s are different.  

(define (unify-imports imports)           
  (if (null? imports)                   
      '()
      (let* ((first (car imports))
             (rest  (unify-imports (cdr imports))))
        (let loop ((rest rest)
                   (seen '()))
          (cond ((null? rest)
                 (cons first seen))
                ((eq? (car first) (caar rest))
                 (or (eq? (binding-symbol (cdr first))
                          (binding-symbol (cdar rest)))
                     (syntax-error "Same name imported from different libraries"
                                   (car first)))
                 (cons (cons (car first)
                             (make-binding (binding-symbol (cdr first))
                                           (unionv (binding-levels (cdr first))
                                                   (binding-levels (cdar rest)))))
                       (append seen (cdr rest))))
                (else
                 (loop (cdr rest)
                       (cons (car rest) seen))))))))  

(define (for-spec? spec)
  (and (list? spec)
       (>= (length spec) 3)
       (for? (car spec))))

(define (meta-spec? level)
  (and (list? level)
       (= (length level) 2)
       (meta? (car level))
       (integer? (cadr level))))

(define (only-set? set)
  (and (only? (car set))
       (andmap identifier? (cddr set))))

(define (except-set? set)
  (and (except? (car set))
       (andmap identifier? (cddr set))))

(define (add-prefix-set? set)
  (and (add-prefix? (car set))
       (= (length set) 3)
       (identifier? (caddr set))))

(define (rename-set? set)
  (and (rename? (car set))
       (rename-list? (cddr set))))

(define (primitive-set? set)
  (and (list? set)
       (= (length set) 2)
       (primitives? (car set))
       (list (cadr set))
       (andmap identifier? (cadr set))))

(define (rename-export-set? set)
  (and (list? set)
       (>= (length set) 1)
       (rename? (car set))
       (rename-list? (cdr set))))

(define (rename-list? ls)
  (andmap (lambda (e)
            (and (list? e)
                 (= (length e) 2)
                 (andmap identifier? e)))
          ls))

(define for?        (make-free-predicate 'for))
(define run?        (make-free-predicate 'run))
(define expand?     (make-free-predicate 'expand))
(define import?     (make-free-predicate 'import))
(define export?     (make-free-predicate 'export))
(define only?       (make-free-predicate 'only))
(define except?     (make-free-predicate 'except))
(define add-prefix? (make-free-predicate 'add-prefix))
(define rename?     (make-free-predicate 'rename))
(define primitives? (make-free-predicate 'primitives))
(define meta?       (make-free-predicate 'meta))

(define (scan-library-name e)
  (or (library-name? e)
      (syntax-error "Invalid library name" e))
  (library-name->symbol e))

(define (library-name? e)
  (or (identifier? e)
      (and (list? e)
           (> (length e) 0)
           (identifier? (car e))
           (or (andmap (lambda (e)
                         (and (integer? e) (>= e 0)))
                       (cdr e))
               (library-name? (cdr e))))))

(define (library-name->symbol e)
  (if (identifier? e)
      (library-name->symbol `(,e))
      (make-free-name 
       (string->symbol
        (string-append (symbol->string (syntax->datum (car e)))
                       (apply string-append 
                              (map (lambda (e)
                                     (string-append "."
                                                    (if (identifier? e)
                                                        (symbol->string
                                                         (syntax->datum e))
                                                        (number->string e))))
                                   (cdr e)))))
       0)))

;; TODO - predicate references.

(define library-ref? library-name?)
(define library-ref->symbol library-name->symbol) 

(define (name-for-visit name)
  (string->symbol 
   (string-append (symbol->string name)
                  "|visit")))

(define (name-for-invoke name)
  (string->symbol 
   (string-append (symbol->string name)
                  "|invoke")))

;;;==========================================================================
;;;
;;; Debugging facilities:
;;;
;;;==========================================================================

;; Debugging information displayed by syntax-error.

(define *backtrace* (make-parameter '()))

(define (stacktrace term thunk)
  (parameterize ((*backtrace* (cons term (*backtrace*))))
    (thunk)))

(define (syntax-warning . args)
  (newline)
  (display "Syntax warning:")
  (display-args args))

(define (syntax-error . args)
  (newline)
  (display "Syntax error:")
  (display-args args)
  (for-each (lambda (exp)
              (display "  ")
              (pretty-display (syntax-debug exp))
              (newline)
              (newline))
            (*backtrace*))
  (error))

(define (display-args args)
  (newline)
  (newline)
  (for-each (lambda (arg)
              (display (syntax-debug arg)) (display " "))
            args)
  (newline)
  (newline))

(define (syntax-debug exp)
  (sexp-map (lambda (leaf)
              (cond ((identifier? leaf) 
                     (identifier-name leaf))
                    (else leaf)))
            exp))

;;;=====================================================================
;;;
;;; Utilities:
;;;
;;;=====================================================================

(define (flatten l)
  (cond ((null? l) l)
        ((pair? l) (cons (car l)
                         (flatten (cdr l))))
        (else (list l))))

(define (sexp-map f s)
  (cond ((null? s) '())
        ((pair? s) (cons (sexp-map f (car s))
                         (sexp-map f (cdr s))))
        ((vector? s)
         (apply vector (sexp-map f (vector->list s))))
        (else (f s))))

(define (map-in-order f ls)
  (if (null? ls)
      '()
      (let ((first (f (car ls))))
        (cons first
              (map-in-order f (cdr ls))))))

(define (dotted-member? x ls =)
  (cond ((null? ls) #f)
        ((pair? ls) (or (= x (car ls))
                        (dotted-member? x (cdr ls) =)))
        (else (= x ls))))

(define (dotted-map f lst)
  (cond ((null? lst) '())
        ((pair? lst) (cons (f (car lst))
                           (dotted-map f (cdr lst))))
        (else (f lst))))

;; Returns 0 also for non-list a la SRFI-1 protest.

(define (dotted-length dl)
  (cond ((null? dl) 0)
        ((pair? dl) (+ 1 (dotted-length (cdr dl))))
        (else 0)))
  
(define (dotted-butlast ls n)
  (let recurse ((ls ls)
                (length-left (dotted-length ls)))
    (cond ((< length-left n) (error "Dotted-butlast - list too short" ls n))
          ((= length-left n) '())
          (else
           (cons (car ls) 
                 (recurse (cdr ls)
                          (- length-left 1)))))))

(define (dotted-last ls n)
  (let recurse ((ls ls)
                (length-left (dotted-length ls)))
    (cond ((< length-left n) (error "Dotted-last - list too short" ls n))
          ((= length-left n) ls)
          (else  
           (recurse (cdr ls)
                    (- length-left 1))))))

(define (map-while f lst)
  (cond ((null? lst) '())
        ((pair? lst)
         (let ((head (f (car lst))))
           (if head
               (cons head 
                     (map-while f
                                (cdr lst)))
               #f)))
        (else '())))
  
(define (every? p? ls)
  (cond ((null? ls) #t)
        ((pair? ls) (and (p? (car ls))
                         (every? p? (cdr ls))))
        (else #f)))

(define (assoc= key alist =)
  (cond ((null? alist)        #f)
        ((= (caar alist) key) (car alist))
        (else                 (assoc= key (cdr alist) =))))

(define (member=? x ls =)
  (cond ((null? ls) #f)
        ((pair? ls) (or (= x (car ls))
                        (member=? x (cdr ls) =)))
        (else (error "Member=?" x ls =))))

(define (unique=? ls =)
  (or (null? ls)
      (and (not (member=? (car ls) (cdr ls) =))
           (unique=? (cdr ls) =))))

(define (filter p? lst)
  (if (null? lst)
      '()
      (if (p? (car lst))
          (cons (car lst)
                (filter p? (cdr lst)))
          (filter p? (cdr lst)))))

(define (unionv . sets)
  (cond ((null? sets) '())
        ((null? (car sets)) 
         (apply unionv (cdr sets)))
        (else 
         (let ((rest (apply unionv 
                            (cdr (car sets)) 
                            (cdr sets))))
           (if (memv (car (car sets)) rest)
               rest
               (cons (car (car sets)) rest))))))
   
(define (alist-cons key datum alist)
  (cons (cons key datum) alist))

(define (alist-ref key alist)
  (cond ((assq key alist) => cdr)
        (else #f)))

(define (alist-delete key alist)
  (cond ((null? alist)
         '())
        ((eq? (caar alist) key)
         (alist-delete key (cdr alist)))
        (else
         (cons (car alist)
               (alist-delete key (cdr alist))))))

(define (alist-remove-duplicates alist)
  (define (rem alist already)
    (cond ((null? alist)               '())
          ((memq (caar alist) already) (rem (cdr alist) already))
          (else                        (cons (car alist)
                                             (rem (cdr alist)
                                                  (cons (caar alist)
                                                        already))))))
  (rem alist '()))

(define unspecified
  (let ((x (if #f #f)))
    (lambda () x)))

(define (compose f g)
  (lambda (x) (f (g x))))

(define (check x p? from)
  (or (p? x)
      (syntax-error from "Invalid argument:" x)))   

;;;==========================================================================
;;;
;;; Toplevel:
;;;
;;;==========================================================================

;; Converting source to syntax objects:

(define (source->syntax datum)
  (datum->syntax toplevel-template datum))

;; Imports additional bindings into toplevel environment.
;; Syntax is the same as <import spec>.

(define (expand-import t)              
  (or (and (list? t)                              
           (>= (length t) 1))
      (syntax-error))                                                    
  (import-toplevel (cdr t)))

;; For deterministic toplevel behaviour, we start
;; with clean visited/invoked slate every time.

(define (import-toplevel import-specs)
  (let-values (((imported-libraries imports) (scan-import-specs import-specs)))
    (visit-imports imported-libraries 0)   
    (invoke-imports imported-libraries 0)
    (*usage-env* (import-usage-env* toplevel-template imports))))   

;; Imports at toplevel are done simply by using datum->syntax to create
;; implicit identifiers from the keyword, and mapping these
;; to the external bindings. 

(define (import-usage-env* keyword imports)      
  (extend-usage-env*
   (map (lambda (import)
          (cons (datum->syntax keyword (car import))
                (cdr import)))
        imports)))

;;;==========================================================================
;;;
;;;  Eval and environment:
;;;
;;;==========================================================================

(define eval-template
  (make-identifier 'eval-template
                   no-colours 
                   '() 
                   0))  

(define-struct environment (imported-libraries imports))

(define (environment . import-specs)
  (parameterize ((*usage-env* '()))
    (parameterize ((*usage-env*                           
                    (import-usage-env* eval-template  
                                       (map (lambda (name)
                                              (cons name (make-binding name '(0))))  
                                            '(for
                                              run               
                                              expand
                                              meta
                                              only
                                              except
                                              add-prefix
                                              rename
                                              primitives)))))
      (let-values (((imported-libraries imports)
                    (scan-import-specs
                     (map (lambda (spec) 
                            (datum->syntax eval-template spec))
                          import-specs))))
        (make-environment imported-libraries imports)))))
  
(define (r6rs-eval exp env)
  (parameterize ((*usage-env* '()))
    (let ((exp (reannotate-library (datum->syntax eval-template exp)
                                   eval-template 
                                   (environment-imports env))))
      (visit-imports  (environment-imported-libraries env) 0)
      (invoke-imports (environment-imported-libraries env) 0)
      (eval (expand exp)))))

;;;==========================================================================
;;;
;;; Toplevel bootstrap:
;;;
;;;==========================================================================

(define toplevel-template
  (make-identifier 'toplevel-template
                   no-colours 
                   '() 
                   0))  
  
;; These are the only bindings available in the initial toplevel
;; environment.

(*usage-env*                           
 (import-usage-env* toplevel-template  
                    (map (lambda (name)
                           (cons name (make-binding name '(0))))  
                         
                         ;; The default language available at toplevel is
                         ;; the syntax import (toplevel meaning)
                         ;; and the R6RS library language:
                         
                         '(import      
                           library                 
                           import             
                           export
                           for
                           run               
                           expand
                           meta
                           only
                           except
                           add-prefix
                           rename
                           primitives))))
      
(*macros* `((library          . ,(make-expander expand-library))
            (import           . ,(make-expander expand-import))
            (lambda           . ,(make-expander expand-lambda))
            (if               . ,(make-expander expand-if))
            (set!             . ,(make-expander expand-set!))
            (begin            . ,(make-expander expand-begin))
            (syntax           . ,(make-expander expand-syntax))
            (quote            . ,(make-expander expand-quote))
            (define           . ,(make-expander expand-define))
            (define-syntax    . ,(make-expander expand-define-syntax))
            (let-syntax       . ,(make-expander expand-let-syntax))
            (letrec-syntax    . ,(make-expander expand-letrec-syntax))
            (syntax-case      . ,(make-expander expand-syntax-case))
            (_                . ,(make-expander syntax-error))
            (...              . ,(make-expander syntax-error))
            (declare          . ,(make-expander syntax-error))
            (unsafe           . ,(make-expander syntax-error))
            (safe             . ,(make-expander syntax-error))
            (fast             . ,(make-expander syntax-error))
            (small            . ,(make-expander syntax-error))
            (debug            . ,(make-expander syntax-error))
            ;; (indirect-export  . ,(make-expander syntax-error)) - removed
            (for              . ,(make-expander syntax-error)) 
            (run              . ,(make-expander syntax-error)) 
            (expand           . ,(make-expander syntax-error)) 
            (meta             . ,(make-expander syntax-error)) 
            (only             . ,(make-expander syntax-error)) 
            (except           . ,(make-expander syntax-error)) 
            (add-prefix       . ,(make-expander syntax-error)) 
            (rename           . ,(make-expander syntax-error)) 
            (primitives       . ,(make-expander syntax-error)))) 

;;;============================================================================
;;;
;;; REPL integration:
;;;
;;;============================================================================

(define (repl exps)
  (for-each (lambda (exp)
              ;; This is only necessary to reprise
              ;; in case of error:
              (reset-toplevel!)
              (for-each (lambda (result)
                          (display result)
                          (newline))
                        (call-with-values
                         (lambda ()
                           (eval (expand (source->syntax exp))))
                         list)))
            exps))

(define (reset-toplevel!)
  (*backtrace* '())
  (*pattern-env* '())
  (*level* 0)
  (*current-colour* no-colours))

;;;==========================================================================
;;;
;;;  Load and expand-file:
;;;
;;;==========================================================================

;; This may be used as a front end for the compiler:

(define (expand-file filename)
  (reset-toplevel!)
  (map-in-order expand (map source->syntax (read-file filename))))
  
(define (r6rs-load filename)
  (for-each eval (expand-file filename)))

(define read-file
  (lambda (fn)
    (let ((p (open-input-file fn)))
      (let f ((x (read p)))
        (if (eof-object? x)
            (begin (close-input-port p) '())
            (cons x
                  (f (read p))))))))

;;;==========================================================================
;;;
;;;  Make derived syntaxes available:
;;;
;;;==========================================================================

;; This expands and loads the core libraries composing r6rs.
;; In production, instead of doing this, just include the result 
;; of compiling (expand-file "macros-derived.scm")

(r6rs-load "macros-derived.scm")
