(module anything racket
  (provide (all-defined-out))
  (require peg/peg)
  (begin
    (require "peg-result.rkt")
    (define char-table '(("null" . #\nul) ("nul" . #\nul) ("backspace" . #\backspace) ("tab" . #\tab) ("newline" . #\newline) ("vtab" . #\vtab) ("page" . #\page) ("return" . #\return) ("space" . #\space) ("rubout" . #\rubout)))
    (define (symbol->keyword sym) (string->keyword (symbol->string sym)))
    (define-peg/drop _ (* (or #\space #\tab #\newline)))
    (define-peg s-exp (or list box-list quote quasiquote unquote syntax-quote syntax-quasiquote syntax-unquote boolean number identifier dotdotdot keyword character string))
    (define-peg list (and "(" _ (name lst (* (and s-exp _))) (? (and (name dotted-pair ".") _ (name back s-exp))) ")") (if dotted-pair (append lst back) lst))
    (define-peg box-list (and "[" _ (name lst (* (and s-exp _))) (? (and (name dotted-pair ".") _ (name back s-exp))) "]") (if dotted-pair (append lst back) lst))
    (define-peg quote (and "'" _ (name s s-exp)) (list 'quote s))
    (define-peg quasiquote (and "`" _ (name s s-exp)) (list 'quasiquote s))
    (define-peg unquote (and "," _ (name s s-exp)) (list 'unquote s))
    (define-peg syntax-quote (and "#'" _ (name s s-exp)) (list 'syntax s))
    (define-peg syntax-quasiquote (and "#`" _ (name s s-exp)) (list 'quasisyntax s))
    (define-peg syntax-unquote (and "#," _ (name s s-exp)) (list 'unsyntax s))
    (define-peg boolean (or (name x "#t") (name x "#f")) (equal? "#t" x))
    (define-peg identifier (name s (+ (and (! (or #\. #\space #\tab #\newline #\( #\) #\[ #\] #\{ #\} #\" #\, #\' #\` #\; #\# #\| #\\)) (any-char)))) (string->symbol s))
    (define-peg dotdotdot "..." '...)
    (define-peg keyword (and "#:" (name s identifier)) (symbol->keyword s))
    (define-peg number floating-point)
    (define-peg string (and #\" (name s (* (or (and (! (or #\" #\\)) (any-char)) escaped-char))) #\") s)
    (define-peg escaped-char (or escaped-newline escaped-tab (and (drop #\\) (any-char))))
    (define-peg escaped-newline (and #\\ "n") (peg-result "\n"))
    (define-peg escaped-tab (and #\\ "t") (peg-result "\t"))
    (define-peg character (and (drop "#\\") (name v code)) v)
    (define-peg alphabetic (name v (or (range #\a #\z) (range #\A #\Z))) (string-ref v 0))
    (define-peg code (or named-char alphabetic-code digit))
    (define-peg named-char (and (name nm (or "null" "nul" "backspace" "tab" "newline" "tab" "vtab" "page" "return" "space" "rubout")) (! alphabetic)) (cdr (assoc nm char-table)))
    (define-peg alphabetic-code (and (name v alphabetic) (! alphabetic)) v)
    (define-peg digit (name v (range #\0 #\9)) (string-ref v 0))
    (define-peg signal (or "-" "+"))
    (define-peg integer-part (+ (range #\0 #\9)))
    (define-peg fractional-part (+ (range #\0 #\9)))
    (define-peg scientific-notation (and (or "e" "E") integer-part))
    (define-peg floating-point (name value (and (? signal) integer-part (? (and "." fractional-part)) (? scientific-notation))) (string->number value))))
