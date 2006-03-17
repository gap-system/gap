############################################################################
##
#W  vec8bit.gi                   GAP Library                     Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file mainly installs the kernel methods for 8 bit vectors
##
Revision.vec8bit_gi :=
    "@(#)$Id$";

#############################################################################
##
#V  `TYPES_VEC8BIT . . . . . . . . prepared types for compressed GF(q) vectors
##
##  A length 2 list of length 257 lists. TYPES_VEC8BIT[1][q] will be the type
##  of mutable vectors over GF(q), TYPES_VEC8BIT[2][q] is the type of 
##  immutable vectors and TYPES_VEC8BIT[3][q] the type of locked vectors
##  The 257th position is bound to 1 to stop the lists
##  shrinking.
##
##  It is accessed directly by the kernel, so the format cannot be changed
##  without changing the kernel.
##

InstallValue(TYPES_VEC8BIT , [[],[], [], []]);
TYPES_VEC8BIT[1][257] := 1;
TYPES_VEC8BIT[2][257] := 1;
TYPES_VEC8BIT[3][257] := 1;
TYPES_VEC8BIT[4][257] := 1;


#############################################################################
##
#F  TYPE_VEC8BIT( <q>, <mut> ) . .  computes type of compressed GF(q) vectors
##
##  Normally called by the kernel, caches results in TYPES_VEC8BIT,
##  which is directly accessed by the kernel
##

InstallGlobalFunction(TYPE_VEC8BIT,
  function( q, mut)
    local col,filts;
    if mut then col := 1; else col := 2; fi;
    if not IsBound(TYPES_VEC8BIT[col][q]) then
        filts := IsHomogeneousList and IsListDefault and IsCopyable and
                 Is8BitVectorRep and IsSmallList and
                 IsNoImmediateMethodsObject and
                 IsRingElementList and HasLength;
        if mut then filts := filts and IsMutable; fi;
        TYPES_VEC8BIT[col][q] := NewType(FamilyObj(GF(q)),filts);
    fi;
    return TYPES_VEC8BIT[col][q];
end);

InstallGlobalFunction(TYPE_VEC8BIT_LOCKED,
  function( q, mut)
    local col,filts;
    if mut then col := 3; else col := 4; fi;
    if not IsBound(TYPES_VEC8BIT[col][q]) then
        filts := IsHomogeneousList and IsListDefault and IsCopyable and
                 Is8BitVectorRep and IsSmallList and
                 IsNoImmediateMethodsObject and
                 IsLockedRepresentationVector and
                 IsRingElementList and HasLength;
        if mut then filts := filts and IsMutable; fi;
        TYPES_VEC8BIT[col][q] := NewType(FamilyObj(GF(q)),filts);
    fi;
    return TYPES_VEC8BIT[col][q];
end);

#############################################################################
##
#V  TYPE_FIELDINFO_8BIT type of the fieldinfo bags
##
##  These bags are created by the kernel and accessed by the kernel. The type
##  doesn't really say anything, because there are no applicable operations.
##

InstallValue( TYPE_FIELDINFO_8BIT,
  NewType(NewFamily("FieldInfo8BitFamily", IsObject),
          IsObject and IsDataObjectRep));

#############################################################################
##
#M  Length( <vec> )
##

InstallMethod( Length, "For a compressed VecFFE", 
        true, [IsList and Is8BitVectorRep], 0, LEN_VEC8BIT);

#############################################################################
##
#M  <vec> [ <pos> ]
##

InstallMethod( \[\],  "For a compressed VecFFE", 
        true, [IsList and Is8BitVectorRep, IsPosInt], 0, ELM_VEC8BIT);

#############################################################################
##
#M  <vec> [ <pos> ] := <val>
##
##  This may involve turning <vec> into a plain list, if <val> does
##  not lie in the appropriate field.
##
##  <vec> may also be converted back into vector rep over a bigger field.
##
               
InstallMethod( \[\]\:\=,  "For a compressed VecFFE", 
        true, [IsMutable and IsList and Is8BitVectorRep, IsPosInt, IsObject], 
        0, ASS_VEC8BIT);

#############################################################################
##
#M  Unbind( <vec> [ <pos> ] )
##
##  Unless the last position is being unbound, this will result in <vec>
##  turning into a plain list
##

