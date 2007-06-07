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
; (bytevector-ieee)
;
; This file defines the operations of (r6rs bytevector) that
; have to do with IEEE-754 single and double precision
; floating point numbers.
;
; The definitions in this file should work in systems
; that use IEEE-754 double precision to represent inexact
; reals, and will probably work or come close to working
; with other floating point representations.  Although
; they assume big-endian is the native representation,
; as in bvec-proto.sch, none of the code in this file
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
; bytevector-ieee-single-native-ref
; bytevector-ieee-double-native-ref
; bytevector-ieee-single-native-set!
; bytevector-ieee-double-native-set!
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

(library bytevector-proto-ieee

  (export bytevector-ieee-single-native-ref bytevector-ieee-single-ref
          bytevector-ieee-double-native-ref bytevector-ieee-double-ref
          bytevector-ieee-single-native-set! bytevector-ieee-single-set!
          bytevector-ieee-double-native-set! bytevector-ieee-double-set!)

  (import (r6rs base) (r6rs control) (r6rs r5rs)
          bytevector-core bytevector-proto)



; FIXME: these definitions are temporary, in case the
; infinite? and nan? procedures aren't yet in a system's
; preliminary version of (r6rs base).

(define (bytevector:nan? x)
  (and (real? x)
       (not (= x x))))

(define (bytevector:infinite? x)
  (and (real? x)
       (not (bytevector:nan? x))
       (bytevector:nan? (- x x))))

; Magic numbers for IEEE-754 single and double precision:
;     the exponent bias (127 or 1023)
;     the integer value of the hidden bit (2^23 or 2^52)

(define bytevector:single-maxexponent 255)
(define bytevector:single-bias (bytevector:div bytevector:single-maxexponent 2))
(define bytevector:single-hidden-bit 8388608)

(define bytevector:double-maxexponent 2047)
(define bytevector:double-bias (bytevector:div bytevector:double-maxexponent 2))
(define bytevector:double-hidden-bit 4503599627370496)

; Given four exact integers, returns
;
;     (-1)^sign * (2^exponent) * p/q
;
; as an inexact real.

(define (bytevector:normalized sign exponent p q)
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

(define (bytevector:normalized-ieee-parts p q)
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

(define (bytevector:ieee-parts x bias q)
  (cond ((bytevector:nan? x)
         (values 0 (+ bias bias 1) (- q 1)))
        ((bytevector:infinite? x)
         (values (if (positive? x) 0 1) (+ bias bias 1) 0))
        ((zero? x)
         (values (if (eqv? x -0.0) 1 0) 0 0))
        (else
         (let* ((sign (if (negative? x) 1 0))
                (y (inexact->exact (abs x)))
                (num (numerator y))
                (den (denominator y)))
           (call-with-values
            (lambda () (bytevector:normalized-ieee-parts num den))
            (lambda (exponent num den)
              (let ((biased-exponent (+ exponent bias)))
                (cond ((< 0 biased-exponent (+ bias bias 1))
                       ; within the range of normalized numbers
                       (if (<= den q)
                           (let* ((factor (/ q den))
                                  (num*factor (* num factor)))
                             (if (integer? factor)
                                 (values sign biased-exponent num*factor)
                                 (error 'bytevector:ieee-parts
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
                                 (round (bytevector:div num 2))))
                           ((and (< num q) (= biased 1))
                            (values sign biased num))))))))))))

; The exported procedures

(define (bytevector-ieee-single-native-ref bytevector k)
  (let ((b0 (bytevector-u8-ref bytevector k))
        (b1 (bytevector-u8-ref bytevector (+ k 1)))
        (b2 (bytevector-u8-ref bytevector (+ k 2)))
        (b3 (bytevector-u8-ref bytevector (+ k 3))))
    (let ((sign (bytevector:div b0 128))
          (exponent (+ (* 2 (bytevector:mod b0 128))
                       (bytevector:div b1 128)))
          (fraction (+ (* 256 256 (bytevector:mod b1 128))
                       (* 256 b2)
                       b3)))
      (cond ((< 0 exponent bytevector:single-maxexponent)
             ; normalized (the usual case)
             (bytevector:normalized sign
                               (- exponent bytevector:single-bias)
                               (+ bytevector:single-hidden-bit fraction)
                               bytevector:single-hidden-bit))
            ((= 0 exponent)
             (cond ((> fraction 0)
                    ; denormalized
                    (bytevector:normalized sign
                                      (+ (- bytevector:single-bias) 1)
                                      fraction
                                      bytevector:single-hidden-bit))
                   ((= sign 0) 0.0)
                   (else -0.0)))
            ((= 0 fraction)
             (if (= sign 0) +inf.0 -inf.0))
            (else
             (if (= sign 0) +nan.0 -nan.0))))))

(define (bytevector-ieee-double-native-ref bytevector k)
  (let ((b0 (bytevector-u8-ref bytevector k))
        (b1 (bytevector-u8-ref bytevector (+ k 1)))
        (b2 (bytevector-u8-ref bytevector (+ k 2))))
    (let ((sign (bytevector:div b0 128))
          (exponent (+ (* 16 (bytevector:mod b0 128))
                       (bytevector:div b1 16)))
          (fraction (+ (* 281474976710656 (bytevector:mod b1 16))
                       (bytevector-uint-ref bytevector (+ k 2) 'big 6))))
      (cond ((< 0 exponent bytevector:double-maxexponent)
             ; normalized (the usual case)
             (bytevector:normalized sign
                               (- exponent bytevector:double-bias)
                               (+ bytevector:double-hidden-bit fraction)
                               bytevector:double-hidden-bit))
            ((= 0 exponent)
             (cond ((> fraction 0)
                    ; denormalized
                    (bytevector:normalized sign
                                      (+ (- bytevector:double-bias) 1)
                                      fraction
                                      bytevector:double-hidden-bit))
                   ((= sign 0) 0.0)
                   (else -0.0)))
            ((= 0 fraction)
             (if (= sign 0) +inf.0 -inf.0))
            (else
             (if (= sign 0) +nan.0 -nan.0))))))

(define (bytevector-ieee-single-ref bytevector k endianness)
  (if (eq? endianness 'big)
      (if (= 0 (bytevector:mod k 4))
          (bytevector-ieee-single-native-ref bytevector k)
          (let ((b (make-bytevector 4)))
            (bytevector-copy! bytevector k b 0 4)
            (bytevector-ieee-single-native-ref b 0)))
      (let ((b (make-bytevector 4)))
        (bytevector-u8-set! b 0 (bytevector-u8-ref bytevector (+ k 3)))
        (bytevector-u8-set! b 1 (bytevector-u8-ref bytevector (+ k 2)))
        (bytevector-u8-set! b 2 (bytevector-u8-ref bytevector (+ k 1)))
        (bytevector-u8-set! b 3 (bytevector-u8-ref bytevector k))
        (bytevector-ieee-single-native-ref b 0))))

(define (bytevector-ieee-double-ref bytevector k endianness)
  (if (eq? endianness 'big)
      (if (= 0 (bytevector:mod k 8))
          (bytevector-ieee-double-native-ref bytevector k)
          (let ((b (make-bytevector 8)))
            (bytevector-copy! bytevector k b 0 8)
            (bytevector-ieee-double-native-ref b 0)))
      (let ((b (make-bytevector 8)))
        (bytevector-u8-set! b 0 (bytevector-u8-ref bytevector (+ k 7)))
        (bytevector-u8-set! b 1 (bytevector-u8-ref bytevector (+ k 6)))
        (bytevector-u8-set! b 2 (bytevector-u8-ref bytevector (+ k 5)))
        (bytevector-u8-set! b 3 (bytevector-u8-ref bytevector (+ k 4)))
        (bytevector-u8-set! b 4 (bytevector-u8-ref bytevector (+ k 3)))
        (bytevector-u8-set! b 5 (bytevector-u8-ref bytevector (+ k 2)))
        (bytevector-u8-set! b 6 (bytevector-u8-ref bytevector (+ k 1)))
        (bytevector-u8-set! b 7 (bytevector-u8-ref bytevector k))
        (bytevector-ieee-double-native-ref b 0))))

(define (bytevector-ieee-single-native-set! bytevector k x)
  (call-with-values
   (lambda () (bytevector:ieee-parts x bytevector:single-bias bytevector:single-hidden-bit))
   (lambda (sign biased-exponent frac)
     (define (store! sign biased-exponent frac)
       (bytevector-u8-set! bytevector k
                            (+ (* 128 sign) (bytevector:div biased-exponent 2)))
       (bytevector-u8-set! bytevector (+ k 1)
                            (+ (* 128 (bytevector:mod biased-exponent 2))
                               (bytevector:div frac (* 256 256))))
       (bytevector-u8-set! bytevector (+ k 2)
                            (bytevector:div (bytevector:mod frac (* 256 256)) 256))
       (bytevector-u8-set! bytevector (+ k 3)
                            (bytevector:mod frac 256))
       (unspecified))
     (cond ((= biased-exponent bytevector:single-maxexponent)
            (store! sign biased-exponent frac))
           ((< frac bytevector:single-hidden-bit)
            (store! sign 0 frac))
           (else
            (store! sign biased-exponent (- frac bytevector:single-hidden-bit)))))))

(define (bytevector-ieee-double-native-set! bytevector k x)
  (call-with-values
   (lambda ()
     (bytevector:ieee-parts x bytevector:double-bias
                            bytevector:double-hidden-bit))
   (lambda (sign biased-exponent frac)
     (define (store! sign biased-exponent frac)
       (bytevector-u8-set! bytevector k
                            (+ (* 128 sign)
                               (bytevector:div biased-exponent 16)))
       (bytevector-u8-set! bytevector (+ k 1)
                            (+ (* 16 (bytevector:mod biased-exponent 16))
                               (bytevector:div frac (* 65536 65536 65536))))
       (bytevector-u16-native-set! bytevector (+ k 2)
                              (bytevector:div (bytevector:mod frac (* 65536 65536 65536))
                                         (* 65536 65536)))
       (bytevector-u32-native-set! bytevector (+ k 4)
                              (bytevector:mod frac (* 65536 65536)))
       (unspecified))
     (cond ((= biased-exponent bytevector:double-maxexponent)
            (store! sign biased-exponent frac))
           ((< frac bytevector:double-hidden-bit)
            (store! sign 0 frac))
           (else
            (store! sign biased-exponent (- frac bytevector:double-hidden-bit)))))))

(define (bytevector-ieee-single-set! bytevector k x endianness)
  (if (eq? endianness 'big)
      (if (= 0 (bytevector:mod k 4))
          (bytevector-ieee-single-native-set! bytevector k x)
          (let ((b (make-bytevector 4)))
            (bytevector-ieee-single-native-set! b 0 x)
            (bytevector-copy! b 0 bytevector k 4)))
      (let ((b (make-bytevector 4)))
        (bytevector-ieee-single-native-set! b 0 x)
        (bytevector-u8-set! bytevector k (bytevector-u8-ref b 3))
        (bytevector-u8-set! bytevector (+ k 1) (bytevector-u8-ref b 2))
        (bytevector-u8-set! bytevector (+ k 2) (bytevector-u8-ref b 1))
        (bytevector-u8-set! bytevector (+ k 3) (bytevector-u8-ref b 0)))))

(define (bytevector-ieee-double-set! bytevector k x endianness)
  (if (eq? endianness 'big)
      (if (= 0 (bytevector:mod k 8))
          (bytevector-ieee-double-native-set! bytevector k x)
          (let ((b (make-bytevector 8)))
            (bytevector-ieee-double-native-set! b 0 x)
            (bytevector-copy! b 0 bytevector k 8)))
      (let ((b (make-bytevector 8)))
        (bytevector-ieee-double-native-set! b 0 x)
        (bytevector-u8-set! bytevector k (bytevector-u8-ref b 7))
        (bytevector-u8-set! bytevector (+ k 1) (bytevector-u8-ref b 6))
        (bytevector-u8-set! bytevector (+ k 2) (bytevector-u8-ref b 5))
        (bytevector-u8-set! bytevector (+ k 3) (bytevector-u8-ref b 4))
        (bytevector-u8-set! bytevector (+ k 4) (bytevector-u8-ref b 3))
        (bytevector-u8-set! bytevector (+ k 5) (bytevector-u8-ref b 2))
        (bytevector-u8-set! bytevector (+ k 6) (bytevector-u8-ref b 1))
        (bytevector-u8-set! bytevector (+ k 7) (bytevector-u8-ref b 0)))))

)
