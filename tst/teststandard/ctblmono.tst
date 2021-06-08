gap> START_TEST("ctblmono.tst");

#
# the following test comes from https://github.com/gap-system/gap/issues/4452
# this used to give method not found for non-solvable groups
#
gap> IsMinimalNonmonomial(SL(2,3));
true
gap> IsMinimalNonmonomial(GL(2,3));
false
gap> IsMinimalNonmonomial(PSL(2,4));
true
gap> IsMinimalNonmonomial(PGL(2,5));
false
gap> IsMinimalNonmonomial(PSL(2,7));
true
gap> IsMinimalNonmonomial(PSL(2,8));
true
gap> IsMinimalNonmonomial(PSL(2,9));
false
gap> IsMinimalNonmonomial(PSL(2,11));
false
gap> IsMinimalNonmonomial(PSL(2,27));
true
gap> IsMinimalNonmonomial(PSL(3,3));
false
gap> IsMinimalNonmonomial(Sz(8));
true
gap> IsMinimalNonmonomial(Sz(2^9));
false

# To avoid more silly mistakes, the following tests were also run
# Since they take several minutes, I have left them commented out
# gap> IsMNMNaive := g ->
# > (IsMonomialGroup(g)=false) # not monomial itself
# > and ForAll( NormalSubgroups(g), n -> Size(n) = 1 or
# > IsMonomialGroup(g/n) ) # every proper quotient is monomial
# > and ForAll( MaximalSubgroupClassReps(g), IsMonomialGroup) # quicker
# > and ForAll( ConjugacyClassesSubgroups(g), c -> # every proper subgroup
# > Size( Representative(c) ) = Size(g) or IsMonomialGroup(Representative(c)));;
# gap> for n in [1..767] do
# > if IsPrimePowerInt(n) then continue; fi;
# > if NrSmallGroups(n) > 2000 then continue; fi;
# > for k in [1..NrSmallGroups(n)] do
# > sg := SmallGroup(n,k);
# > Assert(0, IsMNMNaive(sg) = IsMinimalNonmonomial(sg) );
# > od; od;
# gap> for n in SizesPerfectGroups() do
# > for k in [1..NrPerfectLibraryGroups(n)] do
# > pg := PerfectGroup(IsPermGroup,n,k);
# > Assert(0, IsMNMNaive(pg) = IsMinimalNonmonomial(pg) );
# > od; od;
# gap> for pg in PrimitiveGroupsIterator(NrMovedPoints,[1..20],IsSolvableGroup,false) do
# > if IsNaturalAlternatingGroup(pg) or IsNaturalSymmetricGroup(pg) then continue; fi;
# > if Size(pg) > 10^6 then continue; fi;
# > Assert(0, IsMNMNaive(pg) = IsMinimalNonmonomial(pg) );
# > od;

#
gap> STOP_TEST( "ctblmono.tst", 1);
