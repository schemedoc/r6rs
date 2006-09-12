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
; This just combines the (proto-unicode1) and (proto-unicode2)
; libraries, which are in separate files because their copyright
; notices are different.

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

  (import (proto-unicode1)
          (proto-unicode2)))
