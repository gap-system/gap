#############################################################################
##
#W  wordrep.gi                  GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This  file contains  methods for   associative words  that  depend on the
##  representation.
##
##  Currently,  there are four  representations for objects with the external
##  representation as list of generators  numbers and exponents (so not  only
##  for  associative  words but  perhaps  also for   elements  in a  finitely
##  presented group).
##
##  The   representations differ  w.r.t. the  space  needed   by the internal
##  representation:
##
##  the first three need 8, 16, 32 bits for each generator/exponent pair, and
##  the last  uses the list defined  by  the external representation  also as
##  internal data.
##
##  The    result of an arithmetic    operation  with  objects   of the  same
##  representation  will be also of that  representation if this is possible.
##  The  result  of  an  arithmetic   operation  with  objects  of  different
##  representations  will be the bigger  one of the two  if this is possible.
##  Otherwise 'ObjByExtRep' will choose the smallest possible representation.
##  In all cases the representation of the operands is *not* changed.
##
Revision.wordrep_gi :=
    "@(#)$Id$";


#############################################################################
##

#R  Is8BitsAssocWord( <obj> )
#R  Is16BitsAssocWord( <obj> )
#R  Is32BitsAssocWord( <obj> )
#R  IsInfBitsAssocWord( <obj> )
##
Is8BitsAssocWord := NewRepresentation(
    "Is8BitsAssocWord",
    IsAssocWord and IsDataObjectRep, [] );

Is16BitsAssocWord := NewRepresentation(
    "Is16BitsAssocWord",
    IsAssocWord and IsDataObjectRep, [] );

Is32BitsAssocWord := NewRepresentation(
    "Is32BitsAssocWord",
    IsAssocWord and IsDataObjectRep, [] );

IsInfBitsAssocWord := NewRepresentation(
    "IsInfBitsAssocWord",
    IsAssocWord and IsComponentObjectRep, [] );


#############################################################################
##
#V  AWP_PURE_TYPE
#V  AWP_NR_BITS_EXP
#V  AWP_NR_GENS
#V  AWP_NR_BITS_PAIR
#V  AWP_FUN_OBJ_BY_VECTOR
#V  AWP_FUN_ASSOC_WORD
#V  AWP_FIRST_FREE
##
##  are positions of non-defining data in the types of associative words,
##  namely
##  - the pure type of the object itself, without knowledge features,
##  - the number of bits available for each exponent,
##  - the number of generators,
##  - the number of bits available for each generator/exponent pair,
##  - the construction function to be called by 'ObjByVector',
##  - the construction function to be called by 'AssocWord',
##  - the first position that can be used for private purposes.
##
##  This data must be provided already in the construction of the family,
##  in order to make sure that calls of 'NewType' fetch types that know
##  this data.
##


#############################################################################
##
#F  InfBits_AssocWord( <Type>, <list> )
##
InfBits_AssocWord := function( Type, list )

    local n,
          i,
          j;

    # Check that the data is admissible.
    n:= Type![ AWP_NR_GENS ];
    if Length( list ) mod 2 <> 0 then
      Error( "<list> must have even length" );
    fi;
    for i in [ 1 .. Length( list ) / 2 ] do
      j:= 2*i - 1;
      if not ( IsInt( list[j] ) and list[j] > 0 and list[j] <= n ) then
        Error( "value at odd position <j> must denote generator" );
      fi;
      if not IsInt( list[ j+1 ] ) then
        Error( "value at even position <j+1> must be an integer" );
      fi;
    od;
    return Objectify( Type, [ Immutable( list ) ] );
end;


#############################################################################
##
#M  Print( <w> )
##
InstallMethod( PrintObj,
    "method for an associative word",
    true,
    [ IsAssocWord ], 0,
    function( elm )

    local names,
          word,
          len,
          i;

    names:= FamilyObj( elm )!.names;
    word:= ExtRepOfObj( elm );
    len:= Length( word ) - 1;
    i:= 1;
    if len < 0 then
      Print( "<identity> of ..." );
    else
      while i < len do
        Print( names[ word[i] ] );
        if word[ i+1 ] <> 1 then
          Print( "^", word[ i+1 ] );
        fi;
        Print( "*" );
        i:= i+2;
      od;
      Print( names[ word[i] ] );
      if word[ i+1 ] <> 1 then
        Print( "^", word[ i+1 ] );
      fi;
    fi;
    end );


