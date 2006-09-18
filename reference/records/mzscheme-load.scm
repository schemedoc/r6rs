
;; A MzScheme "implementation" of R6RS `library' that's just good
;;  enough to run the code here.

(module r6rs-expand-time mzscheme
  (define-syntax (unwrapping-syntax stx)
    (syntax-case stx ()
      [(_ (e ....))
       (and (identifier? #'....)
	    (module-identifier=? #'.... (quote-syntax ...)))
       #'(syntax->list (syntax (e ....)))]
      [(_ e) #'(syntax e)]))
  (provide (all-from-except mzscheme
			    syntax-object->datum
			    datum->syntax-object
			    syntax)
	   (rename syntax-object->datum syntax->datum)
	   (rename datum->syntax-object datum->syntax)
	   (rename unwrapping-syntax syntax)))

(module mzscheme-core mzscheme
  (provide (rename core-module-begin #%module-begin)
	   require provide)
  
  (define-syntax core-module-begin
    (lambda (stx)
      (datum->syntax-object
       (quote-syntax here)
       (list* (quote-syntax #%plain-module-begin)
	      (datum->syntax-object
	       stx
	       (list (quote-syntax require-for-syntax) 'r6rs-expand-time))
	      (cdr (syntax-e stx)))
       stx))))

(define-for-syntax (collapse-name seq)
  (syntax-case seq (rename only add-prefix)
    [(rename seq (ext int) ...)
     (with-syntax ([(collapsed ...) (collapse-name #'seq)])
       (syntax->list #'((all-except collapsed ... ext ...)
			(rename collapsed ... int ext) ...)))]
    [(only seq name ...)
     (list #`(only #,@(collapse-name #'seq)
		   name ...))]
    [(add-prefix seq pfx)
     (list #`(prefix pfx #,@(collapse-name #'seq)))]
    [else
     (list (string->symbol
	    (apply string-append
		   (map symbol->string
			(map syntax-e
			     (syntax->list seq))))))]))

(define-syntax (library stx)
  (syntax-case stx (import export)
    [(_ (name ...)
	(export ex-spec ...)
	(import im-spec ...)
	body ...)
     ;; Using `eval' with quote strips lexical info and starts over
     #`(eval '(module #,@(collapse-name #'(name ...)) mzscheme-core
		(provide ex-spec ...)
		(require #,@(apply append
				   (map collapse-name (syntax->list #'(im-spec ...)))))
		body ...))]))

(define-syntax (import stx)
  (syntax-case stx ()
    [(_ im-spec ...)
     #`(eval '(require #,@(apply append
				 (map collapse-name (syntax->list #'(im-spec ...))))))]))

(library (r6rs)
  (export)
  (import)
  (require (lib "list.ss")
	   (all-except mzscheme
		       #%module-begin 
		       require provide))
  (define (find f l)
    (let ([v (memf f l)])
      (and v (car v))))
  (provide (all-from mzscheme)
	   find
	   (rename andmap forall)
	   (rename ormap exists)
	   (rename error contract-violation)))

(load "mzscheme-vector-types.scm")
 
; Alternate implementation of vector types that builds on
; SRFI-9 instead of MzScheme struct types:
;(load "mzscheme-srfi-9.scm")
;(load "generic-opaque-cells.scm")
;(load "generic-vector-types.scm")

(load "r6rs-records-private-core.scm")
(load "r6rs-records-procedural.scm")
(load "r6rs-records-inspection.scm")
(load "r6rs-records-explicit.scm")
(load "r6rs-records-implicit.scm")
