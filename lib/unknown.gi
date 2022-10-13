#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This  file  implements the  arithmetic  for unknown values,  unknowns for
##  short.  Unknowns  are written as `Unknown(<n>)'  where  <n> is an integer
##  that distinguishes  different unknowns.  Every unknown stands for a fixed,
##  well defined, but unknown  scalar value,  i.e., an  unknown  integer,  an
##  unknown rational, or an unknown cyclotomic.
##
##  Being unknown is a contagious property.  That is  to say  that the result
##  of  a scalar operation involving an  unknown is   also  unknown, with the
##  exception of multiplication by 0,  which  is  0.  Every scalar  operation
##  involving an  unknown operand is  a  new  unknown, with  the exception of
##  addition of 0 or multiplication by 1, which is the old unknown.
##
##  Note that infinity is not regarded as a well defined scalar value.   Thus
##  an unknown never stands for infinity. Therefore division by 0 still gives
##  an  error, not an unknown.  Also  division by an  unknown gives an error,
##  because the unknown could stand for 0.
##


#############################################################################
##
#R  IsUnknownDefaultRep( <obj> )
##
DeclareRepresentation( "IsUnknownDefaultRep",
    IsPositionalObjectRep, [ 1 ] );


#############################################################################
##
#V  UnknownsType
##
BindGlobal( "UnknownsType", NewType( CyclotomicsFamily,
    IsUnknown and IsUnknownDefaultRep ) );


#############################################################################
##
#M  Unknown( <n> )  . . . . . . . . . . . . . . . . . .  construct an unknown
##
InstallMethod( Unknown,
    "for positive integer",
    [ IsPosInt ],
    function( n )
    if LargestUnknown < n then
      LargestUnknown:= n;
    fi;
    return Objectify( UnknownsType, [ n ] );
    end );


#############################################################################
##
#M  Unknown( )  . . . . . . . . . . . . . . . . . . . construct a new unknown
##
InstallMethod( Unknown,
    "for empty argument",
    [],
    function()
    LargestUnknown:= LargestUnknown + 1;
    return Objectify( UnknownsType, [ LargestUnknown ] );
    end );


#############################################################################
##
#M  PrintObj( <obj> ) . . . . . . . . . . . . . . . . . . .  print an unknown
##
##  prints the unknown <obj> in the form `Unknown(<n>)'.
##
InstallMethod( PrintObj,
    "for unknown in default representation",
    [ IsUnknown and IsUnknownDefaultRep ],
    function( obj )
    Print( "Unknown(", obj![1], ")" );
    end );


#############################################################################
##
#M  `<x> = <y>' . . . . . . . . . . .  . . . . test if two unknowns are equal
##
##  is `true' if the two unknowns <x> and <y> are equal,
##  and `false' otherwise.
##
##  Note that two unknowns with different <n> are assumed to be different.
##  I dont like this at all.
##
InstallMethod( \=,
    "for unknown and cyclotomic",
    [ IsUnknown, IsCyc ],
    ReturnFalse );

InstallMethod( \=,
    "for cyclotomic and unknown",
    [ IsCyc, IsUnknown ],
    ReturnFalse );

InstallMethod( \=,
    "for two unknowns in default representation",
    [ IsUnknown and IsUnknownDefaultRep,
      IsUnknown and IsUnknownDefaultRep ],
    function( x, y ) return x![1] = y![1]; end );


#############################################################################
##
#M  `<x> \< <y>'  . . . . . . . . .  test if one unknown is less than another
##
##  is `true' if the unknown <x> is less than the unknown <y>,
##  and `false' otherwise.
##
##  Note that two unknowns with different <n> are assumed to be different.
##  I don't like this at all.
##
InstallMethod( \<,
    "for unknown and cyclotomic",
    [ IsUnknown, IsCyc ],
    ReturnFalse );

InstallMethod( \<,
    "for cyclotomic and unknown",
    [ IsCyc, IsUnknown ],
    ReturnTrue );

InstallMethod( \<,
    "for two unknowns in default representation",
    [ IsUnknown and IsUnknownDefaultRep,
      IsUnknown and IsUnknownDefaultRep ],
    function( x, y ) return x![1] < y![1]; end );


