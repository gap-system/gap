#############################################################################
##
#W  vecmat.gi                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains  the basic methods for  creating and doing  arithmetic
##  with vectors and matrices.
##
Revision.vecmat_gi :=
    "@(#)$Id$";


#############################################################################
##

#V  TYPE_LIST_GF2VEC  . . . . . . . . . . . . . . type of mutable GF2 vectors
##
InstallValue( TYPE_LIST_GF2VEC,
  NewType( CollectionsFamily( FFEFamily(2) ),
           IsHomogeneousList
           and IsMutable and IsCopyable and IsGF2VectorRep )
);


#############################################################################
##
#V  TYPE_LIST_GF2VEC_IMM  . . . . . . . . . . . type of immutable GF2 vectors
##
InstallValue( TYPE_LIST_GF2VEC_IMM,
  NewType( CollectionsFamily( FFEFamily(2) ),
           IsHomogeneousList and IsCopyable and IsGF2VectorRep )
);


#############################################################################
##
#V  TYPE_LIST_GF2MAT  . . . . . . . . . . . . .  type of mutable GF2 matrices
##
InstallValue( TYPE_LIST_GF2MAT,
  NewType( CollectionsFamily(CollectionsFamily(FFEFamily(2))),
           IsMatrix and IsMutable and IsCopyable and IsGF2MatrixRep )
);


#############################################################################
##
#V  TYPE_LIST_GF2MAT_IMM  . . . . . . . . . .  type of immutable GF2 matrices
##
InstallValue( TYPE_LIST_GF2MAT_IMM,
  NewType( CollectionsFamily(CollectionsFamily(FFEFamily(2))),
           IsMatrix and IsCopyable and IsGF2MatrixRep )
);


#############################################################################
##

#M  Length( <gf2vec> )  . . . . . . . . . . . . . . .  length of a GF2 vector
##
InstallMethod( Length,
    "for GF2 vector",
    true,
    [ IsList and IsGF2VectorRep ],
    0,
    LEN_GF2VEC );


#############################################################################
##
#M  ELM0_LIST( <gf2vec>, <pos> )  . . . . select an element from a GF2 vector
##
InstallMethod( ELM0_LIST,
    "for GF2 vector",
    true,
    [ IsList and IsGF2VectorRep,
      IsPosInt ],
    0,
    ELM0_GF2VEC );


#############################################################################
##
#M  ELM_LIST( <gf2vec>, <pos> ) . . . . . select an element from a GF2 vector
##
InstallMethod( ELM_LIST,
    "for GF2 vector",
    true,
    [ IsList and IsGF2VectorRep,
      IsPosInt ],
    0,
    ELM_GF2VEC );


#############################################################################
##
#M  ELMS_LIST( <gf2vec>, <poss> ) . . . . . select elements from a GF2 vector
##
InstallMethod( ELMS_LIST,
    "for GF2 vector",
    true,
    [ IsList and IsGF2VectorRep,
      IsList and IsDenseList and IsInternalRep ],
    0,
    ELMS_GF2VEC );


#############################################################################
##
#M  ASS_LIST( <gf2vec>, <pos>, <elm> )  . . assign an element to a GF2 vector
##
InstallMethod( ASS_LIST,
    "for GF2 vector",
    true,
    [ IsList and IsGF2VectorRep and IsMutable,
      IsPosInt,
      IsObject ],
    0,
    ASS_GF2VEC );

InstallOtherMethod( ASS_LIST,
    "for GF2 vector",
    true,
    [ IsList and IsGF2VectorRep,
      IsPosInt,
      IsObject ],
    0,
    ASS_GF2VEC );


#############################################################################
##
#M  ASS_LIST( <empty-list>, <pos>, <ffe> )  . . . . .  start a new GF2 vector
##
InstallMethod( ASS_LIST,
    "for empty plain list and finite field element",
    true,
    [ IsMutable and IsList and IsPlistRep and IsEmpty,
      IsPosInt,
      IsFFE ],
    0,

function( list, pos, val )
    if pos = 1 and ( val = GF2Zero or val = GF2One )  then
        CONV_GF2VEC(list);
        ASS_GF2VEC( list, pos, val );
    else
        ASS_PLIST_DEFAULT( list, pos, val );
    fi;
end );