#############################################################################
##
#M  String( <w> )
##
InstallMethod( String,
    "method for an associative word",
    true,
    [ IsAssocWord ], 0,
    function( elm )

    local names,
          word,
          len,
          i,
          str;

    names:= FamilyObj( elm )!.names;
    word:= ExtRepOfObj( elm );
    len:= Length( word ) - 1;
    i:= 1;
    str:= "";
    if len < 0 then
      return "<identity> of ...";
#T ??
    fi;
    while i < len do
      Append( str, names[ word[i] ] );
      if word[ i+1 ] <> 1 then
        Add( str, '^' );
        Append( str, word[ i+1 ] );
      fi;
      Add( str, '*' );
      i:= i+2;
    od;
    Append( str, names[ word[i] ] );
    if word[ i+1 ] <> 1 then
      Add( str, '^' );
      Append( str, word[ i+1 ] );
    fi;
    ConvertToStringRep( str );
    return str;
    end );


#############################################################################
##
#F  AssocWord( <Type>, <descr> )
##
AssocWord := function( Type, descr )
    return Type![ AWP_FUN_ASSOC_WORD ]( Type![ AWP_PURE_TYPE ], descr );
end;


#############################################################################
##
#M  ObjByExtRep( <F>, <descr> )
##
InstallMethod( ObjByExtRep,
    "method for a family of associative words, and a homogeneous list",
    true,
    [ IsAssocWordFamily, IsHomogeneousList ], 0,
    function( F, descr )
    local maxexp,   # maximal exponent in 'descr'
          i,        # loop over exponents in 'descr'
          expbits;  # list of maximal exponents for the four representations

    maxexp:= 0;
    for i in [ 2, 4 .. Length( descr ) ] do
      if maxexp < descr[i] then
        maxexp:= descr[i];
      elif maxexp < - descr[i] then
        maxexp:= - descr[i];
      fi;
    od;
    expbits:= F!.expBitsInfo;
    if   maxexp < expbits[2] then
      if maxexp < expbits[1] then
        return AssocWord( F!.types[1], descr );
      else
        return AssocWord( F!.types[2], descr );
      fi;
    elif maxexp < expbits[3] then
        return AssocWord( F!.types[3], descr );
    else
        return AssocWord( F!.types[4], descr );
    fi;
    end );

InstallOtherMethod( ObjByExtRep, true,
    [ IsAssocWordFamily and Is8BitsFamily, IsHomogeneousList ], 0,
    function( F, descr )
    return AssocWord( F!.types[1], descr );
    end );

InstallOtherMethod( ObjByExtRep, true,
    [ IsAssocWordFamily and Is16BitsFamily, IsHomogeneousList ], 0,
    function( F, descr )
    return AssocWord( F!.types[2], descr );
    end );

InstallOtherMethod( ObjByExtRep, true,
    [ IsAssocWordFamily and Is32BitsFamily, IsHomogeneousList ], 0,
    function( F, descr )
    return AssocWord( F!.types[3], descr );
    end );

InstallOtherMethod( ObjByExtRep, true,
    [ IsAssocWordFamily and IsInfBitsFamily, IsHomogeneousList ], 0,
    function( F, descr )
    return AssocWord( F!.types[4], descr );
    end );


#############################################################################
##
#M  ObjByExtRep( <F>, <expbits>, <maxcand>, <descr> )
##
##  is an object that belongs to the smallest possible type that has
##  at least <expbits> bits for the exponent and that allows <maxcand> as
##  exponent.
##
##  If the family itself knows that its objects have (at most) a specified
##  size then objects of the corresponding type are created faster.
##
InstallOtherMethod( ObjByExtRep, true,
    [ IsAssocWordFamily, IsCyclotomic, IsInt, IsHomogeneousList ], 0,
    function( F, exp, maxcand, descr )

    local info, expbits;

    # Choose the appropriate type.
    if maxcand < 0 then
      maxcand:= - maxcand;
    fi;
    info:= F!.expBitsInfo;
    expbits:= F!.expBits;
    if   exp <= expbits[2] and maxcand < info[2] then
      if exp <= expbits[1] and maxcand < info[1] then
        return AssocWord( F!.types[1], descr );
      else
        return AssocWord( F!.types[2], descr );
      fi;
    elif exp <= expbits[3] and maxcand < info[3] then
        return AssocWord( F!.types[3], descr );
    else
        return AssocWord( F!.types[4], descr );
    fi;
    end );


