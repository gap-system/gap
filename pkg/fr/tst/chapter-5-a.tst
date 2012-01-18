#############################################################################
##
#W  chapter-5-a.tst                FR Package               Laurent Bartholdi
##
#H  @(#)$Id: chapter-5-a.tst,v 1.4 2011/09/20 11:45:35 gap Exp $
##
#Y  Copyright (C) 2008,  Laurent Bartholdi
##
#############################################################################
##
##  This file tests the functions explained in chapter 5 of the manual
##
#############################################################################

gap> START_TEST("fr:chapter 5 (1/2)");
gap> 
gap> Info(InfoFR,1,"5.1 Creators for MealyMachines and MealyElements");
#I  5.1 Creators for MealyMachines and MealyElements
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
gap> Info(InfoFR,1,"5.1.1-3 MealyMachine/Element(NC)");
#I  5.1.1-3 MealyMachine/Element(NC)
gap> 
gap> # machines
gap> 
gap> ForAll([1..5], i -> ForAll(mg[i], m -> ForAll(mealym[i]{[1,2]}, mealy -> AsMealyMachine(m) = mealy)));
true
gap> ForAll([7,8], i -> ForAll(mm[i], m -> ForAll(mealym[i]{[1,2]}, mealy -> AsMealyMachine(m) = mealy)));
true
gap> 
gap> ForAll([1..5], i -> ForAll(mg[i], m -> ForAll(mealym[i]{[1..3]}, mealy -> AsMealyMachine(m) = AsIntMealyMachine(mealy))));
true
gap> ForAll([1,2,3, 5], i -> ForAll(mg[i], m -> SubFRMachine(AsMealyMachine(m), AsIntMealyMachine(mealym[i][4])) <> fail and SubFRMachine(AsIntMealyMachine(mealym[i][4]), AsMealyMachine(m)) <> fail));
true
gap> # machine 4 is special because we need to relabel the tree...
gap> ForAll([7,8], i -> ForAll(mm[i], m -> ForAll(mealym[i]{[1..3]}, mealy -> AsMealyMachine(m) = AsIntMealyMachine(mealy))));
true
gap> ForAll([7,8], i -> ForAll(mm[i], m -> SubFRMachine(AsMealyMachine(m), AsIntMealyMachine(mealym[i][4])) <> fail and SubFRMachine(AsIntMealyMachine(mealym[i][4]), AsMealyMachine(m)) <> fail));
true
gap> 
gap> ForAll(mealym{[1,2,3,4,5]}, list -> ForAll(list{[1..3]}, m -> list[1] = AsIntMealyMachine(m)));
true
gap> ForAll(mealym{[1,2,3, 5]}, list -> SubFRMachine(AsIntMealyMachine(list[4]), list[1]) <> fail and SubFRMachine(list[1], AsIntMealyMachine(list[4])) <> fail);
true
gap> # machine 4 is special because we need to relabel the tree...
gap> ForAll(mealym{[7,8]}, list -> ForAll(list{[1..3]}, m -> list[1] = AsIntMealyMachine(m)));
true
gap> ForAll(mealym{[7,8]}, list -> SubFRMachine(AsIntMealyMachine(list[4]), list[1]) <> fail and SubFRMachine(list[1], AsIntMealyMachine(list[4])) <> fail);
true
gap> 
gap> # elements
gap> 
gap> ForAll([1], i -> ForAll(frel[i], frelts -> ForAll(mealyel[i], mealyelts -> List(frelts, AsMealyElement) = List(mealyelts, AsIntMealyElement))));
true
gap> ForAll([2,3, 5], i -> ForAll(frel[i], frelts -> ForAll(mealyel[i], mealyelts -> List(Concatenation(frelts, [One(frelts[1])]), AsMealyElement) = List(mealyelts, AsIntMealyElement))));
true
gap> ForAll([4], i -> ForAll(frel[i], frelts -> ForAll(mealyel[i]{[1,2,3, 5]}, mealyelts -> List(Concatenation(frelts, [One(frelts[1])]), AsMealyElement) = List(mealyelts, AsIntMealyElement))));
true
gap> 
gap> ForAll([7], i -> ForAll(frel[i], frelts -> ForAll(mealyel[i], mealyelts -> List(Concatenation(frelts, [One(frelts[1])]), AsMealyElement) = List(mealyelts, AsIntMealyElement))));
true
gap> ForAll([8], i -> ForAll(frel[i], frelts -> ForAll(mealyel[i], mealyelts -> List(frelts, AsMealyElement) = List(mealyelts, AsIntMealyElement))));
true
gap> 
gap> for machine in mealyel{[1,2,3, 5]} do
>   Print(ForAll(machine, elts -> ForAll(elts, el -> AsIntMealyElement(el) = machine[1][Position(elts, el)])), "\n");
> od;
true
true
true
true
gap> ForAll(mealyel[4]{[1,2,3, 5]}, elts -> ForAll(elts, el -> AsIntMealyElement(el) = mealyel[4][1][Position(elts, el)]));
true
gap> for machine in mealyel{[7,8]} do
>   Print(ForAll(machine, elts -> ForAll(elts, el -> AsIntMealyElement(el) = machine[1][Position(elts, el)])), "\n");
> od;
true
true
gap> 
gap> Length(AsSet(Concatenation(List(Flat(mealyel{[1,3]}), AsIntMealyElement), List(Flat(mealyel[7]), AsIntMealyElement)))) = 10;
true
gap> ForAll(mealyel{[2,5]}, list -> Length(AsSet(List(Flat(list), AsIntMealyElement))) = Length(list[1]));
true
gap> ForAll(mealyel{[4]}, list -> Length(AsSet(List(Flat(list), AsIntMealyElement))) = Length(list[1])+1); # again, the alphabet...
true
gap> ForAll(mealyel{[7,8]}, list -> Length(AsSet(List(Flat(list), AsIntMealyElement))) = Length(list[1]));
true
gap> 
gap> Info(InfoFR,1,"We now test the functions already tested on FRMachines");
#I  We now test the functions already tested on FRMachines
gap> 
gap> Info(InfoFR,1,"3.3.3 UnderlyingFRMachine, ...");
#I  3.3.3 UnderlyingFRMachine, ...
gap> 
gap> ForAll([1,2,3,4,5,6], i -> ForAll([1..Size(frel[i][1])], j -> UnderlyingFRMachine(frel[i][1][j]) = mg[i][1]));
true
gap> ForAll([7,8,9], i -> ForAll([1..Size(frel[i][1])], j -> UnderlyingFRMachine(frel[i][1][j]) = mm[i][1]));
true
gap> 
gap> Info(InfoFR,1,"3.3.4 AsGroupFRMachine, ...");
#I  3.3.4 AsGroupFRMachine, ...
gap> 
gap> # loops testing AsGroupFRMachine, AsMonoidFRMachine and AsSemigroupFRMachine
gap> b := Ball(GrigorchukGroup,2);;
gap> bg := List(b,AsGroupFRElement);;
gap> bm := List(b,AsMonoidFRElement);;
gap> bs := List(b,AsSemigroupFRElement);;
gap> N := [1..Length(b)];;
gap> ForAll(N,i->ForAll(N,j->(b[i]<b[j])=(i<j)));
true
gap> ForAll(N,i->ForAll(N,j->(b[i]=b[j])=(i=j)));
true
gap> ForAll(N,i->ForAll(N,j->(b[i]<bg[j])=(i<j)));
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
#I  \<: converting first argument to FR element
true
gap> ForAll(N,i->ForAll(N,j->(b[i]=bg[j])=(i=j)));
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
#I  \=: converting first argument to FR element
true
gap> ForAll(N,i->ForAll(N,j->(bg[i]<b[j])=(i<j)));
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
#I  \<: converting second argument to FR element
true
gap> ForAll(N,i->ForAll(N,j->(bg[i]=b[j])=(i=j)));
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
#I  \=: converting second argument to FR element
true
gap> ForAll(N,i->ForAll(N,j->(bg[i]<bg[j])=(i<j)));
true
gap> ForAll(N,i->ForAll(N,j->(bg[i]=bg[j])=(i=j)));
true
gap> ForAll(N,i->ForAll(N,j->(bm[i]<bm[j])=(i<j)));
true
gap> ForAll(N,i->ForAll(N,j->(bm[i]=bm[j])=(i=j)));
true
gap> 
gap> for i in [1..5] do
>   Print("Machine ",i,": ");
>   Print(ForAll(mealym[i]{[1,2]}, m -> AsGroupFRMachine(m) = mg[i][1]), "\n");
> od;
Machine 1: false
Machine 2: true
Machine 3: true
Machine 4: true
Machine 5: true
gap> # 1 is not ok because we have the identity in mg[1][1]
gap> for i in [1..5] do
>   Print("Machine ",i,": ");
>   Print(ForAll(mealym[i]{[3,4]}, m -> AsGroupFRMachine(AsIntMealyMachine(m)) = mg[i][1]), "\n");
> od;
Machine 1: false
Machine 2: true
Machine 3: true
Machine 4: false
Machine 5: true
gap> # same as above, and for 4 it is a problem with the alphabet
gap> ForAll(mealym[1]{[1,2]}, m -> SubFRMachine(mg[1][1], AsGroupFRMachine(m)) <> fail);
true
gap> for i in [7,8] do
>   Print("Machine ",i,": ");
>   Print(ForAll(mealym[i]{[1,2]}, m -> AsMonoidFRMachine(m) = mm[i][1]), "\n");
> od;
Machine 7: true
Machine 8: true
gap> for i in [7,8] do
>   Print("Machine ",i,": ");
>   Print(AsMonoidFRMachine(mealym[i][3]) = mm[i][1] and SubFRMachine(AsMonoidFRMachine(mealym[i][4]), mm[i][1]) <> fail and SubFRMachine(mm[i][1], AsMonoidFRMachine(mealym[i][4])) <> fail, "\n");
> od;
Machine 7: true
Machine 8: true
gap> for i in [1,2,3, 5] do
>   Print("Machine ",i,": ");
>   Print(ForAll(mealym[i], m -> SubFRMachine(AsSemigroupFRMachine(m), msiu[i][1]) <> fail and SubFRMachine(msiu[i][1], AsSemigroupFRMachine(m)) <> fail), "\n");
> od;
Machine 1: true
Machine 2: true
Machine 3: true
Machine 5: false
gap> ForAll(mealym[5], m -> SubFRMachine(msiu[5][1], AsSemigroupFRMachine(m)) <> fail);
true
gap> for i in [7,8] do
>   Print("Machine ",i,": ");
>   Print(ForAll(mealym[i], m -> SubFRMachine(AsSemigroupFRMachine(m), msu[i][1]) <> fail and SubFRMachine(msu[i][1], AsSemigroupFRMachine(m)) <> fail), "\n");
> od;
Machine 7: true
Machine 8: false
gap> ForAll(mealym[8], m -> SubFRMachine(msu[8][1], AsSemigroupFRMachine(m)) <> fail);
true
gap> 
gap> Info(InfoFR,1,"3.3.5 ChangeFRMachineBasis");
#I  3.3.5 ChangeFRMachineBasis
gap> 
gap> # only implemented for groupFRMachine
gap> 
gap> Info(InfoFR,1,"3.4 Attributes of FRMachines");
#I  3.4 Attributes of FRMachines
gap> 
gap> Info(InfoFR,1,"3.4.1 StateSet, 3.4.2 GeneratorsOfFRMachine");
#I  3.4.1 StateSet, 3.4.2 GeneratorsOfFRMachine
gap> 
gap> nstates := [5,4,4,2,4,0,4,2,0];
[ 5, 4, 4, 2, 4, 0, 4, 2, 0 ]
gap> for i in [1..9] do
>   Print(ForAll(mealym[i], m -> GeneratorsOfFRMachine(m) = StateSet(m))," ", ForAll(mealym[i], m -> Size(StateSet(m)) = nstates[i]), "\n");
> od;
true true
true true
true true
true true
true true
true true
true true
true true
true true
gap> 
gap> Info(InfoFR,1,"3.4.3 Output");
#I  3.4.3 Output
gap> 
gap> for i in [1,2,3,4,5, 7,8 ] do
>   Print(ForAll(mealym[i]{[1,2]}, m -> List(GeneratorsOfFRMachine(m), g -> Output(m, g)) = outputsm[i]), "\n");
> od;
true
true
true
true
true
true
true
gap> for i in [1,2,3,    7,8 ] do
>   Print(ForAll(mealym[i]{[3,4]}, m -> List(GeneratorsOfFRMachine(m), g -> List(AlphabetOfFRObject(m), x -> x^Output(m, g))) = List(outputsm[i], s -> List([1..Size(AlphabetOfFRObject(m))], x -> AsList(AlphabetOfFRObject(m))[s[x]]))), "\n");
> od;
true
true
true
true
true
gap> 
gap> Info(InfoFR,1,"3.4.4 Transition");
#I  3.4.4 Transition
gap> 
gap> for i in [1,2,3,4,5, 7,8 ] do
>   Print(ForAll(mealym[i]{[1,2,3]}, m -> List(GeneratorsOfFRMachine(m), s -> List(AlphabetOfFRObject(m), x -> Transition(m, s, x))) = transitionsm[i]), "\n");
> od;
true
true
true
true
true
true
true
gap> for i in [1,2,3, 5, 7,8 ] do
>   Print(ForAll(mealym[i]{[4]}, m -> List(GeneratorsOfFRMachine(m), s -> List(AlphabetOfFRObject(m), x -> Transition(m, s, x))) = List(transitionsm[i], s -> List(s, x -> AsList(StateSet(m))[x]))), "\n");
> od;
true
true
true
true
true
true
gap> 
gap> m := mealym[1][1];
<Mealy machine on alphabet [ 1 .. 2 ] with 5 states>
gap> f := StateSet(m);
[ 1 .. 5 ]
gap> Transition(m, f[3], ListWithIdenticalEntries(30, 2)) = 3;
true
gap> Transition(m, f[3], Concatenation(ListWithIdenticalEntries(31, 2), [1])) = 2;
true
gap> m := mealym[2][1];
<Mealy machine on alphabet [ 1 .. 8 ] with 4 states>
gap> f := StateSet(m);
[ 1 .. 4 ]
gap> Transition(m, f[3], ListWithIdenticalEntries(30, 8)) = 3;
true
gap> 
gap> Info(InfoFR,1,"3.4.5 WreathRecursion");
#I  3.4.5 WreathRecursion
gap> 
gap> wr := WreathRecursion(mealym[2][1]);
function( i ) ... end
gap> wr(3) = [[4,4,4,4,4,4,1,3], [3,4,1,2,5,6,7,8]];
true
gap> 
gap> wr := WreathRecursion(mealym[8][1]);
function( i ) ... end
gap> wr(1) = [[1,2,1,2,1,2,1], [2,5,4,7,7,4,3]];
true
gap> 
gap> Info(InfoFR,1,"3.5 Operations of FRMachines");
#I  3.5 Operations of FRMachines
gap> 
gap> Info(InfoFR,1,"3.5.1 StructuralGroup, ...");
#I  3.5.1 StructuralGroup, ...
gap> 
gap> g := StructuralGroup(mealym[1][1]);
<fp group on the generators [ a, b, c, d, e, 1, 2 ]>
gap> m := StructuralMonoid(mealym[1][1]);
<fp monoid on the generators [ a, b, c, d, e, 1, 2 ]>
gap> s := StructuralSemigroup(mealym[1][1]);
<fp semigroup on the generators [ a, b, c, d, e, 1, 2 ]>
gap> RelatorsOfFpGroup(g);
[ a*1*a^-1*1^-1, a*2*a^-1*2^-1, b*2*a^-1*1^-1, b*1*a^-1*2^-1, c*1*b^-1*1^-1, 
  c*2*d^-1*2^-1, d*1*b^-1*1^-1, d*2*e^-1*2^-1, e*1*a^-1*1^-1, e*2*c^-1*2^-1 ]
