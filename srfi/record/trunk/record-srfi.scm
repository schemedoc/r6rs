(load "srfi-template.scm")

(define record-srfi
  `(html:begin
    (srfi
     (srfi-head "SRFI ??: R6RS Records")
     (body
      (srfi-title "R6RS Records")
      (srfi-authors "Will Clinger, R. Kent Dybvig, Michael Sperber")

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
	"a procedural layer for explaining the semantics of records, and for "
	"introspection and reflection; it has library status")
       (li
	"an explicit-naming syntactic layer for defining the various entities associated "
	"with a record type "
	"- constructor, predicate, field accessors, mutators, etc. - at once; "
	"it has primitive status")
       (li
	"an implicit-naming syntactic layer built on top of explicit-naming syntactic "
	"layer, which chooses the names for the various entities based on the name of "
	"the record type; it has library status"))

      (h1 "Rationale")

      (p
       "The explicit-naming syntactic layer described here is similar to "
       (a (@ (href "http://srfi.schemers.org/srfi-9/")) "SRFI 9: Defining Record Types") ". "
       "However, it contains some modest functionality extensions to the record types:")
      
      (ul
       (li "single inheritance")
       (li "non-generative record types"))

      (p
       "Also, the procedural layer (already present in the reference implementation of "
       "SRFI 9) is now part of the specification, and allows introspection, the implementation "
       "of portable debuggers and metacircular interpreters that manipulate records compatibly "
       "with the host language.")

      (p
       "The syntax is designed to allow future extensions via keyworded clauses.")

      (p
       "The syntax is designed in such a way as to obviate having to write separate "
       "constructor procedures that shuffle arguments, provide default values for fields, "
       "and/or register the created objects.")

      (p
       "The implicit-naming layer chooses names for the constructor, predicate, "
       "accessors, and mutators based on the name of the record type.  This "
       "makes record-type definitions more succinct and prescribes a standard "
       "naming convention.  This has the cost of binding identifiers that do "
       "not occur verbatim in the source code, thus hiding them from tools like "
       (code "grep(1)") ", and possibly causing confusion among programmers "
       "new to Scheme.")

      (p
       "The two layers were designed in tandem; the implicit-naming layer is simply "
       "a conservative extension of the explicit-naming layer.  The goal was to "
       "make explicit-naming definitions reasonably natural and allowing a seamless "
       "\"upgrade\" to implicit naming.")

      (h1 "Issues")

      (ul
       (li 
	"The names " (code "define-record-type/explicit") " and "
	(code "define-record-type/implicit") " are obviously unsatisfactory and need "
	"to be replaced eventually.  It is open whether both names should in fact "
	"be the same.   This raises the question of how to distinguish them; presumably "
	"a module system would allow that.")
       (li
	(p
	 "Compared to some other record-defining forms that have been proposed and implemented, "
	 "the syntax is comparatively verbose.  For instance, PLT Scheme has a "
	 (code "define-struct") " form that allows record-type definitions as short as this:")
	(verbatim
	 "(define-struct point (x y))")
	(p
	 "This proposal requires at least:")
	(verbatim
	 "(define-record-type/implicit point (x y)"
	 "  (fields ((mutable x) x)"
	 "          ((mutable y) y)))")
	(p
	 "Arguably, the added verbosity contains valuable information.  Moreover, "
	 "it is trivial to define forms like " (code "define-struct") " on top "
	 "of this proposal.")
	(p
	 "It would be possible to introduce abbreviations into the syntax. "
	 "In the " (code "fields") " clause, a single identifier could serve as a shorthand "
	 "for a " (code "mutable") " or " (code "immutable") " clause:")
	(verbatim
	 "(define-record-type/implicit point (x y)"
	 "  (fields (x x)"
	 "          (y y)")
	(p
	 "Even more radically, a default " (code "fields") " clause could be provided:")
	(verbatim
	 "(define-record-type/implicit point (x y))")
	(p
	 "Again, this conciseness comes at the cost of more obscure semantics")))

      (p
       "Members of the Scheme community should express their opinion on these questions.")

      (h1 "Specification")

      (h2 "Procedural layer")

      (dl
       (dt
	(prototype "make-record-type-descriptor"
		   (var "name")
		   (var "parent")
		   (var "sealed?")
		   (var "uid")
		   (var "fields")))
       (dd
	(p
	 "This creates and returns a " (i "record-type descriptor") ", a value "
	 "representing a new data type.")
	(p
	 "The " (var "name") " argument must be a symbol naming the record type; "
	 "it has purely informational purpose, and may be used for printing by "
	 "the underlying Scheme system.")
	(p
	 "The " (var "parent") " argument is either " (code "#f") " or an existing "
	 "record-type descriptor.  If it is an existing record-type descriptor, "
	 "the record type returned is an extension of " (var "parent") ".  This means "
	 "that each record with the returned record type is also a record of type "
	 (var "parent") ", and all operations applicable to record of type " (var "parent")
	 " are also applicable.")
	(p
	 "A record type that has another as a parent is said to " (i "extend") " the "
	 "parent type; \"extends\" is transitive in the sense that a child of a child of "
	 " a record type also extends the grandparent type, and so on.")
	(p
	 "The " (var "sealed?") " flag is a boolean.  If it is true, the "
	 "record type being created is " (i "sealed") ".  This means that it is "
	 "an error to create another record type that extends the one being created.")

	(p
	 "The " (var "uid") " argument is either " (code "#f") " or a symbol. "
	 "If it is a symbol, the created record type is " (i "non-generative") ", i.e. "
	 "there may be only one record type with that uid in the entire system.  "
	 "When " (code "make-record-type-descriptor") " is called repeatedly with the "
	 "same " (var "uid") " argument, all other arguments to "
	 (code "make-record-type-descriptor") " must also be the same, and the same "
	 "record-type descriptor is returned every time.  If a call with the same "
	 "uid differs in any argument, it is an error.  If " (var "uid") " is "
	 (code "#f") ", " (code "make-record-type-descriptor") " returns a fresh "
	 "record-type descriptor, disjoint from all other types.")

	(p
	 "The " (var "fields") " argument must be a list of pairwise different "
	 "symbols naming the fields of the record type."))

       (dt
	(prototype "record-type-descriptor?"
		   (var "obj")))
       (dd
	(p
	 "This returns " (code "#t") " if the argument is a record-type descriptor, "
	 (code "#f") "otherwise."))

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
	 (code "#f") " if it has none."))

       (dt
	(prototype "record-type-field-names"
		   (var "rtd")))
       (dd
	(p
	 "Returns the field names of the record-type descriptor " (var "rtd") "."))

       (dt
	(prototype "record-constructor"
		   (var "rtd")))

       (dd
	(p
	 "Returns a procedure that, given arguments that correspond to the "
	 "constructor arguments of the parent of " (var "rtd") " (if present) "
	 "and, subsequently, the field names returned by "
	 (code "(record-type-field-names " (var "rtd") ")")
	 ", creates and returns an instance of the record type represented by "
	 (var "rtd") ".")
	(p
	 "Two records created by such a constructor are equal according to " 
	 (code "equal?")
	 " iff they are " (code "eq?") "."))

       (dt
	(prototype "record-predicate"
		   (var "rtd")))
       (dd
	(p
	 "Returns a predicate that, given an object " (var "obj") ", returns " (code "#t")
	 "iff " (var obj) " is a record that was created by "
	 (code "(record-constructor " (var "rtd") ")")
	 " or by the constructor for some record type that extends " (var "rtd") "."))

       (dt
	(prototype "record-accessor"
		   (var "rtd")
		   (var "field-id")))
       (dd
	(p
	 "Given a record-type descriptor " (var "rtd") " and a " (var "field-id")
	 " argument that specifies one "
	 "of the fields of " (var "rtd") ", returns a one-argument procedure that, "
	 "given a record for which " (code "(record-predicate " (var "rtd") ")") 
	 " is true, returns the value of the corresponding field of that record.")
	(p
	 "The " (var "field-id") " argument may be a symbol or an exact non-negative integer. "
	 "If it is a symbol, it corresponds to the field of that name in " (var "rtd") ". "
	 "If it is an exact integer, it is the 0-based index of the argument to the constructor "
	 "returned by " (code "(record-constructor " (var "rtd") ")") ".  Note that, in the "
	 "latter case, the fields of the parent types precede the fields of " (var "rtd")
	 " itself.")
	(p
	 "If " (code "record-accessor") " is called on an inaccessible field (see below), "
	 "an error is signalled."))

       (dt
	(prototype "record-mutator"
		   (var "rtd")
		   (var "field-id")))
       (dd
	(p
	 "Given a record-type descriptor " (var "rtd") " and a " (var "field-id")
	 " argument that specifies one "
	 "of the mutable fields of " (var "rtd") ", returns a two-argument procedure that, "
	 "given a record for which " (code "(record-predicate " (var "rtd") ")") 
	 " is true, and an object " (var "obj") ", stores " (var "obj")
	 " within the field of that record specified by " (var "field-id") ".")
	(p
	 "The " (var "field-id") " argument is as in " (code "record-accessor") ".")
	(p
	 "If " (code "record-mutator") " is called on an immutable field (see below), "
	 "an error is signalled."))

       (dt
	(prototype "record-field-accessible?"
		   (var "rtd")
		   (var "field-id")))
       (dd
	(p
	 "This checks whether the record field specified by " (var "field-id")
	 " (as in " (code "record-field-accessor") ") is accessible.")
	(p
	 "A Scheme system has license to mark a field of a record type "
	 "inaccessible (and not allocate storage for it, for example), "
	 "if it can prove that a program doesn't access the field."))

       (dt
	(prototype "record-field-mutable?"
		   (var "rtd")
		   (var "field-id")))
       (dd
	(p
	 "This checks whether the record field specified by " (var "field-id")
	 " (as in " (code "record-field-accessor") ") is mutable.")
	(p
	 "A Scheme system has license to mark a field of a record type "
	 "immutable (and allocate in read-only storage, for example), "
	 "if it can prove that a program doesn't mutate the field, or if the "
	 "programmer has indicated the field should be immutable via "
	 "some means not specified here."))

       (dt
	(prototype "record?"
		   (var "obj")))
       (dd
	(p
	 "Returns " (code "#t") " if " (var "obj") " was created by calling "
	 (code "(record-constructor " (var "rtd") ")")
	 " for some " (var "rtd") "; otherwise returns " (code "#f") "."))

       (dt
	(prototype "record-type-descriptor"
		   (var "rec")))
       (dd
	(p
	 "Given a record " (var "rec") " created by calling "
	 (code "(record-constructor " (var "rtd") ")") ", returns " (var "rtd") "."))

       )

      (h2 "Explicit-Naming Syntactic Layer")

      (p
       "The record-type-defining form " (code "define-record-type/explicit") " can occur "
       "anywhere a " (meta "definition") " can occur.")

      (dl
       (dt
	(prototype "define-record-type/explicit"
		   (code "(")
		   (meta "record name")
		   (meta "constructor name")
		   (meta "predicate name")
		   (code ")")
		   (meta "formals")
		   (meta "simple record clause") "*")
	   " (syntax)")
       (dd
	(p
	 (meta "Record name") ", " (meta "constructor name") ", and " (meta "predicate name")
	 " must all be identifiers.  "  (meta "Formals") " must be a formal argument list "
	 " as in R5RS.  " (meta "Simple record clause") " is as described below.")
	(p
	 "This defines a new record type, along with associated constructor, predicate, "
	 "field accessors and mutators.")
	(p
	 (meta "Record name") " is defined such that it can be an argument to "
	 (code "record-type-rtd") " (see below).")

	(p
	 (meta "Constructor name") " is defined to a procedure with argument list as "
	 "specified by " (meta "formals") " that calls the record constructor of the "
	 "record type with arguments according to the " (code "fields") " clauses "
	 "(see below).")

	(p
	 (meta "Predicate name") " is defined to the predicate of the record type.")

	(p
	 "Each " (meta "simple record clause") " must have one of the following forms:")

	(dl
	 (dt (prototype "fields" (meta "field-spec")))
	 (dd
	  (p
	   "where each " (meta "field-spec") " has one of the following forms")
	  (dl
	   (dt
	    (code "((immutable ") (meta "field name") " " (meta "accessor name") ") "
	    (meta "init expression") (code ")"))
	   (dt
	    (code "((mutable ") (meta "field name")
	    " " (meta "accessor name") " " (meta "mutator name") 
	    ") "
	    (meta "init expression") (code ")")))

	  (p
	   (meta "Field name") ", " (meta "accessor name") ", and " (meta "mutator name")
	   " must all be identifiers; " (meta "init expression") " must be an expression.")

	  (p
	   "The first form specifies an immutable field called " (meta "field name")
	   ", with the corresponding "
	   "accessor named " (meta "acccessor name") ". "
	   (meta "Init expression") " specifies the operand to the call of the "
	   "constructor of the record type corresponding to this field.")

	  (p
	   "The first form specifies an mutable field called " (meta "field name")
	   ", with the corresponding "
	   "accessor named " (meta "acccessor name") ", and with the corresponding "
	   "mutator named " (meta "mutator name") ". "
	   (meta "Init expression") " specifies the operand to the call of the "
	   "constructor of the record type corresponding to this field."))

	 (dt
	  (prototype "parent" (meta "parent name") " " (meta "constructor arg") "*"))
	 (dd
	  (p
	   "This specifies that the record type is to have parent type "
	   (meta "parent name") ", where " (meta "parent name") " is the "
	   (meta "record name") " of a previous " (code "define-record-type/explicit")
	   " form.  The absence of a " (code "parent") " clause implies a "
	   "record type with no parent type.")
	  (p
	   "The " (meta "constructor arg") " operands must all be expressions; their values "
	   "are passed as the arguments to the constructor corresponding to "
	   "the fields of the parent record type.   (Not the arguments to the constructor "
	   "created by the " (code "define-record-type/explicit") " form for the parent!)"))

	 (dt
	  (code "sealed"))
	 (dd
	  (p
	   "If this clause is specified, it means that the record type being created is "
	   "sealed and cannot be extended.  If no " (code "sealed") " clause is present, "
	   "the record type being created is not sealed."))

	 (dt
	  (prototype "nongenerative" (meta "uid")))
	 (dd
	  (p
	   "This specifies that the record type be nongenerative with uid "
	   (meta "uid") " (which must be a " (meta "symbol") "). "
	   "The absence of a " (code "nongenerative") " clause implies a "
	   "generative record type."))

	 (dt
	  (prototype "init!" (code "(") (meta "identifier") (code ")") (meta "expression") "*"))
	 (dd
	  (p
	   "When this clause is specified, the constructor being defined by the "
	   (code "define-record-type/implicit") " form calls "
	   (code "(lambda (") (meta "identifier") (code ") ") (meta "expression") "*" (code ")")
	  " with the newly created record as an argument before returning the record object to the "
	  "caller.  Any return values from the initialization procedure are ignored.")))

	(p
	 "Whether or not " (code "define-record-type/explicit") " creates a new "
	 "record type every time it is evaluated is unspecified.  It is possible "
	 "that a new record type is created every time, or that the same one is re-used. "
	 "Correspondingly, it is unspecified whether " (meta "record name") " is bound "
	 "at expansion time only, or at run time.  (But see " (code "record-type-rtd")
	 " below.)")
	)

       (dt
	(prototype "record-type-rtd"
		   (meta "record name"))
	" (syntax)")
       (dd
	(p
	 "This evaluates to, given a " (meta "record name") " defined with "
	 (code "define-record-type/explicit") ", the associated record-type descriptor."))
	
      )

      (h2 "Implicit-Naming Syntactic Layer")

      (p
       "The " (code "define-record-type/implicit") " form of the implicit-naming syntactic layer is "
       " a conservative extension of " (code "define-record-type/explicit") " - "
       "a " (code "define-record-type/explicit") " form can be changed to an equivalent "
       (code "define-record-type/implicit") " form merely by renaming the " (code "explicit")
       " to " (code "implicit") ". "
       "The " (code "define-record-type/implicit") " form is explained by translation to a "
       (code "define-record-type/explicit") " form.")

      (dl
       (dt
	(prototype "define-record-type/explicit"
		   (code "(")
		   (meta "record name")
		   (meta "constructor name")
		   (meta "predicate name")
		   (code ")")
		   (meta "formals")
		   (meta "record clause") "*")
	   " (syntax)")
       (dt
	(prototype "define-record-type/explicit"
		   (meta "record name")
		   (meta "formals")
		   (meta "record clause") "*")
	   " (syntax)")
       (dd
	(p
	 "The first form is like " (code "define-record-type/explicit") ", except that the "
	 "set of possible clauses is extended (see below), and that the constructor "
	 "may perform additional initialization (see below).")
	(p
	 "The second form is translated to the first by using "
	 (code "make-") (meta "record name") " as the " (meta "constructor name") ", and "
	 (meta "record name") (code "?") " as the " (meta "predicate name") ".")

	(p
	 "Each " (meta "record clause") " is a either " (meta "simple record clause") ", "
	 "in which case it means the same as with " (code "define-record-type/explicit") ", "
	 "or it is an extended " (code "fields") " clause:")

	(dl
	 (dt (prototype "fields" (meta "field-spec")))
	 (dd
	  (p
	   "where each " (meta "field-spec") " has one of the following forms")
	  (dl
	   (dt
	    (code "((immutable ") (meta "field name") " " (meta "accessor name") ") "
	    (meta "init expression") (code ")"))
	   (dt
	    (code "((immutable ") (meta "field name") ") " (meta "init expression") (code ")"))
	   (dt
	    (code "((mutable ") (meta "field name")
	    " " (meta "accessor name") " " (meta "mutator name") 
	    ") "
	    (meta "init expression") (code ")"))
	   (dt
	    (code "((mutable ") (meta "field name") ") " (meta "init expression") (code ")")))

	  (p
	   "The respective first form with " (code "immutable") " and " (code "mutable") 
	   " are as in " (code "define-record-type/explicit") ".")

	  (p
	   "The forms omitting " (meta "accessor name") " and " (meta "mutator name")
	   " imply an " (meta "accessor name") " of " (meta "record name") (code "-")
	   (meta "field name") ", and a " (meta "mutator name") " of "
	   (meta "record name") (code "-")
	   (meta "field name") (code "-set!") ".")))))

      (h1 "Examples")

      (h2 "Procedural layer")

      (verbatim
       "(define point (make-record-type-descriptor 'point #f #f '(x y)))"
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
       "(point-y p1) ; => 1"
       "(point-x-set! p1 5)"
       "(point-x p1) ; => 5"
       ""
       "(define point2 (make-record-type-descriptor 'point2 point #f '(x y)))"
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
       "(define-record-type/explicit (pare kons pare?) (x y)"
       "  (fields"
       "   ((mutable x kar set-kar!) x)"
       "   ((immutable y kdr) y)))"
       ""
       "(pare? (kons 1 2)) ; => #t"
       "(pare? (cons 1 2)) ; => #f"
       "(kar (kons 1 2)) ; => 1"
       "(kdr (kons 1 2)) ; => 2"
       "(let ((k (kons 1 2)))"
       "  (set-kar! k 3)"
       "  (kar k)) ; => 3"
       ""
       "(define-record-type/explicit (point make-point point?) (x y)"
       "  (fields ((immutable x point-x) x)"
       "          ((mutable y point-y set-point-y!) y))"
       "  (nongenerative point-4893d957-e00b-11d9-817f-00111175eb9e))"
       ""
       "(define-record-type/explicit (cpoint make-cpoint cpoint?) (x y c)"
       "  (parent point x y)"
       "  (fields ((mutable rgb cpoint-rgb cpoint-rgb-set!) (color->rgb c))))"
       ""
       "(define (color->rgb c)"
       "  (cons 'rgb c))"
       ""
       "(define p1 (make-cpoint 3 4 'red))"
       "(point? p1) ; => #t"
       "(cpoint-rgb p1) ; => (rgb . red)")

      (h2 "Implicit-naming syntactic layer")

      (verbatim
       "(define-record-type/implicit (point make-point point?) (x y)"
       "  (fields ((immutable x point-x) x)"
       "          ((mutable y point-y set-point-y!) y))"
       "  (nongenerative point-4893d957-e00b-11d9-817f-00111175eb9e))"
       ""
       "(define *the-cpoint* #f)"
       ""
       "(define-record-type/implicit cpoint (x y c)"
       "  (parent point x y)"
       "  (fields ((mutable rgb) (color->rgb c)))"
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
       " for the procedural layer and the simple syntactic layer. "
       "The implementation of the simple syntactic layer also assumes "
       (code "letrec*") " semantics (as specified by the upcoming R6RS) for internal definitions "
       "to support internal record-type definitions. "
       "The featureful syntactic layer cannot be implemented using " (code "syntax-rules")
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
       "reposted Pavel's proposal on 5 February 1992.  Pavel's proposal "
       "appears to have been a starting point for the records of Chez "
       "Scheme.  Larceny added single inheritance in 1998, but it is "
       "likely that other implementations had done this earlier.")

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
	"The (undocumented) " (code "define-record") " form of "
	(a (@ (href "http://www.iro.umontreal.ca/~gambit/")) "Gambit-C 4.0beta")
	".")

      )))))

(with-output-to-file "record-srfi.html"
  (lambda ()
    (generate-html record-srfi)))
