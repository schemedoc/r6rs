
(module r6rs-reader-test mzscheme
  (require (prefix r6rs- "r6rs-reader.ss"))

  (define passed 0)

  (define (test expect str)
    (let ([v (r6rs-read (open-input-string str))])
      (unless (equal? v expect)
	(error 'test "for ~a: expected ~e, got ~e"
	       'str expect v))
      (set! passed (add1 passed))))

  (define (test-str+sym expect str)
    (test expect (format "\"~a\"" str))
    (test (string->symbol expect) (format "|~a|" str)))

  (define (test-error str)
    (with-handlers ([exn:fail:read? (lambda (exn)
				      (printf "OK: ~a\n" (exn-message exn))
				      (set! passed (add1 passed)))])
      (r6rs-read (open-input-string str))
      (error 'test-error "should have failed")))

  (define (test-str+sym-error str)
    (test-error (format "\"~a\"" str))
    (test-error (format "|~a|" str)))

  (test-str+sym (string (integer->char 97)) "a")

  (test-str+sym (string (integer->char 7)) "\\a")
  (test-str+sym (string (integer->char 8)) "\\b")
  (test-str+sym (string (integer->char 9)) "\\t")
  (test-str+sym (string (integer->char 10)) "\\n")
  (test-str+sym (string (integer->char 11)) "\\v")
  (test-str+sym (string (integer->char 12)) "\\f")
  (test-str+sym (string (integer->char 13)) "\\r")
  (test-str+sym (string (integer->char 34)) "\\\"")
  (test-str+sym (string (integer->char 124)) "\\|")
  (test-str+sym " " "\\ ")
  (test-str+sym "abcd" "abc\\\n     d")
  (test-str+sym "abc d" "abc\\\n     \\ d")
  (test-str+sym "abc\nd" "abc\\\n     \nd")

  (test-str+sym (string (integer->char #x56)) "\\x56;")
  (test-str+sym (string (integer->char #x56)) "\\x0056;")
  (test-str+sym (string (integer->char #x1256)) "\\x1256;")
  (test-str+sym (string (integer->char #x1256) #\7 #\8) "\\x125678;")
  (test-str+sym (string (integer->char #x00105678)) "\\x00105678;")

  (test-str+sym-error "\\\r")

  (define (test-char n str)
    (test (integer->char n) str)
    (test (integer->char n) (string-append str ";"))
    (test (integer->char n) (string-append str "\t")))

  (test-char 0 "#\\nul")
  (test-char 7 "#\\alarm")
  (test-char 8 "#\\backspace")
  (test-char 9 "#\\tab")
  (test-char 10 "#\\newline")
  (test-char 10 "#\\linefeed")
  (test-char 11 "#\\vtab")
  (test-char 12 "#\\page")
  (test-char 13 "#\\return")
  (test-char (char->integer #\() "#\\(")
  (test-char (char->integer #\() "#\\()")
  (test-char (char->integer #\x) "#\\x")
  (test-char (char->integer #\u) "#\\u")
  (test-char (char->integer #\U) "#\\U")
  (test-char #x1256 (format "#\\~a" (integer->char #x1256)))

  (test-char #x56 "#\\x56")
  (test-char #x56 "#\\x0056")
  (test-char #x3bb "#\\x03bb")
  (test-char #x3BB "#\\x03BB")
  (test-char #x1256 "#\\x1256")
  (test-char #x00105678 "#\\x00105678")

  (test-error "#\\nonesuch")
  (test-error "#\\Nul")
  (test-error "#\\X20")
  (test-error "#\\x000000000")
  (test-error (format "#\\~xaz" (integer->char  #x1256)))

  (define (test-hex-error str)
    (test-str+sym-error str)
    (test-error (string-append "#" str)))

  (test-hex-error "\\xza")
  (test-hex-error "\\xaz")
  (test-hex-error "\\xd90x")
  (test-hex-error "\\xx90d")
  (test-hex-error "\\xd900")
  (test-hex-error "\\x0000d900")
  (test-hex-error "\\x00125678")

  (printf "~a tests passed\n" passed))