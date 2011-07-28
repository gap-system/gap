#############################################################################
##
#W  mpfi.gi                        GAP library              Laurent Bartholdi
##
#H  @(#)$Id: mpfi.gi,v 1.2 2011/04/11 13:17:21 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with interval floats
##
Revision.mpfi_gi :=
  "@(#)$Id: mpfi.gi,v 1.2 2011/04/11 13:17:21 gap Exp $";

################################################################
# viewers
################################################################
InstallMethod(ViewObj, "float", [IsMPFIFloat],
        function(obj)
    if IsInt(ValueOption("FloatViewLength")) then
        Print(VIEWSTRING_MPFI(obj,ValueOption("FloatViewLength")));
    else
        Print(VIEWSTRING_MPFI(obj,0));
    fi;
end);

InstallMethod(PrintObj, "float", [IsMPFIFloat],
        function(obj)
    Print(String(obj));
end);

InstallMethod(Display, "float", [IsMPFIFloat],
        function(obj)
    Display(String(obj));
end);

InstallMethod(String, "float, int", [IsMPFIFloat, IsInt],
        function(obj,len)
    return STRING_MPFI(obj,len);
end);
        
InstallMethod(String, "float", [IsMPFIFloat],
        obj->STRING_MPFI(obj,0));

################################################################
# constants
################################################################
InstallValue(MPFI, rec(0 := MPFI_INT(0),
    _0 := AINV_MPFI(MPFI_INT(0)),
    1 := MPFI_INT(1),
    _1 := MPFI_INT(-1),
    2 := MPFI_INT(2),
    infinity := MPFI_MAKEINFINITY(1),
    _infinity := MPFI_MAKEINFINITY(-1),
    NaN := MPFI_MAKENAN(1),
    makePi := MPFI_PI,
    New := MPFIFloat
));
MPFI.make2Pi := prec->MPFI.2*MPFI_PI(prec);

################################################################
# unary operations
################################################################
for __i in [["AINV",AINV_MPFI],
        ["INV",INV_MPFI],
        ["Int",INT_MPFI],
        ["AbsoluteValue",ABS_MPFI],
        ["ZERO",ZERO_MPFI],
        ["ONE",ONE_MPFI],
        ["Sqrt",SQRT_MPFI],
        ["Cos",COS_MPFI],
        ["Sin",SIN_MPFI],
        ["Tan",TAN_MPFI],
        ["Asin",ASIN_MPFI],
        ["Acos",ACOS_MPFI],
        ["Atan",ATAN_MPFI],
        ["Cosh",COSH_MPFI],
        ["Sinh",SINH_MPFI],
        ["Tanh",TANH_MPFI],
        ["Asinh",ASINH_MPFI],
        ["Acosh",ACOSH_MPFI],
        ["Atanh",ATANH_MPFI],
        ["Log",LOG_MPFI],
        ["Log2",LOG2_MPFI],
        ["Log10",LOG10_MPFI],
        ["Exp",EXP_MPFI],
        ["Exp2",EXP2_MPFI],
        ["Square",SQR_MPFI],
        ["PrecisionFloat",PREC_MPFI]] do
    InstallOtherMethod(VALUE_GLOBAL(__i[1]), "float", [IsMPFIFloat], __i[2]);
od;
Unbind(__i);

if false then
return [        ["Sec",SEC_MPFI],
        ["Csc",CSC_MPFI],
        ["Cot",COT_MPFI],
        ["Sech",SECH_MPFI],
        ["Csch",CSCH_MPFI],
        ["Coth",COTH_MPFI],
        ["Exp10",EXP10_MPFI],
        ["CubeRoot",CBRT_MPFI],
        ["Ceil",CEIL_MPFI],
        ["Floor",FLOOR_MPFI],
        ["Round",ROUND_MPFI],
               ["Trunc",TRUNC_MPFI],
               ["MOD",MOD_MPFI],
               ["POW",POW_MPFI],
               0];
InstallMethod(Atan2, "float", [IsMPFIFloat, IsMPFIFloat], ATAN2_MPFI);
fi;
  
InstallMethod(SignFloat, "float", [IsMPFIFloat], function(x)
    if x>MPFI.0 then
        return 1;
    elif x < MPFI.0 then
        return -1;
    else
        return 0;
    fi;
end);

InstallMethod(Inf, "float", [IsMPFIFloat], LEFT_MPFI);
InstallMethod(Sup, "float", [IsMPFIFloat], RIGHT_MPFI);

################################################################
# binary operations
################################################################
for __i in ["SUM","DIFF","QUO","PROD","LQUO","EQ","LT"] do
    InstallMethod(VALUE_GLOBAL(__i), "float",
            [IsMPFIFloat, IsMPFIFloat], VALUE_GLOBAL(Concatenation(__i,"_MPFI")));
od;
Unbind(__i);

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


InstallMethod(SUM, "float, scalar", [IsMPFIFloat,IsScalar],
        function(x,y) return SUM(x,MPFIFloat(y)); end);
