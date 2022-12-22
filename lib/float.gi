#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton, Laurent Bartholdi.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file deals with floats, and sets up a default interface, within GAP,
##  to deal with floateans.
##

#############################################################################
## a category describing the "fields" of floating-point numbers
## we must put it here, because float.gd is read too early for "IsAlgebra"
## this is used mainly to create polynomials
DeclareCategory("IsFloatPseudoField", IsAlgebra);

## these things should also be in float.gd, but require IsRationalFunction
DeclareCategory("IsFloatRationalFunction", IsRationalFunction);
DeclareSynonym("IsFloatPolynomial", IsFloatRationalFunction and IsPolynomial);
DeclareSynonym("IsFloatUnivariatePolynomial", IsFloatRationalFunction and IsUnivariatePolynomial);
DeclareOperation("Value", [IsFloatRationalFunction,IsFloat]);
DeclareOperation("ValueInterval", [IsFloatRationalFunction,IsFloat]);
#############################################################################

MAX_FLOAT_LITERAL_CACHE_SIZE := 0; # cache all float literals by default.

FLOAT_DEFAULT_REP := fail;
FLOAT_STRING := fail;
FLOAT_PSEUDOFIELD := fail;
FLOAT := fail; # holds the constants
if IsHPCGAP then
    BindGlobal("EAGER_FLOAT_LITERAL_CONVERTERS", AtomicRecord());
else
    BindGlobal("EAGER_FLOAT_LITERAL_CONVERTERS", rec());
fi;

InstallGlobalFunction(SetFloats, function(arg)
    local i, r, prec, install;

    r := fail;
    prec := fail;
    install := true;
    for i in [1..Length(arg)] do
        if IsRecord(arg[i]) and i=1 then
            r := arg[1];
        elif IsBool(arg[i]) then
            install := arg[i];
        elif IsPosInt(arg[i]) then
            prec := arg[i];
        else
            r := fail;
            break;
        fi;
    od;
    while r=fail do
        Error("SetFloats requires a record, and optional precision(posint) and install(bool), not ",arg);
    od;

    if install then
        if IsBound(r.filter) then
            FLOAT_DEFAULT_REP := r.filter;
        fi;
        if IsBound(r.constants) then
            FLOAT := r.constants;
        fi;
        if IsBound(r.creator) then
            FLOAT_STRING := r.creator;
        fi;
        if IsBound(r.field) then
            FLOAT_PSEUDOFIELD := r.field;
        fi;
    fi;

    if IsBound(r.creator) and IsBound(r.eager) then
        EAGER_FLOAT_LITERAL_CONVERTERS.([r.eager]) := r.creator;
    fi;

    FLUSH_FLOAT_LITERAL_CACHE();

    if prec<>fail then
        r.constants.MANT_DIG := prec;
        if IsBound(r.constants.recompute) then
            r.constants.recompute(r.constants,prec);
        fi;
    fi;
end);

################################################################
# creators
################################################################
InstallGlobalFunction(Float, function(obj)
    if not IsString(obj) and IsList(obj) then
        return List(obj,Float);
    else
        return NewFloat(FLOAT_DEFAULT_REP,obj);
    fi;
end);

