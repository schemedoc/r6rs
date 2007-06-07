; Copyright 2007 William D Clinger.
;
; Permission to copy this software, in whole or in part, to use this
; software for any lawful purpose, and to redistribute this software
; is granted subject to the restriction that all copies made of this
; software must include this copyright notice in full.
;
; I also request that you send me a copy of any improvements that you
; make to this software so that they may be incorporated within it to
; the benefit of the Scheme community.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; (bytevector-string)
;
; This file defines the operations of (r6rs bytevector) that
; convert strings to bytevectors and vice versa.
;
; To simplify bootstrapping, to improve efficiency, and to
; avoid some potential problems with byte order marks, this
; implementation does not rely on (r6rs i/o ports).
;
; This code often uses bytevector-u8-X operations in place of
; bytevector-u16-X operations with an endianness argument, on
; the possibly incorrect theory that adding an adjustment is
; faster than dispatching on a symbol.

(library bytevector-string

  (export string->utf8 string->utf16 string->utf32
          utf8->string utf16->string utf32->string)

  (import (r6rs base) (r6rs control) (r6rs arithmetic bitwise)
          bytevector-core bytevector-proto)

(define (string->utf8 string)
  (let* ((n (string-length string))
         (k (do ((i 0 (+ i 1))
                 (k 0 (+ k (let ((sv (char->integer (string-ref string i))))
                             (cond ((<= sv #x007f) 1)
                                   ((<= sv #x07ff) 2)
                                   ((<= sv #xffff) 3)
                                   (else 4))))))
                ((= i n) k)))
         (bv (make-bytevector k)))
    (define (loop i j)
      (if (= i n)
          bv
          (let ((sv (char->integer (string-ref string i))))
            (cond ((<= sv #x007f)
                   (bytevector-u8-set! bv j sv)
                   (loop (+ i 1) (+ j 1)))
                  ((<= sv #x07ff)
                   (let ((u0 (bitwise-ior #b11000000
                                          (bitwise-bit-field sv 6 11)))
                         (u1 (bitwise-ior #b10000000
                                          (bitwise-bit-field sv 0 6))))
                     (bytevector-u8-set! bv j u0)
                     (bytevector-u8-set! bv (+ j 1) u1)
                     (loop (+ i 1) (+ j 2))))
                  ((<= sv #xffff)
                   (let ((u0 (bitwise-ior #b11100000
                                          (bitwise-bit-field sv 12 16)))
                         (u1 (bitwise-ior #b10000000
                                          (bitwise-bit-field sv 6 12)))
                         (u2 (bitwise-ior #b10000000
                                          (bitwise-bit-field sv 0 6))))
                     (bytevector-u8-set! bv j u0)
                     (bytevector-u8-set! bv (+ j 1) u1)
                     (bytevector-u8-set! bv (+ j 2) u2)
                     (loop (+ i 1) (+ j 3))))
                  (else
                   (let ((u0 (bitwise-ior #b11110000
                                          (bitwise-bit-field sv 18 21)))
                         (u1 (bitwise-ior #b10000000
                                          (bitwise-bit-field sv 12 18)))
                         (u2 (bitwise-ior #b10000000
                                          (bitwise-bit-field sv 6 12)))
                         (u3 (bitwise-ior #b10000000
                                          (bitwise-bit-field sv 0 6))))
                     (bytevector-u8-set! bv j u0)
                     (bytevector-u8-set! bv (+ j 1) u1)
                     (bytevector-u8-set! bv (+ j 2) u2)
                     (bytevector-u8-set! bv (+ j 3) u3)
                     (loop (+ i 1) (+ j 4))))))))
    (loop 0 0)))

; Given a bytevector containing the UTF-8 encoding
; of a string, decodes and returns a newly allocated
; string (unless empty).
;
; If the bytevector begins with the three-byte sequence
; #xef #xbb #xbf, then those bytes are ignored.  (They
; are conventionally used as a signature to indicate
; UTF-8 encoding.  The string->utf8 procedure does not
; emit those bytes, but UTF-8 encodings produced by
; other sources may contain them.)
;
; The main difficulty is that Unicode Corrigendum #1
; ( http://unicode.org/versions/corrigendum1.html )
; forbids interpretation of illegal code unit sequences,
; which include non-shortest forms.  A UTF-8 decoder
; must therefore detect non-shortest forms and treat
; them as errors.
;
; Another difficulty is that the specification of this
; particular decoder says it will replace an illegal
; code unit sequence by a replacement character, but
; does not fully specify the recovery process, which
; affects the number of replacement characters that
; will appear in the result.
;
; Ignoring the special treatment of a ZERO WIDTH
; NO-BREAK SPACE at the beginning of a bytevector,
; the decoding is implemented by the following
; state machine.  q0 is the start state and the
; only state in which no more input is acceptable.
;
; q0 --- dispatching on the first byte of a character
; Dispatch on the next byte according to Table 3.1B
; of Corrigendum #1.  Note that there are two error
; ranges not shown in that table, for a total of 9.
; The 00..7f, 80..c1, and f5..ff ranges remain in
; state q0.  00..7f is an Ascii character; the other
; two ranges that remain in state q0 are illegal.
;
; q1 --- expecting one more byte in range 80..bf
;
; q2 --- expecting two more bytes, the first in range lower..bf
;
; q3 --- expecting three more bytes, the first in range lower..upper

(define (utf8->string bv)
  (let* ((n (bytevector-length bv))
         (replacement-character (integer->char #xfffd))
         (bits->char (lambda (bits)
                       (cond ((<= 0 bits #xd7ff)
                              (integer->char bits))
                             ((<= #xe000 bits #x10ffff)
                              (integer->char bits))
                             (else
                              replacement-character))))
         (begins-with-bom?
          (and (<= 3 n)
               (= #xef (bytevector-u8-ref bv 0))
               (= #xbb (bytevector-u8-ref bv 1))
               (= #xbf (bytevector-u8-ref bv 2)))))

    (define (result-length)
      ; i is index of the next byte
      ; k is the number of characters encoded by bytes 0 through i-1
      (define (q0 i k)
        (if (= i n)
            k
            (let ((unit (bytevector-u8-ref bv i))
                  (i1 (+ i 1))
                  (k1 (+ k 1)))
              (cond ((<= unit #x7f)
                     (q0 i1 k1))
                    ((<= unit #xc1)
                     ; illegal
                     (q0 i1 k1))
                    ((<= unit #xdf)
                     (q1 i1 k1))
                    ((<= unit #xe0)
                     (q2 i1 k1 #xa0))
                    ((<= unit #xef)
                     (q2 i1 k1 #x80))
                    ((<= unit #xf0)
                     (q3 i1 k1 #x90 #xbf))
                    ((<= unit #xf3)
                     (q3 i1 k1 #x80 #xbf))
                    ((<= unit #xf4)
                     (q3 i1 k1 #x80 #x8f))
                    (else
                     ; illegal
                     (q0 i1 k1))))))
      (define (q1 i k)
        (if (= i n)
            k
            (let ((unit (bytevector-u8-ref bv i))
                  (i1 (+ i 1)))
              (cond ((< unit #x80)
                     ; illegal
                     (q0 i k))
                    ((<= unit #xbf)
                     (q0 i1 k))
                    (else
                     ; illegal
                     (q0 i k))))))
      (define (q2 i k lower)
        (if (= i n)
            k
            (let ((unit (bytevector-u8-ref bv i))
                  (i1 (+ i 1)))
              (cond ((< unit lower)
                     ; illegal
                     (q0 i k))
                    ((<= unit #xbf)
                     (q1 i1 k))
                    (else
                     ; illegal
                     (q0 i k))))))
      (define (q3 i k lower upper)
        (if (= i n)
            k
            (let ((unit (bytevector-u8-ref bv i))
                  (i1 (+ i 1)))
              (cond ((< unit lower)
                     ; illegal
                     (q0 i k))
                    ((<= unit upper)
                     (q2 i1 k #x80))
                    (else
                     ; illegal
                     (q0 i k))))))
      (if begins-with-bom?
          (q0 3 0)
          (q0 0 0)))

    (let* ((k (result-length))
           (s (make-string k)))

      ; i is index of the next byte in bv
      ; k is index of the next character in s

      (define (q0 i k)
        (if (< i n)
            (let ((unit (bytevector-u8-ref bv i))
                  (i1 (+ i 1))
                  (k1 (+ k 1)))
              (cond ((<= unit #x7f)
                     (string-set! s k (integer->char unit))
                     (q0 i1 k1))
                    ((<= unit #xc1)
                     ; illegal
                     (string-set! s k replacement-character)
                     (q0 i1 k1))
                    ((<= unit #xdf)
                     (q1 i1 k (bitwise-and unit #x1f)))
                    ((<= unit #xe0)
                     (q2 i1 k #xa0 0))
                    ((<= unit #xef)
                     (q2 i1 k #x80 (bitwise-and unit #x0f)))
                    ((<= unit #xf0)
                     (q3 i1 k #x90 #xbf 0))
                    ((<= unit #xf3)
                     (q3 i1 k #x80 #xbf (bitwise-and unit #x07)))
                    ((<= unit #xf4)
                     (q3 i1 k #x80 #x8f (bitwise-and unit #x07)))
                    (else
                     ; illegal
                     (string-set! s k replacement-character)
                     (q0 i1 k1))))))
      (define (q1 i k bits)
        (if (= i n)
            (string-set! s k replacement-character)
            (let ((unit (bytevector-u8-ref bv i))
                  (i1 (+ i 1))
                  (k1 (+ k 1)))
              (cond ((< unit #x80)
                     ; illegal
                     (string-set! s k replacement-character)
                     (q0 i k1))
                    ((<= unit #xbf)
                     (string-set! s k (bits->char
                                       (bitwise-ior
                                        (bitwise-arithmetic-shift-left bits 6)
                                        (bitwise-and unit #x3f))))
                     (q0 i1 k1))
                    (else
                     ; illegal
                     (string-set! s k replacement-character)
                     (q0 i k1))))))
      (define (q2 i k lower bits)
        (if (= i n)
            (string-set! s k replacement-character)
            (let ((unit (bytevector-u8-ref bv i))
                  (i1 (+ i 1)))
              (cond ((< unit lower)
                     ; illegal
                     (string-set! s k replacement-character)
                     (q0 i (+ k 1)))
                    ((<= unit #x00bf)
                     (q1 i1 k (bitwise-ior
                               (bitwise-arithmetic-shift-left bits 6)
                               (bitwise-and unit #x3f))))
                    (else
                     ; illegal
                     (string-set! s k replacement-character)
                     (q0 i (+ k 1)))))))
      (define (q3 i k lower upper bits)
        (if (= i n)
            (string-set! s k replacement-character)
            (let ((unit (bytevector-u8-ref bv i))
                  (i1 (+ i 1)))
              (cond ((< unit lower)
                     ; illegal
                     (string-set! s k replacement-character)
                     (q0 i (+ k 1)))
                    ((<= unit upper)
                     (q2 i1 k #x80 (bitwise-ior
                                    (bitwise-arithmetic-shift-left bits 6)
                                    (bitwise-and unit #x3f))))
                    (else
                     ; illegal
                     (string-set! s k replacement-character)
                     (q0 i (+ k 1)))))))
      (if begins-with-bom?
          (q0 3 0)
          (q0 0 0))
      s)))

; (utf-32-codec) might write a byte order mark,
; so it's better not to use textual i/o for this.

(define (string->utf16 string . rest)
  (let* ((endianness (cond ((null? rest) 'big)
                           ((not (null? (cdr rest)))
                            (apply assertion-violation 'string->utf16
                                   "too many arguments" string rest))
                           ((eq? (car rest) 'big) 'big)
                           ((eq? (car rest) 'little) 'little)
                           (else (endianness-violation
                                  'string->utf16
                                  (car rest)))))

         ; endianness-dependent adjustments to indexing

         (hi (if (eq? 'big endianness) 0 1))
         (lo (- 1 hi))

         (n (string-length string)))

    (define (result-length)
      (do ((i 0 (+ i 1))
           (k 0 (let ((sv (char->integer (string-ref string i))))
                  (if (< sv #x10000) (+ k 2) (+ k 4)))))
          ((= i n) k)))

    (let ((bv (make-bytevector (result-length))))

      (define (loop i k)
        (if (< i n)
            (let ((sv (char->integer (string-ref string i))))
              (if (< sv #x10000)
                  (let ((hibits (bitwise-bit-field sv 8 16))
                        (lobits (bitwise-bit-field sv 0 8)))
                    (bytevector-u8-set! bv (+ k hi) hibits)
                    (bytevector-u8-set! bv (+ k lo) lobits)
                    (loop (+ i 1) (+ k 2)))
                  (let* ((x (- sv #x10000))
                         (hibits (bitwise-bit-field x 10 20))
                         (lobits (bitwise-bit-field x 0 10))
                         (hi16 (bitwise-ior #xd800 hibits))
                         (lo16 (bitwise-ior #xdc00 lobits))
                         (hi1 (bitwise-bit-field hi16 8 16))
                         (lo1 (bitwise-bit-field hi16 0 8))
                         (hi2 (bitwise-bit-field lo16 8 16))
                         (lo2 (bitwise-bit-field lo16 0 8)))
                    (bytevector-u8-set! bv (+ k hi) hi1)
                    (bytevector-u8-set! bv (+ k lo) lo1)
                    (bytevector-u8-set! bv (+ k hi 2) hi2)
                    (bytevector-u8-set! bv (+ k lo 2) lo2)
                    (loop (+ i 1) (+ k 4)))))))

      (loop 0 0)
      bv)))

(define (utf16->string bytevector . rest)
  (let* ((n (bytevector-length bytevector))

         (begins-with-bom?
          (and (null? rest)
               (<= 2 n)
               (let ((b0 (bytevector-u8-ref bytevector 0))
                     (b1 (bytevector-u8-ref bytevector 1)))
                 (or (and (= b0 #xfe) (= b1 #xff) 'big)
                     (and (= b0 #xff) (= b1 #xfe) 'little)))))

         (endianness (cond ((null? rest) (or begins-with-bom? 'big))
                           ((eq? (car rest) 'big) 'big)
                           ((eq? (car rest) 'little) 'little)
                           (else (endianness-violation
                                  'utf16->string
                                  (car rest)))))

         ; endianness-dependent adjustments to indexing

         (hi (if (eq? 'big endianness) 0 1))
         (lo (- 1 hi))

         (replacement-character (integer->char #xfffd)))

    ; computes the length of the encoded string

    (define (result-length)
      (define (loop i k)
        (if (>= i n)
            k
            (let ((octet (bytevector-u8-ref bytevector i)))
              (cond ((< octet #xd8)
                     (loop (+ i 2) (+ k 1)))
                    ((< octet #xdc)
                     (let* ((i2 (+ i 2))
                            (octet2 (if (< i2 n)
                                        (bytevector-u8-ref bytevector i2)
                                        0)))
                       (if (<= #xdc octet2 #xdf)
                           (loop (+ i 4) (+ k 1))
                           ; bad surrogate pair, becomes replacement character
                           (loop i2 (+ k 1)))))
                    (else (loop (+ i 2) (+ k 1)))))))
      (if begins-with-bom?
          (loop (+ hi 2) 0)
          (loop hi 0)))

    (if (odd? n)
        (assertion-violation 'utf16->string
                             "bytevector has odd length" bytevector))

    (let ((s (make-string (result-length))))
      (define (loop i k)
        (if (< i n)
            (let ((hibits (bytevector-u8-ref bytevector (+ i hi)))
                  (lobits (bytevector-u8-ref bytevector (+ i lo))))
              (cond ((< hibits #xd8)
                     (let ((c (integer->char
                               (bitwise-ior
                                (bitwise-arithmetic-shift-left hibits 8)
                                lobits))))
                       (string-set! s k c))
                     (loop (+ i 2) (+ k 1)))
                    ((< hibits #xdc)
                     (let* ((i2 (+ i hi 2))
                            (i3 (+ i lo 2))
                            (octet2 (if (< i2 n)
                                        (bytevector-u8-ref bytevector i2)
                                        0))
                            (octet3 (if (< i2 n)
                                        (bytevector-u8-ref bytevector i3)
                                        0)))
                       (if (<= #xdc octet2 #xdf)
                           (let* ((sv (+ #x10000
                                         (bitwise-arithmetic-shift-left
                                          (bitwise-and
                                           (bitwise-ior
                                            (bitwise-arithmetic-shift-left
                                             hibits 8)
                                            lobits)
                                           #x03ff)
                                          10)
                                         (bitwise-and
                                          (bitwise-ior
                                           (bitwise-arithmetic-shift-left
                                            octet2 8)
                                           octet3)
                                          #x03ff)))
                                  (c (if (<= #x10000 sv #x10ffff)
                                         (integer->char sv)
                                         replacement-character)))
                             (string-set! s k c)
                             (loop (+ i 4) (+ k 1)))
                           ; bad surrogate pair
                           (begin (string-set! s k replacement-character)
                                  (loop (+ i 2) (+ k 1))))))
                    ((< hibits #xe0)
                     ; second surrogate not preceded by a first surrogate
                     (string-set! s k replacement-character)
                     (loop (+ i 2) (+ k 1)))
                    (else
                     (let ((c (integer->char
                               (bitwise-ior
                                (bitwise-arithmetic-shift-left hibits 8)
                                lobits))))
                       (string-set! s k c))
                     (loop (+ i 2) (+ k 1)))))))
      (if begins-with-bom?
          (loop 2 0)
          (loop 0 0))
      s)))

; There is no utf-32-codec, so we can't use textual i/o for this.

(define (string->utf32 string . rest)
  (let* ((endianness (cond ((null? rest) 'big)
                           ((eq? (car rest) 'big) 'big)
                           ((eq? (car rest) 'little) 'little)
                           (else (endianness-violation
                                  'string->utf32
                                  (car rest)))))
         (n (string-length string))
         (result (make-bytevector (* 4 n))))
    (do ((i 0 (+ i 1)))
        ((= i n) result)
      (bytevector-u32-set! result
                           (* 4 i)
                           (char->integer (string-ref string i))
                           endianness))))

; There is no utf-32-codec, so we can't use textual i/o for this.

(define (utf32->string bytevector . rest)
  (let* ((n (bytevector-length bytevector))

         (begins-with-bom?
          (and (null? rest)
               (<= 4 n)
               (let ((b0 (bytevector-u8-ref bytevector 0))
                     (b1 (bytevector-u8-ref bytevector 1))
                     (b2 (bytevector-u8-ref bytevector 2))
                     (b3 (bytevector-u8-ref bytevector 3)))
                 (or (and (= b0 0) (= b1 0) (= b2 #xfe) (= b3 #xff)
                          'big)
                     (and (= b0 #xff) (= b1 #xfe) (= b2 0) (= b3 0)
                          'little)))))

         (endianness (cond ((null? rest) (or begins-with-bom? 'big))
                           ((eq? (car rest) 'big) 'big)
                           ((eq? (car rest) 'little) 'little)
                           (else (endianness-violation
                                  'string->utf32
                                  (car rest)))))

         (i0 (if begins-with-bom? 4 0))

         (result (if (zero? (remainder n 4))
                     (make-string (quotient (- n i0) 4))
                     (assertion-violation
                      'utf32->string
                      "Bytevector has bad length." bytevector))))

    (do ((i i0 (+ i 4))
         (j 0 (+ j 1)))
        ((= i n) result)
      (let* ((sv (bytevector-u32-ref bytevector i endianness))
             (sv (cond ((< sv #xd800) sv)
                       ((< sv #xe000) #xfffd) ; replacement character
                       ((< sv #x110000) sv)
                       (else #xfffd)))        ; replacement character
             (c (integer->char sv)))
        (string-set! result j c)))))

(define (endianness-violation who what)
  (assertion-violation who "bad endianness" what))

)
