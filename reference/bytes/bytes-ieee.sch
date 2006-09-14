; Copyright 2006 William D Clinger.
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
; (bytes-ieee)
;
; This file defines the operations of (r6rs bytes) that
; have to do with IEEE-754 single and double precision
; floating point numbers.
;
; The definitions in this file should work in systems
; that use IEEE-754 double precision to represent inexact
; reals, and will probably work or come close to working
; with other floating point representations.  Although
; they assume big-endian is the native representation,
; as in bytes-proto.sch, none of the code in this file
; depends upon the bit-level representation of inexact
; reals.  (The code *does* depend upon the bit-level
; representation of IEEE-754 single and double precision,
; but that is an entirely different matter.)
;
; The representation-independent definitions in this file
; are far less efficient than a representation-dependent
; implementation would be.  For reasonable efficiency,
; the following procedures should be redefined:
;
; bytes-ieee-single-native-ref
; bytes-ieee-double-native-ref
; bytes-ieee-single-native-set!
; bytes-ieee-double-native-set!
;
; Since those four procedures are easier to implement in
; machine language, it did not seem worthwhile to try to
; optimize their semi-portable definitions in this file.
;
; To simplify bootstrapping, this file uses R5RS arithmetic
; instead of R6RS fixnum and flonum operations.
;
; Known bugs:
;
; The -set! procedures perform double rounding for
; denormalized numbers.  Redefining the -native-set!
; procedures in machine language will eliminate those
; bugs.
;

