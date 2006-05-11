; Examples for bytes objects

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

(define *correct-count* 0)
(define *failed-count* 0)

(define-syntax check
  (syntax-rules (=>)
    ((check ec => desired-result)
     (check ec => (equal?) desired-result))
    ((check ec => (equal?) desired-result)
     (begin
       (newline)
       (write (quote ec))
       (newline)
       (let ((actual-result ec))
         (display "  => ")
         (write actual-result)
         (if (equal? actual-result desired-result)
             (begin
               (display " ; correct")
               (set! *correct-count* (+ *correct-count* 1)) )
             (begin
               (display " ; *** failed ***, desired result:")
               (newline)
               (display "  => ")
               (write desired-result)
               (set! *failed-count* (+ *failed-count* 1)) ))
         (newline) )))))

(define b1 (make-bytes 16))

(check (bytes-length b1) => 16)

(bytes-u8-set! b1 0 223)
(bytes-s8-set! b1 1 123)
(bytes-s8-set! b1 2 -123)
(bytes-u8-set! b1 3 15)

(check (list (bytes-u8-ref b1 0)
	     (bytes-s8-ref b1 1)
	     (bytes-u8-ref b1 1)
	     (bytes-s8-ref b1 2)
	     (bytes-u8-ref b1 2)
	     (bytes-u8-ref b1 3))
       => '(223 123 123 -123 133 15))

(bytes-uint-set! 16 (endianness little)
		b1 0 (- (expt 2 128) 3))

(check (bytes-uint-ref 16 (endianness little) b1 0)
       =>  (- (expt 2 128) 3))

(check (bytes-sint-ref 16 (endianness little) b1 0)
       =>  -3)
		
(check (bytes->u8-list b1)
       => '(253 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255))

(bytes-uint-set! 16 (endianness big)
		b1 0 (- (expt 2 128) 3))

(check (bytes-uint-ref 16 (endianness big) b1 0)
       =>  (- (expt 2 128) 3))

(check (bytes-sint-ref 16 (endianness big) b1 0)
       =>  -3)

(check (bytes->u8-list b1)
       => '(255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 253))

(check (bytes-u16-ref (endianness little) b1 14)
       => 65023)
(check (bytes-s16-ref (endianness little) b1 14)
       => -513)
(check (bytes-u16-ref (endianness big) b1 14)
       => 65533)
(check (bytes-s16-ref (endianness big) b1 14)
       => -3)

(bytes-u16-set! (endianness little) b1 0 12345)

(bytes-u16-native-set! (endianness little) b1 0 12345)

(check (bytes-u16-native-ref (endianness little) b1 0)
       => 12345)

(check (bytes-u32-ref (endianness little) b1 12)
       => 4261412863)
(check (bytes-s32-ref (endianness little) b1 12)
       => -33554433)
(check (bytes-u32-ref (endianness big) b1 12)
       => 4294967293)
(check (bytes-s32-ref (endianness big) b1 12)
       => -3)

(bytes-u32-set! (endianness little) b1 0 12345)

(bytes-u32-native-set! (endianness little) b1 0 12345)

(check (bytes-u32-native-ref (endianness little) b1 0)
       => 12345)

(check (bytes-u64-ref (endianness little) b1 8)
       => 18302628885633695743)
(check (bytes-s64-ref (endianness little) b1 8)
       => -144115188075855873)
(check (bytes-u64-ref (endianness big) b1 8)
       => 18446744073709551613)
(check (bytes-s64-ref (endianness big) b1 8)
       => -3)

(bytes-u64-set! (endianness little) b1 0 12345)

(bytes-u64-native-set! (endianness little) b1 0 12345)

(check (bytes-u64-native-ref (endianness little) b1 0)
       => 12345)

(define b2 (u8-list->bytes '(1 2 3 4 5 6 7 8)))
(define b3 (bytes-copy b2))

(check (bytes=? b2 b3) => #t)
(check (bytes=? b1 b2) => #f)

(bytes-copy! b3 0 b3 4 4)

(check (bytes->u8-list b3) => '(1 2 3 4 1 2 3 4))

(bytes-copy! b3 0 b3 2 6)

(check (bytes->u8-list b3) => '(1 2 1 2 3 4 1 2))

(bytes-copy! b3 2 b3 0 6)

(check (bytes->u8-list b3) => '(1 2 3 4 1 2 1 2))

(check (bytes->uint-list 1 (endianness little) b3)
       => '(1 2 3 4 1 2 1 2))

(check (bytes->uint-list 2 (endianness little) b3)
       => '(513 1027 513 513))

(define b4 (u8-list->bytes '(0 0 0 0 0 0 48 57 255 255 255 255 255 255 255 253)))

(check (bytes->sint-list 2 (endianness little) b4)
       => '(0 0 0 14640 -1 -1 -1 -513))


(newline)
(display "correct tests: ")
(display *correct-count*)
(newline)
(display "failed tests: ")
(display *failed-count*)
(newline)
