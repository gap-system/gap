#@local t, irr, ind, red, l, r, i, M, oe, C, Xli, irrli, j
######################################################################
gap> START_TEST( "example_3.2.25.tst" );

######################################################################
gap> t := CharacterTable("Suz");;
gap> irr := Irr(t){[1]};;           ind := InducedCyclic( t, "all");;
gap> red := Reduced( t, irr, ind );;  l := LLL( t, red.remainders );;
gap> r := l.remainders;;  List( r , Norm );
[ 2, 2, 2, 11, 10, 15, 14, 12, 12, 11, 11, 8, 6, 14, 14, 10, 14, 18, 13, 14, 
  19, 10, 27, 29, 25, 21, 21, 24, 18, 22, 15, 19, 21, 19, 27, 25, 24, 23, 30, 
  23, 23, 20 ]

######################################################################
gap>  for  i in [2,3,4] do
>  Append(r , Symmetrizations(t,r,i) );
>  r := Reduced(t,irr,r).remainders;
>  r := LLL(t,r).remainders;
>  od;   List(r , Norm);
[ 2, 2, 3, 2, 4, 3, 3, 5, 5, 4, 8, 6, 7, 6, 14, 12, 12, 11, 11, 7, 10, 5, 10, 
  11, 10, 12, 13, 8, 5, 12, 13, 9, 6, 15, 11, 12, 16, 9, 12, 14, 12, 13 ]
gap>  M := MatScalarProducts( t, r, r );;
gap> oe := OrthogonalEmbeddings( M, 42 );;
gap> Length( oe.solutions ); C := oe.vectors;;
12

######################################################################
gap> Xli := List( oe.solutions , x -> C{x} );;
gap> irrli := List( Xli , x ->  ( TransposedMat( x ) )^-1  * r  );;
gap>  for i in [1..Length( irrli )] do
>       for j in [1..Length( irrli[i] )] do
>        if irrli[i][j][1] < 0 then irrli[i][j] := - irrli[i][j]; fi;
>       od;
>     od;

######################################################################
gap> irrli := Filtered(irrli, x -> not  0 in List( x, x_i -> x_i[1] ) );;
gap> Length(irrli);
8
gap> for i in [1..8] do
> red:= Reduced( t, irrli[i], Tensored(irrli[i], irrli[i] ) );
> if red.remainders = [] then Print(i,","); fi;
> od;  Print( "\n" );
5,6,7,8,
gap> irrli := irrli{[5,6,7,8]};;

######################################################################
gap>   for i in [1..4] do
> red:= Reduced( t, irrli[i], Symmetrizations (t, irrli[i], 3) );
> if red.remainders = [] then Print(i,","); fi;
> od;  Print( "\n" );
1,
gap> Append( irr, irrli[3] );

######################################################################
gap> STOP_TEST( "example_3.2.25.tst" );
