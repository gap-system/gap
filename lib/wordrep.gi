#############################################################################
##
#W  wordrep.gi                  GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
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
#V  AWP_PURE_KIND
#V  AWP_NR_BITS_EXP
#V  AWP_NR_GENS
#V  AWP_NR_BITS_PAIR
#V  AWP_FUN_OBJ_BY_VECTOR
#V  AWP_FUN_ASSOC_WORD
#V  AWP_FIRST_FREE
##
##  are positions of non-defining data in the kinds of associative words,
##  namely
##  - the pure kind of the object itself, without knowledge features,
##  - the number of bits available for each exponent,
##  - the number of generators,
##  - the number of bits available for each generator/exponent pair,
##  - the construction function to be called by 'ObjByVector',
##  - the construction function to be called by 'AssocWord',
##  - the first position that can be used for private purposes.
##
##  This data must be provided already in the construction of the family,
##  in order to make sure that calls of 'NewKind' fetch kinds that know
##  this data.
##
# AWP_PURE_KIND         :=  4;
# AWP_NR_BITS_EXP       :=  5;
# AWP_NR_GENS           :=  6;
# AWP_NR_BITS_PAIR      :=  7;
# AWP_FUN_OBJ_BY_VECTOR :=  8;
# AWP_FUN_ASSOC_WORD    :=  9;
# AWP_FIRST_FREE        := 10;


#############################################################################
##
#F  InfBits_AssocWord( <Kind>, <list> )
##
InfBits_AssocWord := function( Kind, list )

    local n,
          i,
          j;

    # Check that the data is admissible.
    n:= Kind![ AWP_NR_GENS ];
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
    return Objectify( Kind, [ Immutable( list ) ] );
end;


