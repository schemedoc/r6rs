
The "example.scm" is an R6RS script that contains examples and tests
using records.

The files
  rnrs/records/procedural-6.sls
  rnrs/records/syntactic-6.sls
  rnrs/records/inspection-6.sls
each contain an R6RS library implementing an R6RS record library.

The core of the procedural implementation (with inspection) is in
  rnrs/records/private/core.sls
as an R6RS library.  It imports `(implementation vector-types)', which
is an implementation-specific library for relatively simple generative
types. The `(implementation vector-types)' library must export
procedures as described below.


Executing in MzScheme (with `library' hack)
-------------------------------------------

A MzScheme-specific `(implementation vector-types)' is in
  mzscheme/implementation/vector-types.sls
It supports the implementation of R6RS records with no overhead
over MzScheme's native structure types.

The "mzscheme-load.scm" file can be used to load the implementation in
MzScheme. It uses the `(implementation vector-types)' library in
 mzscheme/implementation/vector-types.sls
The "mzscheme-load.ss" file begins with a hack to implement of
`library' and `import' in terms of MzScheme's `module' and `require'.

To try this implementation using MzScheme:
  > (load "mzscheme-load.scm")
  > (load "example.scm")


Portable Execution via van Tonder `syntax-case' and `library'
-------------------------------------------------------------

As a potential stepping stone for other implementations of
`(implementation vector-types)', the files
  generic/implementation/vector-types.sls
  generic/implementation/opaque-cells.sls
build portably on a SRFI-9 library.

The purpose of these two generic libraries is to clarify the job of
`(implementation vector-types)'.  It's not much of a practical step
forward, though, since it relies on SRFI-9, and if you can implement
SRFI-9, then you probably have a more direct route (with less
overhead) for implementing `(implementation vector-types)'.

Indeed, the files
  generic/implementation/srfi_9.sls
  generic/implementation/make-struct-type.sls

implement SRFI-9 in terms of SRFI-9, with even more overhead.  This is
accomplished by defining one record type at the top level, then
importing the constructor and selectors into "make-struct-type.sls",
which is used to implemented SRFI-9 *within* the R6RS module
system. The reason for this back-and-forth is that van Tonder's
library system supports importing primitive values such as a specific
constructor, but not primitive macros.

To run via van Tonder's system, you must first load van Tonder's
system into your Scheme implementation. That is, get "expander.scm"
loaded, along with the standard library included with the
expander. Then, load "vantonder-load.scm".

As of the June-22-2007 version of the van Tonder system, you must
manually replace each `r6rs' in "standard-libraries.scm" to `rnrs'.

The "vantonder-load.scm" file assumes that SRFI-9 becomes available at
the top level in the process of loading the expander, so it can be
used to bootstraps the generic implementation SRFI-9 in terms of
SRFI-9.


Procedures to be supplied by `(implementation vector-types)'
------------------------------------------------------------

 * (make-vector-type name supertype data field-mutability opaque?)
   Generate a new primitive type. 

    - The `name' symbol is provided for debugging use, only.

    - The `supertype' argument is either #f or a previous result from
      `make-vector-type'; in the latter case, the resulting type must
      be a subtype of the given type.

    - The `data' argument is an arbitrary value to be extracted from
      the result type later via `vector-type-data'.

    - The `field-mutability' argument is a list of booleans. The
      length of the list corresponds to the total number of fields in
      the record (including any that are in the supertype), and each
      boolean is #t if the corresponding field is mutable.

      The vector-type library need not enforce immutability, because
      that it handled at the procedural core level. However, the
      vector-type library must enforce the argument count of a
      type's constructor.

    - The `opaque?' boolean argument indicates whether the type is
      opaque. The vector-type library need not implement the
      inspection implications of opacity, because that is implemented
      at the procedural core level. The vector-type library is only
      responsible for opacity as it might interact with non-R6RS
      features of the implementation; in other words the vector-type
      library could ignore this argument.

   The result is a descriptor for a generative type. That is,
   instances of the type will not match predicates for any existing
   type, except the predicates matches by the supertype (if any).

 * (vector-type? v) - Returns #t if `v' is a result produced by
   `make-vector-type', #f otherwise.

 * (vector-type-data vt) - Returns the `data' argument for the call
   to `make-vector-type' that produced `vt'.

 * (vector-type-predicate vt) - Returns a predicate that recognizes
   instances of `vt' and its subtypes.

 * (typed-vector-constructor vt) - Returns a constructor that takes as
   many arguments as the length of `field-mutability' for the call to
   `make-vector-type' that produced `vt'. The result of the
   constructor is an instance of `vt' with the given arguments as the
   instance's field values.

 * (typed-vector-accessor vt pos) - Returns an accessor procedure that
   extracts the `pos'th field from an instance of `vt'. The
   `typed-vector-accessor' procedure is only provided sensible `pos'
   values, but the resulting accessor must check that a provided value
   is an instance of `vt' (or any of its subtypes).

 * (typed-vector-mutator vt pos) - Returns an mutator procedure that
   sets the `pos'th field from an instance of `vt' to a given
   value. The `typed-vector-accessor' procedure is only provided
   sensible `pos' values (i.e., for mutable fields), but the resulting
   accessor must check that a provided value is an instance of `vt'
   (or any of its subtypes).

 * (typed-vector? v) - Returns #t if `v' is an instance of a
   non-opaque type prodcued by `make-vector-type'. The `typed-vector?'
   procedure may also return #t for instances of opaque vector
   types. It must return #f for anything else.

 * (typed-vector-type v) - Returns the vector type for which `v' is an
   instance. The `typed-vector-type' procedure is only applied to `v'
   is `(typed-vector? v)' produces #t.