BindGlobal("INSTALLFLOATCONSTRUCTORS", function(arg)
    local filter, float, constants, i;

    if IsRecord(arg[1]) then
        filter := arg[1].filter;
    else
        filter := arg[1];
    fi;

    # we intentionally provide no default method for converting rationals, as
    # implementing this accurately depends a lot on the specific floatean type

    InstallMethod(NewFloat, [filter,IsInfinity], -1, function(filter,obj)
        return Inverse(NewFloat(filter,0));
    end);

    InstallMethod(NewFloat, [filter,IsNegInfinity], -1, function(filter,obj)
        return -Inverse(NewFloat(filter,0));
    end);

    InstallMethod(NewFloat, [filter,IsList], -1, function(filter,mantexp)
        if mantexp[1]=0 then
            if mantexp[2]=0 then return NewFloat(filter,0);
            elif mantexp[2]=1 then return Inverse(-Inverse(NewFloat(filter,0)));
            elif mantexp[2]=2 then return Inverse(NewFloat(filter,0));
            elif mantexp[2]=3 then return -Inverse(NewFloat(filter,0));
            else return NewFloat(filter,0)/NewFloat(filter,0);
            fi;
        fi;
        return NewFloat(filter,mantexp[1])*2^(mantexp[2]-LogInt(AbsoluteValue(mantexp[1]),2)-1);
    end);

    InstallMethod(NewFloat, [filter,filter], -1, function(filter,obj)
        return obj; # floats are immutable, no harm to return the same one
    end);

    InstallMethod(MakeFloat, [filter,IsInfinity], -1, function(filter,obj)
        return Inverse(MakeFloat(filter,0));
    end);

    InstallMethod(MakeFloat, [filter,IsNegInfinity], -1, function(filter,obj)
        return -Inverse(MakeFloat(filter,0));
    end);

    InstallMethod(MakeFloat, [filter,IsList], -1, function(filter,mantexp)
        if mantexp[1]=0 then
            if mantexp[2]=0 then return MakeFloat(filter,0);
            elif mantexp[2]=1 then return Inverse(-Inverse(MakeFloat(filter,0)));
            elif mantexp[2]=2 then return Inverse(MakeFloat(filter,0));
            elif mantexp[2]=3 then return -Inverse(MakeFloat(filter,0));
            else return MakeFloat(filter,0)/MakeFloat(filter,0);
            fi;
        fi;
        return MakeFloat(filter,mantexp[1])*2^(mantexp[2]-LogInt(AbsoluteValue(mantexp[1]),2)-1);
    end);

    InstallMethod(MakeFloat, [filter,filter], -1, function(filter,obj)
        return obj; # floats are immutable, no harm to return the same one
    end);

    if IsRecord(arg[1]) and IsBound(arg[1].constants) then
        float := arg[1].constants;
        constants := [["E","2.7182818284590452354"],
                      ["LOG2E", "1.4426950408889634074"],
                      ["LOG10E", "0.43429448190325182765"],
                      ["LN2", "0.69314718055994530942"],
                      ["LN10", "2.30258509299404568402"],
                      ["PI", "3.14159265358979323846"],
                      ["2PI", "6.28318530717958647692"],
                      ["PI_2", "1.57079632679489661923"],
                      ["PI_4", "0.78539816339744830962"],
                      ["1_PI", "0.31830988618379067154"],
                      ["2_PI", "0.63661977236758134308"],
                      ["2_SQRTPI", "1.12837916709551257390"],
                      ["SQRT2", "1.41421356237309504880"],
                      ["SQRT1_2", "0.70710678118654752440"]];
        for i in constants do
            if not IsBound(float.(i[1])) then
                float.(i[1]) := NewFloat(filter,i[2]);
            fi;
        od;
    fi;
end);
################################################################
# inner converter from string to float
################################################################
BindGlobal("CONVERT_FLOAT_LITERAL", function(s)
    local i,f,s1;
    f:= FLOAT_STRING(s);
    if f<>fail then return f; fi;

    s1 := "";
    for i in [1..LENGTH(s)] do
        if s[i] in ".0123456789eE+-" then
            s1[i] := s[i];
        elif s[i] in "dDqQ" then
            s1[i] := 'e';
        else
            s1 := fail; break;
        fi;
    od;
    if s1<>fail then
        f := FLOAT_STRING(s1);
        if f<>fail then return f; fi;
    fi;

    return fail; # conversion failure; signal the kernel that something went wrong
end);

BindGlobal("CONVERT_FLOAT_LITERAL_EAGER", function(s,mark)
    local f;
    if mark = '\000' then
        return CONVERT_FLOAT_LITERAL(s);
    else
        if not IsBound(EAGER_FLOAT_LITERAL_CONVERTERS.([mark])) then
            Error("Unknown float literal conversion ",mark);
        else
            f := EAGER_FLOAT_LITERAL_CONVERTERS.([mark]);
            if not IsFunction(f) then
                Error("Float literal conversion for ",mark," bound to non-function");
            fi;
            return f(s);
        fi;
    fi;
end);

################################################################
# zeros
################################################################
InstallGlobalFunction(RootsFloat, function(arg)
    local l;
    if Length(arg)=1 and IsList(arg[1]) then
        l := arg[1];
    elif ForAll(arg,IsFloat) then
        l := arg;
    elif Length(arg)=1 and IsUnivariatePolynomial(arg[1]) then
        l := CoefficientsOfUnivariatePolynomial(arg[1]);
    else
        Error("RootsFloat: expected coefficients, a list of coefficients, or a polynomial, not ",arg);
    fi;
    if Length(l)=0 then return []; fi;
    return RootsFloatOp(l,l[1]);
end);

#############################################################################
## Default methods
##
## These methods have priority -1, because they are inefficient.
## Hopefully every float implementation implements them better.
#############################################################################
InstallMethod( Diameter, "for a float interval", [ IsFloatInterval ],
        AbsoluteDiameter );

InstallMethod( AbsoluteValue, "for real floats", [ IsRealFloat ], -1,
        function ( x )
    if x < Zero(x) then return -x; else return x; fi;
end );

InstallMethod( Norm, "for real floats", [ IsRealFloat ], -1,
        function ( x )
    return x*x;
end );

InstallMethod( SignFloat, "for real floats", [ IsRealFloat ], -1,
        function ( x )
    if IsZero( x ) then
        return 0;
    elif x < Zero( x ) then
        return -1;
    else
        return 1;
    fi;
end );

InstallMethod( Exp2, "for floats", [ IsFloat ], -1,
        function ( x )
    return Exp(Log(MakeFloat(x,2))*x);
end );

