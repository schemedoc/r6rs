; This file is part of the reference implementation of the R6RS Arithmetic SRFI.
; See file COPYING.

; Tests for exact generic arithmetic

(define (n-r5rs= a b)
  (exact=? a (r5rs->number b)))

(let ((inputs (cons (numerical exact-make-rectangular 3 0)
                    (numerical list  8/4 6/10 3+4i 4/5-9/10i 4.0 4+5.0i))))
  (define (all f) (map f inputs))
  (check (all exact-number?) => '(#t  #t   #t   #t     #t     #f    #f))
  (check (all exact-complex?) => '(#t #t   #t   #t     #t     #f    #f))
  (check (all exact-rational?) => '(#t #t  #t   #f     #f     #f    #f))
  (check (all exact-integer?) => '(#t #t   #f   #f     #f     #f    #f)))

(check (numerical exact<=? 1 2 3 4) => #t)
(check (numerical exact<? 1 2 7/2 4 9999999999999999999) => #t)
(check (numerical exact>? 1 2 7/2 4 9999999999999999999) => #f)
(check (numerical exact>=? 2 2 3/4 0) => #t)
(check (numerical exact=? 0 -0) => #t)
(check (exact=? (numerical exact-make-rectangular 4 0) (r5rs->number 4)) => #t)
(check (exact=? (numerical exact-make-rectangular 4 0) 
		(numerical exact-make-rectangular 4 2)) => #f)
(check (exact=? (numerical exact-make-rectangular 4 2) 
		(numerical exact-make-rectangular 4 0)) => #f)
(check (exact=? (numerical exact-make-rectangular 4 2) (r5rs->number 4)) => #f)
(check (exact=? (numerical exact-make-rectangular 10000000000000000000000000000000000000000 0) (r5rs->number 10000000000000000000000000000000000000000)) => #t)

(let ((inputs (numerical list -17 0 23
                              -3218943724243 3218943724243
                              -3218943724243/47 3218943724243/53)))
  (define (all f) (map f inputs))
  (check (all exact-zero?) => '(#f #t #f #f #f #f #f))
  (check (all exact-positive?) => '(#f #f #t #f #t #f #t))
  (check (all exact-negative?) => '(#t #f #f #t #f #t #f)))

(check (exact-zero? (numerical exact-make-rectangular 0 0)) => #t)

(check (numerical exact-odd? 5) => #t)
(check (numerical exact-odd? 4) => #f)
(check (numerical exact-odd? 9999999999989000000000001) => #t)
(check (numerical exact-odd? 9999999999989000000000000) => #f)
(check (numerical exact-even? 5) => #f)
(check (numerical exact-even? 4) => #t)
(check (numerical exact-even? 9999999999989000000000001) => #f)
(check (numerical exact-even? 9999999999989000000000000) => #t)

(check (numerical exact-abs 7) ==> 7)
(check (numerical exact-abs -7) ==> 7)
(check (numerical exact-abs 3/4) ==> 3/4)
(check (numerical exact-abs -3/4) ==> 3/4)
(check (numerical exact-abs -341084120340) ==> 341084120340)

(check (numerical exact-max 1 2 4 3 5) ==> 5)
(check (numerical exact-max 1 2 3 5 4) ==> 5)
(check (numerical exact-max 1 5 7/2 2 4) ==> 5)
(check (numerical exact-min 4 1 2 3 5) ==> 1)
(check (numerical exact-min 2 1 3 5 4) ==> 1)
(check (numerical exact-min 1 5 7/2 2 4) ==> 1)
(check (numerical exact-max -12084120983412 94/3 15) ==> 94/3)
(check (numerical exact-min -12084120983412 94/3 15) ==> -12084120983412)

(check (numerical exact+ 3 4) ==> 7)
(check (numerical exact+ 3) ==> 3)
(check (numerical exact+) ==> 0)
(check (numerical exact+ 9999999999999 999999999999) ==> 10999999999998)
(check (numerical exact+ 1000 5) ==> 1005)
(check (numerical exact* 4) ==> 4)
(check (numerical exact*) ==> 1)
(check (numerical exact* 4 3000) ==> 12000)
(check (numerical exact* 9999999999999 999999999999)
       ==> 9999999999989000000000001)

(check (numerical exact- 3 4) ==> -1)
(check (numerical exact- 3 4 5) ==> -6)
(check (numerical exact- 3) ==> -3)
(check (numerical exact/ 3 4 5) ==> 3/20)
(check (numerical exact/ 3) ==> 1/3)
(check (numerical exact/ 1 2) ==> 1/2)

(check (numerical exact-div 1000000 999) ==> 1001)
(check (numerical exact-mod 1000000 999) ==> 1)
(check (numerical exact-div 1000000 -1001) ==> -999)
(check (numerical exact-mod 1000000 -1001) ==> 1)
(check (numerical exact-div -1000000 999) ==> -1002)
(check (numerical exact-mod -1000000 999) ==> 998)
(check (numerical exact-div -1000000 -999) ==> 1002)
(check (numerical exact-mod -1000000 -999) ==> 998)
(check (numerical exact-div 1000 1) ==> 1000)
(check (numerical exact-mod 1000 1) ==> 0)
(check (exact-div (greatest-fixnum) (least-fixnum)) ==> 0)
(check (exact=? (exact-mod (greatest-fixnum) (least-fixnum))
               (greatest-fixnum)) => #t)
(check (exact-div (least-fixnum) (greatest-fixnum)) ==> -2)
(check (exact=? (exact-mod (least-fixnum) (greatest-fixnum))
               (exact- (greatest-fixnum) (r5rs->number 1))) => #t)
(check (exact-div (least-fixnum) (least-fixnum)) ==> 1)
(check (exact-mod (least-fixnum) (least-fixnum)) ==> 0)
(check (exact=? (exact-div (least-fixnum) (r5rs->number 1))
                (least-fixnum)) => #t)
(check (exact-mod (least-fixnum) (r5rs->number 1)) ==> 0)
(check (exact=? (exact-div (least-fixnum) (r5rs->number -1))
                (exact-abs (least-fixnum))) => #t)
(check (exact-mod (least-fixnum) (r5rs->number -1)) ==> 0)
(check (numerical exact-div 1000000024 1000) ==> 1000000)
(check (numerical exact-mod 1000000024 1000) ==> 24)
(check (numerical exact-div 73/3 4/3) ==> 18)
(check (numerical exact-mod 73/3 4/3) ==> 1/3)

(check (numerical exact-div0 75/3 4/3) ==> 19)
(check (numerical exact-mod0 75/3 4/3) ==> -1/3)

(let ((checker (lambda (div+mod div mod x y)
                 (call-with-values
                  (lambda () (numerical div+mod x y))
                  (lambda (d m)
                    (check (exact=? d (numerical div x y)) => #t)
                    (check (exact=? m (numerical mod x y)) => #t)))))
      (xs '(-999999999999 0 100 100000000000))
      (ys '(-1000000000 -99 57 100 348129341)))
  (define (test-div-mod x y)
    (checker exact-div+mod exact-div exact-mod x y))
  (define (test-div0-mod0 x y)
    (checker exact-div0+mod0 exact-div0 exact-mod0 x y))

  (for-each (lambda (x)
              (for-each (lambda (y)
                          (test-div-mod x y)
                          (test-div0-mod0 x y))
                        ys))
            xs))

(check (numerical exact-gcd) ==> 0)
(check (numerical exact-lcm 32 -36) ==> 288)
(check (numerical exact-lcm) ==> 1)
(check (numerical exact-gcd 120340150 105250) ==> 50)
(check (numerical exact-lcm 120340150 105250) ==> 253316015750)

(check (numerical exact-floor #e-4.3) ==> -5)
(check (numerical exact-ceiling #e-4.3) ==> -4)
(check (numerical exact-truncate #e-4.3) ==> -4)
(check (numerical exact-round #e-4.3) ==> -4)

(check (numerical exact-floor #e3.5) ==> 3)
(check (numerical exact-ceiling #e3.5) ==> 4)
(check (numerical exact-truncate #e3.5) ==> 3)

(check (numerical exact-round 7/2) ==> 4)
(check (numerical exact-round 7) ==> 7)

(check (numerical exact-expt 5 3) ==>  125)
(check (numerical exact-expt 3 123)
       ==> 48519278097689642681155855396759336072749841943521979872827)
(check (numerical exact-expt 5 0) ==> 1)
(check (numerical exact-expt 0 5) ==>  0)
(check (numerical exact-expt 0 0) ==> 1)

(check (exact-numerator (numerical exact/ 3 -4)) ==> -3)
(check (numerical exact-denominator 0) ==> 1)

(check (exact-real-part (numerical exact-make-rectangular 3/4 4/5)) ==> 3/4)
(check (exact-imag-part (numerical exact-make-rectangular 3/4 4/5)) ==> 4/5)
(check (numerical exact-real-part 13) ==> 13)
(check (numerical exact-real-part 13/5) ==> 13/5)
(check (numerical exact-real-part 1357986420) ==> 1357986420)
(check (numerical exact-imag-part 13) ==> 0)
(check (numerical exact-imag-part 13/5) ==> 0)
(check (numerical exact-imag-part 1357986420) ==> 0)



(for-each (lambda (n)
	    (check
	     (call-with-values
		 (lambda ()
		   (numerical exact-sqrt n))
	       (lambda (s r)
		 (and (exact=? (r5rs->number n)
			       (exact+ (exact* s s) r))
		      
		      (exact<? (r5rs->number n)
			       (exact* (exact+ s (r5rs->number 1))
				       (exact+ s (r5rs->number 1)))))))
	     => #t))
	  '(10
	    100 10000 100000000 10000000000000000 
	    100000000000000000000000000000000
	    10000000000000000000000000000000000000000000000000000000000000000))
				       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; New procedures.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check (numerical exact-not -4) ==> 3)
(check (exact=? (numerical exact-not #x700000000001)
                (numerical exact-    #x700000000002))
       => #t)
(check (numerical exact-and #x1234567890ab #xff88) ==> #x9088)
(check (numerical exact-and #x1234567890ab
                            #xba0987654321)
                        ==> #x120006600021)
(check (numerical exact-ior #x1234567890ab #xff88) ==> #x12345678ffab)
(check (numerical exact-ior #x1234567890ab
                            #xba0987654321)
                        ==> #xba3dd77dd3ab)
(check (numerical exact-xor #x1234567890ab #xff88) ==> #x123456786f23)
(check (numerical exact-xor #x1234567890ab
                            #xba0987654321)
                        ==> #xa83dd11dd38a)

(check (numerical exact-if #x1234567890ab
                           #x00000fedcba9
                           #x123456543210)
                       ==> #x0000066ca2b9)

(check (numerical exact-bit-count 0) ==> 0)
(check (numerical exact-bit-count #b110101) ==> 4)
(check (numerical exact-bit-count #b11010101010100011101011000101) ==> 15)
(check (numerical exact-bit-count #b-110101) ==> 3)
(check (numerical exact-bit-count #b-11010101010100011101011000101)
       ==> 14)

(check (numerical exact-length 0) ==> 0)
(check (numerical exact-length #b110101) ==> 6)
(check (numerical exact-length #b11010101010100011101011000101) ==> 29)
(check (numerical exact-length #b-110101) ==> 6)
(check (numerical exact-length #b-11010101010100011101011000100)
       ==> 29)

(check (numerical exact-first-bit-set 0) ==> -1)
(check (numerical exact-first-bit-set #b110101) ==> 0)
(check (numerical exact-first-bit-set #b11010101010100011101011000000) ==> 6)
(check (numerical exact-first-bit-set #b-110101) ==> 0)
(check (numerical exact-first-bit-set #b-11010101010100011101011000100)
       ==> 2)
(check (numerical exact-first-bit-set #x4000000000000000) ==> 62)

(check (numerical exact-bit-set? 32767 15) => #f)
(check (numerical exact-bit-set? 32767 14) => #t)
(check (exact-bit-set? (least-fixnum) (fixnum-width)) => #f)
(check (exact-bit-set? (exact* (r5rs->number 2) (least-fixnum)) (fixnum-width))
       => #t)

(check (numerical exact-copy-bit 32767 15 1) ==> 65535)
(check (numerical exact-copy-bit 32767 7 0) ==> 32639)
(check (numerical exact-copy-bit 12 1000 0) ==> 12)
(check (numerical exact-copy-bit 12 32 1) ==> 4294967308)
(check (numerical exact-copy-bit #xffffffffffffffffffff 32 0)
                             ==> #xfffffffffffeffffffff)

(check (numerical exact-bit-field 32767 3 8) ==> 31)
(check (numerical exact-bit-field #x1234567890ab 4 32) ==> #x567890a)
(check (numerical exact-copy-bit-field #x1238567890ab 4 33 #x4343434)
                                   ==> #x12384343434b)

(check (numerical exact-arithmetic-shift #x101 8) ==> #x10100)
(check (numerical exact-arithmetic-shift #x101 -4) ==> #x10)
(check (numerical exact-arithmetic-shift -2 8) ==> -512)
(check (numerical exact-arithmetic-shift -256 -5) ==> -8)
(check (numerical exact-arithmetic-shift #x101 32) ==> #x10100000000)
(check (numerical exact-arithmetic-shift #x101 -64) ==> 0)
(check (numerical exact-arithmetic-shift -2 32) ==> -8589934592)
(check (numerical exact-arithmetic-shift -256 -50) ==> -1)
(check (numerical exact-arithmetic-shift #x12345678ffee 4) ==> #x12345678ffee0)
(check (numerical exact-arithmetic-shift #x12345678ffee -16) ==> #x12345678)
(check (numerical exact-arithmetic-shift #x12345678ffee -32) ==> #x1234)
(check (numerical exact-arithmetic-shift #x-12345678ffee 32)
       ==> -85968058394968644911104)
(check (numerical exact-arithmetic-shift #x-12345678ffee -12)
       ==> #x-123456790)

(check (numerical exact-arithmetic-shift-left #x101 8) ==> #x10100)
(check (numerical exact-arithmetic-shift-left -2 8) ==> -512)
(check (numerical exact-arithmetic-shift-left #x101 32) ==> #x10100000000)
(check (numerical exact-arithmetic-shift-left #x101 -64) ==> 0)
(check (numerical exact-arithmetic-shift-left -2 32) ==> -8589934592)
(check (numerical exact-arithmetic-shift-left #x12345678ffee 4)
       ==> #x12345678ffee0)
(check (numerical exact-arithmetic-shift-left #x-12345678ffee 32)
       ==> -85968058394968644911104)



(check (numerical exact-arithmetic-shift-right #x101 4) ==> #x10)
(check (numerical exact-arithmetic-shift-right -256 5) ==> -8)
(check (numerical exact-arithmetic-shift-right -256 50) ==> -1)
(check (numerical exact-arithmetic-shift-right #x12345678ffee 16)
       ==> #x12345678)
(check (numerical exact-arithmetic-shift-right #x12345678ffee 32) ==> #x1234)
(check (numerical exact-arithmetic-shift-right #x-12345678ffee 12)
       ==> #x-123456790)

(check (numerical exact-rotate-bit-field #b1011011101111 3 12 4)
       ==> #b1111010110111)
(check (numerical exact-rotate-bit-field #x87654321abcd 4 36 8)
       ==> #x876321abc54d)
(check (numerical exact-rotate-bit-field #b-1011011101111 3 12 4)
       ==> #b-1111010110111)
(check (numerical exact-rotate-bit-field #x-87654321abcd 4 36 8)
       ==> #x-876321abc54d)

(check (numerical exact-reverse-bit-field #b1011011101111 3 12)
       ==> #b1101110110111)           
(check (numerical exact-reverse-bit-field #x87654321abcd 4 36)
       ==> #x8763d584c2ad)
(check (numerical exact-reverse-bit-field #b-1011011101111 3 12)
       ==> #b-1101110110111)
(check (numerical exact-reverse-bit-field -256 4 36)
       ==> -64424509456)
