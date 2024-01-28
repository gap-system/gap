#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##
##  This file contains generic methods for nonassociative words.
##


#############################################################################
##
#M  \=( <w1>, <w2> )  . . . . . . . . . . . . . . . . . . . . . . . for words
##
InstallMethod( \=,
    "for two words",
    IsIdenticalObj,
    [ IsWord, IsWord ], 0,
    function( x, y )
    return ExtRepOfObj( x ) = ExtRepOfObj( y );
    end );


#############################################################################
##
#M  \<( <w1>, <w2> )  . . . . . . . . . . . . . . . . . . . . . . . for words
##
##  Words are ordered by the lexicographical order of their external
##  representation.
##
InstallMethod( \<,
    "nonassoc words",
    IsIdenticalObj,
    [ IsWord, IsWord ], 0,
    function( x, y )
    local n;

    # this method does not work for assoc words!
    if IsAssocWord(x) and IsAssocWord(y) then
      TryNextMethod();
    fi;

    x:= ExtRepOfObj( x );
    y:= ExtRepOfObj( y );
    if IsInt( x ) then
      return IsList( y ) or x < y;
    elif IsInt( y ) then
      return false;
    fi;
    for n in [ 1 .. Minimum( Length( x ), Length( y ) ) ] do
      if x[n] < y[n] then
        return true;
      elif y[n] < x[n] then
        return false;
      fi;
    od;
    return Length( x ) < Length( y );
    end );


#############################################################################
##
#M  \*( <w1>, <w2> )  . . . . . . . . . . . . . . .  for nonassociative words
##
##  Multiplication of nonassociative words is done by putting the two factors
##  into a bracket.
##
InstallMethod( \*,
    "for two nonassoc. words",
    IsIdenticalObj,
    [ IsNonassocWord, IsNonassocWord ], 0,
    function( x, y )

    local xx,    # external representation of `x'
          yy;    # external representation of `y'

    # Treat the special cases that one argument is trivial.
    xx:= ExtRepOfObj( x );
    if xx = 0 then
      return y;
    fi;
    yy:= ExtRepOfObj( y );
    if yy = 0 then
      return x;
    fi;

    # Form the product.
    return ObjByExtRep( FamilyObj( x ), [ xx, yy ] );
    end );


#############################################################################
##
#M  Length( <w> ) . . . . . . . . . . . . . . . . . . .  for a nonassoc. word
##
InstallOtherMethod( Length,
    "for a nonassoc. word",
    true,
    [ IsNonassocWord ], 0,
    function( w )
    local len;
    len:= function( obj )
      if obj = 0 then
        return 0;
      elif IsInt( obj ) then
        return 1;
      else
        return len( obj[1] ) + len( obj[2] );
      fi;
    end;
    return len( ExtRepOfObj( w ) );
    end );


#############################################################################
##
#M  MappedWord( <x>, <gens1>, <gens2> )
##
InstallMethod( MappedWord,
    "for a nonassoc. word, a homogeneous list, and a list",
    IsElmsCollsX,
    [ IsNonassocWord, IsNonassocWordCollection, IsList ], 0,
    function( x, gens1, gens2 )

    local mapped;

    gens1:= List( gens1, ExtRepOfObj );
    mapped:= function( word )
      if word = 0 then
        return One( gens2[1] );
      elif IsInt( word ) then
        return gens2[ Position( gens1, word ) ];
      else
        return mapped( word[1] ) * mapped( word[2] );
      fi;
    end;

    return mapped( ExtRepOfObj( x ) );
    end );

#############################################################################
##
#M  MappedWord( <x>, <empty>, <empty> )
##
InstallOtherMethod( MappedWord, "empty generators list", true,
    [ IsObject, IsEmpty, IsList ], 0,
ReturnFirst );

#############################################################################
##
#R  IsBracketRep( <obj> )
##
##  This representation is equal to the external representation.
##
if IsHPCGAP then
DeclareRepresentation( "IsBracketRep", IsAtomicPositionalObjectRep, [] );
else
DeclareRepresentation( "IsBracketRep", IsPositionalObjectRep, [] );
fi;

#############################################################################
##
#M  Print( <w> )  . . . . . . . . . . . . . . . . . . .  for a nonassoc. word
##
InstallMethod( PrintObj,
    "for a nonassociative word",
    true,
    [ IsNonassocWord ], 0,
    function( elm )

    local names,
          print;

    names:= FamilyObj( elm )!.names;
    print:= function( expr )
      if expr = 0 then
        Print( "<identity ...>" );
      elif IsInt( expr ) then
        Print( names[ expr ] );
      else
        Print( "(" );
        print( expr[1] );
        Print( "*" );
        print( expr[2] );
        Print( ")" );
      fi;
    end;
    print( ExtRepOfObj( elm ) );
    end );


#############################################################################
##
#M  String( <w> ) . . . . . . . . . . . . . . . . . . .  for a nonassoc. word
##
InstallMethod( String,
    "for a nonassociative word",
    true,
    [ IsNonassocWord ], 0,
    function( elm )

    local names,
          string;

    names:= FamilyObj( elm )!.names;
    string:= function( expr )
      if expr = 0 then
        return "<identity ...>" ;
      elif IsInt( expr ) then
        return names[ expr ];
      else
        return Concatenation( "(", string( expr[1] ), "*",
                              string( expr[2] ), ")" );
      fi;
    end;
    elm:= string( ExtRepOfObj( elm ) );
    ConvertToStringRep( elm );
    return elm;
    end );


#############################################################################
##
#M  ObjByExtRep( <F>, <descr> ) . . . . . .  for a nonassociative word family
##
##  We have to distinguish the cases that the second argument is an integer
##  (external representation of generators) and that it is a nested list of
##  integers.
##
InstallMethod( ObjByExtRep,
    "for a family of nonassociative words, and an integer",
    true,
    [ IsNonassocWordFamily, IsInt ], 0,
    function( F, pos )
    return Objectify( F!.defaultType, [ pos ] );
    end );

InstallMethod( ObjByExtRep,
    "for a family of nonassociative words, and a list",
    true,
    [ IsNonassocWordFamily, IsList ], 0,
    function( F, list )
    return Objectify( F!.defaultType, [ list ] );
    end );


#############################################################################
##
#M  ExtRepOfObj( <w> )  . . . . . . . . . . . . . . for a nonassociative word
##
InstallMethod( ExtRepOfObj,
    "for a nonassoc. word",
    true,
    [ IsNonassocWord and IsBracketRep ], 0,
    elm -> elm![1] );


#############################################################################
##
#M  OneOp( <w> )  . . . . . . . . . . . . . . . . for a nonass. word-with-one
##
InstallMethod( OneOp,
    "for a nonassoc. word-with-one",
    true,
    [ IsNonassocWordWithOne ], 0,
    x -> ObjByExtRep( FamilyObj( x ), 0 ) );
