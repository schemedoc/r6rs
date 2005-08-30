(define (list-intersperse src-l elem)
  (if (null? src-l) src-l
    (let loop ((l (cdr src-l)) (dest (cons (car src-l) '())))
      (if (null? l) (reverse dest)
        (loop (cdr l) (cons (car l) (cons elem dest)))))))

(define (generate-HTML content)
  (let*
      ;; Universal transformation rules. Work for every HTML,
      ;; present and future
      ((nl (string #\newline))
       (universal-conversion-rules
	`((@
	   ((*default*			; local override for attributes
	     . ,(lambda (attr-key . value) ((enattr attr-key) value))))
	   . ,(lambda (trigger . value) (list '@ value)))
	  (*default* . ,(lambda (tag . elems) (apply (entag tag) elems)))
	  (*text* . ,(lambda (trigger str) 
		       (if (string? str) (string->goodHTML str) str)))
	  (n_				; a non-breaking space
	   . ,(lambda (tag . elems)
		(list "&nbsp;" elems)))))


       ;; Do the identical transformation for an alist
       (alist-conv-rules
	`((*default* . ,(lambda (tag . elems) (cons tag elems)))
	  (*text* . ,(lambda (trigger str) str)))))

    (SRV:send-reply
     (post-order
      content
      `(
	,@universal-conversion-rules
	
	(html:begin 
	 . ,(lambda (tag . elems)
	      (list
	       "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\""
	       "\"http://www.w3.org/TR/REC-html40/loose.dtd\">" nl
	       "<html>" nl
	       elems
	       "</html>" nl)))

	(srfi
	 . ,(lambda (tag . elems)
	      (list
	       "<body>" nl
	       elems
	       "<H1>Copyright</H1>" nl
	       "Copyright (C) Will Clinger, R. Kent Dybvig, Michael Sperber, Anton van Straaten (2005). All Rights Reserved. " nl
	       "<p>" nl
"Permission is hereby granted, free of charge, to any person obtaining a" nl
"copy of this software and associated documentation files (the \"Software\")," nl
"to deal in the Software without restriction, including without limitation" nl
"the rights to use, copy, modify, merge, publish, distribute, sublicense," nl
"and/or sell copies of the Software, and to permit persons to whom the" nl
"Software is furnished to do so, subject to the following conditions:" nl
"<p>" nl
"The above copyright notice and this permission notice shall be included in" nl
"all copies or substantial portions of the Software." nl
"<p>" nl
"THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR" nl
"IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY," nl
"FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL" nl
"THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER" nl
"LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING" nl
"FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER" nl
"DEALINGS IN THE SOFTWARE." nl
"" nl
	       "    <hr>" nl
	       "    <address>Editor: <a href=\"mailto:srfi-editors@srfi.schemers.org\">David Van Horn</a></address>" nl
	       "</body>")))

	(srfi-head
	 . ,(lambda (tag title)
	      (list "<head>" nl
		    "<title>"
		    title
		    "</title>" nl
		    "</head>" nl nl)))

	(srfi-title
	 . ,(lambda (tag title)
	      (list "<H1>Title</H1>" nl nl
		    title
		    nl nl)))

	(srfi-authors
	 . ,(lambda (tag authors)
	      (list "<H1>Authors</H1>" nl nl
		    authors nl nl)))

	(srfi-author
	 . ,(lambda (tag authors)
	      (list "<H1>Author</H1>" nl nl
		    authors nl nl)))

	(body
	 . ,(lambda (tag . elems)
	      (list "<body>" nl elems "</body>")))

	(verbatim			; set off pieces of code: one or several lines
	 . ,(lambda (tag . lines)
	      (list "<pre>"
		    (map (lambda (line) (list line nl))
			 lines)
		    "</pre>")))

	(dfn
	 . ,(lambda (tag . stuff)
	      (list "<i>" stuff "</i>")))

	(URL 
	 . ,(lambda (tag url)
	      (list "<br>&lt;<a href=\"" url "\">" url "</a>&gt;")))

	(_nbsp
	 . ,(lambda (tag)
	      (list "&nbsp;")))

	(meta
	 . ,(lambda (tag . term)
	      `("&lt;" ,@term "&gt;")))
	(prototype
	 . ,(lambda (tag name . args)
	      (if (null? args)
		  `("<code>(" ,name ")</code>")
		  `("<code>(" ,name " </code>"
		    ,@(list-intersperse args " ")
		    "<code>)</code>"))))

	(comment
	 . ,(lambda (tag . args)
	      '()))

	;; Grammatical terms
	(nonterm			; Non-terminal of a grammar
	 . ,(lambda (tag term)
	      (list "&lt;" term "&gt;")))

	(term-id			; terminal that is a Scheme id
	 . ,(lambda (tag term)
	      (list term )))

	(term-str			; terminal that is a Scheme string
	 . ,(lambda (tag term)
	      (list "\"" term "\"")))

	(term-lit			; a literal Scheme symbol
	 . ,(lambda (tag term)
	      (list "<em>" term "</em>")))

	(ebnf-opt			; An optional term
	 . ,(lambda (tag term)
	      (list term "?")))

	(ebnf-*				; Zero or more repetitions
	 . ,(lambda (tag term)
	      (list term "*")))

	(ebnf-+				; One or more repetitions
	 . ,(lambda (tag term)
	      (list term "+")))

	(ebnf-choice			; Choice of terms
	 . ,(lambda (tag . terms)
	      (list-intersperse terms " | ")))
	)))))
