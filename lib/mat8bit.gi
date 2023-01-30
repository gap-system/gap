#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file is a first stab at a special posobj-based representation
##  for 8 bit matrices, mimicking the one for GF(2)
##
##  all rows must be the same length and written over the same field
##

#############################################################################
##
#V  TYPES_MAT8BIT . . . . . . . . prepared types for compressed GF(q) vectors
##
##  A length 2 list of length 257 lists. TYPES_MAT8BIT[1][q] will be the type
##  of mutable vectors over GF(q), TYPES_MAT8BIT[2][q] is the type of
##  immutable vectors. The 257th position is bound to 1 to stop the lists
##  shrinking.
##
##  It is accessed directly by the kernel, so the format cannot be changed
##  without changing the kernel.
##

if IsHPCGAP then
    BindGlobal("TYPES_MAT8BIT", [ FixedAtomicList(256), FixedAtomicList(256) ]);
    MakeReadOnlyObj(TYPES_MAT8BIT);
else
    BindGlobal("TYPES_MAT8BIT", [[],[]]);
    TYPES_MAT8BIT[1][257] := 1;
    TYPES_MAT8BIT[2][257] := 1;
fi;

#############################################################################
##
#F  TYPE_MAT8BIT( <q>, <mut> ) . .  computes type of compressed GF(q) matrices
##
##  Normally called by the kernel, caches results in TYPES_MAT8BIT,
##  which is directly accessed by the kernel
##

InstallGlobalFunction(TYPE_MAT8BIT,
  function( q, mut)
    local col, filts, type;
    if mut then col := 1; else col := 2; fi;
    if not IsBound(TYPES_MAT8BIT[col][q]) then
        filts := IsHomogeneousList and IsListDefault and IsCopyable and
                 Is8BitMatrixRep and IsSmallList and IsOrdinaryMatrix and
                 IsRingElementTable and IsNoImmediateMethodsObject and
                 HasIsRectangularTable and IsRectangularTable;
        if mut then filts := filts and IsMutable; fi;
        type := NewType(CollectionsFamily(FamilyObj(GF(q))),filts);
        if IsHPCGAP then
            InstallTypeSerializationTag(type, SERIALIZATION_BASE_MAT8BIT +
                        SERIALIZATION_TAG_BASE * (q * 2 + col - 1));
        fi;
        TYPES_MAT8BIT[col][q] := type;
    fi;
    return TYPES_MAT8BIT[col][q];
end);


#############################################################################
##
#M  Length( <mat> )
##

InstallOtherMethod( Length, "for a compressed MatFFE",
        true, [IsList and Is8BitMatrixRep], 0, m->m![1]);

#############################################################################
##
#M  <mat> [ <pos> ]
##

InstallOtherMethod( \[\],  "for a compressed MatFFE",
        [IsList and Is8BitMatrixRep, IsPosInt],
        ELM_MAT8BIT
        );

#############################################################################
##
#M  <mat> [ <pos1>, <pos2> ]
##

InstallMethod( \[\,\],  "for a compressed MatFFE",
        [Is8BitMatrixRep, IsPosInt, IsPosInt],
        MAT_ELM_MAT8BIT
        );

#############################################################################
##
#M  <mat> [ <pos> ] := <val>
##
##  This may involve turning <mat> into a plain list, if <mat> does
##  not lie in the appropriate field.
##

InstallOtherMethod( \[\]\:\=,  "for a compressed MatFFE",
        [IsMutable and IsList and Is8BitMatrixRep, IsPosInt, IsObject],
        ASS_MAT8BIT
        );

#############################################################################
##
#M  <mat> [ <pos1>, <pos2> ] := <val>
##

InstallMethod( \[\,\]\:\=,  "for a compressed MatFFE",
        [IsMutable and Is8BitMatrixRep, IsPosInt, IsPosInt, IsObject],
        SET_MAT_ELM_MAT8BIT
        );

#############################################################################
##
#M  Unbind( <mat> [ <pos> ] )
##
##  Unless the last position is being unbound, this will result in <mat>
##  turning into a plain list
##