InstallMethod( Exp10, "for floats", [ IsFloat ], -1,
        function ( x )
    return Exp(Log(MakeFloat(x,10))*x);
end );

InstallMethod( Expm1, "for floats", [ IsFloat ], -1,
        function ( x )
    return Exp(x)-MakeFloat(x,1);
end );

InstallMethod( Log2, "for floats", [ IsFloat ], -1,
        function ( x )
    return Log(x) / Log(MakeFloat(x,2));
end );

InstallMethod( Log10, "for floats", [ IsFloat ], -1,
        function ( x )
    return Log(x) / Log(MakeFloat(x,10));
end );

InstallMethod( Log1p, "for floats", [ IsFloat ], -1,
        function ( x )
    return Log(MakeFloat(x,1)+x);
end );

InstallMethod( Sec, "for floats", [ IsFloat ], -1,
        function ( x )
    return Inverse(Cos(x));
end );

InstallMethod( Csc, "for floats", [ IsFloat ], -1,
        function ( x )
    return Inverse(Sin(x));
end );

InstallMethod( Cot, "for floats", [ IsFloat ], -1,
        function ( x )
    return Inverse(Tan(x));
end );

InstallMethod( Sech, "for floats", [ IsFloat ], -1,
        function ( x )
    return Inverse(Cosh(x));
end );

InstallMethod( Csch, "for floats", [ IsFloat ], -1,
        function ( x )
    return Inverse(Sinh(x));
end );

InstallMethod( Coth, "for floats", [ IsFloat ], -1,
        function ( x )
    return Inverse(Tanh(x));
end );

InstallMethod( CubeRoot, "for floats", [ IsFloat ], -1,
        function ( x )
    if x>Zero(x) then
        return Exp(Log(x)/3);
    elif IsZero(x) then
        return x;
    else
        return -Exp(Log(-x)/3);
    fi;
end );

InstallMethod( Square, "for floats", [ IsFloat ], -1,
        function ( x )
    return x*x;
end );

InstallMethod( Hypothenuse, "for floats", [ IsFloat, IsFloat ], -1,
        function ( x, y )
    return Sqrt(x*x+y*y);
end );

InstallMethod( Ceil, "for real floats", [ IsRealFloat ], -1,
        function ( x )
    return -Floor(-x);
end );

# this is disabled because it's so bad... it loses an ulp in fringe cases.
#InstallMethod( Round, "for floats", [ IsFloat ], -1,
#        function ( x )
#    return Floor(x+MakeFloat(x,1/2));
#end );

InstallMethod( Trunc, "for real floats", [ IsRealFloat ], -1,
        function ( x )
    if x>Zero(x) then
        return Floor(x);
    else
        return -Floor(-x);
    fi;
end );

InstallMethod( Frac, "for floats", [ IsFloat ], -1,
        function ( x )
    return x-Floor(x);
end );

InstallMethod( SinCos, "for floats", [ IsFloat ], -1,
        function ( x )
    return [Sin(x), Cos(x)];
end );

InstallMethod( Hypothenuse, "for floats", [ IsFloat, IsFloat ], -1,
        function ( x, y )
    return Sqrt(x*x+y*y);
end );

InstallMethod( FrExp, "for floats", [ IsFloat ], -1,
        function(obj)
    local m, e;
    if IsZero(obj) then return [0,0]; fi;
    if obj<=Zero(obj) then obj := -obj; fi;
    e := Int(Log2(obj))+1;
    m := obj/2^e;
    return [m,e];
end);

InstallMethod( LdExp, "for floats", [ IsFloat, IsInt ], -1,
        function(m,e)
    return m*2^e;
end);

InstallMethod( ExtRepOfObj, "for floats", [ IsFloat ], -1,
        function(obj)
    local p, v;
    if IsZero(obj) then # special treatment for 0 and -0
        if 1/obj > Zero(obj) then
            return [0,0];
        else
            return [0,1];
        fi;
    elif IsPInfinity(obj) then
        return [0,2];
    elif IsNInfinity(obj) then
        return [0,3];
    elif IsNaN(obj) then
        return [0,4];
    fi;

    p := FrExp(obj);
    v := p[1];
    while v mod One(v) <> Zero(v) do v := 2*v; od;
    return [Int(v),p[2]];
end);

InstallMethod( ObjByExtRep, "for floats", [ IsFloatFamily, IsCyclotomicCollection ], -1,
        function(fam,obj)
    if obj[1]=0 then
        if obj[2]=0 then
            return 0.0; # 0
        elif obj[2]=1 then
            return 1/(-(1.0/0.0)); # -0
        elif obj[2]=2 then
            return 1.0/0.0; # inf
        elif obj[2]=3 then
            return -1.0/0.0; # -inf
        elif obj[2]=4 then
            return 0.0/0.0; # NaN
        elif obj[2]=5 then
            return -0.0/0.0; # -NaN
        else
            Error("Unknown external float representation ",obj);
        fi;
    fi;
    return LdExp(Float(obj[1]),obj[2]-LogInt(AbsInt(obj[1]),2)-1);
end);

