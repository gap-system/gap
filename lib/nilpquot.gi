#############################################################################
##  
#W  nilpquot.gi                 GAP Library                     Werner Nickel
##
##


LeftNormedComm := function( list )
    local   n;

    n := Length( list );

    if n = 1 then return list[1]; fi;

    return Comm( LeftNormedComm( list{[1..n-1]} ), list[n] );
end;