#############################################################################
##
#M  UNB_LIST( <gf2vec>, <pos> ) . . . . . . unbind a position of a GF2 vector
##
InstallMethod( UNB_LIST,
    "for GF2 vector",
    true,
    [ IsList and IsGF2VectorRep and IsMutable,
      IsPosInt ],
    0,
    UNB_GF2VEC );

InstallOtherMethod( UNB_LIST,
    "for GF2 vector",
    true,
    [ IsList and IsGF2VectorRep,
      IsPosInt ],
    0,
    UNB_GF2VEC );


#############################################################################
##
#M  PrintObj( <gf2vec> )  . . . . . . . . . . . . . . . .  print a GF2 vector
##
InstallMethod( PrintObj,
    "for GF2 vector",
    true,
    [ IsGF2VectorRep ],
    0,

function( vec )
    local   i;

    Print( "[ " );
    for i  in [ 1 .. Length(vec) ]  do
        if 1 < i  then Print( ", " );  fi;
        Print( vec[i] );
    od;
    Print( " ]" );
end );


#############################################################################
##
#M  ViewObj( <gf2vec> ) . . . . . . . . . . . . . . . . . . view a GF2 vector
##
InstallMethod( ViewObj,
    "for GF2 vector",
    true,
    [ IsRowVector and IsFinite and IsGF2VectorRep ],
    0,

function( vec )
    if IsMutable(vec)  then
        Print( "<a GF2 vector of length ", Length(vec), ">" );
    else
        Print( "<an immutable GF2 vector of length ", Length(vec), ">" );
    fi;
end );


#############################################################################
##
#M  AdditiveInverse( <gf2vec> )	. . . . . .  additive inverse of a GF2 vector
##
InstallMethod( AdditiveInverse,
    "for GF2 vector",
    true,
    [ IsRowVector and IsGF2VectorRep ],
    0,
    ImmutableGF2VectorRep );


#############################################################################
##
#M  Zero( <gf2vec> )  . . . . . . . . . . . . . . . . . . . . zero GF2 vector
##
InstallMethod( Zero,
    "for GF2 vector",
    true,
    [ IsRowVector and IsGF2VectorRep ],
    0,
    ZERO_GF2VEC );


#############################################################################
##
#M  \=( <gf2vec>, <gf2vec> )  . . . . . . . . . . . . equality of GF2 vectors
##
InstallMethod( \=,
    "for GF2 vectors",
    IsIdenticalObj,
    [ IsRowVector and IsGF2VectorRep,
      IsRowVector and IsGF2VectorRep ],
    0,
    EQ_GF2VEC_GF2VEC );


#############################################################################
##
#M  \+( <gf2vec>, <gf2vec> )  . . . . . . . . . . . .  sum of two GF2 vectors
##
InstallMethod( \+,
    "for GF2 vectors",
    IsIdenticalObj,
    [ IsRowVector and IsGF2VectorRep,
      IsRowVector and IsGF2VectorRep ],
    0,
    SUM_GF2VEC_GF2VEC );


#############################################################################
##
#M  \-( <gf2vec>, <gf2vec> )  . . . . . . . . . difference of two GF2 vectors
##
InstallMethod( \-,
    "for GF2 vectors",
    IsIdenticalObj,
    [ IsRowVector and IsGF2VectorRep,
      IsRowVector and IsGF2VectorRep ],
    0,
    # we are in GF(2)
    SUM_GF2VEC_GF2VEC );


#############################################################################
##
#M  \*( <gf2vec>, <gf2vec> )  . . . . . . . . . .  product of two GF2 vectors
##
InstallMethod( \*,
    "for GF2 vectors",
    IsIdenticalObj,
    [ IsRingElementList and IsRowVector and IsGF2VectorRep,
      IsRingElementList and IsRowVector and IsGF2VectorRep ],
    0,
    PROD_GF2VEC_GF2VEC );


#############################################################################
##
#M  \*( <ffe>, <gf2vec> ) . . . . . . . . . . . product of FFE and GF2 vector
##
InstallMethod( \*,
    "for FFE and GF2 vector",
    IsElmsColls,
    [ IsFFE,
      IsRingElementList and IsRowVector and IsGF2VectorRep ],
    0,

function( a, b )
    if a = GF2Zero  then
        return Zero(b);
    elif a = GF2One  then
        return Immutable(b);
    else
        TryNextMethod();
    fi;
end );


