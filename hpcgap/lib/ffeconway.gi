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
##  This file contains methods for `FFE's represented as library objects by
##  coefficients of polynomials modulo the Conway polynomial.
##

#############################################################################
##
#R IsCoeffsModConwayPolRep( <obj> )
##
## An element in this representation is stored a three component
## PositionalObject
##
## The first component is a mutable vector giving the coefficients of a polynomial
## over a prime field. Where appropriate, this should be compressed.
##
## The second component is an integer specifying the degree of the field extension
## over the prime field in which this element is written.
##
## The third component may hold the representation of the element written over
## the field extension that it generates. If this is 'fail' then this is not known
## if it is 'false' then the element is known to be irreducible. This value may be
## an internal FFE or a ZmodpZ object.
##
##
##

DeclareRepresentation("IsCoeffsModConwayPolRep", IsPositionalObjectRep, 3);

#############################################################################
##
#V FFECONWAY is a holder for private function
##

BindGlobal("FFECONWAY", rec());

#############################################################################
##
#F FFECONWAY.ZNC(<p>,<d>) .. construct a primitive root
##
## this function also deals with construction and caching of the
## Conway Polynomial and associated data. It must always be called before
## any computation with elements of GF(p^d)
##
## To support computing with these objects, a variety of data is stored in the
## FFEFamily:
##
## 'fam!.ConwayFldEltDefaultType' contains the type of the field elements in this
##                                characteristic and representation
## 'fam!.ConwayPolCoeffs[d]'   contains the coefficients of the Conway Polynomial
##                               for GF(p^d)
## 'fam!.ConwayFldEltReducers[d]' contains a function which will take a mutable
##                               vector of FFEs in compressed format (if appropriate)
##                               reduce it modulo the Conway polynomial and fix its
##                               length to be exactly 'd'
## 'fam!.ZCache[d]'            contains 'Z(p,d)' once it has been computed.
##

FFECONWAY.SetUpConwayStuff := function(p,d)
    local   fam,  cp,  cps,  i, reducer;
    fam := FFEFamily(p);
    if not IsBound(fam!.ConwayPolCoeffs) then
        fam!.ConwayPolCoeffs := ShareSpecialObj([]);
        fam!.ConwayFldEltReducers := AtomicList([]);
    fi;

    atomic readonly fam!.ConwayPolCoeffs do
        if IsBound(fam!.ConwayPolCoeffs[d]) then
            return;
        fi;
    od;

    if not IsCheapConwayPolynomial(p,d) then
        Error("Conway Polynomial ",p,"^",d,
              " will need to computed and might be slow\n", "return to continue");
    fi;
    cp := CoefficientsOfUnivariatePolynomial(ConwayPolynomial(p,d));

    #
    # various cases for reducers
    #
    if p = 2 then
        reducer := function(v)
            REDUCE_COEFFS_GF2VEC(v,Length(v),cp,d+1);
            RESIZE_GF2VEC(v,d);
        end;
    elif p <= 256 then
        #
        # We can save time on repeated reductions using
        # pre-computed shifts
        #
        cps := MAKE_SHIFTED_COEFFS_VEC8BIT(cp,d+1);
        reducer := function(v)
            REDUCE_COEFFS_VEC8BIT(v,Length(v),cps);
            RESIZE_VEC8BIT(v,d);
        end;
    else
        #
        # Need to adjust the length "by hand"
        #
        reducer := function(v)
            ReduceCoeffs(v,Length(v),cp,d+1);
            if Length(v) < d then
                PadCoeffs(v,d);
            elif Length(v) > d then
                for i in [d+1..Length(v)] do
                    Unbind(v[i]);
                od;
            fi;
        end;
    fi;

    atomic readwrite fam!.ConwayPolCoeffs do
      if not IsBound(fam!.ConwayPolCoeffs[d]) then
        fam!.ConwayPolCoeffs[d] := MakeReadOnlyObj(cp);
        fam!.ConwayFldEltReducers[d] := reducer;
      fi;
    od;
end;


FFECONWAY.ZNC := function(p,d)
    local   fam,  zpd,  v;
    fam := FFEFamily(p);

    if not IsBound(fam!.ZCache) then
        fam!.ZCache := MakeWriteOnceAtomic([]);
    fi;

    if IsBound(fam!.ZCache[d]) then
        return fam!.ZCache[d];
    fi;

    # because MakeWriteOnceAtomic was applied to fam when it was created,
    # it should be safe to assign fam!.ConwayFldEltDefaultType as below
    if not IsBound(fam!.ConwayFldEltDefaultType) then
        fam!.ConwayFldEltDefaultType := NewType(fam, IsCoeffsModConwayPolRep and IsLexOrderedFFE);
    fi;
    FFECONWAY.SetUpConwayStuff(p,d);
    v := ListWithIdenticalEntries(d,0*Z(p));
    v[2] := Z(p)^0;
    if p<=256 then
        v := CopyToVectorRep(v,p);
    fi;
    # put 'false' in the third component because we know it is irreducible
    zpd := Objectify(fam!.ConwayFldEltDefaultType, [v,d,false] );

    if not IsBound(fam!.ZCache[d]) then
        fam!.ZCache[d] := MakeReadOnlyObj(zpd);
    fi;
    return fam!.ZCache[d];

end;

#############################################################################
##
#M Z(p,d), Z(q) ..
##
##     check various things and call FFECONWAY.ZNC

InstallOtherMethod(ZOp,
        [IsPosInt, IsPosInt],
        function(p,d)
    local   q;
    if not IsPrimeInt(p) then
        Error("Z: <p> must be a prime (not the integer ", p, ")");
    fi;
    q := p^d;
    if q <= MAXSIZE_GF_INTERNAL or d =1 then
        return Z(q);
    fi;
    return FFECONWAY.ZNC(p,d);
end);

