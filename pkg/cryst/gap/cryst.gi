#############################################################################
##
#A  cryst.gi                  Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##
##  Methods for affine crystallographic groups
##

#############################################################################
##
##  Utility functions
##
#############################################################################

#############################################################################
##
#M  IsAffineMatrixOnRight( <mat> ) . . . . . . . affine matrix action OnRight
##
InstallGlobalFunction( IsAffineMatrixOnRight, function( mat )
    local d, v;
    if not IsMatrix( mat ) or not IsCyclotomicCollColl( mat ) then
        return false;
    fi;
    d := Length( mat );
    v := 0 * [1..d]; v[d] := 1;
    return mat{[1..d]}[d] = v;
end );

#############################################################################
##
#M  IsAffineMatrixOnLeft( <mat> ) . . . . . . . . affine matrix action OnLeft
##
InstallGlobalFunction( IsAffineMatrixOnLeft, function( mat )
    local d, v;
    if not IsMatrix( mat ) or not IsCyclotomicCollColl( mat ) then
        return false;
    fi;
    d := Length( mat );
    v := 0 * [1..d]; v[d] := 1;
    return mat[d] = v;
end );


#############################################################################
##
##  Methods and functions for CrystGroups and PointGroups
##
#############################################################################

#############################################################################
##
#M  IsAffineCrystGroupOnLeftOrRight( <S> )  . . . . . AffineCrystGroup acting 
#M  . . . . . . . . . . . . . . . . . . . . . . . .  either OnLeft or OnRight
##
InstallTrueMethod(IsAffineCrystGroupOnLeftOrRight,IsAffineCrystGroupOnRight);
InstallTrueMethod(IsAffineCrystGroupOnLeftOrRight,IsAffineCrystGroupOnLeft);

#############################################################################
##
#M  TransposedMatrixGroup( <S> ) . . . . . . . .transpose of AffineCrystGroup
##
InstallMethod( TransposedMatrixGroup, 
    true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
function( S )
    local gen, grp;
    gen := List( GeneratorsOfGroup( S ), TransposedMat );
    grp := Group( gen, One( S ) );
    if IsAffineCrystGroupOnRight( S ) then
        SetIsAffineCrystGroupOnLeft( grp, true );
    else
        SetIsAffineCrystGroupOnRight( grp, true );
    fi;
    if HasTranslationBasis( S ) then
        AddTranslationBasis( grp, TranslationBasis( S ) );
    fi;
    SetTransposedMatrixGroup( grp, S );
    UseIsomorphismRelation( S, grp );
    return grp;
end );

#############################################################################
##
#M  InternalBasis( S ) . . . . . . . . . . . . . . . . . . . . internal basis
##
InstallMethod( InternalBasis, 
    true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
function( S )

    local d, T, basis, comp, i, j, k, mat;

    d := DimensionOfMatrixGroup( S ) - 1;
    T := TranslationBasis( S );
    if Length( T ) = d then
        basis := T;
    elif Length( T ) = 0 then
        basis := IdentityMat( d );
    else
        comp := NullMat( d - Length(T), d );
        i:=1; j:=1; k:=1;
        while i <= Length( T ) do
            while T[i][j] = 0 do
                comp[k][j] := 1;
                k := k+1; j:=j+1;
            od;
            i := i+1; j := j+1;
        od;
        while j <= d do
            comp[k][j] := 1;
            k := k+1; j:=j+1;
        od;            
        basis := Concatenation( T, comp );
    fi;

    SetIsStandardAffineCrystGroup( S, basis = IdentityMat( d ) );

    if not IsStandardAffineCrystGroup( S ) then
        mat := IdentityMat( d+1 );
        mat{[1..d]}{[1..d]} := basis;
        if IsAffineCrystGroupOnRight( S ) then
            S!.lconj := mat;
            S!.rconj := mat^-1;
        else
            mat := TransposedMat( mat );
            S!.lconj := mat^-1;
            S!.rconj := mat;
        fi;
    fi;

    return basis;

end );

