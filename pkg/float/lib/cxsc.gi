#############################################################################
##
#W  cxsc.gi                        GAP library              Laurent Bartholdi
##
#H  @(#)$Id: cxsc.gi,v 1.13 2011/12/08 21:30:36 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with floats
##
Revision.float.cxsc_gi :=
  "@(#)$Id: cxsc.gi,v 1.13 2011/12/08 21:30:36 gap Exp $";

################################################################
# viewers
################################################################
InstallMethod(ViewString, "cxsc:*", [IsCXSCFloat],
        function(obj)
    return STRING_CXSC(obj,0,FLOAT.VIEW_DIG);
end);

InstallOtherMethod(String, "cxsc:*,len,digits", [IsCXSCFloat,IsInt,IsInt],
        STRING_CXSC);

InstallMethod(String, "cxsc:*, int", [IsCXSCFloat, IsInt],
        function(obj,len)
    return STRING_CXSC(obj,0,len);
end);
        
InstallMethod(String, "cxsc:*", [IsCXSCFloat],
        obj->STRING_CXSC(obj,0,FLOAT.DECIMAL_DIG));

BindGlobal("CXSC_STRING", function(s)
    if 'i' in s or 'I' in s then
        return CP_CXSC_STRING(s);
    else
        return RP_CXSC_STRING(s);
    fi;
end);

InstallMethod(PrecisionFloat, "cxsc:*", [IsCXSCFloat], x->CXSC.constants.MANT_DIG);

################################################################
# constants
################################################################
InstallValue(CXSC, rec(creator := CXSC_STRING,
    objbyextrep := fail,
    eager := 'X',
    filter := IsCXSCFloat,
    constants := rec(INFINITY := CXSC_NEWCONSTANT(3),
        NINFINITY := AINV_CXSC_RP(CXSC_NEWCONSTANT(3)),
        MAX := CXSC_NEWCONSTANT(2),
        NAN := CXSC_NEWCONSTANT(5),
        DIG := 15,
        VIEW_DIG := 6,
        MANT_DIG := 53,
        MAX_10_EXP := 308,
        MAX_EXP := 1024,
        MIN_10_EXP := -307,
        MIN_EXP := -1021,
        DECIMAL_DIG := 17,
        I := CP_CXSC_RP_RP(CXSC_INT(0),CXSC_INT(1)),
        2IPI := CP_CXSC_RP_RP(CXSC_INT(0),CXSC_NEWCONSTANT(7))
)));

EAGER_FLOAT_LITERAL_CONVERTERS.X := CXSC_STRING;
EAGER_FLOAT_LITERAL_CONVERTERS.R := RP_CXSC_STRING;
EAGER_FLOAT_LITERAL_CONVERTERS.C := CP_CXSC_STRING;
EAGER_FLOAT_LITERAL_CONVERTERS.I := RI_CXSC_STRING;
EAGER_FLOAT_LITERAL_CONVERTERS.B := CI_CXSC_STRING;

################################################################
# unary operations
################################################################
InstallMethod(ZeroMutable,[IsCXSCReal],x->0.0_R);
InstallMethod(ZeroMutable,[IsCXSCComplex],x->0.0_C);
InstallMethod(ZeroMutable,[IsCXSCInterval],x->0.0_I);
InstallMethod(ZeroMutable,[IsCXSCBox],x->0.0_B);
InstallMethod(ZeroSameMutability,[IsCXSCReal],x->0.0_R);
InstallMethod(ZeroSameMutability,[IsCXSCComplex],x->0.0_C);
InstallMethod(ZeroSameMutability,[IsCXSCInterval],x->0.0_I);
InstallMethod(ZeroSameMutability,[IsCXSCBox],x->0.0_B);
InstallMethod(ZeroImmutable,[IsCXSCReal],x->0.0_R);
InstallMethod(ZeroImmutable,[IsCXSCComplex],x->0.0_C);
InstallMethod(ZeroImmutable,[IsCXSCInterval],x->0.0_I);
InstallMethod(ZeroImmutable,[IsCXSCBox],x->0.0_B);

