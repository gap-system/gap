#############################################################################
##
#W  small.gi                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the basic installations for the library of small
##  groups and the group identification routines. 
##

#############################################################################
##
#F  SMALL_AVAILABLE_FUNCS
##
##  On every level of the small groups library one function is written into
##  this list. It will detect those sizes, which are contained in this
##  library level.
SMALL_AVAILABLE_FUNCS := [ ];

#############################################################################
##
#F  SMALL_AVAILABLE( size )
##
##  returns fail if the library of groups of <size> is not installed.
##  Otherwise a record with some information about the construction of the
##  groups of <size> is returned.
InstallGlobalFunction( SMALL_AVAILABLE, function( size )
    local l, r;

    for l in [ 1 .. Length( SMALL_AVAILABLE_FUNCS ) ] do
        if IsBound( SMALL_AVAILABLE_FUNCS[ l ] ) then
            r := SMALL_AVAILABLE_FUNCS[ l ]( size );
            if r <> fail then
                return r;
            fi;
        fi;
    od;
    return fail;
end );

#############################################################################
##
#F  SMALL_GROUP_FUNCS
##
##  This list will contain all functions to construct/read the groups from
##  the library.
SMALL_GROUP_FUNCS := [ ];

#############################################################################
##
#F  CODE_SMALL_GROUP_FUNCS
##
##  This list will contain those functions used to read the code of the
##  groups of some sizes from the data files.
CODE_SMALL_GROUP_FUNCS := [ ];

#############################################################################
##
#F  NUMBER_SMALL_GROUPS_FUNCS
##
NUMBER_SMALL_GROUPS_FUNCS := [ ];

#############################################################################
##
#F  SELECT_SMALL_GROUPS_FUNCS
##
SELECT_SMALL_GROUPS_FUNCS := [ ];

#############################################################################
##
#V  SMALL_GROUP_LIB
##
##  This list will contain all data for the group construction read from the
##  small group library.
SMALL_GROUP_LIB := AtomicList([ ]);

#############################################################################
##
#V  PROPERTIES_SMALL_GROUPS
##
##  This list will contain all data for the group selection read from the
##  small group library.
PROPERTIES_SMALL_GROUPS := AtomicList([ ]);

#############################################################################
##
#F  SmallGroup(<size>,<i>)
##
##  returns the <i>th  group of  order <size> in the catalogue. It will return
##  an PcGroup, if the group is soluble and a permutation group otherwise.
##  If the groups of this size are not installed, it will return an error.
InstallGlobalFunction( SmallGroup, function( arg )
    local inforec, g, size, i;

    if Length( arg ) = 1 then
        if not IsList( arg[1] ) or Length( arg[1] ) <> 2 then 
            Error( "usage: SmallGroup( order, number )" ); 
        fi;
        size := arg[ 1 ][ 1 ];
        i    := arg[ 1 ][ 2 ];
    elif Length( arg ) = 2 then 
        size := arg[ 1 ];
        i    := arg[ 2 ];
    else 
        Error( "usage: SmallGroup( order, number )" ); 
    fi;
    if not IsPosInt( size ) or not IsPosInt( i ) then 
        Error( "usage: SmallGroup( order, number )" ); 
    fi;
    inforec := SMALL_AVAILABLE( size );
    if inforec = fail then
        Error( "the library of groups of size ", size, " is not available" );
    fi;
    g := SMALL_GROUP_FUNCS[ inforec.func ]( size, i, inforec );
    SetIdGroup( g, [ size, i ] );
    IsPGroup( g );
    return g;
end );

