; The CHECK macro is essentially stolen from Sebastian Egner's SRFIs.

(define *correct-count* 0)
(define *failed-count* 0)

(define-syntax check
  (syntax-rules (=>)
    ((check ec => desired-result)
     (check ec => (equal?) desired-result))
    ((check ec => (equal?) desired-result)
     (begin
       (newline)
       (write (quote ec))
       (newline)
       (let ((actual-result ec))
         (display "  => ")
         (write actual-result)
         (if (equal? actual-result desired-result)
             (begin
               (display " ; correct")
               (set! *correct-count* (+ *correct-count* 1)) )
             (begin
               (display " ; *** failed ***, desired result:")
               (newline)
               (display "  => ")
               (write desired-result)
               (set! *failed-count* (+ *failed-count* 1)) ))
         (newline) )))))

(define-syntax check-exception
  (syntax-rules ()
    ((check-exception ?e)
     (begin
       (newline)
       (write (quote ?e))
       (newline)
       (guard
	(_
	 (else
	  (begin
	    (display " ; correct")
	    (set! *correct-count* (+ *correct-count* 1)) )))
	(let ((actual-result ?e))
	  (display "  => ")
	  (write actual-result)
	  (display " ; *** failed ***, desired exception")
	  (set! *failed-count* (+ *failed-count* 1))
	  (newline)))))))

(check
 (get-datum (open-input-string "-123")) => -123)
(check
 (get-datum (open-input-string "+123")) => 123)
(check
 (get-datum (open-input-string "...")) => '...)
(check-exception
 (get-datum (open-input-string "..")))
(check
 (get-datum (open-input-string ".5")) => 0.5)
(check
 (get-datum (open-input-string "(1 2 3)")) => '(1 2 3))
(check-exception
 (get-datum (open-input-string "(1 2 3]")))
(check
 (get-datum (open-input-string "foo")) => 'foo)
(check
 (get-datum (open-input-string "fOo")) => (string->symbol "fOo"))
(check
 (get-datum (open-input-string "[1 2 3]")) => '(1 2 3))
(check
 (get-datum (open-input-string "#\\linefeed")) => (integer->char 10))
(check
 (get-datum (open-input-string "#\\x578")) => (integer->char #x578))
(check
 (get-datum (open-input-string "\"\\a\\b\\t\\n\\v\\f\\r\\\"\\\\\""))
 => (list->string (map integer->char '(7 8 9 #xA #xB #xC #xD #x22 #x5c))))
(check
 (get-datum (open-input-string "\"\\x578;\\x123;\""))
  => (list->string (map integer->char '(#x578 #x123))))
(check-exception
 (get-datum (open-input-string "\"\\x578;\\x123\"")))
(check-exception
 (get-datum (open-input-string "\"\\x578\\x123\"")))
(check-exception
 (get-datum (open-input-string "#\\Alarm")))
(check
 (get-datum (open-input-string "h\\x65;llo")) => 'hello)
(check-exception
 (get-datum (open-input-string "h\\x65llo")))
(check
 (get-datum (open-input-string "'foo")) => '(quote foo))
(check
 (get-datum (open-input-string "`foo")) => '(quasiquote foo))
(check
 (get-datum (open-input-string ",foo")) => '(unquote foo))
(check
 (get-datum (open-input-string ",@foo")) => '(unquote-splicing foo))
(check
 (get-datum (open-input-string "#'foo")) => '(syntax foo))
(check
 (get-datum (open-input-string "#`foo")) => '(quasisyntax foo))
(check
 (get-datum (open-input-string "#,foo")) => '(unsyntax foo))
(check
 (get-datum (open-input-string "#,@foo")) => '(unsyntax-splicing foo))
(check
 (get-datum (open-input-string "(1 #| foo bar |# 2 3)")) => '(1 2 3))
(check
 (get-datum (open-input-string "(1 #| foo #| bar |# |# 2 3)")) => '(1 2 3))
(check
 (get-datum (open-input-string "(1 #;(foo bar baz) 2 3)")) => '(1 2 3))
(check
 (get-datum (open-input-string "->foo")) => (string->symbol "->foo"))
(check
 (get-datum (open-input-string "#vu8(1 2 3 4 5)")) => (bytes=?) (u8-list->bytes '(1 2 3 4 5)))
(check
 (get-datum (open-input-string "(#t #f #b1001 #T #F #B1001)")) => '(#t #f 9 #t #f 9))
(check-exception
 (get-datum (open-input-string "@")))
(check
 (get-datum (open-input-string "a@")) => 'a@)

(check
 (get-datum (open-input-string (string (integer->char #xa0)))) => (eof-object))
(check
 (get-datum (open-input-string (string (integer->char #xa1)))) =>
 (string->symbol (string (integer->char #xa1))))
(check-exception
 (get-datum (open-input-string "(#\\Z#\\F)")))
(check
 (get-datum (open-input-string "(#\\Z #\\F)")) => '(#\Z #\F))
(check-exception
 (get-datum (open-input-string "->#")))
(check-exception
 (get-datum (open-input-string "(a#b)")))
(check-exception
 (get-datum (open-input-string "(a,b)"))) ; missing delimiter
(check
 (get-datum (open-input-string "(a ,b)")) => '(a (unquote b)))
(check-exception
 (get-datum (open-input-string "(#\\A,b)"))) ; missing delimiter
(check
 (get-datum (open-input-string "(#\\A ,b)")) => '(#\A (unquote b)))
(check-exception
 (get-datum (open-input-string "(#\\t,b)")))
(check
 (get-datum (open-input-string "(#\\t ,b)")) => '(#\t (unquote b)))
(check-exception
 (get-datum (open-input-string "(#t#f)")))
(check
 (get-datum (open-input-string "(#t #f)")) => '(#t #f))

(check
 (get-datum (open-input-string "#!r6rs")) => (eof-object))
(check
 (get-datum (open-input-string "#!r6rs ")) => (eof-object))
(check
 (get-datum (open-input-string "#!r6rs a")) => 'a)

(define (single-character-passes lo hi)
  (do ((i lo (+ 1 i))
       (r '()
	  (guard
	   (_
	    (else r))
	   (get-datum (open-input-string (string (integer->char i))))
	   (cons i r))))
      ((> i hi)
       (reverse r))))

(check (single-character-passes 0 255)
       => '(9 10 11 12 13 32 33 36 37 38 42 43 45 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 94 95 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 126 133 160 161 162 163 164 165 166 167 168 169 170 172 174 175 176 177 178 179 180 181 182 183 184 185 186 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255))

(newline)
(display "correct tests: ")
(display *correct-count*)
(newline)
(display "failed tests: ")
(display *failed-count*)
(newline)