#############################################################################
##
#F  TranslationBasisFun( S ) . . . . . determine basis of translation lattice
##
TranslationBasisFun := function ( S )

    local d, P, Sgens, Pgens, trans, g, m, F, Fgens, rel, new;

    if IsAffineCrystGroupOnLeft( S ) then
        Error( "use only for an AffineCrystGroupOnRight" );
    fi;

    d := DimensionOfMatrixGroup( S ) - 1;
    P := PointGroup( S );
    Pgens := [];
    Sgens := [];
    trans := [];

    # first the obvious translations
    for g in GeneratorsOfGroup( S ) do
        m := g{[1..d]}{[1..d]};
        if IsOne( m ) then
            Add( trans, g[d+1]{[1..d]} );
        else
            Add( Sgens, g );
            Add( Pgens, m );
        fi;
    od;

    # then the hidden translations
    if not IsTrivial( P ) then
        F := Image( IsomorphismFpGroupByGenerators( P, Pgens ) );
        Fgens := GeneratorsOfGroup( FreeGroupOfFpGroup( F ) );
        for rel in RelatorsOfFpGroup( F ) do
            new := MappedWord( rel, Fgens, Sgens );
            Add( trans, new[d+1]{[1..d]} );
        od;
    fi;

    # make translations invariant under point group
    trans := Set( Union( Orbits( P, trans ) ) );
    return ReducedLatticeBasis( trans );

end;

#############################################################################
##
#M  AddTranslationBasis( S, basis ) . . . . .add basis of translation lattice
##
InstallGlobalFunction( AddTranslationBasis, function ( S, basis )

    local T;

    if not IsAffineCrystGroupOnLeftOrRight( S ) then
        Error("S must be an AffineCrystGroup");
    fi;

    T := ReducedLatticeBasis( basis );

    if HasTranslationBasis( S ) then
        if T <> TranslationBasis( S ) then
            Error("adding incompatible translation basis attempted");
        fi;
    else
        SetTranslationBasis( S, T );
        if not IsStandardAffineCrystGroup( S ) then
            InternalBasis( S );  # computes S!.lconj, S!.rconj
        fi;
    fi;

end );

#############################################################################
##
#M  TranslationBasis( S ) . . . . . . . . . . . .basis of translation lattice
##
InstallMethod( TranslationBasis, true, [ IsAffineCrystGroupOnLeftOrRight ],0,
function( S )
    local T;
    if IsAffineCrystGroupOnRight( S ) then
        T := TranslationBasisFun( S );
    else
        T := TranslationBasis( TransposedMatrixGroup( S ) );
    fi;
    AddTranslationBasis( S, T );
    return T;
end );

#############################################################################
##
#M  CheckTranslationBasis( S ) . . . . . . check basis of translation lattice
##
InstallGlobalFunction( CheckTranslationBasis, function( S )
    local T;
    if IsAffineCrystGroupOnRight( S ) then
        T := TranslationBasisFun( S );
    else
        T := TranslationBasisFun( TransposedMatrixGroup( S ) );
    fi;
    if HasTranslationBasis( S ) then
        if T <> TranslationBasis( S ) then
            Print( "#W  Warning: translations are INCORRECT - you better\n", 
                   "#W           start again with a fresh group!\n" ); 
        fi;
    else
        AddTranslationBasis( S, T ); 
    fi;
end );

#############################################################################
##
#M  \^( S, conj )  . . . . . . . . . . . . . . . . . . . . . . . change basis
##
InstallOtherMethod( \^,
    IsCollsElms, [ IsAffineCrystGroupOnRight, IsMatrix ], 0,
function ( S, conj )

    local d, c, ci, C, Ci, gens, i, R, W, r, w;

    d := DimensionOfMatrixGroup( S ) - 1;
    if not IsAffineMatrixOnRight( conj ) then
        Error( "conj must represent an affine transformation" );
    fi;

    # get the conjugators;
    C  := conj;
    Ci := conj^-1;
    c  := C {[1..d]}{[1..d]};
    ci := Ci{[1..d]}{[1..d]};

    # conjugate the generators of S
    gens := ShallowCopy( GeneratorsOfGroup( S ) );
    for i in [1..Length(gens)] do
        gens[i] := Ci * gens[i] * C;
    od;
    R := AffineCrystGroupOnRight( gens, One( S ) );

    # add translations if known
    if HasTranslationBasis( S ) then
        AddTranslationBasis( R, TranslationBasis( S ) * c );
    fi;

    # add Wyckoff positions if known
    if HasWyckoffPositions( S ) then
        W := [];
        for w in WyckoffPositions( S ) do
            r := rec( basis       := w!.basis*c,
                      translation := w!.translation*c,
                      class       := w!.class,
                      spaceGroup  := R );
            ReduceAffineSubspaceLattice( r );
            Add( W, WyckoffPositionObject( r ) );
        od;
        SetWyckoffPositions( R, W );
    fi;

    return R;

end );
    
