#############################################################################
##
#W  gprd.gi                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.5  1997/03/10 15:43:14  beick
#H  removed new catagory for products of groups, added products of pc groups
#H
#H  Revision 4.4  1997/02/13 10:38:20  ahulpke
#H  Added 'Embedding' and 'Projection' for semidirect products
#H
#H  Revision 4.3  1996/12/19 09:59:01  htheisse
#H  added revision lines
#H
#H  Revision 4.2  1996/10/30 15:46:33  htheisse
#H  fixed errors with group products
#H
#H  Revision 4.1  1996/10/30 15:17:01  htheisse
#H  added products of permutation groups
#H
##
Revision.gprd_gi :=
    "@(#)$Id$";

DirectProduct := function( arg )
    local   D,  i;
    
    D := arg[ 1 ];
    for i  in [ 2 .. Length( arg ) ]  do
        D := DirectProduct2( D, arg[ i ] );
    od;
    return D;
end;

#############################################################################
##

#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:
#############################################################################