#############################################################################
##
#F  NumberSmallGroups(<size>)
##
##  returns the  number of groups of the order <size>.
InstallGlobalFunction( NumberSmallGroups, function( size )
    local inforec, r;

    if not IsPosInt( size ) then 
        Error( "usage: NumberSmallGroups( order )" ); 
    fi;
    if size = 1024 then 
        return 49487365422;
    fi;

    inforec := SMALL_AVAILABLE( size );
    if inforec = fail then
        Error( "the library of groups of size ", size, " is not available" );
    fi;

    if IsBound( inforec.number ) then 
        return inforec.number;
    fi;
    
    r := NUMBER_SMALL_GROUPS_FUNCS[ inforec.func ]( size, inforec );
    
    atomic readonly r do
        return r.number;
    od;    
    
end );

#############################################################################
##
#F  SelectSmallGroups( argl, all, id )
##
InstallGlobalFunction( SelectSmallGroups, function( argl, all, id )
    local sizes, size, i, funcs, vals, gs, inforec, result, hasSizes, pos,
          idList;

    sizes := [ ];
    hasSizes := false;
    idList := fail;

    for i in [ 1 .. Length( argl ) ] do
        if i = 1 and argl[ i ] = Size then
            ;
        elif ( not hasSizes ) and IsList( argl[ i ] )
                              and Length( sizes ) = 1 then
            idList := argl[ i ];
        elif ( not hasSizes ) and IsList( argl[ i ] ) then
            Append( sizes, argl[ i ] );
        elif ( not hasSizes ) and IsInt( argl[ i ] ) then
            Add( sizes, argl[ i ] );
        elif ( not hasSizes ) and sizes <> [] and IsFunction( argl[i] ) then
            hasSizes     := true;
            funcs        := [ argl[ i ] ];
            vals         := [ [ ] ];
            pos          := 1;
        elif not hasSizes then 
            Error( "usage: AllSmallGroups / OneGroup(\n",
                   "             Size, [ sizes ],\n",
                   "             function1, [ values1 ],\n",
                   "             function2, [ values2 ], ... )" );
        elif vals[ pos ] <> [ ] and IsFunction( argl[ i ] ) then
            pos          := pos + 1;
            funcs[ pos ] := argl[ i ];
            vals[ pos ]  := [ ];
        elif IsFunction( argl[ i ] ) then
            vals[ pos ]  := [ true ];
            pos          := pos + 1; 
            funcs[ pos ] := argl[ i ];
            vals[ pos ]  := [ ];
        elif IsList( argl[ i ] ) and vals[ pos ] = [ ] then
            vals[ pos ]  := argl[ i ];
        elif IsList( argl[ i ] ) and IsInt( argl[ i ][ 1 ] ) and 
             IsList( vals[ pos ][ 1 ] ) and IsInt( vals[ pos ][1][ 1 ] ) then
            Add( vals[ pos ], argl[ i ] );
        elif IsList( argl[ i ] ) and IsInt( argl[ i ][ 1 ] ) and 
             IsInt( vals[ pos ][ 1 ] ) then
            vals[ pos ]  := [ vals[ pos ], argl[ i ] ];
        else 
            Add( vals[ pos ], argl[ i ] );
        fi;
    od;

    if sizes <> [ ] and ( not IsBound( vals ) ) then
        funcs := [ ];
        vals  := [ ];
    elif vals[ pos ] = [ ] then
        vals[ pos ] := [ true ];
    fi;

    result := [ ];
    for size in sizes do
        inforec := SMALL_AVAILABLE( size );
        if inforec = fail then
            Error( "AllSmallGroups / OneGroup: groups of order ", size,
                   " not available" );
        fi;
        gs := SELECT_SMALL_GROUPS_FUNCS[ inforec.func ]
                             ( size, funcs, vals, inforec, all, id, idList );
        if all then
            Append( result, gs );
        elif gs <> fail then
            return gs;
        fi;
    od;
    
    if all then
        return result;
    else
        return fail;
    fi;
end );

#############################################################################
##
#F ID_AVAILABLE_FUNCS
##
ID_AVAILABLE_FUNCS := [ ];