InstallMethod(ZOp,
        [IsPosInt],
        function(q)
    local   p,  d;
    if q <= MAXSIZE_GF_INTERNAL then
        TryNextMethod(); # should never happen
    fi;
    p := SmallestRootInt(q);
    d := LogInt(q,p);
    Assert(1, q=p^d);
    if not IsPrimeInt(p) then
        Error("Z: <q> must be a positive prime power (not the integer ", q, ")");
    fi;
    if d > 1 then
        return FFECONWAY.ZNC(p,d);
    fi;
    TryNextMethod();
end);


#############################################################################
##
#M  PrintObj( <ffe> )
#M  String( <ffe> )
#M  ViewObj( <ffe> )
#M  ViewString( <ffe> )
#M  Display( <ffe> )
#M  DisplayString( <ffe> )
##
## output methods
##

InstallMethod(String,"for large finite field elements",
        [IsFFE and IsCoeffsModConwayPolRep],
        function(x)
    local   started,  coeffs,  fam,  s,  str,  i;
    if not IsBool(x![3]) then
        return String(x![3]);
    fi;
    started := false;
    coeffs := x![1];
    fam := FamilyObj(x);
    s := Concatenation("Z(",String(fam!.Characteristic),",",String(x![2]),")");
    if Length(coeffs) = 0 then
        str := "0*";
        Append(str,s);
        return str;
    fi;
    str := "";
    if not IsZero(coeffs[1]) then
        Append(str,String(coeffs[1]));
        started := true;
    fi;
    for i in [2..Length(coeffs)] do
        if not IsZero(coeffs[i]) then
            if started then
                Add(str,'+');
            fi;
            if not IsOne(coeffs[i]) then
                Append(str,String(IntFFE(coeffs[i])));
                Add(str,'*');
            fi;
            Append(str,s);
            if i > 2 then
                Add(str,'^');
                Append(str,String(i-1));
            fi;
            started := true;
        fi;
    od;
    if not started then
        str := "0*";
        Append(str,s);
    fi;
    return str;
end);

InstallMethod(PrintObj, "for large finite field elements (use String)",
        [IsFFE and IsCoeffsModConwayPolRep],
        function(x)
    Print(String(x));
end);

BindGlobal( "DisplayStringForLargeFiniteFieldElements",
  function(x)
    local   s,  j,  a;
    if IsZero(x) then
        return "0z\n";
    elif IsOne(x) then
        return "z0\n";
    fi;
    s := "";
    for j in [0..x![2]-1] do
        a := IntFFE(x![1][j+1]);
        if a <> 0 then
            if Length(s) <> 0 then
                Append(s,"+");
            fi;
            if a <> 1 or j = 0 then
                Append(s,String(a));
            fi;
            if j <> 0 then
                Append(s,"z");
                if j <> 1 then
                    Append(s,String(j));
                fi;
            fi;
        fi;
    od;
    Add(s,'\n');
    return s;
  end );

InstallMethod(DisplayString,"for large finite field elements",
        [IsFFE and IsCoeffsModConwayPolRep],
        DisplayStringForLargeFiniteFieldElements );

InstallMethod(Display,"for large finite field elements",
        [IsFFE and IsCoeffsModConwayPolRep],
        function(x)
    Print(DisplayString(x));
end);

InstallMethod(ViewString,"for large finite field elements",
        [IsFFE and IsCoeffsModConwayPolRep],
        function(x)
    local   s;
    s := DisplayStringForLargeFiniteFieldElements(x);
    if Length(s) > GAPInfo.ViewLength*SizeScreen()[1] then
        return Concatenation("<<an element of GF(",
                       String(Characteristic(x)), ", ",
                       String(DegreeFFE(x)),")>>");
    else
        Remove(s); # get rid of trailing newline
        return s;
    fi;
end);

InstallMethod(ViewObj, "for large finite field elements",
        [IsFFE and IsCoeffsModConwayPolRep],
        function(x)
    Print(ViewString(x));
end);

#############################################################################
##
#F FFECONWAY.GetConwayPolCoeffs( <family>, <degree>)
##
## returns stored Conway Polynomial coefficients from family
## triggers computation if needed.
##
FFECONWAY.GetConwayPolCoeffs := function(f,d)
    local   p;

    # because MakeWriteOnceAtomic was applied to fam when it was created,
    # it should be safe to assign fam!.ConwayPolCoeffs as below
    if not IsBound(f!.ConwayPolCoeffs) then
        f!.ConwayPolCoeffs := ShareSpecialObj([]);
    fi;

    atomic readonly f!.ConwayPolCoeffs do
      if IsBound(f!.ConwayPolCoeffs[d]) then
        return f!.ConwayPolCoeffs[d];
      fi;
    od;

    p := f!.Characteristic;
    FFECONWAY.SetUpConwayStuff(p,d);
    # now f!.ConwayPolCoeffs[d] should be set by FFECONWAY.SetUpConwayStuff(p,d);

    atomic readonly f!.ConwayPolCoeffs do
      return f!.ConwayPolCoeffs[d];
    od;
end;




#############################################################################
##
#F FFECONWAY.FiniteFieldEmbeddingRecord(<prime>, <smalldeg>, <bigdeg> )
##
## returns a record (stored in the family after it is first computed)
## describing the embedding of F1 = GF(p^d1) into F2= GF(p^d2). The components
## of this record are:
##
## mat: a <d1> x <d2> matrix whose rows are the canonical basis of F1
## semi: a semi-echelonized version of mat
## convert: a <d1> x <d1> matrix such that <convert>*<mat> = <semi>
## pivots: a vector giving the position of the first non-zero entry in each
##         row of <semi>
##



