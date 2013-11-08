(custom-set-variables
'(line-number-mode t)
'(column-number-mode t))

; set meta-g to be the goto-line command
(global-set-key "\M-g" 'goto-line)
(global-set-key "\M-r" 'replace-string)
;(global-set-key "\C-?" 'comment-region)

; add to the load-path
(add-to-list 'load-path "~/.emacs.d/lisp/")
(add-to-list 'load-path "~/dev/github/dbriones/cucumber.el/")
(add-to-list 'load-path "~/dev/github/dbriones/markdown-mode/")

(autoload 'markdown-mode "markdown-mode.el" 
  "Major mode for editing Markdown files" t) 
(setq auto-mode-alist 
  (cons '("\\.md" . markdown-mode) auto-mode-alist))

;;; turn on syntax highlighting
(global-font-lock-mode 1)

(add-to-list 'custom-theme-load-path "~/dev/github/dbriones/emacs-color-theme-solarized/")
(load-theme 'solarized-dark t)

;(global-set-key "\M-s d" 'load-theme "solarized-dark")

(require 'feature-mode)
(add-to-list 'auto-mode-alist '("\.feature$" . feature-mode))