#############################################################################
##
#M  Install (internal) methods for objects of the 8 bits type
##
InstallMethod( ExtRepOfObj,
    "method for an 8 bits assoc. word",
    true,
    [ Is8BitsAssocWord ], 0,
    8Bits_ExtRepOfObj );

InstallMethod( \=,
    "method for two 8 bits assoc. words",
    IsIdentical,
    [ Is8BitsAssocWord, Is8BitsAssocWord ], 0,
    8Bits_Equal );

InstallMethod( \<,
    "method for two 8 bits assoc. words",
    IsIdentical,
    [ Is8BitsAssocWord, Is8BitsAssocWord ], 0,
    8Bits_Less );

InstallMethod( \*,
    "method for two 8 bits assoc. words",
    IsIdentical,
    [ Is8BitsAssocWord, Is8BitsAssocWord ], 0,
    8Bits_Product );

InstallMethod( One,
    "method for an 8 bits assoc. word-with-one",
    true,
    [ Is8BitsAssocWord and IsAssocWordWithOne ], 0,
    x -> 8Bits_AssocWord( FamilyObj( x )!.types[1], [] ) );

InstallMethod( \^,
    "method for an 8 bits assoc. word, and a small integer",
    true,
    [ Is8BitsAssocWord, IsInt and IsSmallIntRep ], 0,
    8Bits_Power );

InstallMethod( ExponentSyllable,
    "method for an 8 bits assoc. word, and a pos. integer",
    true,
    [ Is8BitsAssocWord, IsInt and IsPosRat ], 0,
    8Bits_ExponentSyllable );

InstallMethod( GeneratorSyllable,
    "method for an 8 bits assoc. word, and an integer",
    true,
    [ Is8BitsAssocWord, IsInt ], 0,
    8Bits_GeneratorSyllable );

InstallMethod( NumberSyllables,
    "method for an 8 bits assoc. word",
    true,
    [ Is8BitsAssocWord ], 0,
    8Bits_NumberSyllables );

InstallMethod( ExponentSums,
    "method for an 8 bits assoc. word",
    true,
    [ Is8BitsAssocWord ], 0,
    8Bits_ExponentSums1 );

InstallOtherMethod( ExponentSums,
    "method for an 8 bits assoc. word, and two integers",
    true,
    [ Is8BitsAssocWord, IsInt, IsInt ], 0,
    8Bits_ExponentSums3 );


#############################################################################
##
#M  Install (internal) methods for objects of the 16 bits type
##
InstallMethod( ExtRepOfObj,
    "method for a 16 bits assoc. word",
    true,
    [ Is16BitsAssocWord ], 0,
    16Bits_ExtRepOfObj );

InstallMethod( \=,
    "method for two 16 bits assoc. words",
    IsIdentical,
    [ Is16BitsAssocWord, Is16BitsAssocWord ], 0,
    16Bits_Equal );

InstallMethod( \<,
    "method for two 16 bits assoc. words",
    IsIdentical,
    [ Is16BitsAssocWord, Is16BitsAssocWord ], 0,
    16Bits_Less );

InstallMethod( \*,
    "method for two 16 bits assoc. words",
    IsIdentical,
    [ Is16BitsAssocWord, Is16BitsAssocWord ], 0,
    16Bits_Product );

InstallMethod( One,
    "method for a 16 bits assoc. word-with-one",
    true,
    [ Is16BitsAssocWord and IsAssocWordWithOne ], 0,
    x -> 16Bits_AssocWord( FamilyObj( x )!.types[2], [] ) );

InstallMethod( \^,
    "method for a 16 bits assoc. word, and small integer",
    true,
    [ Is16BitsAssocWord, IsInt and IsSmallIntRep ], 0,
    16Bits_Power );

InstallMethod( ExponentSyllable,
    "method for a 16 bits assoc. word, and pos. integer",
    true,
    [ Is16BitsAssocWord, IsInt and IsPosRat ], 0,
    16Bits_ExponentSyllable );

