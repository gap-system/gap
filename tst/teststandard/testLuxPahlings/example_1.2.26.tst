#@local G, orb, a, x, y, i, j, k
######################################################################
gap> START_TEST( "example_1.2.26.tst" );

######################################################################
gap> G := PrimitiveGroup( 100, 3 );;
gap> orb := Orbits( G , Tuples([1..100],2) , OnPairs);;
gap> List( orb , Length );
[ 100, 7700, 2200 ]

######################################################################
gap> List([1,2,3], i -> Length( Filtered( orb[i], p -> p[1] = 1) ) );
[ 1, 77, 22 ]

######################################################################
gap> a := [];; x := 1;;  y := 1;;
gap> for i in [1..Length(orb)] do
>     a[i] := [];      # a[i] will be the i-th intersection matrix
>     for j in [1..Length(orb)] do
>       a[i][j]:= [];      #  a[i][j] will be the j-th row of a[i]
>       for k in [1..Length(orb)] do
>         x:=orb[k][1][1];  y:=orb[k][1][2];    # [x,y] in orb[k]
>         a[i][j][k] :=  Size( Intersection (
>             Filtered([1..100] , z -> [x,z] in orb[i]),
>             Filtered([1..100] , z -> [y,z] in orb[j]) ) );
>       od;
>     od;
>    od;

######################################################################
gap> Display( Eigenspaces( Rationals, TransposedMat(a[2]) ));;
[ VectorSpace( Rationals, [ [ 1, 77, 22 ] ] ), 
  VectorSpace( Rationals, [ [ 1, 7, -8 ] ] ), 
  VectorSpace( Rationals, [ [ 1, -3, 2 ] ] ) ]
gap> Display( Eigenspaces( Rationals, TransposedMat(a[3]) ));;
[ VectorSpace( Rationals, [ [ 1, 77, 22 ] ] ), 
  VectorSpace( Rationals, [ [ 1, -3, 2 ] ] ), 
  VectorSpace( Rationals, [ [ 1, 7, -8 ] ] ) ]

######################################################################
gap> STOP_TEST( "example_1.1.26.tst" );
