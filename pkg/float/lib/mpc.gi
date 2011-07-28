#############################################################################
##
#W  mpc.gi                        GAP library               Laurent Bartholdi
##
#H  @(#)$Id: mpc.gi,v 1.2 2011/04/11 13:17:21 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with complex floats
##
Revision.mpc_gi :=
  "@(#)$Id: mpc.gi,v 1.2 2011/04/11 13:17:21 gap Exp $";

################################################################
# viewers
################################################################
InstallMethod(ViewObj, "float", [IsMPCFloat],
        function(obj)
    if IsInt(ValueOption("FloatViewLength")) then
        Print(VIEWSTRING_MPC(obj,ValueOption("FloatViewLength")));
    else
        Print(VIEWSTRING_MPC(obj,0));
    fi;
end);

InstallMethod(PrintObj, "float", [IsMPCFloat],
        function(obj)
    Print(String(obj));
end);

InstallMethod(Display, "float", [IsMPCFloat],
        function(obj)
    Display(String(obj));
end);

InstallMethod(String, "float, int", [IsMPCFloat, IsInt],
        function(obj,len)
    return STRING_MPC(obj,len);
end);
        
InstallMethod(String, "float", [IsMPCFloat],
        obj->STRING_MPC(obj,0));

################################################################
# constants
################################################################
InstallValue(MPC, rec(0 := MPC_INT(0),
    _0 := AINV_MPC(MPC_INT(0)),
    1 := MPC_INT(1),
    _1 := MPC_INT(-1),
    2 := MPC_INT(2),
    i := MPC_2MPFR(MPFR.0,MPFR.1),
    _i := MPC_2MPFR(MPFR.0,MPFR._1),
    infinity := MPC_MAKEINFINITY(1),
    _infinity := MPC_MAKEINFINITY(-1),
    NaN := MPC_MAKENAN(1),
    makePi := prec->MPC_MPFR(MPFR_PI(prec)),
    make2Pi := prec->MPC_MPFR(MPFR.2*MPFR_PI(prec)),
    make2IPi := prec->MPC_2MPFR(MPFR.0,MPFR.2*MPFR_PI(prec)),
    New := MPCFloat
));

################################################################
# unary operations
################################################################
for __i in [["AINV",AINV_MPC],
        ["INV",INV_MPC],
        ["AbsoluteValue",ABS_MPC],
        ["ZERO",ZERO_MPC],
        ["ONE",ONE_MPC],
        ["Sqrt",SQRT_MPC],
        ["Sin",SIN_MPC],
        ["Exp",EXP_MPC],
        ["Square",SQR_MPC],
        ["RealPart",REAL_MPC],
        ["ImaginaryPart",IMAG_MPC],
        ["Norm",NORM_MPC],
        ["PrecisionFloat",PREC_MPC]] do
    InstallOtherMethod(VALUE_GLOBAL(__i[1]), "float", [IsMPCFloat], __i[2]);
od;
Unbind(__i);

################################################################
# binary operations
################################################################
for __i in ["SUM","DIFF","QUO","PROD","LQUO","EQ","LT"] do
    InstallMethod(VALUE_GLOBAL(__i), "float",
            [IsMPCFloat, IsMPCFloat], VALUE_GLOBAL(Concatenation(__i,"_MPC")));
od;
Unbind(__i);

InstallMethod(SUM, "float, scalar", [IsMPCFloat,IsScalar],
        function(x,y) return SUM(x,MPCFloat(y)); end);
InstallMethod(SUM, "scalar, float", [IsScalar,IsMPCFloat],
        function(x,y) return SUM(MPCFloat(x),y); end);
InstallMethod(DIFF, "float, scalar", [IsMPCFloat,IsScalar],
        function(x,y) return DIFF(x,MPCFloat(y)); end);
InstallMethod(DIFF, "scalar, float", [IsScalar,IsMPCFloat],
        function(x,y) return DIFF(MPCFloat(x),y); end);
