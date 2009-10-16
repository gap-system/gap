#############################################################################
##
#W  cxsc.gi                        GAP library              Laurent Bartholdi
##
#H  @(#)$Id: cxsc.gi,v 1.1 2008/06/14 15:45:40 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with floats
##
Revision.cxsc_gi :=
  "@(#)$Id: cxsc.gi,v 1.1 2008/06/14 15:45:40 gap Exp $";

################################################################
# domains
################################################################
SetLeftActingDomain(CXSC_REAL_FIELD,CXSC_REAL_FIELD);
SetCharacteristic(CXSC_REAL_FIELD,0);
# SetBaseField(CXSC_REAL_FIELD,Rationals); # no such method seems to exist
SetDimension(CXSC_REAL_FIELD,infinity);
SetSize(CXSC_REAL_FIELD,infinity);
SetIsWholeFamily(CXSC_REAL_FIELD,true);
SetName(CXSC_REAL_FIELD,"CXSC_REAL_FIELD");
SetIsUFDFamily(CXSCRealFamily,true);

SetLeftActingDomain(CXSC_COMPLEX_FIELD,CXSC_COMPLEX_FIELD);
SetCharacteristic(CXSC_COMPLEX_FIELD,0);
# SetBaseField(CXSC_COMPLEX_FIELD,Rationals); # no such method seems to exist
SetDimension(CXSC_COMPLEX_FIELD,infinity);
SetSize(CXSC_COMPLEX_FIELD,infinity);
SetIsWholeFamily(CXSC_COMPLEX_FIELD,true);
SetName(CXSC_COMPLEX_FIELD,"CXSC_COMPLEX_FIELD");
SetIsUFDFamily(CXSCComplexFamily,true);

SetLeftActingDomain(CXSC_INTERVAL_FIELD,CXSC_INTERVAL_FIELD);
SetCharacteristic(CXSC_INTERVAL_FIELD,0);
# SetBaseField(CXSC_INTERVAL_FIELD,Rationals); # no such method seems to exist
SetDimension(CXSC_INTERVAL_FIELD,infinity);
SetSize(CXSC_INTERVAL_FIELD,infinity);
SetIsWholeFamily(CXSC_INTERVAL_FIELD,true);
SetName(CXSC_INTERVAL_FIELD,"CXSC_INTERVAL_FIELD");
SetIsUFDFamily(CXSCIntervalFamily,true);

SetLeftActingDomain(CXSC_CINTERVAL_FIELD,CXSC_CINTERVAL_FIELD);
SetCharacteristic(CXSC_CINTERVAL_FIELD,0);
# SetBaseField(CXSC_CINTERVAL_FIELD,Rationals); # no such method seems to exist
SetDimension(CXSC_CINTERVAL_FIELD,infinity);
SetSize(CXSC_CINTERVAL_FIELD,infinity);
SetIsWholeFamily(CXSC_CINTERVAL_FIELD,true);
SetName(CXSC_CINTERVAL_FIELD,"CXSC_CINTERVAL_FIELD");
SetIsUFDFamily(CXSCCIntervalFamily,true);

################################################################
# domains
################################################################
SetLeftActingDomain(CXSC_REAL_FIELD,CXSC_REAL_FIELD);
SetCharacteristic(CXSC_REAL_FIELD,0);
# SetBaseField(CXSC_REAL_FIELD,Rationals); # no such method seems to exist
SetDimension(CXSC_REAL_FIELD,infinity);
SetSize(CXSC_REAL_FIELD,infinity);
SetIsWholeFamily(CXSC_REAL_FIELD,true);
SetName(CXSC_REAL_FIELD,"CXSC_REAL_FIELD");
SetIsUFDFamily(CXSCRealFamily,true);

SetLeftActingDomain(CXSC_COMPLEX_FIELD,CXSC_COMPLEX_FIELD);
SetCharacteristic(CXSC_COMPLEX_FIELD,0);
# SetBaseField(CXSC_COMPLEX_FIELD,Rationals); # no such method seems to exist
SetDimension(CXSC_COMPLEX_FIELD,infinity);
SetSize(CXSC_COMPLEX_FIELD,infinity);
SetIsWholeFamily(CXSC_COMPLEX_FIELD,true);
SetName(CXSC_COMPLEX_FIELD,"CXSC_COMPLEX_FIELD");
SetIsUFDFamily(CXSCComplexFamily,true);

