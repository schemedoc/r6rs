; Basic tests of SRFI 75 procedures,
; mostly taken from the SRFI 75 examples
; and restricted to ASCII characters and strings.
;
; FIXME: Tests of things that aren't fully implemented yet
; are commented out.

(define (basic-unicode-tests)
  (call-with-current-continuation
   (lambda (exit)
     (let-syntax ((return (syntax-rules ()
                           ((return) (exit #t))))
                  (test (syntax-rules (=> error)
                         ((test name exp => result)
                          (if (not (equal? exp 'result))
                              (begin (display "*****BUG*****")
                                     (newline)
                                     (display "Failed test ")
                                     (display 'name)
                                     (display ":")
                                     (newline)
                                     (write 'exp)
                                     (newline)
                                     (exit #f)))))))

       (test type1 (integer->char 32) => #\space)
      ;(test type2 (char->integer (integer->char 5000)) => 5000)
      ;(test type3 (integer->char #xd800) => error)

       (test comp1 (char<? #\z #\~) => #t)
       (test comp2 (char<? #\z #\Z) => #f)
       (test comp3 (char-ci<? #\z #\Z) => #f)
       (test comp4 (char-ci=? #\z #\Z) => #t)
       (test comp5 (char-ci=? #\? #\?) => #t)

       (test case1 (char-upcase #\i) => #\I)
       (test case2 (char-downcase #\i) => #\i)
       (test case3 (char-titlecase #\i) => #\I)
       (test case4 (char-foldcase #\i) => #\i)

       ; FIXME: replace #\? with the Greek letters of SRFI 75

       (test case5 (char-upcase #\?) => #\?)
       (test case6 (char-downcase #\?) => #\?)
       (test case7 (char-titlecase #\?) => #\?)
       (test case8 (char-foldcase #\?) => #\?)

       (test cat1 (char-general-category #\a) => Ll)
       (test cat2 (char-general-category #\space) => Zs)
      ;(test cat3 (char-general-category (integer->char #x10FFFF)) => Cn)

       (test alpha1 (char-alphabetic? #\a) => #t)
       (test numer1 (char-numeric? #\1) => #t)
       (test white1 (char-whitespace? #\space) => #t)
       (test white2 (char-whitespace? (integer->char #x00A0)) => #t)
       (test upper1 (char-upper-case? #\Z) => #t)
       (test lower1 (char-lower-case? #\z) => #t)
       (test lower2 (char-lower-case? (integer->char #x00AA)) => #t)
       (test title1 (char-title-case? #\I) => #f)
      ;(test title2 (char-title-case? (integer->char #x01C5)) => #t)

       (test scomp1 (string<? "z" "~") => #t)
       (test scomp2 (string<? "z" "zz") => #t)
       (test scomp3 (string<? "z" "Z") => #f)
      ;(test scomp4 (string=? "Stra?e" "Strasse") => #f)

       (test sup1 (string-upcase "Hi") => "HI")
       (test sdown1 (string-downcase "Hi") => "hi")
       (test sfold1 (string-foldcase "Hi") => "hi")

      ;(test sup2  (string-upcase "Stra?e") => "STRASSE")
      ;(test sdown2 (string-downcase "Stra?e") => "stra?e")
      ;(test sfold2 (string-foldcase "Stra?e") => "strasse")
       (test sdown3 (string-downcase "STRASSE")  => "strasse")

       (test stitle1 (string-titlecase "kNock KNoCK") => "Knock Knock")
       (test stitle2 (string-titlecase "who's there?") => "Who's There?")
       (test stitle3 (string-titlecase "r6rs") => "R6Rs")
       (test stitle4 (string-titlecase "R6RS") => "R6Rs")

      ;(test norm1 (string-normalize-nfd "\xE9;") => "\x65;\x301;")
      ;(test norm2 (string-normalize-nfc "\xE9;") => "\xE9;")
      ;(test norm3 (string-normalize-nfd "\x65;\x301;") => "\x65;\x301;")
      ;(test norm4 (string-normalize-nfc "\x65;\x301;") => "\xE9;")

       (test sci1 (string-ci<? "z" "Z") => #f)
       (test sci2 (string-ci=? "z" "Z") => #t)
      ;(test sci3 (string-ci=? "Stra?e" "Strasse") => #t)
      ;(test sci4 (string-ci=? "Stra?e" "STRASSE") => #t)
      ;(test sci5 (string-ci=? "????" "????") => #t)

))))
