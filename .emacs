;; Original Author - Karl Voit
;; link - https://github.com/novoid/dot-emacs/blob/master/init.el

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(message "—————• Custom Variables initialisation")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" default)))
 '(inhibit-startup-screen t)
 '(initial-buffer-choice "~/todo/todo.org")
 '(magit-diff-arguments (quote ("--no-ext-diff" "--stat")))
 '(package-selected-packages
   (quote
    (evil pytest flymd yasnippet-snippets multiple-cursors icicles company-anaconda anaconda-mode helm-ros smart-mode-line projectile-speedbar neotree monokai-alt-theme magit kooten-theme helm-rtags helm-projectile helm-flymake google-c-style golden-ratio flymake-google-cpplint flymake-cppcheck flycheck-rtags flycheck-irony company-shell company-rtags company-irony-c-headers company-irony company-c-headers cmake-project cmake-ide auctex afternoon-theme))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(setq my-user-emacs-directory "~/.emacs.d/")

(add-to-list 'load-path
	     (concat my-user-emacs-directory "emacs-config/lisp/"))


;; BEGIN Copied from https://github.com/novoid/dot-emacs/blob/master/init.el

(require 'org)

;; =======================================================================================
;; The init.el file looks for "config.org" and tangles its elisp blocks (matching
;; the criteria described below) to "config.el" which is loaded as Emacs configuration.
;; Inspired and copied from: http://www.holgerschurig.de/en/emacs-init-tangle/
;; =======================================================================================


(defun my-tangle-config-org ()
  "This function will write all source blocks from =config.org= into =config.el= that are ...
- not marked as =tangle: no=
- doesn't have the TODO state =DISABLED=
- have a source-code of =emacs-lisp="
  (require 'org)
  (let* ((body-list ())
         (output-file (concat my-user-emacs-directory "emacs-config/emacs-config.el"))
         (org-babel-default-header-args (org-babel-merge-params org-babel-default-header-args
                                                                (list (cons :tangle output-file)))))
    (message "—————• Re-generating %s …" output-file)
    (save-restriction
      (save-excursion
        (org-babel-map-src-blocks (concat my-user-emacs-directory "emacs-config/emacs-config.org")
	  (let* (
		 (org_block_info (org-babel-get-src-block-info 'light))
		 ;;(block_name (nth 4 org_block_info))
		 (tfile (cdr (assq :tangle (nth 2 org_block_info))))
		 (match_for_TODO_keyword)
		 )
	    (save-excursion
	      (catch 'exit
		;;(when (string= "" block_name)
		;;  (message "Going to write block name: " block_name)
		;;  (add-to-list 'body-list (concat "message(\"" block_name "\")"));; adding a debug statement for named blocks
		;;  )
		(org-back-to-heading t)
		(when (looking-at org-outline-regexp)
		  (goto-char (1- (match-end 0))))
		(when (looking-at (concat " +" org-todo-regexp "\\( +\\|[ \t]*$\\)"))
		  (setq match_for_TODO_keyword (match-string 1)))))
	    (unless (or (string= "no" tfile)
			(string= "DISABLED" match_for_TODO_keyword)
			(not (string= "emacs-lisp" lang)))
	      (add-to-list 'body-list (concat "\n\n;; #####################################################################################\n"
					      "(message \"config • " (org-get-heading) " …\")\n\n")
			   )
	      (add-to-list 'body-list body)
	      ))))
      (with-temp-file output-file
	;; Thanks for http://irreal.org/blog/?p=6236 and https://github.com/marcowahl/.emacs.d/blob/master/init.org for the read-only-trick:
        (insert ";; emacs-config.el --- This is the GNU/Emacs config file of Sree Gowtham J. -*- eval: (read-only-mode 1) -*-\n")
        (insert ";; ======================================================================================\n")
        (insert ";; Don't edit this file, edit emacs-config.org' instead ...\n")
        (insert ";; ======================================================================================\n\n")
        (insert (apply 'concat (reverse body-list))))
      (message "—————• Wrote %s" output-file))))


;; following lines are executed only when my-tangle-config-org-hook-func()
;; was not invoked when saving config.org which is the normal case:
(let ((orgfile (concat my-user-emacs-directory "emacs-config/emacs-config.org"))
      (elfile (concat my-user-emacs-directory "emacs-config/emacs-config.el"))
      (gc-cons-threshold most-positive-fixnum))
  (when (or (not (file-exists-p elfile))
            (file-newer-than-file-p orgfile elfile))
    (my-tangle-config-org)
    ;;(save-buffers-kill-emacs);; TEST: kill Emacs when config has been re-generated due to many issues when loading newly generated config.el
    )
  (load-file elfile))

;; when config.org is saved, re-generate config.el:
(defun my-tangle-config-org-hook-func ()
  (when (string= "emacs-config/emacs-config.org" (buffer-name))
	(let ((orgfile (concat my-user-emacs-directory "emacs-config/emacs-config.org"))
		  (elfile (concat my-user-emacs-directory "emacs-config/emacs-config.el")))
	  (my-tangle-config-org))))
(add-hook 'after-save-hook 'my-tangle-config-org-hook-func)


;; END Copied from https://github.com/novoid/dot-emacs/blob/master/init.el
