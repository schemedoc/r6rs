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

; This uses SRFIs 23, 26, 60, and 66

(define-syntax endianness
  (syntax-rules (little big)
    ((endianness little) 'little) 
    ((endianness big) 'big)))

; change this to the endianness of your architecture
(define (native-endianness)
  (endianness little))

(define bytes? u8vector?)

(define (make-bytes k)
  (make-u8vector k 0))

(define (bytes-length b)
  (u8vector-length b))

(define (bytes-u8-ref b k)
  (u8vector-ref b k))
(define (bytes-u8-set! b k octet)
  (u8vector-set! b k octet))

(define (bytes-s8-ref b k)
  (u8->s8 (u8vector-ref b k)))

(define (u8->s8 octet)
  (if (> octet 127)
      (- octet 256)
      octet))

(define (bytes-s8-set! b k val)
  (u8vector-set! b k (s8->u8 val)))

(define (s8->u8 val)
  (if (negative? val)
      (+ val 256)
      val))

(define (index-iterate start count low-first?
		       unit proc)
  (if low-first?
      (let loop ((index 0)
		 (acc unit))
	(if (>= index count)
	    acc
	    (loop (+ index 1)
		  (proc (+ start index) acc))))

      (let loop ((index (- (+ start count) 1))
		 (acc unit))
	(if (< index start)
	    acc
	    (loop (- index 1)
		  (proc index acc))))))

(define (bytes-uint-ref size endness bytes index)
  (index-iterate index size
		       (eq? (endianness big) endness)
		       0
		       (lambda (index acc)
			 (+ (u8vector-ref bytes index) (arithmetic-shift acc 8)))))

(define (bytes-sint-ref size endness bytes index)
  (let ((high-byte (u8vector-ref bytes
				 (if (eq? endness (endianness big))
				     index
				     (- (+ index size) 1)))))

    (if (> high-byte 127)
	(- (+ 1
	      (index-iterate index size
			     (eq? (endianness big) endness)
			     0
			     (lambda (index acc)
			       (+ (- 255 (u8vector-ref bytes index))
				  (arithmetic-shift acc 8))))))
	(index-iterate index size
		       (eq? (endianness big) endness)
		       0
		       (lambda (index acc)
			 (+ (u8vector-ref bytes index) (arithmetic-shift acc 8)))))))

(define (make-uint-ref size)
  (cut bytes-uint-ref size <> <> <>))

(define (make-sint-ref size)
  (cut bytes-sint-ref size <> <> <>))

(define (bytes-uint-set! size endness bytes index val)
  (index-iterate index size (eq? (endianness little) endness)
		 val
		 (lambda (index acc)
		   (u8vector-set! bytes index (remainder acc 256))
		   (quotient acc 256)))
  (values))

(define (bytes-sint-set! size endness bytes index val)
  (if (negative? val)
      (index-iterate index size (eq? (endianness little) endness)
		     (- -1 val)
		     (lambda (index acc)
		       (u8vector-set! bytes index (- 255 (remainder acc 256)))
		       (quotient acc 256)))
      
      (index-iterate index size (eq? (endianness little) endness)
		     val
		     (lambda (index acc)
		       (u8vector-set! bytes index (remainder acc 256))
		       (quotient acc 256))))
  
  (values))
  
(define (make-uint-set! size)
  (cut bytes-uint-set! size <> <> <> <>))
(define (make-sint-set! size)
  (cut bytes-sint-set! size <> <> <> <>))

(define (make-ref/native base base-ref)
  (lambda (bytes index)
    (ensure-aligned index base)
    (base-ref (native-endianness) bytes index)))

(define (make-set!/native base base-set!)
  (lambda (bytes index val)
    (ensure-aligned index base)
    (base-set! (native-endianness) bytes index val)))

(define (ensure-aligned index base)
  (if (not (zero? (remainder index base)))
      (error "non-aligned bytes access" index base)))

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

; Auxiliary stuff

(define (bytes-copy! source source-start target target-start count)
  (u8vector-copy! source source-start target target-start count))

(define (bytes-copy b)
  (u8vector-copy b))

(define (bytes=? b1 b2)
  (u8vector=? b1 b2))

(define (bytes->u8-list b)
  (u8vector->list b))
(define (bytes->s8-list b)
  (map u8->s8 (u8vector->list b)))

(define (u8-list->bytes l)
  (list->u8vector l))
(define (s8-list->bytes l)
  (list->u8vector (map s8->u8 l)))

(define (make-bytes->int-list bytes-ref)
  (lambda (size endness b)
    (let ((ref (cut bytes-ref size endness b <>))
	  (length (bytes-length b)))
      (let loop ((i 0) (r '()))
	(if (>= i length)
	    (reverse r)
	    (loop (+ i size)
		  (cons (ref i) r)))))))

(define bytes->uint-list (make-bytes->int-list bytes-uint-ref))
(define bytes->sint-list (make-bytes->int-list bytes-sint-ref))

(define (make-int-list->bytes bytes-set!)
  (lambda (size endness l)
    (let* ((bytes (make-bytes (* size (length l))))
	   (set! (cut bytes-set! size endness bytes <> <>)))
      (let loop ((i 0) (l l))
	(if (null? l)
	    bytes
	    (begin
	      (set! i (car l))
	      (loop (+ i size) (cdr l))))))))

(define uint-list->bytes (make-int-list->bytes bytes-uint-set!))
(define sint-list->bytes (make-int-list->bytes bytes-sint-set!))