InstallMethod(PROD, "float, scalar", [IsMPCFloat,IsScalar],
        function(x,y) return PROD(x,MPCFloat(y)); end);
InstallMethod(PROD, "scalar, float", [IsScalar,IsMPCFloat],
        function(x,y) return PROD(MPCFloat(x),y); end);
InstallMethod(QUO, "float, scalar", [IsMPCFloat,IsScalar],
        function(x,y) return QUO(x,MPCFloat(y)); end);
InstallMethod(QUO, "scalar, float", [IsScalar,IsMPCFloat],
        function(x,y) return QUO(MPCFloat(x),y); end);
InstallMethod(POW, "float, scalar", [IsMPCFloat,IsScalar],
        function(x,y) return POW(x,MPCFloat(y)); end);
InstallMethod(POW, "scalar, float", [IsScalar,IsMPCFloat],
        function(x,y) return POW(MPCFloat(x),y); end);
InstallMethod(LQUO, "float, scalar", [IsMPCFloat,IsScalar],
        function(x,y) return LQUO(x,MPCFloat(y)); end);
InstallMethod(LQUO, "scalar, float", [IsScalar,IsMPCFloat],
        function(x,y) return LQUO(MPCFloat(x),y); end);
InstallMethod(MOD, "float, scalar", [IsMPCFloat,IsScalar],
        function(x,y) return MOD(x,MPCFloat(y)); end);
InstallMethod(MOD, "scalar, float", [IsScalar,IsMPCFloat],
        function(x,y) return MOD(MPCFloat(x),y); end);
InstallMethod(EQ, "float, scalar", [IsMPCFloat,IsScalar],
        function(x,y) return EQ(x,MPCFloat(y)); end);
InstallMethod(EQ, "scalar, float", [IsScalar,IsMPCFloat],
        function(x,y) return EQ(MPCFloat(x),y); end);
InstallMethod(LT, "float, scalar", [IsMPCFloat,IsScalar],
        function(x,y) return LT(x,MPCFloat(y)); end);
InstallMethod(LT, "scalar, float", [IsScalar,IsMPCFloat],
        function(x,y) return LT(MPCFloat(x),y); end);
        
################################################################
# constructor
################################################################
InstallMethod(MPCFloat, "for integers", [IsInt],
        function(int)
    if IsInt(ValueOption("PrecisionFloat")) then
        return MPC_INTPREC(int,ValueOption("PrecisionFloat"));
    else
        return MPC_INT(int);
    fi;
end);
InstallMethod(MPCFloat, "for rationals", [IsRat],
        function(rat)
    local n, d, prec;
    n := NumeratorRat(rat);
    d := DenominatorRat(rat);
    if IsInt(ValueOption("PrecisionFloat")) then
        prec := ValueOption("PrecisionFloat");
    elif n=0 then
        return MPC.0;
    else
        prec := Maximum(64,2+LogInt(AbsInt(n),2),2+LogInt(d,2));
    fi;
    return MPC_INTPREC(n,prec)/MPC_INTPREC(d,prec);
end);
InstallMethod(MPCFloat, "for lists", [IsList],
        l->List(l,MPCFloat));
InstallMethod(MPCFloat, "for macfloats", [IsFloat], #!!!
        x->MPCFloat(String(x)));
InstallMethod(MPCFloat, "for strings", [IsString],
        function(s)
    if IsInt(ValueOption("PrecisionFloat")) then
        return MPC_STRING(s,ValueOption("PrecisionFloat"));
    else
        return MPC_STRING(s,Maximum(64,Int(Length(s)*100000/30103)));
    fi;
end);
InstallMethod(MPCFloat, "for float", [IsMPCFloat],
        function(obj)
    if IsInt(ValueOption("PrecisionFloat")) then
        return MPC_MPCPREC(obj,ValueOption("PrecisionFloat"));
    else
        return obj;
    fi;
end);

#############################################################################
##
#E
