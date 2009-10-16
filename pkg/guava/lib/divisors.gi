#############################################################################
##
#A   divisors.gd             GUAVA library                      David Joyner
##
##  this file contains implementations for divisors on curves
##
#H  @(#)$Id: divisors.gi,v 1.1 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/divisors_gi") :=
    "@(#)$Id: divisors.gi,v 1.1 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  AffinePointsOnCurve(<f>, <R>, <E>)
##
InstallGlobalFunction(AffinePointsOnCurve,function(f,R,E)
 local a,b,indets,solns;
 solns:=[];
 indets:=IndeterminatesOfPolynomialRing(R);
 for a in E do
  for b in E do
    if Value(f,indets,[a,b])=Zero(E) then
     solns:=Concatenation([[a,b]],solns); 
    fi;
  od;
 od;
 return solns;
end);
