#@local r,x,funcstr,func
gap> START_TEST("function.tst");

# Test functions with very large lists
gap> r := List([1..(16777216/GAPInfo.BytesPerVariable)-1]);;
gap> funcstr := String(r);;
gap> funcstr := Concatenation("return ", funcstr, ";");;
gap> func := ReadAsFunction(InputTextString(funcstr));;
gap> func() = r;
true
gap> funcstr := String(List([1..(16777216/GAPInfo.BytesPerVariable)], x -> x));;
gap> funcstr := Concatenation("return ", funcstr, ";");;
gap> ReadAsFunction(InputTextString(funcstr));;
Error, function too large for parser

# Test functions with very large records
gap> r := rec();; for x in [1..(16777216/GAPInfo.BytesPerVariable-2)/2] do r.(x) := x; od;;
gap> funcstr := String(r);;
gap> funcstr := Concatenation("return ", funcstr, ";");;
gap> func := ReadAsFunction(InputTextString(funcstr));;
gap> func() = r;
true
gap> r := rec();; for x in [1..(16777216/GAPInfo.BytesPerVariable)/2] do r.(x) := x; od;;
gap> funcstr := String(r);;
gap> funcstr := Concatenation("return ", funcstr, ";");;
gap> ReadAsFunction(InputTextString(funcstr));;
Error, function too large for parser

#
gap> STOP_TEST("function.tst", 1);
