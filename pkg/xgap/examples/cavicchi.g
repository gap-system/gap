# This is the third example from the XGAP manual:
# The Cavicchioli-group: A finitely presented group.
# $Id:
f := FreeGroup( "a", "b" );  a := f.1;;  b := f.2;;
c2 := f / [ a*b*a^-2*b*a/b, (b^-1*a^3*b^-1*a^-3)^2*a ];
SetName(c2,"c2");
s := GraphicSubgroupLattice(c2);