InstallOtherMethod( \^,
    IsCollsElms, [ IsAffineCrystGroupOnLeft, IsMatrix ], 0,
function ( S, conj )

    local d, c, ci, C, Ci, gens, i, R, W, r, w;

    d := DimensionOfMatrixGroup( S ) - 1;
    if not IsAffineMatrixOnLeft( conj ) then
        Error( "conj must represent an affine transformation" );
    fi;

    # get the conjugators;
    C  := conj;
    Ci := conj^-1;
    c  := C {[1..d]}{[1..d]};
    ci := Ci{[1..d]}{[1..d]};

    # conjugate the generators of S
    gens := ShallowCopy( GeneratorsOfGroup( S ) );
    for i in [1..Length(gens)] do
        gens[i] := C * gens[i] * Ci;
    od;
    R := AffineCrystGroupOnLeft( gens, One( S ) );

    # add translations if known
    if HasTranslationBasis( S ) then
        AddTranslationBasis( R, TranslationBasis( S ) * c );
    fi;

    # add Wyckoff positions if known
    if HasWyckoffPositions( S ) then
        W := [];
        for w in WyckoffPositions( S ) do
            r := rec( basis       := w!.basis*c,
                      translation := w!.translation*c,
                      class       := w!.class,
                      spaceGroup  := R );
            ReduceAffineSubspaceLattice( r );
            Add( W, WyckoffPositionObject( r ) );
        od;
        SetWyckoffPositions( R, W );
    fi;

    return R;

end );

#############################################################################
##
#M  StandardAffineCrystGroup( S ) . . . . . . . . . . change basis to std rep
##
InstallGlobalFunction( StandardAffineCrystGroup, function( S )

    local B, d, C;

    if IsAffineCrystGroupOnRight( S )  then
        B := InternalBasis( S );
    elif IsAffineCrystGroupOnLeft( S ) then
        B := TransposedMat( InternalBasis( S ) );
    else
        Error( "S must be an AffineCrystGroup" );
    fi;

    d := DimensionOfMatrixGroup( S ) - 1;
    C := IdentityMat( d+1 );
    C{[1..d]}{[1..d]} := B^-1;
    return S^C;

end );
    
#############################################################################
##
#M  Size( S ) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .Size
##
InstallMethod( Size, 
    "for AffineCrystGroup", 
    true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
function( S )
    if Length( TranslationBasis( S ) ) > 0 then
        return infinity;
    else
        return Size( PointGroup( S ) );
    fi;
end );

#############################################################################
##
#M  IsFinite( S ) . . . . . . . . . . . . . . . . . . . . . . . . . .IsFinite
##
InstallMethod( IsFinite, "for AffineCrystGroup", 
    true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
    S -> Length( TranslationBasis( S ) ) = 0 );

#############################################################################
##
#M  EnumeratorSorted( S ) . . . . . . . . . . EnumeratorSorted for CrystGroup
##
InstallMethod( EnumeratorSorted, 
    "for AffineCrystGroup", 
    true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
function( S )
    if not IsFinite( S ) then
        Error("S is infinite");
    else
        TryNextMethod();
    fi;
end );

