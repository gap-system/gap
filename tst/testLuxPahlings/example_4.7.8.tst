#@local testmodpi, t, ct, p, omegaBs, pb, inducedblocks, i, h, cth
#@local blh, k, y, z
######################################################################
gap> START_TEST( "example_4.7.8.tst" );

######################################################################
gap> testmodpi := function( t, y, p )
> # t character table, y classfunction, p a prime; the function tests
> # whether  for all i   IsIntegralCyclotomic( y[i]^m / p ) where
> # m = Phi( OrdersClassRepresentatives(t)[i] )
> local i, res ;
> res:= true;
> for i in [1..Length(y)] do
>   if IsInt( y[i] ) and not IsInt( y[i]/p ) then
>        res := false;
>   elif not IsInt( y[i] ) and  not
>     IsIntegralCyclotomic( y[i]^Phi( OrdersClassRepresentatives(t)[i] )/ p )
>     then res := false;
>   fi;
> od;
> return( res );
> end;;

######################################################################
gap>  t := TableOfMarks( "M11" );;
gap>  ct := CharacterTable( UnderlyingGroup(t) );; p := 2;;
gap>  omegaBs := List( Irr(ct){[1,6,7]} , CentralCharacter );;

######################################################################
gap>  pb := PrimeBlocks( ct, p );;
gap>  omegaBs := List( Irr(ct){List( [1..Length(pb.defect)],
>                    j -> Position(pb.block,j) )} ,CentralCharacter);;

######################################################################
gap>  inducedblocks := [];;
gap>  for i in [1..Length(OrdersTom(t))-1] do
>       h := RepresentativeTom( t, i );;
>       cth := CharacterTable(h); blh := PrimeBlocks( cth, p );
>       for k in [1..Length(blh.defect)] do
>          y := Irr(cth)[ Position( blh.block, k ) ];
>          y := InducedClassFunction( y, ct );
>          for z in omegaBs do
>             if testmodpi( ct, CentralCharacter(y) - z , p ) then
>                Add( inducedblocks , [ i, k, Position( omegaBs , z) ] );
>             fi;
>          od;
>       od;
>     od;

######################################################################
gap> STOP_TEST( "example_4.7.8.tst" );