SetLeftActingDomain(CXSC_INTERVAL_FIELD,CXSC_INTERVAL_FIELD);
SetCharacteristic(CXSC_INTERVAL_FIELD,0);
# SetBaseField(CXSC_INTERVAL_FIELD,Rationals); # no such method seems to exist
SetDimension(CXSC_INTERVAL_FIELD,infinity);
SetSize(CXSC_INTERVAL_FIELD,infinity);
SetIsWholeFamily(CXSC_INTERVAL_FIELD,true);
SetName(CXSC_INTERVAL_FIELD,"CXSC_INTERVAL_FIELD");
SetIsUFDFamily(CXSCIntervalFamily,true);

SetLeftActingDomain(CXSC_CINTERVAL_FIELD,CXSC_CINTERVAL_FIELD);
SetCharacteristic(CXSC_CINTERVAL_FIELD,0);
# SetBaseField(CXSC_CINTERVAL_FIELD,Rationals); # no such method seems to exist
SetDimension(CXSC_CINTERVAL_FIELD,infinity);
SetSize(CXSC_CINTERVAL_FIELD,infinity);
SetIsWholeFamily(CXSC_CINTERVAL_FIELD,true);
SetName(CXSC_CINTERVAL_FIELD,"CXSC_CINTERVAL_FIELD");
SetIsUFDFamily(CXSCCIntervalFamily,true);

################################################################
# viewers
################################################################
InstallMethod(ViewObj, "cxsc:", [IsCXSCFloat],
        function(obj)
    if IsInt(ValueOption("FloatViewLength")) then
        Print(STRING_CXSC(obj,0,ValueOption("FloatViewLength")));
    else
        Print(STRING_CXSC(obj,0,10));
    fi;
end);

InstallMethod(PrintObj, "cxsc:", [IsCXSCFloat],
        function(obj)
    Print(String(obj));
end);

InstallMethod(Display, "cxsc:", [IsCXSCFloat],
        function(obj)
    Display(String(obj));
end);

InstallMethod(String, "cxsc:", [IsCXSCFloat], x->STRING_CXSC(x,0,10));

InstallMethod(String, "cxsc:,len", [IsCXSCFloat,IsInt],
        function(x,len)
    return STRING_CXSC(x,len,10);
end);

InstallOtherMethod(String, "cxsc:,len,digits", [IsCXSCFloat,IsInt,IsInt],
        STRING_CXSC);

InstallMethod(PrecisionFloat, "cxsc", [IsCXSCFloat], x->52);

################################################################
# constants
################################################################
InstallValue(CXSC, rec(0 := CXSC_INT(0), 1 := CXSC_INT(1), 2 := CXSC_INT(2),
                            _1 := CXSC_INT(-1), New := CXSCFloat));
CXSC.0c := CXSC_C_RR(CXSC.0,CXSC.0);
CXSC.0i := CXSC_I_RR(CXSC.0,CXSC.0);
CXSC.0d := CXSC_D_II(CXSC.0i,CXSC.0i);
CXSC.1c := CXSC_C_RR(CXSC.1,CXSC.0);
CXSC.1i := CXSC_I_RR(CXSC.1,CXSC.1);
CXSC.1d := CXSC_D_II(CXSC.1i,CXSC.0i);
CXSC.infinity := CXSC_NEWCONSTANT(3);
CXSC.NaN := CXSC_NEWCONSTANT(5);
CXSC.Pi := CXSC_NEWCONSTANT(6);
CXSC.2Pi := CXSC_NEWCONSTANT(7);
CXSC.2IPi := CXSC_C_RR(CXSC.0,CXSC_NEWCONSTANT(7));

SetZero(CXSCRealFamily,CXSC.0);
SetOne(CXSCRealFamily,CXSC.1);
SetZero(CXSCComplexFamily,CXSC.0c);
SetOne(CXSCComplexFamily,CXSC.1c);
SetZero(CXSCIntervalFamily,CXSC.0i);
SetOne(CXSCIntervalFamily,CXSC.1i);
SetZero(CXSCCIntervalFamily,CXSC.0d);
SetOne(CXSCCIntervalFamily,CXSC.1d);

