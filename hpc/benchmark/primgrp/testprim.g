has_errors := false;

PGTest1:=function(G)
# Checks that the sum of the orders of conjugacy classes 
# equals to the order of the group
return Sum(List(ConjugacyClasses(G),Size)) = Size(G);
end;

TestAllPrimitiveGroups := function( degree )
local n,G,res;
for n in [1..NrPrimitiveGroups(degree)] do
  G:=PrimitiveGroup(degree,n);
  res := CALL_WITH_CATCH( PGTest1, [ G ] );
  if res[1] = true then
    if not res[2] then
      Print( "wrong conjugacy classes sizes for PrimitiveGroup(", degree, ",", n, ")\n" );
      has_errors := true;
    fi;
  else
      Print( "error in PGTest1 for PrimitiveGroup(", degree, ",", n, ")\n" );
      Print( res[2], "\n" );
      has_errors := true;
  fi;
od;
end;