InstallMethod( ViewObj, "for floats", [ IsFloat ],
        function ( x )
    Print(ViewString(x));
end);

InstallMethod( Display, "for floats", [ IsFloat ],
        function ( x )
    Print(DisplayString(x));
end);

InstallMethod( PrintObj, "for floats", [ IsFloat ],
        function ( x )
    Print(String(x));
end);

InstallMethod( DisplayString, "for floats", [ IsFloat ], f->Concatenation(String(f),"\n"));

InstallMethod( ViewString, "for floats", [ IsFloat ], String );

InstallMethod( IsPInfinity, "for floats", [ IsFloat ], -1,
        x->x=x+x and x>-x);

InstallMethod( IsNInfinity, "for floats", [ IsFloat ], -1,
        x->x=x+x and x<-x);

InstallMethod( IsXInfinity, "for floats", [ IsFloat ], -1,
        x->x=x+x and x<>-x);

InstallMethod( IsFinite, "for floats", [ IsFloat ], -1,
        x->not IsXInfinity(x) and not IsNaN(x));

InstallMethod( IsNaN, "for floats", [ IsFloat ], -1, # IEEE754, not GAP standard
        x->x<>x+Zero(x));

InstallMethod( EqFloat, "for floats", [ IsFloat, IsFloat ], -1,
        function(x,y)
    return (not IsNaN(x)) and x=y;
end);

InstallMethod( Zero, "for floats", [ IsFloat ], -1,
        function(x)
    return MakeFloat(x,0);
end);

InstallMethod( One, "for floats", [ IsFloat ], -1,
        function(x)
    return MakeFloat(x,1);
end);
#############################################################################
##
#M  Rat( x ) . . . . . . . . . . . . . . . . . . . . . . . . . . . for macfloats
##
InstallOtherMethod( Rat, "for floats", [ IsFloat ],
        function ( x )

    local  M, a_i, i, sign, maxdenom, maxpartial;

    if not IsFinite(x) then
        Error("cannot convert float ", x, " to rational");
    fi;

    i := 0; M := [[1,0],[0,1]];
    maxdenom := ValueOption("maxdenom");
    maxpartial := ValueOption("maxpartial");
    if maxpartial=fail then maxpartial := 10000; fi;
    if maxdenom=fail then maxdenom := 10^QuoInt(FLOAT.DECIMAL_DIG,2); fi;

    if x < Zero(x) then sign := -1; x := -x; else sign := 1; fi;
    repeat
      a_i := Int(x);
      if i >= 1 and a_i > maxpartial then break; fi;
      M := M * [[a_i,1],[1,0]];
      if x = Float(a_i) then break; fi;
      x := One(x) / (x - a_i);
      i := i+1;
    until M[2][1] > maxdenom;
    return sign * M[1][1]/M[2][1];
end );

InstallOtherMethod( Rat, "for float intervals", [ IsFloatInterval ],
        function ( x )
    local M, a;

    if x < Zero(x) then
        M := [[-1,0],[0,1]]; x := -x;
    else
        M := [[1,0],[0,1]];
    fi;
    repeat
        a := Int(Sup(x));
        M := M * [[a,1],[1,0]];
        x := x-a;
        if Zero(x) in x then break; fi;
        x := Inverse(x);
    until AbsoluteDiameter(x) >= One(x);
    return M[1][1]/M[2][1];
end);

BindGlobal("CYC_FLOAT_DEGREE", function(x,n,prec)
    local i, m, b, phi;

    phi := Phi(n);
    m := IdentityMat(phi+1);
    b := [];
    for i in [1..phi] do
        Add(m[i],Int(LdExp(Cos(FLOAT.2PI*(i-1)/n),prec)));
        Add(m[i],Int(LdExp(Sin(FLOAT.2PI*(i-1)/n),prec)));
        b[i] := E(n)^(i-1);
    od;
    Add(m[phi+1],Int(LdExp(RealPart(x),prec)));
    Add(m[phi+1],Int(LdExp(ImaginaryPart(x),prec)));

    m := First(LLLReducedBasis(m).basis,r->r[phi+1]<>0);

    return -b*m{[1..phi]}/m[phi+1];
end);

BindGlobal("CYC_FLOAT", function(x,prec)
    local n, len, e, minlen, minn, mine;

    n := 2;
    minlen := infinity;
    repeat
        e := CYC_FLOAT_DEGREE(x,n,prec);
        len := n*Norm(DenominatorCyc(e)*e)^2;
        if len < minlen then
            Info(InfoWarning,2,"Degree ",n,": ",e);
            minlen := len;
            minn := n;
            mine := e;
        fi;
        n := n+1;
    until n > 2*minn+4;
    return mine;
end);

InstallMethod( Cyc, "for floats, degree", [ IsFloat, IsPosInt ], -1,
        function(x,n)
    local prec;

    prec := ValueOption("bits");
    if not IsPosInt(prec) then prec := PrecisionFloat(x); fi;

    return CYC_FLOAT_DEGREE(x,n,prec);
end);

