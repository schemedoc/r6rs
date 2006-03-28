; "inf.scm", test Scheme implementation for reading and writing infinities
; Copyright (c) 2003 Aubrey Jaffer
;
;Permission to copy this software, to modify it, to redistribute it,
;to distribute modified versions, and to use it for any purpose is
;granted, subject to the following restrictions and understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warranty or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.

;This facility is a generalization of Common Lisp `unwind-protect',
;designed to take into account the fact that continuations produced by
;CALL-WITH-CURRENT-CONTINUATION may be reentered.

(define real-infs
  '("+inf.0" "-inf.0" "+nan.0" "-nan.0" "nan.0"	;MZScheme
    "+inf." "-inf." "+nan." "-nan." "nan." ;Gambit
    "+INF" "-Inf" "inf" "+NAN" "-Nan" "nan" ;glibc scanf
    "+#.#" "-#.#" "#.#"			;Guile
    "1/0" "-1/0" "0/0"			;SCM
    "#i0/0"                             ;Kawa
    ))

(define complex-infs
  '("inf.+i" "-inf.+i" "+nan.+i" "-nan.+i" ;Gambit
    "+inf.i" "-inf.i" "+nan.i" "-nan.i"
    "inf.+inf.i" "inf.-inf.i" "inf.+nan.i" "inf.-nan.i"
    "-inf.+inf.i" "-inf.-inf.i" "-inf.+nan.i" "-inf.-nan.i"
    "+nan.+inf.i" "+nan.-inf.i" "+nan.+nan.i" "+nan.-nan.i"
    "-nan.+inf.i" "-nan.-inf.i" "-nan.+nan.i" "-nan.-nan.i"
    
    "inf.0+i" "-inf.0+i" "+nan.0+i" "-nan.0+i" ;MZScheme
    "+inf.0i" "-inf.0i" "+nan.0i" "-nan.0i"
    "0+inf.0i" "0-inf.0i" "0+nan.0i" "0-nan.0i"
    "inf.0+inf.0i" "inf.0-inf.0i" "inf.0+nan.0i" "inf.0-nan.0i"
    "-inf.0+inf.0i" "-inf.0-inf.0i" "-inf.0+nan.0i" "-inf.0-nan.0i"
    "+nan.0+inf.0i" "+nan.0-inf.0i" "+nan.0+nan.0i" "+nan.0-nan.0i"
    "-nan.0+inf.0i" "-nan.0-inf.0i" "-nan.0+nan.0i" "-nan.0-nan.0i"

    "1/0+i" "-1/0+i" "0/0+i"		;SCM
    "+1/0i" "-1/0i" "+0/0i" "-0/0i"
    "1/0+1/0i" "1/0-1/0i" "1/0+0/0i" "1/0-0/0i"
    "-1/0+1/0i" "-1/0-1/0i" "-1/0+0/0i" "-1/0-0/0i"
    "0/0+1/0i" "0/0-1/0i" "0/0+0/0i" "0/0-0/0i"

    "#i1/0+i" "#i-1/0+i" "#i0/0+i"		;Kawa
    "#i+1/0i" "#i-1/0i" "#i+0/0i" "#i-0/0i"
    "#i1/0+1/0i" "#i1/0-1/0i" "#i1/0+0/0i" "#i1/0-0/0i"
    "#i-1/0+1/0i" "#i-1/0-1/0i" "#i-1/0+0/0i" "#i-1/0-0/0i"
    "#i0/0+1/0i" "#i0/0-1/0i" "#i0/0+0/0i" "#i0/0-0/0i"
    ))

(define (trydivs . opt)
  (for-each (lambda (exp)
	      (define ans (apply eval exp opt))
	      (cond (ans (write exp)
			 (display "		==> ")
			 (write ans) (newline))))
	    /cases))
(define (inex-props . opt)
  (for-each (lambda (exp)
	      (define ans (apply eval exp opt))
	      (cond ((number? ans)
		     (display "<TR><TD ALIGN=RIGHT><TT>")
		     (display ans)
		     (display "</TT>")
		     (display (if (inexact? ans) "<TH>*" "<TH>"))
		     (display (if (exact? ans) "<TH>*" "<TH>"))
		     (display (if (rational? ans) "<TH>*" "<TH>"))
		     (display (if (integer? ans) "<TH>*" "<TH>"))
		     (display (if (real? ans)  "<TH>*" "<TH>"))
		     (display (if (and (real? ans) (positive? ans))  "<TH>*" "<TH>"))
		     (display (if (zero? ans)  "<TH>*" "<TH>"))
		     (display (if (and (real? ans) (negative? ans))  "<TH>*" "<TH>"))
		     (newline))))
	    /inexact-cases))
(define (ex-props . opt)
  (for-each (lambda (exp)
	      (define ans (apply eval exp opt))
	      (cond ((number? ans)
		     (display "<TR><TD ALIGN=RIGHT><TT>")
		     (display ans)
		     (display "</TT>")
		     (display (if (inexact? ans) "<TH>*" "<TH>"))
		     (display (if (exact? ans) "<TH>*" "<TH>"))
		     (display (if (rational? ans) "<TH>*" "<TH>"))
		     (display (if (integer? ans) "<TH>*" "<TH>"))
		     (display (if (real? ans)  "<TH>*" "<TH>"))
		     (display (if (positive? ans)  "<TH>*" "<TH>"))
		     (display (if (zero? ans)  "<TH>*" "<TH>"))
		     (display (if (negative? ans)  "<TH>*" "<TH>"))
		     (newline))))
	    /exact-cases))
(define (str2num str)
  (define num (string->number str))
  (write str)
  (cond (num (display (make-string (- 16 (string-length str)) #\ ))
	     (display " ==> ") (write num) (newline))
	(else (newline))))

(display "Division test cases:") (newline)
(define /inexact-cases '((/ 0.) (/ -1. 0.) (/ -1 0.) (/ 0. 0.) (/ 0 0.)))
(define /cases (append /inexact-cases
		       '((/ -1. 0) (/ 0. 0) (/ 0 0) (/ 0) (/ -1 0))))
(define /exact-cases '((/ 0) (/ -1 0)))
(write /cases) (newline)
(display "After the STRING->NUMBER tests, do") (newline)
(display "  (trydivs) for single-argument EVAL;") (newline)
(display "  (trydivs (interaction-environment)) for two-argument EVAL;")
(newline)
(newline)
(display "Testing STRING->NUMBER on real infinities:") (newline)
(for-each str2num real-infs) (newline)
(cond ((string->number "1+3i")
       (display "Testing STRING->NUMBER on complex infinities:") (newline)
       (for-each str2num complex-infs)))

(inex-props (interaction-environment))
;;(ex-props (interaction-environment))
(trydivs (interaction-environment))

(display "Done.") (newline)
