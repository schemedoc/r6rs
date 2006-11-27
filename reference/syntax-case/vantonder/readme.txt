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