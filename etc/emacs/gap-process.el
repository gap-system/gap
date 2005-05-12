;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Begin update gap-process.el
;;
;; Running a GAP session in an Emacs buffer, based on comint-mode.
;;
;; Michael Smith                        smith@pell.anu.edu.au
;; Australian National University
;; February 1993
;;
;;! Changed from version 1.50,  15:44 Thu 22 Apr 1993
;;! by Gary Zablackis (4/2005)
;;
;; A modification and extension of the GAP mode of Goetz Pfeiffer.
;;
;; Uses comint-mode instead of shell-mode (which means you must have the
;; comint package installed).
;;
;; Command completion is available ("TAB"). Output to separate *Completions*
;; buffer instead of GAP session.
;;
;; Help is available at any time by pressing "?". Output to *Help* buffer.
;;
;; The comint package provides command input history (with searching),
;; resend previous line etc.
;;
;; To install, put this file somewhere in your load path, preferably byte
;; compile it, and add the following line to your .emacs:
;;
;;    (autoload 'gap "gap-process" "*Run GAP" t)
;;
;; You can also have GAP start up in a particular directory by setting
;; gap-directory; for example:
;;
;;    (setq gap-directory "~/gap")
;;
;; To run GAP, just type "M-x gap".
;;
;; To run GAP with contents of current buffer as initial input use a prefix
;; arg, "C-u M-x gap" (this is still a bit of a hack, so use with caution).
;;
;; Note that while a GAP process is running in the *gap* buffer, the commands
;; gap-complete and gap-help can be bound to keys in other buffers to issue
;; commands to the running GAP process.
;;
;;! ----------------------------------------------------------------------
;;! v1.50 -
;;! * Fixed problem of disappearing output when point not in *gap* buffer.
;;!   Also ensure that output scrolls if visible in window.
;;! v1.20 -
;;! * Allow switching to existing process buffer if it exists, also piping
;;!   current buffer into it if prefix arg.
;;! v1.12 -
;;! * Included "brk>" in prompt-regexp. How could I forget this!
;;! v1.10 -
;;! * Now gap-complete-double-cols controls formatting of completions buff.
;;! v1.08 -
;;! * Fixed gap-prompt-regexp so that a > in line would not be confused.
;;! v1.07 -
;;! * Fixed cosmetic problem with *help* output. Now instead of stripping
;;!   all the ^H and ^M from the output, leave it unchanged and tidy up
;;!   buffer after help output has finished.
;;! v1.06 -
;;! * Fixed bug in gap-ident-around-point that caused non-word characters
;;!   to end up in the extracted identifier.
;;! v1.05 - 
;;! * Added C-l to call comint-previous-similar-input, which is almost
;;!   the same as the GAP C-l previous input command. Moved recenter
;;!   to C-c C-l to make room.
(require 'comint)
(defvar gap-executable "/usr/local/algebra/bin/gap"
  "* The GAP executable.")
(defvar gap-start-options (list "-b"
    ;;"-l" "/usr/local/algebra/gap3.2/lib/"
    "-m" "2m")
  "* The list of initial GAP options.")
(defvar gap-prompt-regexp "\\(.*\\(gap\\|brk\\)>\\|^>\\) *" 
  "* Regexp used by Newline command in GAP mode to match prompt.")
(defvar gap-directory nil
  "* If this is non-nil, change to this directory before running GAP. Otherwise
will just use the default directory of the new *GAP* buffer.")
(defvar gap-process-beep nil
  "* Only beep when GAP asks if this is non-nil.")
(defvar gap-complete-double-cols t
  "* Controls final formatting of the GAP completions buffer. If t and
buffer is currently shown with more than 80 columns and not enough lines,
then make the list double columned. If not nil or t, then always make the
completions list double columnes.")
(defvar gap-process-map nil)
(if gap-process-map nil
  (setq gap-process-map (copy-keymap comint-mode-map))
  (define-key gap-process-map "\C-m" 'gap-send)
  (define-key gap-process-map "\t" 'gap-complete)
  (define-key gap-process-map "?" 'gap-help)
  (define-key gap-process-map "\C-l" 'comint-previous-similar-input)
  (define-key gap-process-map "\C-c\C-l" 'recenter)
  )
(defvar gap-send-state nil
  "Variable used by filter to trap echos and completion in GAP output")
(defvar gap-syntax-table nil
  "Syntax table used while in gap mode.")
(if gap-syntax-table ()
  (setq gap-syntax-table (make-syntax-table))
  (modify-syntax-entry ?. "w" gap-syntax-table) ;; . is part of identifiers
  (modify-syntax-entry ?# "<" gap-syntax-table) ;; # starts comment
  (modify-syntax-entry ?\n ">" gap-syntax-table) ;; newline ends comment
  )
(defvar gap-completion-ident nil
  "Stores identifier that GAP is completing")
(defvar gap-process-buffer nil
  "Points to a running gap session.")
(defvar gap-pending-input nil
  "Holds input to feed slowly to GAP when starting with buffer as input.")
(defvar gap-pending-pointer nil)
(defun gap-running-p nil
  (and gap-process-buffer
       (get-buffer-process gap-process-buffer)
       (eq (process-status (get-buffer-process gap-process-buffer))
    'run)))
(defun gap (&optional send-buffer)
  "* Start up a GAP session in a comint-mode buffer.  With prefix arg, send
the contents of the current buffer to the GAP session as initial standard
input. Switch to existing *gap* buffer if process is already running, also
sending current buffer if prefix arg."
  (interactive "P")
  (if (not (gap-running-p))
      (let (proc)
 (setq gap-pending-input (if send-buffer (buffer-string) nil))
 (setq gap-pending-pointer 0)
 (setq gap-process-buffer
       (get-start-process gap-executable nil
     (if gap-directory
         (expand-file-name gap-directory)
       nil)
     gap-start-options))
 (setq proc (get-buffer-process gap-process-buffer))
 (gap-process-mode)
 (if (not send-buffer)
     (set-process-filter proc 'gap-output-filter)
   (set-process-filter proc 'gap-startfile-filter)))
    (if send-buffer
 (let (proc)
   (setq gap-pending-input (buffer-string))
   (setq gap-pending-pointer 0)
   (setq proc (get-buffer-process gap-process-buffer))
   (set-process-filter proc 'gap-startfile-filter)
   (comint-send-string proc "\n")))
    (switch-to-buffer gap-process-buffer)))
 
(defun gap-process-mode ()
  "Major mode for interacting with Gap. Provides special support for the help
system (hit ? anytime for help on symbol under point) and completion (TAB).
Consult the help for comint-mode for a list of special comint features. Prefix
the ? by C-q to insert a ? in the buffer instead of callig help.
  ?     gap-help
  TAB   gap-complete
  C-l   comint-previous-similar-input  (C-c C-l for recenter)"
  
  (interactive)
  (comint-mode)
  (make-local-variable 'comint-prompt-regexp)
  (setq comint-prompt-regexp gap-prompt-regexp)
  (make-local-variable 'comint-eol-on-send)
  (setq comint-eol-on-send t)
  (setq major-mode 'gap-process-mode)
  (setq mode-name "Gap")
  (set-syntax-table gap-syntax-table)
  (use-local-map gap-process-map)
  (setq gap-send-state 'normal))
(defun gap-send ()
  "Send input to GAP."
  (interactive "*")
  (setq gap-send-state 'echo)
  (comint-send-input))
(defun gap-startfile-filter (proc string)
  "This function is the output filter for the GAP process while there is
still initial standard input to pipe into the process.  To avoid problems
with overflowing input buffers, this function sends the next line of input
when it thinks GAP is waiting for it (using gap-prompt-regexp)."
  (let ((cbuf (current-buffer)))
    (set-buffer (process-buffer proc))
    (goto-char (point-max))
    (insert (string-strip-chars string "\C-h\C-g\C-m"))
    (set-marker (process-mark proc) (point))
    (if (and gap-process-beep (string-match "\C-g" string))
 (beep))
    (save-excursion
      (beginning-of-line)
      (if (looking-at (concat ".*" gap-prompt-regexp "$"))
   (let ((x (string-match "\n" (substring gap-pending-input
       gap-pending-pointer))))
     (if x
  (progn
    (comint-send-string proc
          (substring gap-pending-input
       gap-pending-pointer
       (+ 1 x gap-pending-pointer)))
    (setq gap-pending-pointer (+ 1 x gap-pending-pointer)))
       (set-process-filter proc 'gap-output-filter)
       (gap-process-mode)
       (comint-send-string proc (substring gap-pending-input
        gap-pending-pointer))
       (setq gap-pending-input nil)))))
    (set-buffer cbuf)))
(defun gap-output-filter (proc string)
  "This function handles the output from a GAP process most of the time.
It depends on the variable gap-send-state to determine which of three
possible output states GAP is in: 'normal for output that should be shown,
'echo for the GAP echoing of the last command  (suppressed), and 'completing
when GAP will be trying to complete a symbol before point."
  (let ((cbuf (current-buffer)))
    (cond
     ((eq gap-send-state 'normal)
      (set-buffer (process-buffer proc))
      (scrolling-process-filter
       proc (string-strip-chars string "\C-g\C-h\C-m"))
      (set-marker (process-mark proc) (point)))
     ((eq gap-send-state 'echo)
      (set-buffer (process-buffer proc))
      (let ((x (string-match "\n" string)))
 (if x
     (progn
       (setq gap-send-state 'normal)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTE: this section is only needed for NTEmacs
;       (insert (string-strip-chars string                        ;;GEZ: NTEmacs: get back 1st line of output
;                                          "\C-g\C-h\C-m"))             ;;GEZ: NTEmacs: get back 1st line of output
;; NOTE: end NTEmacs specific code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       (insert (string-strip-chars (substring string (+ x 1))    ;;GEZ: original
                                          "\C-g\C-h\C-m"))              ;;GEZ: original
       (set-marker (process-mark proc) (point))))))
     ((eq gap-send-state 'completing)
      (let ((x (string-match "\C-g" string)))
 (if x  ;; GAP beeped on completing: now ask for all completions
     (progn
       (if gap-process-beep (beep))
       (insert (string-strip-chars string " \C-h\C-g\C-m"))
       (gap-complete t)
       (setq gap-send-state 'normal))
   (insert (string-strip-chars string " \C-h\C-g\C-m"))))))
    (set-buffer cbuf)))
(defun gap-help-filter (proc string)
  "This output filter pipes the output of a help command into a *Help* buffer.
It must handle the -- <space> page, <n> next line, <b> back, <p> back line, <q> quit -- prompts,    ;; GEZ: GAP 4.4.x
strip them and send spaces to continue                                                              ;; GEZ: GAP 4.4.x
the output until it is done."
  (let ((cbuf (current-buffer)))
    (set-buffer "*Help*")
    (setq buffer-read-only nil)                                     ;; GEZ: so we can put help info into the buffer
    (goto-char (point-max))
    (insert string)
    (beginning-of-line)
    (if (re-search-forward
         "  -- <space> page, <n> next line, <b> back, <p> back line, <q> quit --"
         nil t
        )                    ;;GEZ: Add to handle GAP 4.4.x output
        (progn
          (delete-region (match-beginning 0) (point))
          (comint-send-string proc " ")))                           ;;NOTE: tell GAP to continue with next page

    ;(if (looking-at gap-prompt-regexp)                             ;;GEZ: original
     (if (looking-at (concat gap-prompt-regexp "$"))                ;;GEZ: make sure get the end of it all
        (progn
          (delete-region (point) (point-max))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTE: this section is only needed for NTEmacs
   (goto-char (point-min))
          (while (re-search-forward
                  "gap: 'ioctl' could not turn off raw mode!\n" nil t)
            (replace-match ""))
;; NOTE: end NTEmacs specific code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          (goto-char (point-min))
   (while (re-search-forward
                  "^\\( *\^H\\)\\|\\(\C-m\\)" nil t)              ;;GEZ: get rid of ^H ^H and ^M
     (replace-match ""))
          (set-process-filter proc 'gap-output-filter)))
    (set-buffer cbuf)))

(defun gap-completions-filter (proc string)
  "This output filter pipes the list of all completions of a symbol into
a *Completions* buffer."
  (let ((cbuf (current-buffer)))
    (set-buffer "*Completions*")
    (setq buffer-read-only nil)                                     ;; GEZ: so we can put completions into the buffer
    (goto-char (point-max))
    (insert (string-strip-chars string "\C-g\C-m\C-h"))
    (beginning-of-line)
    (if (looking-at (concat gap-prompt-regexp ".*"
       gap-completion-ident
       (make-string (length gap-completion-ident)
      (string-to-char " "))))
        (progn
          (delete-region (point) (point-max))
   (let ((win (get-buffer-window (current-buffer)))
  (lines (count-lines (point-min) (point)))
  p1 rect)
     (if (not
   (and gap-complete-double-cols
        (or (and win
          (> lines (window-height win))
          (> (window-width win) 79))
     (not (eq gap-complete-double-cols t)))))
  nil
       (forward-line (- 1 (/ lines 2)))
       (beginning-of-line)
       (setq p1 (point))
       (goto-char (point-max))
       (insert (make-string (- 39 (move-to-column 39)) ? ))
       (setq rect (delete-extract-rectangle p1 (point)))
       (goto-char (point-min)) (forward-line 1)
       (insert (make-string (- 39 (move-to-column 39)) ? ))
       (insert-rectangle rect)))
   (set-process-filter proc 'gap-output-filter)))
    (set-buffer cbuf)))
(defun gap-complete (&optional full)
  "Complete the partial identifier preceeding point. With arg, send two
TABs to GAP to get a full list of the completions."
  (interactive "*")
  (let ((process (get-buffer-process gap-process-buffer)))
    (if (not (gap-running-p))
 (error "No GAP process running in buffer %s" gap-process-buffer))
    (if (not (looking-at "\\>"))
 (if (not (re-search-forward "\\>" nil t))
     (error "Complete what?")))
    (setq gap-completion-ident (gap-ident-around-point))
    (if (not full)
 (progn
   ;;  delete partial identifier from input line
   (delete-backward-char (length gap-completion-ident))
    
   ;;  ask for completion and clear input line
   (setq gap-send-state 'completing)
   (process-send-string process (concat gap-completion-ident
                                               "\t\C-x")))
      (setq gap-send-state 'normal)
      (unwind-protect
   (progn
     (with-output-to-temp-buffer "*Completions*"
       (print-help-return-message))
     (set-process-filter process 'gap-completions-filter)
     (process-send-string process (concat gap-completion-ident
       "\t\t\C-x")))))))

(defun gap-ident-around-point ()
 "Return the identifier around the point as a string."
 (save-excursion
   (let (beg)
     (if (not (looking-at "\\(\\>\\|\\w\\)"))
  ""
       (re-search-backward "\\<" nil t)
       (setq beg (point))
       (re-search-forward "\\>" nil t)
       (buffer-substring beg (point))))))
(defun gap-help (topic arg)
  "Display GAP help about TOPIC in the *Help* buffer."
  (interactive 
   (let ((enable-recursive-minibuffers t)
  (try-word (gap-ident-around-point))
  val)
     (if (string-equal try-word "gap>")
  (setq val (read-string "GAP topic: "))
       (setq val (read-string (format "GAP topic (default %s): "
          try-word)))
       (if (string-equal val "")
    (setq val try-word)))
     (list val current-prefix-arg)))
  (let ((process (get-buffer-process gap-process-buffer)))
    (if (not (gap-running-p))
 (error "No gap process running in buffer %s" gap-process-buffer))
    (unwind-protect
 (progn
   (with-output-to-temp-buffer "*Help*"
     (print-help-return-message))
          (set-process-filter process 'gap-help-filter)
   (process-send-string process (concat "?" topic "\n"))))))

(defun get-start-process (progm &optional name dir args startfile)
  "Run program PROGM in buffer *NAME* (or if NAME is nil use *PROGM*).
Optionally sets the default directory. If already running, just switch.
Has a optional list ARGS of command line arguments, and file STARTFILE
containing initial standard input to process."
  (interactive)
  (require 'comint)
  (setq name (or name (file-name-nondirectory progm)))
  (setq buffname (concat "*" name "*"))
  (cond ((not (comint-check-proc buffname))
  (let ((buff (get-buffer-create buffname)))
    (set-buffer buff)
    (switch-to-buffer buff)
    (if dir (cd dir))
    (apply 'make-comint name progm startfile args)))
 (t
  (switch-to-buffer buffname)
  (get-buffer buffname))))
(defun string-strip-chars (string strip)
  "Take STRING and remove characters in STRIP"
  (while (> (length strip) 0)
    (let ((pos 0))
      (setq pos (string-match (substring strip 0 1) string pos))
      (while (not (eq pos nil))
 (setq string (concat (substring string 0 pos) 
        (substring string (+ pos 1))))
 (setq pos (string-match (substring strip 0 1) string pos)))
      (setq strip (substring strip 1))))
  string)

;; Jim Thompson's scrolling output filter
(defun scrolling-process-filter (proc str)
  "Handle all output from the process PROC.  If the process buffer
is visible, try to keep the end on screen."
  (let ((obuf (current-buffer)))
    (set-buffer (process-buffer proc)) ;this IS needed
    (save-excursion
      (goto-char (process-mark proc))
      (insert-before-markers str))
    (set-buffer obuf)))
 
;; Local Variables:
;; mode:Emacs-Lisp
;; mode:outline-minor
;; Install-Name: "/usr/local/emacs-18.59/site-lisp/mjs/gap-process.el"
;; Install-Copy: "/usr/home/ftp/pub/gnu/elisp/gap-process.el"
;; Install-Byte-Compile: t
;; outline-regexp:"^\\(;;!\\|(def\\)"
;; eval: (hide-body)
;; End:
