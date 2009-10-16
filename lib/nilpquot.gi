#############################################################################
##  
#W  nilpquot.gi                 GAP Library                     Werner Nickel
##
#H  $Id: nilpquot.gi,v 4.1 1999/09/13 16:51:06 werner Exp $
##
Revision.nilpquot_gi :=
    "$Id: nilpquot.gi,v 4.1 1999/09/13 16:51:06 werner Exp $";


LeftNormedComm := function( list )
    local   n;

    n := Length( list );

    if n = 1 then return list[1]; fi;

    return Comm( LeftNormedComm( list{[1..n-1]} ), list[n] );
end;
