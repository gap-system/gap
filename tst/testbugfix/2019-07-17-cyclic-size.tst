# Fix a bug that only occurs if all packages are loaded
gap> F:=FreeGroup(2);;
gap> F:=F/[F.1/F.2];;
gap> H:=Group(F.1);;
gap> IsCyclic(H);
true
gap> HasIsFinite(H);
false
gap>  Size(H); # should be instant, not infinite recursion / loop
infinity