SMALLINT@ := 2^27; SMALLREAL@ := CXSC_INT(SMALLINT@);

################################################################
# unary operations
################################################################
InstallMethod(ZERO,[IsCXSCReal],x->CXSC.0);
InstallMethod(ZERO,[IsCXSCComplex],x->CXSC.0c);
InstallMethod(ZERO,[IsCXSCInterval],x->CXSC.0i);
InstallMethod(ZERO,[IsCXSCCInterval],x->CXSC.0d);
InstallMethod(ZeroImmutable,[IsCXSCReal],x->CXSC.0);
InstallMethod(ZeroImmutable,[IsCXSCComplex],x->CXSC.0c);
InstallMethod(ZeroImmutable,[IsCXSCInterval],x->CXSC.0i);
InstallMethod(ZeroImmutable,[IsCXSCCInterval],x->CXSC.0d);
InstallMethod(IsZero,[IsCXSCReal],x->x=CXSC.0);
InstallMethod(IsZero,[IsCXSCComplex],x->x=CXSC.0c);
InstallMethod(IsZero,[IsCXSCInterval],x->x=CXSC.0i);
InstallMethod(IsZero,[IsCXSCCInterval],x->x=CXSC.0d);

InstallMethod(ONE,[IsCXSCReal],x->CXSC.1);
InstallMethod(ONE,[IsCXSCComplex],x->CXSC.1c);
InstallMethod(ONE,[IsCXSCInterval],x->CXSC.1i);
InstallMethod(ONE,[IsCXSCCInterval],x->CXSC.1d);
InstallMethod(OneImmutable,[IsCXSCReal],x->CXSC.1);
InstallMethod(OneImmutable,[IsCXSCComplex],x->CXSC.1c);
InstallMethod(OneImmutable,[IsCXSCInterval],x->CXSC.1i);
InstallMethod(OneImmutable,[IsCXSCCInterval],x->CXSC.1d);
InstallMethod(IsOne,[IsCXSCReal],x->x=CXSC.1);
InstallMethod(IsOne,[IsCXSCComplex],x->x=CXSC.1c);
InstallMethod(IsOne,[IsCXSCInterval],x->x=CXSC.1i);
InstallMethod(IsOne,[IsCXSCCInterval],x->x=CXSC.1d);

InstallMethod(Int, [IsCXSCReal], INT_CXSC);

for __i in [["AINV","AINV_CXSC"],
        ["AINV_MUT","AINV_CXSC"],
        ["INV","INV_CXSC"],
        ["INV_MUT","INV_CXSC"],
        ["AbsoluteValue","ABS_CXSC"],
        ["Sqrt","SQRT_CXSC"],
        ["Cos","COS_CXSC"],
        ["Sin","SIN_CXSC"],
        ["Tan","TAN_CXSC"],
        ["Cot","COT_CXSC"],
        ["Asin","ASIN_CXSC"],
        ["Acos","ACOS_CXSC"],
        ["Atan","ATAN_CXSC"],
        ["Cosh","COSH_CXSC"],
        ["Sinh","SINH_CXSC"],
        ["Tanh","TANH_CXSC"],
        ["Coth","COTH_CXSC"],
        ["Asinh","ASINH_CXSC"],
        ["Acosh","ACOSH_CXSC"],
        ["Atanh","ATANH_CXSC"],
        ["Log","LOG_CXSC"],
        ["Exp","EXP_CXSC"],
        ["Square","SQR_CXSC"]] do
    InstallOtherMethod(VALUE_GLOBAL(__i[1]), "cxsc:rp", [IsCXSCReal],
            VALUE_GLOBAL(Concatenation(__i[2],"_R")));
    InstallOtherMethod(VALUE_GLOBAL(__i[1]), "cxsc:cp", [IsCXSCComplex],
            VALUE_GLOBAL(Concatenation(__i[2],"_C")));
    InstallOtherMethod(VALUE_GLOBAL(__i[1]), "cxsc:ri", [IsCXSCInterval],
            VALUE_GLOBAL(Concatenation(__i[2],"_I")));
    InstallOtherMethod(VALUE_GLOBAL(__i[1]), "cxsc:ci", [IsCXSCCInterval],
            VALUE_GLOBAL(Concatenation(__i[2],"_D")));
