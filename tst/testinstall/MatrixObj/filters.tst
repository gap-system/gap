#@local m, v, G
gap> START_TEST( "filters.tst" );

#
# matrices in 'IsMatrix' get the entry filters from their family
#
gap> m:= [ [ Z(4), 0*Z(4) ], [ 0*Z(4), Z(4)^2 ] ];;
gap> IsFFEMatrix( m );  IsFFEMatrixObj( m );
true
false
gap> IsFiniteFieldMatrix( m );  IsCyclotomicMatrix( m );
true
false
gap> m:= [ [ 1, 2 ], [ 3, 4 ] ];;
gap> IsCyclotomicMatrix( m );  IsFFEMatrix( m );
true
false
gap> IsFiniteFieldMatrix( m );
false

#
# matrix objects get them from their base domain
#
gap> for m in [ Matrix( IsPlistMatrixRep, GF(4), [ [ Z(4) ] ] ),
>               Matrix( IsGenericMatrixRep, GF(4), [ [ Z(4) ] ] ),
>               Matrix( GF(4), [ [ Z(4) ] ] ),
>               Matrix( GF(2), [ [ Z(2) ] ] ) ] do
>   Assert( 0, IsFFEMatrixObj( m ) );
>   Assert( 0, IsFiniteFieldMatrixObj( m ) );
>   Assert( 0, not IsCyclotomicMatrixObj( m ) );
> od;
gap> for m in [ Matrix( IsPlistMatrixRep, Integers, [ [ 1 ] ] ),
>               Matrix( IsPlistMatrixRep, Rationals, [ [ 1/2 ] ] ),
>               Matrix( IsGenericMatrixRep, Integers, [ [ 1 ] ] ) ] do
>   Assert( 0, IsCyclotomicMatrixObj( m ) );
>   Assert( 0, not IsFFEMatrixObj( m ) );
>   Assert( 0, not IsFiniteFieldMatrixObj( m ) );
> od;

#
# ditto for vectors
#
gap> v:= [ Z(4), 0*Z(4) ];;
gap> IsFFEVector( v );  IsFFEVectorObj( v );
true
false
gap> for v in [ NewVector( IsPlistVectorRep, GF(4), [ Z(4) ] ),
>               Vector( GF(4), [ Z(4) ] ),
>               Vector( GF(2), [ Z(2) ] ) ] do
>   Assert( 0, IsFFEVectorObj( v ) );
>   Assert( 0, not IsCyclotomicVectorObj( v ) );
> od;
gap> for v in [ NewVector( IsPlistVectorRep, Integers, [ 1 ] ),
>               NewVector( IsPlistVectorRep, Rationals, [ 1/2 ] ) ] do
>   Assert( 0, IsCyclotomicVectorObj( v ) );
>   Assert( 0, not IsFFEVectorObj( v ) );
> od;

#
# 'IsFFEMatrixOrMatrixObj' implies 'IsFiniteFieldMatrixOrMatrixObj'
#
gap> IS_IMPLIED_BY( IsFiniteFieldMatrixOrMatrixObj, IsFFEMatrixOrMatrixObj );
true
gap> IS_IMPLIED_BY( IsFFEMatrixOrMatrixObj, IsFiniteFieldMatrixOrMatrixObj );
false

#
# groups of matrix objects: the filters are deduced from the generators,
# not only from the family, so they also work for matrix objects that are
# not collections of their entries
#
gap> G:= Group( Matrix( IsPlistMatrixRep, GF(4), [ [ Z(4), 0*Z(4) ],
>                                                  [ 0*Z(4), Z(4)^2 ] ] ) );;
gap> IsMatrixGroup( G );  IsFiniteFieldMatrixGroup( G );
true
true
gap> IsFFEMatrixGroup( G );
true
gap> G:= Group( Matrix( IsPlistMatrixRep, Integers, [ [ 1, 1 ], [ 0, 1 ] ] ) );;
gap> IsMatrixGroup( G );  IsFiniteFieldMatrixGroup( G );
true
false

#
# and not for groups that are not matrix groups
#
gap> IsMatrixGroup( SymmetricGroup( 3 ) );
false
gap> IsMatrixGroup( CyclicGroup( 4 ) );
false

#
gap> STOP_TEST( "filters.tst" );