FFECONWAY.FiniteFieldEmbeddingRecord := function(p, d1,d2)
    local   fam,  c,  n,  zz,  x,  z1,  m,  z,  i,  r,  res;
    fam := FFEFamily(p);
    if not IsBound(fam!.embeddingRecords) then
        fam!.embeddingRecords := AtomicList([]);
    fi;
    if not IsBound(fam!.embeddingRecords[d2]) then
        fam!.embeddingRecords[d2] := MakeWriteOnceAtomic([]);
    fi;
    if not IsBound(fam!.embeddingRecords[d2][d1]) then
        c := FFECONWAY.GetConwayPolCoeffs(fam,d2);
        n := (p^d2-1)/(p^d1-1);
        zz := 0*Z(p);
        x := [zz,Z(p)^0];
        if p <= 256 then
            x := CopyToVectorRep(x,p);
        fi;
        z1 := PowerModCoeffs(x,n,c);
        fam!.ConwayFldEltReducers[d2](z1);
        m := [ZeroMutable(z1),z1];
        m[1,1] := Z(p)^0;
        z := z1;
        for i in [2..d1-1] do
            z := ProductCoeffs(z,z1);
            fam!.ConwayFldEltReducers[d2](z);
            Add(m,z);
        od;
        ConvertToMatrixRep(m,p);
        r := rec( mat := m);
        res := SemiEchelonMatTransformation(r.mat);
        r.semi := res.vectors;
        r.convert := res.coeffs;
        r.pivots := [];
        for i in [1..Length(res.heads)] do
            if res.heads[i] > 0 then
                r.pivots[res.heads[i]] := i;
            fi;
        od;
        Assert(2,d1 = 1 or res.relations = []);
        MakeReadOnlyObj(r);
        fam!.embeddingRecords[d2][d1] := r;
    fi;
    return fam!.embeddingRecords[d2][d1];
end;

#############################################################################
##
#F FFECONWAY.WriteOverLargerField( <ffe>, <bigdeg> )
##
## returns an element written over a field of degree <bigdeg>, but equal to <ffe>
## <ffe> can be an internal FFE or a ZmodpZ object
##

FFECONWAY.WriteOverLargerField := function(x,d2)
    local   fam,  p,  d1,  v,  f, y;
    fam := FamilyObj(x);
    p := fam!.Characteristic;
    if p^d2 <= MAXSIZE_GF_INTERNAL then
        return x;
    fi;
    if not IsCoeffsModConwayPolRep(x) then
        d1 := DegreeFFE(x);
        if d1 = d2 then
            return x;
        fi;
        v := Coefficients(CanonicalBasis(AsField(GF(p,1),GF(p,d1))),x);
    else
        d1 := x![2];
        if d1 = d2 then
            return x;
        fi;
        v := x![1];
    fi;
    Assert(1,d2 mod d1 = 0);
    f := FFECONWAY.FiniteFieldEmbeddingRecord(p,d1,d2);
    if not IsCoeffsModConwayPolRep(x) or x![3] = false then
        y := x;
    elif x![3] <> fail then
        y := x![3];
    else
        y := fail;
    fi;
    return Objectify(fam!.ConwayFldEltDefaultType, [v*f!.mat,d2,y]);
end;

#############################################################################
##
#F FFECONWAY.TryToWriteInSmallerField( <ffe>, <smalldeg> )
##
## returns an element written over a field of degree <smalldeg>, but equal to <ffe>
## if possible, otherwise fail. The returned element may be an internal FFE
## or a ZmodpZ object.
##

FFECONWAY.TryToWriteInSmallerField := function(x,d1)
    local   dmin,  fam,  p,  d2,  smalld,  r,  v,  v2,  i,  piv,  w,
            oversmalld,  z;
    if IsInternalRep(x) then
        return fail;
    fi;
    if IsZmodpZObj(x) then
        return fail;
    fi;
    if d1 = x![2] then
        return fail;
    fi;
    if x![3] = false then
        return fail;
    fi;
    if x![3] <> fail then
        if IsCoeffsModConwayPolRep(x![3]) then
            dmin := x![3]![2];
        else
            dmin := DegreeFFE(x![3]);
        fi;
        if dmin = d1 then
            return x![3];
        elif d1 mod dmin = 0 then
            return FFECONWAY.WriteOverLargerField(x![3],d1);
        else
            return fail;
        fi;
    fi;
    fam := FamilyObj(x);
    p := fam!.Characteristic;
    d2 := x![2];
    if not IsMutable(x![1]) then
        x![1] := ShallowCopy(x![1]);
    fi;
    PadCoeffs(x![1],d2);
    smalld := Gcd(d1,d2);
    r := FFECONWAY.FiniteFieldEmbeddingRecord(p, smalld,d2);
    v := ShallowCopy(x![1]);
    v2 := ZeroMutable(r.convert[1]);
    for i in [1..smalld] do
        piv := r.pivots[i];
        w := r.semi[i];
        x := v[piv]/w[piv];
        AddCoeffs(v,w,-x);
        AddCoeffs(v2,r.convert[i],x);
    od;
    if not IsZero(v) then
        return fail;
    fi;
    if d1 = 1 then
        oversmalld :=  v2[1];
    elif p^d1 <= MAXSIZE_GF_INTERNAL then
        z := Z(p^smalld);
        oversmalld :=  Sum([1..smalld], i-> z^(i-1)*v2[i]);

    else
        oversmalld :=  Objectify(fam!.ConwayFldEltDefaultType,[v2,d1,fail]);
    fi;
    if smalld < d1 then
        return FFECONWAY.WriteOverLargerField(oversmalld, d1);
    else
       return oversmalld;
    fi;
end;

#############################################################################
##
#F FFECONWAY.WriteOverSmallestField( <ffe> )
##
## Returns <ffe> written over the field it generates.
##

