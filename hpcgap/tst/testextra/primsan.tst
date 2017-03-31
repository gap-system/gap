#############################################################################
##
#W  primsan.tst                 GAP library                      Steve Linton
##
##
#Y  Copyright (C)  1999,  School of Computer Science, St Andrews
##
##  sanity test for primitive groups library -- takes 30-40 minutes on
##  a PIII/500, and need 400MB of RAM
##
##  Exclude from testinstall.g until the typical developer's desktop
##  is big and fast enough.
##
gap> START_TEST("primsan.tst");

#
# Disable warnings which depend on Conway Polynomial databases 
#
gap> iW := InfoLevel(InfoWarning);;
gap> SetInfoLevel(InfoWarning,0);

#############################################################################
##
##  Define a function to check the primitive groups of degree n and 
##  loop over a range of n
##
gap> checkdegree := function(n) 
>     local g;
>     for g in AllPrimitiveGroups(DegreeOperation,n) do
>         if MovedPoints(g) <> [1..n] or not IsTransitive(g,[1..n]) 
>            or not IsPrimitive(g,[1..n]) then
>             Error("Failure at ",g," degree ",n,"\n");
>         fi;
>     od;
> end;;
gap> for n in [2..999] do 
>     checkdegree(n);
> od;
gap> SetInfoLevel(InfoWarning,iW);
gap> STOP_TEST( "primsan.tst", 1);

#############################################################################
##
#E