#############################################################################
##
#M  Enumerator( S ) . . . . . . . . . . . . . . . . Enumerator for CrystGroup
##
InstallMethod( Enumerator,
    "for AffineCrystGroup", 
    true, [ IsAffineCrystGroupOnLeftOrRight ], 0, 
function( S )
    if not IsFinite( S ) then
        Error("S is infinite");
    else
        TryNextMethod();
    fi;
end );

#############################################################################
##
#M  TransParts( S )  reduced transl. parts of GeneratorsSmallest of point grp
##
InstallMethod( TransParts, true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
function( S )

    local T, P, d, gens;

    T := TranslationBasis( S );
    P := PointGroup( S );
    d := DimensionOfMatrixGroup( P );

    gens := GeneratorsSmallest( NiceObject( P ) );
    gens := List( gens, x -> ImagesRepresentative( NiceToCryst( P ), x ) );
    if IsAffineCrystGroupOnRight( S ) then
        gens := List( gens, x -> VectorModL( x[d+1]{[1..d]}, T ) );
    else
        gens := List( gens, x -> VectorModL( x{[1..d]}[d+1], T ) );
    fi;

    return gens;

end );

#############################################################################
##
#M  \<( S1, S2 ) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . \<
##
AffineCrystGroupLessFun := function( S1, S2 )

    local T1, T2, P1, P2;

    # first compare the translation lattices
    T1 := TranslationBasis( S1 );
    T2 := TranslationBasis( S2 );
    if not T1 = T2 then
        return T1 < T2;
    fi;

    # then the point groups
    P1 := PointGroup( S1 );
    P2 := PointGroup( S2 );
    if not P1 = P2 then
        return P1 < P2;
    fi;

    # finally the translation parts
    return TransParts( S1 ) < TransParts( S2 );

end;

InstallMethod( \<, "two AffineCrystGroupOnRight", IsIdenticalObj, 
    [ IsAffineCrystGroupOnRight, IsAffineCrystGroupOnRight ], 0,
    AffineCrystGroupLessFun 
);

InstallMethod( \<, "two AffineCrystGroupOnLeft", IsIdenticalObj, 
    [ IsAffineCrystGroupOnLeft, IsAffineCrystGroupOnLeft ], 0,
    AffineCrystGroupLessFun 
);

#############################################################################
##
#M  \in( m, S ) . . . . . . . . . . . . . . . .check membership in CrystGroup
##
InstallMethod( \in, "for CrystGroup", 
    IsElmsColls, [ IsMatrix, IsAffineCrystGroupOnLeftOrRight ], 0,
function( m, S )

    local d, P, mm, t;

    d  := DimensionOfMatrixGroup( S ) - 1;
    P  := PointGroup( S );
    mm := m{[1..d]}{[1..d]};
    if not mm in P then
        return false;
    fi;

    mm := PreImagesRepresentative( PointHomomorphism( S ), mm );
    if IsAffineCrystGroupOnRight( S ) then
        t  := m[d+1]{[1..d]} - mm[d+1]{[1..d]};
    else
        t  := m{[1..d]}[d+1] - mm{[1..d]}[d+1];
    fi;
    return 0*t = VectorModL( t, TranslationBasis( S ) );

end );

#############################################################################
##
#M  IsSpaceGroup( S ) . . . . . . . . . . . . . . . . . . is S a space group?
##
InstallMethod( IsSpaceGroup, true, [ IsCyclotomicMatrixGroup ], 0,
function( S )
    local d;
    if IsAffineCrystGroupOnLeftOrRight( S ) then
        d := DimensionOfMatrixGroup( S ) - 1;
        return d = Length( TranslationBasis( S ) );
    else
        return false;
    fi; 
end ); 

#############################################################################
##
#M  IsSymmorphicSpaceGroup( S ) . . . . . . . . . . . . . . .is S symmorphic? 
##
InstallMethod( IsSymmorphicSpaceGroup,
    "generic method", true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
    S -> CocVecs( S ) = [] );

#############################################################################
##
#M  IsStandardAffineCrystGroup( S ) . . . . . . . . .  is S in standard form?
##
InstallMethod( IsStandardAffineCrystGroup, 
    true, [ IsCyclotomicMatrixGroup ], 0,
function( S )
    local d, T;
    if IsAffineCrystGroupOnLeftOrRight( S ) then
        d := DimensionOfMatrixGroup( S ) - 1;
        return InternalBasis( S ) = IdentityMat( d );
    else
        return false;
    fi; 
end );

