;; GAP Programming mode for automatic indentation of GAP code.
;;
;; Michael Smith                        smith@pell.anu.edu.au
;; Australian National University
;; February 1993
;;
;;! version 1.96, 23:10 Thu 11 May 1995
;;!
;;
;;
;; Major mode for writing Gap programs.
;; Provides automatic indentation of Gap code.
;;
;; Installation:
;;   Copy this file to somewhere in your load path, then put the
;;   following lines in your .emacs file:
;;
;;      (autoload 'gap-mode "gap-mode" "Gap editing mode" t)
;;      (setq auto-mode-alist (apply 'list
;;                                   '("\\.g$" . gap-mode)
;;                                   '("\\.gap$" . gap-mode)
;;                                   auto-mode-alist))
;;
;; Then visiting any file ending in ".g" or ".gap" will automatically put
;; you in Gap-mode.  Alternatively, to enter gap mode at anytime, just type
;;    M-x gap-mode
;;
;; While in gap-mode, type "C-h m" for help on its features.
;;
;;! ----------------------------------------------------------------------
;;! v1.96 -
;;! * Added a flag to choose whether the complete command (ESC-tab) simply
;;!   calls dynamic abbreviation (dabbrev-expand), the default, or tries
;;!   to complete the word by asking a running gap process.
;;! v1.95 -
;;! * Fixed bug in 'gap-insert-local-variables. It was only picking up
;;!   variables that were the first on the line - a big problem.
;;!   Finally fixed the treatment of local function definitions. It will
;;!   now skip over locally defined functions when compiling the local
;;!   variable list.
;;! v1.92 -
;;! * Defined my own "memberequal" function for checking strings in lists.
;;! v1.90 -
;;! * Fixed a bug in gap-insert-local-variables (stray "," appearing).
;;! * Added variables gap-local-statement-format and
;;!   gap-local-statement-margin for controlling format of local
;;!   variable statement inserted. It now wraps the line correctly.
;;! v1.85 -
;;! * Added variables gap-insert-debug-name, gap-insert-debug-string to
;;!   allow customization of debugging/print statements inserted by function
;;!   gap-insert-debug-print.
;;! v1.80 -
;;! * New function gap-insert-local-variables for inserting a local variable
;;!   statement for the current function at the point.
;;! v1.70 -
;;! * New function gap-insert-debug-print for inserting Inform(... lines.
;;! v1.60 -
;;! * Fixed the add-local-variable function so that it skips over local
;;!   statements of functions defined within the current function.
;;! v1.55 -
;;! * Added a regular expression for gin-mode, and changed the fill region
;;!   function to check if gin-mode is on, if so and in a comment, do
;;!   fill-paragraph instead of indent region. Does this make sense?
;;! v1.51 -
;;! * Fixed silly error due to copying a magma-mode function across.
;;! v1.50 -
;;! * Fixed the function that leaps across if..else..fi and similar stmts.
;;! v1.40 -
;;! * Added new function 'gap-add-local-variable.
;;! v1.30 -
;;! * changed code to make it more compatible with outline-minor-mode.
;;!   Many changes to regular expressions, adding "\C-m" whenever "\n"
;;!   occurs, and modifiying many beginning-of-line etc functions.
;;! v1.25 -
;;! * eliminated bug introduced in last modification.
;;! v1.20 -
;;! * Made the special continued line handling more versatile.
;;! v1.10 -
;;! * Cleaned up code immensely. Should be much easier to understand.
;;! * Fixed some bugs in special indentation checking where it could get
;;!   confused with the contents of gap strings (eg a ":=" in a string).
;;! v1.01 -
;;! * Just changed some defaults.
;;! v1.00 -
;;! * First release version.

;;! Autoload functions from gap-process.
(autoload 'gap-help "gap-process" nil t)
(autoload 'gap-complete "gap-process" nil t)


;;! Fix member function?!
(defun memberequal (x y)
  "Like memq, but uses `equal' for comparison.
This is a subr in Emacs 19."
  (while (and y (not (equal x (car y))))
    (setq y (cdr y)))
  y)


(defvar gap-indent-brackets t
  "* Whether to check back for unclosed brackets in determining
indentation level. This is good for formatting lists and matrices.")

(defvar gap-bracket-threshold 8
  "* If indentation due to bracketing will indent more than this value,
use this value instead.  nil is equivalent to infinity.")

(defvar gap-indent-step 4
  "* Amount of extra indentation for each level of grouping in Gap code.")

(defvar gap-indent-step-continued 2
  "* Amount of extra indentation to add for normal continued lines.")

(defvar gap-indent-comments t
  "* Variable controlling how the indent command works on comments.  A comment
will be indented to the next tab-stop if gap-indent-comments is:
  0    and the cursor is on the # character
  1    and the cursor is 1 character to the right of the # character
  t    and the cursor is anywhere to the right of the # character
If nil then use calculated indentation level only.")

(defvar gap-indent-comments-flushleft nil
  "* If t then indent comments based on gap-indent-comments regardless
of whether the comment is flush-left or not.  Set this to nil to treat
flush-left comments as special---i.e. not to be indented by pressing TAB.")

(defvar gap-auto-indent-comments t
  "* Controls whether the region indentation commands will change
indentation of comment lines.")

(defvar gap-pre-return-indent t
  "* If t, then indent the line before breaking to next line on RET keypress.")

(defvar gap-post-return-indent t
  "* If t, then autoindent after a RET keypress.")

(defvar gin-retain-indent-re "[ \t]*#+[ \t]*\\|[ \t]+"
  "* regular expression for gin-mode's filling command to allow it to
fill GAP comments")

(defvar gap-fill-if-gin nil
  "* Set to t to intelligently fill paragraphs if point is in comment and
indent region command is run.")

(defvar gap-tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44
			      48 52 56 60 64 68 72 74 78)
  "* Gap-mode tab-stop-list.  Note this is effectively only used in the
indentation of comments---all gap code indentation depends on the
variable gap-indent-step.")

(defvar gap-mode-hook nil
  "* Function to be called after setting gap-mode for buffer.")

(defvar gap-local-statement-format '(3 2)
  "Two element list determining format of local var statement inserted.
First element is number of spaces after \"local\", the second is number
of spaces after each comma.")

(defvar gap-local-statement-margin (if fill-column fill-column 75)
  "Column at which to wrap local variable statement.")

(defvar gap-insert-debug-name "Info"
  "* Function name to use when inserting a debugging/print statement.")

(defvar gap-insert-debug-string "#I  %s: "
  "* String to use when inserting a debugging/print statement.
A %s is substituted with the name of the current function.")

(defvar gap-use-dabbrev t
  "* If true then the complete command will simply call dabbrev instead
of communicating with a running gap process.")


;;
;;
;; Non-user variables and function definitions.

(defvar gap-debug-indent nil
  "* Show the facts that gap-indent bases its decision on.")

(defvar gap-syntax-table nil
  "Syntax table used while in gap mode.")

(if gap-syntax-table ()
  (setq gap-syntax-table (make-syntax-table))
  (modify-syntax-entry ?. "w" gap-syntax-table) ;; . is part of identifiers
  (modify-syntax-entry ?# "<" gap-syntax-table)
  (modify-syntax-entry ?\n ">" gap-syntax-table)
  (modify-syntax-entry ?\C-m ">" gap-syntax-table) ;; cope with outline mode
  )

(defvar gap-mode-map nil)
(if gap-mode-map
    nil
  (setq gap-mode-map (make-sparse-keymap))
  (define-key gap-mode-map "\C-c%" 'gap-match-group)
  (define-key gap-mode-map "\C-m" 'gap-newline-command)
  (define-key gap-mode-map "\t" 'gap-indent-command)
  (define-key gap-mode-map "\eq" 'gap-format-region)
  (define-key gap-mode-map "\e\C-q" 'gap-format-buffer)
  (define-key gap-mode-map "\e\t" 'gap-completion)
  (define-key gap-mode-map "\e?" 'gap-help)
  (define-key gap-mode-map "\C-c#" 'gap-comment-region)
  (define-key gap-mode-map "\C-ca" 'gap-add-local-variable)
  (define-key gap-mode-map "\C-cd" 'gap-insert-debug-print)
  (define-key gap-mode-map "\C-cl" 'gap-insert-local-variables)
  )

(defun gap-mode ()
  "Major mode for writing Gap programs.  The following keys are defined:

 \\[gap-indent-command]      to intelligently indent current line.
 \\[gap-newline-command]      newline with indentation of current and new line.
 \\[gap-format-region]    to indent each line of the region.
 \\[gap-format-buffer]  to indent each line of the whole buffer.
 \\[gap-match-group]    to find matching beginning or end of grouping at point.
          See the documentation for command gap-match-group.
 \\[gap-comment-region]   to comment out region: with arg to uncomment region.
 \\[gap-add-local-variable]   to add identifier to local variables of function.
 \\[gap-insert-local-variables]   to insert a local variables statement for the current function.

If a GAP process is running in buffer *gap*, then also:

 \\[gap-completion]  complete identifier at point
 \\[gap-help]  get GAP help on (any) topic

Variables: (with default given)

  gap-indent-step = (default 4)
        the amount of indentation to add at each level of a group

  gap-indent-step-continued =  (default 2)
        the extra indentation for continued lines that aren't special
        in some way.

See also the documentation for the variables:
  gap-pre-return-indent  
  gap-post-return-indent 
  gap-indent-comments                
  gap-indent-comments-flushleft      
  gap-auto-indent-comments           
  gap-indent-brackets
  gap-bracket-threshold
  gap-tab-stop-list      
  gap-mode-hook

and documentation for the functions:
  gap-percent-command

The indentation style is demonstrated by the following example, assuming
default gap indentation variables:

test := function (x,y)
    # this is a test
    local n,
          m,
          x;
    if true then
        Print( \"if true then \",
               \"nothing\");
    fi;
    x := [ [ 1, 2, 3 ],
           [ 5, 6, 8 ],
           [ 9, 8, 7 ] ];
    y := 1 + 2 + 3 +
         4 + 5 + 6;
    z := Filtered( List( origlist,
               x -> f( x + x^2 + x^3 + x^4 + x^5,
                       x^-1, x^-2, x^-3)),
               IsMat);
end;"

  (interactive)
  (setq major-mode 'gap-mode)
  (setq mode-name "Gap")
  (use-local-map gap-mode-map)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'gap-indent-line)
  (set-syntax-table gap-syntax-table)
  (setq indent-tabs-mode nil)
  (setq tab-stop-list gap-tab-stop-list)
  (run-hooks 'gap-mode-hook))

(defun gap-comment-region (arg p1 p2)
  (interactive "p\nr")
  (save-excursion
    (save-restriction
      (narrow-to-region (beg-of-line-from-point p1)
			(end-of-line-from-point p2))
      (goto-char (point-min))
      (let ((first t))
	(while (or first
		   (re-search-forward "[\n\C-m]" nil t))
	  (setq first nil)
	  (cond ((= arg 1)
		 (insert "#"))
		((and (> arg 1)
		      (looking-at "#"))
		 (delete-char 1))))))))

(defun gap-newline-command ()
  (interactive)
  (open-line 1)
  (if gap-pre-return-indent
      (gap-indent-line))
  (forward-char 1)
  (if gap-post-return-indent
      (progn
	(gap-indent-line)
	(back-to-indentation))))

(defun gap-indent-line ()
  "Gap intelligent indentation of code"
  (interactive)
  (save-excursion
    (back-to-indentation)
    (let ((cur (current-column))
	  (ind (gap-calculate-indent)))
      (if (= cur ind)
	  nil
	(indent-to-left-margin)
	(indent-to ind))))
  (if (= (current-column) 0)
      (back-to-indentation)))

(defun gap-indent-command (col)
  "Smart Gap mode indent command.  Behaviour depends on gap-mode variables.
If prefix arg, then just indent this line to column given by argument.
If line is a comment starting in column 1 then do nothing.
If point is immediately following a comment character (#) then call
tab-to-tab-stop, which moves comment up to four character right (default).
Otherwise indent the line intelligently by calling gap-indent-line"
    
  (interactive "P")
  (if col
      (progn
	(back-to-indentation)
	(indent-to col))
    (if (and (not gap-indent-comments-flushleft)
	     (save-excursion
	       (beginning-of-line)
	       (looking-at "#")))
	nil
      (if (or (and (eq gap-indent-comments t)
		   (gap-point-in-comment))
	      (and (numberp gap-indent-comments)
		   (= (char-after (- (point) gap-indent-comments)) ?#)))
	  (progn
	    (save-excursion
	      (beginning-of-line)
	      (while (not (gap-point-in-comment))
		(re-search-forward "#"))
	      (forward-char -1)
	      (to-tab-stop)
	      (message (format "column %d" (current-column)))
	      (forward-char 1)))
	(gap-indent-line)))))


(defun gap-format-region ()
  (interactive)
  ;; Make it compatible with gin-mode, in the sense that if gap-fill-if-gin
  ;; is true, and buffer is in gin-mode, and point is in comment, then do
  ;; fill paragraph instead of indenting region.
  (if (and gap-fill-if-gin
           (boundp 'gin-mode)
	   gin-mode 
	   (gap-point-in-comment))
      (fill-paragraph nil)
    (let (ret p)
      (if (> (point) (mark))
	  (exchange-point-and-mark))
      (setq p (point))
      (gap-indent-line)
      (while (re-search-forward "[\n\C-m]" (end-of-line-from-point (mark)) t)
	(if (gap-looking-at "^[ \t]*[\n\C-m]")
	    (indent-to-left-margin)
	  (if (and (not gap-auto-indent-comments)
		   (gap-looking-at "^[ \t]*#"))
	      nil
	    (gap-indent-line))))
      (goto-char p)
      (exchange-point-and-mark))))



(defun gap-format-buffer ()
  (interactive)
  (set-mark (point-max))
  (goto-char (point-min))
  (gap-format-region))


(defun gap-insert-local-variables () 
"Insert a local variable statement for the current function.  

The local statement is inserted before the line the cursor is on.  This
function assumes that a variable is local if occurs on the left-hand side
of an assignment statement or occurs as the index variable of a do loop.
You may have to trim globals from the list if you assign values to them.

This function will skip over any embedded local function declarations, and
may be invoked within a local function definition to generate a local
statement for that function.
"
  ;; Not very efficient, but it seems to work

  (interactive)
  (let (p1 p2
           (formal nil)
           (names nil)
           name)
    (save-excursion

      (if (not (gap-find-matching "\\<function\\>" "\\<end\\>" nil t t))
          (error "no end of function!"))
      (setq p2 (point))
      (if (not (gap-find-matching "\\<function\\>" "\\<end\\>" nil -1 t))
          (error "no beginning of function"))
      (if (not (looking-at "function *("))
          (error "bad beginning of function"))
      (goto-char (match-end 0))
      (while (looking-at " *\\([a-z][a-z0-9_]*\\),?")
        (setq formal (append formal 
                             (list (buffer-substring
                                    (match-beginning 1) (match-end 1)))))
        (goto-char (match-end 0)))
      (while (gap-searcher 're-search-forward 
                           (concat 
                            "\\(" "\\(^\\|;\\) *\\([a-z][a-z0-9_]*\\) *:= *"
                            "\\|" "\\(^\\|;\\) *for +\\([a-z][a-z0-9_]*\\)"
                                  " +in\\>" "\\)")
                           p2 t '(match-beginning 0))
        (cond ((looking-at "\\(^\\|;\\) *\\([a-z][a-z0-9_]*\\) *:= *")
               (setq name (buffer-substring (match-beginning 2) (match-end 2)))
               (goto-char (match-end 0))
               (if (looking-at "function *(")
                   (progn
                     (goto-char (match-end 0))
                     (if (not (gap-find-matching "\\<function\\>" 
                                                 "\\<end\\>" nil t t))
                         (error "No local function end?!")))))
              ((looking-at "\\(^\\|;\\) *for +\\([a-z][a-z0-9_]*\\) +in\\>")
               (setq name (buffer-substring (match-beginning 2) (match-end 2)))
               (goto-char (match-end 0)))
              (t (error "gap-insert-local-variables incorrect code!")))
        (if (not (memberequal name names))
            (setq names (append names (list name))))))
    (beginning-of-line)
    (let (lnames)
      (while (car names)
        (if (memberequal (car names) formal)
            (setq names (cdr names))
          (setq lnames (append lnames (list (car names))))
          (setq names (cdr names))))
      (if (not lnames)
          (error "No local variables!")
        (insert "local")
        (insert-char ?  (nth 0 gap-local-statement-format))
        (gap-indent-line)
        (while (car lnames)
          (if (< (+ (current-column) (length (car lnames)))
                 gap-local-statement-margin)
              (insert (car lnames))
            (insert "\n" (car lnames))
            (gap-indent-line))
          (setq lnames (cdr lnames))
          (if lnames
              (progn
                (insert ",")
                (insert-char ?  (nth 1 gap-local-statement-format)))))
        (insert ";\n")))))


(defun gap-add-local-variable (ident)
  "Add a new local variable to the local variable section of the current
function. Prompts for name with default the identifier at the point. If
there is no local variable statement yet, signals error."
  (interactive
   (let ((enable-recursive-minibuffers t)
	 (try-word (gap-ident-around-point))
	 val)
     (setq val (read-string (format "Variable name (default %s): "
				    try-word)))
     (if (string-equal val "")
	 (setq val try-word))
     (list val)))
  (save-excursion
    (let ((pos (point)))
      (gap-find-matching "\\<function\\>" "\\<end\\>" nil -1)
      (goto-char (match-end 0))
      (gap-find-matching "\\<function\\>" "\\<local\\>" "\\<function\\>" t)
      (if (not (looking-at "local"))
	  (error "No local statement. Add one first.")
	(gap-search-forward-end-stmt pos 1 'end)
	(forward-char -1)
	(insert ", " ident)))))

(defun gap-insert-debug-print ()
  "Insert a print statement for debuggin purposes."
  (interactive)
  (let (name)
    (save-excursion
      (gap-find-matching "\\<function\\>" "\\<end\\>" nil -1)
      (beginning-of-line)
      (setq name (gap-ident-around-point)))
    (beginning-of-line)
    (open-line 1)
    (indent-to (gap-calculate-indent))
    (insert gap-insert-debug-name "( \""
            (format gap-insert-debug-string name) "\" );")
    (backward-char 3)))
		 

(defun gap-completion (&optional full)
  "Try to complete word at point. Will simply call dynamic abbreviation command
if gap-use-dabbrev is non-nil. Otherwise contact a running gap process to
get a gap completion of the word."
  (interactive "*")
  (if gap-use-dabbrev
      (dabbrev-expand full)
    (gap-complete full) ;; defined in gap-process.el
    ))


;;! Now the indentation functions and variables
;;

(setq gap-end-of-statement
      (concat "\\(;\\|\\<then\\>\\|\\<else\\>\\|\\<do\\>\\|"
	      "\\<repeat\\>\\|\\<function\\>.*(.*)\\)"))

(setq gap-increment-indentation-regexp (concat "^[ \t]*\\("
					       "if\\>"
					       "\\|else\\>"
					       "\\|elif\\>"
					       "\\|for\\>"
					       "\\|while\\>"
					       "\\|repeat\\>"
					       "\\|.*\\<function\\>"
					       "\\)"))

(setq gap-decrement-indentation-regexp (concat "^[ \t]*\\("
					       "fi\\>"
					       "\\|od\\>"
					       "\\|else\\>"
					       "\\|elif\\>"
					       "\\|until\\>"
					       "\\|end\\>"
					       "\\)"))


(defvar gap-continued-special-list
      (list
       ;; '( REGEXP  N  OFFSET  TERMINATE)
       '("#!#" nil 0 t)
       '("\\<local\\>[ \t\n]*\\([^ \t\n]\\)" 1 0 nil)
       '("\\<return\\>[ \t\n]*\\([^ \t\n]\\)" 1 0 t)
       ;;'(":=[ \t\n]*function[ \t\n]*(.*)" nil 4 t)
       '(":=[ \t\n]*\\([^ \t\n]\\)" 1 0 nil)
       '("\\<if\\>[ \t\n]*\\([^ \t\n]\\)" 1 0 nil)
       '("\\<until[ \t\n]*\\([^ \t\n]\\)" 1 0 nil))
      "
Determines special continued lines and indentation for them.
For each element of this list: search forward (from start of line initially
and from last match otherwise) for REGEXP entry. If second entry is nil, jump
back to the indentation, otherwise if a number N jump to the beginning of
the Nth group of the regexp. Take current indentation and add the third
OFFSET entry).  Take the maximum of values so obtained for each element.
If TERMINATE is t, then don't check any later ones if matched.")


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

(defun gap-point-in-comment-string ()
  (save-excursion
    (let* ((p (point))
	   (line (buffer-substring (beg-of-line-from-point) p)))
      (string-match "\\([^\\\\]\"\\|#\\)"
		    (gap-strip-line-of-strings line)))))
      

(defun gap-point-in-comment ()
  (save-excursion
    (let* ((p (point))
	   (line (buffer-substring (beg-of-line-from-point) p)))
      (string-match "^[^\"]*#" (gap-strip-line-of-strings line)))))


(defun gap-strip-line-of-strings (line)
  (while (string-match "[^\\\\]\\(\"\"\\|\"[^\"]*[^\\\\]\"\\)" line)
    (setq line (concat (substring line 0 (match-beginning 1))
		       (substring line (match-end 1)))))
  line)

(defun gap-strip-line-of-brackets (line)
  "currently not used."
  (while (or (string-match "([^()]*)" line)
	     (string-match "\\[[^\\[\\]]*\\]" line)
	     (string-match "{[^{}]*}" line))
    (setq line (concat (substring line 0 (match-beginning 0))
		       (substring line (match-end 0)))))
  line)

(defun gap-strip-line-of-comments (line)
  (while (string-match "#.*[\n\C-m]" line)
    (setq line (concat (substring line 0 (match-beginning 0))
		       (substring line (match-end 0)))))
  line)
  

(defun gap-strip-strings-comments (stmt)
  (gap-strip-line-of-comments
   (gap-strip-line-of-strings stmt)))


(defun gap-skip-forward-to-token (limit ret)
  "Skip forward from point to first character that is not in a comment."
  (while (and (if (not (re-search-forward "[^ \t\n\C-m]" limit ret))
		  nil
		(goto-char (match-beginning 0))
		t)
	      (if (looking-at "#")
		  (re-search-forward "[\n\C-m]" limit ret)
		nil))))
  

(defun gap-debug-inform (base ind prev this &optional note)
  (message
   (concat (if base (format "Base:%d  " base))
	   (if ind (format "Ind:%d  " ind))
	   (if prev (format "Prev:|%s|  "
			    (if (< (length prev) 20)
				prev
			      (concat (substring prev 0 9) "..."
				      (substring prev -9)))))
	   (if this (format "This:|%s|"
			    (if (< (length this) 20)
				this
			      (concat (substring this 0 9) "..."
				      (substring this -9)))))
	   (if note (format "  (%s)" note))
	   )))



(defun end-of-line-from-point (&optional p)
  (save-excursion
    (if p (goto-char p))
    (gap-end-of-line)
    (end-of-line)
    (point)))

(defun beg-of-line-from-point (&optional p)
  (save-excursion
    (if p (goto-char p))
    (gap-beginning-of-line)
    (point)))

(defun gap-beginning-of-line ()
  (if (re-search-backward "[\n\C-m]" nil 1)
      (forward-char 1)))

(defun gap-end-of-line ()
  (if (re-search-forward "[\n\C-m]" nil 1)
      (forward-char -1)))

(defun lines-indentation (&optional p)
  (save-excursion
    (if p (goto-char p))
    (+ (- (progn (gap-beginning-of-line) (point)))
       (progn (skip-chars-forward " \t") (point)))))

(defun gap-looking-at (s)
  (save-excursion
    (if (eq (substring s 0 1) "^")
	(progn
	  (setq s (concat "[\n\C-m]" (substring s 1)))
	  (forward-char -1)))
    (looking-at s)))

(defun gap-back-to-indentation ()
  (gap-beginning-of-line)
  (skip-chars-forward " \t"))

(defun gap-current-column ()
  (- (point)
     (beg-of-line-from-point)))

(defun to-tab-stop ()
  "Version of tab-to-tab-stop that inserts before point."
  (interactive)
  (if abbrev-mode (expand-abbrev))
  (let ((tabs tab-stop-list))
    (while (and tabs (>= (current-column) (car tabs)))
      (setq tabs (cdr tabs)))
    (if tabs
	(insert-before-markers
	 (make-string (- (car tabs) (current-column)) 32))
      (insert ? ))))


;; Note- for the purposes of indentation calculations, the following
;; statement segments are considered to be fully contained statements:
;;    ... function (...)
;;    for ... do
;;    while ... do
;;    od;
;;    repeat
;;    if ... then
;;    else
;;    elif .. then
;;    fi; 


;; Gap group beginning-end matching

(defun gap-match-group ()
  "Gap find matching delimiter function. If point is on a character with
bracket syntax, then use built in lisp function forward-list to find
matching bracket. Otherwise, check to see if point is on the first character
of 'do', 'od', 'if', 'elif', 'else', 'fi', 'function', 'end'. If it is,
jump to the matching delimiter."
  (interactive)
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1) t)
	((looking-at "\\s\)") (forward-char 1) (backward-list 1) t)
	((not (gap-point-in-comment-string))
	 (cond ((looking-at "\\<if\\>")
		(goto-char (match-end 0))
		(gap-find-matching "\\<if\\>" "\\<fi\\>"
				   "\\<\\(else\\|elif\\)\\>" t))
	       ((looking-at "\\<fi\\>")
		(gap-find-matching "\\<if\\>" "\\<fi\\>" nil -1))
	       ((looking-at "\\<\\(else\\|elif\\)\\>")
		(goto-char (match-end 0))
		(gap-find-matching "\\<if\\>" "\\<fi\\>"
				   "\\<\\(else\\|elif\\)\\>" t))
	       ((looking-at "\\<do\\>")
		(goto-char (match-end 0))
		(gap-find-matching "\\<do\\>" "\\<od\\>" nil t))
	       ((looking-at "\\<od\\>")
		(gap-find-matching "\\<do\\>" "\\<od\\>" nil -1))
	       ((looking-at "\\<function\\>")
		(goto-char (match-end 0))
		(gap-find-matching "\\<function\\>" "\\<end\\>" nil t))
	       ((looking-at "\\<end\\>")
		(gap-find-matching "\\<function\\>" "\\<end\\>" nil -1))
	       (t nil)))
	(t nil)))

(defun gap-percent-command (arg)
  "* This Gap-mode function is for people who are used to the % command in vi.
Binding this function to the '%' key in Gap-mode will: match whatever beginning
or end of a group that the point is on, otherwise just insert a % symbol."
  (interactive "p")
  (if (not (gap-match-group))
      (self-insert-command (or arg 1))))

(defun gap-find-matching (breg ereg &optional also forw noerr)
  ;; if regexp also, then also stop on it if found
  ;; if forw it t, then match forward instead of trying to figure it out
  ;; if forw is -1, then match backward instead of figuring it out
  ;; if noerr, just return nil
  (let ((p (point))
	(searcher 're-search-forward)
	(inc breg)  ;; Everytime we see this, increment counter 
	(dec ereg)  ;; Everytime we see this, decrement counter 
	(c 1)
	(d t) ;; d=t => direction forward
	(p1 (point)))
    (cond ((eq forw nil)
	   (cond ((or (looking-at breg) (and also (looking-at also)))
		  (setq p1 (match-end 0)))
		 ((looking-at ereg)
		  (setq p1 (match-beginning 0))
		  (setq searcher 're-search-backward
			inc ereg
			dec breg
			d nil))))
	  ((eq forw -1)
	   (setq p1 (point))
	   (setq searcher 're-search-backward
		 inc ereg
		 dec breg
		 d nil)))
    (goto-char p1)
    (while (and (> c 0) (apply searcher (concat "\\(" breg "\\|" ereg
						(if also "\\|") also "\\)")
			       nil t nil))
      (setq p1 (match-beginning 0))
      (if (not (gap-point-in-comment-string))
	  (save-excursion
	    (goto-char p1)
	    (if (and (= c 1) also (looking-at also))
		(setq c 0)
	      (setq c (+ c (cond ((looking-at inc) 1)
				 ((looking-at dec) -1)
				 (t 0)))))
	    (if (= c 0) (setq p (point))))))
    (if (not (= c 0))
        (if noerr
            (setq p nil)
          (error "No match!"))
      (goto-char p))
    p))
  


(defun gap-calculate-indent ()
  (save-excursion
    (gap-beginning-of-line)
    (let ((pos (point))
	  this-stmt this-beg this-end
	  last-stmt last-beg last-end
	  ind)

      ;; extract this statement
      (gap-search-back-end-stmt nil 1 'end)
      (setq last-end (point))

      (gap-skip-forward-to-token pos 1)
      (setq this-beg (point))
      (gap-search-forward-end-stmt (end-of-line-from-point pos) 1 'end)
      (setq this-end (point))
      (setq this-stmt (gap-strip-strings-comments
		       (buffer-substring this-beg this-end)))

      ;; First check if this is a continued line and handle that.
      (if (setq ind (gap-calc-continued-stmt
		     this-stmt this-beg this-end pos))
	  ind

	;; Not a continued line. Find the previous statement.
	(goto-char last-end)
	(gap-search-back-end-stmt nil 1 'beg) ; jump to beginning of
					      ; the end of last stmt
	(gap-search-back-end-stmt nil 1 'end) ; jump to end of the end of the
					      ; stmt before the last stmt
	(gap-skip-forward-to-token nil t)     ; skip forward to start of last
	(setq last-beg (point))
	(setq last-stmt (gap-strip-strings-comments
			 (buffer-substring last-beg last-end)))

	;; Now find the indentation
	(setq ind (gap-calc-new-stmt
		   this-stmt this-beg this-end
		   last-stmt last-beg last-end)))

      ;; return the indentation
      ind)))
	

(defun gap-calc-new-stmt (this-stmt this-beg this-end last-stmt
				    last-beg last-end)
  "Find indentation for new statement in gap"
  (let (base ind)
    (goto-char last-beg)
    (setq base (progn (gap-back-to-indentation) (gap-current-column))
	  ind base)

    (if (string-match gap-increment-indentation-regexp last-stmt)
	(setq ind (+ ind gap-indent-step)))
    (if (string-match gap-decrement-indentation-regexp this-stmt)
	(setq ind (- ind gap-indent-step)))
    (if gap-debug-indent
	(gap-debug-inform base ind last-stmt this-stmt))
    ind))
	

(defun gap-calc-continued-stmt (this-stmt this-beg this-end pos)
  ;; now check to see if we have a continued line or not
  (save-excursion
    (goto-char this-beg)
    (if (not (save-excursion (re-search-forward "[\n\C-m]" pos t)))
	nil
      ;; we are on a continued line. Handle it and return indentation.
      (let ((bracks (if gap-indent-brackets
			(gap-calc-brackets this-beg pos)
		      nil))
	    ind-special
	    ind)
	
	;; Right.  Now check to see if our special
	;; continued line reg-exp matches this statment
	(goto-char this-beg)

	;; If it is not a special continued line, then the indentation
	;; will be...
	(setq ind (+ (lines-indentation this-beg) 
		     gap-indent-step-continued))
	
	;; Now must check whether statement matches special indentation
	;; regular expression.
	
	(setq ind-special nil)
	(let ((special-list gap-continued-special-list))
	  (while special-list
	    (let ((regexp (nth 0 (car special-list)))
		  (match (nth 1 (car special-list)))
		  (offset (nth 2 (car special-list)))
		  (term (nth 3 (car special-list))))
	      (if (not (gap-searcher 're-search-forward			      
				     regexp
				     pos t
				     (if (numberp match)
					 '(match-beginning match))))
		  ;; No match, try next one.
		  (setq special-list (cdr special-list))
		;; Found a match! Great
		(if term
		    (setq special-list nil)
		  (setq special-list (cdr special-list)))
		(if (null match)
		    (gap-back-to-indentation))
		(setq ind-special (max (if (null ind-special) 0 ind-special)
				       (+ (gap-current-column) offset)))))))
		
	;; Now decide on the actual indentation.
	(cond ( (and bracks ind-special)
		;; both special stmt and within brackets.
		(setq ind
		      (max ind-special
			   (if gap-bracket-threshold
			       (min (car bracks)
				    (+ (max ind-special (cdr bracks))
				       gap-bracket-threshold))
			     (car bracks))))
		(if gap-debug-indent
		    (gap-debug-inform ind-special ind nil this-stmt
				      "Special & Brackets")))
	      ( bracks
		;; within brackets.
		(setq ind
		      (if gap-bracket-threshold
			  (min (car bracks)
			       (+ (cdr bracks) gap-bracket-threshold))
			(car bracks)))
		(if gap-debug-indent
		    (gap-debug-inform (cdr bracks) ind nil this-stmt
				      "Brackets")))
	      ( ind-special
		;; just on special indentation line (no bracketing)
		(setq ind ind-special)
		(if gap-debug-indent
		    (gap-debug-inform nil ind nil this-stmt
				      "Special")))
	      ( t
		;; otherwise, don't adjust standard indentation
		(if gap-debug-indent
		    (gap-debug-inform nil ind this-stmt
				      "Continued"))))
	ind))))


(defun gap-calc-brackets (this-beg pos)
  "Check to see if there is unfinished bracket list and if there is,
return a pair (ind . base) for indentation due to bracketing, and the
base indentation of the line starting the bracket grouping"
  (goto-char pos)
  (let ((brack-level -1) ind-brack base-brack)
    (while (and (< brack-level 0)
		(gap-searcher 're-search-backward
			      "\\(\\s(\\|\\s)\\)" this-beg t))
      (cond ((looking-at "\\s(")
	     (setq brack-level (1+ brack-level)))
	    ((looking-at "\\s)")
	     (setq brack-level (1- brack-level)))))
    (if (not (= brack-level 0))
	;; Not within unclosed brackets.
	nil
      ;; Yes we are within unclosed brackets.
      (setq base-brack (current-indentation))
      (forward-char 1)
      (skip-chars-forward " \t")
      (setq ind-brack (gap-current-column))
      ;; return cons of indentation level due to bracks, and the base
      (cons ind-brack base-brack))))

(defun gap-searcher (search-func object &optional bound silent move)
  "Use function SEARCH-FUNC to search for OBJECT.  Also passes BOUND for
specifying the character position bounding the search, SILENT to tell
search routines that they should not signal errors.
  The result is a search that skips matches that occur in comments or
strings in the gap code.
  If MOVE is non-nil the move to the buffer position returned by evaling
MOVE after each search. This is for moving to the beginning or end of
groups in the regexp. eg use '(match-beginning 0)."
  (let ((done nil)
	return pos)
    (while (not done)
      (if (not (apply search-func object bound silent nil))
	  (setq done t
		return nil)
	;; move to position asked
	(setq pos (if move
		      (eval move)
		    (point)))
	;; Make sure that we haven't hit a string/comment!
	(if (gap-point-in-comment-string)
	    ;; in comment/string! Not finished yet. Try again.
	    nil
	  ;; Found the position.
	  (goto-char pos)
	  (setq done t
		return t))))
    return))
  

(defun gap-search-back-end-stmt (limit ret goto)
  "This function searches backward from point for the end of a gap
statement, making sure to skip over comments and strings."
  (if (not (gap-searcher 're-search-backward ; searcher to use.
			 gap-end-of-statement ; regular expression.
			 limit		; bound for search.
			 (if ret 1 t)	; return nil if no match
					; and goto bound if RET.
			 (if (eq goto 'end)
			     '(match-end 0)
			   '(match-beginning 0))))
      ;; not found. Move to limit if so asked
      nil      
    ;; now make sure we skip over multiple semi-colons
    (while (and (not (eq goto 'end))
		(looking-at ";")
		(> (point) (point-min)))
      (forward-char -1))
    t))

(defun gap-search-forward-end-stmt (limit ret goto)
  "This function searches forward from point for the end of a gap
statement, making sure to skip over comments and strings."
  (if (not (gap-searcher 're-search-forward   ; searcher to use.
			 gap-end-of-statement ; regular expression.
			 limit		; bound for search.
			 (if ret 1 t)	; return nil if no match
					; and goto bound if RET.
			 (if (eq goto 'end)
			     '(match-end 0)
			   '(match-beginning 0))))
      ;; not found. Move to limit if so asked
      nil      
    ;; now make sure we skip over multiple semi-colons
    (while (and (not (eq goto 'end))
		(looking-at ";")
		(> (point) (point-min)))
      (forward-char -1))
    t))

			 

;;! Emacs Variables:
;; Local Variables:
;; mode:Emacs-Lisp
;; mode:outline-minor
;; Install-Name: "/usr/local/emacs-18.59/site-lisp/mjs/gap-mode.el"
;; Install-Copy: "/home/ftp/pub/gnu/elisp/gap-mode.el"
;; Install-Byte-Compile: t
;; outline-regexp:"^\\(;;!\\|(defun\\|(defmacro\\|(defvar\\|(setq\\)"
;; eval: (hide-body)
;; End:
