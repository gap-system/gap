# Issue related to PrimePGroup for filter IsPGroup and HasDirectProductInfo
# Examples reported on issue #1719 on github.com/gap-system/gap
#
gap> level := AssertionLevel();;
gap> SetAssertionLevel(1);
gap> G := CyclicGroup(IsPcGroup, 5);;
gap> H := Range(IsomorphismPermGroup(G));
Group([ (1,2,3,4,5) ])
gap> PrimePGroup(H);
5
gap> SetAssertionLevel(level);;
