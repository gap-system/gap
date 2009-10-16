#############################################################################
##
#W  mpfr.gi                        GAP library              Laurent Bartholdi
##
#H  @(#)$Id: mpfr.gi,v 1.1 2008/06/14 15:45:40 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with floats
##
Revision.mpfr_gi :=
  "@(#)$Id: mpfr.gi,v 1.1 2008/06/14 15:45:40 gap Exp $";

################################################################
# viewers
################################################################
InstallMethod(ViewObj, "float", [IsMPFRFloat],
        function(obj)
    if IsInt(ValueOption("FloatViewLength")) then
        Print(STRING_MPFR(obj,ValueOption("FloatViewLength")));
    else
        Print(STRING_MPFR(obj,0));
    fi;
end);

InstallMethod(PrintObj, "float", [IsMPFRFloat],
        function(obj)
    Print(String(obj));
end);

InstallMethod(Display, "float", [IsMPFRFloat],
        function(obj)
    Display(String(obj));
end);

InstallMethod(String, "float, int", [IsMPFRFloat, IsInt],
        function(obj,len)
    return STRING_MPFR(obj,len);
end);
        
InstallMethod(String, "float", [IsMPFRFloat],
        obj->STRING_MPFR(obj,0));

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
    New := MPFRFloat
));
MPFR.make2Pi := prec->MPFR.2*MPFR_PI(prec);

################################################################
# unary operations
################################################################
for __i in [["AINV",AINV_MPFR],
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
        ["PrecisionFloat",PREC_MPFR]] do
    InstallOtherMethod(VALUE_GLOBAL(__i[1]), "float", [IsMPFRFloat], __i[2]);
od;
Unbind(__i);

InstallMethod(SignFloat, "float", [IsMPFRFloat], function(x)
    if x>MPFR.0 then
        return 1;
    elif x < MPFR.0 then
        return -1;
    else
        return 0;
    fi;
end);

################################################################
# binary operations
################################################################
for __i in ["SUM","DIFF","QUO","PROD","LQUO","MOD","POW","EQ","LT"] do
    InstallMethod(VALUE_GLOBAL(__i), "float",
            [IsMPFRFloat, IsMPFRFloat], VALUE_GLOBAL(Concatenation(__i,"_MPFR")));
od;
Unbind(__i);

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

InstallMethod(SUM, "float, scalar", [IsMPFRFloat,IsScalar],
        function(x,y) return SUM(x,MPFRFloat(y)); end);
InstallMethod(SUM, "scalar, float", [IsScalar,IsMPFRFloat],
        function(x,y) return SUM(MPFRFloat(x),y); end);
InstallMethod(DIFF, "float, scalar", [IsMPFRFloat,IsScalar],
        function(x,y) return DIFF(x,MPFRFloat(y)); end);
InstallMethod(DIFF, "scalar, float", [IsScalar,IsMPFRFloat],
        function(x,y) return DIFF(MPFRFloat(x),y); end);
InstallMethod(PROD, "float, scalar", [IsMPFRFloat,IsScalar],
        function(x,y) return PROD(x,MPFRFloat(y)); end);
InstallMethod(PROD, "scalar, float", [IsScalar,IsMPFRFloat],
        function(x,y) return PROD(MPFRFloat(x),y); end);
InstallMethod(QUO, "float, scalar", [IsMPFRFloat,IsScalar],
        function(x,y) return QUO(x,MPFRFloat(y)); end);
InstallMethod(QUO, "scalar, float", [IsScalar,IsMPFRFloat],
        function(x,y) return QUO(MPFRFloat(x),y); end);
InstallMethod(POW, "float, scalar", [IsMPFRFloat,IsScalar],
        function(x,y) return POW(x,MPFRFloat(y)); end);
InstallMethod(POW, "scalar, float", [IsScalar,IsMPFRFloat],
        function(x,y) return POW(MPFRFloat(x),y); end);
InstallMethod(LQUO, "float, scalar", [IsMPFRFloat,IsScalar],
        function(x,y) return LQUO(x,MPFRFloat(y)); end);
InstallMethod(LQUO, "scalar, float", [IsScalar,IsMPFRFloat],
        function(x,y) return LQUO(MPFRFloat(x),y); end);
InstallMethod(MOD, "float, scalar", [IsMPFRFloat,IsScalar],
        function(x,y) return MOD(x,MPFRFloat(y)); end);
InstallMethod(MOD, "scalar, float", [IsScalar,IsMPFRFloat],
        function(x,y) return MOD(MPFRFloat(x),y); end);
InstallMethod(EQ, "float, scalar", [IsMPFRFloat,IsScalar],
        function(x,y) return EQ(x,MPFRFloat(y)); end);
InstallMethod(EQ, "scalar, float", [IsScalar,IsMPFRFloat],
        function(x,y) return EQ(MPFRFloat(x),y); end);
InstallMethod(LT, "float, scalar", [IsMPFRFloat,IsScalar],
        function(x,y) return LT(x,MPFRFloat(y)); end);
InstallMethod(LT, "scalar, float", [IsScalar,IsMPFRFloat],
        function(x,y) return LT(MPFRFloat(x),y); end);
        
################################################################
# constructor
################################################################
InstallMethod(MPFRFloat, "for integers", [IsInt],
        function(int)
    if IsInt(ValueOption("PrecisionFloat")) then
        return MPFR_INTPREC(int,ValueOption("PrecisionFloat"));
    else
        return MPFR_INT(int);
    fi;
end);
InstallMethod(MPFRFloat, "for rationals", [IsRat],
        function(rat)
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
InstallMethod(MPFRFloat, "for lists", [IsList],
        l->List(l,MPFRFloat));
InstallMethod(MPFRFloat, "for macfloats", [IsMacFloat],
        x->MPFRFloat(String(x)));
InstallMethod(MPFRFloat, "for strings", [IsString],
        function(s)
    if IsInt(ValueOption("PrecisionFloat")) then
        return MPFR_STRING(s,ValueOption("PrecisionFloat"));
    else
        return MPFR_STRING(s,Maximum(64,Int(Length(s)*100000/30103)));
    fi;
end);
InstallMethod(MPFRFloat, "for float", [IsMPFRFloat],
        function(obj)
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