InstallMethod( GeneratorSyllable,
    "method for a 16 bits assoc. word, and integer",
    true,
    [ Is16BitsAssocWord, IsInt ], 0,
    16Bits_GeneratorSyllable );

InstallMethod( NumberSyllables,
    "method for a 16 bits assoc. word",
    true,
    [ Is16BitsAssocWord ], 0,
    16Bits_NumberSyllables );

InstallMethod( ExponentSums,
    "method for a 16 bits assoc. word",
    true,
    [ Is16BitsAssocWord ], 0,
    16Bits_ExponentSums1 );

InstallOtherMethod( ExponentSums,
    "method for a 16 bits assoc. word, and two integers",
    true,
    [ Is16BitsAssocWord, IsInt, IsInt ], 0,
    16Bits_ExponentSums3 );


#############################################################################
##
#M  Install (internal) methods for objects of the 32 bits type
##
InstallMethod( ExtRepOfObj,
    "method for a 32 bits assoc. word",
    true,
    [ Is32BitsAssocWord ], 0,
    32Bits_ExtRepOfObj );

InstallMethod( \=,
    "method for two 32 bits assoc. words",
    IsIdentical,
    [ Is32BitsAssocWord, Is32BitsAssocWord ], 0,
    32Bits_Equal );

InstallMethod( \<,
    "method for two 32 bits assoc. words",
    IsIdentical,
    [ Is32BitsAssocWord, Is32BitsAssocWord ], 0,
    32Bits_Less );

InstallMethod( \*,
    "method for two 32 bits assoc. words",
    IsIdentical,
    [ Is32BitsAssocWord, Is32BitsAssocWord ], 0,
    32Bits_Product );

InstallMethod( One,
    "method for a 32 bits assoc. word-with-one",
    true,
    [ Is32BitsAssocWord and IsAssocWordWithOne ], 0,
    x -> 32Bits_AssocWord( FamilyObj( x )!.types[3], [] ) );

InstallMethod( \^,
    "method for a 32 bits assoc. word, and small integer",
    true,
    [ Is32BitsAssocWord, IsInt and IsSmallIntRep ], 0,
    32Bits_Power );

InstallMethod( ExponentSyllable,
    "method for a 32 bits assoc. word, and pos. integer",
    true,
    [ Is32BitsAssocWord, IsInt and IsPosRat ], 0,
    32Bits_ExponentSyllable );

InstallMethod( GeneratorSyllable,
    "method for a 32 bits assoc. word, and pos. integer",
    true,
    [ Is32BitsAssocWord, IsInt and IsPosRat ], 0,
    32Bits_GeneratorSyllable );

InstallMethod( NumberSyllables,
    "method for a 32 bits assoc. word",
    true,
    [ Is32BitsAssocWord ], 0,
    32Bits_NumberSyllables );

InstallMethod( ExponentSums,
    "method for a 32 bits assoc. word",
    true,
    [ Is32BitsAssocWord ], 0,
    32Bits_ExponentSums1 );

InstallOtherMethod( ExponentSums,
    "method for a 32 bits assoc. word",
    true,
    [ Is32BitsAssocWord, IsInt, IsInt ], 0,
    32Bits_ExponentSums3 );


#############################################################################
##
#M  Install methods for objects of the infinity type
##
InstallMethod( ExtRepOfObj,
    "method for a inf. bits assoc. word",
    true,
    [ IsInfBitsAssocWord ], 0,
    function( elm ) return elm![1]; end );

InstallMethod( \=,
    "method for two inf. bits assoc. words",
    IsIdentical,
    [ IsInfBitsAssocWord, IsInfBitsAssocWord ], 0,
    function( x, y ) return x![1] = y![1]; end );

