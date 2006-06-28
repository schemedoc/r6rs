(("r6rs-core"
  (|#;| lexical-syntax derived)
  (|#\alarm| character primitive)
  (|#\backspace| character primitive)
  (|#\delete| character primitive)
  (|#\esc| character primitive)
  (|#\linefeed| character primitive)
  (|#\nul| character primitive)
  (|#\page| character primitive)
  (|#\return| character primitive)
  (|#\space| character primitive)
  (|#\tab| character primitive)
  (|#\vtab| character primitive)
  (\#\| lexical-syntax derived)
  (&alist condition derived)
  (&condition condition derived)
  (&domain condition derived)
  (&error condition derived)
  (&eval-environment condition derived)
  (&file-does-not-exist condition derived)
  (&file-exists condition derived)
  (&immutable condition derived)
  (&immutable-variable condition derived)
  (&implementation-restriction condition derived)
  (&incompatible condition derived)
  (&io condition derived)
  (&letrec condition derived)
  (&lexical condition derived)
  (&list condition derived)
  (&message condition derived)
  (&no-infinities condition derived)
  (&no-nans condition derived)
  (&non-continuable condition derived)
  (&non-negative-exact-integer condition derived)
  (&nonstandard condition derived)
  (&pair condition derived)
  (&range condition derived)
  (&result condition derived)
  (&scalar-value condition derived)
  (&serious condition derived)
  (&syntax condition derived)
  (&type condition derived)
  (&undefined-variable condition derived)
  (&values condition derived)
  (&violation condition derived)
  (&violation condition derived)
  (&warning condition derived)
  (|'| syntax primitive (alias quote))
  (* procedure derived)
  (+ procedure derived)
  (- procedure derived)
  (->exact procedure derived)
  (->inexact procedure derived)
  (/ procedure derived)
  (|;| lexical-syntax derived)
  (< procedure derived)
  (<= procedure derived)
  (= procedure derived)
  (> procedure derived)
  (>= procedure derived)
  (|`| lexical-syntax primitive (alias quasiquote))
  (abs procedure derived)
  (acos procedure derived)
  (and syntax derived)
  (angle procedure derived)
  (append procedure derived)
  (apply procedure primitive)
  (asin procedure derived)
  (atan procedure derived)
  (begin syntax derived)
  (boolean? procedure derived)
  (caar procedure derived)
  (cadr procedure derived)
  (call-with-current-continuation procedure primitive)
  (call-with-values procedure primitive)
  (call/cc procedure primitive (alias call-with-current-continuation))
  (car procedure primitive)
  (case syntax derived)
  (cdddar procedure derived)
  (cddddr procedure derived)
  (cdr procedure primitive)
  (ceiling procedure derived)
  (char->integer procedure primitive)
  (char<=? procedure primitive)
  (char<? procedure primitive)
  (char=? procedure primitive)
  (char>=? procedure primitive)
  (char>? procedure primitive)
  (char? procedure primitive)
  (complex? procedure derived)
  (cond syntax derived)
  (condition procedure derived)
  (condition-has-type? procedure derived)
  (condition-ref procedure derived)
  (condition-type? procedure derived)
  (condition? procedure derived)
  (cons procedure primitive)
  (cos procedure derived)
  (define syntax primitive)
  (define-condition-type procedure derived)
  (define-syntax syntax primitive)
  (denominator procedure derived)
  (div procedure derived)
  (div+mod procedure derived)
  (div0 procedure derived)
  (div0+mod0 procedure derived)
  (do syntax derived)
  (dynamic-wind procedure primitive)
  (eof-object procedure derived)
  (eof-object? procedure derived)
  (eq? procedure primitive)
  (equal? procedure derived)
  (eqv? procedure primitive)
  (even? procedure derived)
  (exact? procedure derived)
  (exp procedure derived)
  (expt procedure derived)
  (extract-condition procedure derived)
  (finite? procedure derived)
  (floor procedure derived)
  (for-each procedure derived)
  (gcd procedure derived)
  (guard procedure derived)
  (if syntax primitive)
  (imag-part procedure derived)
  (inexact? procedure derived)
  (infinite? procedure derived)
  (integer->char procedure primitive)
  (integer-valued? procedure derived)
  (integer? procedure derived)
  (lambda syntax primitive)
  (lcm procedure derived)
  (length procedure derived)
  (let syntax derived)
  (let* syntax derived)
  (let*-values syntax derived)
  (let-syntax syntax primitive)
  (let-values syntax derived)
  (letrec syntax derived)
  (letrec* syntax derived)
  (letrec-syntax syntax primitive)
  (letrec-values syntax derived)
  (library syntax primitive)
  (list procedure derived)
  (list->string procedure derived)
  (list->vector procedure derived)
  (list-ref procedure derived)
  (list-tail procedure derived)
  (list? procedure derived)
  (log procedure derived)
  (magnitude procedure derived)
  (make-compound-condition procedure derived)
  (make-condition procedure derived)
  (make-condition-type procedure derived)
  (make-polar procedure derived)
  (make-rectangular procedure derived)
  (make-string procedure primitive)
  (make-vector procedure primitive)
  (map procedure derived)
  (max procedure derived)
  (min procedure derived)
  (mod procedure derived)
  (mod0 procedure derived)
  (nan? procedure derived)
  (negative? procedure derived)
  (not procedure derived)
  (null? procedure derived)
  (number->string procedure derived)
  (number? procedure derived)
  (numerator procedure derived)
  (odd? procedure derived)
  (or syntax derived)
  (pair? procedure primitive)
  (positive? procedure derived)
  (procedure? procedure primitive)
  (quasiquote syntax primitive)
  (quote syntax primitive)
  (raise procedure derived)
  (raise-continuable procedure derived)
  (rational-valued? procedure derived)
  (rational? procedure derived)
  (rationalize procedure derived)
  (real->flonum procedure derived)
  (real-part procedure derived)
  (real-valued? procedure derived)
  (real? procedure derived)
  (reverse procedure derived)
  (round procedure derived)
  (set! syntax primitive)
  (set-car! procedure primitive)
  (set-cdr! procedure primitive)
  (sin procedure derived)
  (sqrt procedure derived)
  (string procedure derived)
  (string->list procedure derived)
  (string->number procedure derived)
  (string->symbol procedure primitive)
  (string-append procedure derived)
  (string-copy procedure derived)
  (string-fill! procedure derived)
  (string-length procedure primitive)
  (string-ref procedure primitive)
  (string-set! procedure primitive)
  (string<=? procedure derived)
  (string<? procedure derived)
  (string=? procedure derived)
  (string>=? procedure derived)
  (string>? procedure derived)
  (string? procedure primitive)
  (substring procedure derived)
  (symbol->string procedure primitive)
  (symbol? procedure primitive)
  (tan procedure derived)
  (truncate procedure derived)
  (unspecified procedure derived)
  (values procedure primitive)
  (vector procedure derived)
  (vector->list procedure derived)
  (vector-fill! procedure derived)
  (vector-length procedure primitive)
  (vector-ref procedure primitive)
  (vector-set! procedure primitive)
  (vector? procedure primitive)
  (with-exception-handler procedure derived)
  (zero? procedure derived)
  (\|# lexical-syntax derived))
 ("list"
  (assoc procedure derived)
  (assp procedure derived)
  (assq procedure derived)
  (assv procedure derived)
  (exists procedure derived)
  (filter procedure derived)
  (find procedure derived)
  (fold-left procedure derived)
  (fold-right procedure derived)
  (forall procedure derived)
  (iota procedure derived)
  (member procedure derived)
  (memp procedure derived)
  (memq procedure derived)
  (memv procedure derived)
  (partition procedure derived)
  (remove procedure derived)
  (remp procedure derived)
  (remq procedure derived)
  (remv procedure derived))
 ("unicode"
  (char-alphabetic? procedure derived)
  (char-ci<=? procedure derived)
  (char-ci<? procedure derived)
  (char-ci=? procedure derived)
  (char-ci>=? procedure derived)
  (char-ci>? procedure derived)
  (char-downcase procedure derived)
  (char-foldcase procedure derived)
  (char-general-category procedure derived)
  (char-lower-case? procedure derived)
  (char-numeric? procedure derived)
  (char-title-case? procedure derived)
  (char-titlecase procedure derived)
  (char-upcase procedure derived)
  (char-upper-case? procedure derived)
  (char-whitespace? procedure derived)
  (string-ci<=? procedure derived)
  (string-ci<? procedure derived)
  (string-ci=? procedure derived)
  (string-ci>=? procedure derived)
  (string-ci>? procedure derived)
  (string-downcase procedure derived)
  (string-foldcase procedure derived)
  (string-normalize-nfc procedure derived)
  (string-normalize-nfd procedure derived)
  (string-normalize-nfkc procedure derived)
  (string-normalize-nfkd procedure derived)
  (string-titlecase procedure derived)
  (string-upcase procedure derived))
 ("syntax-rules" (syntax-rules syntax primitive))
 ("syntax-case"
  (bound-identifier=? procedure derived)
  (datum->syntax procedure derived)
  (free-identifier=? procedure derived)
  (generate-temporaries procedure derived)
  (identifier-syntax procedure derived)
  (identifier? procedure derived)
  (make-variable-transformer procedure derived)
  (syntax procedure derived)
  (syntax->datum procedure derived)
  (syntax-case procedure derived)
  (with-syntax procedure derived))
 ("bytes"
  (bytes->sint-list procedure derived)
  (bytes->u8-list procedure derived)
  (bytes->uint-list procedure derived)
  (bytes-copy procedure derived)
  (bytes-copy! procedure derived)
  (bytes-length procedure derived)
  (bytes-s16-native-ref procedure derived)
  (bytes-s16-native-set! procedure derived)
  (bytes-s16-ref procedure derived)
  (bytes-s16-set! procedure derived)
  (bytes-s32-native-ref procedure derived)
  (bytes-s32-native-set! procedure derived)
  (bytes-s32-ref procedure derived)
  (bytes-s32-set! procedure derived)
  (bytes-s64-native-ref procedure derived)
  (bytes-s64-native-set! procedure derived)
  (bytes-s64-ref procedure derived)
  (bytes-s64-set! procedure derived)
  (bytes-s8-ref procedure derived)
  (bytes-s8-set! procedure derived)
  (bytes-sint-ref procedure derived)
  (bytes-sint-set! procedure derived)
  (bytes-u16-native-ref procedure derived)
  (bytes-u16-native-set! procedure derived)
  (bytes-u16-ref procedure derived)
  (bytes-u16-set! procedure derived)
  (bytes-u32-native-ref procedure derived)
  (bytes-u32-native-set! procedure derived)
  (bytes-u32-ref procedure derived)
  (bytes-u32-set! procedure derived)
  (bytes-u64-native-ref procedure derived)
  (bytes-u64-native-set! procedure derived)
  (bytes-u64-ref procedure derived)
  (bytes-u64-set! procedure derived)
  (bytes-u8-ref procedure derived)
  (bytes-u8-set! procedure derived)
  (bytes-uint-ref procedure derived)
  (bytes-uint-set! procedure derived)
  (bytes=? procedure derived)
  (bytes? procedure derived)
  (endianness procedure derived)
  (make-bytes procedure derived)
  (native-endianness procedure derived)
  (sint-list->bytes procedure derived)
  (u8-list->bytes procedure derived)
  (uint-list->bytes procedure derived))
 ("arithmetic-fixnum"
  (fixnum* procedure derived)
  (fixnum*/carry procedure derived)
  (fixnum+ procedure derived)
  (fixnum+/carry procedure derived)
  (fixnum- procedure derived)
  (fixnum-/carry procedure derived)
  (fixnum-and procedure derived)
  (fixnum-arithmetic-shift procedure derived)
  (fixnum-arithmetic-shift-left procedure derived)
  (fixnum-arithmetic-shift-right procedure derived)
  (fixnum-bit-count procedure derived)
  (fixnum-bit-field procedure derived)
  (fixnum-bit-set? procedure derived)
  (fixnum-copy-bit procedure derived)
  (fixnum-copy-bit-field procedure derived)
  (fixnum-div procedure derived)
  (fixnum-div+mod procedure derived)
  (fixnum-div0 procedure derived)
  (fixnum-div0+mod0 procedure derived)
  (fixnum-even? procedure derived)
  (fixnum-first-bit-set procedure derived)
  (fixnum-if procedure derived)
  (fixnum-ior procedure derived)
  (fixnum-length procedure derived)
  (fixnum-logical-shift-left procedure derived)
  (fixnum-logical-shift-right procedure derived)
  (fixnum-max procedure derived)
  (fixnum-min procedure derived)
  (fixnum-mod procedure derived)
  (fixnum-mod0 procedure derived)
  (fixnum-negative? procedure derived)
  (fixnum-not procedure derived)
  (fixnum-odd? procedure derived)
  (fixnum-positive? procedure derived)
  (fixnum-reverse-bit-field procedure derived)
  (fixnum-rotate-bit-field procedure derived)
  (fixnum-width procedure derived)
  (fixnum-xor procedure derived)
  (fixnum-zero? procedure derived)
  (fixnum< procedure derived)
  (fixnum<= procedure derived)
  (fixnum= procedure derived)
  (fixnum> procedure derived)
  (fixnum>= procedure derived)
  (fixnum? procedure derived)
  (greatest-fixnum procedure derived)
  (least-fixnum procedure derived))
 ("arithmetic-flonum"
  (fixnum->flonum procedure derived)
  (fl* procedure derived)
  (fl+ procedure derived)
  (fl- procedure derived)
  (fl/ procedure derived)
  (fl< procedure derived)
  (fl<= procedure derived)
  (fl= procedure derived)
  (fl> procedure derived)
  (fl>= procedure derived)
  (flabs procedure derived)
  (flasin procedure derived)
  (flatan procedure derived)
  (flceiling procedure derived)
  (flcos procedure derived)
  (fldenominator procedure derived)
  (fldiv procedure derived)
  (fldiv+mod procedure derived)
  (fldiv0 procedure derived)
  (fldiv0+mod0 procedure derived)
  (fleven? procedure derived)
  (flexp procedure derived)
  (flexpt procedure derived)
  (flfinite? procedure derived)
  (flfloor procedure derived)
  (flinfinite? procedure derived)
  (flinteger? procedure derived)
  (fllog procedure derived)
  (flmax procedure derived)
  (flmin procedure derived)
  (flmod procedure derived)
  (flmod0 procedure derived)
  (flnan? procedure derived)
  (flnegative? procedure derived)
  (flnumerator procedure derived)
  (flodd? procedure derived)
  (flonum? procedure derived)
  (flpositive? procedure derived)
  (flround procedure derived)
  (flsin procedure derived)
  (flsqrt procedure derived)
  (fltan procedure derived)
  (fltruncate procedure derived)
  (flzero? procedure derived))
 ("arithmetic-fx"
  (fx* procedure derived)
  (fx+ procedure derived)
  (fx- procedure derived)
  (fx< procedure derived)
  (fx<= procedure derived)
  (fx= procedure derived)
  (fx> procedure derived)
  (fx>= procedure derived)
  (fxand procedure derived)
  (fxarithmetic-shift procedure derived)
  (fxarithmetic-shift-left procedure derived)
  (fxarithmetic-shift-right procedure derived)
  (fxbit-count procedure derived)
  (fxbit-field procedure derived)
  (fxbit-set? procedure derived)
  (fxcopy-bit procedure derived)
  (fxcopy-bit-field procedure derived)
  (fxdiv procedure derived)
  (fxdiv+mod procedure derived)
  (fxdiv0 procedure derived)
  (fxdiv0+mod0 procedure derived)
  (fxeven? procedure derived)
  (fxfirst-bit-set procedure derived)
  (fxif procedure derived)
  (fxior procedure derived)
  (fxlength procedure derived)
  (fxmax procedure derived)
  (fxmin procedure derived)
  (fxmod procedure derived)
  (fxmod0 procedure derived)
  (fxnegative? procedure derived)
  (fxnot procedure derived)
  (fxodd? procedure derived)
  (fxpositive? procedure derived)
  (fxreverse-bit-field procedure derived)
  (fxrotate-bit-field procedure derived)
  (fxxor procedure derived)
  (fxzero? procedure derived))
 ("arithmetic-exact"
  (exact* procedure derived)
  (exact+ procedure derived)
  (exact- procedure derived)
  (exact-abs procedure derived)
  (exact-and procedure derived)
  (exact-arithmetic-shift procedure derived)
  (exact-arithmetic-shift-left procedure derived)
  (exact-arithmetic-shift-right procedure derived)
  (exact-bit-count procedure derived)
  (exact-bit-field procedure derived)
  (exact-bit-set? procedure derived)
  (exact-ceiling procedure derived)
  (exact-complex? procedure derived)
  (exact-copy-bit procedure derived)
  (exact-copy-bit-field procedure derived)
  (exact-denominator procedure derived)
  (exact-div procedure derived)
  (exact-div+mod procedure derived)
  (exact-div0 procedure derived)
  (exact-div0+mod0 procedure derived)
  (exact-even? procedure derived)
  (exact-expt procedure derived)
  (exact-first-bit-set procedure derived)
  (exact-floor procedure derived)
  (exact-gcd procedure derived)
  (exact-if procedure derived)
  (exact-imag-part procedure derived)
  (exact-integer-sqrt procedure derived)
  (exact-integer? procedure derived)
  (exact-ior procedure derived)
  (exact-lcm procedure derived)
  (exact-length procedure derived)
  (exact-make-rectangular procedure derived)
  (exact-max procedure derived)
  (exact-min procedure derived)
  (exact-mod procedure derived)
  (exact-mod0 procedure derived)
  (exact-negative? procedure derived)
  (exact-not procedure derived)
  (exact-number? procedure derived)
  (exact-numerator procedure derived)
  (exact-odd? procedure derived)
  (exact-positive? procedure derived)
  (exact-rational? procedure derived)
  (exact-real-part procedure derived)
  (exact-reverse-bit-field procedure derived)
  (exact-rotate-bit-field procedure derived)
  (exact-round procedure derived)
  (exact-truncate procedure derived)
  (exact-xor procedure derived)
  (exact-zero? procedure derived)
  (exact/ procedure derived)
  (exact<=? procedure derived)
  (exact<? procedure derived)
  (exact= procedure derived)
  (exact>=? procedure derived)
  (exact>? procedure derived))
 ("arithmetic-inexact"
  (inexact* procedure derived)
  (inexact+ procedure derived)
  (inexact- procedure derived)
  (inexact-abs procedure derived)
  (inexact-angle procedure derived)
  (inexact-asin procedure derived)
  (inexact-atan procedure derived)
  (inexact-ceiling procedure derived)
  (inexact-complex? procedure derived)
  (inexact-cos procedure derived)
  (inexact-denominator procedure derived)
  (inexact-div procedure derived)
  (inexact-div+mod procedure derived)
  (inexact-div0 procedure derived)
  (inexact-div0+mod0 procedure derived)
  (inexact-even? procedure derived)
  (inexact-exp procedure derived)
  (inexact-expt procedure derived)
  (inexact-finite? procedure derived)
  (inexact-floor procedure derived)
  (inexact-gcd procedure derived)
  (inexact-imag-part procedure derived)
  (inexact-infinite? procedure derived)
  (inexact-integer? procedure derived)
  (inexact-lcm procedure derived)
  (inexact-log procedure derived)
  (inexact-magnitude procedure derived)
  (inexact-make-polar procedure derived)
  (inexact-make-rectangular procedure derived)
  (inexact-max procedure derived)
  (inexact-min procedure derived)
  (inexact-mod procedure derived)
  (inexact-mod0 procedure derived)
  (inexact-nan? procedure derived)
  (inexact-negative? procedure derived)
  (inexact-number? procedure derived)
  (inexact-numerator procedure derived)
  (inexact-odd? procedure derived)
  (inexact-positive? procedure derived)
  (inexact-rational? procedure derived)
  (inexact-real-part procedure derived)
  (inexact-real? procedure derived)
  (inexact-round procedure derived)
  (inexact-sin procedure derived)
  (inexact-sqrt procedure derived)
  (inexact-tan procedure derived)
  (inexact-truncate procedure derived)
  (inexact-zero? procedure derived)
  (inexact/ procedure derived)
  (inexact<=? procedure derived)
  (inexact<? procedure derived)
  (inexact=? procedure derived)
  (inexact>=? procedure derived)
  (inexact>? procedure derived))
 ("primitive-i/o"
  (file-options procedure derived)
  (file-options-include? procedure derived)
  (file-options-union procedure derived)
  (file-options? procedure derived)
  (make-i/o-buffer procedure derived)
  (make-simple-reader procedure derived)
  (make-simple-writer procedure derived)
  (open-bytes-reader procedure derived)
  (open-bytes-writer procedure derived)
  (open-file-reader procedure derived)
  (open-file-reader+writer procedure derived)
  (open-file-writer procedure derived)
  (reader-available procedure derived)
  (reader-chunk-size procedure derived)
  (reader-close procedure derived)
  (reader-descriptor procedure derived)
  (reader-end-position procedure derived)
  (reader-get-position procedure derived)
  (reader-has-end-position? procedure derived)
  (reader-has-get-position? procedure derived)
  (reader-has-set-position!? procedure derived)
  (reader-id procedure derived)
  (reader-read! procedure derived)
  (reader-set-position! procedure derived)
  (reader? procedure derived)
  (standard-error-writer procedure derived)
  (standard-input-reader procedure derived)
  (standard-output-writer procedure derived)
  (writer-bytes procedure derived)
  (writer-chunk-size procedure derived)
  (writer-close procedure derived)
  (writer-descriptor procedure derived)
  (writer-end-position procedure derived)
  (writer-get-position procedure derived)
  (writer-has-end-position? procedure derived)
  (writer-has-get-position? procedure derived)
  (writer-has-set-position!? procedure derived)
  (writer-id procedure derived)
  (writer-set-position! procedure derived)
  (writer-write! procedure derived)
  (writer? procedure derived))
 ("port-i/o"
  (buffer-mode procedure derived)
  (buffer-mode? procedure derived)
  (call-with-bytes-output-port procedure derived)
  (call-with-input-port procedure derived)
  (call-with-output-port procedure derived)
  (call-with-string-output-port procedure derived)
  (close-input-port procedure derived)
  (close-output-port procedure derived)
  (eol-style procedure derived)
  (flush-output-port procedure derived)
  (input-port-position procedure derived)
  (input-port? procedure derived)
  (latin-1-codec procedure derived)
  (newline procedure derived)
  (open-bytes-input-port procedure derived)
  (open-file-input+output-ports procedure derived)
  (open-file-input-port procedure derived)
  (open-file-output-port procedure derived)
  (open-reader-input-port procedure derived)
  (open-string-input-port procedure derived)
  (open-writer-output-port procedure derived)
  (output-port-buffer-mode procedure derived)
  (output-port-position procedure derived)
  (output-port? procedure derived)
  (peek-char procedure derived)
  (peek-u8 procedure derived)
  (port-eof? procedure derived)
  (read-bytes-all procedure derived)
  (read-bytes-n procedure derived)
  (read-bytes-n! procedure derived)
  (read-bytes-some procedure derived)
  (read-char procedure derived)
  (read-datum procedure derived)
  (read-string procedure derived)
  (read-string-all procedure derived)
  (read-string-n procedure derived)
  (read-string-n! procedure derived)
  (read-u8 procedure derived)
  (set-input-port-position! procedure derived)
  (set-output-port-buffer-mode! procedure derived)
  (set-output-port-position! procedure derived)
  (standard-error-port procedure derived)
  (standard-input-port procedure derived)
  (standard-output-port procedure derived)
  (transcode-input-port! procedure derived)
  (transcode-output-port! procedure derived)
  (transcoder procedure derived)
  (update-transcoder procedure derived)
  (utf-16be-codec procedure derived)
  (utf-16le-codec procedure derived)
  (utf-32be-codec procedure derived)
  (utf-32le-codec procedure derived)
  (write-bytes procedure derived)
  (write-char procedure derived)
  (write-datum procedure derived)
  (write-string-n procedure derived)
  (write-u8 procedure derived))
 ("records-procedural"
  (make-record-constructor-descriptor procedure derived)
  (make-record-type-descriptor procedure derived)
  (record-accessor procedure derived)
  (record-constructor procedure derived)
  (record-mutator procedure derived)
  (record-predicate procedure derived)
  (record-type-descriptor? procedure derived))
 ("records-explicit"
  (define-record-type procedure derived)
  (record-constructor-descriptor procedure derived)
  (record-type-descriptor procedure derived))
 ("records-implicit"
  (define-record-type procedure derived)
  (record-constructor-descriptor procedure derived)
  (record-type-descriptor procedure derived))
 ("records-reflection"
  (record-field-mutable? procedure derived)
  (record-rtd procedure derived)
  (record-type-field-names procedure derived)
  (record-type-generative? procedure derived)
  (record-type-name procedure derived)
  (record-type-opaque? procedure derived)
  (record-type-parent procedure derived)
  (record-type-sealed? procedure derived)
  (record-type-uid procedure derived)
  (record? procedure derived))
 ("when-unless" (unless procedure derived) (when procedure derived))
 ("case-lambda" (case-lambda procedure derived))
 ("promises" (delay procedure derived) (force procedure derived))
 ("eval"
  (eval procedure derived)
  (eval-library procedure derived)
  (library-environment procedure derived)
  (load procedure derived))
 ("hash"
  (equal-hash procedure derived)
  (hash-table-clear! procedure derived)
  (hash-table-contains? procedure derived)
  (hash-table-copy procedure derived)
  (hash-table-delete! procedure derived)
  (hash-table-equivalence-predicate procedure derived)
  (hash-table-fold procedure derived)
  (hash-table-for-each procedure derived)
  (hash-table-get procedure derived)
  (hash-table-hash-function procedure derived)
  (hash-table-mutable? procedure derived)
  (hash-table-ref procedure derived)
  (hash-table-ref/call procedure derived)
  (hash-table-ref/default procedure derived)
  (hash-table-ref/thunk procedure derived)
  (hash-table-set! procedure derived)
  (hash-table-size procedure derived)
  (hash-table-update! procedure derived)
  (hash-table-update!/call procedure derived)
  (hash-table-update!/default procedure derived)
  (hash-table-update!/thunk procedure derived)
  (hash-table? procedure derived)
  (make-eq-hash-table procedure derived)
  (make-eqv-hash-table procedure derived)
  (make-hash-table procedure derived)
  (string-ci-hash procedure derived)
  (string-hash procedure derived)
  (symbol-hash procedure derived))
 ("r5rs-compatibility"
  (exact->inexact procedure derived)
  (inexact->exact procedure derived)
  (modulo procedure derived)
  (null-environment procedure derived)
  (quotient procedure derived)
  (remainder procedure derived)
  (scheme-report-environment procedure derived))
 ("r5rs-i/o"
  (call-with-input-file procedure derived)
  (call-with-output-file procedure derived)
  (current-input-port procedure derived)
  (current-output-port procedure derived)
  (display procedure derived)
  (open-input-file procedure derived)
  (open-output-file procedure derived)
  (port? procedure derived)
  (read procedure derived)
  (with-input-from-file procedure derived)
  (with-output-to-file procedure derived)
  (write procedure derived))
 ("obsolete"
  (char-ready? procedure derived)
  (interaction-environment procedure derived)
  (newline procedure derived)
  (transcript-off procedure derived)
  (transcript-on procedure derived)))
