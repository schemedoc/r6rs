; Bytes objects

; Copyright (C) Michael Sperber (2005). All Rights Reserved. 
; 
; Permission is hereby granted, free of charge, to any person
; obtaining a copy of this software and associated documentation files
; (the "Software"), to deal in the Software without restriction,
; including without limitation the rights to use, copy, modify, merge,
; publish, distribute, sublicense, and/or sell copies of the Software,
; and to permit persons to whom the Software is furnished to do so,
; subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

; Modified by William D Clinger, beginning 2 August 2006.
;
; Calls to many of these procedures should be compiled
; into a short sequence of machine instructions.
; Many of the definitions below could be made faster
; by inlining help procedures and unrolling loops,
; but that would not be as fast as generating machine
; code.
;
; This file defines all of the operations on bytes objects
; except for those defined in bytes-core.sch and in bytes-ieee.sch.
;

(library bytes-proto
  (export endianness native-endianness
          bytes? make-bytes bytes-length
          bytes-u8-ref bytes-s8-ref bytes-u8-set! bytes-s8-set!
          bytes-uint-ref bytes-sint-ref bytes-uint-set! bytes-sint-set!
          bytes-u16-ref bytes-s16-ref
          bytes-u16-set! bytes-s16-set!
          bytes-u16-native-ref bytes-s16-native-ref
          bytes-u16-native-set! bytes-s16-native-set!
          bytes-u32-ref bytes-s32-ref
          bytes-u32-set! bytes-s32-set!
          bytes-u32-native-ref bytes-s32-native-ref
          bytes-u32-native-set! bytes-s32-native-set!
          bytes-u64-ref bytes-s64-ref
          bytes-u64-set! bytes-s64-set!
          bytes-u64-native-ref bytes-s64-native-ref
          bytes-u64-native-set! bytes-s64-native-set!
          bytes=?
          bytes-copy! bytes-copy
          bytes->u8-list u8-list->bytes
          bytes->uint-list bytes->sint-list
          uint-list->bytes sint-list->bytes)

  (import (r6rs base) bytes-core)

; Help procedures; not exported.

(define (u8->s8 octet)
  (if (> octet 127)
      (- octet 256)
      octet))

(define (s8->u8 val)
  (if (negative? val)
      (+ val 256)
      val))

(define (make-uint-ref size)
  (lambda (bytes k endianness)
    (bytes-uint-ref bytes k endianness size)))

(define (make-sint-ref size)
  (lambda (bytes k endianness)
    (bytes-sint-ref bytes k endianness size)))

(define (make-uint-set! size)
  (lambda (bytes k n endianness)
    (bytes-uint-set! bytes k n endianness size)))

(define (make-sint-set! size)
  (lambda (bytes k n endianness)
    (bytes-sint-set! bytes k n endianness size)))

(define (make-ref/native base base-ref)
  (lambda (bytes index)
    (ensure-aligned index base)
    (base-ref bytes index (native-endianness))))

(define (make-set!/native base base-set!)
  (lambda (bytes index val)
    (ensure-aligned index base)
    (base-set! bytes index val (native-endianness))))

(define (ensure-aligned index base)
  (if (not (zero? (bytes:mod index base)))
      (error "non-aligned bytes access" index base)))

(define (make-bytes->int-list bytes-ref)
  (lambda (b endness size)
    (let ((ref (lambda (i) (bytes-ref b i endness size)))
	  (length (bytes-length b)))
      (let loop ((i 0) (r '()))
	(if (>= i length)
	    (reverse r)
	    (loop (+ i size)
		  (cons (ref i) r)))))))

(define (make-int-list->bytes bytes-set!)
  (lambda (l endness size)
    (let* ((bytes (make-bytes (* size (length l))))
	   (setter! (lambda (i n) (bytes-set! bytes i n endness size))))
      (let loop ((i 0) (l l))
	(if (null? l)
	    bytes
	    (begin
	      (setter! i (car l))
	      (loop (+ i size) (cdr l))))))))

; Exported syntax and procedures.

(define-syntax endianness
  (syntax-rules (little big)
    ((endianness little) 'little) 
    ((endianness big) 'big)))

(define (bytes-s8-ref b k)
  (u8->s8 (bytes-u8-ref b k)))

(define (bytes-s8-set! b k val)
  (bytes-u8-set! b k (s8->u8 val)))

(define (bytes-uint-ref bytes index endness size)
  (case endness
   ((big)
    (do ((i 0 (+ i 1))
         (result 0 (+ (* 256 result) (bytes-u8-ref bytes (+ index i)))))
        ((>= i size)
         result)))
   ((little)
    (do ((i (- size 1) (- i 1))
         (result 0 (+ (* 256 result) (bytes-u8-ref bytes (+ index i)))))
        ((< i 0)
         result)))
   (else
    (error 'bytes-uint-ref "Invalid endianness: " endness))))

(define (bytes-sint-ref bytes index endness size)
  (let* ((high-byte (bytes-u8-ref bytes
                               (if (eq? endness 'big)
                                   index
                                   (+ index size -1))))
         (uresult (bytes-uint-ref bytes index endness size)))
    (if (> high-byte 127)
        (- uresult (expt 256 size))
	uresult)))

; FIXME: Some of these procedures may not do enough range checking.

(define (bytes-uint-set! bytes index val endness size)
  (case endness
   ((little)
    (do ((i 0 (+ i 1))
         (val val (bytes:div val 256)))
        ((>= i size)
         (unspecified))
      (bytes-u8-set! bytes (+ index i) (bytes:mod val 256))))
   ((big)
    (do ((i (- size 1) (- i 1))
         (val val (bytes:div val 256)))
        ((< i 0)
         (unspecified))
      (bytes-u8-set! bytes (+ index i) (bytes:mod val 256))))
   (else
    (error 'bytes-uint-set! "Invalid endianness: " endness))))

; FIXME: incorrect.

(define (bytes-sint-set! bytes index val endness size)
  (bytes-uint-set! bytes index vala endness size))
  
(define bytes-u16-ref (make-uint-ref 2))
(define bytes-u16-set! (make-uint-set! 2))
(define bytes-s16-ref (make-sint-ref 2))
(define bytes-s16-set! (make-sint-set! 2))
(define bytes-u16-native-ref (make-ref/native 2 bytes-u16-ref))
(define bytes-u16-native-set! (make-set!/native 2 bytes-u16-set!))
(define bytes-s16-native-ref (make-ref/native 2 bytes-s16-ref))
(define bytes-s16-native-set! (make-set!/native 2 bytes-s16-set!))

(define bytes-u32-ref (make-uint-ref 4))
(define bytes-u32-set! (make-uint-set! 4))
(define bytes-s32-ref (make-sint-ref 4))
(define bytes-s32-set! (make-sint-set! 4))
(define bytes-u32-native-ref (make-ref/native 4 bytes-u32-ref))
(define bytes-u32-native-set! (make-set!/native 4 bytes-u32-set!))
(define bytes-s32-native-ref (make-ref/native 4 bytes-s32-ref))
(define bytes-s32-native-set! (make-set!/native 4 bytes-s32-set!))

(define bytes-u64-ref (make-uint-ref 8))
(define bytes-u64-set! (make-uint-set! 8))
(define bytes-s64-ref (make-sint-ref 8))
(define bytes-s64-set! (make-sint-set! 8))
(define bytes-u64-native-ref (make-ref/native 8 bytes-u64-ref))
(define bytes-u64-native-set! (make-set!/native 8 bytes-u64-set!))
(define bytes-s64-native-ref (make-ref/native 8 bytes-s64-ref))
(define bytes-s64-native-set! (make-set!/native 8 bytes-s64-set!))

(define (bytes=? b1 b2)
  (if (or (not (bytes? b1))
          (not (bytes? b2)))
      (error 'bytes=? "Illegal arguments: " b1 b2)
      (let ((n1 (bytes-length b1))
            (n2 (bytes-length b2)))
        (and (= n1 n2)
             (do ((i 0 (+ i 1)))
                 ((or (= i n1)
                      (not (= (bytes-u8-ref b1 i)
                              (bytes-u8-ref b2 i))))
                  (= i n1)))))))

; FIXME: should use word-at-a-time when possible

(define (bytes-copy! source source-start target target-start count)
  (if (>= source-start target-start)
      (do ((i 0 (+ i 1)))
          ((>= i count)
           (unspecified))
        (bytes-u8-set! target
                       (+ target-start i)
                       (bytes-u8-ref source (+ source-start i))))
      (do ((i (- count 1) (- i 1)))
          ((< i 0)
           (unspecified))
        (bytes-u8-set! target
                       (+ target-start i)
                       (bytes-u8-ref source (+ source-start i))))))

(define (bytes-copy b)
  (let* ((n (bytes-length b))
         (b2 (make-bytes n)))
    (bytes-copy! b 0 b2 0 n)
    b2))

(define (bytes->u8-list b)
  (let ((n (bytes-length b)))
    (do ((i (- n 1) (- i 1))
         (result '() (cons (bytes-u8-ref b i) result)))
        ((< i 0)
         result))))

(define (bytes->s8-list b)
  (let ((n (bytes-length b)))
    (do ((i (- n 1) (- i 1))
         (result '() (cons (bytes-s8-ref b i) result)))
        ((< i 0)
         result))))

(define (u8-list->bytes vals)
  (let* ((n (length vals))
         (b (make-bytes n)))
    (do ((vals vals (cdr vals))
         (i 0 (+ i 1)))
        ((null? vals))
      (bytes-u8-set! b i (car vals)))
    b))

(define (s8-list->bytes l)
  (let* ((n (length vals))
         (b (make-bytes n)))
    (do ((vals vals (cdr vals))
         (i 0 (+ i 1)))
        ((null? vals))
      (bytes-s8-set! b i (car vals)))
    b))

(define bytes->uint-list (make-bytes->int-list bytes-uint-ref))
(define bytes->sint-list (make-bytes->int-list bytes-sint-ref))

(define uint-list->bytes (make-int-list->bytes bytes-uint-set!))
(define sint-list->bytes (make-int-list->bytes bytes-sint-set!))

; FIXME: not implemented yet

(define (bytes-ieee-single-native-ref bytes k) ...)
(define (bytes-ieee-single-ref bytes k endianness) ...)
(define (bytes-ieee-double-native-ref bytes k) ...)
(define (bytes-ieee-double-ref bytes k endianness) ...)
(define (bytes-ieee-single-native-set! bytes k x) ...)
(define (bytes-ieee-single-set! bytes k x endianness) ...)
(define (bytes-ieee-double-native-set! bytes k x) ...)
(define (bytes-ieee-double-set! bytes k x endianness) ...)



)