InstallMethod(OneMutable,[IsCXSCReal],x->1.0_R);
InstallMethod(OneMutable,[IsCXSCComplex],x->1.0_C);
InstallMethod(OneMutable,[IsCXSCInterval],x->1.0_I);
InstallMethod(OneMutable,[IsCXSCBox],x->1.0_B);
InstallMethod(OneSameMutability,[IsCXSCReal],x->1.0_R);
InstallMethod(OneSameMutability,[IsCXSCComplex],x->1.0_C);
InstallMethod(OneSameMutability,[IsCXSCInterval],x->1.0_I);
InstallMethod(OneSameMutability,[IsCXSCBox],x->1.0_B);
InstallMethod(OneImmutable,[IsCXSCReal],x->1.0_R);
InstallMethod(OneImmutable,[IsCXSCComplex],x->1.0_C);
InstallMethod(OneImmutable,[IsCXSCInterval],x->1.0_I);
InstallMethod(OneImmutable,[IsCXSCBox],x->1.0_B);

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

CallFuncList(function(arg)
    local i;
    for i in arg do
        InstallOtherMethod(VALUE_GLOBAL(i[1]), "cxsc:rp", [IsCXSCReal],
                VALUE_GLOBAL(Concatenation(i[2],"_RP")));
        InstallOtherMethod(VALUE_GLOBAL(i[1]), "cxsc:cp", [IsCXSCComplex],
                VALUE_GLOBAL(Concatenation(i[2],"_CP")));
        InstallOtherMethod(VALUE_GLOBAL(i[1]), "cxsc:ri", [IsCXSCInterval],
                VALUE_GLOBAL(Concatenation(i[2],"_RI")));
        InstallOtherMethod(VALUE_GLOBAL(i[1]), "cxsc:ci", [IsCXSCBox],
                VALUE_GLOBAL(Concatenation(i[2],"_CI")));
    od;
end,   [["AINV","AINV_CXSC"],
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
        ["Log1p","LOG1P_CXSC"],
        ["Log2","LOG2_CXSC"],
        ["Log10","LOG10_CXSC"],
        ["Exp","EXP_CXSC"],
        ["Expm1","EXPM1_CXSC"],
        ["FrExp","FREXP_CXSC"],
        ["ExtRepOfObj","EXTREPOFOBJ_CXSC"],
        ["IsNaN","ISNAN_CXSC"],
        ["IsFinite","ISNUMBER_CXSC"],
        ["IsPInfinity","ISPINF_CXSC"],
        ["IsNInfinity","ISNINF_CXSC"],
        ["IsXInfinity","ISXINF_CXSC"],
        ["IsZero","ISZERO_CXSC"],
        ["IsOne","ISONE_CXSC"],
        ["Square","SQR_CXSC"]]);

InstallMethod(SignFloat, "cxsc:rp", [IsCXSCReal], SIGN_CXSC_RP);
InstallMethod(SignFloat, "cxsc:ri", [IsCXSCInterval], SIGN_CXSC_RI);
InstallMethod(Hypothenuse, "cxsc:rp", [IsCXSCReal,IsCXSCReal], HYPOT_CXSC_RP2);

################################################################
# interval stuff
################################################################

InstallMethod(Inf, "cxsc:ri", [IsCXSCInterval], INF_CXSC_RI);
InstallMethod(Sup, "cxsc:ri", [IsCXSCInterval], SUP_CXSC_RI);
InstallMethod(Mid, "cxsc:ri", [IsCXSCInterval], MID_CXSC_RI);
InstallMethod(AbsoluteDiameter, "cxsc:ri", [IsCXSCInterval], DIAM_CXSC_RI);
InstallMethod(RelativeDiameter, "cxsc:ri", [IsCXSCInterval], DIAM_REL_CXSC_RI);
InstallMethod(Inf, "cxsc:ci", [IsCXSCBox], INF_CXSC_CI);
InstallMethod(Sup, "cxsc:ci", [IsCXSCBox], SUP_CXSC_CI);
InstallMethod(Mid, "cxsc:ci", [IsCXSCBox], MID_CXSC_CI);
InstallMethod(AbsoluteDiameter, "cxsc:ci", [IsCXSCBox], DIAM_CXSC_CI);
InstallMethod(RelativeDiameter, "cxsc:ci", [IsCXSCBox], DIAM_REL_CXSC_CI);

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
InstallMethod(IsSubset, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval], SUM_FLAGS,
        IN_CXSC_RI_RI);
