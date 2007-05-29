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
; Reference implementation of (r6rs unicode)
;
; This just combines the various (proto-unicode*) libraries.
; One of them has to be in a separate file because its copyright
; notice is different from the others, and the others are in
; separate files to impose some modularity upon this library.

(library (r6rs unicode)
  (export

    char-upcase
    char-downcase
    char-titlecase
    char-foldcase

    char-ci=?
    char-ci<?
    char-ci>?
    char-ci<=?
    char-ci>=?

    char-general-category
    char-alphabetic?
    char-numeric?
    char-whitespace?
    char-upper-case?
    char-lower-case?
    char-title-case?

    string-upcase
    string-downcase
    string-titlecase
    string-foldcase

    string-ci=?
    string-ci<?
    string-ci>?
    string-ci<=?
    string-ci>=?

    string-normalize-nfd
    string-normalize-nfkd
    string-normalize-nfc
    string-normalize-nfkc)

  (import ;(proto-unicode0)
           (proto-unicode1)
          ;(proto-unicode2)
           (proto-unicode3)
           (proto-unicode4)))
