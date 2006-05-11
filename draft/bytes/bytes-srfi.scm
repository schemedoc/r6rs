(load "srfi-template.scm")

(define bytes-srfi
  `(html:begin
    (srfi
     (srfi-head "Bytes Objects")
     (body
      (srfi-title "Bytes Objects")
      (srfi-authors "Michael Sperber")

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      (h1 "Abstract")
      (p
       "This library defines a set of procedures for creating, accessing, and manipulating "
       "byte-addressed blocks of binary data, in short, " (i "bytes objects") ". "
       "The library provides access primitives for fixed-length integers of arbitrary size, "
       "with specified endianness, and a choice of unsigned and two's complement "
       "representations.")

      (p
       "This library is a variation of "
       (a (@ (href "http://srfi.schemers.org/srfi-74/")) "SRFI 74")
       ".  Compared to SRFI 74, this library uses a different terminology: "
       "what SRFI 74 calls " (i "blob") " this library calls " (i "bytes") ".")

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
       "Therefore, this library provides a " (em "single") " type for blocks of binary "
       "data with multiple ways to access that data.  It deals only with integers "
       "in various sizes with specified endianness, because these are the most frequent "
       "applications.  Dealing with other kinds of binary data, such as "
       "floating-point numbers or variable-size integers would be natural extensions, "
       "but are left for a separate library.")

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      (h1 "Specification")

      (h2 "General remarks")

      (p
       "Bytes objects are objects of a disjoint type.  Conceptually, a bytes object "
       "represents a sequence of bytes.")

      (p
       "The length of a bytes object is the number of bytes it "
       "contains.  This number is fixed.  A valid index into a bytes object "
       " is an exact, non-negative integer.  The first byte of a bytes object "
       " has index 0, the last byte has an index one less than the "
       " length of the bytes object.")

      (p
       "Generally, the access procedures come in different flavors "
       "according to the size of the represented integer, and the "
       (a (@ (href "http://en.wikipedia.org/wiki/Endianness")) "endianness")
       " of the representation.  The procedures also distinguish signed and "
       "unsigned representations.  The signed representations all use "
       (a (@ (href "http://en.wikipedia.org/wiki/Two's_complement")) "two's complement")
       ".")

      (p
       "For procedures that have no \"natural\" return value, this description often uses the sentence")
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
	

       (dd
	(p
	 (code "(endianness big)") " and " (code "(endianness little)")
	 " evaluate to the symbols " (code "big") " and " (code "little")
	 ", respectively.  These symbols represent an endianness, and whenever "
	 " one of the procedures operating on bytes objects accepts an endianness "
	 " as an argument, that argument must be one of these symbols.  "
	 "If the operarand to " (code "endianness") " is anything other than "
	 (code "big") " or " (code "little") ", an expansion-time error is signalled."))

       (dt
	(prototype "native-endianness"))
	
       (dd
	(p
	 "This procedure returns the endianness of the underlying machine architecture, "
	 "either "
	 (code "(endianness big)") " or " (code "(endianness little)")))
	
       (dt
	(prototype "bytes?"
		   (var "obj")))
       (dd
	(p "Returns " (code "#t") " if " (var "obj") " is a bytes object, "
	   "otherwise returns " (code "#f") "."))

       (dt
	(prototype "make-bytes"
		   (var "k")))
       (dd
	(p
	 "Returns a newly allocated bytes object of " (var "k") " bytes, all of them "
	 "0."))

       (dt
	(prototype "bytes-length"
		   (var "bytes")))
       (dd
	(p
	 "Returns the number of bytes in " (var "bytes") " as an "
	 "exact integer."))

       (dt
	(prototype "bytes-u8-ref"
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-s8-ref"
		   (var "bytes")
		   (var "k")))
       (dd
	(p
	 (var "K") " must be a valid index of " (var "bytes") ".")
	(p
	 (code "Bytes-u8-ref") " returns the byte at index " (var "k")
	 " of " (var "bytes") ".")
	(p
	 (code "Bytes-s8-ref") " returns the exact integer corresponding "
	 "to the two's complement representation at index " (var "k")
	 " of " (var "bytes") "."))

       (dt
	(prototype "bytes-u8-set!"
		   (var "bytes")
		   (var "k")
		   (var "octet")))
       (dt
	(prototype "bytes-s8-set!"
		   (var "bytes")
		   (var "k")
		   (var "byte")))
       (dd
	(p
	 (var "K") " must be a valid index of " (var "bytes") ".")
	(p
	 (code "Bytes-u8-set!") " stores " (var "octet") " in element "
	 (var "k") " of "(var "bytes") ".")
	(p
	 (var "Byte") ", must be an exact integer in the interval "
	 "{-128, ..., 127}. "
	 (code "Bytes-u8-set!") " stores the two's complement representation "
	 " of " (var "byte") " in element " (var "k") " of "(var "bytes") ".")
	(p
	 "The return values are unspecified."))

       (dt
	(prototype "bytes-uint-ref"
		   (var "size")
		   (var "endianness")
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-sint-ref"
		   (var "size")
		   (var "endianness")
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-uint-set!"
		   (var "size")
		   (var "endianness")
		   (var "bytes")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "bytes-sint-set!"
		   (var "size")
		   (var "endianness")
		   (var "bytes")
		   (var "k")
		   (var "n")))
       (dd
	(p
	 (var "Size") " must be a positive exact integer. "
	 (var "K") " must be a valid index of " (var "bytes") "; so must "
	 "the indices {" (var "k") ", ..., " (var "k") " + " (var "size") " - 1}. "
	 (var "Endianness") " must be an endianness object. ")
	(p
	 (code "Bytes-uint-ref") " retrieves the exact integer corresponding to the "
	 "unsigned representation of size " (var "size") " and specified by " (var "endianness")
	 " at indices {" (var "k") ", ..., " (var "k") " + " (var "size") " - 1}.")
	(p
	 (code "Bytes-sint-ref") " retrieves the exact integer corresponding to the "
	 "two's complement representation of size " (var "size") 
	 " and specified by " (var "endianness") " at indices {" 
	 (var "k") ", ..., " (var "k") " + " (var "size") " - 1}.")
	(p
	 "For " (code "bytes-uint-set!") ", " (var "n") " must be an exact integer "
	 "in the interval [0, (256^" (var "size") ")-1]. " (code "Bytes-uint-set!")
	 " stores the unsigned representation of size " (var "size") " and specified "
	 "by " (var "endianness") " into the bytes object at indices {" 
	 (var "k") ", ..., " (var "k") " + " (var "size") " - 1}.")
	(p
	 "For " (code "bytes-uint-set!") ", " (var "n") " must be an exact integer "
	 "in the interval [-256^(" (var "size") "-1), (256^(" (var "size") "-1))-1]. "
	 (code "Bytes-sint-set!")
	 " stores the two's complement representation of size " (var "size") " and specified "
	 "by " (var "endianness") " into the bytes object at indices {" 
	 (var "k") ", ..., " (var "k") " + " (var "size") " - 1}."))
       

       (dt
	(prototype "bytes-u16-ref"
		   (var "endianness")
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-s16-ref"
		   (var "endianness")
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-u16-native-ref"
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-s16-native-ref"
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-u16-set!"
		   (var "endianness")
		   (var "bytes")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "bytes-s16-set!"
		   (var "endianness")
		   (var "bytes")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "bytes-u16-native-set!"
		   (var "bytes")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "bytes-s16-native-set!"
		   (var "bytes")
		   (var "k")
		   (var "n")))

       (dd
	(p
	 (var "K") " must be a valid index of " (var "bytes") "; so must "
	 "the index " (var "k") "+ 1. "
	 (var "Endianness") " must be an endianness object. ")
	(p
	 "These retrieve and set two-byte representations of numbers at "
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
	(prototype "bytes-u32-ref"
		   (var "endianness")
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-s32-ref"
		   (var "endianness")
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-u32-native-ref"
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-s32-native-ref"
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-u32-set!"
		   (var "endianness")
		   (var "bytes")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "bytes-s32-set!"
		   (var "endianness")
		   (var "bytes")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "bytes-u32-native-set!"
		   (var "bytes")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "bytes-s32-native-set!"
		   (var "bytes")
		   (var "k")
		   (var "n")))

       (dd
	(p
	 (var "K") " must be a valid index of " (var "bytes") "; so must "
	 "the indices {" (var "k") ", ..., " (var "k") "+ 3}. "
	 (var "Endianness") " must be an endianness object. ")
	(p
	 "These retrieve and set four-byte representations of numbers at "
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
	(prototype "bytes-u64-ref"
		   (var "endianness")
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-s64-ref"
		   (var "endianness")
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-u64-native-ref"
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-s64-native-ref"
		   (var "bytes")
		   (var "k")))
       (dt
	(prototype "bytes-u64-set!"
		   (var "endianness")
		   (var "bytes")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "bytes-s64-set!"
		   (var "endianness")
		   (var "bytes")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "bytes-u64-native-set!"
		   (var "bytes")
		   (var "k")
		   (var "n")))
       (dt
	(prototype "bytes-s64-native-set!"
		   (var "bytes")
		   (var "k")
		   (var "n")))

       (dd
	(p
	 (var "K") " must be a valid index of " (var "bytes") "; so must "
	 "the indices {" (var "k") ", ..., " (var "k") "+ 7}. "
	 (var "Endianness") " must be an endianness object. ")
	(p
	 "These retrieve and set eight-byte representations of numbers at "
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
	(prototype "bytes=?"
		   (var "bytes-1")
		   (var "bytes-2")))
       (dd
	(p
	 "Returns " (var "#t") " if " (var "bytes-1") " and "  (var "bytes-2")
	 " are equal---that is, if they have the same length and equal bytes "
	 "at all valid indices."))

       (dt
	(prototype "bytes-copy!"
		   (var "source") (var "source-start")
		   (var "target") (var "target-start")
		   (var "n")))
       (dd
	(p
	 "Copies data from bytes " (var "source") " to bytes "
	 (var "target") ".  " (var "Source-start") ", " (var "target-start")
	 ", and " (var "n") " must be non-negative exact integers that satisfy")
       
	(p
	 "0 <= " (var "source-start")
	 " <= "
	 (var "source-start") " + " (var "n")
	 " <= " (code "(bytes-length " (var "source") ")"))
	(p
	 "0 <= " (var "target-start")
	 " <= "
	 (var "target-start") " + " (var "n")
	 " <= " (code "(bytes-length " (var "target") ")"))

	(p
	 "This copies the bytes from " (var "source") " at indices "
	 "[" (var "source-start") ", " (var "source-start") " + " (var "n") ")"
	 " to consecutive indices in " (var "target") " starting at "
	 (var "target-index") ".")

	(p
	 "This must work even if the memory regions for the source and the "
	 "target overlap, i.e., the bytes at the target "
	 "location after the copy must be equal to the bytes "
	 "at the source location before the copy.")
       
	(p
	 "The return values are unspecified."))

       (dt
	(prototype "bytes-copy"
		   (var "bytes")))
       (dd
	(p
	 "Returns a newly allocated copy of bytes object " (var "bytes") "."))

       (dt
	(prototype "bytes->u8-list"
		   (var "bytes")))
       (dt
	(prototype "u8-list->bytes"
		   (var "bytes")))
       (dd
	(p
	 (code "bytes->u8-list") 
	 "returns a newly allocated list of the bytes of " (var "bytes")
	 " in the same order."))
       (dd
	(p
	 (code "U8-list->bytes") 
	 " returns a newly allocated bytes object whose elements are the elements "
	 "of list " (var "bytes") ", which must all be bytes, in the same order. "
	 "Analogous to " (code "list->vector") "."))

       (dt
	(prototype "bytes->uint-list"
		   (var "size")
		   (var "endianness")
		   (var "bytes")))
       (dt
	(prototype "bytes->sint-list"
		   (var "size")
		   (var "endianness")
		   (var "bytes")))
       (dt
	(prototype "uint-list->bytes"
		   (var "size")
		   (var "endianness")
		   (var "list")))
       (dt
	(prototype "sint-list->bytes"
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
	 " in bytes objects in the same way as " (code "bytes->u8-list")
	 ", " (code "bytes->s8-list") ", " (code " u8-list->bytes") ", and "
	 (code "s8-list->bytes") " do for one-byte representations."))

       )
	
      (h1 "Reference Implementation")
      
      (p
       "This " (a (@ (href "bytes.scm")) "reference implementation") " makes use of "
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
	" (Octet Vectors)")

       (li
	(a (@ (href "http://srfi.schemers.org/srfi-74/")) "SRFI 74")
	" (Octet-Addressed Binary Blocks)"))))))

(with-output-to-file "bytes-srfi.html"
  (lambda ()
    (generate-html bytes-srfi)))
