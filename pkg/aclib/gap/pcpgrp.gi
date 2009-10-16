#############################################################################
##
#W    pcpgrp.gi                                                  Bettina Eick
##
##    This file contains the header functions to handle the 3- and 
##    4-dimensional almost crystallographic pcp groups.
##

#############################################################################
##
#F IsAlmostCrystallographic( <G> )
##
InstallMethod( IsAlmostCrystallographic, "for pcp groups", true,
    [IsPcpGroup ], 0,
function( G )
    if HasAlmostCrystallographicInfo( G ) then return true; fi;
    return (IsInt(Index(G,FittingSubgroup(G))) and 
            Size(NormalTorsionSubgroup(G)) = 1); 
end );

#############################################################################
##
#F IsAlmostBieberbachGroup( <G> )
##
InstallMethod( IsAlmostBieberbachGroup, "for pcp groups", true,
    [IsPcpGroup ], 0,
function( G )
    return IsInt(Index(G,FittingSubgroup(G))) and IsTorsionFree(G);
end );

#############################################################################
##
#F IsolatorSubgroup( G, N )
##
InstallGlobalFunction( IsolatorSubgroup, function( G, N )
    local nat, F, T;
    if not IsNormal( G, N ) then return fail; fi;
    nat := NaturalHomomorphism( G, N );
    F := Image( nat );
    T := TorsionSubgroup( F );
    if IsBool( T ) then return fail; fi;
    return PreImage( nat, T );
end);

#############################################################################
##
#F AlmostCrystallographicPcpDim3( type, param )
##
InstallGlobalFunction( AlmostCrystallographicPcpDim3,
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
        if param[1] = 0 then param[1] := Random(Integers)^2+1; fi;
    elif IsInt( param ) then 
        param := List( [1..ACDim3Param[g]], x -> param );
    elif Length( param ) <> ACDim3Param[g] then 
        Error("parameter should be a list of length ", ACDim3Param[g] );
    fi;

    # get group
    if Length( param ) = 4 then 
        G := ACPcpDim3Funcs[g](param[1], param[2], param[3], param[4]);
    elif Length(param) = 2 then
        G := ACPcpDim3Funcs[g](param[1], param[2] );
    elif Length(param) = 1 then 
        G := ACPcpDim3Funcs[g](param[1]);
    fi;

    # set some information
    info := rec( dim := 3, type := g, param := param );
    SetAlmostCrystallographicInfo( G, info );
    SetIsAlmostCrystallographic( G, true );
    SetSize( G, infinity );
    return G;
end );
 
#############################################################################
##
#F AlmostCrystallographicPcpDim4( type, param )
##
InstallGlobalFunction( AlmostCrystallographicPcpDim4,
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
        if param[1] = 0 then param[1] := Random(Integers)^2+1; fi;
    elif IsInt( param ) then 
        param := List( [1..ACDim4Param[g]], x -> param );
    elif Length( param ) <> ACDim4Param[g] then
        Error("parameter should be a list of length ", ACDim4Param[g] );
    fi;

    # get group
    if Length(param) = 7 then
        G := ACPcpDim4Funcs[g]( param[1], param[2], param[3], param[4], 
                                param[5], param[6], param[7]);
    elif Length(param) = 6 then
        G := ACPcpDim4Funcs[g]( param[1], param[2], param[3], param[4], 
                                param[5], param[6]);
    elif Length(param) = 5 then
        G := ACPcpDim4Funcs[g]( param[1], param[2], param[3], param[4], 
                                param[5]);
    elif Length(param) = 4 then
        G := ACPcpDim4Funcs[g]( param[1], param[2], param[3], param[4]);
    elif Length(param) = 3 then
        G := ACPcpDim4Funcs[g]( param[1], param[2], param[3]);
    fi;

    # set some information
    info := rec( dim := 4, type := g, param := param );
    SetAlmostCrystallographicInfo( G, info );
    SetIsAlmostCrystallographic( G, true );
    SetSize( G, infinity );
    return G;
end );

#############################################################################
##
#F AlmostCrystallographicPcpGroup( dim, type, param )
##
InstallGlobalFunction( AlmostCrystallographicPcpGroup,
function( dim, type, param )
    if dim = 3 then 
        return AlmostCrystallographicPcpDim3( type, param );
    elif dim = 4 then 
        return AlmostCrystallographicPcpDim4( type, param );
    else
        Error("dimension must be 3 or 4");
    fi;
end );

#############################################################################
##
#A  FittingSubgroup( < G > )
##
InstallMethod( FittingSubgroup, "for ac pcp groups", true, 
      [IsPcpGroup and HasAlmostCrystallographicInfo], 0, 
function( G )
    local pcp, rel, sub, F;
    pcp := Pcp( G );
    rel := RelativeOrdersOfPcp( pcp );
    sub := Filtered( [1..Length(pcp)], x -> rel[x] = 0 );
    F := Subgroup( G, pcp{sub} );
    SetIsNilpotentGroup( F, true );
    return F;
end );

#############################################################################
##
#F  NaturalHomomorphismOnHolonomyGroup( < G > )
#F  HolonomyGroup( < G > )
##
InstallMethod( NaturalHomomorphismOnHolonomyGroup, "for ac pcp groups", true,
    [IsPcpGroup and IsAlmostCrystallographic], 0, 
function( G )
    return NaturalHomomorphism(G,FittingSubgroup(G));
end );

InstallMethod( HolonomyGroup, "for ac pcp groups", true,
    [IsPcpGroup and IsAlmostCrystallographic], 0, 
function( G )
    return Image( NaturalHomomorphismOnHolonomyGroup(G) );
end );


