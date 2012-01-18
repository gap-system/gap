#############################################################################
##
#W  mpfr.gi                        GAP library              Laurent Bartholdi
##
#H  @(#)$Id: mpfr.gi,v 1.15 2012/01/17 10:57:03 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with floats
##
Revision.float.mpfr_gi :=
  "@(#)$Id: mpfr.gi,v 1.15 2012/01/17 10:57:03 gap Exp $";

################################################################
# viewers
################################################################
BindGlobal("MPFRBITS@", function(obj)
    local s;
    s := ValueOption("bits");
    if IsInt(s) then return s; fi;
    if IsMPFRFloat(obj) then return PrecisionFloat(obj); fi;
    return MPFR.constants.MANT_DIG;
end);

InstallMethod(ViewString, "float", [IsMPFRFloat],
        function(obj)
    return STRING_MPFR(obj,FLOAT.VIEW_DIG);
end);

InstallMethod(String, "float, int", [IsMPFRFloat, IsInt],
        function(obj,len)
    return STRING_MPFR(obj,len);
end);
        
InstallMethod(String, "float", [IsMPFRFloat],
        obj->STRING_MPFR(obj,0));

BindGlobal("MPFRFLOAT_STRING", s->MPFR_STRING(s,MPFRBITS@(fail)));

################################################################
# constants
################################################################
EAGER_FLOAT_LITERAL_CONVERTERS.r := MPFRFLOAT_STRING;

InstallValue(MPFR, rec(
    creator := MPFRFLOAT_STRING,
    objbyextrep := OBJBYEXTREP_MPFR,
    eager := 'r',
    filter := IsMPFRFloat,
    constants := rec(INFINITY := MPFR_MAKEINFINITY(1),
                     NINFINITY := MPFR_MAKEINFINITY(-1),
                     VIEW_DIG := 6,
                     DECIMAL_DIG := 30,
                     MANT_DIG := 100,
                     NAN := MPFR_MAKENAN(1),
                     recompute := function(r,prec)
    r.PI := MPFR_PI(prec);
    r.1_PI := Inverse(r.PI);
    r.2PI := MPFR_INT(2)*r.PI;
    r.2_PI := Inverse(r.2PI);
    r.2_SQRTPI := MPFR_INT(2)/Sqrt(r.PI);
    r.PI_2 := r.PI/MPFR_INT(2);
    r.PI_4 := r.PI_2/MPFR_INT(2);
    
    r.SQRT2 := Sqrt(MPFR_INTPREC(2,prec));
    r.1_SQRT2 := Inverse(r.SQRT2);
    
    r.E := Exp(MPFR_INTPREC(1,prec));
    r.LN2 := Log(MPFR_INTPREC(2,prec));
    r.LN10 := Log(MPFR_INTPREC(10,prec));
    r.LOG10E := Inverse(r.LN10);
    r.LOG2E := Inverse(r.LN2);
end)));

