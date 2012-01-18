#############################################################################
##
#W  mpfi.gi                        GAP library              Laurent Bartholdi
##
#H  @(#)$Id: mpfi.gi,v 1.10 2011/09/27 14:46:01 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with interval floats
##
Revision.float.mpfi_gi :=
  "@(#)$Id: mpfi.gi,v 1.10 2011/09/27 14:46:01 gap Exp $";

################################################################
# viewers
################################################################
InstallMethod(ViewString, "float", [IsMPFIFloat],
        function(obj)
    return VIEWSTRING_MPFI(obj,FLOAT.VIEW_DIG);
end);

InstallMethod(String, "float, int", [IsMPFIFloat, IsInt],
        function(obj,len)
    return STRING_MPFI(obj,len);
end);
        
InstallMethod(String, "float", [IsMPFIFloat],
        obj->STRING_MPFI(obj,0));

BindGlobal("MPFIBITS@", function(obj)
    local s;
    s := ValueOption("bits");
    if IsInt(s) then return s; fi;
    if IsMPFIFloat(obj) then return PrecisionFloat(obj); fi;
    return MPFI.constants.MANT_DIG;
end);

BindGlobal("MPFIFLOAT_STRING", s->MPFI_STRING(s,MPFIBITS@(fail)));

################################################################
# constants
################################################################
EAGER_FLOAT_LITERAL_CONVERTERS.i := MPFIFLOAT_STRING;

InstallValue(MPFI, rec(
    creator := MPFIFLOAT_STRING,
    objbyextrep := OBJBYEXTREP_MPFI,
    eager := 'i',
    filter := IsMPFIFloat,
    constants := rec(INFINITY := MPFI_MAKEINFINITY(1),
                     NINFINITY := MPFI_MAKEINFINITY(-1),
                     VIEW_DIG := 6,
                     MANT_DIG := 100,
                     NAN := MPFI_MAKENAN(1),
                     recompute := function(r,prec)
    r.PI := MPFI_PI(prec);
    r.1_PI := Inverse(r.PI);
    r.2PI := MPFI_INT(2)*r.PI;
    r.2_PI := Inverse(r.2PI);
    r.2_SQRTPI := MPFI_INT(2)/Sqrt(r.PI);
    r.PI_2 := r.PI/MPFI_INT(2);
    r.PI_4 := r.PI_2/MPFI_INT(2);
    
    r.SQRT2 := Sqrt(MPFI_INTPREC(2,prec));
    r.1_SQRT2 := Inverse(r.SQRT2);
    
    r.E := Exp(MPFI_INTPREC(1,prec));
    r.LN2 := Log(MPFI_INTPREC(2,prec));
    r.LN10 := Log(MPFI_INTPREC(10,prec));
    r.LOG10E := Inverse(r.LN10);
    r.LOG2E := Inverse(r.LN2);
end)));

################################################################
# unary operations
################################################################
CallFuncList(function(arg)
    local i;
    for i in arg do
        InstallOtherMethod(VALUE_GLOBAL(i[1]), "MPFI float", [IsMPFIFloat], i[2]);
    od;
end,   [["AINV",AINV_MPFI],
        ["INV",INV_MPFI],
        ["Int",INT_MPFI],
        ["AbsoluteValue",ABS_MPFI],
        ["ZeroMutable",ZERO_MPFI],
        ["ZeroImmutable",ZERO_MPFI],
        ["ZeroSameMutability",ZERO_MPFI],
        ["OneMutable",ONE_MPFI],
        ["OneImmutable",ONE_MPFI],
        ["OneSameMutability",ONE_MPFI],
        ["Sqrt",SQRT_MPFI],
        ["Cos",COS_MPFI],
        ["Sin",SIN_MPFI],
        ["Tan",TAN_MPFI],
        ["Sec",SEC_MPFI],
        ["Csc",CSC_MPFI],
        ["Cot",COT_MPFI],
        ["Asin",ASIN_MPFI],
        ["Acos",ACOS_MPFI],
        ["Atan",ATAN_MPFI],
        ["Cosh",COSH_MPFI],
        ["Sinh",SINH_MPFI],
        ["Tanh",TANH_MPFI],
        ["Sech",SECH_MPFI],
        ["Csch",CSCH_MPFI],
        ["Coth",COTH_MPFI],
        ["Asinh",ASINH_MPFI],
        ["Acosh",ACOSH_MPFI],
        ["Atanh",ATANH_MPFI],
        ["Log",LOG_MPFI],
        ["Log2",LOG2_MPFI],
        ["Log10",LOG10_MPFI],
        ["Exp",EXP_MPFI],
        ["Exp2",EXP2_MPFI],
        ["Exp10",EXP10_MPFI],
        ["CubeRoot",CBRT_MPFI],
        ["Square",SQR_MPFI],
        ["Inf", LEFT_MPFI],
        ["Sup", RIGHT_MPFI],
        ["Mid", MID_MPFI],
        ["AbsoluteDiameter", DIAM_MPFI],
        ["RelativeDiameter", DIAM_REL_MPFI],
        ["BisectInterval", BISECT_MPFI],
#        ["Ceil",CEIL_MPFI],
#        ["Floor",FLOOR_MPFI],
#        ["Round",ROUND_MPFI],
#        ["Trunc",TRUNC_MPFI],
#        ["Frac",FRAC_MPFI],
        ["FrExp",FREXP_MPFI],
        ["Norm",SQR_MPFI],
        ["Argument",ZERO_MPFI],
        ["SignFloat",SIGN_MPFI],
        ["IsXInfinity",ISXINF_MPFI],
        ["IsPInfinity",ISPINF_MPFI],
        ["IsNInfinity",ISNINF_MPFI],
        ["IsFinite",ISNUMBER_MPFI],
        ["IsNaN",ISNAN_MPFI],
        ["IsZero",ISZERO_MPFI],
        ["IsEmpty",ISEMPTY_MPFI],
        ["ExtRepOfObj",EXTREPOFOBJ_MPFI],
        ["RealPart",x->x],
        ["ImaginaryPart",ZERO_MPFI],
        ["ComplexConjugate",x->x],
        ["PrecisionFloat",PREC_MPFI]]);

