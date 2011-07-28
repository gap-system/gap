#############################################################################
##
#W  chapter-3.tst                  FR Package               Laurent Bartholdi
##
#H  @(#)$Id: chapter-3.tst,v 1.6 2010/06/04 11:55:35 gap Exp $
##
#Y  Copyright (C) 2008,  Laurent Bartholdi
##
#############################################################################
##
##  This file tests the functions explained in chapter 3 of the manual
##
#############################################################################

gap> START_TEST("fr:chapter 3");
gap> 
gap> Info(InfoFR,1,"3.3 Creators for FR machines");
#I  3.3 Creators for FR machines
gap> 
gap> Read(Filename(DirectoriesPackageLibrary("fr","tst"),"frmachines.g"));
gap> 
gap> Info(InfoFR,1,"3.3.1 FRMachineNC, 3.3.2 FRMachine");
#I  3.3.1 FRMachineNC, 3.3.2 FRMachine
gap> 
gap> # tests if all the definitions of FRMachineNC and FRMachine agree.
gap> for list in [mg, mm, ms, mmi, msiu, msu] do
>   for machines in list do
>     if Length(machines) > 1 then
>       Print(ForAll(machines{[2..Length(machines)]}, m -> m = machines[1]), "\n");
>     fi;
>   od;
>   Print("\n");
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
true
true
true

true
true
true

true
true
true
true
true
true

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
gap> Info(InfoFR,1,"3.3.4 AsGroupFRMachine, ...");
#I  3.3.4 AsGroupFRMachine, ...
gap> 
gap> # 5 loops testing AsGroupFRMachine, AsMonoidFRMachine and AsSemigroupFRMachine
gap> for i in [1..Length(mg)] do
>   if Length(mg[i]) > 1 then
>     Print("Machine ",i,":\n");
>     for list in [mm, ms, msu] do
>       Print(ForAll(list[i], m -> AsGroupFRMachine(m) = mg[i][1]), "\n");
>     od;
>   fi;
> od;
Machine 1:
true
true
true
Machine 2:
true
true
true
Machine 3:
true
true
true
Machine 4:
true
true
true
Machine 5:
true
true
true
Machine 6:
true
true
true
gap> for i in [1..Length(mmi)] do
>   if Length(mmi[i]) > 1 then
>     Print("Machine ",i,":\n");
>     for list in [mg] do
>       Print(ForAll(list[i], m -> AsMonoidFRMachine(m) = mmi[i][1]), "\n");
>     od;
>   fi;
> od;
Machine 1:
false
Machine 2:
true
Machine 3:
true
Machine 4:
true
Machine 5:
false
Machine 6:
true
gap> # should be false for machines 1 and 5. For machine 1, the identity transformation is already in mg, and for machine 5, in mmi, the ordering of the elements is not the right one. See SubFRMachine.
gap> for i in [1..Length(mm)] do
>   if Length(mm[i]) > 1 then
>     Print("Machine ",i,":\n");
>     for list in [ms] do
>       Print(ForAll(list[i], m -> AsMonoidFRMachine(m) = mm[i][1]), "\n");
>     od;
>   fi;
> od;
Machine 1:
true
Machine 4:
true
Machine 5:
true
Machine 7:
true
Machine 8:
true
Machine 9:
true
gap> for i in [1..Length(msiu)] do
>   if Length(msiu[i]) > 1 then
>     Print("Machine ",i,":\n");
>     for list in [mg, mmi] do
>       Print(ForAll(list[i], m -> AsSemigroupFRMachine(m) = msiu[i][1]), "\n");
>     od;
>   fi;
> od; # Same problems as before : ordering of states
Machine 1:
false
false
Machine 2:
false
false
Machine 3:
false
false
Machine 4:
false
false
Machine 5:
false
true
Machine 6:
true
true
gap> for i in [1..Length(msu)] do
>   if Length(msu[i]) > 1 then
>     Print("Machine ",i,":\n");
>     for list in [mm] do
>       Print(ForAll(list[i], m -> AsSemigroupFRMachine(m) = msu[i][1]), "\n");
>     od;
>   fi;
> od; # Same problems as before : ordering of states
Machine 7:
false
Machine 8:
true
Machine 9:
true
gap> 
gap> Info(InfoFR,1,"3.3.5 ChangeFRMachineBasis");
#I  3.3.5 ChangeFRMachineBasis
gap> 
gap> m := mg[1][1];
<FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2, f3, f4, f5 ] )>
gap> f := StateSet(m);;
gap> l := [f.3,f.2];
[ f3, f2 ]
gap> ChangeFRMachineBasis(m, l);
<FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2, f3, f4, f5 ] )>
gap> Display(last);
 G  |            1               2   
