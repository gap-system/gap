#############################################################################
##
#W  ieee754.g                         GAP library                Steve Linton
##                                                                Stefan Kohl
##                                                          Laurent Bartholdi
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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

#############################################################################
##
#M  String( x ) . . . . . . . . . . . . . . . . . . . . . . . .  for macfloats
##
BindGlobal("MACFLOAT_STRING_DOTTIFY", function(s)
    local p;
    if '.' in s or Intersection(s,"0123456789")=[] then return s; fi;
    for p in [1..Length(s)] do
        if not s[p] in "+-0123456789" then p := p-1; break; fi;
    od;
    Add(s,'.',p+1);
    return s;
end);    

InstallMethod( String, "for macfloats", [ IsIEEE754FloatRep ],
        f->MACFLOAT_STRING_DOTTIFY(STRING_DIGITS_MACFLOAT(FLOAT.DECIMAL_DIG,f)));

InstallMethod( ViewString, "for macfloats", [ IsIEEE754FloatRep ],
        f->MACFLOAT_STRING_DOTTIFY(STRING_DIGITS_MACFLOAT(FLOAT.VIEW_DIG,f)));

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
InstallMethod( Acos, "for macfloats", [ IsIEEE754FloatRep ], ACOS_MACFLOAT );
InstallMethod( Asin, "for macfloats", [ IsIEEE754FloatRep ], ASIN_MACFLOAT );
InstallMethod( Atan, "for macfloats", [ IsIEEE754FloatRep ], ATAN_MACFLOAT );
InstallMethod( Atan2, "for macfloats", [ IsIEEE754FloatRep, IsIEEE754FloatRep ], ATAN2_MACFLOAT );
InstallMethod( Log, "for macfloats", [ IsIEEE754FloatRep ], LOG_MACFLOAT );
InstallMethod( Exp, "for macfloats", [ IsIEEE754FloatRep ], EXP_MACFLOAT );
if IsBound(LOG2_MACFLOAT) then
    InstallMethod( Log2, "for macfloats", [ IsIEEE754FloatRep ], LOG2_MACFLOAT );
fi;
if IsBound(LOG10_MACFLOAT) then
    InstallMethod( Log10, "for macfloats", [ IsIEEE754FloatRep ], LOG10_MACFLOAT );
fi;
if IsBound(LOG1P_MACFLOAT) then
    InstallMethod( Log1p, "for macfloats", [ IsIEEE754FloatRep ], LOG1P_MACFLOAT );
fi;
if IsBound(EXP2_MACFLOAT) then
    InstallMethod( Exp2, "for macfloats", [ IsIEEE754FloatRep ], EXP2_MACFLOAT );
fi;
if IsBound(EXPM1_MACFLOAT) then
    InstallMethod( Expm1, "for macfloats", [ IsIEEE754FloatRep ], EXPM1_MACFLOAT );
fi;
if IsBound(EXP10_MACFLOAT) then
    InstallMethod( Exp10, "for macfloats", [ IsIEEE754FloatRep ], EXP10_MACFLOAT );
fi;    

InstallMethod( Sqrt, "for macfloats", [ IsIEEE754FloatRep ], SQRT_MACFLOAT );
InstallMethod( Round, "for macfloats", [ IsIEEE754FloatRep ], RINT_MACFLOAT );
InstallMethod( Floor, "for macfloats", [ IsIEEE754FloatRep ], FLOOR_MACFLOAT );
InstallMethod( Ceil, "for macfloats", [ IsIEEE754FloatRep ], CEIL_MACFLOAT );
InstallMethod( AbsoluteValue, "for macfloats", [ IsIEEE754FloatRep ], ABS_MACFLOAT );
InstallMethod( Hypothenuse, "for macfloats", [ IsIEEE754FloatRep, IsIEEE754FloatRep ], HYPOT_MACFLOAT );
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

MakeReadOnly( IEEE754FLOAT );

# finally install the default floateans
INSTALLFLOATCONSTRUCTORS(IEEE754FLOAT);
SetFloats(IEEE754FLOAT);

#############################################################################
##
#E
