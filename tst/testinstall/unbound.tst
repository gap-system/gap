#@local f
gap> START_TEST("unbound.tst");
gap> f := function() unknownvarname := 1; end;;
Syntax warning: Unbound global variable in stream:1
f := function() unknownvarname := 1; end;;
                ^^^^^^^^^^^^^^
gap> f := function() unknownvarname.test := 2; end;;
Syntax warning: Unbound global variable in stream:1
f := function() unknownvarname.test := 2; end;;
                ^^^^^^^^^^^^^^
gap> f := function() unknownvarname1 := unknownvarname2; end;;
Syntax warning: Unbound global variable in stream:1
f := function() unknownvarname1 := unknownvarname2; end;;
                ^^^^^^^^^^^^^^^
Syntax warning: Unbound global variable in stream:1
f := function() unknownvarname1 := unknownvarname2; end;;
                                   ^^^^^^^^^^^^^^^

# Cases where we can't get the right marker, check we do not crash
gap> f := function() unknownvarname
> := 2; end;;
Syntax warning: Unbound global variable in stream:2
:= 2; end;;
 ^
gap> f := function() unknownva\
> name := 2; end;;
Syntax warning: Unbound global variable in stream:2
name := 2; end;;
 ^^^^^^
gap> f := function() unknownva\
> name
> := 2; end;;
Syntax warning: Unbound global variable in stream:3
:= 2; end;;
 ^

# Not global variable problems
gap> f := function(unknownname) unknownname := 2; end;;
gap> f := function() unknownname -> 3; end;;
Syntax error: Function literal in impossible context in stream:1
f := function() unknownname -> 3; end;;
                            ^^
gap> f := function() return unknownname -> 3; end;;

#
gap> STOP_TEST( "unknown.tst", 1);