----+---------------+---------------+
 f1 | f3^-1*f1*f3,1   f2^-1*f1*f2,2  
 f2 | f3^-1*f1*f2,2   f2^-1*f1*f3,1  
 f3 | f3^-1*f2*f3,1   f2^-1*f4*f2,2  
 f4 | f3^-1*f2*f3,1   f2^-1*f5*f2,2  
 f5 | f3^-1*f1*f3,1   f2^-1*f3*f2,2  
----+---------------+---------------+
gap> 
gap> Info(InfoFR,1,"3.4 Attributes of FRMachines");
#I  3.4 Attributes of FRMachines
gap> 
gap> Info(InfoFR,1,"3.4.1 StateSet, 3.4.2 GeneratorsOfFRMachine");
#I  3.4.1 StateSet, 3.4.2 GeneratorsOfFRMachine
gap> 
gap> for list in mg do
>   for m in list do
>     Print(RankOfFreeGroup(StateSet(m)));
>     gen := GeneratorsOfFRMachine(m);
>     Print(Length(gen));
>   od;
>   Print("\n");
> od;
55555555
33333333
33333333
11111111
33333333
22222222



gap> 
gap> for type in [mm, mmi] do
>   for list in type do
>     for m in list do
>       Print(Length(GeneratorsOfMonoid(StateSet(m))));
>       gen := GeneratorsOfFRMachine(m);
>       Print(Length(gen));
>     od;
>     Print("\n");
>   od;
> od;
5555


1111
3333

33333333
22222222
22222222
9999
6666
6666
2222
6666
4444



gap> 
gap> for type in [ms, msu, msiu] do
>   for list in type do
>     for m in list do
>       Print(Length(GeneratorsOfSemigroup(StateSet(m))));
>       gen := GeneratorsOfFRMachine(m);
>       Print(Length(gen));
>     od;
>     Print("\n");
>   od;
> od;
5555






2222
2222






44545444
3333
3333
9999
7777
7777
3333
7777
5555



gap> 
gap> Info(InfoFR,1,"3.4.3 Output");
#I  3.4.3 Output
gap> 
gap> for type in [mg, mm, ms, mmi, msiu, msu] do
>   for i in [1..Length(type)] do
>     Print(ForAll(type[i], m -> List(GeneratorsOfFRMachine(m), g -> Output(m, g)) = outputs[i]), "\n");
>   od;
>   Print("\n");
> od;# get false because of empty lists or wrong number of indices
true
true
true
true
true
true
true
true
true

true
true
true
true
true
true
true
true
true

true
true
true
true
true
true
true
true
true

false
false
false
false
false
false
true
true
true

false
false
false
false
false
false
true
true
true

true
true
true
true
true
true
false
false
false

gap> 
gap> Info(InfoFR,1,"3.4.4 Transition");
#I  3.4.4 Transition
gap> 
gap> for i in [1..6] do
>   Print(ForAll(mg[i]{[1,4]}, m -> List(GeneratorsOfFRMachine(m), s -> List(AlphabetOfFRObject(m), x -> Transition(m, s, x))) = transitions[i]), "\n");
> od;
true
true
true
true
true
true
gap> for i in [7..9] do
>   Print(ForAll(mm[i]{[1,4]}, m -> List(GeneratorsOfFRMachine(m), s -> List(AlphabetOfFRObject(m), x -> Transition(m, s, x))) = transitions[i]), "\n");
> od;
true
true
true
gap> 
gap> m := mg[1][1];
<FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2, f3, f4, f5 ] )>
gap> f := StateSet(m);
<free group on the generators [ f1, f2, f3, f4, f5 ]>
gap> Transition(m, f.3, ListWithIdenticalEntries(30, 2));
f3
gap> Transition(m, f.3, Concatenation(ListWithIdenticalEntries(31, 2), [1]));
f2
gap> m := mg[2][1];
<FR machine with alphabet [ 1, 2, 3, 4, 5, 6, 7, 8 ] on Group( 
[ f1, f2, f3 ] )>
gap> f := StateSet(m);
<free group on the generators [ f1, f2, f3 ]>
gap> Transition(m, f.3, ListWithIdenticalEntries(30, 8));
f3
gap> Transition(m, f.1*f.3*f.1^-1*f.3^-1, Concatenation([4], ListWithIdenticalEntries(30, 8)));
f3
gap> 
gap> Info(InfoFR,1,"3.4.5 WreathRecursion");
#I  3.4.5 WreathRecursion
gap> 
gap> m := mg[2][1];
<FR machine with alphabet [ 1, 2, 3, 4, 5, 6, 7, 8 ] on Group( 
[ f1, f2, f3 ] )>
gap> f := StateSet(m);
<free group on the generators [ f1, f2, f3 ]>
gap> wr := WreathRecursion(m);
function( w ) ... end
gap> wr(f.3);
[ [ <identity ...>, <identity ...>, <identity ...>, <identity ...>, 
      <identity ...>, <identity ...>, f1, f3 ], [ 3, 4, 1, 2, 5, 6, 7, 8 ] ]
