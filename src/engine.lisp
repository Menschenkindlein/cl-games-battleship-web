(in-package :cl-games-battleship-web)

(defclass game ()
  ((human-game-space :accessor human-game-space)
   (comp-game-space :accessor comp-game-space)
   (human-name :initarg :human-name :reader human-name)
   (comp-player-name :initarg :comp-player-name :reader comp-player-name)
   (comp-killer :accessor comp-killer)
   (result :accessor result)))

(defmethod initialize-instance :after ((game game)
				       &key comp-placer comp-killer config
				       human-ships-positions)
  (setf (comp-killer game)
	(make-instance 'killer
		       :player comp-killer
		       :config config))
  (setf (human-game-space game)
	(make-instance 'game-space
		       :gsconfig (first config)
		       :ships-positions
		       human-ships-positions))
  (setf (comp-game-space game)
	(make-instance 'game-space
		       :gsconfig (first config)
		       :ships-positions
		       (funcall comp-placer
				(first config)
				(second config)))))

(defmethod turn ((game game) &optional shooting-place)
  (setf (result game) (if shooting-place
			  (shoot (comp-game-space game) shooting-place)
			  (shoot (human-game-space game)
				 (ask (comp-killer game) (result game)))))
    (if shooting-place
	(if (cleared (comp-game-space game))
	    (ask-human game "are winner")
	    (ask-human game (result game)))
	(if (cleared (human-game-space game))
	    (ask-human game "is winner")
	    (ask-human game (result game)))))

(defmethod ask-human ((game game) &optional result)
  (concatenate 'string
	       (print-game-space-web (human-game-space game))
	       "|"
	       (print-game-space-web (comp-game-space game)
				     :enemy t)
	       "|"
	       (if result
		   (princ-to-string result))))

(defmacro incn (n list &optional (increment 1))
  (let ((incfed-list (gensym)))
    `(let ((,incfed-list (copy-list ,list)))
       (incf (nth ,n ,incfed-list) ,increment)
       ,incfed-list)))

(defun convert-ships-positions (ships-positions)
  (let ((ships-positions (read-from-string ships-positions))
	placed
	real-positions
	(current-ship (make-list 3)))
    (loop for cell in ships-positions doing
	 (unless (find cell placed :test #'equal)
	   (push cell placed)
	   (setf (second current-ship) (mapcar #'1+ cell))
	   (setf (third current-ship)
		 (loop for n upto 1 doing
		      (if (find (incn n cell) ships-positions
				:test #'equal)
			  (return n))))
	   (if (third current-ship)
	       (setf (first current-ship)
		     (loop for n by 1 doing
			  (if (find (incn (third current-ship) cell n)
				    ships-positions :test #'equal)
			      (push (incn (third current-ship) cell n) placed)
			      (return n))))
	       (setf (first current-ship) 1 (third current-ship) 0))
	   (incf (third current-ship))
	   (push (copy-list current-ship) real-positions)))
    real-positions))
