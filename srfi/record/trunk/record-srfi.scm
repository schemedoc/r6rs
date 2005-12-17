(load "srfi-template.scm")

(define nl (string #\newline))

(define record-srfi
  `(html:begin
    (srfi 76
     "R6RS Records"
     "Will Clinger, R. Kent Dybvig, Michael Sperber, Anton van Straaten"

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      (h1 "Note")

      (p 
       "This SRFI is being submitted by a member of the Scheme "
       "Language Editor's Committee as part of the Scheme standardization "
       "process.  The purpose of such ``R6RS SRFIs'' is to inform the Scheme "
       "community of features and design ideas under consideration by the "
       "editors and to allow the community to give the editors some direct "
       "feedback that will be considered during the design process.")

      (p
       "At the end of the discussion period, this SRFI will be withdrawn. "
       "When the R6RS specification is finalized, the SRFI may be revised to "
       "conform to the R6RS specification and then resubmitted with the intent "
       "to finalize it.  This procedure aims to avoid the situation where this "
       "SRFI is inconsistent with R6RS.  An inconsistency between R6RS and "
       "this SRFI could confuse some users.  Moreover it could pose "
       "implementation problems for R6RS compliant Scheme systems that aim to "
       "support this SRFI.  Note that departures from the SRFI specification "
       "by the Scheme Language Editor's Committee may occur due to other "
       "design constraints, such as design consistency with other features "
       "that are not under discussion as SRFIs. ")

      (h1 "Abstract")

      (p
       "This SRFI describes abstractions for creating new data types representing "
       "records - data structures with named fields.  This SRFI comes in four "
       "parts:")

      (ul
       (li
        "a procedural layer for creating and manipulating record types and record
         instances")
       (li
        "an explicit-naming syntactic layer for defining the various entities associated "
        "with a record type "
        "- construction procedure, predicate, field accessors, mutators, etc. - at once")
       (li
        "an implicit-naming syntactic layer built on top of explicit-naming syntactic "
        "layer, which chooses the names for the various products based on the names of "
        "the record type and fields")
       (li
        "a set of reflection procedures"))

      (h1 "Rationale")

      (p
       "The procedural layer allows dynamic construction of new record types and "
       "associated procedures for creating and manipulating records, "
       "which is particularly useful when writing interpreters that "
       "construct host-compatible record types.  It may also serve as a target "
       "for expansion of the syntactic layers.")

      (p
       "The procedural layer allows record types to be extended.  This allows "
       "using record types to naturally model hierarchies that occur in applications "
       "like algebraic data types, and also single-inheritance class systems.  "
       "This model of extension has a well-understood representation that is simple "
       "to implement.")

      (p
       "The explicit-naming syntactic layer provides a basic syntactic interface "
       "whereby a single record definition serves as a shorthand for the definition "
       "of several record creation and manipulation routines: a construction procedure, "
       "a predicate, accessors, and mutators. "
       "As the name suggests, the explicit-naming syntactic layer requires the "
       "programmer to name each of these products explicitly. "
       "The explicit-naming syntactic layer is similar to "
       (a (@ (href "http://srfi.schemers.org/srfi-9/")) "SRFI 9: Defining Record Types") ", "
       "but adds several features, including single inheritance and non-generative "
       "record types.")

      (p
       "The implicit-naming syntactic layer extends the explicit-naming syntactic layer "
       "by allowing the names for construction procedure, predicate, accessors, and mutators "
       "to be determined automatically from the name of the record and names of "
       "the fields.  This establishes a standard naming convention and allows "
       "record-type definitions to be more succinct, with the downside that the "
       "product definitions cannot easily be located via a simple search for the "
       "product name.  The programmer may override some or all of the default names "
       "by specifying them explicitly as in the explicit-naming syntactic layer.")

      (p
       "The syntax of both syntactic layers is also designed to allow future extensions "
       "by using clauses introduced by keywords.")

      (p
       "The two layers are designed to be fully compatible; the implicit-naming layer is simply "
       "a conservative extension of the explicit-naming layer.  The goal is to "
       "make both explicit-naming and implicit-naming definitions reasonably natural "
       "while allowing a seamless transition between explicit and implicit naming.")

      (p
       "The reflection procedures allow programs to obtain from a record instance "
       "a descriptor for the type and from there obtain access to the fields of "
       "the record instance.  This allows the creation of portable printers and "
       "inspectors.  A program may prevent access to a record's type and thereby "
       "protect the information stored in the record from the reflection mechanism "
       "by declaring the type " (i "opaque") ".  Thus, opacity as presented here "
       "can be used to enforce abstraction barriers---it is not intended as a security "
       "mechanism.")

      (p
       "Fresh record types may be generated at different times---for example, when "
       "a record-type-defining form is expanded, or when it is evaluated.  The available "
       "choices all have different advantages and trade-offs.  These typically "
       "come into play when a record-type-defining form may be evaluated multiple times, "
       "for example, as part of interactive operation of the Scheme system, or as a body "
       "form of an abstraction.  The SRFI leaves the default generativity largely "
       "unspecified to allow different implementations, but also provides for "
       "non-generativity, which guarantees that the evaluation of identical "
       "record-type-defining forms yields compatible record types.")
       

      (h1 "Issues")

      (ul
       (li 
	(p
        "The name " (code "define-record-type") " is used for both the "
        "implicit-naming and explicit-naming syntactic interfaces. "
        "It is unclear whether both names should in fact be the same. "
        "With different names it would be easier to identify when only "
        "the explicit-naming interface is being used; presumably, "
        "a module system would also make this possible.  "
	"On the other hand, with different names it would also be "
	"more difficult to transition between the two interfaces, "
	"and the name to use for partly implicit, partly explicit record "
	"definitions might not be obvious."))

       (li
	(p
	 "Compared to some other record-defining forms that have been proposed and implemented, "
	 "the syntax is comparatively verbose.  For instance, PLT Scheme has a "
	 (code "define-struct") " form that allows record-type definitions as short as this:")
	(verbatim
	 "(define-struct point (x y))")
	(p
	 "The " (a (@ (href "#design-rationale")) "Design Rationale section")
	 " explains why.")
        (p
         "It would be possible to introduce abbreviations into the syntax. "
         "In the " (code "fields") " clause, a single identifier might serve as a shorthand "
         "for a " (code "mutable") " field clause:")
        (verbatim
         "(define-record-type point (fields x y))")

	(p
	 "Allowing such abbreviations would make some record definitions more "
	 "concise but may also discourage programmers from specifying valuable "
	 "field mutability information and taking advantage of nontrivial "
	 "field initializers.  In any case, it is trivial to define forms like "
	 (code "define-struct") " on top of this proposal."))

       (li
	(p
	 "Similarly, one might allow plain symbols to be used as field specifiers "
	 "in the " (var "fields") " argument to " (code "make-record-type-descriptor")
	 ", defaulting to mutability or immutability."))

       (li
	(p
	 "Macros that expand into the implicit-naming layer might have "
	 "unexpected behavior, as field names that are distinct as identifiers "
	 "may not be distinct as symbols, which is how they're used.  For this "
	 "reason, and to simplify the proposal should the implicit-naming layer "
	 "be dropped?"))
	        
       (li
	(p
	 "The specification of " (code "make-record-type-descriptor") " has this:")
	(blockquote
	 "If " (var "parent") " is not " (code "#f") ", and " (var "uid")
	 " is not " (code "#f") ", and the parent is generative "
	 " (i.e. its uid is " (code "#f") "), an error is signalled.")
	(p
	 "However, the semantics would be perfectly clear even in the error case "
	 "described above.  Should this restriction be lifted, if only for reasons "
	 "of simplicity?"))
       (li
	(p
	 "The specification of " (code "eq?") " on records allows certain kinds "
	 "of unboxing optimizations, at the cost of leaving its behavior on records unspecified.  "
	 "Should instead the following be required to hold for immutable records as well?")
	(verbatim
	 "(let ((r (construct ...)))"
	 "  (eq? r r))                ==> #t"))
       (li
	(p
	 "The behavior of " (code "equal?") " on records is one of several possibilities. "
	 "See the " (a (@ (href "http://www.lisp.org/HyperSpec/Issues/iss143-writeup.html"))
		       "Issue EQUAL-STRUCTURE Writeup")
	 " in the Common Lisp HyperSpec on why any behavior of " (code "equal?") " on "
	 "records is wrong for some purposes."))
       (li
	(p
	 "There is no way to use a record-type descriptor created by a call to "
	 (code "make-record-type-descriptor") " as a parent type in a "
	 (code "define-record-type") " form.  Should this be rectified, for example by "
	 "another " (code "define-record-type") " clause named " (code "parent-rtd") "?"))

       (li
	(p
	 "The time at which a record-type descriptor is generated for the syntactic "
	 "record-type-definition forms "
	 "is presently unspecified.  Should this be tightened, and, if so, to what kind "
	 "of generativity?"))

       (li
	(p
	 "Record-types defined via the syntactic layer default to non-opaque.  "
	 "Should they default to opaque instead?"))

       (li
	(p
	 "The concepts of typed aggregates (with subtyping) with positional addressing "
	 "and opacity can be separated from the much heavier and more arbitrary composite notion "
	 "of records with named fields defined in this SRFI - see the reference "
	 "implementation on how it's done.  Should these be the primitive part of "
	 "the standard, and records derived from them?"))

       (li
	(p
	 "Functional update and/or copy operations would be useful additions.  "
	 "(See " (a (@ (href "http://srfi.schemers.org/srfi-76/mail-archive/msg00066.html"))
		   "this post")
	 " for some discussion on the issue.)  However, there are several design "
	 " issues with these operations:")
	(ul
	 (li
	  "Should a copy/update operation for a given record type be able to copy "
	  "records of an extension?")
	 (li
	  "If so, what should the semantics be?")
	 (li
	  "If so, should a record type be able to prevent copy/update for its "
	  "children?")
	 (li
	  "How does update interact with the regular creation of new records? "
	  "Specifically, can updaters be built using something similar to the "
	  "makers used for creating constructors?")))

       (li
	(p
	 "Should the " (code "nongenerative") " clause take an expression operand rather than "
	 "a symbol, as argued "
	 (a (@ (href "http://srfi.schemers.org/srfi-76/mail-archive/msg00056.html")) "here")
	 "?"))
	
       )

      (p
       "We invite members of the Scheme community to express their opinions on these issues.")

      (h1 "Specification")

      (h2 "Procedural layer")

      (dl
       (dt
        (prototype "make-record-type-descriptor"
                   (var "name")
                   (var "parent")
                   (var "uid")
                   (var "sealed?")
                   (var "opaque?")
                   (var "fields")))
       (dd
        (p
         "This returns a " (i "record-type descriptor") ", or " (i "rtd") ".  The rtd "
         "represents a record type distinct from all built in types and other record types.  The "
         "rtd and the data type it represents are new except possibly if " (var "uid")
         " is provided (see below).")
        (p
         "The " (var "name") " argument must be a symbol naming the record type; "
         "it is purely for informational purposes, and may be used for printing by "
         "the underlying Scheme system.")
        (p
         "The " (var "parent") " argument is either " (code "#f") " or an "
         "rtd.  If it is an rtd, "
         "the returned record type, " (i "t") ", " (i "extends") " the record "
         "type " (i "p") " represented by " (var "parent") ".  Each "
         "record of type " (i "t") " is also a record of type " (i "p") ", and "
         "all operations applicable to a record of type " (i "p") " are also "
         "applicable to a record of type " (i "t") ", except for reflection "
	 "operations if " (i "t") " is opaque but " (i "p") " is not.  "
         "An error is signalled if " (var "parent") " is sealed (see below).")
        (p
         "The extension relationship is transitive in the sense that a type extends "
         "its parent's parent, if any, and so on. ")
        (p
         "The " (var "uid") " argument is either " (code "#f") " or a symbol. "
         "If it is a symbol, the created record type is " (i "non-generative") ", i.e. "
         "there may be only one record type with that uid in the entire system "
	 "(in the sense of " (code "eqv?") ").  "
         "When " (code "make-record-type-descriptor") " is called repeatedly with the "
         "same " (var "uid") " argument (in the sense of " (code "eq?") "), the "
	 (var "parent") " argument must be the same in the sense of " (code "eqv?")
	 " (more on this below), and the " (var "uid") ", " (var "sealed?") ", "
	 (var "opaque?") ", and " (var "fields") " arguments must be the same in the "
	 "sense of " (code "equal?") ".  In this case, the same "
         "record-type descriptor (in the sense of " (code "eqv?") ") is returned every time.  "
	 "If a call with the same "
         "uid differs in any argument, an error is signalled.  If " (var "uid") " is "
         (code "#f") ", or if no record type with the given uid has been created "
         "before, " (code "make-record-type-descriptor") " returns a fresh "
         "record-type descriptor representing a new type disjoint from all other types.")

	(blockquote
	 (i "Note: ")
	 "Users are strongly strongly encouraged to use symbol names "
	 "constructed using the "
	 (a (@ (href "http://www.ietf.org/rfc/rfc4122")) "UUID namespace")
	 " (for example, using the record-type name as a prefix) for the "
	 (var "uid") " argument.")

	(p
	 "If " (var "parent") " is not " (code "#f") ", and " (var "uid")
	 " is not " (code "#f") ", and the parent is generative "
	 " (i.e. its uid is " (code "#f") "), an error is signalled.  "
	 "In other words, the parent of a non-generative rtd must be "
	 "non-generative itself.")

        (p
         "The " (var "sealed?") " flag is a boolean.  If true, the "
         "returned record type is " (i "sealed") ", i.e., it cannot be extended.")

        (p
         "The " (var "opaque?") " flag is a boolean.  If true, the "
         "returned record type is " (i "opaque") ".  This means that calls to "
         (code "record?") " will return " (code "#f") " and "
	 (code "record-rtd") " (see \"Reflection\" below) will signal an error. "
         "The record type is also opaque if an opaque parent is supplied. "
         "If " (var "opaque?") " is false and an opaque parent is not supplied, "
         "the record is not opaque.")

        (p
         "The " (var "fields") " argument must be a list of " (var "field specifiers") ". "
         "Each " (var "field specifier") " must be "
         "a list of the form " (code "(mutable ") (var "name") (code ")") ", or a list "
         " of the form " (code "(immutable ") (var "name") (code ")") ". "
         "The specified fields are added to the parent fields, if any, to "
         "determine the complete set of fields of the returned record type. "
         "Each " (var "name") " must be a symbol and names the corresponding field of the "
         "record type; the names not must be distinct. "
         "A field with tag " (code "mutable") " may be modified, whereas an attempt "
	 "to obtain a mutator for a field "
	 "with tag " (code "immutable") " will signal an error.")
        (p
	 "Where field order is relevant, e.g., for record construction and "
	 "field access, the fields are considered to be ordered as specified, "
	 "although no particular order is required for the actual representation "
	 "of a record instance.")
	(p
	 "A record type whose complete set of fields "
	 "are all immutable is called " (i "immutable") " itself.  Conversely, a record type "
	 "is called " (i "mutable") " if there is at least one mutable field in its complete "
	 "set of fields.")
	(p
	 "A generative record-type descriptor created by a call to " 
	 (code "make-record-type-descriptor") " is not " (code "eqv?") " to any "
	 "record-type descriptor (generative or non-generative) created by another "
	 "call to " (code "make-record-type-descriptor") ".  A generative record-type "
	 "descriptor is only " (code "eqv?") " to itself, i.e., " (code "(eqv? rtd1 rtd2)")
	 " iff " (code "(eq? rtd1 rtd2)") ".  Moreover:")
	 (verbatim
	 "(let ((rtd (make-record-type-descriptor ...)))"
	 "  (eqv? rtd rtd))                ==> #t")
	 (p
	  "Note that this does " (em "not") " imply the following:")
	 (verbatim
	  "(let ((rtd (make-record-type-descriptor ...)))"
	  "  (eq? rtd rtd))                 ==> #t")
	 (p
	  "Also, two non-generative record-type descriptors are " (code "eqv?")
	  " if they were successfully created by calls to " (code "make-record-type-descriptor")
	  " with the same " (var "uid") " arguments."))


       (dt
        (prototype "record-type-descriptor?"
                   (var "obj")))
       (dd
        (p
         "This returns " (code "#t") " if the argument is a record-type descriptor, "
         (code "#f") " otherwise."))

       (dt
	(prototype "make-record-type-maker"
		   (var "rtd")
		   (var "cons-cons")
		   (var "maker")))
       (dd
	(p
	 "This returns a " (i "record-type maker") " (or " (i "maker")
	 " for short) that can be used to create record constructors (via "
	 (code "record-constructor") "; see below) or other makers. "
	 (var "Rtd") " must be a record-type descriptor.  " (var "Cons-cons")
	 " is a " (i "constructor constructor") ", a procedure of one parameter "
	 "that must itself return a procedure, the " (i "constructor") ".  The "
	 (var "cons-cons") " procedure will be called by " (code "record-constructor")
	 " with a procedure " (var "c") " as an argument that  can be used to construct the "
	 "record object itself and seed its fields with initial values.")
	(p
	 "If " (var "rtd") " is " (em "not") " an extension of another record type, "
	 (var "c") " is a procedure with a parameter for every field of "
	 (var "rtd") "; calling it will return a record object with the "
	 "fields of " (var "rtd") " initialized to the arguments of the call.")

	(p "Constructor-constructor example:")
	(verbatim
	 "(lambda (c) (lambda (v ...)  (c v ...)))")
	(p
	 "Here, the call to " (code "c") 
	 " will return a record where the fields of " (var "rtd") " are "
	 "simply initialized with the arguments " (code "v ...") ".")
	(p
	 "As the constructor constructor can be used to construct records of an "
	 "extension of " (var "rtd") ", the record returned by " (var "c") 
	 " may be of a record type extending " (var "rtd") ".  (See below.)")

	(p
	 "If " (var "rtd") " " (em "is") " an extension of another record type " (var "rtd'")
	 ", " (var "maker") " itself must be a record-type maker of " (var "rtd'")
	 " (except for default values; see below).  In this case, "
	 (var "c") " is a procedure that accepts arguments that will be passed "
	 "unchanged to the constructor of " (var "maker") "; " (var "c")
	 " will return another procedure that accepts as argument the initial "
	 "values for the fields of " (var "rtd") " and itself returns "
	 "what the constructor of " (var "maker") " returns.  "
	 "(this should typically be the record object itself)  "
	 "with the field values of " (var "rtd'") " (and its parent and so on) "
	 "initialized according to " (var "maker") " and with the field values of "
	 (var "rtd") " initialized according to " (var "c") ".")

	(p "Constructor-constructor example")
	(verbatim
	 "(lambda (c) (lambda (x ... v ...) ((p x ...) v ...)")
	(p
	 "This will initialize the fields of the parent of " (var "rtd")
	 "according to " (var "maker") ", calling the associated constructor with "
	 (code "x ...") " as arguments, and initializing the fields of " (var "rtd")
	 " itself with " (code "v ...") ".")
	(p
	 "In other words, makers for a record type form a chain of "
	 "constructor constructors exactly parallel to the chain of record-type parents. "
	 "Each maker in the chain determines the field values for the "
	 "associated record type.")

	(p
	 "If " (var "rtd") " is not an extension of another record type, "
	 "then " (var "maker") " must be " (code "#f") ".")
	(p
	 (var "Cons-cons") " can be " (code "#f") ", specifying a default.  "
	 "This is only admissible if either " (var "rtd")
	 " is not an extension of another record type, or, if it is, " 
	 " if " (var "maker") " itself was constructed with " 
	 " a default constructor constructor.  In the first case, "
	 (var "cons-cons") " will default to a procedure equivalent to the following:")
	(verbatim
	 "(lambda (c)"
	 "  (lambda field-values"
	 "    (apply c field-values)))")

	(p
	 "In the latter case, it will default to a constructor constructor "
	 "that returns a constructor that will accept as many arguments "
	 " as " (var "rtd") " has total fields (i.e. as the sum of the "
	 "number of fields in the entire chain of record types) "
	 " and will return a record with fields initialized to those arguments, "
	 " with the field values for the parent coming before those of the "
	 " extension in the argument list."))

       (dt
        (prototype "record-constructor"
                   (var "maker")))

       (dd
        (p
         "Calls the constructor constructor of record-type maker " (var "maker")
	 " with an appropriate procedure " (var "c") " as an argument "
	 "(see the description of  " (code "make-record-type-maker") ") that "
	 "will create a record of the record type associated with " (var "maker") ".")
	(p
	 "If the record type associated with " (var "maker") "is opaque, then the values "
	 "created by such a constructor are not considered by the reflection "
	 "procedures to be records; see "
	 "the specification of " (code "record?") " below.")
	(p
	 "A record from an immutable record type is called " (i "immutable") "; "
	 "conversely, a record from a mutable record type is called " (i "mutable") ".")
        (p
         "Two records created by such a constructor are equal according to " 
         (code "equal?")
         " iff they are " (code "eqv?") ", provided their record type was not used "
	 "to implement any of the types explicitly mentioned in the definition of "
	 (code "equal?") ".")
	(p
	 "If " (code "construct") " is bound to a constructor returned by "
	 (code "record-constructor") ", the following holds:")
	(verbatim
	 "(let ((r (construct ...)))"
	 "  (eqv? r r))                ==> #t")
	(p
	 "For mutable records, but not necessarily for immutable ones, "
	 "the following holds:")
	(verbatim
	 "(let ((r (construct ...)))"
	 "  (eq? r r))                 ==> #t")
	(p
	 "For mutable records, the following holds:")
	(verbatim "(let ((f (lambda () (construct ...))))"
		  "  (eq? (f) (f))) => #f")
	(p
	 "For immutable records, the value of the above expression "
	 "is unspecified.")
	)

       (dt
        (prototype "record-predicate"
                   (var "rtd")))
       (dd
        (p
         "Returns a procedure that, given an object " (var "obj") ", returns " (code "#t")
         " iff " (var "obj") " is a record of the type represented by " (var "rtd") "."))

       (dt
        (prototype "record-accessor"
                   (var "rtd")
                   (var "k")))
       (dd
        (p
         "Given a record-type descriptor " (var "rtd") " and an exact non-negative integer "
	 (var "k")
         " argument that specifies one "
         "of the fields of " (var "rtd") ", " (code "record-accessor") " returns a one-argument "
         "procedure that, given a record of the type represented by " (var "rtd") ", returns "
         "the value of the selected field of that record.")
	(p
	 "It is an error if the accessor procedure is given something other "
	 "than a record of the type represented by " (var "rtd") ".  Note that "
	 "the records of the type represented by " (var "rtd") " include "
	 "records of extensions of the type represented by " (var "rtd") ".")
        (p
         "The field selected "
	 "is the one corresponding the the " (var "k") "th element (0-based) of the "
	 (var "fields") " argument to the invocation of " (code "make-record-type-descriptor")
	 " that created " (var "rtd") ". "
	 "Note that " (var "k") " cannot be used to specify a field of "
	 "any type " (var "rtd") " extends."))

       (dt
        (prototype "record-mutator"
                   (var "rtd")
                   (var "k")))
       (dd
        (p
         "Given a record-type descriptor " (var "rtd") " and a " (var "k")
         " argument that specifies one "
         "of the mutable fields of " (var "rtd") ", " (code "record-accessor") " returns a "
         "two-argument procedure that, "
         "given a record " (var "r") " of the type represented by " (var "rtd") " and an "
         "object " (var "obj") ", stores " (var "obj")
         " within the field of " (var "r") " specified by " (var "k") ". "
         "The " (var "k") " argument is as in " (code "record-accessor") ". "
         "If " (code "record-mutator") " is called on an immutable field, "
         "an error is signalled."))
       )

      (h2 "Explicit-Naming Syntactic Layer")

      (p
       "The record-type-defining form " (code "define-record-type") " is a
        definition and can appear "
       "anywhere any other " (meta "definition") " can appear.")

      (dl
       (dt
        (prototype "define-record-type"
                   (meta "name-spec")
                   (meta "record clause") "*")
           " (syntax)")
       (dd
        (p
         "A " (code "define-record-type") " form defines a new record type "
         "along with associated maker and constructor, predicate, "
         "field accessors and field mutators.  The " (code "define-record-type") " form "
	 "expands into a set of definitions in the "
	 "environment where " (code "define-record-type") " appears; hence, it is possible to "
	 "refer to the bindings (except for that of the record-type itself) recursively.")

        (p
         "The " (meta "name-spec") " specifies the names of the record type, construction "
	 "procedure, and predicate.  It must take the following form.")

	(p
	 (code "(") (meta "record name") " " (meta "constructor name") " " (meta "predicate name") (code ")"))
         
        (p
         (meta "Record name") ", " (meta "constructor name") ", and " (meta "predicate name")
         " must all be identifiers.")

        (p
         (meta "Record name") " becomes the name of the record type.  Additionally, "
	 "it is bound by this definition "
	 "to an expand-time or run-time description of the "
         "record type for use as parent name in syntactic record-type definitions that extend "
         "this definition.  It may also be used as a handle to gain access to the "
         "underlying record-type descriptor and maker (see " (code "record-type-descriptor")
	 " and " (code "record-type-maker") " below).")

        (p
         (meta "Constructor name") " is defined by this definition to a constructor for "
	 "the defined record type, with a constructor constructor specified by the "
	 (code "constructor-constructor") " clause, or, in its absence, using a default value. "
	 "For details, see the description of the " (code "constructor-constructor")
	 "clause below.")

        (p
         (meta "Predicate name") " is defined by this definition to a predicate for the defined "
         "record type.")

        (p
         "Each " (meta "record clause") " must take one of the following forms; "
	 "it is an error if multiple "
	 (meta "record clause") "s of the same kind "
	 "appear in a " (code "define-record-type") " form.")

        (dl
         (dt (prototype "fields" (meta "field-spec") "*"))
         (dd
          (p
           "where each " (meta "field-spec") " has one of the following forms")
          (dl
           (dt
            (prototype (meta "field name") (code " (") (meta "accessor name") (code ")")))
           (dt
            (prototype (meta "field name") (code " (") (meta "accessor name") (meta "mutator name") (code ")"))))
          (p
           (meta "Field name") ", " (meta "accessor name") ", and " (meta "mutator name")
           " must all be identifiers. "
           "The first form declares an immutable field called " (meta "field name")
           ", with the corresponding "
           "accessor named " (meta "acccessor name") ". "
           "The second form declares a mutable field called " (meta "field name")
           ", with the corresponding "
           "accessor named " (meta "acccessor name") ", and with the corresponding "
           "mutator named " (meta "mutator name") ".")
	  (p
	   "The " (meta "field name") "s become, as symbols, "
	   "the names of the fields of the record type being created, in the same order.  "
	   "They are not used in any other way."))

         (dt
          (prototype "parent" (meta "parent name")))
         (dd
          (p
           "This specifies that the record type is to have parent type "
           (meta "parent name") ", where " (meta "parent name") " is the "
           (meta "record name") " of a record type previously defined using "
	   (code "define-record-type") ". "
           "The absence of a " (code "parent") " clause implies a "
           "record type with no parent type."))

	 (dt
	  (prototype "constructor-constructor" (meta "exp")))
	 (dd
	  (p
	   (meta "Exp") " is evaluated in the same environment as the "
	   (code "define-record-type") " form, and must evaluate to a "
	   "constructor constructor appropriate for the record type being "
	   "defined (see above in the description of " (code "make-record-type-maker")
	   ").  The constructor constructor is used to create a record-type maker "
	   "where, if the record-type being defined has a parent, the parent-type maker "
	   "is that associated with the parent type specified in the " (code "parent")
	   " clause.")
	  (p
	   "If no " (code "constructor-constructor") " clause is specified, a maker is still "
	   "created using a default constructor constructor.  The rules for this are the same "
	   "as for " (code "make-record-type-maker") ": the clause can only be absent "
	   "if the record type defined has no parent type, or if the parent type itself "
	   "specified a default constructor constructor."))

	 (dt
	  (prototype "sealed" (code "#t")))
	 (dt
	  (prototype "sealed" (code "#f")))
	 (dd
	  (p
	   "If this option is specified, it means that the opacity of the type is "
	   "the value specified as the operand.  "
	   "If no " (code "sealed")
	   " option is present, the defined record type is not sealed."))
	 (dt
	  (prototype "opaque" (code "#t")))
	 (dt
	  (prototype "opaque" (code "#f")))
	 (dd
	  (p
	   "If this option is specified, it means that the opacity of the type is "
	   "the value specified as the operand.  "
	   "It is also opaque if an opaque parent is specified. "
	   "If the " (code "opaque") " option is not present, the record type is "
	   "not opaque."))

         (dt
          (prototype "nongenerative" (meta "uid")))
         (dd
          (p
           "This specifies that the record type be nongenerative with uid "
           (meta "uid") ", which must be an " (meta "identifier") ". "
           "The absence of a " (code "nongenerative") " clause implies that "
           "the defined type is generative.  In the latter case, a new type "
           "may be generated once for each evaluation of the record definition "
           "or once for all evaluations of the record definition, but the type "
           "is guaranteed to be distinct even for verbatim copies of the same "
           "record definition appearing in different parts of a program.")))
	
	(p
	 "Note that all bindings created by this form (for the record type, "
	 "the construction procedure, the predicate, the accessors, and the mutators) "
	 "must have names that are pairwise distinct.")
	
	(p
	 "For two non-generative record-type definitions with the same uid, if the "
	 "implied arguments to " (code "make-record-type-descriptor") " "
	 "would create an equivalent record-type descriptor, the created type "
	 "is the same as the previous one.  Otherwise, an error is signalled.")
	(p
	 "Note again that, in the absence of a " (code "nongenerative") " clause, the "
	 "question of expand-time or run-time generativity is unspecified.  Specifically, "
	 "the return value of the following expression in unspecified:")
	(verbatim
	 "(let ((f (lambda (x) (define-record-type r ---) (if x r? (make-r ---)))))"
	 "  ((f #t) (f #f)))"))

       (dt
        (prototype "record-type-descriptor"
                   (meta "record name"))
        " (syntax)")
       (dd
        (p
         "This evaluates to the record-type descriptor associated with the type "
         "specified by " (meta "record-name") ".")
	(p
	 "Note that, in the absense, of a " (code "nongenerative") " clause, "
	 "the return value of the following expression is unspecified:")
	(verbatim
	 "(let ((f (lambda () (define-record-type r ---) (record-type-descriptor r))))"
	 "  (eqv? (f) (f)))")
	(p
	 "Note that " (code "record-type-descriptor") "  works on "
	 "both opaque and non-opaque record types."))

       (dt
        (prototype "record-type-maker"
                   (meta "record name"))
        " (syntax)")
       (dd
        (p
         "This evaluates to the record-type maker associated with the type "
         "specified by " (meta "record-name") ".")))

      (h2 "Implicit-Naming Syntactic Layer")

      (p
       "The " (code "define-record-type") " form of the implicit-naming syntactic layer is "
       " a conservative extension of the " (code "define-record-type") " form of the "
       "explicit-naming layer: "
       "a " (code "define-record-type") " form that conforms to the syntax of the "
       "explicit-naming layer also conforms to the syntax of the "
       "implicit-naming layer, and any definition in the implicit-naming layer "
       "can be understood by its translation into the explicit-naming layer.")
      (p
       "This means that a record type defined by the " (code "define-record-type") " form "
       "of either layer can be used by the other.")

      (p
       "The implicit-naming syntactic layer extends the explicit-naming layer in "
       "two ways.  First, " (meta "name-spec") " may be a single identifier "
       "representing just the record name. "
       "In this case, the name of the construction procedure is generated by prefixing the record "
       "name with " (code "make-") ", and the predicate name is generated by adding "
       "a question mark (" (code "?") ") to the end of the record name. "
       "For example, if the record name is " (code "frob") " then the name of the construction "
       "procedure is " (code "make-frob") " and the predicate name is "
       (code "frob?") ".")
    
      (p
       "Second, the syntax of " (meta "field-spec") " is extended to allow the "
       "accessor and mutator names to be omitted.  That is, " (meta "field-spec")
       " can take one of the following forms as well as the forms described in "
       "the preceding section.")

      (p
       "Note that the field names with implicitly-named "
       "accessors must be distinct to avoid a conflict between the "
       "accessors.")

      (dl
       (dt
	(prototype (meta "field name") (code " immutable")))
       (dt
	(prototype (meta "field name") (code " mutable"))))

      (p
       "If " (meta "field-spec") " takes one of these forms, then the accessor name "
       "is generated by appending the record name and field name with a hyphen "
       "separator, and the mutator name (for a mutable field) is generated by "
       "adding a " (code "-set!") " suffix to the accessor name. "
       "For example, if the record name is " (code "frob") " and the field name is "
       (code "widget") ", the accessor name is " (code "frob-widget") " and the "
       "mutator name is " (code "frob-widget-set!") ".")

      (p
       "Any definition that takes advantage of implicit naming can be rewritten "
       "trivially to a definition that conforms to the syntax of the implicit-naming "
       "layer merely by specifing the names explicitly. "
       "For example, the implicit-naming layer record definition:")

      (verbatim
       "(define-record-type frob"
       "  (fields (widget mutable))"
       "  (constructor-constructor"
       "    (lambda (c) (c (make-widget n)))))")

      (p "is equivalent to the following explicit-naming layer record definition.")

      (verbatim
       "(define-record-type (frob make-frob frob?)"
       "  (fields (widget (frob-widget frob-widget-set!))"
       "  (constructor-constructor"
       "    (lambda (c) (c (make-widget n)))))")

      (p
       "With the explicit-naming layer, one can choose to specify just some of the "
       "names explicitly; for example, the following overrides the choice of "
       "accessor and mutator names for the " (code "widget") " field.")
   
      (verbatim
       "(define-record-type (frob make-frob frob?)"
       "  (fields (widget (getwid setwid!))"
       "  (constructor-constructor"
       "    (lambda (c) (c (make-widget n)))))")

      (h2 "Reflection")

      (p
       "A set of procedures are provided for reflecting on records and their record-type descriptors. "
       "These procedures are designed to allow the writing of portable printers and inspectors. ")
      (p
       "Note that " (code "record?") " and " (code "record-rtd")
       " treat records of opaque record types as if they were "
       "not record.  On the other hand, the reflection procedures that operate on record-type "
       "descriptors themselves are not affected by opacity.  In other words, "
       "opacity controls whether a program can obtain an rtd from an instance.  If the program "
       "has access to the rtd through other means, it can reflect on it.")
        
      (dl
       (dt
        (prototype "record?"
                   (var "obj")))
       (dd
        (p
         "Returns " (code "#t") " if " (var "obj") " is a record, and its record type is not opaque. "
	 "Returns " (code "#f") " otherwise."))

       (dt
        (prototype "record-rtd"
                   (var "rec")))
       (dd
        (p
         "Returns the rtd representing the type of " (var "rec") " if the type is not opaque. "
         "The rtd of the most precise type is returned; that is, the type " (var "t") " such "
         "that " (var "rec") " is of type " (var "t") " but not of any type that extends "
         (var "t") ". "
         "If the type is opaque, " (code "record-rtd") " signals an error."))

       (dt
        (prototype "record-type-name"
                   (var "rtd")))
       (dd
        (p
         "Returns the name of the record-type descriptor " (var "rtd") "."))

       (dt
        (prototype "record-type-parent"
                   (var "rtd")))
       (dd
        (p
         "Returns the parent of the record-type descriptor " (var "rtd") ", or "
         (code "#f") " if it has none."))

       (dt
        (prototype "record-type-uid"
                   (var "rtd")))
       (dd
        (p
         "Returns the uid of the record-type descriptor " (var "rtd") ", or "
         (code "#f") " if it has none.  (An implementation may assign a generated "
         "uid to a record type even if the type is generative, so the return of a uid "
         "does not necessarily imply that the type is nongenerative.)"))

       (dt
	(prototype "record-type-generative?"
		   (var "rtd")))

       (dd
	(p
	 "Returns " (code "#t") " if " (var "rtd") " is generative, and " (code "#f")
	 " if not."))

       (dt
        (prototype "record-type-sealed?"
                   (var "rtd")))
       (dd
        (p
         "Returns a boolean value indicating whether the record-type descriptor is "
         "sealed."))

       (dt
        (prototype "record-type-opaque?"
                   (var "rtd")))
       (dd
        (p
         "Returns a boolean value indicating whether the record-type descriptor is "
         "opaque."))

       (dt
        (prototype "record-type-field-names"
                   (var "rtd")))
       (dd
        (p
         "Returns a list of symbols naming the fields of the type represented "
         "by " (var "rtd") " (not including the fields of parent types) where "
	 "the fields are ordered "
         "as described under " (code "make-record-type-descriptor") "."))

       (dt
        (prototype "record-field-mutable?"
                   (var "rtd")
                   (var "k")))
       (dd
        (p
         "Returns a boolean value indicating whether the field specified by "
         (var "k") " of the type represented by " (var "rtd") " is mutable, "
         "where " (var "k") " is as in " (code "record-accessor") "."))
       )

      (h1 (a (@ (name "design-rationale")) "Design Rationale"))

      (h2 "Constructor constructors, makers, and constructors")

      (p
       "The proposal contains infrastructure for creating specialized constructors, "
       "rather than just creating default constructors that just accept the initial "
       "values of all the fields as arguments.  The mechanism for creating "
       "makers and constructors may seem overly complex at first.")
      (p
       "The rationale for the design is that the initial values of the fields will "
       "often need to be specially "
       "computed or default to constant values.  Moreover, the created record "
       "might need to be registered somewhere before being ready for processing.")
      (p
       "Moreover, the maker mechanism allows the creation of such initializers in a "
       "modular manner, separating the initialization concerns of the "
       "parent types of those of the extensions.")
      (p
       "During the design phase as well as the discussion period of the SRFI, we "
       "experimented with several mechanisms for achieving this purpose; "
       "the one described here "
       "achieves complete generality without cluttering the syntactic layer, "
       "possibly sacrificing a bit of notational convenience in special cases, as "
       "compared to previous versions of this proposal.")

      (h2 "Non-distinct field names")

      (p
       "The field names provided as an argument to " (code "make-record-type-descriptor")
       " and in the syntactic layers are only for informational purposes for use in, say, "
       "debuggers.  They aren't actively used "
       "anywhere else in the interface (though they were in an earlier draft) "
       "except for the implicit generation of field names in the implicit-naming "
       "syntactic layer, where there is a restriction "
       "on duplicate names. "
       "There has been some discussion on this issue "
       (a (@ href "http://srfi.schemers.org/srfi-76/mail-archive/msg00061.html") "here") ".")
      (p
       "On the practical side, we decided not to require distinctness "
       "because it is inconvenient "
       "for a macro that calls " (code "make-record-type-descriptor") " to arrange for the "
       "names it provides to be both unique and meaningful.  Moreover, a symbolic "
       "key would have to be combined with the record-type it appears in to "
       "uniquely reference a field, as disallowing duplicate field names between "
       "a record type and its extensions would break important abstraction barriers.")
      (p
       "From a more principled perspective, the record abstractions described here "
       "don't use names as keys into record values (any more) but instead indices "
       "relative to the record type.  Abstractions that do use keys could be "
       "layered on top of the facilities described here.  These would certainly be "
       "useful to enable, say, pattern-matching or separate abstractions that refer "
       "to fields by name, but are outside the scope of this proposal.")

      (h2 "No multiple inheritance")

      (p
       "Multiple inheritance could be formulated as an extension of the present "
       "system, but it would raise more complex semantic and implementation issues "
       "(sharing among common parent types, among other things) than we are prepared "
       "to handle at this time.")

      (h1 "Examples")

      (h2 "Procedural layer")
      
      (verbatim
       "(define :point"
       "  (make-record-type-descriptor"
       "   'point #f"
       "   #f #f #f "
       "   '((mutable x) (mutable y))))"
       ""
       "(define make-point"
       "  (record-constructor (make-record-type-maker :point #f #f)))"
       ""
       "(define point? (record-predicate :point))"
       "(define point-x (record-accessor :point 0))"
       "(define point-y (record-accessor :point 1))"
       "(define point-x-set! (record-mutator :point 0))"
       "(define point-y-set! (record-mutator :point 1))"
       ""
       "(define p1 (make-point 1 2))"
       "(point? p1) ; => #t"
       "(point-x p1) ; => 1"
       "(point-y p1) ; => 2"
       "(point-x-set! p1 5)"
       "(point-x p1) ; => 5"
       ""
       "(define :point2"
       "  (make-record-type-descriptor"
       "   'point2 :point "
       "   #f #f #f '((mutable x) (mutable y))))"
       ""
       "(define make-point2"
       "  (record-constructor (make-record-type-maker :point2 #f #f)))"
       "(define point2? (record-predicate :point2))"
       "(define point2-xx (record-accessor :point2 0))"
       "(define point2-yy (record-accessor :point2 1))"
       ""
       "(define p2 (make-point2 1 2 3 4))"
       "(point? p2) ; => #t"
       "(point-x p2) ; => 1"
       "(point-y p2) ; => 2"
       "(point2-xx p2) ; => 3"
       "(point2-yy p2) ; => 4")

      (h2 "Explicit-naming syntactic layer")

      (verbatim
       "(define-record-type (point3 make-point3 point3?)"
       "  (fields (x (point3-x))"
       "          (y (point3-y set-point3-y!)))"
       "  (nongenerative point3-4893d957-e00b-11d9-817f-00111175eb9e))"
       ""
       "(define-record-type (cpoint make-cpoint cpoint?)"
       "  (parent point3)"
       "  (constructor-constructor"
       "   (lambda (p)"
       "     (lambda (x y c) "
       "       ((p x y) (color->rgb c)))))"
       "  (fields (rgb (cpoint-rgb cpoint-rgb-set!))))"
       ""
       "(define (color->rgb c)"
       "  (cons 'rgb c))"
       ""
       "(define p3-1 (make-point3 1 2))"
       "(define p3-2 (make-cpoint 3 4 'red))"
       ""
       "(point3? p3-1) ; => #t"
       "(point3? p3-2) ; => #t"
       "(point3? (vector)) ; => #f"
       "(point3? (cons 'a 'b)) ; => #f"
       "(cpoint? p3-1) ; => #f"
       "(cpoint? p3-2) ; => #t"
       "(point3-x p3-1) ; => 1"
       "(point3-y p3-1) ; => 2"
       "(point3-x p3-2) ; => 3"
       "(point3-y p3-2) ; => 4"
       "(cpoint-rgb p3-2) ; => '(rgb . red)"
       ""
       "(set-point3-y! p3-1 17)"
       "(point3-y p3-1) ; => 17)"
       ""
       "(record-rtd p3-1) ; => (record-type-descriptor point3)"
       ""
       "(define-record-type (ex1 make-ex1 ex1?)"
       "  (constructor-constructor (lambda (p) (lambda a (p a))))"
       "  (fields (f (ex1-f))))"
       ""
       "(define ex1-i1 (make-ex1 1 2 3))"
       "(ex1-f ex1-i1) ; => '(1 2 3)"
       ""
       "(define-record-type (ex2 make-ex2 ex2?)"
       "  (constructor-constructor (lambda (p) (lambda (a . b) (p a b))))"
       "  (fields (a (ex2-a))"
       "          (b (ex2-b))))"
       ""
       "(define ex2-i1 (make-ex2 1 2 3))"
       "(ex2-a ex2-i1) ; => 1"
       "(ex2-b ex2-i1) ; => '(2 3)"
       ""
       "(define-record-type (unit-vector make-unit-vector unit-vector?)"
       "  (constructor-constructor"
       "   (lambda (p)"
       "     (lambda (x y z)"
       "       (let ((length (+ (* x x) (* y y) (* z z))))"
       "         (p  (/ x length)"
       "             (/ y length)"
       "             (/ z length))))))"
       "  (fields (x (unit-vector-x))"
       "          (y (unit-vector-y))"
       "          (z (unit-vector-z))))")


      (h2 "Implicit-naming syntactic layer")

      (verbatim
       "(define *ex3-instance* #f)"
       ""
       "(define-record-type ex3"
       "  (parent cpoint)"
       "  (constructor-constructor"
       "   (lambda (p)"
       "     (lambda (x y t)"
       "       (let ((r ((p x y 'red) t)))"
       "         (set! *ex3-instance* r)"
       "         r))))"
       "  (fields "
       "   (thickness mutable))"
       "  (sealed #t) (opaque #t))"
       ""
       "(define ex3-i1 (make-ex3 1 2 17))"
       "(ex3? ex3-i1) ; => #t"
       "(cpoint-rgb ex3-i1) ; => '(rgb . red)"
       "(ex3-thickness ex3-i1) ; => 17"
       "(ex3-thickness-set! ex3-i1 18)"
       "(ex3-thickness ex3-i1) ; => 18"
       "*ex3-instance* ; => ex3-i1"
       ""
       "(record? ex3-i1) ; => #f")
      
      (h1 "Reference implementation")

      (p
       "The " 
       (a (@ (href "records-reference.tar.gz")) "reference implementation ")
       "makes use of "
       (a (@ (href "http://srfi.schemers.org/srfi-9/")) "SRFI 9") " (Defining Record Types)"
      ", "
       (a (@ (href "http://srfi.schemers.org/srfi-23/")) "SRFI 23") " (Error reporting mechanism)"
      ", and "
       (a (@ (href "http://srfi.schemers.org/srfi-26/")) "SRFI 26") " (Notation for Specializing Parameters without Currying)"
       " for the procedural layer and the explicit-naming syntactic layer. "
       "The implementation of the explicit-naming syntactic layer also assumes "
       (code "letrec*") " semantics (as specified by the upcoming R6RS) for internal definitions "
       "to support internal record-type definitions. "
       "The explicit-naming syntactic layer cannot be implemented using " (code "syntax-rules")
       " alone.  Two implementations, one for Scheme 48 using explicit renaming, and one for "
       "PLT Scheme using " (code "syntax-case") " are provided.")
      
      (h1 "References")

      (p
       "Over the years, many records proposal have been advanced.  This section lists "
       "only the ones that were a direct influence to this proposal.")

      (p
       "The procedural layer of this SRFI is essentially an extension of "
       "a proposal that was considered by "
       "the R*RS authors about 15 years ago, and was supported at that "
       "time by a vote of approximately 28 to 2.  On 1 September 1989, "
       "Pavel Curtis posted the proposal to rrrs-authors.  Norman Adams "
       "reposted Pavel's proposal on 5 February 1992. "
       "Kent Dybvig presented an extended version of Pavel's proposal along "
       "with a syntactic interface, both developed in collaboration with Bill Rozas, "
       "at the 1998 Scheme Worshop. "
       "Pavel's proposal was also a starting point for Chez Scheme's procedural "
       "interface. "
       "The mechanism for defining and using constructor arguments in the "
       "syntactic interface is similar to the syntax used by "
       "the Scheme Widget Library for class definitions. "
       "Single inheritance was added to Larceny in 1998 and Chez Scheme in 1999, "
       "but it is likely that other implementations had inheritance before then.")

      (ul
       (li
        (a (@ (href "http://zurich.csail.mit.edu/pipermail/rrrs-authors/1992-May/001303.html"))
           "Pavel Curtis's 1989 proposal"))

       (li
        (a (@ (href "http://srfi.schemers.org/srfi-9/")) "SRFI 9: Defining Record Types") " by Richard A. Kelsey")

       (li
        "The Records section in the "
        (a (@ (href "http://www.scheme.com/csug/")) "Chez Scheme User's Guide")
        " by R. Kent Dybvig")

       (li
        (a (@ (href "http://www.cs.indiana.edu/chezscheme/swlman/")) "SWL Reference Manual")
        " by Oscar Waddell")

       (li
        "The (undocumented) " (code "define-record") " form of "
        (a (@ (href "http://www.iro.umontreal.ca/~gambit/")) "Gambit-C 4.0beta")
        "."))

       (h1 "Acknowledgements")

       (p
	"We are grateful to Donovan Kolbly who did extensive pre-draft editing.")

       (p
	"This SRFI was written in consultation with the other R6RS editors: "
	"Marc Feeley, Matthew Flatt, and Manuel Serrano.")

      )))

(with-output-to-file "record-srfi.html"
  (lambda ()
    (generate-html record-srfi)))