#############################################################################
##
#F  PointGroupHomomorphism( S ) . . . . . . . . . . . .PointGroupHomomorphism
##
PointGroupHomomorphism := function( S )

    local d, gen, im, I, Pgens, Sgens, i, P, nice, N, perms, lift, H;

    d   := DimensionOfMatrixGroup( S ) - 1;
    gen := GeneratorsOfGroup( S );
    im  := List( gen, m -> m{[1..d]}{[1..d]} );
    I   := IdentityMat( d );

    Pgens := [];
    Sgens := [];
    for i in [1..Length( im )] do
        if im[i] <> I and not im[i] in Pgens then
            Add( Pgens, im[i] );
            Add( Sgens, MutableMatrix( gen[i] ) );
        fi;
    od;

    P := GroupByGenerators( Pgens, I );
    SetIsPointGroup( P, true );
    SetAffineCrystGroupOfPointGroup( P, S );
    if not IsFinite( P ) then
        Error( "AffineCrystGroups must have a *finite* point group" );
    fi;

    nice  := NiceMonomorphism( P ); 
    N     := NiceObject( P );
    perms := List( Pgens, x -> ImagesRepresentative( nice, x ) );
    lift  := GroupHomomorphismByImagesNC( N, S, perms, Sgens );
    SetNiceToCryst( P, lift );

    H := GroupHomomorphismByImagesNC( S, P, gen, im );
    SetIsPointHomomorphism( H, true );

    return [ P, H ];

end;    

#############################################################################
##
#M  PointGroup( S ) . . . . . . . . . . . . PointGroup of an AffineCrystGroup
##
InstallMethod( PointGroup, true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
function( S )
    local res; 
    res := PointGroupHomomorphism( S );
    SetPointHomomorphism( S, res[2] );
    return res[1];
end );    

#############################################################################
##
#M  PointHomomorphism( S ) . . . . . PointHomomorphism of an AffineCrystGroup
##
InstallMethod( PointHomomorphism, true, [IsAffineCrystGroupOnLeftOrRight], 0,
function( S )
    local res; 
    res := PointGroupHomomorphism( S );
    SetPointGroup( S, res[1] );
    return res[2];
end );    

#############################################################################
##
#M  IsPointGroup( <P> ) . . . . . . . . .  PointGroup of an AffineCrystGroup?
##

# PointGroups always know that they are PointGroups
InstallMethod( IsPointGroup, 
    "fallback method", true, [ IsCyclotomicMatrixGroup ], 0, P -> false );

#############################################################################
##
#M  IsSubset( <G>, <U> ) . . . . . . . . . . . . . . .  for AffineCrystGroups 
##
InstallMethod( IsSubset, IsIdenticalObj,
    [ IsAffineCrystGroupOnRight, IsAffineCrystGroupOnLeft ], 0, ReturnFalse);
InstallMethod( IsSubset, IsIdenticalObj,
    [ IsAffineCrystGroupOnLeft, IsAffineCrystGroupOnRight ], 0, ReturnFalse);


#############################################################################
##
##  Identification and construction of affine crystallographic groups
##
#############################################################################

#############################################################################
##
#M  IsAffineCrystGroupOnRight( <S> )  . . . . AffineCrystGroup acting OnRight
##

# Subgroups of AffineCrystGroups are AffineCrystGroups
InstallSubsetMaintenance( IsAffineCrystGroupOnRight, 
                          IsAffineCrystGroupOnRight, IsCollection );

# AffineCrystGroups always know that they are AffineCrystGroups
InstallMethod( IsAffineCrystGroupOnRight, 
    "fallback method", true, [ IsCyclotomicMatrixGroup ], 0, S -> false );

#############################################################################
##
#M  IsAffineCrystGroupOnLeft( <S> ) . . . . .  AffineCrystGroup acting OnLeft
##

