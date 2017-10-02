# Issue #1664 on github.com/gap-system/gap
gap> G := TrivialGroup(IsPcGroup);
<pc group of size 1 with 0 generators>
gap> CodePcGroup(G);
0
gap> IsTrivial(PcGroupCode(0, 1));
true
