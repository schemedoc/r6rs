; PLT module definition for implementation of procedural layer for Records SRFI

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

(module procedural-record-types-all mzscheme
  (provide make-record-type-descriptor
	   record-type-descriptor?
	   record-type-name
	   record-type-parent
	   record-type-sealed?
	   record-type-uid
	   record-type-field-names
	   record-type-opaque?
	   make-record-constructor-descriptor record-constructor
	   record-predicate
	   record-accessor record-mutator
	   record-field-mutable? record-type-generative?
	   record? record-rtd)
  (require (only (lib "1.ss" "srfi") find every any delete-duplicates split-at)
	   (lib "26.ss" "srfi")) ; CUT
  
  (require "opaque-cells.ss")
  (require "vector-types.ss")

  (require (lib "include.ss"))
  (include "procedural-record.scm"))
