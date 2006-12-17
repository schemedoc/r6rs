; Create an index for the tickets

(define (read-line port)
  (if (eof-object? (peek-char port))
      (peek-char port)
      (let loop ((revchars '()))
	(let ((thing (read-char port)))
	  (if (char=? #\newline thing)
	      (list->string (reverse revchars))
	      (loop (cons thing revchars)))))))

(define (ticket-filename n)
  (string-append "ticket-" (number->string n) ".txt"))

(define (ticket-title n)
  (call-with-input-file (ticket-filename n)
    (lambda (inport)
      (read-line inport) ; skip "Formal comment #"
      (let loop ()
	(let ((thing (read-line inport)))
	  (if (and (not (string=? "" thing))
		   (not (char-whitespace? (string-ref thing 0))))
	      thing
	      (loop)))))))

(define (display-comment-index ns not-yets)
  (display "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">") (newline)
  (display "<html>") (newline)
  (display "  <head>") (newline)
  (display "    <title>Formal Comments</title>") (newline)
  (display "    <link type='text/css' rel='stylesheet' href='/r6rs.css'>") (newline)
  (display "  </head>") (newline)
  (newline)
  (display "  <body>") (newline)
  (display "    <h1>Formal Comments</h1>") (newline)
  (newline)

  (display "<p style='width:7in;'>")
  (display "Formal comments which were submitted by November 15th are listed below. ")
  (display "Each comment is numbered for reference purposes. ")
  (display "Comments are linked to a text file containing the text of the comment, ")
  (display "followed by a \"RESPONSE:\" heading, followed by the editors' formal response.</p>")

  (display "    <menu>") (newline)
  (for-each (lambda (n)
	      (cond
		((memq n not-yets)
		 (display "      <li>")
		 (display "Comment #")
		 (display n)
		 (display ": ")
		 (display (ticket-title n))
		 (display " &mdash; response to follow</li>")
		 (newline))
		(else
		 (let ((filename (ticket-filename n)))
		 (display "      <li><a href=\"")
		 (display filename)
		 (display "\">Comment #")
		 (display n)
		 (display ": ")
		 (display (ticket-title n))
		 (display "</a></li>")
		 (newline)))))
	    ns)
  (display "    </menu>") (newline)
  (newline)
  (display "    <hr>") (newline)
  (display "  </body>") (newline)
  (display "</html>") (newline))


; 54 is a dup, omitted
; Not yet approved: 7 10 28 52 59 73 75 80 122 129        135  > 137
(define *tickets*
  '(4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 136))

(define *not-approved* '(7 10 28 52 59 73 75 80 122 129))

(with-output-to-file "formal-comment-index.html"
  (lambda ()
    (display-comment-index *tickets* *not-approved*)))