InstallOtherMethod( Unbind\[\], "for a compressed MatFFE",
        true, [IsMutable and IsList and Is8BitMatrixRep, IsPosInt],
        0, function(m,p)
    if p = 1 or  p <> m![1] then
        PLAIN_MAT8BIT(m);
        Unbind(m[p]);
    else
        m![1] := p-1;
        Unbind(m![p+1]);
    fi;
end);

#############################################################################
##
#M  ViewObj( <mat> )
##
##  Up to 25 entries,  GF(q) matrices are viewed in full, over that a
##  description is printed
##

InstallMethod( ViewObj, "for a compressed MatFFE",
        true, [Is8BitMatrixRep and IsSmallList], 0,
        function( m )
    local r,c;
    r := m![1];
    c := LEN_VEC8BIT(m![2]);
    if r*c > 25 or r = 0 or c = 0 then
        Print("< ");
        if not IsMutable(m) then
            Print("im");
        fi;
        Print("mutable compressed matrix ",r,"x",c," over GF(",Q_VEC8BIT(m![2]),") >");
    else
        PrintObj(m);
    fi;
end);

#############################################################################
##
#M  PrintObj( <mat> )
##
##  Same method as for lists in internal rep.
##

InstallMethod( PrintObj, "for a compressed MatFFE",
        true, [Is8BitMatrixRep and IsSmallList], 0,
        function( mat )
    local i,l;
    Print("\>\>[ \>\>");
    l := mat![1];
    if l <> 0 then
        PrintObj(mat![2]);
        for i in [2..l] do
            Print("\<,\< \>\>");
            PrintObj(mat![i+1]);
        od;
    fi;
    Print(" \<\<\<\<]");
end);

#############################################################################
##
#M  ShallowCopy(<mat>)
##
##

InstallMethod(ShallowCopy, "for a compressed MatFFE",
        true, [Is8BitMatrixRep and IsSmallList], 0,
        function(m)
    local c,i,l;
    l := m![1];
    c := [l];
    for i in [2..l+1] do
        c[i] := m![i];
    od;
    Objectify(TYPE_MAT8BIT(Q_VEC8BIT(m![2]), true),c);
    return c;
end );

#############################################################################
##
#M PositionCanonical( <mat> , <vec> )
##

InstallMethod( PositionCanonical,
    "for 8bit matrices lists, fall back on `Position'",
    true, # the list may be non-homogeneous.
    [ IsList and Is8BitMatrixRep, IsObject ], 0,
    function( list, obj )
    return Position( list, obj, 0 );
end );



#############################################################################
##
#M  <mat1> + <mat2>
##

InstallMethod( \+, "for two 8 bit matrices in same characteristic",
        IsIdenticalObj, [IsMatrix and Is8BitMatrixRep,
                IsMatrix and Is8BitMatrixRep], 0,
        SUM_MAT8BIT_MAT8BIT
);

#############################################################################
##
#M  <mat1> - <mat2>
##

InstallMethod( \-, "for two 8 bit matrices in same characteristic",
        IsIdenticalObj, [IsMatrix and Is8BitMatrixRep,
                IsMatrix and Is8BitMatrixRep], 0,
        DIFF_MAT8BIT_MAT8BIT
);


#############################################################################
##
#M  ConvertToMatrixRepNC( <list>, <fieldsize )
#M  ConvertToMatrixRep( <list>[, <fieldsize> | <field>])
##


