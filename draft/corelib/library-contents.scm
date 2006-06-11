((library:r6rs-core
   |#\alarm|
   |#\backspace|
   |#\delete|
   |#\esc|
   |#\linefeed|
   |#\nul|
   |#\page|
   |#\return|
   |#\space|
   |#\tab|
   |#\vtab|
   &condition
   &error
   &message
   &non-continuable
   &serious
   &violation
   &warning
   |'|
   |,|
   |,@|
   |;|
   =>
   |`|
   and
   append
   apply
   assoc
   assq
   assv
   begin
   boolean?
   caar
   cadr
   call-with-current-continuation
   call-with-values
   call/cc
   car
   case
   cdddar
   cddddr
   cdr
   char->integer
   char-alphabetic?
   char-ci<=?
   char-ci<?
   char-ci=?
   char-ci>=?
   char-ci>?
   char-downcase
   char-foldcase
   char-general-category
   char-lower-case?
   char-numeric?
   char-title-case?
   char-titlecase
   char-upcase
   char-upper-case?
   char-whitespace?
   char<=?
   char<?
   char=?
   char>=?
   char>?
   char?
   cond
   condition
   condition-has-type?
   condition-ref
   condition-type?
   condition?
   cons
   define
   define-condition-type
   define-syntax
   do
   dynamic-wind
   else
   eq?
   equal?
   eqv?
   extract-condition
   for-each
   guard
   if
   integer->char
   lambda
   length
   let
   let*
   let-syntax
   let-values
   letrec
   letrec*
   letrec-syntax
   letrec-values
   library
   list
   list->string
   list->vector
   list-ref
   list-tail
   list?
   make-compound-condition
   make-condition
   make-condition-type
   make-string
   make-vector
   map
   member
   memq
   memv
   not
   null?
   or
   pair?
   procedure?
   quasiquote
   quote
   raise
   raise-continuable
   reverse
   set!
   set-car!
   set-cdr!
   string
   string->list
   string->symbol
   string-append
   string-ci<=?
   string-ci<?
   string-ci=?
   string-ci>=?
   string-ci>?
   string-copy
   string-downcase
   string-fill!
   string-foldcase
   string-length
   string-normalize-nfc
   string-normalize-nfd
   string-normalize-nfkc
   string-normalize-nfkd
   string-ref
   string-set!
   string-titlecase
   string-upcase
   string<=?
   string<?
   string=?
   string>=?
   string>?
   string?
   substring
   symbol->string
   symbol?
   unquote
   unquote-splicing
   values
   vector
   vector->list
   vector-fill!
   vector-length
   vector-ref
   vector-set!
   vector?
   with-exception-handler)
 (library:syntax-rules ... syntax-rules)
 (library:syntax-case
   bound-identifier=?
   datum->syntax
   free-identifier=?
   generate-temporaries
   identifier-syntax
   identifier?
   make-variable-transformer
   syntax
   syntax->datum
   syntax-case
   with-syntax)
 (library:bytes
   bytes->sint-list
   bytes->u8-list
   bytes->uint-list
   bytes-copy
   bytes-copy!
   bytes-length
   bytes-s16-native-ref
   bytes-s16-native-set!
   bytes-s16-ref
   bytes-s16-set!
   bytes-s32-native-ref
   bytes-s32-native-set!
   bytes-s32-ref
   bytes-s32-set!
   bytes-s64-native-ref
   bytes-s64-native-set!
   bytes-s64-ref
   bytes-s64-set!
   bytes-s8-ref
   bytes-s8-set!
   bytes-sint-ref
   bytes-sint-set!
   bytes-u16-native-ref
   bytes-u16-native-set!
   bytes-u16-ref
   bytes-u16-set!
   bytes-u32-native-ref
   bytes-u32-native-set!
   bytes-u32-ref
   bytes-u32-set!
   bytes-u64-native-ref
   bytes-u64-native-set!
   bytes-u64-ref
   bytes-u64-set!
   bytes-u8-ref
   bytes-u8-set!
   bytes-uint-ref
   bytes-uint-set!
   bytes=?
   bytes?
   endianness
   make-bytes
   native-endianness
   sint-list->bytes
   u8-list->bytes
   uint-list->bytes)
 (library:arithmetic-generic
   *
   +
   -
   ->exact
   ->inexact
   /
   <
   <=
   =
   >
   >=
   abs
   acos
   angle
   asin
   atan
   ceiling
   complex?
   cos
   denominator
   div
   div+mod
   div0
   div0+mod0
   even?
   exact?
   exp
   expt
   finite?
   floor
   gcd
   imag-part
   inexact?
   infinite?
   integer-valued?
   integer?
   lcm
   log
   magnitude
   make-polar
   make-rectangular
   max
   min
   mod
   mod0
   nan?
   negative?
   number->string
   number?
   numerator
   odd?
   positive?
   rational-valued?
   rational?
   rationalize
   real->flonum
   real-part
   real-valued?
   real?
   round
   sin
   sqrt
   string->number
   tan
   truncate
   zero?)
 (library:arithmetic-fixnum
   fixnum*
   fixnum*/carry
   fixnum+
   fixnum+/carry
   fixnum-
   fixnum-/carry
   fixnum-and
   fixnum-arithmetic-shift
   fixnum-arithmetic-shift-left
   fixnum-arithmetic-shift-right
   fixnum-bit-count
   fixnum-bit-field
   fixnum-bit-set?
   fixnum-copy-bit
   fixnum-copy-bit-field
   fixnum-div
   fixnum-div+mod
   fixnum-div0
   fixnum-div0+mod0
   fixnum-even?
   fixnum-first-bit-set
   fixnum-if
   fixnum-ior
   fixnum-length
   fixnum-logical-shift-left
   fixnum-logical-shift-right
   fixnum-max
   fixnum-min
   fixnum-mod
   fixnum-mod0
   fixnum-negative?
   fixnum-not
   fixnum-odd?
   fixnum-positive?
   fixnum-reverse-bit-field
   fixnum-rotate-bit-field
   fixnum-width
   fixnum-xor
   fixnum-zero?
   fixnum<
   fixnum<=
   fixnum=
   fixnum>
   fixnum>=
   fixnum?
   greatest-fixnum
   least-fixnum)
 (library:arithmetic-flonum
   fixnum->flonum
   fl*
   fl+
   fl-
   fl/
   fl<
   fl<=
   fl=
   fl>
   fl>=
   flabs
   flasin
   flatan
   flceiling
   flcos
   fldenominator
   fldiv
   fldiv+mod
   fldiv0
   fldiv0+mod0
   fleven?
   flexp
   flexpt
   flfinite?
   flfloor
   flinfinite?
   flinteger?
   fllog
   flmax
   flmin
   flmod
   flmod0
   flnan?
   flnegative?
   flnumerator
   flodd?
   flonum?
   flpositive?
   flround
   flsin
   flsqrt
   fltan
   fltruncate
   flzero?)
 (library:arithmetic-fx
   fx*
   fx+
   fx-
   fx<
   fx<=
   fx=
   fx>
   fx>=
   fxand
   fxarithmetic-shift
   fxarithmetic-shift-left
   fxarithmetic-shift-right
   fxbit-count
   fxbit-field
   fxbit-set?
   fxcopy-bit
   fxcopy-bit-field
   fxdiv
   fxdiv+mod
   fxdiv0
   fxdiv0+mod0
   fxeven?
   fxfirst-bit-set
   fxif
   fxior
   fxlength
   fxmax
   fxmin
   fxmod
   fxmod0
   fxnegative?
   fxnot
   fxodd?
   fxpositive?
   fxreverse-bit-field
   fxrotate-bit-field
   fxxor
   fxzero?)
 (library:arithmetic-exact
   exact*
   exact+
   exact-
   exact-abs
   exact-and
   exact-arithmetic-shift
   exact-arithmetic-shift-left
   exact-arithmetic-shift-right
   exact-bit-count
   exact-bit-field
   exact-bit-set?
   exact-ceiling
   exact-complex?
   exact-copy-bit
   exact-copy-bit-field
   exact-denominator
   exact-div
   exact-div+mod
   exact-div0
   exact-div0+mod0
   exact-even?
   exact-expt
   exact-first-bit-set
   exact-floor
   exact-gcd
   exact-if
   exact-imag-part
   exact-integer-sqrt
   exact-integer?
   exact-ior
   exact-lcm
   exact-length
   exact-make-rectangular
   exact-max
   exact-min
   exact-mod
   exact-mod0
   exact-negative?
   exact-not
   exact-number?
   exact-numerator
   exact-odd?
   exact-positive?
   exact-rational?
   exact-real-part
   exact-reverse-bit-field
   exact-rotate-bit-field
   exact-round
   exact-truncate
   exact-xor
   exact-zero?
   exact/
   exact<=?
   exact<?
   exact=
   exact>=?
   exact>?)
 (library:arithmetic-inexact
   inexact*
   inexact+
   inexact-
   inexact-abs
   inexact-angle
   inexact-asin
   inexact-atan
   inexact-ceiling
   inexact-complex?
   inexact-cos
   inexact-denominator
   inexact-div
   inexact-div+mod
   inexact-div0
   inexact-div0+mod0
   inexact-even?
   inexact-exp
   inexact-expt
   inexact-finite?
   inexact-floor
   inexact-gcd
   inexact-imag-part
   inexact-infinite?
   inexact-integer?
   inexact-lcm
   inexact-log
   inexact-magnitude
   inexact-make-polar
   inexact-make-rectangular
   inexact-max
   inexact-min
   inexact-mod
   inexact-mod0
   inexact-nan?
   inexact-negative?
   inexact-number?
   inexact-numerator
   inexact-odd?
   inexact-positive?
   inexact-rational?
   inexact-real-part
   inexact-real?
   inexact-round
   inexact-sin
   inexact-sqrt
   inexact-tan
   inexact-truncate
   inexact-zero?
   inexact/
   inexact<=?
   inexact<?
   inexact=?
   inexact>=?
   inexact>?)
 (library:primitive-i/o
   file-options
   file-options-include?
   file-options-union
   file-options?
   make-i/o-buffer
   make-simple-reader
   make-simple-writer
   open-bytes-reader
   open-bytes-writer
   open-file-reader
   open-file-reader+writer
   open-file-writer
   reader-available
   reader-chunk-size
   reader-close
   reader-descriptor
   reader-end-position
   reader-get-position
   reader-has-end-position?
   reader-has-get-position?
   reader-has-set-position!?
   reader-id
   reader-read!
   reader-set-position!
   reader?
   standard-error-writer
   standard-input-reader
   standard-output-writer
   writer-bytes
   writer-chunk-size
   writer-close
   writer-descriptor
   writer-end-position
   writer-get-position
   writer-has-end-position?
   writer-has-get-position?
   writer-has-set-position!?
   writer-id
   writer-set-position!
   writer-write!
   writer?)
 (library:port-i/o
   buffer-mode
   buffer-mode?
   call-with-bytes-output-port
   call-with-input-port
   call-with-output-port
   call-with-string-output-port
   close-input-port
   close-output-port
   eol-style
   flush-output-port
   input-port-position
   input-port?
   latin-1-codec
   newline
   open-bytes-input-port
   open-file-input+output-ports
   open-file-input-port
   open-file-output-port
   open-reader-input-port
   open-string-input-port
   open-writer-output-port
   output-port-buffer-mode
   output-port-position
   output-port?
   peek-char
   peek-u8
   port-eof?
   read-bytes-all
   read-bytes-n
   read-bytes-n!
   read-bytes-some
   read-char
   read-string
   read-string-all
   read-string-n
   read-string-n!
   read-u8
   set-input-port-position!
   set-output-port-buffer-mode!
   set-output-port-position!
   standard-error-port
   standard-input-port
   standard-output-port
   transcode-input-port!
   transcode-output-port!
   transcoder
   update-transcoder
   utf-16be-codec
   utf-16le-codec
   utf-32be-codec
   utf-32le-codec
   write-bytes
   write-char
   write-string-n
   write-u8)
 (library:records-procedural
   make-record-constructor-descriptor
   make-record-type-descriptor
   record-accessor
   record-constructor
   record-mutator
   record-predicate
   record-type-descriptor?)
 (library:records-explicit
   define-record-type
   record-constructor-descriptor
   record-type-descriptor)
 (library:records-implicit
   define-record-type
   record-constructor-descriptor
   record-type-descriptor)
 (library:records-reflection
   record-field-mutable?
   record-rtd
   record-type-field-names
   record-type-generative?
   record-type-name
   record-type-opaque?
   record-type-parent
   record-type-sealed?
   record-type-uid
   record?)
 (library:promises delay force)
 (library:hash
   equal-hash
   hash-table-clear!
   hash-table-contains?
   hash-table-copy
   hash-table-delete!
   hash-table-equivalence-predicate
   hash-table-fold
   hash-table-for-each
   hash-table-get
   hash-table-hash-function
   hash-table-mutable?
   hash-table-ref
   hash-table-ref/call
   hash-table-ref/default
   hash-table-ref/thunk
   hash-table-set!
   hash-table-size
   hash-table-update!
   hash-table-update!/call
   hash-table-update!/default
   hash-table-update!/thunk
   hash-table?
   make-eq-hash-table
   make-eqv-hash-table
   make-hash-table
   string-ci-hash
   string-hash
   symbol-hash)
 (library:eval eval eval-library library-environment load)
 (library:r5rs-compatibility
   exact->inexact
   inexact->exact
   modulo
   null-environment
   quotient
   remainder
   scheme-report-environment)
 (library:obsolete
   char-ready?
   interaction-environment
   transcript-off
   transcript-on))
