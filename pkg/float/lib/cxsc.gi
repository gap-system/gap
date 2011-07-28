#############################################################################
##
#W  cxsc.gi                        GAP library              Laurent Bartholdi
##
#H  @(#)$Id: cxsc.gi,v 1.2 2010/02/22 19:25:24 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with floats
##
Revision.cxsc_gi :=
  "@(#)$Id: cxsc.gi,v 1.2 2010/02/22 19:25:24 gap Exp $";

################################################################
# domains
################################################################
SetLeftActingDomain(CXSC_RP_FIELD,CXSC_RP_FIELD);
SetCharacteristic(CXSC_RP_FIELD,0);
# SetBaseField(CXSC_RP_FIELD,Rationals); # no such method seems to exist
SetDimension(CXSC_RP_FIELD,infinity);
SetSize(CXSC_RP_FIELD,infinity);
SetIsWholeFamily(CXSC_RP_FIELD,true);
SetName(CXSC_RP_FIELD,"CXSC_RP_FIELD");
SetIsUFDFamily(CXSCRealFamily,true);

SetLeftActingDomain(CXSC_CP_FIELD,CXSC_CP_FIELD);
SetCharacteristic(CXSC_CP_FIELD,0);
# SetBaseField(CXSC_CP_FIELD,Rationals); # no such method seems to exist
SetDimension(CXSC_CP_FIELD,infinity);
SetSize(CXSC_CP_FIELD,infinity);
SetIsWholeFamily(CXSC_CP_FIELD,true);
SetName(CXSC_CP_FIELD,"CXSC_CP_FIELD");
SetIsUFDFamily(CXSCComplexFamily,true);

SetLeftActingDomain(CXSC_RI_FIELD,CXSC_RI_FIELD);
SetCharacteristic(CXSC_RI_FIELD,0);
# SetBaseField(CXSC_RI_FIELD,Rationals); # no such method seems to exist
SetDimension(CXSC_RI_FIELD,infinity);
SetSize(CXSC_RI_FIELD,infinity);
SetIsWholeFamily(CXSC_RI_FIELD,true);
SetName(CXSC_RI_FIELD,"CXSC_RI_FIELD");
SetIsUFDFamily(CXSCIntervalFamily,true);

SetLeftActingDomain(CXSC_CI_FIELD,CXSC_CI_FIELD);
SetCharacteristic(CXSC_CI_FIELD,0);
# SetBaseField(CXSC_CI_FIELD,Rationals); # no such method seems to exist
SetDimension(CXSC_CI_FIELD,infinity);
SetSize(CXSC_CI_FIELD,infinity);
SetIsWholeFamily(CXSC_CI_FIELD,true);
SetName(CXSC_CI_FIELD,"CXSC_CI_FIELD");
SetIsUFDFamily(CXSCBoxFamily,true);

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

InstallMethod(String, "cxsc:*", [IsCXSCFloat], x->STRING_CXSC(x,0,10));

InstallMethod(String, "cxsc:*,len", [IsCXSCFloat,IsInt],
        function(x,len)
    return STRING_CXSC(x,len,10);
end);

InstallOtherMethod(String, "cxsc:*,len,digits", [IsCXSCFloat,IsInt,IsInt],
        STRING_CXSC);

InstallMethod(PrecisionFloat, "cxsc", [IsCXSCFloat], x->52);

################################################################
# constants
################################################################
InstallValue(CXSC, rec(0 := CXSC_INT(0), 1 := CXSC_INT(1), 2 := CXSC_INT(2),
                            _1 := CXSC_INT(-1), New := CXSCFloat));