InstallMethod(IsSubset, "cxsc:ri,ci", [IsCXSCInterval,IsCXSCBox], SUM_FLAGS,
        IN_CXSC_RI_CI);
InstallMethod(IsSubset, "cxsc:ci,ci", [IsCXSCBox,IsCXSCBox], SUM_FLAGS,
        IN_CXSC_CI_CI);
InstallMethod(IsDisjoint, "cxsc:ci,ci", [IsCXSCBox,IsCXSCBox],
        DISJOINT_CXSC_CI_CI);
InstallMethod(Overlaps, "cxsc:ci,ci", [IsCXSCBox,IsCXSCBox],
        function(a,b) return not DISJOINT_CXSC_CI_CI(a,b); end);
InstallOtherMethod(Union2, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval],
        OR_CXSC_RI_RI);
InstallOtherMethod(Union2, "cxsc:ri,ci", [IsCXSCInterval,IsCXSCBox],
        OR_CXSC_RI_CI);
InstallOtherMethod(Union2, "cxsc:ci,ri", [IsCXSCBox,IsCXSCInterval],
        OR_CXSC_CI_RI);
InstallOtherMethod(Union2, "cxsc:ci,ci", [IsCXSCBox,IsCXSCBox],
        OR_CXSC_CI_CI);
InstallOtherMethod(Intersection2, "cxsc:ri,ri", [IsCXSCInterval,IsCXSCInterval],
        AND_CXSC_RI_RI);
InstallOtherMethod(Intersection2, "cxsc:ri,ci", [IsCXSCInterval,IsCXSCBox],
        AND_CXSC_RI_CI);
InstallOtherMethod(Intersection2, "cxsc:ci,ri", [IsCXSCBox,IsCXSCInterval],
        AND_CXSC_CI_RI);
InstallOtherMethod(Intersection2, "cxsc:ci,ci", [IsCXSCBox,IsCXSCBox],
        AND_CXSC_CI_CI);

InstallMethod(Value, [IsUnivariatePolynomial, IsCXSCReal],
        function(poly,r)
    local v;
    poly := FloatCoefficientsOfUnivariatePolynomial(poly);
    if not ForAll(poly,c->IsCXSCReal(c) or IsCXSCComplex(c)) then
        TryNextMethod();
    fi;
    v := EVALPOLY_CXSC(poly,r);
    if v=fail then TryNextMethod(); fi;
    return v[1];
end);

InstallMethod(ValueInterval, [IsUnivariatePolynomial, IsCXSCReal],
        function(poly,r)
    local v;
    poly := FloatCoefficientsOfUnivariatePolynomial(poly);
    if not ForAll(poly,c->IsCXSCReal(c) or IsCXSCComplex(c)) then
        TryNextMethod();
    fi;
    v := EVALPOLY_CXSC(poly,r);
    if v=fail then TryNextMethod(); fi;
    return v[2];
end);

################################################################
# complex stuff
################################################################
InstallMethod(RealPart, "cxsc:rp", [IsCXSCReal], x->x);
InstallMethod(RealPart, "cxsc:ri", [IsCXSCInterval], x->x);
InstallMethod(RealPart, "cxsc:cp", [IsCXSCComplex], REAL_CXSC_CP);
InstallMethod(RealPart, "cxsc:ci", [IsCXSCBox], REAL_CXSC_CI);
InstallMethod(ImaginaryPart, "cxsc:cp", [IsCXSCReal], x->0.0_R);
InstallMethod(ImaginaryPart, "cxsc:ci", [IsCXSCInterval], x->0.0_I);
InstallMethod(ImaginaryPart, "cxsc:cp", [IsCXSCComplex], IMAG_CXSC_CP);
InstallMethod(ImaginaryPart, "cxsc:ci", [IsCXSCBox], IMAG_CXSC_CI);
InstallMethod(ComplexConjugate, "cxsc:rp", [IsCXSCReal], x->x);
InstallMethod(ComplexConjugate, "cxsc:ri", [IsCXSCInterval], x->x);
InstallMethod(ComplexConjugate, "cxsc:cp", [IsCXSCComplex], CONJ_CXSC_CP);
InstallMethod(ComplexConjugate, "cxsc:ci", [IsCXSCBox], CONJ_CXSC_CI);
InstallMethod(Norm, "cxsc:rp", [IsCXSCReal], SQR_CXSC_RP);
InstallMethod(Norm, "cxsc:ri", [IsCXSCInterval], SQR_CXSC_RI);
InstallMethod(Norm, "cxsc:cp", [IsCXSCComplex], NORM_CXSC_CP);
InstallMethod(Norm, "cxsc:ci", [IsCXSCBox], NORM_CXSC_CI);
        