gap> l := wr(f.1*f.3*f.1^-1*f.3^-1);
[ [ <identity ...>, <identity ...>, f1, f3, f1^-1, f3^-1, <identity ...>, 
      <identity ...> ], [ 3, 4, 1, 2, 7, 8, 5, 6 ] ]
gap> wr(l[1][6]);
[ [ <identity ...>, <identity ...>, <identity ...>, <identity ...>, 
      <identity ...>, <identity ...>, f1^-1, f3^-1 ], 
  [ 3, 4, 1, 2, 5, 6, 7, 8 ] ]
gap> 
gap> m := ms[9][1];
<FR machine with alphabet [ 1, 2, 3 ] on Semigroup( [ s1, s2 ] )>
gap> f := StateSet(m);
<free semigroup on the generators [ s1, s2 ]>
gap> wr := WreathRecursion(m);
function( w ) ... end
gap> wr(f.1);
[ [ s1^2, s2^3*s1, s2 ], [ 3, 2, 2 ] ]
gap> wr(f.1*f.2);
[ [ s1^4*s2^2*s1, s2^3*s1^8, s2*s1^7 ], [ 3, 1, 1 ] ]
gap> 
gap> Info(InfoFR,1,"3.5 Operations of FRMachines");
#I  3.5 Operations of FRMachines
gap> 
gap> Info(InfoFR,1,"3.5.1 StructuralGroup, ...");
#I  3.5.1 StructuralGroup, ...
gap> 
gap> g := StructuralGroup(mg[1][1]);
<fp group on the generators [ f1, f2, f3, f4, f5, 1, 2 ]>
gap> m := StructuralMonoid(mm[1][1]);
<fp monoid on the generators [ m1, m2, m3, m4, m5, 1, 2 ]>
gap> s := StructuralSemigroup(ms[1][1]);
<fp semigroup on the generators [ s1, s2, s3, s4, s5, 1, 2 ]>
gap> RelatorsOfFpGroup(g);
[ f1*1*f1^-1*1^-1, f1*2*f1^-1*2^-1, f2*2*f1^-1*1^-1, f2*1*f1^-1*2^-1, 
  f3*1*f2^-1*1^-1, f3*2*f4^-1*2^-1, f4*1*f2^-1*1^-1, f4*2*f5^-1*2^-1, 
  f5*1*f1^-1*1^-1, f5*2*f3^-1*2^-1 ]
gap> RelationsOfFpMonoid(m);
[ [ m1*1, 1*m1 ], [ m1*2, 2*m1 ], [ m2*2, 1*m1 ], [ m2*1, 2*m1 ], 
  [ m3*1, 1*m2 ], [ m3*2, 2*m4 ], [ m4*1, 1*m2 ], [ m4*2, 2*m5 ], 
  [ m5*1, 1*m1 ], [ m5*2, 2*m3 ] ]
gap> RelationsOfFpSemigroup(s);
[ [ s1*1, 1*s1 ], [ s1*2, 2*s1 ], [ s2*2, 1*s1 ], [ s2*1, 2*s1 ], 
  [ s3*1, 1*s2 ], [ s3*2, 2*s4 ], [ s4*1, 1*s2 ], [ s4*2, 2*s5 ], 
  [ s5*1, 1*s1 ], [ s5*2, 2*s3 ] ]
gap> 
gap> Info(InfoFR,1,"3.5.2 \\+");
#I  3.5.2 \+
gap> 
gap> m := mg[1][1] + mg[3][3];;
gap> Rank(StateSet(m)) = 8;
true
gap> SubFRMachine(m, mg[1][1]) <> fail;
true
gap> SubFRMachine(m, mg[3][3]) <> fail;
true
gap> Display(m);
 G  |     1        2   
----+--------+--------+
 f1 |   f1,1     f1,2  
 f2 |   f1,2     f1,1  
 f3 |   f2,1     f4,2  
 f4 |   f2,1     f5,2  
 f5 |   f1,1     f3,2  
  a | <id>,2   <id>,1  
 b1 |    a,1     b2,2  
 b2 | <id>,1     b1,2  
