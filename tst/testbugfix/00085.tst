# 2005/07/21 (JS)
gap> G:=PerfectGroup(IsPermGroup,734832,1);;
gap> H:=PerfectGroup(IsPermGroup,734832,2);;
gap> K:=PerfectGroup(IsPermGroup,734832,3);;
gap> Assert(0,H<>K); # Fails in 4.4.5
gap> Assert(0,Size(G)=734832 and IsPerfectGroup(G)); # Sanity check
gap> Assert(0,Size(H)=734832 and IsPerfectGroup(H)); # Sanity check
gap> Assert(0,Size(K)=734832 and IsPerfectGroup(K)); # Sanity check
gap> Assert(0,Size(ComplementClassesRepresentatives(G,SylowSubgroup(FittingSubgroup(G),3)))=1); # Iso check
gap> Assert(0,Size(ComplementClassesRepresentatives(H,SylowSubgroup(FittingSubgroup(H),3)))=3); # Iso check
gap> Assert(0,Size(ComplementClassesRepresentatives(K,SylowSubgroup(FittingSubgroup(K),3)))=0); # Iso check
