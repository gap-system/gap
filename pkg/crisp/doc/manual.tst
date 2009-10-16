
gap> RequirePackage ("crisp");
true
gap> FermatPrimes := Class (p -> IsPrime (p) and p = 2^LogInt (p, 2) + 1);
Class (in:=function( p ) ... end)

gap> cmpl := Complement([1,2]);
Complement ([ 1, 2 ])
gap> Complement (cmpl);
[ 1, 2 ]

gap> Intersection (Class (IsPrimeInt), [1..10]);
[ 2, 3, 5, 7 ]
gap> Intersection (Class (IsPrimeInt), Class (n -> n = 2^LogInt (n+1, 2) - 1));
Intersection ([ Class (in:=function( n ) ... end),
  Class (in:=function( n ) ... end) ])

gap> Union (Class (n -> n mod 2 = 0), Class (n -> n mod 3 = 0));
Union ([ Class (in:=function( n ) ... end), Class (in:=function( n ) ... end)
 ])

gap> Difference (Class (IsPrimePowerInt), Class (IsPrimeInt));
Intersection ([ Class (in:=function( n ) ... end),
  Complement (Class (in:=function( n ) ... end)) ])
gap> Difference ([1..10], Class (IsPrimeInt));
[ 1, 4, 6, 8, 9, 10 ]

gap> GroupClass(IsNilpotent);
GroupClass (in:=<Operation "IsNilpotent">)
gap> GroupClass([CyclicGroup(2), CyclicGroup(3)]);
GroupClass ([ <pc group of size 2 with 1 generators>,
  <pc group of size 3 with 1 generators> ])
gap> AbelianIsomorphismTest := function (A,B)
>     if IsAbelian (A) then
>         if IsAbelian (B) then
>             return AbelianInvariants (A) = AbelianInvariants (B);
>         else
>             return false;
>         fi;
>     elif IsAbelian (B) then
>         return false;
>     else # this will not happen if called from GroupClass
>         Error ("At least one of the groups <A> and <B> must be abelian");
>     fi;
> end;
function( A, B ) ... end
gap> cl := GroupClass ([AbelianGroup ([2,2]), AbelianGroup ([3,5])],
> AbelianIsomorphismTest);
GroupClass ([ <pc group of size 4 with 2 generators>,
  <pc group of size 15 with 2 generators> ], function( A, B ) ... end)
gap> Group ((1,2), (3,4)) in cl;
true

gap> nilp := GroupClass (IsNilpotent);
GroupClass (in:=<Operation "IsNilpotent">)
gap> SetIsFittingClass (nilp, true);
gap> nilp;
FittingClass (in:=<Operation "IsNilpotent">)

gap> nilp := SchunckClass (rec (bound := G -> not IsCyclic (G),
>        name := "class of all nilpotent groups"));
class of all nilpotent groups
gap> DihedralGroup (8) in nilp;
true
gap> SymmetricGroup (3) in nilp;
false

gap> H := SchunckClass (rec (bound := G -> Size (G) = 6));
SchunckClass (bound:=function( G ) ... end)
gap> Size (Projector (GL(2,3), H));
16
gap> # H-projectors coincide with Sylow subgroups
gap> U := SchunckClass (rec ( # class of all supersolvable groups
>    bound := G -> not IsPrimeInt ( Size (Socle (G)))
> ));
SchunckClass (bound:=function( G ) ... end)
gap> Size (Projector (SymmetricGroup (4), U));
6
gap> # the projectors are the point stabilizers

gap> der3 := OrdinaryFormation (rec (
>    res := G -> DerivedSubgroup (DerivedSubgroup (DerivedSubgroup (G)))
> ));
OrdinaryFormation (res:=function( G ) ... end)
gap> SymmetricGroup (4) in der3;
true
gap> GL (2,3) in der3;
false
gap> exp6 := OrdinaryFormation (rec (
>    \in := G -> 6 mod Exponent (G) = 0,
>    char := [2,3]));
OrdinaryFormation (in:=function( G ) ... end)

