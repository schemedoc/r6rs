
The files "r6rs-records-procedural.scm", "r6rs-records-implicit.scm",
"r6rs-records-explicit.scm", and "r6rs-records-inspection.scm" each
contain an R6RS library implementing an R6RS record library.

The core of the procedural implementation (with inspection) is in
"r6rs-records-private-core.scm", again as an R6RS library.  It imports
`(implementation vector-types)', which is an implementation-specific
library for relatively simple generative types. The `(implementation
vector-types)' library must export procedures as described below.

The "generic-vector-types.scm" file implements `(implementation
vector-types)' by building on a SRFI-9 library and `(implementation
opaque-cells)'. The "generic-opaque-cells.scm" file, in turn,
implements `(implementation opaque-cells)' by building on a SRFI-9
library.

The "mzscheme-load.scm" file can be used to load the implementation in
MzScheme. It uses the `(implementation vector-types)' library in
"mzscheme-vector-types.scm". The "mzscheme-load.ss" file begins with a
hacked-up implementaton of `library' and `import' in terms of
MzScheme's `module' and `require'.

The "example.scm" is an R6RS script that contains examples.

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
