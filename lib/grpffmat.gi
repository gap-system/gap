#############################################################################
##
#W  grpffmat.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for matrix groups over finite field.
##
Revision.grpffmat_gi :=
    "@(#)$Id$";


#############################################################################
##

#R  IsGeneralLinearGroupWithFormRep . . . isometry group of non-singular form
##
IsGeneralLinearGroupWithFormRep := NewRepresentation
    ( "IsGeneralLinearGroupWithFormRep", IsMatrixGroup, [ "form" ] );

IsGeneralUnitaryGroupWithFormRep := NewRepresentation
    ( "IsGeneralLinearGroupWithFormRep", IsMatrixGroup, [ "form" ] );

#############################################################################
##
#M  <mat> in <G>  . . . . . . . . . . . . . . . . . . . .  is form invariant?
##
InstallMethod( \in, IsElmsColls,
        [ IsMatrix, IsGeneralLinearGroupWithFormRep ], 0,
    function( mat, G )
    return mat * G!.form * TransposedMat( mat ) = G!.form;
end );

InstallMethod( \in, IsElmsColls,
        [ IsMatrix, IsGeneralUnitaryGroupWithFormRep ], 0,
    function( mat, G )
    local   f;
    
    f := FrobeniusAutomorphism( FieldOfMatrixGroup( G ) );
    return mat * G!.form * List( TransposedMat( mat ),
                   row -> OnTuples( row, f ) ) = G!.form;
end );

#############################################################################
##
#M  FieldOfMatrixGroup( <ffe-mat-grp> )
##
InstallMethod( FieldOfMatrixGroup,
    true,
    [ IsFFEMatrixGroup ],
    0,

function( grp )
    local   gens,  deg,  i,  j,  char;

    gens := GeneratorsOfGroup(grp);
    deg  := 1;
    for i  in gens  do
        for j  in i  do
            deg := LcmInt( deg, DegreeFFE(j) );
        od;
    od;
    if 0 < Length(gens)  then
        char := Characteristic(gens[1][1]);
    else
        char := Characteristic(One(grp)[1]);
    fi;
    return GF(char^deg);
end );

#############################################################################
##
#M  IsGeneralLinearGroup( <ffe-mat-grp> )
##
InstallMethod( IsGeneralLinearGroup,
    "size comparison",
    true,
    [ IsFFEMatrixGroup ],
    0,

function( grp )
    return Size( grp ) = Size( GL( DimensionOfMatrixGroup( grp ),
                   Size( FieldOfMatrixGroup( grp ) ) ) );
end );


#############################################################################
##
#M  NiceMonomorphism( <ffe-mat-grp> )
##
NicomorphismOfFFEMatrixGroup := function( grp )
    local   field,  dim,  V,  xset,  nice;
    
    Size( grp );
    field := FieldOfMatrixGroup( grp );
    dim   := DimensionOfMatrixGroup( grp );
    V     := field ^ dim;
    if    HasIsGeneralLinearGroup( grp )  and  IsGeneralLinearGroup( grp )
       or IsGeneralLinearGroupWithFormRep( grp )
       or IsGeneralUnitaryGroupWithFormRep( grp )  then
        xset := ExternalSet( grp, V );
    else
        xset := ExternalSubset( grp, V, One( grp ) );
    fi;
    SetBase( xset, One( grp ) );
    nice := OperationHomomorphism( xset );
    SetIsInjective( nice, true );
    return nice;
end;

InstallMethod( NiceMonomorphism,
    "falling back on GL",
    true,
    [ IsFFEMatrixGroup ],
    0,

function( grp )
    return NicomorphismOfFFEMatrixGroup( GL( DimensionOfMatrixGroup( grp ),
                   Size( FieldOfMatrixGroup( Parent(grp) ) ) ) );
end );

InstallMethod( IsomorphismPermGroup, "return Niceomorphism",true,
  [IsFFEMatrixGroup],0,NiceMonomorphism);

#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) . . . .  via nicomorphism
##
InstallMethod( NaturalHomomorphismByNormalSubgroup, IsIdentical,
        [ IsFFEMatrixGroup, IsFFEMatrixGroup ], 0,
    function( G, N )
    local   nice;
    
    nice := NicomorphismOfFFEMatrixGroup( G );
    G := ImagesSource( nice );
    N := ImagesSet   ( nice, N );
    return CompositionMapping( NaturalHomomorphismByNormalSubgroup( G, N ),
                   nice );
end );

#############################################################################
##

#M  Size( <general-linear-group> )
##
InstallMethod( Size,
    "general linear group",
    true,
    [ IsFFEMatrixGroup and IsGeneralLinearGroup ],
    0,

function( G )
    local   n,  q,  size,  qi,  i;
    
    n := DimensionOfMatrixGroup(G);
    q := Size( FieldOfMatrixGroup(G) );
    size := q-1;
    qi   := q;
    for i  in [ 2 .. n ]  do
        qi   := qi * q;
        size := size * (qi-1);
    od;
    return q^(n*(n-1)/2) * size;
end );

InstallMethod( \in, "general linear group", IsElmsColls,
        [ IsMatrix, IsFFEMatrixGroup and IsGeneralLinearGroup ], 0,
    function( mat, G )
    return     Length( mat ) = Length( mat[ 1 ] )
           and Length( mat ) = DimensionOfMatrixGroup( G )
           and ForAll( mat, row -> IsSubset( FieldOfMatrixGroup( G ), row ) )
           and Length( mat ) = RankMat( mat );
end );
        
#############################################################################
##

#E  grpffmat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
