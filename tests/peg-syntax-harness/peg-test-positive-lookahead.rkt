#lang racket

(require peg)
(require rackunit)

(require "../peg-syntax/peg-example-positive-lookahead.rkt")

(check-equal? (peg anbncn "aaabbbccc")
  '(anbncn (equal-a-b (anbn "a" (anbn "a" (anbn . "ab") "b") "b") "ccc")))

(check-equal? (peg anbncn "abc")
  '(anbncn (equal-a-b (anbn . "ab") "c")))