----+--------+--------+
gap> m := mm[7][1] + mg[3][3];
<FR machine with alphabet [ 1, 2 ] on Monoid( 
[ m1, m2, m3, a^-1, a, b1^-1, b1, b2^-1, b2 ], ... )>
gap> Size(GeneratorsOfMonoid(StateSet(m))) = 9 and IsFreeMonoid(StateSet(m));
true
gap> SubFRMachine(m, mm[7][1]) <> fail;
true
gap> SubFRMachine(m, AsMonoidFRMachine(mg[3][3])) <> fail;
true
gap> Display(m);
 M     |     1         2   
-------+--------+---------+
    m1 |   m1,1      m3,1  
    m2 |   m2,2    <id>,1  
    m3 |   m2,2      m1,2  
  a^-1 | <id>,2    <id>,1  
     a | <id>,2    <id>,1  
 b1^-1 | a^-1,1   b2^-1,2  
    b1 |    a,1      b2,2  
 b2^-1 | <id>,1   b1^-1,2  
    b2 | <id>,1      b1,2  
-------+--------+---------+
gap> m := mm[9][1] + ms[9][2];
<FR machine with alphabet [ 1, 2, 3 ] on Semigroup( 
[ <identity ...>, m1, m2, s1, s2 ] )>
gap> Size(GeneratorsOfSemigroup(StateSet(m))) = 5 and IsFreeSemigroup(StateSet(m));
true
gap> SubFRMachine(m, AsSemigroupFRMachine(mm[9][1])) <> fail;
true
gap> SubFRMachine(m, ms[9][2]) <> fail;
true
gap> Display(m);
 S    |     1           2                3   
------+--------+-----------+----------------+
 <id> | <id>,1      <id>,2           <id>,3  
   m1 | m1^2,3   m2^3*m1,2             m2,2  
   m2 |   m1,2      m1^7,1   m1^2*m2^2*m1,3  
   s1 | s1^2,3   s2^3*s1,2             s2,2  
   s2 |   s1,2      s1^7,1   s1^2*s2^2*s1,3  