od;
Unbind(__i);

InstallMethod(SignFloat, "cxsc:", [IsCXSCFloat], function(x)
    if x>CXSC.0 then
        return 1;
    elif x < CXSC.0 then
        return -1;
    else
        return 0;
    fi;
end);

InstallMethod(Inf, "cxsc:ri", [IsCXSCInterval], INF_CXSC);
InstallMethod(Sup, "cxsc:ri", [IsCXSCInterval], SUP_CXSC);
InstallMethod(Mid, "cxsc:ri", [IsCXSCInterval], MID_CXSC);
InstallMethod(Inf, "cxsc:ci", [IsCXSCCInterval], INF_CXSC);
InstallMethod(Sup, "cxsc:ci", [IsCXSCCInterval], SUP_CXSC);
InstallMethod(Mid, "cxsc:ci", [IsCXSCCInterval], MID_CXSC);

################################################################
# interval stuff
################################################################
InstallMethod(IsDisjoint, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval],
        DISJOINT_CXSC_II);
InstallMethod(Overlaps, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval],
        function(a,b) return not DISJOINT_CXSC_II(a,b); end);
InstallMethod(IN, "cxsc:rp,ri", [IsCXSCReal,IsCXSCInterval],
        IN_CXSC_R_I);
InstallMethod(IN, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval],
        IN_CXSC_I_I);
InstallMethod(IN, "cxsc:ci,ci", [IsCXSCCInterval,IsCXSCCInterval],
        IN_CXSC_D_D);
InstallMethod(IsDisjoint, "cxsc:ci,ci", [IsCXSCCInterval,IsCXSCCInterval],
        DISJOINT_CXSC_DD);
InstallMethod(Overlaps, "cxsc:ci,ci", [IsCXSCCInterval,IsCXSCCInterval],
        function(a,b) return not DISJOINT_CXSC_DD(a,b); end);
InstallMethod(Union2, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval],
        OR_CXSC_I_I);
InstallMethod(Union2, "cxsc:ri,ci", [IsCXSCInterval,IsCXSCCInterval],
        OR_CXSC_I_D);
InstallMethod(Union2, "cxsc:ci,ri", [IsCXSCCInterval,IsCXSCInterval],
        OR_CXSC_D_I);
InstallMethod(Union2, "cxsc:ci,ci", [IsCXSCCInterval,IsCXSCCInterval],
        OR_CXSC_D_D);
InstallMethod(Intersection2, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval],
        AND_CXSC_I_I);
InstallMethod(Intersection2, "cxsc:ri,ci", [IsCXSCInterval,IsCXSCCInterval],
        AND_CXSC_I_D);
InstallMethod(Intersection2, "cxsc:ci,ri", [IsCXSCCInterval,IsCXSCInterval],
        AND_CXSC_D_I);
InstallMethod(Intersection2, "cxsc:ci,ci", [IsCXSCCInterval,IsCXSCCInterval],
        AND_CXSC_D_D);
################################################################
# complex stuff
################################################################
InstallMethod(RealPart, "cxsc:cp", [IsCXSCComplex], REAL_CXSC);
InstallMethod(ImaginaryPart, "cxsc:cp", [IsCXSCComplex], IMAG_CXSC);
InstallMethod(RealPart, "cxsc:ci", [IsCXSCCInterval], REAL_CXSC);
InstallMethod(ImaginaryPart, "cxsc:ci", [IsCXSCCInterval], IMAG_CXSC);
InstallMethod(Norm, "cxsc:cp", [IsCXSCComplex], NORM_CXSC);
InstallMethod(Norm, "cxsc:ci", [IsCXSCCInterval], NORM_CXSC);
InstallMethod(ComplexConjugate, "cxsc:cp", [IsCXSCComplex], CONJ_CXSC);
InstallMethod(ComplexConjugate, "cxsc:ci", [IsCXSCCInterval], CONJ_CXSC);
        