InstallMethod( Cyc, "for intervals, degree", [ IsFloatInterval, IsPosInt ], -1,
        function(x,n)
    local diam;

    diam := AbsoluteDiameter(x);
    if IsZero(diam) then
        return CYC_FLOAT_DEGREE(Mid(x),n,PrecisionFloat(x));
    else
        return CYC_FLOAT_DEGREE(Mid(x),n,1+LogInt(1+Int(Inverse(diam)),2));
    fi;
end);

InstallMethod( Cyc, "for floats", [ IsFloat ], -1,
        function(x)
    local prec;

    prec := ValueOption("bits");
    if not IsPosInt(prec) then prec := PrecisionFloat(x); fi;

    return CYC_FLOAT(x,prec);
end);

InstallMethod( Cyc, "for intervals", [ IsFloatInterval ], -1,
        function(x)
    local diam;

    diam := AbsoluteDiameter(x);
    if IsZero(diam) then
        return CYC_FLOAT(Mid(x),PrecisionFloat(x));
    else
        return CYC_FLOAT(Mid(x),1+LogInt(1+Int(Inverse(diam)),2));
    fi;
end);

BindGlobal("FLOAT_MINIMALPOLYNOMIAL", function(x,n,ind,prec)
    local z, i, m;

    m := IdentityMat(n);
    z := LdExp(One(x),prec);
    for i in [1..n] do
        Add(m[i],Int(RealPart(z)));
        Add(m[i],Int(ImaginaryPart(z)));
        z := z*x;
    od;

    m := LLLReducedBasis(m).basis[1];

    return UnivariatePolynomialByCoefficients(CyclotomicsFamily,m{[n,n-1..1]},ind);
end);

InstallMethod( MinimalPolynomial, "for floats", [ IsRationals, IsFloat, IsPosInt ],
        function(ring,x,ind)
    local n, len, p, lastlen, lastp, prec;

    prec := ValueOption("bits");
    if not IsPosInt(prec) then
        prec := PrecisionFloat(x);
        if IsFloatInterval(x) then
            p := AbsoluteDiameter(x);
            if not IsZero(x) then
                prec := 1+LogInt(1+Int(Inverse(p)),2);
            fi;
        fi;
    fi;
    if IsFloatInterval(x) then
        x := Mid(x);
    fi;

    n := ValueOption("degree");
    if IsPosInt(n) then
        return FLOAT_MINIMALPOLYNOMIAL(x,n+1,ind,prec);
    fi;
    n := 1;
    len := infinity;
    p := fail;
    repeat
        lastlen := len;
        lastp := p;
        p := FLOAT_MINIMALPOLYNOMIAL(x,n+1,ind,prec);
        len := (CoefficientsOfUnivariatePolynomial(p)^2)^n;
        n := n+1;
    until len > lastlen;
    return lastp;
end);

################################################################
# rational functions
################################################################
# we need a new method, so that we keep track of the 0 and 1 of the
# specific pseudofield
InstallOtherMethod(RationalFunctionsFamily, "floats pseudofield",
        [IsFloatPseudoField],
        function(pf)
  local   fam;

  # create a new family in the category <IsRationalFunctionsFamily>
  fam := NewFamily("RationalFunctionsFamily(...)",
                 IsPolynomialFunction and IsPolynomialFunctionsFamilyElement
                 and IsFloatRationalFunction and IsRationalFunctionsFamilyElement,
                 CanEasilySortElements,
          IsPolynomialFunctionsFamily and CanEasilySortElements and
          IsRationalFunctionsFamily);

  # default type for polynomials
  fam!.defaultPolynomialType := NewType( fam,
          IsPolynomial and IsPolynomialDefaultRep and
          HasExtRepPolynomialRatFun);

  # default type for univariate laurent polynomials
  fam!.threeLaurentPolynomialTypes :=
    [ NewType( fam,
          IsLaurentPolynomial
          and IsLaurentPolynomialDefaultRep and
          HasIndeterminateNumberOfLaurentPolynomial and
          HasCoefficientsOfLaurentPolynomial),

          NewType( fam,
            IsLaurentPolynomial
            and IsLaurentPolynomialDefaultRep and
            HasIndeterminateNumberOfLaurentPolynomial and
            HasCoefficientsOfLaurentPolynomial and
            IsConstantRationalFunction and IsUnivariatePolynomial),

          NewType( fam,
            IsLaurentPolynomial and IsLaurentPolynomialDefaultRep and
            HasIndeterminateNumberOfLaurentPolynomial and
            HasCoefficientsOfLaurentPolynomial and
            IsUnivariatePolynomial)];

  # default type for univariate rational functions
  fam!.univariateRatfunType := NewType( fam,
          IsUnivariateRationalFunctionDefaultRep  and
          HasIndeterminateNumberOfLaurentPolynomial and
          HasCoefficientsOfUnivariateRationalFunction);

  fam!.defaultRatFunType := NewType( fam,
          IsRationalFunctionDefaultRep and
          HasExtRepNumeratorRatFun and HasExtRepDenominatorRatFun);

  # functions to add zipped lists
  fam!.zippedSum := [ MONOM_GRLEX, \+ ];

  # functions to multiply zipped lists
  fam!.zippedProduct := [ MONOM_PROD,
                          MONOM_GRLEX, \+, \* ];

  # set the one and zero coefficient
  fam!.zeroCoefficient := Zero(pf);
  fam!.oneCoefficient  := One(pf);
  fam!.oneCoefflist  := Immutable([fam!.oneCoefficient]);

  # set the coefficients
  SetCoefficientsFamily( fam, FamilyObj(fam!.zeroCoefficient) );

  SetCharacteristic( fam, 0 );

  # and set one and zero
  SetZero( fam, PolynomialByExtRepNC(fam,[]));
  SetOne( fam, PolynomialByExtRepNC(fam,[[],fam!.oneCoefficient]));

  # we will store separate `one's for univariate polynomials. This will
  # allow to keep univariate calculations in this one indeterminate.
  fam!.univariateOnePolynomials:=[];
  fam!.univariateZeroPolynomials:=[];

  # assign a names list
  fam!.namesIndets := [];

  # and return
  return fam;
end);

