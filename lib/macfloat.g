#############################################################################
##
#W  macfloat.g                        GAP library                   Steve Linton
##                                                                Stefan Kohl
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file deals with macfloats
##
Revision.macfloat_g :=
  "@(#)$Id$";

BIND_GLOBAL( "MacFloatsFamily", 
        NewFamily( "MacFloatsFamily", IS_MACFLOAT ));

BIND_GLOBAL( "TYPE_MACFLOAT", 
        NewType(MacFloatsFamily, IS_MACFLOAT and IsInternalRep and IsScalar
                and IsCommutativeElement));

BIND_GLOBAL( "TYPE_MACFLOAT0", 
        NewType(MacFloatsFamily, IS_MACFLOAT and IsInternalRep and IsZero and IsScalar
                and IsCommutativeElement));

#############################################################################
##
#C  IsMacFloat . . . . . . . . . . . . . . . . . . . . . . . . . . . . . C macfloat
##
DeclareSynonym( "IsMacFloat", IS_MACFLOAT );

#############################################################################
##
#A  AbsoluteValue( x ) . . . . . . . . . . . . . . . . . . . . . . for macfloats
##
DeclareAttribute( "AbsoluteValue", IsMacFloat );
InstallOtherMethod( AbsoluteValue,
                    "for macfloats", true, [ IsMacFloat ], 0,

  function ( x )
    if x < MACFLOAT_INT(0) then return -x; else return x; fi;
  end );

#############################################################################
##
#O  MacFloat( x ) . . . . . . . . . . . . . . . . . macfloating point approximation
##
DeclareOperation( "MacFloat", [ IsObject ] );

#############################################################################
##
#M  MacFloat( n ) . . . . . . . . . . . . . . . . . . . . . . . . . for integers
##
InstallMethod( MacFloat,
               "for integers", true, [ IsInt ], 0,

  function ( n )

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
  end );

#############################################################################
##
#M  MacFloat( x ) . . . . . . . . . . . . . . . . . . . . . . . .  for rationals
##
InstallMethod( MacFloat,
               "for rationals", true, [ IsRat ], 0,
               x -> MacFloat(NumeratorRat(x))/MacFloat(DenominatorRat(x)));

#############################################################################
##
#M  MacFloat( M ) . . . . . . . . . . . . . . . . . . . . . . . . . for matrices
##
InstallMethod( MacFloat,
               "for matrices", true, [ IsMatrix ], 0,
               M -> List( M, l -> List( l, MacFloat ) ) );

#############################################################################
##
#M  MacFloat( x ) . . . . . . . . . . . . . . . . . . . . . . . .  for macfloats
##
InstallMethod( MacFloat, "for macfloats", true, [ IsMacFloat ], 0, IdFunc );

#############################################################################
##
#M  MacFloat( x ) . . . . . . . . . . . . . . . . . . . . . . . .  for strings
##
InstallMethod( MacFloat, "for strings", true, [ IsString ], 0, MACFLOAT_STRING );

#############################################################################
##
#M  String( x ) . . . . . . . . . . . . . . . . . . . . . . . .  for macfloats
##
InstallMethod( String, "for macfloats", true, [ IsMacFloat ], 0, STRING_MACFLOAT );

InstallMethod( ViewObj, "for macfloats", true, [ IsMacFloat ], 0, function(f)
    Print(STRING_DIGITS_MACFLOAT(6,f));
end);

#############################################################################
##
#M  Int( x ) . . . . . . . . . . . . . . . . . . . . . . . . . . . for macfloats
##
InstallMethod( Int, "for macfloats", true, [ IsMacFloat ], 0, INTFLOOR_MACFLOAT );

#############################################################################
##
#M  Rat( x ) . . . . . . . . . . . . . . . . . . . . . . . . . . . for macfloats
##
InstallOtherMethod( Rat,
                    "for macfloats", true, [ IsMacFloat ], 0,

  function ( x )

    local  M, a_i, i, sign;

    i := 0; M := [[1,0],[0,1]];
    if x < 0 then sign := -1; x := -x; else sign := 1; fi;
    repeat
      a_i := Int(x); i := i + 1;
      M := M * [[a_i,1],[1,0]];
      if x - a_i > 1/10000 then x := 1/(x - a_i); else break; fi;
    until M[1][1] * FLOOR_MACFLOAT(x) > 10000;
    return sign * M[1][1]/M[2][1];
  end );

#############################################################################
##
#M  \<( x ) . . . . . . . . . . . . . . . . . . . . .  for rational and macfloat
##
InstallMethod( \<,
               "for rational and macfloat", ReturnTrue, [ IsRat, IsMacFloat ], 0,
               function ( x, y ) return MacFloat(x) < y; end );

#############################################################################
##
#M  \<( x ) . . . . . . . . . . . . . . . . . . . . .  for macfloat and rational
##
InstallMethod( \<,
               "for macfloat and rational", ReturnTrue, [ IsMacFloat, IsRat ], 0,
               function ( x, y ) return x < MacFloat(y); end );

#############################################################################
##
#M  \+( x ) . . . . . . . . . . . . . . . . . . . . .  for macfloat and rational
##
InstallOtherMethod( \+,
                    "for macfloat and rational", ReturnTrue, [ IsMacFloat, IsRat ],
                    0, function ( x, y ) return x + MacFloat(y); end );

#############################################################################
##
#M  \+( x ) . . . . . . . . . . . . . . . . . . . . .  for rational and macfloat
##
InstallOtherMethod( \+,
                    "for rational and macfloat", ReturnTrue, [ IsRat, IsMacFloat ],
                    0, function ( x, y ) return MacFloat(x) + y; end );

#############################################################################
##
#M  \*( x ) . . . . . . . . . . . . . . . . . . . . .  for macfloat and rational
##
InstallOtherMethod( \*,
                    "for macfloat and rational", ReturnTrue, [ IsMacFloat, IsRat ],
                    0, function ( x, y ) return x * MacFloat(y); end );

#############################################################################
##
#M  \*( x ) . . . . . . . . . . . . . . . . . . . . .  for rational and macfloat
##
InstallOtherMethod( \*,
                    "for rational and macfloat", ReturnTrue, [ IsRat, IsMacFloat ],
                    0, function ( x, y ) return MacFloat(x) * y; end );

#############################################################################
##
#M  \^( x ) . . . . . . . . . . . . . . . . . . . . .  for macfloat and rational
##
InstallOtherMethod( \^,
                    "for macfloat and rational", ReturnTrue, [ IsMacFloat, IsRat ],
                    3, function ( x, y ) return x ^ MacFloat(y); end );

#############################################################################
##
#M  \^( x ) . . . . . . . . . . . . . . . . . . . . .  for rational and macfloat
##
InstallOtherMethod( \^,
                    "for rational and macfloat", ReturnTrue, [ IsRat, IsMacFloat ],
                    0, function ( x, y ) return MacFloat(x) ^ y; end );

#############################################################################
##
#M  Sqrt( x ) . . . . . . . . . . . . . . . . . . . . . . . . . .  for macfloats
##
InstallOtherMethod( Sqrt, "for macfloats", true, [ IsMacFloat ], 0, SQRT_MACFLOAT );

#############################################################################
##
## Temporary synonyms for backwards compatibility
DeclareSynonym( "IsFloat", IsMacFloat );
DeclareSynonym( "Float", MacFloat );

#############################################################################
##
#E