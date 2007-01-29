(module show-examples mzscheme
  
  (require (planet "gui.ss" ("robby" "redex.plt" 3))
           (planet "reduction-semantics.ss" ("robby" "redex.plt" 3))
           "r6rs.scm")
  (provide show show-expression)

  
  
  ;; the number of steps to produce automatically (the GUI lets you produce more if you wish)
  (reduction-steps-cutoff 100)
  
  ;; the width of the boxes in the GUI (used when pretty-printing their contents)
  ;; defaults to 40 if unspecified
  (initial-char-width 60)
  
  ;; show : sexp -> void
  ;; shows the reduction sequence for its argument; any terms
  ;; that don't match the script p (p*) non-terminal are turned pink
  (define (show x)
    (traces/pred lang 
                 reductions
                 (list x) 
                 (λ (x) 
                   (let ([m (tm x)])
                     (and m
                          (= 1 (length m)))))))
  (define tm (test-match lang p*))

  (define (show-expression x) (show `(store () (,x))))

  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; example uses of the above functions
  ;; if any of the terms in the graph don't 
  ;;    match p*, they will be colored red
  ;; #; comments out an entire sexpression.
  ;; 
  
  (show '(store () ((lambda (x y) (set! x (+ x y)) x) 2 3)))

  ;; an infinite, tail-recursive loop
  (show-expression '((lambda (x) ((call/cc call/cc) x)) (call/cc call/cc)))
  
  )

