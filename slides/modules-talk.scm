(module modules-talk (lib "run.ss" "slideshow")
  
  (require (lib "etc.ss"))
  (require (lib "code.ss" "slideshow"))

  (slide/name/center
   "Module Issues"
   (titlet "Module Issues")
   (blank)
   (t "Mike Sperber"))

  (define (page-item/description tag . stuff)
    (apply page-item/bullet
	   (colorize (t tag) blue)
	   stuff))

  (slide/title/center
   "What are Modules?"

   (page-item/description "Matthew:"
			  "separate compilation, managing universal namespace, "
			  "importing implementations as opposed to importing "
			  "interfaces")

   (page-item/description "Will:"
			  "putting pieces together without name clashes, "
			  "hierarchical")

   (page-item/description "Mike:" "interchangeable parts")

   (page-item/description "Marc:" "encapsulation, managing namespace")

   (page-item/description "Manuel:"
			  "to organize programs in files, initialize things, name"
			  "entry points, etc.")

   (page-item/description "Kent:"
			  "all of the above except maybe files; namespace management, "
			  "analyzability, compile-time link"))

  (define (subtitle heading)
    (vc-append
     (colorize (t heading) blue)
     (blank)))

  (define (subheading heading)
    (colorize (t heading) orange))

  (define my-bullet (colorize (baseless
                               (cc-superimpose (disk (/ gap-size 2)) 
                                               (blank 0 gap-size)))
                              "blue"))
  
  (define (my-page-item . stuff)
    (apply page-item/bullet my-bullet stuff))


  (slide/title/center
   "Bigloo"
   (code
    (module m1
	(export foo bar))

    (define foo 23)
    (define bar 42))

   (code
    (module m2
	(export baz)
      (import m1))

    (define baz (+ foo bar)))
      
   )

  (slide/title/center
   "Chez Scheme"

   (code
    (module m1 (foo bar)
      (define foo 23)
      (define bar 42)))

   (code
    (module m2 (baz)
      (import m1)
      (define baz (+ foo bar)))))

  (slide/title/center
   "MzScheme"
   (code
    (module m1 mzscheme
      (provide foo bar)
      (define foo 23)
      (define bar 42)))

   (code
    (module m2 mzscheme
      (provide baz)
      (require m1)
      (define foo 23)
      (define bar 42))
    )
   )

  (slide/title/center
   "Scheme 48"
			
   (code
    (define-interface m1-interface
      (export foo bar))
    (define-structure m1 m1-interface
      (open scheme)
      (begin
	(define foo 23)
	(define bar 42)))
    )

   (code
    (define-interface m2-interface
      (export baz))
    (define-structure m2 m2-interface
      (open scheme
	    m1)
      (begin
	(define baz (+ foo bar))))
    )
   )

  (slide/title/center
   "Making Module Definitions Available"
   (subtitle "Bigloo")
   (subheading "m1.scm:")
    (code
     (module m1
	 (export foo bar))
     
     (define foo 23)
     ...)

    (blank)

    (subheading "Module access file:")
    (code
     ((m1 "m1.scm")
      ...))
     
   )

  (slide/title/center
   "Making Module Definitions Available"
   (subtitle "Chez Scheme")
   (subheading "m1.scm")
   (code
    (module m1 (foo bar)
      (define foo 23)
      ...))
   (blank)
   (code
    (load "m1.scm"))
   )

  (slide/title/center
   "Making Module Definitions Available"
   (subtitle "MzScheme")
   (subheading "m1.ss:")
   (code
    (module m1 mzscheme
      (provide foo bar)
      (define foo 23)
      ...))

   (blank)
   (code
    (require (lib "m1.ss" "libmike")))
   )

  (slide/title/center
   "Making Module Definitions Available"
   (subtitle "Scheme 48")
   
   (subheading "m1-config.scm:")
   (code
    (define-interface m1-interface
      (export foo bar))
    (define-structure m1 m1-interface
      (open scheme)
      (begin
	(define foo 23)
	...)))

   (blank)
   (subheading "REPL:")

   (tt ",config ,load m1-config.scm")
   )

  (define config-separator
    (picture 0 0 '((connect 0 0 200 0))))

  (slide/title/center
   "Separate Configuration Language"
   (subtitle "Bigloo")

   (code
    (module m1
	(export foo bar))

    (unsyntax config-separator)

    (define foo 23)
    (define bar 42))

   (code
    (module m2
	(export baz)
      (import m1))

    (unsyntax config-separator)

    (define baz (+ foo bar)))

   )

  (slide/title/center
   "Separate Configuration Language"
   (subtitle "Chez Scheme")
   (code
    (unsyntax config-separator)
    (module m1 (foo bar)
      (define foo 23)
      (define bar 42)))

   (code
    (unsyntax config-separator)
    (module m2 (baz)
      (import m1)
      (define baz (+ foo bar))))
   )

  (slide/title/center
   "Separate Configuration Language"
   (subtitle "MzScheme")
   (code
    (module m1 mzscheme
      (unsyntax config-separator)
      (provide foo bar)
      (define foo 23)
      (define bar 42)))

   (code
    (module m2 mzscheme
      (unsyntax config-separator)
      (provide baz)
      (require m1)
      (define foo 23)
      (define bar 42))
    )
   )

  (slide/title/center
   "Separate Configuration Language"
   (subtitle "Scheme 48")

   (code
    (define-interface m1-interface
      (export foo bar))
    (define-structure m1 m1-interface
      (open scheme)
      (begin
	(unsyntax config-separator)
	(define foo 23)
	(define bar 42)))
    ))

  (slide/title/center
   "Separate Configuration Language"
   (subtitle "Scheme 48")
   (code
    (define-interface m2-interface
      (export baz))
    (define-structure m2 m2-interface
      (open scheme
	    m1)
      (begin
	(unsyntax config-separator)
	(define baz (+ foo bar))))
    )
   )

  (slide/title/center
   "Neat Stuff with Local Modules"
   (code
    (define-syntax module*
      (syntax-rules ()
	((_ (id ...) form ...)
	 (begin
	   (module* tmp (id ...) form ...)
	   (import tmp)))
	((_ name (id ...) form ...)
	 (module name (id ...) form ...))))))
	 
    
  (slide/title/center
   "Neat Stuff with Local Modules"
   (code
    (define-syntax import*
      (syntax-rules ()
	((_ M) (begin))
	((_ M (new old))
	 (module* (new)
           (define-alias new tmp)
	   (module* (tmp)
             (import M)
	     (define-alias tmp old))))
	((_ M id)
	 (module* (id) (import M)))
	((_ M spec0 spec1 ...)
	 (begin
	   (import* M spec0)
	   (import* M spec1 ...)))))
    )
   )

  #;(slide/title/center
   "Ambiguities with Internal Definitions"

   (code
    (let-syntax ((foo (syntax-rules ()
			((foo) 'outer))))
      (let ()
	(define a (foo))
	(define-syntax foo
	  (syntax-rules ()
	    ((foo) 'inner)))
	a))
    => outer)
   )

  #;(slide/title/center
   "Ambiguities with Internal Definitions"

   (code
    (let-syntax ((foo (syntax-rules ()
			((foo ?x) (define ?x 'outer)))))
      (let ()
	(foo a)
	(define-syntax foo
	  (syntax-rules ()
	    ((foo ?x) (define ?x 'inner))))
	a))
    => outer))

  (slide/title/center
   "Ambiguities with Internal Definitions"

   (code
    (let ((x 10))
      (let-syntax ((foo (syntax-rules (x)
			  ((foo x d)
			   (define d 'outer))
			  ((foo n d)
			   'inner))))
	(let ()
	  (foo x y)			; <---
	  (define z (foo x y))		; <---

	  (define x 5)

	  (list y z))))))

  (slide/title/center
   "Chez Macro Expansion Algorithm"

   (page-para
    "Chez Scheme processes body forms from left to right and adds macro"
    "definitions to the compile-time environment as it proceeds.  [...]"
    "define rhs expressions are expanded, along with the body expressions"
    "that follow the definitions, only after the set of definitions is"
    "determined."))

  (slide/title/center
   "Local Import vs. Hygiene"
   (vl-append
   (code
    (module m (foo bar)
      (define foo 'm)))
   (blank 40)
   (code
    (define-syntax baz
      (syntax-rules ()
	((baz) (import m)))))
   (blank 40)
   (code
    (let ((foo 'bar))
      (baz)
      foo) => m)
   )
   )

  (slide/title/center
   "\"Implicit\" Exports"
   (code
    (define-syntax foo
      (syntax-rules ()
	((foo) a)))
    (define a 5)
    ...
    (code:comment "export foo"))
   )

  (slide/title/center
   "\"Implicit\" Exports"
   (code
    (define-syntax foo
      (syntax-rules ()
	((foo ?x) (?x a))))
    (define a 5)
    ...
    (code:comment "export foo")
    ... (foo quote) ...)
   )


  (slide/title/center
   "Phase Separation"
   (code
    (module syntax-helpers mzscheme
      (provide syntax2list)
      (define syntax2list
	(lambda (x)
	  (syntax-case x ()
	    [() '()]
	    [(a . d) (cons #'a (syntax2list #'d))])))))
   
   (code
    (module m mzscheme
      (require-for-syntax syntax-helpers)
      (define-syntax foo
	(lambda (x)
	  (syntax-case x ()
	    ((_)
	     ... (syntax2list ...) ...))))))
   )

  (slide/title/center
   "Export Annotation"
   (subtitle "Scheme 48:")

   (code
    (define-interface foo-interface
      (export v
	      (m :syntax)
	      (write-string
	       (proc (:string
		      &opt :value
		           :exact-integer :exact-integer)
		     :unspecific)))))
    
   )

  (slide/title/center
   "Modules vs. Files"
   
   (my-page-item "Is it possible to define more than one module in a single file?")
   (my-page-item "Is it possible to define a module in a single file?")
   (my-page-item "Is it possible to have an import refer to different modules depending on context?")
   (my-page-item "Does the association between module identifiers (in whatever format) and modules always happen as an implicit part of module definition, or is it specified separately?"))

  (slide/title/center
   "What's an Import?"
   (subtitle "Bigloo")
   (code
    (import m))
   
   (subtitle "Chez Scheme")
   (code
    (import m))
   
   (subtitle "MzScheme")
   (code
    (require (lib "m.ss" "libmike")))
   
   (subtitle "Scheme 48")
   (code
    (open m))
   )

  (slide/title/center
   "The Missing Link"
   
   (my-page-item "imports are of interfaces, not modules")
   (my-page-item "linking is implicit, like C")
   (my-page-item "explicit links only needed for conflicts")
   )


  (slide/title/center
   "Separate vs. Independent Compilation"
   (code
    (define-structure foo (export (m :syntax))
      (define-syntax m
	(syntax-rules ()
	  ((m) 1)))))
   )
  
  (slide/title/center
   "Exported Macros as Part of the Interface"
   (code
    (define-interface promises-interface
      (export force
	      (define-syntax delay
		(syntax-rules ()
		  ((delay ?exp)
		   (make-promise
		    (lambda () ?exp))))))))

   (code
    (define-module promises promises-interface
      ...
      (begin
	(define make-promise ...)
	(define force ...))))
  )


  (slide/title/center
   "Miscellaneous Issues"
   (my-page-item "interactive toplevel")
   (my-page-item (code eval))
   (my-page-item "tying module names to file names")
   (my-page-item "small executables")
   (my-page-item "optional initialization")
   (my-page-item "initialization order")
   )


  )
