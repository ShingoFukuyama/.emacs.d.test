
(setq user-emacs-directory "~/.emacs.d.test/")
(defvar my-emacs-dir (expand-file-name user-emacs-directory))
(defvar my-elisp-dir (concat my-emacs-dir "elisp/"))
;; ----------------------------------------------------------------------
;; melpa - package manager
(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list 'package-archives
               '("melpa" . "http://melpa.milkbox.net/packages/") t)
  (package-initialize))
;; ----------------------------------------------------------------------
;; system judgement
(cond ((string-match "apple-darwin" system-configuration)
       (setq os-type 'mac))
      ((string-match "linux" system-configuration)
       (setq os-type 'linux))
      ((string-match "freebsd" system-configuration)
       (setq os-type 'bsd))
      ((string-match "mingw" system-configuration)
       (setq os-type 'win)))
(defun mac? () (eq os-type 'mac))
(defun linux? () (eq os-type 'linux))
(defun bsd? () (eq os-type 'freebsd))
(defun win? () (eq os-type 'win))
;; ----------------------------------------------------------------------
;; Japanese
(when (or (mac?) (linux?))
  ;;(set-language-environment "Japanese")
  (set-language-environment 'utf-8)
  (prefer-coding-system                          'utf-8)
  (set-terminal-coding-system                    'utf-8)
  (set-keyboard-coding-system                    'utf-8)
  (set-default-coding-systems                    'utf-8)
  (setq buffer-file-coding-system                'utf-8)
  (setq file-name-coding-system                  'utf-8)
  (setq locale-coding-system                     'utf-8-unix)
  (set-clipboard-coding-system                   'utf-8))
(when (mac?) ;; (eq system-type 'darwin)
  (when (require 'ucs-normalize nil t)
    (set-file-name-coding-system 'utf-8-hfs)
    (setq locale-coding-system 'utf-8-hfs)))
(when (linux?)
  (autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
  (add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
  (setq x-select-enable-clipboard t)
  (when (require 'mozc nil t)
    (set-language-environment "Japanese")
    (setq default-input-method "japanese-mozc")
    (global-set-key (kbd "s-SPC") 'mozc-mode)
    (setq mozc-candidate-style 'echo-area) ;; overlay or echo-area
    ))
(when (win?) ;; (eq window-system 'w32)
   (set-keyboard-coding-system 'cp932)
   (prefer-coding-system 'utf-8-dos)
   (set-file-name-coding-system 'cp932)
   (setq default-process-coding-system '(cp932 . cp932))
   ;; 機種依存文字
   (require 'cp5022x)
   (define-coding-system-alias 'euc-jp 'cp51932)
   ;; decode-translation-table の設定
   (coding-system-put 'euc-jp :decode-translation-table
              (get 'japanese-ucs-jis-to-cp932-map 'translation-table))
   (coding-system-put 'iso-2022-jp :decode-translation-table
              (get 'japanese-ucs-jis-to-cp932-map 'translation-table))
   (coding-system-put 'utf-8 :decode-translation-table
              (get 'japanese-ucs-jis-to-cp932-map 'translation-table))
   ;; encode-translation-table の設定
   (coding-system-put 'euc-jp :encode-translation-table
              (get 'japanese-ucs-cp932-to-jis-map 'translation-table))
   (coding-system-put 'iso-2022-jp :encode-translation-table
              (get 'japanese-ucs-cp932-to-jis-map 'translation-table))
   (coding-system-put 'cp932 :encode-translation-table
              (get 'japanese-ucs-jis-to-cp932-map 'translation-table))
   (coding-system-put 'utf-8 :encode-translation-table
              (get 'japanese-ucs-jis-to-cp932-map 'translation-table))
   ;; charset と coding-system の優先度設定
   (set-charset-priority 'ascii 'japanese-jisx0208 'latin-jisx0201
             'katakana-jisx0201 'iso-8859-1 'cp1252 'unicode)
   (set-coding-system-priority 'utf-8 'euc-jp 'iso-2022-jp 'cp932)
   ;; PuTTY 用の terminal-coding-system の設定
   (apply 'define-coding-system 'utf-8-for-putty
      "UTF-8 (translate jis to cp932)"
      :encode-translation-table
      (get 'japanese-ucs-jis-to-cp932-map 'translation-table)
      (coding-system-plist 'utf-8))
   (set-terminal-coding-system 'utf-8-for-putty))
;; ----------------------------------------------------------------------
;; font
(cond ((mac?)
       (set-face-attribute 'default nil :family "Ricty Diminished" :height 135)
       (set-fontset-font nil 'japanese-jisx0208
                         (font-spec :family "Ricty Diminished")))
      ((linux?)
       (set-face-attribute 'default nil :family "Ricty Diminished" :height 150)
       (set-fontset-font nil 'japanese-jisx0208
                         (font-spec :family "Ricty Diminished" :height 150)))
      ((win?)
       (set-face-attribute 'default nil :family "Ricty Diminished"
                           :height 150)
       (set-fontset-font nil 'japanese-jisx0208
                         (font-spec :family "Ricty Diminished" :height 150))))
;; ----------------------------------------------------------------------
;; shell command path
(dolist (dir (list
              "/sbin"
              "/bin"
              "/usr/sbin"
              "/usr/bin"
              "/usr/local/bin"
              "/usr/texbin"
              (expand-file-name "~/.nvm/v0.10.24/bin")
              (expand-file-name "~/.zsh.d")
              (expand-file-name "~/.emacs.d/lib/bin")
              "/opt/local/bin" ;;csslint
              (expand-file-name "~/node_modules/.bin")
              ;; windows
              ;; (expand-file-name "~/../app/cygwin/local/bin")
              ;; ubuntu
              ;; (expand-file-name "~/.emacs.d/lib/rbenv/versions/1.9.2-p320/bin")
              (expand-file-name "~/.emacs.d/lib/rbenv/bin")
              (expand-file-name "~/.emacs.d/lib/rbenv/shims")
              ;;; mac
              (expand-file-name "~/.rbenv/shims")
              (expand-file-name "~/.rbenv/versions/1.9.2-p320/bin")
              ))
  (when (and (file-exists-p dir) (not (member dir exec-path)))
    (setenv "PATH" (concat dir ":" (getenv "PATH")))
    (setq exec-path (append (list dir) exec-path))))
;;; MANPATH
(setenv "MANPATH" (concat "/usr/local/man:"
                          "/usr/share/man:"
                          (getenv "MANPATH")))
;; ----------------------------------------------------------------------
;; macro
(defmacro gset (&rest $body)
  (declare (indent 3))
  `(let (($pairs (list ,@$body)) $k $f)
     (while $pairs
       (setq $k (car $pairs))
       (setq $f (cadr $pairs))
       (unless (stringp $k)
         (error (format "%s is not string" $k)))
       (unless (functionp $f)
         (error (format "%s is not function" $f)))
       (global-set-key (read-kbd-macro $k) $f)
       (setq $pairs (nthcdr 2 $pairs)))))
(defmacro lset (&rest $body)
  (declare (indent 3))
  `(let (($pairs (list ,@$body)) $k $f)
     (while $pairs
       (setq $k (car $pairs))
       (setq $f (cadr $pairs))
       (unless (stringp $k)
         (error (format "%s is not string" $k)))
       (unless (functionp $f)
         (error (format "%s is not function" $f)))
       (local-set-key (read-kbd-macro $k) $f)
       (setq $pairs (nthcdr 2 $pairs)))))
(defmacro ffopen (&rest $body)
  (declare (indent 1))
  `(let (($file (concat ,@$body)))
     (if (file-exists-p $file)
         (find-file $file)
       (message (format "Not exists: %s" $file)))))
;; ----------------------------------------------------------------------
;; frame size
(cond
 ((equal user-full-name "FukuyamaShingo")
  (setq initial-frame-alist
        (append (list
               ;;; 15' MacBookPro
                 '(width . 180)
                 '(height . 48)
                 '(top . 10)
                 '(left . 62)))))
 ((equal user-full-name "Shingo Fukuyama")
  (setq initial-frame-alist
        (append (list
               ;;; 15' MacBookPro
                 '(width . 162)
                 '(height . 40)
                 '(top . 10)
                 '(left . 62)))))
 ((or (linux?) (mac?))
  (setq initial-frame-alist
        (append (list
                 '(width . 178)
                 '(height . 50)
                 '(top . 10)
                 '(left . 52)
                 )
                initial-frame-alist)))
 ((win?)
  (setq initial-frame-alist
        (append (list
                 '(width . 140)
                 '(height . 38)
                 '(top . 0)
                 '(left . 0))
                initial-frame-alist))))
(setq default-frame-alist initial-frame-alist)
;; ----------------------------------------------------------------------
(global-set-key (kbd "C-h") 'delete-backward-char)
(define-key isearch-mode-map (kbd "C-h") 'isearch-del-char)
(delete-selection-mode t)
(global-unset-key (kbd "C-q"))
(global-unset-key (kbd "C-z"))
(global-set-key (kbd "C-c C-q") 'quoted-insert)
(global-set-key (kbd "C-q C-k") 'kill-this-buffer)
(global-set-key (kbd "C-c h")   'help-for-help)
(global-set-key (kbd "C-q C-a") 'align-regexp)

;;; beep sound
(setq ring-bell-function 'ignore)

;; KeyRemap4Macbook
(global-unset-key (kbd "RET"))
(setq ns-function-modifier 'hyper)
(setq ns-right-control-modifier 'meta)

;; prompt
(defalias 'yes-or-no-p 'y-or-n-p)
(define-key query-replace-map [return] 'act)

;; indent
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

;; file
(setq ns-pop-up-frames nil) ;; file open in current window
(add-hook 'before-save-hook 'delete-trailing-whitespace)
;;; add excutable permission if a file 1st line begins with "#!"
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;; parentheses
(show-paren-mode 1)
(setq show-paren-style 'expression)
(set-face-background 'show-paren-match-face "#0066ff")
(set-face-foreground 'show-paren-match-face "#ffff00")
(set-face-underline  'show-paren-match-face t)
;; ----------------------------------------------------------------------
;; dired
(require 'wdired)
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)
(setq wdired-allow-to-change-permissions t)
(global-set-key (kbd "C-x C-j") 'dired-jump)
;; auto fill copy/move destination acoding to adjacent buffer
(setq dired-dwim-target t)
;; ----------------------------------------------------------------------
;; window
(defun other-window-or-split ()
  (interactive)
  (when (one-window-p)
    (split-window-horizontally))
  (other-window 1))
(global-set-key (kbd "C-t") 'other-window-or-split)
(add-hook 'dired-mode-hook
          (lambda ()
            (define-key dired-mode-map (kbd "C-t") 'other-window-or-split)))
(add-hook 'term-mode-hook
          (lambda ()
            (define-key term-raw-map (kbd "C-t") 'other-window-or-split)))
;; ----------------------------------------------------------------------
;; initialize
(other-window-or-split)
(ffopen (concat my-emacs-dir "init.el"))
(other-window 1)
(ffopen (concat my-emacs-dir "init.el"))
(global-set-key (kbd "s-p") 'package-list-packages)
;; ----------------------------------------------------------------------
(when (require 'helm-swoop nil t)
  (global-set-key (kbd "C-;")      'helm-for-files)
  (global-set-key (kbd "M-y")      'helm-show-kill-ring)
  (global-set-key (kbd "C-x r l")  'helm-bookmarks)
  (global-set-key (kbd "C-q C-f")  'helm-apropos)
  (global-set-key (kbd "C-z h")    'helm-resume)
  (global-set-key (kbd "M-x")      'helm-M-x)
  (helm-mode 1)
  (setq helm-ff-auto-update-initial-value nil)
  (define-key helm-map (kbd "C-h") 'delete-backward-char)
  (define-key helm-read-file-map (kbd "TAB")
    'helm-execute-persistent-action)
  (when (require 'helm-swoop nil t)
    (global-set-key (kbd "M-i")     'helm-swoop)
    (global-set-key (kbd "M-I")     'helm-swoop-back-to-last-point)
    (global-set-key (kbd "C-c M-i") 'helm-multi-swoop)
    (global-set-key (kbd "C-x M-i") 'helm-multi-swoop-all)
    (setq helm-multi-swoop-edit-save t)
    (setq helm-swoop-split-with-multiple-windows nil)
    (setq helm-swoop-split-direction 'split-window-vertically)
    ))

(when (require 'open-junk-file nil t)
  (setq open-junk-file-directory (concat
                                  my-emacs-dir "junk/%Y%m%d-%H%M%S."))
  (global-set-key (kbd "C-x C-z") 'open-junk-file))
