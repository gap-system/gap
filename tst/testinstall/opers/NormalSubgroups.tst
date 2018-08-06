gap> START_TEST("NormalSubgroups.tst");

# Natural symmetric groups
gap> NormalSubgroups(SymmetricGroup(0)) = [Group(())];
true
gap> NormalSubgroups(SymmetricGroup(1)) = [Group(())];
true
gap> Set(NormalSubgroups(SymmetricGroup(2))) =
> Set([Group(()), SymmetricGroup(2)]);
true
gap> Set(NormalSubgroups(SymmetricGroup(3))) =
> Set([Group(()), AlternatingGroup(3), SymmetricGroup(3)]);
true
gap> Set(NormalSubgroups(SymmetricGroup(4))) =
> Set([Group(()), Group((1,2)(3,4), (1,3)(2,4)),
>  AlternatingGroup(4), SymmetricGroup(4)]);
true
gap> Set(NormalSubgroups(SymmetricGroup(5))) =
> Set([Group(()), AlternatingGroup(5), SymmetricGroup(5)]);
true
gap> Set(NormalSubgroups(SymmetricGroup(6))) =
> Set([Group(()), AlternatingGroup(6), SymmetricGroup(6)]);
true
gap> Set(NormalSubgroups(SymmetricGroup(15))) =
> Set([Group(()), AlternatingGroup(15), SymmetricGroup(15)]);
true
gap> Set(NormalSubgroups(SymmetricGroup([3,7,4,11,70]))) =
> Set([Group(()), AlternatingGroup([3, 4, 7, 11, 70]),
>      SymmetricGroup([3, 4, 7, 11, 70])]);
true
gap> Set(NormalSubgroups(SymmetricGroup([7,4,13,21]))) =
> Set([Group(()), Group((4,7)(13,21), (4,13)(7,21)),
>      AlternatingGroup([4, 7, 13, 21]), SymmetricGroup([4, 7, 13, 21])]);
true
gap> NormalSubgroups(SymmetricGroup([42])) = [Group(())];
true
gap> NormalSubgroups(SymmetricGroup([])) = [Group(())];
true
gap> G := Group((7,3,5,11), (11,3), (5,3));;
gap> IsNaturalSymmetricGroup(G);
true
gap> Set(NormalSubgroups(G)) =
> Set([Group(()), Group((3,5)(7,11), (3,7)(5,11)),
>      AlternatingGroup([3, 5, 7, 11]), SymmetricGroup([3, 5, 7, 11])]);
true

# Non-natural symmetric groups
gap> S4 := Group((1,2,3,4), (1,2));;
gap> hom := ActionHomomorphism(S4, Arrangements([1..4], 4), OnTuples);;
gap> G := Image(hom);;
gap> IsSymmetricGroup(G);
true
gap> SymmetricDegree(G);
4
gap> MovedPoints(G) = [1..24];
true
gap> Set(NormalSubgroups(G)) = Set([G,
> Group([(1,13,9)(2,14,10)(3,15,7)(4,16,8)
>        (5,17,12)(6,18,11)(19,23,22)(20,24,21),
>        (1,21,16)(2,22,15)(3,19,18)(4,20,17)
>        (5,24,13)(6,23,14)(7,11,10)(8,12,9)]), 
> Group([(1,24)(2,23)(3,22)(4,21)(5,20)(6,19)
>        (7,18)(8,17)(9,16)(10,15)(11,14)(12,13),
>        (1,8)(2,7)(3,11)(4,12)(5,9)(6,10)
>        (13,21)(14,22)(15,19)(16,20)(17,24)(18,23)]),
> Group(())]);
true

# Natural alternating groups
gap> NormalSubgroups(AlternatingGroup(0)) = [Group(())];
true
gap> NormalSubgroups(AlternatingGroup(1)) = [Group(())];
true
gap> Set(NormalSubgroups(AlternatingGroup(2))) =
> Set([Group(()), AlternatingGroup(2)]);
true
gap> Set(NormalSubgroups(AlternatingGroup(3))) =
> Set([Group(()), AlternatingGroup(3)]);
true
gap> Set(NormalSubgroups(AlternatingGroup(4))) =
> Set([Group(()), Group((1,2)(3,4), (1,3)(2,4)),
>  AlternatingGroup(4)]);
true
gap> Set(NormalSubgroups(AlternatingGroup(5))) =
> Set([Group(()), AlternatingGroup(5)]);
true
gap> Set(NormalSubgroups(AlternatingGroup(6))) =
> Set([Group(()), AlternatingGroup(6)]);
true
gap> Set(NormalSubgroups(AlternatingGroup(15))) =
> Set([Group(()), AlternatingGroup(15)]);
true
gap> Set(NormalSubgroups(AlternatingGroup([3,7,4,11,70]))) =
> Set([Group(()), AlternatingGroup([3, 4, 7, 11, 70])]);
true
gap> Set(NormalSubgroups(AlternatingGroup([7,4,13,21]))) =
> Set([Group(()), Group((4,7)(13,21), (4,13)(7,21)),
>      AlternatingGroup([4, 7, 13, 21])]);
true
gap> NormalSubgroups(AlternatingGroup([42])) = [Group(())];
true
gap> NormalSubgroups(AlternatingGroup([])) = [Group(())];
true
gap> G := Group((7,3,5), (11,3,7));;
gap> IsNaturalAlternatingGroup(G);
true
gap> Set(NormalSubgroups(G)) =
> Set([Group(()), Group((3,5)(7,11), (3,7)(5,11)),
>      AlternatingGroup([3, 5, 7, 11])]);
true

#
gap> STOP_TEST( "NormalSubgroups.tst", 1);