FFECONWAY.WriteOverSmallestField := function(x)
    local   d,  f,  fac,  l,  d1,  x1,  x2;
    if IsInternalRep(x) or IsZmodpZObj(x) then
        return x;
    fi;
    if x![3] = false then
        return x;
    elif x![3] <> fail then
        return x![3];
    fi;
    d := x![2];
    f := Collected(Factors(Integers,d));
    for fac in f do
        l := fac[1];
        d1 := d/l;
        x1 := FFECONWAY.TryToWriteInSmallerField(x,d1);
        if x1 <> fail then
            x2 := FFECONWAY.WriteOverSmallestField(x1);
            x![3] := x2;
            return x2;
        fi;
    od;
    x![3] := false;
    return x;
end;

#############################################################################
##
#M DegreeFFE( <ffe> )

InstallMethod(DegreeFFE, [IsCoeffsModConwayPolRep and IsFFE],
        function(x)
    local   y;
    y := FFECONWAY.WriteOverSmallestField(x);
    if  IsCoeffsModConwayPolRep(y)  then
        return y![2];
    else
        return DegreeFFE(y);
    fi;
end);

#############################################################################
##
#M  \=(<ffe>,<ffe>)
##
## Includes equality with internal FFE and ZmodpZ objects
##

InstallMethod(\=,
        IsIdenticalObj,
        [IsCoeffsModConwayPolRep and IsFFE, IsCoeffsModConwayPolRep and IsFFE],
        function(x1,x2)
    local   d1,  d2,  y2,  y1,  d;
    d1 := x1![2];
    d2 := x2![2];
    if d1 = d2 then
        return x1![1] = x2![1];
    fi;
    if d2 mod d1 = 0 then
        y2 := FFECONWAY.TryToWriteInSmallerField(x2,d1);
        if y2 = fail then
            return false;
        else
            return y2![1] = x1![1];
        fi;
    elif d1 mod d2 = 0 then
        y1 := FFECONWAY.TryToWriteInSmallerField(x1,d2);
        if y1 = fail then
            return false;
        else
            return y1![1] = x2![1];
        fi;
    else
        d := Gcd(d1,d2);
        y1 := FFECONWAY.TryToWriteInSmallerField(x1,d);
        if y1 = fail then
            return false;
        fi;
        y2 := FFECONWAY.TryToWriteInSmallerField(x2,d);
        if y2 = fail then
            return false;
        fi;
        return y1 = y2;
    fi;
end);


InstallMethod(\=,
        IsIdenticalObj,
        [IsCoeffsModConwayPolRep and IsFFE, IsFFE],
        function(x1,x2)
    local   d2,  y1;
    d2 := DegreeFFE(x2);
    y1 := FFECONWAY.TryToWriteInSmallerField(x1,d2);
    if y1 = fail then
        return false;
    else
        return y1 = x2;
    fi;
end);

InstallMethod(\=,
        IsIdenticalObj,
        [ IsFFE, IsCoeffsModConwayPolRep and IsFFE],
        function(x1,x2)
    local   d1,  y2;
    d1 := DegreeFFE(x1);
    y2 := FFECONWAY.TryToWriteInSmallerField(x2,d1);
    if y2 = fail then
        return false;
    else
        return y2 = x1;
    fi;
end);

#############################################################################
##
#F FFECONWAY.CoeffsOverCommonField(<ffe>,<ffe>) .. utility function
##
## Returns a length 3 list. The first and second entries of the
## list are the coefficient vectors of the two arguments written over
## a field which contains both of them, whose degree is the third entry
##
FFECONWAY.CoeffsOverCommonField := function(x1,x2)
    local   fam,  d1,  d2,  v1,  v2,  d,  y2,  y1;
    fam := FamilyObj(x1);
    if IsCoeffsModConwayPolRep(x1) then
        d1 := x1![2];
        v1 := x1![1];
    else
        d1 := DegreeFFE(x1);
    fi;
    if IsCoeffsModConwayPolRep(x2) then
        d2 := x2![2];
        v2 := x2![1];
    else
        d2 := DegreeFFE(x2);
    fi;
    if d1 = d2 then
        d := d1;
    elif d1 mod d2 = 0 then
        y2 := FFECONWAY.WriteOverLargerField(x2,d1);
        v2 := y2![1];
        d := d1;
    elif d2 mod d1 = 0 then
        y1 := FFECONWAY.WriteOverLargerField(x1,d2);
        v1 := y1![1];
        d := d2;
    else
        d := Lcm(d1,d2);
        Z(Characteristic(fam),d);
        y1 := FFECONWAY.WriteOverLargerField(x1,d);
        v1 := y1![1];
        y2 := FFECONWAY.WriteOverLargerField(x2,d);
        v2 := y2![1];
    fi;
    return [v1,v2,d];
end;

#############################################################################
##
#F FFECONWAY.SumConwayOtherFFEs( <ffe1>, <ffe2> ) .. Sum method
##   this is the sum method for cases where one of the summands might
##   not be in the Conway field representation.
##

FFECONWAY.SumConwayOtherFFEs := function(x1,x2)
    local   fam,  cc,  v;
    fam := FamilyObj(x1);
    cc := FFECONWAY.CoeffsOverCommonField(x1,x2);
    v := cc[1]+cc[2];
       return Objectify(fam!.ConwayFldEltDefaultType, [v,cc[3],fail]);
end;

#############################################################################
##
#M \+(<ffe1>,<ffe2>)
##
## try and be quick in the common case of two Conway elements over the same field.
## also handle all other cases.

InstallMethod(\+,
        IsIdenticalObj,
        [ IsCoeffsModConwayPolRep and IsFFE,
          IsCoeffsModConwayPolRep and IsFFE],
        function(x1,x2)
    local   v,  d,  cc,  fam;
    if x1![2] = x2![2] then
        v := x1![1]+x2![1];
        d := x1![2];
    else
        cc := FFECONWAY.CoeffsOverCommonField(x1,x2);
        v := cc[1]+cc[2];
        d := cc[3];
    fi;
    fam := FamilyObj(x1);
    return Objectify(fam!.ConwayFldEltDefaultType,
                   [v,d,fail]);
end);

