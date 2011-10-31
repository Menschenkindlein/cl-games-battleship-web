(defsystem cl-games-battleship-web
    :depends-on (:cl-games-battleship :hunchentoot)
    :components
    ((:module "src"
	      :components
	      ((:file "package")
	       (:file "interface" :depends-on ("package"))
	       (:file "engine" :depends-on ("interface"))
	       (:file "server" :depends-on ("package"))
	       (:file "pages" :depends-on ("engine" "server"))))))
