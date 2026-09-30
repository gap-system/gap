gap> START_TEST( "2026-09-28-SemiSimpleType.tst" );

# `SemiSimpleType' looped forever if the splitting field modulo a prime
# not dividing the discriminant was too big.
# This is sl2 over Q[x]/(x^7+x+1), in which 5 is inert; the basis vector
# 3*k+i is t^k times e, h, f for i = 1, 2, 3.
gap> x:= Indeterminate( Rationals );;
gap> T:= EmptySCTable( 21, 0, "antisymmetric" );;
gap> for k in [ 0 .. 6 ] do
>      for l in [ 0 .. 6 ] do
>        c:= CoefficientsOfUnivariatePolynomial(
>                EuclideanRemainder( x^(k+l), x^7+x+1 ) );
>        ef:= [ ];  he:= [ ];  hf:= [ ];
>        for i in [ 1 .. Length( c ) ] do
>          if c[i] <> 0 then
>            Append( ef, [ c[i], 3*i-1 ] );
>            Append( he, [ 2*c[i], 3*i-2 ] );
>            Append( hf, [ -2*c[i], 3*i ] );
>          fi;
>        od;
>        SetEntrySCTable( T, 3*k+1, 3*l+3, ef );
>        SetEntrySCTable( T, 3*k+2, 3*l+1, he );
>        SetEntrySCTable( T, 3*k+2, 3*l+3, hf );
>      od;
>    od;
gap> L:= LieAlgebraByStructureConstants( Rationals, T );;
gap> SemiSimpleType( L );
"A1 A1 A1 A1 A1 A1 A1"

#
gap> STOP_TEST( "2026-09-28-SemiSimpleType.tst" );