CXSC.0c := CP_CXSC_RP_RP(CXSC.0,CXSC.0);
CXSC.0i := RI_CXSC_RP_RP(CXSC.0,CXSC.0);
CXSC.0b := CI_CXSC_RI_RI(CXSC.0i,CXSC.0i);
CXSC.1c := CP_CXSC_RP_RP(CXSC.1,CXSC.0);
CXSC.1i := RI_CXSC_RP_RP(CXSC.1,CXSC.1);
CXSC.1b := CI_CXSC_RI_RI(CXSC.1i,CXSC.0i);
CXSC.infinity := CXSC_NEWCONSTANT(3);
CXSC.NaN := CXSC_NEWCONSTANT(5);
CXSC.Pi := CXSC_NEWCONSTANT(6);
CXSC.Pii := CXSC_NEWCONSTANT(100);
CXSC.2Pi := CXSC_NEWCONSTANT(7);
CXSC.2Pii := CXSC_NEWCONSTANT(101);
CXSC.2IPi := CP_CXSC_RP_RP(CXSC.0,CXSC_NEWCONSTANT(7));
CXSC.2IPib := CI_CXSC_RI_RI(CXSC.0i,CXSC_NEWCONSTANT(101));
CXSC.I := CP_CXSC_RP_RP(CXSC.0,CXSC.1);
CXSC.Ib := CI_CXSC_RI_RI(CXSC.0i,CXSC.1i);

SetZero(CXSCRealFamily,CXSC.0);
SetOne(CXSCRealFamily,CXSC.1);
SetZero(CXSCComplexFamily,CXSC.0c);
SetOne(CXSCComplexFamily,CXSC.1c);
SetZero(CXSCIntervalFamily,CXSC.0i);
SetOne(CXSCIntervalFamily,CXSC.1i);
SetZero(CXSCBoxFamily,CXSC.0b);
SetOne(CXSCBoxFamily,CXSC.1b);

SMALLINT@ := 2^27; SMALLREAL@ := CXSC_INT(SMALLINT@);

################################################################
# unary operations
################################################################
InstallMethod(ZERO,[IsCXSCReal],x->CXSC.0);
InstallMethod(ZERO,[IsCXSCComplex],x->CXSC.0c);
InstallMethod(ZERO,[IsCXSCInterval],x->CXSC.0i);
InstallMethod(ZERO,[IsCXSCBox],x->CXSC.0b);
InstallMethod(ZeroImmutable,[IsCXSCReal],x->CXSC.0);
InstallMethod(ZeroImmutable,[IsCXSCComplex],x->CXSC.0c);
InstallMethod(ZeroImmutable,[IsCXSCInterval],x->CXSC.0i);
InstallMethod(ZeroImmutable,[IsCXSCBox],x->CXSC.0b);
InstallMethod(IsZero,[IsCXSCReal],x->x=CXSC.0);
InstallMethod(IsZero,[IsCXSCComplex],x->x=CXSC.0c);
InstallMethod(IsZero,[IsCXSCInterval],x->CXSC.0 in x);
InstallMethod(IsZero,[IsCXSCBox],x->CXSC.0b in x);

InstallMethod(ONE,[IsCXSCReal],x->CXSC.1);
InstallMethod(ONE,[IsCXSCComplex],x->CXSC.1c);
InstallMethod(ONE,[IsCXSCInterval],x->CXSC.1i);
InstallMethod(ONE,[IsCXSCBox],x->CXSC.1b);
InstallMethod(OneImmutable,[IsCXSCReal],x->CXSC.1);
InstallMethod(OneImmutable,[IsCXSCComplex],x->CXSC.1c);
InstallMethod(OneImmutable,[IsCXSCInterval],x->CXSC.1i);
InstallMethod(OneImmutable,[IsCXSCBox],x->CXSC.1b);
InstallMethod(IsOne,[IsCXSCReal],x->x=CXSC.1);
InstallMethod(IsOne,[IsCXSCComplex],x->x=CXSC.1c);
InstallMethod(IsOne,[IsCXSCInterval],x->x=CXSC.1i);
InstallMethod(IsOne,[IsCXSCBox],x->x=CXSC.1b);