------+--------+-----------+----------------+
gap> 
gap> Info(InfoFR,1,"3.5.3 \\*");
#I  3.5.3 \*
gap> 
gap> mg[1][1] + mg[3][3] = mg[1][1]*mg[3][3];
true
gap> mm[7][1] + mg[3][3] = mm[7][1]*mg[3][3];
true
gap> mm[9][1] + ms[9][2] = mm[9][1]*ms[9][2];
true
gap> 
gap> Info(InfoFR,1,"3.5.4 TensorSumOp");
#I  3.5.4 TensorSumOp
gap> 
gap> ForAll(Flat([mg, mm, ms]), m -> TensorSum(m) = m);
true
gap> m := TensorSum(mg[3][1],mg[3][1]);
<FR machine with alphabet [ 1 .. 4 ] on Group( [ f1, f2, f3 ] )>
gap> Size(AlphabetOfFRObject(m)) = 4;
true
gap> IsGroupFRMachine(m);
true
gap> Activity(m[1]) = (1,2)(3,4);
true
gap> Size(PermGroup(SCGroup(m), 3)) = Size(PermGroup(SCGroup(mg[3][1]),3));
true
gap> m := TensorSum(mm[8][1],mm[8][1]);
<FR machine with alphabet [ 1 .. 14 ] on Monoid( [ m1, m2 ], ... )>
gap> Size(AlphabetOfFRObject(m)) = 14;
true
gap> IsMonoidFRMachine(m);
true
gap> Activity(m[1]) = Trans(Concatenation(List([0,1], i -> ListTrans(Activity(mm[8][1][1])) + 7*i)));
true
gap> Size(TransMonoid(SCMonoid(m), 1)) = Size(TransMonoid(SCMonoid(mm[8][1]),1));
true
gap> m := TensorSum(ms[9][2],ms[9][2]);
<FR machine with alphabet [ 1 .. 6 ] on Semigroup( [ s1, s2 ] )>
gap> Size(AlphabetOfFRObject(m)) = 6;
true
gap> IsSemigroupFRMachine(m);
true
gap> Activity(m[1]) = Trans(Concatenation(List([0,1], i -> ListTrans(Activity(ms[9][1][1])) + 3*i)));
true
gap> Size(TransSemigroup(SCSemigroup(m), 4)) = Size(TransSemigroup(SCSemigroup(ms[9][1]),4));
true
gap> 
gap> Info(InfoFR,1,"3.5.5 TensorProductOp");
#I  3.5.5 TensorProductOp
gap> 
gap> ForAll(Flat([mg, mm, ms]), m -> TensorProduct(m) = m);
true
gap> m := TensorProduct(mg[4][1],mg[4][1]);
<FR machine with alphabet [ 1 .. 25 ] on Group( [ f1 ] )>
gap> Size(AlphabetOfFRObject(m)) = 25;
true
gap> IsGroupFRMachine(m);
true
gap> Activity(m[1],2) = Activity(mg[4][1][1], 4);
true
gap> Size(PermGroup(SCGroup(m), 1)) = Size(PermGroup(SCGroup(mg[4][1]),2));
true
gap> SubFRMachine(TensorProduct(mg[1][1],mg[1][1],mg[1][1]), mg[2][1]) <> fail;
true
gap> m := TensorProduct(mm[7][1],mm[7][1]);
<FR machine with alphabet [ 1 .. 4 ] on Monoid( [ m1, m2, m3 ], ... )>
gap> Size(AlphabetOfFRObject(m)) = 4;
true
gap> IsMonoidFRMachine(m);
true
gap> Activity(m[1]) = Trans([1,1,2,2]);
true
gap> Size(TransMonoid(SCMonoid(m), 1)) = Size(TransMonoid(SCMonoid(mm[7][1]),2));
true
gap> m := TensorProduct(ms[9][2],ms[9][2]);
<FR machine with alphabet [ 1 .. 9 ] on Semigroup( [ s1, s2 ] )>
gap> Size(AlphabetOfFRObject(m)) = 9;
true
gap> IsSemigroupFRMachine(m);
true
gap> Activity(m[1]) = Activity(ms[9][2][1], 2);
true
gap> Size(TransSemigroup(SCSemigroup(m), 2)) = Size(TransSemigroup(SCSemigroup(ms[9][1]),4));
true
gap> 
gap> Info(InfoFR,1,"3.5.6 DirectSumOp");
#I  3.5.6 DirectSumOp
gap> 
gap> ForAll(Flat([mg, mm, ms]), m -> DirectSum(m) = m);
true
gap> m := DirectSum(mg[1][1],mg[2][1]);
<FR machine with alphabet [ 1 .. 10 ] on Group( 
[ f1.1, f2.1, f3.1, f4, f5, f1.2, f2.2, f3.2 ] )>
gap> Size(AlphabetOfFRObject(m)) = 10;
true
gap> Size(GeneratorsOfGroup(StateSet(m))) = 8;
true
gap> IsGroupFRMachine(m);
true
gap> Activity(m[2]) = Activity(mg[1][1][2]);
true
gap> Activity(m[6]) = PermList(Concatenation([1,2],ListPerm(Activity(mg[2][1][1]))+2));
true
gap> Size(PermGroup(SCGroup(m),2)) = Size(PermGroup(SCGroup(mg[1][1]),2))*Size(PermGroup(SCGroup(mg[2][1]),2));
true
gap> m := DirectSum(mm[4][1],mm[7][3]);
<FR machine with alphabet [ 1, 2, 3, 4, 5, 6, 7 ] on Monoid( 
[ m1, z, y, x ], ... )>
gap> Size(AlphabetOfFRObject(m)) = 7;
true
gap> Size(GeneratorsOfMonoid(StateSet(m))) = 4;
true
gap> IsMonoidFRMachine(m);
true
gap> Activity(m[1]) = Activity(mm[4][1][1]);
true
gap> Activity(m[2]) = TransList(Concatenation([1,2,3,4,5],ListTrans(Activity(mm[7][1][1]))+5));
true
gap> Size(TransMonoid(SCMonoid(m),2)) = Size(TransMonoid(SCMonoid(mm[4][1]),2))*Size(TransMonoid(SCMonoid(mm[7][1]),2));
true
gap> m := DirectSum(ms[1][1],ms[9][2]);
<FR machine with alphabet [ 1, 2, 3, 4, 5 ] on Semigroup( 
[ s1.1, s2.1, s3, s4, s5, s1.2, s2.2 ] )>
gap> Size(AlphabetOfFRObject(m)) = 5;
true
gap> Size(GeneratorsOfSemigroup(StateSet(m))) = 7;
true
gap> IsSemigroupFRMachine(m);
true
gap> Activity(m[2]) = Activity(ms[1][1][2]);
true
gap> Activity(m[6]) = TransList(Concatenation([1,2],ListTrans(Activity(ms[9][1][1]))+2));
true
gap> 
gap> Info(InfoFR,1,"3.5.7 DirectProductOp");
#I  3.5.7 DirectProductOp
gap> 
gap> ForAll(Flat([mg, mm, ms]), m -> DirectProduct(m) = m);
true
gap> m := DirectProduct(mg[1][1],mg[2][1]);
<FR machine with alphabet [ 1 .. 16 ] on Group( 
[ f1.1, f2.1, f3.1, f4, f5, f1.2, f2.2, f3.2 ] )>
gap> Size(AlphabetOfFRObject(m)) = 16;
true
gap> Size(GeneratorsOfGroup(StateSet(m))) = 8;
true
gap> IsGroupFRMachine(m);
true
gap> ForAll([1..5], n -> Output(m[n]) = ListX(8*(Output(mg[1][1][n])-1),[1..8],\+));
true
gap> ForAll([1..3], n -> Output(m[5+n]) = ListX(8*[0,1],Output(mg[2][1][n]),\+));
true
gap> Size(Set(WreathRecursion(m)(GeneratorsOfFRMachine(m)[3])[1]{[1..8]})) = 1;
true
gap> Size(Set(WreathRecursion(m)(GeneratorsOfFRMachine(m)[3])[1]{[9..16]})) = 1;
true
gap> Size(Set(WreathRecursion(m)(GeneratorsOfFRMachine(m)[7])[1]{[1,3..15]})) = 1;
true
gap> Size(Set(WreathRecursion(m)(GeneratorsOfFRMachine(m)[6])[1])) = 1;
true
gap> Size(PermGroup(SCGroup(m),2)) = Size(PermGroup(SCGroup(mg[1][1]),2))*Size(PermGroup(SCGroup(mg[2][1]),2));
true
gap> m := DirectProduct(mm[7][1],mm[1][1]);
<FR machine with alphabet [ 1 .. 4 ] on Monoid( 
[ m1.1, m2.1, m3.1, m1.2, m2.2, m3.2, m4, m5 ], ... )>
gap> Size(AlphabetOfFRObject(m)) = 4;
true
gap> Size(GeneratorsOfMonoid(StateSet(m))) = 8;
true
gap> IsMonoidFRMachine(m);
true
gap> ForAll([1..3], n -> Output(m[n]) = ListX(2*(Output(mm[7][1][n])-1),[1..2],\+));
true
gap> ForAll([1..5], n -> Output(m[3+n]) = ListX(2*[0,1],Output(mm[1][1][n]),\+));
true
gap> Size(TransMonoid(SCMonoid(m),2)) = Size(TransMonoid(SCMonoid(mm[7][1]),2))*Size(TransMonoid(SCMonoid(mm[1][1]),2));
true
gap> m := DirectProduct(ms[9][1],mm[7][1]);
<FR machine with alphabet [ 1 .. 6 ] on Semigroup( 
[ s1, s2, <identity ...>, m1, m2, m3 ] )>
gap> Size(AlphabetOfFRObject(m)) = 6;
true
gap> Size(GeneratorsOfSemigroup(StateSet(m))) = 6;
true
gap> IsSemigroupFRMachine(m);
true
gap> ForAll([1..2], n -> Output(m[n]) = ListX(2*(Output(ms[9][1][n])-1),[1..2],\+));
true
gap> Set(List([1..4], n -> Output(m[2+n]))) = Set(List([1..4], n -> ListX(2*[0,1,2],Output(AsSemigroupFRMachine(mm[7][1]),n),\+)));
true
gap> Size(TransMonoid(SCMonoid(m),2)) = Size(TransMonoid(SCMonoid(mm[7][1]),2))*Size(TransMonoid(SCMonoid(mm[9][1]),2));
true
gap> 
gap> Info(InfoFR,1,"3.5.8 TreeWreathProduct");
#I  3.5.8 TreeWreathProduct
gap> 
gap> m := TreeWreathProduct(mg[1][1],mg[3][1],2,2);
<FR machine with alphabet [ 1 .. 4 ] on Group( 
[ f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11 ] )>
gap> Size(AlphabetOfFRObject(m)) = 4;
true
gap> Size(GeneratorsOfGroup(StateSet(m))) = 11;
true
gap> Collected(Flat(List([1..11], i -> WreathRecursion(m)(GeneratorsOfGroup(StateSet(m))[i])[1]))){[1..11]}[2] = [28,1,1,1,1,1,1,1,3,2,2];
true
gap> m := TreeWreathProduct(mm[7][1], ms[8][2],2,5);
<FR machine with alphabet [ 1 .. 14 ] on Semigroup( 
[ s1, s2, s3, s4, s5, s6, s7, s8, s9 ] )>
gap> Size(AlphabetOfFRObject(m)) = 14;
true
gap> Size(GeneratorsOfSemigroup(StateSet(m))) = 9;
true
gap> IsOne(m[9]);
true
gap> Collected(Flat(List([1..9], i -> WreathRecursion(m)(GeneratorsOfSemigroup(StateSet(m))[i])[1]))){[1..9]}[2] = [1,1,1,7,7,3,3,2,101];
true
gap> 
gap> Info(InfoFR,1,"3.5.9 SubFRMachine");
#I  3.5.9 SubFRMachine
gap> 
gap> SubFRMachine(mg[6][1], mg[6][3]);
[ a, b ] -> [ f1, f2 ]
gap> SubFRMachine(mmi[1][1], AsMonoidFRMachine(mg[1][1]));
MappingByFunction( <free monoid on the generators 
[ m1, m2, m3, m4, m5, m6, m7, m8, m9, m10 ]>, <free monoid on the generators 
[ m1, m2, m3, m4, m5, m6, m7, m8, m9 ]>, function( w ) ... end )
gap> SubFRMachine(AsMonoidFRMachine(mg[1][1]), mmi[1][1]);
MappingByFunction( <free monoid on the generators 
[ m1, m2, m3, m4, m5, m6, m7, m8, m9 ]>, <free monoid on the generators 
[ m1, m2, m3, m4, m5, m6, m7, m8, m9, m10 ]>, function( w ) ... end )
gap> SubFRMachine(mmi[5][1], AsMonoidFRMachine(mg[5][1]));
MappingByFunction( <free monoid on the generators [ m1, m2, m3, m4, m5, m6 
 ]>, <free monoid on the generators [ x, x', y, y', z, z' 
 ]>, function( w ) ... end )