InstallOtherMethod( UnivariatePolynomialByCoefficients, "ring",
        [IsFloatPseudoField,IsList,IsInt],
        function(r,cofs,ind)
    return LaurentPolynomialByCoefficients(r,cofs,0,ind);
end );

InstallOtherMethod( LaurentPolynomialByCoefficients, "ring",
        [IsFloatPseudoField,IsList,IsInt,IsInt],
        function(r,cofs,val,ind)
    local lc, fam;
    lc := Length(cofs);
    fam := RationalFunctionsFamily(r);
    if lc > 0 and (IsZero( cofs[1] ) or IsZero( cofs[lc] ))  then
        cofs := ShallowCopy( cofs );
        val := val + RemoveOuterCoeffs( cofs, fam!.zeroCoefficient );
    fi;
    return LaurentPolynomialByExtRepNC( fam, cofs, val, ind );
end );

InstallOtherMethod( UnivariateRationalFunctionByCoefficients, "ring",
        [IsFloatPseudoField,IsList,IsList,IsInt],
        function(r,ncof,dcof,val)
    return UnivariateRationalFunctionByCoefficients(r,ncof,dcof,val,1);
end );

InstallOtherMethod( UnivariateRationalFunctionByCoefficients, "ring",
        [IsFloatPseudoField,IsList,IsList,IsInt,IsInt],
        function(r,ncof,dcof,val,ind)
    local fam;
    fam := RationalFunctionsFamily( r );
    if Length( ncof ) > 0 and (IsZero( ncof[1] ) or IsZero( ncof[Length( ncof )] ))  then
        if not IsMutable( ncof )  then
            ncof := ShallowCopy( ncof );
        fi;
        val := val + RemoveOuterCoeffs( ncof, fam!.zeroCoefficient );
    fi;
    if Length( dcof ) > 0 and (IsZero( dcof[1] ) or IsZero( dcof[Length( dcof )] ))  then
        if not IsMutable( dcof )  then
            dcof := ShallowCopy( dcof );
        fi;
        val := val - RemoveOuterCoeffs( dcof, fam!.zeroCoefficient );
    fi;
    return UnivariateRationalFunctionByExtRepNC( fam, ncof, dcof, val, ind );
end );

InstallMethod( PolynomialRing,"indetlist", true, [ IsFloatPseudoField, IsList ],
  1,
function( r, n )
    local   rfun,  zero,  one,  ind,  i,  type,  prng;

    if IsPolynomialFunctionCollection(n) and ForAll(n,IsLaurentPolynomial) then
      n:=List(n,IndeterminateNumberOfLaurentPolynomial);
    fi;
    if IsEmpty(n) or not IsInt(n[1]) then
      TryNextMethod();
    fi;

    # get the rational functions of the elements family
    rfun := RationalFunctionsFamily(r);

    # cache univariate rings - they might be created often
    if not IsBound(r!.univariateRings) then
      r!.univariateRings:=[];
    fi;

    if Length(n)=1
      # some bozo might put in a ridiculous number
      and n[1]<10000
      # only cache for the prime field
      and IsField(r)
      and IsBound(r!.univariateRings[n[1]]) then
      return r!.univariateRings[n[1]];
    fi;

    # first the indeterminates
    zero := Zero(r);
    one  := One(r);
    ind  := [];
    for i  in n  do
        Add( ind, LaurentPolynomialByCoefficients(r,[one],1,i) );
    od;

    # construct a polynomial ring
    type := IsPolynomialRing and IsAttributeStoringRep and IsFreeLeftModule and IsAlgebraWithOne;

    if Length(n) = 1 then
        type := type and IsUnivariatePolynomialRing and IsEuclideanRing;
                     #and IsAlgebraWithOne; # done above already
    fi;

    prng := Objectify( NewType( CollectionsFamily(rfun), type ), rec() );

    # set the left acting domain
    SetLeftActingDomain( prng, r );

    # set the indeterminates
    SetIndeterminatesOfPolynomialRing( prng, ind );

    # set known properties
    SetIsFinite( prng, false );
    SetIsFiniteDimensional( prng, false );
    SetSize( prng, infinity );

    # set the coefficients ring
    SetCoefficientsRing( prng, r );

    # set one and zero
    SetOne(  prng, ind[1]^0 );
    SetZero( prng, ind[1]*zero );

    # set the generators left operator ring-with-one if the rank is one
    if IsRingWithOne(r) then
        SetGeneratorsOfLeftOperatorRingWithOne( prng, ind );
    fi;


    if Length(n)=1 and n[1]<10000
      # only cache for the prime field
      and IsField(r) then
      r!.univariateRings[n[1]]:=prng;
    fi;

    # and return
    return prng;
end );

