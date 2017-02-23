# Crash when reading certain pieces of syntactically invalid code
# Fix and test case added by MH on 2012-09-06.
gap> str := Concatenation("function()\n",
> "local e, v;\n",
> "for e in [] do\n",
> "    v := rec(a := [];);\n",
> "od;\n"
> );
"function()\nlocal e, v;\nfor e in [] do\n    v := rec(a := [];);\nod;\n"
gap> s:=InputTextString(str);
InputTextString(0,66)
gap> Read(s);
Syntax error: ) expected in stream:4
    v := rec(a := [];);
                    ^
Syntax error: end expected in stream:5
od;
 ^
