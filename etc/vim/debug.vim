"
" Keyboard configuration for vim sessions during the `Debug' call
" from the library file "debug.g".
"
" By Thomas Breuer and Max Neunhöffer 2003
"
"
map <f2> OError("Breakpoint #<esc>"apa");<esc>
map <f3> OPrint("Watchpoint #<esc>"apa\n");<esc>
map <f4> ODEBUG_LIST[<esc>"apa].count := DEBUG_LIST[<esc>"apa].count - 1;<cr>if DEBUG_LIST[<esc>"apa].count <= 0 then Error("Breakpoint #<esc>"apa"); fi;<esc>
map <f5> OPrint("\n");<esc>5<left>
