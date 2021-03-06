(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
(setq exec-path (append exec-path '("/usr/local/bin")))

(load (expand-file-name "~/.emacs.d/user/wm.el"))

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pinned packages

(add-to-list 'package-pinned-packages '(cider . "melpa-stable") t)
(add-to-list 'package-pinned-packages '(cider-nrepl . "melpa-stable") t)
(package-initialize)

(defun install-package (package-name)
  (unless (package-installed-p package-name)
    (package-refresh-contents)
    (package-install package-name)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Macros ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key [f2] 'start-kbd-macro)
(global-set-key [f3] 'end-kbd-macro)
(global-set-key [f4] 'call-last-kbd-macro)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Misc ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq split-height-threshold nil)
(if window-system
    (progn (scroll-bar-mode -1)
	(tool-bar-mode -1)))

(setq inhibit-startup-screen t)
(defalias 'yes-or-no-p 'y-or-n-p)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq default-directory "~/")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ## Clojure

(install-package 'paredit)
(install-package 'cider)
(install-package 'clj-refactor)
(show-paren-mode 1)

;; To store the REPL history in a file:
(setq cider-repl-history-file "~/.emacs.d/.repl-history")

;; Enabling CamelCase support for editing commands(like forward-word,
;; backward-word, etc) in the REPL is quite useful since we often have
;; to deal with Java class and method names. The built-in Emacs minor
;; mode subword-mode provides such functionality
(add-hook 'cider-repl-mode-hook 'subword-mode)

;; The use of paredit when editing Clojure (or any other Lisp) code is
;; highly recommended. You're probably using it already in your
;; clojure-mode buffers (if you're not you probably should). You might
;; also want to enable paredit in the REPL buffer as well:
(add-hook 'clojure-mode-hook #'paredit-mode)
(add-hook 'cider-repl-mode-hook #'paredit-mode)
(add-hook 'clojure-mode-hook (lambda ()
			       (local-set-key (kbd "M-SPC") 'mark-sexp)
			       (clj-refactor-mode 1)
			       (yas-minor-mode 1)
			       (cljr-add-keybindings-with-prefix "C-c C-m")))
(install-package 'clojure-cheatsheet)
(global-set-key (kbd "C-c s") 'clojure-cheatsheet)

(eval-after-load 'clojure-mode
  ;; Custom indentation rules; see clojure-indent-function
  '(define-clojure-indent
       (using 'defun)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ## Magit

(install-package 'magit)
(global-set-key (kbd "C-x m") 'magit-status)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ## Org mode

;; Custom org mode to get clojure babel support
(add-to-list 'load-path "~/.emacs.d/local-packages/org-mode-8.0/lisp")
(require 'org)
(require 'org-compat)
(require 'org-clock)
(require 'org-faces)

(set-face-attribute 'org-mode-line-clock nil :background "pink")

(when (fboundp 'set-word-wrap)
  (add-hook 'org-mode-hook 'set-word-wrap))

(setq daypage-path "~/Dropbox/daypage/")

(defun find-daypage (&optional date)
  "Go to the day page for the specified date,
   or toady's if none is specified."
  (interactive (list
                (org-read-date "" 'totime nil nil
                               (current-time) "")))
  (setq date (or date (current-time)))
  (let* ((file (expand-file-name
                (concat daypage-path
                        (format-time-string "daypage-%Y-%m-%d-%a" date) ".org")))
         (buffer (find-buffer-visiting file)))
    (if buffer
        (pop-to-buffer buffer)
      (find-file file))
    (when (= 0 (buffer-size))
      ;; Insert an initial for the page
      (insert (format-time-string "%Y-%m-%d %A : " date)))))

(defun todays-daypage ()
  "Go straight to today's day page without prompting for a date."
  (interactive)
  (find-daypage))

(global-set-key "\C-con" 'todays-daypage)
(global-set-key "\C-coN" 'find-daypage)

(defun my-agenda ()
  (interactive)
  (org-agenda nil "n"))

(global-set-key (kbd "C-c o a") 'my-agenda)

;; Babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (clojure . t)))

;; Use cider as the clojure execution backend
(setq org-babel-clojure-backend 'cider)
(require 'ob-clojure)

;; Let's have pretty source code blocks
(setq org-edit-src-content-indentation 0
      org-src-tab-acts-natively t
      org-src-fontify-natively t
      org-confirm-babel-evaluate nil)

(setq org-export-backends '(md))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Color themes

(install-package 'color-theme-solarized)
(require 'color-theme)
(setq color-theme-is-global t)
(add-to-list 'load-path "~/.emacs.d/themes")
(color-theme-solarized-dark)

;;(require 'gentooish-theme)
;;(color-theme-gentooish)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Whitespace

;; from https://github.com/candera/emacs/blob/3cc572daf3148a1aebe2fc69c1c93e462dba2fee/init.el#L298

(defun detabify-buffer ()
  "Calls untabify on the current buffer"
  (interactive)
  (untabify (point-min) (point-max)))

(defvar detabify-modes '(javascript-mode emacs-lisp-mode ruby-mode clojure-mode java-mode)
  "A list of the modes that will have tabs converted to spaces before saving.")

(defun mode-aware-detabify ()
  "Calls untabify on the current buffer if the major mode is one of 'detabify-modes'"
  (interactive)
  (when (member major-mode detabify-modes)
    (detabify-buffer)))

(defvar delete-trailing-whitespace-modes detabify-modes
  "A list of the modes that will have trailing whitespace before saving.")

(defun mode-aware-trailing-whitespace-cleanup ()
  "Calls delete-trailing-whitespace-modes on the current buffer
if the major mode is one of 'delete-trailing-whitespace-modes'"
  (interactive)
  (when (member major-mode delete-trailing-whitespace-modes)
    (delete-trailing-whitespace)))

(defun clean-up-whitespace ()
  "Calls untabify and delete-trailing-whitespace on the current buffer."
  (interactive)
  (detabify-buffer)
  (delete-trailing-whitespace))

(global-set-key (kbd "C-x t") 'clean-up-whitespace)

(defun toggle-show-whitespace ()
  (interactive)
  (setq show-trailing-whitespace
        (not show-trailing-whitespace)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rotate windows

;; from http://emacswiki.org/emacs/TransposeWindows
(defun rotate-windows ()
  "Rotate your windows"
  (interactive)
  (cond
   ((not (> (count-windows) 1))
    (message "You can't rotate a single window!"))
   (t
    (let ((i 1)
          (num-windows (count-windows)))
      (while  (< i num-windows)
        (let* ((w1 (elt (window-list) i))
               (w2 (elt (window-list) (+ (% i num-windows) 1)))
               (b1 (window-buffer w1))
               (b2 (window-buffer w2))
               (s1 (window-start w1))
               (s2 (window-start w2)))
          (set-window-buffer w1 b2)
          (set-window-buffer w2 b1)
          (set-window-start w1 s2)
          (set-window-start w2 s1)
          (setq i (1+ i))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;; IDO mode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IDO = Interactively Do Things. It's packaged in emacs by default
;; but needs to be switched on

(ido-mode t)

(install-package 'flx-ido)
(install-package 'ido-ubiquitous)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; smex ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(install-package 'smex)
(require 'smex)
(global-set-key [(meta x)] (lambda ()
                             (interactive)
                             (or (boundp 'smex-cache)
                                 (smex-initialize))
                             (global-set-key [(meta x)] 'smex)
                             (smex)))

(global-set-key [(shift meta x)] (lambda ()
                                   (interactive)
                                   (or (boundp 'smex-cache)
                                       (smex-initialize))
                                   (global-set-key [(shift meta x)] 'smex-major-mode-commands)
                                   (smex-major-mode-commands)))

;;;;;;;;;;;;;;;;;;;;;;;;;; Helm (find files in project) ;;;;;;;;;;;;;;;;;;;;;;;;;;

(install-package 'helm-ls-git)
(global-set-key (kbd "C-c f") 'helm-ls-git-ls)
(setq helm-ff-transformer-show-only-basename nil
      helm-ls-git-show-abs-or-relative 'relative)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Git link
(install-package 'git-link)

(global-set-key (kbd "C-c C-g") 'git-link)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Markdown mode
(install-package 'markdown-mode)

(setq markdown-indent-on-enter nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shell script mode

(defun setup-sh-mode ()
  "Set sh-mode to use 2 spaces for indentation"
  (interactive)
  (setq sh-basic-offset 2
	sh-indentation 2))
(add-hook 'sh-mode-hook 'setup-sh-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ## Misc modes

(install-package 'yaml-mode)
(install-package 'web-mode)
(install-package 'protobuf-mode)
(put 'upcase-region 'disabled nil)
