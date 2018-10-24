f := function() 
  local l;
  l := 0 * [1..6];
  l[[1..3]] := 1;
end;
f();
Where();
quit;


f:=function() if true = 1/0 then return 1; fi; return 2; end;;
f();
Where();
quit;


f:=function() local x; if x then return 1; fi; return 2; end;;
f();
Where();
quit;


f:=function() if 1 then return 1; fi; return 2; end;;
f();
Where();
quit;


f:=function() if 1 < 0 then return 1; elif 1 then return 2; fi; return 3; end;;
f();
Where();
quit;


f:=function() while 1 do return 1; od; return 2; end;;
f();
Where();
quit;


f:=function() local i; for i in 1 do return 1; od; return 2; end;;
f();
Where();
quit;


f:=function() local i; for i in true do return 1; od; return 2; end;;
f();
Where();
quit;


f:=function() local x; repeat x:=1; until 1; return 2; end;;
f();
Where();
quit;


f:=function() local x; Assert(0, 1); return 2; end;;
f();
Where();
quit;


f:=function() local x; Assert(0, 1, "hello"); return 2; end;;
f();
Where();
quit;

# Verify issue #2656 is fixed
l := [[1]];; f := {} -> l[2,1];;
f();
Where();
quit;

# verify issue #1373 is fixed
InstallMethod( Matrix, [IsFilter, IsSemiring, IsMatrixObj], {a,b,c} -> fail );
