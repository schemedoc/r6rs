; Copyright (c) 2006 Michael Sperber
; All rights reserved.
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
; 3. The name of the authors may not be used to endorse or promote products
;    derived from this software without specific prior written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS OR
; IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
; OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
; IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY DIRECT, INDIRECT,
; INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
; NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
; THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Majorly hacked for Larceny by William D Clinger, 3 August 2006.
;
; I think this file should now run in any R5RS-conforming system
; that supports Unicode characters, strings, and the normalization
; procedures being tested.

; Get NormalizationTest.txt from http://www.unicode.org/

(define normalization-tests-filename "NormalizationTest.txt")

(load "unicode1.sch")
(load "unicode2.sch")
(load "unicode.sch")

(define (read-line port)
  (let loop ((l '()))
    (let ((c (read-char port)))
      (if (eof-object? c)
          c
          (if (char=? c #\newline)
              (list->string (reverse l))
              (loop (cons c l)))))))

; Given a string and a starting index,
; returns the index of the first character in the string
; at or following the starting index that is not a hex digit.
; Returns the length of the string if no such character is found.

(define (index-of-next-non-hex-digit s i)
  (let ((n (string-length s)))
    (let loop ((i i))
      (if (< i n)
          (case (string-ref s i)
           ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9
             #\a #\b #\c #\d #\e #\f 
             #\A #\B #\C #\D #\E #\F)
            (loop (+ i 1)))
           (else
            i))
          n))))

; Given a string of hex digits, returns its value as an integer.

(define (hexstring->int s)
  (define (hexdigit->int c)
    (case c
     ((#\0) 0)
     ((#\1) 1)
     ((#\2) 2)
     ((#\3) 3)
     ((#\4) 4)
     ((#\5) 5)
     ((#\6) 6)
     ((#\7) 7)
     ((#\8) 8)
     ((#\9) 9)
     ((#\a #\A) 10)
     ((#\b #\B) 11)
     ((#\c #\C) 12)
     ((#\d #\D) 13)
     ((#\e #\E) 14)
     ((#\f #\F) 15)
     (else (error "Bad hex digit: " c))))
  (let ((n (string-length s)))
    (do ((i 0 (+ i 1))
         (result 0 (+ (* 16 result) (hexdigit->int (string-ref s i)))))
        ((= i n) result))))

; Given a non-comment line from NormalizationTest.txt,
; returns the 5 strings parsed from that line (as multiple values).

(define (parse-scalar-values s)
  (let ((size (string-length s)))
    (let column-loop ((start 0) (count 0) (rev-columns '()))
      (if (= count 5)
	  (apply values (reverse rev-columns))
	  (let sv-loop ((start start) (rev-svs '()))
	    (let* ((i (index-of-next-non-hex-digit s start))
		   (n (hexstring->int (substring s start i))))
	      (if (char=? #\space (string-ref s i))
		  (sv-loop (+ 1 i) (cons n rev-svs))
		  (column-loop (+ 1 i) (+ 1 count)
			       (cons (list->string
                                      (map integer->char
                                           (reverse (cons n rev-svs))))
				     rev-columns)))))))))

; Crude test rig.

(define total-tests 0)
(define total-failed 0)
(define total-inputs 0)
(define current-input "")
(define failed-inputs '())

(define (test-init!)
  (set! total-tests 0)
  (set! total-failed 0)
  (set! total-inputs 0)
  (set! current-input "")
  (set! failed-inputs '()))

(define (test-start name)
  (display ".")
  (set! total-inputs (+ total-inputs 1))
  (set! current-input name))

(define (test name predicate x y)
  (set! total-tests (+ total-tests 1))
  (if (not (predicate x y))
      (begin (set! total-failed (+ total-failed 1))
             (if (or (null? failed-inputs)
                     (not (equal? current-input (car failed-inputs))))
                 (set! failed-inputs (cons current-input failed-inputs)))
             (display "***** test failed ***** ")
             (display total-inputs)
             (newline)
             (display current-input)
             (newline)
             (display name)
             (newline))))

(define (test-summarize)
  (newline)
  (display "Failed ")
  (write total-failed)
  (display " out of ")
  (write total-tests)
  (newline))

(define (check-line s)
  (call-with-values
   (lambda ()
     (parse-scalar-values s))
   (lambda (c1 c2 c3 c4 c5)
     (test-start s)
     (check-one c1 c2 c3 c4 c5))))

(define (check-one c1 c2 c3 c4 c5)
  (test "c2 == NFC(c1)" string=? c2 (string-normalize-nfc c1))
  (test "c2 == NFC(c2)" string=? c2 (string-normalize-nfc c2))
  (test "c2 == NFC(c3)" string=? c2 (string-normalize-nfc c3))
  (test "c4 == NFC(c4)" string=? c4 (string-normalize-nfc c4))
  (test "c4 == NFC(c5)" string=? c4 (string-normalize-nfc c5))
  
  (test "c3 == NFD(c1)" string=? c3 (string-normalize-nfd c1))
  (test "c3 == NFD(c2)" string=? c3 (string-normalize-nfd c2))
  (test "c3 == NFD(c3)" string=? c3 (string-normalize-nfd c3))
  (test "c5 == NFD(c4)" string=? c5 (string-normalize-nfd c4))
  (test "c5 == NFD(c5)" string=? c5 (string-normalize-nfd c5))

  (test "c4 == NFKC(c1)" string=? c4 (string-normalize-nfkc c1))
  (test "c4 == NFKC(c2)" string=? c4 (string-normalize-nfkc c2))
  (test "c4 == NFKC(c3)" string=? c4 (string-normalize-nfkc c3))
  (test "c4 == NFKC(c4)" string=? c4 (string-normalize-nfkc c4))
  (test "c4 == NFKC(c5)" string=? c4 (string-normalize-nfkc c5))

  (test "c5 == NFKD(c1)" string=? c5 (string-normalize-nfkd c1))
  (test "c5 == NFKD(c2)" string=? c5 (string-normalize-nfkd c2))
  (test "c5 == NFKD(c3)" string=? c5 (string-normalize-nfkd c3))
  (test "c5 == NFKD(c4)" string=? c5 (string-normalize-nfkd c4))
  (test "c5 == NFKD(c5)" string=? c5 (string-normalize-nfkd c5)))

(define (check-all filename)
  (call-with-input-file filename
    (lambda (port)
      (let loop ()
	(let ((thing (read-line port)))
(set! current-line thing)
	  (if (string? thing)
	      (begin
		(if (and (not (string=? "" thing))
			 (not (char=? (string-ref thing 0) #\#))
			 (not (char=? (string-ref thing 0) #\@)))
		    (check-line thing))
		(loop))))))))

(define (run-tests)
  (test-init!)
  (check-all normalization-tests-filename)
  (test-summarize))