InstallMethod(\+,
        IsIdenticalObj,
        [ IsCoeffsModConwayPolRep and IsFFE,
          IsFFE],
        FFECONWAY.SumConwayOtherFFEs
        );

InstallMethod(\+,
        IsIdenticalObj,
        [ IsFFE,
          IsCoeffsModConwayPolRep and IsFFE],
        FFECONWAY.SumConwayOtherFFEs
        );

InstallMethod(SUM_FFE_LARGE,
        IsIdenticalObj,
        [ IsFFE and IsInternalRep,
          IsFFE and IsInternalRep],
        FFECONWAY.SumConwayOtherFFEs);

FFECONWAY.CATCH_UNEQUAL_CHARACTERISTIC := function(x,y)
    if Characteristic(x) <> Characteristic(y) then
        Error("Binary operation on finite field elements: characteristics must match\n");
    fi;
    TryNextMethod();
end;

InstallMethod(\+, [IsFFE,IsFFE],
        FFECONWAY.CATCH_UNEQUAL_CHARACTERISTIC);

#############################################################################
##
#F FFECONWAY.DiffConwayOtherFFEs( <ffe1>, <ffe2> ) .. Sum method
##   this is the sum method for cases where one of the summands might
##   not be in the Conway field representation.
##

FFECONWAY.DiffConwayOtherFFEs := function(x1,x2)
    local   fam,  cc,  v;
    fam := FamilyObj(x1);
    cc := FFECONWAY.CoeffsOverCommonField(x1,x2);
    v := cc[1]-cc[2];
       return Objectify(fam!.ConwayFldEltDefaultType, [v,cc[3],fail]);
end;

#############################################################################
##
#M \-(<ffe1>,<ffe2>)
##
## try and be quick in the common case of two Conway elements over the same field.
## also handle all other cases.

InstallMethod(\-,
        IsIdenticalObj,
        [ IsCoeffsModConwayPolRep and IsFFE,
          IsCoeffsModConwayPolRep and IsFFE],
        function(x1,x2)
    local   v,  d,  cc,  fam;
    if x1![2] = x2![2] then
        v := x1![1]-x2![1];
        d := x1![2];
    else
        cc := FFECONWAY.CoeffsOverCommonField(x1,x2);
        v := cc[1]-cc[2];
        d := cc[3];
    fi;
    fam := FamilyObj(x1);
    return Objectify(fam!.ConwayFldEltDefaultType,
                   [v,d,fail]);
end);

InstallMethod(\-,
        IsIdenticalObj,
        [ IsCoeffsModConwayPolRep and IsFFE,
          IsFFE],
        FFECONWAY.DiffConwayOtherFFEs
        );

InstallMethod(\-,
        IsIdenticalObj,
        [ IsFFE,
          IsCoeffsModConwayPolRep and IsFFE],
        FFECONWAY.DiffConwayOtherFFEs
        );

InstallMethod(DIFF_FFE_LARGE,
        IsIdenticalObj,
        [ IsFFE and IsInternalRep,
          IsFFE and IsInternalRep],
        FFECONWAY.DiffConwayOtherFFEs);

InstallMethod(\-, [IsFFE,IsFFE],
        FFECONWAY.CATCH_UNEQUAL_CHARACTERISTIC);


#############################################################################
##
#F FFECONWAY.ProdConwayOtherFFEs(<ffe1>,<ffe2>) general product method
##

FFECONWAY.ProdConwayOtherFFEs := function(x1,x2)
    local   fam,  cc,  v;
    fam := FamilyObj(x1);
    cc := FFECONWAY.CoeffsOverCommonField(x1,x2);
    v := ProductCoeffs(cc[1],cc[2]);
    fam!.ConwayFldEltReducers[cc[3]](v);
    return Objectify(fam!.ConwayFldEltDefaultType, [v,cc[3], fail]);
end;

#############################################################################
##
#M \*(<ffe1>, <ffe2>)

InstallMethod(\*,
        IsIdenticalObj,
                [ IsCoeffsModConwayPolRep and IsFFE,
                  IsCoeffsModConwayPolRep and IsFFE],
        function(x1,x2)
    local   v,  d,  cc,  fam;
    if x1![2] = x2![2] then
        v := ProductCoeffs(x1![1],x2![1]);
        d := x1![2];
    else
        cc := FFECONWAY.CoeffsOverCommonField(x1,x2);
        v := ProductCoeffs(cc[1],cc[2]);
        d := cc[3];
    fi;
    fam := FamilyObj(x1);
    fam!.ConwayFldEltReducers[d](v);
    return Objectify(fam!.ConwayFldEltDefaultType,
                   [v,d,fail]);
    end

);

InstallMethod(\*,
        IsIdenticalObj,
                [ IsFFE,
                  IsCoeffsModConwayPolRep and IsFFE],
        FFECONWAY.ProdConwayOtherFFEs
);
InstallMethod(\*,
        IsIdenticalObj,
                [ IsCoeffsModConwayPolRep and IsFFE,
                  IsFFE ],
        FFECONWAY.ProdConwayOtherFFEs
);

InstallMethod(PROD_FFE_LARGE,
        IsIdenticalObj,
        [ IsFFE and IsInternalRep,
          IsFFE and IsInternalRep],
        FFECONWAY.ProdConwayOtherFFEs);

InstallMethod(\*, [IsFFE,IsFFE],
        FFECONWAY.CATCH_UNEQUAL_CHARACTERISTIC);

InstallMethod(QUO, [IsFFE,IsFFE],
        FFECONWAY.CATCH_UNEQUAL_CHARACTERISTIC);


#############################################################################
##
#M AdditiveInverse

InstallMethod(AdditiveInverseOp,
        [ IsCoeffsModConwayPolRep and IsFFE],
        function(x)
    local   fam, y;
    fam := FamilyObj(x);
    if IsBool(x![3]) then
        y := x![3];
    else
        y := -x![3];
    fi;
    return Objectify(fam!.ConwayFldEltDefaultType, [AdditiveInverseMutable(x![1]),x![2],y]);
end);

