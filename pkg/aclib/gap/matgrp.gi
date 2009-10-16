#############################################################################
##
#W    matgrp.gi                                                  Bettina Eick
##
##    This file contains the header functions to handle the 3- and 
##    4-dimensional almost crystallographic integral matrix groups.
##

#############################################################################
##
#F AlmostCrystallographicDim3( type, param )
##
InstallGlobalFunction( AlmostCrystallographicDim3, 
function( type, param )
    local g, G, info;
  
    # type is integer or string
    if IsString( type ) then 
        g := Int( type );
    elif IsInt( type ) then
        g := type;
    else 
        g := false;
    fi;
    if not g in [1..17] then 
        Error("type does not define a valid ac-group type");
    fi;

    # check parameters
    if IsBool( param ) then
        param := List( [1..ACDim3Param[g]], x -> Random(Integers) );
        if param[1] = 0 then param[1] := Random(Integers)^2 + 1; fi;
    elif IsInt( param ) then 
        param := List( [1..ACDim3Param[g]], x -> param );
    elif Length( param ) <> ACDim3Param[g] then
        Error("parameter should be a list of length ", ACDim3Param[g] );
    fi;

    # get group
    if Length( param ) = 4 then
        G := ACDim3Funcs[g](param[1], param[2], param[3], param[4]);
    elif Length(param) = 2 then
        G := ACDim3Funcs[g](param[1], param[2] );
    elif Length(param) = 1 then
        G := ACDim3Funcs[g](param[1]);
    fi;

    # set some information
    info := rec( dim := 3, type := g, param := param );
    SetAlmostCrystallographicInfo( G, info );
    SetIsAlmostCrystallographic( G, true );
    SetDimensionOfMatrixGroup( G, 4 );
    SetFieldOfMatrixGroup( G, Rationals );
    SetSize( G, infinity );
    return G;
end );
 
#############################################################################
##
#F AlmostCrystallographicDim4( type, param )
##
InstallGlobalFunction( AlmostCrystallographicDim4, 
function( type, param )
    local g, G, info;

    # type is integer or string
    if IsString( type ) then
        g := Position( ACDim4Types, type );
    elif IsInt( type ) then
        g := type;
    else 
        g := false;
    fi;
    if not g in [1..95] then 
        Error("type does not define a valid ac-group type");
    fi;

    # check parameters
    if IsBool( param ) then
        param := List( [1..ACDim4Param[g]], x -> Random(Integers) );
        if param[1] = 0 then param[1] := Random(Integers)^2 + 1; fi;
    elif IsInt( param ) then 
        param := List( [1..ACDim4Param[g]], x -> param );
    elif Length( param ) <> ACDim4Param[g] then
        Error("parameter should be a list of length ", ACDim4Param[g] );
    fi;

    # get group
    if Length(param) = 7 then
        G := ACDim4Funcs[g]( param[1], param[2], param[3], param[4], 
                             param[5], param[6], param[7]);
    elif Length(param) = 6 then
        G := ACDim4Funcs[g]( param[1], param[2], param[3], param[4], 
                             param[5], param[6]);
    elif Length(param) = 5 then
        G := ACDim4Funcs[g]( param[1], param[2], param[3], param[4], 
                             param[5]);
    elif Length(param) = 4 then
        G := ACDim4Funcs[g]( param[1], param[2], param[3], param[4]);
    elif Length(param) = 3 then
        G := ACDim4Funcs[g]( param[1], param[2], param[3]);
    fi;

    # set some information
    info := rec( dim := 4, type := g, param := param );
    SetAlmostCrystallographicInfo( G, info );
    SetIsAlmostCrystallographic( G, true );
    SetDimensionOfMatrixGroup( G, 5 );
    SetFieldOfMatrixGroup( G, Rationals );
    SetSize( G, infinity );
    return G;
end );

#############################################################################
##
#F AlmostCrystallographicGroup( dim, type, param )
##
InstallGlobalFunction( AlmostCrystallographicGroup,
function( dim, type, param )
    if dim = 3 then 
        return AlmostCrystallographicDim3( type, param );
    elif dim = 4 then 
        return AlmostCrystallographicDim4( type, param );
    else
        Error("dimension must be 3 or 4");
    fi;
end );

#############################################################################
##
#F IsomorphismPcpGroup( <G> )
##
InstallMethod( IsomorphismPcpGroup, "for ac groups", true, 
    [IsMatrixGroup and HasAlmostCrystallographicInfo], 0,
function( G )
    local info, H, gensH, gensG, l, d, newsG, hom;

    # get the corresponding pcp group
    info := AlmostCrystallographicInfo( G );
    H := AlmostCrystallographicPcpGroup( info.dim, info.type, info.param );
    gensH := GeneratorsOfGroup(H);
    gensG := GeneratorsOfGroup(G);

    # sort the generators of G according to the generators of H
    l := Length( gensG );
    d := info.dim;
    newsG := Concatenation( Reversed( gensG{[d+1..l]} ), gensG{[1..d]} );
    hom := GroupHomomorphismByImagesNC( G, H, newsG, gensH );
    SetIsInjective( hom, true );
    SetIsSurjective( hom, true );
    return hom;
end );

#############################################################################
##
#F IsAlmostCrystallographic( <G> )
##
InstallMethod( IsAlmostCrystallographic, "for groups", true, 
    [IsGroup ], 0,
function( G )
    if HasAlmostCrystallographicInfo( G ) then
        return true;
    else
        Print("sorry - cannot check this property \n");
        return fail;
    fi;
end );