################################################################
# binary operations
################################################################
CallFuncList(function(arg)
    local i, j;
    for i in arg do
        for j in Tuples([["RP",IsCXSCReal],["CP",IsCXSCComplex],["RI",IsCXSCInterval],["CI",IsCXSCBox]],2) do
            InstallMethod(VALUE_GLOBAL(i), Concatenation("cxsc:",j[1][1],",",j[2][1]),
                    j{[1..2]}[2], VALUE_GLOBAL(Concatenation(i,"_CXSC_",j[1][1],"_",j[2][1])));
        od;
        CallFuncList(function(oper)
            InstallOtherMethod(oper,"float,cyc",[IsCXSCFloatRep,IsCyc],
                    function(x,y)
                return oper(x,MakeFloat(x,y));
            end);
            InstallOtherMethod(oper,"float,any",[IsCyc,IsCXSCFloatRep],
                    function(x,y)
                return oper(MakeFloat(y,x),y);
            end);
        end,[VALUE_GLOBAL(i)]);
    od;
end, ["SUM","DIFF","QUO","PROD","POW","EQ","LT"]);

BindGlobal("CXSC_POW_RAT", function(f,r,POWER,ROOT)
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
end);

InstallMethod(POW, "cxsc:, rat", [IsCXSCReal, IsRat],
        function(f,r)
    return CXSC_POW_RAT(f,r,POWER_CXSC_RP,ROOT_CXSC_RP);
end);
InstallMethod(POW, "cxsc:, rat", [IsCXSCComplex, IsRat],
        function(f,r)
    return CXSC_POW_RAT(f,r,POWER_CXSC_CP,ROOT_CXSC_CP);
end);
InstallMethod(POW, "cxsc:, rat", [IsCXSCInterval, IsRat],
        function(f,r)
    return CXSC_POW_RAT(f,r,POWER_CXSC_RI,ROOT_CXSC_RI);
end);
InstallMethod(POW, "cxsc:, rat", [IsCXSCBox, IsRat],
        function(f,r)
    return CXSC_POW_RAT(f,r,POWER_CXSC_CI,ROOT_CXSC_CI);
end);

InstallMethod(Atan2, "cxsc:rp,rp", [IsCXSCReal,IsCXSCReal], ATAN2_CXSC_RP_RP);
InstallOtherMethod(Atan2, "cxsc:cp", [IsCXSCComplex], ATAN2_CXSC_CP);
InstallOtherMethod(Atan2, "cxsc:ci", [IsCXSCBox], ATAN2_CXSC_CI);

InstallMethod(LdExp, "cxsc:rp, int", [IsCXSCReal, IsInt], LDEXP_CXSC_RP);
InstallMethod(LdExp, "cxsc:ri, int", [IsCXSCInterval, IsInt], LDEXP_CXSC_RI);
InstallMethod(LdExp, "cxsc:cp, int", [IsCXSCComplex, IsInt], LDEXP_CXSC_CP);
InstallMethod(LdExp, "cxsc:ci, int", [IsCXSCBox, IsInt], LDEXP_CXSC_CI);

################################################################
# roots
################################################################
InstallMethod(RootsFloatOp, "cxsc: list, cxsc:ci", [IsList,IsCXSCFloat],
        function(p,filter)
    return ROOTPOLY_CXSC(p,false);
end);