#############################################################################
##
#M Inverse -- uses Euclids algorithm to express the GCD of x and the ConwayPolynomial
## (which had better be 1!) as r.x + s.c (actually don't compute s). Then r is
## the inverse of x.
##

InstallMethod(InverseOp,
        [ IsCoeffsModConwayPolRep and IsFFE],
        function(x)
    local   t, fam,  p,  d,  c,  a,  b,  r,  s,  qr, y;
    fam := FamilyObj(x);
    p := fam!.Characteristic;
    d := x![2];
    c := FFECONWAY.GetConwayPolCoeffs(fam,d);
    a := ShallowCopy(x![1]);
    b := ShallowCopy(c);
    r := [Z(p)^0];
    if p <= 256 then
        r :=  CopyToVectorRep(r,p);
    fi;
    s := ZeroMutable(r);
    ShrinkRowVector(a);
    if Length(a) = 0 then
        return fail;
    fi;
    while Length(a) > 1 do

        qr := QuotRemCoeffs(b,a);
        b := a;
        a := qr[2];
        ShrinkRowVector(a);
        t := r;
        r := s-ProductCoeffs(r,qr[1]);
        s := t;
    od;
    Assert(1,Length(a) = 1);
    MultVector(r,Inverse(a[1]));
    if AssertionLevel() >= 2 then
        t := ProductCoeffs(x![1],r);
        fam!.ConwayFldEltReducers[d](t);
        if not IsOne(t[1]) or ForAny([2..Length(t)], i->not IsZero(t[i])) then
            Error("Inverse has failed");
        fi;
    fi;
    fam!.ConwayFldEltReducers[d](r);
    if IsBool(x![3]) then
        y := x![3];
    else
        y := Inverse(x![3]);
    fi;
    return MakeReadOnlyObj( Objectify(fam!.ConwayFldEltDefaultType,[r,d,y]) );
end);

InstallMethod(QUO_FFE_LARGE,
        IsIdenticalObj,
        [ IsFFE and IsInternalRep,
          IsFFE and IsInternalRep],
        function(x,y)
    return FFECONWAY.ProdConwayOtherFFEs(x,y^-1);
end);



#############################################################################
##
#M IsZero
##

InstallMethod(IsZero,
        [ IsCoeffsModConwayPolRep and IsFFE],
        x-> IsZero(x![1]));

#############################################################################
##
#M IsOne -- coefficients vector must be [1,0,..0]
##


InstallMethod(IsOne,
        [ IsCoeffsModConwayPolRep and IsFFE],
        function(x)
    local   v,  i;
    v := x![1];
    if not IsOne(v[1]) then
        return false;
    fi;
    for i in [2..Length(v)] do
        if not IsZero(v![i]) then
            return false;
        fi;
    od;
    return true;
end);

#############################################################################
##
#M  ZeroOp -- Make a zero.
##

FFECONWAY.Zero := function(x)
    local   fam,  d;
    fam := FamilyObj(x);
    if not IsBound(fam!.ZeroConwayFFEs) then
        fam!.ZeroConwayFFEs := MakeWriteOnceAtomic([]);
    fi;
    d := x![2];
    if not IsBound(fam!.ZeroConwayFFEs[d]) then
        fam!.ZeroConwayFFEs[d] := MakeReadOnlyObj(Objectify(fam!.ConwayFldEltDefaultType,[ZeroMutable(x![1]),d,
                                          0*Z(fam!.Characteristic)]));
    fi;
    return fam!.ZeroConwayFFEs[d];
end;


InstallMethod(ZeroOp,
        [ IsCoeffsModConwayPolRep and IsFFE],
        FFECONWAY.Zero);

InstallMethod(ZeroImmutable,
        [ IsCoeffsModConwayPolRep and IsFFE],
        FFECONWAY.Zero);



#############################################################################
##
#M OneOp
##

FFECONWAY.One := function(x)
    local   fam,  d,  v;
    fam := FamilyObj(x);
    if not IsBound(fam!.OneConwayFFEs) then
        fam!.OneConwayFFEs := MakeWriteOnceAtomic([]);
    fi;
    d := x![2];
    if not IsBound(fam!.OneConwayFFEs[d]) then
        v := ZeroMutable(x![1]);
        v[1] := Z(fam!.Characteristic)^0;
        fam!.OneConwayFFEs[d] := MakeReadOnlyObj(Objectify(fam!.ConwayFldEltDefaultType,[v,d,
                                         Z(fam!.Characteristic)^0]));
    fi;
    return fam!.OneConwayFFEs[d];
end;


InstallMethod(OneOp,
        [ IsCoeffsModConwayPolRep and IsFFE],
        FFECONWAY.One);

InstallMethod(OneImmutable,
        [ IsCoeffsModConwayPolRep and IsFFE],
        FFECONWAY.One);


#############################################################################
##
#M \<   this is a bit complicated due to the rules for comparing FFEs in GAP
##       We have to identify the smallest field representation of our elements
##       then deal with the possibility that that is in another representation
##

InstallMethod(\<,
        IsIdenticalObj,
        [ IsCoeffsModConwayPolRep and IsLexOrderedFFE,
          IsCoeffsModConwayPolRep and IsLexOrderedFFE ],
        function(x1,x2)
    local   y1,  y2,  d1,  d2;
    y1 := FFECONWAY.WriteOverSmallestField(x1);
    y2 := FFECONWAY.WriteOverSmallestField(x2);
    if IsInternalRep(y1) then
        if IsInternalRep(y2) then
            return y1<y2;
        fi;
        return true;
    elif IsInternalRep(y2) then
        return false;
    fi;
    if IsModulusRep(y1) then
        if IsModulusRep(y2) then
            return y1<y2;
        fi;
        return true;
    elif IsModulusRep(y2) then
        return false;
    fi;

    d1 := y1![2];
    d2 := y2![2];
    if d1 < d2 then
        return true;
    elif d1 > d2 then
        return false;
    fi;
    return y1![1] < y2![1];
end);


