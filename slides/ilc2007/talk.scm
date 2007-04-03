(module talk (lib "slideshow.ss" "slideshow")

  (require (lib "etc.ss"))
  
  (require (lib "step.ss" "slideshow"))
  (require (lib "face.ss" "texpict"))
  (require (lib "symbol.ss" "texpict"))
  (require (lib "code.ss" "slideshow"))

  (define (verbatim . lines)
    (apply vl-append
           (map tt lines)))
  
  (define my-bullet (colorize (baseless
                               (cc-superimpose (disk (/ gap-size 2)) 
                                               (blank 0 gap-size)))
                              "blue"))
  
  (define (my-page-item . stuff)
    (apply page-item/bullet my-bullet stuff))

  (define (frame-pict size pict)
    (frame (inset pict size)))
  
  (define (middle c1 c2)
    (+ c1 (/ (- c2 c1) 2)))
  
  (define (place-over-at-ref main x y sub find-ref)
    (let* ((mark (blank))
           (marked (place-over main x y mark)))
      (let-values (((mx my) (find-cc marked mark))
                   ((lx ly) (find-ref sub sub)))
        (place-over marked
                    (- mx lx)
                    (- (- (pict-height marked) my)
                       (- (pict-height sub) ly))
                    sub))))
  
  (define (attach-label pict find-ref-pict label find-ref-label)
    (let-values (((px py) (find-ref-pict pict pict)))
      (place-over-at-ref pict px py
                         label find-ref-label)))
    
  
  (define (draw-from-to draw-line main from find-from to find-to label find-label-ref)
    (let-values (((ax ay) (find-from main from))
		 ((bx by) (find-to main to)))
      (let ((middle-x (middle ax bx))
	    (middle-y (- (pict-height main) (middle ay by)))
	    (mark (blank)))
	(let* ((basic
		(place-over
		 main ax (- (pict-height main) ay)
		 (draw-line (- bx ax) (- by ay))))
	       (with-label
		(if label
		    (place-over-at-ref basic 
				       middle-x middle-y
				       label find-label-ref)
		    basic)))
	  with-label))))

  (define arrow-from-to
    (opt-lambda (main from find-from to find-to (label #f) (find-label-ref find-rc))
      (draw-from-to (lambda (dx dy)
                      (arrow-line dx dy 6))
                    main from find-from to find-to
                    label find-label-ref)))
  
  (define (line dx dy)
    (picture 0 0
             `((connect 0 0 ,dx ,dy))))

  (define line-from-to
    (opt-lambda (main from find-from to find-to (label #f) (find-label-ref find-rc))
      (draw-from-to line
                    main from find-from to find-to
                    label find-label-ref)))

  (define (scale-to-fit pict max-width max-height)
    (let ((scale-x (/ max-width (pict-width pict)))
          (scale-y (/ max-height (pict-height pict))))
      (if (> scale-x scale-y)
          (scale pict scale-y)
          (scale pict scale-x))))

  (define (scream text)
    (colorize (it text) "red"))

  (define (subheading t)
    (vc-append (colorize (bt t) "blue")
	       (blank (* 0.7 gap-size))))

  (define (break) (blank gap-size))

  (slide/name/center
   "Blank"

   (page-para "This slide intentionally left blank."))

  (slide/name/center
   "Title"

   (titlet "How to Win Friends")
   (titlet "and Influence People")

   (t "Mike Sperber")
   (blank)
   (t "R6RS Editors:")
   (colorize
    (vc-append
     (t "Will Clinger, Kent Dybvig")
     (t "Matthew Flatt, Anton van Straaten"))
    "blue"))

  (slide/name/center
   "R6RS Process"

   (let ((r6rs-process (scale (t "R6RS Process") 2.0)))

     (cc-superimpose
      (scale-to-fit
       (bitmap "pic_pattern-struggle.jpg")
       client-w client-h)
      (colorize
       (filled-rounded-rectangle (+ 20 (pict-width r6rs-process))
				 (+ 20 (pict-height r6rs-process)))
       "white")
      r6rs-process
      
      (vc-append
       (hc-append
	(scale-to-fit (bitmap "bergbau.jpg") 200 200)
	(blank 50)
	(scale-to-fit (bitmap "contortion.jpg") 200 200)
	(blank 50)
	(scale-to-fit (bitmap "index_pain.gif") 200 200))
       (blank (+ 100 (pict-height r6rs-process)))
       (hc-append
	(scale-to-fit (bitmap "struggle.jpg") 200 200)
	(blank 200)
	(scale-to-fit (bitmap "sumo.jpg") 200 200)))
    ))
   )
 
  (slide/title/center
   "Disclaimer"

   (page-para
    "I am speaking this as an individual member of the Scheme"
    "community.")
   
   (page-para
    "I am not speaking for the R6RS editors, and"
    "nothing in this talk should be confused with the editors'"
    "official position."))

  (slide/title/center
   "R6RS Programs"

   (code
    #,(tt "#!r6rs")
    (import (r6rs base)
	    (r6rs i/o ports))
    (put-bytes (standard-output-port)
	       (call-with-port
		(open-file-input-port
                 (cadr (command-line)))
		get-bytes-all))))

  (slide/title/center
   "R6RS Libraries"
   (code
    (library (ilc points)
      (export make-point point?
	      point-x point-y
	      move-point!)
      (import (r6rs base)
	      (r6rs records syntactic))
      code:blank
      (define-record-type (point make-point point?)
	(fields 
	 (mutable x point-x set-point-x!)
	 (mutable y point-y set-point-y!)))
      code:blank
      (define (move-point! p xd yd)
	(set-point-x! p (+ (point-x p) xd))
	(set-point-y! p (+ (point-y p) yd))))))

  (define (time-item year . items)
    (apply page-item/bullet
	   (colorize (t (number->string year)) "green")
	   items))

  (slide/title/center
   "History"
   (time-item 1992 "PARC meeting")
   (time-item 1998 "R5RS")
   (time-item 1998 "ICFP '98 Scheme Workshop")
   (time-item 1998
	      (scale-to-fit (bitmap "srfi.png") client-w (pict-width (t "SRFI")))
	      " process launch") 
   (time-item 2002 "strategy committee")
   (time-item 2003 "Scheme standardization charter")
   (time-item 2004 "R6RS committee")
   (time-item 2006 "R5.91RS, public review" (tt "@r6rs.org"))
   (time-item 2007 "R6RS (hopefully)"))

  (slide/title/center
   "Two Reports"

   (scale-to-fit (bitmap "report.jpg") client-w (* 0.3 client-h))
   (blank)
   (scale-to-fit (bitmap "lib-report.jpg") client-w (* 0.3 client-h))

   (blank)
   
   (t "later: non-normative appendices, rationale"))

  (slide/title/center
   "New Goals"

   (my-page-item "substantial portable programs")
   (my-page-item "hygiene-breaking macros")
   (my-page-item "new unique data types")
   (my-page-item "type safety")
   (my-page-item "efficient code"))

  (slide/title/center
   "R6RS Highlights"
   
   (my-page-item "libraries")
   (my-page-item "programs")
   (my-page-item "full numerical tower")
   (my-page-item "Unicode text")
   (my-page-item "exception system")
   (my-page-item "serious I/O")
   (my-page-item "bytevectors")
   (my-page-item "hash tables")
   (my-page-item (code syntax-case) "macros")
   (my-page-item "executable operational semantics")
   (my-page-item (colorize (t "more") "red"))) 

  (slide/title/center
   "R6RS Libraries Aren't Layered"

   (scale-to-fit (bitmap "layering.jpg") client-w (* 0.8 client-h)))

  (define (library-box name)
    (let ((name-p (inset (colorize (scale (tt name) 0.8) "blue") 7)))
      (cc-superimpose
       (file-icon (pict-width name-p) (pict-height name-p) #t #t)
       name-p)))

  (define r6rs-base (library-box "(r6rs base)"))
  (define r6rs-records-syntactic (library-box "(r6rs records syntactic)"))
  (define r6rs-i/o-ports (library-box "(r6rs i/o ports)"))
  (define r6rs-hashtables (library-box "(r6rs hashtables)"))
  (define r6rs-r5rs (library-box "(r6rs r5rs)"))
  (define r6rs-mutable-pairs (library-box "(r6rs mutable-pairs)"))
  (define r6rs-mutable-strings (library-box "(r6rs mutable-strings)"))
  (define r6rs-eval (library-box "(r6rs eval)"))
  (define r6rs-syntax-case (library-box "(r6rs syntax-case)"))


  (slide/title/center
   "Libraries Organized According to Usage"

   (let ((my-library (library-box "(my library)"))
	 (your-library (library-box "(your library)"))
	 (lisas-library (library-box "(lisas library)"))
	 (freds-library (library-box "(freds library)")))

     (define (from-to pict from to)
       (pin-arrow-line gap-size pict
		       from ct-find 
		       to cb-find
		       1 "green"))      

     (let* ((p
	     (vc-append
	      (hc-append r6rs-base
			 (blank 50)
			 (vc-append
			  (hc-append r6rs-records-syntactic
				     (blank 10)
				     r6rs-i/o-ports)
			  (blank 30)
			  (hc-append r6rs-hashtables
				     (blank 10)
				     r6rs-r5rs)
			  (blank 30)
			  (tt "...")))
	      (blank 150)
	      (hc-append my-library
			 (blank 30)
			 your-library
			 (blank 30)
			 lisas-library
			 (blank 30)
			 freds-library)))
	    (p (from-to p my-library r6rs-base))
	    (p (from-to p your-library r6rs-base))
	    (p (from-to p lisas-library r6rs-base))
	    (p (from-to p freds-library r6rs-base))

	    (p (from-to p my-library r6rs-records-syntactic))
	    (p (from-to p my-library r6rs-i/o-ports))

	    (p (from-to p your-library r6rs-hashtables))
	    (p (from-to p lisas-library r6rs-r5rs))
	    (p (from-to p freds-library r6rs-i/o-ports))
	    (p (from-to p freds-library r6rs-hashtables)))
       
       p))
	    
   )
  
  (slide/title/center
   "Composite Library"
   
   (tt "(r6rs)")

   (let ((p
	  (inset (vc-append
		  r6rs-base
		  (blank 30)
		  (hc-append r6rs-records-syntactic
			     (blank 10)
			     r6rs-i/o-ports)
		  (blank 30)
		  (hc-append r6rs-hashtables
			     (blank 10)
			     r6rs-syntax-case)
		  (blank 30)
		  (tt "..."))
		 70 110)))
     (cc-superimpose
      (cloud (pict-width p) (pict-height p))
      p))

   (blank)

   (hc-append (t "orphaned:")
	      (blank 20)
	      (scale r6rs-mutable-pairs 0.7)
	      (blank 20)
	      (scale r6rs-mutable-strings 0.7)
	      (blank 20)
	      (scale r6rs-eval 0.7)
	      (blank 20)
	      (scale r6rs-r5rs 0.7))
	      
   )

  (define (pic-cloud pic color)
    (cc-superimpose
     (cloud (* (pict-width pic) 1.3)
	    (* (pict-width pic) 1.8)
	    color)
     pic))

  (slide/title/center
   "Showcases"

   (my-page-item "Portability")
   (my-page-item "Records")
   (my-page-item "Libraries")
   (my-page-item "Unicode"))

  (slide/title/center
   "Aspects of Portability"
   
   (my-page-item "more standard stuff")
   (my-page-item "sufficiently powerful library system")
   (my-page-item "\"implicit\" extensions discouraged"))

  (slide/title/center
   "Portability"
   
   (hc-append
    (pic-cloud (t "portability") "LightBlue")
    (scale-to-fit (bitmap "spring.png")
		  (* 0.5 client-h) client-w)
    (pic-cloud
     (vc-append
      (vc-append
       (t "implementation")
       (t "strategies"))
      (blank 30)
      (t "readability")
      (blank 30)
      (t "extensibility"))
     "LightBlue")))

  (slide/title/center
   "What's the Value of a Side Effect?"

   (code 
    (let* ((x ...)
	   (dummy (display x))
	   (y ...))
      ...))

   (titlet "R5.92RS")

   (code
    (define (display thing)
      ...
      (unspecified)))
   
   (titlet "R5.93RS")
   
   (code
    (define (display thing)
      ...
      <unspecified>)))

  (slide/title/center
   "Unspecifiedness"

   (my-page-item "evaluation order in applications")
   (my-page-item (code letrec) "evaluation order")
   (my-page-item "return value(s) of side effects")
   (my-page-item (code ((lambda (x) ...) (values ... ...)))))

  (define (impl-cloud name color)
    (let ((name-p (inset (t name) 25)))
      (cc-superimpose
       (cloud (pict-width name-p)
	      (pict-height name-p)
	      color)
       name-p)))

  (slide/title/center
   "We Need One True Record Syntax!"
   
   (vc-append
    (hc-append
     (impl-cloud "PLT" "green")
     (blank 30)
     (lift (impl-cloud "Larceny" "DeepPink") 40)
     (blank 30)
     (impl-cloud "Gambit-C" "red"))
    (blank 50)
    (hc-append
     (impl-cloud "Scheme 48" "blue")
     (blank 30)
     (drop (impl-cloud "Chez" "Turquoise") 50)
     (blank 30)
     (lift (impl-cloud "Chicken" "DarkViolet") 60)
     (blank 30)
     (lift (impl-cloud "Bigloo" "LightBlue") 60))
    (blank 40)
    (t "..."))
   
   (blank)

   'next

   (scream "... forget about it."))

  (slide/name/center
   "Requirements"

   (titlet "Prior Art:")

   
   (my-page-item "Curtis proposal (Pavel Curtis, 1989/1991)")
   (my-page-item "SRFI 9 (Richard Kelsey) (1999)")

   (titlet "Wanted:")

   (my-page-item "single inheritance")
   (my-page-item "optional opacity")
   (my-page-item "sealedness")
   (my-page-item "ability to name everything")
   (my-page-item "custom, modular constructors"))

  (define (bound pict w h)
    (inset pict
	   (* 0.5 (- w (pict-width pict)))
	   (* 0.5 (- h (pict-height pict)))))

  (slide/title/center
   "Layering"

   (let ((in
	   (lambda (txt col)
	     (inset (colorize (t txt) col) 10))))
     (let ((procedural (in "procedural" "Medium Blue"))
	   (inspection (in "inspection" "Medium Blue"))
	   (syntactic (in "syntactic" "Medium Blue"))
	   (implicit (in "implicit-naming" "Black"))
	   (explicit (in "explicit-naming" "Black")))
       (let ((width
	      (apply max (map pict-width (list implicit explicit))))
	     (height (pict-height procedural)))

	 (define (bump p)
	   (bound p width height))

	 (vl-append
	  (ht-append (frame (bump procedural)) (blank 20) (frame (bump inspection)))
	  (blank 50)
	  (frame
	   (vc-append
	    syntactic
	    (blank 15)
	    explicit
	    (dash-hline width 1)
	    implicit))))))
   
   (blank)

   (code
    (define-record-type point (fields x y))))

  (slide/title/center
   "Layering"

   (code
    (define-record-type point (fields x y))
    code:blank
    (define-record-type point
      (fields
       (immutable x)
       (immutable y)))
    code:blank
    (define-record-type (point make-point point?)
      (fields 
       (immutable x point-x)
       (immutable y point-y)))))

  (slide/title/center
   "Layering"

   (code
    (define $point-rtd (make-record-type-descriptor ...))
    (define-syntax point ...)
    code:blank
    (define make-point (record-constructor  ...))
    code:blank
    (define point? (record-predicate $point-rtd))
    code:blank
    (define point-x (record-accessor $point-rtd 0))
    code:blank
    (define point-y (record-accessor $point-rtd 1))))

  
  (slide/title/center
   "\"Modules\""

   (titlet "Requirements:")

   (scale-to-fit (bitmap "blackboard.jpg") client-w (* 0.6 client-h))

   (t "(dramatized for illustratory purposes;")
   (t "not historically factual)"))

  (slide/title/center
   "Bigloo"
   (code
    (module m1
	(export foo bar))

    (define foo 23)
    (define bar 42)
    
    code:blank
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
      (define bar 42))
    code:blank
    (module m2 (baz)
      (import m1)
      (define baz (+ foo bar)))))

  (slide/title/center
   "MzScheme"
   (code
    (module m1 mzscheme
      (provide foo bar)
      (define foo 23)
      (define bar 42))
    code:blank
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
    (define-structure m1 (export foo bar)
      (open scheme)
      (begin
	(define foo 23)
	(define bar 42)))
    code:blank
    (define-structure m2 (export baz)
      (open scheme
	    m1)
      (begin
	(define baz (+ foo bar))))
    )
   )

  (define config-separator
    (picture 0 0 '((connect 0 0 200 0))))

  (define (subtitle heading)
    (vc-append
     (colorize (t heading) blue)
     (blank)))

  (slide/title/center
   "Separate Configuration Language"
   (subtitle "Bigloo")

   (code
    (module m1
	(export foo bar))

    (unsyntax config-separator)

    (define foo 23)
    (define bar 42)
   code:blank
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
      (define bar 42))
    code:blank
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
      (define bar 42))
   code:blank
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
    (define-structure m1 (export foo bar)
      (open scheme)
      (begin
	(unsyntax config-separator)
	(define foo 23)
	(define bar 42)))
    code:blank
    (define-structure m2 (export baz)
      (open scheme
	    m1)
      (begin
	(unsyntax config-separator)
	(define baz (+ foo bar))))
    )
   )


  (slide/title/center
   "Important Requirements"
   
   (my-page-item "export macros")
   (my-page-item "separate compilation")
   (colorize (my-page-item "share code with others")
	     "red")
   (my-page-item "namespace management")
   (my-page-item "explicit declaration of dependencies")
   )

  (slide/title/center
   "Libraries"
   (code
    (library (my-helpers id-stuff)
      (export find-dup)
      (import (r6rs))
      code:blank
      (define (find-dup l)
	(and (pair? l)
	     (let loop ((rest (cdr l)))
	       (cond
		[(null? rest) (find-dup (cdr l))]
		[(bound-identifier=? (car l) (car rest)) 
		 (car rest)]
		[else (loop (cdr rest))])))))))

  (slide/title/center
   "Libraries" 
   (code
    (library (my-helpers values-stuff)
      (export mvlet)
      (import (r6rs) (for (my-helpers id-stuff) expand))
      code:blank
      (define-syntax mvlet
	(lambda (stx)
	  (syntax-case stx ()
	    [(_ [(id ...) expr] body0 body ...)
	     (not (find-dup (syntax (id ...))))
	     (syntax
	      (call-with-values
		  (lambda () expr) 
		(lambda (id ...) body0 body ...)))]))))))

  (slide/title/center
   "Libraries"
   (code
    (library (let-div)
      (export let-div)
      (import (r6rs)
	      (my-helpers values-stuff)
	      (r6rs r5rs))
      code:blank
      (define (quotient+remainder n d)
	(let ([q (quotient n d)])
	  (values q (- n (* q d)))))
      code:blank
      (define-syntax let-div
	(syntax-rules ()
	  [(_ n d (q r) body0 body ...)
	   (mvlet [(q r) (quotient+remainder n d)]
	     body0 body ...)])))))

  (with-steps
   (start crossout)
   (slide/title/center
    "Unicode"
    
    (table 2
	   (list 
	    (cc-superimpose
	     (bitmap "ubesfig.gif")
	     (if (after? crossout)
		 (bitmap "ubesfig-crossout.gif")
		 (blank)))
	    (vl-append
	     (t "UTF-8")
	     (t "UTF-16be")
	     (t "UTF-16le")
	     (t "UTF-32be")
	     (t "UTF-32le")
	     (t "..."))
	    (colorize (t "semantics") "blue") (colorize (t "encoding") "blue"))
	   cc-superimpose ; h-center the columns
	   cc-superimpose ; v-center the rows
	   gap-size ; column gap
	   gap-size ; row gap
	   )))

  (slide/title/center
   "What's Ahead"
   
   (my-page-item "public review")
   (my-page-item "formal-comment responses (April 15)")
   (my-page-item "R5.93RS (> May 15)")
   (my-page-item "non-normative appendices & rationale")
   (my-page-item "ratification?")

   (blank)
   
   (colorize (scale (tt "http://www.r6rs.org/") 2.0)
	     "Medium Blue"))

  (slide/title/center
   "Conclusions"

   (my-page-item "many changes")
   (my-page-item "more portability")
   (my-page-item "much bigger")
   (my-page-item "wonderful community")
   (my-page-item "not possible with unanimous consent")
   
   (blank)

   (colorize (scale (bt "PLEASE RATIFY (OR NOT)!") 2.0)
	     "DarkGreen"))
		    
)


