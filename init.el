;;; init.el --- Emacs startup
;;; Commentary:
;;; Code:

;; basic setup first
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file)

;; reduce the frequency of garbage collection by making it happen on
;; each 100MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold (* 100 1024 1024)) ;; 100 mb
;; Allow font-lock-mode to do background parsing
(setq jit-lock-stealth-time 1
      ;; jit-lock-stealth-load 200
      jit-lock-chunk-size 1000
      jit-lock-defer-time 0.05)


;;; Install mouse wheel for scrolling
(when (require 'mwheel nil 'noerror) (mouse-wheel-mode t))
(global-set-key (kbd "<C-mouse-4>") 'text-scale-increase)
(global-set-key (kbd "<C-mouse-5>") 'text-scale-decrease)

(setq mouse-yank-at-point t)

;;; disable the bell
(setq ring-bell-function 'ignore)

;;; Turn off any startup messages
(setq inhibit-startup-message t)

;;; Turn off annoying cordump on tooltip "feature"
(setq x-gtk-use-system-tooltips nil)
(setq x-gtk-use-system-tooltips t)

;;; Insert spaces instead of tabs
(setq-default indent-tabs-mode nil)

;;; Set tab-width 4
(setq tab-width 4)

;;; Line numbers and column numbers
(column-number-mode t)
(line-number-mode t)
;; (global-linum-mode t)

;; ease on the font-locking because it's slowing down the system too much
(setq font-lock-maximum-decoration '((c++-mode . 2) (t . 1)))

(set-face-attribute 'default nil
                    :family "Inconsolata"
                    :height 110
                    :weight 'normal)

;; adjust transpose-chars to switch previous two characters
;; source: http://pragmaticemacs.com/emacs/transpose-characters/
(global-set-key (kbd "C-t")
                (lambda () (interactive)
                  (backward-char)
                  (transpose-chars 1)))

;; Make sure that files end with a newline.
(setq require-final-newline t)

;; Set timezone to UK (London)
(setenv "TZ" "Europe/London")

;; yes no alias
(defalias 'yes-or-no-p 'y-or-n-p)

(blink-cursor-mode 0)

;; If the buffer is a script, make the file executable. Otherwise, we
;; would just have to do it manually afterwards.
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;; Disable the tool bar when it's available.
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

;;;;;;;;;;;;;;
;; backup settings
;;;;;;;;;;;;;
(setq
 backup-by-copying t
 backup-directory-alist '((".*" . "~/.backups")) ; don't litter my fs tree
 auto-save-file-name-transforms '((".*" "~/.backups/" t)) ;; based on emacswiki.org/emacs/AutoSave
 delete-old-versions t
 kept-new-versions 20
 kept-old-versions 2
 version-control t) ; use versioned backups

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

;;;;;;;;;;;;;
;; highlight matching parenthesis
;;;;;;;;;;;;;
;; first, disable the delay
(setq show-paren-delay 0)
(show-paren-mode 1)

(setq package-enable-at-startup nil)
(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")))
(package-initialize)

;;bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-verbose t)


(use-package evil
  :ensure t
  :config (evil-mode))

(use-package evil-ediff)

(use-package evil-avy)

(use-package magit
  :ensure t 
  :bind (("C-c g" . magit-status)
         :magit-blame-mode
         ("<return>" . magit-show-commit))
  :init
  (progn
    (setq magit-log-arguments '("--graph" "--color" "--decorate" "-n128")
          magit-popup-use-prefix-argument 'default
          magit-fetch-arguments '("--prune")
          magit-save-repository-buffers 'dontask
          magit-branch-prefer-remote-upstream 't))
  :config
  (progn
    (defun apella/magit-remote-add-bbgh (user)
      "Add a remote named USER with the url bbgithub:USER/<current dir name>."
      (interactive (list (magit-read-string-ns "user name")))
      (let ((repo-name (file-name-nondirectory
                        (directory-file-name default-directory))))
        (magit-remote-add user (concat "bbgithub:" user "/" repo-name ".git"))))
    (magit-define-popup-action 'magit-remote-popup ?b "bbgithub" 'apella/magit-remote-add-bbgh)))
(use-package evil-magit)

;;;;;; Personalisation!

;;; coloring of variables
(add-hook 'after-init-hook 'global-color-identifiers-mode)

;;; dumb jump to definition enabling
(dumb-jump-mode)
