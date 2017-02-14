# 2005/08/22 (JS+AH)
gap> ##  The mailing lists contain more specific test code that is longer.
gap> ##  The following should never terminate, but does in 4.4.5
gap> # repeat G:=PerfectGroup(IsPermGroup,79200,3); P:=SylowSubgroup(G,11);
gap> # N:=Normalizer(G,P); Q:=N/P; until Size(DerivedSubgroup(Q)) <> 120;
