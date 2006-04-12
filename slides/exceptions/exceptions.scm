(module exceptions (lib "run.ss" "slideshow")

  ;;(require (lib "face.ss" "texpict"))
  (require (lib "symbol.ss" "texpict"))
  (require (lib "step.ss" "slideshow"))
  (require (lib "code.ss" "slideshow"))
  
  (slide/name/center
   "Why (car '()) is not an exception"
   (titlet "Why (car '()) Is Not An Exception")
   (blank)
   (colorize (page-para* (t "Or:") (it "This") "Exception System Is Not" (it "That") "Exception System")
             "magenta")
   (t "Mike Sperber")
   (colorize (t "DeinProgramm") blue))

  (define (scale-to-fit pict max-width max-height)
    (let ((scale-x (/ max-width (pict-width pict)))
          (scale-y (/ max-height (pict-height pict))))
      (if (> scale-x scale-y)
          (scale pict scale-y)
          (scale pict scale-x))))
  
  (slide/title/center
   "Getting Back to A Known Place"
   (scale-to-fit
    (size-in-pixels (bitmap "unterm-schwanz.jpg"))
    client-w client-h))

  (with-steps
   (plain exception bug asynch extension)
   (slide/title/center
    "What's an Exception?"
    (page-item "file not found" (if (after? exception) (colorize (t "(exceptional situation)") "red") ""))
    (page-item "division by 0" (if (after? bug) (colorize (t "(bug)") "red") ""))
    (page-item (code (car '())) (if (after? bug) (colorize (t "(bug)") "red") ""))
    (page-item "timer interrupt" (if (after? asynch) (colorize (t "(asynchronous event)") "red") ""))
    (page-item "mixed-mode arithmetic"
               (if (after? extension) (colorize (t "(request for implementation extension)") "red") ""))))

  
  (slide/title/center
   "Possible Reactions"
    (page-item "ostrich approach")
    (page-item "abort program")
    (page-item "start debugger")
    (page-item "return to some earlier continuation")
    (page-item "fix, then continue")
    (page-item "..."))
  
  (slide/title/center
   "Possible Requirements"
   (page-item "resumption possible")
   (page-item "resumption fast")
   (page-item "handling fast")
   (page-item "problem description rich")
   (page-item "..."))
  
  (slide/title/center
   "The Right Tool for the Job"
   (scale-to-fit
    (hc-append (size-in-pixels (bitmap "leatherman.jpg"))
               (blank 30)
               (t "or")
               (blank 30)
               (scale (size-in-pixels (bitmap "scalpel.jpg")) 0.5)
               (blank 20)
               (t "?"))
    client-w client-h))

  (slide/title/center
   "Exceptions for Programs"
   
   (page-item "purpose: communication between programs")
   (page-item "handlers are installed" (colorize (it "often") "blue"))
   (page-item "handlers are" (colorize (it "bound") "blue") ", not set")
   (page-item "exceptions are" (colorize (it "rare") "blue"))
   (page-item "resumption is" (colorize (it "unusual") "blue"))
   (page-item "descriptions are" (colorize (it "rich") "blue")))

  (slide/title/center
   "Bugs"
   (page-item "purpose: test suites, graceful program abortion")
   (page-item "handlers are installed" (colorize (it "rarely") "blue"))
   (page-item "handlers are" (colorize (it "set") "blue") ", not bound")
   (page-item "exceptions are" (colorize (it "rare") "blue"))
   (page-item "resumption is" (colorize (it "very rare") "blue"))
   (page-item "descriptions are" (colorize (it "rich") "blue")))

  (slide/title/center
   "Asynchronous Events"
   (page-item "purpose: notice and synchronize to external events")
   (page-item "handlers are installed" (colorize (it "rarely") "blue"))
   (page-item "handlers are" (colorize (it "set") "blue") ", not bound")
   (page-item "exceptions occur" (colorize (it "very often") "blue"))
   (page-item "resumption is" (colorize (it "frequent") "blue"))
   (page-item "descriptions are" (colorize (it "few") "blue")))

  (slide/title/center
   "Requests for System Extension"
   (page-item "purpose: modular system extension")
   (page-item "handlers are installed" (colorize (it "rarely") "blue"))
   (page-item "handlers are" (colorize (it "set") "blue") ", not bound")
   (page-item "exceptions occur" (colorize (it "frequently") "blue"))
   (page-item "resumption is" (colorize (it "frequent") "blue"))
   (page-item "descriptions are" (colorize (it "from a finite set") "blue")))

  (define (verbatim . lines)
    (apply vl-append
           (map tt lines)))
  
  (slide/title/center
   "SRFI 35: Conditions"
   (t "(with Richard Kelsey)")
   
   (page-para
    (verbatim "(define-condition-type &i/o-filename-error"
              "                       &i/o-error"
              "  i/o-filename-error?"
              "  (filename i/o-error-filename))"))
   (blank)
   (page-para
    (verbatim "(define c1"
              "  (condition"
              "    (&i/o-filename-error"
              "      (filename \"/bermuda/triangle/r6rs.txt\"))))"))
   (blank)
   (page-para
    (tt "(i/o-filename-error? c1)") (colorize sym:implies "green") (tt "#t"))
   (page-para
    (tt "(i/o-error-filename c1)") (colorize sym:implies "green")  (tt "\"/bermuda/triangle/r6rs.txt\"")))

  (slide/title/center
   "Subtyping between Condition Types"
   (page-para
    (verbatim "(define-condition-type &i/o-error &error"
              "  i/o-error?)"))
   (blank)
   (page-para
    (verbatim "(define-condition-type &error &serious"
              "  error?)"))
   (blank)
   (page-para
    (verbatim "(define-condition-type &serious &condition"
              "  serious-condition?)")))
  
  (slide/title/center
   "Multiple Conditions at Once"

   (page-para "Networking error while accesing NFS file:")
   (blank)

   (page-para
    (vl-append (tt "(define c2")
               (hbl-append
                (tt "  (condition (&i/o-read-error (port ") (colorize (t "p") "blue") (tt "))"))
               (hbl-append
                (tt "             (&network-read-error (socket ") (colorize (t "s") "blue") (t "))))"))))
  
   (blank)
   (page-para
    (tt "(i/o-read-error? c2)") (colorize sym:implies "green") (tt "#t"))
   (page-para
    (tt "(network-read-error? c2)") (colorize sym:implies "green") (tt "#t"))
   (page-para
    (tt "(i/o-error-port c2)") (colorize sym:implies "green") (colorize (t "p") "blue"))
   (page-para
    (tt "(network-error-socket c2)") (colorize sym:implies "green") (colorize (t "p") "blue")))

  (slide/title/center
   "More Condition Types"
   (verbatim"(define-condition-type &message &condition"
            "  message-condition?"
            "  (message condition-message))"
            " "
            "(define-condition-type &i/o-no-such-file-error"
            "                       &i/o-filename-error"
            "  i/o-no-such-file-error?)"))

  (slide/title/center
   "SRFI 34: Exception Handling for Programs"
   
   (t "(mit Richard Kelsey)")
   (blank)
 
   (verbatim
    "(call-with-current-continuation"
    " (lambda (k)"
    "   (with-exception-handler (lambda (x)"
    "                             (display \"condition: \")"
    "                             (write x)"
    "                             (newline)"
    "                             (k 'hot))"
    "     (lambda ()"
    "       (+ 1 (raise 'hell))))))")
   (page-para
    (colorize (tt "condition: hell") "green"))
   (page-para
    (colorize sym:implies "green") (tt "hot")))

  (slide/title/center
   "Raise + Continuations"
   (verbatim "(with-exception-handler"
             "      (lambda (x)"
             "        (display \"Houston, we have a problem\")"
             "        (newline)"
             "        'dont-care)"
             "  (lambda ()"
             "    (+ 1 (raise 'problem))))))")
   (page-para
    (colorize (t "Houston, we have a problem") "green"))
   (page-para
    (colorize sym:implies "green") (it "unspecified")))


  (slide/title/center
   "Common Case: No Resumption"
   (verbatim "(guard (condition"
             "         ((eq? 'heaven condition)"
             "          'sunny)"
             "         ((eq? 'hell condition)"
             "          'hot))"
             " (raise 'hell))")
   (page-para
    (colorize sym:implies "green") (it "hot")))

  
  (slide/title/center
   "Context Issues"

   (verbatim
    "(call-with-current-continuation"
    " (lambda (k)"
    "   (with-exception-handler (lambda (x)"
    "                             (display \"reraised \")"
    "                             (write x) (newline)"
    "                             (k 'neutral))"
    "     (lambda ()"
    "       (guard (condition ((eq? 'heaven condition)"
    "                           'sunny)"
    "                         ((eq? 'hell condition)"
    "                           'hot))"
    "        (raise 'purgatory))))))")
   (page-para
    (colorize (t "reraised purgatory") "green"))
   (page-para
    (colorize sym:implies "green") (it "neutral")))

  (slide/title/center
   "Everyday Use"
   (verbatim "(guard (condition"
             "        ((i/o-filename-error? condition)"
             "         (display \"I/O error opening file \")"
             "         (display (i/o-error-filename condition))"
             "         ...)"
             "        ((i/o-error? condition)"
             "         (display \"I/O error\")"
             "         ...))"
             "  (read-file \"/bermuda/triangle/r6rs.txt\"))"))
  
  (slide/title/center
   "Ingredients"
   (page-item "current exception handler")
   (page-item "dynamic context")
   (page-item "no control flow for the primitives")
   (page-item (code guard) "for the common case: dispatch + unwinding"))
  
  (slide/title/center
   "Conclusions"
   (page-item "no single exception system is good for everyone")
   (page-item (colorize (bit "design for a specific problem") "red"))
   (page-item (colorize (bit "abstract when you're finished") "red"))
   (page-item (colorize (bit "... or not.") "red")))
              
  
  ;; (start-at-recent-slide)
 
)