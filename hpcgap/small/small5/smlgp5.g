#############################################################################
##
#W  smlgp5.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the reading and selection functions for the groups of
##  size 1001 to 2000 except 1024, 1152, 1536, 1920 and size a product of
##  more then 3 primes
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("small5","1.0");

#############################################################################
##
#F SMALL_AVAILABLE_FUNCS[ 5 ]
##
SMALL_AVAILABLE_FUNCS[ 5 ] := function( size )
    local pos, numbs;

    if size > 2000 or size in [ 512, 1024, 1152, 1536, 1920 ] then 
        return fail;
    fi;

    pos := PositionSet( [ 1296, 1344, 1440, 1600, 1728, 1944 ], size );
    if pos <> fail then
        # the groups are split into files with 2500 groups each
        numbs := [ 3609, 11720, 5958, 10281, 47937, 3973 ];
        return rec( func   := 10, 
                    lib    := 5,
                    number := numbs[ pos ] );
    fi;

    if size in [ 1008, 1040, 1056, 1080, 1120, 1134, 1176, 1200, 1248, 1360,
                 1368, 1404, 1488, 1512, 1560, 1568, 1584, 1620, 1632, 1680,
                 1760, 1764, 1776, 1800, 1824, 1872, 1968, 2000 ] then
        # every of these sizes is contained in a seperate file
        return rec( func := 8,
                    lib  := 5 );
    fi;

    # the other sizes are collected into 24 files
    return rec( func := 9,
                lib  := 5,
                file := PositionSorted( [ 1062, 1104, 1164, 1224, 1260, 1320,
                        1352, 1392, 1444, 1464, 1500, 1548, 1624, 1656, 1710,
                        1755, 1820, 1840, 1880, 1904, 1938, 1976, 1998 ],
                                          size ) );
end;