InstallMethod( Unbind\[\], "For a compressed VecFFE",
        true, [IsMutable and IsList and Is8BitVectorRep, IsPosInt],
        0, UNB_VEC8BIT);

#############################################################################
##
#M  ViewObj( <vec> )
##
##  Up to length 10, GF(q) vectors are viewed in full, over that a 
##  description is printed
##

InstallMethod( ViewObj, "For a compressed VecFFE",
        true, [Is8BitVectorRep and IsSmallList], 0,
        function( vec )
    local len;
    len := LEN_VEC8BIT(vec);
    if (len = 0 or len > 10) then
        Print("< ");
        if not IsMutable(vec) then
            Print("im");
        fi;
        Print("mutable compressed vector length ",
              LEN_VEC8BIT(vec)," over GF(",Q_VEC8BIT(vec),") >");
    else
        PrintObj(vec);
    fi;
end);

#############################################################################
##
#M  PrintObj( <vec> )
##
##  Same method as for lists in internal rep. 
##

InstallMethod( PrintObj, "For a compressed VecFFE",
        true, [Is8BitVectorRep and IsSmallList], 0,
        function( vec )
    local i,l;
    Print("\>\>[ \>\>");
    l := Length(vec);
    if l <> 0 then
        PrintObj(vec[1]);
        for i in [2..l] do
            Print("\<,\<\>\> ");
            PrintObj(vec[i]);
        od;
    fi;
    Print(" \<\<\<\<]");
end);

#############################################################################
##
#M  ShallowCopy(<vec>)
##
##  kernel method produces a copy in the same representation
##

InstallMethod(ShallowCopy, "For a compressed VecFFE",
        true, [Is8BitVectorRep and IsSmallList], 0,
        SHALLOWCOPY_VEC8BIT);


#############################################################################
##
#M  <vec1> + <vec2>
##
##  The method installation enforced same
##  characteristic. Compatability of fields and vector lengths is
##  handled in the method

InstallMethod( \+, "For two 8 bit vectors in same characteristic",
        IsIdenticalObj, [IsRowVector and Is8BitVectorRep,
                IsRowVector and Is8BitVectorRep], 0,
        SUM_VEC8BIT_VEC8BIT);

InstallMethod( \+, "For a GF2 vector and an 8 bit vector of char 2",
        IsIdenticalObj, [IsRowVector  and IsGF2VectorRep,
                IsRowVector and Is8BitVectorRep], 0,
        function(v,w)
    if IsLockedRepresentationVector(v) then
        TryNextMethod();
    else
        ConvertToVectorRepNC(v,GF(Q_VEC8BIT(w)));
        return v+w;
    fi;
end);

InstallMethod( \+, "For an 8 bit vector of char 2 and a GF2 vector",
        IsIdenticalObj, [IsRowVector and Is8BitVectorRep,
                IsRowVector and IsGF2VectorRep ], 0,
        function(w,v)
    if IsLockedRepresentationVector(v) then
        TryNextMethod();
    else
        ConvertToVectorRepNC(v,GF(Q_VEC8BIT(w)));
        return w+v;
    fi;
end);

#############################################################################
##
#M  `PlainListCopyOp( <vec> ) 
##
##  Make the vector into a plain list (in place)
##

InstallMethod( PlainListCopyOp, "For an 8 bit vector",
        true, [IsSmallList and Is8BitVectorRep], 0,
        function (v)
    PLAIN_VEC8BIT(v);
    return v;
end);

#############################################################################
##
#M  ELM0_LIST( <vec> ) 
##
##  alternatibe element access interface, returns fail when unbound
##

InstallMethod(ELM0_LIST, "For an 8 bit vector",
        true, [IsList and Is8BitVectorRep, IsPosInt], 0,
        ELM0_VEC8BIT);

