# 2013/02/27 (AK)
gap> G:=SymmetricGroup(8);
Sym( [ 1 .. 8 ] )
gap> H:=SylowSubgroup(G,3);;
gap> HasIsPGroup(H);
true
gap> HasPrimePGroup(H);
true
