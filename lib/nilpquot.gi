#############################################################################
##  
#W  nilpquot.gi                 GAP Library                     Werner Nickel
##
#H  $Id$
##
Revision.nilpquot_gi :=
    "$Id$";


LeftNormedComm := function( list )
    local   n;

    n := Length( list );

    if n = 1 then return list[1]; fi;

    return Comm( LeftNormedComm( list{[1..n-1]} ), list[n] );
end;
