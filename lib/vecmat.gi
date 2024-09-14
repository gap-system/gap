#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains  the basic methods for  creating and doing  arithmetic
##  with GF2 vectors and matrices.
##

#############################################################################
##
#F IsLockedRepresentationVector . . filter used by GF2 and GF(q)
##                                  matrix reps to stop their rows
##                                  changing representation

DeclareFilter( "IsLockedRepresentationVector" );

#############################################################################
##
#V  TYPE_LIST_GF2VEC  . . . . . . . . . . . . . . type of mutable GF2 vectors
##
BindGlobal( "TYPE_LIST_GF2VEC",
  NewType( CollectionsFamily( FFEFamily(2) ),
           IsHomogeneousList and IsListDefault and IsNoImmediateMethodsObject
           and IsMutable and IsCopyable and IsGF2VectorRep )
);


#############################################################################
##
#V  TYPE_LIST_GF2VEC_IMM  . . . . . . . . . . . type of immutable GF2 vectors
##
BindGlobal( "TYPE_LIST_GF2VEC_IMM",
  NewType( CollectionsFamily( FFEFamily(2) ),
          IsHomogeneousList and IsListDefault and IsNoImmediateMethodsObject
           and IsCopyable and IsGF2VectorRep )
);


#############################################################################
##
#V  TYPE_LIST_GF2VEC_IMM_LOCKED  . . . . type of immutable locked GF2 vectors
##
BindGlobal( "TYPE_LIST_GF2VEC_IMM_LOCKED",
  NewType( CollectionsFamily( FFEFamily(2) ),
          IsHomogeneousList and IsListDefault and IsNoImmediateMethodsObject
           and IsCopyable and IsGF2VectorRep and IsLockedRepresentationVector)
);


#############################################################################
##
#V  TYPE_LIST_GF2VEC_LOCKED  . . . . type of mutable locked GF2 vectors
##
BindGlobal( "TYPE_LIST_GF2VEC_LOCKED",
  NewType( CollectionsFamily( FFEFamily(2) ),
          IsHomogeneousList and IsListDefault and IsNoImmediateMethodsObject
           and IsCopyable and IsGF2VectorRep and
          IsLockedRepresentationVector and IsMutable)
);


#############################################################################
##
#V  TYPE_LIST_GF2MAT  . . . . . . . . . . . . .  type of mutable GF2 matrices
##
BindGlobal( "TYPE_LIST_GF2MAT",
  NewType( CollectionsFamily(CollectionsFamily(FFEFamily(2))),
           IsMatrix and IsListDefault and IsSmallList and
          IsFFECollColl and IsNoImmediateMethodsObject
           and IsMutable and IsCopyable and IsGF2MatrixRep and
          HasIsRectangularTable and IsRectangularTable )
);


#############################################################################
##
#V  TYPE_LIST_GF2MAT_IMM  . . . . . . . . . .  type of immutable GF2 matrices
##
BindGlobal( "TYPE_LIST_GF2MAT_IMM",
  NewType( CollectionsFamily(CollectionsFamily(FFEFamily(2))),
          IsMatrix and IsListDefault and IsCopyable and IsGF2MatrixRep
          and IsNoImmediateMethodsObject
          and IsSmallList and IsFFECollColl and
          HasIsRectangularTable and IsRectangularTable)
);


#############################################################################
##
## HPC-GAP serialization
##
if IsHPCGAP then
    InstallTypeSerializationTag(TYPE_LIST_GF2VEC,
      SERIALIZATION_BASE_GF2VEC + SERIALIZATION_TAG_BASE * 1);

    InstallTypeSerializationTag(TYPE_LIST_GF2VEC_IMM,
      SERIALIZATION_BASE_GF2VEC + SERIALIZATION_TAG_BASE * 2);

    InstallTypeSerializationTag(TYPE_LIST_GF2VEC_IMM_LOCKED,
      SERIALIZATION_BASE_GF2VEC + SERIALIZATION_TAG_BASE * 3);

    InstallTypeSerializationTag(TYPE_LIST_GF2VEC_LOCKED,
      SERIALIZATION_BASE_GF2VEC + SERIALIZATION_TAG_BASE * 4);

    InstallTypeSerializationTag(TYPE_LIST_GF2MAT,
      SERIALIZATION_BASE_GF2MAT + SERIALIZATION_TAG_BASE * 1);

    InstallTypeSerializationTag(TYPE_LIST_GF2MAT_IMM,
      SERIALIZATION_BASE_GF2MAT + SERIALIZATION_TAG_BASE * 2);
fi;


#############################################################################
##
#M  Length( <gf2vec> )  . . . . . . . . . . . . . . .  length of a GF2 vector
##
InstallOtherMethod( Length,
    "for GF2 vector",
    true,
    [ IsList and IsGF2VectorRep ],
    0,
    LEN_GF2VEC );


