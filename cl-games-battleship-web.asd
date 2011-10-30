(defsystem cl-games-battleship-web
    :depends-on (:cl-games-battleship :hunchentoot)
    :components
    ((:file "package")
     (:file "engine" :depends-on ("package"))
     (:file "server" :depends-on ("engine"))))