gap> RelationsOfFpMonoid(m);
[ [ a*1, 1*a ], [ a*2, 2*a ], [ b*2, 1*a ], [ b*1, 2*a ], [ c*1, 1*b ], 
  [ c*2, 2*d ], [ d*1, 1*b ], [ d*2, 2*e ], [ e*1, 1*a ], [ e*2, 2*c ] ]
gap> RelationsOfFpSemigroup(s);
[ [ a*1, 1*a ], [ a*2, 2*a ], [ b*2, 1*a ], [ b*1, 2*a ], [ c*1, 1*b ], 
  [ c*2, 2*d ], [ d*1, 1*b ], [ d*2, 2*e ], [ e*1, 1*a ], [ e*2, 2*c ] ]
gap> 
gap> Info(InfoFR,1,"3.5.2 \\+");
#I  3.5.2 \+
gap> 
gap> m := mealym[1][1] + mealym[3][2];;
gap> Size(StateSet(m)) = 9;
true
gap> SubFRMachine(m, mealym[1][1]) <> fail;
true
gap> SubFRMachine(m, mealym[3][2]) <> fail;
true
gap> Display(m);
    |   1      2   
----+------+------+
  a |  a,1    a,2  
  b |  a,2    a,1  
  c |  b,1    d,2  
  d |  b,1    e,2  
  e |  a,1    c,2  
  f | aa,2   aa,1  
  g |  f,1    h,2  
  h | aa,1    g,2  
 aa | aa,1   aa,2  
