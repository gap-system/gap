" Vim syntax file
" Language:	GAP
" Maintainer:	Alexander Hulpke <ahulpke@math.ohio-state.edu>
" Last change:	2000 September 12

" Remove any old syntax stuff hanging around
syn clear

" String
syn region  gapString	start=+"+  end=+"+ skip=+\\"+

" comments
syn match gapComment  "#.*$"

" must do
syn keyword gapTodo TODO contained
syn keyword gapTodo XXX contained
syn match gapTodoComment "#.*$" contains=gapTodo
syn match gapTTodoComment "#T.*$"

syn keyword gapDeclare	DeclareOperation DeclareGlobalFunction
syn keyword gapDeclare	DeclareAttribute DeclareProperty
syn keyword gapDeclare	DeclareCategory DeclareFilter
syn keyword gapDeclare	DeclareRepresentation DeclareInfoClass
syn keyword gapDeclare	DeclareCategoryCollections DeclareSynonym
syn keyword gapDeclare	DeclareCategoryFamily
syn keyword gapMethsel	InstallMethod InstallOtherMethod NewType Objectify 
syn keyword gapMethsel	NewFamily InstallTrueMethod
syn keyword gapMethsel  InstallGlobalFunction ObjectifyWithAttributes
syn keyword gapMethsel  BindGlobal BIND_GLOBAL

syn keyword gapOperator	and div in mod not or

syn keyword gapFunction	function -> return local end
syn keyword gapConditional	if else then fi elif
syn keyword gapRepeat		do od for while repeat until
syn keyword gapOtherKey         Info Unbind

syn keyword gapBool         true false fail
syn match  gapNumber		"-\=\<\d\+\>"
syn match  gapListDelimiter	"[][]"
syn match  gapParentheses	"[)(]"
syn match  gapSublist	"[}{]"

"hilite
hi gapBlue	term=underline ctermfg=DarkBlue guifg=Blue
hi gapCyan  ctermfg=DarkCyan guifg=DarkCyan
hi gapGreen term=bold ctermfg=DarkGreen guifg=SeaGreen
hi gapRed   term=bold ctermfg=DarkRed guifg=DarkRed gui=bold
hi gapPurple   ctermfg=DarkMagenta guifg=Purple
hi gapBrown  ctermfg=Blue ctermbg=Brown guifg=Brown

hi link gapString  gapCyan
hi link gapFunction gapBlue
hi link gapDeclare  gapRed
hi link gapMethsel  gapBlue
hi link gapOtherKey  gapBlue
hi link gapOperator gapRed
hi link gapConditional gapRed
hi link gapRepeat gapRed
hi link gapComment  gapGreen
hi gapTodo  term=standout ctermbg=Red ctermfg=Black guifg=Blue guibg=Red
hi link gapTTodoComment  gapTodo
hi link gapTodoComment	gapComment
hi link gapNumber gapBlue
hi link gapBool gapNumber

hi link gapListDelimiter gapPurple
"hi link gapParentheses gapPurple
hi link gapSublist gapPurple

syn sync lines=250

let b:current_syntax = "gap"
set comments=sr:/*,mb:*,el:*/,://,b:#,:##,:%,n:>,fb:-