InstallOtherMethod( Indeterminate, [IsFloatFamily,IsPosInt],
        function(fam,ind)
    Error("`Indeterminate(<family>,<ind>)' cannot be used with floats; use `Indeterminate(<float pseudofield>,<ind>)'");
end);

InstallOtherMethod( Indeterminate,"number", true, [ IsFloatPseudoField,IsPosInt ],0,
function( r,n )
  return LaurentPolynomialByCoefficients(r,[One(r)],1,n);
end);

InstallOtherMethod( Indeterminate,"number 1", true, [ IsFloatPseudoField ],0,
function( r )
  return LaurentPolynomialByCoefficients(r,[One(r)],1,1);
end);

InstallOtherMethod( Indeterminate,"number, avoid", true, [ IsFloatPseudoField,IsList ],0,
function( r,a )
  if not IsRationalFunction(a[1]) then
    TryNextMethod();
  fi;
  return LaurentPolynomialByCoefficients(r,[One(r)],1,
          GiveNumbersNIndeterminates(RationalFunctionsFamily(r),1,[],a)[1]);
end);

InstallOtherMethod( Indeterminate,"number, name", true, [ IsFloatPseudoField,IsString ],0,
function( r,n )
  if not IsString(n) then
    TryNextMethod();
  fi;
  return LaurentPolynomialByCoefficients(r,[One(r)],1,
          GiveNumbersNIndeterminates(RationalFunctionsFamily(r),1,[n],[])[1]);
end);

InstallOtherMethod( Indeterminate,"number, name, avoid",true,
  [ IsFloatPseudoField,IsString,IsList ],0,
function( r,n,a )
  if not IsString(n) then
    TryNextMethod();
  fi;
  return LaurentPolynomialByCoefficients(r,[One(r)],1,
          GiveNumbersNIndeterminates(RationalFunctionsFamily(r),1,[n],a)[1]);
end);

# we must avoid over/underflow here; hence the specific method
InstallOtherMethod(ReduceCoeffs, "for float vectors",
        [IsFloatCollection, IsInt, IsFloatCollection, IsInt],
        function (l1, n1, l2, n2)
    local l, q, i, x;
    if 0 = n2  then
        Error("<l2> must be non-zero");
    elif 0 = n1  then
        return n1;
    fi;
    while 0 < n2 and IsZero(l2[n2]) do n2 := n2 - 1; od;
    if 0 = n2 then
        Error("<l2> must be non-zero");
    fi;
    while 0 < n1 and IsZero(l1[n1]) do n1 := n1 - 1; od;
    while n1 >= n2  do
        q := l1[n1] / l2[n2];
        l := n1-n2;
        for i in [ n1-n2+1 .. n1 ] do
            x := l1[i] - q * l2[i-n1+n2];
            if i=n1 or l1[i] - x/2 = l1[i] then # epsilon-small value
                l1[i] := Zero(l1[i]);
            else
                l1[i] := x;
                l := i;
            fi;
        od;
        n1 := l;
    od;
    return n1;
end);

InstallMethod( Derivative, "for float laurent polynomial",
        [IsFloatRationalFunction and IsUnivariateRationalFunction and IsLaurentPolynomial],
        function(f)
    local  c, d, e, i, ind, fam;
    ind := IndeterminateNumberOfUnivariateRationalFunction( f );
    fam := FamilyObj(f);
    e := CoefficientsOfLaurentPolynomial( f );
    c := e[1];
    if Length( c ) = 0  then
        return f;
    fi;
    e := e[2];
    d := [  ];
    for i  in [ 1 .. Length(c) ]  do
        d[i] := (i + e - 1) * c[i];
    od;
    e := e-1 + RemoveOuterCoeffs(d, fam!.zeroCoefficient);
    return LaurentPolynomialByExtRepNC( fam, d, e, ind );
end );