#############################################################################
##
#M  ELM_LIST( <gf2vec>, <pos> ) . . . . . select an element from a GF2 vector
##
InstallOtherMethod( ELM_LIST,
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
InstallOtherMethod( ELMS_LIST,
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
##  We use an OtherMethod and trap assignment to immutable vectors in
##  the kernel method.

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
#InstallMethod( ASS_LIST,
#    "for empty plain list and finite field element",
#    true,
#    [ IsMutable and IsList and IsPlistRep and IsEmpty,
#      IsPosInt,
#      IsFFE ],
#    0,

#function( list, pos, val )
#    if pos = 1 and ( val = GF2Zero or val = GF2One )  then
#        CONV_GF2VEC(list);
#        ASS_GF2VEC( list, pos, val );
#    else
#        ASS_PLIST_DEFAULT( list, pos, val );
#        # force kernel to notice that this is now a list of FFEs
#        ConvertToVectorRep( list );
#    fi;
#end );


#############################################################################
##
#M  UNB_LIST( <gf2vec>, <pos> ) . . . . . . unbind a position of a GF2 vector
##
##  We use an OtherMethod and trap assignment to immutable vectors in
##  the kernel method.

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
#M  AdditiveInverseOp( <gf2vec> ) .  mutable additive inverse of a GF2 vector
##
InstallMethod( AdditiveInverseMutable,
    "for GF2 vector",
    true,
    [ IsRowVector and IsListDefault and IsGF2VectorRep ],
    0,
    ShallowCopy );

InstallMethod( AdditiveInverseSameMutability,
    "for GF2 vector, mutable",
    true,
    [ IsRowVector and IsListDefault and IsGF2VectorRep and IsMutable],
    0,
    ShallowCopy );

InstallMethod( AdditiveInverseSameMutability,
    "for GF2 vector, immutable",
    true,
    [ IsRowVector and IsListDefault and IsGF2VectorRep],
    0,
        function(v)
    if IsMutable(v) then
       TryNextMethod();
    fi;
    return v;
    end );


#############################################################################
##
#M  AdditiveInverse( <gf2vec> ) . . . . . .  additive inverse of a GF2 vector
##
InstallMethod( AdditiveInverse,
    "for GF2 vector",
    true,
    [ IsRowVector and IsListDefault and IsGF2VectorRep ],
    0,
    Immutable );


#############################################################################
##
#M  ZeroOp( <gf2vec> )  . . . . . . . . . . . . . . . mutable zero GF2 vector
##
InstallMethod( ZeroOp,
    "for GF2 vector",
    true,
    [ IsRowVector and IsListDefault and IsGF2VectorRep ],
    0,
    ZERO_GF2VEC );

#############################################################################
##
#M  ZeroSameMutability( <gf2vec> ) . . . . .  same mutability zero GF2 vector
##
InstallMethod( ZeroSameMutability,
    "for GF2 vector, mutable",
    true,
    [ IsRowVector and IsListDefault and IsGF2VectorRep and IsMutable],
    0,
    ZERO_GF2VEC );

InstallMethod( ZeroSameMutability,
    "for GF2 vector, immutable",
    true,
    [ IsRowVector and IsListDefault and IsGF2VectorRep],
        0,
        function(v)
    local z;
    if IsMutable(v) then
        TryNextMethod();
    fi;
    z :=    ZERO_GF2VEC(v);
    MakeImmutable(z);
    return z;
end);


#############################################################################
##
#M  \=( <gf2vec>, <gf2vec> )  . . . . . . . . . . . . equality of GF2 vectors
##
InstallMethod( \=,"for GF2 vectors",IsIdenticalObj,
    [ IsRowVector and IsGF2VectorRep,
      IsRowVector and IsGF2VectorRep ], 0, EQ_GF2VEC_GF2VEC );

#############################################################################
##
#M  \<( <gf2vec>, <gf2vec> )  . . . . . . . . . . . . equality of GF2 vectors
##
InstallMethod( \<,"for GF2 vectors",IsIdenticalObj,
    [ IsRowVector and IsGF2VectorRep,
      IsRowVector and IsGF2VectorRep ], 0, LT_GF2VEC_GF2VEC );


#############################################################################
##
#M  \+( <gf2vec>, <gf2vec> )  . . . . . . . . . . . .  sum of two GF2 vectors
##
InstallMethod( \+,
    "for GF2 vectors",
    IsIdenticalObj,
    [ IsRowVector and IsListDefault and IsGF2VectorRep,
      IsRowVector and IsListDefault and IsGF2VectorRep ],
    0,
    SUM_GF2VEC_GF2VEC );


#############################################################################
##
#M  \-( <gf2vec>, <gf2vec> )  . . . . . . . . . difference of two GF2 vectors
##
InstallMethod( \-,
    "for GF2 vectors",
    IsIdenticalObj,
    [ IsRowVector and IsListDefault and IsGF2VectorRep,
      IsRowVector and IsListDefault and IsGF2VectorRep ],
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
    [ IsRingElementList and IsListDefault and IsRowVector and IsGF2VectorRep,
      IsRingElementList and IsListDefault and IsRowVector and IsGF2VectorRep ],
    0,
    PROD_GF2VEC_GF2VEC );


#############################################################################
##
#M  \*( <ffe>, <gf2vec> ) . . . . . . . . . . . product of FFE and GF2 vector
##
##  This method is installed with positive rank because it is the
##  specialised method for GF(2) elements and should fall through to
##  the general method for GF(2^k).
##
InstallMethod( \*,
    "for FFE and GF2 vector",
    IsElmsColls,
    [ IsFFE,
      IsRingElementList and IsRowVector and IsGF2VectorRep ],
    10,

function( a, b )
    if a = GF2Zero  then
        return ZeroSameMutability(b);
    elif a = GF2One  then
        if IsMutable(b) then
            return ShallowCopy(b);
        else
            return b;
        fi;
    else
        TryNextMethod();
    fi;
end );



#############################################################################
##
#M  \*( <gf2vec>, <ffe> ) . . . . . . . . . . . product of GF2 vector and FFE
##
##  This method is installed with positive rank because it is the
##  specialised method for GF(2) elements and should fall through to
##  the general method for GF(2^k).
##

InstallMethod( \*,
    "for GF2 vector and FFE",
    IsCollsElms,
    [ IsRingElementList and IsRowVector and IsGF2VectorRep,
      IsFFE ],
    10,

function( a, b )
    if b = GF2Zero  then
        return ZeroSameMutability(a);
    elif b = GF2One  then
        if IsMutable(a) then
            return ShallowCopy(a);
            else
                return a;
            fi;
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
#M  PadCoeffs( <gf2vec>, <len> )  . . . . . . . . . . . expand a GF2 vector
##
InstallMethod( PadCoeffs,
    "for GF2 vector",
    true,
        [ IsMutable and IsRowVector and IsAdditiveElementWithZeroCollection and IsGF2VectorRep,
          IsPosInt ],
        0,
        function(v,len)
    if len > LEN_GF2VEC(v) then
        RESIZE_GF2VEC(v,len);
    fi;
end);

#############################################################################
##
#M  QuotRemCoeffs( <gf2vec>, <len>, <gf2vec>, <len> )
##
InstallMethod( QuotRemCoeffs,
        "GF2 vectors",
        [ IsRowVector and IsGF2VectorRep, IsInt, IsRowVector and IsGF2VectorRep, IsInt],
        QUOTREM_COEFFS_GF2VEC);

#############################################################################
##
#M  NormedRowVector( <v> )
##
InstallMethod( NormedRowVector, "for GF(2) vector", true,
    [ IsRowVector and IsGF2VectorRep and IsScalarCollection ],0,
 # Over GF(2) one can norm only to 1
 x->x);

#############################################################################
##
#M  Length( <list> )  . . . . . . . . . . . . . . . .  length of a GF2 matrix
##
InstallOtherMethod( Length,
    "for GF2 matrix",
    true,
    [ IsMatrix and IsGF2MatrixRep ],
    0,

function( list )
    return list![1];
end );


#############################################################################
##
#M  <list> [ <pos> ] . . . . . . . . . . .  select an element of a GF2 matrix
##
InstallOtherMethod( \[\], "for GF2 matrix",
    [ IsMatrix and IsGF2MatrixRep,
      IsPosInt ],
    ELM_GF2MAT );

InstallMethod( \[\,\], "for GF2 matrix",
    [ IsGF2MatrixRep,
      IsPosInt, IsPosInt ],
    MAT_ELM_GF2MAT );


#############################################################################
##
#M  <gf2mat> [ <pos> ] := <elm> . . . . . . assign an element to a GF2 matrix
##
InstallOtherMethod( \[\]\:\=,
    "for GF2 matrix",
    [ IsList and IsGF2MatrixRep and IsMutable,
      IsPosInt,
      IsObject ],
    ASS_GF2MAT );

InstallOtherMethod( \[\]\:\=,
    "for GF2 matrix",
    [ IsList and IsGF2MatrixRep,
      IsPosInt,
      IsObject ],
    ASS_GF2MAT );

InstallMethod( \[\,\]\:\=,
    "for GF2 matrix",
    [ IsGF2MatrixRep and IsMutable,
      IsPosInt, IsPosInt,
      IsObject ],
    SET_MAT_ELM_GF2MAT );


#############################################################################
##
#M  ASS_LIST( <empty-list>, <pos>, <gf2vec> ) . . . .  start a new GF2 matrix
##
#InstallMethod( ASS_LIST,
#    "for empty plain list and GF2 vector",
#    true,
#    [ IsMutable and IsList and IsPlistRep and IsEmpty,
#      IsPosInt,
#      IsGF2VectorRep ],
#    0,

#function( list, pos, val )
#    if pos = 1 and not IsMutable(val) then
#        list[1] := 1;
#        list[2] := val;
#        SetFilterObj(val, IsLockedRepresentationVector);
#        Objectify( TYPE_LIST_GF2MAT, list );
#    else
#        ASS_PLIST_DEFAULT( list, pos, val );
#    fi;
#end );

#############################################################################
##
#M  UNB_LIST( <gf2mat>, <pos> ) . . . . . . unbind a position of a GF2 matrix
##
InstallOtherMethod( UNB_LIST,
    "for GF2 matrix",
    true,
    [ IsList and IsGF2MatrixRep and IsMutable,
      IsPosInt ],
    0,
    UNB_GF2MAT );

InstallOtherMethod( UNB_LIST,
        "for GF2 matrix",
        true,
        [ IsList and IsGF2MatrixRep,
          IsPosInt ],
        0,
        function(m, pos)
    if IsMutable(m) then
        TryNextMethod();
    elif pos <= Length(m) then
        Error("Unbind: can't unbind an entry of an immutable GF2 Matrix" );
    fi;
end);


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
    Print( "\>\>[ \>\>" );
    for i  in [ 1 .. NrRows(mat) ]  do
        if 1 < i  then Print( "\<,\< \>\>" );  fi;
        Print( "\>\>[ \>\>" );
        for j  in [ 1 .. NrCols(mat) ]  do
            if 1 < j  then Print( "\<,\< \>\>" );  fi;
            Print( mat[i,j] );
        od;
        Print( " \<\<\<\<]" );
    od;
    Print( " \<\<\<\<]" );
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
    if IsMutable(mat)  then
        Print("<a ",NrRows(mat),"x",NrCols(mat)," matrix over GF2>");
    else
        Print( "<an immutable ", NrRows(mat), "x", NrCols(mat),
               " matrix over GF2>" );
    fi;
end );

#############################################################################
##
#M  ShallowCopy( <gf2mat> ) . . . . . .  mutable shallow copy of a GF2 matrix
##
BindGlobal("SHALLOWCOPY_GF2MAT",
function(mat)
    local   copy,  i, len;

    len := mat![1];
    copy := [ len ];
    for i  in [2..len+1] do
        copy[i] := mat![i];
    od;
    Objectify( TYPE_LIST_GF2MAT, copy );
    return copy;
end);

InstallMethod( ShallowCopy,
        "for GF2 matrix",
        true,
        [ IsMatrix and IsGF2MatrixRep ],
        0,
        SHALLOWCOPY_GF2MAT);

InstallOtherMethod(TransposedMat,"GF2 matrix",true,
  [IsMatrix and IsGF2MatrixRep],0,TRANSPOSED_GF2MAT);

InstallOtherMethod(MutableTransposedMat,"GF2 matrix",true,
  [IsMatrix and IsGF2MatrixRep],0,TRANSPOSED_GF2MAT);


#############################################################################
##
#M  AdditiveInverseOp( <gf2mat> ) .  mutable additive inverse of a GF2 matrix
##
InstallMethod( AdditiveInverseOp,
    "for GF2 matrix",
    true,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep ],
        0,
        function(mat)
    local   copy,  i, len;

    len := mat![1];
    copy := [ len ];
    for i  in [2..len+1] do
        copy[i] := ShallowCopy(mat![i]);
        SetFilterObj(copy[i],IsLockedRepresentationVector);
    od;
    Objectify( TYPE_LIST_GF2MAT, copy );
    return copy;
end);

#############################################################################
##
#M  AdditiveInverseSameMutability( <gf2mat> ) .  same mutability additive inverse
##
InstallMethod( AdditiveInverseSameMutability,
    "for GF2 matrix",
    true,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep ],
        0,
        function(mat)
    local   copy,  i, len,r ;

    if not IsMutable(mat) then
        return mat;
    fi;
    len := mat![1];
    copy := [ len ];
    for i  in [2..len+1] do
        r := mat![i];
        if IsMutable(r) then
            copy[i] := ShallowCopy(mat![i]);
            SetFilterObj(copy[i],IsLockedRepresentationVector);
        else
            copy[i] := r;
        fi;
    od;
    Objectify( TYPE_LIST_GF2MAT, copy );
    return copy;
end);