(library bytes-proto-ieee

  (export bytes-ieee-single-native-ref bytes-ieee-single-ref
          bytes-ieee-double-native-ref bytes-ieee-double-ref
          bytes-ieee-single-native-set! bytes-ieee-single-set!
          bytes-ieee-double-native-set! bytes-ieee-double-set!)

  (import (r6rs base) (r6rs r5rs) bytes-core bytes-proto)



; FIXME: these definitions are temporary, in case the
; infinite? and nan? procedures aren't yet in a system's
; preliminary version of (r6rs base).

(define (bytes:nan? x)
  (and (real? x)
       (not (= x x))))

(define (bytes:infinite? x)
  (and (real? x)
       (not (bytes:nan? x))
       (bytes:nan? (- x x))))

; Magic numbers for IEEE-754 single and double precision:
;     the exponent bias (127 or 1023)
;     the integer value of the hidden bit (2^23 or 2^52)

(define bytes:single-maxexponent 255)
(define bytes:single-bias (bytes:div bytes:single-maxexponent 2))
(define bytes:single-hidden-bit 8388608)

(define bytes:double-maxexponent 2047)
(define bytes:double-bias (bytes:div bytes:double-maxexponent 2))
(define bytes:double-hidden-bit 4503599627370496)

; Given four exact integers, returns
;
;     (-1)^sign * (2^exponent) * p/q
;
; as an inexact real.

(define (bytes:normalized sign exponent p q)
  (let* ((p/q (exact->inexact (/ p q)))
         (x (* p/q (expt 2.0 exponent))))
    (cond ((= sign 0) x)
          ((= x 0.0) -0.0)
          (else (- x)))))

; Given exact positive integers p and q,
; returns three values:
; exact integers exponent, p2, and q2 such that
;     q2 <= p2 < q2+q2
;     p / q = (p2 * 2^exponent) / q2

(define (bytes:normalized-ieee-parts p q)
  (cond ((< p q)
         (do ((p p (+ p p))
              (e 0 (- e 1)))
             ((>= p q)
              (values e p q))))
        ((<= (+ q q) p)
         (do ((q q (+ q q))
              (e 0 (+ e 1)))
             ((< p (+ q q))
              (values e p q))))
        (else
         (values 0 p q))))

; Given an inexact real x, an exponent bias, and an exact positive
; integer q that is a power of 2 representing the integer value of
; the hidden bit, returns three exact integers:
;
; sign
; biased-exponent
; p
;
; If x is normalized, then 0 < biased-exponent <= bias+bias,
; q <= p < 2*q, and
;
;     x = (-1)^sign * (2^(biased-exponent - bias)) * p/q
;
; If x is denormalized, then p < q and the equation holds.
; If x is zero, then biased-exponent and p are zero.
; If x is infinity, then biased-exponent = bias+bias+1 and p=0.
; If x is a NaN, then biased-exponent = bias+bias+1 and p>0.
;

(define (bytes:ieee-parts x bias q)
  (cond ((bytes:nan? x)
         (values 0 (+ bias bias 1) (- q 1)))
        ((bytes:infinite? x)
         (values (if (positive? x) 0 1) (+ bias bias 1) 0))
        ((zero? x)
         (values (if (eqv? x -0.0) 1 0) 0 0))
        (else
         (let* ((sign (if (negative? x) 1 0))
                (y (inexact->exact (abs x)))
                (num (numerator y))
                (den (denominator y)))
           (call-with-values
            (lambda () (bytes:normalized-ieee-parts num den))
            (lambda (exponent num den)
              (let ((biased-exponent (+ exponent bias)))
                (cond ((< 0 biased-exponent (+ bias bias 1))
                       ; within the range of normalized numbers
                       (if (<= den q)
                           (let* ((factor (/ q den))
                                  (num*factor (* num factor)))
                             (if (integer? factor)
                                 (values sign biased-exponent num*factor)
                                 (error 'bytes:ieee-parts
                                        "this shouldn't happen: " x bias q)))
                           (let* ((factor (/ den q))
                                  (num*factor (/ num factor)))
                             (values sign
                                     biased-exponent
                                     (round num*factor)))))
                      ((>= biased-exponent (+ bias bias 1))
                       ; infinity
                       (values (if (positive? x) 0 1) (+ bias bias 1) 0))
                      (else
                       ; denormalized
                       ; FIXME: this has the double rounding bug
                       (do ((biased biased-exponent (+ biased 1))
                            (num (round (/ (* q num) den))
                                 (round (bytes:div num 2))))
                           ((and (< num q) (= biased 1))
                            (values sign biased num))))))))))))

; The exported procedures

(define (bytes-ieee-single-native-ref bytes k)
  (let ((b0 (bytes-u8-ref bytes k))
        (b1 (bytes-u8-ref bytes (+ k 1)))
        (b2 (bytes-u8-ref bytes (+ k 2)))
        (b3 (bytes-u8-ref bytes (+ k 3))))
    (let ((sign (bytes:div b0 128))
          (exponent (+ (* 2 (bytes:mod b0 128))
                       (bytes:div b1 128)))
          (fraction (+ (* 256 256 (bytes:mod b1 128))
                       (* 256 b2)
                       b3)))
      (cond ((< 0 exponent bytes:single-maxexponent)
             ; normalized (the usual case)
             (bytes:normalized sign
                               (- exponent bytes:single-bias)
                               (+ bytes:single-hidden-bit fraction)
                               bytes:single-hidden-bit))
            ((= 0 exponent)
             (cond ((> fraction 0)
                    ; denormalized
                    (bytes:normalized sign
                                      (+ (- bytes:single-bias) 1)
                                      fraction
                                      bytes:single-hidden-bit))
                   ((= sign 0) 0.0)
                   (else -0.0)))
            ((= 0 fraction)
             (if (= sign 0) +inf.0 -inf.0))
            (else
             (if (= sign 0) +nan.0 -nan.0))))))

(define (bytes-ieee-double-native-ref bytes k)
  (let ((b0 (bytes-u8-ref bytes k))
        (b1 (bytes-u8-ref bytes (+ k 1)))
        (b2 (bytes-u8-ref bytes (+ k 2))))
    (let ((sign (bytes:div b0 128))
          (exponent (+ (* 16 (bytes:mod b0 128))
                       (bytes:div b1 16)))
          (fraction (+ (* 281474976710656 (bytes:mod b1 16))
                       (bytes-uint-ref bytes (+ k 2) 'big 6))))
      (cond ((< 0 exponent bytes:double-maxexponent)
             ; normalized (the usual case)
             (bytes:normalized sign
                               (- exponent bytes:double-bias)
                               (+ bytes:double-hidden-bit fraction)
                               bytes:double-hidden-bit))
            ((= 0 exponent)
             (cond ((> fraction 0)
                    ; denormalized
                    (bytes:normalized sign
                                      (+ (- bytes:double-bias) 1)
                                      fraction
                                      bytes:double-hidden-bit))
                   ((= sign 0) 0.0)
                   (else -0.0)))
            ((= 0 fraction)
             (if (= sign 0) +inf.0 -inf.0))
            (else
             (if (= sign 0) +nan.0 -nan.0))))))

(define (bytes-ieee-single-ref bytes k endianness)
  (if (eq? endianness 'big)
      (if (= 0 (bytes:mod k 4))
          (bytes-ieee-single-native-ref bytes k)
          (let ((b (make-bytes 4)))
            (bytes-copy! bytes k b 0 4)
            (bytes-ieee-single-native-ref b 0)))
      (let ((b (make-bytes 4)))
        (bytes-u8-set! b 0 (bytes-u8-ref bytes (+ k 3)))
        (bytes-u8-set! b 1 (bytes-u8-ref bytes (+ k 2)))
        (bytes-u8-set! b 2 (bytes-u8-ref bytes (+ k 1)))
        (bytes-u8-set! b 3 (bytes-u8-ref bytes k))
        (bytes-ieee-single-native-ref b 0))))

(define (bytes-ieee-double-ref bytes k endianness)
  (if (eq? endianness 'big)
      (if (= 0 (bytes:mod k 8))
          (bytes-ieee-double-native-ref bytes k)
          (let ((b (make-bytes 8)))
            (bytes-copy! bytes k b 0 8)
            (bytes-ieee-double-native-ref b 0)))
      (let ((b (make-bytes 8)))
        (bytes-u8-set! b 0 (bytes-u8-ref bytes (+ k 7)))
        (bytes-u8-set! b 1 (bytes-u8-ref bytes (+ k 6)))
        (bytes-u8-set! b 2 (bytes-u8-ref bytes (+ k 5)))
        (bytes-u8-set! b 3 (bytes-u8-ref bytes (+ k 4)))
        (bytes-u8-set! b 4 (bytes-u8-ref bytes (+ k 3)))
        (bytes-u8-set! b 5 (bytes-u8-ref bytes (+ k 2)))
        (bytes-u8-set! b 6 (bytes-u8-ref bytes (+ k 1)))
        (bytes-u8-set! b 7 (bytes-u8-ref bytes k))
        (bytes-ieee-double-native-ref b 0))))

(define (bytes-ieee-single-native-set! bytes k x)
  (call-with-values
   (lambda () (bytes:ieee-parts x bytes:single-bias bytes:single-hidden-bit))
   (lambda (sign biased-exponent frac)
     (define (store! sign biased-exponent frac)
       (bytes-u8-set! bytes k
                            (+ (* 128 sign) (bytes:div biased-exponent 2)))
       (bytes-u8-set! bytes (+ k 1)
                            (+ (* 128 (bytes:mod biased-exponent 2))
                               (bytes:div frac (* 256 256))))
       (bytes-u8-set! bytes (+ k 2)
                            (bytes:div (bytes:mod frac (* 256 256)) 256))
       (bytes-u8-set! bytes (+ k 3)
                            (bytes:mod frac 256))
       (unspecified))
     (cond ((= biased-exponent bytes:single-maxexponent)
            (store! sign biased-exponent frac))
           ((< frac bytes:single-hidden-bit)
            (store! sign 0 frac))
           (else
            (store! sign biased-exponent (- frac bytes:single-hidden-bit)))))))

(define (bytes-ieee-double-native-set! bytes k x)
  (call-with-values
   (lambda () (bytes:ieee-parts x bytes:double-bias bytes:double-hidden-bit))
   (lambda (sign biased-exponent frac)
     (define (store! sign biased-exponent frac)
       (bytes-u8-set! bytes k
                            (+ (* 128 sign) (bytes:div biased-exponent 16)))
       (bytes-u8-set! bytes (+ k 1)
                            (+ (* 16 (bytes:mod biased-exponent 16))
                               (bytes:div frac (* 65536 65536 65536))))
       (bytes-u16-native-set! bytes (+ k 2)
                              (bytes:div (bytes:mod frac (* 65536 65536 65536))
                                         (* 65536 65536)))
       (bytes-u32-native-set! bytes (+ k 4)
                              (bytes:mod frac (* 65536 65536)))
       (unspecified))
     (cond ((= biased-exponent bytes:double-maxexponent)
            (store! sign biased-exponent frac))
           ((< frac bytes:double-hidden-bit)
            (store! sign 0 frac))
           (else
            (store! sign biased-exponent (- frac bytes:double-hidden-bit)))))))

(define (bytes-ieee-single-set! bytes k x endianness)
  (if (eq? endianness 'big)
      (if (= 0 (bytes:mod k 4))
          (bytes-ieee-single-native-set! bytes k x)
          (let ((b (make-bytes 4)))
            (bytes-ieee-single-native-set! b 0 x)
            (bytes-copy! b 0 bytes k 4)))
      (let ((b (make-bytes 4)))
        (bytes-ieee-single-native-set! b 0 x)
        (bytes-u8-set! bytes k (bytes-u8-ref b 3))
        (bytes-u8-set! bytes (+ k 1) (bytes-u8-ref b 2))
        (bytes-u8-set! bytes (+ k 2) (bytes-u8-ref b 1))
        (bytes-u8-set! bytes (+ k 3) (bytes-u8-ref b 0)))))

(define (bytes-ieee-double-set! bytes k x endianness)
  (if (eq? endianness 'big)
      (if (= 0 (bytes:mod k 8))
          (bytes-ieee-double-native-set! bytes k x)
          (let ((b (make-bytes 8)))
            (bytes-ieee-double-native-set! b 0 x)
            (bytes-copy! b 0 bytes k 8)))
      (let ((b (make-bytes 8)))
        (bytes-ieee-double-native-set! b 0 x)
        (bytes-u8-set! bytes k (bytes-u8-ref b 7))
        (bytes-u8-set! bytes (+ k 1) (bytes-u8-ref b 6))
        (bytes-u8-set! bytes (+ k 2) (bytes-u8-ref b 5))
        (bytes-u8-set! bytes (+ k 3) (bytes-u8-ref b 4))
        (bytes-u8-set! bytes (+ k 4) (bytes-u8-ref b 3))
        (bytes-u8-set! bytes (+ k 5) (bytes-u8-ref b 2))
        (bytes-u8-set! bytes (+ k 6) (bytes-u8-ref b 1))
        (bytes-u8-set! bytes (+ k 7) (bytes-u8-ref b 0)))))

)
