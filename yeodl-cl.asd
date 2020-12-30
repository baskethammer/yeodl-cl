;;;; yeodl-cl.asd

(asdf:defsystem #:yeodl-cl
  :description "An API for YEODL stock database"
  :author "BasketHammer <bh@baskethammer.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:iterate #:sqlite)
  :components ((:file "package")
	       (:file "yeodl")))