#############################################################################
##
#M  AdditiveInverse( <gf2mat> ) . . . . . .  additive inverse of a GF2 matrix
##
InstallMethod( AdditiveInverse,
    "for GF2 matrix",
    true,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep ],
    0,
    # we are in GF2
    Immutable );


#############################################################################
##
#M  InverseOp( <gf2mat> ) . . . . . . . . . . mutable inverse of a GF2 matrix
##
InstallMethod( InverseOp,
    "for GF2 matrix",
    true,
    [ IsMultiplicativeElementWithInverse and IsOrdinaryMatrix and
      IsSmallList and IsFFECollColl
      and IsGF2MatrixRep ],
    0,
    INV_GF2MAT_MUTABLE );

#############################################################################
##
#M  InverseSameMutability( <gf2mat> ) same mutability inverse of a GF2 matrix
##
InstallMethod( InverseSameMutability,
    "for GF2 matrix",
    true,
    [ IsMultiplicativeElementWithInverse and IsOrdinaryMatrix and
      IsSmallList and IsFFECollColl
      and IsGF2MatrixRep ],
    0,
        INV_GF2MAT_SAME_MUTABILITY );


#############################################################################
##
#M  InverseOp( <list of gf2 vectors> ) .  . . mutable inverse of a GF2 matrix
##

InstallMethod( InverseOp,
    "for plain list of GF2 vectors",
    true,
    [ IsPlistRep and IsFFECollColl and IsMatrix],
    0,
    m->INV_PLIST_GF2VECS_DESTRUCTIVE(List(m, ShallowCopy)) );

#############################################################################
##
#M  InverseSameMutability( <list of gf2 vectors> ) .  same mutability inverse of a GF2 matrix
##

InstallMethod( InverseSameMutability,
    "for plain list of GF2 vectors",
    true,
    [ IsPlistRep and IsFFECollColl and IsMatrix],
        0,
        function(m)
    local inv,i;
    inv := INV_PLIST_GF2VECS_DESTRUCTIVE(List(m, ShallowCopy));
    if inv = TRY_NEXT_METHOD then
        TryNextMethod();
    fi;
    if IsMutable(m) then
        if not IsMutable(m[1]) then
            for i in [1..NrRows(m)] do
                MakeImmutable(inv[i]);
            od;
        fi;
    else
        MakeImmutable(inv);
    fi;
    return inv;
end );


#############################################################################
##
#M  OneOp( <gf2mat> ) . . . . . . . . . . . . . . mutable identity GF2 matrix
##
##  A fully mutable GF2 matrix cannot be in the special compressed rep.
##  so return it as a plain list
##

BindGlobal("GF2IdentityMatrix", function(n, imm)
    local i,id,line,o;
    o := Z(2);
    id := [n];
    for i in [1..n] do
        line := ZERO_GF2VEC_2(n);
        line[i] := o;
        SetFilterObj(line,IsLockedRepresentationVector);
        if imm > 0 then
            MakeImmutable(line);
        fi;
        Add(id, line);
    od;
    if imm > 1 then
        Objectify(TYPE_LIST_GF2MAT_IMM, id);
    else
        Objectify(TYPE_LIST_GF2MAT, id);
    fi;
    return id;
end);




InstallMethod( OneOp,
    "for GF2 Matrix",
    true,
    [ IsOrdinaryMatrix and IsGF2MatrixRep and IsMultiplicativeElementWithOne],
        0,
        function(mat)
    local len;
    len := NrRows(mat);
    if len <> NrCols(mat) then
        return fail;
    fi;
    return GF2IdentityMatrix(len, 0);
end);


#############################################################################
##
#M  One( <gf2mat> ) . . . . . . . . . . . . . . . . . . . identity GF2 matrix
##
InstallMethod( One,
    "for GF2 Matrix",
    true,
    [ IsOrdinaryMatrix and IsGF2MatrixRep and IsMultiplicativeElementWithOne],
    0,
        function(mat)
    local len;
    len := NrRows(mat);
    if len <> NrCols(mat) then
        return fail;
    fi;
    return GF2IdentityMatrix(len, 2);
end );


#############################################################################
##
#M  OneSameMutability( <gf2mat> ) . . . . . . . . . . . . identity GF2 matrix
##
InstallMethod( OneSameMutability,
    "for GF2 Matrix",
    true,
    [ IsOrdinaryMatrix and IsGF2MatrixRep and IsMultiplicativeElementWithOne],
    0,
        function(mat)
    local len,row1;
    len := NrRows(mat);
    if len <> NrCols(mat) then
        return fail;
    fi;
    row1 := mat[1];
    if not IsMutable(mat) then
        return GF2IdentityMatrix(len, 2);
    elif IsMutable(mat) and not IsMutable(row1) then
        return GF2IdentityMatrix(len, 1);
    else
        return GF2IdentityMatrix(len, 0);
    fi;
end );


#############################################################################
##
#M  ZeroOp( <gf2mat> )  . . . . . . . . . . . . . . . mutable zero GF2 matrix
##
##

InstallMethod( ZeroOp,
    "for GF2 Matrix",
    true,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep ],
    0,

function( mat )
    local   new,  zero,  i;

    new := [ Length(mat) ];
    if 0 < new[1]   then
        for i in [ 1 .. new[1] ]  do
            zero := ZeroOp(mat[1]);
            SetFilterObj(zero, IsLockedRepresentationVector);
            Add( new, zero );
        od;
    fi;
    Objectify( TYPE_LIST_GF2MAT, new );
    return new;
end );


#############################################################################
##
#M  ZeroSameMutability( <gf2mat> ) . . . . . . . . . . .  matching mutability
##
InstallMethod( ZeroSameMutability,
    "for GF2 Matrix",
    true,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep ],
    0,

function( mat )
    local   new,  zero,  i;

    new := [ Length(mat) ];
    if 0 < new[1]   then
        if  IsMutable(mat![2]) then
            for i in [ 1 .. new[1] ]  do
                zero := ZeroSameMutability(mat![2]);
                SetFilterObj(zero, IsLockedRepresentationVector);
                Add( new, zero );
            od;
        else
            zero := ZeroSameMutability(mat![2]);
            SetFilterObj(zero, IsLockedRepresentationVector);
            for i in [ 1 .. new[1] ]  do
                Add( new, zero );
            od;
        fi;
    fi;
    Objectify( TypeObj(mat), new );
    return new;
end );



#############################################################################
##
#M  Zero( <gf2mat> )  . . . . . . . . . . . . . . . . . . . . zero GF2 matrix
##
InstallMethod( Zero,
    "for GF2 Matrix",
    true,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep ],
    0,

function( mat )
    local   new,  zero,  i;

    new := [ Length(mat) ];
    if 0 < new[1]   then
        zero := Zero(mat[1]);
        SetFilterObj(zero, IsLockedRepresentationVector);
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

InstallMethod( \+,
    "for GF2 matrix and GF2 matrix",
    IsIdenticalObj,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep,
      IsMatrix and IsListDefault and IsGF2MatrixRep ],
    0,
    SUM_GF2MAT_GF2MAT );

#############################################################################
##
#M  \<( <gf2mat>, <gf2mat> )  . . . . . . . . . . .comparison of GF2 matrices
##

InstallMethod( \<,
    "for GF2 matrix and GF2 matrix",
    IsIdenticalObj,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep,
      IsMatrix and IsListDefault and IsGF2MatrixRep ],
    0,
        LT_GF2MAT_GF2MAT);

#############################################################################
##
#M  \=( <gf2mat>, <gf2mat> )  . . . . . . . . . . .comparison of GF2 matrices
##

InstallMethod( \=,
    "for GF2 matrix and GF2 matrix",
    IsIdenticalObj,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep,
      IsMatrix and IsListDefault and IsGF2MatrixRep ],
    0,
        EQ_GF2MAT_GF2MAT);


#############################################################################
##
#M  \-( <gf2mat>, <gf2mat> )  . . .  . . sum of a GF2 matrix and a GF2 matrix
##
InstallMethod( \-,
    "for GF2 matrix and GF2 matrix",
    IsIdenticalObj,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep,
      IsMatrix and IsListDefault and IsGF2MatrixRep ],
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
    [ IsRingElementList and IsRowVector and IsListDefault and IsGF2VectorRep,
      IsMatrix and IsListDefault and IsGF2MatrixRep ],
    0,
    PROD_GF2VEC_GF2MAT );


#############################################################################
##
#M  <vec>*<mat> . . . general method for GF2 vector and a matrix
##                    works fast when the matrix is a plain list
##                    of compressed GF2 vectors, otherwise falls through
##

InstallMethod(\*, "for a GF2 vector and a compatible matrix",
        IsElmsColls, [IsRowVector and IsGF2VectorRep and IsSmallList
                and IsRingElementList,
                IsRingElementTable and IsPlistRep], 0,
        PROD_GF2VEC_ANYMAT);


#############################################################################
##
#M  \*( <gf2mat>, <gf2vec> )  . . .  product of a GF2 matrix and a GF2 vector
##
InstallMethod( \*,
    "for GF2 matrix and GF2 vector",
    true,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep,
      IsRowVector and IsListDefault and IsGF2VectorRep ],
    0,
    PROD_GF2MAT_GF2VEC );


#############################################################################
##
#M  \*( <gf2mat>, <gf2mat> )  . . .  product of a GF2 matrix and a GF2 matrix
##
InstallMethod( \*,
    "for GF2 matrix and GF2 matrix",
    IsIdenticalObj,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep,
      IsMatrix and IsListDefault and IsGF2MatrixRep ],
    0,

        PROD_GF2MAT_GF2MAT );

