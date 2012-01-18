#############################################################################
##
#W  mpc.gi                        GAP library               Laurent Bartholdi
##
#H  @(#)$Id: mpc.gi,v 1.14 2011/09/27 15:42:04 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with complex floats
##
Revision.float.mpc_gi :=
  "@(#)$Id: mpc.gi,v 1.14 2011/09/27 15:42:04 gap Exp $";

################################################################
# viewers
################################################################
InstallMethod(ViewString, "float", [IsMPCFloat],
        function(obj)
    return VIEWSTRING_MPC(obj,FLOAT.VIEW_DIG);
end);

InstallMethod(String, "float, int", [IsMPCFloat, IsInt],
        function(obj,len)
    return STRING_MPC(obj,len);
end);
        
InstallMethod(String, "float", [IsMPCFloat],
        obj->STRING_MPC(obj,0));

BindGlobal("MPCBITS@", function(obj)
    local s;
    s := ValueOption("bits");
    if IsInt(s) then return s; fi;
    if IsMPCFloat(obj) then return PrecisionFloat(obj); fi;
    return MPC.constants.MANT_DIG;
end);

BindGlobal("MPCFLOAT_STRING", s->MPC_STRING(s,MPCBITS@(fail)));

################################################################
# constants
################################################################
EAGER_FLOAT_LITERAL_CONVERTERS.c := MPCFLOAT_STRING;

InstallValue(MPC, rec(
    creator := MPCFLOAT_STRING,
    objbyextrep := OBJBYEXTREP_MPFI,
    eager := 'c',
    filter := IsMPCFloat,
    constants := rec(INFINITY := MPC_MAKEINFINITY(1),
                     VIEW_DIG := 6,
                     DECIMAL_DIG := 30,
                     MANT_DIG := 100,
                     NAN := MPC_MAKENAN(1),
                     recompute := function(r,prec)
    r.PI := MPC_MPFR(MPFR_PI(prec));
    r.1_PI := Inverse(r.PI);
    r.2PI := MPC_INT(2)*r.PI;
    r.2_PI := Inverse(r.2PI);
    r.2_SQRTPI := MPC_INT(2)/Sqrt(r.PI);
    r.PI_2 := r.PI/MPC_INT(2);
    r.PI_4 := r.PI_2/MPC_INT(2);
    
    r.SQRT2 := Sqrt(MPC_INTPREC(2,prec));
    r.1_SQRT2 := Inverse(r.SQRT2);
    
    r.E := Exp(MPC_INTPREC(1,prec));
    r.LN2 := Log(MPC_INTPREC(2,prec));
    r.LN10 := Log(MPC_INTPREC(10,prec));
    r.LOG10E := Inverse(r.LN10);
    r.LOG2E := Inverse(r.LN2);
    
    r.I := MPC_2MPFR(MPFR_INT(0),MPFR_INTPREC(1,prec));
    r.2IPI := r.I*r.2PI;
    r.OMEGA := MPC_2MPFR(MPFR_INT(1),Sqrt(MPFR_INTPREC(3,prec)))/MPC_INT(2);
end)));

################################################################
# unary operations
################################################################
CallFuncList(function(arg)
    local i;
    for i in arg do
        InstallOtherMethod(VALUE_GLOBAL(i[1]), "MPC float", [IsMPCFloat], i[2]);
    od;
end,   [["AINV",AINV_MPC],
        ["INV",INV_MPC],
        ["AbsoluteValue",ABS_MPC],
        ["ZeroMutable",ZERO_MPC],
        ["ZeroImmutable",ZERO_MPC],
        ["ZeroSameMutability",ZERO_MPC],
        ["OneMutable",ONE_MPC],
        ["OneImmutable",ONE_MPC],
        ["OneSameMutability",ONE_MPC],
        ["Sqrt",SQRT_MPC],
        ["Cos",COS_MPC],
        ["Sin",SIN_MPC],
        ["Tan",TAN_MPC],
        ["Asin",ASIN_MPC],
        ["Acos",ACOS_MPC],
        ["Atan",ATAN_MPC],
        ["Cosh",COSH_MPC],
        ["Sinh",SINH_MPC],
        ["Tanh",TANH_MPC],
        ["Asinh",ASINH_MPC],
        ["Acosh",ACOSH_MPC],
        ["Atanh",ATANH_MPC],
        ["Log",LOG_MPC],
        ["Exp",EXP_MPC],
        ["Square",SQR_MPC],
        ["SphereProject",PROJ_MPC],
        ["FrExp",FREXP_MPC],
        ["Norm",NORM_MPC],
        ["Argument",ZERO_MPC],
        ["IsXInfinity",ISINF_MPC],
        ["IsPInfinity",ISINF_MPC],
        ["IsNInfinity",ISINF_MPC],
        ["IsFinite",ISNUMBER_MPC],
        ["IsNaN",ISNAN_MPC],
        ["ExtRepOfObj",EXTREPOFOBJ_MPC],
        ["RealPart",REAL_MPC],
        ["ImaginaryPart",IMAG_MPC],
        ["PrecisionFloat",PREC_MPC]]);