InstallMethod(\<,
        IsIdenticalObj,
        [ IsCoeffsModConwayPolRep,
          IsFFE and IsInternalRep ],
        function(x1,x2)
    local   y1;
    y1 := FFECONWAY.WriteOverSmallestField(x1);
    if not IsInternalRep(y1) then
        return false;
    else
        return y1 < x2;
    fi;
end);

InstallMethod(\<,
        IsIdenticalObj,
        [ IsFFE and IsInternalRep,
          IsCoeffsModConwayPolRep],

        function(x1,x2)
    local   y2;
    y2 := FFECONWAY.WriteOverSmallestField(x2);
    if not IsInternalRep(y2) then
        return true;
    else
        return x1 < y2;
    fi;
end);

InstallMethod(\<,
        IsIdenticalObj,
        [ IsCoeffsModConwayPolRep,
          IsFFE and IsModulusRep ],
        function(x1,x2)
    local   y1;
    y1 := FFECONWAY.WriteOverSmallestField(x1);
    if not IsModulusRep(y1) then
        return false;
    else
        return y1 < x2;
    fi;
end);

InstallMethod(\<,
        IsIdenticalObj,
        [ IsFFE and IsModulusRep,
          IsCoeffsModConwayPolRep],

        function(x1,x2)
    local   y2;
    y2 := FFECONWAY.WriteOverSmallestField(x2);
    if not IsModulusRep(y2) then
        return true;
    else
        return x1 < y2;
    fi;
end);

#############################################################################
##
#M  IntFFE
##

InstallMethod(IntFFE,
        [IsFFE and IsCoeffsModConwayPolRep],
        function(x)
    local   i;
    for i in [2..Length(x![1])] do
        if not IsZero(x![1][i]) then
            Error("IntFFE: element must lie in prime field");
        fi;
    od;
    return IntFFE(x![1][1]);
end);

#############################################################################
##
#M  LogFFE( <x>, <base> )
##

InstallMethod( LogFFE,
        IsIdenticalObj,
        [IsFFE and IsCoeffsModConwayPolRep, IsFFE and IsCoeffsModConwayPolRep],
        DoDLog );

InstallMethod( LogFFE,
        IsIdenticalObj,
        [IsFFE and IsInternalRep, IsFFE and IsCoeffsModConwayPolRep],
        DoDLog );

InstallMethod( LogFFE,
        IsIdenticalObj,
        [ IsFFE and IsCoeffsModConwayPolRep, IsFFE and IsInternalRep],
        DoDLog );

#############################################################################
##
#M LargeGaloisField(p,d) -- construct GFs in this size range
##           try next method if it goes wrong, to avoid dependency on
##           method selection sequence.
##
##         Cache fields in the family.
##         Assuming we came via GF we have already passed a cache for last case called
##

InstallMethod( LargeGaloisField,
        [IsPosInt, IsPosInt],
        function(p,d)
    local   fam;
    if not IsPrimeInt(p) then
        Error("LargeGaloisField: Characteristic must be prime");
    fi;
    if d =1 or p^d <= MAXSIZE_GF_INTERNAL then
        TryNextMethod();
    fi;
    fam := FFEFamily(p);
    if not IsBound(fam!.ConwayFieldCache) then
        fam!.ConwayFieldCache := MakeWriteOnceAtomic([]);
    fi;
    if not IsBound(fam!.ConwayFieldCache[d]) then
        fam!.ConwayFieldCache[d] := FieldByGenerators(GF(p,1),[FFECONWAY.ZNC(p,d)]);
    fi;
    return fam!.ConwayFieldCache[d];
end);


#############################################################################
##
#M  PrimitiveRoot for Galois fields
##

InstallMethod(PrimitiveRoot,
        [IsField and IsFFECollection and IsFinite],
        function(f)
    local   p,  d;
    p := Characteristic(f);
    d := DegreeOverPrimeField(f);
    if d > 1 and p^d > MAXSIZE_GF_INTERNAL then
        return FFECONWAY.ZNC(p,d);
    else
        TryNextMethod();
    fi;
end);

#############################################################################
##
#M Coefficients of an element wrt the canonical basis -- are stored in the
##                                                       element
InstallMethod(Coefficients,
        "for a FFE in Conway polynomial representation wrt the canonical basis of its natural field",
        IsCollsElms,
        [IsCanonicalBasis and IsBasisFiniteFieldRep, IsFFE and IsCoeffsModConwayPolRep],
        function(cb,x)
    if not IsPrimeField(LeftActingDomain(UnderlyingLeftModule(cb))) then
        TryNextMethod();
    fi;
    if DegreeOverPrimeField(UnderlyingLeftModule(cb)) <> x![2] then
        TryNextMethod();
    fi;
    PadCoeffs(x![1],x![2]);
    return Immutable(x![1]);
end);

#############################################################################
##
#M Enumerator -- for a GF -- use an Enumerator for the equivalent rowspace
##
## when looking up elements, we may have to promote them to the right field

InstallMethod(Enumerator,
        [IsField and IsFinite and IsFFECollection],
        function(f)
    local   p,  fam,  d,  e,  x;
    if Size(f) <= MAXSIZE_GF_INTERNAL  then
        TryNextMethod();
    fi;
    p := Characteristic(f);
    fam := FFEFamily(p);
    d := DegreeOverPrimeField(f);
    if d = 1 then TryNextMethod(); fi;
    e := Enumerator(RowSpace(GF(p,1),d));
    return EnumeratorByFunctions(f, rec(
                   ElementNumber := function(en,n)
        return Objectify(fam!.ConwayFldEltDefaultType, [ e[n], d, fail]);
        end,
                   NumberElement := function(en,x)
        x := FFECONWAY.WriteOverLargerField(x,d);
        return Position(e,x![1]);
    end));
end);

