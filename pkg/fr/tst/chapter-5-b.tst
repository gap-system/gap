#############################################################################
##
#W  chapter-5-b.tst                FR Package               Laurent Bartholdi
##
#H  @(#)$Id: chapter-5-b.tst,v 1.2 2008/11/14 11:13:25 gap Exp $
##
#Y  Copyright (C) 2008,  Laurent Bartholdi
##
#############################################################################
##
##  This file tests the functions explained in chapter 5 of the manual
##
#############################################################################

gap> START_TEST("fr:chapter 5 (2/2)");
gap> 
gap> Info(InfoFR,1,"5.1 Creators for MealyMachines and MealyElements (continued)");
#I  5.1 Creators for MealyMachines and MealyElements (continued)
gap> 
gap> Read(Filename(DirectoriesPackageLibrary("fr","tst"),"mealymachines.g"));
gap> Read(Filename(DirectoriesPackageLibrary("fr","tst"),"mealyelements.g"));
gap> Read(Filename(DirectoriesPackageLibrary("fr","tst"),"frelements.g"));
gap> Read(Filename(DirectoriesPackageLibrary("fr","tst"),"frmachines.g"));
gap> 
gap> # Minimization of the non-minimized elements.
gap> for list in mealyel{[1,2,3,4,5, 7,8 ]} do
>   Apply(list[1], Minimized);
> od;
gap> 
gap> Info(InfoFR,1,"5.1.4 AllMealyMachines");
#I  5.1.4 AllMealyMachines
gap> 
gap> ForAll([1..6], n -> Length(AllMealyMachines(n, 1, IsInvertible)) = Factorial(n));
true
gap> Length(AllMealyMachines(2, 2)) = 256;
true
gap> Length(AllMealyMachines(2, 2, IsInvertible)) = 64;
true
gap> Length(AllMealyMachines(2, 2, IsTransitive, IsInvertible)) = 48;
true
gap> Length(AllMealyMachines(2, 2, IsBireversible)) = 12;
true
gap> Length(AllMealyMachines(2, 2, IsInvertible, IsReversible)) = 16;
true
gap> Length(AllMealyMachines(2, 2, IsReversible)) = 64;
true
gap> Length(AllMealyMachines(2, 2, EquivalenceClasses)) = 76;
true
gap> Length(AllMealyMachines(2, 2, IsInvertible, EquivalenceClasses)) = 24;
true
gap> Length(AllMealyMachines(2, 2, IsBireversible, EquivalenceClasses)) = 8;
true
gap> Length(AllMealyMachines(2, 2, IsBireversible, IsTransitive, EquivalenceClasses)) = 5;
true
gap> Length(AllMealyMachines(3, 2, Group((1,2,3)))) = 576;
true
gap> Length(AllMealyMachines(3, 2, Group((1,2,3)), IsSurjective)) = 512;
true
gap> Length(AllMealyMachines(3, 2, Group((1,2,3)), IsBireversible, EquivalenceClasses)) = 12;
true
gap> 
gap> Info(InfoFR,1,"5.2 Operations and Attributes for MealyMachines and MealyElements");
#I  5.2 Operations and Attributes for MealyMachines and MealyElements
gap> 
gap> Info(InfoFR,1,"5.2.1 Draw");
#I  5.2.1 Draw
gap> Info(InfoFR,1,"Not tested");
#I  Not tested
gap> 
gap> Info(InfoFR,1,"5.2.2 Minimized");
#I  5.2.2 Minimized
gap> # already tested in chapter-4-a.tst
gap> MealyMachine([[1,1]],[[1,2]]) = Minimized(MealyMachine([[1,2],[2,1]],[[1,2],[1,2]]));
true
gap> 
gap> Info(InfoFR,1,"5.2.3 DualMachine");
#I  5.2.3 DualMachine
gap> 
gap> ForAll(Flat(mealym{[1,2,3,4,5, 7,8 ]}{[1,2]}), x -> [Size(AlphabetOfFRObject(DualMachine(x))), Size(StateSet(DualMachine(x)))] = [Size(StateSet(x)), Size(AlphabetOfFRObject(x))]);
true
gap> ForAll(Flat(mealym{[1,2,3,4,5, 7,8 ]}{[1,2]}), x -> x = DualMachine(DualMachine(x)));
true
gap> 
gap> Info(InfoFR,1,"5.2.4 IsReversible");
#I  5.2.4 IsReversible
gap> 
gap> ForAll(Flat(mealym{[1,2,3,4,5, 7,8 ]}{[1,2]}), x -> not IsReversible(x));
true
gap> ForAll(Flat(mealym{[1,2,3,4,5]}{[1,2]}), x -> IsInvertible(x));
true
gap> ForAll(Flat(mealym{[7,8]}{[1,2]}), x -> not IsInvertible(x));
true
gap> IsReversible(AleshinMachine);
true
gap> IsReversible(BabyAleshinMachine);
true
gap> 
gap> Info(InfoFR,1,"5.2.5 IsMinimized");
#I  5.2.5 IsMinimized
gap> 
gap> ForAll(Flat(mealym{[1,2,3,4,5, 7,8 ]}{[1,2]}), IsMinimized);
true
gap> IsMinimized(MealyMachine([[1,1]],[[1,2]]));
true
gap> not IsMinimized(MealyMachine([[1,2],[2,1]],[[1,2],[1,2]]));
true
gap> 
gap> Info(InfoFR,1,"5.2.6 AlphabetInvolution");
#I  5.2.6 AlphabetInvolution
gap> 
gap> AlphabetInvolution(GammaPQMachine(3,5));
[ 6, 5, 4, 3, 2, 1 ]
gap> AlphabetInvolution(GammaPQMachine(5,7));
[ 8, 7, 6, 5, 4, 3, 2, 1 ]
gap> 
gap> Info(InfoFR,1,"5.2.7 IsBireversible");
#I  5.2.7 IsBireversible
gap> 
gap> ForAll(Flat(mealym{[1,2,3,4,5, 7,8 ]}{[1,2]}), x -> not IsBireversible(x));
true
gap> IsBireversible(AleshinMachine);
true
gap> IsBireversible(BabyAleshinMachine);
true
gap> 
gap> Info(InfoFR,1,"5.2.8 StateGrowth");
#I  5.2.8 StateGrowth
gap> 
gap> x := Indeterminate(Rationals, "x");
x
gap> AsSet(List(Flat(mealym), StateGrowth));
[ (3)/(-x+1), (2*x+3)/(-x^2-x+1), (1)/(-x+1),
  (79228162514264337593543950336*x+237684487542793012780631851008)/(-158456325\
028528675187087900672*x^2-396140812571321687967719751680*x+7922816251426433759\
3543950336), (702464)/(-2458624*x+351232), (x+4)/(-x+1) ]
gap> AsSet(List(Flat(mealyel), StateGrowth));
[ 0, (-1)/(-x^3+2*x-1), (2*x^2+2*x+1)/(-x^3+1), (-2*x-1)/(x^2-1),
  (x+1)/(-x^2-x+1), (1)/(-x+1),
  (-4398046511104*x-4398046511104)/(8796093022208*x^2+21990232555520*x-4398046\
511104), (-1792)/(12544*x-1792),
  (524288*x-524288)/(1048576*x^2+2621440*x-524288), (x^3+2*x^2+x+1)/(-x^3+1),
  (x^3+x^2+2*x+1)/(-x^3+1), (x+1)/(-x+1), (x^3+2*x^2+x+1)/(-x^3+1),
  (x^3+x^2+2*x+1)/(-x^3+1), (x+1)/(-x+1), (x^3+2*x^2+x+1)/(-x^3+1),
  (x^3+x^2+2*x+1)/(-x^3+1), (-x^2-x-1)/(x^2-1), (x+1)/(-x+1), 1 ]