#############################################################################
##
#M  \*( <gf2elm>, <gf2mat> )  . . .  product of a GF2 element and a GF2 matrix
##
InstallMethod( \*,
    "for GF2 element and GF2 matrix",
    IsElmsCollColls,
    [ IsFFE,
      IsMatrix and IsListDefault and IsGF2MatrixRep ],
    0,
        function(s,m)
    if s = Z(2) then
        return AdditiveInverseSameMutability(m);
    elif IsZero(s) then
        return ZeroSameMutability(m);
    else
        TryNextMethod();
    fi;
end);

#############################################################################
##
#M  \*( <gf2mat>, <gf2elm> )  . . .  product of a GF2 matrix  and a GF2 element
##
InstallMethod( \*,
    "for GF2 matrix and GF2 element",
    IsCollCollsElms,
        [       IsMatrix and IsListDefault and IsGF2MatrixRep,
                IsFFE ],
    0,
        function(m,s)
    if s = Z(2) then
        return AdditiveInverseSameMutability(m);
    elif IsZero(s) then
        return ZeroSameMutability(m);
    else
        TryNextMethod();
    fi;
end);

#############################################################################
##
#F  ConvertToVectorRep(<v>)
##

BindGlobal("LOCAL_COPY_GF2", GF(2));
BindGlobal("SMALL_PRIME_POWERS", Immutable(Filtered([2..256], IsPrimePowerInt)));

InstallGlobalFunction(ConvertToVectorRepNC,function( arg )
    local v, q, vc, common, field, q0;
    if Length(arg) < 1 then
        Error("ConvertToVectorRep: one or two arguments required");
    fi;
    v := arg[1];
#
# Handle fast, certain cases where there is no work. Microseconds count here
#
    if IsGF2VectorRep(v) and (Length(arg) = 1 or arg[2] = 2 or arg[2] = LOCAL_COPY_GF2) then
        return 2;
    fi;

    if Is8BitVectorRep(v) then
        q0 := Q_VEC8BIT(v);
        if Length(arg) = 1 then
            return q0;
        fi;
        if IsPosInt(arg[2]) then
            q := arg[2];
        elif IsField(arg[2]) then
            q := Size(arg[2]);
        else
            return fail;
        fi;
        if q = q0 then
            return q;
        fi;
        if IsLockedRepresentationVector(v) then
            Error("Vector is locked over current field");
        else
            if q = 2 then
                CONV_GF2VEC(v);
                return 2;
            elif q <= 256 then
                if not q in SMALL_PRIME_POWERS then
                    return fail;
                fi;
                CONV_VEC8BIT(v,q);
                return q;
            else
                if q mod q0 <> 0 then
                    Error("New field size incompatible with vector entries");
                else
                    PLAIN_VEC8BIT(v);
                    return q;
                fi;

            fi;
        fi;
    fi;


    if (Length(v) = 0 and Length(arg) = 1) or
      (Length(v) >0 and not IsRowVector(v))  then
        return fail;
    fi;

    # if the representation of v is already locked, then
    # we ignore a second arguments and just report on the vector

    if IsLockedRepresentationVector(v) then
        if IsGF2VectorRep(v) then
            q := 2;
        elif Is8BitVectorRep(v) then
            q := Q_VEC8BIT(v);
        else
            Error("vector is locked in an unknown representation");
        fi;
        if not IsInt(arg[2]) then
            arg[2] := Size(arg[2]);
        fi;
        if Length(arg) = 2 and q <> arg[2] then
          Info(InfoWarning, 1,
          "ConvertToVectorRep: locked vector not converted to different field");
        fi;
        return q;
    fi;


    #
    # Ask the kernel to check the list for us.
    # We have to do this, even in an NC version because the list might contain
    # elements of large finite fields
    #

    if not IS_VECFFE(v) then
        if IsFFECollection(v) then
            # now we might have some elements in a large field representation
            # or possibly a totally bad list
            vc := ShallowCopy(v);
            common := FFECONWAY.WriteOverSmallestCommonField(vc);
            #
            # FFECONWAY.WriteOverSmallestCommonField returns an integer or fail.
            # When integer is returned, it also may modify entries of vc
            #
            if common = fail or common  > 256 then
                #
                # vector needs a field > 256, so can't be compressed
                # or vector contains non-ffes or no common characteristic
                #
                return fail;
            fi;
            # Switching the object below can change the mutability of v, so we
            # make sure that if v is immutable it stays immutable.
            if not IsMutable(v) then
                MakeImmutable(vc);
            fi;
            SWITCH_OBJ(v,vc);
        else
            return fail;
        fi;
    else
        common := COMMON_FIELD_VECFFE(v);
    fi;

    #
    # see if the user gave us q
    #
    if Length(arg) > 1 then
        field := arg[2];
        if IsPosInt(field) then
            q := field;
            Assert(2,IsPrimePowerInt(q));
        elif IsField(field) then
            q := Size(field);
        else
            Error("q not a field or positive integer");
        fi;
    else
        q := fail;
    fi;

    #
    # if there is a field, we go to work
    #
    if q = fail then
        if common = fail then
            return fail;
        fi;
        if not IsPrimeInt(common) then
            common := SMALLEST_FIELD_VECFFE(v);
        fi;
        if common = 2 then
            CONV_GF2VEC(v);
            return 2;
        elif common <= 256 then
            CONV_VEC8BIT(v,common);
            return common;
        else
            return fail;
        fi;
    elif q = 2 then
        if common > 2 and common mod 2 = 0 then
            common := SMALLEST_FIELD_VECFFE(v);
        fi;
        if common <> 2 then
            Error("ConvertToVectorRepNC: Vector cannot be written over GF(2)");
        fi;
        CONV_GF2VEC(v); # safe to call this even with an invalid argument
        return 2;
    elif q <= 256 then
        if common <> q then
            if IsPlistRep(v) and  GcdInt(common,q) > 1  then
                common := SMALLEST_FIELD_VECFFE(v);
            fi;
            if common ^ LogInt(q, common) <> q then
                Error("ConvertToVectorRepNC: Vector cannot be written over GF(",q,")");
            fi;
        fi;
        Assert(2, ForAll(v, elm -> elm in GF(q)));
        CONV_VEC8BIT(v,q);
        return q;
    else
        return fail;
    fi;
end);


#############################################################################
##
#F  CopyToVectorRep( <v>, <q> )
##
InstallGlobalFunction(CopyToVectorRep,function( v, q )
    local vc, common, res;

    # Handle fast, certain cases where there is no work. Microseconds count here

    if Length(v) = 0 then
        return v;
    fi;

    if IsGF2VectorRep(v) and q=2 then
        if IsMutable(v) then
          return(ShallowCopy(v));
        else
          return v;
        fi;
    fi;

    if Is8BitVectorRep(v) then
        if q = Q_VEC8BIT(v) then
            if IsMutable(v) then
                return(ShallowCopy(v));
            else
                return v;
            fi;
        fi;
    fi;

    # Ask the kernel to check the list for us.
    # We have to do this, even in an NC version because the list might contain
    # elements of large finite fields.
    # Calling IS_VECFFE may force a full inspection of the list.

    if not IS_VECFFE(v) then
        # TODO: no need of the next 'if' block in the NC-version
        if IsFFECollection(v) then
            # Now we might have some elements in a large field representation
            # or possibly a totally bad list. We will examine the shallow copy
            # of v to avoid side effects when CopyToVectorRep modifies v and
            # then returns fail
            vc := ShallowCopy(v);
            common := FFECONWAY.WriteOverSmallestCommonField(vc);
            #
            # FFECONWAY.WriteOverSmallestCommonField returns an integer or fail.
            # When it returns an integer, it may modify individual entries of vc
            #
            if common = fail or common  > 256 then
                #
                # vector needs a field > 256, so can't be compressed
                # or vector contains non-ffes or no common characteristic
                #
                return fail; # v cannot be written over GF(q)
            fi;
            if not IsMutable(v) then
                MakeImmutable(vc);
            fi;
        else
            return fail; # v cannot be written over GF(q)
        fi;
    else
        common := COMMON_FIELD_VECFFE(v);
        vc := v;
    fi;

    if q = 2 then
        Assert(2, ForAll(vc, elm -> elm in GF(2)));
        if common > 2 and common mod 2 = 0 then
            common := SMALLEST_FIELD_VECFFE(vc);
        fi;
        if common <> 2 then
            Error("CopyToVectorRep: Vector cannot be written over GF(2)");
        fi;
        res := COPY_GF2VEC(vc);
        if not IsMutable(v) then MakeImmutable(res); fi;
        return res;
    elif q <= 256 then
        if common <> q then
            Assert(2, ForAll(vc, elm -> elm in GF(q)));
            if IsPlistRep(vc) and  GcdInt(common,q) > 1  then
                common := SMALLEST_FIELD_VECFFE(vc);
            fi;
            if common ^ LogInt(q, common) <> q then
                Error("CopyToVectorRep: Vector cannot be written over GF(",q,")");
            fi;
        fi;
        res := COPY_VEC8BIT(vc,q);
        if not IsMutable(v) then MakeImmutable(res); fi;
        return res;
    else
        return fail; # vector cannot be written over GF(q)
    fi;
end);