gap> SubFRMachine(AsMonoidFRMachine(mg[5][2]), mmi[5][2]);
MappingByFunction( <free monoid on the generators [ x, x', y, y', z, z' 
 ]>, <free monoid on the generators [ m1, m2, m3, m4, m5, m6 
 ]>, function( w ) ... end )
gap> for i in [1, 5] do
>   Print("Machine ",i,":\n");
>   for list in [mg] do
>     Print(ForAll(list[i], m -> SubFRMachine(mmi[i][1], AsMonoidFRMachine(m)) <> fail), "\n");
>   od;
> od;
Machine 1:
true
Machine 5:
true
gap> for i in [1..5] do
>   Print("Machine ",i,":\n");
>   for list in [mg, mmi] do
>     Print(ForAll(list[i], m -> SubFRMachine(AsSemigroupFRMachine(m), msiu[i][1]) <> fail), "\n");
>   od;
> od;
Machine 1:
true
true
Machine 2:
true
true
Machine 3:
true
true
Machine 4:
true
true
Machine 5:
true
true
gap> for i in [7] do
>   Print("Machine ",i,":\n");
>   for list in [mm] do
>     Print(ForAll(list[i], m -> SubFRMachine(AsSemigroupFRMachine(m), msu[i][1]) <> fail), "\n");
>   od;
> od;
Machine 7:
true
gap> 
gap> Info(InfoFR,1,"3.5.10 Minimized");
#I  3.5.10 Minimized
gap> 
gap> Length(GeneratorsOfGroup(StateSet(Minimized(mg[1][1])))) = 4;
true
gap> Length(GeneratorsOfMonoid(StateSet(Minimized(mmi[1][1])))) = 4;
true
gap> Length(GeneratorsOfSemigroup(StateSet(Minimized(msiu[1][1])))) = 5;
true
gap> Length(GeneratorsOfGroup(StateSet(Minimized(mg[2][1])))) = 3;
true
gap> Length(GeneratorsOfMonoid(StateSet(Minimized(mmi[2][1])))) = 3;
true
gap> Length(GeneratorsOfSemigroup(StateSet(Minimized(msiu[2][1])))) = 4;
true
gap> Length(GeneratorsOfGroup(StateSet(Minimized(mg[3][1])))) = 3;
true
gap> Length(GeneratorsOfMonoid(StateSet(Minimized(mmi[3][1])))) = 3;
true
gap> Length(GeneratorsOfSemigroup(StateSet(Minimized(msiu[3][1])))) = 4;
true
gap> Length(GeneratorsOfGroup(StateSet(Minimized(mg[4][1])))) = 1;
true
gap> Length(GeneratorsOfMonoid(StateSet(Minimized(mmi[4][1])))) = 2;
true
gap> Length(GeneratorsOfSemigroup(StateSet(Minimized(msiu[4][1])))) = 3;
true
gap> Length(GeneratorsOfGroup(StateSet(Minimized(mg[5][1])))) = 3;
true
gap> Length(GeneratorsOfMonoid(StateSet(Minimized(mmi[5][1])))) = 6;
true
gap> Length(GeneratorsOfSemigroup(StateSet(Minimized(msiu[5][1])))) = 7;
true
gap> Length(GeneratorsOfGroup(StateSet(Minimized(mg[6][1])))) = 2;
true
gap> Length(GeneratorsOfMonoid(StateSet(Minimized(mmi[6][1])))) = 4;
true
gap> Length(GeneratorsOfSemigroup(StateSet(Minimized(msiu[6][1])))) = 5;
true
gap> Length(GeneratorsOfMonoid(StateSet(Minimized(mm[7][1])))) = 3;
true
gap> Length(GeneratorsOfSemigroup(StateSet(Minimized(msu[7][1])))) = 4;
true
gap> Length(GeneratorsOfMonoid(StateSet(Minimized(AsMonoidFRMachine(msu[7][1]))))) = 3;
true
gap> Length(GeneratorsOfMonoid(StateSet(Minimized(mm[8][1])))) = 2;
true
gap> Length(GeneratorsOfSemigroup(StateSet(Minimized(ms[8][1])))) = 2;
true
gap> Length(GeneratorsOfSemigroup(StateSet(Minimized(msu[8][1])))) = 3;
true
gap> Length(GeneratorsOfMonoid(StateSet(Minimized(mm[9][1])))) = 2;
true
gap> Length(GeneratorsOfSemigroup(StateSet(Minimized(ms[9][1])))) = 2;
true
gap> Length(GeneratorsOfSemigroup(StateSet(Minimized(msu[9][1])))) = 3;
true
gap> 
gap> Info(InfoFR,1,"3.5.11 Correspondence");
#I  3.5.11 Correspondence
gap> 
gap> m := mg[1][1];
<FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2, f3, f4, f5 ] )>
gap> min := Minimized(m);
<FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2, f3, f4 ] )>
gap> map := Correspondence(min);
[ f1, f2, f3, f4, f5 ] -> [ <identity ...>, f1, f2, f3, f4 ]
gap> f := StateSet(m);
<free group on the generators [ f1, f2, f3, f4, f5 ]>
gap> f.1^map = One(StateSet(min));
true
gap> 
gap> m2 := m + m;
<FR machine with alphabet [ 1, 2 ] on Group( [ f1.1, f2.1, f3.1, f4.1, f5.1, 
  f1.2, f2.2, f3.2, f4.2, f5.2 ] )>
