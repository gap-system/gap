#############################################################################
##
#W  float.g                        GAP library                   Steve Linton
##                                                                Stefan Kohl
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file deals with floats
##
Revision.float_g :=
  "@(#)$Id$";

BIND_GLOBAL( "FloatsFamily", 
        NewFamily( "FloatsFamily", IS_FLOAT ));

BIND_GLOBAL( "TYPE_FLOAT", 
        NewType(FloatsFamily, IS_FLOAT and IsInternalRep and IsScalar
                and IsCommutativeElement));

BIND_GLOBAL( "TYPE_FLOAT0", 
        NewType(FloatsFamily, IS_FLOAT and IsInternalRep and IsZero and IsScalar
                and IsCommutativeElement));

#############################################################################
##
#C  IsFloat . . . . . . . . . . . . . . . . . . . . . . . . . . . . . C float
##
DeclareSynonym( "IsFloat", IS_FLOAT );

#############################################################################
##
#A  AbsoluteValue( x ) . . . . . . . . . . . . . . . . . . . . . . for floats
##
DeclareAttribute( "AbsoluteValue", IsFloat );
InstallOtherMethod( AbsoluteValue,
                    "for floats", true, [ IsFloat ], 0,

  function ( x )
    if x < FLOAT_INT(0) then return -x; else return x; fi;
  end );

#############################################################################
##
#O  Float( x ) . . . . . . . . . . . . . . . . . floating point approximation
##
DeclareOperation( "Float", [ IsObject ] );

#############################################################################
##
#M  Float( n ) . . . . . . . . . . . . . . . . . . . . . . . . . for integers
##
InstallMethod( Float,
               "for integers", true, [ IsInt ], 0,

  function ( n )

    local  x, b, pow, sgn;

    if n < 0 then n := -n; sgn := -1; else sgn := 1; fi;
    x := FLOAT_INT(0);
    b := FLOAT_INT(65536); pow := FLOAT_INT(1);
    while n > 0 do
      x   := x + pow * FLOAT_INT(n mod 65536);
      n   := QUO_INT(n,65536);
      pow := pow * b;
    od;
    return FLOAT_INT(sgn) * x;
  end );

#############################################################################
##
#M  Float( x ) . . . . . . . . . . . . . . . . . . . . . . . .  for rationals
##
InstallMethod( Float,
               "for rationals", true, [ IsRat ], 0,
               x -> FLOAT_INT(NumeratorRat(x))/FLOAT_INT(DenominatorRat(x)));

#############################################################################
##
#M  Float( M ) . . . . . . . . . . . . . . . . . . . . . . . . . for matrices
##
InstallMethod( Float,
               "for matrices", true, [ IsMatrix ], 0,
               M -> List( M, l -> List( l, Float ) ) );

#############################################################################
##
#M  Int( x ) . . . . . . . . . . . . . . . . . . . . . . . . . . . for floats
##
InstallMethod( Int,
               "for floats", true, [ IsFloat ], 0,

  function ( x )

    local  n, pow2, sign;

    x := FLOOR_FLOAT(x);
    if x < 0 then x := -x; sign := -1; else sign := 1; fi;
    if x > 2^28-1   then return fail; fi;
    if x < Float(1) then return 0;    fi;
    pow2 := 2^26; n := 2^27;
    while Float(n) <> x do
      if Float(n) < x then n := n + pow2; else n := n - pow2; fi;
      pow2 := pow2 / 2;
    od;
    return n * sign;
  end );

#############################################################################
##
#M  Rat( x ) . . . . . . . . . . . . . . . . . . . . . . . . . . . for floats
##
InstallOtherMethod( Rat,
                    "for floats", true, [ IsFloat ], 0,

  function ( x )

    local  M, a_i, i, sign;

    i := 0; M := [[1,0],[0,1]];
    if x < 0 then sign := -1; x := -x; else sign := 1; fi;
    repeat
      a_i := Int(x); i := i + 1;
      M := M * [[a_i,1],[1,0]];
      if x - a_i > 1/10000 then x := 1/(x - a_i); else break; fi;
    until M[1][1] * FLOOR_FLOAT(x) > 10000;
    return sign * M[1][1]/M[2][1];
  end );

#############################################################################
##
#M  \<( x ) . . . . . . . . . . . . . . . . . . . . .  for rational and float
##
InstallMethod( \<,
               "for rational and float", ReturnTrue, [ IsRat, IsFloat ], 0,
               function ( x, y ) return Float(x) < y; end );

#############################################################################
##
#M  \<( x ) . . . . . . . . . . . . . . . . . . . . .  for float and rational
##
InstallMethod( \<,
               "for float and rational", ReturnTrue, [ IsFloat, IsRat ], 0,
               function ( x, y ) return x < Float(y); end );

#############################################################################
##
#M  \+( x ) . . . . . . . . . . . . . . . . . . . . .  for float and rational
##
InstallOtherMethod( \+,
                    "for float and rational", ReturnTrue, [ IsFloat, IsRat ],
                    0, function ( x, y ) return x + Float(y); end );

#############################################################################
##
#M  \+( x ) . . . . . . . . . . . . . . . . . . . . .  for rational and float
##
InstallOtherMethod( \+,
                    "for rational and float", ReturnTrue, [ IsRat, IsFloat ],
                    0, function ( x, y ) return Float(x) + y; end );

#############################################################################
##
#M  \*( x ) . . . . . . . . . . . . . . . . . . . . .  for float and rational
##
InstallOtherMethod( \*,
                    "for float and rational", ReturnTrue, [ IsFloat, IsRat ],
                    0, function ( x, y ) return x * Float(y); end );

#############################################################################
##
#M  \*( x ) . . . . . . . . . . . . . . . . . . . . .  for rational and float
##
InstallOtherMethod( \*,
                    "for rational and float", ReturnTrue, [ IsRat, IsFloat ],
                    0, function ( x, y ) return Float(x) * y; end );

#############################################################################
##
#E