has_errors := false;

TestAllGroups := function( size )
local n,G,ccl,S;
for n in [1..NrSmallGroups(size)] do
  G:=SmallGroup(size,n);
  #
  # Check that the sum of the orders of conjugacy classes 
  # equals to the order of the group
  #
  ccl:=ConjugacyClasses(G);
  if Sum(List(ccl,Size)) <> size then
    Print( "wrong conjugacy classes sizes for SmallGroup(", size, ",", n, ")\n" );
    has_errors := true;
  fi;
  #
  # Check that the IdGroup of the isomorphic permutation group is the same
  #
  if size>1 then
    S:=Group(GeneratorsOfGroup(Image(IsomorphismPermGroup(G))));
  else
    S:=Group(());
  fi;
  if IdGroup(S) <> [size,n] then
    Print( "wrong IdGroup ", IdGroup(S), " for SmallGroup(", size, ",", n, ")\n" );
    has_errors := true;
  fi;
od;
end;