#############################################################################
##
#M  \*( <gf2vec>, <ffe> ) . . . . . . . . . . . product of GF2 vector and FFE
##
InstallMethod( \*,
    "for GF2 vector and FFE",
    IsCollsElms,
    [ IsRingElementList and IsRowVector and IsGF2VectorRep,
      IsFFE ],
    0,

function( a, b )
    if b = GF2Zero  then
        return Zero(a);
    elif b = GF2One  then
        return Immutable(a);
    else
        TryNextMethod();
    fi;
end );


#############################################################################
##
#M  AddCoeffs( <gf2vec>, <gf2vec>, <mul> )  . . . . . . . .  add coefficients
##
InstallOtherMethod( AddCoeffs,
    "for GF2 vectors and FFE",
    function(a,b,c) return IsIdenticalObj(a,b); end,
    [ IsRowVector and IsGF2VectorRep and IsMutable,
      IsRowVector and IsGF2VectorRep,
      IsFFE ],
    0,
    ADDCOEFFS_GF2VEC_GF2VEC_MULT );


#############################################################################
##
#M  AddCoeffs( <gf2vec>, <gf2vec> ) . . . . . . . . . . . .  add coefficients
##
InstallOtherMethod( AddCoeffs,
    "for GF2 vectors",
    IsIdenticalObj,
    [ IsRowVector and IsGF2VectorRep and IsMutable,
      IsRowVector and IsGF2VectorRep ],
    0,
    ADDCOEFFS_GF2VEC_GF2VEC );


#############################################################################
##
#M  AddCoeffs( <empty-list>, <gf2vec>, <mul> )  . . . . . .  add coefficients
##
InstallOtherMethod( AddCoeffs,
    "for empty list, GF2 vector and FFE",
    true,
    [ IsList and IsEmpty and IsMutable,
      IsRowVector and IsGF2VectorRep,
      IsFFE ],
    0,

function( a, b, c )
    CONV_GF2VEC(a);
    return ADDCOEFFS_GF2VEC_GF2VEC_MULT( a, b, c );
end );



#############################################################################
##
#M  AddCoeffs( <empty-list>, <gf2vec> ) . . . . . . . . . .  add coefficients
##
InstallOtherMethod( AddCoeffs,
    "for empty list, GF2 vector",
    true,
    [ IsList and IsEmpty and IsMutable,
      IsRowVector and IsGF2VectorRep ],
    0,

function( a, b )
    CONV_GF2VEC(a);
    return ADDCOEFFS_GF2VEC_GF2VEC(a,b);
end );


#############################################################################
##
#M  ShrinkCoeffs( <gf2vec> )  . . . . . . . . . . . . . . shrink a GF2 vector
##
InstallMethod( ShrinkCoeffs,
    "for GF2 vector",
    true,
    [ IsRowVector and IsGF2VectorRep ],
    0,
    SHRINKCOEFFS_GF2VEC );


#############################################################################
##

#M  Length( <list> )  . . . . . . . . . . . . . . . .  length of a GF2 matrix
##
InstallMethod( Length,
    "for GF2 matrix",
    true,
    [ IsMatrix and IsGF2MatrixRep ],
    0,

function( list )
    return list![1];
end );


#############################################################################
##
#M  ELM_LIST( <list>, <pos> ) . . . . . . . select an element of a GF2 matrix
##
InstallMethod( ELM_LIST,
    "for GF2 matrix",
    true,
    [ IsMatrix and IsGF2MatrixRep,
      IsPosInt ],
    0,

function( list, pos )
    return list![pos+1];
end );


#############################################################################
##
#M  SET_ELM_GF2MAT( <list>, <pos>, <obj> )  . . . set element of a GF2 matrix
##
SET_ELM_GF2MAT := function( list, pos, obj )
    list![pos+1] := obj;
end;


#############################################################################
##
#M  ASS_LIST( <gf2mat>, <pos>, <elm> )  . . assign an element to a GF2 matrix
##
InstallMethod( ASS_LIST,
    "for GF2 matrix",
    true,
    [ IsList and IsGF2MatrixRep and IsMutable,
      IsPosInt,
      IsObject ],
    0,
    ASS_GF2MAT );

