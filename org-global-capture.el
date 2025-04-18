;;; org-global-capture.el --- description

;;; Commentary:
;; Put together from these sources:
;; http://www.windley.com/archives/2010/12/capture_mode_and_emacs.shtml
;; https://github.com/pashinin/emacsd/blob/master/elisp/init-org-capture.el

;; activated by a keybinding to
;; emacsclient -c -F '(quote (name . "capture"))' -e '(activate-capture-frame)'
;; activated as a org-roam-dailies-capture-today buffer by a keybinding to
;; emacsclient -c -F '(quote (name . "capture"))' -e '(activate-capture-frame t)'

;;; Code:

(defun suppress-window-splitting-advice (&rest _args)
  "Delete the extra window if we're in a capture frame."
  (when (equal "capture" (frame-parameter nil 'name))
    (centaur-tabs-local-mode 1)
    (maximize-window)
    (delete-other-windows)))

(defun delete-capture-frame-finalize-advice (&rest _args)
  "Close the frame if it's a capture frame after capture-finalize."
  (when (and (equal "capture" (frame-parameter nil 'name))
             (not (eq this-command 'org-capture-refile)))
    (delete-frame)
    (kill-buffer "*empty*")))

(defun delete-capture-frame-refile-advice (&rest _args)
  "Close the frame if it's a capture frame after org-refile."
  (when (equal "capture" (frame-parameter nil 'name))
    (delete-frame)
    (kill-buffer "*empty*")))

(advice-add 'switch-to-buffer-other-window :after #'suppress-window-splitting-advice)
(advice-add 'org-capture-finalize :after #'delete-capture-frame-finalize-advice)
(advice-add 'org-capture-refile :after #'delete-capture-frame-refile-advice)
(advice-add 'org-capture :after #'suppress-window-splitting-advice)

(defun activate-capture-frame (&optional is-roam)
  "run org-capture in capture frame"
  :type '(boolean)
  (select-frame-by-name "capture")
  (switch-to-buffer (get-buffer-create "*emtpy*"))
  (erase-buffer)
  (read-only-mode 1)
  (centaur-tabs-local-mode 1)
  (delete-other-windows)
  (if is-roam (org-roam-dailies-capture-today) (org-capture))
  )

;; Only works if there's already an other frame:
(defun make-capture-frame ()
  "Create a new frame and run org-capture."
  (interactive)
  (make-frame '((name . "capture")
                (width . 90)
                (height . 20)
                (minibuffer . t)
                (window-system . x)
                ))
  (activate-capture-frame))

(provide 'org-global-capture)

;;; org-global-capture.el ends here
