#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton, Stefan Kohl, Laurent Bartholdi.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file deals with macfloats
##

#############################################################################
##
#M  Constructors . . . . . . . . . . . . . . . . . . . . . . . . for integers
##
INSTALLFLOATCREATOR("for IsIEEE754FloatRep and integer",
        [ IsIEEE754FloatRep, IsInt ],
        function ( filter, n )

    local  x, b, pow, sgn;

    if n < 0 then n := -n; sgn := -1; else sgn := 1; fi;
    x := MACFLOAT_INT(0);
    b := MACFLOAT_INT(65536); pow := MACFLOAT_INT(1);
    while n > 0 do
        x   := x + pow * MACFLOAT_INT(n mod 65536);
        n   := QUO_INT(n,65536);
        pow := pow * b;
    od;
    return MACFLOAT_INT(sgn) * x;
end);

#############################################################################
##
#M  Constructor. . . . . . . . . . . . . . . . . . . . . . . . .  for strings
##
INSTALLFLOATCREATOR("for IsIEEE754FloatRep and string",
        [ IsIEEE754FloatRep, IsString ],
        function ( filter, s )
    return MACFLOAT_STRING(s);
end);

InstallMethod( String, "for macfloats", [ IsIEEE754FloatRep ],
        f->STRING_DIGITS_MACFLOAT(FLOAT.DECIMAL_DIG,f));

InstallMethod( ViewString, "for macfloats", [ IsIEEE754FloatRep ],
        f->STRING_DIGITS_MACFLOAT(FLOAT.VIEW_DIG,f));

#############################################################################
##
#M  Int( x ) . . . . . . . . . . . . . . . . . . . . . . . . . . . for macfloats
##
InstallMethod( Int, "for macfloats", true, [ IsIEEE754FloatRep ], 0, INTFLOOR_MACFLOAT );

#############################################################################
##
#M  Sqrt, etc. for macfloats
##
InstallMethod( Sin, "for macfloats", [ IsIEEE754FloatRep ], SIN_MACFLOAT );
InstallMethod( Cos, "for macfloats", [ IsIEEE754FloatRep ], COS_MACFLOAT );
InstallMethod( Tan, "for macfloats", [ IsIEEE754FloatRep ], TAN_MACFLOAT );
InstallMethod( Asin, "for macfloats", [ IsIEEE754FloatRep ], ASIN_MACFLOAT );
InstallMethod( Acos, "for macfloats", [ IsIEEE754FloatRep ], ACOS_MACFLOAT );
InstallMethod( Atan, "for macfloats", [ IsIEEE754FloatRep ], ATAN_MACFLOAT );

InstallMethod( Sinh, "for macfloats", [ IsIEEE754FloatRep ], SINH_MACFLOAT );
InstallMethod( Cosh, "for macfloats", [ IsIEEE754FloatRep ], COSH_MACFLOAT );
InstallMethod( Tanh, "for macfloats", [ IsIEEE754FloatRep ], TANH_MACFLOAT );
InstallMethod( Asinh, "for macfloats", [ IsIEEE754FloatRep ], ASINH_MACFLOAT );
InstallMethod( Acosh, "for macfloats", [ IsIEEE754FloatRep ], ACOSH_MACFLOAT );
InstallMethod( Atanh, "for macfloats", [ IsIEEE754FloatRep ], ATANH_MACFLOAT );

InstallMethod( Log, "for macfloats", [ IsIEEE754FloatRep ], LOG_MACFLOAT );
InstallMethod( Log2, "for macfloats", [ IsIEEE754FloatRep ], LOG2_MACFLOAT );
InstallMethod( Log10, "for macfloats", [ IsIEEE754FloatRep ], LOG10_MACFLOAT );
InstallMethod( Log1p, "for macfloats", [ IsIEEE754FloatRep ], LOG1P_MACFLOAT );

InstallMethod( Exp, "for macfloats", [ IsIEEE754FloatRep ], EXP_MACFLOAT );
InstallMethod( Exp2, "for macfloats", [ IsIEEE754FloatRep ], EXP2_MACFLOAT );
InstallMethod( Expm1, "for macfloats", [ IsIEEE754FloatRep ], EXPM1_MACFLOAT );
if IsBound(EXP10_MACFLOAT) then
    InstallMethod( Exp10, "for macfloats", [ IsIEEE754FloatRep ], EXP10_MACFLOAT );
fi;

InstallMethod( Sqrt, "for macfloats", [ IsIEEE754FloatRep ], SQRT_MACFLOAT );
InstallMethod( CubeRoot, "for macfloats", [ IsIEEE754FloatRep ], CBRT_MACFLOAT );

InstallMethod( Atan2, "for macfloats", [ IsIEEE754FloatRep, IsIEEE754FloatRep ], ATAN2_MACFLOAT );
InstallMethod( Hypothenuse, "for macfloats", [ IsIEEE754FloatRep, IsIEEE754FloatRep ], HYPOT_MACFLOAT );

InstallMethod( Erf, "for macfloats", [ IsIEEE754FloatRep ], ERF_MACFLOAT );
InstallMethod( Gamma, "for macfloats", [ IsIEEE754FloatRep ], GAMMA_MACFLOAT );

