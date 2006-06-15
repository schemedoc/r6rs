; Partial implementation of some of the uglier parts of
; SRFI 75 (R6RS Unicode data)
;
; Assumes the following primitive procedures behave as
; specified by SRFI 75:
;
;     integer->char
;     char->integer
;     make-string
;     string-length
;     string-ref
;     string-set!
;
; This file does not rely on any lexical syntax for
; characters and strings.
;
; This file currently implements:
;
; char-general-category
; char-alphabetic?
; char-numeric?
; char-whitespace?
; char-upper-case?
; char-lower-case?
; char-title-case?
;
; char=?
; char<?
; char>?
; char<=?
; char>=?
;
; string=?
; string<?
; string>?
; string<=?
; string>=?
;
; This file currently implements the following procedures
; for ASCII characters and strings, possibly incorrectly,
; but the implementations are definitely incorrect for
; Unicode characters and strings in general.
;
; char-upcase
; char-downcase
; char-titlecase
; char-foldcase
;
; string-upcase
; string-downcase
; string-titlecase
; string-foldcase
;
; This file does not yet implement:
;
; string-normalize-nfd
; string-normalize-nfkd
; string-normalize-nfc
; string-normalize-nfkc
;
; This file implements the following in terms of as yet
; incorrectly implemented case-folding procedures:
;
; char-ci=?
; char-ci<?
; char-ci>?
; char-ci<=?
; char-ci>=?
;
; string-ci=?
; string-ci<?
; string-ci>?
; string-ci<=?
; string-ci>=?
;
; Known bugs (search for FIXME):
;
; The case conversions are currently defined only for the
; ASCII subset of Unicode.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Compatibility issue: uses bytevectors.
;
; The bytevector operations used in this file are
;
;     make-bytevector
;     bytevector-length
;     bytevector-ref
;     bytevector-set!
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; For R5RS code, uncomment the following definitions.

'
(begin (define make-bytevector make-vector)
       (define bytevector-length vector-length)
       (define bytevector-ref vector-ref)
       (define bytevector-set! vector-set!))

