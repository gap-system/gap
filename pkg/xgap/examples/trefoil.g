# This is the fourth example from the XGAP manual:
# The Trefoil knot group: A finitely presented group.
# $Id:
f := FreeGroup( "a", "b" );
k3 := f / [ f.1*f.2*f.1 / (f.2*f.1*f.2) ];
s := GraphicSubgroupLattice(k3);