#############################################################################
##
#F ID_AVAILABLE
##
InstallGlobalFunction( ID_AVAILABLE, function( size )
    local l, r;

    if not IsInt( size ) then return fail; fi;

    for l in [ 1 .. Length( ID_AVAILABLE_FUNCS ) ] do
        if IsBound( ID_AVAILABLE_FUNCS[ l ] ) then
            r := ID_AVAILABLE_FUNCS[ l ]( size );
            if r <> fail then 
                return r;
            fi;
        fi;
    od;
    return fail;
end );

#############################################################################
##
#F  ID_GROUP_FUNCS
##
ID_GROUP_FUNCS := [ ];

#############################################################################
##
#M  IdGroup( G )
##
InstallMethod( IdGroup,
               "generic method for groups",
               true,
               [ IsGroup ],
               0,
function( G )
    local inforec, size;

    size := Size( G );
    if size = 1 then return [ 1, 1 ]; fi;

    inforec := ID_AVAILABLE( size );
    if inforec = fail then
        Error( "the group identification for groups of size ", size,
               " is not available" );
    fi;

    if not ( IsPcGroup( G ) or IsPermGroup( G ) ) then
        if IsSolvableGroup( G ) then
            G := Image( IsomorphismPcGroup( G ) );
        else
            G := Image( IsomorphismPermGroup( G ) );
        fi;
    fi;

    if Size( G ) > 1000 and IsPermGroup( G )
          and LargestMovedPoint( G ) > 100 and IsSolvableGroup( G ) then
        G := Image( IsomorphismPcGroup( G ) );
    fi;

    if IsPcGroup( G ) and HasParent( G ) and Size( Parent( G ) ) > 10000
       and Size( Parent( G ) ) / Size( G ) > 10 then
        G := PcGroupCode( CodePcGroup( G ), Size( G ) );
    fi;

    return [ size, ID_GROUP_FUNCS[ inforec.func ]( G, inforec ) ];
end );

#############################################################################
##
#V  ID_GROUP_TREE
##
##  Variable containing information for group identification
ID_GROUP_TREE := ShareSpecialObj( rec( fp := [ 1 .. 50000 ], next := [ ] ) );

#############################################################################
##
#F  ReadSmallLib( str, i, size, list )
##
##  universal reading function for data files
ReadSmallLib := function( str, i, size, list )
    local l, str2, str3, j;

    l := "abcdefghijklmnopqrstuvwxyz";     
    str2 := Concatenation( str, String( size ) );
    str3 :=  [ ];
    for j in list do
        if j > 702 then
            Add( str3, l[ QuoInt( j - 27, 676 ) ] );
            j := 27 + ( j - 27 ) mod 676;
        fi; 
        if j > 26 then
            Add( str3, l[ QuoInt( j - 1, 26 ) ] );        
        fi;         
        Add( str3, l[ ( j - 1 ) mod 26 + 1 ] );
    od;

    if Length( str2 ) > 8 then
        str3 := Concatenation( str2{[ 9..Length( str2 ) ]} , str3 );
        str2 := str2{[ 1..8 ]};
    elif Length( str3 ) = 0 then
        str3 := "z";
    elif Length( str3 ) > 3 then
        str2 := Concatenation( str2, str3{[ 1 .. Length( str3 ) - 3 ]} );
        str3 := str3{[ Length( str3 ) - 2 .. Length( str3 ) ]};
    fi;

    if str in [ "sml", "col", "prop", "nor" ] then
        READ_SMALL_FUNCS[ i ]( Concatenation( str2, ".", str3 ) );
    else
        READ_IDLIB_FUNCS[ i ]( Concatenation( str2, ".", str3 ) );
    fi;
end;

#############################################################################
##
#V  GAP3_CATALOGUE_ID_GROUP
##
##  List with the gap3-ids. Will be loaded before use.
GAP3_CATALOGUE_ID_GROUP := fail;

