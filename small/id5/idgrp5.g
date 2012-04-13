#############################################################################
##
#W  idgrp5.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the identification routines for groups of order
##  1001 to 2000 except 1024, 1152, 1536, 1920 and size a product of
##  more then 3 primes
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("id5","1.0");

#############################################################################
##
#F ID_AVAILABLE_FUNCS[ 5 ]
##
ID_AVAILABLE_FUNCS[ 5 ] := function( size )

    if size > 2000 or size in [ 512, 1024, 1152, 1536, 1920 ] then 
        return fail;
    fi;

    return rec( func := 8,
                lib := 5 );
end;
