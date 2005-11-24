; PLT-specific part of the implementation of DEFINE-TYPE for Records SRFI

; Copyright (C) Michael Sperber (2005). All Rights Reserved. 
; 
; Permission is hereby granted, free of charge, to any person
; obtaining a copy of this software and associated documentation files
; (the "Software"), to deal in the Software without restriction,
; including without limitation the rights to use, copy, modify, merge,
; publish, distribute, sublicense, and/or sell copies of the Software,
; and to permit persons to whom the Software is furnished to do so,
; subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

(define-syntax define-type-2
  (lambda (form)
    (syntax-case form ()
      ((_ ?record-name (?record-name-2 ?constructor-name ?predicate-name)
       ?formals
       (?simple-clause ...))

       (syntax
	(begin
	  (define-type/explicit (?record-name ?constructor-name ?predicate-name)
	    ?formals
	    ?simple-clause ...))))

      ((_ ?record-name ?record-name-2
       ?formals
       (?simple-clause ...))

       (with-syntax ((?constructor-name
		      (datum->syntax-object (syntax ?record-name)
					    (string->symbol
					     (string-append "make-"
							    (symbol->string
							     (syntax-object->datum
							      (syntax ?record-name)))))))
		     (?predicate-name
		      (datum->syntax-object (syntax ?record-name)
					    (string->symbol
					     (string-append (symbol->string
							     (syntax-object->datum
							      (syntax ?record-name)))
							    "?")))))
		     
					    
       (syntax
	(define-type-2 ?record-name (?record-name ?constructor-name ?predicate-name)
	  ?formals
	  (?simple-clause ...))))))))

(define-syntax process-fields-clause
  (lambda (form)
    (syntax-case form (fields mutable immutable)
      ((_ (fields ?field-clause ...)
	  ?record-name ?record-name-spec
	  ?formals
	  ?bindings* ?binding-clauses
	  (?simple-clause ...)
	  ?clause ...)

       (let ((record-name (symbol->string (syntax-object->datum (syntax ?record-name)))))
	 (with-syntax
	     (((?simple-field ...)
	       (map (lambda (clause)
		      (syntax-case clause (mutable immutable)
			((?field-name immutable ?init ...)
			 (with-syntax ((?accessor-name
					(datum->syntax-object
					 (syntax ?field-name)
					 (string->symbol
					  (string-append record-name "-"
							 (symbol->string
							  (syntax-object->datum
							   (syntax ?field-name))))))))
			   (syntax
			    (?field-name (?accessor-name) ?init ...))))
			((?field-name mutable ?init ...)
			 (with-syntax ((?accessor-name
					(datum->syntax-object
					 (syntax ?field-name)
					 (string->symbol
					  (string-append record-name "-"
							 (symbol->string
							  (syntax-object->datum
							   (syntax ?field-name)))))))
				       (?mutator-name
					(datum->syntax-object
					 (syntax ?field-name)
					 (string->symbol
					  (string-append record-name "-"
							 (symbol->string
							  (syntax-object->datum
							   (syntax ?field-name)))
							 "-set!")))))
			   (syntax
			    ( ?field-name (?accessor-name ?mutator-name) ?init ...))))
			(?clause
			 clause)))
		    (syntax->list (syntax (?field-clause ...))))))
	   (syntax
	    (define-type-1 
	      ?record-name ?record-name-spec
	      ?formals
	      ?bindings*
	      ((fields ?simple-field ...) . ?binding-clauses)
	      (?simple-clause ...)
	      ?clause ...))))))))