################################################################
# unary operations
################################################################
CallFuncList(function(arg)
    local i;
    for i in arg do
        InstallOtherMethod(VALUE_GLOBAL(i[1]), "MPFR float", [IsMPFRFloat], i[2]);
    od;
end,   [["AINV",AINV_MPFR],
        ["INV",INV_MPFR],
        ["Int",INT_MPFR],
        ["AbsoluteValue",ABS_MPFR],
        ["ZeroMutable",ZERO_MPFR],
        ["ZeroImmutable",ZERO_MPFR],
        ["ZeroSameMutability",ZERO_MPFR],
        ["OneMutable",ONE_MPFR],
        ["OneImmutable",ONE_MPFR],
        ["OneSameMutability",ONE_MPFR],
        ["Sqrt",SQRT_MPFR],
        ["Cos",COS_MPFR],
        ["Sin",SIN_MPFR],
        ["SinCos",SINCOS_MPFR],
        ["Tan",TAN_MPFR],
        ["Sec",SEC_MPFR],
        ["Csc",CSC_MPFR],
        ["Cot",COT_MPFR],
        ["Asin",ASIN_MPFR],
        ["Acos",ACOS_MPFR],
        ["Atan",ATAN_MPFR],
        ["Cosh",COSH_MPFR],
        ["Sinh",SINH_MPFR],
        ["Tanh",TANH_MPFR],
        ["Sech",SECH_MPFR],
        ["Csch",CSCH_MPFR],
        ["Coth",COTH_MPFR],
        ["Asinh",ASINH_MPFR],
        ["Acosh",ACOSH_MPFR],
        ["Atanh",ATANH_MPFR],
        ["Log",LOG_MPFR],
        ["Log2",LOG2_MPFR],
        ["Log10",LOG10_MPFR],
        ["Log1p",LOG1P_MPFR],
        ["Exp",EXP_MPFR],
        ["Exp2",EXP2_MPFR],
        ["Exp10",EXP10_MPFR],
        ["Expm1",EXPM1_MPFR],
        ["CubeRoot",CBRT_MPFR],
        ["Square",SQR_MPFR],
        ["Ceil",CEIL_MPFR],
        ["Floor",FLOOR_MPFR],
        ["Round",ROUND_MPFR],
        ["Trunc",TRUNC_MPFR],
        ["Frac",FRAC_MPFR],
        ["FrExp",FREXP_MPFR],
        ["Norm",SQR_MPFR],
        ["Argument",ZERO_MPFR],
        ["SignFloat",SIGN_MPFR],
        ["IsXInfinity",ISXINF_MPFR],
        ["IsPInfinity",ISPINF_MPFR],
        ["IsNInfinity",ISNINF_MPFR],
        ["IsFinite",ISNUMBER_MPFR],
        ["IsNaN",ISNAN_MPFR],
        ["ExtRepOfObj",EXTREPOFOBJ_MPFR],
        ["RealPart",x->x],
        ["ImaginaryPart",ZERO_MPFR],
        ["ComplexConjugate",x->x],
        ["PrecisionFloat",PREC_MPFR]]);

################################################################
# binary operations
################################################################
CallFuncList(function(arg)
    local i;
    for i in arg do
        InstallMethod(VALUE_GLOBAL(i), "float", [IsMPFRFloat, IsMPFRFloat],
                VALUE_GLOBAL(Concatenation(i,"_MPFR")));
    od;
end, ["SUM","DIFF","QUO","PROD","LQUO","MOD","POW","EQ","LT"]);

InstallMethod(EqFloat, "float, float", [IsMPFRFloat, IsMPFRFloat], EQ_MPFR);

InstallMethod(POW, "float, rat", [IsMPFRFloat, IsRat], 
        function(f,r)
    if DenominatorRat(r)=1 then
        TryNextMethod();
    fi;
    if NumeratorRat(r)<>1 then
        f := f^NumeratorRat(r);
    fi;
    return ROOT_MPFR(f,DenominatorRat(r));
end);

InstallMethod(Atan2, "MPFR float, MPFR float", [IsMPFRFloat, IsMPFRFloat], ATAN2_MPFR);
InstallMethod(Hypothenuse, "MPFR float, MPFR float", [IsMPFRFloat, IsMPFRFloat], HYPOT_MPFR);
InstallMethod(LdExp, "MPFR float, int", [IsMPFRFloat, IsInt], LDEXP_MPFR);

if IsBound(COMPLEXROOTS_MPC) then
InstallMethod(RootsFloatOp, "MPFR float list, MPFR float",
        [IsList,IsMPFRFloat],
        function(coeff,tag)
    local roots, i, j, r, lone;
    
    if not ForAll(coeff,x->IsMPFRFloat(x)) then
        TryNextMethod();
    fi;
    roots := COMPLEXROOTS_MPC(List(coeff,x->NewFloat(IsMPCFloat,x)),MPFRBITS@(fail));
    
    for i in [1..Length(roots)] do
        r := 10.0_r*Norm(ImaginaryPart(roots[i]));
        lone := true;
        for j in [1..Length(roots)] do
            if i<>j and Norm(roots[i]-roots[j]) <= r then
                lone := false;
                break;
            fi;
        od;
        if lone then
            roots[i] := RealPart(roots[i]);
        fi;
    od;
    return roots;
end);
fi;

