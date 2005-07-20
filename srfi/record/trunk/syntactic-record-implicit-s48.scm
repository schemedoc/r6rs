; Scheme-48-specific part of the implementation of DEFINE-TYPE for Records SRFI

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
  (lambda (form rename compare)
    (let* ((name-spec (caddr form))
	   (constructor-name
	    (if (pair? name-spec)
		(cadr name-spec)
		(string->symbol (string-append "make-" (symbol->string name-spec)))))
	   (predicate-name
	    (if (pair? name-spec)
		(caddr name-spec)
		(string->symbol (string-append (symbol->string name-spec) "?")))))
      
      `(,(rename 'define-type/explicit) (,(cadr form) ,constructor-name ,predicate-name)
	,(list-ref form 3)		; formals
	,@(list-ref form 4)))))		; simple clauses


(define-syntax process-fields-clause
  (lambda (form rename compare)
    (let* ((record-name (symbol->string (caddr form)))
	   (simple-fields
	    (map (lambda (clause)
		   (let ((field-spec (car clause)))
		     (cond
		      ((compare (rename 'immutable) (car field-spec))
		       (if (= (length field-spec) 3)
			   clause
			   (list
			    (list (car field-spec) (cadr field-spec)
				  (string->symbol
				   (string-append record-name "-"
						  (symbol->string (cadr field-spec)))))
			    (cadr clause))))
		      ((compare (rename 'mutable) (car field-spec))
		       (if (= (length field-spec) 4)
			   clause
			   (list
			    (list (car field-spec) (cadr field-spec)
				  (string->symbol
				   (string-append record-name "-"
						  (symbol->string (cadr field-spec))))
				  (string->symbol
				   (string-append record-name "-"
						  (symbol->string (cadr field-spec))
						  "-set!")))
			    (cadr clause)))))))
		 (cdr (cadr form))))
	   (simple-fields-clause
	    (cons (caadr form) simple-fields)))
      `(,(rename 'define-type-1) ,(caddr form) ,(cadddr form)
	,(list-ref form 4)
	,(append (list-ref form 5) (list simple-fields-clause))
	,@(list-tail form 6)))))
