(load "srfi-template.scm")

(define record-srfi
  `(html:begin
    (srfi
     (srfi-head "SRFI ??: R6RS Records")
     (body
      (srfi-title "R6RS Records")
      (srfi-authors "Will Clinger, R. Kent Dybvig, Michael Sperber, Anton van Straaten")

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
       "records - data structures with named fields.  The proposal comes in three "
       "parts:")

      (ul
       (li
        "a procedural layer for creating and manipulating record types and record
         instances; it has primitive status")
       (li
        "an explicit-naming syntactic layer for defining the various entities associated "
        "with a record type "
        "- constructor, predicate, field accessors, mutators, etc. - at once; "
        "it has primitive status")
       (li
        "an implicit-naming syntactic layer built on top of explicit-naming syntactic "
        "layer, which chooses the names for the various products based on the names of "
        "the record type and fields; it has library status")
       (li
        "a set of reflection procedures; it has library status"))

      (h1 "Rationale")

      (p
       "The procedural layer allows dynamic construction of new record types and "
       "associated procedures for creating and manipulating records, "
       "which is particularly useful when writing interpreters that "
       "construct host-compatible record types.  It may also serve as a target "
       "for expansion of the syntactic layers.")

      (p
       "The explicit-naming syntactic layer provides a basic syntactic interface "
       "whereby a single record definition serves as a shorthand for the definition "
       "of several record creation and manipulation routines: a constructor, "
       "a predicate, accessors, and mutators. "
       "As the name suggests, the explicit-naming syntactic layer requires the "
       "programmer to name each of these products explicitly. "
       "The explicit-naming syntactic layer is similar to "
       (a (@ (href "http://srfi.schemers.org/srfi-9/")) "SRFI 9: Defining Record Types") ", "
       "but adds several features, including single inheritance and non-generative "
       "record types.")

      (p
       "The implicit-naming syntactic layer extends the explicit-naming syntactic layer "
       "by allowing the names for constructor, predicate, accessors, and mutators "
       "to be determined automatically from the name of the record and names of "
       "the fields.  This establishes a standard naming convention and allows "
       "record-type definitions to be more succinct, with the downside that the "
       "product definitions cannot easily be located via a simple search for the "
       "product name.  The programmer may override some or all of the default names "
       "by specifying them explicitly as in the explicit-naming syntactic layer.")

      (p
       "The syntax of both syntactic layers is designed to obviate "
       "separate constructor procedures that shuffle arguments, provide default "
       "values for fields, and/or perform initialization actions on the created "
       "instance, such as registering it in some manner.")

      (p
       "The syntax of both syntactic layers is also designed to allow future extensions "
       "via keyworded clauses.")

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
       "by declaring the type " (i "opaque") ".")

      (h1 "Issues")

      (ul
       (li 
        "The name " (code "define-type") " is used for both the "
        "implicit-naming and explicit-naming syntactic interfaces. "
        "It is unclear whether both names should in fact be the same. "
        "With different names it would be easier to identify when only "
        "the explicit-naming interface is being used; presumably, "
        "a module system would also make this possible.")

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
         "(define-type point (x y) (fields x y))")
        (p
         "Even more radically, a default " (code "fields") " clause could be provided, "
         "with the constructor formals serving as implicit field names and initializers:")
        (verbatim
         "(define-type point (x y))")
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
	 "Should syntactic record-type definitions default to creating opaque or "
	 "non-opaque record types?"))
       (li
	(p
	 "The specification of " (code "make-record-type-descriptor") " has this:")
	(p
	 (blockquote
	 "If " (var "parent") " is not " (code "#f") ", and " (var "uid")
	 " is not " (code "#f") ", and the parent is generative "
	 " (i.e. its uid is " (code "#f") "), an error is signalled."))
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
	 "The semantics of generativity for the syntactic record-type-definition forms "
	 "is presently unspecified.  Should this be tightened, and, if so, to what kind "
	 "of generativity?")))

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
         "it has purely informational purpose, and may be used for printing by "
         "the underlying Scheme system.")
        (p
         "The " (var "parent") " argument is either " (code "#f") " or an "
         "rtd.  If it is an rtd, "
         "the returned record type, " (emph "t") ", " (i "extends") " the record "
         "type " (i "p") " represented by " (var "parent") ".  Each "
         "record of type " (i "t") " is also a record of type " (i "p") ", and "
         "all operations applicable to a record of type " (i "p") " are also "
         "applicable to a record of type " (i "t") ".  "
         "An error is signaled if " (var "parent") " is sealed (see below).")
        (p
         "The extension relationship is transitive in the sense that a type extends "
         "its parent's parent, if any, and so on. ")
        (p
         "The " (var "uid") " argument is either " (code "#f") " or a symbol. "
         "If it is a symbol, the created record type is " (i "non-generative") ", i.e. "
         "there may be only one record type with that uid in the entire system "
	 "(in the sense of " (code "eqv?") ").  "
         "When " (code "make-record-type-descriptor") " is called repeatedly with the "
         "same " (var "uid") " argument (in the sense of " (code "eq?") "), all other arguments to "
         (code "make-record-type-descriptor") " must also be the same (in the sense of "
	 (code "equal?") "), and the same "
         "record-type descriptor (in the sense of " (code "eq?") ") is returned every time.  "
	 "If a call with the same "
         "uid differs in any argument, an error is signaled.  If " (var "uid") " is "
         (code "#f") ", or if no record type with the given uid has been created "
         "before, " (code "make-record-type-descriptor") " returns a fresh "
         "record-type descriptor representing a new type disjoint from all other types.")

	(p
	 (blockquote
	  (i "Note: ")
	  "Users are strongly strongly encouraged to use symbol names "
	  "from the "
	  (a (@ (href "http://www.ietf.org/rfc/rfc4122")) "UUID namespace")
	  " for the " (var "uid") " argument."))

	(p
	 "If " (var "parent") " is not " (code "#f") ", and " (var "uid")
	 " is not " (code "#f") ", and the parent is generative "
	 " (i.e. its uid is " (code "#f") "), an error is signalled.")

        (p
         "The " (var "sealed?") " flag is a boolean.  If true, the "
         "returned record type is " (i "sealed") ", i.e., it cannot be extended.")

        (p
         "The " (var "opaque?") " flag is a boolean.  If true, the "
         "returned record type is " (i "opaque") ".  This means that calls to "
         (code "record?") " will return " (code "#f") " and "
	 (code "record-descriptor") " (see \"Reflection\" below) will signal an error. "
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
         "record type; the names need not be distinct. "
         "A field marked mutable may be modified, whereas a field marked immutable may not.")
        (p
         "Where field order is relevant, e.g., for record construction and field access, "
         "the fields are considered to "
         "be ordered as specified, with parent fields first (and grandparent fields before "
         "that, and so on).  No particular order is required for the actual representation "
         "of a record instance, however.")
	(p
	 "A record type whose fields (including the fields the record types it extends) "
	 "are all immutable is called " (i "immutable") " itself.  A record type that has "
	 "at least one mutable field or extends a record type that has is called "
	 (i "mutable.")))

       (dt
        (prototype "record-type-descriptor?"
                   (var "obj")))
       (dd
        (p
         "This returns " (code "#t") " if the argument is a record-type descriptor, "
         (code "#f") " otherwise."))

       (dt
        (prototype "record-constructor"
                   (var "rtd")))

       (dd
        (p
         "Returns a procedure that returns a new instance of the record type "
         "represented by " (var "rtd") ". "
         "The procedure accepts one argument per field, in order, with parent "
         "fields first (and grandparent fields before that, and so on).")
	(p
	 "If " (var "rtd") " describes an opaque record type, then the values "
	 "created by such a constructor are not considered to be records; see "
	 "the specification of " (code "record?") " below.")
	(p
	 "A record from an immutable record type is called " (i "immutable") "; "
	 "conversely, a record from an mutable record type is called " (i "mutable") ".")
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
	 "  (eq? r r))                 ==> #t"))

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
                   (var "field-id")))
       (dd
        (p
         "Given a record-type descriptor " (var "rtd") " and a " (var "field-id")
         " argument that specifies one "
         "of the fields of " (var "rtd") ", " (code "record-accessor") " returns a one-argument "
         "procedure that, given a record of the type represented by " (var "rtd") ", returns "
         "the value of the selected field of that record.")
        (p
         "The " (var "field-id") " argument may be a symbol or an exact non-negative integer. "
         "If it is a symbol " (var "s") ", the field named " (var "s") " is selected. "
         "If more than one field has the given name, the field selected is the first "
	 "field with that name in " (var "rtd") ", or, if there is no such field in " (var "rtd")
	 ", the first field with that name in its parent, and so on."
         "If " (var "field-id") " is an exact non-negative integer " (var "i") ", the field at "
         "the 0-based index " (var "i") " is selected, where the fields are ordered "
         "as described under " (code "make-record-type-descriptor") " above."))

       (dt
        (prototype "record-mutator"
                   (var "rtd")
                   (var "field-id")))
       (dd
        (p
         "Given a record-type descriptor " (var "rtd") " and a " (var "field-id")
         " argument that specifies one "
         "of the mutable fields of " (var "rtd") ", " (code "record-accessor") " returns a "
         "two-argument procedure that, "
         "given a record " (var "r") " of the type represented by " (var "rtd") " and an "
         "object " (var "obj") ", stores " (var "obj")
         " within the field of " (var "r") " specified by " (var "field-id") ". "
         "The " (var "field-id") " argument is as in " (code "record-accessor") ". "
         "If " (code "record-mutator") " is called on an immutable field, "
         "an error is signaled."))
       )

      (h2 "Explicit-Naming Syntactic Layer")

      (p
       "The record-type-defining form " (code "define-type") " is a
        definition and can appear "
       "anywhere any other " (meta "definition") " can appear.")

      (dl
       (dt
        (prototype "define-type"
                   (meta "name-spec")
                   (meta "formals")
                   (meta "record clause") "*")
           " (syntax)")
       (dd
        (p
         "A " (code "define-type") " form defines a new record type "
         "along with associated constructor, predicate, "
         "field accessors and field mutators.")

        (p
         "The " (meta "name-spec") " specifies the names of the record type, constructor, "
         "and predicate.  It must take the form below.")

	(p
	 (code "(") (meta "record name") " " (meta "constructor name") " " (meta "predicate name") (code ")"))
         
        (p
         (meta "Record name") ", " (meta "constructor name") ", and " (meta "predicate name")
         " must all be identifiers.")

        (p
         (meta "Formals") " must be a formal argument list as in R5RS. "
         "The formals are visible within the field init expressions, parent "
         "constructor arguments, and " (code "init!") " expressions (see below).")

        (p (meta "Record clause") " is as described below.")

        (p
         (meta "Record name") " is bound to a compile-time or run-time description of the "
         "record type for use as parent name in record definitions that extend "
         "this definition.  It may also be used as a handle to gain access to the "
         "underlying record-type descriptor (see " (code "type-descriptor") " below).")

        (p
         (meta "Constructor name") " is defined to be a construction procedure. "
         "The construction procedure accepts the number(s) of arguments implied "
         "by " (meta "formals") " and creates a new record instance of the "
         "defined type with the fields initialized as described below.")

        (p
         (meta "Predicate name") " is defined to be a predicate for the defined "
         "record type.")

        (p
         "Each " (meta "record clause") " must take one of the following forms:")

        (dl
         (dt (prototype "fields" (meta "field-spec") "*"))
         (dd
          (p
           "where each " (meta "field-spec") " has one of the following forms")
          (dl
           (dt
            (prototype (meta "field name") (code "(") (meta "accessor name") (code ")")
		       (ebnf-opt (meta "init expression"))))
           (dt
            (prototype (meta "field name") (code "(") (meta "accessor name") (meta "mutator name") (code ")")
		       (ebnf-opt (meta "init expression")))))
          (p
           (meta "Field name") ", " (meta "accessor name") ", and " (meta "mutator name")
           " must all be identifiers; " (meta "init expression") ", if present, must be an expression. "
           "The first form declares an immutable field called " (meta "field name")
           ", with the corresponding "
           "accessor named " (meta "acccessor name") ". "
           "The second form declares a mutable field called " (meta "field name")
           ", with the corresponding "
           "accessor named " (meta "acccessor name") ", and with the corresponding "
           "mutator named " (meta "mutator name") ". "
           "In either form, " (meta "init expression") " specifies the initial "
           "value of the field when it is created by the constructor. "
	   "If " (meta "init expression") " is absent, it defaults to 
	   " (meta "field name") ".  In this case, the formals list must have "
	   "a corresponding parameter, whose value will become the initial value of "
	   "the field."))

         (dt
          (prototype "parent" (meta "parent name") " " (meta "constructor argument") "*"))
         (dd
          (p
           "This specifies that the record type is to have parent type "
           (meta "parent name") ", where " (meta "parent name") " is the "
           (meta "record name") " of a previously defined record type. "
           "The absence of a " (code "parent") " clause implies a "
           "record type with no parent type.")
          (p
           "Each " (meta "constructor argument") " must be an expression; the values of "
           "these expressions become the values of the parent's formals in the "
           "constructor."))

	 (dt
	  (prototype "sealed"))
	 (dd
	  (p
	   "If this option is specified, the defined record type is "
	   "sealed, i.e., cannot be extended.  If no " (code "sealed")
	   " option is present, the defined record type is not sealed."))

	 (dt
	  (prototype "opaque"))
	 (dd
	  (p
	   "If this option is specified, it means that the record type is "
	   "opaque.  It is also opaque if an opaque parent is specified. "
	   "If the " (code "opaque") " option is not present and an opaque parent "
	   "is not specified, the record type is not opaque."))



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
           "record definition appearing in different parts of a program."))

         (dt
          (prototype "init!" (code "(") (meta "identifier") (code ")") (meta "expression") "*"))
         (dd
          (p
           "When this clause is specified, the defined constructor "
           "arranges to evaluate the specified expressions in the scope of "
           "a binding for " (meta "identifier") " to the new record instance, "
           "before the instance is returned from the constructor. "
           "Parent init expressions, if any, are evaluated before child init "
           "expressions.  The values of the expressions are ignored.")))
	
	(p
	 "Note that all bindings created by this form (for the record type, "
	 "the constructor, the predicate, the accessors, and the mutators) "
	 "must have names that are pairwise distinct.")
	
	(p
	 "If the " (code "define-type") " form has a " (code "nongenerative") " clause, "
	 "a subsequent evaluation of an identical " (code "define-type") " form will "
	 "reuse the previously created rtd, and the procedures created will behave identically "
	 "to the previously created ones.  If the "
	 "implied arguments to " (code "make-record-type-descriptor") " are the same as with "
	 "a previously evaluated " (code "define-type") " form are the same, the rtd is "
	 "also reused, and bindings will be created or modified according to the more recent form. "
	 "If the implied arguments to " (code "make-record-type-descriptor") " are not the same, "
	 "an error is signalled."
	 ))

       (dt
        (prototype "type-descriptor"
                   (meta "record name"))
        " (syntax)")
       (dd
        (p
         "This evaluates to the record-type descriptor representing the type "
         "specified by " (meta "record-name") "."))
      )

      (h2 "Implicit-Naming Syntactic Layer")

      (p
       "The " (code "define-type") " form of the implicit-naming syntactic layer is "
       " a conservative extension of " (code "define-type") " form of the "
       "explicit-naming layer: "
       "a " (code "define-type") " form that conforms to the syntax of the "
       "explicit-naming layer also conforms to the syntax of the "
       "implicit-naming layer, and any definition in the implicit-naming layer "
       "can be understood by its translation into the explicit-naming layer.")

      (p
       "The implicit-naming syntactic layer extends the explicit-naming layer in "
       "two ways.  First, " (meta "name-spec") " may be a single identifier "
       "representing just the record name. "
       "In this case, the constructor name is generated by prefixing the record "
       "name with " (code "make-") ", and the predicate name is generated by adding "
       "a question mark (" (code "?") ") to the end of the record name. "
       "For example, if the record name is " (code "frob") " the constructor "
       "name is " (code "make-frob") " and the predicate name is "
       (code "frob?") ".")
    
      (p
       "Second, the syntax of " (meta "field-spec") " is extended to allow the "
       "accessor and mutator names to be omitted.  That is, " (meta "field-spec")
       " can take one of the following forms as well as the forms described in "
       "the preceding section.")

      (dl
       (dt
	(prototype (meta "field name") (code "immutable")
		   (ebnf-opt (meta "init expression"))))
       (dt
	(prototype (meta "field name") (code "mutable")
		   (ebnf-opt (meta "init expression")))))

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
       "For example, the implicit-layer record definition:")

      (verbatim
       "(define-type frob (n)"
       "  (fields (widget mutable (make-widget n))))")

      (p "is equivalent to the following explicit-layer record definition.")

      (verbatim
       "(define-type (frob make-frob frob?) (n)"
       "  (fields (widget (frob-widget frob-widget-set!) (make-widget n))))")

      (p
       "With the explicit-naming layer, one can choose to specify just some of the "
       "names explicitly; for example, the following overrides the choice of "
       "accessor and mutator names for the " (code "widget") " field.")
   
      (verbatim
       "(define-type frob (n)"
       "  (fields (widget (getwid setwid!) (make-widget n))))")


      (h2 "Reflection")

      (p
       "A set of procedures are provided for reflecting on records and their record-type descriptors. "
       "These procedures are designed to allow the writing of portable printers and inspectors. ")
        
      (dl
       (dt
        (prototype "record?"
                   (var "obj")))
       (dd
        (p
         "Returns " (code "#t") " if " (var "obj") " is a record, and its record type is not opaque. "
	 "Returns " (code "#f") " otherwise."))

       (dt
        (prototype "record-type-descriptor"
                   (var "rec")))
       (dd
        (p
         "Returns the rtd representing the type of " (var "rec") " if the type is not opaque. "
         "The rtd of the most precise type is returned; that is, the type " (var "t") " such "
         "that " (var "rec") " is of type " (var "t") " but not of any type that extends "
         (var "t") ". "
         "If the type is opaque, " (code "record-type-descriptor") " signals an error."))

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
         "by " (var "rtd") " where the fields are ordered "
         "as described under " (code "make-record-type-descriptor") "."))

       (dt
        (prototype "record-field-mutable?"
                   (var "rtd")
                   (var "field-id")))
       (dd
        (p
         "Returns a boolean value indicating whether the field specified by "
         (var "field-id") " of the type represented by " (var "rtd") " is mutable, "
         "where " (var "field-id") " is as in " (code "record-accessor") "."))
       )

      (h1 (a (@ (name "design-rationale")) "Design Rationale"))

      (h2 "Field initialization and verbosity")

      (p
       "To define a record type with two mutable fields, this proposal requires at least:")
      (verbatim
       "(define-type point (x y)"
       "  (fields (x mutable)"
       "          (y mutable)))")
      (p
       "While this is arguably verbose, the proposed syntax generalizes gracefully beyond this "
       "trivial sort of record definition, as illustrated by the two record "
       "definitions below.")
      
      (verbatim
       "(define-type hash-table (pred hasher size)"
       "  (fields (pred immutable pred)"
       "          (hasher immutable hasher)"
       "          (data mutable (make-vector (nearest-prime size)))"
       "          (count mutable 0)))"
       ""
       "(define-type eq-hash-table (pred hasher size)"
       "  (parent hash-table pred hasher size)"
       "  (fields (gc-count mutable 0)))")

      (p
       "The first defines a " (code "hash-table") " record with four fields: "
       (code "pred") ", " (code "hasher") ", "
       (code "data") ", and " (code "count") ".  "
       "Two of the fields, " (code "pred") " and " (code "hasher") ", are immutable "
       "and set to the values of the first two constructor arguments.  The "
       (code "data") " field is initialized to a vector whose size is a "
       "function of the third constructor argument.  "
       "The " (code "count") " field is initialized to zero.")

      (p
       "The second extends the " (code "hash-table") 
       " record to form an " (code "eq-hash-table")
       " record with an additional " (code "gc-count") " field, used in systems whose "
       "collectors move objects to determine if a collection has occurred "
       "since the last rehash.  The child record does not initialize the "
       "parent fields directly but rather defers to the initialization code "
       "in the parent record definition by passing along the constructor "
       "arguments.")

      (p
       "If the custom field initialization were omitted, it would still be possible to perform "
       "custom initialization by writing a separate constructor procedure, which "
       "would wrap a record type's actual constructor.  However, this creates "
       "the need for an extra procedure name which is not part of the record "
       "type's definition.  This means that extensions which deal with the "
       "record type's definition (such as " (code "co-export") ", but also extensions to "
       "support keyword arguments, etc.) don't have access to the record type's "
       "actual constructor.")

      (h2 (code "init!") " clause")

      (p
       "When constructing records, custom initialization code is commonly "
       "required, because the initial field values often do not have a "
       "one-to-one correspondence to the constructor arguments.  There may also "
       "be a need to perform other construction-time initialization, such as "
       "calling a procedure to \"register\" the new record.")

      (p
       "Internally, record construction involves an initialization step, and the "
       (code "init!") " clause provides a hook into this step, in order to "
       "support custom initialization.")

      (p
       "If this feature were omitted, many record-type definitions would require "
       "a separate constructor procedure, with the same consequences as explained "
       "above in the section on field initialization.")

      (p
       "The " (code "init!") " clause addresses this common requirement by "
       "allowing arbitrary operations on the new record instance, before it is "
       "returned from the constructor.  This eliminates the need to define a "
       "constructor wrapper procedure, and means that the record type's defined "
       "constructor can always be the actual constructor used by clients.")


      (h1 "Examples")

      (h2 "Procedural layer")

      (verbatim
       "(define point (make-record-type-descriptor 'point #f #f #f #f '(x y)))"
       "(define make-point (record-constructor point))"
       "(define point? (record-predicate point))"
       "(define point-x (record-accessor point 'x))"
       "(define point-y (record-accessor point 'y))"
       "(define point-x-set! (record-mutator point 'x))"
       "(define point-y-set! (record-mutator point 'y))"
       ""
       "(define p1 (make-point 1 2))"
       "(point? p1) ; => #t"
       "(point-x p1) ; => 1"
       "(point-y p1) ; => 2"
       "(point-x-set! p1 5)"
       "(point-x p1) ; => 5"
       ""
       "(define point2 (make-record-type-descriptor 'point2 point #f #f #f '(x y)))"
       "(define make-point2 (record-constructor point2))"
       "(define point2? (record-predicate point2))"
       "(define point2-x (record-accessor point2 0))"
       "(define point2-y (record-accessor point2 1))"
       "(define point2-xx (record-accessor point2 2))"
       "(define point2-yy (record-accessor point2 3))"
       ""
       "(define p2 (make-point2 1 2 3 4))"
       "(point? p2) ; => #t"
       "(point2-x p2) ; => 1"
       "(point2-y p2) ; => 2"
       "(point2-xx p2) ; => 3"
       "(point2-yy p2) ; => 4")

      (h2 "Explicit-naming syntactic layer")

      (verbatim
       "(define-type (pare kons pare?) (x y)"
       "  (fields (x (kar set-kar!) x)"
       "          (y (kdr) y)))"
       ""
       "(pare? (kons 1 2)) ; => #t"
       "(pare? (cons 1 2)) ; => #f"
       "(kar (kons 1 2)) ; => 1"
       "(kdr (kons 1 2)) ; => 2"
       "(let ((k (kons 1 2)))"
       "  (set-kar! k 3)"
       "  (kar k)) ; => 3"
       ""
       "(define-type (point make-point point?) (x y)"
       "  (fields (x (point-x) x)"
       "          (y (point-y set-point-y!) y))"
       "  (nongenerative point-4893d957-e00b-11d9-817f-00111175eb9e))"
       ""
       "(define-type (cpoint make-cpoint cpoint?) (x y c)"
       "  (parent point x y)"
       "  (fields (rgb (cpoint-rgb cpoint-rgb-set!) (color->rgb c))))"
       ""
       "(define (color->rgb c)"
       "  (cons 'rgb c))"
       ""
       "(define p1 (make-cpoint 3 4 'red))"
       "(point? p1) ; => #t"
       "(cpoint-rgb p1) ; => (rgb . red)")

      (h2 "Implicit-naming syntactic layer")

      (verbatim
       "(define-type (point make-point point?) (x y)"
       "  (fields (x immutable x)"
       "          (y mutable y))"
       "  (nongenerative point-4893d957-e00b-11d9-817f-00111175eb9e))"
       ""
       "(define *the-cpoint* #f)"
       ""
       "(define-type cpoint (x y c)"
       "  (parent point x y)"
       "  (fields (rgb mutable (color->rgb c)))"
       "  (init! (p) (set! *the-cpoint* p)))"
       ""
       "(define cpoint-i1 (make-cpoint 1 2 'red))"
       "(cpoint? cpoint-i1) ; => #t"
       "(cpoint-rgb cpoint-i1) ; => (rgb . red)"
       "(cpoint-rgb-set! cpoint-i1 '(rgb . blue))"
       "(cpoint-rgb cpoint-i1) ; => (rgb . blue)"
       "(eq? *the-cpoint* cpoint-i1) ; => #t")

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
	"This SRFI was written in consultation with the R6RS editors: Will Clinger, R. Kent Dybvig, "
	"Marc Feeley, Matthew Flatt, Manuel Serrano, Michael Sperber, and Anton van Straaten. "
	"Anton van Straaten wrote parts of the Design Rationale section.")

      ))))

(with-output-to-file "record-srfi.html"
  (lambda ()
    (generate-html record-srfi)))
