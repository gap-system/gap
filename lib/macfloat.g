#############################################################################
##
#W  macfloat.g                        GAP library                Steve Linton
##                                                                Stefan Kohl
##                                                          Laurent Bartholdi
##
#H  @(#)$Id: macfloat.g,v 4.10 2011/06/20 21:55:24 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file deals with macfloats 
##
Revision.macfloat_g :=

  "@(#)$Id: macfloat.g,v 4.10 2011/06/20 21:55:24 gap Exp $";



#############################################################################
DeclareRepresentation("IsIEEE754FloatRep", IsFloat and IsInternalRep and IS_MACFLOAT,[]);

BIND_GLOBAL( "TYPE_MACFLOAT", NewType(FloatsFamily, IsIEEE754FloatRep));

BIND_GLOBAL( "TYPE_MACFLOAT0", NewType(FloatsFamily, IsIEEE754FloatRep and IsZero));

#############################################################################
##
#M  Constructors . . . . . . . . . . . . . . . . . . . . . . . . for integers
##
InstallMethod( NewFloat, "for IsIEEE754FloatRep and integer",
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
InstallMethod( NewFloat, "for IsIEEE754FloatRep and string",
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
InstallMethod( Sqrt, "for macfloats", [ IsIEEE754FloatRep ], SQRT_MACFLOAT );
InstallMethod( Round, "for macfloats", [ IsIEEE754FloatRep ], RINT_MACFLOAT );
InstallMethod( Floor, "for macfloats", [ IsIEEE754FloatRep ], FLOOR_MACFLOAT );
InstallMethod( LdExp, "for macfloat,int", [ IsIEEE754FloatRep, IsInt ], LDEXP_MACFLOAT );
InstallMethod( FrExp, "for macfloat", [ IsIEEE754FloatRep ], FREXP_MACFLOAT );

#############################################################################
# constants
BindGlobal("IEEE754FLOAT_CONSTANTS", rec(
        DIG := 15,
        VIEW_DIG := 6,
        MANT_DIG := 53,
        EPSILON := LDEXP_MACFLOAT(MACFLOAT_INT(1),1-~.MANT_DIG),
        MAX_10_EXP := 308,
        MAX_EXP := 1024,
        MAX := LDEXP_MACFLOAT(NewFloat(IsIEEE754FloatRep,2^~.MANT_DIG-1),~.MAX_EXP-~.MANT_DIG),
        MIN_10_EXP := -307,
        MIN_EXP := -1021,
        MIN := LDEXP_MACFLOAT(MACFLOAT_INT(1),~.MIN_EXP-1),
        DECIMAL_DIG := 17,
        INFINITY := MACFLOAT_STRING("inf"),
        NINFINITY := MACFLOAT_STRING("-inf"),
        NAN := MACFLOAT_STRING("nan")));
        
#############################################################################
# default constructor record
BindGlobal("IEEE754FLOAT", rec(
        constants := IEEE754FLOAT_CONSTANTS,
        filter := IsIEEE754FloatRep,
        creator := MACFLOAT_STRING,
        eager := 'l') );

#############################################################################
##
#E