################################################################
# binary operations
################################################################
CallFuncList(function(arg)
    local i;
    for i in arg do
        InstallMethod(VALUE_GLOBAL(i), "MPC float, MPC float", [IsMPCFloat, IsMPCFloat],
                VALUE_GLOBAL(Concatenation(i,"_MPC")));
        InstallMethod(VALUE_GLOBAL(i), "MPC float, MPFR float", [IsMPCFloat, IsMPFRFloat],
                VALUE_GLOBAL(Concatenation(i,"_MPC_MPFR")));
        InstallMethod(VALUE_GLOBAL(i), "MPFR float, MPC float", [IsMPFRFloat, IsMPCFloat],
                VALUE_GLOBAL(Concatenation(i,"_MPFR_MPC")));
    od;
end, ["SUM","DIFF","QUO","PROD","LQUO","POW","EQ","LT"]);

InstallMethod(LdExp, "MPC float, int", [IsMPCFloat, IsInt], LDEXP_MPC);

InstallMethod(RootsFloatOp, "MPC float list, MPC float",
        [IsList,IsMPCFloat],
        function(coeff,tag)
    if ForAll(coeff,x->IsMPCFloat(x)) then
        return COMPLEXROOTS_MPC(coeff,MPCBITS@(fail));
    fi;
    TryNextMethod();
end);

################################################################
# constructor
################################################################
  
INSTALLFLOATCREATOR("for list", [IsMPCFloat,IsList],
        function(filter,list)
    return OBJBYEXTREP_MPC(list);
end);

INSTALLFLOATCREATOR("for integers", [IsMPCFloat,IsInt],
        function(filter,int)
    return MPC_INTPREC(int,MPCBITS@(filter));
end);

INSTALLFLOATCREATOR("for rationals", [IsMPCFloat,IsRat], -1,
        function(filter,rat)
    local n, d, prec;
    n := NumeratorRat(rat);
    d := DenominatorRat(rat);
    prec := MPCBITS@(filter);
    return MPC_INTPREC(n,prec)/MPC_INTPREC(d,prec);
end);

INSTALLFLOATCREATOR("for strings", [IsMPCFloat,IsString],
        function(filter,s)
    return MPC_STRING(s,MPCBITS@(filter));
end);

INSTALLFLOATCREATOR("for MPC float", [IsMPCFloat,IsMPCFloat],
        function(filter,obj)
    return MPC_MPCPREC(obj,MPCBITS@(filter));
end);

INSTALLFLOATCREATOR("for MPFR float", [IsMPCFloat,IsMPFRFloat],
        function(filter,obj)
    return MPC_MPFR(obj);
end);

DECLAREFLOATCREATOR(IsMPCFloat,IsMPFRFloat,IsMPFRFloat);
INSTALLFLOATCREATOR("for 2 MPFR floats", [IsMPCFloat,IsMPFRFloat,IsMPFRFloat],
        function(filter,re,im)
    return MPC_2MPFR(re,im);
end);

DECLAREFLOATCREATOR(IsMPCFloat,IsInt,IsInt);
INSTALLFLOATCREATOR("for 2 ints", [IsMPCFloat,IsInt,IsInt],
        function(filter,re,im)
    return MPC_2MPFR(MPFR_INT(re),MPFR_INT(im));
end);

INSTALLFLOATCREATOR("for macfloat", [IsMPCFloat,IsIEEE754FloatRep],
        function(filter,obj)
    return MPC_MPFR(MPFR_MACFLOAT(obj));
end);

INSTALLFLOATCREATOR("for cyc", [IsMPCFloat,IsCyc], -2,
        function(filter,obj)
    local l, z;
    l := ExtRepOfObj(obj);
    z := MPC_2MPFR(0.0_r,2.0_r*MPFR_PI(MPCBITS@(filter)))/Length(l);
    return l*List([0..Length(l)-1],i->Exp(z*i));
end);    

INSTALLFLOATCONSTRUCTORS(MPC);

#############################################################################
##
#E
