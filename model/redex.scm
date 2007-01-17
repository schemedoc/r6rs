(module redex mzscheme
  (require (planet "reduction-semantics.ss" ("robby" "redex.plt" 3))
           (planet "subst.ss" ("robby" "redex.plt" 3)))
  (provide (all-from (planet "reduction-semantics.ss" ("robby" "redex.plt" 3)))
           (all-from (planet "subst.ss" ("robby" "redex.plt" 3)))))