InstallMethod( \<,
    "method for two inf. bits assoc. words",
    IsIdentical,
    [ IsInfBitsAssocWord, IsInfBitsAssocWord ], 0,
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( One,
    "method for an inf. bits assoc. word-with-one",
    true,
    [ IsInfBitsAssocWord and IsAssocWordWithOne ], 0,
    x -> InfBits_AssocWord( FamilyObj( x )!.types[4], [] ) );

InstallMethod( ExponentSyllable,
    "method for an inf. bits assoc. word, and a pos. integer",
    true,
    [ IsInfBitsAssocWord, IsInt and IsPosRat ], 0,
    function( x, i ) return x![1][ 2*i ]; end );

InstallMethod( GeneratorSyllable,
    "method for an inf. bits assoc. word, and an integer",
    true,
    [ IsInfBitsAssocWord, IsInt ], 0,
    function( x, i ) return x![1][ 2*i-1 ]; end );

InstallMethod( NumberSyllables,
    "method for an inf. bits assoc. word",
    true,
    [ IsInfBitsAssocWord ], 0,
    function( x ) return Length( x![1] ) / 2; end );

InstallMethod( ExponentSums,
    "method for an inf. bits assoc. word",
    true,
    [ IsInfBitsAssocWord ], 0,
    function( obj )
    local expvec, i;
    expvec:= [];
    for i in [ 1 .. TypeObj( obj )![ AWP_NR_GENS ] ] do
      expvec[i]:= 0;
    od;
    obj:= obj![1];
    for i in [ 1, 3 .. Length( obj ) - 1 ] do
      expvec[ obj[i] ]:= expvec[ obj[i] ] + obj[ i+1 ];
    od;
    return expvec;
    end );

InstallOtherMethod( ExponentSums,
    "method for an inf. bits assoc. word, and two integers",
    true,
    [ IsInfBitsAssocWord, IsInt, IsInt ], 0,
    function( obj, from, to )
    local expvec, i;
    expvec:= [];
    if from < 2 then from:= 1; else from:= 2 * from - 1; fi;
    if TypeObj( obj )![ AWP_NR_GENS ] / 2 < to then
      to:= TypeObj( obj )![ AWP_NR_GENS ] / 2 - 1;
    else
      to:= 2 * to - 1;
    fi;
    for i in [ from .. to ] do
      expvec[i]:= 0;
    od;
    obj:= obj![1];
    for i in [ from, from + 2 .. to ] do
      expvec[ obj[i] ]:= expvec[ obj[i] ] + obj[ i+1 ];
    od;
    return expvec;
    end );


#############################################################################
##
#F  ObjByVector( <Type>, <vector> )
#T  ObjByVector( <Fam>, <vector> )
##
ObjByVector := function( Type, vec )
    return Type![ AWP_FUN_OBJ_BY_VECTOR ]( Type![ AWP_PURE_TYPE ], vec );
end;


InfBits_ObjByVector := function( F, vec )
    local expr, i;
    expr:= [];
    for i in [ 1 .. Length( vec ) ] do
      if vec[i] <> 0 then
        Add( expr, i );
        Add( expr, vec[i] );
      fi;
    od;
    return ObjByExtRep( F, expr );
end;


#############################################################################
##
#M  ObjByExtRep( <Fam>, <exp>, <maxcand>, <descr> )
##
##  If the family does already know that all only words in a prescribed
##  type will be constructed then we store this in the family,
##  and 'ObjByExtRep' will construct only such objects.
##
InstallOtherMethod( ObjByExtRep,
    "method for an 8 bits assoc. words family, two integers, and a list",
    true,
    [ IsAssocWordFamily and Is8BitsFamily, IsInt, IsInt,
      IsHomogeneousList ], 0,
    function( F, exp, maxcand, descr )
    return 8Bits_AssocWord( F!.types[1], descr );
    end );

InstallOtherMethod( ObjByExtRep,
    "method for a 16 bits assoc. words family, two integers, and a list",
    true,
    [ IsAssocWordFamily and Is16BitsFamily, IsInt, IsInt,
      IsHomogeneousList ], 0,
    function( F, exp, maxcand, descr )
    return 16Bits_AssocWord( F!.types[2], descr );
    end );

InstallOtherMethod( ObjByExtRep,
    "method for a 32 bits assoc. words family, two integers, and a list",
    true,
    [ IsAssocWordFamily and Is32BitsFamily, IsInt, IsInt,
      IsHomogeneousList ], 0,
    function( F, exp, maxcand, descr )
    return 32Bits_AssocWord( F!.types[3], descr );
    end );

InstallOtherMethod( ObjByExtRep,
    "method for an inf. bits assoc. words family, two integers, and a list",
    true,
    [ IsAssocWordFamily and IsInfBitsFamily, IsCyclotomic, IsInt,
      IsHomogeneousList ], 0,
    function( F, exp, maxcand, descr )
    return InfBits_AssocWord( F!.types[4], descr );
    end );


#############################################################################
##
#F  StoreInfoFreeMagma( <F>, <names>, <req> )
##
##  does the administrative work in the construction of free semigroups,
##  free monoids, and free groups.
##
##  <F> is the family of objects, <names> is a list of generators names,
##  and <req> is the required category for the elements, that is,
##  'IsAssocWord', 'IsAssocWordWithOne', or 'IsAssocWordWithInverse'.
##
StoreInfoFreeMagma := function( F, names, req )

    local rank,
          rbits,
          K;

    # Store the names, initialize the types list.
    F!.types := [];
    F!.names := Immutable( names );

    if not IsFinite( names ) then

      SetFilterObj( F, IsInfBitsFamily );

    else

      # Install the data (number of bits available for exponents).
      # Note that in the case of the 32 bits representation,
      # at most 28 bits are allowed for the exponents in order to avoid
      # overflow checks.
      rank  := Length( names );
      rbits := 1;
      while 2^rbits < rank do
        rbits:= rbits + 1;
      od;
      F!.expBits       := [  8 - rbits,
                            16 - rbits,
                            Minimum( 32 - rbits, 28 ),
                            infinity ];
      F!.expBitsInfo   := [ 2^( F!.expBits[1] - 1 ),
                            2^( F!.expBits[2] - 1 ),
                            2^( F!.expBits[3] - 1 ),
                            infinity          ];

      # Store the internal types.
      K:= NewType( F, Is8BitsAssocWord and req );
      K![ AWP_PURE_TYPE    ]      := K;
      K![ AWP_NR_BITS_EXP  ]      := F!.expBits[1];
      K![ AWP_NR_GENS      ]      := rank;
      K![ AWP_NR_BITS_PAIR ]      := 8;
      K![ AWP_FUN_OBJ_BY_VECTOR ] := 8Bits_ObjByVector;
      K![ AWP_FUN_ASSOC_WORD    ] := 8Bits_AssocWord;
      F!.types[1]:= K;
  
      K:= NewType( F, Is16BitsAssocWord and req );
      K![ AWP_PURE_TYPE    ]      := K;
      K![ AWP_NR_BITS_EXP  ]      := F!.expBits[2];
      K![ AWP_NR_GENS      ]      := rank;
      K![ AWP_NR_BITS_PAIR ]      := 16;
      K![ AWP_FUN_OBJ_BY_VECTOR ] := 16Bits_ObjByVector;
      K![ AWP_FUN_ASSOC_WORD    ] := 16Bits_AssocWord;
      F!.types[2]:= K;
  
      K:= NewType( F, Is32BitsAssocWord and req );
      K![ AWP_PURE_TYPE    ]      := K;
      K![ AWP_NR_BITS_EXP  ]      := F!.expBits[3];
      K![ AWP_NR_GENS      ]      := rank;
      K![ AWP_NR_BITS_PAIR ]      := 32;
      K![ AWP_FUN_OBJ_BY_VECTOR ] := 32Bits_ObjByVector;
      K![ AWP_FUN_ASSOC_WORD    ] := 32Bits_AssocWord;
      F!.types[3]:= K;

    fi;

    K:= NewType( F, IsInfBitsAssocWord and req );
    K![ AWP_PURE_TYPE    ]      := K;
    K![ AWP_NR_BITS_EXP  ]      := infinity;
    K![ AWP_NR_GENS      ]      := infinity;
    K![ AWP_NR_BITS_PAIR ]      := infinity;
    K![ AWP_FUN_OBJ_BY_VECTOR ] := InfBits_ObjByVector;
    K![ AWP_FUN_ASSOC_WORD    ] := InfBits_AssocWord;
    F!.types[4]:= K;

end;


#############################################################################
##
#R  IsInfiniteListOfNamesRep( <string> )
##
##  is a representation of a list containing at position $i$ the string
##  '<string>$i$'.
##
##  <string> is stored at position 1 in the list object.
##
IsInfiniteListOfNamesRep := NewRepresentation( "IsInfiniteListOfNamesRep",
    IsPositionalObjectRep and IsConstantTimeAccessListRep,
    [ 1 ] );

InstallMethod( PrintObj,
    "method for an infinite list of names",
    true,
    [ IsList and IsInfiniteListOfNamesRep ], 0,
    function( list )
    Print( "[ ", list[1], ", ", list[2], ", ... ]" );
    end );

InstallMethod( \[\],
    "method for an infinite list of names",
    true,
    [ IsList and IsInfiniteListOfNamesRep, IsInt and IsPosRat ], 0,
    function( list, pos )
    local entry;
    entry:= Concatenation( list![1], String( pos ) );
    ConvertToStringRep( entry );
    return entry;
    end );

InstallMethod( Position,
    "method for an infinite list of names, an object, and zero",
    true,
    [ IsList and IsInfiniteListOfNamesRep, IsObject, IsZeroCyc ], 0,
    function( list, obj, zero )
    local digits, pos, i;
    if    ( not IsString( obj ) )
       or Length( obj ) <= Length( list![1] )
       or obj{ [ 1 .. Length( list![1] ) ] } <> list![1] then
      return fail;
    fi;
    digits:= "0123456789";
    pos:= 0;
    for i in [ Length( list![1] ) + 1 .. Length( obj ) ] do
      if obj[i] in digits then
        pos:= 10*pos + Position( digits, obj[i], 0 ) - 1;
      else
        return fail;
      fi;
    od;
    return pos;
    end );


#############################################################################
##
#F  InfiniteListOfNames( <string> )
##
InfiniteListOfNames := function( string )
    local list;
    list:= Objectify( NewType( CollectionsFamily( FamilyObj( string ) ),
                                   IsList
                               and IsDenseList
                               and IsInfiniteListOfNamesRep ),
                      [ string ] );
    SetIsFinite( list, false );
    SetIsEmpty( list, false );
    SetLength( list, infinity );
    return list;
end;


#############################################################################
##
#R  IsInfiniteListOfGeneratorsRep( <F> )
##
##  is a representation of a list containing at position $i$ the $i$-th
##  generator of the free something family <F>.
##
##  <F> is stored at position 1 in the list object.
##
IsInfiniteListOfGeneratorsRep := NewRepresentation(
    "IsInfiniteListOfGeneratorsRep",
    IsPositionalObjectRep and IsConstantTimeAccessListRep,
    [ 1 ] );

InstallMethod( PrintObj,
    "method for an infinite list of generators",
    true,
    [ IsList and IsInfiniteListOfGeneratorsRep ], 0,
    function( list )
    Print( "[ ", list[1], ", ", list[2], ", ... ]" );
    end );

InstallMethod( \[\],
    "method for an infinite list of generators",
    true,
    [ IsList and IsInfiniteListOfGeneratorsRep, IsInt and IsPosRat ], 0,
    function( list, i )
    return ObjByExtRep( list![1], [ i, 1 ] );
    end );

InstallMethod( Position,
    "method for an infinite list of generators, an object, and zero",
    true,
    [ IsList and IsInfiniteListOfGeneratorsRep, IsObject, IsZeroCyc ], 0,
    function( list, obj, zero )
    local digits, pos;
    if FamilyObj( obj ) <> list![1] then
      return fail;
    fi;
    obj:= ExtRepOfObj( obj );
    if obj[2] <> 1 then
      return fail;
    else
      return obj[1];
    fi;
    end );


#############################################################################
##
#M  Random( <list> )  . . . . . . . . . .  for an infinite list of generators
##
InstallMethod( Random,
    "method for an infinite list of generators",
    true,
    [ IsList and IsInfiniteListOfGeneratorsRep ], 0,
    function( list )
    local pos;
    pos:= Random( Integers );
    if 0 <= pos then
      return list[ 2 * pos + 1 ];
    else
      return list[ -2 * pos ];
    fi;
    end );
#T should be moved to list.gi, or?


#############################################################################
##
#F  InfiniteListOfGenerators( <F> )
##
InfiniteListOfGenerators := function( F )
    local list;
    list:= Objectify( NewType( CollectionsFamily( F ),
                                   IsList
                               and IsDenseList
                               and IsInfiniteListOfGeneratorsRep ),
                      [ F ] );
    SetIsFinite( list, false );
    SetIsEmpty( list, false );
    SetLength( list, infinity );
    return list;
end;


#############################################################################
##

#E  wordrep.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



