" Vim syntax file
" Language:	GAP
" Author:  Frank L�beck,  highlighting based on file by Alexander Hulpke
" Maintainer:	Frank L�beck
" Last change:	June 2001 
" CVS version:  $Id: gap.vim,v 1.7 2001/10/31 08:40:19 gap Exp $
" 
" Comments: If you want to use this file, you may want to adjust colors to
" your taste. There are some functions/macros for 
" GAPnl                -- newline, with reindenting the old line
"                         (mapped on <CTRL>-j)
" ToggleCommentGAP     -- toggle comment, add or remove "##  " 
"                         (mapped on F12)
" <F4>                 -- macro to add word under cursor to `local' list
" GAPlocal             -- add whole `local' declaration to current function
"                         (mapped on <F5>)
" Then the completion mechanism <CTRL>-p is extended to complete all
" GAP variable names - search `GAPWORDS' below, how to do this.
"
" For vim version >= 6.0 folding is switched on.
" 
" For vim version >= 6.0 there is another file gap_indent.vim which you 
" may want to copy into ~/.vim/indent/gap.vim -- this provides a nice
" automatic indenting while writing GAP code.
"

" Please, send comments and suggestions to:  Frank.Luebeck@Math.RWTH-Aachen.De

" Remove any old syntax stuff hanging around
syn clear

" comments
syn match gapComment "\(#.*\)*" contains=gapTodo,gapFunLine

" strings and characters
syn region gapString  start=+"+ end=+\([^\\]\|^\)\(\\\\\)*"+
syn match  gapString  +"\(\\\\\)*"+
syn match gapChar +'\\\=.'+ 
syn match gapChar +'\\"'+

" must do
syn keyword gapTodo TODO contained
syn keyword gapTodo XXX contained

" basic infos in file and folded lines
syn match gapFunLine '^#[FVOMPCAW] .*$' contained

syn keyword gapDeclare	DeclareOperation DeclareGlobalFunction 
syn keyword gapDeclare  DeclareGlobalVariable
syn keyword gapDeclare	DeclareAttribute DeclareProperty
syn keyword gapDeclare	DeclareCategory DeclareFilter DeclareCategoryFamily
syn keyword gapDeclare	DeclareRepresentation DeclareInfoClass
syn keyword gapDeclare	DeclareCategoryCollections DeclareSynonym
" the CHEVIE utils
syn keyword gapDeclare  MakeProperty MakeAttribute MakeOperation 
syn keyword gapDeclare  MakeGlobalVariable MakeGlobalFunction

syn keyword gapMethsel	InstallMethod InstallOtherMethod NewType Objectify 
syn keyword gapMethsel	NewFamily InstallTrueMethod
syn keyword gapMethsel  InstallGlobalFunction ObjectifyWithAttributes
syn keyword gapMethsel  BindGlobal BIND_GLOBAL InstallValue
" CHEVIE util
syn keyword gapMethsel  NewMethod

syn keyword gapOperator	and div in mod not or

syn keyword gapFunction	function -> return local end Error 
syn keyword gapConditional	if else elif then fi
syn keyword gapRepeat		do od for while repeat until
syn keyword gapOtherKey         Info Unbind IsBound

syn keyword gapBool         true false fail
syn match  gapNumber		"-\=\<\d\+\>\/"
syn match  gapListDelimiter	"[][]"
syn match  gapParentheses	"[)(]"
syn match  gapSublist	"[}{]"

"hilite
" this is very much dependent on personal taste, must add gui case if you
" use gvim
hi gapString ctermfg=2
hi gapFunction  ctermfg=1
hi gapDeclare  cterm=bold ctermfg=4
hi gapMethsel  ctermfg=6
hi gapOtherKey  ctermfg=3
hi gapOperator cterm=bold ctermfg=8
hi gapConditional cterm=bold ctermfg=9
hi gapRepeat cterm=bold ctermfg=12
hi gapComment  ctermfg=4
hi gapTodo  ctermbg=2 ctermfg=0
hi link gapTTodoComment  gapTodo
hi link gapTodoComment	gapComment
hi gapNumber ctermfg=5
hi gapBool ctermfg=5
hi gapChar ctermfg=3
hi gapListDelimiter ctermfg=8
hi gapParentheses ctermfg=12
hi gapSublist ctermfg=14
hi gapFunLine ctermbg=3 ctermfg=0

syn sync maxlines=500

" an ex function which returns a `fold level' for line n of the current
" buffer (only used with folding in vim >= 6.0) 
func! GAPFoldLevel(n) 
  " none at top of file
  if (a:n==0)
    return 0
  endif
  let l = getline(a:n)
  let lb = getline(a:n-1)
  " GAPDoc in comment is level 1
  if (l =~ "^##.*<#GAPDoc")
    return 1
  endif
  if (lb =~ "^##.*<#/GAPDoc")
    return 0
  endif
  " recurse inside comment
  if (l =~ "^#" && lb =~ "^#")
    return GAPFoldLevel(a:n-1)
  endif
  " in code one level per 4 blanks indent
  " from previous non-blank line
  let n = a:n
  while (n>1 && getline(n) =~ '^\s*$')
    let n = n - 1
  endwhile
  return (indent(n)+3)/4