# Subgroups of AffineCrystGroups are AffineCrystGroups
InstallSubsetMaintenance( IsAffineCrystGroupOnLeft, 
                          IsAffineCrystGroupOnLeft, IsCollection );

# AffineCrystGroups always know that they are AffineCrystGroups
InstallMethod( IsAffineCrystGroupOnLeft, 
    "fallback method", true, [ IsCyclotomicMatrixGroup ], 0, S -> false );

#############################################################################
##
#M  IsAffineCrystGroup( <S> ) . . . . . . . . . . . . AffineCrystGroup acting
#M  . . . . . . . . . . . . . . . . . as specified by CrystGroupDefaultAction
##
InstallGlobalFunction( IsAffineCrystGroup, function( S )
    if   CrystGroupDefaultAction = RightAction then
        return IsAffineCrystGroupOnRight( S );
    elif CrystGroupDefaultAction = LeftAction  then
        return IsAffineCrystGroupOnLeft( S );
    else
        Error(" CrystGroupDefaultAction must be RightAction or LeftAction" );
    fi;
end );

#############################################################################
##
#M  AffineCrystGroupOnRight( <gens> ) . . . . . . . . . . . . . . . . . . . .
#M  AffineCrystGroupOnRight( <genlist> )  . . . . . . . . . . . . . . . . . .
#M  AffineCrystGroupOnRight( <genlist>, <identity> )  . . . . . . constructor
##
InstallGlobalFunction( AffineCrystGroupOnRight, function( arg )
    local G;
    G := CallFuncList( Group, arg );
    return AsAffineCrystGroupOnRight( G );
end );

InstallGlobalFunction( AffineCrystGroupOnRightNC, function( arg )
    local G;
    G := CallFuncList( Group, arg );
    SetIsAffineCrystGroupOnRight( G, true );
    return G;
end );

#############################################################################
##
#M  AffineCrystGroupOnLeft( <gens> )  . . . . . . . . . . . . . . . . . . . .
#M  AffineCrystGroupOnLeft( <genlist> ) . . . . . . . . . . . . . . . . . . .
#M  AffineCrystGroupOnLeft( <genlist>, <identity> ) . . . . . . . constructor
##
InstallGlobalFunction( AffineCrystGroupOnLeft, function( arg )
    local G;
    G := CallFuncList( Group, arg );
    return AsAffineCrystGroupOnLeft( G );
end );

InstallGlobalFunction( AffineCrystGroupOnLeftNC, function( arg )
    local G;
    G := CallFuncList( Group, arg );
    SetIsAffineCrystGroupOnLeft( G, true );
    return G;
end );

#############################################################################
##
#M  AffineCrystGroup( <gens> )  . . . . . . . . . . . . . . . . . . . . . . .
#M  AffineCrystGroup( <genlist> ) . . . . . . . . . . . . . . . . . . . . . .
#M  AffineCrystGroup( <genlist>, <identity> ) . . . . . . . . . . constructor
##
InstallGlobalFunction( AffineCrystGroup, function( arg )
    local G;
    G := CallFuncList( Group, arg );
    if CrystGroupDefaultAction = RightAction then
        return AsAffineCrystGroupOnRight( G );
    else
        return AsAffineCrystGroupOnLeft( G );
    fi;
end );

InstallGlobalFunction( AffineCrystGroupNC, function( arg )
    local G;
    G := CallFuncList( Group, arg );
    if CrystGroupDefaultAction = RightAction then
        SetIsAffineCrystGroupOnRight( G, true );
        return G;
    else
        SetIsAffineCrystGroupOnLeft( G, true );
        return G;
    fi;
end );

