# ASS_MAT8BIT converting a one-row matrix to GF2 representation stored
# the new row without informing the garbage collector
gap> ref:= List( [ 1 .. 64 ], i -> Z(2)^(i mod 2) );;
gap> ConvertToVectorRep( ref, 2 );;
gap> ok:= true;;
gap> for n in [ 1 .. 20 ] do
>      m:= [ List( [ 1 .. 64 ], i -> Z(4) ) ];
>      ConvertToMatrixRep( m, 4 );
>      GASMAN( "collect" );
>      v:= ShallowCopy( ref );
>      ConvertToVectorRep( v, 2 );
>      ASS_MAT8BIT( m, 1, v );
>      v:= 0;
>      GASMAN( "partial" );
>      for i in [ 1 .. 2000 ] do x:= List( [ 1 .. 20 ], j -> [ j ] ); od;
>      GASMAN( "partial" );
>      ok:= ok and IsGF2MatrixRep( m ) and m[1] = ref;
>    od;
gap> ok;
true