InstallMethod(Int, [IsCXSCReal], function(x)
    local i, w, n;
    w := INT_CXSC(x);
    if w=fail then
        i := 1;
        repeat
            n := INT_CXSC(x/i);
            i := 2*i;
        until n<>fail;
        i := i/2;
        w := 0;
        repeat
            w := w+n*i;
            x := x-n*i;
            i := i/2;
            n := INT_CXSC(x/i);
        until i=1;
    fi;
    return w;
end);
InstallMethod(Int, [IsCXSCInterval], x->Int(Sup(x)));

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
            VALUE_GLOBAL(Concatenation(__i[2],"_RP")));
    InstallOtherMethod(VALUE_GLOBAL(__i[1]), "cxsc:cp", [IsCXSCComplex],
            VALUE_GLOBAL(Concatenation(__i[2],"_CP")));
    InstallOtherMethod(VALUE_GLOBAL(__i[1]), "cxsc:ri", [IsCXSCInterval],
            VALUE_GLOBAL(Concatenation(__i[2],"_RI")));
    InstallOtherMethod(VALUE_GLOBAL(__i[1]), "cxsc:ci", [IsCXSCBox],
            VALUE_GLOBAL(Concatenation(__i[2],"_CI")));
od;
Unbind(__i);

InstallMethod(SignFloat, "cxsc:rp", [IsCXSCFloat], function(x)
    if x>CXSC.0 then
        return 1;
    elif x < CXSC.0 then
        return -1;
    else
        return 0;
    fi;
end);

InstallMethod(SignFloat, "cxsc:ri", [IsCXSCInterval], function(x)
    if Inf(x)>CXSC.0 then
        return 1;
    elif Sup(x) < CXSC.0 then
        return -1;
    else
        return 0;
    fi;
end);

InstallMethod(Inf, "cxsc:ri", [IsCXSCInterval], INF_CXSC_RI);
InstallMethod(Sup, "cxsc:ri", [IsCXSCInterval], SUP_CXSC_RI);
InstallMethod(Mid, "cxsc:ri", [IsCXSCInterval], MID_CXSC_RI);
InstallMethod(Diameter, "cxsc:ri", [IsCXSCInterval], DIAM_CXSC_RI);
InstallMethod(Inf, "cxsc:ci", [IsCXSCBox], INF_CXSC_CI);
InstallMethod(Sup, "cxsc:ci", [IsCXSCBox], SUP_CXSC_CI);
InstallMethod(Mid, "cxsc:ci", [IsCXSCBox], MID_CXSC_CI);
InstallMethod(Diameter, "cxsc:ci", [IsCXSCBox], DIAM_CXSC_CI);

################################################################
# interval stuff
################################################################
InstallMethod(IsDisjoint, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval],
        DISJOINT_CXSC_RI_RI);
InstallMethod(Overlaps, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval],
        function(a,b) return not DISJOINT_CXSC_RI_RI(a,b); end);
InstallMethod(IN, "cxsc:rp,ri", [IsCXSCReal,IsCXSCInterval], SUM_FLAGS,
        IN_CXSC_RP_RI);
InstallMethod(IN, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval], SUM_FLAGS,
        IN_CXSC_RI_RI);
InstallMethod(IN, "cxsc:rp,ci", [IsCXSCReal,IsCXSCBox], SUM_FLAGS,
        IN_CXSC_RP_CI);
InstallMethod(IN, "cxsc:cp,ci", [IsCXSCComplex,IsCXSCBox], SUM_FLAGS,
        IN_CXSC_CP_CI);
InstallMethod(IN, "cxsc:ri,ci", [IsCXSCInterval,IsCXSCBox], SUM_FLAGS,
        IN_CXSC_RI_CI);
InstallMethod(IN, "cxsc:ci,ci", [IsCXSCBox,IsCXSCBox], SUM_FLAGS,
        IN_CXSC_CI_CI);
InstallMethod(IsDisjoint, "cxsc:ci,ci", [IsCXSCBox,IsCXSCBox],
        DISJOINT_CXSC_CI_CI);
