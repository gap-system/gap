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
#F CoefficientsMultiadic
##
CoefficientsMultiadic := function( list, c )
    local v, i;
    v := List( list, x -> false );
    for i in Reversed([1..Length(list)]) do
        v[i] := RemInt( c, list[i] );
        c := QuoInt( c, list[i] );
    od;
    return v;
end; 

#############################################################################
##
#F PermGroupCode( c ) . . . . . . . . . . . . . . .look up permgroup in table
##
PermGroupCode := function( c )
    local size, nr, tab, g;

    size := -c mod 1000;
    nr   := QuoInt( -c, 1000 );
    tab  := PermGroupTable[ size ][ nr ];
    g    := Group( tab.gens, () );
    return g;
end;

#############################################################################
##
#F  AgGroupCode( code ) . . . . . . . .construct ag-group from numerical code
##
AgGroupCode := function( code )
    local n1, size, f, l, mi, n, t1, indices, gens, rels, g, i, 
          uc, ll, rr, t, j, z, z2, result, F, rws, x;

    # get the size
    size:= code mod 1000;
    if size = 0 then 
        size := 1000;
        code := code - 1000;
    fi;
    n := QuoInt( code, 1000 );

    # single out 1-group
    if size = 1 then
        return Range( IsomorphismPcGroup( Group(()) ) );
    fi;

    # create free group
    f := Factors(size);
    l := Length(f);
    F := FreeGroup( l );
    gens := GeneratorsOfGroup( F );
    rels := [];

    # get relative orders
    mi:= Maximum(f)-1;
    if Length(Set(f)) > 1 then
        if mi^l < 2^28 then
            indices:=CoefficientsMultiadic(List([1..l], x->mi),n mod (mi^l))+2;
        else
            indices := [ ];
            n1 := n mod (mi^l);
            for i in Reversed( [1..l] ) do
                indices[ i ] := ( n1 mod mi ) + 2;
                n1 := QuoInt( n1, mi );
            od;
        fi;
        n:=QuoInt(n,mi^l);
    else
        indices := f;
    fi;

    # create the collector for the free group
    rws := SingleCollector( F, indices );

    # set up non-trivial relators
    ll:=l*(l+1)/2-1;
    if ll < 28 then
        uc:=Reversed(CoefficientsMultiadic(List([1..ll],x->2),n mod (2^ll)));
    else
        uc := [];
        n1 := n mod (2^ll);
        for i in [1..ll] do
            uc[i] := n1 mod 2;
            n1 := QuoInt( n1, 2 );
        od;
    fi;
    n:=QuoInt(n,2^ll);

    # construct non-trivial relators - get tails
    rr   := [];
    for i in [1..Sum(uc)] do
        t:=CoefficientsMultiadic(indices,n mod size);
        g:=gens[1]^0;
        for j in [1..l] do
            if t[j] > 0 then 
                g:=g*gens[j]^t[j];
            fi;
        od;
        Add(rr,g);
        n:=QuoInt(n,size);
    od;

    # compute non-trivial power relators
    z:=1;
    for i in [1..l-1] do
        if uc[i] = 1 then
            Add( rels, [i, rr[z]] );
            z:=z+1;
        fi;
    od;
    z2:=l-1;

    # compute non-trivial commutator relators
    for i in [1..l] do
        for j in [i+1..l] do
            z2:=z2+1;
            if uc[z2] = 1 then
                Add( rels , [j, i, rr[z]] );
                z:=z+1;
            fi;
        od;
    od;

    # introduce powers and commutators for the rws
    for x  in rels  do
        if 2 = Length(x)  then
            SetPower( rws, x[1], x[2] );
        else
            SetCommutator( rws, x[1], x[2], x[3] );
        fi;
    od;

    # create the group
    return GroupByRwsNC( rws );
end;

#############################################################################
##
#F GroupCode( c ) . . . . . . . . . . . . . . . . . . . . . . . . . . .decode
##
GroupCode := function( c )
    if c > 0 then
        return AgGroupCode( c );
    fi;
    return PermGroupCode( c );
end;

#############################################################################
##
#F LoadSmallGroups( list ) . . . . . . . . . . . . . . . . . . . .load groups
##
LoadSmallGroups := function( list )
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
end;

#############################################################################
##
#F UnloadSmallGroups( list ) . . . . . . . . . . . . . . . . . .unbind groups
##
UnloadSmallGroups := function( list )
    local i;
    for i in list do
        Unbind( Table1000[i] );
    od;
end;

#############################################################################
##
#F SmallGroup( size, nr ) . . . . . . . . . . .construct group from catalogue
##
SmallGroup := function( size, nr )
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
    g := GroupCode( Table1000[ size ][ nr ] );
    return g;
end;

#############################################################################
##
#F AllSmallGroups( size ) . . . . . . . . . . construct groups from catalogue
##
AllSmallGroups := function( size )

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
end;

#############################################################################
##
#F NumberSmallGroups( size ) . . . . . . . . . . . . . . . . number of groups
##
NumberSmallGroups := function( size )

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
end;