#############################################################################
##
#M  DegreeFFE( <vector> )
##
BindGlobal("Q_TO_DEGREE", # discrete logarithm list
  [0,1,1,2,1,0,1,3,2,0,1,0,1,0,0,4,1,0,1,0,0,0,1,0,2,0,3,0,1,0,1,5,0,0,0,0,
  1,0,0,0,1,0,1,0,0,0,1,0,2,0,0,0,1,0,0,0,0,0,1,0,1,0,0,6,0,0,1,0,0,0,1,0,
  1,0,0,0,0,0,1,0,4,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,
  1,0,0,0,1,0,0,0,0,0,0,0,2,0,0,0,3,0,1,7,0,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,
  0,0,0,0,1,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,1,0,2,0,0,0,1,0,0,0,0,0,1,0,
  1,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,
  0,0,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,0,0,1,0,1,0,5,0,0,0,0,0,0,0,1,0,
  0,0,0,8]);

InstallOtherMethod( DegreeFFE, "for 8 bit vectors", true,
    [ IsRowVector and IsFFECollection and Is8BitVectorRep], 0,
function( vec )
local q, deg, i, maxdeg;
  q:=Q_VEC8BIT(vec);
  maxdeg:=Q_TO_DEGREE[q]; 
  # the degree could be smaller. Check or prove.
  if Length(vec) = 0 then
      return 0;
  fi;
  deg := DegreeFFE( vec[1] );
  for i  in [ 2 .. Length( vec ) ]  do
    deg := LcmInt( deg, DegreeFFE( vec[i] ) );
    if deg=maxdeg then 
        return deg; 
    fi;
  od;
  return deg;
end );

#############################################################################
##
#M  <vec>{<poss>}
##
##  multi-element access
##
InstallMethod(ELMS_LIST, "For an 8 bit vector and a plain list",
        true, [IsList and Is8BitVectorRep, 
               IsPlistRep and IsDenseList ], 0,
        ELMS_VEC8BIT);

InstallMethod(ELMS_LIST, "For an 8 bit vector and a range",
        true, [IsList and Is8BitVectorRep, 
               IsRange and IsInternalRep ], 0,
        ELMS_VEC8BIT_RANGE);

#############################################################################
##
#M  <vec>*<ffe>
##

InstallMethod(\*, "For an 8 bit vector and an FFE",
        IsCollsElms, [IsRowVector and Is8BitVectorRep,
                IsFFE and IsInternalRep], 0,
        PROD_VEC8BIT_FFE);

#############################################################################
##
#M  <vec>*<mat>
##

InstallMethod(\*, "For an 8 bit vector and a compatible matrix",
        IsElmsColls, [IsRowVector and Is8BitVectorRep and IsSmallList
                and IsRingElementList,
                IsRingElementTable and IsPlistRep], 0,
        PROD_VEC8BIT_MATRIX);

#############################################################################
##
#M  \*( <ffe>, <gf2vec> ) . . . . . . . . . . . product of FFE and GF2 vector
##
##  This is here to catch the case of an element in GF(2^k) 1 < k <= 8,
##  in which case we can convert to an 8 bit vector. There is a
##  higher-priority method in vecmat.gi which handles GF(2) elements.
##  
InstallMethod( \*,
    "for FFE and GF2 vector",
    IsElmsColls,
    [ IsFFE,
      IsRingElementList and IsRowVector and IsGF2VectorRep  ],
    0,

function( a, b )
    if DegreeFFE(a) > 8 or IsLockedRepresentationVector(b) then
        TryNextMethod();
    else
        ConvertToVectorRepNC(b,Field(a));
        return a*b;
    fi;
end );

#############################################################################
##
#M <ffe>*<vec>
##

InstallMethod(\*, "For an FFE and an 8 bit vector ",
        IsElmsColls, [IsFFE and IsInternalRep, 
                IsRowVector and Is8BitVectorRep], 
        0,
        PROD_FFE_VEC8BIT);

#############################################################################
##
#M  \*( <ffe>, <gf2vec> ) . . . . . . . . . . . product of FFE and GF2 vector
##
##  This is here to catch the case of an element in GF(2^k) 1 < k <= 8,
##  in which case we can convert to an 8 bit vector. There is a
##  higher-priority method in vecmat.gi which handles GF(2) elements.
##
InstallMethod( \*,
    "for FFE and GF2 vector",
    IsElmsColls,
    [ IsFFE,
      IsRingElementList and IsRowVector and IsGF2VectorRep ],
    0,

function( b, a )
    if DegreeFFE(b) > 8 or IsLockedRepresentationVector(a) then
        TryNextMethod();
    else
        ConvertToVectorRepNC(a,Field(b));
        return b*a;
    fi;
end );


