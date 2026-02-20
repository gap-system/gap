#@local G, H, g, h, tmp, stabChain, iter, s1, s2, a, S, prod, i, v, s, pow
#@local m, mm
gap> START_TEST( "memory.tst" );

#
gap> G := GroupWithMemory([ (1,2,3,4,5), (1,2) ]);;
gap> H := GroupWithMemory(GL(IsMatrixGroup, 3, 3));;
gap> g := H.1 ^ 2;; h := H.2 ^ 2;;
gap> StripMemory(g);
[ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), Z(3)^0 ] ]
gap> StripMemory([g, h]);
[ [ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3) ], 
      [ 0*Z(3), 0*Z(3), Z(3)^0 ] ], 
  [ [ Z(3)^0, Z(3), Z(3) ], [ Z(3)^0, 0*Z(3), Z(3) ], 
      [ Z(3)^0, 0*Z(3), 0*Z(3) ] ] ]
gap> ForgetMemory(1);
Error, This object does not allow forgetting memory.
gap> ForgetMemory(H.1 ^ 2);
Error, You probably mean "StripMemory" instead of "ForgetMemory".
gap> ForgetMemory([g, h]);
gap> tmp := GroupWithMemory(GroupByGenerators([ (1,2,3,4,5), (1,2) ]));;
gap> stabChain := StabChainMutable(tmp);;
gap> stabChain.labels[1];
<() with mem>
gap> StripStabChain(stabChain);;
gap> stabChain.labels[1];
()
gap> tmp := GroupWithMemory(GroupByGenerators([ (1,2,3,4,5), (1,2) ]));;
gap> iter := Iterator(tmp);;
gap> NextIterator(iter);
<() with mem>
gap> iter := IteratorStabChain(StabChain(GroupWithMemory([ () ])));;
gap> iter := ShallowCopy( iter );;
gap> NextIterator(iter);
<() with mem>
gap> s1 := SLPOfElm(g);;
gap> g = ResultOfStraightLineProgram(s1, GeneratorsOfGroup(H));
true
gap> s2 := SLPOfElms([g, h]);;
gap> [g, h] = ResultOfStraightLineProgram(s2, GeneratorsOfGroup(H));
true
gap> SLPOfElms([G.1, H.1]);
Error, SLPOfElms: the slp components of all elements must be identical
gap> g * h;
<[ [ Z(3)^0, Z(3), Z(3) ], [ Z(3)^0, 0*Z(3), Z(3) ], 
  [ Z(3)^0, 0*Z(3), 0*Z(3) ] ] with mem>
gap> g * G.1;
Error, \* for objects with memory: a!.slp and b!.slp must be identical

# permutation methods
gap> G:= SymmetricGroup( 5 );;
gap> H:= GroupWithMemory( G );;
gap> ( H.1 = H.2 ) = ( G.1 = G.2 );
true
gap> ( H.1 = G.2 ) = ( G.1 = G.2 );
true
gap> ( G.1 = H.2 ) = ( G.1 = G.2 );
true
gap> G.1 = H.1;
true
gap> ( H.1 < H.2 ) = ( G.1 < G.2 );
true
gap> ( H.1 < G.2 ) = ( G.1 < G.2 );
true
gap> ( G.1 < H.2 ) = ( G.1 < G.2 );
true
gap> prod:= H.1 * H.2;;
gap> IsObjWithMemory( prod ) and prod = G.1 * G.2;
true
gap> IsObjWithMemory( One( H.1 ) ) and One( H.1 ) = One( G.1 );
true
gap> IsObjWithMemory( Inverse( H.1 ) ) and Inverse( H.1 ) = Inverse( G.1 );
true
gap> for i in [ -1 .. 3 ] do
>      pow:= H.1^i;
>      if not IsObjWithMemory( pow ) then
>        Error( "wrong type" );
>      elif pow <> G.1^i then
>        Error( "wrong result" );
>      fi;
>    od;
gap> Order( G.1 ) = Order( H.1 );
true
gap> LargestMovedPoint( G.1 ) = LargestMovedPoint( H.1 );
true
gap> ForAll( [ 1 .. 5 ], i -> i ^ G.1 = i ^ H.1 );
true
gap> ForAll( [ 1 .. 5 ], i -> i / G.1 = i / H.1 );
true
gap> ForAll( [ 1 .. 5 ], i -> Cycle( G.1, i ) = Cycle( H.1, i ) );
true
gap> ForAll( [ 1 .. 5 ], i -> CycleLength( G.1, i ) = CycleLength( H.1, i ) );
true
gap> CycleStructurePerm( G.1 ) = CycleStructurePerm( H.1 );
true
gap> RestrictedPerm( G.2, [ 1 .. 3 ] ) = RestrictedPerm( H.2, [ 1 .. 3 ] );
true
gap> IsObjWithMemory( RestrictedPerm( H.2, [ 1 .. 3 ] ) );
true
gap> SignPerm( G.2 ) = SignPerm( H.2 );
true

# legacy matrix methods
gap> G:= GL(2, 3);;
gap> H:= GroupWithMemory( G );;
gap> Order( G.1 ) = Order( H.1 );
true
gap> IsOne( G.1 ) = IsOne( H.1 );
true
gap> IsOne( One( G ) ) = IsOne( One( H ) );
true
gap> IsObjWithMemory( One( H.1 ) ) and One( H.1 ) = One( G.1 );
true
gap> IsObjWithMemory( One( H ) );
true
gap> IsList( G.1 );
true
gap> Length( G.1 ) = Length( H.1 );
true
gap> G.1[1] = H.1[1];
true
gap> v:= [ Z(3), Z(3)^2 ];;
gap> v * G.1 = v * H.1;
true
gap> Z(3) * G.1 = Z(3) * H.1;
true
gap> G.1 * Z(3) = H.1 * Z(3);
true
gap> ProjectiveOrder( G.1 ) = ProjectiveOrder( H.1 );
true
gap> m:= [ [ Z(2) ] ];
[ [ Z(2)^0 ] ]
gap> IsPlistRep( m );
true
gap> s:= GeneratorsWithMemory( [ m ] );
[ <[ [ Z(2)^0 ] ] with mem> ]
gap> mm:= ImmutableMatrix( GF(4), s[1] );
<[ [ Z(2)^0 ] ] with mem>
gap> IsMutable( mm );
false
gap> Is8BitMatrixRep( StripMemory( mm ) );
true

# free group element methods
gap> G:= FreeGroup( 2 );;
gap> H:= GroupWithMemory( G );;
gap> Length( G.1 ) = Length( H.1 );
true

# ImmutableMatrix on a matrix with memory
# see https://github.com/gap-system/gap/issues/5872
gap> G:=GroupWithMemory(SL(4,16));;
gap> g:=ImmutableMatrix(GF(4), G.1^5);
<[ [ Z(2^2), 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), Z(2^2)^2, 0*Z(2), 0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2) ], [ 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0 ] 
 ] with mem>

# 'SCRSift' works also for non-internal permutations,
# by delegating to 'SiftedPermutation'.
gap> G:= GroupWithMemory( MathieuGroup( 11 ) );;
gap> a:= G.1;;
gap> IsPerm( a );
true
gap> IsInternalRep( a );
false
gap> S:= StabChain( G );;
gap> SCRSift( S, a );
<() with mem>

#
gap> STOP_TEST( "memory.tst" );