gap> nilp := SaturatedFormation (rec (
>      locdef := function (G, p)
>          return GeneratorsOfGroup (G);
>      end));
SaturatedFormation (locdef:=function( G, p ) ... end)
gap> form := SaturatedFormation (rec (
>    locdef := function (G, p)
>        if p = 2 then
>           return GeneratorsOfGroup (G);
>        elif p mod 4 = 3 then
>           return GeneratorsOfGroup (DerivedSubgroup (G));
>        else
>           return fail;
>        fi;
>     end));
SaturatedFormation (locdef:=function( G, p ) ... end)
gap> Projector (GL(2,3), form);
Group([ [ [ Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ],
  [ [ Z(3)^0, Z(3) ], [ 0*Z(3), Z(3)^0 ] ],
  [ [ Z(3), 0*Z(3) ], [ 0*Z(3), Z(3) ] ] ])

gap> nilp := SaturatedFormation (rec (\in := IsNilpotent, name := "nilp"));
nilp
gap> FormationProduct (nilp, der3); # no characteristic known
FormationProduct (nilp, OrdinaryFormation (res:=function( G ) ... end))
gap> HasIsSaturated (last);HasCharacteristic (nilp);
false
false
gap> SetCharacteristic (nilp, AllPrimes);
gap> FormationProduct (nilp, der3); # try with characteristic
FormationProduct (nilp, OrdinaryFormation (res:=function( G ) ... end))
gap> IsSaturated (last);
true

gap> nilp := FittingFormation (rec (\in := IsNilpotent, name := "nilp"));;
gap> FormationProduct (nilp, nilp);
FittingFormationProduct (nilp, nilp)
gap> FittingProduct (nilp, nilp);
FittingFormationProduct (nilp, nilp)
gap> FittingFormationProduct (nilp, nilp);
FittingFormationProduct (nilp, nilp)

gap> G := DirectProduct (SL(2,3), CyclicGroup (2));;
gap> data := rec (gens := GeneratorsOfGroup (G),
>    comms := List (Combinations (GeneratorsOfGroup (G), 2),
>       x -> Comm (x[1],x[2])));;
gap> OneNormalSubgroupMinWrtQProperty (
>    G,
>    function (U, V, R, data) # test if U/V is central in G
>        if ForAny (ModuloPcgs (U, V), y ->
>           ForAny (data.gens, x -> not Comm (x, y) in V)) then
>           return false;
>        else
>           return fail;
>        fi;
>     end,
>     function (S, R, data)
>        return ForAll (data.comms, x -> x in S);
>     end,
>     data) = DerivedSubgroup (G); # compare results
true

gap> normsWithSupersolvableFactorGroups :=
> AllNormalSubgroupsWithQProperty (GL(2,3),
>    function (U, V, R, data)
>       return IsPrimeInt (Index (U, V));
>    end,
>    ReturnFail, # pretest is sufficient
>    fail); # no data required
[ GL(2,3),
  Group([ [ [ Z(3)^0, Z(3) ], [ 0*Z(3), Z(3)^0 ] ], [ [ Z(3), Z(3)^0 ],
          [ Z(3)^0, Z(3)^0 ] ], [ [ 0*Z(3), Z(3)^0 ], [ Z(3), 0*Z(3) ] ],
      [ [ Z(3), 0*Z(3) ], [ 0*Z(3), Z(3) ] ] ]),
  Group([ [ [ Z(3), Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ],
      [ [ 0*Z(3), Z(3)^0 ], [ Z(3), 0*Z(3) ] ],
      [ [ Z(3), 0*Z(3) ], [ 0*Z(3), Z(3) ] ] ]) ]

gap> myNilpotentGroups := FittingClass(rec(\in := IsNilpotent,
>    rad := FittingSubgroup));
FittingClass (in:=<Operation "IsNilpotent">, rad:=<Operation "FittingSubgroup"\
>)
gap> myTwoGroups := FittingClass(rec(
>    \in := G -> IsSubset([2], Set(Factors(Size(G)))),
>    rad :=  G -> PCore(G,2),
>    inj := G -> SylowSubgroup(G,2)));
FittingClass (in:=function( G ) ... end, rad:=function( G ) ... end, inj:=func\
tion( G ) ... end)
gap> myL2_Nilp := FittingClass (rec (\in := 
>     G -> IsSolvableGroup (G) 
>          and Index (G, Injector (G, myNilpotentGroups)) mod 2 <> 0));
FittingClass (in:=function( G ) ... end)
gap> SymmetricGroup (3) in myL2_Nilp;
false
gap> SymmetricGroup (4) in myL2_Nilp;
true

gap> FittingProduct (myNilpotentGroups, myTwoGroups);
FittingProduct (FittingClass (in:=<Operation "IsNilpotent">, rad:=<Operation "\
FittingSubgroup">), FittingClass (in:=function( G ) ... end, rad:=function( G \
) ... end, inj:=function( G ) ... end))
gap> FittingProduct (myNilpotentGroups, myL2_Nilp);
FittingProduct (FittingClass (in:=<Operation "IsNilpotent">, rad:=<Operation "\
FittingSubgroup">), FittingClass (in:=function( G ) ... end))

gap>  fitset := FittingSet(SymmetricGroup (4), rec(
>        \in := S -> IsSubgroup (AlternatingGroup (4), S),
>        rad := S -> Intersection (AlternatingGroup (4), S),
>        inj := S -> Intersection (AlternatingGroup (4), S)));
FittingSet (SymmetricGroup(
[ 1 .. 4 ] ), rec (in:=function( S ) ... end, rad:=function( S ) ... end, inj:\
=function( S ) ... end))
gap> FittingSet (SymmetricGroup (3), rec(
>       \in := H -> H in [Group (()), Group ((1,2)), Group ((1,3)), Group ((2,3))]));
FittingSet (SymmetricGroup( [ 1 .. 3 ] ), rec (in:=function( H ) ... end))

gap> alpha := GroupHomomorphismByImages (SymmetricGroup (4), SymmetricGroup (3),
>  [(1,2), (1,3), (1,4)], [(1,2), (1,3), (2,3)]);;
gap> im := ImageFittingSet (alpha, fitset);
FittingSet (Group( [ (1,2), (1,3), (2,3)
 ] ), rec (inj:=function( G ) ... end))
gap> Radical (Image (alpha), im);
Group([ (1,2,3), (1,3,2) ])

gap> pre := PreImageFittingSet (alpha, NilpotentGroups);
FittingSet (SymmetricGroup( [ 1 .. 4 ] ), rec (inj:=function( G ) ... end))
gap> Injector (Source (alpha), pre);
Group([ (1,4)(2,3), (1,2)(3,4), (2,3,4) ])

gap> F1 := FittingSet (SymmetricGroup (3),
> rec (\in := IsNilpotent, rad := FittingSubgroup));
FittingSet (SymmetricGroup(
[ 1 .. 3 ] ), rec (in:=<Operation "IsNilpotent">, rad:=<Operation "FittingSubg\
roup">))
gap> F2 := FittingSet (AlternatingGroup (4),
> rec (\in := ReturnTrue, rad := H -> H));
FittingSet (AlternatingGroup(
[ 1 .. 4 ] ), rec (in:=function(  ) ... end, rad:=function( H ) ... end))
gap> F := Intersection (F1, F2);
FittingSet (Group(
[ (1,2,3) ] ), rec (in:=function( x ) ... end, rad:=function( G ) ... end))
gap> Intersection (F1, PiGroups ([2,5]));
FittingSet (SymmetricGroup(
[ 1 .. 3 ] ), rec (in:=function( x ) ... end, rad:=function( G ) ... end))

gap> Radical (SymmetricGroup (4), FittingClass (rec(\in := IsNilpotentGroup)));
Group([ (1,4)(2,3), (1,3)(2,4) ])
gap> Radical (SymmetricGroup (4), myL2_Nilp);
Sym( [ 1 .. 4 ] )
gap> Radical (SymmetricGroup (3), myL2_Nilp);
Group([ (1,2,3) ])

gap> Injector (SymmetricGroup (4), FittingClass (rec(\in := IsNilpotentGroup)));
Group([ (1,3)(2,4), (1,4)(2,3), (3,4) ])

gap> AllNormalSubgroupsWithNProperty (
> DihedralGroup (8),
>     ReturnFail,
>     function (R, S, data)
>         return IsAbelian (R);
>     end,
>     fail);
[ Group([ f3 ]), <pc group with 2 generators>, <pc group with 2 generators>,
  Group([ f2, f3 ]), Group([  ]) ]