#############################################################################
##
#M  <vecl> - <vecr>
##
InstallMethod(\-, "For two 8bit vectors",
        IsIdenticalObj, [IsRowVector and Is8BitVectorRep,
                IsRowVector and Is8BitVectorRep], 
        0,
        DIFF_VEC8BIT_VEC8BIT );

InstallMethod( \-, "For a GF2 vector and an 8 bit vector of char 2",
        IsIdenticalObj, [IsRowVector and IsGF2VectorRep ,
                IsRowVector and Is8BitVectorRep], 0,
        function(v,w)
    if IsLockedRepresentationVector(v) then
        TryNextMethod();
    else
        ConvertToVectorRepNC(v,GF(Q_VEC8BIT(w)));
        return v-w;
    fi;
end);

InstallMethod( \-, "For an 8 bit vector of char 2 and a GF2 vector",
        IsIdenticalObj, [IsRowVector and Is8BitVectorRep ,
                IsRowVector and IsGF2VectorRep], 0,
        function(w,v)
    if IsLockedRepresentationVector(v) then
        TryNextMethod();
    else
        ConvertToVectorRepNC(v,GF(Q_VEC8BIT(w)));
        return w-v;
    fi;
end);

#############################################################################
##
#M  -<vec>
##

InstallMethod( AdditiveInverseOp, "For an 8 bit vector",
        true, [IsRowVector and Is8BitVectorRep],
        0,
        AINV_VEC8BIT_MUTABLE);

#############################################################################
##
#M  -<vec>
##

InstallMethod( AdditiveInverseSameMutability, "For an 8 bit vector",
        true, [IsRowVector and Is8BitVectorRep],
        0,
        AINV_VEC8BIT_SAME_MUTABILITY );

#############################################################################
##
#M  -<vec>
##

InstallMethod( AdditiveInverseImmutable, "For an 8 bit vector",
        true, [IsRowVector and Is8BitVectorRep],
        0,
        AINV_VEC8BIT_IMMUTABLE );

#############################################################################
##
#M  ZeroOp( <vec> )
##
##  A  mutable zero vector of the same field and length 
##

InstallMethod( ZeroOp, "For an 8 bit vector",
        true, [IsRowVector and Is8BitVectorRep],
        0,
        ZERO_VEC8BIT);

#############################################################################
##
#M  ZEROOp( <vec> )
##
##  A  zero vector of the same field and length and mutability
##

InstallMethod( ZeroSameMutability, "For an 8 bit vector",
        true, [IsRowVector and Is8BitVectorRep],
        0,
        function(v)
    local z;
    z := ZERO_VEC8BIT(v);
    if not IsMutable(v) then
        MakeImmutable(z);
    fi;
    return z;
end );

#############################################################################
##
#M  <vec1> = <vec2>
##

InstallMethod( \=, "For 2 8 bit vectors",
        IsIdenticalObj, [IsRowVector and Is8BitVectorRep,
                IsRowVector and Is8BitVectorRep],
        0,
        EQ_VEC8BIT_VEC8BIT);

#############################################################################
##
#M  <vec1> < <vec2>
##
##  Usual lexicographic ordering
##

InstallMethod( \<, "For 2 8 bit vectors",
        IsIdenticalObj, [IsRowVector and Is8BitVectorRep,
                IsRowVector and Is8BitVectorRep],
        0,
        LT_VEC8BIT_VEC8BIT);

#############################################################################
##
#M  <vec1>*<vec2>
##
##  scalar product
#'
InstallMethod( \*, "For 2 8 bit vectors",
        IsIdenticalObj, [IsRingElementList and Is8BitVectorRep,
                IsRingElementList and Is8BitVectorRep],
        0,
        PROD_VEC8BIT_VEC8BIT);

InstallMethod( \*, "For a GF2 vector and an 8 bit vector of char 2",
        IsIdenticalObj, [IsRowVector and IsGF2VectorRep,
                IsRowVector and Is8BitVectorRep], 0,
        function(v,w)
    if IsLockedRepresentationVector(v) then
        TryNextMethod();
    else
        ConvertToVectorRepNC(v,GF(Q_VEC8BIT(w)));
        return v*w;
    fi;
end);

