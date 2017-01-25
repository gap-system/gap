" GAP indent file
" Language:	GAP  (https://www.gap-system.org)
" Maintainer:	Frank Lübeck (Frank.Luebeck@Math.RWTH-Aachen.De)
" Comments: 
" --  started from Matlab indent file in vim 6.0
" --  Many people like a 4 blank indentation, I prefer 2 blanks: this can
"     be adjusted by setting `GAPIndentShift' to 4, 2 (default) or whatever
"     you like
" TODO: nice handling of `continuation' lines 

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
finish
endif
let b:did_indent = 1

" Some preliminary setting
setlocal nolisp		" Make sure lisp indenting doesn't supersede us

setlocal autoindent
setlocal indentexpr=GetGAPIndent(v:lnum)
setlocal indentkeys=o,O=end,=fi,=else,=elif,=od,=\)
let GAPIndentShift = 2

" Only define the function once.
if exists("*GetGAPIndent")
finish
endif

" this function computes for line lnum of the current buffer the number of
" blanks for the indentation
function! GetGAPIndent(lnum)
    " Give up if this line is explicitly joined.
    if getline(a:lnum - 1) =~ '\\$'
      return -1
    endif

    " Search backwards for the first non-empty line.
    let plnum = a:lnum - 1
    while plnum > 0 && getline(plnum) =~ '^\s*$'
      let plnum = plnum - 1
    endwhile

    if plnum == 0
      " This is the first non-empty line, use zero indent.
      return 0
    endif

    let curind = indent(plnum)

    " If the current line is a stop-block statement...
    if getline(v:lnum) =~ '^\s*\(end\|else\|elif\|fi\|od\|until\)\>'
      " See if this line does not follow the line right after an openblock
      if getline(plnum) =~ '^\s*\(for\|if\|then\|else\|elif\|while\|repeat\)\>'
      " See if the user has already dedented
      elseif indent(v:lnum) > curind - g:GAPIndentShift
        " If not, recommend one dedent
          let curind = curind - g:GAPIndentShift
      else
        " Otherwise, trust the user
        return -1
      endif

    " If the previous line opened a block
    elseif (getline(plnum) =~ '^\s*\(for\|if\|then\|else\|elif\|while\|repeat\)\>' || getline(plnum) =~ '\<function\> *(')
      " See if the user has already indented, or if block is also finished
      " im plnum
      if (indent(v:lnum) < curind + g:GAPIndentShift && getline(plnum) !~ '\<\(end\|fi\|od\)\>')
        "If not, recommend indent
        let curind = curind + g:GAPIndentShift
      else
        " Otherwise, trust the user
        return -1
      endif
    " Handle assignments over several lines
    elseif (getline(plnum) =~ '^\s*[a-zA-Z0-9]*\s*:=[^;]*$')
      let curind = match(getline(plnum), ':=') + 3
    " Handle continuing function calls over several lines
    elseif (getline(plnum) =~ '^\s*[a-zA-Z0-9]*\s*([^;]*$')
      let curind = indent(plnum) + 2*GAPIndentShift;
    endif

    " If we got to here, it means that the user takes the standard version, 
    " so we return it
    return curind
endfunction

" vim:sw=2
