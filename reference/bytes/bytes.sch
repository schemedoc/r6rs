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
; (r6rs bytes)
;
; Bytes objects

(library (r6rs bytes)

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
          bytes-ieee-single-native-ref bytes-ieee-single-ref
          bytes-ieee-double-native-ref bytes-ieee-double-ref
          bytes-ieee-single-native-set! bytes-ieee-single-set!
          bytes-ieee-double-native-set! bytes-ieee-double-set!
          bytes-copy! bytes-copy
          bytes->u8-list u8-list->bytes
          bytes->uint-list bytes->sint-list
          uint-list->bytes sint-list->bytes)

  (import (r6rs base) bytes-core bytes-proto bytes-ieee)

)
