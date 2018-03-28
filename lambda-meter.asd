; vim: ft=lisp et
(in-package :asdf)
(defsystem "lambda-meter"
  :depends-on
  ("with-package"       ; To import symbols locally.
   "named-readtables"   ; To provide readtable.
   )
  :components
  ((:file "lambda-meter")))