#############################################################################
##
#M  Gap3CatalogueIdGroup(<G>)
##             
InstallMethod( Gap3CatalogueIdGroup,                              
               "for permgroups or pcgroups",        
               true,         
               [ IsGroup ],
               0,
function( G )
    if Size( G ) > 100 then
        Error( "Gap3CatalogueIdGroup: the group catalogue of gap-3.0 was\n",
               "limited to size 100" );
    fi;

    if GAP3_CATALOGUE_ID_GROUP = fail then
        ReadSmall( "gap3cat.g" );
    fi;

    if not IsBound( GAP3_CATALOGUE_ID_GROUP[ Size( G ) ] ) then
        return IdGroup( G );
    fi;

    return [ Size( G ),
             GAP3_CATALOGUE_ID_GROUP[ Size( G ) ][ IdGroup( G )[ 2 ] ] ];
end );

#############################################################################
##
#F  Gap3CatalogueGroup(<size>,<i>)
##             
InstallGlobalFunction( Gap3CatalogueGroup, function( size, i )
    local p;

    if size > 100 then
        Error( "Gap3CatalogueIdGroup: the group catalogue of gap-3.0 was\n",
               "limited to size 100" );
    fi;

    if GAP3_CATALOGUE_ID_GROUP = fail then
        ReadSmall( "gap3cat.g" );
    fi;

    if not IsBound( GAP3_CATALOGUE_ID_GROUP[ size ] ) then
        return SmallGroup( size, i );
    fi;

    p := Position( GAP3_CATALOGUE_ID_GROUP[ size ], i );
    if p = fail then
        Error( "Gap3CatalogueGroup: there are just ",
               Length( GAP3_CATALOGUE_ID_GROUP[ size ] ),
               " groups of size ", size );
    fi;

    return SmallGroup( size, p );
end );

#############################################################################
##
#F  UnloadSmallGroupsData( )
##
##  will remove the data from the small groups library from memory. 
InstallGlobalFunction( UnloadSmallGroupsData, function( )
    SMALL_GROUP_LIB := AtomicList([ ]);
    PROPERTIES_SMALL_GROUPS := AtomicList([ ]);
    GAP3_CATALOGUE_ID_GROUP := fail;
    ID_GROUP_TREE := ShareSpecialObj( rec( fp := [ 1 .. 50000 ], next := [ ] ) );
end );

#############################################################################
##
#M  FrattinifactorSize(<G>)
##
InstallMethod( FrattinifactorSize,
               "generic method for groups",
               true,
               [ IsGroup ],
               0,
function( G )
    return Size( G ) / Size( FrattiniSubgroup( G ) );
end );

#############################################################################
##
#M  FrattinifactorId(<G>)
##
InstallMethod( FrattinifactorId,
               "generic method for groups",
               true,
               [ IsGroup ],
               0,
function( G )
    local ff;                                  

    ff := G / FrattiniSubgroup( G );  
    if ID_AVAILABLE( Size( ff ) ) = fail then
        Error( "FrattinifactorId: IdGroup for groups of size ", Size( ff ),
               " not available" );
    fi;
    return IdGroup( ff );                                      
end );

#############################################################################
##  
#F  FinalizeSmallGroupData()
##
##  This function should be called when all levels of the small group library 
##  have been loaded. It makes various records immutable for thread-safety.
##
InstallGlobalFunction( FinalizeSmallGroupData,
        function()
    MakeImmutable(CODE_SMALL_GROUP_FUNCS);
    MakeImmutable(SMALL_GROUP_FUNCS);
    MakeImmutable(NUMBER_SMALL_GROUPS_FUNCS);
    MakeImmutable(SELECT_SMALL_GROUPS_FUNCS);
    MakeImmutable(SMALL_AVAILABLE_FUNCS);
    MakeImmutable(ID_AVAILABLE_FUNCS);
    MakeImmutable(READ_SMALL_FUNCS);
    MakeImmutable(READ_IDLIB_FUNCS);
    MakeImmutable(ID_GROUP_FUNCS);
end);

