(in-package :cl-games-battleship-web)

(defmacro path-here (path)
  (merge-pathnames path (asdf:component-pathname
			 (asdf:find-system :cl-games-battleship-web))))

(setf hunchentoot:*session-removal-hook* (lambda (session)
					   (remhash session *game-spaces*)))
(push
 (hunchentoot:create-static-file-dispatcher-and-handler "/"
							(path-here
							 "index.html"))
 hunchentoot:*dispatch-table*)

(push
 (hunchentoot:create-static-file-dispatcher-and-handler "/styles"
							(path-here
							 "styles.css"))
 hunchentoot:*dispatch-table*)

(push
 (hunchentoot:create-static-file-dispatcher-and-handler "/scripts"
							(path-here
							 "script.js"))
 hunchentoot:*dispatch-table*)

(hunchentoot:define-easy-handler (create-bship-game
				  :uri "/create") (ships-positions
						   config comp-player
						   name)
  (setf (hunchentoot:content-type*) "text/plain")
  (setf ships-positions (convert-ships-positions ships-positions))
  (unless config
    (setf config "((10 10) (4 3 3 2 2 2 1 1 1 1))"))
  (let (placer killer)
    (cond
      ((equal comp-player "easy")
       (setf placer #'constant-placer)
       (setf killer #'constant-killer-web))
      ((equal comp-player "medium")
       (setf placer #'constant-placer)
       (setf killer #'random-killer-web))
      ((equal comp-player "moderate")
       (setf placer #'random-placer-bf)
       (setf killer #'constant-killer-web))
      ((equal comp-player "hard")
       (setf placer #'random-placer-bf)
       (setf killer #'random-killer-web)))
    (setf (gethash hunchentoot:*session* *game-spaces*)
	  (make-instance 'game
			 :config (read-from-string config)
			 :human-ships-positions ships-positions
			 :human-name name
			 :comp-player-name comp-player
			 :comp-placer placer
			 :comp-killer killer)))
  (ask-human (gethash hunchentoot:*session* *game-spaces*) "Hello"))

(hunchentoot:define-easy-handler (make-turn
				  :uri "/turn") (place-to-shoot)
  (setf (hunchentoot:content-type*) "text/plain")
  (turn (gethash hunchentoot:*session* *game-spaces*)
	(when (and place-to-shoot
		   (not (equal place-to-shoot "none")))
	  (read-from-string place-to-shoot))))

(hunchentoot:define-easy-handler (random-helper
				  :uri "/random") (config)
  (setf (hunchentoot:content-type*) "text/plain")
  (unless config
    (setf config "((10 10) (4 3 3 2 2 2 1 1 1 1))"))
  (let ((config '((10 10) (4 3 3 2 2 2 1 1 1 1))))
    (print-game-space-web (make-instance 'game-space
					 :ships-positions
					 (random-placer-bf
					  (first config)
					  (second config))
					 :gsconfig (first config)))))

(hunchentoot:define-easy-handler (gamespace-tester
				  :uri "/correct") (ships-positions)
  (setf (hunchentoot:content-type*) "text/plain")
  (setf ships-positions (sort (convert-ships-positions ships-positions)
			      (lambda (a b) (> (first a) (first b)))))
  (if (every (lambda (conf ship)
	       (= conf (first ship)))
	     '(4 3 3 2 2 2 1 1 1 1)
	     ships-positions)
      (princ-to-string (correct (make-instance 'game-space
					       :ships-positions
					       ships-positions
					       :gsconfig '(10 10))))
      (princ-to-string nil)))

(defvar *server-killers* (make-hash-table))

(defun start-server (port)
  (let ((server (hunchentoot:start
		 (make-instance 'hunchentoot:acceptor :port port))))
    (setf (gethash port *server-killers*)
	  (lambda () (hunchentoot:stop server)))))

(defun stop-server (port)
  (funcall (gethash port *server-killers*)))