################################################################
# binary operations
################################################################
CallFuncList(function(arg)
    local i;
    for i in arg do
        InstallMethod(VALUE_GLOBAL(i), "MPFI float, MPFI float", [IsMPFIFloat, IsMPFIFloat],
                VALUE_GLOBAL(Concatenation(i,"_MPFI")));
        InstallMethod(VALUE_GLOBAL(i), "MPFI float, MPFR float", [IsMPFIFloat, IsMPFRFloat],
                VALUE_GLOBAL(Concatenation(i,"_MPFI_MPFR")));
        InstallMethod(VALUE_GLOBAL(i), "MPFR float, MPFI float", [IsMPFRFloat, IsMPFIFloat],
                VALUE_GLOBAL(Concatenation(i,"_MPFR_MPFI")));
    od;
end, ["SUM","DIFF","QUO","PROD","LQUO","EQ","LT"]);

InstallMethod(LdExp, "MPFI float, int", [IsMPFIFloat, IsInt], LDEXP_MPFI);
InstallMethod(Atan2, "float", [IsMPFIFloat, IsMPFIFloat], ATAN2_MPFI);  

InstallMethod(POW, "float, rat", [IsMPFIFloat, IsRat], 
        function(f,r)
    if DenominatorRat(r)=1 then
        TryNextMethod();
    fi;
    if NumeratorRat(r)<>1 then
        f := f^NumeratorRat(r);
    fi;
    return ROOT_MPFI(f,DenominatorRat(r));
end);

InstallMethod(IsSubset, [IsMPFIFloat, IsMPFIFloat], ISINSIDE_MPFI);
InstallMethod(IN, [IsMPFIFloat, IsMPFIFloat], SUM_FLAGS, ISINSIDE_MPFI);
InstallMethod(IN, [IsMPFRFloat, IsMPFIFloat], SUM_FLAGS, ISINSIDE_MPFRMPFI);
InstallMethod(Intersection2, [IsMPFIFloat, IsMPFIFloat], INTERSECT_MPFI);
InstallMethod(Union2, [IsMPFIFloat, IsMPFIFloat], UNION_MPFI);
InstallMethod(IncreaseInterval, [IsMPFIFloat, IsMPFRFloat], BLOWUP_MPFI);
InstallMethod(IncreaseInterval, [IsMPFIFloat, IsMPFIFloat],
        function(x,y) return INCREASE_MPFI(x,Sup(y)); end);
InstallMethod(BlowupInterval, [IsMPFIFloat, IsMPFIFloat], BLOWUP_MPFI);
InstallMethod(BlowupInterval, [IsMPFIFloat, IsMPFIFloat],
        function(x,y) return BLOWUP_MPFI(x,Sup(y)); end);
  
################################################################
# constructor
################################################################

INSTALLFLOATCREATOR("for list", [IsMPFIFloat,IsList],
        function(filter,list)
    return OBJBYEXTREP_MPFI(list);
end);

INSTALLFLOATCREATOR("for integers", [IsMPFIFloat,IsInt], 20,
        function(filter,int)
    return MPFI_INTPREC(int,MPFIBITS@(filter));
end);

INSTALLFLOATCREATOR("for rationals", [IsMPFIFloat,IsRat], 10,
        function(filter,rat)
    local n, d, prec;
    n := NumeratorRat(rat);
    d := DenominatorRat(rat);
    prec := MPFIBITS@(filter);
    return MPFI_INTPREC(n,prec)/MPFI_INTPREC(d,prec);
end);

INSTALLFLOATCREATOR("for strings", [IsMPFIFloat,IsString],
        function(filter,s)
    return MPFI_STRING(s,MPFIBITS@(filter));
end);

INSTALLFLOATCREATOR("for MPFI float", [IsMPFIFloat,IsMPFIFloat],
        function(filter,obj)
    return MPFI_MPFIPREC(obj,MPFIBITS@(filter));
end);

INSTALLFLOATCREATOR("for MPFR float", [IsMPFIFloat,IsMPFRFloat],
        function(filter,obj)
    return MPFI_MPFR(obj);
end);

DECLAREFLOATCREATOR(IsMPFIFloat,IsMPFRFloat,IsMPFRFloat);
INSTALLFLOATCREATOR("for 2 MPFR floats", [IsMPFIFloat,IsMPFRFloat,IsMPFRFloat],
        function(filter,re,im)
    return MPFI_2MPFR(re,im);
end);

DECLAREFLOATCREATOR(IsMPFIFloat,IsInt,IsInt);
INSTALLFLOATCREATOR("for 2 ints", [IsMPFIFloat,IsInt,IsInt],
        function(filter,re,im)
    return MPFI_2MPFR(MPFR_INT(re),MPFR_INT(im));
end);

INSTALLFLOATCREATOR("for macfloat", [IsMPFIFloat,IsIEEE754FloatRep],
        function(filter,obj)
    return MPFI_MPFR(MPFR_MACFLOAT(obj));
end);

INSTALLFLOATCONSTRUCTORS(MPFI);

#############################################################################
##
#E
