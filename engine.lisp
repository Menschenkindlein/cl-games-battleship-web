(in-package :cl-games-battleship-web)

(defclass game ()
  ((human-game-space :accessor human-game-space)
   (comp-game-space :accessor comp-game-space)
   (human-name :initarg :human-name :reader human-name)
   (comp-player-name :initarg :comp-player-name :reader comp-player-name)
   (comp-killer :accessor comp-killer)))

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

(defun print-game-space-web (gamespace &key enemy preview)
  (let ((gamespace (print-game-space gamespace :enemy enemy :preview preview)))
    (apply #'concatenate 'string
	   (loop for x from 1 to 10 collecting
		(concatenate 'string
			     (princ-to-string #\Newline)
			     "<tr>"
			     (apply
			      #'concatenate
			      'string
			      (loop for y from 1 to 10 collecting
				   (concatenate
				    'string
				    "<td"
				    (case (aref gamespace x y)
				      (9 "")
				      (0 " class=\"sea\"")
				      (1 " class=\"ship\"")
				      (2 " class=\"shooted-ship\""))
				    "></td>")))
			      "</tr>")))))

(defmacro enclose (tagname thing)
  `(concatenate 'string
		"<" ,tagname ">" ,thing "</" ,tagname ">" #(#\Newline)))

(defmethod ask-human ((game game) &optional result)
  (concatenate 'string
	       (print-game-space-web (human-game-space game))
	       "|"
	       (print-game-space-web (comp-game-space game)
				     :enemy t)
	       "|"
	       (if result
		   (princ-to-string result))))

(defvar *game-spaces* (make-hash-table))

(defmethod turn ((game game) &optional shooting-place)
  (let ((result (if shooting-place
		    (shoot (comp-game-space game) shooting-place)
		    (shoot (human-game-space game) (ask (comp-killer game))))))
    (if shooting-place
	(if (cleared (comp-game-space game))
	    (ask-human game "are winner")
	    (ask-human game result))
	(if (cleared (human-game-space game))
	    (ask-human game "is winner")
	    (progn
	      (change-killing-sequence (comp-killer game) result)
	      (ask-human game result))))))

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