endfunc

" enable folding and much better indenting in  vim >= 6.0
if version>=600
  syn sync fromstart
  set foldmethod=expr
  set foldminlines=3
  set foldexpr=GAPFoldLevel(v:lnum)
  hi Folded ctermbg=6 ctermfg=0
  " load the indent file
  runtime indent/gap.vim
endif

let b:current_syntax = "gap"

" some macros for editing GAP files (adjust as you like)
" This adds word under cursor to local variables list.
map <F4> miviwy?\<local\><CR>/;<CR>i, <ESC>p`i
map! <F4> <ESC>miviwy?\<local\><CR>/;<CR>i, <ESC>p`ia

" for word completion, fall back to list of GAP global variable names
" (after loading your favourite packages in GAP say:
" for w in NamesGVars() do AppendTo("~/.vim/GAPWORDS",w,"\n"); od;    )
set complete=.,w,b,u,t,i,k~/.vim/GAPWORDS

" function for *toggling* GAP comments in beginning of line
func! ToggleCommentGAP()
  let l = getline(".")
  if (l =~ "^## *$")
    let l = ""
  elseif (l =~ "^##  ")
    let l = strpart(l, 4, strlen(l))
  else
    let l = "##  " . l
  endif
  call setline(".", l)
endfunc
" I put it on F12, adjust as you like
map <F12> :call ToggleCommentGAP()<CR>j
map! <F12> <ESC>:call ToggleCommentGAP()<CR>ji


" function for nice indenting after line breaks (bound to <C-J>)

" helper, returns string with n spaces
func! SpStr( n )
  let i = 0
  let res = ""
  while (i < a:n)
    let res = res . " "
    let i = i + 1
  endwhile
  return res
endfunc

" reindents current line and puts next line
" (outdated with vim 6.0's nice indent functionality)
func! GAPnl()
  let nc = line(".")
  let cl = getline(nc)
  let nsp = matchend(cl, "^[ ]*")
  let m =  match(cl, "^[ ]*\\(if\\|while\\|for\\) ")
  let m1 =  match(cl, ".*[^a-zA-Z0-9_]function[ ]*(.*)[ ]*$")
  if (m != -1 || m1 != -1)
    call append(nc, SpStr(nsp + 2))
    return
  endif
  let m = match(cl, "^  [ ]*\\(fi\\|end\\|od\\)\\([);,]\\)")
  if (m != -1)
    let cl = substitute(cl, "^  ", "", "")
    call setline(nc, cl)
    call append(nc, SpStr(nsp -  2))
    return
  endif
  let m = match(cl, "^  [ ]*\\(else\\|elif\\)")
  if (m != -1)
    let cl = substitute(cl, "^  ", "", "")
    call setline(nc, cl)
    call append(nc, SpStr(nsp))
    return
  endif
  call append(nc, SpStr(nsp)) 
endfunc

" call GAPnl, goto end of next line and in append mode
map! <C-J> <ESC>:call GAPnl()<CR>j$a

" position count from 0 here
" (we assume that pos is after the begin delimiter b to match)
function! MatchingDelim(str, pos, b, e)
  let len = strlen(a:str)
  let res = a:pos + 1
  let stop = 1
  while (stop > 0 && res < len)
    if (a:str[res] == a:e)
      let stop = stop - 1
    endif
    if (a:str == a:b)
      let stop = stop + 1
    endif
    let res = res + 1
  endwhile
  return res - 1
endfunction
    

" insert complete list of local variable declaration on top of function
function! GAPlocal()
  let t = ""
  let i = line(".")
" collect forward to 'end'  
  let stop = 1
  while (stop > 0 && i < 10000)
    let cl = getline(i)
" throw away comments    
    let m = match(cl, "#")
    if (m != -1)
      let cl = strpart(cl, 0, m)
    endif
    let t = t . cl . " "
    let m = match(cl, "\\(^\\|[^a-zA-Z0-9_]\\)end[^a-zA-Z0-9_]")
    if (m != -1)
      let stop = stop - 1
    endif
    let m = match(cl, "\\(^\\|[^a-zA-Z0-9_]\\)function[ ]*(")
    if (m != -1)
      let stop = stop + 1
    endif
    let i = i + 1
  endwhile
" collect backward to matching 'function'  
  let i = line(".") - 1
  let stop = 1
  while (stop > 0 && i > -1)
    let cl = getline(i)