################################################################
# default constructors
################################################################
INSTALLFLOATCREATOR("for lists", [IsCXSCFloat,IsList],
        function(filter,list)
    return OBJBYEXTREP_CXSC_RP(list);
end);

INSTALLFLOATCREATOR("for integers", [IsCXSCFloat,IsInt],
        function(filter,int)
    local f, m;
    f := 0.0_R;
    m := 1.0_R;
    while int <> 0 do
        f := f + m*CXSC_INT(RemInt(int,2^27));
        int := QuoInt(int,2^27);
        m := LdExp(m,27);
    od;
    return f;
end);

INSTALLFLOATCREATOR("for strings", [IsCXSCReal,IsFloat],
        function(filter,s)
    return RP_CXSC_STRING(s);
end);

INSTALLFLOATCREATOR("for cxsc:rp", [IsCXSCReal,IsIEEE754FloatRep],
        function(filter,x)
    return CXSC_IEEE754(x);
end);

################################################################
# real constructors
################################################################
INSTALLFLOATCREATOR("for lists", [IsCXSCReal,IsList],
        function(filter,list)
    return OBJBYEXTREP_CXSC_RP(list);
end);

INSTALLFLOATCREATOR("for integers", [IsCXSCReal,IsInt],
        function(filter,int)
    local f, m;
    f := 0.0_R;
    m := 1.0_R;
    while int <> 0 do
        f := f + m*CXSC_INT(RemInt(int,2^27));
        int := QuoInt(int,2^27);
        m := LdExp(m,27);
    od;
    return f;
end);

INSTALLFLOATCREATOR("for strings", [IsCXSCReal,IsString],
        function(filter,s)
    return RP_CXSC_STRING(s);
end);

INSTALLFLOATCREATOR("for cxsc:rp", [IsCXSCReal,IsCXSCReal],
        function(filter,x)
    return x;
end);

INSTALLFLOATCONSTRUCTORS(rec(filter:=IsCXSCReal, constants := CXSC.constants));

################################################################
# complex constructors
################################################################
INSTALLFLOATCREATOR("for lists", [IsCXSCComplex,IsList],
        function(filter,list)
    return OBJBYEXTREP_CXSC_CP(list);
end);

INSTALLFLOATCREATOR("for ints", [IsCXSCComplex,IsInt],
        function(filter,x)
    return CP_CXSC_RP(NewFloat(IsCXSCReal,x));
end);

DECLAREFLOATCREATOR(IsCXSCComplex,IsCXSCReal,IsCXSCReal);
INSTALLFLOATCREATOR("for two reals", [IsCXSCComplex,IsCXSCReal,IsCXSCReal],
        function(filter,x,y)
    return CP_CXSC_RP_RP(x,y);
end);
                
DECLAREFLOATCREATOR(IsCXSCComplex,IsInt,IsInt);
INSTALLFLOATCREATOR("for two ints", [IsCXSCComplex,IsInt,IsInt],
        function(filter,x,y)
    return CP_CXSC_RP_RP(NewFloat(IsCXSCReal,x),NewFloat(IsCXSCReal,y));
end);
                
INSTALLFLOATCREATOR("for strings", [IsCXSCComplex,IsString],
        function(filter,s)
    return CP_CXSC_STRING(s);
end);

INSTALLFLOATCREATOR("for a real", [IsCXSCComplex,IsCXSCReal],
        function(filter,x)
    return CP_CXSC_RP(x);
end);

INSTALLFLOATCREATOR("for a complex", [IsCXSCComplex,IsCXSCComplex],
        function(filter,x)
    return x;
end);

INSTALLFLOATCONSTRUCTORS(rec(filter:=IsCXSCComplex));

################################################################
# interval constructors
################################################################
INSTALLFLOATCREATOR("for lists", [IsCXSCInterval,IsList],
        function(filter,list)
    return OBJBYEXTREP_CXSC_RI(list);
end);

INSTALLFLOATCREATOR("for ints", [IsCXSCInterval,IsInt],
        function(filter,x)
    return RI_CXSC_RP(NewFloat(IsCXSCReal,x));
end);