InstallGlobalFunction(ConvertToMatrixRep,
        function( arg )
    local m,qs, v,  q, givenq, q1, LeastCommonPower, lens;

    LeastCommonPower := function(qs)
        local p, d, x, i;
        Assert(1, Length(qs) > 0);

        x := Z(qs[1]);
        p := Characteristic(x);
        d := DegreeFFE(x);
        for i in [2..Length(qs)] do
            x := Z(qs[i]);
            if p <> Characteristic(x) then
                return fail;
            fi;
            d := Lcm(d, DegreeFFE(x));
        od;
        return p^d;
    end;

    qs := [];

    m := arg[1];
    if Length(arg) > 1 then
        q1 := arg[2];
        if not IsInt(q1) then
            if IsField(q1) then
                if Characteristic(q1) = 0 then
                    return fail;
                fi;
                q1 := Size(q1);
            else
                return fail; # not a field -- exit
            fi;
        fi;
        if q1 > 256 then
            return fail;
        fi;
        givenq := true;
        Add(qs,q1);
    else
        givenq := false;
    fi;

    if Length(m) = 0 then
        if givenq then
            return q1;
        else
            return fail;
        fi;
    fi;

    #
    # If we are already compressed, then our rows are certainly
    #  locked, so we will not be able to change representation
    #
    if Is8BitMatrixRep(m) then
        q := Q_VEC8BIT(m![2]);
        if not givenq or q = q1 then
            return q;
        else
            return fail;
        fi;
    fi;

    if IsGF2MatrixRep(m) then
        if not givenq or q1 = 2 then
            return 2;
        else
            return fail;
        fi;
    fi;

    #
    # Pass 1, get all rows compressed, and find out what fields we have
    #

    #    mut := false;
    lens := [];
    for v in m do
        if IsGF2VectorRep(v) then
            AddSet(qs,2);
        elif Is8BitVectorRep(v) then
            AddSet(qs,Q_VEC8BIT(v));
        elif givenq then
            AddSet(qs,ConvertToVectorRepNC(v,q1));
        else
            AddSet(qs,ConvertToVectorRepNC(v));
        fi;
        AddSet(lens, Length(v));
#        mut := mut or IsMutable(v);
    od;

    #
    # We may know that there is no common field
    # or that we can't win for some other reason
    #
    if
      #      mut or
      Length(lens) > 1 or lens[1] = 0 or
      fail in qs  or true in qs then
        return fail;
    fi;

    #
    # or it may be easy
    #
    if Length(qs) = 1 then
        q := qs[1];
    else

        #
        # Now work out the common field
        #
        q := LeastCommonPower(qs);

        if q = fail then
            return fail;
        fi;

        if givenq and q1 <> q then
            Error("ConvertToMatrixRep( <mat>, <q> ): not all entries of <mat> written over <q>");
        fi;

        #
        # Now try and rewrite all the rows over this field
        # this may fail if some rows are locked over a smaller field
        #

        for v in m do
            if q <> ConvertToVectorRepNC(v,q) then
                return fail;
            fi;
        od;
    fi;

    if q <= 256 then
        ConvertToMatrixRepNC(m,q);
    fi;

    return q;
end);


InstallGlobalFunction(ConvertToMatrixRepNC, function(arg)
    local   v, m,  q, result;
    if Length(arg) = 1 then
        return ConvertToMatrixRep(arg[1]);
    else
        m := arg[1];
        q := arg[2];
    fi;
    if Length(m)=0 then
        return ConvertToMatrixRep(m,q);
    fi;
    if not IsInt(q) then
        q := Size(q);
    fi;
    if Is8BitMatrixRep(m) then
        return Q_VEC8BIT(m[1]);
    fi;
    if IsGF2MatrixRep(m) then
        return 2;
    fi;
    for v in m do
        result := ConvertToVectorRepNC(v,q);
        if result <> q then
            return fail;
        fi;
    od;
    if q = 2 then
        CONV_GF2MAT(m);
    elif q <= 256 then
        CONV_MAT8BIT(m, q);
    fi;
    return q;
end);

#############################################################################
##
#M <vec> * <mat>
##

InstallMethod( \*, "8 bit vector * 8 bit matrix", IsElmsColls,
        [ Is8BitVectorRep and IsRowVector and IsRingElementList,
          Is8BitMatrixRep and IsMatrix
          ], 0,
        PROD_VEC8BIT_MAT8BIT);


#############################################################################
##
#M <mat> * <vec>
##

InstallMethod( \*, "8 bit matrix * 8 bit vector", IsCollsElms,
        [           Is8BitMatrixRep and IsMatrix,
                Is8BitVectorRep and IsRowVector and IsRingElementList
          ], 0,
        PROD_MAT8BIT_VEC8BIT);