#############################################################################
##
#F  CopyToVectorRepNC( <v>, <q> )
##
##  This is the NC-version of CopyToVectorRep. It is forbidden to call it
##  unless v is a plain list or a row vector, q<=256 is a valid size of a
##  finite field, and all elements of v lie in this field.
##
InstallGlobalFunction(CopyToVectorRepNC,function( v, q )
    local common, res;

    # Handle fast, certain cases where there is no work. Microseconds count here

    if Length(v) = 0 then
        return v;
    fi;

    if IsGF2VectorRep(v) and q=2 then
        if IsMutable(v) then
          return(ShallowCopy(v));
        else
          return v;
        fi;
    fi;

    if Is8BitVectorRep(v) then
        if q = Q_VEC8BIT(v) then
            if IsMutable(v) then
                return(ShallowCopy(v));
            else
                return v;
            fi;
        fi;
    fi;

    # Calling COMMON_FIELD_VECFFE may force a full inspection of the list.
    common := COMMON_FIELD_VECFFE(v);
    if common = fail then
        common := SMALLEST_FIELD_VECFFE(v);
        if common = fail then
            Error("CopyToVectorRepNC: Vector cannot be written over GF(",q,").\n",
                  "You may try to use CopyToVectorRep instead\n");
        fi;

    fi;

    if q = 2 then
        Assert(2, ForAll(v, elm -> elm in GF(2)));
        if common > 2 and common mod 2 = 0 then
            common := SMALLEST_FIELD_VECFFE(v);
        fi;
        if common <> 2 then
            Error("CopyToVectorRepNC: Vector cannot be written over GF(2)");
        fi;
        res := COPY_GF2VEC(v);
        if not IsMutable(v) then MakeImmutable(res); fi;
        return res;
    elif q <= 256 then
        if common <> q then
            Assert(2, ForAll(v, elm -> elm in GF(q)));
            if IsPlistRep(v) and  GcdInt(common,q) > 1  then
                common := SMALLEST_FIELD_VECFFE(v);
            fi;
            if common ^ LogInt(q, common) <> q then
                Error("CopyToVectorRepNC: Vector cannot be written over GF(",q,")");
            fi;
        fi;
        res :=COPY_VEC8BIT(v,q);
        if not IsMutable(v) then MakeImmutable(res); fi;
        return res;
    else
        Error("CopyToVectorRepNC: Vector cannot be written over GF(",q,")");
    fi;
end);


#############################################################################
##
#F  ImmutableMatrix( <field>, <matrix> [,<change>] )
##
BindGlobal("DoImmutableMatrix", function(field,matrix,change)
local sf, rep, ind, ind2, row, i,big,l,nr;
  if IsMatrixObj(matrix) then
    # result is a matrix object iff 'matrix' is
    if field=BaseDomain(matrix) then
      return Immutable(matrix);
    else
      return ImmutableMatrix(field,Unpack(matrix));
    fi;
  elif not (IsPlistRep(matrix) or IsGF2MatrixRep(matrix) or
    Is8BitMatrixRep(matrix)) then
    # if empty or not list based, simply return `Immutable'.
    return Immutable(matrix);
  fi;
  if IsPosInt(field) then
    sf:=field;
  elif IsField(field) then
    sf:=Size(field);
  elif IsZmodnZObjNonprimeCollection(field) then
    # slight abuse of ``field'' variable name
    sf:=Size(field);
  else
    # not a field
    return Immutable(matrix);
  fi;

  big:=sf>256 or sf=0 or not IsFFECollColl(matrix);

  # the representation we want the rows to be in
  if sf=2 then
    rep:=IsGF2VectorRep;
  elif not big then
    rep:=function(v) return Is8BitVectorRep(v) and Q_VEC8BIT(v) = sf; end;
  else
    rep:=IsPlistRep;
  fi;

  # cannot use NrRows consistently, as input might be mixed format
  if IsList(matrix) then
    nr:=Length(matrix);
  else
    nr:=NrRows(matrix);
  fi;

  # get the indices of the rows that need changing the representation.
  ind:=[]; # rows to convert
  ind2:=[]; # rows to rebuild
  for i in [1..nr] do
    if not rep(matrix[i]) then
      if big or IsLockedRepresentationVector(matrix[i])
        or (IsMutable(matrix[i]) and not change) then
        Add(ind2,i);
      else
        # wrong rep, but can be converted
        Add(ind,i);
      fi;
    elif (IsMutable(matrix[i]) and not change) then
      # right rep but wrong mutability
      Add(ind2,i);
    fi;
  od;

  # do we need to rebuild outer matrix layer?
  if (IsMutable(matrix) and not change) # matrix was mutable
    or (Length(ind2)>0 and   # we want to change rows
      not IsMutable(matrix)) #but cannot change entries
    or (Is8BitMatrixRep(matrix) # matrix is be compact rep
       and (Length(ind)>0 or Length(ind2)>0) ) # and we change rows
       then
    l:=matrix;
    matrix:=[];
    for i in l do
      Add(matrix,i);
    od;
  fi;

  # rebuild some rows
  if IsZmodnZObjNonprimeCollection(field) then
    big:=true;
  elif big then
    if sf<>infinity and IsPrimeInt(sf) and sf>MAXSIZE_GF_INTERNAL then
      if not (IsMatrixObj(matrix) and not IsMutable(matrix)) then
        if field=sf then field:=Integers mod sf;fi;
        for i in ind2 do
          matrix[i]:=List(matrix[i],j->j); # plist conversion
        od;
      fi;
    else
      for i in ind2 do
        matrix[i]:=List(matrix[i],j->j); # plist conversion
      od;
    fi;
  else
    for i in ind2 do
      row := ShallowCopy(matrix[i]);
      ConvertToVectorRepNC(row, sf);
      matrix[i] := row;
    od;
    for i in ind do
      ConvertToVectorRepNC(matrix[i],sf);
    od;
  fi;

  MakeImmutable(matrix);
  if not big and sf=2 and not IsGF2MatrixRep(matrix) then
    CONV_GF2MAT(matrix);
  elif not big and sf>2 and sf<=256 and not Is8BitMatrixRep(matrix) then
    CONV_MAT8BIT(matrix,sf);
  fi;
  return matrix;
end);

InstallOtherMethod( ImmutableMatrix,"general,2",
[IsObject,IsMatrixOrMatrixObj],0,
function(f,m)
  return DoImmutableMatrix(f,m,false);
end);

InstallOtherMethod( ImmutableMatrix,"List of vectors",
[IsObject,IsList],0,
function(f,m)
  if not ForAll(m,x->IsList(x) or IsVector(x)) then TryNextMethod();fi;
  return DoImmutableMatrix(f,m,false);
end);

InstallOtherMethod(ImmutableMatrix,"general,3",[IsObject,IsMatrixOrMatrixObj,IsBool],0,
  DoImmutableMatrix);

InstallOtherMethod( ImmutableMatrix,"field,8bit",[IsField,Is8BitMatrixRep],0,
function(f,m)
  if Q_VEC8BIT(m[1])<>Size(f) then
    TryNextMethod();
  fi;
  return Immutable(m);
end);

InstallOtherMethod( ImmutableMatrix,"field,gf2",[IsField,IsGF2MatrixRep],0,
function(f,m)
  if 2<>Size(f) then
    TryNextMethod();
  fi;
  return Immutable(m);
end);

InstallOtherMethod( ImmutableMatrix,"fieldsize,8bit",[IsPosInt,Is8BitMatrixRep],0,
function(f,m)
  if Q_VEC8BIT(m[1])<>f then
    TryNextMethod();
  fi;
  return Immutable(m);
end);

InstallOtherMethod( ImmutableMatrix,"fieldsize,gf2",[IsPosInt,IsGF2MatrixRep],0,
function(f,m)
  if 2<>f then
    TryNextMethod();
  fi;
  return Immutable(m);
end);

InstallOtherMethod( ImmutableMatrix,"empty",[IsObject,IsEmpty],0,
function(f,m)
  return Immutable(m);
end);

InstallOtherMethod( ImmutableMatrix,"transposed empty",[IsObject,IsList],0,
function(f,m)
  if not ForAll(m,i->IsList(i) and Length(i)=0) then
    TryNextMethod();
  fi;
  return Immutable(m);
end);


#############################################################################
##
#F  ImmutableVector( <field>, <vector> )
##
InstallMethod( ImmutableVector,"general,2",[IsObject,IsRowVector],0,
function(f,v)
  local v2;
  if not IsInt(f) then f := Size(f); fi;
  # 'IsRowVector' implies 'IsList'.
  # We are not allowed to return a non-list,
  # thus we are not allowed to call 'Vector'.
  # Since there is a method for 'IsVectorObj' as the second argument,
  # we do not deal with proper vector objects here.
  if f <= 256 then
    v2 := CopyToVectorRep(v,f);
    if v2 <> fail then v := v2; fi;
  fi;
  return Immutable(v);
end);

InstallOtherMethod( ImmutableVector,"vectorObj,2",[IsObject,IsVectorObj],0,
function(f,v)
  return MakeImmutable( ChangedBaseDomain( v, f ) );
end);

InstallOtherMethod( ImmutableVector,"general,3",[IsObject,IsRowVector,IsBool],0,
function(f,v,change)
#TODO: Do we really want to change the representation of 'v'?
#      The documentation of 'ImmutableVector' allows this.
#      However, the HPC GAP variant cannot do this,
#      and calls 'CopyToVectorRep' instead.
  ConvertToVectorRepNC(v,f);
  if change then
    MakeImmutable(v);
    return v;
  fi;
  return Immutable(v);
end);

