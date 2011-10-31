(in-package :cl-games-battleship-web)

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
