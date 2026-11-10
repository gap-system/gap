# Embedding and Projection of a pc group direct product must not assume that
# Pcgs(D) is the family pcgs, see
# <https://github.com/gap-system/gap/issues/6000>
gap> g1:= ExtraspecialGroup( 2^3, "+" );;
gap> g2:= CyclicGroup( 4 );;
gap> dp:= DirectProduct( g1, g2 );;
gap> SetPcgs( dp, SpecialPcgs( FamilyPcgs( dp ) ) );;
gap> AsList( Pcgs( dp ) );
[ f1, f2, f4, f3, f5 ]
gap> e1:= Embedding( dp, 1 );;  e2:= Embedding( dp, 2 );;
gap> MappingGeneratorsImages( e2 );
[ Pcgs([ f1, f2 ]), [ f4, f5 ] ]
gap> List( AllSubgroups( Image( e2 ) ), Size );
[ 1, 2, 4 ]
gap> p1:= Projection( dp, 1 );;  p2:= Projection( dp, 2 );;
gap> Kernel( p1 ) = Image( e2 );
true
gap> Kernel( p2 ) = Image( e1 );
true
gap> List( Pcgs( g2 ), x -> ImagesRepresentative( p2,
>        ImagesRepresentative( e2, x ) ) ) = AsList( Pcgs( g2 ) );
true
