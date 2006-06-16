; Partial implementation of some of the uglier parts of
; SRFI 75 (R6RS Unicode data)
;
; The tables in this file were generated from the
; Unicode Character Database, revision 4.1.0.
;
; This file does not rely on any lexical syntax for
; characters and strings.
;
; This file assumes the following primitive procedures
; behave as specified by SRFI 75:
;
;     integer->char
;     char->integer
;     make-string
;     string-length
;     string-ref
;     string-set!
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
; char-upcase
; char-downcase
; char-titlecase
; char-foldcase
;
; char=?
; char<?
; char>?
; char<=?
; char>=?
;
; char-ci=?
; char-ci<?
; char-ci>?
; char-ci<=?
; char-ci>=?
;
; string=?
; string<?
; string>?
; string<=?
; string>=?
;
; string-ci=?
; string-ci<?
; string-ci>?
; string-ci<=?
; string-ci>=?
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
; Known bugs (search for FIXME):
;
; These procedures are largely untested.
;
; The normalization procedures are not yet implemented.

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Simple (character-to-character) case conversions.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The tables used to implement these conversions occupy about 5424 bytes.

(define (char-upcase c)
  (let ((n (char->integer c)))
    (cond ((<= #x61 n #x7a)
           (integer->char (- n #x20)))
          ((< n #xb5)
           c)
          ((<= #xe0 n #xfe)
           (integer->char (- n #x20)))
          ((= n #xb5)
           (integer->char #x039c))
          ((< n #xff)
           c)
          ((<= n #xffff)
           (let ((probe (binary-search-16bit n simple-upcase-chars)))
             (if probe
                 (integer->char
                  (+ n (vector-ref simple-case-adjustments
                                   (bytevector-ref simple-upcase-adjustments
                                                   probe))))
                 c)))
          ((<= #x10428 n #x1044f)
           (integer->char (- n 40)))
          (else c))))

(define (char-downcase c)
  (let ((n (char->integer c)))
    (cond ((<= #x41 n #x5a)
           (integer->char (+ n #x20)))
          ((< n #xc0)
           c)
          ((<= n #xde)
           (integer->char (+ n #x20)))
          ((< n #xff)
           c)
          ((<= n #xffff)
           (let ((probe (binary-search-16bit n simple-downcase-chars)))
             (if probe
                 (integer->char
                  (- n (vector-ref simple-case-adjustments
                                   (bytevector-ref simple-downcase-adjustments
                                                   probe))))
                 c)))
          ((<= #x10400 n #x10427)
           (integer->char (+ n 40)))
          (else c))))

(define (char-titlecase c)
  (let ((n (char->integer c)))
    (cond ((< n #x01c4)
           (char-upcase c))
          ((> n #x01f3)
           (char-upcase c))
          (else
           (case n
             ((#x01c4 #x01c5 #x01c6)
              (integer->char #x01c5))
             ((#x01c7 #x01c8 #x01c9)
              (integer->char #x01c8))
             ((#x01ca #x01cb #x01cc)
              (integer->char #x01cb))
             ((#x01f1 #x01f2 #x01f3)
              (integer->char #x01f2))
             (else
              (char-upcase c)))))))

; FIXME
; The following definition is correct, but should be
; made more efficient.

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

; Case-insensitive comparisons.
; FIXME
; These are correct, but the common case should not allocate
; new strings.

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

(define (string-upcase s)
  (let* ((n (string-length s))
         (s2 (make-string n)))
    ; For when character-to-character mappings suffice.
    (define (fast i)
      (if (< i n)
          (let* ((c (string-ref s i))
                 (cp (char->integer c)))
            (if (< cp #x00df)
                (begin (string-set! s2 i (char-upcase c))
                       (fast (+ i 1)))
                (let ((probe (binary-search-16bit cp special-case-chars)))
                  (if probe
                      (let ((c2 (vector-ref special-uppercase-mapping probe)))
                        (if (char? c2)
                            (begin (string-set! s2 i c2)
                                   (fast (+ i 1)))
                            (slow-caser s
                                        i
                                        (list (substring s2 0 i))
                                        i
                                        char-upcase
                                        special-uppercase-mapping)))
                      (begin (string-set! s2 i (char-upcase c))
                             (fast (+ i 1)))))))
          s2))
    (fast 0)))

(define (string-downcase s)
  (let* ((n (string-length s))
         (s2 (make-string n)))
    ; For when character-to-character mappings suffice.
    (define (fast i)
      (if (< i n)
          (let* ((c (string-ref s i))
                 (cp (char->integer c)))
            (if (< cp #x00df)
                (begin (string-set! s2 i (char-downcase c))
                       (fast (+ i 1)))
                (let ((probe (binary-search-16bit cp special-case-chars)))
                  (if probe
                      (let ((c2 (vector-ref special-lowercase-mapping probe)))
                        (if (char? c2)
                            (begin (string-set! s2 i c2)
                                   (fast (+ i 1)))
                            (slow-caser s
                                        i
                                        (list (substring s2 0 i))
                                        i
                                        char-downcase
                                        special-lowercase-mapping)))
                      (begin (string-set! s2 i (char-downcase c))
                             (fast (+ i 1)))))))
          s2))
    (fast 0)))

; The string-titlecase procedure converts the first character
; to titlecase in each contiguous sequence of cased characters
; within string, and it downcases all other cased characters;
; for the purposes of detecting cased-character sequences,
; case-ignorable characters are ignored (i.e., they do not
; interrupt the sequence).
;
; A character C is defined to be case-ignorable if C has the Unicode
; Property Word_Break=MidLetter as defined in Unicode Standard Annex
; #29, "Text Boundaries;" or the General Category of C is Nonspacing
; Mark (Mn), Enclosing Mark (Me), Format Control (Cf), Letter Modifier
; (Lm), or Symbol Modifier (Sk).

(define (string-titlecase s)
  (let ((n (string-length s)))
    (define (loop i isFirst chars)
      (if (= i n)

          ; Concatenate the characters and strings.
          (let* ((n2 (do ((mapped chars (cdr mapped))
                          (n2 0
                              (+ n2 (if (char? (car mapped))
                                        1
                                        (string-length (car mapped))))))
                         ((null? mapped) n2)))
                 (s2 (make-string n2)))
            (define (loop i mapped)
              (if (null? mapped)
                  s2
                  (let ((c2 (car mapped)))
                    (if (char? c2)
                        (let ((i1 (- i 1)))
                          (string-set! s2 i1 c2)
                          (loop i1 (cdr mapped)))
                        (do ((j (- (string-length c2) 1) (- j 1))
                             (i (- i 1) (- i 1)))
                            ((< j 0)
                             (loop i (cdr mapped)))
                          (string-set! s2 i (string-ref c2 j)))))))
            (loop n2 chars))

          (let* ((c (string-ref s i))
                 (cp (char->integer c))
                 (category (char-general-category c)))
            (case category
             ((Lu Ll Lt)
              (let ((probe (if (< cp #x00df)
                               #f
                               (binary-search-16bit cp special-case-chars))))
                (if isFirst
                    (let ((x (if probe
                                 (vector-ref special-titlecase-mapping probe)
                                 (char-titlecase c))))
                      (loop (+ i 1) #f (cons x chars)))
                    (let ((x (if probe
                                 (vector-ref special-lowercase-mapping probe)
                                 (char-downcase c))))
                      (loop (+ i 1) #f (cons x chars))))))
             ((Po Pf)
              (case (char->integer c)
               ; The MidLetter characters are:
               ; apostrophe, middle dot,
               ; Hebrew punctuation GERSHAYIM,
               ; right single quotation mark,
               ; hyphenation point, colon
               ((#x0027 #x00b7 #x05f4 #x2019 #x2027 #x003a)
                (loop (+ i 1) isFirst (cons c chars)))
               (else
                (loop (+ i 1) #t (cons c chars)))))
             ((Mn Me Cf Lm Sk)
              (loop (+ i 1) isFirst (cons c chars)))
             (else
              (loop (+ i 1) #t (cons c chars)))))))
    (loop 0 #t '())))

; FIXME
; I think this is correct, but it should be made to run twice
; as fast for ASCII strings.

(define (string-foldcase s)
  (string-downcase (string-upcase s)))

; FIXME
; String normalizations will go here,
; but are not yet implemented.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Help procedures and tables (not part of SRFI 75)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
; For R6RS, these can be replaced by the corresponding
; operations on bytes.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

; Given an exact integer key and a bytevector of 16-bit unsigned
; big-endian integers in strictly increasing order,
; returns i such that elements (* 2 i) and (+ (* 2 i) 1)
; are equal to the key, or returns #f if the key is not found.

(define (binary-search-16bit key bytes)

  (define (bytes-ref16 bytes i)
    (let ((i2 (+ i i)))
      (+ (* 256 (bytevector-ref bytes i2))
         (bytevector-ref bytes (+ i2 1)))))

  (define (loop i j)
    (let ((mid (quotient (+ i j) 2)))
      (cond ((= i mid)
             (if (= (bytes-ref16 bytes mid) key)
                 mid
                 #f))
            ((<= (bytes-ref16 bytes mid) key)
             (loop mid j))
            (else
             (loop i mid)))))

  (let ((hi (quotient (bytevector-length bytes) 2)))
    (if (or (= hi 0) (< key (bytes-ref16 bytes 0)))
        #f
        (loop 0 hi))))

; Given:
;
;     s:       the string whose case is being converted
;     i:       an exact integer index into or past s
;     mapped:  a list of characters and strings
;     n2:      an exact integer
;     caser:   a simple case mapping
;     table:   a table of special mappings
;
; such that:
;
;     0 <= i <= (string-length s)
;     (substring s 0 i) maps to (concatenation (reverse mapped))
;     n2 = (string-length (concatenation (reverse mapped)))
;     caser is char-downcase, char-upcase, or char-titlecase
;     table is one of
;         special-lowercase-mapping
;         special-uppercase-mapping
;         special-titlecase-mapping
;
; where (concatenation things)
;     = (apply string-append
;              (map (lambda (x) (if (char? x) (string x) x))
;                   things))
;
; Returns: the cased version of s.

(define (slow-caser s i mapped n2 caser table)
  (if (< i (string-length s))
      (let* ((c (string-ref s i))
             (cp (char->integer c)))
        (if (< cp #x00df)
            (slow-caser s
                        (+ i 1)
                        (cons (caser c) mapped)
                        (+ n2 1)
                        caser
                        table)
            (let ((probe (binary-search-16bit cp special-case-chars)))
              (if probe
                  (let ((c2 (vector-ref table probe)))
                    ; Special handling of Greek capital sigma
                    ; when converting to lower case.
                    (if (and (char? c2)
                             (= cp #x03a3)           ; capital sigma
                             (= (char->integer c2)
                                #x03c2))             ; small final sigma
                        ; Is the capital sigma the last letter of a word?
                        (let ((c3 (if (final-letter? s i)
                                      c2
                                      (integer->char #x03c3))))
                          (slow-caser s
                                      (+ i 1)
                                      (cons c3 mapped)
                                      (+ n2 1)
                                      caser
                                      table))
                        (slow-caser s
                                    (+ i 1)
                                    (cons c2 mapped)
                                    (+ n2
                                       (if (char? c2)
                                           1
                                           (string-length c2)))
                                    caser
                                    table)))
                  (slow-caser s
                              (+ i 1)
                              (cons (caser c) mapped)
                              (+ n2 1)
                              caser
                              table)))))
      (let ((s2 (make-string n2)))
        (define (loop i mapped)
          (if (null? mapped)
              s2
              (let ((c2 (car mapped)))
                (if (char? c2)
                    (let ((i1 (- i 1)))
                      (string-set! s2 i1 c2)
                      (loop i1 (cdr mapped)))
                    (do ((j (- (string-length c2) 1) (- j 1))
                         (i (- i 1) (- i 1)))
                        ((< j 0)
                         (loop i (cdr mapped)))
                      (string-set! s2 i (string-ref c2 j)))))))
        (loop n2 mapped))))

; Given a string s and an index i into s,
; returns #t if and only if (string-ref s i) is the final letter
; in a word.

(define (final-letter? s i)
  (let ((i1 (+ i 1)))
    (or (>= i1 (string-length s))
        (let* ((c (string-ref s i1))
               (category (char-general-category c)))
          (case category
            ((Lu Ll Lt) #f)
            ((Po Pf)
             (case (char->integer c)
               ; The MidLetter characters are:
               ; apostrophe, middle dot,
               ; Hebrew punctuation GERSHAYIM,
               ; right single quotation mark,
               ; hyphenation point, colon
               ((#x0027 #x00b7 #x05f4 #x2019 #x2027 #x003a)
                (final-letter? s i1))
               (else #t)))
            (else #t))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Unicode general properties.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Simple case conversions.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This bytevector uses two bytes per code point
; to list all 16-bit code points, in increasing order,
; that have a simple uppercase mapping.
;
; This table occupies about 1728 bytes.

(define simple-upcase-chars (make-bytevector 0))

; The bytes of this bytevector are indexes into
; the simple-case-adjustments vector, and correspond
; to the code points (pairs of bytes) in simple-upcase-chars.
;
; This table occupies about 872 bytes.

(define simple-upcase-adjustments (make-bytevector 0))

; This bytevector uses two bytes per code point
; to list all 16-bit code points, in increasing order,
; that have a simple lowercase mapping.
;
; This table occupies about 1712 bytes.

(define simple-downcase-chars (make-bytevector 0))

; The bytes of this bytevector are indexes into
; the simple-case-adjustments vector, and correspond
; to the code points (pairs of bytes) in simple-downcase-chars.
;
; This table occupies about 864 bytes.

(define simple-downcase-adjustments (make-bytevector 0))

; This vector contains the numerical adjustments to make
; when converting a character from one case to another.
; For conversions to uppercase or titlecase, add the
; adjustment contained in this vector.
; For conversions to lowercase, subtract the adjustment
; contained in this vector.
;
; This table contains 59 elements, and occupies about 248 bytes.

(define simple-case-adjustments (make-vector 0))

; Initialization of the above tables must compute the
; distinct adjustments for the shared table of
; simple-case-adjustments.

(let ((simple-upcase-mappings
       '(
         (#x61 #x0041)
         (#x62 #x0042)
         (#x63 #x0043)
         (#x64 #x0044)
         (#x65 #x0045)
         (#x66 #x0046)
         (#x67 #x0047)
         (#x68 #x0048)
         (#x69 #x0049)
         (#x6a #x004A)
         (#x6b #x004B)
         (#x6c #x004C)
         (#x6d #x004D)
         (#x6e #x004E)
         (#x6f #x004F)
         (#x70 #x0050)
         (#x71 #x0051)
         (#x72 #x0052)
         (#x73 #x0053)
         (#x74 #x0054)
         (#x75 #x0055)
         (#x76 #x0056)
         (#x77 #x0057)
         (#x78 #x0058)
         (#x79 #x0059)
         (#x7a #x005A)
         (#xb5 #x039C)
         (#xe0 #x00C0)
         (#xe1 #x00C1)
         (#xe2 #x00C2)
         (#xe3 #x00C3)
         (#xe4 #x00C4)
         (#xe5 #x00C5)
         (#xe6 #x00C6)
         (#xe7 #x00C7)
         (#xe8 #x00C8)
         (#xe9 #x00C9)
         (#xea #x00CA)
         (#xeb #x00CB)
         (#xec #x00CC)
         (#xed #x00CD)
         (#xee #x00CE)
         (#xef #x00CF)
         (#xf0 #x00D0)
         (#xf1 #x00D1)
         (#xf2 #x00D2)
         (#xf3 #x00D3)
         (#xf4 #x00D4)
         (#xf5 #x00D5)
         (#xf6 #x00D6)
         (#xf8 #x00D8)
         (#xf9 #x00D9)
         (#xfa #x00DA)
         (#xfb #x00DB)
         (#xfc #x00DC)
         (#xfd #x00DD)
         (#xfe #x00DE)
         (#xff #x0178)
         (#x101 #x0100)
         (#x103 #x0102)
         (#x105 #x0104)
         (#x107 #x0106)
         (#x109 #x0108)
         (#x10b #x010A)
         (#x10d #x010C)
         (#x10f #x010E)
         (#x111 #x0110)
         (#x113 #x0112)
         (#x115 #x0114)
         (#x117 #x0116)
         (#x119 #x0118)
         (#x11b #x011A)
         (#x11d #x011C)
         (#x11f #x011E)
         (#x121 #x0120)
         (#x123 #x0122)
         (#x125 #x0124)
         (#x127 #x0126)
         (#x129 #x0128)
         (#x12b #x012A)
         (#x12d #x012C)
         (#x12f #x012E)
         (#x131 #x0049)
         (#x133 #x0132)
         (#x135 #x0134)
         (#x137 #x0136)
         (#x13a #x0139)
         (#x13c #x013B)
         (#x13e #x013D)
         (#x140 #x013F)
         (#x142 #x0141)
         (#x144 #x0143)
         (#x146 #x0145)
         (#x148 #x0147)
         (#x14b #x014A)
         (#x14d #x014C)
         (#x14f #x014E)
         (#x151 #x0150)
         (#x153 #x0152)
         (#x155 #x0154)
         (#x157 #x0156)
         (#x159 #x0158)
         (#x15b #x015A)
         (#x15d #x015C)
         (#x15f #x015E)
         (#x161 #x0160)
         (#x163 #x0162)
         (#x165 #x0164)
         (#x167 #x0166)
         (#x169 #x0168)
         (#x16b #x016A)
         (#x16d #x016C)
         (#x16f #x016E)
         (#x171 #x0170)
         (#x173 #x0172)
         (#x175 #x0174)
         (#x177 #x0176)
         (#x17a #x0179)
         (#x17c #x017B)
         (#x17e #x017D)
         (#x17f #x0053)
         (#x183 #x0182)
         (#x185 #x0184)
         (#x188 #x0187)
         (#x18c #x018B)
         (#x192 #x0191)
         (#x195 #x01F6)
         (#x199 #x0198)
         (#x19a #x023D)
         (#x19e #x0220)
         (#x1a1 #x01A0)
         (#x1a3 #x01A2)
         (#x1a5 #x01A4)
         (#x1a8 #x01A7)
         (#x1ad #x01AC)
         (#x1b0 #x01AF)
         (#x1b4 #x01B3)
         (#x1b6 #x01B5)
         (#x1b9 #x01B8)
         (#x1bd #x01BC)
         (#x1bf #x01F7)
         (#x1c5 #x01C4)
         (#x1c6 #x01C4)
         (#x1c8 #x01C7)
         (#x1c9 #x01C7)
         (#x1cb #x01CA)
         (#x1cc #x01CA)
         (#x1ce #x01CD)
         (#x1d0 #x01CF)
         (#x1d2 #x01D1)
         (#x1d4 #x01D3)
         (#x1d6 #x01D5)
         (#x1d8 #x01D7)
         (#x1da #x01D9)
         (#x1dc #x01DB)
         (#x1dd #x018E)
         (#x1df #x01DE)
         (#x1e1 #x01E0)
         (#x1e3 #x01E2)
         (#x1e5 #x01E4)
         (#x1e7 #x01E6)
         (#x1e9 #x01E8)
         (#x1eb #x01EA)
         (#x1ed #x01EC)
         (#x1ef #x01EE)
         (#x1f2 #x01F1)
         (#x1f3 #x01F1)
         (#x1f5 #x01F4)
         (#x1f9 #x01F8)
         (#x1fb #x01FA)
         (#x1fd #x01FC)
         (#x1ff #x01FE)
         (#x201 #x0200)
         (#x203 #x0202)
         (#x205 #x0204)
         (#x207 #x0206)
         (#x209 #x0208)
         (#x20b #x020A)
         (#x20d #x020C)
         (#x20f #x020E)
         (#x211 #x0210)
         (#x213 #x0212)
         (#x215 #x0214)
         (#x217 #x0216)
         (#x219 #x0218)
         (#x21b #x021A)
         (#x21d #x021C)
         (#x21f #x021E)
         (#x223 #x0222)
         (#x225 #x0224)
         (#x227 #x0226)
         (#x229 #x0228)
         (#x22b #x022A)
         (#x22d #x022C)
         (#x22f #x022E)
         (#x231 #x0230)
         (#x233 #x0232)
         (#x23c #x023B)
         (#x253 #x0181)
         (#x254 #x0186)
         (#x256 #x0189)
         (#x257 #x018A)
         (#x259 #x018F)
         (#x25b #x0190)
         (#x260 #x0193)
         (#x263 #x0194)
         (#x268 #x0197)
         (#x269 #x0196)
         (#x26f #x019C)
         (#x272 #x019D)
         (#x275 #x019F)
         (#x280 #x01A6)
         (#x283 #x01A9)
         (#x288 #x01AE)
         (#x28a #x01B1)
         (#x28b #x01B2)
         (#x292 #x01B7)
         (#x294 #x0241)
         (#x345 #x0399)
         (#x3ac #x0386)
         (#x3ad #x0388)
         (#x3ae #x0389)
         (#x3af #x038A)
         (#x3b1 #x0391)
         (#x3b2 #x0392)
         (#x3b3 #x0393)
         (#x3b4 #x0394)
         (#x3b5 #x0395)
         (#x3b6 #x0396)
         (#x3b7 #x0397)
         (#x3b8 #x0398)
         (#x3b9 #x0399)
         (#x3ba #x039A)
         (#x3bb #x039B)
         (#x3bc #x039C)
         (#x3bd #x039D)
         (#x3be #x039E)
         (#x3bf #x039F)
         (#x3c0 #x03A0)
         (#x3c1 #x03A1)
         (#x3c2 #x03A3)
         (#x3c3 #x03A3)
         (#x3c4 #x03A4)
         (#x3c5 #x03A5)
         (#x3c6 #x03A6)
         (#x3c7 #x03A7)
         (#x3c8 #x03A8)
         (#x3c9 #x03A9)
         (#x3ca #x03AA)
         (#x3cb #x03AB)
         (#x3cc #x038C)
         (#x3cd #x038E)
         (#x3ce #x038F)
         (#x3d0 #x0392)
         (#x3d1 #x0398)
         (#x3d5 #x03A6)
         (#x3d6 #x03A0)
         (#x3d9 #x03D8)
         (#x3db #x03DA)
         (#x3dd #x03DC)
         (#x3df #x03DE)
         (#x3e1 #x03E0)
         (#x3e3 #x03E2)
         (#x3e5 #x03E4)
         (#x3e7 #x03E6)
         (#x3e9 #x03E8)
         (#x3eb #x03EA)
         (#x3ed #x03EC)
         (#x3ef #x03EE)
         (#x3f0 #x039A)
         (#x3f1 #x03A1)
         (#x3f2 #x03F9)
         (#x3f5 #x0395)
         (#x3f8 #x03F7)
         (#x3fb #x03FA)
         (#x430 #x0410)
         (#x431 #x0411)
         (#x432 #x0412)
         (#x433 #x0413)
         (#x434 #x0414)
         (#x435 #x0415)
         (#x436 #x0416)
         (#x437 #x0417)
         (#x438 #x0418)
         (#x439 #x0419)
         (#x43a #x041A)
         (#x43b #x041B)
         (#x43c #x041C)
         (#x43d #x041D)
         (#x43e #x041E)
         (#x43f #x041F)
         (#x440 #x0420)
         (#x441 #x0421)
         (#x442 #x0422)
         (#x443 #x0423)
         (#x444 #x0424)
         (#x445 #x0425)
         (#x446 #x0426)
         (#x447 #x0427)
         (#x448 #x0428)
         (#x449 #x0429)
         (#x44a #x042A)
         (#x44b #x042B)
         (#x44c #x042C)
         (#x44d #x042D)
         (#x44e #x042E)
         (#x44f #x042F)
         (#x450 #x0400)
         (#x451 #x0401)
         (#x452 #x0402)
         (#x453 #x0403)
         (#x454 #x0404)
         (#x455 #x0405)
         (#x456 #x0406)
         (#x457 #x0407)
         (#x458 #x0408)
         (#x459 #x0409)
         (#x45a #x040A)
         (#x45b #x040B)
         (#x45c #x040C)
         (#x45d #x040D)
         (#x45e #x040E)
         (#x45f #x040F)
         (#x461 #x0460)
         (#x463 #x0462)
         (#x465 #x0464)
         (#x467 #x0466)
         (#x469 #x0468)
         (#x46b #x046A)
         (#x46d #x046C)
         (#x46f #x046E)
         (#x471 #x0470)
         (#x473 #x0472)
         (#x475 #x0474)
         (#x477 #x0476)
         (#x479 #x0478)
         (#x47b #x047A)
         (#x47d #x047C)
         (#x47f #x047E)
         (#x481 #x0480)
         (#x48b #x048A)
         (#x48d #x048C)
         (#x48f #x048E)
         (#x491 #x0490)
         (#x493 #x0492)
         (#x495 #x0494)
         (#x497 #x0496)
         (#x499 #x0498)
         (#x49b #x049A)
         (#x49d #x049C)
         (#x49f #x049E)
         (#x4a1 #x04A0)
         (#x4a3 #x04A2)
         (#x4a5 #x04A4)
         (#x4a7 #x04A6)
         (#x4a9 #x04A8)
         (#x4ab #x04AA)
         (#x4ad #x04AC)
         (#x4af #x04AE)
         (#x4b1 #x04B0)
         (#x4b3 #x04B2)
         (#x4b5 #x04B4)
         (#x4b7 #x04B6)
         (#x4b9 #x04B8)
         (#x4bb #x04BA)
         (#x4bd #x04BC)
         (#x4bf #x04BE)
         (#x4c2 #x04C1)
         (#x4c4 #x04C3)
         (#x4c6 #x04C5)
         (#x4c8 #x04C7)
         (#x4ca #x04C9)
         (#x4cc #x04CB)
         (#x4ce #x04CD)
         (#x4d1 #x04D0)
         (#x4d3 #x04D2)
         (#x4d5 #x04D4)
         (#x4d7 #x04D6)
         (#x4d9 #x04D8)
         (#x4db #x04DA)
         (#x4dd #x04DC)
         (#x4df #x04DE)
         (#x4e1 #x04E0)
         (#x4e3 #x04E2)
         (#x4e5 #x04E4)
         (#x4e7 #x04E6)
         (#x4e9 #x04E8)
         (#x4eb #x04EA)
         (#x4ed #x04EC)
         (#x4ef #x04EE)
         (#x4f1 #x04F0)
         (#x4f3 #x04F2)
         (#x4f5 #x04F4)
         (#x4f7 #x04F6)
         (#x4f9 #x04F8)
         (#x501 #x0500)
         (#x503 #x0502)
         (#x505 #x0504)
         (#x507 #x0506)
         (#x509 #x0508)
         (#x50b #x050A)
         (#x50d #x050C)
         (#x50f #x050E)
         (#x561 #x0531)
         (#x562 #x0532)
         (#x563 #x0533)
         (#x564 #x0534)
         (#x565 #x0535)
         (#x566 #x0536)
         (#x567 #x0537)
         (#x568 #x0538)
         (#x569 #x0539)
         (#x56a #x053A)
         (#x56b #x053B)
         (#x56c #x053C)
         (#x56d #x053D)
         (#x56e #x053E)
         (#x56f #x053F)
         (#x570 #x0540)
         (#x571 #x0541)
         (#x572 #x0542)
         (#x573 #x0543)
         (#x574 #x0544)
         (#x575 #x0545)
         (#x576 #x0546)
         (#x577 #x0547)
         (#x578 #x0548)
         (#x579 #x0549)
         (#x57a #x054A)
         (#x57b #x054B)
         (#x57c #x054C)
         (#x57d #x054D)
         (#x57e #x054E)
         (#x57f #x054F)
         (#x580 #x0550)
         (#x581 #x0551)
         (#x582 #x0552)
         (#x583 #x0553)
         (#x584 #x0554)
         (#x585 #x0555)
         (#x586 #x0556)
         (#x1e01 #x1E00)
         (#x1e03 #x1E02)
         (#x1e05 #x1E04)
         (#x1e07 #x1E06)
         (#x1e09 #x1E08)
         (#x1e0b #x1E0A)
         (#x1e0d #x1E0C)
         (#x1e0f #x1E0E)
         (#x1e11 #x1E10)
         (#x1e13 #x1E12)
         (#x1e15 #x1E14)
         (#x1e17 #x1E16)
         (#x1e19 #x1E18)
         (#x1e1b #x1E1A)
         (#x1e1d #x1E1C)
         (#x1e1f #x1E1E)
         (#x1e21 #x1E20)
         (#x1e23 #x1E22)
         (#x1e25 #x1E24)
         (#x1e27 #x1E26)
         (#x1e29 #x1E28)
         (#x1e2b #x1E2A)
         (#x1e2d #x1E2C)
         (#x1e2f #x1E2E)
         (#x1e31 #x1E30)
         (#x1e33 #x1E32)
         (#x1e35 #x1E34)
         (#x1e37 #x1E36)
         (#x1e39 #x1E38)
         (#x1e3b #x1E3A)
         (#x1e3d #x1E3C)
         (#x1e3f #x1E3E)
         (#x1e41 #x1E40)
         (#x1e43 #x1E42)
         (#x1e45 #x1E44)
         (#x1e47 #x1E46)
         (#x1e49 #x1E48)
         (#x1e4b #x1E4A)
         (#x1e4d #x1E4C)
         (#x1e4f #x1E4E)
         (#x1e51 #x1E50)
         (#x1e53 #x1E52)
         (#x1e55 #x1E54)
         (#x1e57 #x1E56)
         (#x1e59 #x1E58)
         (#x1e5b #x1E5A)
         (#x1e5d #x1E5C)
         (#x1e5f #x1E5E)
         (#x1e61 #x1E60)
         (#x1e63 #x1E62)
         (#x1e65 #x1E64)
         (#x1e67 #x1E66)
         (#x1e69 #x1E68)
         (#x1e6b #x1E6A)
         (#x1e6d #x1E6C)
         (#x1e6f #x1E6E)
         (#x1e71 #x1E70)
         (#x1e73 #x1E72)
         (#x1e75 #x1E74)
         (#x1e77 #x1E76)
         (#x1e79 #x1E78)
         (#x1e7b #x1E7A)
         (#x1e7d #x1E7C)
         (#x1e7f #x1E7E)
         (#x1e81 #x1E80)
         (#x1e83 #x1E82)
         (#x1e85 #x1E84)
         (#x1e87 #x1E86)
         (#x1e89 #x1E88)
         (#x1e8b #x1E8A)
         (#x1e8d #x1E8C)
         (#x1e8f #x1E8E)
         (#x1e91 #x1E90)
         (#x1e93 #x1E92)
         (#x1e95 #x1E94)
         (#x1e9b #x1E60)
         (#x1ea1 #x1EA0)
         (#x1ea3 #x1EA2)
         (#x1ea5 #x1EA4)
         (#x1ea7 #x1EA6)
         (#x1ea9 #x1EA8)
         (#x1eab #x1EAA)
         (#x1ead #x1EAC)
         (#x1eaf #x1EAE)
         (#x1eb1 #x1EB0)
         (#x1eb3 #x1EB2)
         (#x1eb5 #x1EB4)
         (#x1eb7 #x1EB6)
         (#x1eb9 #x1EB8)
         (#x1ebb #x1EBA)
         (#x1ebd #x1EBC)
         (#x1ebf #x1EBE)
         (#x1ec1 #x1EC0)
         (#x1ec3 #x1EC2)
         (#x1ec5 #x1EC4)
         (#x1ec7 #x1EC6)
         (#x1ec9 #x1EC8)
         (#x1ecb #x1ECA)
         (#x1ecd #x1ECC)
         (#x1ecf #x1ECE)
         (#x1ed1 #x1ED0)
         (#x1ed3 #x1ED2)
         (#x1ed5 #x1ED4)
         (#x1ed7 #x1ED6)
         (#x1ed9 #x1ED8)
         (#x1edb #x1EDA)
         (#x1edd #x1EDC)
         (#x1edf #x1EDE)
         (#x1ee1 #x1EE0)
         (#x1ee3 #x1EE2)
         (#x1ee5 #x1EE4)
         (#x1ee7 #x1EE6)
         (#x1ee9 #x1EE8)
         (#x1eeb #x1EEA)
         (#x1eed #x1EEC)
         (#x1eef #x1EEE)
         (#x1ef1 #x1EF0)
         (#x1ef3 #x1EF2)
         (#x1ef5 #x1EF4)
         (#x1ef7 #x1EF6)
         (#x1ef9 #x1EF8)
         (#x1f00 #x1F08)
         (#x1f01 #x1F09)
         (#x1f02 #x1F0A)
         (#x1f03 #x1F0B)
         (#x1f04 #x1F0C)
         (#x1f05 #x1F0D)
         (#x1f06 #x1F0E)
         (#x1f07 #x1F0F)
         (#x1f10 #x1F18)
         (#x1f11 #x1F19)
         (#x1f12 #x1F1A)
         (#x1f13 #x1F1B)
         (#x1f14 #x1F1C)
         (#x1f15 #x1F1D)
         (#x1f20 #x1F28)
         (#x1f21 #x1F29)
         (#x1f22 #x1F2A)
         (#x1f23 #x1F2B)
         (#x1f24 #x1F2C)
         (#x1f25 #x1F2D)
         (#x1f26 #x1F2E)
         (#x1f27 #x1F2F)
         (#x1f30 #x1F38)
         (#x1f31 #x1F39)
         (#x1f32 #x1F3A)
         (#x1f33 #x1F3B)
         (#x1f34 #x1F3C)
         (#x1f35 #x1F3D)
         (#x1f36 #x1F3E)
         (#x1f37 #x1F3F)
         (#x1f40 #x1F48)
         (#x1f41 #x1F49)
         (#x1f42 #x1F4A)
         (#x1f43 #x1F4B)
         (#x1f44 #x1F4C)
         (#x1f45 #x1F4D)
         (#x1f51 #x1F59)
         (#x1f53 #x1F5B)
         (#x1f55 #x1F5D)
         (#x1f57 #x1F5F)
         (#x1f60 #x1F68)
         (#x1f61 #x1F69)
         (#x1f62 #x1F6A)
         (#x1f63 #x1F6B)
         (#x1f64 #x1F6C)
         (#x1f65 #x1F6D)
         (#x1f66 #x1F6E)
         (#x1f67 #x1F6F)
         (#x1f70 #x1FBA)
         (#x1f71 #x1FBB)
         (#x1f72 #x1FC8)
         (#x1f73 #x1FC9)
         (#x1f74 #x1FCA)
         (#x1f75 #x1FCB)
         (#x1f76 #x1FDA)
         (#x1f77 #x1FDB)
         (#x1f78 #x1FF8)
         (#x1f79 #x1FF9)
         (#x1f7a #x1FEA)
         (#x1f7b #x1FEB)
         (#x1f7c #x1FFA)
         (#x1f7d #x1FFB)
         (#x1f80 #x1F88)
         (#x1f81 #x1F89)
         (#x1f82 #x1F8A)
         (#x1f83 #x1F8B)
         (#x1f84 #x1F8C)
         (#x1f85 #x1F8D)
         (#x1f86 #x1F8E)
         (#x1f87 #x1F8F)
         (#x1f90 #x1F98)
         (#x1f91 #x1F99)
         (#x1f92 #x1F9A)
         (#x1f93 #x1F9B)
         (#x1f94 #x1F9C)
         (#x1f95 #x1F9D)
         (#x1f96 #x1F9E)
         (#x1f97 #x1F9F)
         (#x1fa0 #x1FA8)
         (#x1fa1 #x1FA9)
         (#x1fa2 #x1FAA)
         (#x1fa3 #x1FAB)
         (#x1fa4 #x1FAC)
         (#x1fa5 #x1FAD)
         (#x1fa6 #x1FAE)
         (#x1fa7 #x1FAF)
         (#x1fb0 #x1FB8)
         (#x1fb1 #x1FB9)
         (#x1fb3 #x1FBC)
         (#x1fbe #x0399)
         (#x1fc3 #x1FCC)
         (#x1fd0 #x1FD8)
         (#x1fd1 #x1FD9)
         (#x1fe0 #x1FE8)
         (#x1fe1 #x1FE9)
         (#x1fe5 #x1FEC)
         (#x1ff3 #x1FFC)
         (#x2170 #x2160)
         (#x2171 #x2161)
         (#x2172 #x2162)
         (#x2173 #x2163)
         (#x2174 #x2164)
         (#x2175 #x2165)
         (#x2176 #x2166)
         (#x2177 #x2167)
         (#x2178 #x2168)
         (#x2179 #x2169)
         (#x217a #x216A)
         (#x217b #x216B)
         (#x217c #x216C)
         (#x217d #x216D)
         (#x217e #x216E)
         (#x217f #x216F)
         (#x24d0 #x24B6)
         (#x24d1 #x24B7)
         (#x24d2 #x24B8)
         (#x24d3 #x24B9)
         (#x24d4 #x24BA)
         (#x24d5 #x24BB)
         (#x24d6 #x24BC)
         (#x24d7 #x24BD)
         (#x24d8 #x24BE)
         (#x24d9 #x24BF)
         (#x24da #x24C0)
         (#x24db #x24C1)
         (#x24dc #x24C2)
         (#x24dd #x24C3)
         (#x24de #x24C4)
         (#x24df #x24C5)
         (#x24e0 #x24C6)
         (#x24e1 #x24C7)
         (#x24e2 #x24C8)
         (#x24e3 #x24C9)
         (#x24e4 #x24CA)
         (#x24e5 #x24CB)
         (#x24e6 #x24CC)
         (#x24e7 #x24CD)
         (#x24e8 #x24CE)
         (#x24e9 #x24CF)
         (#x2c30 #x2C00)
         (#x2c31 #x2C01)
         (#x2c32 #x2C02)
         (#x2c33 #x2C03)
         (#x2c34 #x2C04)
         (#x2c35 #x2C05)
         (#x2c36 #x2C06)
         (#x2c37 #x2C07)
         (#x2c38 #x2C08)
         (#x2c39 #x2C09)
         (#x2c3a #x2C0A)
         (#x2c3b #x2C0B)
         (#x2c3c #x2C0C)
         (#x2c3d #x2C0D)
         (#x2c3e #x2C0E)
         (#x2c3f #x2C0F)
         (#x2c40 #x2C10)
         (#x2c41 #x2C11)
         (#x2c42 #x2C12)
         (#x2c43 #x2C13)
         (#x2c44 #x2C14)
         (#x2c45 #x2C15)
         (#x2c46 #x2C16)
         (#x2c47 #x2C17)
         (#x2c48 #x2C18)
         (#x2c49 #x2C19)
         (#x2c4a #x2C1A)
         (#x2c4b #x2C1B)
         (#x2c4c #x2C1C)
         (#x2c4d #x2C1D)
         (#x2c4e #x2C1E)
         (#x2c4f #x2C1F)
         (#x2c50 #x2C20)
         (#x2c51 #x2C21)
         (#x2c52 #x2C22)
         (#x2c53 #x2C23)
         (#x2c54 #x2C24)
         (#x2c55 #x2C25)
         (#x2c56 #x2C26)
         (#x2c57 #x2C27)
         (#x2c58 #x2C28)
         (#x2c59 #x2C29)
         (#x2c5a #x2C2A)
         (#x2c5b #x2C2B)
         (#x2c5c #x2C2C)
         (#x2c5d #x2C2D)
         (#x2c5e #x2C2E)
         (#x2c81 #x2C80)
         (#x2c83 #x2C82)
         (#x2c85 #x2C84)
         (#x2c87 #x2C86)
         (#x2c89 #x2C88)
         (#x2c8b #x2C8A)
         (#x2c8d #x2C8C)
         (#x2c8f #x2C8E)
         (#x2c91 #x2C90)
         (#x2c93 #x2C92)
         (#x2c95 #x2C94)
         (#x2c97 #x2C96)
         (#x2c99 #x2C98)
         (#x2c9b #x2C9A)
         (#x2c9d #x2C9C)
         (#x2c9f #x2C9E)
         (#x2ca1 #x2CA0)
         (#x2ca3 #x2CA2)
         (#x2ca5 #x2CA4)
         (#x2ca7 #x2CA6)
         (#x2ca9 #x2CA8)
         (#x2cab #x2CAA)
         (#x2cad #x2CAC)
         (#x2caf #x2CAE)
         (#x2cb1 #x2CB0)
         (#x2cb3 #x2CB2)
         (#x2cb5 #x2CB4)
         (#x2cb7 #x2CB6)
         (#x2cb9 #x2CB8)
         (#x2cbb #x2CBA)
         (#x2cbd #x2CBC)
         (#x2cbf #x2CBE)
         (#x2cc1 #x2CC0)
         (#x2cc3 #x2CC2)
         (#x2cc5 #x2CC4)
         (#x2cc7 #x2CC6)
         (#x2cc9 #x2CC8)
         (#x2ccb #x2CCA)
         (#x2ccd #x2CCC)
         (#x2ccf #x2CCE)
         (#x2cd1 #x2CD0)
         (#x2cd3 #x2CD2)
         (#x2cd5 #x2CD4)
         (#x2cd7 #x2CD6)
         (#x2cd9 #x2CD8)
         (#x2cdb #x2CDA)
         (#x2cdd #x2CDC)
         (#x2cdf #x2CDE)
         (#x2ce1 #x2CE0)
         (#x2ce3 #x2CE2)
         (#x2d00 #x10A0)
         (#x2d01 #x10A1)
         (#x2d02 #x10A2)
         (#x2d03 #x10A3)
         (#x2d04 #x10A4)
         (#x2d05 #x10A5)
         (#x2d06 #x10A6)
         (#x2d07 #x10A7)
         (#x2d08 #x10A8)
         (#x2d09 #x10A9)
         (#x2d0a #x10AA)
         (#x2d0b #x10AB)
         (#x2d0c #x10AC)
         (#x2d0d #x10AD)
         (#x2d0e #x10AE)
         (#x2d0f #x10AF)
         (#x2d10 #x10B0)
         (#x2d11 #x10B1)
         (#x2d12 #x10B2)
         (#x2d13 #x10B3)
         (#x2d14 #x10B4)
         (#x2d15 #x10B5)
         (#x2d16 #x10B6)
         (#x2d17 #x10B7)
         (#x2d18 #x10B8)
         (#x2d19 #x10B9)
         (#x2d1a #x10BA)
         (#x2d1b #x10BB)
         (#x2d1c #x10BC)
         (#x2d1d #x10BD)
         (#x2d1e #x10BE)
         (#x2d1f #x10BF)
         (#x2d20 #x10C0)
         (#x2d21 #x10C1)
         (#x2d22 #x10C2)
         (#x2d23 #x10C3)
         (#x2d24 #x10C4)
         (#x2d25 #x10C5)
         (#xff41 #xFF21)
         (#xff42 #xFF22)
         (#xff43 #xFF23)
         (#xff44 #xFF24)
         (#xff45 #xFF25)
         (#xff46 #xFF26)
         (#xff47 #xFF27)
         (#xff48 #xFF28)
         (#xff49 #xFF29)
         (#xff4a #xFF2A)
         (#xff4b #xFF2B)
         (#xff4c #xFF2C)
         (#xff4d #xFF2D)
         (#xff4e #xFF2E)
         (#xff4f #xFF2F)
         (#xff50 #xFF30)
         (#xff51 #xFF31)
         (#xff52 #xFF32)
         (#xff53 #xFF33)
         (#xff54 #xFF34)
         (#xff55 #xFF35)
         (#xff56 #xFF36)
         (#xff57 #xFF37)
         (#xff58 #xFF38)
         (#xff59 #xFF39)
         (#xff5a #xFF3A)))

      (simple-downcase-mappings
       '(
         (#x41 #x0061)
         (#x42 #x0062)
         (#x43 #x0063)
         (#x44 #x0064)
         (#x45 #x0065)
         (#x46 #x0066)
         (#x47 #x0067)
         (#x48 #x0068)
         (#x49 #x0069)
         (#x4a #x006A)
         (#x4b #x006B)
         (#x4c #x006C)
         (#x4d #x006D)
         (#x4e #x006E)
         (#x4f #x006F)
         (#x50 #x0070)
         (#x51 #x0071)
         (#x52 #x0072)
         (#x53 #x0073)
         (#x54 #x0074)
         (#x55 #x0075)
         (#x56 #x0076)
         (#x57 #x0077)
         (#x58 #x0078)
         (#x59 #x0079)
         (#x5a #x007A)
         (#xc0 #x00E0)
         (#xc1 #x00E1)
         (#xc2 #x00E2)
         (#xc3 #x00E3)
         (#xc4 #x00E4)
         (#xc5 #x00E5)
         (#xc6 #x00E6)
         (#xc7 #x00E7)
         (#xc8 #x00E8)
         (#xc9 #x00E9)
         (#xca #x00EA)
         (#xcb #x00EB)
         (#xcc #x00EC)
         (#xcd #x00ED)
         (#xce #x00EE)
         (#xcf #x00EF)
         (#xd0 #x00F0)
         (#xd1 #x00F1)
         (#xd2 #x00F2)
         (#xd3 #x00F3)
         (#xd4 #x00F4)
         (#xd5 #x00F5)
         (#xd6 #x00F6)
         (#xd8 #x00F8)
         (#xd9 #x00F9)
         (#xda #x00FA)
         (#xdb #x00FB)
         (#xdc #x00FC)
         (#xdd #x00FD)
         (#xde #x00FE)
         (#x100 #x0101)
         (#x102 #x0103)
         (#x104 #x0105)
         (#x106 #x0107)
         (#x108 #x0109)
         (#x10a #x010B)
         (#x10c #x010D)
         (#x10e #x010F)
         (#x110 #x0111)
         (#x112 #x0113)
         (#x114 #x0115)
         (#x116 #x0117)
         (#x118 #x0119)
         (#x11a #x011B)
         (#x11c #x011D)
         (#x11e #x011F)
         (#x120 #x0121)
         (#x122 #x0123)
         (#x124 #x0125)
         (#x126 #x0127)
         (#x128 #x0129)
         (#x12a #x012B)
         (#x12c #x012D)
         (#x12e #x012F)
         (#x130 #x0069)
         (#x132 #x0133)
         (#x134 #x0135)
         (#x136 #x0137)
         (#x139 #x013A)
         (#x13b #x013C)
         (#x13d #x013E)
         (#x13f #x0140)
         (#x141 #x0142)
         (#x143 #x0144)
         (#x145 #x0146)
         (#x147 #x0148)
         (#x14a #x014B)
         (#x14c #x014D)
         (#x14e #x014F)
         (#x150 #x0151)
         (#x152 #x0153)
         (#x154 #x0155)
         (#x156 #x0157)
         (#x158 #x0159)
         (#x15a #x015B)
         (#x15c #x015D)
         (#x15e #x015F)
         (#x160 #x0161)
         (#x162 #x0163)
         (#x164 #x0165)
         (#x166 #x0167)
         (#x168 #x0169)
         (#x16a #x016B)
         (#x16c #x016D)
         (#x16e #x016F)
         (#x170 #x0171)
         (#x172 #x0173)
         (#x174 #x0175)
         (#x176 #x0177)
         (#x178 #x00FF)
         (#x179 #x017A)
         (#x17b #x017C)
         (#x17d #x017E)
         (#x181 #x0253)
         (#x182 #x0183)
         (#x184 #x0185)
         (#x186 #x0254)
         (#x187 #x0188)
         (#x189 #x0256)
         (#x18a #x0257)
         (#x18b #x018C)
         (#x18e #x01DD)
         (#x18f #x0259)
         (#x190 #x025B)
         (#x191 #x0192)
         (#x193 #x0260)
         (#x194 #x0263)
         (#x196 #x0269)
         (#x197 #x0268)
         (#x198 #x0199)
         (#x19c #x026F)
         (#x19d #x0272)
         (#x19f #x0275)
         (#x1a0 #x01A1)
         (#x1a2 #x01A3)
         (#x1a4 #x01A5)
         (#x1a6 #x0280)
         (#x1a7 #x01A8)
         (#x1a9 #x0283)
         (#x1ac #x01AD)
         (#x1ae #x0288)
         (#x1af #x01B0)
         (#x1b1 #x028A)
         (#x1b2 #x028B)
         (#x1b3 #x01B4)
         (#x1b5 #x01B6)
         (#x1b7 #x0292)
         (#x1b8 #x01B9)
         (#x1bc #x01BD)
         (#x1c4 #x01C6)
         (#x1c5 #x01C6)
         (#x1c7 #x01C9)
         (#x1c8 #x01C9)
         (#x1ca #x01CC)
         (#x1cb #x01CC)
         (#x1cd #x01CE)
         (#x1cf #x01D0)
         (#x1d1 #x01D2)
         (#x1d3 #x01D4)
         (#x1d5 #x01D6)
         (#x1d7 #x01D8)
         (#x1d9 #x01DA)
         (#x1db #x01DC)
         (#x1de #x01DF)
         (#x1e0 #x01E1)
         (#x1e2 #x01E3)
         (#x1e4 #x01E5)
         (#x1e6 #x01E7)
         (#x1e8 #x01E9)
         (#x1ea #x01EB)
         (#x1ec #x01ED)
         (#x1ee #x01EF)
         (#x1f1 #x01F3)
         (#x1f2 #x01F3)
         (#x1f4 #x01F5)
         (#x1f6 #x0195)
         (#x1f7 #x01BF)
         (#x1f8 #x01F9)
         (#x1fa #x01FB)
         (#x1fc #x01FD)
         (#x1fe #x01FF)
         (#x200 #x0201)
         (#x202 #x0203)
         (#x204 #x0205)
         (#x206 #x0207)
         (#x208 #x0209)
         (#x20a #x020B)
         (#x20c #x020D)
         (#x20e #x020F)
         (#x210 #x0211)
         (#x212 #x0213)
         (#x214 #x0215)
         (#x216 #x0217)
         (#x218 #x0219)
         (#x21a #x021B)
         (#x21c #x021D)
         (#x21e #x021F)
         (#x220 #x019E)
         (#x222 #x0223)
         (#x224 #x0225)
         (#x226 #x0227)
         (#x228 #x0229)
         (#x22a #x022B)
         (#x22c #x022D)
         (#x22e #x022F)
         (#x230 #x0231)
         (#x232 #x0233)
         (#x23b #x023C)
         (#x23d #x019A)
         (#x241 #x0294)
         (#x386 #x03AC)
         (#x388 #x03AD)
         (#x389 #x03AE)
         (#x38a #x03AF)
         (#x38c #x03CC)
         (#x38e #x03CD)
         (#x38f #x03CE)
         (#x391 #x03B1)
         (#x392 #x03B2)
         (#x393 #x03B3)
         (#x394 #x03B4)
         (#x395 #x03B5)
         (#x396 #x03B6)
         (#x397 #x03B7)
         (#x398 #x03B8)
         (#x399 #x03B9)
         (#x39a #x03BA)
         (#x39b #x03BB)
         (#x39c #x03BC)
         (#x39d #x03BD)
         (#x39e #x03BE)
         (#x39f #x03BF)
         (#x3a0 #x03C0)
         (#x3a1 #x03C1)
         (#x3a3 #x03C3)
         (#x3a4 #x03C4)
         (#x3a5 #x03C5)
         (#x3a6 #x03C6)
         (#x3a7 #x03C7)
         (#x3a8 #x03C8)
         (#x3a9 #x03C9)
         (#x3aa #x03CA)
         (#x3ab #x03CB)
         (#x3d8 #x03D9)
         (#x3da #x03DB)
         (#x3dc #x03DD)
         (#x3de #x03DF)
         (#x3e0 #x03E1)
         (#x3e2 #x03E3)
         (#x3e4 #x03E5)
         (#x3e6 #x03E7)
         (#x3e8 #x03E9)
         (#x3ea #x03EB)
         (#x3ec #x03ED)
         (#x3ee #x03EF)
         (#x3f4 #x03B8)
         (#x3f7 #x03F8)
         (#x3f9 #x03F2)
         (#x3fa #x03FB)
         (#x400 #x0450)
         (#x401 #x0451)
         (#x402 #x0452)
         (#x403 #x0453)
         (#x404 #x0454)
         (#x405 #x0455)
         (#x406 #x0456)
         (#x407 #x0457)
         (#x408 #x0458)
         (#x409 #x0459)
         (#x40a #x045A)
         (#x40b #x045B)
         (#x40c #x045C)
         (#x40d #x045D)
         (#x40e #x045E)
         (#x40f #x045F)
         (#x410 #x0430)
         (#x411 #x0431)
         (#x412 #x0432)
         (#x413 #x0433)
         (#x414 #x0434)
         (#x415 #x0435)
         (#x416 #x0436)
         (#x417 #x0437)
         (#x418 #x0438)
         (#x419 #x0439)
         (#x41a #x043A)
         (#x41b #x043B)
         (#x41c #x043C)
         (#x41d #x043D)
         (#x41e #x043E)
         (#x41f #x043F)
         (#x420 #x0440)
         (#x421 #x0441)
         (#x422 #x0442)
         (#x423 #x0443)
         (#x424 #x0444)
         (#x425 #x0445)
         (#x426 #x0446)
         (#x427 #x0447)
         (#x428 #x0448)
         (#x429 #x0449)
         (#x42a #x044A)
         (#x42b #x044B)
         (#x42c #x044C)
         (#x42d #x044D)
         (#x42e #x044E)
         (#x42f #x044F)
         (#x460 #x0461)
         (#x462 #x0463)
         (#x464 #x0465)
         (#x466 #x0467)
         (#x468 #x0469)
         (#x46a #x046B)
         (#x46c #x046D)
         (#x46e #x046F)
         (#x470 #x0471)
         (#x472 #x0473)
         (#x474 #x0475)
         (#x476 #x0477)
         (#x478 #x0479)
         (#x47a #x047B)
         (#x47c #x047D)
         (#x47e #x047F)
         (#x480 #x0481)
         (#x48a #x048B)
         (#x48c #x048D)
         (#x48e #x048F)
         (#x490 #x0491)
         (#x492 #x0493)
         (#x494 #x0495)
         (#x496 #x0497)
         (#x498 #x0499)
         (#x49a #x049B)
         (#x49c #x049D)
         (#x49e #x049F)
         (#x4a0 #x04A1)
         (#x4a2 #x04A3)
         (#x4a4 #x04A5)
         (#x4a6 #x04A7)
         (#x4a8 #x04A9)
         (#x4aa #x04AB)
         (#x4ac #x04AD)
         (#x4ae #x04AF)
         (#x4b0 #x04B1)
         (#x4b2 #x04B3)
         (#x4b4 #x04B5)
         (#x4b6 #x04B7)
         (#x4b8 #x04B9)
         (#x4ba #x04BB)
         (#x4bc #x04BD)
         (#x4be #x04BF)
         (#x4c1 #x04C2)
         (#x4c3 #x04C4)
         (#x4c5 #x04C6)
         (#x4c7 #x04C8)
         (#x4c9 #x04CA)
         (#x4cb #x04CC)
         (#x4cd #x04CE)
         (#x4d0 #x04D1)
         (#x4d2 #x04D3)
         (#x4d4 #x04D5)
         (#x4d6 #x04D7)
         (#x4d8 #x04D9)
         (#x4da #x04DB)
         (#x4dc #x04DD)
         (#x4de #x04DF)
         (#x4e0 #x04E1)
         (#x4e2 #x04E3)
         (#x4e4 #x04E5)
         (#x4e6 #x04E7)
         (#x4e8 #x04E9)
         (#x4ea #x04EB)
         (#x4ec #x04ED)
         (#x4ee #x04EF)
         (#x4f0 #x04F1)
         (#x4f2 #x04F3)
         (#x4f4 #x04F5)
         (#x4f6 #x04F7)
         (#x4f8 #x04F9)
         (#x500 #x0501)
         (#x502 #x0503)
         (#x504 #x0505)
         (#x506 #x0507)
         (#x508 #x0509)
         (#x50a #x050B)
         (#x50c #x050D)
         (#x50e #x050F)
         (#x531 #x0561)
         (#x532 #x0562)
         (#x533 #x0563)
         (#x534 #x0564)
         (#x535 #x0565)
         (#x536 #x0566)
         (#x537 #x0567)
         (#x538 #x0568)
         (#x539 #x0569)
         (#x53a #x056A)
         (#x53b #x056B)
         (#x53c #x056C)
         (#x53d #x056D)
         (#x53e #x056E)
         (#x53f #x056F)
         (#x540 #x0570)
         (#x541 #x0571)
         (#x542 #x0572)
         (#x543 #x0573)
         (#x544 #x0574)
         (#x545 #x0575)
         (#x546 #x0576)
         (#x547 #x0577)
         (#x548 #x0578)
         (#x549 #x0579)
         (#x54a #x057A)
         (#x54b #x057B)
         (#x54c #x057C)
         (#x54d #x057D)
         (#x54e #x057E)
         (#x54f #x057F)
         (#x550 #x0580)
         (#x551 #x0581)
         (#x552 #x0582)
         (#x553 #x0583)
         (#x554 #x0584)
         (#x555 #x0585)
         (#x556 #x0586)
         (#x10a0 #x2D00)
         (#x10a1 #x2D01)
         (#x10a2 #x2D02)
         (#x10a3 #x2D03)
         (#x10a4 #x2D04)
         (#x10a5 #x2D05)
         (#x10a6 #x2D06)
         (#x10a7 #x2D07)
         (#x10a8 #x2D08)
         (#x10a9 #x2D09)
         (#x10aa #x2D0A)
         (#x10ab #x2D0B)
         (#x10ac #x2D0C)
         (#x10ad #x2D0D)
         (#x10ae #x2D0E)
         (#x10af #x2D0F)
         (#x10b0 #x2D10)
         (#x10b1 #x2D11)
         (#x10b2 #x2D12)
         (#x10b3 #x2D13)
         (#x10b4 #x2D14)
         (#x10b5 #x2D15)
         (#x10b6 #x2D16)
         (#x10b7 #x2D17)
         (#x10b8 #x2D18)
         (#x10b9 #x2D19)
         (#x10ba #x2D1A)
         (#x10bb #x2D1B)
         (#x10bc #x2D1C)
         (#x10bd #x2D1D)
         (#x10be #x2D1E)
         (#x10bf #x2D1F)
         (#x10c0 #x2D20)
         (#x10c1 #x2D21)
         (#x10c2 #x2D22)
         (#x10c3 #x2D23)
         (#x10c4 #x2D24)
         (#x10c5 #x2D25)
         (#x1e00 #x1E01)
         (#x1e02 #x1E03)
         (#x1e04 #x1E05)
         (#x1e06 #x1E07)
         (#x1e08 #x1E09)
         (#x1e0a #x1E0B)
         (#x1e0c #x1E0D)
         (#x1e0e #x1E0F)
         (#x1e10 #x1E11)
         (#x1e12 #x1E13)
         (#x1e14 #x1E15)
         (#x1e16 #x1E17)
         (#x1e18 #x1E19)
         (#x1e1a #x1E1B)
         (#x1e1c #x1E1D)
         (#x1e1e #x1E1F)
         (#x1e20 #x1E21)
         (#x1e22 #x1E23)
         (#x1e24 #x1E25)
         (#x1e26 #x1E27)
         (#x1e28 #x1E29)
         (#x1e2a #x1E2B)
         (#x1e2c #x1E2D)
         (#x1e2e #x1E2F)
         (#x1e30 #x1E31)
         (#x1e32 #x1E33)
         (#x1e34 #x1E35)
         (#x1e36 #x1E37)
         (#x1e38 #x1E39)
         (#x1e3a #x1E3B)
         (#x1e3c #x1E3D)
         (#x1e3e #x1E3F)
         (#x1e40 #x1E41)
         (#x1e42 #x1E43)
         (#x1e44 #x1E45)
         (#x1e46 #x1E47)
         (#x1e48 #x1E49)
         (#x1e4a #x1E4B)
         (#x1e4c #x1E4D)
         (#x1e4e #x1E4F)
         (#x1e50 #x1E51)
         (#x1e52 #x1E53)
         (#x1e54 #x1E55)
         (#x1e56 #x1E57)
         (#x1e58 #x1E59)
         (#x1e5a #x1E5B)
         (#x1e5c #x1E5D)
         (#x1e5e #x1E5F)
         (#x1e60 #x1E61)
         (#x1e62 #x1E63)
         (#x1e64 #x1E65)
         (#x1e66 #x1E67)
         (#x1e68 #x1E69)
         (#x1e6a #x1E6B)
         (#x1e6c #x1E6D)
         (#x1e6e #x1E6F)
         (#x1e70 #x1E71)
         (#x1e72 #x1E73)
         (#x1e74 #x1E75)
         (#x1e76 #x1E77)
         (#x1e78 #x1E79)
         (#x1e7a #x1E7B)
         (#x1e7c #x1E7D)
         (#x1e7e #x1E7F)
         (#x1e80 #x1E81)
         (#x1e82 #x1E83)
         (#x1e84 #x1E85)
         (#x1e86 #x1E87)
         (#x1e88 #x1E89)
         (#x1e8a #x1E8B)
         (#x1e8c #x1E8D)
         (#x1e8e #x1E8F)
         (#x1e90 #x1E91)
         (#x1e92 #x1E93)
         (#x1e94 #x1E95)
         (#x1ea0 #x1EA1)
         (#x1ea2 #x1EA3)
         (#x1ea4 #x1EA5)
         (#x1ea6 #x1EA7)
         (#x1ea8 #x1EA9)
         (#x1eaa #x1EAB)
         (#x1eac #x1EAD)
         (#x1eae #x1EAF)
         (#x1eb0 #x1EB1)
         (#x1eb2 #x1EB3)
         (#x1eb4 #x1EB5)
         (#x1eb6 #x1EB7)
         (#x1eb8 #x1EB9)
         (#x1eba #x1EBB)
         (#x1ebc #x1EBD)
         (#x1ebe #x1EBF)
         (#x1ec0 #x1EC1)
         (#x1ec2 #x1EC3)
         (#x1ec4 #x1EC5)
         (#x1ec6 #x1EC7)
         (#x1ec8 #x1EC9)
         (#x1eca #x1ECB)
         (#x1ecc #x1ECD)
         (#x1ece #x1ECF)
         (#x1ed0 #x1ED1)
         (#x1ed2 #x1ED3)
         (#x1ed4 #x1ED5)
         (#x1ed6 #x1ED7)
         (#x1ed8 #x1ED9)
         (#x1eda #x1EDB)
         (#x1edc #x1EDD)
         (#x1ede #x1EDF)
         (#x1ee0 #x1EE1)
         (#x1ee2 #x1EE3)
         (#x1ee4 #x1EE5)
         (#x1ee6 #x1EE7)
         (#x1ee8 #x1EE9)
         (#x1eea #x1EEB)
         (#x1eec #x1EED)
         (#x1eee #x1EEF)
         (#x1ef0 #x1EF1)
         (#x1ef2 #x1EF3)
         (#x1ef4 #x1EF5)
         (#x1ef6 #x1EF7)
         (#x1ef8 #x1EF9)
         (#x1f08 #x1F00)
         (#x1f09 #x1F01)
         (#x1f0a #x1F02)
         (#x1f0b #x1F03)
         (#x1f0c #x1F04)
         (#x1f0d #x1F05)
         (#x1f0e #x1F06)
         (#x1f0f #x1F07)
         (#x1f18 #x1F10)
         (#x1f19 #x1F11)
         (#x1f1a #x1F12)
         (#x1f1b #x1F13)
         (#x1f1c #x1F14)
         (#x1f1d #x1F15)
         (#x1f28 #x1F20)
         (#x1f29 #x1F21)
         (#x1f2a #x1F22)
         (#x1f2b #x1F23)
         (#x1f2c #x1F24)
         (#x1f2d #x1F25)
         (#x1f2e #x1F26)
         (#x1f2f #x1F27)
         (#x1f38 #x1F30)
         (#x1f39 #x1F31)
         (#x1f3a #x1F32)
         (#x1f3b #x1F33)
         (#x1f3c #x1F34)
         (#x1f3d #x1F35)
         (#x1f3e #x1F36)
         (#x1f3f #x1F37)
         (#x1f48 #x1F40)
         (#x1f49 #x1F41)
         (#x1f4a #x1F42)
         (#x1f4b #x1F43)
         (#x1f4c #x1F44)
         (#x1f4d #x1F45)
         (#x1f59 #x1F51)
         (#x1f5b #x1F53)
         (#x1f5d #x1F55)
         (#x1f5f #x1F57)
         (#x1f68 #x1F60)
         (#x1f69 #x1F61)
         (#x1f6a #x1F62)
         (#x1f6b #x1F63)
         (#x1f6c #x1F64)
         (#x1f6d #x1F65)
         (#x1f6e #x1F66)
         (#x1f6f #x1F67)
         (#x1f88 #x1F80)
         (#x1f89 #x1F81)
         (#x1f8a #x1F82)
         (#x1f8b #x1F83)
         (#x1f8c #x1F84)
         (#x1f8d #x1F85)
         (#x1f8e #x1F86)
         (#x1f8f #x1F87)
         (#x1f98 #x1F90)
         (#x1f99 #x1F91)
         (#x1f9a #x1F92)
         (#x1f9b #x1F93)
         (#x1f9c #x1F94)
         (#x1f9d #x1F95)
         (#x1f9e #x1F96)
         (#x1f9f #x1F97)
         (#x1fa8 #x1FA0)
         (#x1fa9 #x1FA1)
         (#x1faa #x1FA2)
         (#x1fab #x1FA3)
         (#x1fac #x1FA4)
         (#x1fad #x1FA5)
         (#x1fae #x1FA6)
         (#x1faf #x1FA7)
         (#x1fb8 #x1FB0)
         (#x1fb9 #x1FB1)
         (#x1fba #x1F70)
         (#x1fbb #x1F71)
         (#x1fbc #x1FB3)
         (#x1fc8 #x1F72)
         (#x1fc9 #x1F73)
         (#x1fca #x1F74)
         (#x1fcb #x1F75)
         (#x1fcc #x1FC3)
         (#x1fd8 #x1FD0)
         (#x1fd9 #x1FD1)
         (#x1fda #x1F76)
         (#x1fdb #x1F77)
         (#x1fe8 #x1FE0)
         (#x1fe9 #x1FE1)
         (#x1fea #x1F7A)
         (#x1feb #x1F7B)
         (#x1fec #x1FE5)
         (#x1ff8 #x1F78)
         (#x1ff9 #x1F79)
         (#x1ffa #x1F7C)
         (#x1ffb #x1F7D)
         (#x1ffc #x1FF3)
         (#x2126 #x03C9)
         (#x212a #x006B)
         (#x212b #x00E5)
         (#x2160 #x2170)
         (#x2161 #x2171)
         (#x2162 #x2172)
         (#x2163 #x2173)
         (#x2164 #x2174)
         (#x2165 #x2175)
         (#x2166 #x2176)
         (#x2167 #x2177)
         (#x2168 #x2178)
         (#x2169 #x2179)
         (#x216a #x217A)
         (#x216b #x217B)
         (#x216c #x217C)
         (#x216d #x217D)
         (#x216e #x217E)
         (#x216f #x217F)
         (#x24b6 #x24D0)
         (#x24b7 #x24D1)
         (#x24b8 #x24D2)
         (#x24b9 #x24D3)
         (#x24ba #x24D4)
         (#x24bb #x24D5)
         (#x24bc #x24D6)
         (#x24bd #x24D7)
         (#x24be #x24D8)
         (#x24bf #x24D9)
         (#x24c0 #x24DA)
         (#x24c1 #x24DB)
         (#x24c2 #x24DC)
         (#x24c3 #x24DD)
         (#x24c4 #x24DE)
         (#x24c5 #x24DF)
         (#x24c6 #x24E0)
         (#x24c7 #x24E1)
         (#x24c8 #x24E2)
         (#x24c9 #x24E3)
         (#x24ca #x24E4)
         (#x24cb #x24E5)
         (#x24cc #x24E6)
         (#x24cd #x24E7)
         (#x24ce #x24E8)
         (#x24cf #x24E9)
         (#x2c00 #x2C30)
         (#x2c01 #x2C31)
         (#x2c02 #x2C32)
         (#x2c03 #x2C33)
         (#x2c04 #x2C34)
         (#x2c05 #x2C35)
         (#x2c06 #x2C36)
         (#x2c07 #x2C37)
         (#x2c08 #x2C38)
         (#x2c09 #x2C39)
         (#x2c0a #x2C3A)
         (#x2c0b #x2C3B)
         (#x2c0c #x2C3C)
         (#x2c0d #x2C3D)
         (#x2c0e #x2C3E)
         (#x2c0f #x2C3F)
         (#x2c10 #x2C40)
         (#x2c11 #x2C41)
         (#x2c12 #x2C42)
         (#x2c13 #x2C43)
         (#x2c14 #x2C44)
         (#x2c15 #x2C45)
         (#x2c16 #x2C46)
         (#x2c17 #x2C47)
         (#x2c18 #x2C48)
         (#x2c19 #x2C49)
         (#x2c1a #x2C4A)
         (#x2c1b #x2C4B)
         (#x2c1c #x2C4C)
         (#x2c1d #x2C4D)
         (#x2c1e #x2C4E)
         (#x2c1f #x2C4F)
         (#x2c20 #x2C50)
         (#x2c21 #x2C51)
         (#x2c22 #x2C52)
         (#x2c23 #x2C53)
         (#x2c24 #x2C54)
         (#x2c25 #x2C55)
         (#x2c26 #x2C56)
         (#x2c27 #x2C57)
         (#x2c28 #x2C58)
         (#x2c29 #x2C59)
         (#x2c2a #x2C5A)
         (#x2c2b #x2C5B)
         (#x2c2c #x2C5C)
         (#x2c2d #x2C5D)
         (#x2c2e #x2C5E)
         (#x2c80 #x2C81)
         (#x2c82 #x2C83)
         (#x2c84 #x2C85)
         (#x2c86 #x2C87)
         (#x2c88 #x2C89)
         (#x2c8a #x2C8B)
         (#x2c8c #x2C8D)
         (#x2c8e #x2C8F)
         (#x2c90 #x2C91)
         (#x2c92 #x2C93)
         (#x2c94 #x2C95)
         (#x2c96 #x2C97)
         (#x2c98 #x2C99)
         (#x2c9a #x2C9B)
         (#x2c9c #x2C9D)
         (#x2c9e #x2C9F)
         (#x2ca0 #x2CA1)
         (#x2ca2 #x2CA3)
         (#x2ca4 #x2CA5)
         (#x2ca6 #x2CA7)
         (#x2ca8 #x2CA9)
         (#x2caa #x2CAB)
         (#x2cac #x2CAD)
         (#x2cae #x2CAF)
         (#x2cb0 #x2CB1)
         (#x2cb2 #x2CB3)
         (#x2cb4 #x2CB5)
         (#x2cb6 #x2CB7)
         (#x2cb8 #x2CB9)
         (#x2cba #x2CBB)
         (#x2cbc #x2CBD)
         (#x2cbe #x2CBF)
         (#x2cc0 #x2CC1)
         (#x2cc2 #x2CC3)
         (#x2cc4 #x2CC5)
         (#x2cc6 #x2CC7)
         (#x2cc8 #x2CC9)
         (#x2cca #x2CCB)
         (#x2ccc #x2CCD)
         (#x2cce #x2CCF)
         (#x2cd0 #x2CD1)
         (#x2cd2 #x2CD3)
         (#x2cd4 #x2CD5)
         (#x2cd6 #x2CD7)
         (#x2cd8 #x2CD9)
         (#x2cda #x2CDB)
         (#x2cdc #x2CDD)
         (#x2cde #x2CDF)
         (#x2ce0 #x2CE1)
         (#x2ce2 #x2CE3)
         (#xff21 #xFF41)
         (#xff22 #xFF42)
         (#xff23 #xFF43)
         (#xff24 #xFF44)
         (#xff25 #xFF45)
         (#xff26 #xFF46)
         (#xff27 #xFF47)
         (#xff28 #xFF48)
         (#xff29 #xFF49)
         (#xff2a #xFF4A)
         (#xff2b #xFF4B)
         (#xff2c #xFF4C)
         (#xff2d #xFF4D)
         (#xff2e #xFF4E)
         (#xff2f #xFF4F)
         (#xff30 #xFF50)
         (#xff31 #xFF51)
         (#xff32 #xFF52)
         (#xff33 #xFF53)
         (#xff34 #xFF54)
         (#xff35 #xFF55)
         (#xff36 #xFF56)
         (#xff37 #xFF57)
         (#xff38 #xFF58)
         (#xff39 #xFF59)
         (#xff3a #xFF5A))))

  (let ((adjustments '()))

    ; Given a list of pairs of exact integers that map
    ; code points to code points, adds the difference
    ; between the two code points to the list of adjustments
    ; if it isn't there already.

    (define (compute-distinct-adjustments! mappings)
      (for-each (lambda (mapping)
                  (let ((adjustment (- (cadr mapping) (car mapping))))
                    (if (not (memv adjustment adjustments))
                        (set! adjustments
                              (cons adjustment adjustments)))))
                mappings))

    ; Glarg.  Sorting isn't necessary, but aids debugging
    ; and may make the initialization go a little faster.

    (define (mysort xs)
      (define (insert x xs)
        (if (or (null? xs)
                (<= x (car xs)))
            (cons x xs)
            (cons (car xs)
                  (insert x (cdr xs)))))
      (define (sort xs)
        (if (null? xs)
            '()
            (insert (car xs)
                    (sort (cdr xs)))))
      (sort xs))

    ; Given a 16-bit exact integer code point, returns its low 8 bits.

    (define (lo-bits k) (remainder k 256))

    ; Given a 16-bit exact integer code point, returns its high 8 bits.

    (define (hi-bits k) (quotient k 256))

    (compute-distinct-adjustments! simple-downcase-mappings)
    (set! adjustments (map - adjustments))
    (compute-distinct-adjustments! simple-upcase-mappings)

    (set! simple-case-adjustments (list->vector (mysort adjustments)))

    (if (>= (vector-length simple-case-adjustments) 256)
        (error "Too many simple case adjustments."))

    (set! simple-upcase-adjustments
          (make-bytevector (length simple-upcase-mappings)))

    (set! simple-downcase-adjustments
          (make-bytevector (length simple-downcase-mappings)))

    (set! simple-upcase-chars
          (make-bytevector
           (* 2 (bytevector-length simple-upcase-adjustments))))

    (set! simple-downcase-chars
          (make-bytevector
           (* 2 (bytevector-length simple-downcase-adjustments))))

    (do ((i 0 (+ i 1))
         (j 0 (+ j 2))
         (mappings simple-upcase-mappings (cdr mappings)))
        ((null? mappings))
      (let* ((mapping (car mappings))
             (cp0 (car mapping))
             (cp1 (cadr mapping)))
        (bytevector-set! simple-upcase-chars j (hi-bits cp0))
        (bytevector-set! simple-upcase-chars (+ j 1) (lo-bits cp0))
        (bytevector-set! simple-upcase-adjustments
                         i
                         (binary-search-of-vector (- cp1 cp0)
                                                  simple-case-adjustments))))

    (do ((i 0 (+ i 1))
         (j 0 (+ j 2))
         (mappings simple-downcase-mappings (cdr mappings)))
        ((null? mappings))
      (let* ((mapping (car mappings))
             (cp0 (car mapping))
             (cp1 (cadr mapping)))
        (bytevector-set! simple-downcase-chars j (hi-bits cp0))
        (bytevector-set! simple-downcase-chars (+ j 1) (lo-bits cp0))
        (bytevector-set! simple-downcase-adjustments
                         i
                         (binary-search-of-vector (- cp0 cp1)
                                                  simple-case-adjustments))))

    #t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The tables below occupy about 216+(3*416)+2416 = 3880 bytes.

; This bytevector uses two bytes per code point
; to list 16-bit code points, in increasing order,
; that have anything other than a simple case mapping.
;
; The locale-dependent mappings are not in this table.
;
; This table occupies about 216 bytes.

(define special-case-chars (make-bytevector 0))

; Each code point in special-case-chars maps to the character
; or string contained in the following tables.
;
; Each of these tables contains 103 elements
; and occupies about 416 bytes, not counting
; the strings that are the elements themselves.
; At 4 bytes/character, those strings occupy about 2416 bytes.

(define special-lowercase-mapping (make-vector 0))
(define special-titlecase-mapping (make-vector 0))
(define special-uppercase-mapping (make-vector 0))

; Initialization for the tables above.
; The data is taken from SpecialCasing.txt

(let ((special-case-mappings
       '(
         ; ((<code>) (<lower>) (<title>) (<upper>))
         ((#xdf) (#x00DF) (#x0053 #x0073) (#x0053 #x0053))
         ((#x130) (#x0069 #x0307) (#x0130) (#x0130))
         ((#x149) (#x0149) (#x02BC #x004E) (#x02BC #x004E))
         ((#x1f0) (#x01F0) (#x004A #x030C) (#x004A #x030C))
         ((#x390) (#x0390) (#x0399 #x0308 #x0301) (#x0399 #x0308 #x0301))
         ; Greek capital sigma is here so it will be recognized
         ; as a special case.
         ((#x03a3) (#x03c2) (#x03a3) (#x03a3))
         ((#x3b0) (#x03B0) (#x03A5 #x0308 #x0301) (#x03A5 #x0308 #x0301))
         ((#x587) (#x0587) (#x0535 #x0582) (#x0535 #x0552))
         ((#x1e96) (#x1E96) (#x0048 #x0331) (#x0048 #x0331))
         ((#x1e97) (#x1E97) (#x0054 #x0308) (#x0054 #x0308))
         ((#x1e98) (#x1E98) (#x0057 #x030A) (#x0057 #x030A))
         ((#x1e99) (#x1E99) (#x0059 #x030A) (#x0059 #x030A))
         ((#x1e9a) (#x1E9A) (#x0041 #x02BE) (#x0041 #x02BE))
         ((#x1f50) (#x1F50) (#x03A5 #x0313) (#x03A5 #x0313))
         ((#x1f52) (#x1F52) (#x03A5 #x0313 #x0300) (#x03A5 #x0313 #x0300))
         ((#x1f54) (#x1F54) (#x03A5 #x0313 #x0301) (#x03A5 #x0313 #x0301))
         ((#x1f56) (#x1F56) (#x03A5 #x0313 #x0342) (#x03A5 #x0313 #x0342))
         ((#x1fb6) (#x1FB6) (#x0391 #x0342) (#x0391 #x0342))
         ((#x1fc6) (#x1FC6) (#x0397 #x0342) (#x0397 #x0342))
         ((#x1fd2) (#x1FD2) (#x0399 #x0308 #x0300) (#x0399 #x0308 #x0300))
         ((#x1fd3) (#x1FD3) (#x0399 #x0308 #x0301) (#x0399 #x0308 #x0301))
         ((#x1fd6) (#x1FD6) (#x0399 #x0342) (#x0399 #x0342))
         ((#x1fd7) (#x1FD7) (#x0399 #x0308 #x0342) (#x0399 #x0308 #x0342))
         ((#x1fe2) (#x1FE2) (#x03A5 #x0308 #x0300) (#x03A5 #x0308 #x0300))
         ((#x1fe3) (#x1FE3) (#x03A5 #x0308 #x0301) (#x03A5 #x0308 #x0301))
         ((#x1fe4) (#x1FE4) (#x03A1 #x0313) (#x03A1 #x0313))
         ((#x1fe6) (#x1FE6) (#x03A5 #x0342) (#x03A5 #x0342))
         ((#x1fe7) (#x1FE7) (#x03A5 #x0308 #x0342) (#x03A5 #x0308 #x0342))
         ((#x1ff6) (#x1FF6) (#x03A9 #x0342) (#x03A9 #x0342))
         ((#x1f80) (#x1F80) (#x1F88) (#x1F08 #x0399))
         ((#x1f81) (#x1F81) (#x1F89) (#x1F09 #x0399))
         ((#x1f82) (#x1F82) (#x1F8A) (#x1F0A #x0399))
         ((#x1f83) (#x1F83) (#x1F8B) (#x1F0B #x0399))
         ((#x1f84) (#x1F84) (#x1F8C) (#x1F0C #x0399))
         ((#x1f85) (#x1F85) (#x1F8D) (#x1F0D #x0399))
         ((#x1f86) (#x1F86) (#x1F8E) (#x1F0E #x0399))
         ((#x1f87) (#x1F87) (#x1F8F) (#x1F0F #x0399))
         ((#x1f88) (#x1F80) (#x1F88) (#x1F08 #x0399))
         ((#x1f89) (#x1F81) (#x1F89) (#x1F09 #x0399))
         ((#x1f8a) (#x1F82) (#x1F8A) (#x1F0A #x0399))
         ((#x1f8b) (#x1F83) (#x1F8B) (#x1F0B #x0399))
         ((#x1f8c) (#x1F84) (#x1F8C) (#x1F0C #x0399))
         ((#x1f8d) (#x1F85) (#x1F8D) (#x1F0D #x0399))
         ((#x1f8e) (#x1F86) (#x1F8E) (#x1F0E #x0399))
         ((#x1f8f) (#x1F87) (#x1F8F) (#x1F0F #x0399))
         ((#x1f90) (#x1F90) (#x1F98) (#x1F28 #x0399))
         ((#x1f91) (#x1F91) (#x1F99) (#x1F29 #x0399))
         ((#x1f92) (#x1F92) (#x1F9A) (#x1F2A #x0399))
         ((#x1f93) (#x1F93) (#x1F9B) (#x1F2B #x0399))
         ((#x1f94) (#x1F94) (#x1F9C) (#x1F2C #x0399))
         ((#x1f95) (#x1F95) (#x1F9D) (#x1F2D #x0399))
         ((#x1f96) (#x1F96) (#x1F9E) (#x1F2E #x0399))
         ((#x1f97) (#x1F97) (#x1F9F) (#x1F2F #x0399))
         ((#x1f98) (#x1F90) (#x1F98) (#x1F28 #x0399))
         ((#x1f99) (#x1F91) (#x1F99) (#x1F29 #x0399))
         ((#x1f9a) (#x1F92) (#x1F9A) (#x1F2A #x0399))
         ((#x1f9b) (#x1F93) (#x1F9B) (#x1F2B #x0399))
         ((#x1f9c) (#x1F94) (#x1F9C) (#x1F2C #x0399))
         ((#x1f9d) (#x1F95) (#x1F9D) (#x1F2D #x0399))
         ((#x1f9e) (#x1F96) (#x1F9E) (#x1F2E #x0399))
         ((#x1f9f) (#x1F97) (#x1F9F) (#x1F2F #x0399))
         ((#x1fa0) (#x1FA0) (#x1FA8) (#x1F68 #x0399))
         ((#x1fa1) (#x1FA1) (#x1FA9) (#x1F69 #x0399))
         ((#x1fa2) (#x1FA2) (#x1FAA) (#x1F6A #x0399))
         ((#x1fa3) (#x1FA3) (#x1FAB) (#x1F6B #x0399))
         ((#x1fa4) (#x1FA4) (#x1FAC) (#x1F6C #x0399))
         ((#x1fa5) (#x1FA5) (#x1FAD) (#x1F6D #x0399))
         ((#x1fa6) (#x1FA6) (#x1FAE) (#x1F6E #x0399))
         ((#x1fa7) (#x1FA7) (#x1FAF) (#x1F6F #x0399))
         ((#x1fa8) (#x1FA0) (#x1FA8) (#x1F68 #x0399))
         ((#x1fa9) (#x1FA1) (#x1FA9) (#x1F69 #x0399))
         ((#x1faa) (#x1FA2) (#x1FAA) (#x1F6A #x0399))
         ((#x1fab) (#x1FA3) (#x1FAB) (#x1F6B #x0399))
         ((#x1fac) (#x1FA4) (#x1FAC) (#x1F6C #x0399))
         ((#x1fad) (#x1FA5) (#x1FAD) (#x1F6D #x0399))
         ((#x1fae) (#x1FA6) (#x1FAE) (#x1F6E #x0399))
         ((#x1faf) (#x1FA7) (#x1FAF) (#x1F6F #x0399))
         ((#x1fb3) (#x1FB3) (#x1FBC) (#x0391 #x0399))
         ((#x1fbc) (#x1FB3) (#x1FBC) (#x0391 #x0399))
         ((#x1fc3) (#x1FC3) (#x1FCC) (#x0397 #x0399))
         ((#x1fcc) (#x1FC3) (#x1FCC) (#x0397 #x0399))
         ((#x1ff3) (#x1FF3) (#x1FFC) (#x03A9 #x0399))
         ((#x1ffc) (#x1FF3) (#x1FFC) (#x03A9 #x0399))
         ((#x1fb2) (#x1FB2) (#x1FBA #x0345) (#x1FBA #x0399))
         ((#x1fb4) (#x1FB4) (#x0386 #x0345) (#x0386 #x0399))
         ((#x1fc2) (#x1FC2) (#x1FCA #x0345) (#x1FCA #x0399))
         ((#x1fc4) (#x1FC4) (#x0389 #x0345) (#x0389 #x0399))
         ((#x1ff2) (#x1FF2) (#x1FFA #x0345) (#x1FFA #x0399))
         ((#x1ff4) (#x1FF4) (#x038F #x0345) (#x038F #x0399))
         ((#x1fb7) (#x1FB7) (#x0391 #x0342 #x0345) (#x0391 #x0342 #x0399))
         ((#x1fc7) (#x1FC7) (#x0397 #x0342 #x0345) (#x0397 #x0342 #x0399))
         ((#x1ff7) (#x1FF7) (#x03A9 #x0342 #x0345) (#x03A9 #x0342 #x0399))
         ((#xfb00) (#xFB00) (#x0046 #x0066) (#x0046 #x0046))
         ((#xfb01) (#xFB01) (#x0046 #x0069) (#x0046 #x0049))
         ((#xfb02) (#xFB02) (#x0046 #x006C) (#x0046 #x004C))
         ((#xfb03) (#xFB03) (#x0046 #x0066 #x0069) (#x0046 #x0046 #x0049))
         ((#xfb04) (#xFB04) (#x0046 #x0066 #x006C) (#x0046 #x0046 #x004C))
         ((#xfb05) (#xFB05) (#x0053 #x0074) (#x0053 #x0054))
         ((#xfb06) (#xFB06) (#x0053 #x0074) (#x0053 #x0054))
         ((#xfb13) (#xFB13) (#x0544 #x0576) (#x0544 #x0546))
         ((#xfb14) (#xFB14) (#x0544 #x0565) (#x0544 #x0535))
         ((#xfb15) (#xFB15) (#x0544 #x056B) (#x0544 #x053B))
         ((#xfb16) (#xFB16) (#x054E #x0576) (#x054E #x0546))
         ((#xfb17) (#xFB17) (#x0544 #x056D) (#x0544 #x053D)))))

    
    ; Given a 16-bit exact integer code point, returns its low 8 bits.

    (define (lo-bits k) (remainder k 256))

    ; Given a 16-bit exact integer code point, returns its high 8 bits.

    (define (hi-bits k) (quotient k 256))

    ; Given a list of characters, returns a string of those characters.

    (define (list->string chars)
      (let* ((n (length chars))
             (s (make-string n)))
        (do ((i 0 (+ i 1))
             (chars chars (cdr chars)))
            ((= i n) s)
          (string-set! s i (car chars)))))

    ; Given a non-empty list of exact integer code points,
    ; returns the corresponding character if there is only one,
    ; or the corresponding string if there are more than one.

    (define (encoded codes)
      (if (null? (cdr codes))
          (integer->char (car codes))
          (list->string (map integer->char codes))))

    (let ((n (length special-case-mappings)))
      (set! special-case-chars (make-bytevector (* 2 n)))
      (set! special-lowercase-mapping (make-vector n))
      (set! special-titlecase-mapping (make-vector n))
      (set! special-uppercase-mapping (make-vector n)))

    (do ((i 0 (+ i 1))
         (j 0 (+ j 2))
         (mappings special-case-mappings (cdr mappings)))
        ((null? mappings))
      (let* ((mapping (car mappings))
             (cp0 (caar mapping))
             (lower (encoded (cadr mapping)))
             (title (encoded (caddr mapping)))
             (upper (encoded (cadddr mapping))))
        (bytevector-set! special-case-chars j (hi-bits cp0))
        (bytevector-set! special-case-chars (+ j 1) (lo-bits cp0))
        (vector-set! special-lowercase-mapping i lower)
        (vector-set! special-uppercase-mapping i upper)
        (vector-set! special-titlecase-mapping i title)))

    #t)
