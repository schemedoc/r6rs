(load "srfi-template.scm")

(define blob-srfi
  `(html:begin
    (srfi
     (srfi-head "SRFI xx: Octet-Addressed Binary Blocks")
     (body
      (srfi-title "Octet-Addressed Binary Blocks")
      (srfi-authors "Michael Sperber")

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      (h1 "Abstract")
      (p
       "This SRFI defines a set of procedures for creating, accessing, and manipulating "
       "octet-addressed blocks of binary data, in short, " (i "blobs") ". "
       "The SRFI provides access primitives for fixed-length integers of arbitrary size, "
       "with specified endianness, and a choice of unsigned and two's complement "
       "representations.")

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      (h1 "Rationale")

      (p
       "Many applications must deal with blocks of binary data by accessing them in "
       "various ways---extracting signed or unsigned numbers of various sizes.  "
       "Such an application can use octet vectors as in "
       	(a (@ (href "http://srfi.schemers.org/srfi-66/")) "SRFI 66")
	" or any of the other types of homogeneous vectors in "
	(a (@ (href "http://srfi.schemers.org/srfi-4/")) "SRFI 4")
	", but these both only allow retrieving the binary data of one type.")

      (p
       "This is awkward in many situations, because an application might access "
       "different kinds of entities from a single binary block.  Even for "
       "uniform blocks, the disjointness of the various vector data types in SRFI 4 "
       "means that, say, an I/O API needs to provide an army of procedures for each of "
       "them in order to provide efficient access to binary data.")

      (p
       "Therefore, this SRFI provides a " (em "single") " type for blocks of binary "
       "data with multiple ways to access that data.  It deals only with integers "
       "in various sizes with specified endianness, because these are the most frequent "
       "applications.  Dealing with other kinds of binary data, such as "
       "floating-point numbers or variable-size integers would be natural extensions, "
       "but are left for a future SRFI.")

     
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      (h1 "Specification")

      (h2 "General remarks")

      (p
       "Blobs are objects of a new type.  Conceptually, a blob "
       "represents a sequence of octets.")

      (p
       "Scheme systems implementing both SRFI 4 and/or SRFI 66 and this SRFI may "
       "or may not use the same type for u8vector and blobs.  They are encouraged "
       "to do so, however.")

      (p
       "As with u8vectors, the length of a blob is the number of octets it "
       "contains.  This number is fixed.  A valid index into a blob "
       " is an exact, non-negative integer.  The first octet of a blob "
       " has index 0, the last octet has an index one less than the "
       " length of the blob.")

      (p
       "Generally, the access procedures come in different flavors "
       "according to the size of the represented integer, and the "
       (a (@ (href "http://en.wikipedia.org/wiki/Endianness")) "endianness")
       " of the representation.  The procedures also distinguish signed and "
       "unsigned representations.  The signed representations all use "
       (a (@ (href "http://en.wikipedia.org/wiki/Two's_complement")) "two's complement")
       ".")

      (p
       "For procedures that have no \"natural\" return value, this SRFI often uses the sentence")
      (p
       (em "The return values are unspecified."))
      (p
       "This means that number of return values "
       " and the return values are unspecified.  However, the number of return values "
       " is such that it is accepted by a continuation created by " (code "begin") ".  "
       "Specifically, on Scheme implementations where continuations created by " (code "begin")
       " accept an arbitrary number of arguments (this includes most implementations), "
       "it is suggested that the procedure return zero return values.")

      (h2 "Interface")

      (dl

       (dt
	(prototype "endianness" (code "big")) " (syntax)")
       (dt
	(prototype "endianness" (code "little")) " (syntax)")
       (dt
	(prototype "endianness" (code "native")) " (syntax)")
	

       (dd
	(p
	 (code "(endianness big)") " and " (code "(endianness little)")
	 " evaluate to two distinct and unique objects representing an  "
	 "endianness.  The " (code "native") " endianness evaluates to "
	 "the endianness of the underlying machine architecture, and must be "
	 (code "eq?") " to either "
	 (code "(endianness big)") " or " (code "(endianness little)")
	 "."))

       (dt
	(prototype "blob?"
		   (var "obj")))
       (dd
	(p "Returns " (code "#t") " if " (var "obj") " is a blob, "
	   "otherwise returns " (code "#f") "."))

       (dt
	(prototype "make-blob"
		   (var "k")))
       (dd
	(p
	 "Returns a newly allocated blob of " (var "k") " octets, all of them "
	 "0."))

       (dt
	(prototype "blob-length"
		   (var "blob")))
       (dd
	(p
	 "Returns the number of octets in " (var "blob") " as an "
	 "exact integer."))

       (dt
	(prototype "blob-u8-ref"
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-s8-ref"
		   (var "blob")
		   (var "k")))
       (dd
	(p
	 (var "K") " must be a valid index of " (var "blob") ".")
	(p
	 (code "Blob-u8-ref") " returns the octet at index " (var "k")
	 " of " (var "blob") ".")
	(p
	 (code "Blob-s8-ref") " returns the exact integer corresponding "
	 "to the two's complement representation at index " (var "k")
	 " of " (var "blob") "."))

       (dt
	(prototype "blob-u8-set!"
		   (var "blob")
		   (var "k")
		   (var "octet")))
       (dt
	(prototype "blob-s8-set!"
		   (var "blob")
		   (var "k")
		   (var "byte")))
       (dd
	(p
	 (var "K") " must be a valid index of " (var "blob") ".")
	(p
	 (code "Blob-u8-set!") " stores " (var "octet") " in element "
	 (var "k") " of "(var "blob") ".")
	(p
	 (var "Byte") ", must be an exact integer in the interval "
	 "{-128, ..., 127}. "
	 (code "Blob-u8-set!") " stores the two's complement representation "
	 " of " (var "byte") " in element " (var "k") " of "(var "blob") ".")
	(p
	 "The return values are unspecified."))

       (dt
	(prototype "blob-uint-ref"
		   (var "size")
		   (var "endianness")
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-sint-ref"
		   (var "size")
		   (var "endianness")
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-uint-set!"
		   (var "size")
		   (var "endianness")
		   (var "blob")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "blob-sint-set!"
		   (var "size")
		   (var "endianness")
		   (var "blob")
		   (var "k")
		   (var "n")))
       (dd
	(p
	 (var "Size") " must be a positive exact integer. "
	 (var "K") " must be a valid index of " (var "blob") "; so must "
	 "the indices {" (var "k") ", ..., " (var "k") " + " (var "size") " - 1}. "
	 (var "Endianness") " must be an endianness object. ")
	(p
	 (code "Blob-uint-ref") " retrieves the exact integer corresponding to the "
	 "unsigned representation of size " (var "size") " and specified by " (var "endianness")
	 " at indices {" (var "k") ", ..., " (var "k") " + " (var "size") " - 1}.")
	(p
	 (code "Blob-sint-ref") " retrieves the exact integer corresponding to the "
	 "two's complement representation of size " (var "size") 
	 " and specified by " (var "endianness") " at indices {" 
	 (var "k") ", ..., " (var "k") " + " (var "size") " - 1}.")
	(p
	 "For " (code "blob-uint-set!") ", " (var "n") " must be an exact integer "
	 "in the interval [0, (256^" (var "size") ")-1]. " (code "Blob-uint-set!")
	 " stores the unsigned representation of size " (var "size") " and specified "
	 "by " (var "endianness") " into the blob at indices {" 
	 (var "k") ", ..., " (var "k") " + " (var "size") " - 1}.")
	(p
	 "For " (code "blob-uint-set!") ", " (var "n") " must be an exact integer "
	 "in the interval [-256^(" (var "size") "-1), (256^(" (var "size") "-1))-1]. "
	 (code "Blob-sint-set!")
	 " stores the two's complement representation of size " (var "size") " and specified "
	 "by " (var "endianness") " into the blob at indices {" 
	 (var "k") ", ..., " (var "k") " + " (var "size") " - 1}."))
       

       (dt
	(prototype "blob-u16-ref"
		   (var "endianness")
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-s16-ref"
		   (var "endianness")
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-u16-native-ref"
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-s16-native-ref"
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-u16-set!"
		   (var "endianness")
		   (var "blob")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "blob-s16-set!"
		   (var "endianness")
		   (var "blob")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "blob-u16-native-set!"
		   (var "blob")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "blob-s16-native-set!"
		   (var "blob")
		   (var "k")
		   (var "n")))

       (dd
	(p
	 (var "K") " must be a valid index of " (var "blob") "; so must "
	 "the index " (var "k") "+ 1. "
	 (var "Endianness") " must be an endianness object. ")
	(p
	 "These retrieve and set two-octet representations of numbers at "
	 "indices " (var "k") " and " (var "k") "+1, according to "
	 "the endianness specified by " (var "endianness") ". "
	 "The procedures with " (code "u16") " in their names deal with "
	 "the unsigned representation, those with " (code "s16") " with "
	 "the two's complement representation.")
	(p
	 "The procedures with " (code "native") " in their names employ the "
	 "native endianness, and only work at aligned indices: "
	 (var "k") " must be a multiple of 2.  It is an error to use them at "
	 "non-aligned indices."))

       (dt
	(prototype "blob-u32-ref"
		   (var "endianness")
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-s32-ref"
		   (var "endianness")
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-u32-native-ref"
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-s32-native-ref"
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-u32-set!"
		   (var "endianness")
		   (var "blob")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "blob-s32-set!"
		   (var "endianness")
		   (var "blob")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "blob-u32-native-set!"
		   (var "blob")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "blob-s32-native-set!"
		   (var "blob")
		   (var "k")
		   (var "n")))

       (dd
	(p
	 (var "K") " must be a valid index of " (var "blob") "; so must "
	 "the indices {" (var "k") ", ..., " (var "k") "+ 3}. "
	 (var "Endianness") " must be an endianness object. ")
	(p
	 "These retrieve and set four-octet representations of numbers at "
	 "indices {" (var "k") ", ..., " (var "k") "+ 3}, according to "
	 "the endianness specified by " (var "endianness") ". "
	 "The procedures with " (code "u32") " in their names deal with "
	 "the unsigned representation, those with " (code "s32") " with "
	 "the two's complement representation.")
	(p
	 "The procedures with " (code "native") " in their names employ the "
	 "native endianness, and only work at aligned indices: "
	 (var "k") " must be a multiple of 4.  It is an error to use them at "
	 "non-aligned indices."))


       (dt
	(prototype "blob-u64-ref"
		   (var "endianness")
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-s64-ref"
		   (var "endianness")
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-u64-native-ref"
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-s64-native-ref"
		   (var "blob")
		   (var "k")))
       (dt
	(prototype "blob-u64-set!"
		   (var "endianness")
		   (var "blob")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "blob-s64-set!"
		   (var "endianness")
		   (var "blob")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "blob-u64-native-set!"
		   (var "blob")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "blob-s64-native-set!"
		   (var "blob")
		   (var "k")
		   (var "n")))

       (dd
	(p
	 (var "K") " must be a valid index of " (var "blob") "; so must "
	 "the indices {" (var "k") ", ..., " (var "k") "+ 7}. "
	 (var "Endianness") " must be an endianness object. ")
	(p
	 "These retrieve and set eight-octet representations of numbers at "
	 "indices {" (var "k") ", ..., " (var "k") "+ 7}, according to "
	 "the endianness specified by " (var "endianness") ". "
	 "The procedures with " (code "u64") " in their names deal with "
	 "the unsigned representation, those with " (code "s64") " with "
	 "the two's complement representation.")
	(p
	 "The procedures with " (code "native") " in their names employ the "
	 "native endianness, and only work at aligned indices: "
	 (var "k") " must be a multiple of 8.  It is an error to use them at "
	 "non-aligned indices."))

       (dt
	(prototype "blob=?"
		   (var "blob-1")
		   (var "blob-2")))
       (dd
	(p
	 "Returns " (var "#t") " if " (var "blob-1") " and "  (var "blob-2")
	 " are equal---that is, if they have the same length and equal octets "
	 "at all valid indices."))

       (dt
	(prototype "blob-copy!"
		   (var "source") (var "source-start")
		   (var "target") (var "target-start")
		   (var "n")))
       (dd
	(p
	 "Copies data from blob " (var "source") " to blob "
	 (var "target") ".  " (var "Source-start") ", " (var "target-start")
	 ", and " (var "n") " must be non-negative exact integers that satisfy")
       
	(p
	 "0 <= " (var "source-start")
	 " <= "
	 (var "source-start") " + " (var "n")
	 " <= " (code "(blob-length " (var "source") ")"))
	(p
	 "0 <= " (var "target-start")
	 " <= "
	 (var "target-start") " + " (var "n")
	 " <= " (code "(blob-length " (var "target") ")"))

	(p
	 "This copies the octets from " (var "source") " at indices "
	 "[" (var "source-start") ", " (var "source-start") " + " (var "n") ")"
	 " to consecutive indices in " (var "target") " starting at "
	 (var "target-index") ".")

	(p
	 "This must work even if the memory regions for the source and the "
	 "target overlap, i.e., the octets at the target "
	 "location after the copy must be equal to the octets "
	 "at the source location before the copy.")
       
	(p
	 "The return values are unspecified."))

       (dt
	(prototype "blob-copy"
		   (var "blob")))
       (dd
	(p
	 "Returns a newly allocated copy of blob " (var "blob") "."))

       (dt
	(prototype "blob->u8-list"
		   (var "blob")))
       (dt
	(prototype "u8-list->blob"
		   (var "blob")))
       (dd
	(p
	 (code "blob->u8-list") 
	 "returns a newly allocated list of the octets of " (var "blob")
	 " in the same order."))
       (dd
	(p
	 (code "U8-list->blob") 
	 " returns a newly allocated blob whose elements are the elements "
	 "of list " (var "octets") ", which must all be octets, in the same order. "
	 "Analogous to " (code "list->vector") "."))

       (dt
	(prototype "blob->uint-list"
		   (var "size")
		   (var "endianness")
		   (var "blob")))
       (dt
	(prototype "blob->sint-list"
		   (var "size")
		   (var "endianness")
		   (var "blob")))
       (dt
	(prototype "uint-list->blob"
		   (var "size")
		   (var "endianness")
		   (var "list")))
       (dt
	(prototype "sint-list->blob"
		   (var "size")
		   (var "endianness")
		   (var "list")))

       (dd
	(p
	 (var "Size") " must be a positive exact integer. "
	 (var "Endianness") " must be an endianness object.")
	(p
	 "These convert between lists of integers and their consecutive "
	 "representations according to " (var "size") " and " (var "endianness")
	 " in blobs in the same way as " (code "blob->u8-list")
	 ", " (code "blob->s8-list") ", " (code " u8-list->blob") ", and "
	 (code "s8-list->blob") " do for one-octet representations."))

       )
	
      (h1 "Reference Implementation")
      
      (p
       "This " (a (@ (href "blob.scm")) "reference implementation") " makes use of "
       (a (@ (href "http://srfi.schemers.org/srfi-23/")) "SRFI 23") " (Error reporting mechanism), "
       (a (@ (href "http://srfi.schemers.org/srfi-26/")) "SRFI 26")
       " (Notation for Specializing Parameters without Currying), "
       (a (@ (href "http://srfi.schemers.org/srfi-60/")) "SRFI 60")
       " (Integers as Bits), "
       "and "
       (a (@ (href "http://srfi.schemers.org/srfi-66")) "SRFI 66") " (Octet Vectors) "

       ".")

      (h1 "Examples")

      (p
       "The " (a (@ (href "example.scm")) "test suite") " doubles as a source of examples.")

      (h1 "References")

      (ul
       (li
	(a (@ (href "http://srfi.schemers.org/srfi-4/")) "SRFI 4")
	" (Homogeneous numeric vector datatypes)")
       (li
	(a (@ (href "http://srfi.schemers.org/srfi-56/")) "SRFI 56")
	" (Binary I/O)")
       (li
	(a (@ (href "http://srfi.schemers.org/srfi-66/")) "SRFI 66")
	" (Octet Vectors)"))))))

(with-output-to-file "blob-srfi.html"
  (lambda ()
    (generate-html blob-srfi)))
