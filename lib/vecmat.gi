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
##  with GF2 vectors and matrices.
##
Revision.vecmat_gi :=
    "@(#)$Id$";

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
InstallValue( TYPE_LIST_GF2VEC,
  NewType( CollectionsFamily( FFEFamily(2) ),
           IsHomogeneousList and IsListDefault and IsNoImmediateMethodsObject
           and IsMutable and IsCopyable and IsGF2VectorRep )
);


#############################################################################
##
#V  TYPE_LIST_GF2VEC_IMM  . . . . . . . . . . . type of immutable GF2 vectors
##
InstallValue( TYPE_LIST_GF2VEC_IMM,
  NewType( CollectionsFamily( FFEFamily(2) ),
          IsHomogeneousList and IsListDefault and IsNoImmediateMethodsObject 
           and IsCopyable and IsGF2VectorRep )
);

#############################################################################
##
#V  TYPE_LIST_GF2VEC_IMM_LOCKED  . . . . type of immutable locked GF2 vectors
##
InstallValue( TYPE_LIST_GF2VEC_IMM_LOCKED,
  NewType( CollectionsFamily( FFEFamily(2) ),
          IsHomogeneousList and IsListDefault and IsNoImmediateMethodsObject 
           and IsCopyable and IsGF2VectorRep and IsLockedRepresentationVector)
);


#############################################################################
##
#V  TYPE_LIST_GF2MAT  . . . . . . . . . . . . .  type of mutable GF2 matrices
##
InstallValue( TYPE_LIST_GF2MAT,
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
InstallValue( TYPE_LIST_GF2MAT_IMM,
  NewType( CollectionsFamily(CollectionsFamily(FFEFamily(2))),
          IsMatrix and IsListDefault and IsCopyable and IsGF2MatrixRep
          and IsNoImmediateMethodsObject 
          and IsSmallList and IsFFECollColl and
          HasIsRectangularTable and IsRectangularTable)
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
InstallMethod( AdditiveInverseOp,
    "for GF2 vector",
    true,
    [ IsRowVector and IsListDefault and IsGF2VectorRep ],
    0,
    ShallowCopy );


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
        return Zero(b);
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
        return Zero(a);
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
#M  ShrinkCoeffs( <gf2vec> )  . . . . . . . . . . . . . . shrink a GF2 vector
##
InstallMethod( ShrinkCoeffs,
    "for GF2 vector",
    true,
    [ IsMutable and IsRowVector and IsGF2VectorRep ],
    0,
    SHRINKCOEFFS_GF2VEC );

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


#############################################################################
##
#M  AdditiveInverseOp( <gf2mat> ) .  mutable additive inverse of a GF2 matrix
##
InstallMethod( AdditiveInverseOp,
    "for GF2 matrix",
    true,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep ],
        0,
        SHALLOWCOPY_GF2MAT);


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
    INV_GF2MAT );


#############################################################################
##
#M  OneOp( <gf2mat> ) . . . . . . . . . . . . . . mutable identity GF2 matrix
##
##  A fully mutable GF2 matrix cannot be in the special compressed rep.
##  so return it as a plain list
##
InstallMethod( OneOp,
    "for GF2 Matrix",
    true,
    [ IsOrdinaryMatrix and IsGF2MatrixRep and IsMultiplicativeElementWithOne],
    0,

function( mat )
    local   new,  zero,  i,  line, o, len;
    
    new := [];
    len := Length(mat);
    if len > 0 then
        o := Z(2);
        zero := Zero(mat[1]);
        for i in [ 1 .. len ]  do
            line := ShallowCopy(zero);
            line[i] := o;
            Add( new, line );
        od;
    fi;
    return new;
end );


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
    local   new,  zero,  i,  line, o;

    new := [ Length(mat) ];
    zero := Zero(mat[1]);
    o := Z(2);
    for i in [ 1 .. new[1] ]  do
        line := ShallowCopy(zero);
        line[i] := o;
        MakeImmutable( line );
        SetFilterObj(line, IsLockedRepresentationVector );
        Add( new, line );
    od;
    Objectify( TYPE_LIST_GF2MAT_IMM, new );
    return new;
end );