" throw away comments    
    let m = match(cl, "#")
    if (m != -1)
      let cl = strpart(cl, 0, m)
    endif
    let t = cl . t . " "
    let m = match(cl, "\\(^\\|[^a-zA-Z0-9_]\\)function[ ]*(")
    if (m != -1)
      let stop = stop - 1
    endif
    let m = match(cl, "\\(^\\|[^a-zA-Z0-9_]\\)end[^a-zA-Z]")
    if (m != -1)
      let stop = stop + 1
    endif
    let i = i - 1
  endwhile
" line for 'local ...'  
  let locline = i + 1
" filter out first 'function' and local functions, store parameters 
  let m = matchend(t, "\\(^\\|[^a-zA-Z0-9_]\\)function[ ]*(")
  let param = strpart(t, m, MatchingDelim(t, m-1, "(", ")") - m)
  let param = "," . substitute(param, " ", "", "g") . ","
  let t = strpart(t, m, strlen(t))
  let m = matchend(t, "\\(^\\|[^a-zA-Z0-9_]\\)function[ ]*(")
  while (m != -1)
    let tt = strpart(t, 0, m - 3) . "; "
    let m = match(t, "\\(^\\|[^a-zA-Z0-9_]\\)end[^a-zA-Z0-9_]")
    let tt = tt . strpart(t, m + 2, strlen(t))
    let t = tt
    let m = matchend(t, "\\(^\\|[^a-zA-Z0-9_]\\)function[ ]*(")
  endwhile
" filter out rec( .. ), which may contain := assignments
  let m = matchend(t, "\\(^\\|[^a-zA-Z0-9_]\\)rec[ ]*(")
  while (m != -1)
    let tt = strpart(t, 0, m-2) . "; " 
    let tt = tt . strpart(t, MatchingDelim(t, m-1, "(", ")"), strlen(t))
    let t = tt
    let m = matchend(t, "\\(^\\|[^a-zA-Z0-9_]\\)rec[ ]*(")
  endwhile
" now collect local variables, 
" first lhd's of assignments, then vars in for loops
  let vars = ","
  let tt = t
  let m = matchstr(tt, "\\(^\\|[^.a-zA-Z_]\\)[a-zA-Z0-9_][a-zA-Z0-9_]*[ ]*:=")
  while (strlen(m) > 0)
" XXX why is this necessary?
    let m = strpart(m, match(m, "[a-zA-Z0-9_]"), strlen(m))
    let m = matchstr(m, "[a-zA-Z0-9_]*")
    if (vars.param !~# ("," . m . ","))
      let vars = vars . matchstr(m, "[a-zA-Z0-9_]*") . ","
    endif
    let m = matchend(tt, "\\(^\\|[^.a-zA-Z0-9_]\\)[a-zA-Z0-9_][a-zA-Z0-9_]*[ ]*:=")
    let tt = strpart(tt, m, strlen(tt))
    let m = matchstr(tt, "\\(^\\|[^.a-zA-Z0-9_]\\)[a-zA-Z0-9_][a-zA-Z0-9_]*[ ]*:=")
  endwhile
  let tt = t
  let m = matchstr(tt, "for[ ]*[a-zA-Z0-9_]*[ ]*in")
  while (strlen(m) > 0)
    let m = strpart(m, 4, strlen(m))
    let m = matchstr(m, "[a-zA-Z0-9_]*")
    if (vars.param !~# ("," . m . ","))
      let vars = vars . matchstr(m, "[a-zA-Z0-9_]*") . ","
    endif
    let m = matchend(tt, "for[ ]*[a-zA-Z0-9_]*[ ]*in")
    let tt = strpart(tt, m, strlen(tt))
    let m = matchstr(tt, "for[ ]*[a-zA-Z0-9_]*[ ]*in")
  endwhile
" now format the result vars (if not empty)
  if (strlen(vars) > 1)
    let vars = strpart(vars, 1, strlen(vars) - 2)
    let vars = substitute(vars, ",", ", ", "g")
    let vars = matchstr(getline(locline), "^[ ]*") . "  local " . vars . ";"
    call append(locline, vars)
  endif
  return
endfunction

" I map it on F5
map! <F5> <ESC>:call GAPlocal()<CR>i
map <F5> :call GAPlocal()<CR>

" very personal, for adding GAPDoc XML code in comments in GAP file
vmap <ESC>}F14 y:n bla.xml<CR>Gp:.,$ s/##  \(.*\)/\1/<CR>i
map <ESC>}F15 :n bla.xml<CR>:1,$ s/\(.*\)/##  \1/<CR>1GVGyu<C-^>gpi
map! <ESC>}F15 <ESC>:n bla.xml<CR>:1,$ s/\(.*\)/##  \1/<CR>1GVGyu<C-^>gpi
vmap <ESC>}F22 !(mv -f bla.xml bla1.xml; sed -e "s/^\#\#  \(.*\)/\1/" >bla.xml;xterm -e vim bla.xml ;sed -e "s/\(.*\)/\#\#  \1/" bla.xml)<CR><CR>

" vim: ts=2