gap> map2 := Correspondence(m2);
[ [ f1, f2, f3, f4, f5 ] -> [ f1.1, f2.1, f3.1, f4.1, f5.1 ], 
  [ f1, f2, f3, f4, f5 ] -> [ f1.2, f2.2, f3.2, f4.2, f5.2 ] ]
gap> min := Minimized(m2);
<FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2, f3, f4 ] )>
gap> map := Correspondence(min);
[ f1.1, f2.1, f3.1, f4.1, f5.1, f1.2, f2.2, f3.2, f4.2, f5.2 ] -> 
[ <identity ...>, f1, f2, f3, f4, <identity ...>, f1, f2, f3, f4 ]
gap> f := StateSet(m);
<free group on the generators [ f1, f2, f3, f4, f5 ]>
gap> (f.1^map2[1])^map = One(StateSet(min));
true
gap> (f.1^map2[2])^map = One(StateSet(min));
true
gap> 
gap> m := AsGroupFRMachine(mm[5][1]);
<FR machine with alphabet [ 1, 2, 3, 4, 5, 6, 7 ] on Group( [ f1, f2, f3 ] )>
gap> Correspondence(m);
MappingByFunction( <free monoid on the generators 
[ x, y, z ]>, <free group on the generators 
[ f1, f2, f3 ]>, function( w ) ... end )
gap> 
gap> for type in [mg, mm, mmi] do
>   for list in type do
>     for m in list do
>       m2 := AsSemigroupFRMachine(m);
>       map := Correspondence(m2);
>       Print(Length(States(FRElement(m2, One(StateSet(m))^map))) = 1, "\n");
>     od;
>   od;
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
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
true
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
gap> firstel := function(list)
>   if IsEmpty(list) then
>     return [];
>   else
>     return [list[1]];
>   fi;
> end;
function( list ) ... end
gap> for type in [mg, mm, ms, mmi, msiu, msu] do
>   for list in type do
>     Print(AsSet(list) = firstel(list), "\n");
>   od;
>   Print("\n");
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

true
true
true
true
true
true
true
true
true

true
true
true
true
true
true
true
true
true

true
true
true
true
true
true
true
true
true

true
true
true
true
true
true
true
true
true

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
gap> Length(AsSet(Concatenation(mg[1],mg[3],mm[7]))) = 3;
true
gap> 
gap> STOP_TEST( "chapter-3.tst", 3*10^8 );

#E chapter-3.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
