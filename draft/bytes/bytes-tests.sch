; Basic tests of (r6rs bytes).

(define-syntax test
  (syntax-rules (=> error)
   ((test exp => result)
    (if (not (equal? exp 'result))
        (begin (display "*****BUG*****")
               (newline)
               (display "Failed test: ")
               (newline)
               (write 'exp)
               (newline))))))

(define (basic-bytes-tests)
  (call-with-current-continuation
   (lambda (exit)
     (let ()

       (test (endianness big) => big)
       (test (endianness little) => little)

       (test (or (eq? (native-endianness) 'big)
                 (eq? (native-endianness) 'little)) => #t)

       (test (bytes? (vector)) => #f)
       (test (bytes? (make-bytes 3)) => #t)

       (test (bytes-length (make-bytes 44)) => 44)

       (test (let ((b1 (make-bytes 16 -127))
                   (b2 (make-bytes 16 255)))
               (list
                (bytes-s8-ref b1 0)
                (bytes-u8-ref b1 0)
                (bytes-s8-ref b2 0)
                (bytes-u8-ref b2 0))) => (-127 129 -1 255))

       (test (let ((b (make-bytes 16 -127)))
               (bytes-s8-set! b 0 -126)
               (bytes-u8-set! b 1 246)
               (list
                (bytes-s8-ref b 0)
                (bytes-u8-ref b 0)
                (bytes-s8-ref b 1)
                (bytes-u8-ref b 1))) => (-126 130 -10 246))

       (let ()
         (define b (make-bytes 16 -127))
         (bytes-uint-set! b 0 (- (expt 2 128) 3) (endianness little) 16)

         (test (bytes-uint-ref b 0 (endianness little) 16)
               => #xfffffffffffffffffffffffffffffffd)

         (test (bytes-sint-ref b 0 (endianness little) 16) => -3)

         (test (bytes->u8-list b)
               => (253 255 255 255 255 255 255 255
                   255 255 255 255 255 255 255 255))

         (bytes-uint-set! b 0 (- (expt 2 128) 3) (endianness big) 16)

         (test (bytes-uint-ref b 0 (endianness big) 16)
               => #xfffffffffffffffffffffffffffffffd)

         (test (bytes-sint-ref b 0 (endianness big) 16) => -3)

         (test (bytes->u8-list b)
               => (255 255 255 255 255 255 255 255
                   255 255 255 255 255 255 255 253)))

       (let ()
         (define b
           (u8-list->bytes
            '(255 255 255 255 255 255 255 255
              255 255 255 255 255 255 255 253)))

         (test (bytes-u16-ref b 14 (endianness little)) => 65023)

         (test (bytes-s16-ref b 14 (endianness little)) => -513)

         (test (bytes-u16-ref b 14 (endianness big)) => 65533)

         (test (bytes-s16-ref b 14 (endianness big)) => -3)

         (bytes-u16-set! b 0 12345 (endianness little))

         (test (bytes-u16-ref b 0 (endianness little)) => 12345)

         (bytes-u16-native-set! b 0 12345)

         (test (bytes-u16-native-ref b 0) => 12345))

       (let ()
         (define b
           (u8-list->bytes
            '(255 255 255 255 255 255 255 255
              255 255 255 255 255 255 255 253)))

         (test (bytes-u32-ref b 12 (endianness little)) => 4261412863)

         (test (bytes-s32-ref b 12 (endianness little)) => -33554433)

         (test (bytes-u32-ref b 12 (endianness big)) => 4294967293)

         (test (bytes-s32-ref b 12 (endianness big)) => -3))

       (let ()
         (define b
           (u8-list->bytes
            '(255 255 255 255 255 255 255 255
              255 255 255 255 255 255 255 253)))

         (test (bytes-u64-ref b 8 (endianness little))
               => 18302628885633695743)

         (test (bytes-s64-ref b 8 (endianness little))
               => -144115188075855873)

         (test (bytes-u64-ref b 8 (endianness big))
               => 18446744073709551613)

         (test (bytes-s64-ref b 8 (endianness big)) => -3))

       (let ()
         (define b1 (u8-list->bytes '(255 2 254 3 255)))
         (define b2 (u8-list->bytes '(255 3 254 2 255)))
         (define b3 (u8-list->bytes '(255 3 254 2 255)))
         (define b4 (u8-list->bytes '(255 3 255)))

         (test (bytes=? b1 b2) => #f)
         (test (bytes=? b2 b3) => #t)
         (test (bytes=? b3 b4) => #f)
         (test (bytes=? b4 b3) => #f))

       (let ()
         (define b
           (u8-list->bytes
            '(63 240 0 0 0 0 0 0)))

         (test (bytes-ieee-single-ref b 4 'little) => 0.0)

         (test (bytes-ieee-double-ref b 0 'big) => 1.0)

         (bytes-ieee-single-native-set! b 4 3.0)

         (test (bytes-ieee-single-native-ref b 4) => 3.0)

         (bytes-ieee-double-native-set! b 0 5.0)

         (test (bytes-ieee-double-native-ref b 0) => 5.0)

         (bytes-ieee-double-set! b 0 1.75 'big)

         (test (bytes->u8-list b) => (63 252 0 0 0 0 0 0)))

       (let ((b (u8-list->bytes '(1 2 3 4 5 6 7 8))))
         (bytes-copy! b 0 b 3 4)
         (test (bytes->u8-list b) => (1 2 3 1 2 3 4 8))
         (test (bytes=? b (bytes-copy b)) => #t))

       (let ((b (u8-list->bytes '(1 2 3 255 1 2 1 2))))
         (test (bytes->sint-list b (endianness little) 2)
               => (513 -253 513 513))
         (test (bytes->uint-list b (endianness little) 2)
               => (513 65283 513 513)))))))


(define (ieee-bytes-tests)

  (define (roundtrip x getter setter! k endness)
    (let ((b (make-bytes 100)))
      (setter! b k x endness)
      (getter b k endness)))

  (define (->single x)
    (roundtrip x bytes-ieee-single-ref bytes-ieee-single-set! 0 'big))

  (define (->double x)
    (roundtrip x bytes-ieee-double-ref bytes-ieee-double-set! 0 'big))

  ; Single precision, offset 0, big-endian

  (test (roundtrip +inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 0 'big)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 0 'big)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-single-ref bytes-ieee-single-set!
                            0 'big)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-single-ref bytes-ieee-single-set! 0 'big)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-single-ref bytes-ieee-single-set! 0 'big)
        => -0.2822580337524414)

  ; Single precision, offset 0, little-endian

  (test (roundtrip +inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 0 'little)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 0 'little)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-single-ref bytes-ieee-single-set!
                            0 'little)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-single-ref bytes-ieee-single-set! 0 'little)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-single-ref bytes-ieee-single-set! 0 'little)
        => -0.2822580337524414)

  ; Single precision, offset 1, big-endian

  (test (roundtrip +inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 1 'big)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 1 'big)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-single-ref bytes-ieee-single-set!
                            1 'big)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-single-ref bytes-ieee-single-set! 1 'big)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-single-ref bytes-ieee-single-set! 1 'big)
        => -0.2822580337524414)

  ; Single precision, offset 1, little-endian

  (test (roundtrip +inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 1 'little)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 1 'little)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-single-ref bytes-ieee-single-set!
                            1 'little)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-single-ref bytes-ieee-single-set! 1 'little)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-single-ref bytes-ieee-single-set! 1 'little)
        => -0.2822580337524414)

  ; Single precision, offset 2, big-endian

  (test (roundtrip +inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 2 'big)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 2 'big)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-single-ref bytes-ieee-single-set!
                            2 'big)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-single-ref bytes-ieee-single-set! 2 'big)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-single-ref bytes-ieee-single-set! 2 'big)
        => -0.2822580337524414)

  ; Single precision, offset 2, little-endian

  (test (roundtrip +inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 2 'little)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 2 'little)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-single-ref bytes-ieee-single-set!
                            2 'little)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-single-ref bytes-ieee-single-set! 2 'little)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-single-ref bytes-ieee-single-set! 2 'little)
        => -0.2822580337524414)

  ; Single precision, offset 3, big-endian

  (test (roundtrip +inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 3 'big)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 3 'big)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-single-ref bytes-ieee-single-set!
                            3 'big)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-single-ref bytes-ieee-single-set! 3 'big)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-single-ref bytes-ieee-single-set! 3 'big)
        => -0.2822580337524414)

  ; Single precision, offset 3, little-endian

  (test (roundtrip +inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 3 'little)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-single-ref bytes-ieee-single-set! 3 'little)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-single-ref bytes-ieee-single-set!
                            3 'little)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-single-ref bytes-ieee-single-set! 3 'little)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-single-ref bytes-ieee-single-set! 3 'little)
        => -0.2822580337524414)

  ; Double precision, offset 0, big-endian

  (test (roundtrip +inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 0 'big)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 0 'big)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-double-ref bytes-ieee-double-set!
                            0 'big)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-double-ref bytes-ieee-double-set! 0 'big)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-double-ref bytes-ieee-double-set! 0 'big)
        => -0.2822580337524414)

  ; Double precision, offset 0, little-endian

  (test (roundtrip +inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 0 'little)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 0 'little)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-double-ref bytes-ieee-double-set!
                            0 'little)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-double-ref bytes-ieee-double-set! 0 'little)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-double-ref bytes-ieee-double-set! 0 'little)
        => -0.2822580337524414)

  ; Double precision, offset 1, big-endian

  (test (roundtrip +inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 1 'big)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 1 'big)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-double-ref bytes-ieee-double-set!
                            1 'big)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-double-ref bytes-ieee-double-set! 1 'big)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-double-ref bytes-ieee-double-set! 1 'big)
        => -0.2822580337524414)

  ; Double precision, offset 1, little-endian

  (test (roundtrip +inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 1 'little)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 1 'little)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-double-ref bytes-ieee-double-set!
                            1 'little)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-double-ref bytes-ieee-double-set! 1 'little)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-double-ref bytes-ieee-double-set! 1 'little)
        => -0.2822580337524414)

  ; Double precision, offset 2, big-endian

  (test (roundtrip +inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 2 'big)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 2 'big)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-double-ref bytes-ieee-double-set!
                            2 'big)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-double-ref bytes-ieee-double-set! 2 'big)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-double-ref bytes-ieee-double-set! 2 'big)
        => -0.2822580337524414)

  ; Double precision, offset 2, little-endian

  (test (roundtrip +inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 2 'little)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 2 'little)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-double-ref bytes-ieee-double-set!
                            2 'little)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-double-ref bytes-ieee-double-set! 2 'little)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-double-ref bytes-ieee-double-set! 2 'little)
        => -0.2822580337524414)

  ; Double precision, offset 3, big-endian

  (test (roundtrip +inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 3 'big)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 3 'big)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-double-ref bytes-ieee-double-set!
                            3 'big)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-double-ref bytes-ieee-double-set! 3 'big)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-double-ref bytes-ieee-double-set! 3 'big)
        => -0.2822580337524414)

  ; Double precision, offset 3, little-endian

  (test (roundtrip +inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 3 'little)
        => +inf.0)

  (test (roundtrip -inf.0
                   bytes-ieee-double-ref bytes-ieee-double-set! 3 'little)
        => -inf.0)

  (test (let ((x (roundtrip +nan.0
                            bytes-ieee-double-ref bytes-ieee-double-set!
                            3 'little)))
          (= x x))
        => #f)

  (test (roundtrip 1e10
                   bytes-ieee-double-ref bytes-ieee-double-set! 3 'little)
        => 1e10)

  (test (roundtrip -0.2822580337524414
                   bytes-ieee-double-ref bytes-ieee-double-set! 3 'little)
        => -0.2822580337524414)

  ; Denormalized numbers.

  (do ((x 1.0 (* .5 x)))
      ((= x 0.0))
    (let ((y (->single x)))
      (if (and (> y 0.0)
               (not (= x y)))
          (begin (write (list 'inaccurate-single-conversion: x '=> y))
                 (newline)))))

  (do ((x 1.0 (* .5 x)))
      ((= x 0.0))
    (let ((y (->double x)))
      (if (not (= x y))
          (begin (write (list 'inaccurate-double-conversion: x '=> y))
                 (newline))))))


