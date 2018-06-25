# Test help

#
gap> if true then ?what fi;
Syntax error: '?' cannot be used in this context in stream:1
if true then ?what fi;
             ^^^^^^^^^
Syntax error: fi expected in stream:2


#
gap> if false then ?what fi;
Syntax error: '?' cannot be used in this context in stream:1
if false then ?what fi;
              ^^^^^^^^^
Syntax error: fi expected in stream:2


#
gap> f := function()
> ?help
Syntax error: '?' cannot be used in this context in stream:2
?help
^^^^^
Syntax error: end expected in stream:3

