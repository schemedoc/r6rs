
;; A MzScheme "implementation" of RNRS `library' that's just good
;;  enough to run the code here.

(module rnrs-expand-time mzscheme
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
	       (list (quote-syntax require-for-syntax) 'rnrs-expand-time))
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
    [_else
     (list (string->symbol
	    (apply string-append
		   (map symbol->string
                        (let loop ([l (map syntax-e
                                           (syntax->list seq))])
                          (cond
                           [(null? l) null]
                           [(symbol? (car l)) (cons (car l) (loop (cdr l)))]
                           [else (loop (cdr l))]))))))]))

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

(library (rnrs)
  (export)
  (import)
  (require (lib "list.ss")
	   (all-except mzscheme
		       #%module-begin 
		       require provide))
  (define (find f l)
    (let ([v (memf f l)])
      (and v (car v))))
  (define (assertion-violation who msg . args)
    (apply error (if who
                     (format "~a: ~a" who msg)
                     msg)
           args))
  (provide (all-from mzscheme)
	   find
	   (rename andmap for-all)
	   (rename ormap exists)
	   assertion-violation
           (rename call-with-exception-handler with-exception-handler)))

(load "mzscheme/implementation/vector-types.sls")
 
; Alternate implementation of vector types that builds on
; SRFI-9 instead of MzScheme struct types:
;(load "mzscheme/implementation/srfi_9.sls")
;(load "generic/implementation/opaque-cells.sls")
;(load "generic/implementation/vector-types.sls")

(load "rnrs/records/private/core.sls")
(load "rnrs/records/procedural-6.sls")
(load "rnrs/records/inspection-6.sls")
(load "rnrs/records/private/explicit.sls")
(load "rnrs/records/syntactic-6.sls")
