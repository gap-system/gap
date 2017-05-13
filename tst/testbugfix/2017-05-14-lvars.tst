gap> GetCurrentLVars();
<lvars bag>
gap> ContentsLVars(GetCurrentLVars());
false
gap> f := function() return ContentsLVars(GetCurrentLVars()); end;
function(  ) ... end
gap> f();
rec( func := function(  ) ... end, names := [  ], values := [  ] )
gap> f := function() local x; return ContentsLVars(GetCurrentLVars()); end;;
gap> f();
rec( func := function(  ) ... end, names := [ "x" ], values := [  ] )
gap> f := function(a,b,c) local x,y,z; y := 2; return ContentsLVars(GetCurrentLVars()); end;;
gap> f(1,2,3);
rec( func := function( a, b, c ) ... end, 
  names := [ "a", "b", "c", "x", "y", "z" ], values := [ 1, 2, 3,, 2 ] )
gap> f := function(a,b,c...) local x,y,z; y := 2; return ContentsLVars(GetCurrentLVars()); end;;
gap> f(1,2,3);
rec( func := function( a, b, c... ) ... end, 
  names := [ "a", "b", "c", "x", "y", "z" ], values := [ 1, 2, [ 3 ],, 2 ] )
