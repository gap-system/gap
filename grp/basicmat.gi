#############################################################################
##
#W  basicmat.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file  contains the methods for the  construction of the basic matrix
##  group types.
##
Revision.basicmat_gi :=
    "@(#)$Id$";


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
    local   o,  m,  i;

    o := One(fld);
    m := MutableNullMat( n, n, fld );
    for i  in [ 1 .. n-1 ]  do
        m[i][i+1] := o;
    od;
    m[n][1] := o;
    m := Group( Immutable(m) );
    SetSize( m, n );
    return m;
    
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

    m := MutableNullMat( n, n, Rationals );
    for i  in [ 1 .. n-1 ]  do
        m[i][i+1] := 1;
    od;
    m[n][1] := 1;
    m := Group( Immutable(m) );
    SetSize( m, n );
    return m;
    
end );


#############################################################################
##
#M  GeneralLinearGroupCons( <IsMatrixGroup>, <d>, <q> )
##
InstallMethod( GeneralLinearGroupCons,
    "matrix group for dimension and finite field size",
    true,
    [ IsMatrixGroup and IsFinite,
      IsInt and IsPosRat,
      IsInt and IsPosRat ],
    0,

function( filter, n, q )
    local   f,  z,  o,  mat1,  mat2,  i,  g;

    # small cases
    if q = 2 and 1 < n  then
        return SL( n, 2 );
    fi;

    # construct the generators
    f := GF( q );
    z := PrimitiveRoot( f );
    o := One( f );

    mat1 := MutableIdentityMat( n, o );
    mat1[1][1] := z;
    mat2 := List( Zero(o) * mat1, ShallowCopy );
    mat2[1][1] := -o;
    mat2[1][n] := o;
    for i  in [ 2 .. n ]  do mat2[i][i-1]:= -o;  od;

    g := GroupByGenerators( [ mat1, mat2 ] );
    SetName( g, Concatenation("GL(",String(n),",",String(q),")") );
    SetDimensionOfMatrixGroup( g, n );
    SetFieldOfMatrixGroup( g, f );
    SetIsGeneralLinearGroup( g, true );

    # Return the group.
    return g;
end );


#############################################################################
##
#M  SpecialLinearGroupCons( <IsMatrixGroup>, <d>, <q> )
##
InstallMethod( SpecialLinearGroupCons,
    "matrix group for dimension and finite field size",
    true,
    [ IsMatrixGroup and IsFinite,
      IsInt and IsPosRat,
      IsInt and IsPosRat ],
    0,

function( filter, n, q )
     local   f,  g,  o,  z,  mat1,  mat2,  i,  size,  qi;

     # construct the underlying field
     f := GF(q);

     # handle the trivial case first
     if n = 1 then
         g := GroupByGenerators( [ [ [ One(f) ] ] ] );

     # now the general case
     else

         # construct the generators
         o := One(f);
         z := PrimitiveRoot(f);
         mat1 := MutableIdentityMat( n, o );
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

         g := GroupByGenerators( [ mat1, mat2 ] );
     fi;

     # set name, dimension and field
     SetName( g, Concatenation("SL(",String(n),",",String(q),")") );
     SetDimensionOfMatrixGroup( g, n );
     SetFieldOfMatrixGroup( g, f );
     SetIsFinite( g, true );
     if q = 2  then
         SetIsGeneralLinearGroup( g, true );
     fi;

     # add the size
     size := 1;
     qi   := q;
     for i in [ 2 .. n ] do
       qi   := qi * q;
       size := size * (qi-1);
     od;
     SetSize( g, q^(n*(n-1)/2) * size );

     # return the group
     return g;
end );


#############################################################################
##

#E  basicmat.gd	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
