#@local x, D
gap> START_TEST( "arith.tst" );

# 'OneSameMutability' for mult. elements
gap> for x in [ Z(2), [ [ 1 ] ], Immutable( [ [ 1 ] ] ) ] do
>      if IsMutable( OneSameMutability( x ) ) <> IsMutable( x ) then
>        Error( "result must have same mutability value" );
>      fi;
>    od;

# 'OneSameMutability' for domains with one (result shall be immutable)
gap> for D in [ SymmetricGroup(4), GL(2, 3), GF(2) ] do
>      if IsMutable( OneSameMutability( D ) ) then
>        Error( "result must be immutable" );
>      fi;
>    od;

# 'ZeroSameMutability' for add. elements
gap> for x in [ Z(2), [ [ 1 ] ], Immutable( [ [ 1 ] ] ) ] do
>      if IsMutable( ZeroSameMutability( x ) ) <> IsMutable( x ) then
>        Error( "result must have same mutability value" );
>      fi;
>    od;

# 'ZeroSameMutability' for domains with zero (result shall be immutable)
gap> for D in [ GF(2), GF(2)^2, GF(2)^[2, 2] ] do
>      if IsMutable( ZeroSameMutability( D ) ) then
>        Error( "result must be immutable" );
>      fi;
>    od;

#
gap> STOP_TEST( "arith.tst" );
