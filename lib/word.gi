#############################################################################
##
#W  word.gi                     GAP library                     Thomas Breuer
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
#H  @(#)$Id$
##
##  This file contains generic methods for nonassociative words.
##
Revision.word_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  \=( <w1>, <w2> )  . . . . . . . . . . . . . . . . . . . . . . . for words
##
InstallMethod( \=,
    "method for two words",
    IsIdentical,
    [ IsWord, IsWord ], 0,
    function( x, y )
    return ExtRepOfObj( x ) = ExtRepOfObj( y );
    end );


#############################################################################
##
#M  \<( <w1>, <w2> )  . . . . . . . . . . . . . . . . . . . . . . . for words
##
##  Words  are ordered as  follows: a lexicographical   order in the external
##  representation is chosen.
##
InstallMethod( \<,
    "method for two words",
    IsIdentical,
    [ IsWord, IsWord ], 0,
    function( x, y )
    local n;

    x := ExtRepOfObj( x );
    y := ExtRepOfObj( y );
    if IsInt( x ) then
      return IsList( y ) or x < y;
    elif IsInt( y ) then
      return false;
    fi;
    for n  in [ 1 .. Minimum(Length(x),Length(y)) ]  do
        if x[n] < y[n]  then
            return true;
        elif y[n] < x[n]  then
            return false;
        fi;
    od;
    return Length(x) < Length(y);
    end );


#############################################################################
##
#M  \*( <w1>, <w2> )  . . . . . . . . . . . . . . .  for nonassociative words
##
##  Multiplication of nonassociative words is done by putting the two factors
##  into a bracket.
##
InstallMethod( \*,
    "method for two nonassoc. words",
    IsIdentical,
    [ IsNonassocWord, IsNonassocWord ], 0,
    function( x, y )

    local xx,    # external representation of 'x'
          l,     # current length of 'xx', minus 1
          yy,    # external representation of 'y'
          p,     # current first valid position in 'yy'
          len;   # total length of 'yy' minus 1

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
#M  \^( <w>, <n> )
##
#T  how is this defined?


#############################################################################
##
#M  LengthWord( <w> ) . . . . . . . . . . . . . . . . .  for a nonassoc. word
##
InstallMethod( LengthWord,
    "method for a nonassoc. word",
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
    "method for a nonassoc. word, a homogeneous list, and a list",
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
#R  IsBracketRep( <obj> )
##
##  This representation is equal to the external representation.
##
IsBracketRep := NewRepresentation( "IsBracketRep",
    IsPositionalObjectRep, [] );


#############################################################################
##
#M  Print( <w> )  . . . . . . . . . . . . . . . . . . .  for a nonassoc. word
##
InstallMethod( PrintObj,
    "method for a nonassociative word",
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
    "method for a nonassociative word",
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
InstallMethod( ObjByExtRep,
    "method for a family of nonassociative words, and a homogeneous list",
    true,
    [ IsNonassocWordFamily, IsObject ], 0,
    function( F, descr )
    return Objectify( F!.defaultType, [ descr ] );
    end );


#############################################################################
##
#M  ExtRepOfObj( <w> )  . . . . . . . . . . . . . . for a nonassociative word
##
InstallMethod( ExtRepOfObj,
    "method for a nonassoc. word",
    true,
    [ IsNonassocWord and IsBracketRep ], 0,
    elm -> elm![1] );


#############################################################################
##
#M  NonassocWord( <Fam>, <descr> )  . . . . . . . . for a nonass. word family
##
NonassocWord := ObjByExtRep;


#############################################################################
##
#M  One( <w> )  . . . . . . . . . . . . . . . . . for a nonass. word-with-one
##
InstallMethod( One,
    "method for a nonassoc. word-with-one",
    true,
    [ IsNonassocWordWithOne ], 0,
    x -> ObjByExtRep( FamilyObj( x )!.defaultType, 0 ) );


#############################################################################
##
#E  word.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



