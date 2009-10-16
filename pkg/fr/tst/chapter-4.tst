#############################################################################
##
#W  chapter-4.tst                  FR Package               Laurent Bartholdi
##
#H  @(#)$Id: chapter-4.tst,v 1.3 2008/10/29 12:57:41 gap Exp $
##
#Y  Copyright (C) 2008,  Laurent Bartholdi
##
#############################################################################
##
##  This file tests the functions explained in chapter 4 of the manual
##
#############################################################################

gap> START_TEST("fr:chapter 4");
gap> 
gap> Info(InfoFR,1,"4.1 FRElements");
#I  4.1 FRElements
gap> 
gap> Read(Filename(DirectoriesPackageLibrary("fr","tst"),"frelements.g"));
gap> Read(Filename(DirectoriesPackageLibrary("fr","tst"),"frmachines.g"));
gap> 
gap> Info(InfoFR,1,"4.1.1 FRElementNC, 4.1.2/3 FRElement");
#I  4.1.1 FRElementNC, 4.1.2/3 FRElement
gap> 
gap> for machine in frel do
>   Print(ForAll(machine, elts -> ForAll(elts, el -> el = machine[1][Position(elts, el)])), "\n");
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
gap> Length(AsSet(Flat(frel{[1,3,7]}))) = 10;
true
gap> ForAll(frel{[2, 4,5,6,7,8,9]}, list -> Length(AsSet(Flat(list))) = Length(list[1]));
true
gap> 
gap> Info(InfoFR,1,"4.1.4 ComposeElement");
#I  4.1.4 ComposeElement
gap> 
gap> e := frel[1][1][1];
<2|f1>
gap> a := frel[1][1][2];
<2|f2>
gap> b := frel[1][1][3];
<2|f3>
gap> c := frel[1][1][4];
<2|f4>
gap> d := frel[1][1][5];
<2|f5>
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
gap> a := frel[2][1][1];
<8|f1>
gap> b := frel[2][1][2];
<8|f2>
gap> c := frel[2][1][3];
<8|f3>
gap> ComposeElement([One(b),One(b),One(b),One(b),One(b),One(b),One(b),b],Output(b)) = b;
true
gap> ComposeElement([One(b),One(b),One(b),One(b),One(b),One(b),a,c],Output(c)) = c;
true
gap> ComposeElement([One(b),One(b),One(b),One(b),One(b),One(b),a,b*c],Output(b){Output(c)}) = b*c;
true
gap> 
gap> a := frel[3][1][1];
<2|f1>
gap> b1 := frel[3][1][2];
<2|f2>
gap> b2 := frel[3][1][3];
<2|f3>
gap> ComposeElement([a,b2],()) = b1;
true
gap> ComposeElement([One(a),b1],()) = b2;
true
gap> n := 2;
2
gap> ComposeElement([(b1*b2*a)^(2^n),(a*b1*b2)^(2^n)],()) = (a*b1*b2)^(2^(n+1));
true
gap> 
gap> t := frel[4][1][1];
<5|f1>
gap> ComposeElement([One(t),One(t),One(t),t,t],(1,2,3,4,5)^2) = t^2;
true
gap> n := 2;
2
gap> ComposeElement([t^(5^n),t^(5^n),t^(5^n),t^(5^n),t^(5^n)],()) = t^(5^(n+1));
true
gap> 
gap> x := frel[5][1][1];
<7|x>
gap> y := frel[5][1][2];
<7|y>
gap> z := frel[5][1][3];
<7|z>
gap> ComposeElement([x,y,z,x,y,z,One(x)],(1,2,3,4,5)) = x;
true
gap> ComposeElement([x,y,z,One(x),z,y,x],(1,4)(2,3)) = y;
true
gap> ComposeElement([One(x),y,y,x,z,One(x),One(x)],(1,6,3)(2,5)) = z;
true
gap> ComposeElement([x,y*z,z*y,x,z^2,y^2,x^2],()) = y^2;
true
gap> 
gap> a := frel[6][3][1];
<3|f1>
gap> b := frel[6][3][2];
<3|f2>
gap> ComposeElement([a*b,One(a),a^2],(1,2,3)) = a;
true
gap> ComposeElement([b^-5,Comm(a,b),b*a^-1],(1,2)) = b;
true
gap> 
gap> z := frel[7][1][1];
<2|m1>
gap> y := frel[7][1][2];
<2|m2>
gap> x := frel[7][1][3];
<2|m3>
gap> ComposeElement([z, x],Trans([1,1])) = z;
true
gap> ComposeElement([y, One(x)],Trans([2,1])) = y;
true
gap> ComposeElement([y, One(x)],(1,2)) = y;
true
gap> ComposeElement([y, z],Trans([2,2])) = x;
true
gap> 
gap> a := frel[8][1][1];
<7|m1>
gap> b := frel[8][1][2];
<7|m2>
gap> ComposeElement([a,b,a,b,a,b,a], Trans([2,5,4,7,7,4,3])) = a;
true
gap> ComposeElement([b,b,a,b,a,a,b], Trans([3,1,6,7,4,7,1])) = b;
true
gap> ComposeElement([a*b,b*a,a*b,b^2,a*b,b^2,a^2], Trans([2,5,4,7,7,4,3])*Trans([3,1,6,7,4,7,1])) = a*b;
true
gap> 
gap> a1 := frel[9][1][1];
<3|s1>
gap> a2 := frel[9][1][2];
<3|s2>
gap> ComposeElement([a1^2,a2^3*a1,a2],Trans([3,2,2])) = a1;
true
gap> ComposeElement([a1,a1^7,a1^2*a2^2*a1],(1,2)) = a2;
true
gap> ComposeElement([a1,a1^7,a1^2*a2^2*a1],Trans([2,1,3])) = a2;
true
gap> 
gap> Info(InfoFR,1,"4.1.5 VertexElement");
#I  4.1.5 VertexElement
gap> 
gap> e := frel[1][1][1];
<2|f1>
gap> a := frel[1][1][2];
<2|f2>
gap> b := frel[1][1][3];
<2|f3>
gap> c := frel[1][1][4];
<2|f4>
gap> d := frel[1][1][5];
<2|f5>
gap> VertexElement([1], a)*VertexElement([2],d) = c;
true
gap> VertexElement(1, a)*VertexElement(2,d) = c;
true
gap> VertexElement([1], a)*VertexElement([2,1], a)*VertexElement([2,2],d) = b;
true
gap> AsSet(List([a,b,c,d], g -> Order(VertexElement([2,2,1,1],g)))) = [2];
true
gap> Comm(VertexElement([1,2],a),VertexElement([1,1],a)) = VertexElement(2,e);
true
gap> 
gap> a := frel[3][1][1];
<2|f1>
gap> b1 := frel[3][1][2];
<2|f2>
gap> b2 := frel[3][1][3];
<2|f3>
gap> VertexElement(2,b1) = b2;
true
gap> VertexElement(1,a)*VertexElement([2,2],b1) = b1;
true
gap> 
gap> t := frel[4][1][1];
<5|f1>
gap> Product([1..5], i -> VertexElement(i,t)) = t^5;
true
gap> 
gap> a := frel[6][3][1];
<3|f1>
gap> b := frel[6][3][2];
<3|f2>
gap> VertexElement(1,b^-5*Comm(a,b))*VertexElement(2,(b^-1)^a*b^-4)*VertexElement(3,b/a*b/a) = b^2;
true
gap> 
gap> z := frel[7][1][1];
<2|m1>
gap> y := frel[7][1][2];
<2|m2>
gap> x := frel[7][1][3];
<2|m3>
gap> VertexElement(1,y)*VertexElement(2,y) = y^2;
true
gap> VertexElement([],z) = z;
true
gap> VertexElement([2],x)*y = y*VertexElement([1],x);
true
gap> 
gap> a := frel[8][1][1];
<7|m1>
gap> b := frel[8][1][2];
<7|m2>
gap> VertexElement([5,3],a)*VertexElement([5,3],b) = VertexElement([5,3],a*b);
true
gap> 
gap> a1 := frel[9][1][1];
<3|s1>
gap> a2 := frel[9][1][2];
<3|s2>
gap> VertexElement([],a1) = a1;
true
gap> VertexElement([],a2) = a2;
true
gap> VertexElement([1],a1)*VertexElement([2,1],a2) = VertexElement([2,1],a2)*VertexElement([1],a1);
true
gap> 
gap> Info(InfoFR,1,"4.1.6 DiagonalElement");
#I  4.1.6 DiagonalElement
gap> 
gap> a := frel[1][1][2];
<2|f2>
gap> DiagonalElement(0,a) = VertexElement(1,a);
true
gap> DiagonalElement(1,a) = VertexElement(1,a)*VertexElement(2,a);
true
gap> DiagonalElement(-1,a) = VertexElement(1,a)*VertexElement(2,a);
true
gap> DiagonalElement(3,a) = DiagonalElement(1,a);
true
gap> 
gap> b := frel[2][1][2];
<8|f2>
gap> DiagonalElement(2,b) = VertexElement(1,b)*VertexElement(3,b);
true
gap> 
gap> t := frel[4][1][1];
<5|f1>
gap> DiagonalElement(-1,t) = t^5;
true
gap> DiagonalElement(3,t) = ComposeElement([t, t^-3, t^3, t^-1, t^0], ());
true
gap> 
gap> x := frel[5][1][1];
<7|x>
gap> y := frel[5][1][2];
<7|y>
gap> z := frel[5][1][3];
<7|z>
gap> DiagonalElement(6, x) = ComposeElement([x, x^-6, x^15, x^-20, x^15, x^-6, x], ());
true
gap> DiagonalElement(-1, y) = ComposeElement(ListWithIdenticalEntries(7, y), ());
true
gap> DiagonalElement(1, z) = Comm(ComposeElement(ListWithIdenticalEntries(7, One(z)),(1,2)),VertexElement(1,z));
true
gap> DiagonalElement(0,x*z) = VertexElement(1,x*z);
true
gap> 
gap> a := frel[6][3][1];
<3|f1>
gap> b := frel[6][3][2];
<3|f2>
gap> DiagonalElement(1,a) = VertexElement(1,a)*VertexElement(2,a^-1);
true
gap> DiagonalElement(-1,b) = VertexElement(1,b)*VertexElement(2,b)*VertexElement(3,b);
true
gap> 
gap> z := frel[7][1][1];
<2|m1>
gap> y := frel[7][1][2];
<2|m2>
gap> x := frel[7][1][3];
<2|m3>
gap> ForAll([x,y,z,x*z*y], g -> DiagonalElement(0,g) = VertexElement(1,g));
true
gap> ForAll([x,y,z,x*y*z], g -> DiagonalElement(-1,g) = VertexElement(1,g)*VertexElement(2,g));
true
gap> 
gap> a := frel[8][1][1];
<7|m1>
gap> b := frel[8][1][2];
<7|m2>
gap> ForAll([a,b,(a*b)^2], g -> DiagonalElement(0,g) = VertexElement(1,g));
true
gap> ForAll([a,b,a*b^2*a], g -> DiagonalElement(-1,g) = Product([1..7], i -> VertexElement(i,g)));
true
gap> 
gap> a1 := frel[9][1][1];
<3|s1>
gap> a2 := frel[9][1][2];
<3|s2>
gap> ForAll([a1, a2, a2*a1], g -> DiagonalElement(0,g) = VertexElement(1,g));
true
gap> ForAll([a1, a2, a1*a2], g -> DiagonalElement(-1,g) = Product([1..3], i -> VertexElement(i,g)));
true
gap> 
gap> Info(InfoFR,1,"4.1.7 AsGroupFRElement, ...");
#I  4.1.7 AsGroupFRElement, ...
gap> 
gap> for machine in frel{[1..6]} do
>   Print(ForAll(machine, elts -> ForAll(elts, el -> AsGroupFRElement(el) = machine[1][Position(elts, el)])), "\n");
> od;
true
true
true
true
true
true
gap> for machine in frel do
>   Print(ForAll(machine, elts -> ForAll(elts, el -> AsMonoidFRElement(el) = machine[1][Position(elts, el)])), "\n");
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
gap> for machine in frel do
>   Print(ForAll(machine, elts -> ForAll(elts, el -> AsSemigroupFRElement(el) = machine[1][Position(elts, el)])), "\n");
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
gap> Info(InfoFR,1,"4.2 Operations and Attributes for FRElements");
#I  4.2 Operations and Attributes for FRElements
gap> 
gap> Info(InfoFR,1,"4.2.1 UnderlyingFRMachine");
#I  4.2.1 UnderlyingFRMachine
gap> 
gap> for i in [1..6] do
>   Print(ForAll(frel[i], type -> ForAll(type, el -> UnderlyingFRMachine(el) = mg[i][1])), "\n");
> od;
true
true
true
true
true
true
gap> for i in [7..8] do
>   Print(ForAll(frel[i], type -> ForAll(type, el -> UnderlyingFRMachine(el) = mm[i][1])), "\n");
> od;
true
true
gap> for i in [9] do
>   Print(ForAll(frel[i], type -> ForAll(type, el -> SubFRMachine(UnderlyingFRMachine(el), ms[i][1]) <> fail)), "\n");
> od; # must be careful because of Monoid- and SemigroupFRMachines
true
gap> 
gap> Info(InfoFR,1,"4.2.2 Output");
#I  4.2.2 Output
gap> 
gap> for i in [1..9] do
>   Print(ForAll(frel[i], el_list -> List(el_list, Output) = outputs[i]), "\n");
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
gap> Info(InfoFR,1,"4.2.4 Activity");
#I  4.2.4 Activity
gap> 
gap> for i in [1..9] do
>   Print(ForAll(frel[i], el_list -> List(el_list, g -> Activity(g, 1)) = List(outputs[i], x -> Trans(x))), "\n");
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
gap> ForAll([1..3], i -> Activity(frel[1][1][i+1], 3) = PermList(Output(frel[2][1][i])));
true
gap> a := frel[2][1][1];
<8|f1>
gap> b := frel[2][1][2];
<8|f2>
gap> n := 5;
5
gap> Activity((a*b)^(2^(n+1)), n) = ();
true
gap> Order(Activity(frel[4][1][1], n)) = 5^n;
true
gap> Activity(frel[5][1][2], 2) = (1,23,2,24,3,25,4,26,5,22)(6,27)(7,28)(8,18,11,15,13,20,10,16,12,19,9,17)(14,
> 21)(29,34,31)(30,33)(36,39)(37,38)(43,44,45,46,47);
true
gap> Activity(frel[7][1][3], 2) = Trans([ 4, 3, 3, 3 ]);
true
gap> Activity(frel[9][1][1], 2) = Trans([ 8, 8, 8, 5, 6, 5, 5, 4, 6 ]);
true
gap> 
gap> Info(InfoFR,1,"4.2.5 Transition");
#I  4.2.5 Transition
gap> 
gap> for i in [1..9] do
>   Print(ForAll(frel[i], el_list -> ForAll(el_list, el -> ForAll([1..Size(AlphabetOfFRObject(el))], input -> Transition(el, input) in StateSet(el) and Transition(el, input) in StateSet(UnderlyingFRMachine(el))))), "\n");
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
gap> Info(InfoFR,1,"4.2.6 Portrait");
#I  4.2.6 Portrait
gap> 
gap> for m in frel do
>   Print(ForAll(m, list -> ForAll(list, g -> Portrait(g,1) = [Trans(Output(g)), List(AlphabetOfFRObject(g), i -> Trans(Output(State(g, i))))])), "\n");
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
gap> for m in frel do
>   Print(ForAll(m, list -> ForAll(list, g -> PortraitInt(g,1) = [ActivityInt(g), List(AlphabetOfFRObject(g), i -> ActivityInt(State(g, i)))])), "\n");
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
gap> Portrait(frel[9][1][1],1) = [Trans([3,2,2]),[Trans([2,2,2]),Trans([2,3,2]),Trans([2,1,3])]];
true
gap> 
gap> Info(InfoFR,1,"4.2.7 DecompositionOfFRElement");
#I  4.2.7 DecompositionOfFRElement
gap> 
gap> for i in [1..6] do
>   Print(ForAll(frel[i], el_list -> ForAll(el_list, el -> DecompositionOfFRElement(el) = [List([1..Size(AlphabetOfFRObject(el))], x -> FRElement(mg[i][1], transitions[i][Position(el_list, el)][x])),outputs[i][Position(el_list, el)]])), "\n");
> od;
true
true
true
true
true
true
gap> for i in [7..9] do
>   Print(ForAll(frel[i], el_list -> ForAll(el_list, el -> DecompositionOfFRElement(el) = [List([1..Size(AlphabetOfFRObject(el))], x -> FRElement(mm[i][1], transitions[i][Position(el_list, el)][x])),outputs[i][Position(el_list, el)]])), "\n");
> od;
true
true
true
gap> 
gap> Info(InfoFR,1,"4.2.8 StateSet");
#I  4.2.8 StateSet
gap> 
gap> rk := [5,3,3,1,3,2,3,2,2];
[ 5, 3, 3, 1, 3, 2, 3, 2, 2 ]
gap> for i in [1..6] do
>   Print(ForAll(frel[i], el_list -> ForAll(el_list, el -> Size(GeneratorsOfGroup(StateSet(el))) = rk[i])), "\n");
> od;
true
true
true
true
true
true
gap> for i in [7..8] do
>   Print(ForAll(frel[i], el_list -> ForAll(el_list, el -> Size(GeneratorsOfMonoid(StateSet(el))) = rk[i])), "\n");
> od;
true
true
gap> for i in [9] do
>   Print(ForAll(frel[i]{[1,3]}, el_list -> ForAll(el_list, el -> Size(GeneratorsOfSemigroup(StateSet(el))) = rk[i])), "\n");
> od;
true
gap> for i in [9] do
>   Print(ForAll(frel[i]{[2,4]}, el_list -> ForAll(el_list, el -> Size(GeneratorsOfSemigroup(StateSet(el))) = rk[i]+1)), "\n");
> od;
true
gap> 
gap> Info(InfoFR,1,"4.2.9 State");
#I  4.2.9 State
gap> 
gap> ForAll(Flat(frel), el -> ForAll(Tuples(AlphabetOfFRObject(el),2), w -> State(el, w) = FRElement(UnderlyingFRMachine(el), Transition(el, w))));
true
gap> 
gap> Info(InfoFR,1,"4.2.10 States");
#I  4.2.10 States
gap> 
gap> l := [5,4,4,2,4,-1,4,2,-1];
[ 5, 4, 4, 2, 4, -1, 4, 2, -1 ]
gap> for i in [1,2,3,4,5, 7,8 ] do # 6 and 9 are not finite-state...
>   Print(ForAll(frel[i], list -> Length(States(list)) = l[i]), "\n");
> od;
true
true
true
true
true
true
true
gap> AsSet(States(frel[1][1][3])) = AsSet(frel[1][1]);
true
gap> Length(AsSet(States(Concatenation(frel[1][1], frel[3][1], frel[7][1])))) = 10;
true
gap> States(frel[3][4][2]) = [frel[3][4][2], frel[3][4][1], frel[3][4][3], One(frel[3][4][1])];
true
gap> States(frel[4][2][1]^6) = [frel[4][2][1]^6,frel[4][2][1],frel[4][2][1]^2,One(frel[4][2][1])];
true
gap> AsSet(States(frel[5][3][2])) = AsSet(Concatenation(frel[5][3], [One(frel[5][3][1])]));
true
gap> States(frel[7][2][2]) = [frel[7][2][2], One(frel[7][2][2])];
true
gap> States(frel[8][4][2]) = Reversed(frel[8][4]);
true
gap> 
gap> Info(InfoFR,1,"4.2.11 FixedStates");
#I  4.2.11 FixedStates
gap> 
gap> FixedStates(frel[1][1][3]) = frel[1][1]{[2,4,5,1,3]};
true
gap> FixedStates(frel[1][1]) = frel[1][1]{[1,2,4,5,3]};
true
gap> FixedStates(frel[4][4][1]^10) = [frel[4][4][1]^2];
true
gap> FixedStates(frel[4][4][1]^25) = [frel[4][4][1]^5,frel[4][4][1]];
true
gap> FixedStates(frel[6][1]) = [frel[6][1][2]*frel[6][1][1]^-1, frel[6][1][2]^-6*frel[6][1][1]^-1];
true
gap> FixedStates(frel[7][2][3]*frel[7][2][1]) = [frel[7][2][2]*frel[7][2][3],frel[7][2][2]];
true
gap> FixedStates(frel[9][1][1]) = [frel[9][1][2]^3*frel[9][1][1]];
true
gap> 
gap> Info(InfoFR,1,"4.2.12 LimitStates");
#I  4.2.12 LimitStates
gap> 
gap> for i in [1..4] do
>   t := true;
>   t := t and LimitStates(frel[1][i][1]) = [frel[1][i][1]];
>   t := t and LimitStates(frel[1][i][2]) = [frel[1][i][1]];
>   t := t and AsSet(LimitStates(frel[1][i][3])) = AsSet(frel[1][i]);
>   t := t and AsSet(LimitStates(frel[2][i][2])) = AsSet([frel[2][i][2], One(frel[2][i][2])]);
>   t := t and AsSet(LimitStates(frel[3][i][2])) = AsSet(Concatenation(frel[3][i], [One(frel[3][i][1])]));
>   t := t and AsSet(LimitStates(frel[4][i][1])) = AsSet(Concatenation(frel[4][i], [One(frel[4][i][1])]));
>   t := t and ForAll([1..3], j -> AsSet(LimitStates(frel[5][i][j])) = AsSet(Concatenation(frel[5][i], [One(frel[5][i][1])])));
>   t := t and ForAll([1,3], j -> AsSet(LimitStates(frel[7][i][j])) = AsSet(Concatenation(frel[7][i], [One(frel[7][i][1])])));
>   t := t and AsSet(LimitStates(frel[7][i][2])) = AsSet([frel[7][i][2], One(frel[7][i][1])]);
>   t := t and ForAll([1..2], j -> AsSet(LimitStates(frel[8][i][j])) = AsSet(frel[8][i]));
>   Print(t, "\n");
> od;
true
true
true
true
gap> 
gap> Info(InfoFR,1,"4.2.13 InitialState");
#I  4.2.13 InitialState
gap> 
gap> ForAll(Flat(frel), g -> InitialState(g) = Transition(g,[]));
true
gap> f := StateSet(frel[9][1][1]);
<free semigroup on the generators [ s1, s2 ]>
gap> g := f.2^2*f.1^4*f.2*f.1*f.2;
s2^2*s1^4*s2*s1*s2
gap> InitialState(FRElement(UnderlyingFRMachine(frel[9][1][1]), g)) = g;
true
gap> 
gap> Info(InfoFR,1,"4.2.14 \\^");
#I  4.2.14 \^
gap> 
gap> ForAll(Flat(frel), g -> ForAll(AlphabetOfFRObject(g), i -> i^g = Output(g)[i]));
true
gap> n := 2;
2
gap> ForAll(Flat(frel), g -> ForAll(Tuples(AlphabetOfFRObject(g), n), w -> w^g = Reversed(CoefficientsQadic((List([n-1,n-2..0], i -> Size(AlphabetOfFRObject(g))^i)*(w-ListWithIdenticalEntries(n, 1))+1)^Activity(g, n) - 1, Size(AlphabetOfFRObject(g))) + ListWithIdenticalEntries(n, 1))));
true
gap> 
gap> Info(InfoFR,1,"4.2.15 \\*");
#I  4.2.15 \*
gap> 
gap> Activity(frel[7][1][1]*frel[1][1][3], 2) = Trans([2,2,1,1]);
true
gap> 
gap> Info(InfoFR,1,"4.2.16 \\[\\]");
#I  4.2.16 \[\]
gap> 
gap> for i in [1..6] do
>   Print(ForAll(mg[i], m -> ForAll([1..Size(frel[i][1])], j -> m[j] = frel[i][1][j])), "\n");
> od;
true
true
true
true
true
true
gap> for i in [7..9] do
>   Print(ForAll(mm[i], m -> ForAll([1..Size(frel[i][1])], j -> m[j] = frel[i][1][j])), "\n");
> od;
true
true
true
gap> for i in [1..6] do
>   Print(ForAll(mg[i], m -> m{[1..Size(frel[i][1])]} = frel[i][1]), "\n");
> od;
true
true
true
true
true
true
gap> for i in [7..9] do
>   Print(ForAll(mm[i], m -> m{[1..Size(frel[i][1])]} = frel[i][1]), "\n");
> od;
true
true
true
gap> 
gap> STOP_TEST( "chapter-4.tst", 10^10 );

#E chapter-4.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 