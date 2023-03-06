#@local G, module, bsm, sm, mat, i, j, cf, W, wd, w, Gmat, orbit
#@local Gper, U, nsU
######################################################################
gap> START_TEST( "example_1.3.12.tst" );

######################################################################
gap> G := PrimitiveGroup( 100, 3 );;
gap> module := PermutationGModule( G , GF(2) );;
gap> bsm := MTX.BasesSubmodules( module );;

######################################################################
gap>  sm := List( bsm , bas -> Submodule( GF(2)^100 , bas ) );;
gap>  mat := [];;
gap> for i in [1..Length(bsm)] do
>     mat[i] :=  [];
>        for j in [1..Length(bsm)] do
>            if IsSubspace( sm[i], sm[j]) then mat[i][j] := 1 ;
>             else  mat[i][j] := 0;
>            fi;
>        od;
>    od;

######################################################################
gap> cf := MTX.CollectedFactors( module );;
gap> List( cf, x->x[1].dimension );
[ 1, 20, 56 ]
gap> List( cf, x->x[2] ); # the multiplicities:
[ 4, 2, 1 ]
gap> List( cf, x -> MTX.IsAbsolutelyIrreducible(x[1]) );
[ true, true, true ]

######################################################################
gap> W := sm[3];;
gap> wd := DistancesDistributionMatFFEVecFFE( bsm[3], GF(2), Zero(W) );
[ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 3850, 0, 0, 0, 4125, 0, 0, 0, 92400, 0, 0, 0, 347600, 
  0, 0, 0, 600600, 0, 0, 0, 600600, 0, 0, 0, 347600, 0, 0, 0, 92400, 0, 0, 0, 
  4125, 0, 0, 0, 3850, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ]
gap> Position( wd, 3850 );
33

######################################################################
gap> repeat   w := Random( W );  until WeightVecFFE( w ) = 32 ;

######################################################################
gap> Gmat := Group ( MTX.Generators(module) );;
gap> orbit := Orbit( Gmat , w , OnRight );;
gap> Length( orbit );
3850

######################################################################
gap> Gper := Image( ActionHomomorphism( Gmat, orbit) );;
gap> IsPrimitive( Gper );
true
gap> U := Stabilizer( Gper, 1 );
<permutation group of size 11520 with 4 generators>
gap>  U := Image ( SmallerDegreePermutationRepresentation( U ) ) ;;
gap> DegreeOperation( U );
32
gap> nsU := NormalSubgroups( U );
[ Group(()), <permutation group of size 16 with 4 generators>, 
  <permutation group of size 5760 with 7 generators>, 
  <permutation group of size 11520 with 4 generators> ]
gap> StructureDescription( nsU[2] );
"C2 x C2 x C2 x C2"
gap> StructureDescription( FactorGroup( U , nsU[2] ) );
"S6"

######################################################################
gap> STOP_TEST( "example_1.3.12.tst" );
