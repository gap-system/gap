#@local hat, ct, b1, hchi, res, ct1, hxi, resn, T, J, eps, mu, domain
#@local ctpord, ct1pord, nz
######################################################################
gap> START_TEST( "example_4.14.30.tst" );

######################################################################
gap> hat := function(t,i)
> local n,y,j ;   n:=Length(Irr(t));   y := List([1..n], x -> 0);
> for j in [1..n] do
> if not IsInt(OrdersClassRepresentatives(t)[j]/2) then y[j]:=Irr(t)[i][j];fi;
> od;
> return(y);end;;
gap> ct := CharacterTable("J1");;
gap> b1 := Positions( PrimeBlocks(ct,2).block, 1 );
[ 1, 6, 7, 8, 12, 13, 14, 15 ]
gap> hchi := List( b1, i -> hat(ct,i) );;
gap> res := 8*MatScalarProducts( ct, hchi, hchi );;
gap> Display(res);
[ [   5,   1,   1,   1,   1,   1,   1,  -3 ],
  [   1,   5,   1,   1,  -3,   1,   1,   1 ],
  [   1,   1,   5,   1,   1,  -3,   1,   1 ],
  [   1,   1,   1,   5,   1,   1,  -3,   1 ],
  [   1,  -3,   1,   1,   5,   1,   1,   1 ],
  [   1,   1,  -3,   1,   1,   5,   1,   1 ],
  [   1,   1,   1,  -3,   1,   1,   5,   1 ],
  [  -3,   1,   1,   1,   1,   1,   1,   5 ] ]
gap> ct1 := CharacterTable("2^3.7.3");;
gap> hxi := List( [1..8], i -> hat(ct1,i) );;
gap> resn:= 8*MatScalarProducts( ct1, hxi, hxi );;
gap> Display(resn);
[ [   5,   1,   1,  -1,  -1,   3,  -1,  -1 ],
  [   1,   5,   1,  -1,  -1,  -1,   3,  -1 ],
  [   1,   1,   5,  -1,  -1,  -1,  -1,   3 ],
  [  -1,  -1,  -1,   5,  -3,   1,   1,   1 ],
  [  -1,  -1,  -1,  -3,   5,   1,   1,   1 ],
  [   3,  -1,  -1,   1,   1,   5,   1,   1 ],
  [  -1,   3,  -1,   1,   1,   1,   5,   1 ],
  [  -1,  -1,   3,   1,   1,   1,   1,   5 ] ]
gap> T:=
> [ [ 1, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 0, 0, 0 ],
>   [ 0, 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, -1, 0, 0, 0, 0 ],
>   [ 0, 0, 0, 0, 0, 0, -1, 0 ], [ 0, 0, 0, 0, 0, 0, 0, -1 ],
>   [ 0, 0, 0, 0, -1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, -1, 0, 0 ] ];;
gap> res = T*resn*TransposedMat(T);
true

######################################################################
gap> J := [1,6,7,8,14,15,12,13];;   eps := [1,1,1,-1,-1,-1,-1,-1];;
gap> mu := function(i,j)    return( Sum( List( [1..8], k ->
>            eps[k] * Irr(ct)[ J[k] ][i] * Irr(ct1)[k][j])) ); end;;
gap> domain := Cartesian( [1..Length(Irr(ct))], [1..Length(Irr(ct1))] );;

######################################################################
gap> ctpord := List( SizesCentralizers(ct),
>                    x -> Product( Filtered(Factors(x), p -> p=2) ) );;
gap> ct1pord := List( SizesCentralizers(ct1),
>                    x -> Product( Filtered(Factors(x), p -> p=2) ) );;
gap> ForAll( domain ,
>         x ->  IsIntegralCyclotomic(mu(x[1],x[2])/ctpord[x[1]]) and
>               IsIntegralCyclotomic(mu(x[1],x[2])/ct1pord[x[2]]) );
true
gap> nz := Filtered( domain, x -> mu(x[1],x[2]) <> 0);;
gap> ForAll( nz, x -> ( IsInt(OrdersClassRepresentatives(ct)[x[1]]/2)
>                 and  IsInt(OrdersClassRepresentatives(ct1)[x[2]]/2) )
>         or      ( not IsInt(OrdersClassRepresentatives(ct)[x[1]]/2)
>              and not IsInt(OrdersClassRepresentatives(ct1)[x[2]]/2) ) );
true

######################################################################
gap> STOP_TEST( "example_4.14.30.tst" );