#############################################################################
##
#M  AsList, Iterator
##
##   since we have a really efficient Enumerator method, lets use it.

InstallMethod(AsList,
        [IsField and IsFinite and IsFFECollection],
        function(f)
    if Size(f) <= MAXSIZE_GF_INTERNAL  then
        TryNextMethod();
    fi;
    return AsList(Enumerator(f));
end);

InstallMethod(Iterator,
        [IsField and IsFinite and IsFFECollection],
        function(f)
    if Size(f) <= MAXSIZE_GF_INTERNAL  then
        TryNextMethod();
    fi;
    return IteratorList(Enumerator(f));
end);

#############################################################################
##
#M  Random -- use Rowspace
##

InstallMethodWithRandomSource( Random,
        "for a random source and a large non-prime finite field",
        [IsRandomSource, IsField and IsFFECollection and IsFinite],
        function(rs, f)
    local   d,  p,  v,  fam;
    if Size(f) <= MAXSIZE_GF_INTERNAL then
        TryNextMethod();
    fi;
    if IsPrimeField(f) then
        TryNextMethod();
    fi;
    d := DegreeOverPrimeField(f);
    p := Characteristic(f);
    v := Random(rs, RowSpace(GF(p,1),d));
    fam := FFEFamily(Characteristic(f));
    return Objectify(fam!.ConwayFldEltDefaultType, [v,d,fail]);
end);

#############################################################################
##
#M  MinimalPolynomial(<fld>,<elm>,<ind>)
##

InstallMethod(MinimalPolynomial,
        IsCollsElmsX,
        [IsPrimeField, IsCoeffsModConwayPolRep and IsFFE, IsPosInt],
        function(fld, elm, ind)
    local   fam,  d,  dd,  x,  y,  p,  o,  m,  i,  r;
    fam := FamilyObj(elm);
    d := DegreeFFE(elm);
    dd := elm![2];
    x := elm![1];
    y := x;
    p := Characteristic(elm);
    o := ListWithIdenticalEntries(dd,Z(p)*0);
    o[1] := Z(p)^0;
    if p <= 256 then
        o := CopyToVectorRep(o,p);
    fi;
    m := [o,y];
    for i in [2..d] do
        y := ProductCoeffs(y,x);
        fam!.ConwayFldEltReducers[dd](y);
        Add(m,y);
    od;
    ConvertToMatrixRep(m,p);
    r := SemiEchelonMatTransformation(m);
    Assert(1, Length(r.relations) = 1);
    return UnivariatePolynomialByCoefficients(fam, r.relations[1],ind);
end);



#############################################################################
##
#M  Display for matrix of ffes
##

InstallMethod( Display,
    "for matrix of FFEs (for larger fields)",
    [ IsFFECollColl and IsMatrix ], 10, # prefer this to existing method
        function(m)
    local   deg,  chr,  d,  w,  r,  dr,  x,  s,  y,  j,  a;
    if Length(m) = 0 or Length(m[1])= 0 then
        TryNextMethod();
    fi;
    deg  := Lcm( List( m, DegreeFFE ) );
    chr  := Characteristic(m[1,1]);
    if deg = 1 or chr^deg <= MAXSIZE_GF_INTERNAL then
        TryNextMethod();
    fi;
    Print("z = Z( ",chr,", ",deg,"); z2 = z^2, etc.\n");
    d := [];
    w := 1;
    for r in m do
        dr := [];
        for x in r do
            if IsZero(x) then
                Add(dr,".");
            else
                s := "";
                y := FFECONWAY.WriteOverLargerField(x,deg);
                for j in [0..deg-1] do
                    a := IntFFE(y![1][j+1]);
                    if a <> 0 then
                        if Length(s) <> 0 then
                            Append(s,"+");
                        fi;
                        if a = 1 and j = 0 then
                            Append(s,"1");
                        else
                            if a <> 1 then
                                Append(s,String(a));
                            fi;
                            if j <> 0 then
                                Append(s,"z");
                                if j <> 1 then
                                    Append(s,String(j));
                                fi;
                            fi;
                        fi;
                    fi;
                od;
                Add(dr,s);
                if Length(s) > w then
                    w := Length(s);
                fi;
            fi;
        od;
        Add(d,dr);
    od;
    for dr in d do
        for s in dr do
            Print(String(s,-w-1));
        od;
        Print("\n");
    od;
end);

#############################################################################
##
#F  FFECONWAY.WriteOverSmallestCommonField( <v> )
##

FFECONWAY.WriteOverSmallestCommonField := function(v)
    local   d,  degs,  p,  x,  dx,  i;
    d := 1;
    degs := [];
    p := Characteristic(v[1]);
    for x in v do
        if not IsFFE(x) or Characteristic(x) <> p then
            return fail;
        fi;
        dx := DegreeFFE(x);
        Add(degs, dx);
    od;
    d := Lcm(Set(degs));
    for i in [1..Length(v)] do
        if IsCoeffsModConwayPolRep(v[i]) then
            if d < v[i]![2] then
                v[i] := FFECONWAY.TryToWriteInSmallerField(v[i],d);
            elif d > v[i]![2] then
                v[i] := FFECONWAY.WriteOverLargerField(v[i],d);
            fi;
        fi;
    od;
    return p^d;
end;

#############################################################################
##
#M  AsInternalFFE( <conway ffe> )
##
InstallMethod( AsInternalFFE, [IsFFE and IsCoeffsModConwayPolRep],
        function (x)
    local y;
    y := FFECONWAY.WriteOverSmallestField(x);
    if IsInternalRep(y) then
        return y;
    else
        return fail;
    fi;
end);


SetNamesForFunctionsInRecord("FFECONWAY");
MakeImmutable(FFECONWAY);