################################################################
# binary operations
################################################################
for __i in ["SUM","DIFF","QUO","PROD","POW","EQ","LT"] do
    for __j in Tuples([["R",IsCXSCReal],["C",IsCXSCComplex],["I",IsCXSCInterval],["D",IsCXSCCInterval]],2) do
        InstallMethod(VALUE_GLOBAL(__i), "cxsc:",
                [__j[1][2],__j[2][2]], VALUE_GLOBAL(Concatenation(__i,"_CXSC_",__j[1][1],"_",__j[2][1])));
    od;
    CallFuncList(function(oper)
        InstallOtherMethod(oper,"float,any",[IsCXSCFloat,IsScalar],
                function(x,y)
            return oper(x,CXSCReal(y));
        end);
        InstallOtherMethod(oper,"float,any",[IsScalar,IsCXSCFloat],
                function(x,y)
            return oper(CXSCReal(x),y);
        end);
    end,[VALUE_GLOBAL(__i)]);
od;
Unbind(__i); Unbind(__j);

CXSC_POW@ := function(f,r,POWER,ROOT)
    local d, n;
    d := DenominatorRat(r);
    n := NumeratorRat(r);
    if AbsoluteValue(n)<2^28 then
        f := POWER(f,n);
    else
        TryNextMethod();
    fi;
    if d<2^28 then
        f := ROOT(f,d);
    else
        TryNextMethod();
    fi;
    return f;
end;

InstallMethod(POW, "cxsc:, rat", [IsCXSCReal, IsRat],
        function(f,r)
    return CXSC_POW@(f,r,POWER_CXSC_R,ROOT_CXSC_R);
end);
InstallMethod(POW, "cxsc:, rat", [IsCXSCComplex, IsRat],
        function(f,r)
    return CXSC_POW@(f,r,POWER_CXSC_C,ROOT_CXSC_C);
end);
InstallMethod(POW, "cxsc:, rat", [IsCXSCInterval, IsRat],
        function(f,r)
    return CXSC_POW@(f,r,POWER_CXSC_I,ROOT_CXSC_I);
end);
InstallMethod(POW, "cxsc:, rat", [IsCXSCCInterval, IsRat],
        function(f,r)
    return CXSC_POW@(f,r,POWER_CXSC_D,ROOT_CXSC_D);
end);

InstallMethod(Atan2, "cxsc:rp,rp", [IsCXSCReal,IsCXSCReal], ATAN2_CXSC);

################################################################
# roots
################################################################
InstallMethod(ComplexRootsOfUnivariatePolynomial, "list", [IsList],
        function(l)
    return ROOTPOLY_CXSC(l,false);
end);

InstallMethod(ComplexRootsOfUnivariatePolynomial, "polynomial", [IsPolynomial],
        function(p)
    return ROOTPOLY_CXSC(CoefficientsOfUnivariatePolynomial(p),false);
end);

InstallMethod(CIntervalRootsOfUnivariatePolynomial, "list", [IsList],
        function(l)
    return ROOTPOLY_CXSC(l,true);
end);

InstallMethod(CIntervalRootsOfUnivariatePolynomial, "polynomial", [IsPolynomial],
        function(p)
    return ROOTPOLY_CXSC(CoefficientsOfUnivariatePolynomial(p),true);
end);

################################################################
# real constructors
################################################################
InstallMethod(CXSCReal, "for integers", [IsInt],
        function(int)
    local f, m;
    f := CXSC.0;
    m := CXSC.1;
    while int <> 0 do
        f := f + m*CXSC_INT(RemInt(int,SMALLINT@));
        int := QuoInt(int,SMALLINT@);
        m := m*SMALLREAL@;
    od;
    return f;
end);
InstallMethod(CXSCReal, "for rationals", [IsRat],
        function(rat)
    return CXSCReal(NumeratorRat(rat))/CXSCReal(DenominatorRat(rat));
end);
InstallMethod(CXSCReal, "for strings", [IsString],
        function(str)
    return CXSC_R_STRING(str);
end);

################################################################
# complex constructors
################################################################
InstallMethod(CXSCComplex, "for rationals", [IsScalar],
        x->CXSC_C_RR(CXSCReal(x),CXSC.0));