(define (list->bytevector x)
  (let ((bv (make-bytevector (length x))))
    (do ((i 0 (+ i 1))
         (x x (cdr x)))
        ((null? x) bv)
      (bytevector-set! bv i (car x)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Definitions of procedures as specified in SRFI 75.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Procedures that operate on characters.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Comparisons.

(define (char=? c1 c2)
  (= (char->integer c1) (char->integer c2)))

(define (char<? c1 c2)
  (< (char->integer c1) (char->integer c2)))

(define (char>? c1 c2)
  (> (char->integer c1) (char->integer c2)))

(define (char<=? c1 c2)
  (<= (char->integer c1) (char->integer c2)))

(define (char>=? c1 c2)
  (>= (char->integer c1) (char->integer c2)))

; Case-insensitive comparisons.

(define (char-ci=? c1 c2)
  (char=? (char-foldcase c1) (char-foldcase c2)))

(define (char-ci<? c1 c2)
  (char<? (char-foldcase c1) (char-foldcase c2)))

(define (char-ci>? c1 c2)
  (char>? (char-foldcase c1) (char-foldcase c2)))

(define (char-ci<=? c1 c2)
  (char<=? (char-foldcase c1) (char-foldcase c2)))

(define (char-ci>=? c1 c2)
  (char>=? (char-foldcase c1) (char-foldcase c2)))

; FIXME
; Character case conversions are not yet implemented correctly.
; They should be correct for ASCII characters, however.

(define (char-upcase c)
  (let ((n (char->integer c)))
    (if (<= #x61 n #x7a)
        (integer->char (- n #x20))
        c)))

(define (char-downcase c)
  (let ((n (char->integer c)))
    (if (<= #x41 n #x5a)
        (integer->char (+ n #x20))
        c)))

(define (char-titlecase c)
  (char-upcase c))

; FIXME
; The following definition should be correct when the above
; definitions are corrected, but should be made more efficient.

(define (char-foldcase c)
  (case (char->integer c)
   ((#x130 #x131) c)
   (else
    (char-downcase (char-upcase c)))))    

; Given a character, returns its Unicode general category.
; The tables used to implement this procedure occupy about 12440 bytes.
; 4408 of those bytes could be saved by splitting the large vector
; into a bytes object for the 16-bit scalar values and using a
; general vector only for the scalar values greater than 65535.

(define (char-general-category c)
  (let ((n (char->integer c)))
    (vector-ref
     vector-of-general-category-symbols
     (if (< n (bytevector-length
               general-category-indices-for-common-characters))
         (bytevector-ref general-category-indices-for-common-characters n)
         (bytevector-ref general-category-indices-for-all-characters
                         (binary-search-of-vector
                          n
                          vector-of-code-points-with-same-category))))))

; Given a character, returns true if and only if the character
; is alphabetic, numeric, whitespace, upper-case, lower-case,
; or title-case respectively.

(define (char-alphabetic? c)
  (if (memq (char-general-category c)
            '(Lu Ll Lt Lm Lo))
      #t
      #f))

(define (char-numeric? c)
  (eq? (char-general-category c)
       'Nd))

(define (char-whitespace? c)
  (let ((k (char->integer c)))
    (if (< k 256)
        (case k
         ((#x09 #x0a #x0b #x0c #x0d #x20 #xa0) #t)
         (else #f))
        (if (memq (char-general-category c)
                  '(Zs Zl Zp))
            #t
            #f))))

(define (char-upper-case? c)
  (eq? 'Lu (char-general-category c)))

(define (char-lower-case? c)
  (eq? 'Ll (char-general-category c)))

(define (char-title-case? c)
  (eq? 'Lt (char-general-category c)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Procedures that operate on strings.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Comparisons.

(define (string=? a b)
  (= (string-compare a b 'string=?) 0))

(define (string<? a b)
  (< (string-compare a b 'string<?) 0))

(define (string<=? a b)
  (<= (string-compare a b 'string<=?) 0))

(define (string>? a b)
  (> (string-compare a b 'string>?) 0))

(define (string>=? a b)
  (>= (string-compare a b 'string>=?) 0))

; FIXME
; String case conversions are not yet implemented correctly.
; They should be correct for ASCII strings, however.

(define (string-upcase s)
  (let* ((n (string-length s))
         (s2 (make-string n)))
    (do ((i 0 (+ i 1)))
        ((= i n) s2)
      (string-set! s2 i (char-upcase (string-ref s i))))))

(define (string-downcase s)
  (let* ((n (string-length s))
         (s2 (make-string n)))
    (do ((i 0 (+ i 1)))
        ((= i n) s2)
      (string-set! s2 i (char-downcase (string-ref s i))))))

(define (string-titlecase s)
  (let ((n (string-length s)))
    (define (loop i isFirst chars)
      (if (= i n)
          (do ((result (make-string (length chars)))
               (i 0 (+ i 1))
               (chars (reverse chars) (cdr chars)))
              ((null? chars)
               result)
            (string-set! result i (car chars)))
          (let* ((c (string-ref s i))
                 (category (char-general-category c)))
            ; FIXME: this is just a guess anyway,
            ; and for Unicode a character may turn into
            ; more than one letter
            (case category
             ((Lu Ll Lt)
              (if isFirst
                  (loop (+ i 1)
                        #f
                        (cons (char-titlecase c) chars))
                  (loop (+ i 1)
                        #f
                        (cons (char-downcase c) chars))))
             ((Lm Lo Pc Pd Ps Pe Pi Pf Po)
              (loop (+ i 1) isFirst (cons c chars)))
             (else
              (loop (+ i 1) #t (cons c chars)))))))
    (loop 0 #t '())))                    

(define (string-foldcase s)
  (let* ((n (string-length s))
         (s2 (make-string n)))
    (do ((i 0 (+ i 1)))
        ((= i n) s2)
      (string-set! s2 i (char-foldcase (string-ref s i))))))

; FIXME
; String normalizations will go here,
; but are not yet implemented.

; Case-insensitive comparisons.

(define (string-ci=? s1 s2)
  (string=? (string-foldcase s1) (string-foldcase s2)))

(define (string-ci<? s1 s2)
  (string<? (string-foldcase s1) (string-foldcase s2)))

(define (string-ci>? s1 s2)
  (string>? (string-foldcase s1) (string-foldcase s2)))

(define (string-ci<=? s1 s2)
  (string<=? (string-foldcase s1) (string-foldcase s2)))

(define (string-ci>=? s1 s2)
  (string>=? (string-foldcase s1) (string-foldcase s2)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Help procedures (not part of SRFI 75)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Given two strings and the name of the caller,
; returns -1, 0, or 1 to indicate whether the
; first string is less than, equal to, or greater
; than the second in the usual lexicographic order.

(define (string-compare a b name)
  (if (not (and (string? a) (string? b)))
      (begin (error name ": Operands must be strings: " a " " b)
	     #t)
      (let* ((na (string-length a))
             (nb (string-length b))
             (n (min na nb)))
        (define (loop i)
          (if (= i n)
              (cond ((< na nb) -1)
                    ((> na nb) +1)
                    (else 0))
              (let ((ai (string-ref a i))
                    (bi (string-ref b i)))
                (cond ((char<? ai bi) -1)
                      ((char>? ai bi) +1)
                      (else (loop (+ i 1)))))))
        (loop 0))))

; Given an exact integer key and a vector of exact integers
; in strictly increasing order, returns the largest i such
; that element i of the vector is less than or equal to key,
; or -1 if key is less than every element of the vector.

(define (binary-search-of-vector key vec)

  ; Loop invariants:
  ; 0 <= i < j <= (vector-length vec)
  ; vec[i] <= key
  ; if j < (vector-length vec), then key < vec[j]

  (define (loop i j)
    (let ((mid (quotient (+ i j) 2)))
      (cond ((= i mid)
             mid)
            ((<= (vector-ref vec mid) key)
             (loop mid j))
            (else
             (loop i mid)))))

  (let ((hi (vector-length vec)))
    (if (or (= hi 0) (< key (vector-ref vec 0)))
        -1
        (loop 0 hi))))

; The symbols that represent Unicode general properties.
; There are 30 of these.
; This table occupies about 128 bytes, not counting
; the space occupied by the symbols themselves.

(define vector-of-general-category-symbols
  '#(
     ; Letter: uppercase, lowercase, titlecase, modifier, other
     Lu Ll Lt Lm Lo

     ; Mark: nonspacing, spacing combining, enclosing
     Mn Mc Me

     ; Number: decimal digit, letter, other
     Nd Nl No

     ; Punctuation: connector, dash, open, close,
     ;     initial quote, final quote, other
     Pc Pd Ps Pe Pi Pf Po

     ; Symbol: math, currency, modifier, other
     Sm Sc Sk So

     ; Separator: space, line, paragraph
     Zs Zl Zp

     ; Other: control, format, surrogate, private use, not assigned
     Cc Cf Cs Co Cn))

; Given a symbol that appears in the vector above,
; returns its index within the vector.
; Used only for initialization, so it needn't be fast.

(define (general-category-symbol->index sym)
  (let ((n (vector-length vector-of-general-category-symbols)))
    (do ((i 0 (+ i 1)))
        ((or (= i n)
             (eq? sym (vector-ref vector-of-general-category-symbols i)))
         (if (= i n)
             (error "Unrecognized Unicode general category" sym)
             i)))))

; The following array of bytes, together with the vector below it,
; implements an indirect mapping from all Unicode scalar values to
; indices into the above vector.
; This array contains 2408 entries, and occupies about 2416 bytes.

(define general-category-indices-for-all-characters
  (list->bytevector
   (map
    general-category-symbol->index
    '(Cc Zs Po Sc Po Ps Pe Po Sm Po Pd Po Nd Po Sm Po
      Lu Ps Po Pe Sk Pc Sk Ll Ps Sm Pe Sm Cc Zs Po Sc
      So Sk So Ll Pi Sm Cf So Sk So Sm No Sk Ll So Po
      Sk No Ll Pf No Po Lu Sm Lu Ll Sm Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lo Lu Ll Lo
      Lu Lt Ll Lu Lt Ll Lu Lt Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Lt Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Cn Ll Lm Sk Lm Sk Lm Sk Lm Sk Mn Cn Sk Cn Lm
      Cn Po Cn Sk Lu Po Lu Cn Lu Cn Lu Ll Lu Cn Lu Ll
      Cn Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Sm Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll So Mn Cn Me Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Cn
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Cn Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Cn Lu Cn Lm Po
      Cn Ll Cn Po Pd Cn Mn Cn Mn Po Mn Po Mn Po Mn Po
      Mn Cn Lo Cn Lo Po Cn Cf Cn Sc Po So Mn Cn Po Cn
      Po Cn Lo Cn Lm Lo Mn Cn Nd Po Lo Mn Lo Po Lo Mn
      Cf Me Mn Lm Mn So Mn Lo Nd Lo So Lo Po Cn Cf Lo
      Mn Lo Mn Cn Lo Cn Lo Mn Lo Cn Mn Mc Lo Cn Mn Lo
      Mc Mn Mc Mn Cn Lo Mn Cn Lo Mn Po Nd Po Cn Lo Cn
      Mn Mc Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Mn
      Lo Mc Mn Cn Mc Cn Mc Mn Lo Cn Mc Cn Lo Cn Lo Mn
      Cn Nd Lo Sc No So Cn Mn Mc Cn Lo Cn Lo Cn Lo Cn
      Lo Cn Lo Cn Lo Cn Lo Cn Mn Cn Mc Mn Cn Mn Cn Mn
      Cn Lo Cn Lo Cn Nd Mn Lo Cn Mn Mc Cn Lo Cn Lo Cn
      Lo Cn Lo Cn Lo Cn Lo Cn Mn Lo Mc Mn Cn Mn Mc Cn
      Mc Mn Cn Lo Cn Lo Mn Cn Nd Cn Sc Cn Mn Mc Cn Lo
      Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Mn Lo Mc Mn Mc
      Mn Cn Mc Cn Mc Mn Cn Mn Mc Cn Lo Cn Lo Cn Nd So
      Lo Cn Mn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo
      Cn Lo Cn Lo Cn Lo Cn Mc Mn Mc Cn Mc Cn Mc Mn Cn
      Mc Cn Nd No So Sc So Cn Mc Cn Lo Cn Lo Cn Lo Cn
      Lo Cn Lo Cn Mn Mc Cn Mn Cn Mn Cn Mn Cn Lo Cn Nd
      Cn Mc Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Mn Lo Mc
      Mn Mc Cn Mn Mc Cn Mc Mn Cn Mc Cn Lo Cn Lo Cn Nd
      Cn Mc Cn Lo Cn Lo Cn Lo Cn Lo Cn Mc Mn Cn Mc Cn
      Mc Mn Cn Mc Cn Lo Cn Nd Cn Mc Cn Lo Cn Lo Cn Lo
      Cn Lo Cn Lo Cn Mn Cn Mc Mn Cn Mn Cn Mc Cn Mc Po
      Cn Lo Mn Lo Mn Cn Sc Lo Lm Mn Po Nd Po Cn Lo Cn
      Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn
      Lo Cn Lo Cn Lo Mn Lo Mn Cn Mn Lo Cn Lo Cn Lm Cn
      Mn Cn Nd Cn Lo Cn Lo So Po So Mn So Nd No So Mn
      So Mn So Mn Ps Pe Ps Pe Mc Lo Cn Lo Cn Mn Mc Mn
      Po Mn Lo Cn Mn Cn Mn Cn So Mn So Cn So Po Cn Lo
      Cn Lo Cn Lo Cn Mc Mn Mc Mn Cn Mn Mc Mn Cn Nd Po
      Lo Mc Mn Cn Lu Cn Lo Po Lm Cn Lo Cn Lo Cn Lo Cn
      Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn
      Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn
      Mn So Po No Cn Lo So Cn Lo Cn Lo Po Lo Cn Zs Lo
      Ps Pe Cn Lo Po Nl Cn Lo Cn Lo Mn Cn Lo Mn Po Cn
      Lo Mn Cn Lo Cn Lo Cn Mn Cn Lo Cf Mc Mn Mc Mn Mc
      Mn Po Lm Po Sc Lo Mn Cn Nd Cn No Cn Po Pd Po Mn
      Zs Cn Nd Cn Lo Lm Lo Cn Lo Mn Cn Lo Cn Mn Mc Mn
      Mc Cn Mc Mn Mc Mn Cn So Cn Po Nd Lo Cn Lo Cn Lo
      Cn Mc Lo Mc Cn Nd Cn Po So Lo Mn Mc Cn Po Cn Ll
      Lm Ll Lm Ll Lm Mn Cn Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Cn Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll
      Lu Ll Lu Ll Lu Ll Lu Ll Cn Ll Lu Ll Cn Lu Cn Ll
      Lu Ll Lu Ll Cn Lu Cn Ll Cn Lu Cn Lu Cn Lu Cn Lu
      Ll Lu Ll Cn Ll Lt Ll Lt Ll Lt Ll Cn Ll Lu Lt Sk
      Ll Sk Ll Cn Ll Lu Lt Sk Ll Cn Ll Lu Cn Sk Ll Lu
      Sk Cn Ll Cn Ll Lu Lt Sk Cn Zs Cf Pd Po Pi Pf Ps
      Pi Pf Ps Pi Po Zl Zp Cf Zs Po Pi Pf Po Pc Po Sm
      Ps Pe Po Sm Po Pc Po Zs Cf Cn Cf No Ll Cn No Sm
      Ps Pe Ll No Sm Ps Pe Cn Lm Cn Sc Cn Mn Me Mn Me
      Mn Cn So Lu So Lu So Ll Lu Ll Lu Ll So Lu So Lu
      So Lu So Lu So Lu So Lu So Ll Lu So Lu Ll Lo Ll
      So Ll Lu Sm Lu Ll So Sm So Cn No Nl Cn Sm So Sm
      So Sm So Sm So Sm So Sm So Sm So Sm So Sm So Sm
      So Sm So Sm So Ps Pe So Sm So Sm Ps Pe Po So Cn
      So Cn So Cn No So No So Sm So Sm So Sm So Sm So
      Cn So Cn So Cn So Cn So Cn So Cn So Cn So Cn So
      Cn So Cn So Ps Pe Ps Pe Ps Pe Ps Pe Ps Pe Ps Pe
      Ps Pe No So Cn So Cn So Cn Sm Ps Pe Cn Sm Ps Pe
      Ps Pe Ps Pe Cn Sm So Sm Ps Pe Ps Pe Ps Pe Ps Pe
      Ps Pe Ps Pe Ps Pe Ps Pe Ps Pe Ps Pe Ps Pe Sm Ps
      Pe Ps Pe Sm Ps Pe Sm So Cn Lu Cn Ll Cn Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu
      Ll So Cn Po No Po Ll Cn Lo Cn Lm Cn Lo Cn Lo Cn
      Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Po Pi
      Pf Pi Pf Po Pi Pf Po Pi Pf Po Pd Cn Pi Pf Cn So
      Cn So Cn So Cn So Cn Zs Po So Lm Lo Nl Ps Pe Ps
      Pe Ps Pe Ps Pe Ps Pe So Ps Pe Ps Pe Ps Pe Ps Pe
      Pd Ps Pe So Nl Mn Pd Lm So Nl Lm Lo Po So Cn Lo
      Cn Mn Sk Lm Lo Pd Lo Po Lm Lo Cn Lo Cn Lo Cn So
      No So Lo Cn So Cn Lo So Cn No So Cn So No So No
      So No So Cn So Lo Cn So Lo Cn Lo Lm Lo Cn So Cn
      Sk Cn Lo Mc Lo Mn Lo Mn Lo Mc Mn Mc So Cn Lo Cn
      Cs Co Lo Cn Lo Cn Lo Cn Ll Cn Ll Cn Lo Mn Lo Sm
      Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Lo Ps Pe Cn
      Lo Cn Lo Cn Lo Sc So Cn Mn Po Ps Pe Po Cn Mn Cn
      Po Pd Pc Ps Pe Ps Pe Ps Pe Ps Pe Ps Pe Ps Pe Ps
      Pe Ps Pe Po Ps Pe Po Pc Po Cn Po Pd Ps Pe Ps Pe
      Ps Pe Po Sm Pd Sm Cn Po Sc Po Cn Lo Cn Lo Cn Cf
      Cn Po Sc Po Ps Pe Po Sm Po Pd Po Nd Po Sm Po Lu
      Ps Po Pe Sk Pc Sk Ll Ps Sm Pe Sm Ps Pe Po Ps Pe
      Po Lo Lm Lo Lm Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Sc
      Sm Sk So Sc Cn So Sm So Cn Cf So Cn Lo Cn Lo Cn
      Lo Cn Lo Cn Lo Cn Lo Cn Lo Cn Po So Cn No Cn So
      Nl No So No Cn Lo Cn No Cn Lo Nl Cn Lo Cn Po Lo
      Cn Lo So Nl Cn Lu Ll Lo Cn Nd Cn Lo Cn Lo Cn Lo
      Cn Lo Cn Lo Cn Lo Cn Lo Mn Cn Mn Cn Mn Lo Cn Lo
      Cn Lo Cn Mn Cn Mn No Cn Po Cn So Cn So Cn So Mc
      Mn So Mc Cf Mn So Mn So Mn So Cn So Mn So Cn So
      Cn Lu Ll Lu Ll Cn Ll Lu Ll Lu Cn Lu Cn Lu Cn Lu
      Cn Lu Cn Lu Ll Cn Ll Cn Ll Cn Ll Lu Ll Lu Cn Lu
      Cn Lu Cn Lu Cn Ll Lu Cn Lu Cn Lu Cn Lu Cn Lu Cn
      Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Lu Ll Cn Lu Sm
      Ll Sm Ll Lu Sm Ll Sm Ll Lu Sm Ll Sm Ll Lu Sm Ll
      Sm Ll Lu Sm Ll Sm Ll Cn Nd Cn Lo Cn Lo Cn Cf Cn
      Cf Cn Mn Cn Co Cn Co Cn))))

; The following vector of exact integers represents the
; Unicode scalar values whose Unicode general category
; is different from the Unicode scalar value immediately
; less than it.
; This array contains 2408 entries, and occupies about 9632 bytes.

(define vector-of-code-points-with-same-category
  '#(#x00 #x20 #x21 #x24 #x25 #x28 #x29 #x2a
     #x2b #x2c #x2d #x2e #x30 #x3a #x3c #x3f
     #x41 #x5b #x5c #x5d #x5e #x5f #x60 #x61
     #x7b #x7c #x7d #x7e #x7f #xa0 #xa1 #xa2
     #xa6 #xa8 #xa9 #xaa #xab #xac #xad #xae
     #xaf #xb0 #xb1 #xb2 #xb4 #xb5 #xb6 #xb7
     #xb8 #xb9 #xba #xbb #xbc #xbf #xc0 #xd7
     #xd8 #xdf #xf7 #xf8 #x100 #x101 #x102 #x103
     #x104 #x105 #x106 #x107 #x108 #x109 #x10a #x10b
     #x10c #x10d #x10e #x10f #x110 #x111 #x112 #x113
     #x114 #x115 #x116 #x117 #x118 #x119 #x11a #x11b
     #x11c #x11d #x11e #x11f #x120 #x121 #x122 #x123
     #x124 #x125 #x126 #x127 #x128 #x129 #x12a #x12b
     #x12c #x12d #x12e #x12f #x130 #x131 #x132 #x133
     #x134 #x135 #x136 #x137 #x139 #x13a #x13b #x13c
     #x13d #x13e #x13f #x140 #x141 #x142 #x143 #x144
     #x145 #x146 #x147 #x148 #x14a #x14b #x14c #x14d
     #x14e #x14f #x150 #x151 #x152 #x153 #x154 #x155
     #x156 #x157 #x158 #x159 #x15a #x15b #x15c #x15d
     #x15e #x15f #x160 #x161 #x162 #x163 #x164 #x165
     #x166 #x167 #x168 #x169 #x16a #x16b #x16c #x16d
     #x16e #x16f #x170 #x171 #x172 #x173 #x174 #x175
     #x176 #x177 #x178 #x17a #x17b #x17c #x17d #x17e
     #x181 #x183 #x184 #x185 #x186 #x188 #x189 #x18c
     #x18e #x192 #x193 #x195 #x196 #x199 #x19c #x19e
     #x19f #x1a1 #x1a2 #x1a3 #x1a4 #x1a5 #x1a6 #x1a8
     #x1a9 #x1aa #x1ac #x1ad #x1ae #x1b0 #x1b1 #x1b4
     #x1b5 #x1b6 #x1b7 #x1b9 #x1bb #x1bc #x1bd #x1c0
     #x1c4 #x1c5 #x1c6 #x1c7 #x1c8 #x1c9 #x1ca #x1cb
     #x1cc #x1cd #x1ce #x1cf #x1d0 #x1d1 #x1d2 #x1d3
     #x1d4 #x1d5 #x1d6 #x1d7 #x1d8 #x1d9 #x1da #x1db
     #x1dc #x1de #x1df #x1e0 #x1e1 #x1e2 #x1e3 #x1e4
     #x1e5 #x1e6 #x1e7 #x1e8 #x1e9 #x1ea #x1eb #x1ec
     #x1ed #x1ee #x1ef #x1f1 #x1f2 #x1f3 #x1f4 #x1f5
     #x1f6 #x1f9 #x1fa #x1fb #x1fc #x1fd #x1fe #x1ff
     #x200 #x201 #x202 #x203 #x204 #x205 #x206 #x207
     #x208 #x209 #x20a #x20b #x20c #x20d #x20e #x20f
     #x210 #x211 #x212 #x213 #x214 #x215 #x216 #x217
     #x218 #x219 #x21a #x21b #x21c #x21d #x21e #x21f
     #x220 #x221 #x222 #x223 #x224 #x225 #x226 #x227
     #x228 #x229 #x22a #x22b #x22c #x22d #x22e #x22f
     #x230 #x231 #x232 #x233 #x23a #x23c #x23d #x23f
     #x241 #x242 #x250 #x2b0 #x2c2 #x2c6 #x2d2 #x2e0
     #x2e5 #x2ee #x2ef #x300 #x370 #x374 #x376 #x37a
     #x37b #x37e #x37f #x384 #x386 #x387 #x388 #x38b
     #x38c #x38d #x38e #x390 #x391 #x3a2 #x3a3 #x3ac
     #x3cf #x3d0 #x3d2 #x3d5 #x3d8 #x3d9 #x3da #x3db
     #x3dc #x3dd #x3de #x3df #x3e0 #x3e1 #x3e2 #x3e3
     #x3e4 #x3e5 #x3e6 #x3e7 #x3e8 #x3e9 #x3ea #x3eb
     #x3ec #x3ed #x3ee #x3ef #x3f4 #x3f5 #x3f6 #x3f7
     #x3f8 #x3f9 #x3fb #x3fd #x430 #x460 #x461 #x462
     #x463 #x464 #x465 #x466 #x467 #x468 #x469 #x46a
     #x46b #x46c #x46d #x46e #x46f #x470 #x471 #x472
     #x473 #x474 #x475 #x476 #x477 #x478 #x479 #x47a
     #x47b #x47c #x47d #x47e #x47f #x480 #x481 #x482
     #x483 #x487 #x488 #x48a #x48b #x48c #x48d #x48e
     #x48f #x490 #x491 #x492 #x493 #x494 #x495 #x496
     #x497 #x498 #x499 #x49a #x49b #x49c #x49d #x49e
     #x49f #x4a0 #x4a1 #x4a2 #x4a3 #x4a4 #x4a5 #x4a6
     #x4a7 #x4a8 #x4a9 #x4aa #x4ab #x4ac #x4ad #x4ae
     #x4af #x4b0 #x4b1 #x4b2 #x4b3 #x4b4 #x4b5 #x4b6
     #x4b7 #x4b8 #x4b9 #x4ba #x4bb #x4bc #x4bd #x4be
     #x4bf #x4c0 #x4c2 #x4c3 #x4c4 #x4c5 #x4c6 #x4c7
     #x4c8 #x4c9 #x4ca #x4cb #x4cc #x4cd #x4ce #x4cf
     #x4d0 #x4d1 #x4d2 #x4d3 #x4d4 #x4d5 #x4d6 #x4d7
     #x4d8 #x4d9 #x4da #x4db #x4dc #x4dd #x4de #x4df
     #x4e0 #x4e1 #x4e2 #x4e3 #x4e4 #x4e5 #x4e6 #x4e7
     #x4e8 #x4e9 #x4ea #x4eb #x4ec #x4ed #x4ee #x4ef
     #x4f0 #x4f1 #x4f2 #x4f3 #x4f4 #x4f5 #x4f6 #x4f7
     #x4f8 #x4f9 #x4fa #x500 #x501 #x502 #x503 #x504
     #x505 #x506 #x507 #x508 #x509 #x50a #x50b #x50c
     #x50d #x50e #x50f #x510 #x531 #x557 #x559 #x55a
     #x560 #x561 #x588 #x589 #x58a #x58b #x591 #x5ba
     #x5bb #x5be #x5bf #x5c0 #x5c1 #x5c3 #x5c4 #x5c6
     #x5c7 #x5c8 #x5d0 #x5eb #x5f0 #x5f3 #x5f5 #x600
     #x604 #x60b #x60c #x60e #x610 #x616 #x61b #x61c
     #x61e #x620 #x621 #x63b #x640 #x641 #x64b #x65f
     #x660 #x66a #x66e #x670 #x671 #x6d4 #x6d5 #x6d6
     #x6dd #x6de #x6df #x6e5 #x6e7 #x6e9 #x6ea #x6ee
     #x6f0 #x6fa #x6fd #x6ff #x700 #x70e #x70f #x710
     #x711 #x712 #x730 #x74b #x74d #x76e #x780 #x7a6
     #x7b1 #x7b2 #x901 #x903 #x904 #x93a #x93c #x93d
     #x93e #x941 #x949 #x94d #x94e #x950 #x951 #x955
     #x958 #x962 #x964 #x966 #x970 #x971 #x97d #x97e
     #x981 #x982 #x984 #x985 #x98d #x98f #x991 #x993
     #x9a9 #x9aa #x9b1 #x9b2 #x9b3 #x9b6 #x9ba #x9bc
     #x9bd #x9be #x9c1 #x9c5 #x9c7 #x9c9 #x9cb #x9cd
     #x9ce #x9cf #x9d7 #x9d8 #x9dc #x9de #x9df #x9e2
     #x9e4 #x9e6 #x9f0 #x9f2 #x9f4 #x9fa #x9fb #xa01
     #xa03 #xa04 #xa05 #xa0b #xa0f #xa11 #xa13 #xa29
     #xa2a #xa31 #xa32 #xa34 #xa35 #xa37 #xa38 #xa3a
     #xa3c #xa3d #xa3e #xa41 #xa43 #xa47 #xa49 #xa4b
     #xa4e #xa59 #xa5d #xa5e #xa5f #xa66 #xa70 #xa72
     #xa75 #xa81 #xa83 #xa84 #xa85 #xa8e #xa8f #xa92
     #xa93 #xaa9 #xaaa #xab1 #xab2 #xab4 #xab5 #xaba
     #xabc #xabd #xabe #xac1 #xac6 #xac7 #xac9 #xaca
     #xacb #xacd #xace #xad0 #xad1 #xae0 #xae2 #xae4
     #xae6 #xaf0 #xaf1 #xaf2 #xb01 #xb02 #xb04 #xb05
     #xb0d #xb0f #xb11 #xb13 #xb29 #xb2a #xb31 #xb32
     #xb34 #xb35 #xb3a #xb3c #xb3d #xb3e #xb3f #xb40
     #xb41 #xb44 #xb47 #xb49 #xb4b #xb4d #xb4e #xb56
     #xb57 #xb58 #xb5c #xb5e #xb5f #xb62 #xb66 #xb70
     #xb71 #xb72 #xb82 #xb83 #xb84 #xb85 #xb8b #xb8e
     #xb91 #xb92 #xb96 #xb99 #xb9b #xb9c #xb9d #xb9e
     #xba0 #xba3 #xba5 #xba8 #xbab #xbae #xbba #xbbe
     #xbc0 #xbc1 #xbc3 #xbc6 #xbc9 #xbca #xbcd #xbce
     #xbd7 #xbd8 #xbe6 #xbf0 #xbf3 #xbf9 #xbfa #xbfb
     #xc01 #xc04 #xc05 #xc0d #xc0e #xc11 #xc12 #xc29
     #xc2a #xc34 #xc35 #xc3a #xc3e #xc41 #xc45 #xc46
     #xc49 #xc4a #xc4e #xc55 #xc57 #xc60 #xc62 #xc66
     #xc70 #xc82 #xc84 #xc85 #xc8d #xc8e #xc91 #xc92
     #xca9 #xcaa #xcb4 #xcb5 #xcba #xcbc #xcbd #xcbe
     #xcbf #xcc0 #xcc5 #xcc6 #xcc7 #xcc9 #xcca #xccc
     #xcce #xcd5 #xcd7 #xcde #xcdf #xce0 #xce2 #xce6
     #xcf0 #xd02 #xd04 #xd05 #xd0d #xd0e #xd11 #xd12
     #xd29 #xd2a #xd3a #xd3e #xd41 #xd44 #xd46 #xd49
     #xd4a #xd4d #xd4e #xd57 #xd58 #xd60 #xd62 #xd66
     #xd70 #xd82 #xd84 #xd85 #xd97 #xd9a #xdb2 #xdb3
     #xdbc #xdbd #xdbe #xdc0 #xdc7 #xdca #xdcb #xdcf
     #xdd2 #xdd5 #xdd6 #xdd7 #xdd8 #xde0 #xdf2 #xdf4
     #xdf5 #xe01 #xe31 #xe32 #xe34 #xe3b #xe3f #xe40
     #xe46 #xe47 #xe4f #xe50 #xe5a #xe5c #xe81 #xe83
     #xe84 #xe85 #xe87 #xe89 #xe8a #xe8b #xe8d #xe8e
     #xe94 #xe98 #xe99 #xea0 #xea1 #xea4 #xea5 #xea6
     #xea7 #xea8 #xeaa #xeac #xead #xeb1 #xeb2 #xeb4
     #xeba #xebb #xebd #xebe #xec0 #xec5 #xec6 #xec7
     #xec8 #xece #xed0 #xeda #xedc #xede #xf00 #xf01
     #xf04 #xf13 #xf18 #xf1a #xf20 #xf2a #xf34 #xf35
     #xf36 #xf37 #xf38 #xf39 #xf3a #xf3b #xf3c #xf3d
     #xf3e #xf40 #xf48 #xf49 #xf6b #xf71 #xf7f #xf80
     #xf85 #xf86 #xf88 #xf8c #xf90 #xf98 #xf99 #xfbd
     #xfbe #xfc6 #xfc7 #xfcd #xfcf #xfd0 #xfd2 #x1000
     #x1022 #x1023 #x1028 #x1029 #x102b #x102c #x102d #x1031
     #x1032 #x1033 #x1036 #x1038 #x1039 #x103a #x1040 #x104a
     #x1050 #x1056 #x1058 #x105a #x10a0 #x10c6 #x10d0 #x10fb
     #x10fc #x10fd #x1100 #x115a #x115f #x11a3 #x11a8 #x11fa
     #x1200 #x1249 #x124a #x124e #x1250 #x1257 #x1258 #x1259
     #x125a #x125e #x1260 #x1289 #x128a #x128e #x1290 #x12b1
     #x12b2 #x12b6 #x12b8 #x12bf #x12c0 #x12c1 #x12c2 #x12c6
     #x12c8 #x12d7 #x12d8 #x1311 #x1312 #x1316 #x1318 #x135b
     #x135f #x1360 #x1361 #x1369 #x137d #x1380 #x1390 #x139a
     #x13a0 #x13f5 #x1401 #x166d #x166f #x1677 #x1680 #x1681
     #x169b #x169c #x169d #x16a0 #x16eb #x16ee #x16f1 #x1700
     #x170d #x170e #x1712 #x1715 #x1720 #x1732 #x1735 #x1737
     #x1740 #x1752 #x1754 #x1760 #x176d #x176e #x1771 #x1772
     #x1774 #x1780 #x17b4 #x17b6 #x17b7 #x17be #x17c6 #x17c7
     #x17c9 #x17d4 #x17d7 #x17d8 #x17db #x17dc #x17dd #x17de
     #x17e0 #x17ea #x17f0 #x17fa #x1800 #x1806 #x1807 #x180b
     #x180e #x180f #x1810 #x181a #x1820 #x1843 #x1844 #x1878
     #x1880 #x18a9 #x18aa #x1900 #x191d #x1920 #x1923 #x1927
     #x1929 #x192c #x1930 #x1932 #x1933 #x1939 #x193c #x1940
     #x1941 #x1944 #x1946 #x1950 #x196e #x1970 #x1975 #x1980
     #x19aa #x19b0 #x19c1 #x19c8 #x19ca #x19d0 #x19da #x19de
     #x19e0 #x1a00 #x1a17 #x1a19 #x1a1c #x1a1e #x1a20 #x1d00
     #x1d2c #x1d62 #x1d78 #x1d79 #x1d9b #x1dc0 #x1dc4 #x1e00
     #x1e01 #x1e02 #x1e03 #x1e04 #x1e05 #x1e06 #x1e07 #x1e08
     #x1e09 #x1e0a #x1e0b #x1e0c #x1e0d #x1e0e #x1e0f #x1e10
     #x1e11 #x1e12 #x1e13 #x1e14 #x1e15 #x1e16 #x1e17 #x1e18
     #x1e19 #x1e1a #x1e1b #x1e1c #x1e1d #x1e1e #x1e1f #x1e20
     #x1e21 #x1e22 #x1e23 #x1e24 #x1e25 #x1e26 #x1e27 #x1e28
     #x1e29 #x1e2a #x1e2b #x1e2c #x1e2d #x1e2e #x1e2f #x1e30
     #x1e31 #x1e32 #x1e33 #x1e34 #x1e35 #x1e36 #x1e37 #x1e38
     #x1e39 #x1e3a #x1e3b #x1e3c #x1e3d #x1e3e #x1e3f #x1e40
     #x1e41 #x1e42 #x1e43 #x1e44 #x1e45 #x1e46 #x1e47 #x1e48
     #x1e49 #x1e4a #x1e4b #x1e4c #x1e4d #x1e4e #x1e4f #x1e50
     #x1e51 #x1e52 #x1e53 #x1e54 #x1e55 #x1e56 #x1e57 #x1e58
     #x1e59 #x1e5a #x1e5b #x1e5c #x1e5d #x1e5e #x1e5f #x1e60
     #x1e61 #x1e62 #x1e63 #x1e64 #x1e65 #x1e66 #x1e67 #x1e68
     #x1e69 #x1e6a #x1e6b #x1e6c #x1e6d #x1e6e #x1e6f #x1e70
     #x1e71 #x1e72 #x1e73 #x1e74 #x1e75 #x1e76 #x1e77 #x1e78
     #x1e79 #x1e7a #x1e7b #x1e7c #x1e7d #x1e7e #x1e7f #x1e80
     #x1e81 #x1e82 #x1e83 #x1e84 #x1e85 #x1e86 #x1e87 #x1e88
     #x1e89 #x1e8a #x1e8b #x1e8c #x1e8d #x1e8e #x1e8f #x1e90
     #x1e91 #x1e92 #x1e93 #x1e94 #x1e95 #x1e9c #x1ea0 #x1ea1
     #x1ea2 #x1ea3 #x1ea4 #x1ea5 #x1ea6 #x1ea7 #x1ea8 #x1ea9
     #x1eaa #x1eab #x1eac #x1ead #x1eae #x1eaf #x1eb0 #x1eb1
     #x1eb2 #x1eb3 #x1eb4 #x1eb5 #x1eb6 #x1eb7 #x1eb8 #x1eb9
     #x1eba #x1ebb #x1ebc #x1ebd #x1ebe #x1ebf #x1ec0 #x1ec1
     #x1ec2 #x1ec3 #x1ec4 #x1ec5 #x1ec6 #x1ec7 #x1ec8 #x1ec9
     #x1eca #x1ecb #x1ecc #x1ecd #x1ece #x1ecf #x1ed0 #x1ed1
     #x1ed2 #x1ed3 #x1ed4 #x1ed5 #x1ed6 #x1ed7 #x1ed8 #x1ed9
     #x1eda #x1edb #x1edc #x1edd #x1ede #x1edf #x1ee0 #x1ee1
     #x1ee2 #x1ee3 #x1ee4 #x1ee5 #x1ee6 #x1ee7 #x1ee8 #x1ee9
     #x1eea #x1eeb #x1eec #x1eed #x1eee #x1eef #x1ef0 #x1ef1
     #x1ef2 #x1ef3 #x1ef4 #x1ef5 #x1ef6 #x1ef7 #x1ef8 #x1ef9
     #x1efa #x1f00 #x1f08 #x1f10 #x1f16 #x1f18 #x1f1e #x1f20
     #x1f28 #x1f30 #x1f38 #x1f40 #x1f46 #x1f48 #x1f4e #x1f50
     #x1f58 #x1f59 #x1f5a #x1f5b #x1f5c #x1f5d #x1f5e #x1f5f
     #x1f60 #x1f68 #x1f70 #x1f7e #x1f80 #x1f88 #x1f90 #x1f98
     #x1fa0 #x1fa8 #x1fb0 #x1fb5 #x1fb6 #x1fb8 #x1fbc #x1fbd
     #x1fbe #x1fbf #x1fc2 #x1fc5 #x1fc6 #x1fc8 #x1fcc #x1fcd
     #x1fd0 #x1fd4 #x1fd6 #x1fd8 #x1fdc #x1fdd #x1fe0 #x1fe8
     #x1fed #x1ff0 #x1ff2 #x1ff5 #x1ff6 #x1ff8 #x1ffc #x1ffd
     #x1fff #x2000 #x200b #x2010 #x2016 #x2018 #x2019 #x201a
     #x201b #x201d #x201e #x201f #x2020 #x2028 #x2029 #x202a
     #x202f #x2030 #x2039 #x203a #x203b #x203f #x2041 #x2044
     #x2045 #x2046 #x2047 #x2052 #x2053 #x2054 #x2055 #x205f
     #x2060 #x2064 #x206a #x2070 #x2071 #x2072 #x2074 #x207a
     #x207d #x207e #x207f #x2080 #x208a #x208d #x208e #x208f
     #x2090 #x2095 #x20a0 #x20b6 #x20d0 #x20dd #x20e1 #x20e2
     #x20e5 #x20ec #x2100 #x2102 #x2103 #x2107 #x2108 #x210a
     #x210b #x210e #x2110 #x2113 #x2114 #x2115 #x2116 #x2119
     #x211e #x2124 #x2125 #x2126 #x2127 #x2128 #x2129 #x212a
     #x212e #x212f #x2130 #x2132 #x2133 #x2134 #x2135 #x2139
     #x213a #x213c #x213e #x2140 #x2145 #x2146 #x214a #x214b
     #x214c #x214d #x2153 #x2160 #x2184 #x2190 #x2195 #x219a
     #x219c #x21a0 #x21a1 #x21a3 #x21a4 #x21a6 #x21a7 #x21ae
     #x21af #x21ce #x21d0 #x21d2 #x21d3 #x21d4 #x21d5 #x21f4
     #x2300 #x2308 #x230c #x2320 #x2322 #x2329 #x232a #x232b
     #x237c #x237d #x239b #x23b4 #x23b5 #x23b6 #x23b7 #x23dc
     #x2400 #x2427 #x2440 #x244b #x2460 #x249c #x24ea #x2500
     #x25b7 #x25b8 #x25c1 #x25c2 #x25f8 #x2600 #x266f #x2670
     #x269d #x26a0 #x26b2 #x2701 #x2705 #x2706 #x270a #x270c
     #x2728 #x2729 #x274c #x274d #x274e #x274f #x2753 #x2756
     #x2757 #x2758 #x275f #x2761 #x2768 #x2769 #x276a #x276b
     #x276c #x276d #x276e #x276f #x2770 #x2771 #x2772 #x2773
     #x2774 #x2775 #x2776 #x2794 #x2795 #x2798 #x27b0 #x27b1
     #x27bf #x27c0 #x27c5 #x27c6 #x27c7 #x27d0 #x27e6 #x27e7
     #x27e8 #x27e9 #x27ea #x27eb #x27ec #x27f0 #x2800 #x2900
     #x2983 #x2984 #x2985 #x2986 #x2987 #x2988 #x2989 #x298a
     #x298b #x298c #x298d #x298e #x298f #x2990 #x2991 #x2992
     #x2993 #x2994 #x2995 #x2996 #x2997 #x2998 #x2999 #x29d8
     #x29d9 #x29da #x29db #x29dc #x29fc #x29fd #x29fe #x2b00
     #x2b14 #x2c00 #x2c2f #x2c30 #x2c5f #x2c80 #x2c81 #x2c82
     #x2c83 #x2c84 #x2c85 #x2c86 #x2c87 #x2c88 #x2c89 #x2c8a
     #x2c8b #x2c8c #x2c8d #x2c8e #x2c8f #x2c90 #x2c91 #x2c92
     #x2c93 #x2c94 #x2c95 #x2c96 #x2c97 #x2c98 #x2c99 #x2c9a
     #x2c9b #x2c9c #x2c9d #x2c9e #x2c9f #x2ca0 #x2ca1 #x2ca2
     #x2ca3 #x2ca4 #x2ca5 #x2ca6 #x2ca7 #x2ca8 #x2ca9 #x2caa
     #x2cab #x2cac #x2cad #x2cae #x2caf #x2cb0 #x2cb1 #x2cb2
     #x2cb3 #x2cb4 #x2cb5 #x2cb6 #x2cb7 #x2cb8 #x2cb9 #x2cba
     #x2cbb #x2cbc #x2cbd #x2cbe #x2cbf #x2cc0 #x2cc1 #x2cc2
     #x2cc3 #x2cc4 #x2cc5 #x2cc6 #x2cc7 #x2cc8 #x2cc9 #x2cca
     #x2ccb #x2ccc #x2ccd #x2cce #x2ccf #x2cd0 #x2cd1 #x2cd2
     #x2cd3 #x2cd4 #x2cd5 #x2cd6 #x2cd7 #x2cd8 #x2cd9 #x2cda
     #x2cdb #x2cdc #x2cdd #x2cde #x2cdf #x2ce0 #x2ce1 #x2ce2
     #x2ce3 #x2ce5 #x2ceb #x2cf9 #x2cfd #x2cfe #x2d00 #x2d26
     #x2d30 #x2d66 #x2d6f #x2d70 #x2d80 #x2d97 #x2da0 #x2da7
     #x2da8 #x2daf #x2db0 #x2db7 #x2db8 #x2dbf #x2dc0 #x2dc7
     #x2dc8 #x2dcf #x2dd0 #x2dd7 #x2dd8 #x2ddf #x2e00 #x2e02
     #x2e03 #x2e04 #x2e05 #x2e06 #x2e09 #x2e0a #x2e0b #x2e0c
     #x2e0d #x2e0e #x2e17 #x2e18 #x2e1c #x2e1d #x2e1e #x2e80
     #x2e9a #x2e9b #x2ef4 #x2f00 #x2fd6 #x2ff0 #x2ffc #x3000
     #x3001 #x3004 #x3005 #x3006 #x3007 #x3008 #x3009 #x300a
     #x300b #x300c #x300d #x300e #x300f #x3010 #x3011 #x3012
     #x3014 #x3015 #x3016 #x3017 #x3018 #x3019 #x301a #x301b
     #x301c #x301d #x301e #x3020 #x3021 #x302a #x3030 #x3031
     #x3036 #x3038 #x303b #x303c #x303d #x303e #x3040 #x3041
     #x3097 #x3099 #x309b #x309d #x309f #x30a0 #x30a1 #x30fb
     #x30fc #x30ff #x3100 #x3105 #x312d #x3131 #x318f #x3190
     #x3192 #x3196 #x31a0 #x31b8 #x31c0 #x31d0 #x31f0 #x3200
     #x321f #x3220 #x322a #x3244 #x3250 #x3251 #x3260 #x3280
     #x328a #x32b1 #x32c0 #x32ff #x3300 #x3400 #x4db6 #x4dc0
     #x4e00 #x9fbc #xa000 #xa015 #xa016 #xa48d #xa490 #xa4c7
     #xa700 #xa717 #xa800 #xa802 #xa803 #xa806 #xa807 #xa80b
     #xa80c #xa823 #xa825 #xa827 #xa828 #xa82c #xac00 #xd7a4
     #xd800 #xe000 #xf900 #xfa2e #xfa30 #xfa6b #xfa70 #xfada
     #xfb00 #xfb07 #xfb13 #xfb18 #xfb1d #xfb1e #xfb1f #xfb29
     #xfb2a #xfb37 #xfb38 #xfb3d #xfb3e #xfb3f #xfb40 #xfb42
     #xfb43 #xfb45 #xfb46 #xfbb2 #xfbd3 #xfd3e #xfd3f #xfd40
     #xfd50 #xfd90 #xfd92 #xfdc8 #xfdf0 #xfdfc #xfdfd #xfdfe
     #xfe00 #xfe10 #xfe17 #xfe18 #xfe19 #xfe1a #xfe20 #xfe24
     #xfe30 #xfe31 #xfe33 #xfe35 #xfe36 #xfe37 #xfe38 #xfe39
     #xfe3a #xfe3b #xfe3c #xfe3d #xfe3e #xfe3f #xfe40 #xfe41
     #xfe42 #xfe43 #xfe44 #xfe45 #xfe47 #xfe48 #xfe49 #xfe4d
     #xfe50 #xfe53 #xfe54 #xfe58 #xfe59 #xfe5a #xfe5b #xfe5c
     #xfe5d #xfe5e #xfe5f #xfe62 #xfe63 #xfe64 #xfe67 #xfe68
     #xfe69 #xfe6a #xfe6c #xfe70 #xfe75 #xfe76 #xfefd #xfeff
     #xff00 #xff01 #xff04 #xff05 #xff08 #xff09 #xff0a #xff0b
     #xff0c #xff0d #xff0e #xff10 #xff1a #xff1c #xff1f #xff21
     #xff3b #xff3c #xff3d #xff3e #xff3f #xff40 #xff41 #xff5b
     #xff5c #xff5d #xff5e #xff5f #xff60 #xff61 #xff62 #xff63
     #xff64 #xff66 #xff70 #xff71 #xff9e #xffa0 #xffbf #xffc2
     #xffc8 #xffca #xffd0 #xffd2 #xffd8 #xffda #xffdd #xffe0
     #xffe2 #xffe3 #xffe4 #xffe5 #xffe7 #xffe8 #xffe9 #xffed
     #xffef #xfff9 #xfffc #xfffe #x10000 #x1000c #x1000d #x10027
     #x10028 #x1003b #x1003c #x1003e #x1003f #x1004e #x10050 #x1005e
     #x10080 #x100fb #x10100 #x10102 #x10103 #x10107 #x10134 #x10137
     #x10140 #x10175 #x10179 #x1018a #x1018b #x10300 #x1031f #x10320
     #x10324 #x10330 #x1034a #x1034b #x10380 #x1039e #x1039f #x103a0
     #x103c4 #x103c8 #x103d0 #x103d1 #x103d6 #x10400 #x10428 #x10450
     #x1049e #x104a0 #x104aa #x10800 #x10806 #x10808 #x10809 #x1080a
     #x10836 #x10837 #x10839 #x1083c #x1083d #x1083f #x10840 #x10a00
     #x10a01 #x10a04 #x10a05 #x10a07 #x10a0c #x10a10 #x10a14 #x10a15
     #x10a18 #x10a19 #x10a34 #x10a38 #x10a3b #x10a3f #x10a40 #x10a48
     #x10a50 #x10a59 #x1d000 #x1d0f6 #x1d100 #x1d127 #x1d12a #x1d165
     #x1d167 #x1d16a #x1d16d #x1d173 #x1d17b #x1d183 #x1d185 #x1d18c
     #x1d1aa #x1d1ae #x1d1de #x1d200 #x1d242 #x1d245 #x1d246 #x1d300
     #x1d357 #x1d400 #x1d41a #x1d434 #x1d44e #x1d455 #x1d456 #x1d468
     #x1d482 #x1d49c #x1d49d #x1d49e #x1d4a0 #x1d4a2 #x1d4a3 #x1d4a5
     #x1d4a7 #x1d4a9 #x1d4ad #x1d4ae #x1d4b6 #x1d4ba #x1d4bb #x1d4bc
     #x1d4bd #x1d4c4 #x1d4c5 #x1d4d0 #x1d4ea #x1d504 #x1d506 #x1d507
     #x1d50b #x1d50d #x1d515 #x1d516 #x1d51d #x1d51e #x1d538 #x1d53a
     #x1d53b #x1d53f #x1d540 #x1d545 #x1d546 #x1d547 #x1d54a #x1d551
     #x1d552 #x1d56c #x1d586 #x1d5a0 #x1d5ba #x1d5d4 #x1d5ee #x1d608
     #x1d622 #x1d63c #x1d656 #x1d670 #x1d68a #x1d6a6 #x1d6a8 #x1d6c1
     #x1d6c2 #x1d6db #x1d6dc #x1d6e2 #x1d6fb #x1d6fc #x1d715 #x1d716
     #x1d71c #x1d735 #x1d736 #x1d74f #x1d750 #x1d756 #x1d76f #x1d770
     #x1d789 #x1d78a #x1d790 #x1d7a9 #x1d7aa #x1d7c3 #x1d7c4 #x1d7ca
     #x1d7ce #x1d800 #x20000 #x2a6d7 #x2f800 #x2fa1e #xe0001 #xe0002
     #xe0020 #xe0080 #xe0100 #xe01f0 #xf0000 #xffffe #x100000 #x10fffe))

; The following array of bytes implements a direct mapping
; from small code points to indices into the above vector.
; This array occupies about 264 bytes.

(define number-of-common-characters 256)

(define general-category-indices-for-common-characters
  (make-bytevector 0))

(do ((i 0 (+ i 1))
     (bv (make-bytevector number-of-common-characters)))
    ((= i number-of-common-characters)
     (set! general-category-indices-for-common-characters bv))
  (bytevector-set! bv
                   i
                   (general-category-symbol->index
                    (char-general-category (integer->char i)))))

; Simple benchmarks for common characters and for uncommon.

