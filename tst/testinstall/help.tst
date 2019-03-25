# Test help

#
gap> if true then ?what fi;
Syntax error: '?' cannot be used in this context in stream:1
if true then ?what fi;
             ^^^^^^^^^
Syntax error: while parsing an 'if' statement: statement or 'fi' expected in s\
tream:2


#
gap> if false then ?what fi;
Syntax error: '?' cannot be used in this context in stream:1
if false then ?what fi;
              ^^^^^^^^^
Syntax error: while parsing an 'if' statement: statement or 'fi' expected in s\
tream:2


#
gap> f := function()
> ?help
Syntax error: '?' cannot be used in this context in stream:2
?help
^^^^^
Syntax error: while parsing a function: statement or 'end' expected in stream:\
3


#
gap> old_help := HELP;;
gap> MakeReadWriteGlobal("HELP");
gap> Unbind(HELP);
gap> ?foo
Error, Global variable "HELP" is not defined. Cannot access help
gap> HELP:=1;;
gap> ?foo
Error, Global variable "HELP" is not a function. Cannot access help
gap> HELP:=x->x;;
gap> ?foo
"foo"
gap> HELP := old_help;;
gap> MakeReadOnlyGlobal("HELP");