InstallOtherMethod( ASS_LIST,
    "for GF2 matrix",
    true,
    [ IsList and IsGF2MatrixRep,
      IsPosInt,
      IsObject ],
    0,
    ASS_GF2MAT );


#############################################################################
##
#M  ASS_LIST( <empty-list>, <pos>, <gf2vec> ) . . . .  start a new GF2 matrix
##
InstallMethod( ASS_LIST,
    "for empty plain list and GF2 vector",
    true,
    [ IsMutable and IsList and IsPlistRep and IsEmpty,
      IsPosInt,
      IsGF2VectorRep ],
    0,

function( list, pos, val )
    if pos = 1 and not IsMutable(val) then
        Objectify( TYPE_LIST_GF2MAT, list );
        SET_LEN_GF2MAT( list, 1 );
        SET_ELM_GF2MAT( list, 1, val );
    else
        ASS_PLIST_DEFAULT( list, pos, val );
    fi;
end );

#############################################################################
##
#M  UNB_LIST( <gf2vec>, <pos> ) . . . . . . unbind a position of a GF2 matrix
##
InstallMethod( UNB_LIST,
    "for GF2 matrix",
    true,
    [ IsList and IsGF2MatrixRep and IsMutable,
      IsPosInt ],
    0,
    UNB_GF2VEC );

InstallOtherMethod( UNB_LIST,
    "for GF2 matrix",
    true,
    [ IsList and IsGF2MatrixRep,
      IsPosInt ],
    0,
    UNB_GF2VEC );


#############################################################################
##
#M  PrintObj( <gf2mat> )  . . . . . . . . . . . . . . . .  print a GF2 matrix
##
InstallMethod( PrintObj,
    "for GF2 matrix",
    true,
    [ IsGF2MatrixRep ],
    0,

function( mat )
    local   i, j;

    Print( "[ " );
    for i  in [ 1 .. Length(mat) ]  do
        if 1 < i  then Print( ", " );  fi;
        Print( "[ " );
        for j  in [ 1 .. Length(mat[i]) ]  do
            if 1 < j  then Print( ", " );  fi;
            Print( mat[i][j] );
        od;
        Print( " ]" );
    od;
    Print( " ]" );
end );


#############################################################################
##
#M  ViewObj( <gf2mat> )   . . . . . . . . . . . . . . . .   view a GF2 matrix
##
InstallMethod( ViewObj,
    "for GF2 matrix",
    true,
    [ IsMatrix and IsFinite and IsGF2MatrixRep ],
    0,

function( mat )
    if Length(mat) = 0  then
        if IsMutable(mat)  then
            Print( "<a 0x0 matrix over GF2>" );
        else
            Print( "<an immutable 0x0 matrix over GF2>" );
        fi;
    else
        if IsMutable(mat)  then
            Print("<a ",Length(mat),"x",Length(mat[1])," matrix over GF2>");
        else
            Print( "<an immutable ", Length(mat), "x", Length(mat[1]),
                   " matrix over GF2>" );
        fi;
    fi;
end );

#############################################################################
##
#M  ShallowCopy( <gf2mat> ) . . . . . .  mutable shallow copy of a GF2 matrix
##
InstallMethod( ShallowCopy,
    "for GF2 matrix",
    true,
    [ IsMatrix and IsGF2MatrixRep ],
    0,

function(mat)
    local   copy,  i;

    copy := [ Length(mat) ];
    for i  in mat  do
        Add( copy, i );
    od;
    Objectify( TYPE_LIST_GF2MAT, copy );
    return copy;
end );


#############################################################################
##
#M  AdditiveInverse( <gf2mat> ) . . . . . .  additive inverse of a GF2 matrix
##
InstallMethod( AdditiveInverse,
    "for GF2 matrix",
    true,
    [ IsMatrix and IsGF2MatrixRep ],
    0,
    # we are in GF2
    Immutable );


#############################################################################
##
#M  Inverse( <gf2mat> ) . . . . . . . . . . . . . . . inverse of a GF2 matrix
##
InstallMethod( Inverse,
    "for GF2 matrix",
    true,
    [ IsMultiplicativeElementWithInverse and IsMatrix and IsGF2MatrixRep ],
    0,
    INV_GF2MAT );


