"
" Keyboard configuration for vim sessions during the `Debug' call
" from the library file "debug.g".
"
" By Thomas Breuer and Max Neunhoeffer 2003
"
" $Id: debug.vim,v 1.1 2003/04/07 17:06:17 gap Exp $
"
map <f2> OError("Breakpoint #<esc>"apa");<esc>
map <f3> OPrint("Watchpoint #<esc>"apa\n");<esc>
map <f4> ODEBUG_LIST[<esc>"apa].count := DEBUG_LIST[<esc>"apa].count - 1;<cr>if DEBUG_LIST[<esc>"apa].count <= 0 then Error("Breakpoint #<esc>"apa"); fi;<esc>
map <f5> OPrint("\n");<esc>5<left>