InstallOtherMethod( ImmutableVector,"field,8bit",[IsField,Is8BitVectorRep],0,
function(f,v)
  if Q_VEC8BIT(v)<>Size(f) then
    TryNextMethod();
  fi;
  return Immutable(v);
end);

InstallOtherMethod( ImmutableVector,"field,gf2",[IsField,IsGF2VectorRep],0,
function(f,v)
  if 2<>Size(f) then
    TryNextMethod();
  fi;
  return Immutable(v);
end);

InstallOtherMethod( ImmutableVector,"fieldsize,8bit",[IsPosInt,Is8BitVectorRep],0,
function(f,v)
  if Q_VEC8BIT(v)<>f then
    TryNextMethod();
  fi;
  return Immutable(v);
end);

InstallOtherMethod( ImmutableVector,"fieldsize,gf2",[IsPosInt,IsGF2VectorRep],0,
function(f,v)
  if 2<>f then
    TryNextMethod();
  fi;
  return Immutable(v);
end);

InstallOtherMethod( ImmutableVector,"empty",[IsObject,IsEmpty],0,
function(f,v)
  return Immutable(v);
end);

#############################################################################
##
#M  MultVector( <vl>, <mul>)
##

InstallOtherMethod( MultVector, "for GF(2) vector and char 2 scalar",
        IsCollsElms, [IsGF2VectorRep and IsRowVector and IsMutable,
                IsFFE], 0,
        MULT_VECTOR_GF2VECS_2);

#############################################################################
##
#M  PositionNot( <vec>, GF2Zero )
#M  PositionNot( <vec>, GF2Zero, 0)
##
InstallOtherMethod( PositionNot, "for GF(2) vector and 0*Z(2)",
        IsCollsElms, [IsGF2VectorRep and IsRowVector , IsFFE and
                IsZero], 0,
        POSITION_NONZERO_GF2VEC);

InstallMethod( PositionNot, "for GF(2) vector and 0*Z(2) and offset",
        IsCollsElmsX, [IsGF2VectorRep and IsRowVector , IsFFE and
                IsZero, IsInt], 0,
        function(v,z,z1)
    return POSITION_NONZERO_GF2VEC3(v,z,z1);
end);

#############################################################################
##
#M  Append( <vecl>, <vecr> )
##

InstallMethod( Append, "for GF2 vectors",
        true, [IsGF2VectorRep and IsMutable and IsList,
               IsGF2VectorRep and IsList], 0,
        APPEND_GF2VEC);

#############################################################################
##
#M  ShallowCopy( <vec> ) . . . for GF2 vectors
##
InstallMethod( ShallowCopy,
        "for GF2 vectors",
        true, [ IsGF2VectorRep and IsList and IsRowVector ], 0,
        SHALLOWCOPY_GF2VEC);

#############################################################################
##
#M  PositionNonZero( <vec> )
##
InstallOtherMethod(PositionNonZero, "for GF(2) vector",true,
        [IsGF2VectorRep and IsRowVector],0,
  # POSITION_NONZERO_GF2VEC ignores the second argument
  v-> POSITION_NONZERO_GF2VEC(v,0));

InstallOtherMethod(PositionNonZero, "for GF(2) vector and offset",true,
        [IsGF2VectorRep and IsRowVector, IsInt],0,
        # POSITION_NONZERO_GF2VEC3 ignores the second argument
        function(v, from)
    return  POSITION_NONZERO_GF2VEC3(v,0,from);
end);

#############################################################################
##
#M  PositionNonZero( <vec> )
##
InstallOtherMethod(PositionNonZero,
  "General method for a row vector",
  true,[IsRowVector],0,
  function(vec)
  local i,z;
  if Length(vec)=0 then return 1;fi;
  z:=Zero(vec[1]);
  for i in [1..Length(vec)] do
    if vec[i]<>z then return i;fi;
  od;
  return Length(vec)+1;
end);


#############################################################################
##
#M  NumberFFVector(<<vec>,<sz>)
##
InstallMethod(NumberFFVector,"GF2-Vector",true,
  [IsGF2VectorRep and IsRowVector and IsFFECollection,IsPosInt],0,
function(v,n)
  if n<>2 then TryNextMethod();fi;
  return NUMBER_GF2VEC(v);
end);

#############################################################################
##
#M  NumberFFVector(<vec>,<sz>)
##
InstallMethod(NumberFFVector,"uncompressed vecffe",
  [IsRowVector and IsFFECollection,IsPosInt],
        function(v,n)
    local qels, sy, p, x;
    qels:= EnumeratorSorted( GF(n) );
    sy := 0;
    for x in v do
        p := Position(qels, x);
        if p = fail then
            Info(InfoWarning,2,
              "NumberFFVector: Vector not over specified field");
            return fail;
        fi;
        sy := n*sy + (p-1);
    od;
    return sy;
end);

#############################################################################
##
#M  IsSubset(<finfield>,<gf2vec>)
##
InstallMethod(IsSubset,"field, 8bit-vector",IsIdenticalObj,
  [ IsField and IsFinite and IsFFECollection,
    IsGF2VectorRep and IsRowVector and IsFFECollection],0,
function(F,v)
  # the family ensures the field is in the correct characteristic.
  return true;
end);


#############################################################################
##
#M  DefaultFieldOfMatrix( <ffe-mat> )
##
InstallMethod( DefaultFieldOfMatrix,
    "method for a matrix over GF(2)", true,
    [ IsMatrix and IsFFECollColl and IsGF2MatrixRep ], 0,
function( mat )
  return GF(2);
end );

#############################################################################
##
#M  DegreeFFE( <ffe-mat> )
##
InstallOtherMethod( DegreeFFE,
    "method for a matrix over GF(2)", true,
    [ IsMatrix and IsFFECollColl and IsGF2MatrixRep ], 0,
function( mat )
  return 1;
end );

#############################################################################
##
#M  DegreeFFE( <vector> )
##
InstallOtherMethod( DegreeFFE, "for GF(2) vectors", true,
    [ IsRowVector and IsFFECollection and IsGF2VectorRep ], 0, v->1);


#############################################################################
##
#M  LeftShiftRowVector( <vec>, <shift> )
##
InstallMethod( LeftShiftRowVector, "gf2 vector", true,
        [IsMutable and IsRowVector and IsGF2VectorRep,
         IsPosInt], 0,
        SHIFT_LEFT_GF2VEC);

#############################################################################
##
#M  RightShiftRowVector( <vec>, <shift>, <zero> )
##
InstallMethod( RightShiftRowVector, "gf2 vector, fill with zeros", IsCollsXElms,
        [IsMutable and IsRowVector and IsGF2VectorRep,
         IsPosInt,
         IsFFE and IsZero], 0,
        SHIFT_RIGHT_GF2VEC);

#############################################################################
##
#M  ShrinkRowVector( <vec> )

InstallMethod( ShrinkRowVector, "GF2 vector", true,
        [IsMutable and IsRowVector and IsGF2VectorRep ],
        0,
        function(vec)
    local r;
    r := RIGHTMOST_NONZERO_GF2VEC(vec);
    RESIZE_GF2VEC(vec, r);
end);

#############################################################################
##
#M  RemoveOuterCoeffs( <vec>, <zero> )
##

InstallMethod( RemoveOuterCoeffs, "gf2vec and zero", IsCollsElms,
        [ IsMutable and IsGF2VectorRep and IsRowVector, IsFFE and
          IsZero], 0,
        function (v,z)
    local shift;
    shift := POSITION_NONZERO_GF2VEC(v,z) -1;
    if shift <> 0 then
        SHIFT_LEFT_GF2VEC( v, shift);
    fi;
    if v <> [] then
        RESIZE_GF2VEC(v, RIGHTMOST_NONZERO_GF2VEC(v));
    fi;
    return shift;
end);

#############################################################################
##
#M  ProductCoeffs( <vec>, <len>, <vec>, <len>)
##
##

InstallMethod( ProductCoeffs, "GF2 vectors, kernel method", IsFamXFamY,
        [IsGF2VectorRep and IsRowVector, IsInt, IsGF2VectorRep and
         IsRowVector, IsInt ], 0,
        PROD_COEFFS_GF2VEC);

InstallOtherMethod( ProductCoeffs, "Gf2 vectors, kernel method (2 arg)",
        IsIdenticalObj,
        [IsGF2VectorRep and IsRowVector, IsGF2VectorRep and
         IsRowVector ], 0,
        function(v,w)
    return PROD_COEFFS_GF2VEC(v, Length(v), w, Length(w));
end);

#############################################################################
##
#M  ReduceCoeffs( <vec>, <len>, <vec>, <len>)
##
##

InstallMethod( ReduceCoeffs, "GF2 vectors, kernel method", IsFamXFamY,
        [IsGF2VectorRep and IsRowVector and IsMutable, IsInt, IsGF2VectorRep and
         IsRowVector, IsInt ], 0,
        REDUCE_COEFFS_GF2VEC);

InstallOtherMethod( ReduceCoeffs, "Gf2 vectors, kernel method (2 arg)",
        IsIdenticalObj,
        [IsGF2VectorRep and IsRowVector and IsMutable, IsGF2VectorRep and
         IsRowVector ], 0,
        function(v,w)
    return REDUCE_COEFFS_GF2VEC(v, Length(v), w, Length(w));
end);