#############################################################################
##
#M <mat> * <mat>
##

InstallMethod( \*, "8 bit matrix * 8 bit matrix", IsIdenticalObj,
        [           Is8BitMatrixRep and IsMatrix,
                Is8BitMatrixRep and IsMatrix
          ], 0,
        PROD_MAT8BIT_MAT8BIT);

#############################################################################
##
#M  <ffe> * <mat>
##
##  If <ffe> lies in the field of <mat> then we return a matrix in
##  `Is8BitMatrixRep`, otherwise we delegate to a generic method.
##

InstallMethod( \*, "internal FFE * 8 bit matrix", IsElmsCollColls,
        [           IsFFE and IsInternalRep,
                Is8BitMatrixRep and IsMatrix
          ], 0,
        function(s,m)
    local q,i,l,r,pv;
    q := Q_VEC8BIT(m![2]);
    if not s in GF(q) then
        TryNextMethod();
    fi;
    l := m![1];
    r := [l];
    for i in [2..l+1] do
        pv := s*m![i];
        SetFilterObj(pv, IsLockedRepresentationVector);
        r[i] := pv;
    od;
    Objectify(TYPE_MAT8BIT(q, IsMutable(m)),r);
    return r;
end);

InstallMethod( \*, "FFE * 8 bit matrix", IsElmsCollColls,
    [ IsFFE, Is8BitMatrixRep and IsMatrix ],
    function( s, m )
    if IsInternalRep( s ) then
      TryNextMethod();
    fi;
    s:= AsInternalFFE( s );
    if s = fail then
      TryNextMethod();
    fi;
    return s * m;
end);


#############################################################################
##
#M  <mat> * <ffe>
##
##  If <ffe> lies in the field of <mat> then we return a matrix in
##  `Is8BitMatrixRep`, otherwise we delegate to a generic method.
##

InstallMethod( \*, "8 bit matrix * internal FFE", IsCollCollsElms,
        [
                Is8BitMatrixRep and IsMatrix,
                IsFFE and IsInternalRep
          ], 0,
        function(m,s)
    local q,i,l,r,pv;
    q := Q_VEC8BIT(m![2]);
    if not s in GF(q) then
        TryNextMethod();
    fi;
    l := m![1];
    r := [l];
    for i in [2..l+1] do
        pv := m![i]*s;
        SetFilterObj(pv, IsLockedRepresentationVector);
        r[i] := pv;
    od;
    Objectify(TYPE_MAT8BIT(q, IsMutable(m)),r);
    return r;
end);

InstallMethod( \*, "8 bit matrix * FFE", IsCollCollsElms,
    [ Is8BitMatrixRep and IsMatrix, IsFFE ],
    function( m, s )
    if IsInternalRep( s ) then
      TryNextMethod();
    fi;
    s:= AsInternalFFE( s );
    if s = fail then
      TryNextMethod();
    fi;
    return m * s;
end);


#############################################################################
##
#M  Additive Inverse
##

InstallMethod(AdditiveInverseMutable, "8 bit matrix", true,
        [Is8BitMatrixRep and IsMatrix and IsAdditiveElementWithZero
         and IsSmallList ],
        0,
        function(mat)
    local neg,i,negv;
    neg := [mat![1]];
    for i in [2..mat![1]+1] do
        negv := AdditiveInverseMutable(mat![i]);
        SetFilterObj(negv, IsLockedRepresentationVector);
        neg[i] := negv;
    od;
    Objectify(TYPE_MAT8BIT(Q_VEC8BIT(mat![2]),true), neg);
    return neg;
end);

InstallMethod(AdditiveInverseImmutable, "8 bit matrix", true,
        [Is8BitMatrixRep and IsMatrix and IsAdditiveElementWithZero
         and IsSmallList ],
        0,
        function(mat)
    local neg,i,negv;
    neg := [mat![1]];
    for i in [2..mat![1]+1] do
        negv := AdditiveInverseImmutable(mat![i]);
        SetFilterObj(negv, IsLockedRepresentationVector);
        neg[i] := negv;
    od;
    Objectify(TYPE_MAT8BIT(Q_VEC8BIT(mat![2]),false), neg);
    return neg;
end);