InstallMethod(CXSCComplex, "for complex", [IsCXSCComplex], x->x);
InstallMethod(CXSCComplex, "for real", [IsCXSCReal], x->CXSC_C_RR(x,CXSC.0));

InstallMethod(CXSCComplex, "for two reals", [IsCXSCReal,IsCXSCReal], CXSC_C_RR);

InstallMethod(CXSCComplex, "for two scalars", [IsScalar,IsScalar],
        function(x,y)
    return CXSC_C_RR(CXSCReal(x),CXSCReal(y));
end);

InstallMethod(CXSCComplex, "for strings", [IsString],
        function(str)
    return CXSC_C_STRING(str);
end);

################################################################
# interval constructors
################################################################
InstallMethod(CXSCInterval, "cxsc:rp,rp", [IsCXSCReal,IsCXSCReal], CXSC_I_RR);

InstallMethod(CXSCInterval, "cxsc:rp,rp", [IsScalar,IsScalar],
        function(x,y)
    return CXSC_I_RR(CXSCReal(x),CXSCReal(y));
end);

InstallMethod(CXSCInterval, "cxsc:rp", [IsCXSCReal],
        function(x)
    return CXSC_I_RR(x,x);
end);

InstallMethod(CXSCInterval, "cxsc:ri", [IsCXSCInterval],
        x->x);

InstallMethod(CXSCInterval, "for integers", [IsInt],
        function(int)
    local f, m;
    f := CXSCInterval(CXSC.0,CXSC.0);
    m := CXSCInterval(CXSC.1,CXSC.1);
    while int <> 0 do
        f := f + m*CXSC_INT(RemInt(int,SMALLINT@));
        int := QuoInt(int,SMALLINT@);
        m := m*SMALLREAL@;
    od;
    return f;
end);
InstallMethod(CXSCInterval, "for rationals", [IsRat],
        function(rat)
    return CXSCInterval(NumeratorRat(rat))/CXSCInterval(DenominatorRat(rat));
end);
InstallMethod(CXSCInterval, "for strings", [IsString],
        function(str)
    return CXSC_I_STRING(str);
end);

################################################################
# complex interval constructors
################################################################
InstallMethod(CXSCCInterval, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval], CXSC_D_II);

InstallMethod(CXSCCInterval, "cxsc:,", [IsScalar,IsScalar],
        function(x,y)
    return CXSC_D_II(CXSCInterval(x),CXSCInterval(y));
end);

InstallMethod(CXSCCInterval, "cxsc:", [IsCXSCFloat],
        function(x)
    return CXSC_D_II(CXSCInterval(x),CXSC.0i);
end);

InstallMethod(CXSCCInterval, "cxsc:cp", [IsCXSCComplex],
        function(x)
    return CXSC_D_II(CXSCInterval(RealPart(x)),CXSCInterval(ImaginaryPart(x)));
end);

InstallMethod(CXSCInterval, "for strings", [IsString],
        function(str)
    return CXSC_D_STRING(str);
end);

################################################################
# generic constructors
################################################################
InstallMethod(CXSCFloat, "x", [IsScalar], CXSCReal);
InstallMethod(CXSCFloat, "l", [IsList], l->CXSCInterval(l[1],l[2]));
InstallMethod(CXSCFloat, "x,x", [IsScalar,IsScalar], CXSCComplex);
InstallMethod(CXSCFloat, "l,l", [IsList,IsList], function(x,y)
    return CXSCCInterval(l->CXSCCInterval(CXSCInterval(x[1],x[2]),CXSCInterval(y[1],y[2])));
end);

################################################################
# convert to rational
################################################################
InstallMethod(Rat, "cxsc:", [IsCXSCInterval],
        function (x)
    local M, rem, a, bound, prec;

    M := [[SignFloat(x),0],[0,1]];
    rem := x;
    repeat
        a := Int(Sup(rem));
        M := M * [[a,1],[1,0]];
        if rem = a then break; fi;
        rem := CXSC.1/(rem - a);
    until Sup(rem) - Inf(rem) >= CXSC.1;
    return M[1][1]/M[2][1];
end);

#############################################################################
##
#E
