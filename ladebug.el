;;; ladebug.el --- Handy debug printing helpers      -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Daniel Nicolai

;; Author: Daniel Nicolai <dalanicolai@2a02-a45d-af56-1-666c-72af-583a-b92d.fixed6.kpn.net>
;; Keywords: lisp, tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(setq warning-minimum-log-level :debug)

(defvar-local ldbg-counter 0)

;;;###autoload
(defun ldbg (&rest args)
  (setq ldbg-counter (1+ ldbg-counter))
  (apply #'lwarn (buffer-name) :debug
         (concat
          (number-to-string counter)
          " "
          (number-to-string (minibuffer-depth))
          (propertize (apply #'concat (make-list (1- (length args)) " %s"))
                      'face '(foreground-color . "red"))
          " %s")
         args)
  (car (last args)))

(defun ldbg-wrap (function-name)
  (pcase-let* ((thing (thing-at-point 'sexp))
	       (new-thing (concat "(" function-name " " thing ")"))
	       (`(,beg . ,end) (bounds-of-thing-at-point 'sexp)))
    (replace-string-in-region thing  new-thing beg (+ beg (length new-thing)))))


(defun ldbg-ldbg-wrap ()
  (interactive)
  (ldbg-wrap "ldbg"))

(defun ldbg-ldbg-unwrap ()
  (interactive)
  (pcase-let* ((thing (thing-at-point 'sexp)))
    (pcase thing
      ("ldbg" (search-backward "("))
      ((pred (string-match-p "^(ldbg ")))
      (_ (search-backward "(ldbg ")))
    (forward-list))
  (pcase-let* ((old (thing-at-point 'sexp))
	       (`(,beg . ,end) (bounds-of-thing-at-point 'sexp)))
    (backward-char 1)
    (replace-string-in-region old (thing-at-point 'sexp) beg end)))

(defun ldbg-switch-to-warning-buffer ()
  (interactive)
  (when-let (b (get-buffer-create "*Warnings*"))
    (switch-to-buffer b)))



(provide 'ladebug)
;;; ladebug.el ends here
