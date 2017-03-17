#############################################################################
##
#W  semirel.tst                 GAP library                Robert F. Morse
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  To be listed in testinstall.g
##
gap> START_TEST("semirel.tst");

##
##  Three non-commutative finite semigroups
##
gap> f := FreeSemigroup(2);;
gap> a := GeneratorsOfSemigroup(f)[1];; b := GeneratorsOfSemigroup(f)[2];;
gap> rels := [[a^2,a],[b^2,b],[(a*b)^10,a*b],[(b*a)^10,b*a]];;
gap> s1 := f/rels;; Size(s1);
38
gap> t1 := Range(IsomorphismTransformationSemigroup(s1));;
gap> Size(t1);
38
gap> f := FreeSemigroup(2);;
gap> a := GeneratorsOfSemigroup(f)[1];; b := GeneratorsOfSemigroup(f)[2];;
gap> rels := [[a^5,a],[b^5,b],[(a*b)^5,a*b],[(b*a)^5,b*a],[a*b^2,a*b],[a^2*b,a*b]];; 
gap> s2 := f/rels;;
gap> t2 := Range(IsomorphismTransformationSemigroup(s2));;
gap> Size(t2);
108
gap> f := FreeSemigroup(2);;
gap> a := GeneratorsOfSemigroup(f)[1];; b := GeneratorsOfSemigroup(f)[2];;
gap> rels := [[a^4,a],[b^4,b],[(a*b)^2,a^2*b^2],[(b*a)^2,b^2*a^2]];; 
gap> s3 := f/rels;;
gap> t3 := Range(IsomorphismTransformationSemigroup(s3));;
gap> Size(t3);
294

##
##  A commutative finite semigroup
##
gap> f := FreeSemigroup(2);;
gap> a := GeneratorsOfSemigroup(f)[1];; b := GeneratorsOfSemigroup(f)[2];;
gap> rels := [[a*b,b*a],[a^4,a],[b^4,b],[(a*b)^2,a^2*b^2],[(b*a)^2,b^2*a^2]];; 
gap> sc := f/rels;;
gap> t4 := Range(IsomorphismTransformationSemigroup(sc));;
gap> Size(t4);
15

##
##  Full transformation semigroup of elements of 3, 4, and 5
##
gap> t3 := FullTransformationSemigroup(3);;
gap> t4 := FullTransformationSemigroup(4);;
gap> t5 := FullTransformationSemigroup(5);;

##
##  Size is known no computation required
##
gap> t20 := FullTransformationSemigroup(20);;
gap> Size(t20);
104857600000000000000000000

##
##  Green's relations
##
gap> grp := EquivalenceRelationPartition(GreensRRelation(s1));;
gap> grp1 := EquivalenceRelationPartition(GreensRRelation(t1));;
gap> Set(List(grp,i->Size(i))) = Set(List(grp1,i->Size(i)));
true
gap> glp := EquivalenceRelationPartition(GreensLRelation(s1));;
gap> glp1 := EquivalenceRelationPartition(GreensLRelation(t1));;
gap> Set(List(glp,i->Size(i))) = Set(List(glp1,i->Size(i)));
true
gap> gjp := EquivalenceRelationPartition(GreensJRelation(s1));;
gap> gjp1 := EquivalenceRelationPartition(GreensJRelation(t1));;
gap> Set(List(gjp,i->Size(i))) = Set(List(gjp1,i->Size(i)));
true

##
##  See that Green's classes for full transformation semigroups
##  are of the proper form
##
gap> ForAll(GreensRClasses(t3), 
> i->ForAll(AsSSortedList(i),j->KernelOfTransformation(j,3)
> = KernelOfTransformation(Representative(i),3)));
true
gap> ForAll(GreensLClasses(t3), 
> i->ForAll(AsSSortedList(i),j->ImageSetOfTransformation(j,3)
> = ImageSetOfTransformation(Representative(i),3)));
true
gap> ForAll(GreensJClasses(t3), 
> i->ForAll(AsSSortedList(i),j->RankOfTransformation(j,3)
> = RankOfTransformation(Representative(i),3)));
true
gap> ForAll(GreensHClasses(t3),
> i->ForAll(AsSSortedList(i),j->ImageSetOfTransformation(j,3)
> = ImageSetOfTransformation(Representative(i),3)   
> and KernelOfTransformation(j,3) = KernelOfTransformation(Representative(i),3)
> ));
true
gap> ForAll(GreensRClasses(t4),
> i->ForAll(AsSSortedList(i),j->KernelOfTransformation(j,4)
> = KernelOfTransformation(Representative(i),4)));
true
gap> ForAll(GreensLClasses(t4),
> i->ForAll(AsSSortedList(i),j->ImageSetOfTransformation(j,4)
> = ImageSetOfTransformation(Representative(i),4)));
true
gap> ForAll(GreensJClasses(t4),
> i->ForAll(AsSSortedList(i),j->RankOfTransformation(j,4)
> = RankOfTransformation(Representative(i),4)));
true
gap> ForAll(GreensHClasses(t4),
> i->ForAll(AsSSortedList(i),j->ImageSetOfTransformation(j,4)
> = ImageSetOfTransformation(Representative(i),4)   
> and KernelOfTransformation(j,4) = KernelOfTransformation(Representative(i),4)
> ));
true
gap> STOP_TEST( "semirel.tst", 1);

#############################################################################
##
#E