DECLAREFLOATCREATOR(IsCXSCInterval,IsCXSCReal,IsCXSCReal);
INSTALLFLOATCREATOR("for two reals", [IsCXSCInterval,IsCXSCReal,IsCXSCReal],
        function(filter,x,y)
    return RI_CXSC_RP_RP(x,y);
end);
                
DECLAREFLOATCREATOR(IsCXSCInterval,IsInt,IsInt);
INSTALLFLOATCREATOR("for two integers", [IsCXSCInterval,IsInt,IsInt],
        function(filter,x,y)
    return RI_CXSC_RP_RP(NewFloat(IsCXSCReal,x),NewFloat(IsCXSCReal,y));
end);
                
INSTALLFLOATCREATOR("for strings", [IsCXSCInterval,IsString],
        function(filter,s)
    return RI_CXSC_STRING(s);
end);

INSTALLFLOATCREATOR("for a real", [IsCXSCInterval,IsCXSCReal],
        function(filter,x)
    return RI_CXSC_RP(x);
end);

INSTALLFLOATCREATOR("for an interval", [IsCXSCInterval,IsCXSCInterval],
        function(filter,x)
    return x;
end);

INSTALLFLOATCONSTRUCTORS(rec(filter:=IsCXSCInterval));

################################################################
# complex interval constructors
################################################################
INSTALLFLOATCREATOR("for lists", [IsCXSCBox,IsList],
        function(filter,list)
    return OBJBYEXTREP_CXSC_CP(list);
end);

INSTALLFLOATCREATOR("for ints", [IsCXSCBox,IsInt],
        function(filter,x)
    return CI_CXSC_RI_RI(NewFloat(IsCXSCInterval,x),0.0_I);
end);

DeclareConstructor("NewFloat", [IsCXSCBox,IsCXSCReal,IsCXSCReal]);
DeclareOperation("MakeFloat", [IsCXSCBox,IsCXSCReal,IsCXSCReal]);
DeclareConstructor("NewFloat", [IsCXSCBox,IsCXSCComplex,IsCXSCComplex]);
DeclareOperation("MakeFloat", [IsCXSCBox,IsCXSCComplex,IsCXSCComplex]);
DeclareConstructor("NewFloat", [IsCXSCBox,IsCXSCInterval,IsCXSCInterval]);
DeclareOperation("MakeFloat", [IsCXSCBox,IsCXSCInterval,IsCXSCInterval]);

INSTALLFLOATCREATOR("for two reals", [IsCXSCBox,IsCXSCReal,IsCXSCReal],
        function(filter,x,y)
    return CI_CXSC_CP(CP_CXSC_RP_RP(x,y));
end);
                
INSTALLFLOATCREATOR("for two complexes", [IsCXSCBox,IsCXSCComplex,IsCXSCComplex],
        function(filter,x,y)
    return CI_CXSC_CP_CP(x,y);
end);
                
INSTALLFLOATCREATOR("for two intervals", [IsCXSCBox,IsCXSCInterval,IsCXSCInterval],
        function(filter,x,y)
    return CI_CXSC_RI_RI(x,y);
end);
                
INSTALLFLOATCREATOR("for strings", [IsCXSCBox,IsString],
        function(filter,s)
    return CI_CXSC_STRING(s);
end);

INSTALLFLOATCREATOR("for a real", [IsCXSCBox,IsCXSCReal],
        function(filter,x)
    return CI_CXSC_CP(CP_CXSC_RP(x));
end);

INSTALLFLOATCREATOR("for a complex", [IsCXSCBox,IsCXSCComplex],
        function(filter,x)
    return CI_CXSC_CP(x);
end);

INSTALLFLOATCREATOR("for an interval", [IsCXSCBox,IsCXSCInterval],
        function(filter,x)
    return CI_CXSC_RI_RI(x,0.0_I);
end);

INSTALLFLOATCREATOR("for a box", [IsCXSCBox,IsCXSCBox],
        function(filter,x)
    return x;
end);

INSTALLFLOATCONSTRUCTORS(rec(filter:=IsCXSCBox));

#############################################################################
##
#E
