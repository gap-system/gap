#############################################################################
##
#W  basicmat.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id: basicmat.gi,v 4.16 2010/02/23 15:12:39 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This file  contains the methods for the  construction of the basic matrix
##  group types.
##
Revision.basicmat_gi :=
    "@(#)$Id: basicmat.gi,v 4.16 2010/02/23 15:12:39 gap Exp $";


#############################################################################
##
#M  CyclicGroupCons( <IsMatrixGroup>, <field>, <n> )
##
InstallOtherMethod( CyclicGroupCons,
    "matrix group for given field",
    true,
    [ IsMatrixGroup and IsFinite,
      IsField,
      IsInt and IsPosRat ],
    0,

function( filter, fld, n )
    local   o,  m,  i, g;

    o := One(fld);
    m := NullMat( n, n, fld );
    for i  in [ 1 .. n-1 ]  do
        m[i][i+1] := o;
    od;
    m[n][1] := o;
    m :=  [ ImmutableMatrix(fld,m,true) ];
    g := GroupByGenerators( m );
    SetIsCyclic (g, true);
    SetMinimalGeneratingSet (g, m);
    SetSize( g, n );
    return g;
    
end );


#############################################################################
##
#M  CyclicGroupCons( <IsMatrixGroup>, <n> )
##
InstallMethod( CyclicGroupCons,
    "matrix group for default field",
    true,
    [ IsMatrixGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, n )
    local   m,  i;

    m := NullMat( n, n, Rationals );
    for i  in [ 1 .. n-1 ]  do
        m[i][i+1] := 1;
    od;
    m[n][1] := 1;
    m := GroupByGenerators( [ ImmutableMatrix(Rationals,m,true) ] );
    SetSize( m, n );
    return m;
    
end );


#############################################################################
##
#M  GeneralLinearGroupCons( <IsMatrixGroup>, <d>, <F> )
##
InstallMethod( GeneralLinearGroupCons,
    "matrix group for dimension and finite field size",
    [ IsMatrixGroup and IsFinite,
      IsInt and IsPosRat,
      IsField and IsFinite ],
function( filter, n, f )
    local   q,  z,  o,  mat1,  mat2,  i,  g;

    q:= Size( f );

    # small cases
    if q = 2 and 1 < n  then
        return SL( n, 2 );
    fi;

    # construct the generators
    z := PrimitiveRoot( f );
    o := One( f );

    mat1 := IdentityMat( n, f );
    mat1[1][1] := z;
    mat2 := List( Zero(o) * mat1, ShallowCopy );
    mat2[1][1] := -o;
    mat2[1][n] := o;
    for i  in [ 2 .. n ]  do mat2[i][i-1]:= -o;  od;

    mat1 := ImmutableMatrix( f, mat1,true );
    mat2 := ImmutableMatrix( f, mat2,true );

    g := GroupByGenerators( [ mat1, mat2 ] );
    SetName( g, Concatenation("GL(",String(n),",",String(q),")") );
    SetDimensionOfMatrixGroup( g, n );
    SetFieldOfMatrixGroup( g, f );
    SetIsNaturalGL( g, true );
    SetIsFinite(g,true);

    if n<50 or n+q<500 then
      Size(g);
    fi;

    # Return the group.
    return g;
end );

#############################################################################
##
#M  SpecialLinearGroupCons( <IsMatrixGroup>, <d>, <q> )
##
InstallMethod( SpecialLinearGroupCons,
    "matrix group for dimension and finite field size",
    [ IsMatrixGroup and IsFinite,
      IsInt and IsPosRat,
      IsField and IsFinite ],

function( filter, n, f )
    local   q,  g,  o,  z,  mat1,  mat2,  i,  size,  qi;

    q:= Size( f );

    # handle the trivial case first
    if n = 1 then
        g := GroupByGenerators( [ ImmutableMatrix( f, [[One(f)]],true ) ] );

    # now the general case
    else

        # construct the generators
        o := One(f);
        z := PrimitiveRoot(f);
        mat1 := IdentityMat( n, f );
        mat2 := List( Zero(o) * mat1, ShallowCopy );
        mat2[1][n] := o;
        for i  in [ 2 .. n ]  do mat2[i][i-1]:= -o;  od;

        if q = 2 or q = 3 then
            mat1[1][2] := o;
        else
            mat1[1][1] := z;
            mat1[2][2] := z^-1;
            mat2[1][1] := -o;
        fi;
        mat1 := ImmutableMatrix(f,mat1,true);
        mat2 := ImmutableMatrix(f,mat2,true);

        g := GroupByGenerators( [ mat1, mat2 ] );
    fi;

    # set name, dimension and field
    SetName( g, Concatenation("SL(",String(n),",",String(q),")") );
    SetDimensionOfMatrixGroup( g, n );
    SetFieldOfMatrixGroup( g, f );
    SetIsFinite( g, true );
    if q = 2  then
        SetIsNaturalGL( g, true );
    fi;
    SetIsNaturalSL( g, true );
    SetIsFinite(g,true);

    # add the size
    if n<50 or n+q<500 then
      Size(g);
    fi;

    # return the group
    return g;
end );


