(in-package :cl-games-battleship-web)

(defvar *game-spaces* (make-hash-table))

(defvar *server-killers* (make-hash-table))

(defun start-server (port)
  (let ((server (hunchentoot:start
		 (make-instance 'hunchentoot:acceptor :port port))))
    (setf (gethash port *server-killers*)
	  (lambda () (hunchentoot:stop server)))))

(defun stop-server (port)
  (funcall (gethash port *server-killers*)))

(setf hunchentoot:*session-removal-hook* (lambda (session)
					   (remhash session *game-spaces*)))
