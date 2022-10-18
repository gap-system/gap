# avoid crashes when converting certain compressed vectors
# see <https://github.com/gap-system/gap/issues/5123>

#
gap> v:= [ 0 * Z(2) ];;
gap> ConvertToVectorRep( v, 4 );
4
gap> ConvertToVectorRep( v, 8 );
8

#
gap> v:= [ 0 * Z(2) ];;
gap> ConvertToVectorRep( v, 4 );
4
gap> CopyToVectorRep( v, 8 );
[ 0*Z(2) ]