InstallMethod( \*, "For an 8 bit vector of char 2 and a GF2 vector",
        IsIdenticalObj, [IsRowVector and Is8BitVectorRep,
                IsRowVector and IsGF2VectorRep ], 0,
        function(w,v)
    if IsLockedRepresentationVector(v) then
        TryNextMethod();
    else
        ConvertToVectorRepNC(v,GF(Q_VEC8BIT(w)));
        return w*v;
    fi;
end);

#############################################################################
##
#M  AddRowVector( <vec1>, <vec2>, <mult>, <from>, <to> )
##
##  add <mult>*<vec2> to <vec1> in place
##

InstallOtherMethod( AddRowVector, "For 2 8 bit vectors and a field element and from and to",
        IsCollsCollsElmsXX, [ IsRowVector and Is8BitVectorRep,
                IsRowVector and Is8BitVectorRep,
                IsFFE and IsInternalRep, IsPosInt, IsPosInt ], 0,
        ADD_ROWVECTOR_VEC8BITS_5);

#############################################################################
##
#M  AddRowVector( <vec1>, <vec2>, <mult> )
##
##  add <mult>*<vec2> to <vec1> in place
##

InstallOtherMethod( AddRowVector, "For 2 8 bit vectors and a field element",
        IsCollsCollsElms, [ IsRowVector and Is8BitVectorRep,
                IsRowVector and Is8BitVectorRep,
                IsFFE and IsInternalRep ], 0,
        ADD_ROWVECTOR_VEC8BITS_3);

#############################################################################
##
#M  AddRowVector( <vec1>, <vec2> )
##
##  add <vec2> to <vec1> in place
##

InstallOtherMethod( AddRowVector, "For 2 8 bit vectors",
        IsIdenticalObj, [ IsRowVector and Is8BitVectorRep,
                IsRowVector and Is8BitVectorRep], 0,
        ADD_ROWVECTOR_VEC8BITS_2);

#############################################################################
##
#M  MultRowVector( <vec>, <ffe> )
##
##  multiply <vec> by <ffe> in place
##

InstallOtherMethod( MultRowVector, "For an 8 bit vector and an ffe",
        IsCollsElms, [ IsRowVector and Is8BitVectorRep,
                IsFFE and IsInternalRep], 0,
        MULT_ROWVECTOR_VEC8BITS);

#############################################################################
##
#M  PositionNot( <vec>, <zero )
#M  PositionNot( <vec>, <zero>, 0)
##
##
InstallOtherMethod( PositionNot, "for 8-bit vector and 0*Z(p)",
        IsCollsElms, [Is8BitVectorRep and IsRowVector , IsFFE and
                IsZero], 0,
        POSITION_NONZERO_VEC8BIT);

InstallMethod( PositionNot, "for 8-bit vector and 0*Z(p) and 0",
        IsCollsElmsX, [Is8BitVectorRep and IsRowVector , IsFFE and
                IsZero, IsZero and IsInt], 0,
        function(v,z,z1) 
    return POSITION_NONZERO_VEC8BIT(v,z); 
end);

InstallMethod( PositionNonZero, "for 8-bit vector",true,
        [Is8BitVectorRep and IsRowVector],0,
  # POSITION_NONZERO_VEC8BIT ignores the second argument
  v->POSITION_NONZERO_VEC8BIT(v,0)); 

#############################################################################
##
#M  Append( <vecl>, <vecr> )
##

InstallMethod( Append, "for 8bitm vectors",
        IsIdenticalObj, [Is8BitVectorRep and IsMutable and IsList,
                Is8BitVectorRep and IsList], 0,
        APPEND_VEC8BIT);
        

#############################################################################
##
#M  NumberFFVector(<<vec>,<sz>)
##
InstallMethod(NumberFFVector,"8bit-vector",true,
  [Is8BitVectorRep and IsRowVector and IsFFECollection,IsPosInt],0,
function(v,n)
  if n<>Q_VEC8BIT(v) then TryNextMethod();fi; 
  return NUMBER_VEC8BIT(v);
end);

