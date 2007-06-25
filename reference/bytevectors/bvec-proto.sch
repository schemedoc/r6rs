; Bytevectors

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
; except for those defined in bytevector-core.sch and in
; bytevector-ieee.sch.
;

(library bytevector-proto
  (export endianness

          ; The next few exports come from bytevector-core.

          native-endianness
          bytevector? make-bytevector bytevector-length
          bytevector-u8-ref bytevector-s8-ref
          bytevector-u8-set! bytevector-s8-set!

          ; The remaining exports are defined in this file.

          bytevector=? bytevector-fill!
          bytevector-copy! bytevector-copy
          bytevector->u8-list u8-list->bytevector
          bytevector-uint-ref bytevector-sint-ref
          bytevector-uint-set! bytevector-sint-set!
          bytevector->uint-list bytevector->sint-list
          uint-list->bytevector sint-list->bytevector
          bytevector-u16-ref bytevector-s16-ref
          bytevector-u16-set! bytevector-s16-set!
          bytevector-u16-native-ref bytevector-s16-native-ref
          bytevector-u16-native-set! bytevector-s16-native-set!
          bytevector-u32-ref bytevector-s32-ref
          bytevector-u32-set! bytevector-s32-set!
          bytevector-u32-native-ref bytevector-s32-native-ref
          bytevector-u32-native-set! bytevector-s32-native-set!
          bytevector-u64-ref bytevector-s64-ref
          bytevector-u64-set! bytevector-s64-set!
          bytevector-u64-native-ref bytevector-s64-native-ref
          bytevector-u64-native-set! bytevector-s64-native-set!
)

  (import (r6rs base) (r6rs control) bytevector-core)

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
  (lambda (bytevector k endianness)
    (bytevector-uint-ref bytevector k endianness size)))

(define (make-sint-ref size)
  (lambda (bytevector k endianness)
    (bytevector-sint-ref bytevector k endianness size)))

(define (make-uint-set! size)
  (lambda (bytevector k n endianness)
    (bytevector-uint-set! bytevector k n endianness size)))

(define (make-sint-set! size)
  (lambda (bytevector k n endianness)
    (bytevector-sint-set! bytevector k n endianness size)))

(define (make-ref/native base base-ref)
  (lambda (bytevector index)
    (ensure-aligned index base)
    (base-ref bytevector index (native-endianness))))

(define (make-set!/native base base-set!)
  (lambda (bytevector index val)
    (ensure-aligned index base)
    (base-set! bytevector index val (native-endianness))))