################################################################
# constructor
################################################################

INSTALLFLOATCREATOR("for list", [IsMPFRFloat,IsList],
        function(filter,list)
    return OBJBYEXTREP_MPFR(list);
end);

INSTALLFLOATCREATOR("for integers", [IsMPFRFloat,IsInt], 20,
        function(filter,int)
    return MPFR_INTPREC(int,MPFRBITS@(filter));
end);

INSTALLFLOATCREATOR("for rationals", [IsMPFRFloat,IsRat], 10,
        function(filter,rat)
    local n, d, prec;
    n := NumeratorRat(rat);
    d := DenominatorRat(rat);
    prec := MPFRBITS@(filter);
    return MPFR_INTPREC(n,prec)/MPFR_INTPREC(d,prec);
end);

INSTALLFLOATCREATOR("for strings", [IsMPFRFloat,IsString],
        function(filter,s)
    return MPFR_STRING(s,MPFRBITS@(filter));
end);

INSTALLFLOATCREATOR("for float", [IsMPFRFloat,IsMPFRFloat],
        function(filter,obj)
    return MPFR_MPFRPREC(obj,MPFRBITS@(filter));
end);

INSTALLFLOATCREATOR("for float and precision", [IsMPFRFloat,IsMPFRFloat,IsInt],
        function(filter,obj,prec)
    return MPFR_MPFRPREC(obj,prec);
end);

INSTALLFLOATCREATOR("for macfloat", [IsMPFRFloat,IsIEEE754FloatRep],
        function(filter,obj)
    return MPFR_MACFLOAT(obj);
end);

INSTALLFLOATCREATOR("for macfloat and precision", [IsMPFRFloat,IsIEEE754FloatRep,IsInt],
        function(filter,obj,prec)
    return MPFR_MPFRPREC(MPFR_MACFLOAT(obj),prec);
end);

INSTALLFLOATCREATOR("for float", [IsIEEE754FloatRep,IsMPFRFloat],
        function(filter,obj)
    return MACFLOAT_MPFR(obj);
end);

InstallMethod(Rat, "float", [IsMPFRFloat],
        function (x)
    local  M, a_i, i, sign, maxdenom, maxpartial, prec;

    prec := PrecisionFloat(x);
    x := NewFloat(IsMPFRFloat,x,prec+2);
    i := 0; M := [[1,0],[0,1]];
    maxdenom := ValueOption("maxdenom");
    maxpartial := ValueOption("maxpartial");
    if maxpartial=fail then maxpartial := 10000; fi;
    if maxdenom=fail then maxdenom := 2^QuoInt(prec,2); fi;

    if x < 0.0_r then sign := -1; x := -x; else sign := 1; fi;
    repeat
      a_i := Int(x);
      if i >= 2 and M[1][1] * a_i > maxpartial then break; fi;
      M := M * [[a_i,1],[1,0]];
      if x = Float(a_i) then break; fi;
      x := 1.0_r / (x - a_i);
      i := i+1;
    until M[2][1] > maxdenom;
    return sign * M[1][1]/M[2][1];
end);

INSTALLFLOATCREATOR("for cyc", [IsMPFRFloat,IsCyc], -2,
        function(filter,obj)
    local l, z;
    if obj<>ComplexConjugate(obj) then
        return fail;
    fi;
    l := ExtRepOfObj(obj);
    z := 2.0_r*MPFR_PI(MPFRBITS@(filter))/Length(l);
    return l*List([0..Length(l)-1],i->Cos(z*i));
end);    

INSTALLFLOATCONSTRUCTORS(MPFR);

#############################################################################
##
#E