#############################################################################
##
#M  One( <gf2mat> ) . . . . . . . . . . . . . . . . . . . identity GF2 matrix
##
InstallMethod( One,
    "for GF2 Matrix",
    true,
    [ IsOrdinaryMatrix and IsGF2MatrixRep and IsMultiplicativeElementWithOne],
    0,

function( mat )
    local   new,  zero,  i,  line;

    new := [ Length(mat) ];
    if 0 < new[1]   then
        zero := Zero(mat[1]);
        for i in [ 1 .. new[1] ]  do
            line := ShallowCopy(zero);
            line[i] := Z(2);
            Add( new, line );
        od;
    fi;
    Objectify( TYPE_LIST_GF2MAT_IMM, new );
    return new;
end );


#############################################################################
##
#M  Zero( <gf2mat> )  . . . . . . . . . . . . . . . . . . . . zero GF2 matrix
##
InstallMethod( Zero,
    "for GF2 Matrix",
    true,
    [ IsMatrix and IsGF2MatrixRep ],
    0,

function( mat )
    local   new,  zero,  i;

    new := [ Length(mat) ];
    if 0 < new[1]   then
        zero := Zero(mat[1]);
        for i in [ 1 .. new[1] ]  do
            Add( new, zero );
        od;
    fi;
    Objectify( TYPE_LIST_GF2MAT_IMM, new );
    return new;
end );


#############################################################################
##
#M  \+( <gf2mat>, <gf2mat> )  . . .  . . sum of a GF2 matrix and a GF2 matrix
##
SUM_GF2MAT_GF2MAT := function( l, r )
    local   p,  i;

    if Length(l) <> Length(r)  then
        Error( "Vector *: <right> must have the same length as <left>" );
    fi;

    p := [ Length(l) ];
    for i  in [ 1 .. Length(l) ]  do
        Add( p, SUM_GF2VEC_GF2VEC( l[i], r[i] ) );
    od;
    Objectify( TYPE_LIST_GF2MAT_IMM, p );
    return p;
end;

InstallMethod( \+,
    "for GF2 matrix and GF2 matrix",
    IsIdenticalObj,
    [ IsMatrix and IsGF2MatrixRep,
      IsMatrix and IsGF2MatrixRep ],
    0,
    SUM_GF2MAT_GF2MAT );


#############################################################################
##
#M  \-( <gf2mat>, <gf2mat> )  . . .  . . sum of a GF2 matrix and a GF2 matrix
##
InstallMethod( \-,
    "for GF2 matrix and GF2 matrix",
    IsIdenticalObj,
    [ IsMatrix and IsGF2MatrixRep,
      IsMatrix and IsGF2MatrixRep ],
    0,
    # we are in GF2
    SUM_GF2MAT_GF2MAT );


#############################################################################
##
#M  \*( <gf2vec>, <gf2mat> )  . . .  product of a GF2 vector and a GF2 matrix
##
InstallMethod( \*,
    "for GF2 vector and GF2 matrix",
    true,
    [ IsRingElementList and IsRowVector and IsGF2VectorRep,
      IsMatrix and IsGF2MatrixRep ],
    0,
    PROD_GF2VEC_GF2MAT );


#############################################################################
##
#M  \*( <gf2mat>, <gf2vec> )  . . .  product of a GF2 matrix and a GF2 vector
##
InstallMethod( \*,
    "for GF2 matrix and GF2 vector",
    true,
    [ IsMatrix and IsGF2MatrixRep,
      IsRowVector and IsGF2VectorRep ],
    0,
    PROD_GF2MAT_GF2VEC );


#############################################################################
##
#M  \*( <gf2mat>, <gf2mat> )  . . .  product of a GF2 matrix and a GF2 matrix
##
InstallMethod( \*,
    "for GF2 matrix and GF2 matrix",
    IsIdenticalObj,
    [ IsMatrix and IsGF2MatrixRep,
      IsMatrix and IsGF2MatrixRep ],
    0,

function( l, r )
    local   len,  prd,  i;

    len := l![1];
    prd := [ len ];
    for i  in [ 2 .. len+1 ]  do
        prd[i] := l![i]*r;
    od;
    Objectify( TYPE_LIST_GF2MAT_IMM, prd );
    return prd;
end );


#############################################################################
##

#E  vecmat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