InstallMethod(Overlaps, "cxsc:ci,ci", [IsCXSCBox,IsCXSCBox],
        function(a,b) return not DISJOINT_CXSC_CI_CI(a,b); end);
InstallMethod(Union2, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval],
        OR_CXSC_RI_RI);
InstallMethod(Union2, "cxsc:ri,ci", [IsCXSCInterval,IsCXSCBox],
        OR_CXSC_RI_CI);
InstallMethod(Union2, "cxsc:ci,ri", [IsCXSCBox,IsCXSCInterval],
        OR_CXSC_CI_RI);
InstallMethod(Union2, "cxsc:ci,ci", [IsCXSCBox,IsCXSCBox],
        OR_CXSC_CI_CI);
InstallMethod(Intersection2, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval],
        AND_CXSC_RI_RI);
InstallMethod(Intersection2, "cxsc:ri,ci", [IsCXSCInterval,IsCXSCBox],
        AND_CXSC_RI_CI);
InstallMethod(Intersection2, "cxsc:ci,ri", [IsCXSCBox,IsCXSCInterval],
        AND_CXSC_CI_RI);
InstallMethod(Intersection2, "cxsc:ci,ci", [IsCXSCBox,IsCXSCBox],
        AND_CXSC_CI_CI);
################################################################
# complex stuff
################################################################
InstallMethod(RealPart, "cxsc:cp", [IsCXSCComplex], REAL_CXSC_CP);
InstallMethod(ImaginaryPart, "cxsc:cp", [IsCXSCComplex], IMAG_CXSC_CP);
InstallMethod(Norm, "cxsc:cp", [IsCXSCComplex], NORM_CXSC_CP);
InstallMethod(ComplexConjugate, "cxsc:cp", [IsCXSCComplex], CONJ_CXSC_CP);
InstallMethod(RealPart, "cxsc:ci", [IsCXSCBox], REAL_CXSC_CI);
InstallMethod(ImaginaryPart, "cxsc:ci", [IsCXSCBox], IMAG_CXSC_CI);
InstallMethod(Norm, "cxsc:ci", [IsCXSCBox], NORM_CXSC_CI);
InstallMethod(ComplexConjugate, "cxsc:ci", [IsCXSCBox], CONJ_CXSC_CI);
        
################################################################
# binary operations
################################################################
for __i in ["SUM","DIFF","QUO","PROD","POW","EQ","LT"] do
    for __j in Tuples([["RP",IsCXSCReal],["CP",IsCXSCComplex],["RI",IsCXSCInterval],["CI",IsCXSCBox]],2) do
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
    return CXSC_POW@(f,r,POWER_CXSC_RP,ROOT_CXSC_RP);
end);
InstallMethod(POW, "cxsc:, rat", [IsCXSCComplex, IsRat],
        function(f,r)
    return CXSC_POW@(f,r,POWER_CXSC_CP,ROOT_CXSC_CP);
end);
InstallMethod(POW, "cxsc:, rat", [IsCXSCInterval, IsRat],
        function(f,r)
    return CXSC_POW@(f,r,POWER_CXSC_RI,ROOT_CXSC_RI);
end);
InstallMethod(POW, "cxsc:, rat", [IsCXSCBox, IsRat],
        function(f,r)
    return CXSC_POW@(f,r,POWER_CXSC_CI,ROOT_CXSC_CI);
end);

InstallMethod(Atan2, "cxsc:rp,rp", [IsCXSCReal,IsCXSCReal], ATAN2_CXSC_RP_RP);
InstallMethod(Atan2, "cxsc:cp", [IsCXSCComplex], ATAN2_CXSC_CP);
InstallMethod(Atan2, "cxsc:ci", [IsCXSCBox], ATAN2_CXSC_CI);

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

InstallMethod(BoxRootsOfUnivariatePolynomial, "list", [IsList],
        function(l)
    return ROOTPOLY_CXSC(l,true);
end);

InstallMethod(BoxRootsOfUnivariatePolynomial, "polynomial", [IsPolynomial],
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
        RP_CXSC_STRING);