----+------+------+
gap> m := mealym[7][1] + mealym[3][2];
<Mealy machine on alphabet [ 1 .. 2 ] with 8 states>
gap> Size(StateSet(m)) = 8;
true
gap> SubFRMachine(m, mealym[7][1]) <> fail;
true
gap> SubFRMachine(m, mealym[3][2]) <> fail;
true
gap> Display(m);
    |   1      2   
----+------+------+
  a |  a,1    c,1  
  b |  b,2    d,1  
  c |  b,2    a,2  
  d |  d,1    d,2  
  e |  h,2    h,1  
  f |  e,1    g,2  
  g |  h,1    f,2  
  h |  h,1    h,2  
----+------+------+
gap> m := mealym[8][1] + mealym[8][2];
<Mealy machine on alphabet [ 1 .. 7 ] with 4 states>
gap> Size(StateSet(m)) = 4;
true
gap> SubFRMachine(m, mealym[8][1]) <> fail;
true
gap> SubFRMachine(m, mealym[8][2]) <> fail;
true
gap> Display(m);
   |  1     2     3     4     5     6     7   
---+-----+-----+-----+-----+-----+-----+-----+
 a | a,2   b,5   a,4   b,7   a,7   b,4   a,3  
 b | b,3   b,1   a,6   b,7   a,4   a,7   b,1  
 c | c,2   d,5   c,4   d,7   c,7   d,4   c,3  
 d | d,3   d,1   c,6   d,7   c,4   c,7   d,1  