#############################################################################
##
#M  ZeroOp( <gf2mat> )  . . . . . . . . . . . . . . . mutable zero GF2 matrix
##
## Once again, this cannot be a compressed matrix
##
InstallMethod( ZeroOp,
    "for GF2 Matrix",
    true,
    [ IsMatrix and IsListDefault and IsGF2MatrixRep ],
    0,

function( mat )
    local   new,  zero,  i, len;

    new := [ ];
    len := Length(mat);
    if 0 < len   then
        zero := ZeroOp( mat[1] );
        for i in [ 1 .. len ]  do
            Add( new, ShallowCopy( zero ) );
        od;
    fi;
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

InstallMethod(\*, "For a GF2 vector and a compatible matrix",
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
#F  ConvertToVectorRep(<v>)
##

InstallGlobalFunction(ConvertToVectorRep,function( arg )
    local x, gf2, gfq, char,deg,q,p,mindeg, v, field ;
    if Length(arg) < 1 then
        Error("ConvertToVectorRep: one or two arguments required");
    fi;
    v := arg[1];
    if (not IsRowVector(v)) or Length(v)=0  then
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
        return q;    fi;
    
    # otherwise, if there is a field, we go to work
    #
    if Length(arg) > 1 then
        field := arg[2];
        if field=2 or (IsField(field) and Size(field)=2) then
            Assert(2, ForAll(v, elm -> elm in GF(2)));
            CONV_GF2VEC(v);
            q := 2;
        else
            if IsPosInt(field) then
                q:=field;
                Assert(2, ForAll(v, elm -> elm in GF(q)));
            elif IsFFECollection(field) and IsField(field) then
                q := Size(field);
                Assert(2, ForAll(v, elm -> elm in field));
            else
                q := fail;      
            fi;
            
            if q <> fail and q > 2 and q <= 256 then
                CONV_VEC8BIT(v,q);
            else
                XTNUM_OBJ(v);
                return true;
            fi;
        fi;
        return q;
    fi;
    
    # Here we were not told what field we are over, so we work it out
    
    # we may already be in a packed rep. If so, do nothing  
    if IsGF2VectorRep(v) then
        return 2;
    elif Is8BitVectorRep(v) then
        return Q_VEC8BIT(v);
    fi;
    
    # otherwisescan the vector to see if we can do anything
    gf2 := true;
    gfq := true;
    p := 0;
    for x in v do
        if not IsFFE(x) then
            return fail;
        fi;
        if gf2 or gfq then
            char := Characteristic(x);
            deg := DegreeFFE(x);
            
            # the tests for GF(2) are simple
            if gf2 and (char <> 2 or deg <> 1) then
                gf2 := false;
            fi;
            
            if gfq then
                if not IsInternalRep(x) then
                    gfq := false;
                elif p = 0 then
                    p := char;
                    mindeg := deg;
                    if p^deg > 256 then
                        gfq := false;
                    fi;
                elif p <> char then
                    gfq := false;
                elif mindeg mod deg <> 0 then
                    mindeg := Lcm(mindeg,deg);
                    if p^mindeg > 256 then
                        gfq := false;
                    fi;
                fi;
            fi;
        fi;
    od;
    
    if gf2 then
        ConvertToGF2VectorRep(v);
        return 2; # we need this in `ConvertToMatrixRep' to know whether we
        # may create a GF-2 matrix.
    elif gfq  then
        CONV_VEC8BIT(v, p^mindeg);
        return Q_VEC8BIT(v);
    else
        # force the kernel to note that this is a FFE vector
        XTNUM_OBJ(v);
    fi;
    return true;
end);

#############################################################################
##
#F  ConvertToMatrixRep(<v>)
##
#InstallGlobalFunction(ConvertToMatrixRep,function(arg)
#    local m;
#    m:=arg[1];
#    if IsGF2MatrixRep(m) then
#        return true;
#    fi;
#    if not IsMatrix(m) or Length(m)=0 then
#        return fail;
#    fi;
#    
#    # enforce to run `ConvertToVectorRep' over all vectors to make them
#    # compressed.
#    if Length(arg)=1 then
#        if ForAny(List(m,i->ConvertToVectorRep(i)),i->i<>2) then
#            return fail;
#        fi;
#    else
#        if ForAny(List(m,i->ConvertToVectorRep(i,arg[2])),i->i<>2) then
#            return fail;
#        fi;
#    fi;
#    if IsMutable(m) and ForAny(m, IsMutable) then
#        return fail;
#    fi;
#    CONV_GF2MAT(m);
#    return true;
#end);

#############################################################################
##
#F  ConvertedMatrix( <field>, <matrix> [,<imm>] ) 
##
InstallGlobalFunction( ConvertedMatrix, function(arg)
local field,matrix,i,sf,rep,ind,ind2;
  field:=arg[1];
  matrix:=arg[2];
  if IsInt(field) then
    sf:=field;
  else
    sf:=Size(field);
  fi;

  # the representation we want the rows to be in
  if sf=2 then
    rep:=IsGF2VectorRep;
  elif sf<=256 then
    rep:=function(v) return Is8BitVectorRep(v) and Q_VEC8BIT(v) = sf; end;
  else
    rep:=IsPlistRep;
  fi;

  # get the indices of the rows that need changing the representation.
  ind:=[];
  ind2:=[];
  for i in [1..Length(matrix)] do
    if not rep(matrix[i]) then
      Add(ind,i);
      if IsLockedRepresentationVector(matrix[i]) then
        Add(ind2,i);
      fi;
    fi;
  od;

  if Length(ind)>0 then
    if Length(ind2)>0 then
      # some rows don't want to change, rebuild the matrix
      matrix:=ShallowCopy(matrix);
      for i in ind2 do
        matrix[i]:=ShallowCopy(matrix[i]);
      od;
    elif sf>256 then
      matrix:=ShallowCopy(matrix); # we will substitute rows
    fi;

    # change the rows that need changing
    for i in ind do
      if sf<=256 then
        ConvertToVectorRep(matrix[i],sf);
      else
        matrix[i]:=List(matrix[i],j->j); # plist conversion
      fi;
    od;
  fi;
  if Length(arg)>2 and arg[3]=true then
    MakeImmutable(matrix);
  fi;
  ConvertToMatrixRep(matrix,field);
  return matrix;
end );

#############################################################################
##
#F  ImmutableMatrix( <field>, <matrix> ) . convert into "best" representation
##
InstallGlobalFunction( ImmutableMatrix, function( field, matrix )
  return ConvertedMatrix(field,matrix,true);
end);

#############################################################################
##
#M  PlainListCopyOp( <v> )
##

InstallMethod( PlainListCopyOp, "for a GF2 vector",
        true, [IsGF2VectorRep and IsSmallList ],
        0, function( v )
    PLAIN_GF2VEC(v);
    return v;
end);

#############################################################################
##
#M  PlainListCopyOp( <m> )
##

InstallMethod( PlainListCopyOp, "for a GF2 matrix",
        true, [IsSmallList and IsGF2MatrixRep ],
        0, function( m )
    PLAIN_GF2MAT(m);
    return m;
end);


#############################################################################
##
#M  MultRowVector( <vl>, <mul>)
##

InstallOtherMethod( MultRowVector, "for GF(2) vector and char 2 scalar",
        IsCollsElms, [IsGF2VectorRep and IsRowVector and IsMutable,
                IsFFE], 0,
        MULT_ROW_VECTOR_GF2VECS_2);

#############################################################################
##
#M  PositionNot( <vec>, GF2Zero )
#M  PositionNot( <vec>, GF2Zero, 0)
##
InstallOtherMethod( PositionNot, "for GF(2) vector and 0*Z(2)",
        IsCollsElms, [IsGF2VectorRep and IsRowVector , IsFFE and
                IsZero], 0,
        POSITION_NONZERO_GF2VEC);

InstallMethod( PositionNot, "for GF(2) vector and 0*Z(2) and 0",
        IsCollsElmsX, [IsGF2VectorRep and IsRowVector , IsFFE and
                IsZero, IsZero and IsInt], 0,
        function(v,z,z1) 
    return POSITION_NONZERO_GF2VEC(v,z); 
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
#M  PositionCanonical( <list>, <obj> )  . .  for GF2 matrices
##
InstallMethod( PositionCanonical,
    "for internally represented lists, fall back on `Position'",
    true, # the list may be non-homogeneous.
    [ IsList and IsGF2MatrixRep, IsObject ], 0,
    function( list, obj )
    return Position( list, obj, 0 );
end );

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
InstallMethod(PositionNonZero, "for GF(2) vector",true,
        [IsGF2VectorRep and IsRowVector],0,
  # POSITION_NONZERO_GF2VEC ignores the second argument
  v-> POSITION_NONZERO_GF2VEC(v,0)); 

#############################################################################
##
#M  PositionNonZero( <vec> )
##
InstallMethod(PositionNonZero,
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
#M  NumberFFVector(<<vec>,<sz>)
##
InstallMethod(NumberFFVector,"uncompressed vecffe",true,
  [IsRowVector and IsFFECollection,IsPosInt],0,
        function(v,n)
    local qels, sy, p, x;
    qels := AsSSortedList(GF(n));
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
InstallMethod(DomainForAction,"vector/matrix",IsElmsCollColls,
  # for technical reasuns a matrix list is not automatically
  # IsMatrixCollection -- thus we cannot use this filter here. AH
  [IsVector,IsList],0,
function(pnt,acts)
local l,f;
  if not ForAll(acts,IsMatrix) then
    TryNextMethod();
  fi;
  if Length(pnt)=0 or Length(acts)=0 then
    return fail;
  fi;
  l:=Concatenation(acts);
  Add(l,pnt);
  f:=DefaultFieldOfMatrix(l);
  if f = fail then
    return fail;
  fi;
  return f^Length(pnt);
end);

#############################################################################
##
#E
##