InstallMethod(AdditiveInverseSameMutability, "an 8-bit matrix",
        [Is8BitMatrixRep and IsMatrix and IsAdditiveElementWithZero
         and IsSmallList],
function(mat)
  local inv_func, neg, i;

  if IsMutable(mat[1]) then
    inv_func := AdditiveInverseMutable;
  else
    inv_func := AdditiveInverseImmutable;
  fi;
  neg := [mat![1]];
  for i in [2..mat![1]+1] do
    neg[i] := inv_func(mat![i]);
    SetFilterObj(neg[i], IsLockedRepresentationVector);
  od;
  if IsMutable(mat) then
    Objectify(TYPE_MAT8BIT(Q_VEC8BIT(mat![2]),true), neg);
  else
    Objectify(TYPE_MAT8BIT(Q_VEC8BIT(mat![2]),false), neg);
  fi;
  return neg;
end);

#############################################################################
##
#M  Zero

InstallMethod( ZeroMutable, "8 bit matrix", true,
        [Is8BitMatrixRep and IsMatrix and IsAdditiveElementWithZero
         and IsSmallList ],
        0,
        function(mat)
    local z, i,zv;
    z := [mat![1]];
    for i in [2..mat![1]+1] do
        zv := ZERO_VEC8BIT(mat![i]);
        SetFilterObj(zv, IsLockedRepresentationVector);
        z[i] := zv;
    od;
    Objectify(TYPE_MAT8BIT(Q_VEC8BIT(mat![2]),true), z);
    return z;
end);

InstallMethod( ZeroImmutable, "8 bit matrix", true,
        [Is8BitMatrixRep and IsMatrix and IsAdditiveElementWithZero
         and IsSmallList ],
        0,
        function(mat)
    local z, i,zv;
    z := [mat![1]];
    zv := ZERO_VEC8BIT(mat![2]);
    SetFilterObj(zv, IsLockedRepresentationVector);
    MakeImmutable(zv);
    for i in [2..mat![1]+1] do
        z[i] := zv;
    od;
    Objectify(TYPE_MAT8BIT(Q_VEC8BIT(mat![2]),false), z);
    return z;
end);

InstallMethod( ZeroSameMutability, "8 bit matrix", true,
        [Is8BitMatrixRep and IsMatrix and IsAdditiveElementWithZero
         and IsSmallList ],
        0,
        function(mat)
    local z, i,zv;
    z := [mat![1]];
    if not IsMutable(mat![2]) then
        zv := ZERO_VEC8BIT(mat![2]);
        SetFilterObj(zv, IsLockedRepresentationVector);
        MakeImmutable(zv);
        for i in [2..mat![1]+1] do
            z[i] := zv;
        od;
    else
        for i in [2..mat![1]+1] do
            zv := ZERO_VEC8BIT(mat![i]);
            SetFilterObj(zv,IsLockedRepresentationVector);
            z[i] := zv;
        od;
    fi;
    if IsMutable(mat) then
       Objectify(TYPE_MAT8BIT(Q_VEC8BIT(mat![2]),true), z);
    else
        Objectify(TYPE_MAT8BIT(Q_VEC8BIT(mat![2]),false), z);
    fi;
    return z;
end);


#############################################################################
##
#M Inverse
##

InstallMethod(InverseMutable, "8 bit matrix", true,
        [Is8BitMatrixRep and IsMatrix and IsMultiplicativeElementWithInverse
        # the following are banalities, but they are required to get the
        # ranking right
        and IsOrdinaryMatrix and IsSmallList and
        IsCommutativeElementCollColl and IsRingElementTable and IsFFECollColl
        ],
        0,
        INV_MAT8BIT_MUTABLE);

InstallMethod(InverseImmutable, "for 8-bit matrix rep", [Is8BitMatrixRep],
INV_MAT8BIT_IMMUTABLE);

