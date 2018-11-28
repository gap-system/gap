#############################################################################
##
##  This file tests Where and WhereWithVars, and in particular how backtraces
##  are reported for different kinds of statements; there used to be various
##  bugs related to that in the past.
##
f := function() 
  local l;
  l := 0 * [1..6];
  l[[1..3]] := 1;
end;
f();
Where();
WhereWithVars();
quit;

#############################################################################
f:=function() if true = 1/0 then return 1; fi; return 2; end;;
f();
Where();
WhereWithVars();
quit;

#############################################################################
f:=function() local x; if x then return 1; fi; return 2; end;;
f();
Where();
WhereWithVars();
quit;

#############################################################################
f:=function() if 1 then return 1; fi; return 2; end;;
f();
Where();
WhereWithVars();
quit;

#############################################################################
f:=function() if 1 < 0 then return 1; elif 1 then return 2; fi; return 3; end;;
f();
Where();
WhereWithVars();
quit;

#############################################################################
f:=function() while 1 do return 1; od; return 2; end;;
f();
Where();
WhereWithVars();
quit;

#############################################################################
f:=function() local i; for i in 1 do return 1; od; return 2; end;;
f();
Where();
WhereWithVars();
quit;

#############################################################################
f:=function() local i; for i in true do return 1; od; return 2; end;;
f();
Where();
WhereWithVars();
quit;

f:=function(x) local i,j; for i in true do return 1; od; return 2; end;;
f([1,2,3]);
Where();
WhereWithVars();
quit;

f:=function(x) local i,j; Unbind(x); for i in true do return 1; od; return 2; end;;
f([1,2,3]);
Where();
WhereWithVars();
quit;

f:=function(x) local i,j; Unbind(x); j := 4; for i in true do return 1; od; return 2; end;;
f([1,2,3]);
Where();
WhereWithVars();
quit;

f:=function() local x; repeat x:=1; until 1; return 2; end;;
f();
Where();
WhereWithVars();
quit;

#############################################################################
f:=function() local x; Assert(0, 1); return 2; end;;
f();
Where();
WhereWithVars();
quit;

#############################################################################
f:=function() local x; Assert(0, 1, "hello"); return 2; end;;
f();
Where();
WhereWithVars();
quit;

#############################################################################
##
##  Verify issue #2656 is fixed
##
InstallMethod( \[\,\], [ IsMatrixOrMatrixObj, IsPosInt, IsPosInt ],
    { m, row, col } -> ELM_LIST( m, row, col ) );
l := [[1]];; f := {} -> l[2,1];;
f();
Where();
WhereWithVars();
quit;

#############################################################################
##
##  Verify issue #1373 is fixed
##
InstallMethod( Matrix, [IsFilter, IsSemiring, IsMatrixObj], {a,b,c} -> fail );
quit;


# Verify issue #3044 is fixed
function() if 1 <> 2 and 3 then return 42;; fi; end();
Where();
quit;


function() if 1 = 2 or 3 then return 42;; fi; end();
Where();
quit;


function() if 1 <> 2 and not 3 then return 42;; fi; end();
Where();
quit;


function() if not 3 then return 42;; fi; end();
Where();
quit;


function() if 3 or false then return 42;; fi; end();
Where();
quit;


function() if 3 and false then return 42;; fi; end();
Where();
quit;


l:=[ function() if 1 <> 2 and ~ then return 42;; fi; end ];;
l[1]();
Where();
#quit;


function() if 1 <> 2 and ((1,2,2) = (1,2,3)) then return 42;; fi; end();
Where();
quit;


f:=function(b,c) if 1=2 or (b and c) then return 42;; fi; end;;
f(3,true);
Where();
quit;

f(true,3);
Where();
quit;


f:=function(b,c) if 1=1 and (b or c) then return 42;; fi; end;;
f(3,false);
Where();
quit;

f(false,3);
Where();
quit;