(define (ensure-aligned index base)
  (if (not (zero? (bytevector:mod index base)))
      (error #f "non-aligned bytevector access" index base)))

(define (make-bytevector->int-list bytevector-ref)
  (lambda (b endness size)
    (let ((ref (lambda (i) (bytevector-ref b i endness size)))
	  (length (bytevector-length b)))
      (let loop ((i 0) (r '()))
	(if (>= i length)
	    (reverse r)
	    (loop (+ i size)
		  (cons (ref i) r)))))))

(define (make-int-list->bytevector bytevector-set!)
  (lambda (l endness size)
    (let* ((bytevector (make-bytevector (* size (length l))))
	   (setter! (lambda (i n)
                      (bytevector-set! bytevector i n endness size))))
      (let loop ((i 0) (l l))
	(if (null? l)
	    bytevector
	    (begin
	      (setter! i (car l))
	      (loop (+ i size) (cdr l))))))))

; Exported syntax and procedures.

(define-syntax endianness
  (syntax-rules (little big)
    ((endianness little) 'little) 
    ((endianness big) 'big)))

(define (bytevector-s8-ref b k)
  (u8->s8 (bytevector-u8-ref b k)))

(define (bytevector-s8-set! b k val)
  (bytevector-u8-set! b k (s8->u8 val)))

(define (bytevector-uint-ref bytevector index endness size)
  (case endness
   ((big)
    (do ((i 0 (+ i 1))
         (result 0 (+ (* 256 result)
                      (bytevector-u8-ref bytevector (+ index i)))))
        ((>= i size)
         result)))
   ((little)
    (do ((i (- size 1) (- i 1))
         (result 0 (+ (* 256 result)
                      (bytevector-u8-ref bytevector (+ index i)))))
        ((< i 0)
         result)))
   (else
    (error 'bytevector-uint-ref "Invalid endianness: " endness))))

(define (bytevector-sint-ref bytevector index endness size)
  (let* ((high-byte (bytevector-u8-ref bytevector
                               (if (eq? endness 'big)
                                   index
                                   (+ index size -1))))
         (uresult (bytevector-uint-ref bytevector index endness size)))
    (if (> high-byte 127)
        (- uresult (expt 256 size))
	uresult)))

; FIXME: Some of these procedures may not do enough range checking.

(define (bytevector-uint-set! bytevector index val endness size)
  (case endness
   ((little)
    (do ((i 0 (+ i 1))
         (val val (bytevector:div val 256)))
        ((>= i size))
      (bytevector-u8-set! bytevector (+ index i) (bytevector:mod val 256))))
   ((big)
    (do ((i (- size 1) (- i 1))
         (val val (bytevector:div val 256)))
        ((< i 0))
      (bytevector-u8-set! bytevector (+ index i) (bytevector:mod val 256))))
   (else
    (error 'bytevector-uint-set! "Invalid endianness: " endness))))

(define (bytevector-sint-set! bytevector index val endness size)
  (let ((uval (if (< val 0)
                  (+ val (* 128 (expt 256 (- size 1))))
                  val)))
    (bytevector-uint-set! bytevector index uval endness size)))
  
(define bytevector-u16-ref (make-uint-ref 2))
(define bytevector-u16-set! (make-uint-set! 2))
(define bytevector-s16-ref (make-sint-ref 2))
(define bytevector-s16-set! (make-sint-set! 2))
(define bytevector-u16-native-ref (make-ref/native 2 bytevector-u16-ref))
(define bytevector-u16-native-set! (make-set!/native 2 bytevector-u16-set!))
(define bytevector-s16-native-ref (make-ref/native 2 bytevector-s16-ref))
(define bytevector-s16-native-set! (make-set!/native 2 bytevector-s16-set!))

(define bytevector-u32-ref (make-uint-ref 4))
(define bytevector-u32-set! (make-uint-set! 4))
(define bytevector-s32-ref (make-sint-ref 4))
(define bytevector-s32-set! (make-sint-set! 4))
(define bytevector-u32-native-ref (make-ref/native 4 bytevector-u32-ref))
(define bytevector-u32-native-set! (make-set!/native 4 bytevector-u32-set!))
(define bytevector-s32-native-ref (make-ref/native 4 bytevector-s32-ref))
(define bytevector-s32-native-set! (make-set!/native 4 bytevector-s32-set!))

(define bytevector-u64-ref (make-uint-ref 8))
(define bytevector-u64-set! (make-uint-set! 8))
(define bytevector-s64-ref (make-sint-ref 8))
(define bytevector-s64-set! (make-sint-set! 8))
(define bytevector-u64-native-ref (make-ref/native 8 bytevector-u64-ref))
(define bytevector-u64-native-set! (make-set!/native 8 bytevector-u64-set!))
(define bytevector-s64-native-ref (make-ref/native 8 bytevector-s64-ref))
(define bytevector-s64-native-set! (make-set!/native 8 bytevector-s64-set!))

(define (bytevector=? b1 b2)
  (if (or (not (bytevector? b1))
          (not (bytevector? b2)))
      (error 'bytevector=? "Illegal arguments: " b1 b2)
      (let ((n1 (bytevector-length b1))
            (n2 (bytevector-length b2)))
        (and (= n1 n2)
             (do ((i 0 (+ i 1)))
                 ((or (= i n1)
                      (not (= (bytevector-u8-ref b1 i)
                              (bytevector-u8-ref b2 i))))
                  (= i n1)))))))

; FIXME: should use word-at-a-time when possible

(define (bytevector-fill! b fill)
  (let ((n (bytevector-length b)))
    (do ((i 0 (+ i 1)))
        ((= i n))
      (bytevector-u8-set! b i fill))))        

(define (bytevector-copy! source source-start target target-start count)
  (if (>= source-start target-start)
      (do ((i 0 (+ i 1)))
          ((>= i count))
        (bytevector-u8-set! target
                       (+ target-start i)
                       (bytevector-u8-ref source (+ source-start i))))
      (do ((i (- count 1) (- i 1)))
          ((< i 0))
        (bytevector-u8-set! target
                       (+ target-start i)
                       (bytevector-u8-ref source (+ source-start i))))))

(define (bytevector-copy b)
  (let* ((n (bytevector-length b))
         (b2 (make-bytevector n)))
    (bytevector-copy! b 0 b2 0 n)
    b2))

(define (bytevector->u8-list b)
  (let ((n (bytevector-length b)))
    (do ((i (- n 1) (- i 1))
         (result '() (cons (bytevector-u8-ref b i) result)))
        ((< i 0)
         result))))

(define (bytevector->s8-list b)
  (let ((n (bytevector-length b)))
    (do ((i (- n 1) (- i 1))
         (result '() (cons (bytevector-s8-ref b i) result)))
        ((< i 0)
         result))))

(define (u8-list->bytevector vals)
  (let* ((n (length vals))
         (b (make-bytevector n)))
    (do ((vals vals (cdr vals))
         (i 0 (+ i 1)))
        ((null? vals))
      (bytevector-u8-set! b i (car vals)))
    b))

(define (s8-list->bytevector vals)
  (let* ((n (length vals))
         (b (make-bytevector n)))
    (do ((vals vals (cdr vals))
         (i 0 (+ i 1)))
        ((null? vals))
      (bytevector-s8-set! b i (car vals)))
    b))

(define bytevector->uint-list (make-bytevector->int-list bytevector-uint-ref))
(define bytevector->sint-list (make-bytevector->int-list bytevector-sint-ref))

(define uint-list->bytevector (make-int-list->bytevector bytevector-uint-set!))
(define sint-list->bytevector (make-int-list->bytevector bytevector-sint-set!))

)
