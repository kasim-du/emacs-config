;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

;;add the load path.
(add-to-list 'load-path "~/.emacs.d/site-lisp")

;;basic emacs setting
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(cua-mode t nil (cua-base))
 '(display-time-mode t)
 '(package-selected-packages
   (quote
    (web-beautify json-mode neotree js2-mode auto-complete elpy micgoline exec-path-from-shell smex projectile)))
 '(scroll-bar-mode nil)
 '(session-use-package t nil (session))
 '(tab-stop-list
   (quote
    (4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120)))
 '(tool-bar-mode nil))

(setq visible-bell t)
(fset 'yes-or-no-p 'y-or-n-p)
(display-time)
(column-number-mode t)
(set-clipboard-coding-system 'ctext)
(setq make-backup-files nil)
(electric-pair-mode 1)
(show-paren-mode 1)
(setq show-paren-style 'mixed)
(setq make-backup-files nil)

;;fix tab auto complete issue in ansi-tem
(add-hook 'term-mode-hook
          (lambda()
            (setq yas-dont-activate t)))

;;rebind the mark region
(global-set-key (kbd "C-x m") 'set-mark-command)

;;show the full path file name in the minibuffer.
(defun show-file-name ()
  "show the full path file name in the minibuffe."
  (interactive)
  (message (buffer-file-name)))
(global-set-key (kbd "C-c z") 'show-file-name)

;;kill all the other buffers.
(defun kill-other-buffers() 
  (interactive)                                                                   
    (mapc 'kill-buffer (cdr (buffer-list (current-buffer)))))
(global-set-key (kbd "C-c k") 'kill-other-buffers)

;;query replace in all buffers.
(defun query-replace-in-open-buffers (arg1 arg2)
  "query-replace in open files"
  (interactive "sQuery Replace in open Buffers: \nsquery with: ")
  (mapcar
   (lambda (x)
     (find-file x)
     (save-excursion
       (beginning-of-buffer)
       (query-replace arg1 arg2)))
   (delq
    nil
    (mapcar
     (lambda (x)
       (buffer-file-name x))
     (buffer-list)))))
(global-set-key (kbd "C-c %") 'query-replace-in-open-buffers);

;;match the parenthesis
(defun match-paren (arg)
  "Go to the matching paren if on a paren; otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))
(global-set-key "%" 'match-paren)

;;copy the word
(defun copy-word-at-point()
  (interactive)
  (save-excursion
    (let ((end (progn (unless (looking-back "\\>" 1) (forward-word 1)) (point)))
          (beg (progn (forward-word -1) (point))))
      (copy-region-as-kill beg end)
      (message (substring-no-properties (current-kill 0))))))
(global-set-key (kbd "C-c w") 'copy-word-at-point)

;;copy the line
(defun copy-line (arg)
  "Copy lines (as many as prefix argument) in the kill ring"
  (interactive "p")
  (kill-ring-save (line-beginning-position)
                  (line-beginning-position (1+ arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s")))
(global-set-key (kbd "C-c l") 'copy-line)

;auto refresh all the buffers
(global-auto-revert-mode t)
;;tab settings
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;point undo to navigate history back and forth.
(require 'point-undo)
(global-set-key (kbd "M-[") 'point-undo)
(global-set-key (kbd "M-]") 'point-redo)

;;shell clear region
(defun shell-clear-region ()
  (interactive)
  (delete-region (point-min) (point-max))
  (comint-send-input))
(global-set-key (kbd "C-c c") 'shell-clear-region)

;auto refresh all the buffers
(global-auto-revert-mode t)

;;display line number
(global-linum-mode 1)

;;;color theme
(require 'color-theme)
(load "color-theme-sunburst")
(color-theme-tm)

;;powerline theme
(require 'powerline)
(powerline-default-theme)

;awesome-tab
(require 'awesome-tab)
(awesome-tab-mode t)
(global-set-key (kbd "M-<left>") (lambda () (interactive) (awesome-tab-backward-tab)))
(global-set-key (kbd "M-<right>") (lambda () (interactive) (awesome-tab-forward-tab)))

;;ido mode
(ido-mode t)

;;session
(require 'session)
(add-hook 'after-init-hook 'session-initialize)
(load "desktop")
(desktop-save-mode 1)

;;font settings
(set-frame-font "Inconsolata-16")

;;scheme setting
(autoload 'paredit-mode "paredit"
  "Minor mode for pseudo-structurally editing Lisp code."
  t)

(require 'cmuscheme)
(setq scheme-program-name "scheme")

;; bypass the interactive question and start the default interpreter
(defun scheme-proc ()
  "Return the current Scheme process, starting one if necessary."
  (unless (and scheme-buffer
               (get-buffer scheme-buffer)
               (comint-check-proc scheme-buffer))
    (save-window-excursion
      (run-scheme scheme-program-name)))
  (or (scheme-get-process)
      (error "No current process. See variable `scheme-buffer'")))


(defun scheme-split-window ()
  (cond
   ((= 1 (count-windows))
    (delete-other-windows)
    (split-window-vertically (floor (* 0.68 (window-height))))
    (other-window 1)
    (switch-to-buffer "*scheme*")
    (other-window 1))
   ((not (find "*scheme*"
               (mapcar (lambda (w) (buffer-name (window-buffer w)))
                       (window-list))
               :test 'equal))
    (other-window 1)
    (switch-to-buffer "*scheme*")
    (other-window -1))))


(defun scheme-send-last-sexp-split-window ()
  (interactive)
  (scheme-split-window)
  (scheme-send-last-sexp))

(defun scheme-send-definition-split-window ()
  (interactive)
  (scheme-split-window)
  (scheme-send-definition))

(add-hook 'scheme-mode-hook
  (lambda ()
    (paredit-mode 1)
    (define-key scheme-mode-map (kbd "<f5>") 'scheme-send-last-sexp-split-window)
    (define-key scheme-mode-map (kbd "<f6>") 'scheme-send-definition-split-window)))

;;auto-complete
(ac-config-default)

;c/c++ mode
(require 'google-c-style)
(add-hook 'c-mode-common-hook 'google-set-c-style)
;;switch between header and source file
(global-set-key (kbd "M-o") 'ff-find-other-file)

;ac-c-headers
(require 'ac-c-headers)
(add-hook 'c-mode-hook
          (lambda ()
            (add-to-list 'ac-sources 'ac-source-c-headers)
            (add-to-list 'ac-sources 'ac-source-c-header-symbols t)))

;js2mode
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

;lua mode
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))

;;neotree
;(add-to-list 'load-path "~/.emacs.d/site-lisp/neotree")
;(require 'neotree)
(global-set-key [f8] 'neotree-toggle)

;;elpy package: emacs lisp python environment
;(elpy-enable)

;yaml mode
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

;;web-beautify
;(require 'web-beautify) ;; Not necessary if using ELPA package
(eval-after-load 'js2-mode
  '(define-key js2-mode-map (kbd "C-c b") 'web-beautify-js))
;; Or if you're using 'js-mode' (a.k.a 'javascript-mode')
(eval-after-load 'js
  '(define-key js-mode-map (kbd "C-c b") 'web-beautify-js))

(eval-after-load 'json-mode
  '(define-key json-mode-map (kbd "C-c b") 'web-beautify-js))

(eval-after-load 'sgml-mode
  '(define-key html-mode-map (kbd "C-c b") 'web-beautify-html))

(eval-after-load 'web-mode
  '(define-key web-mode-map (kbd "C-c b") 'web-beautify-html))

(eval-after-load 'css-mode
  '(define-key css-mode-map (kbd "C-c b") 'web-beautify-css))

;;json-snatcher
;(require 'json-snatcher)
;(defun js-mode-bindings ()
;   "Sets a hotkey for using the json-snatcher plugin"
;     (when (string-match  "\\.json$" (buffer-name))
;           (local-set-key (kbd "C-c C-g") 'jsons-print-path)))
;(add-hook 'js-mode-hook 'js-mode-bindings)
;(add-hook 'js2-mode-hook 'js-mode-bindings)

;;json mode
;(require 'json-mode)

;Ido-mode
;windmove
;ace-jump-mode
;emmet-mode
;magit
;prodigy
;yasnippet
;mutiple-cursor
;visual-regexp
;fiplr
;flycheck
;jedi
;helm