#############################################################################
##
#M  AsAffineCrystGroupOnRight( S ) . . . . . . . . . . . convert matrix group
##
InstallGlobalFunction( AsAffineCrystGroupOnRight, function( S )

    local ph;

    if HasIsAffineCrystGroupOnRight( S ) then
        if IsAffineCrystGroupOnRight( S ) then
            return S;
        else
            S := Group( GeneratorsOfGroup( S ), One( S ) );
        fi;
    fi;

    # an AffineCrystGroup cannot act both OnLeft and OnRight
    if IsAffineCrystGroupOnLeft( S ) then
        S := Group( GeneratorsOfGroup( S ), One( S ) );
    fi;

    # do a few basic checks
    if ForAny( GeneratorsOfGroup( S ), 
               x -> not IsAffineMatrixOnRight( x ) ) then
        Error("this group can not be made an AffineCrystGroupOnRight");
    fi;

    # check if PointGroup is finite
    ph := PointGroupHomomorphism( S );

    # if check did not fail, we can make S an AffineCrystGroupOnRight
    SetIsAffineCrystGroupOnRight( S, true );
    SetPointGroup( S, ph[1] );
    SetPointHomomorphism( S, ph[2] );

    return S;

end );

#############################################################################
##
#M  AsAffineCrystGroupOnLeft( S ) . . . . . . . . . . .  convert matrix group
##
InstallGlobalFunction( AsAffineCrystGroupOnLeft, function( S )

    local ph;

    if HasIsAffineCrystGroupOnLeft( S ) then
        if IsAffineCrystGroupOnLeft( S ) then
            return S;
        else
            S := Group( GeneratorsOfGroup( S ), One( S ) );
        fi;
    fi;

    # an AffineCrystGroup cannot act both OnLeft and OnRight
    if IsAffineCrystGroupOnRight( S ) then
        S := Group( GeneratorsOfGroup( S ), One( S ) );
    fi;

    # do a few basic checks
    if ForAny( GeneratorsOfGroup( S ), 
               x -> not IsAffineMatrixOnLeft( x ) ) then
        Error("this group can not be made an AffineCrystGroupOnLeft");
    fi;

    # check if PointGroup is finite
    ph := PointGroupHomomorphism( S );

    # if check did not fail, we can make S an AffineCrystGroupOnLeft
    SetIsAffineCrystGroupOnLeft( S, true );
    SetPointGroup( S, ph[1] );
    SetPointHomomorphism( S, ph[2] );

    return S;

end );

#############################################################################
##
#F  AsAffineCrystGroup( <S> ) . . . . . . . . . . . . .  convert matrix group
##
InstallGlobalFunction( AsAffineCrystGroup, function( S )
    if CrystGroupDefaultAction = RightAction then
        return AsAffineCrystGroupOnRight( S );
    else
        return AsAffineCrystGroupOnLeft( S );
    fi;
end );

#############################################################################
##
#M  CanEasilyTestMembership( <grp> )
##
InstallTrueMethod( CanEasilyTestMembership, IsAffineCrystGroupOnLeftOrRight);

#############################################################################
##
#M  CanComputeSize( <grp> )
##
InstallTrueMethod( CanComputeSize, IsAffineCrystGroupOnLeftOrRight );

#############################################################################
##
#M  CanComputeSizeAnySubgroup( <grp> )
##
InstallTrueMethod(CanComputeSizeAnySubgroup,IsAffineCrystGroupOnLeftOrRight);

#############################################################################
##
#M  CanComputeIndex( <G>, <H> )
##
InstallMethod( CanComputeIndex, IsIdenticalObj, 
    [IsAffineCrystGroupOnRight,IsAffineCrystGroupOnRight], 0, ReturnTrue );

InstallMethod( CanComputeIndex, IsIdenticalObj, 
    [IsAffineCrystGroupOnLeft,IsAffineCrystGroupOnLeft], 0, ReturnTrue );

#############################################################################
##
#M  CanComputeIsSubset( <G>, <H> )
##
InstallMethod( CanComputeIsSubset, IsIdenticalObj, 
    [IsAffineCrystGroupOnRight,IsAffineCrystGroupOnRight], 0, ReturnTrue );

InstallMethod( CanComputeIsSubset, IsIdenticalObj, 
    [IsAffineCrystGroupOnLeft,IsAffineCrystGroupOnLeft], 0, ReturnTrue );

#############################################################################
##
#M  HirschLength( <S> ) . . . . . . . . . . . . . . . . .Hirsch length of <S>
##
InstallMethod( HirschLength, 
    true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
function( S )
    return Length( TranslationBasis( S ) );
end );