#############################################################################
##
#M  IsSubset(<finfield>,<8bitvec>)
##
InstallMethod(IsSubset,"field, 8bit-vector",IsIdenticalObj,
  [ IsField and IsFinite and IsFFECollection,
    Is8BitVectorRep and IsRowVector and IsFFECollection],0,
function(F,v)
  local q;
  q:=Q_VEC8BIT(v);
  if Size(F)=q then
    return true;
  fi;
    # otherwise we must be a bit more clever
  if 0 = DegreeOverPrimeField(F) mod LogInt(q,Characteristic(F)) then
    return true;    # degrees ovber prime field OK
  fi;
  TryNextMethod(); # the vector still might be written over a too-large
  # field, so we can't say `no'.
end);

#############################################################################
##
#M  DistanceVecFFE(<vecl>,<vecr>)
##
InstallMethod(DistanceVecFFE,"8bit-vector",true,
        [Is8BitVectorRep and IsRowVector,
         Is8BitVectorRep and IsRowVector],0,
DISTANCE_VEC8BIT_VEC8BIT);

#############################################################################
##
#M  AddCoeffs( <vec1>, <vec2>, <mult> )
##
InstallOtherMethod( AddCoeffs, "two 8 bit vectors", IsCollsCollsElms,
        [Is8BitVectorRep and IsRowVector,
         Is8BitVectorRep and IsRowVector,
         IsFFE], 0, 
        ADD_COEFFS_VEC8BIT_3);

InstallOtherMethod( AddCoeffs, "8 bit vector and GF2 vector", IsCollsCollsElms,
        [Is8BitVectorRep and IsRowVector,
         IsGF2VectorRep and IsRowVector,
         IsFFE], 0, 
        function(v,w, x)
    if IsLockedRepresentationVector(w) then
        TryNextMethod();
    else
        ConvertToVectorRepNC(w, Q_VEC8BIT(v));
        return ADD_COEFFS_VEC8BIT_3(v,w,x);
    fi;
end);

InstallOtherMethod( AddCoeffs, "GF2 vector and 8 bit vector", IsCollsCollsElms,
        [IsGF2VectorRep and IsRowVector,
         Is8BitVectorRep and IsRowVector,
         IsFFE], 0, 
        function(v,w, x)
    if IsLockedRepresentationVector(v) then
        TryNextMethod();
    else
        ConvertToVectorRepNC(v, Q_VEC8BIT(w));
        return ADD_COEFFS_VEC8BIT_3(v,w,x);
    fi;
end);

#############################################################################
##
#M  AddCoeffs( <vec1>, <vec2> )
##
InstallOtherMethod( AddCoeffs, "two 8 bit vectors", IsIdenticalObj,
        [Is8BitVectorRep and IsRowVector,
         Is8BitVectorRep and IsRowVector], 0, 
        ADD_COEFFS_VEC8BIT_2);

InstallOtherMethod( AddCoeffs, "8 bit vector and GF2 vector", IsIdenticalObj,
        [Is8BitVectorRep and IsRowVector,
         IsGF2VectorRep and IsRowVector], 0, 
        function(v,w)
    if IsLockedRepresentationVector(w) then
        TryNextMethod();
    else
        ConvertToVectorRepNC(w, Q_VEC8BIT(v));
        return ADD_COEFFS_VEC8BIT_2(v,w);
    fi;
end);

InstallOtherMethod( AddCoeffs, "GF2 vector and 8 bit vector", IsIdenticalObj,
        [IsGF2VectorRep and IsRowVector,
         Is8BitVectorRep and IsRowVector], 0, 
        function(v,w)
    if IsLockedRepresentationVector(v) then
        TryNextMethod();
    else
        ConvertToVectorRepNC(v, Q_VEC8BIT(w));
        return ADD_COEFFS_VEC8BIT_2(v,w);
    fi;
end);

#############################################################################
##
#M  LeftShiftRowVector( <vec>, <shift> )
##
InstallMethod( LeftShiftRowVector, "8bit vector", true,
        [IsMutable and IsRowVector and Is8BitVectorRep,
         IsPosInt], 0,
        SHIFT_VEC8BIT_LEFT);