#############################################################################
##
#M PowerModCoeffs( <vec1>, <len1>, <exp>, <vec2>, <len2> )
##

InstallMethod( PowerModCoeffs, "for gf2vectors", IsFamXYFamZ,
        [IsGF2VectorRep and IsRowVector, IsInt, IsPosInt,
         IsGF2VectorRep and IsRowVector, IsInt], 0,
        function( v, lv, exp, w, lw)

    local pow, lpow, bits, i;
    if exp = 1 then
        pow := ShallowCopy(v);
        ReduceCoeffs(pow,lv,w,lw);
        return pow;
    fi;
    pow := v;
    lpow := lv;
    bits := [];
    while exp > 0 do
        Add(bits, exp mod 2);
        exp := QuoInt(exp,2);
    od;
    bits := Reversed(bits);
    for i in [2..Length(bits)] do
        pow := PROD_COEFFS_GF2VEC(pow,lpow, pow, lpow);
        lpow := Length(pow);
        lpow := REDUCE_COEFFS_GF2VEC( pow, lpow, w, lw);
        if lpow = 0 then
            return pow;
        fi;
        if bits[i] = 1 then
            pow := PROD_COEFFS_GF2VEC(pow, lpow, v, lv);
            lpow := Length(pow);
            lpow := REDUCE_COEFFS_GF2VEC( pow, lpow, w, lw);
            if lpow = 0 then
                return pow;
            fi;
        fi;
    od;
    return pow;
end);

#############################################################################
##
#M  DomainForAction( <pnt>, <acts> )
##
InstallMethod(DomainForAction,"FFE vector/matrix",IsElmsCollCollsX,
  # for technical reasons a matrix list is not automatically
  # IsMatrixCollection -- thus we cannot use this filter here. AH

  #T this method is only installed for finite fields. There ought to be a
  #T method for finite rings and there could be one for infinite fields. AH
  [IsVector and IsFFECollection,IsList,IsFunction],0,
function(pnt,acts,act)
  if (not ForAll(acts,IsMatrix)) or
    (act<>OnPoints and act<>OnLines and act<>OnRight
                   and act<>OnSubspacesByCanonicalBasisConcatenations) or
     CollectionsFamily(CollectionsFamily(FamilyObj(pnt)))<>FamilyObj(acts) then
    TryNextMethod(); # strange operation, might extend the domain
  fi;
  return NaturalActedSpace(acts,[pnt]);
#  if Length(pnt)=0 or Length(acts)=0 then
#    return fail;
#  fi;
#  l:=Concatenation(acts);
#  Add(l,pnt);
#  f:=DefaultFieldOfMatrix(l);
#  if f = fail then
#    return fail;
#  fi;
#  return f^Length(pnt);
end);

#############################################################################
##
#M  DomainForAction( <pnt>, <acts> )
##
InstallMethod(DomainForAction,"matrix/matrix",IsElmsCollsX,
  # for technical reasons a matrix list is not automatically
  # IsMatrixCollection -- thus we cannot use this filter here. AH

  #T this method is only installed for finite fields. There ought to be a
  #T method for finite rings and there could be one for infinite fields. AH
  [IsMatrix and IsFFECollColl,IsList,IsFunction],0,
function(pnt,acts,act)
local l,f;
  if (not ForAll(acts,IsMatrix)) or
    (act<>OnPoints and act<>OnSubspacesByCanonicalBasis and act<>OnRight and act<>OnSets and
    act<>OnTuples) then
    TryNextMethod(); # strange operation, might extend the domain
  fi;
  l:=NaturalActedSpace(acts,pnt);
  f:=Size(LeftActingDomain(l));
  l:=Size(l);
  return rec(hashfun:=function(b)
             local h,i;
               h:=0;
               for i in b do
                 h:=h*l+NumberFFVector(i,f);
               od;
               return h;
              end);
end);

InstallMethod(DomainForAction,"vector/permgrp",true,
  [IsList,IsList,IsFunction],0,
function(pnt,acts,act)
  if (not (ForAll(acts,IsPerm) and ForAll(pnt,IsScalar)))
     or (act<>Permuted) then
    TryNextMethod(); # strange operation, might extend the domain
  fi;
  return DefaultField(pnt)^Length(pnt);
end);

#############################################################################
##
#M  SemiEchelonMat( <GF2 matrix> )
#M  SemiEchelonMatTransformation( <GF2 matrix> )
#M  SemiEchelonMatDestructive( <plain list of GF2 vectors> )
#M  SemiEchelonMatTransformationDestructive( <plain list of GF2 vectors> )
##
#

#
#  This is the rank by which we increase the GF2 kernel methods,
#  so that they get tried before the 8bit ones, as they will fall
#  through faster.
#
#
BindGlobal("GF2_AHEAD_OF_8BIT_RANK", 10);

#
# If mat is in the GF2 special representation, then we do
# have to copy it, but we know that the rows of the result will
# already be in GF2 special representation, so we skip the conversion
# step in the generic method
#


InstallMethod(SemiEchelonMat, "shortcut method for GF2 matrices",
        true,
        [ IsMatrix and IsGF2MatrixRep and IsFFECollColl ],
        0,
        function(mat)
    local res;
    res :=  SemiEchelonMatDestructive( List(mat, ShallowCopy) ) ;
    ConvertToMatrixRepNC(res.vectors,2);
    return res;
    end );

InstallMethod(SemiEchelonMatTransformation,
        "kernel method for plain lists of GF2 vectors",
        true,
        [ IsMatrix and IsFFECollColl and IsGF2MatrixRep],
        0,
        function(mat)
    local res;
    res := SemiEchelonMatTransformationDestructive( List( mat, ShallowCopy) );
    ConvertToMatrixRepNC(res.vectors,2);
    ConvertToMatrixRepNC(res.coeffs,2);
    ConvertToMatrixRepNC(res.relations,2);
    return res;
    end );


#
# The real kernel methods, which are destructive and want plain lists
# of GF2 vectors as their arguments, but will try next if they get other
# plain lists
#

InstallMethod(SemiEchelonMatDestructive,
        "kernel method for plain lists of GF2 vectors",
        true,
        [ IsPlistRep and IsMatrix and IsMutable and IsFFECollColl ],
        GF2_AHEAD_OF_8BIT_RANK,
        SEMIECHELON_LIST_GF2VECS);


InstallMethod(SemiEchelonMatTransformationDestructive,
        "kernel method for plain lists of GF2 vectors",
        true,
        [ IsMatrix and IsPlistRep and IsFFECollColl and IsMutable],
        GF2_AHEAD_OF_8BIT_RANK,
        SEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS);



#############################################################################
##
#M  TriangulizeMat( <plain list of GF2 vectors> )
##
##  The method will fall through if the matrix is not a plain list of
##  GF2 vectors

InstallMethod(TriangulizeMat,
        "kernel method for plain list of GF2 vectors",
        true,
        [IsMatrix and IsPlistRep and IsFFECollColl and IsMutable],
        GF2_AHEAD_OF_8BIT_RANK,
        TRIANGULIZE_LIST_GF2VECS);

##
#T Really should sort this one in the kernel
## but this should fix the major inefficiency for now
##


InstallMethod(TriangulizeMat,
        "for GF2 matrices",
        true,
        [IsMatrix and IsMutable and IsFFECollColl and IsGF2MatrixRep],
        0,
        function(m)
    local i,imms;
    PLAIN_GF2MAT(m);
    imms := [];
    for i in [1..Length(m)] do
        if not IsMutable(m[i]) then
            m[i] := ShallowCopy(m[i]);
            imms[i] := true;
        else
            imms[i] := false;
        fi;
    od;
    TRIANGULIZE_LIST_GF2VECS(m);
    for i in [1..Length(m)] do
        if not IsMutable(m[i]) then
            m[i] := ShallowCopy(m[i]);
            imms[i] := true;
        else
            imms[i] := false;
        fi;
    od;
    CONV_GF2MAT(m);
end);

#############################################################################
##
#M  DeterminantMatDestructive ( <plain list of GF2 vectors> )
##

InstallMethod(DeterminantMatDestructive,
        "kernel method for plain list of GF2 vectors",
        true,
        [IsMatrix and IsPlistRep and IsFFECollColl and IsMutable],
        GF2_AHEAD_OF_8BIT_RANK,
        DETERMINANT_LIST_GF2VECS);

#############################################################################
##
#M  RankMatDestructive ( <plain list of GF2 vectors> )
##


InstallOtherMethod(RankMatDestructive,
        "kernel method for plain list of GF2 vectors",
        [IsMatrix and IsPlistRep and IsFFECollColl and IsMutable],
        GF2_AHEAD_OF_8BIT_RANK,
        RANK_LIST_GF2VECS);


InstallMethod(NestingDepthM, [IsGF2MatrixRep], m->2);
InstallMethod(NestingDepthA, [IsGF2MatrixRep], m->2);
InstallMethod(NestingDepthM, [IsGF2VectorRep], m->1);
InstallMethod(NestingDepthA, [IsGF2VectorRep], m->1);

InstallMethod(PostMakeImmutable, [IsGF2MatrixRep],
        function(m)
    local i;
    for i in [2..m![1]] do
        MakeImmutable(m![i]);
    od;
end);

