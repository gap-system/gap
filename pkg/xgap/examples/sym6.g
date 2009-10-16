# This is the second example from the XGAP manual:
# The symmetric group on 6 points.
# $Id:
s6 := SymmetricGroup(6);
SetName(s6,"S6");
cc := ConjugacyClassesSubgroups(s6);;
Sum(List(cc,Size));
s := GraphicSubgroupLattice(s6);
c60 := Filtered(cc,x->Size(Representative(x))=60);;
s60 := List(c60,Representative);
for g in s60 do InsertVertex(s,g); od;