InstallMethod( InverseSameMutability, "8 bit matrix", true,
        [Is8BitMatrixRep and IsMatrix and IsMultiplicativeElementWithInverse
        # the following are banalities, but they are required to get the
        # ranking right
        and IsOrdinaryMatrix and IsSmallList and
        IsCommutativeElementCollColl and IsRingElementTable and IsFFECollColl
        ],
        0,
        INV_MAT8BIT_SAME_MUTABILITY);

#############################################################################
##
#M One
##

InstallMethod( OneSameMutability, "8 bit matrix", true,
        [Is8BitMatrixRep and IsMatrix and IsMultiplicativeElementWithInverse
        # the following are banalities, but they are required to get the
        # ranking right
        and IsOrdinaryMatrix and IsSmallList and
        IsCommutativeElementCollColl and IsRingElementTable and IsFFECollColl
        ],
        0,
        function(m)
    local   v,  o,  one,  i,  w;
    v := ZeroOp(m![2]);
    o := [];
    one := Z(Q_VEC8BIT(v))^0;
    for i in [1..m![1]] do
        w := ShallowCopy(v);
        w[i] := one;
        Add(o,w);
    od;
    if not IsMutable(m![2]) then
        for i in [1..m![1]] do
            MakeImmutable(o[i]);
        od;
    fi;
    if not IsMutable(m) then
        MakeImmutable(o);
    fi;
    ConvertToMatrixRepNC(o, Q_VEC8BIT(v));
    return o;
end);

InstallMethod( OneMutable, "8 bit matrix", true,
        [Is8BitMatrixRep and IsMatrix and IsMultiplicativeElementWithInverse
        # the following are banalities, but they are required to get the
        # ranking right
        and IsOrdinaryMatrix and IsSmallList and
        IsCommutativeElementCollColl and IsRingElementTable and IsFFECollColl
        ],
        0,
        function(m)
    local   v,  o,  one,  i,  w;
    v := ZeroOp(m![2]);
    o := [];
    one := Z(Q_VEC8BIT(v))^0;
    for i in [1..m![1]] do
        w := ShallowCopy(v);
        w[i] := one;
        Add(o,w);
    od;
    ConvertToMatrixRepNC(o, Q_VEC8BIT(v));
    return o;
end);

InstallMethod(OneImmutable, "8 bit matrix", true,
        [Is8BitMatrixRep and IsMatrix and IsMultiplicativeElementWithInverse
        # the following are banalities, but they are required to get the
        # ranking right
        and IsOrdinaryMatrix and IsSmallList and
        IsCommutativeElementCollColl and IsRingElementTable and IsFFECollColl
        ],
        0,
        function(m)
    return MakeImmutable(OneMutable(m));
    end );

#############################################################################
##
#F  RepresentationsOfMatrix( <mat/vec> )
##
##

