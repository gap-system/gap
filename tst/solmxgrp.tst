#############################################################################
##
#W  solmxgrp.tst                   GAP library		       Gene Cooperman
#W							     and Scott Murray
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1998,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id$");
gap> fooAsMatrixGroup := G -> Group(
>   List( GeneratorsOfGroup( G ), elt -> One(GF(2))
> * PermutationMat( elt, NrMovedPoints(G) ) ) );
function( G ) ... end
gap> bar := function( arg )
>     local G, g, i, size;
>     G := arg[1];
>     g := PseudoRandom( GL(DimensionOfMatrixGroup(G),
>                           Size(FieldOfMatrixGroup(G))) );
>     G := G^g; # randomly conjugate group to make it harder.
>     IsAbelian(G);
>     # If SmallSpaceCutoff = 0, can use:
>     #    ChainSubgroup(G), Size(G), not PseudoRandom(G) in G,
>     #    Length(Enumerator(G)) <> Size(G)
>     MakeHomChain(G);
>     size := SizeOfChainOfGroup(G);
>     if ( Length(arg) = 2 and size <> arg[2] ) then
>         Error("Size test failed.\n");
>     fi;
>     for i in [1..5] do
>         # if not PseudoRandom(G) in G then Error("Sift failed"); fi;
>         if not IsOne(Sift(G,PseudoRandom(G))) then Error("Sift failed"); fi;
>     od;
>     Print("Sift/group membership test succeeded.\n");
>     if size <= 1000 then
>       if Length(Enumerator(G)) <> size then Error("Enumerator failed"); fi;
>       Print("Enumerator test succeeded.\n");
>     else Print("enumerator test skipped.  Size of group too large.\n");
>     fi;
>     return size;
> end;
function( arg ) ... end
gap> foo := function(ints)
>     local G, size;
>     Print("Abelian invariants of new group: ",ints,"\n");
>     G := fooAsMatrixGroup( AbelianGroup(IsPermGroup, ints) );
>     bar( G, Product(ints) );
> end;
function( ints ) ... end

gap> foo( [3] );
Abelian invariants of new group: [ 3 ]
Sift/group membership test succeeded.
Enumerator test succeeded.
gap> foo( [1,3] );
Abelian invariants of new group: [ 1, 3 ]
Sift/group membership test succeeded.
Enumerator test succeeded.
gap> foo( [3,5] );
Abelian invariants of new group: [ 3, 5 ]
Sift/group membership test succeeded.
Enumerator test succeeded.
gap> foo( [2,2] );
Abelian invariants of new group: [ 2, 2 ]
Sift/group membership test succeeded.
Enumerator test succeeded.
gap> foo( [2,2,4] );
Abelian invariants of new group: [ 2, 2, 4 ]
Sift/group membership test succeeded.
Enumerator test succeeded.
gap> foo( [3,3] );
Abelian invariants of new group: [ 3, 3 ]
Sift/group membership test succeeded.
Enumerator test succeeded.
gap> foo( List([1..5], x->2) );
Abelian invariants of new group: [ 2, 2, 2, 2, 2 ]
Sift/group membership test succeeded.
Enumerator test succeeded.
# Takes several seconds
# foo( List([1..5], x->3) );
gap> foo( [3,4,4,4,5,5,5] );
Abelian invariants of new group: [ 3, 4, 4, 4, 5, 5, 5 ]
Sift/group membership test succeeded.
enumerator test skipped.  Size of group too large.
gap> 
gap> primePowers := Filtered([1..100],i->Length(PrimePowersInt(i))=2);
[ 2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25, 27, 29, 31, 32, 37, 41,
  43, 47, 49, 53, 59, 61, 64, 67, 71, 73, 79, 81, 83, 89, 97 ]
gap> foo( [ 2, 83, 43 ] );
Abelian invariants of new group: [ 2, 83, 43 ]
Sift/group membership test succeeded.
enumerator test skipped.  Size of group too large.
gap> G := fooAsMatrixGroup( AbelianGroup(IsPermGroup, [2,2,4]));
<matrix group with 3 generators>
gap> gens := One(GF(9))*List(GeneratorsOfGroup(G), gen ->
>                                 List(gen,i->List(i,IntFFE)));;
gap> gens[1] := IdentityMat(8,GF(9));;
gap> gens[1][1][1] := Z(9)^6;; # elt of order 4
gap> G := Group(gens);
<matrix group with 3 generators>
gap> bar(G,32);
Sift/group membership test succeeded.
Enumerator test succeeded.
32

gap> STOP_TEST( "solmxgrp.tst", 80000000000 );


#############################################################################
##
#E  
##
