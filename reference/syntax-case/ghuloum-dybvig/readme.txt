Copyright (c) 2006 Aziz Ghuloum and Kent Dybvig

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE. 

------------------------------------------------------------------------
September 13, 2006
------------------------------------------------------------------------

There are many tests (both valid compilable libraries and invalid
libraries) in tests.ss.  To run the the tests using Chez Scheme or Petite
Chez Scheme, type the following at the shell prompt:

$ scheme library-manager.ss psyntax-7.1.pp syntax.ss test.ss

Alternatively, load the previous files in sequence at the Scheme REPL.

psyntax-7.1.pp is the expanded version of the portable syntax-case
expander and is required to bootstrap syntax.ss, which makes heavy use of
syntax-case.

------------------------------------------------------------------------
Description of the library manager

The library manager takes care of managing the libraries installed in the
system.  Every library is represented internally as follows:

   (define-record library (name version subst phases))

* The library name and version are both lists.
* The subst is a mapping from exported names to labels.
* The phases is a list of phase records:

  (define-record phase (name version imports import-phases visit invoke))

* The name and version are the same as the library's name and version.
* The imports is a list of libraries whos phase-0 must be visited
  before this library phase is visited and phase-0 is invoked before this 
  library phase is invoked.
* The phases field is a list of phase records corresponding to the ones in
  the imports.  It is used for looking up re-exported labels.
* A visit field which is initially a procedure that, when invoked, returns
  an environment mapping labels to bindings.  During evaluation, the value
  of the field is the symbol |pending| that is used to detect visit
  circularities.  After evaluation, the procedure is replaced by its return
  value and the code is dropped.
* An invoke field which is initially a procedure that, when invoked,
  initialized the exported identifiers of the library.  During evaluation,
  the value of the field is the symbol |pending|.  After evaluation, the
  procedure is replaced by #t and the code is dropped.
