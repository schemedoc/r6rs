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
; (r6rs bytevector)
;
; Bytevectors

(library (r6rs bytevector)

  (export endianness native-endianness
          bytevector? make-bytevector bytevector-length
          bytevector-u8-ref bytevector-s8-ref
          bytevector-u8-set! bytevector-s8-set!
          bytevector-uint-ref bytevector-sint-ref
          bytevector-uint-set! bytevector-sint-set!
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
          bytevector=?
          bytevector-ieee-single-native-ref bytevector-ieee-single-ref
          bytevector-ieee-double-native-ref bytevector-ieee-double-ref
          bytevector-ieee-single-native-set! bytevector-ieee-single-set!
          bytevector-ieee-double-native-set! bytevector-ieee-double-set!
          bytevector-copy! bytevector-copy
          bytevector->u8-list u8-list->bytevector
          bytevector->uint-list bytevector->sint-list
          uint-list->bytevector sint-list->bytevector

          utf8->string utf16->string utf32->string
          string->utf8 string->utf16 string->utf32)

  (import (r6rs base)
   bytevector-core bytevector-proto bytevector-ieee bytevector-string)

)
