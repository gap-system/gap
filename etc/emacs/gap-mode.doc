
Editing GAP files and running GAP in Emacs buffers
==================================================

(Written 20 Feb 1993)

The files "gap-mode.el" and "gap-process.el" provide modes for both editing
GAP  programs in  Emacs and running a  GAP  session within an Emacs buffer.
Brief installation instructions are given at the end of this document.

Editing GAP files in Emacs
--------------------------

Opening any file ending in ".g" or ".gap" should automatically put you into
gap-mode, the  major mode for  editing of GAP  code. This mode may  also be
invoked in any buffer at any time by typing M-x gap-mode.

Once in gap-mode there are some notable changes in the  behaviour of Emacs.
Whenever you  press return for a  new line Emacs will reindent  the current
line and auto-indent the new line (this behaviour can  be deactivated).  At
any time, the TAB key  will reindent the  current line, `M-q' will reindent
each line in the current region, and `M-C-q' will reindent each line in the
whole buffer.

Gap-mode will add indentation for if..then structures, function definitions
and all looping structures,

    for N in [1..10] do
        Print ( N );
        if N > 5 then
            Print ( N^2 );
        fi;
    od; ,

as well as indenting continued statements  (those that cross  a line break)
in a number  of different ways. For example,  it  will attempt to  match up
each line of a matrix,

    x := [ [ 1, 2, 3 ],
           [ 4, 5, 6 ],
           [ 7, 8, 9 ] ];

and the arguments of a function call,

    Print ( a, b, c
            d, e, f ); .

There are quite a number of variables that control how gap-mode indentation
behaves. Consult the help for gap-mode by typing `C-h  m' for a list of the
variables (and the features of gap-mode in general), and then `C-h v <var>'
for a description of what the variable <var> controls.


Running GAP in an Emacs buffer
------------------------------

Type `M-x gap' to run a GAP process with input  and output through an Emacs
buffer.  Any text typed at the end of the *gap* buffer will  be sent to GAP
when the RETURN key is pressed,  and  GAP's output will  be appended to the
end of the buffer. The mode is based on comint-mode.

Moving back through previous commands is slightly different. Use  `M-p' and
`M-n' for previous and  next input. The  command  `M-l' will find the  last
input  that matches what  has already been  typed.    There  are some other
features that are  inherited (as these are) by  using comint-mode as a base
(see  the documentation for gap-process-mode by typing `C-h m' in the *gap*
buffer, and also the help for comint-mode: `C-h f comint-mode').

TAB  will complete  as usual, except  that  if there is no unique (partial)
completion then  the list  of completions will   be given immediately  in a
separate *Completions* buffer. Similarly the help  function `?', which will
ask for  a topic (defaulting to  the current  identifier),  will   give its
results in a *Help* buffer instead of the *gap* buffer.

In fact, if a GAP process is running in the *gap* buffer  and NOT BUSY with
a  calculation, then  completion and help   are also  available in  the gap
editing mode (gap-mode) by typing `M-TAB' and `M-?' respectively.

When starting up the  GAP process, giving  a prefix argument to the command
(eg by typing `C-u M-x gap') will cause the contents of  the current buffer
to be given to GAP as initial input, and GAP will behave exactly  as if you
had typed all the current buffer contents into the new *gap* buffer.


Installation
============

Put the file "gap-mode.el" into a directory in your Emacs lisp load path.
If you wish to run GAP within an Emacs buffer, also put "gap-process.el"
and "comint.el" at the same place. Add the following lines to your ".emacs"
startup file.

----------CUT-HERE----------
;; gap mode
(autoload 'gap-mode "gap-mode" "Gap editing mode" t)
(setq auto-mode-alist (append (list '("\\.g$" . gap-mode)
                                    '("\\.gap$" . gap-mode))
                              auto-mode-alist))
(autoload 'gap "gap-process" "Run GAP in emacs buffer" t)

(setq gap-executable "/usr/algebra/bin/gap")
(setq gap-start-options (list "-l" "/usr/algebra/gap3.1/lib"
                              "-m" "2m"))
----------CUT-HERE----------

Change the  path  to your GAP  executable  and library  appropriately. That
should complete installation!


======================================================================
Michael Smith
Mathematics Research Section
Australian National University.
