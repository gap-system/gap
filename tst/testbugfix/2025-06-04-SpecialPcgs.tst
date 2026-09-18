# Verify <https://github.com/gap-system/gap/issues/6000> is fixed
gap> g1:= ExtraspecialGroup( 2^3, "+" );;
gap> g2:= CyclicGroup( 4 );;
gap> dp:= DirectProduct( g1, g2 );;
gap> Centre( dp );;  # this line makes the difference
gap> img:= Image( Embedding( dp, 2 ) );;
gap> IsCyclic( img );
true
gap> List( GeneratorsOfGroup( img ), Order );
[ 4, 2 ]
gap> List( AllSubgroups( img ), Size );  # this gave wrong output
[ 1, 2, 4 ]
