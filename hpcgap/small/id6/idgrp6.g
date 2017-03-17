#############################################################################
##
#W  idgrp6.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the identification routines for groups of order
##  1152 and 1920.
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("id6","1.0");

#############################################################################
##
#F ID_AVAILABLE_FUNCS[ 6 ]
##
ID_AVAILABLE_FUNCS[ 6 ] := function( size )

    if size in [ 1152, 1920 ] then
        return rec( func := 15, lib := 6 );
    fi;

    return fail;
end;

#############################################################################
##
#F ID_GROUP_FUNCS[ 15 ]( G, inforec )
##
## size 1152 or 1920
##
ID_GROUP_FUNCS[ 15 ] := function( G, inforec )
    local sid;

    if IsNilpotentGroup( G ) then
        sid := IdGroup( SylowSubgroup( G, 2 ) )[ 2 ];
        if Size( G ) = 1152 and
                            IsElementaryAbelian( SylowSubgroup( G, 3 ) ) then
            return sid + 2328;
        else
            return sid;
        fi;
    fi;

    if not IsBound( ID_GROUP_TREE.next[ Size( G ) ] ) then
        ID_GROUP_TREE.next[ Size(G) ] := rec( fp := [ 1, 2 ],
          next := [ rec( fp := [ 1 .. 500 ], next := [] ) ] );
    fi;

    if IsSolvable( G ) and IsNormal( G, HallSubgroup( G, [ 3, 5 ] ) ) then
        sid := IdGroup( SylowSubgroup( G, 2 ) )[ 2 ];
        return ID_GROUP_FUNCS[ 8 ]( G, inforec, [ Size( G ), 1, 
               ( sid - 1 ) mod 500 + 1, sid ] );
    fi;

    return ID_GROUP_FUNCS[ 8 ]( G, inforec, [ Size( G ), 2 ] );
end;