InstallGlobalFunction( RepresentationsOfMatrix,
        function( m )
    if not IsRowVector(m) and not IsMatrix(m) then
        Print("Argument is not a matrix or vector\n");
    fi;
    if IsMutable(m) then
        Print("Mutable ");
    else
        Print("Immutable ");
    fi;
    if not IsMatrix(m) then
        if IsMutable(m) then
            Print("Mutable ");
        else
            Print("Immutable ");
        fi;
        Print("Vector: ");
        if IsGF2VectorRep(m) then
            Print(" compressed over GF(2) ");
        elif Is8BitVectorRep(m) then
            Print(" compressed over GF(",Q_VEC8BIT(m),") ");
        elif IsPlistRep(m) then
            Print(" plain list, tnum: ",TNUM_OBJ(m)," ");
            if TNUM_OBJ(m) in [T_PLIST_FFE,T_PLIST_FFE+1] then
                Print("known to be vecffe over GF(",CHAR_FFE_DEFAULT(m[1]),"^",
                      DEGREE_FFE_DEFAULT(m[1]),") ");
            elif TNUM_OBJ(m) in [T_PLIST_CYC..T_PLIST_CYC_SSORT+1] then
                Print("known to be vector of cyclotomics ");
            fi;
        else
            Print(" not a compressed or plain list, representations: ",
                  RepresentationsOfObject(m)," ");
        fi;
        if IsLockedRepresentationVector(m) then
            Print("locked\n");
        else
            Print("unlocked\n");
        fi;
        return;
    fi;
    if IsMutable(m) then
        if ForAll(m, IsMutable) then
            Print(" with mutable rows ");
        elif not ForAny(m, IsMutable) then
            Print(" with immutable rows ");
        else
            Print(" with mixed mutability rows!! ");
        fi;
    fi;
    if IsGF2MatrixRep(m) then
        Print(" Compressed GF2 representation ");
    elif Is8BitMatrixRep(m) then
        Print(" Compressed 8 bit rep over GF(",Q_VEC8BIT(m[1]),
              "), ");
    elif IsPlistRep(m) then
        Print(" plain list of vectors, tnum: ",TNUM_OBJ(m)," ");
        if ForAll(m, IsGF2VectorRep) then
            Print(" all rows GF2 compressed ");
        elif ForAll(m, Is8BitVectorRep) then
            Print(" all rows 8 bit compressed, fields ",
                  Set(m,Q_VEC8BIT), " ");
        elif ForAll(m, IsPlistRep) then
            Print(" all rows plain lists, tnums: ", Set(m,
                    TNUM_OBJ)," ");
        else
            Print(" mixed row representations or unusual row types ");
        fi;
    else
        Print(" unusual matrix representation: ",
              RepresentationsOfObject(m)," ");
    fi;
    if ForAll(m, IsLockedRepresentationVector) then
        Print(" all rows locked\n");
    elif not ForAny(m, IsLockedRepresentationVector) then
        Print(" no rows locked\n");
    else
        Print(" mixed lock status\n");
    fi;
    return;
    end
    );


#############################################################################
##
#M  ASS_LIST( <empty list>, <vec>)
##

#InstallMethod(ASS_LIST, "empty list and 8 bit vector", true,
#        [IsEmpty and IsMutable and IsList and IsPlistRep, IsPosInt, Is8BitVectorRep],
#        0,
#        function(l,p,  v)
#    if p <> 1 then
#        PLAIN_MAT8BIT(l);
#        l[p] := v;
#    else
#        l[1] := 1;
#        l[2] := v;
#        SetFilterObj(v,IsLockedRepresentationVector);
#        Objectify(TYPE_MAT8BIT(Q_VEC8BIT(v), true), l);
#   fi;
#end);


#############################################################################
##
#M  DefaultFieldOfMatrix( <ffe-mat> )
##
InstallMethod( DefaultFieldOfMatrix,
    "method for a compressed matrix over GF(q)", true,
    [ IsMatrix and IsFFECollColl and Is8BitMatrixRep ], 0,
function( mat )
    return GF(Q_VEC8BIT(mat![2]));
end );

#############################################################################
##
#M  <mat> < <mat>
##

InstallMethod( \<, "for two compressed 8 bit matrices", IsIdenticalObj,
        [ IsMatrix and IsFFECollColl and Is8BitMatrixRep, IsMatrix and IsFFECollColl and Is8BitMatrixRep ], 0,
        LT_MAT8BIT_MAT8BIT);

#############################################################################
##
#M  <mat> = <mat>
##

InstallMethod( \=, "for two compressed 8 bit matrices", IsIdenticalObj,
        [ IsMatrix and IsFFECollColl and Is8BitMatrixRep, IsMatrix and IsFFECollColl and Is8BitMatrixRep ], 0,
        EQ_MAT8BIT_MAT8BIT);

#############################################################################
##
#M  TransposedMat( <mat> )
#M  MutableTransposedMat( <mat> )
##

InstallOtherMethod( TransposedMat, "for a compressed 8 bit matrix",
        true, [IsMatrix and IsFFECollColl and
        Is8BitMatrixRep ], 0,
        TRANSPOSED_MAT8BIT);

InstallOtherMethod( MutableTransposedMat, "for a compressed 8 bit matrix",
        true, [IsMatrix and IsFFECollColl and
        Is8BitMatrixRep ], 0,
        TRANSPOSED_MAT8BIT);