#############################################################################
##
#M  RightShiftRowVector( <vec>, <shift>, <zero> )
##
InstallMethod( RightShiftRowVector, "8bit vector, fill with zeros", IsCollsXElms,
        [IsMutable and IsRowVector and Is8BitVectorRep,
         IsPosInt,
         IsFFE and IsZero], 0,
        SHIFT_VEC8BIT_RIGHT);

#############################################################################
##
#M  ShrinkCoeffs( <vec> )
##
InstallMethod( ShrinkCoeffs, "8 bit vector", true,
        [IsMutable and IsRowVector and Is8BitVectorRep ],
        0,
        function(vec)
    local r;
    r := RIGHTMOST_NONZERO_VEC8BIT(vec);
    RESIZE_VEC8BIT(vec, r);
    return r;
end);

#############################################################################
##
#M  PadCoeffs( <vec>, <len> )
##
InstallMethod( PadCoeffs, "8 bit vector", true,
        [IsMutable and IsRowVector and Is8BitVectorRep and IsAdditiveElementWithZeroCollection, IsPosInt ],
        0,
        function(vec, len)
    if len > LEN_VEC8BIT(vec) then
        RESIZE_VEC8BIT(vec, len);
    fi;
end);

#############################################################################
##
#M  ShrinkRowVector( <vec> )  

InstallMethod( ShrinkRowVector, "8 bit vector", true,
        [IsMutable and IsRowVector and Is8BitVectorRep ],
        0,
        function(vec)
    local r;
    r := RIGHTMOST_NONZERO_VEC8BIT(vec);
    RESIZE_VEC8BIT(vec, r);
end);

#############################################################################
##
#M  RemoveOuterCoeffs( <vec>, <zero> )
##

InstallMethod( RemoveOuterCoeffs, "vec8bit and zero", IsCollsElms, 
        [ IsMutable and Is8BitVectorRep and IsRowVector, IsFFE and
          IsZero], 0,
        function (v,z)
    local shift;
    shift := POSITION_NONZERO_VEC8BIT(v,z) -1;
    if shift <> 0 then
        SHIFT_VEC8BIT_LEFT( v, shift);
    fi;
    if v <> [] then
        RESIZE_VEC8BIT(v,RIGHTMOST_NONZERO_VEC8BIT(v));
    fi;
    return shift;
end);

#############################################################################
##
#M  ProductCoeffs( <vec>, <len>, <vec>, <len>)
##
##

InstallMethod( ProductCoeffs, "8 bit vectors, kernel method", IsFamXFamY,
        [Is8BitVectorRep and IsRowVector, IsInt, Is8BitVectorRep and
         IsRowVector, IsInt ], 0,
        PROD_COEFFS_VEC8BIT);
        
InstallOtherMethod( ProductCoeffs, "8 bit vectors, kernel method (2 arg)", 
        IsIdenticalObj,
        [Is8BitVectorRep and IsRowVector, Is8BitVectorRep and
         IsRowVector ], 0,
        function(v,w) 
    return PROD_COEFFS_VEC8BIT(v, Length(v), w, Length(w));
end);



#############################################################################
##
#M  ReduceCoeffs( <vec>, <len>, <vec>, <len>)
##
##

BindGlobal("ADJUST_FIELDS_VEC8BIT",
        function(v,w) 
    local p,e;
    if Q_VEC8BIT(v)<>Q_VEC8BIT(w) then
      p:=Characteristic(v);
      e:=Lcm(LogInt(Q_VEC8BIT(v),p),LogInt(Q_VEC8BIT(w),p));
      if p^e > 256 or
         p^e <> ConvertToVectorRepNC(v,p^e) or
         p^e <> ConvertToVectorRepNC(w,p^e) then
          return fail;
      fi;
  fi;
  return true;
end);


InstallMethod( ReduceCoeffs, "8 bit vectors, kernel method", IsFamXFamY,
        [Is8BitVectorRep and IsRowVector and IsMutable, IsInt, Is8BitVectorRep and
         IsRowVector, IsInt ], 0,
        function(vl, ll, vr, lr)
        local res;
        if ADJUST_FIELDS_VEC8BIT(vl, vr) = fail then
            TryNextMethod();
        fi;
    	res := REDUCE_COEFFS_VEC8BIT( vl, ll, 
			MAKE_SHIFTED_COEFFS_VEC8BIT(vr, lr));
	if res = fail then 
		TryNextMethod();
	else
		return res;
	fi;
end);

