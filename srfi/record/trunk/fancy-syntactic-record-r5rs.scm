; Portable part of the implementation of DEFINE-RECORD-TYPE for Records SRFI

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

(define-syntax define-record-type
  (syntax-rules (fields parent nongenerative mutable immutable init!)
    ((define-record-type (?record-name ?constructor-name ?predicate-name)
       ?formals
       ?clause ...)
     (define-record-type-1 ?record-name (?record-name ?constructor-name ?predicate-name)
       ?formals
       ()
       values
       ?clause ...))
    ((define-record-type ?record-name
       ?formals
       ?clause ...)
     (define-record-type-1 ?record-name ?record-name
       ?formals
       ()
       values
       ?clause ...))))

(define-syntax define-record-type-1
  (syntax-rules (fields parent nongenerative mutable immutable init!)
    ;; find PARENT clause
    ((define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)
       ?init-proc
       (parent ?parent-name ?expr ...)
       ?clause ...)
     (define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ... (parent ?parent-name ?expr ...))
       ?init-proc
       ?clause ...))

    ;; find FIELDS clause
    ((define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)
       ?init-proc
       (fields ((?mutability ?field-name ?proc-names ...) ?init-expr) ...)
       ?clause ...)
     (process-fields-clause (fields ((?mutability ?field-name ?proc-names ...) ?init-expr) ...)
			    ?record-name ?record-name-spec
			    ?formals
			    (?simple-clause ...)
			    ?init-proc
			    ?clause ...))

    ;; find NONGENERATIVE clause
    ((define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)
       ?init-proc
       (nongenerative ?uid)
       ?clause ...)
     (define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ... (nongenerative ?uid))
       ?init-proc
       ?clause ...))

    ;; find INIT! clause
    ((define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)
       ?init-proc
       (init! (?param) ?expr1 ?expr ...)
       ?clause ...)
     (define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ... (nongenerative ?uid))
       (lambda (?param) ?expr1 ?expr ...)
       ?clause ...))

    ;; pass it on
    ((define-record-type-1 ?record-name ?record-name-spec
       ?formals
       (?simple-clause ...)
       ?init-proc)

     (define-record-type-2 ?record-name ?record-name-spec
       constructor-temp
       ?formals
       (?simple-clause ...)
       ?init-proc))))

(define-syntax define-constructor-with-init
  (syntax-rules ()
    ;; regular parameter list
    ((define-constructor-with-init ?constructor-name ?real-constructor-name
       (?formal ...)
       ?init-proc)
     (define (?constructor-name ?formal ...)
       (let ((r (?real-constructor-name ?formal ...)))
	 (?init-proc r)
	 r)))
    ;; with rest
    ((define-constructor-with-init ?constructor-name ?real-constructor-name
       (?formal1 . ?formals)
       ?init-proc)
     (define-constructor-with-init ?constructor-name ?real-constructor-name
       (?formal1)
       ?formals
       ?init-proc))
    ((define-constructor-with-init ?constructor-name ?real-constructor-name
      (?formal ...)
      (?formal1 . ?formals)
      ?init-proc)
     (define-constructor-with-init ?constructor-name ?real-constructor-name
       (?formal ... ?formal1)
      ?formals
      ?init-proc))
    ((define-constructor-with-init ?constructor-name ?real-constructor-name
       (?formal ...)
       ?formal-rest
       ?init-proc)
     (define (?constructor-name ?formal ... . ?formal-rest)
       (let ((r (apply ?real-constructor-name ?formal ... ?formal-rest)))
	 (?init-proc r)
	 r)))
    ;; rest only
    ((define-constructor-with-init ?constructor-name ?real-constructor-name
       ?formal
       ?init-proc)
     (define (?constructor-name . ?formal)
       (let ((r (apply ?real-constructor-name ?formal)))
	 (?init-proc r)
	 r)))))