#############################################################################
##
#M  `<x> + <y>' . . . . . . . . . . . . . . . . . . . . . sum of two unknowns
##
##  is the sum of the two unknowns <x> and <y>.
##  Either operand may also be a known scalar value.
##
InstallMethod( \+,
    "for unknown and cyclotomic",
    [ IsUnknown, IsCyc ],
    function( x, y )
    if y = 0 then
      return x;
    else
      return Unknown();
    fi;
    end );

InstallMethod( \+,
    "for cyclotomic and unknown",
    [ IsCyc, IsUnknown ],
    function( x, y )
    if x = 0 then
      return y;
    else
      return Unknown();
    fi;
    end );

InstallMethod( \+,
    "for two unknowns",
    [ IsUnknown, IsUnknown ],
    function( x, y ) return Unknown(); end );


#############################################################################
##
#M  `- <x>' . . . . . . . . . . . . . . . . .  additive inverse of an unknown
#M  `<x> - <y>' . . . . . . . . . . . . . . . . .  difference of two unknowns
##
##  is the difference of the two unknowns <x> and <y>.
##  Either operand may also be a known scalar value.
##
InstallMethod( \-,
    "for unknown and cyclotomic",
    [ IsUnknown, IsCyc ],
    function( x, y )
    if y = 0 then
      return x;
    else
      return Unknown();
    fi;
    end );

InstallMethod( \-,
    "for cyclotomic and unknown",
    [ IsCyc, IsUnknown ],
    function( x, y )
    return Unknown();
    end );

InstallMethod( \-,
    "for two unknowns in default representation",
    [ IsUnknown and IsUnknownDefaultRep,
      IsUnknown and IsUnknownDefaultRep ],
    function( x, y )
    if x![1] = y![1] then
      return 0;
    else
      return Unknown();
    fi;
    end );

InstallMethod( AINV_MUT,
    "for an unknown",
    [ IsUnknown ],
    x -> Unknown() );


#############################################################################
##
#M  `<x> \* <y>'  . . . . . . . . . . . . . . . . . . product of two unknowns
##
##  is the product of the two unknowns <x> and <y>.
##  Either operand may also be a known scalar value.
##
InstallMethod( \*,
    "for unknown and cyclotomic",
    [ IsUnknown, IsCyc ],
    function( x, y )
    if y = 0 then
      return 0;
    elif y = 1 then
      return x;
    else
      return Unknown();
    fi;
    end );

InstallMethod( \*,
    "for cyclotomic and unknown",
    [ IsCyc, IsUnknown ],
    function( x, y )
    if x = 0 then
      return 0;
    elif x = 1 then
      return y;
    else
      return Unknown();
    fi;
    end );

InstallMethod( \*,
    "for two unknowns",
    [ IsUnknown, IsUnknown ],
    function( x, y )
    return Unknown();
    end );


#############################################################################
##
#M  `<x> / <y>' . . . . . . . . . . . . . . . . . .  quotient of two unknowns
##
##  is the quotient of the unknown <x> and the scalar <y>.
##  <y> must not be zero, and must not be an unknown,
##  because the unknown could stand for zero.
##
InstallMethod( \/,
    "for unknown and cyclotomic",
    [ IsUnknown, IsCyc ],
    function( x, y )
    if y = 0 then
      Error( "divisor must be nonzero" );
    elif y = 1 then
      return x;
    else
      return Unknown();
    fi;
    end );


#############################################################################
##
#M  `<x> \^ <y>'  . . . . . . . . . . . . . . . . . . . . power of an unknown
##
##  is the unknown <x> raised to the integer power <y>.
##  If <y> is 0, the result is the integer 1.
##  <y> must not be less than 0, because <x> could stand for 0.
##
InstallMethod( \^,
    "for unknown and positive integer",
    [ IsUnknown, IsPosInt ],
    function( x, y )
    if y = 1 then
      return x;
    else
      return Unknown();
    fi;
    end );

InstallMethod( \^,
    "for unknown and zero",
    [ IsUnknown, IsZeroCyc ],
    function( x, zero )
    return 1;
    end );


#############################################################################
##
#M  String( <unknown> ) . . . . . . . . . . . . . . . . . . .  for an unknown
##
InstallMethod( String,
    "for an unknown in default representation",
    [ IsUnknown and IsUnknownDefaultRep ],
    unknown -> Concatenation( "Unknown(", String( unknown![1] ), ")" ) );
