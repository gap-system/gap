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
#F  SL( <n>, <q> )  . . . . . . . . . . . . . . . . . .  special linear group
##
SL := function( n, q )
     local g, z, f, i, o, mat1, mat2, size, qi;

     f:= GF( q );

     # Handle the trivial case first.
     if n = 1 then
       g:= GroupByGenerators( [ [ [ One( f ) ] ] ] );
       SetName( g, Concatenation("SL(1,",String(q),")") );
       return g;
     fi;

     # Construct the generators.
     o:= One( f );
     z:= PrimitiveRoot( f );
     mat1:= List( IdentityMat( n, o ), ShallowCopy );
     mat2:= List( 0 * mat1, ShallowCopy );
     mat2[1][n]:= o;
     for i in [ 2 .. n ] do mat2[i][i-1]:= -o; od;

     if q = 2 or q = 3 then
       mat1[1][2]:= o;
     else
       mat1[1][1]:= z;
       mat1[2][2]:= z^-1;
       mat2[1][1]:= -o;
     fi;

     g:= GroupByGenerators( [ mat1, mat2 ] );
     SetName( g, Concatenation("SL(",String(n),",",String(q),")") );
     SetDimensionOfMatrixGroup( g, Length( mat1 ) );
     SetFieldOfMatrixGroup( g, f );
     if q = 2  then
         SetIsGeneralLinearGroup( g, true );
     fi;

     # Add the size.
     size := 1;
     qi   := q;
     for i in [ 2 .. n ] do
       qi   := qi * q;
       size := size * (qi-1);
     od;
     SetSize( g, q^(n*(n-1)/2) * size );

     # Return the group.
     return g;
end;

#############################################################################
##
#F  GL( <n>, <q> )  . . . . . . . . . . . . . . . . . .  general linear group
##
GL := function( n, q )
     local g, z, f, i, o, mat1, mat2, size, qi;

     if q = 2 and 1 < n  then
       return SL( n, 2 );
     fi;

     # Construct the generators.
     f:= GF( q );
     z:= PrimitiveRoot( f );
     o:= One( f );

     mat1:= List( IdentityMat( n, o ), ShallowCopy );
     mat1[1][1]:= z;
     mat2:= List( 0 * mat1, ShallowCopy );
     mat2[1][1]:= -o;
     mat2[1][n]:= o;
     for i in [ 2 .. n ] do mat2[i][i-1]:= -o; od;

     g := GroupByGenerators( [ mat1, mat2 ] );
     SetName( g, Concatenation("GL(",String(n),",",String(q),")") );
     SetDimensionOfMatrixGroup( g, Length( mat1 ) );
     SetFieldOfMatrixGroup( g, f );
     SetIsGeneralLinearGroup( g, true );

     # Add the size.
     size := q-1;
     qi   := q;
     for i in [ 2 .. n ] do
       qi   := qi * q;
       size := size * (qi-1);
     od;
     SetSize( g, q^(n*(n-1)/2) * size );

     # Return the group.
     return g;
end;

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
InstallMethod( NiceMonomorphism,
    "orbit on vectors",
    true,
    [ IsFFEMatrixGroup and IsGeneralLinearGroup ],
    0,

function( grp )
    local   field,  dim,  xset,  nice;

    # construct
    field  := FieldOfMatrixGroup(grp);
    dim    := DimensionOfMatrixGroup(grp);
    xset   := ExternalSubset( grp, field^dim, One(grp) );
    SetBase( xset, One(grp) );

    nice := OperationHomomorphism(xset);
    SetIsInjective( nice, true );
    return nice;

end );

InstallMethod( NiceMonomorphism,
    "falling back on GL",
    true,
    [ IsFFEMatrixGroup ],
    0,

function( grp )
    return NiceMonomorphism( GL( DimensionOfMatrixGroup( grp ),
                   Size( FieldOfMatrixGroup( grp ) ) ) );
end );

#############################################################################
##

#E  grpffmat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