InstallMethod(CXSCReal, "cxsc:rp", [IsCXSCReal], x->x);

################################################################
# complex constructors
################################################################
InstallMethod(CXSCComplex, "cxsc:*", [IsScalar],
        x->CP_CXSC_RP_RP(CXSCReal(x),CXSC.0));

InstallMethod(CXSCComplex, "cxsc:cp", [IsCXSCComplex], x->x);

InstallMethod(CXSCComplex, "cxsc:rp", [IsCXSCReal],
        CP_CXSC_RP);

InstallMethod(CXSCComplex, "for two reals", [IsCXSCReal,IsCXSCReal],
        CP_CXSC_RP_RP);

InstallMethod(CXSCComplex, "for two scalars", [IsScalar,IsScalar],
        function(x,y)
    return CP_CXSC_RP_RP(CXSCReal(x),CXSCReal(y));
end);

InstallMethod(CXSCComplex, "for strings", [IsString],
        CP_CXSC_STRING);

################################################################
# interval constructors
################################################################
InstallMethod(CXSCInterval, "cxsc:rp,rp", [IsCXSCReal,IsCXSCReal],
        RI_CXSC_RP_RP);

InstallMethod(CXSCInterval, "cxsc:rp", [IsCXSCReal],
        RI_CXSC_RP);

InstallMethod(CXSCInterval, "cxsc:*,*", [IsScalar,IsScalar],
        function(x,y)
    return RI_CXSC_RP_RP(CXSCReal(x),CXSCReal(y));
end);

InstallMethod(CXSCInterval, "cxsc:ri", [IsCXSCInterval],
        x->x);

InstallMethod(CXSCInterval, "for integers", [IsInt],
        function(int)
    local f, m;
    f := CXSC.0i;
    m := CXSC.1i;
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
        RI_CXSC_STRING);

################################################################
# complex interval constructors
################################################################
InstallMethod(CXSCBox, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval],
        CI_CXSC_RI_RI);

InstallMethod(CXSCBox, "csxc:ci", [IsCXSCBox], x->x);

InstallMethod(CXSCBox, "cxsc:*,*", [IsScalar,IsScalar],
        function(x,y)
    return CI_CXSC_RI_RI(CXSCInterval(x),CXSCInterval(y));
end);

InstallMethod(CXSCBox, "cxsc:*", [IsCXSCFloat],
        function(x)
    return CI_CXSC_RI_RI(CXSCInterval(x),CXSC.0i);
end);

InstallMethod(CXSCBox, "cxsc:cp", [IsCXSCComplex],
        CI_CXSC_CP);

InstallMethod(CXSCBox, "cxsc:cp", [IsCXSCComplex, IsCXSCComplex],
        CI_CXSC_CP_CP);

InstallMethod(CXSCBox, "for strings", [IsString],
        CI_CXSC_STRING);

################################################################
# generic constructors
################################################################
InstallMethod(CXSCFloat, "x", [IsScalar], CXSCReal);
InstallMethod(CXSCFloat, "l", [IsList], l->CXSCInterval(l[1],l[2]));
InstallMethod(CXSCFloat, "x,x", [IsScalar,IsScalar], CXSCComplex);
InstallMethod(CXSCFloat, "l,l", [IsList,IsList], function(x,y)
    return CXSCBox(CXSCInterval(x[1],x[2]),CXSCInterval(y[1],y[2]));
end);

################################################################
# convert to rational
################################################################
InstallMethod(Rat, "cxsc:ri", [IsCXSCInterval],
        function (x)
    local M, a;

    M := [[SignFloat(x),0],[0,1]];
    repeat
        a := Int(x);
        M := M * [[a,1],[1,0]];
        x := x - a;
        if IsZero(x) then break; fi;
        x := Inverse(x);
    until Diameter(x) >= CXSC.1;
    return M[1][1]/M[2][1];
end);

#############################################################################
##
#E
