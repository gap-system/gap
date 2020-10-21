#
gap> function() 123; end;
Syntax error: while parsing a function: statement or 'end' expected in stream:\
1
function() 123; end;
           ^^^
gap> if true then 123; fi;
Syntax error: while parsing an 'if' statement: statement or 'fi' expected in s\
tream:1
if true then 123; fi;
             ^^^
gap> while true do 123; od;
Syntax error: while parsing a 'while' loop: statement or 'od' expected in stre\
am:1
while true do 123; od;
              ^^^
gap> repeat 123; until true;
Syntax error: while parsing a 'repeat' loop: statement or 'until' expected in \
stream:1
repeat 123; until true;
       ^^^
gap> for i in [1..3] do 123; od;
Syntax error: while parsing a 'for' loop: statement or 'od' expected in stream\
:1
for i in [1..3] do 123; od;
                   ^^^

#
gap> f := function() Stabilizer; end;
Syntax error: found an expression when a statement was expected in stream:1
f := function() Stabilizer; end;
                          ^
gap> if false then Stabilizer; fi;
Syntax error: found an expression when a statement was expected in stream:1
if false then Stabilizer; fi;
                        ^
