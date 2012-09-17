LoadPackage("io");

# f an FpGroup:

TryFinite := function(f)
  local ct;
  ct := CosetTable(f,TrivialSubgroup(f):silent);
  if ct <> fail then
      return Length(ct[1]);
  fi;
  Print("Finite: looping\n");
  while true do ct := ct; od;
end;

TryInfinite := function(f)
  local ab,h,l;
  ab := AbelianInvariants(f);
  if 0 in ab then return infinity; fi;
  l := LowIndexSubgroupsFpGroupIterator(f,40);
  while not(IsDoneIterator(l)) do
      h := NextIterator(l);
      ab := AbelianInvariants(h);
      if 0 in ab then return infinity; fi;
  od;
  Print("Infinite: looping\n");
  while true do ab := ab; od;
end;

f := FreeGroup(2);

Print(ParTakeFirstResultByFork([TryFinite,TryInfinite],[[f],[f]],
          rec( TimeOut := rec( tv_sec := 60, tv_usec := 0 ) )),"\n");

f := FreeGroup("a","b");
a := f.a;
b := f.b;
rels := [ a^2, b^3, a*b*a*b*a*b*a*b*a*b*a*b*a*b*a*b*a*b*a*b*a*b,
a^-1*b^-1*a*b*a^-1*b^-1*a*b*a^-1*b^-1*a*b*a^-1*b^-1*a*b*a^-1*b^-1*a*b*a^
-1*b^-1*a*b, a*b*a*b*a*b^-1*a*b*a*b*a*b^-1*a*b*a*b*a*b^-1*a*b*a*b*a*b^
-1*a*b*a*b*a*b^-1*a*b*a*b*a*b^-1, a*b*a*b*a*b^-1*a*b^-1*a*b*a*b*a*b^
-1*a*b^-1*a*b*a*b*a*b^-1*a*b^-1*a*b*a*b*a*b^-1*a*b^-1*a*b*a*b*a*b^-1*a*b^-1 ];
g := f/rels;   # this is M12

Print(ParTakeFirstResultByFork([TryFinite,TryInfinite],[[g],[g]],
          rec( TimeOut := rec( tv_sec := 60, tv_usec := 0 ) )),"\n");