gap> List(GeneratorsOfGroup(AleshinGroup), StateGrowth) = [1/(1-2*x),1/(1-2*x),1/(1-2*x)];
true
gap> 
gap> Info(InfoFR,1,"5.2.9 Degree");
#I  5.2.9 Degree
gap> 
gap> AsSet(List(Flat(mealym), Degree)) = [1,infinity];
#I  Degree: converting to Mealy machine
#I  Degree: converting to Mealy machine
#I  Degree: converting to Mealy machine
#I  Degree: converting to Mealy machine
#I  Degree: converting to Mealy machine
#I  Degree: converting to Mealy machine
#I  Degree: converting to Mealy machine
#I  Degree: converting to Mealy machine
#I  Degree: converting to Mealy machine
#I  Degree: converting to Mealy machine
#I  Degree: converting to Mealy machine
#I  Degree: converting to Mealy machine
#I  Degree: converting to Mealy machine
true
gap> List(Flat(mealyel), Degree) = [ -1, 0, 1, 1, 1, -1, 0, 1, 1, 1, -1, 0, 1, 1, 1, -1, 0, 1, 1, 1, -1, 0, 1, 1, 1, 0, 1, 1, -1, 0, 1, 1, -1, 0, 1, 1, -1, 0, 1, 1, -1, 0, 1, 1, -1, 0, 1, 1, -1, 0, 1, 1, -1, 0, 1, 1, -1, 0, 1, 1, -1, 0, 1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, infinity, infinity, infinity, -1, infinity, infinity, infinity, -1, infinity, infinity, infinity, -1, infinity, infinity, infinity, -1, infinity, infinity, infinity, -1, infinity, 1, infinity, -1, infinity, 1, infinity, -1, infinity, 1, infinity, -1, infinity, 1, infinity, -1, infinity, 1, infinity, -1, infinity, infinity, infinity, infinity, infinity, infinity, infinity, infinity, infinity, infinity ];
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
#I  Degree: converting to Mealy element
true
gap> m := MealyMachine([[1,1],[1,1],[1,3],[3,4]],[[1,2],[2,1],[2,1],[1,2]]);
<Mealy machine on alphabet [ 1 .. 2 ] with 4 states>
gap> List(m{[1..4]}, Degree) = [-1..2];
true
gap> m := MealyMachine([[1,1],[1,1],[3,2],[4,3],[5,4]],[[1,2],[2,1],[1,2],[1,2],[1,2]]);
<Mealy machine on alphabet [ 1 .. 2 ] with 5 states>
gap> List(m{[1..5]}, Degree) = [-1..3];
true
gap> 
gap> Info(InfoFR,1,"5.2.10 IsFinitaryFRElement/Machine");
#I  5.2.10 IsFinitaryFRElement/Machine
gap> 
gap> Collected(List(Filtered(Flat(mealyel), x -> IsFinitaryFRElement(x) and not IsOne(x)), Depth)) = [[1,15]];
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
true
gap> 
gap> AsSet(List(Flat(mealym), IsFinitaryFRMachine)) = [false];
true
gap> Collected(List(Flat(mealyel), IsFinitaryFRElement)) = [[true,45],[false, 80]];
true
gap> t := AddingElement(3);
AddingElement(3)
gap> a := GeneratorsOfGroup(FullSCGroup(Group((1,2,3)),1))[1];
<Mealy element on alphabet [ 1 .. 3 ] with 2 states>
gap> not IsFinitaryFRElement(t);
true
gap> IsFinitaryFRElement(a);
true
gap> IsFinitaryFRElement(DiagonalElement([1,5,8,13],a));
true
gap> not IsFinitaryFRMachine(UnderlyingFRMachine(t));
true
gap> IsFinitaryFRMachine(UnderlyingFRMachine(a));
true
gap> IsFinitaryFRMachine(UnderlyingFRMachine(DiagonalElement([1,5,8,13],a)));
true
gap> IsFinitaryFRMachine(UnderlyingFRMachine(AsMealyElement(One(FullSCGroup([1,2])))));
true
gap> 
gap> Info(InfoFR,1,"5.2.11 Depth");
#I  5.2.11 Depth
gap> 
gap> Depth(t) = infinity;
true
gap> Depth(a) = 1;
true
gap> Depth(DiagonalElement([1,5,8,13],a)) = 5;
true
gap> Depth(UnderlyingFRMachine(t)) = infinity;
true
gap> Depth(UnderlyingFRMachine(a)) = 1;
true
gap> Depth(UnderlyingFRMachine(DiagonalElement([1,5,8,13],a))) = 5;
true
gap> Depth(UnderlyingFRMachine(AsMealyElement(One(FullSCGroup([1,2]))))) = 0;
true
gap> AsSet(List([2..10], i -> Depth(One(FullSCGroup([1..i]))))) = [0];
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
#I  Depth: converting to Mealy element
true
gap> 
gap> Info(InfoFR,1,"5.2.12 IsBoundedFRElement/Machine");
#I  5.2.12 IsBoundedFRElement/Machine
gap> 
gap> Collected(List(Flat(mealym), IsBoundedFRMachine)) = [ [ true, 16 ], [ false, 12 ] ];
true
gap> Collected(List(Flat(mealyel), IsBoundedFRElement)) = [ [ true, 90 ], [ false, 35 ] ];
true
gap> 
gap> Info(InfoFR,1,"5.2.13 IsPolynomialGrowthFRElement/Machine");
#I  5.2.13 IsPolynomialGrowthFRElement/Machine
gap> 
gap> Collected(List(Flat(mealym), IsPolynomialGrowthFRMachine)) = [ [ true, 16 ], [ false, 12 ] ];
true
gap> Collected(List(Flat(mealyel), IsPolynomialGrowthFRElement)) = [ [ true, 90 ], [ false, 35 ] ];
true
gap> 
gap> Info(InfoFR,1,"5.2.14 Signatures");
#I  5.2.14 Signatures
gap> 
gap> List(Flat(mealyel{[1..5]}{[2]}), Signatures) = [PeriodicList([],[()]), PeriodicList([(1,2)],[()]), PeriodicList([],[(),(1,2),(1,2)]), PeriodicList([()],[(1,2),(),(1,2)]), PeriodicList([()], [(),(1,2),(1,2)]), PeriodicList([(1,5)(2,6)(3,7)(4,8)],[()]), PeriodicList([],[(1,3)(2,4)(5,6)]), PeriodicList([(1,3)(2,4)],[(1,7,3,5)(2,8,4,6)]), PeriodicList([],[()]), PeriodicList([(1,2)],[()]), PeriodicList([],[(),(1,2)]), PeriodicList([()],[(),(1,2)]), PeriodicList([],[()]), PeriodicList([],[(1,2,3,4,5)]), PeriodicList([],[()]), PeriodicList([(1,2,3,4,5),(1,6)(2,4,3,5),(1,6,4)(2,5,3),(1,4,2)(3,5,6),(1,3)(4,5),(1,2,5)(3,6,4),(1,5,6,4,3)],[(1,3,4)(2,5,6)]), PeriodicList([(1,4)(2,3),(1,6)(2,4,3,5),(1,6,4)(2,5,3),(1,4,2)(3,5,6),(1,3)(4,5),(1,2,5)(3,6,4),(1,5,6,4,3)],[(1,3,4)(2,5,6)]), PeriodicList([(1,6,3)(2,5),(1,6,4,5,3,2)],[(1,3,5,6,2,4),(1,3,5,6,2,4),(1,3,5,6,2,4),(1,3,4,6,2,5),(1,3,4,6,2,5),(1,3,4,6,2,5),(1,2,4,6,3,5),(1,2,4,6,3,5),(1,2,4,6,3,5)]), PeriodicList([],[()])];
true
gap> 
gap> Info(InfoFR,1,"5.2.15 VertexTransformations");
#I  5.2.15 VertexTransformations
gap> 
gap> ForAll(Flat(mealyel{[1..5]}{[2]}), x -> ForAll(Signatures(x), y -> y in VertexTransformationsFRElement(x)));
true
gap> List(Flat(mealym{[1,2,3,4,5]}{[2]}), VertexTransformationsFRMachine) = [SymmetricGroup(2), SylowSubgroup(SymmetricGroup(8), 2), SymmetricGroup(2), CyclicGroup(IsPermGroup,5), SymmetricGroup(6)];
true
gap> List(Flat(mealym{[7,8]}{[2]}), VertexTransformationsFRMachine) = [Monoid(List(Tuples([1,2],2), Transformation)), Monoid(Transformation([2,5,4,7,7,4,3]), Transformation([3,1,6,7,4,7,1]))];
true
gap> 
gap> Info(InfoFR,1,"5.2.16 FixedRay");
#I  5.2.16 FixedRay
gap> 
gap> List(Flat(mealyel[1][1]), FixedRay) = [PeriodicList([],[1]), fail, PeriodicList([2,2],[1]), PeriodicList([2,],[1]), PeriodicList([],[1])];
true
gap> List(Flat(mealyel[2][1]), FixedRay) = [fail, PeriodicList([7],[1]), PeriodicList([5],[1]), PeriodicList([],[1])];
true
gap> List(Flat(mealyel[7][1]), FixedRay) = [PeriodicList([],[1]), fail, PeriodicList([2],[1]), PeriodicList([],[1])];
true
gap> 
gap> Info(InfoFR,1,"5.2.17 IsLevelTransitive");
#I  5.2.17 IsLevelTransitive
gap> 
gap> Collected(List(Flat(mealyel{[1,2,3,4,5]}[2]), IsLevelTransitive)) = [[true,1],[false,18]];
true
gap> 
gap> Info(InfoFR,1,"5.2.18 AsMealyMachine");
#I  5.2.18 AsMealyMachine
gap> # tested in chapter-5-a.tst
gap> 
gap> Info(InfoFR,1,"5.2.19 AsMealyMachine");
#I  5.2.19 AsMealyMachine
gap> 
gap> AsMealyMachine(frel[1][1]) = mealym[1][1];
true
gap> ForAll([2..5], i -> AsMealyMachine(Concatenation(frel[i][1], [One(frel[i][1][1])])) = mealym[i][1]);
true
gap> AsMealyMachine(Concatenation(frel[7][1], [One(frel[7][1][1])])) = mealym[7][1];
true
gap> AsMealyMachine(frel[8][1]) = mealym[8][1];
true
gap> 
gap> Info(InfoFR,1,"5.2.20 AsMealyElement");
#I  5.2.20 AsMealyElement
gap> # tested in chapter-5-a.tst
gap> 
gap> Info(InfoFR,1,"5.2.21 AsIntMealyMachine");
#I  5.2.21 AsIntMealyMachine
gap> # tested in chapter-5-a.tst
gap> 
gap> Info(InfoFR,1,"5.2.22 TopElement");
#I  5.2.22 TopElement
gap> 
gap> TopElement((1,2)) = mealyel[1][2][2];
true
gap> TopElement((1,5)(2,6)(3,7)(4,8)) = mealyel[2][2][1];
true
gap> One(mealyel[4][2][1]) = TopElement((),5);
true
gap> One(mealyel[4][2][1]) = TopElement(Transformation([1..5]));
true
gap> perm := Random(SymmetricGroup(5));
(2,4,3)
gap> ComposeElement(ListWithIdenticalEntries(5, One(mealym[4][2][1])), perm) = TopElement(perm, 5);
true
gap> Activity(TopElement(Transformation([3,2,2]), 4)) = Trans([3,2,2,4]);
true
gap> 
gap> Info(InfoFR,1,"5.2.23 ConfinalityClasses, IsWeaklyFinitaryFRElement");
#I  5.2.23 ConfinalityClasses, IsWeaklyFinitaryFRElement
gap> 
gap> Concatenation(List(mealyel[1][2], ConfinalityClasses)) = [];
true
gap> Concatenation(List(frel[1][2], ConfinalityClasses)) = [];
true
gap> Elements(ConfinalityClasses(mealyel[4][2][1])[1]) = [PeriodicList([],[1]), PeriodicList([],[5])];
true
gap> Set(List(Concatenation(mealyel{[1..3]}[2]), IsWeaklyFinitaryFRElement)) = [true];
true
gap> List(mealyel[4][2], IsWeaklyFinitaryFRElement) = [false, true];
true
gap> List(mealyel[7][2], IsWeaklyFinitaryFRElement) = [false, false, false, true];
true
gap> 
gap> Info(InfoFR,1,"5.2.24 Germs, NormOfBoundedFRElement");
#I  5.2.24 Germs, NormOfBoundedFRElement
gap> 
gap> Set(List(Concatenation(mealyel{[1..3]}[2]), Germs)) = [[], [[PeriodicList([],[2]),PeriodicList([],[1,3])]], [[PeriodicList([],[2]),PeriodicList([],[1,3,5])]], [[PeriodicList([],[8]),PeriodicList([],[1])]]];
true
gap> Collected(List(Concatenation(mealyel{[1..3]}[2]), NormOfBoundedFRElement)) = [[0,6],[1,7]];
true
gap> Germs(mealyel[4][2][1]) = [[PeriodicList([],[5]),PeriodicList([],[1])]];
true
gap> List(mealyel[4][2], NormOfBoundedFRElement) = [1, 0];
true
gap> List(mealyel[7][2], Germs) = [fail, [[PeriodicList([],[1]),PeriodicList([],[1])]], fail, []];
true
gap> List(mealyel[7][2], NormOfBoundedFRElement) = [infinity, 1, infinity, 0];
true
gap> 
gap> Info(InfoFR,1,"5.2.25 HasOpenSetCondition");
#I  5.2.25 HasOpenSetCondition
gap> 
gap> Collected(List(Flat(mealyel{[1..4]}[2]), HasOpenSetConditionFRElement)) = [[true, 8], [false, 7]];
true
gap> 
gap> Info(InfoFR,1,"5.2.26 LimitMachine");
#I  5.2.26 LimitMachine
gap> 
gap> List(List(mealym{[1,2,3,4,5,7,8]}[2], LimitMachine), x -> Size(StateSet(x))) = [5,4,4,2,4,4,2];
true
gap> 
gap> Info(InfoFR,1,"5.2.27 NucleusMachine");
#I  5.2.27 NucleusMachine
gap> 
gap> isoMealyMachine := function(m,n) local a,b; a :=
> SubFRMachine(m,n); b := SubFRMachine(n,m); if b<>fail then return a;
> fi; end;
function( m, n ) ... end
gap> 
gap> ForAll(Flat(mealym{[1,2,3,4]}{[1,2]}), x -> isoMealyMachine(NucleusMachine(x), NucleusMachine(SCSemigroup(x))) <> fail);
true
gap> ForAll(Flat(mealym{[1,2,3,4]}{[1,2]}), x -> isoMealyMachine(Minimized(LimitMachine(x*NucleusMachine(x))), NucleusMachine(x)) <> fail);
true
gap> ForAll(Flat(mealym{[1,2,3,4]}{[1,2]}), x -> isoMealyMachine(Minimized(LimitMachine(NucleusMachine(x)*x)), NucleusMachine(x)) <> fail);
true
gap> 
gap> Info(InfoFR,1,"5.2.28 GuessMealyElement");
#I  5.2.28 GuessMealyElement
gap> Info(InfoFR,1,"Not tested");
#I  Not tested
gap> 
gap> STOP_TEST( "chapter-5-b.tst", 5*10^8 );

#E chapter-5-b.tst . . . . . . . . . . . . . . . . . . . . . . . . . . ends here