#############################################################################
##
#M  \<, \+, ... for float and rat
##

# we say that all floateans are after all rationals, to sort them
BindGlobal("COMPARE_FLOAT_ANY", function(x,y)
    local z;
    if IsFloat(x) then z := y; else z := x; fi;
    Error("Comparison of float and ",z," is not supported. Please refer to the manual section on floats for details");
end);

InstallMethod( \<, "for rational and float", [ IsRat, IsFloat ], -1, COMPARE_FLOAT_ANY );
InstallMethod( \<, "for float and rational", [ IsFloat, IsRat ], -1, COMPARE_FLOAT_ANY );
InstallMethod( \<, "for floats", [ IsFloat, IsFloat ], -1,
        function(x,y) return x < MakeFloat(x,y); end);

InstallMethod( \=, "for rational and float", [ IsRat, IsFloat ], -1, COMPARE_FLOAT_ANY );
InstallMethod( \=, "for float and rational", [ IsFloat, IsRat ], -1, COMPARE_FLOAT_ANY );
InstallMethod( \=, "for floats", [ IsFloat, IsFloat ], -1,
        function(x,y) return x = MakeFloat(x,y); end);

InstallMethod( \+, "for rational and float", ReturnTrue, [ IsRat, IsFloat ], -1,
        function ( x, y ) return MakeFloat(y,x) + y; end );
InstallMethod( \+, "for float and rational", ReturnTrue, [ IsFloat, IsRat ], -1,
        function ( x, y ) return x + MakeFloat(x,y); end );
InstallMethod( \+, "for floats", ReturnTrue, [ IsFloat, IsFloat ], -1,
        function ( x, y ) return x + MakeFloat(x,y); end );

InstallMethod( \-, "for rational and float", ReturnTrue, [ IsRat, IsFloat ], -1,
        function ( x, y ) return MakeFloat(y,x) - y; end );
InstallMethod( \-, "for float and rational", ReturnTrue, [ IsFloat, IsRat ], -1,
        function ( x, y ) return x - MakeFloat(x,y); end );
InstallMethod( \-, "for floats", ReturnTrue, [ IsFloat, IsFloat ], -1,
        function ( x, y ) return x - MakeFloat(x,y); end );

InstallMethod( \*, "for rational and float", ReturnTrue, [ IsRat, IsFloat ], -1,
        function ( x, y ) return MakeFloat(y,x) * y; end );
InstallMethod( \*, "for float and rational", ReturnTrue, [ IsFloat, IsRat ], -1,
        function ( x, y ) return x * MakeFloat(x,y); end );
InstallMethod( \*, "for floats", ReturnTrue, [ IsFloat, IsFloat ], -1,
        function ( x, y ) return x * MakeFloat(x,y); end );

InstallMethod( \/, "for rational and float", ReturnTrue, [ IsRat, IsFloat ], -1,
        function ( x, y ) return MakeFloat(y,x) / y; end );
InstallMethod( \/, "for float and rational", ReturnTrue, [ IsFloat, IsRat ], -1,
        function ( x, y ) return x / MakeFloat(x,y); end );
InstallMethod( \/, "for floats", ReturnTrue, [ IsFloat, IsFloat ], -1,
        function ( x, y ) return x / MakeFloat(x,y); end );

InstallMethod( LQUO, "for rational and float", ReturnTrue, [ IsRat, IsFloat ], -1,
        function ( x, y ) return LQUO(MakeFloat(y,x),y); end );
InstallMethod( LQUO, "for float and rational", ReturnTrue, [ IsFloat, IsRat ], -1,
        function ( x, y ) return LQUO(x,MakeFloat(x,y)); end );
InstallMethod( LQUO, "for floats", ReturnTrue, [ IsFloat, IsFloat ], -1,
        function ( x, y ) return LQUO(x,MakeFloat(x,y)); end );

InstallOtherMethod( \/, "for empty list", [ IsEmpty, IsFloat ],
        function ( x, y ) return x; end );

InstallMethod( \^, "for rational and float", ReturnTrue, [ IsRat, IsFloat ], -1,
        function ( x, y ) return MakeFloat(y,x) ^ y; end );
InstallMethod( \^, "for float and rational", ReturnTrue, [ IsFloat, IsRat ], -1,
        function ( x, y )
    if IsInt(y) then TryNextMethod(); fi;
    return x ^ MakeFloat(x,y);
end );
InstallMethod( \^, "for floats", ReturnTrue, [ IsFloat, IsFloat ], -1,
        function ( x, y ) return x ^ MakeFloat(x,y); end );


InstallMethod( IsGeneratorsOfMagmaWithInverses,
    "for a collection of floats (return false)",
    [ IsFloatCollection ],
    SUM_FLAGS, # override everything else
    function( gens )
    Info( InfoWarning, 1,
          "no groups of floats allowed because of incompatible ^" );
    return false;
    end );