#############################################################################
##
#M  Print( <w> )
##
InstallMethod( PrintObj, true, [ IsAssocWord ], 0,
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
InstallMethod( String, true, [ IsAssocWord ], 0,
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
#F  AssocWord( <Kind>, <descr> )
##
AssocWord := function( Kind, descr )
    return Kind![ AWP_FUN_ASSOC_WORD ]( Kind![ AWP_PURE_KIND ], descr );
end;


#############################################################################
##
#M  ObjByExtRep( <F>, <descr> )
##
InstallMethod( ObjByExtRep, true,
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
        return AssocWord( F!.kinds[1], descr );
      else
        return AssocWord( F!.kinds[2], descr );
      fi;
    elif maxexp < expbits[3] then
        return AssocWord( F!.kinds[3], descr );
    else
        return AssocWord( F!.kinds[4], descr );
    fi;
    end );


#############################################################################
##
#M  ObjByExtRep( <F>, <expbits>, <maxcand>, <descr> )
##
##  is an object that belongs to the smallest possible kind that has
##  at least <expbits> bits for the exponent and that allows <maxcand> as
##  exponent.
##
##  If the family itself knows that its objects have (at most) a specified
##  size then objects of the corresponding kind are created faster.
##
InstallOtherMethod( ObjByExtRep, true,
    [ IsAssocWordFamily, IsInt, IsInt, IsHomogeneousList ], 0,
    function( F, exp, maxcand, descr )

    local info, expbits;

    # Choose the appropriate kind.
    if maxcand < 0 then
      maxcand:= - maxcand;
    fi;
    info:= F!.expBitsInfo;
    expbits:= F!.expBits;
    if   exp <= expbits[2] and maxcand < info[2] then
      if exp <= expbits[1] and maxcand < info[1] then
        return AssocWord( F!.kinds[1], descr );
      else
        return AssocWord( F!.kinds[2], descr );
      fi;
    elif exp <= expbits[3] and maxcand < info[3] then
        return AssocWord( F!.kinds[3], descr );
    else
        return AssocWord( F!.kinds[4], descr );
    fi;
    end );


#############################################################################
##
#M  Install (internal) methods for objects of the 8 bits kind
##
InstallMethod( ExtRepOfObj, true, [ Is8BitsAssocWord ], 0,
    8Bits_ExtRepOfObj );

InstallMethod( \=, IsIdentical, [ Is8BitsAssocWord, Is8BitsAssocWord ], 0,
    8Bits_Equal );

InstallMethod( \<, IsIdentical, [ Is8BitsAssocWord, Is8BitsAssocWord ], 0,
    8Bits_Less );

InstallMethod( \*, IsIdentical, [ Is8BitsAssocWord, Is8BitsAssocWord ], 0,
    8Bits_Product );

InstallMethod( One, true, [ Is8BitsAssocWord and IsAssocWordWithOne ], 0,
    x -> 8Bits_AssocWord( FamilyObj( x )!.kinds[1], [] ) );

InstallMethod( \^, true, [ Is8BitsAssocWord, IsInt and IsSmallIntRep ], 0,
    8Bits_Power );

InstallMethod( ExponentSyllable, true, [ Is8BitsAssocWord,
    IsInt and IsPosRat ], 0, 8Bits_ExponentSyllable );

InstallMethod( GeneratorSyllable, true, [ Is8BitsAssocWord, IsInt ], 0,
    8Bits_GeneratorSyllable );

InstallMethod( NumberSyllables, true, [ Is8BitsAssocWord ], 0,
    8Bits_NumberSyllables );

InstallMethod( ExponentSums, true, [ Is8BitsAssocWord ], 0,
    8Bits_ExponentSums1 );

InstallOtherMethod( ExponentSums, true, [ Is8BitsAssocWord, IsInt, IsInt ],
    0, 8Bits_ExponentSums3 );


#############################################################################
##
#M  Install (internal) methods for objects of the 16 bits kind
##
InstallMethod( ExtRepOfObj, true, [ Is16BitsAssocWord ], 0,
    16Bits_ExtRepOfObj );

InstallMethod( \=, IsIdentical, [ Is16BitsAssocWord, Is16BitsAssocWord ], 0,
    16Bits_Equal );

InstallMethod( \<, IsIdentical, [ Is16BitsAssocWord, Is16BitsAssocWord ], 0,
    16Bits_Less );

InstallMethod( \*, IsIdentical, [ Is16BitsAssocWord, Is16BitsAssocWord ], 0,
    16Bits_Product );

InstallMethod( One, true, [ Is16BitsAssocWord and IsAssocWordWithOne ], 0,
    x -> 16Bits_AssocWord( FamilyObj( x )!.kinds[2], [] ) );

InstallMethod( \^, true, [ Is16BitsAssocWord, IsInt and IsSmallIntRep ], 0,
    16Bits_Power );

InstallMethod( ExponentSyllable, true, [ Is16BitsAssocWord,
    IsInt and IsPosRat ], 0, 16Bits_ExponentSyllable );

InstallMethod( GeneratorSyllable, true, [ Is16BitsAssocWord, IsInt ], 0,
    16Bits_GeneratorSyllable );

InstallMethod( NumberSyllables, true, [ Is16BitsAssocWord ], 0,
    16Bits_NumberSyllables );

InstallMethod( ExponentSums, true, [ Is16BitsAssocWord ], 0,
    16Bits_ExponentSums1 );

InstallOtherMethod( ExponentSums, true, [ Is16BitsAssocWord, IsInt, IsInt ],
    0, 16Bits_ExponentSums3 );


#############################################################################
##
#M  Install (internal) methods for objects of the 32 bits kind
##
InstallMethod( ExtRepOfObj, true, [ Is32BitsAssocWord ], 0,
    32Bits_ExtRepOfObj );

InstallMethod( \=, IsIdentical, [ Is32BitsAssocWord, Is32BitsAssocWord ], 0,
    32Bits_Equal );

InstallMethod( \<, IsIdentical, [ Is32BitsAssocWord, Is32BitsAssocWord ], 0,
    32Bits_Less );

InstallMethod( \*, IsIdentical, [ Is32BitsAssocWord, Is32BitsAssocWord ], 0,
    32Bits_Product );

InstallMethod( One, true, [ Is32BitsAssocWord and IsAssocWordWithOne ], 0,
    x -> 32Bits_AssocWord( FamilyObj( x )!.kinds[3], [] ) );

InstallMethod( \^, true, [ Is32BitsAssocWord, IsInt and IsSmallIntRep ], 0,
    32Bits_Power );

InstallMethod( ExponentSyllable, true, [ Is32BitsAssocWord,
    IsInt and IsPosRat ], 0, 32Bits_ExponentSyllable );

InstallMethod( GeneratorSyllable, true, [ Is32BitsAssocWord,
    IsInt and IsPosRat ], 0, 32Bits_GeneratorSyllable );

InstallMethod( NumberSyllables, true, [ Is32BitsAssocWord ], 0,
    32Bits_NumberSyllables );

InstallMethod( ExponentSums, true, [ Is32BitsAssocWord ], 0,
    32Bits_ExponentSums1 );

InstallOtherMethod( ExponentSums, true, [ Is32BitsAssocWord, IsInt, IsInt ],
    0, 32Bits_ExponentSums3 );


#############################################################################
##
#M  Install methods for objects of the infinity kind
##
InstallMethod( ExtRepOfObj, true, [ IsInfBitsAssocWord ], 0,
    function( elm ) return elm![1]; end );

InstallMethod( \=, IsIdentical, [ IsInfBitsAssocWord, IsInfBitsAssocWord ], 0,
    function( x, y ) return x![1] = y![1]; end );

InstallMethod( \<, IsIdentical, [ IsInfBitsAssocWord, IsInfBitsAssocWord ], 0,
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( One, true, [ IsInfBitsAssocWord and IsAssocWordWithOne ], 0,
    x -> InfBits_AssocWord( FamilyObj( x )!.kinds[4], [] ) );

InstallMethod( ExponentSyllable, true, [ IsInfBitsAssocWord, 
    IsInt and IsPosRat ], 0, function( x, i ) return x![1][ 2*i ]; end );

InstallMethod( GeneratorSyllable, true, [ IsInfBitsAssocWord, IsInt ], 0,
    function( x, i ) return x![1][ 2*i-1 ]; end );

InstallMethod( NumberSyllables, true, [ IsInfBitsAssocWord ], 0,
    function( x ) return Length( x![1] ) / 2; end );

InstallMethod( ExponentSums, true, [ IsInfBitsAssocWord ], 0,
    function( obj )
    local expvec, i;
    expvec:= [];
    for i in [ 1 .. KindObj( obj )![ AWP_NR_GENS ] ] do
      expvec[i]:= 0;
    od;
    obj:= obj![1];
    for i in [ 1, 3 .. Length( obj ) - 1 ] do
      expvec[ obj[i] ]:= expvec[ obj[i] ] + obj[ i+1 ];
    od;
    return expvec;
    end );

InstallOtherMethod( ExponentSums, true,
    [ IsInfBitsAssocWord, IsInt, IsInt ], 0,
    function( obj, from, to )
    local expvec, i;
    expvec:= [];
    if from < 2 then from:= 1; else from:= 2 * from - 1; fi;
    if KindObj( obj )![ AWP_NR_GENS ] / 2 < to then
      to:= KindObj( obj )![ AWP_NR_GENS ] / 2 - 1;
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
#F  ObjByVector( <Kind>, <vector> )
#T  ObjByVector( <Fam>, <vector> )
##
ObjByVector := function( Kind, vec )
    return Kind![ AWP_FUN_OBJ_BY_VECTOR ]( Kind![ AWP_PURE_KIND ], vec );
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
##  kind will be constructed then we store this in the family,
##  and 'ObjByExtRep' will construct only such objects.
##
InstallOtherMethod( ObjByExtRep, true,
    [ IsAssocWordFamily and Is8BitsAssocWord, IsInt, IsInt, IsList ], 0,
    function( F, exp, maxcand, descr )
    return 8Bits_AssocWord( F!.kinds[1], descr );
    end );

InstallOtherMethod( ObjByExtRep, true,
    [ IsAssocWordFamily and Is16BitsAssocWord, IsInt, IsInt, IsList ], 0,
    function( F, exp, maxcand, descr )
    return 16Bits_AssocWord( F!.kinds[2], descr );
    end );

InstallOtherMethod( ObjByExtRep, true,
    [ IsAssocWordFamily and Is32BitsAssocWord, IsInt, IsInt, IsList ], 0,
    function( F, exp, maxcand, descr )
    return 32Bits_AssocWord( F!.kinds[3], descr );
    end );

InstallOtherMethod( ObjByExtRep, true,
    [ IsAssocWordFamily and IsInfBitsAssocWord, IsInt, IsInt, IsList ], 0,
    function( F, exp, maxcand, descr )
    return InfBits_AssocWord( F!.kinds[4], descr );
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

    # Install the data (names, number of bits available for exponents).
    # Note that in the case of the 32 bits representation,
    # at most 28 bits are allowed for the exponents in order to avoid
    # overflow checks.
    rank  := Length( names );
    rbits := 1;
    while 2^rbits < rank do
      rbits:= rbits + 1;
    od;
    F!.names         := Immutable( names );
    F!.expBits       := [  8 - rbits,
                          16 - rbits,
                          Minimum( 32 - rbits, 28 ),
                          infinity ];
    F!.expBitsInfo   := [ 2^( F!.expBits[1] - 1 ),
                          2^( F!.expBits[2] - 1 ),
                          2^( F!.expBits[3] - 1 ),
                          infinity          ];

    # Construct and store the kinds.
    F!.kinds:= [];

    K:= NewKind( F, Is8BitsAssocWord and req );
    K![ AWP_PURE_KIND    ]      := K;
    K![ AWP_NR_BITS_EXP  ]      := F!.expBits[1];
    K![ AWP_NR_GENS      ]      := rank;
    K![ AWP_NR_BITS_PAIR ]      := 8;
    K![ AWP_FUN_OBJ_BY_VECTOR ] := 8Bits_ObjByVector;
    K![ AWP_FUN_ASSOC_WORD    ] := 8Bits_AssocWord;
    F!.kinds[1]:= K;

    K:= NewKind( F, Is16BitsAssocWord and req );
    K![ AWP_PURE_KIND    ]      := K;
    K![ AWP_NR_BITS_EXP  ]      := F!.expBits[2];
    K![ AWP_NR_GENS      ]      := rank;
    K![ AWP_NR_BITS_PAIR ]      := 16;
    K![ AWP_FUN_OBJ_BY_VECTOR ] := 16Bits_ObjByVector;
    K![ AWP_FUN_ASSOC_WORD    ] := 16Bits_AssocWord;
    F!.kinds[2]:= K;

    K:= NewKind( F, Is32BitsAssocWord and req );
    K![ AWP_PURE_KIND    ]      := K;
    K![ AWP_NR_BITS_EXP  ]      := F!.expBits[3];
    K![ AWP_NR_GENS      ]      := rank;
    K![ AWP_NR_BITS_PAIR ]      := 32;
    K![ AWP_FUN_OBJ_BY_VECTOR ] := 32Bits_ObjByVector;
    K![ AWP_FUN_ASSOC_WORD    ] := 32Bits_AssocWord;
    F!.kinds[3]:= K;

    K:= NewKind( F, IsInfBitsAssocWord and req );
    K![ AWP_PURE_KIND    ]      := K;
    K![ AWP_NR_BITS_EXP  ]      := F!.expBits[4];
    K![ AWP_NR_GENS      ]      := rank;
    K![ AWP_NR_BITS_PAIR ]      := infinity;
    K![ AWP_FUN_OBJ_BY_VECTOR ] := InfBits_ObjByVector;
    K![ AWP_FUN_ASSOC_WORD    ] := InfBits_AssocWord;
    F!.kinds[4]:= K;

end;


#############################################################################
##

#E  wordrep.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



