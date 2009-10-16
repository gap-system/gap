#############################################################################
##
#A  color.gi                  Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##
##  Cryst - the crystallographic groups package for GAP (color groups)
##  

#############################################################################
##
#M  IsColorGroup( G ) . . . . . . . . . . . . . . . . . .is it a color group?
##

# Subgroups of ColorGroups are ColorGroups
InstallSubsetMaintenance( IsColorGroup, IsGroup, IsCollection );

# ColorGroups always know that they are ColorGroups
InstallMethod( IsColorGroup, 
    "fallback method", true, [ IsGroup ], 0, G -> false );

#############################################################################
##
#M  ColorSubgroup( G ) . . . . . . . . . . . . . . extract the color subgroup
##
InstallMethod( ColorSubgroup,
    "for subgroups", true, [ IsColorGroup and HasParent ], 0,
function( G )
    local P;
    P := Parent( G );
    while HasParent( P ) and P <> Parent( P ) do
        P := Parent( P );
    od;
    return Intersection( ColorSubgroup( P ), G );
#    return Stabilizer( G, ColorCosetList( P )[1], OnRight );
end );

#############################################################################
##
#M  ColorCosetList( G ) . . . . . . . . . . . . . .color labelling coset list
##
InstallMethod( ColorCosetList,
    "generic", true, [ IsColorGroup ], 0,
    G -> RightCosets( G, ColorSubgroup( G ) ) );

#############################################################################
##
#M  ColorOfElement( G, elm ) . . . . . . . . . . . . . . .color of an element
##
InstallGlobalFunction( ColorOfElement, function( G, elm )
    local P, cos, i;
    P := G;
    while HasParent( P ) and Parent( P ) <> P do
        P := Parent( P );
    od;
    cos := ColorCosetList( P );
    for i in [1..Length( cos )] do
        if elm in cos[i] then
            return i;
        fi;
    od;
    Error("elm must be an element of G");
end );


#############################################################################
##
#F  ColorPermGroupHomomorphism( G ) . . . . .color PermGroup and homomorphism
##
ColorPermGroupHomomorphism := function( G )
    local P, pmg, hom;
    P := G;
    while HasParent( P ) and P <> Parent( P ) do
        P := Parent( P );
    od;
    pmg := Action( G, ColorCosetList( P ), OnRight );
    hom := ActionHomomorphism( G, pmg );
    return [ pmg, hom ];
end;


#############################################################################
##
#M  ColorPermGroup( G ) . . . . . . . . . . . . . . . . . . . color PermGroup
##
InstallMethod( ColorPermGroup,
    "generic", true, [ IsColorGroup ], 0,
function( G )
    local tmp;
    tmp := ColorPermGroupHomomorphism( G );
    SetColorHomomorphism( G, tmp[2] );
    return tmp[1];
end );


#############################################################################
##
#M  ColorHomomorphism( G ) . . . . . . . . . .homomorphism to color PermGroup
##
InstallMethod( ColorHomomorphism,
    "generic", true, [ IsColorGroup ], 0,
function( G )
    local tmp;
    tmp := ColorPermGroupHomomorphism( G );
    SetColorPermGroup( G, tmp[1] );
    return tmp[2];
end );


#############################################################################
##
#M  PointGroup( G ) . . . . . . . . . . . . . . . . . . . . .color PointGroup
##
InstallMethod( PointGroup, "for colored AffineCrystGroups", 
    true, [ IsColorGroup and IsAffineCrystGroupOnLeftOrRight ], 0,
function( G )

    local tmp, P, hom, H, reps;

    tmp := PointGroupHomomorphism( G );
    P   := tmp[1];
    hom := tmp[2];
    SetPointGroup( G, P );
    SetPointHomomorphism( G, hom );

    # color the point group if possible
    H := ColorSubgroup( G );
    if TranslationBasis( G ) = TranslationBasis( H ) then
        H := PointGroup( H );
        SetIsColorGroup( P, true );
        SetColorSubgroup( P, H );
        reps := List( ColorCosetList( G ), 
                x -> ImagesRepresentative( hom, Representative( x ) ) );
        SetColorCosetList( P, List( reps, x -> RightCoset( H, x ) ) );
    fi;
    
    return P;

end );


#############################################################################
##
#M  ColorGroup( G, H ) . . . . . . . . . . . . . . . . . . make a color group
##
InstallGlobalFunction( ColorGroup, function( G, H )

    local C, U, P, reps;

    # H must be a subgroup of G
    if not IsSubgroup( G, H ) then
        Error("H must be contained in G");
    fi;

    # since G may contain uncolored information components, make a new group
    C := GroupByGenerators( GeneratorsOfGroup( G ), One( G ) );
    U := GroupByGenerators( GeneratorsOfGroup( H ), One( H ) );

    # make C a color group
    SetIsColorGroup( C, true );
    SetColorSubgroup( C, U ); 

    # if G is an AffineCrystGroup, make C am AffineCrystGroup
    if IsCyclotomicMatrixGroup( G ) then
        if IsAffineCrystGroupOnRight( G ) then
            SetIsAffineCrystGroupOnRight( C, true );
            SetIsAffineCrystGroupOnRight( U, true );
            if HasTranslationBasis( H ) then
                AddTranslationBasis( U, TranslationBasis( H ) );
            fi;
            if HasTranslationBasis( G ) then
                AddTranslationBasis( C, TranslationBasis( G ) );
            fi;
        fi;
        if IsAffineCrystGroupOnLeft( G ) then
            SetIsAffineCrystGroupOnLeft( C, true );
            SetIsAffineCrystGroupOnLeft( U, true );
            if HasTranslationBasis( H ) then
                AddTranslationBasis( U, TranslationBasis( H ) );
            fi;
            if HasTranslationBasis( G ) then
                AddTranslationBasis( C, TranslationBasis( G ) );
            fi;
        fi;
    fi;

    SetParent( C, C );
    return C;

end );