---+-----+-----+-----+-----+-----+-----+-----+
gap> 
gap> Info(InfoFR,1,"3.5.3 \\*");
#I  3.5.3 \*
gap> 
gap> SubFRMachine(mealym[1][1]*mealym[3][2], mealym[1][1] + mealym[3][2]) <> fail;
true
gap> Size(StateSet(mealym[1][1]*mealym[3][2])) = 20;
true
gap> SubFRMachine(mealym[7][1]*mealym[3][2], mealym[7][1] + mealym[3][2]) <> fail;
true
gap> Size(StateSet(mealym[7][1]*mealym[3][2])) = 16;
true
gap> Size(StateSet(mealym[8][1]*mealym[8][2])) = 4;
true
gap> 
gap> Info(InfoFR,1,"3.5.4 TensorSumOp");
#I  3.5.4 TensorSumOp
gap> 
gap> ForAll(Flat(mealym{[1,2,3,4,5, 7,8 ]}{[1,2]}), m -> TensorSum(m) = m);
true
gap> m := TensorSum(mealym[3][1],mealym[3][1]);
<Mealy machine on alphabet [ 1 .. 4 ] with 4 states>
gap> Size(AlphabetOfFRObject(m)) = 4;
true
gap> IsMealyMachine(m);
true
gap> Activity(m[1]) = (1,2)(3,4);
true
gap> Size(PermGroup(SCGroup(m), 3)) = Size(PermGroup(SCGroup(mg[3][1]),3));
true
gap> m := TensorSum(mealym[8][1],mealym[8][1]);
<Mealy machine on alphabet [ 1 .. 14 ] with 2 states>
gap> Size(AlphabetOfFRObject(m)) = 14;
true
gap> IsMealyMachine(m);
true
gap> Activity(m[1]) = Trans(Concatenation(List([0,1], i -> ListTrans(Activity(mm[8][1][1])) + 7*i)));
true
gap> Size(TransMonoid(SCMonoid(m), 1)) = Size(TransMonoid(SCMonoid(mm[8][1]),1));
true
gap> m := TensorSum(mealym[8][2],mealym[4][2]);
<Mealy machine on alphabet [ 1 .. 12 ] with 2 states>
gap> Size(AlphabetOfFRObject(m)) = 12;
true
gap> IsMealyMachine(m);
true
gap> Activity(m[1]) = Trans(Concatenation([2,5,4,7,7,4,3], 7+[2,3,4,5,1]));
true
gap> Activity(m[2]) = Trans([3,1,6,7,4,7,1]);
true
gap> 
gap> Info(InfoFR,1,"3.5.5 TensorProductOp");
#I  3.5.5 TensorProductOp
gap> 
gap> ForAll(Flat(mealym{[1,2,3,4,5, 7,8 ]}{[1,2]}), m -> TensorProduct(m) = m);
true
gap> m := TensorProduct(mealym[4][1],mealym[4][1]);
<Mealy machine on alphabet [ 1 .. 25 ] with 2 states>
gap> Size(AlphabetOfFRObject(m)) = 25;
true
gap> IsMealyMachine(m);
true
gap> Activity(m[1],2) = Activity(mealym[4][1][1], 4);
true
gap> PermGroup(SCGroup(m), 1) = PermGroup(SCGroup(mealym[4][1]),2);
true
gap> SubFRMachine(TensorProduct(mealym[1][1],mealym[1][1],mealym[1][2]), mealym[2][1]) <> fail;
true
gap> m := TensorProduct(mealym[7][1],mealym[3][1]);
<Mealy machine on alphabet [ 1 .. 4 ] with 4 states>
gap> Size(AlphabetOfFRObject(m)) = 4;
true
gap> IsMealyMachine(m);
true
gap> Activity(m[1]) = Trans([2,1,1,2]);
true
gap> Size(TransMonoid(SCMonoid(m), 1)) = 6;
true
gap> m := TensorProduct(mealym[8][2],mealym[4][2]);
<Mealy machine on alphabet [ 1 .. 35 ] with 2 states>
gap> Size(AlphabetOfFRObject(m)) = 35;
true
gap> IsMealyMachine(m);
true
gap> ForAll([1,2], n -> Output(m[n]) = Flat(List([1..7], i -> Output(mealym[4][2][Transition(mealym[8][2], n, i)])+(Output(mealym[8][2][n])[i]-1)*5)));
true
gap> ForAll([1,2], n -> WreathRecursion(m)(n)[1] = Flat(List([1..7], i -> List([1..5], j -> Transition(mealym[4][2],Transition(mealym[8][2],n,i),j)))));
true
gap> 
gap> Info(InfoFR,1,"3.5.6 DirectSumOp");
#I  3.5.6 DirectSumOp
gap> 
gap> ForAll(Flat(mealym{[1,2,3,4,5, 7,8 ]}{[1,2]}), m -> DirectSum(m) = m);
true
gap> m := DirectSum(mealym[1][1],mealym[2][1]);
<Mealy machine on alphabet [ 1 .. 10 ] with 9 states>
gap> Size(AlphabetOfFRObject(m)) = 10;
true
gap> Size(StateSet(m)) = 9;
true
gap> IsMealyMachine(m);
true
gap> ForAll([1..5], n -> Output(m[n]) = Concatenation(Output(mealym[1][1][n]), [3..10]));
true
gap> ForAll([1..4], n -> Output(m[5+n]) = Concatenation([1,2], 2+Output(mealym[2][1][n])));
true
gap> ForAll([1..5], n -> WreathRecursion(m)(n)[1] = Concatenation(WreathRecursion(mealym[1][1])(n)[1], ListWithIdenticalEntries(8,n)));
true
gap> ForAll([1..4], n -> WreathRecursion(m)(5+n)[1] = 5+Concatenation([n,n],WreathRecursion(mealym[2][1])(n)[1]));
true
gap> Size(PermGroup(SCGroup(m),2)) = Size(PermGroup(SCGroup(mealym[1][1]),2))*Size(PermGroup(SCGroup(mealym[2][1]),2));
true
gap> m := DirectSum(mealym[4][1],mealym[7][2]);
<Mealy machine on alphabet [ 1 .. 7 ] with 6 states>
gap> Size(AlphabetOfFRObject(m)) = 7;
true
gap> Size(StateSet(m)) = 6;
true
gap> IsMealyMachine(m);
true
gap> Activity(m[1]) = Activity(mm[4][1][1]);
true
gap> Activity(m[3]) = TransList(Concatenation([1,2,3,4,5],ListTrans(Activity(mealym[7][1][1]))+5));
true
gap> ForAll([1..2], n -> WreathRecursion(m)(n)[1] = Concatenation(WreathRecursion(mealym[4][1])(n)[1], ListWithIdenticalEntries(2,n)));
true
gap> ForAll([1..4], n -> WreathRecursion(m)(2+n)[1] = 2+Concatenation([n,n,n,n,n],WreathRecursion(mealym[7][1])(n)[1]));
true
gap> Size(TransMonoid(SCMonoid(m),2)) = Size(TransMonoid(SCMonoid(mealym[4][1]),2))*Size(TransMonoid(SCMonoid(mealym[7][1]),2));
true
gap> m := DirectSum(mealym[1][1],mealym[8][2]);
<Mealy machine on alphabet [ 1 .. 9 ] with 7 states>
gap> Size(AlphabetOfFRObject(m)) = 9;
true
gap> Size(StateSet(m)) = 7;
true
gap> IsMealyMachine(m);
true
gap> Activity(m[2]) = Activity(mealym[1][1][2]);
true
gap> Activity(m[6]) = TransList(Concatenation([1,2],ListTrans(Activity(mealym[8][1][1]))+2));
true
gap> 
gap> Info(InfoFR,1,"3.5.7 DirectProductOp");
#I  3.5.7 DirectProductOp
gap> 
gap> ForAll(Flat(mealym{[1,2,3,4,5, 7,8 ]}{[1,2]}), m -> DirectProduct(m) = m);
true
gap> m := DirectProduct(mealym[1][1],mealym[2][1]);
<Mealy machine on alphabet [ 1 .. 16 ] with 20 states>
gap> Size(AlphabetOfFRObject(m)) = 16;
true
gap> Size(StateSet(m)) = 20;
true
gap> IsMealyMachine(m);
true
gap> Size(PermGroup(SCGroup(m),2)) = Size(PermGroup(SCGroup(mealym[1][1]),2))*Size(PermGroup(SCGroup(mealym[2][1]),2));
true
gap> m := DirectProduct(mealym[7][1],mealym[1][1]);
<Mealy machine on alphabet [ 1 .. 4 ] with 20 states>
gap> Size(AlphabetOfFRObject(m)) = 4;
true
gap> Size(StateSet(m)) = 20;
true
gap> IsMealyMachine(m);
true
gap> Size(TransMonoid(SCMonoid(m),2)) = Size(TransMonoid(SCMonoid(mealym[7][1]),2))*Size(TransMonoid(SCMonoid(mealym[1][1]),2));
true
gap> m := DirectProduct(mealym[8][1],mealym[7][1]);
<Mealy machine on alphabet [ 1 .. 14 ] with 8 states>
gap> Size(AlphabetOfFRObject(m)) = 14;
true
gap> Size(StateSet(m)) = 8;
true
gap> IsMealyMachine(m);
true
gap> Size(TransMonoid(SCMonoid(m),1)) = Size(TransMonoid(SCMonoid(mealym[8][1]),1))*Size(TransMonoid(SCMonoid(mealym[7][1]),1))-3;
true
gap> 
gap> Info(InfoFR,1,"3.5.8 TreeWreathProduct");
#I  3.5.8 TreeWreathProduct
gap> 
gap> m := TreeWreathProduct(mealym[1][1],mealym[3][1],2,2);
<Mealy machine on alphabet [ 1 .. 4 ] with 12 states>
gap> Size(AlphabetOfFRObject(m)) = 4;
true
gap> Size(StateSet(m)) = 12;
true
gap> Collected(Flat(List([1..12], i -> WreathRecursion(m)(i)[1]))){[1..12]}[2] = [1,3,32,1,2,1,1,2,2,1,1,1];
true
gap> m := TreeWreathProduct(mealym[7][1], mealym[8][2],2,5);
<Mealy machine on alphabet [ 1 .. 14 ] with 9 states>
gap> Size(AlphabetOfFRObject(m)) = 14;
true
gap> Size(StateSet(m)) = 9;
true
gap> Collected(Flat(List([1..9], i -> WreathRecursion(m)(i)[1]))){[1..9]}[2] = [7,7,3,3,2,101,1,1,1];
true
gap> 
gap> Info(InfoFR,1,"3.5.9 SubFRMachine");
#I  3.5.9 SubFRMachine
gap> 
gap> # Already tested when testing equality of machines
gap> 
gap> Info(InfoFR,1,"3.5.10 Minimized");
#I  3.5.10 Minimized
gap> 
gap> nbgens := [5,4,4,2,4,0,4,2,0];
[ 5, 4, 4, 2, 4, 0, 4, 2, 0 ]
gap> ForAll([1,2,3,4,5, 7,8 ], i -> Size(StateSet(Minimized(mealym[i][1]))) = nbgens[i]);
true
gap> Size(StateSet(Minimized(mealym[1][1] + mealym[3][2]))) = 7;
true
gap> Size(StateSet(Minimized(AsIntMealyMachine(mealym[1][4] + mealym[1][4])))) = 5;
true
gap> Size(StateSet(Minimized(mealym[7][1] + mealym[7][2]))) = 4;
true
gap> Size(StateSet(Minimized(mealym[3][1] + mealym[7][2]))) = 7;
true
gap> 
gap> Info(InfoFR,1,"3.5.11 Correspondence");
#I  3.5.11 Correspondence
gap> 
gap> m := mealym[1][1];
<Mealy machine on alphabet [ 1 .. 2 ] with 5 states>
gap> min := Minimized(m);
<Mealy machine on alphabet [ 1 .. 2 ] with 5 states>
gap> Permuted([1..5],Correspondence(min)) = [2,4,1,3,5];
true
gap> 
gap> m2 := m + m;
<Mealy machine on alphabet [ 1 .. 2 ] with 10 states>
gap> Correspondence(m2) = [(),Trans([6..10])];
true
gap> min := Minimized(m2);
<Mealy machine on alphabet [ 1 .. 2 ] with 5 states>
gap> Correspondence(min) = Trans([3,1,4,2,5,3,1,4,2,5]);
true
gap> 
gap> m := AsGroupFRMachine(mealym[5][1]);
<FR machine with alphabet [ 1 .. 7 ] on Group( [ f1, f2, f3 ] )>
gap> List([1..4], i -> i^Correspondence(m)) = Concatenation(GeneratorsOfGroup(StateSet(m)), [One(StateSet(m))]);
true
gap> 
gap> Length(AsSet(Concatenation(mealym[1]{[1,2]},mealym[3]{[1,2]},mealym[7]{[1,2]}))) = 3;
true
gap> Length(AsSet([mealym[4][4],mealym[4][4]])) = 1;
true
gap> 
gap> Info(InfoFR,1,"We now test the functions already tested on FRElements");
#I  We now test the functions already tested on FRElements
gap> 
gap> Info(InfoFR,1,"4.1.4 ComposeElement");
#I  4.1.4 ComposeElement
gap> 
gap> e := mealyel[1][1][1];
<Trivial Mealy element on alphabet [ 1 .. 2 ]>
gap> a := mealyel[1][1][2];
<Mealy element on alphabet [ 1 .. 2 ] with 2 states>
gap> b := mealyel[1][1][3];
<Mealy element on alphabet [ 1 .. 2 ] with 5 states>
gap> c := mealyel[1][1][4];
<Mealy element on alphabet [ 1 .. 2 ] with 5 states>
gap> d := mealyel[1][1][5];
<Mealy element on alphabet [ 1 .. 2 ] with 5 states>
gap> ComposeElement([e,e],()) = e;
true
gap> ComposeElement([e,e],(1,2)) = a;
true
gap> ComposeElement([a,c],()) = b;
true
gap> ComposeElement([a,d],()) = c;
true
gap> ComposeElement([e,b],()) = d;
true
gap> ComposeElement([a*c,c*a],()) = (b*a)^2;
true
gap> 
gap> a := mealyel[2][1][1];
<Mealy element on alphabet [ 1 .. 8 ] with 2 states>
gap> b := mealyel[2][1][2];
<Mealy element on alphabet [ 1 .. 8 ] with 2 states>
gap> c := mealyel[2][1][3];
<Mealy element on alphabet [ 1 .. 8 ] with 3 states>
gap> ComposeElement([One(b),One(b),One(b),One(b),One(b),One(b),One(b),b],Output(b)) = b;
true
gap> ComposeElement([One(b),One(b),One(b),One(b),One(b),One(b),a,c],Output(c)) = c;
true
gap> ComposeElement([One(b),One(b),One(b),One(b),One(b),One(b),a,b*c],Output(b){Output(c)}) = b*c;
true
gap> 
gap> a := mealyel[3][1][1];
<Mealy element on alphabet [ 1 .. 2 ] with 2 states>
gap> b1 := mealyel[3][1][2];
<Mealy element on alphabet [ 1 .. 2 ] with 4 states>
gap> b2 := mealyel[3][1][3];
<Mealy element on alphabet [ 1 .. 2 ] with 4 states>
gap> ComposeElement([a,b2],()) = b1;
true
gap> ComposeElement([One(a),b1],()) = b2;
true
gap> n := 15;
15
gap> ComposeElement([(b1*b2*a)^(2^n),(a*b1*b2)^(2^n)],()) = (a*b1*b2)^(2^(n+1));
true
gap> 
gap> t := mealyel[4][1][1];
<Mealy element on alphabet [ 1 .. 5 ] with 2 states>
gap> ComposeElement([One(t),One(t),One(t),t,t],(1,2,3,4,5)^2) = t^2;
true
gap> n := 10;
10
gap> ComposeElement([t^(5^n),t^(5^n),t^(5^n),t^(5^n),t^(5^n)],()) = t^(5^(n+1));
true
gap> 
gap> x := mealyel[5][1][1];
<Mealy element on alphabet [ 1 .. 7 ] with 4 states>
gap> y := mealyel[5][1][2];
<Mealy element on alphabet [ 1 .. 7 ] with 4 states>
gap> z := mealyel[5][1][3];
<Mealy element on alphabet [ 1 .. 7 ] with 4 states>
gap> ComposeElement([x,y,z,x,y,z,One(x)],(1,2,3,4,5)) = x;
true
gap> ComposeElement([x,y,z,One(x),z,y,x],(1,4)(2,3)) = y;
true
gap> ComposeElement([One(x),y,y,x,z,One(x),One(x)],(1,6,3)(2,5)) = z;
true
gap> ComposeElement([x,y*z,z*y,x,z^2,y^2,x^2],()) = y^2;
true
gap> 
gap> z := mealyel[7][1][1];
<Mealy element on alphabet [ 1 .. 2 ] with 4 states>
gap> y := mealyel[7][1][2];
<Mealy element on alphabet [ 1 .. 2 ] with 2 states>
gap> x := mealyel[7][1][3];
<Mealy element on alphabet [ 1 .. 2 ] with 4 states>
gap> ComposeElement([z, x],Transformation([1,1])) = z;
true
gap> ComposeElement([y, One(x)],Transformation([2,1])) = y;
true
gap> ComposeElement([y, One(x)],(1,2)) = y;
true
gap> ComposeElement([y, z],Transformation([2,2])) = x;
true
gap> 
gap> a := mealyel[8][1][1];
<Mealy element on alphabet [ 1 .. 7 ] with 2 states>
gap> b := mealyel[8][1][2];
<Mealy element on alphabet [ 1 .. 7 ] with 2 states>
gap> ComposeElement([a,b,a,b,a,b,a], Transformation([2,5,4,7,7,4,3])) = a;
true
gap> ComposeElement([b,b,a,b,a,a,b], Transformation([3,1,6,7,4,7,1])) = b;
true
gap> ComposeElement([a*b,b*a,a*b,b^2,a*b,b^2,a^2], Transformation([2,5,4,7,7,4,3])*Transformation([3,1,6,7,4,7,1])) = a*b;
true
gap> 
gap> Info(InfoFR,1,"4.1.5 VertexElement");
#I  4.1.5 VertexElement
gap> 
gap> e := mealyel[1][1][1];
<Trivial Mealy element on alphabet [ 1 .. 2 ]>
gap> a := mealyel[1][1][2];
<Mealy element on alphabet [ 1 .. 2 ] with 2 states>
gap> b := mealyel[1][1][3];
<Mealy element on alphabet [ 1 .. 2 ] with 5 states>
gap> c := mealyel[1][1][4];
<Mealy element on alphabet [ 1 .. 2 ] with 5 states>
gap> d := mealyel[1][1][5];
<Mealy element on alphabet [ 1 .. 2 ] with 5 states>
gap> VertexElement([1], a)*VertexElement([2],d) = c;
true
gap> VertexElement(1, a)*VertexElement(2,d) = c;
true
gap> VertexElement([1], a)*VertexElement([2,1], a)*VertexElement([2,2],d) = b;
true
gap> AsSet(List([a,b,c,d], g -> Order(VertexElement([2,2,1,1,2],g)))) = [2];
true
gap> Comm(VertexElement([1,2],a),VertexElement([1,1],a)) = VertexElement(2,e);
true
gap> 
gap> a := mealyel[3][1][1];
<Mealy element on alphabet [ 1 .. 2 ] with 2 states>
gap> b1 := mealyel[3][1][2];
<Mealy element on alphabet [ 1 .. 2 ] with 4 states>
gap> b2 := mealyel[3][1][3];
<Mealy element on alphabet [ 1 .. 2 ] with 4 states>
gap> VertexElement(2,b1) = b2;
true
gap> VertexElement(1,a)*VertexElement([2,2],b1) = b1;
true
gap> 
gap> t := mealyel[4][1][1];
<Mealy element on alphabet [ 1 .. 5 ] with 2 states>
gap> Product([1..5], i -> VertexElement(i,t)) = t^5;
true
gap> 
gap> z := mealyel[7][1][1];
<Mealy element on alphabet [ 1 .. 2 ] with 4 states>
gap> y := mealyel[7][1][2];
<Mealy element on alphabet [ 1 .. 2 ] with 2 states>
gap> x := mealyel[7][1][3];
<Mealy element on alphabet [ 1 .. 2 ] with 4 states>
gap> VertexElement(1,y)*VertexElement(2,y) = y^2;
true
gap> VertexElement([],z) = z;
true
gap> VertexElement([2],x)*y = y*VertexElement([1],x);
true
gap> 
gap> a := mealyel[8][1][1];
<Mealy element on alphabet [ 1 .. 7 ] with 2 states>
gap> b := mealyel[8][1][2];
<Mealy element on alphabet [ 1 .. 7 ] with 2 states>
gap> VertexElement([5,3],a)*VertexElement([5,3],b) = VertexElement([5,3],a*b);
true
gap> 
gap> Info(InfoFR,1,"4.1.6 DiagonalElement");
#I  4.1.6 DiagonalElement
gap> 
gap> a := mealyel[1][1][2];
<Mealy element on alphabet [ 1, 2 ] with 2 states>
gap> DiagonalElement(0,a) = VertexElement(1,a);
true
gap> DiagonalElement(1,a) = VertexElement(1,a)*VertexElement(2,a);
true
gap> DiagonalElement(-1,a) = VertexElement(1,a)*VertexElement(2,a);
true
gap> DiagonalElement(3,a) = DiagonalElement(1,a);
true
gap> 
gap> b := mealyel[2][1][2];
<Mealy element on alphabet [ 1 .. 8 ] with 2 states>
gap> DiagonalElement(2,b) = VertexElement(1,b)*VertexElement(3,b);
true
gap> 
gap> t := mealyel[4][1][1];
<Mealy element on alphabet [ 1 .. 5 ] with 2 states>
gap> DiagonalElement(-1,t) = t^5;
true
gap> DiagonalElement(3,t) = ComposeElement([t, t^-3, t^3, t^-1, t^0], ());
true
gap> 
gap> x := mealyel[5][1][1];
<Mealy element on alphabet [ 1 .. 7 ] with 4 states>
gap> y := mealyel[5][1][2];
<Mealy element on alphabet [ 1 .. 7 ] with 4 states>
gap> z := mealyel[5][1][3];
<Mealy element on alphabet [ 1 .. 7 ] with 4 states>
gap> DiagonalElement(4, x) = ComposeElement([x, x^-4, x^6, x^-4, x^1, x^0, x^0], ());
true
gap> DiagonalElement(-1, y) = ComposeElement(ListWithIdenticalEntries(7, y), ());
true
gap> DiagonalElement(1, z) = Comm(ComposeElement(ListWithIdenticalEntries(7, One(z)),(1,2)),VertexElement(1,z));
true
gap> DiagonalElement(0,x*z) = VertexElement(1,x*z);
true
gap> 
gap> z := mealyel[7][1][1];
<Mealy element on alphabet [ 1 .. 2 ] with 4 states>
gap> y := mealyel[7][1][2];
<Mealy element on alphabet [ 1 .. 2 ] with 2 states>
gap> x := mealyel[7][1][3];
<Mealy element on alphabet [ 1 .. 2 ] with 4 states>
gap> ForAll([x,y,z,x*z*y], g -> DiagonalElement(0,g) = VertexElement(1,g));
true
gap> ForAll([x,y,z,x*y*z], g -> DiagonalElement(-1,g) = VertexElement(1,g)*VertexElement(2,g));
true
gap> 
gap> a := mealyel[8][1][1];
<Mealy element on alphabet [ 1 .. 7 ] with 2 states>
gap> b := mealyel[8][1][2];
<Mealy element on alphabet [ 1 .. 7 ] with 2 states>
gap> ForAll([a,b,(a*b)^2], g -> DiagonalElement(0,g) = VertexElement(1,g));
true
gap> ForAll([a,b,a*b^2*a], g -> DiagonalElement(-1,g) = Product([1..7], i -> VertexElement(i,g)));
true
gap> 
gap> Info(InfoFR,1,"4.1.7 AsGroupFRElement, ...");
#I  4.1.7 AsGroupFRElement, ...
gap> 
gap> # Already tested in "5.1.1-3 MealyMachine/Element(NC)"
gap> 
gap> Info(InfoFR,1,"4.2 Operations and Attributes for FRElements");
#I  4.2 Operations and Attributes for FRElements
gap> 
gap> Info(InfoFR,1,"4.2.1 UnderlyingFRMachine");
#I  4.2.1 UnderlyingFRMachine
gap> 
gap> for i in [1..5] do
>   Print(ForAll(mealyel[i]{[1,2,  5]}, type -> ForAll(type, el -> SubFRMachine(mealym[i][1], UnderlyingFRMachine(el)) <> fail)), "\n");
> od;
true
true
true
true
true
gap> for i in [7..8] do
>   Print(ForAll(mealyel[i]{[1,2,  5]}, type -> ForAll(type, el -> SubFRMachine(mealym[i][1], UnderlyingFRMachine(el)) <> fail)), "\n");
> od;
true
true
gap> 
gap> Info(InfoFR,1,"4.2.2 Output, 4.2.3 OutputInt");
#I  4.2.2 Output, 4.2.3 OutputInt
gap> 
gap> for i in [1,2,3,4,5, 7,8 ] do
>   Print(ForAll(mealyel[i]{[1,2,  5]}, el_list -> List(el_list, Output) = outputsm[i]), "\n");
> od;
true
true
true
true
true
true
true
gap> 
gap> Info(InfoFR,1,"4.2.4 Activity");
#I  4.2.4 Activity
gap> 
gap> for i in [1,2,3,4,5, 7,8 ] do
>   Print(ForAll(mealyel[i]{[1,2,  5]}, el_list -> List(el_list, g -> ListPerm(Activity(g, 1), Size(AlphabetOfFRObject(g)))) = outputsm[i]), "\n");
> od;
true
true
true
true
true
true
true
gap> ForAll([1..3], i -> ListPerm(Activity(mealyel[1][1][i+1], 3), 2^3) = Output(mealyel[2][1][i]));
true
gap> a := mealyel[2][1][1];
<Mealy element on alphabet [ 1 .. 8 ] with 2 states>
gap> b := mealyel[2][1][2];
<Mealy element on alphabet [ 1 .. 8 ] with 2 states>
gap> n := 5;
5
gap> Activity((a*b)^(2^(n+1)), n) = ();
true
gap> Order(Activity(mealyel[4][1][1], n)) = 5^n;
true
gap> Activity(mealyel[5][1][2], 2) = (1,23,2,24,3,25,4,26,5,22)(6,27)(7,28)(8,18,11,15,13,20,10,16,12,19,9,17)(14,
> 21)(29,34,31)(30,33)(36,39)(37,38)(43,44,45,46,47);
true
gap> Activity(mealyel[7][1][3], 2) = Trans([ 4, 3, 3, 3 ]);
true
gap> 
gap> Info(InfoFR,1,"4.2.5 Transition");
#I  4.2.5 Transition
gap> 
gap> for i in [1,2,3,4,5, 7,8 ] do
>   Print(ForAll(mealyel[i]{[1,2,  5]}, el_list -> ForAll(el_list, el -> ForAll([1..Size(AlphabetOfFRObject(el))], input -> Transition(el, input) in StateSet(el) and Transition(el, input) in StateSet(UnderlyingFRMachine(el))))), "\n");
> od;
true
true
true
true
true
true
true
gap> 
gap> Info(InfoFR,1,"4.2.6 Portrait");
#I  4.2.6 Portrait
gap> 
gap> for m in mealyel{[1,2,3,4,5, 7,8 ]}{[1,2,  5]} do
>   Print(ForAll(m, list -> ForAll(list, g -> Portrait(g,1) = [Activity(g), List(AlphabetOfFRObject(g), i -> Activity(State(g, i)))])), "\n");
> od;
true
true
true
true
true
true
true
gap> for m in mealyel{[1,2,3,4,5, 7,8 ]}{[1,2,  5]} do
>   Print(ForAll(m, list -> ForAll(list, g -> PortraitInt(g,1) = [ActivityInt(g), List(AlphabetOfFRObject(g), i -> ActivityInt(State(g, i)))])), "\n");
> od;
true
true
true
true
true
true
true
gap> 
gap> Info(InfoFR,1,"4.2.7 DecompositionOfFRElement");
#I  4.2.7 DecompositionOfFRElement
gap> 
gap> for i in [1..5] do
>   Print(ForAll(mealyel[i]{[1,2,  5]}, el_list -> ForAll(el_list, el -> DecompositionOfFRElement(el) = [List([1..Size(AlphabetOfFRObject(el))], x -> FRElement(mealym[i][1], transitionsm[i][Position(el_list, el)][x])),outputsm[i][Position(el_list, el)]])), "\n");
> od;
true
true
true
true
true
gap> for i in [7..8] do
>   Print(ForAll(mealyel[i]{[1,2,  5]}, el_list -> ForAll(el_list, el -> DecompositionOfFRElement(el) = [List([1..Size(AlphabetOfFRObject(el))], x -> FRElement(mealym[i][1], transitionsm[i][Position(el_list, el)][x])),outputsm[i][Position(el_list, el)]])), "\n");
> od;
true
true
gap> 
gap> Info(InfoFR,1,"4.2.8 StateSet");
#I  4.2.8 StateSet
gap> 
gap> rk := [[1,2,5,5,5],[2,2,3,1],[2,4,4,1],[2,1],[4,4,4,1],[],[4,2,4,1],[2,2],[]];;
gap> for i in [1..9] do
>   Print(ForAll(mealyel[i], el_list -> ForAll([1..Length(el_list)], j -> Size(StateSet(el_list[j])) = rk[i][j])), "\n");
> od;
true
true
true
true
true
true
true
true
true
gap> 
gap> Info(InfoFR,1,"4.2.9 State");
#I  4.2.9 State
gap> 
gap> ForAll(Flat(mealyel{[1,2,3,4,5, 7,8 ]}{[1,2,  5]}), el -> ForAll(Tuples(AlphabetOfFRObject(el),2), w -> State(el, w) = FRElement(UnderlyingFRMachine(el), Transition(el, w))));
true
gap> 
gap> Info(InfoFR,1,"4.2.10 States");
#I  4.2.10 States
gap> 
gap> l := [5,4,4,2,4,-1,4,2,-1];
[ 5, 4, 4, 2, 4, -1, 4, 2, -1 ]
gap> for i in [1,2,3,4,5, 7,8 ] do # 6 and 9 are not finite-state...
>   Print(ForAll(mealyel[i]{[1,2,  5]}, list -> Length(States(list)) = l[i]), "\n");
> od;
true
true
true
true
true
true
true
gap> AsSet(States(mealyel[1][1][3])) = AsSet(mealyel[1][1]);
true
gap> Length(AsSet(States(Concatenation(mealyel[1][1], mealyel[3][1], mealyel[7][1])))) = 10;
true
gap> States(mealyel[3][5][2]) = [mealyel[3][5][2], mealyel[3][5][1], mealyel[3][5][3], One(mealyel[3][5][1])];
true
gap> States(mealyel[4][2][1]^6) = [mealyel[4][2][1]^6,mealyel[4][2][1],mealyel[4][2][1]^2,One(mealyel[4][2][1])];
true
gap> AsSet(States(mealyel[5][3][2])) = AsSet(Concatenation(mealyel[5][3], [One(mealyel[5][3][1])]));
true
gap> States(mealyel[7][2][2]) = [mealyel[7][2][2], One(mealyel[7][2][2])];
true
gap> States(mealyel[8][2][2]) = Reversed(mealyel[8][2]);
true
gap> 
gap> Info(InfoFR,1,"4.2.11 FixedStates");
#I  4.2.11 FixedStates
gap> 
gap> FixedStates(mealyel[1][1][3]) = mealyel[1][1]{[2,4,5,1,3]};
true
gap> FixedStates(mealyel[1][1]) = mealyel[1][1]{[1,2,4,5,3]};
true
gap> FixedStates(mealyel[4][5][1]^10) = [mealyel[4][5][1]^2];
true
gap> FixedStates(mealyel[4][5][1]^25) = [mealyel[4][5][1]^5,mealyel[4][5][1]];
true
gap> FixedStates(mealyel[7][2][3]*mealyel[7][2][1]) = [mealyel[7][2][2]*mealyel[7][2][3],mealyel[7][2][2]];
true
gap> 
gap> Info(InfoFR,1,"4.2.12 LimitStates");
#I  4.2.12 LimitStates
gap> 
gap> for i in [1,2,5] do
>   t := true;
>   t := t and LimitStates(mealyel[1][i][1]) = [mealyel[1][i][1]];
>   t := t and LimitStates(mealyel[1][i][2]) = [mealyel[1][i][1]];
>   t := t and AsSet(LimitStates(mealyel[1][i][3])) = AsSet(mealyel[1][i]);
>   t := t and AsSet(LimitStates(mealyel[2][i][2])) = AsSet([mealyel[2][i][2], One(mealyel[2][i][2])]);
>   t := t and AsSet(LimitStates(mealyel[3][i][2])) = AsSet(Concatenation(mealyel[3][i], [One(mealyel[3][i][1])]));
>   t := t and AsSet(LimitStates(mealyel[4][i][1])) = AsSet(Concatenation(mealyel[4][i], [One(mealyel[4][i][1])]));
>   t := t and ForAll([1..3], j -> AsSet(LimitStates(mealyel[5][i][j])) = AsSet(Concatenation(mealyel[5][i], [One(mealyel[5][i][1])])));
>   t := t and ForAll([1,3], j -> AsSet(LimitStates(mealyel[7][i][j])) = AsSet(Concatenation(mealyel[7][i], [One(mealyel[7][i][1])])));
>   t := t and AsSet(LimitStates(mealyel[7][i][2])) = AsSet([mealyel[7][i][2], One(mealyel[7][i][1])]);
>   t := t and ForAll([1..2], j -> AsSet(LimitStates(mealyel[8][i][j])) = AsSet(mealyel[8][i]));
>   Print(t, "\n");
> od;
true
true
true
gap> 
gap> Info(InfoFR,1,"4.2.13 InitialState");
#I  4.2.13 InitialState
gap> 
gap> ForAll(Flat(mealyel{[1,2,3,4,5, 7,8 ]}{[1,2,  5]}), g -> InitialState(g) = Transition(g,[]));
true
gap> 
gap> Info(InfoFR,1,"4.2.14 \\^");
#I  4.2.14 \^
gap> 
gap> ForAll(Flat(mealyel{[1,2,3,4,5, 7,8 ]}{[1,2,  5]}), g -> ForAll(AlphabetOfFRObject(g), i -> i^g = Output(g)[i]));
true
gap> n := 2;
2
gap> ForAll(Flat(mealyel{[1,2,3,4,5, 7,8 ]}{[1,2,  5]}), g -> ForAll(Tuples(AlphabetOfFRObject(g), n), w -> w^g = Reversed(CoefficientsQadic((List([n-1,n-2..0], i -> Size(AlphabetOfFRObject(g))^i)*(w-ListWithIdenticalEntries(n, 1))+1)^Activity(g, n) - 1, Size(AlphabetOfFRObject(g))) + ListWithIdenticalEntries(n, 1))));
true
gap> 
gap> Info(InfoFR,1,"4.2.15 \\*");
#I  4.2.15 \*
gap> 
gap> Activity(mealyel[7][1][1]*mealyel[1][1][3], 2) = Trans([2,2,1,1]);
true
gap> 
gap> Info(InfoFR,1,"4.2.16 \\[\\]");
#I  4.2.16 \[\]
gap> 
gap> for i in [1,2,3,4,5, 7,8 ] do
>   Print(ForAll(mealym[i]{[1,2]}, m -> ForAll([1..Size(mealyel[i][1])], j -> m[j] = mealyel[i][1][j])), "\n");
> od;
true
true
true
true
true
true
true
gap> for i in [1,2,3,4,5, 7,8 ] do
>   Print(ForAll(mealym[i]{[1,2]}, m -> m{[1..Size(mealyel[i][1])]} = mealyel[i][1]), "\n");
> od;
true
true
true
true
true
true
true
gap> 
gap> STOP_TEST( "chapter-5-a.tst", 2*10^9 );

#E chapter-5-a.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