InstallOtherMethod( ReduceCoeffs, "8 bit vectors, kernel method (2 arg)", 
        IsIdenticalObj,
        [Is8BitVectorRep and IsRowVector and IsMutable, Is8BitVectorRep and
         IsRowVector ], 0,
        function(v,w) 
    if ADJUST_FIELDS_VEC8BIT(v, w) = fail then
        TryNextMethod();
    fi;
    return REDUCE_COEFFS_VEC8BIT(v, Length(v),
                   MAKE_SHIFTED_COEFFS_VEC8BIT(w, Length(w)));
end);

#############################################################################
##
#M  QuotremCoeffs( <vec>, <len>, <vec>, <len>)
##
##
InstallMethod( QuotRemCoeffs, "8 bit vectors, kernel method", IsFamXFamY,
        [Is8BitVectorRep and IsRowVector and IsMutable, IsInt, Is8BitVectorRep and
         IsRowVector, IsInt ], 0,
        function(vl, ll, vr, lr)
        local res;
        if ADJUST_FIELDS_VEC8BIT(vl, vr) = fail then
            TryNextMethod();
        fi;
    	res := QUOTREM_COEFFS_VEC8BIT( vl, ll, 
			MAKE_SHIFTED_COEFFS_VEC8BIT(vr, lr));
	if res = fail then 
		TryNextMethod();
	else
		return res;
	fi;
end);

InstallOtherMethod( QuotRemCoeffs, "8 bit vectors, kernel method (2 arg)", 
        IsIdenticalObj,
        [Is8BitVectorRep and IsRowVector and IsMutable, Is8BitVectorRep and
         IsRowVector ], 0,
        function(v,w) 
    if ADJUST_FIELDS_VEC8BIT(v, w) = fail then
        TryNextMethod();
    fi;
    return QUOTREM_COEFFS_VEC8BIT(v, Length(v),
                   MAKE_SHIFTED_COEFFS_VEC8BIT(w, Length(w)));
end);


#############################################################################
##
#M PowerModCoeffs( <vec1>, <len1>, <exp>, <vec2>, <len2> )
##

IsFamXYFamZ := function(F1, F2, F3, F4, F5) return
  IsIdenticalObj(F1,F4); end;

InstallMethod( PowerModCoeffs, 
        "for 8 bit vectors", 
        IsFamXYFamZ,
        [ Is8BitVectorRep and  IsRowVector, IsInt, IsPosInt,
          Is8BitVectorRep and IsRowVector, IsInt ],
        0,
        function( v, lv, exp, w, lw)
    local wshifted, pow, lpow, bits, i,p,e;

    # ensure both vectors are in the same field
    if ADJUST_FIELDS_VEC8BIT(v, w) = fail then
        TryNextMethod();
    fi;
    
    if exp = 1 then
        pow := ShallowCopy(v);
        ReduceCoeffs(pow,lv,w,lw);
        return pow;
    fi;
    wshifted := MAKE_SHIFTED_COEFFS_VEC8BIT(w, lw);
    pow := v;
    lpow := lv;
    bits := [];
    while exp > 0 do
        Add(bits, exp mod 2);
        exp := QuoInt(exp,2);
    od;
    bits := Reversed(bits);
    for i in [2..Length(bits)] do
        pow := PROD_COEFFS_VEC8BIT(pow,lpow, pow, lpow);
        lpow := Length(pow);
        lpow := REDUCE_COEFFS_VEC8BIT( pow, lpow, wshifted);
        if lpow = 0 then
            return pow;
        fi;
        if bits[i] = 1 then
            pow := PROD_COEFFS_VEC8BIT(pow, lpow, v, lv);
            lpow := Length(pow);
            lpow := REDUCE_COEFFS_VEC8BIT( pow, lpow, wshifted);
            if lpow = 0 then
                return pow;
            fi;
        fi;
    od;
    return pow;
end);
            
            
#############################################################################
##
#E
##