#############################################################################
##
#M  ZeroVector( len, <vector> )
##
InstallMethod( ZeroVector, "for an int and a gf2 vector",
  [IsInt, IsGF2VectorRep],
  function( len, v )
    return ZERO_GF2VEC_2(len);
  end );

InstallMethod( ZeroVector, "for an int and a gf2 matrix",
  [IsInt, IsGF2MatrixRep],
  function( len, m )
    return ZERO_GF2VEC_2(len);
  end );


#############################################################################
##
##  Stuff to adhere to new vector/matrix interface:
##
InstallMethod( BaseDomain, "for a gf2 vector",
  [ IsGF2VectorRep ], function( v ) return GF(2); end );
InstallMethod( BaseDomain, "for a gf2 matrix",
  [ IsGF2MatrixRep ], function( m ) return GF(2); end );
InstallMethod( NumberRows, "for a gf2 matrix",
  [ IsGF2MatrixRep ], m -> m![1]);
InstallMethod( NumberColumns, "for a gf2 matrix",
  [ IsGF2MatrixRep ], function( m ) return Length(m[1]); end );
# FIXME: this breaks down for matrices with 0 rows
InstallMethod( Vector, "for a list of gf2 elements and a gf2 vector",
  [ IsList and IsFFECollection, IsGF2VectorRep ],
  function( l, v )
    local r;
    r := ShallowCopy(l);
    ConvertToVectorRep(r,2);
    return r;
  end );

InstallMethodWithRandomSource( Randomize,
    "for a random source and a mutable gf2 vector",
    [ IsRandomSource, IsGF2VectorRep and IsMutable ],
  function( rs, v )
    local i;
    MultVector(v,0);
    for i in [1..Length(v)] do
        if Random(rs,0,1) = 1 then v[i] := Z(2); fi;
    od;
    return v;
  end );

InstallMethod( MutableCopyMatrix, "for a gf2 matrix",
  [ IsGF2MatrixRep ],
  function( m )
    local mm;
    mm := List(m,ShallowCopy);
    ConvertToMatrixRep(mm,2);
    return mm;
  end );

InstallMethod( MatElm, "for a gf2 matrix and two integers",
  [ IsGF2MatrixRep, IsPosInt, IsPosInt ],
  MAT_ELM_GF2MAT );
InstallMethod( SetMatElm, "for a gf2 matrix, two integers, and a ffe",
  [ IsGF2MatrixRep and IsMutable, IsPosInt, IsPosInt, IsFFE ],
  SET_MAT_ELM_GF2MAT );

InstallMethod( Matrix, "for a list of vecs, an integer, and a gf2 mat",
  [IsList, IsInt, IsGF2MatrixRep],
  function(l,rl,m)
    local i,li;
    if not IsList(l[1]) then
        li := [];
        for i in [1..QuoInt(Length(l),rl)] do
            li[i] := l{[(i-1)*rl+1..i*rl]};
        od;
    else
        li:= ShallowCopy(l);
    fi;
    # FIXME: Does not work for matrices m with no rows
    ConvertToMatrixRep(li,2);
    return li;
  end );

InstallMethod( ExtractSubMatrix, "for a gf2 matrix, and two lists",
  [IsGF2MatrixRep, IsList, IsList],
  function( m, rows, cols )
    local mm,r;
    mm := [];
    for r in rows do
        Add(mm, m![r+1]{cols});
    od;
    ConvertToMatrixRepNC(mm,2);
    return mm;
  end );

InstallMethod( CopySubVector, "for two gf2 vectors, and two ranges",
  [IsGF2VectorRep, IsGF2VectorRep and IsMutable, IsRange, IsRange],
        function( v, w, f, t )
    local l;
    l := Length(f);
    Assert(2, l = Length(t));
    if l <= 1 or (f[2] - f[1] = 1 and t[2] - t[1] = 1) then
        COPY_SECTION_GF2VECS(v,w,f[1],t[1],l);
    else
        TryNextMethod();
    fi;
  end );

  InstallMethod( CopySubVector, "for two gf2 vectors, and two lists",
  [IsGF2VectorRep, IsGF2VectorRep and IsMutable, IsList, IsList],
        function( v, w, f, t )
    w{t} := v{f};
  end );

InstallMethod( CopySubMatrix, "for two gf2 matrices, and four lists",
  [IsGF2MatrixRep, IsGF2MatrixRep, IsList, IsList, IsList, IsList],
        function( a, b, frows, trows, fcols, tcols )
    local   i;
    for i in [1..Length(frows)] do
        CopySubVector(a[frows[i]],b[trows[i]], fcols, tcols);
    od;
end );

InstallMethod( CopySubMatrix, "for two gf2 matrices, two lists and two ranges",
  [IsGF2MatrixRep, IsGF2MatrixRep, IsList, IsList, IsRange, IsRange],
        function( a, b, frows, trows, fcols, tcols )
    local   l,  i;
    l := Length(fcols);
    Assert(2, l = Length(tcols));
    if l <= 1 or (fcols[2] - fcols[1] = 1 and tcols[2] - tcols[1] = 1) then
        for i in [1..Length(frows)] do
            COPY_SECTION_GF2VECS(a[frows[i]],b[trows[i]],fcols[1],tcols[1],l);
        od;
    else
        TryNextMethod();
    fi;
end );



InstallMethodWithRandomSource( Randomize,
    "for a random source and a mutable gf2 matrix",
    [ IsRandomSource, IsGF2MatrixRep and IsMutable ],
  function( rs, m )
    local v;
    for v in m do Randomize( rs, v ); od;
    return m;
  end );

InstallMethod( Unpack, "for a gf2 matrix",
  [IsGF2MatrixRep],
  function( m )
    return List(m,AsPlist);
  end );
InstallMethod( Unpack, "for a gf2 vector",
  [IsGF2VectorRep],
  AsPlist );

InstallOtherMethod( KroneckerProduct, "for two gf2 matrices",
  [IsGF2MatrixRep and IsMatrix, IsGF2MatrixRep and IsMatrix],
  KRONECKERPRODUCT_GF2MAT_GF2MAT );

InstallMethod( ConstructingFilter, "for a gf2 vector",
  [ IsGF2VectorRep ], function(v) return IsGF2VectorRep; end );
InstallMethod( ConstructingFilter, "for a gf2 matrix",
  [ IsGF2MatrixRep ], function(v) return IsGF2MatrixRep; end );

InstallMethod( BaseField, "for a compressed gf2 matrix",
  [IsGF2MatrixRep], function(m) return GF(2); end );
InstallMethod( BaseField, "for a compressed gf2 vector",
  [IsGF2VectorRep], function(v) return GF(2); end );

InstallTagBasedMethod( NewVector,
  IsGF2VectorRep,
  function( filter, f, l )
    if Size(f) <> 2 then Error("IsGF2VectorRep only supported over GF(2)"); fi;
    return CopyToVectorRep(l,2);
  end );

InstallTagBasedMethod( NewZeroVector,
  IsGF2VectorRep,
  function( filter, f, i )
    if Size(f) <> 2 then Error("IsGF2VectorRep only supported over GF(2)"); fi;
    return ZERO_GF2VEC_2(i);
  end );

InstallTagBasedMethod( NewMatrix,
  IsGF2MatrixRep,
  function( filter, f, rl, l )
    local m;
    if Size(f) <> 2 then Error("IsGF2MatrixRep only supported over GF(2)"); fi;
    m := List(l,ShallowCopy);
    ConvertToMatrixRep(m,2);
    return m;
  end );

# This is faster than the default method.
InstallTagBasedMethod( NewZeroMatrix,
  IsGF2MatrixRep,
  function( filter, f, rows, cols )
    local m,i;
    if Size(f) <> 2 then Error("IsGF2MatrixRep only supported over GF(2)"); fi;
    if rows = 0 then
        Error("IsGF2MatrixRep with zero rows not yet supported");
    fi;
    m := EmptyPlist(rows);
    for i in [1..rows] do
        m[i] := ZERO_GF2VEC_2(cols);
    od;
    ConvertToMatrixRepNC(m,2);
    return m;
  end );

InstallMethod( ChangedBaseDomain, "for a gf2 vector and a finite field",
  [ IsGF2VectorRep, IsField and IsFinite ],
  function( v, f )
    local w;
    w := Unpack(v);
    ConvertToVectorRep(w,Size(f));
    return w;
  end );

InstallMethod( ChangedBaseDomain, "for a gf2 matrix and a finite field",
  [ IsGF2MatrixRep, IsField and IsFinite ],
  function( v, f )
    local w,i;
    w := [];
    for i in [1..Length(v)] do
        Add(w,ChangedBaseDomain(v[i],f));
    od;
    ConvertToMatrixRep(w,Size(f));
    return w;
  end );

InstallMethod( CompatibleVector, "for a gf2 matrix",
  [ IsGF2MatrixRep ],
  function( m )
    # This will break for a matrix with no rows
    return ShallowCopy(m[1]);
  end );

InstallMethod( CompatibleVectorFilter,
  "for a gf2 matrix",
  [ IsGF2MatrixRep ],
  M -> IsGF2VectorRep );

InstallMethod( WeightOfVector, "for a gf2 vector",
  [ IsGF2VectorRep ],
  function( v )
    return WeightVecFFE(v);
  end );

InstallMethod( DistanceOfVectors, "for two gf2 vectors",
  [ IsGF2VectorRep, IsGF2VectorRep ],
  function( v, w )
    return DistanceVecFFE(v,w);
  end );