#############################################################################
##
#M  GeneralSemilinearGroupCons( IsMatrixGroup, <d>, <q> )
##
InstallMethod( GeneralSemilinearGroupCons,
    "matrix group for dimension and finite field size",
    [ IsMatrixGroup and IsFinite, IsInt and IsPosRat, IsInt and IsPosRat ],
    function( filter, d, q )
    local p, f, field, B, gl, gens, frobact, frobmat, i, g;

    p:= Factors( Integers, q );
    f:= Length( p );
    if f = 1 then
      return GL( d, q );
    fi;
    p:= p[1];

    field:= GF(q);
    B:= Basis( field );
    gl:= GL( d, q );
    gens:= List( GeneratorsOfGroup( gl ), x -> BlownUpMat( B, x ) );

    frobact:= List( BasisVectors( B ), x -> Coefficients( B, x^p ) );
    frobmat:= NullMat( d*f, d*f, GF(p) );
    for i in [ 1 .. d ] do
      frobmat{ [ (i-1)*f+1 .. i*f ] }{ [ (i-1)*f+1 .. i*f ] }:= frobact;
    od;
    Add( gens, frobmat );

    g:= GroupWithGenerators( gens );
    SetName( g, Concatenation( "GammaL(",String(d),",",String(q),")" ) );
    SetDimensionOfMatrixGroup( g, d*f );
    SetFieldOfMatrixGroup( g, GF(p) );
    SetIsFinite( g, true );

    SetSize( g, f * Size( gl ) );

    return g;
    end );


#############################################################################
##
#M  SpecialSemilinearGroupCons( IsMatrixGroup, <d>, <q> )
##
InstallMethod( SpecialSemilinearGroupCons,
    "matrix group for dimension and finite field size",
    [ IsMatrixGroup and IsFinite, IsInt and IsPosRat, IsInt and IsPosRat ],
    function( filter, d, q )
    local p, f, field, B, sl, gens, frobact, frobmat, i, g;

    p:= Factors( Integers, q );
    f:= Length( p );
    if f = 1 then
      return SL( d, q );
    fi;
    p:= p[1];

    field:= GF(q);
    B:= Basis( field );
    sl:= SL( d, q );
    gens:= List( GeneratorsOfGroup( sl ), x -> BlownUpMat( B, x ) );

    frobact:= List( BasisVectors( B ), x -> Coefficients( B, x^p ) );
    frobmat:= NullMat( d*f, d*f, GF(p) );
    for i in [ 1 .. d ] do
      frobmat{ [ (i-1)*f+1 .. i*f ] }{ [ (i-1)*f+1 .. i*f ] }:= frobact;
    od;
    Add( gens, frobmat );

    g:= GroupWithGenerators( gens );
    SetName( g, Concatenation( "SigmaL(",String(d),",",String(q),")" ) );
    SetDimensionOfMatrixGroup( g, d*f );
    SetFieldOfMatrixGroup( g, GF(p) );
    SetIsFinite( g, true );

    SetSize( g, f * Size( sl ) );

    return g;
    end );


#############################################################################
##
#M  GeneralSemilinearGroupCons( IsPermGroup, <d>, <q> )
#M  SpecialSemilinearGroupCons( IsPermGroup, <d>, <q> )
##
PermConstructor( GeneralSemilinearGroupCons,
    [ IsPermGroup, IsPosInt, IsPosInt ],
    IsMatrixGroup and IsFinite );

PermConstructor( SpecialSemilinearGroupCons,
    [ IsPermGroup, IsPosInt, IsPosInt ],
    IsMatrixGroup and IsFinite );


#############################################################################
##
#E

