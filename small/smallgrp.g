#############################################################################
##
#W  smallgrp.g               GAP group library             Hans Ulrich Besche
#W                                                             & Bettina Eick
##
##  This file contains the extraction function for the library of groups of
##  order up to 1000 without the order 512 and 768.
##
#Y  Note:
#Y  All nilpotent groups have been been derived from the 2- and 3-group 
#Y  library of E. A. O'Brien (if possible) or have been computed using
#Y  p-group generation otherwise.
#Y  
#Y  All soluble, non-nilpotent groups have been computed by the Frattini
#Y  group extension method developed by Hans Ulrich Besche and Bettina Eick.
#Y
#Y  All non-soluble groups have been computed by extending perfect groups
#Y  by automorphisms.
##
Revision.smallgrp_g :=
    "@(#)$Id$";

if not IsBound( Table1000 ) then Table1000 := []; fi;
if not IsBound( PermGroupTable ) then 
    ReadSmall( "permtab.sm" );
fi;
Codes1000 := [];

#############################################################################
##
#F PermGroupCode( c, size ) . . . . . . . . . . . .look up permgroup in table
##
InstallGlobalFunction( PermGroupCode, function( c, size )
    local tab, g;
    tab  := PermGroupTable[ size ][ -c ];
    g    := Group( tab.gens, () );
    return g;
end );

#############################################################################
##
#F GroupCode( c, size ) . . . . . . . . . . . . . . . . . . . . . . . .decode
##
InstallGlobalFunction( GroupCode, function( c, size )
    if c >= 0 then
        return PcGroupCode( c, size );
    fi;
    return PermGroupCode( c, size );
end );

#############################################################################
##
#F LoadSmallGroups( list ) . . . . . . . . . . . . . . . . . . . .load groups
##
InstallGlobalFunction( LoadSmallGroups, function( list )
    local new, get, loaded, i, tab, j, str;

    # filter the one we know already
    new := Filtered( list, x -> not IsBound( Table1000[x] ) );

    # check the range
    if not ForAll( new, x -> 1 <= x and x <= 1000 and x <> 512 and x <> 768 )
    then
        Error("some of the sizes are not in the range ");
    fi;
    
    # load the tables
    tab    := [];
    tab[1] := [1..255];
    tab[2] := [256];
    tab[3] := [257..383];
    tab[4] := [384];
    tab[5] := [385..511];
    tab[6] := [513..639];
    tab[7] := [640];
    tab[8] := [641..767];
    tab[9] := [769..895];
    tab[10]:= [896];
    tab[11]:= [897..1000];

    for j in [1..11] do

        # set up lists
        loaded := Filtered( tab[j], x -> IsBound( Table1000[x] ) );
        get    := Intersection( new, tab[j] );
        new    := Difference( new, tab[j] );

        # check if we need to read file
        if Length( get ) > 0 and not
           ForAll( get, x -> IsBound( Codes1000[x] ) ) then

            # if something else is bound, reset first
            if Length( Codes1000 ) > 0 then
                Codes1000 := [];
            fi;

            # set up string
            if j < 10 then
                str := Concatenation( "sgtab0", String( j ), ".sm" );
            else
                str := Concatenation( "sgtab", String( j ), ".sm" );
            fi;

            # read the file we want
            ReadSmall( str );

            # to save space we need to reset the loaded stuff
            for i in loaded do
                Table1000[i] := Codes1000[i];
            od;
        fi;

        # load the wanted orders
        for i in get do
            Table1000[i] := Codes1000[i];
        od;
    od;
end );

#############################################################################
##
#F UnloadSmallGroups( list ) . . . . . . . . . . . . . . . . . .unbind groups
##
InstallGlobalFunction( UnloadSmallGroups, function( list )
    local i;
    for i in list do
        Unbind( Table1000[i] );
    od;
end );

#############################################################################
##
#F SmallGroup( size, nr ) . . . . . . . . . . .construct group from catalogue
##
InstallGlobalFunction( SmallGroup, function( size, nr )
    local g;

    if size in [ 512, 768 ] then
        Error( "SmallGroup: groups of sizes 512 and 768 are not available" );
    elif size > 1000 then
        Error( "SmallGroup: size restricted to 1000");
    elif size < 1 then
        Error( "SmallGroup: size must be at least 1");
    fi;
    if not IsBound( Table1000[size] ) then
        LoadSmallGroups( [size] );
    fi;
    if nr > Length( Table1000[ size ] ) then
        Error( "SmallGroup: there are just ", Length( Table1000[ size ] ), 
               " groups of size ", size );
    fi;

    # get the group
    g := GroupCode( Table1000[ size ][ nr ], size );
    return g;
end );

#############################################################################
##
#F AllSmallGroups( size ) . . . . . . . . . . construct groups from catalogue
##
InstallGlobalFunction( AllSmallGroups, function( size )

    if size in [ 512, 768 ] then
        Error( "AllSmallGroups: sizes 512 and 768 are not available" );
    elif size > 1000 then
        Error( "AllSmallGroups: size restricted to 1000");
    elif size < 1 then
        Error( "AllSmallGroups: size must be at least 1");
    fi;
    if not IsBound( Table1000[size] ) then
        LoadSmallGroups( [size] );
    fi;
    return List( [1..Length(Table1000[size])], x -> SmallGroup(size,x) );
end );

#############################################################################
##
#F NumberSmallGroups( size ) . . . . . . . . . . . . . . . . number of groups
##
InstallGlobalFunction( NumberSmallGroups, function( size )

    if size in [ 512, 768 ] then
        Error( "NumberSmallGroups: sizes 512 and 768 are not available" );
    elif size > 1000 then
        Error( "NumberSmallGroups: size restricted to 1000");
    elif size < 1 then
        Error( "NumberSmallGroups: size must be at least 1");
    fi;
    if not IsBound( Table1000[size] ) then
        LoadSmallGroups( [size] );
    fi;
    return Length( List( Table1000[size] ) );
end );