InstallMethod(SUM, "scalar, float", [IsScalar,IsMPFIFloat],
        function(x,y) return SUM(MPFIFloat(x),y); end);
InstallMethod(DIFF, "float, scalar", [IsMPFIFloat,IsScalar],
        function(x,y) return DIFF(x,MPFIFloat(y)); end);
InstallMethod(DIFF, "scalar, float", [IsScalar,IsMPFIFloat],
        function(x,y) return DIFF(MPFIFloat(x),y); end);
InstallMethod(PROD, "float, scalar", [IsMPFIFloat,IsScalar],
        function(x,y) return PROD(x,MPFIFloat(y)); end);
InstallMethod(PROD, "scalar, float", [IsScalar,IsMPFIFloat],
        function(x,y) return PROD(MPFIFloat(x),y); end);
InstallMethod(QUO, "float, scalar", [IsMPFIFloat,IsScalar],
        function(x,y) return QUO(x,MPFIFloat(y)); end);
InstallMethod(QUO, "scalar, float", [IsScalar,IsMPFIFloat],
        function(x,y) return QUO(MPFIFloat(x),y); end);
InstallMethod(POW, "float, scalar", [IsMPFIFloat,IsScalar],
        function(x,y) return POW(x,MPFIFloat(y)); end);
InstallMethod(POW, "scalar, float", [IsScalar,IsMPFIFloat],
        function(x,y) return POW(MPFIFloat(x),y); end);
InstallMethod(LQUO, "float, scalar", [IsMPFIFloat,IsScalar],
        function(x,y) return LQUO(x,MPFIFloat(y)); end);
InstallMethod(LQUO, "scalar, float", [IsScalar,IsMPFIFloat],
        function(x,y) return LQUO(MPFIFloat(x),y); end);
InstallMethod(MOD, "float, scalar", [IsMPFIFloat,IsScalar],
        function(x,y) return MOD(x,MPFIFloat(y)); end);
InstallMethod(MOD, "scalar, float", [IsScalar,IsMPFIFloat],
        function(x,y) return MOD(MPFIFloat(x),y); end);
InstallMethod(EQ, "float, scalar", [IsMPFIFloat,IsScalar],
        function(x,y) return EQ(x,MPFIFloat(y)); end);
InstallMethod(EQ, "scalar, float", [IsScalar,IsMPFIFloat],
        function(x,y) return EQ(MPFIFloat(x),y); end);
InstallMethod(LT, "float, scalar", [IsMPFIFloat,IsScalar],
        function(x,y) return LT(x,MPFIFloat(y)); end);
InstallMethod(LT, "scalar, float", [IsScalar,IsMPFIFloat],
        function(x,y) return LT(MPFIFloat(x),y); end);
        
################################################################
# constructor
################################################################
InstallMethod(MPFIFloat, "for integers", [IsInt],
        function(int)
    if IsInt(ValueOption("PrecisionFloat")) then
        return MPFI_INTPREC(int,ValueOption("PrecisionFloat"));
    else
        return MPFI_INT(int);
    fi;
end);
InstallMethod(MPFIFloat, "for rationals", [IsRat],
        function(rat)
    local n, d, prec;
    n := NumeratorRat(rat);
    d := DenominatorRat(rat);
    if IsInt(ValueOption("PrecisionFloat")) then
        prec := ValueOption("PrecisionFloat");
    elif n=0 then
        return MPFI.0;
    else
        prec := Maximum(64,2+LogInt(AbsInt(n),2),2+LogInt(d,2));
    fi;
    return MPFI_INTPREC(n,prec)/MPFI_INTPREC(d,prec);
end);
InstallMethod(MPFIFloat, "for lists", [IsList],
        l->List(l,MPFIFloat));
InstallMethod(MPFIFloat, "for macfloats", [IsFloat], #!!!
        x->MPFIFloat(String(x)));
InstallMethod(MPFIFloat, "for strings", [IsString],
        function(s)
    if IsInt(ValueOption("PrecisionFloat")) then
        return MPFI_STRING(s,ValueOption("PrecisionFloat"));
    else
        return MPFI_STRING(s,Maximum(64,Int(Length(s)*100000/30103)));
    fi;
end);
InstallMethod(MPFIFloat, "for float", [IsMPFIFloat],
        function(obj)
    if IsInt(ValueOption("PrecisionFloat")) then
        return MPFI_MPFIPREC(obj,ValueOption("PrecisionFloat"));
    else
        return obj;
    fi;
end);

InstallMethod(Rat, "float", [IsMPFIFloat],
        function (x)
    local M, a;

    M := [[SignFloat(x),0],[0,1]];
    repeat
        a := Int(Sup(x));
        M := M * [[a,1],[1,0]];
        if x = a then break; fi;
        x := MPFI.1/(x - a);
    until Sup(x)-Inf(x) >= MPFR.1;
    return M[1][1]/M[2][1];
end);

#############################################################################
##
#E
