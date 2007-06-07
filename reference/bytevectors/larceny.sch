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
; This Larceny-specific file tests Larceny's bytevector procedures
; by running the tests in bytevector-tests.sch.
;
; This file does not test the reference implementation directly,
; but it tests the reference implementation as adapted for use
; in Larceny v0.94.
;

; Load the tests.

(load "bytevector-tests.sch")

; Run the tests.

(display "Running (basic-bytevector-tests)")
(newline)
(basic-bytevector-tests)

(display "Running (ieee-bytevector-tests)")
(newline)
(ieee-bytevector-tests)

(display "Running (string-bytevector-tests)")
(newline)
(string-bytevector-tests)

(display "Running (exhaustive-string-bytevector-tests)")
(newline)
(exhaustive-string-bytevector-tests)

