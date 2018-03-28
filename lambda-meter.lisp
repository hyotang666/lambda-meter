(defpackage #:lambda-meter
  (:use #:cl)
  (:export
    #:profile-lambda	; Main api, but reader macro is recomended.
    #:unprofile		; Wrapper for sb-profile:unprofile.
    #:enable		; Dispatch macro character setter.
    #:|#M-reader|	; Dispatch macro character function.
    #:syntax		; Readtable name for named-readtables.
    ))
(in-package #:lambda-meter)
(named-readtables:in-readtable with-package:syntax)

#@(:sb-profile #:*profiled-fun-name->info* 	; hash table
	       #:make-profile-info		; constructor
	       #:profile-info-encapsulation-fun ; reader
	       #:profile-encapsulation-lambdas	; initializer
	       )

(defun profile-lambda(id underlying-fun)
  (let((info(gethash id *profiled-fun-name->info*)))
    (if info
      (lambda(&rest args)
	(apply (profile-info-encapsulation-fun info)
	       underlying-fun
	       args))
      (multiple-value-bind(encapsulation-fun read-stats-fun clear-stats-fun)(profile-encapsulation-lambdas)
	(setf (gethash id *profiled-fun-name->info*)
	      (make-profile-info :name id
				 :encapsulated-fun underlying-fun
				 :encapsulation-fun encapsulation-fun
				 :read-stats-fun read-stats-fun
				 :clear-stats-fun clear-stats-fun))
	(lambda(&rest args)
	  (apply encapsulation-fun underlying-fun args))))))

#@(:sb-profile #:*profiled-fun-name->info*)
(defmacro unprofile(&rest names)
  (if names
    `(dolist(name ',names)
       (unprofile1 name))
    `(loop :for name :being :each :hash-key :of *profiled-fun-name->info*
	   :do (unprofile1 name))))

#@(:sb-profile #:*profiled-fun-name->info* #:unprofile-1-fun)
(defun unprofile1(name)
  (if(fboundp name)
    (unprofile-1-fun name)
    (remhash name *profiled-fun-name->info*)))

(defun |#M-reader|(stream character number)
  (declare(ignore character number))
  `(profile-lambda (the symbol ',(read stream t t t))
		   (the function ,(read stream t t t))))

(defun enable(&optional (char #\M))
  (set-dispatch-macro-character #\# char #'|#M-reader|))

(named-readtables:defreadtable lambda-meter:syntax
  (:merge :standard)
  (:dispatch-macro-char #\# #\m #'|#M-reader|))

#++
(progn ; trivial test
(defun adder(num)
  #M adder
  (lambda(n)
    (+ n num)))
(defparameter 2+ (adder 2))
(defparameter 3+ (adder 3))
(assert (= 4 (funcall 2+ 2)))
(assert (= 5 (funcall 3+ 2)))
)
