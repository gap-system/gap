#############################################################################
##
#W  mpfr.gi                        GAP library              Laurent Bartholdi
##
#H  @(#)$Id: mpfr.gi,v 1.4 2011/04/14 21:45:21 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with floats
##
Revision.mpfr_gi :=
  "@(#)$Id: mpfr.gi,v 1.4 2011/04/14 21:45:21 gap Exp $";

################################################################
# viewers
################################################################
InstallMethod(ViewString, "float", [IsMPFRFloat],
        function(obj)
    return STRING_MPFR(obj,FLOAT_VIEW_PRECISION);
end);

InstallMethod(String, "float, int", [IsMPFRFloat, IsInt],
        function(obj,len)
    return STRING_MPFR(obj,len);
end);
        
InstallMethod(String, "float", [IsMPFRFloat],
        obj->STRING_MPFR(obj,0));

BindGlobal("MPFRFLOAT_STRING", s->MPFR_STRING(s,Maximum(64,Int(Length(s)*100000/30103)))); # fast

################################################################
# constants
################################################################
InstallValue(MPFR, rec(0 := MPFR_INT(0),
    _0 := AINV_MPFR(MPFR_INT(0)),
    1 := MPFR_INT(1),
    _1 := MPFR_INT(-1),
    2 := MPFR_INT(2),
    infinity := MPFR_MAKEINFINITY(1),
    _infinity := MPFR_MAKEINFINITY(-1),
    NaN := MPFR_MAKENAN(1),
    makePi := MPFR_PI,
    creator := MPFRFLOAT_STRING,
    filter := IsMPFRFloat
));
MPFR.make2Pi := prec->MPFR.2*MPFR_PI(prec);

################################################################
# unary operations
################################################################
CallFuncList(function(arg)
    local i;
    for i in arg do
        InstallOtherMethod(VALUE_GLOBAL(i[1]), "float", [IsMPFRFloat], i[2]);
    od;
end,   [["AINV",AINV_MPFR],
        ["INV",INV_MPFR],
        ["Int",INT_MPFR],
        ["AbsoluteValue",ABS_MPFR],
        ["ZERO",ZERO_MPFR],
        ["ONE",ONE_MPFR],
        ["Sqrt",SQRT_MPFR],
        ["Cos",COS_MPFR],
        ["Sin",SIN_MPFR],
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
        ["Exp",EXP_MPFR],
        ["Exp2",EXP2_MPFR],
        ["Exp10",EXP10_MPFR],
        ["CubeRoot",CBRT_MPFR],
        ["Square",SQR_MPFR],
        ["Ceil",CEIL_MPFR],
        ["Floor",FLOOR_MPFR],
        ["Round",ROUND_MPFR],
        ["Trunc",TRUNC_MPFR],
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

InstallMethod(Atan2, "float", [IsMPFRFloat, IsMPFRFloat], ATAN2_MPFR);

################################################################
# constructor
################################################################
InstallFloatsConstructors(IsMPFRFloat);

InstallMethod(NewFloat, "for integers", [IsMPFRFloat,IsInt],
        function(filter,int)
    if IsInt(ValueOption("PrecisionFloat")) then
        return MPFR_INTPREC(int,ValueOption("PrecisionFloat"));
    else
        return MPFR_INT(int);
    fi;
end);

InstallMethod(NewFloat, "for rationals", [IsMPFRFloat,IsRat],
        function(filter,rat)
    local n, d, prec;
    n := NumeratorRat(rat);
    d := DenominatorRat(rat);
    if IsInt(ValueOption("PrecisionFloat")) then
        prec := ValueOption("PrecisionFloat");
    elif n=0 then
        return MPFR.0;
    else
        prec := Maximum(64,2+LogInt(AbsInt(n),2),2+LogInt(d,2));
    fi;
    return MPFR_INTPREC(n,prec)/MPFR_INTPREC(d,prec);
end);

InstallMethod(NewFloat, "for strings", [IsMPFRFloat,IsString],
        function(filter,s)
    if IsInt(ValueOption("PrecisionFloat")) then
        return MPFR_STRING(s,ValueOption("PrecisionFloat"));
    else
        return MPFRFLOAT_STRING(s);
    fi;
end);

InstallMethod(NewFloat, "for float", [IsMPFRFloat,IsMPFRFloat],
        function(filter,obj)
    if IsInt(ValueOption("PrecisionFloat")) then
        return MPFR_MPFRPREC(obj,ValueOption("PrecisionFloat"));
    else
        return obj;
    fi;
end);

InstallMethod(Rat, "float", [IsMPFRFloat],
        function (x)
    local M, rem, a, bound, prec;

    M := [[SignFloat(x),0],[0,1]];
    prec := PrecisionFloat(x);
    x := MPFRFloat(x:PrecisionFloat:=prec+2);
    bound := x/2^(prec-1);
    rem := x;
    repeat
        a := Int(rem);
        M := M * [[a,1],[1,0]];
        if rem = a then break; fi;
        rem := MPFR.1/(rem - a);
    until AbsoluteValue(M[1][1]-x*M[2][1]) < M[2][1]*bound;
    return M[1][1]/M[2][1];
end);
#############################################################################
##
#E
