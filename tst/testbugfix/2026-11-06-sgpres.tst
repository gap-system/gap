# tests proposed by Claude AI for sgpres.gi
#@local F,a,b,G,H,U,t,C,ct,P,r
gap> START_TEST("2026-11-06-sgpres.tst");

# AbelianInvariantsSubgroupFpGroupMtc with no relators
gap> F:=FreeGroup("a","b");; a:=F.1;; b:=F.2;;
gap> G:=F/[Comm(a,b)];; H:=Subgroup(G,[G.1,G.2]);;
gap> AbelianInvariantsSubgroupFpGroupMtc(G,H);
[ 0, 0 ]
gap> G:=F/[];; AbelianInvariantsSubgroupFpGroupMtc(G,Subgroup(G,[G.1,G.2]));
[ 0, 0 ]

# AugmentedCosetTableInWholeGroup with given generators and a stored
# table in NEWTC format
gap> G:=F/[a^2,b^3,(a*b)^5];; H:=Subgroup(G,[G.1*G.2]);;
gap> AugmentedCosetTableMtcInWholeGroup(H);;
gap> t:=AugmentedCosetTableInWholeGroup(H,[G.1*G.2]);;
gap> IsBound(t.isNewAugmentedTable);
true

# IsStandardized respects the standard
gap> C:=FreeGroup("c");; C:=C/[C.1^5];;
gap> ct:=CosetTable(C,TrivialSubgroup(C));;
gap> IsStandardized(ct);
true
gap> IsStandardized(ct,"semilenlex");
false
gap> StandardizeTable(ct,"semilenlex");; IsStandardized(ct,"semilenlex");
true

# cyclic replacement where r wraps around the end of the word
gap> NEWTC_ReplacedStringCyclic([4,5,1,2,3],[1,2,3,4],true);
[ 5 ]
gap> NEWTC_ReplacedStringCyclic([2,3,4,5,1],[1,2,3,4],true);
[ 5 ]

# print level argument of PresentationSubgroupMtc
gap> P:=PresentationSubgroupMtc(G,H,"y",0);;
gap> TzOptions(P).printLevel;
0

# quiet option must not loop when the limit is hit while scanning
# subgroup generators
gap> NEWTC_CosetEnumerator(GeneratorsOfGroup(F),[a^2,b^3],[(a*b)^20],
>      false,false:limit:=5,quiet:=true);
fail
gap> NEWTC_CosetEnumerator(GeneratorsOfGroup(F),[a^2,b^3],[(a*b)^20],
>      true,false:limit:=5,quiet:=true);
fail

#
gap> STOP_TEST("2026-11-06-sgpres.tst");