#############################################################################
##
#M  SemiEchelonMat
##
#
# If mat is in the  special representation, then we do
# have to copy it, but we know that the rows of the result will
# already be in special representation, so don't convert
#

InstallMethod(SemiEchelonMat, "shortcut method for 8bit matrices",
        true,
        [ IsMatrix and Is8BitMatrixRep and IsFFECollColl ],
        0,
        function( mat )
    local copymat, res;

    copymat := List(mat, ShallowCopy);
    res := SemiEchelonMatDestructive( copymat );
    ConvertToMatrixRepNC(res.vectors,Q_VEC8BIT(mat![2]));
    return res;
end);

InstallMethod(SemiEchelonMatTransformation, "shortcut method for 8bit matrices",
        true,
        [ IsMatrix and Is8BitMatrixRep and IsFFECollColl ],
        0,
        function( mat )
    local copymat,res,q;
    copymat := List(mat, ShallowCopy);
    res := SemiEchelonMatTransformationDestructive( copymat );
    q := Q_VEC8BIT(mat![2]);
    ConvertToMatrixRepNC(res.vectors,q);
    ConvertToMatrixRepNC(res.coeffs,q);
    ConvertToMatrixRepNC(res.relations,q);
    return res;
end);

InstallMethod(SemiEchelonMatDestructive, "kernel method for plain lists of 8bit vectors",
        true,
        [ IsPlistRep and IsMatrix and IsMutable and IsFFECollColl ],
        0,
        SEMIECHELON_LIST_VEC8BITS
        );

InstallMethod(SemiEchelonMatTransformationDestructive,
        " kernel method for plain lists of 8 bit vectors",
        true,
        [ IsMatrix and IsFFECollColl and IsPlistRep and IsMutable],
        0,
        SEMIECHELON_LIST_VEC8BITS_TRANSFORMATIONS);



#############################################################################
##
#M  TriangulizeMat( <plain list of GF2 vectors> )
##

InstallMethod(TriangulizeMat,
        "kernel method for plain list of GF2 vectors",
        true,
        [IsMatrix and IsPlistRep and IsFFECollColl and IsMutable],
        0,
        TRIANGULIZE_LIST_VEC8BITS);

InstallMethod(TriangulizeMat,
"for a mutable 8-bit matrix",
[IsMutable and IsMatrix and Is8BitMatrixRep and IsFFECollColl],
function(m)
  local q, mut, i;

  q := Q_VEC8BIT(m![2]);
  mut := IsMutable(m[1]);

  PLAIN_MAT8BIT(m);
  for i in [1 .. NrRows(m)] do
    if not IsMutable(m[i]) then
      m[i] := ShallowCopy(m[i]);
    fi;
  od;
  TRIANGULIZE_LIST_VEC8BITS(m);

  CONV_MAT8BIT(m,q);
  if not mut then
    PostMakeImmutable(m);
  fi;
end);

#############################################################################
##
#M  DeterminantMatDestructive ( <plain list of GF2 vectors> )
##

InstallMethod(DeterminantMatDestructive,
        "kernel method for plain list of GF2 vectors",
        true,
        [IsMatrix and IsPlistRep and IsFFECollColl and IsMutable],
        0,
        DETERMINANT_LIST_VEC8BITS);

#############################################################################
##
#M  RankMatDestructive ( <plain list of GF2 vectors> )
##


InstallOtherMethod(RankMatDestructive,
        "kernel method for plain list of GF2 vectors",
        [IsMatrix and IsPlistRep and IsFFECollColl and IsMutable],
        RANK_LIST_VEC8BITS);

InstallMethod(NestingDepthM, [Is8BitMatrixRep], m->2);
InstallMethod(NestingDepthA, [Is8BitMatrixRep], m->2);
InstallMethod(NestingDepthM, [Is8BitVectorRep], m->1);
InstallMethod(NestingDepthA, [Is8BitVectorRep], m->1);

InstallMethod(PostMakeImmutable, [Is8BitMatrixRep],
        function(m)
    local i;
    for i in [2..m![1]+1] do
        MakeImmutable(m![i]);
    od;
end);