InstallMethod( Round, "for macfloats", [ IsIEEE754FloatRep ], RINT_MACFLOAT );
InstallMethod( Floor, "for macfloats", [ IsIEEE754FloatRep ], FLOOR_MACFLOAT );
InstallMethod( Ceil, "for macfloats", [ IsIEEE754FloatRep ], CEIL_MACFLOAT );
InstallMethod( AbsoluteValue, "for macfloats", [ IsIEEE754FloatRep ], ABS_MACFLOAT );
InstallMethod( SignFloat, "for macfloats", [ IsIEEE754FloatRep ], SIGN_MACFLOAT );
InstallMethod( SignBit, "for macfloats", [ IsIEEE754FloatRep ], SIGNBIT_MACFLOAT );
InstallMethod( LdExp, "for macfloat,int", [ IsIEEE754FloatRep, IsInt ], LDEXP_MACFLOAT );
InstallMethod( FrExp, "for macfloat", [ IsIEEE754FloatRep ], FREXP_MACFLOAT );
InstallMethod( EqFloat, "for macfloats", [ IsIEEE754FloatRep, IsIEEE754FloatRep ], EQ_MACFLOAT );
InstallMethod( Zero, "for macfloats", [ IsIEEE754FloatRep ], x->MACFLOAT_INT(0));
InstallMethod( One, "for macfloats", [ IsIEEE754FloatRep ], x->MACFLOAT_INT(1));
InstallMethod( RealPart, "for macfloats", [ IsIEEE754FloatRep ], x->x);
InstallMethod( ImaginaryPart, "for macfloats", [ IsIEEE754FloatRep ], Zero);
InstallMethod( ComplexConjugate, "for macfloats", [ IsIEEE754FloatRep ], x->x);

#############################################################################
# default constructor record

DeclareCategory("IsIEEE754PseudoField", IsFloatPseudoField);
BindGlobal("IEEE754_PSEUDOFIELD",
        Objectify(NewType(CollectionsFamily(IEEE754FloatsFamily),
                IsIEEE754PseudoField and IsAttributeStoringRep),rec()));
SetName(IEEE754_PSEUDOFIELD, "IEEE754_PSEUDOFIELD");

SetLeftActingDomain(IEEE754_PSEUDOFIELD,Rationals);
SetCharacteristic(IEEE754_PSEUDOFIELD,0);
SetDimension(IEEE754_PSEUDOFIELD,infinity);
SetSize(IEEE754_PSEUDOFIELD,infinity);
SetIsWholeFamily(IEEE754_PSEUDOFIELD,true);
SetZero(IEEE754_PSEUDOFIELD,MACFLOAT_INT(0));
SetOne(IEEE754_PSEUDOFIELD,MACFLOAT_INT(1));
InstallMethod( \in, [IsIEEE754FloatRep,IsIEEE754PseudoField], ReturnTrue);

BindGlobal("IEEE754FLOAT", rec(
    constants := rec(
        DIG := 15,
        VIEW_DIG := 6,
        MANT_DIG := 53,
        MAX_10_EXP := 308,
        MAX_EXP := 1024,
        MIN_10_EXP := -307,
        MIN_EXP := -1021,
        DECIMAL_DIG := 17,
        INFINITY := MACFLOAT_STRING("inf"),
        NINFINITY := MACFLOAT_STRING("-inf"),
        NAN := MACFLOAT_STRING("nan")),
    filter := IsIEEE754FloatRep,
    field := IEEE754_PSEUDOFIELD,
    creator := MACFLOAT_STRING,
    eager := 'l'));

SetIsUFDFamily(IEEE754FloatsFamily,true);
SetZero(IEEE754FloatsFamily, NewFloat(IsIEEE754FloatRep,0));
SetOne(IEEE754FloatsFamily, NewFloat(IsIEEE754FloatRep,0));

InstallMethod( PrecisionFloat, "for macfloats", [ IsIEEE754FloatRep ], x->IEEE754FLOAT.constants.MANT_DIG );

IEEE754FLOAT.constants.EPSILON := LDEXP_MACFLOAT(MACFLOAT_INT(1),1-IEEE754FLOAT.constants.MANT_DIG);
IEEE754FLOAT.constants.MAX := LDEXP_MACFLOAT(NewFloat(IsIEEE754FloatRep,2^IEEE754FLOAT.constants.MANT_DIG-1),IEEE754FLOAT.constants.MAX_EXP-IEEE754FLOAT.constants.MANT_DIG);
IEEE754FLOAT.constants.MIN := LDEXP_MACFLOAT(MACFLOAT_INT(1),IEEE754FLOAT.constants.MIN_EXP-1);

# finally install the default floateans
INSTALLFLOATCONSTRUCTORS(IEEE754FLOAT);
if IsHPCGAP then
    MakeReadOnlyObj( IEEE754FLOAT );
fi;

InstallMethod(NewFloat, [IsIEEE754FloatRep,IsRat], -1, function(filter,obj)
    local num, den, extra, N;
    num := NumeratorRat(obj);
    den := DenominatorRat(obj);
    extra := QuoInt(num, den);
    num := RemInt(num, den);
    N := Log2Int(den);
    # Avoid overflows in the conversion of numerator and denominator: if they
    # are too big, shift them down until they (barely) fit. This hardcodes
    # assumptions about the precision of IsIEEE754FloatRep. It also does not
    # try to minimize the numerical error of the computation, but it should be
    # at least reasonably close overall.
    if N >= 1023 then
        num := QuoInt(num, 2^(N-1022));
        den := QuoInt(den, 2^(N-1022));
    fi;
    return NewFloat(filter, extra) + NewFloat(filter, num) / NewFloat(filter, den);
end);

InstallMethod(MakeFloat, [IsIEEE754FloatRep,IsRat], -1, function(filter,obj)
    return NewFloat(IsIEEE754FloatRep, obj);
end);


SetFloats(IEEE754FLOAT);
