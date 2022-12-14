#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for free semigroups.
##
##  Element objects of free semigroups, free monoids and free groups are
##  associative words.
##  For the external representation see the file 'wordrep.gi'.
##


#############################################################################
##
#M  IsWholeFamily( <S> )  . . . . . . .  is a free semigroup the whole family
##
##  <S> contains the whole family of its elements if and only if all
##  magma generators of the family are among the semigroup generators of <S>.
##
InstallMethod( IsWholeFamily,
    "for a free semigroup",
    [ IsSemigroup and IsAssocWordCollection ],
    S -> IsSubset( MagmaGeneratorsOfFamily( ElementsFamily( FamilyObj(S) ) ),
                   GeneratorsOfMagma( S ) ) );


#############################################################################
##
#M  Iterator( <S> ) . . . . . . . . . . . . . . iterator for a free semigroup
##
##  Iterator and enumerator of free semigroups are implemented as follows.
##  Words appear in increasing length in terms of the generators
##  $s_1, s_2, \ldots s_n$.
##  So first all words of length 1 are enumerated, then words of length 2,
##  and so on.
##  There are exactly $n^l$ words of length $l$.
##  They are parametrized by $l$-tuples $(c_1, c_2, \ldots, c_l)$,
##  corresponding to $s_{c_1} s_{c_2} \cdots s_{c_l}$.
##
##  So the word corresponding to the integer
##  $m = \sum_{i=1}^{l-1} n^i + m^{\prime}$,
##  with $1 \leq m^{\prime} \leq n^l$,
##  is the $m^{\prime}$-th word of length $l$.
##  Let $m^{\prime} = \sum_{i=1}^l c_i n^{i-1}$, with $1 \leq c_i \leq n$.
##  Then this word is $s_{c_1} s_{c_2} \cdots s_{c_l}$.
##
BindGlobal( "FreeSemigroup_NextWordExp", function( iter )
    local counter,
          len,
          pos,
          word,
          maxexp,
          i,
          exp;

    counter:= iter!.counter;
    len:= iter!.length;
    pos:= 1;
    while counter[ pos ] = iter!.nrgenerators do
      pos:= pos + 1;
    od;
    if pos > len then

      # All words of length at most 'len' have been used already.
      len:= len + 1;
      iter!.length:= len;
      counter:= List( [ 1 .. len ], x -> 1 );
      Add( counter, 0 );
      iter!.counter:= counter;

      # The first word of length 'len' is the power of the first generator.
      word:= [ 1, len ];
      maxexp:= len;

    else

      # Increase the counter for words of length 'iter!.length'.
      for i in [ 1 .. pos-1 ] do
        counter[i]:= 1;
      od;
      counter[ pos ]:= counter[ pos ] + 1;

      # Convert the string of generators numbers.
      word:= [];
      i:= 1;
      maxexp:= 1;
      while i <= len do
        Add( word, counter[i] );
        exp:= 1;
        while counter[i] = counter[ i+1 ] do
          exp:= exp + 1;
          i:= i+1;
        od;
        Add( word, exp );
        if maxexp < exp then
          maxexp:= exp;
        fi;
        i:= i+1;
      od;

    fi;

    iter!.word:= word;
    iter!.exp:= maxexp;
end );

BindGlobal( "NextIterator_FreeSemigroup", function( iter )
    local word;

    word:= ObjByExtRep( iter!.family, 1, iter!.exp, iter!.word );
    FreeSemigroup_NextWordExp( iter );
    return word;
    end );

BindGlobal( "ShallowCopy_FreeSemigroup",
    iter -> rec(
                family         := iter!.family,
                nrgenerators   := iter!.nrgenerators,
                exp            := iter!.exp,
                word           := ShallowCopy( iter!.word ),
                counter        := ShallowCopy( iter!.counter ),
                length         := iter!.length ) );

InstallMethod( Iterator,
    "for a free semigroup",
    [ IsAssocWordCollection and IsWholeFamily ],
    function( S )
    # A free monoid or free group needs another method.
    # A trivial monoid/group needs another method.
    if IsAssocWordWithOneCollection( S ) or IsTrivial( S ) then
      TryNextMethod();
    fi;

    return IteratorByFunctions( rec(
               IsDoneIterator := ReturnFalse,
               NextIterator   := NextIterator_FreeSemigroup,
               ShallowCopy    := ShallowCopy_FreeSemigroup,

               family         := ElementsFamily( FamilyObj( S ) ),
               nrgenerators   := Length( GeneratorsOfMagma( S ) ),
               exp            := 1,
               word           := [ 1, 1 ],
               counter        := [ 1, 0 ],
               length         := 1 ) );
    end );


#############################################################################
##
#M  Enumerator( <S> ) . . . . . . . . . . . . enumerator for a free semigroup
##
BindGlobal( "ElementNumber_FreeMonoid", function( enum, nr )
    local n, l, power, word, exp, maxexp, cc, i, c;

    if nr = 1 then
      return One( enum!.family );
    fi;

    n:= enum!.nrgenerators;

    # Compute the length of the word corresponding to `nr'.
    l:= 0;
    power:= 1;
    nr:= nr - 1;
    while 0 < nr do
      power:= power * n;
      nr:= nr - power;
      l:= l+1;
    od;
    nr:= nr + power - 1;

    # Compute the vector of the `(nr + 1)'-th element of length `l'.
    exp:= 0;
    maxexp:= 1;
    c:= nr mod n;
    word:= [ c+1 ];
    cc:= c;
    for i in [ 1 .. l ] do
      if c = cc then
        exp:= exp + 1;
      else
        cc:= c;
        Add( word, exp );
        Add( word, c+1 );
        if maxexp < exp then
          maxexp:= exp;
        fi;
        exp:= 1;
      fi;
      nr:= ( nr - c ) / n;
      c:= nr mod n;
    od;
    if maxexp < exp then
      maxexp:= exp;
    fi;
    Add( word, exp );

    # Return the element.
    return ObjByExtRep( enum!.family, 1, maxexp, word );
end );

BindGlobal( "ElementNumber_FreeSemigroup", function( enum, nr )
    return ElementNumber_FreeMonoid( enum, nr+1 );
end );

BindGlobal( "NumberElement_FreeMonoid", function( enum, elm )
    local l, len, i, n, nr, power, c, exp;

    if not IsCollsElms( FamilyObj( enum ), FamilyObj( elm ) ) then
      return fail;
    fi;

    elm:= ExtRepOfObj( elm );
    l:= Length( elm ) / 2;

    # Calculate the length of the word.
    len:= 0;
    for i in [ 2, 4 .. 2*l ] do
      len:= len + elm[i];
    od;

    # Calculate the number of words of smaller length, plus 1.
    n:= enum!.nrgenerators;
    nr:= 1;
    power:= 1;
    for i in [ 1 .. len ] do
      nr:= nr + power;
      power:= power * n;
    od;

    # Add the position in the words of length 'len'.
    power:= 1;
    for i in [ 2, 4 .. 2*l ] do
      c:= elm[ i-1 ] - 1;
      for exp in [ 1 .. elm[i] ] do
        nr:= nr + c * power;
        power:= power * n;
      od;
    od;

    return nr;
end );

BindGlobal( "NumberElement_FreeSemigroup", function( enum, elm )
    local nr;

    nr:= NumberElement_FreeMonoid( enum, elm );
    if nr <> fail then
      nr:= nr - 1;
    fi;

    return nr;
end );

InstallMethod( Enumerator,
    "for a free semigroup",
    [ IsAssocWordCollection and IsWholeFamily and IsSemigroup ],
    function( S )

    # A free monoid or free group needs another method.
    # A trivial semigroup/monoid/group needs another method.
    if IsAssocWordWithOneCollection( S ) or IsTrivial( S ) then
      TryNextMethod();
    fi;

    return EnumeratorByFunctions( S, rec(
               ElementNumber := ElementNumber_FreeSemigroup,
               NumberElement := NumberElement_FreeSemigroup,

               family       := ElementsFamily( FamilyObj( S ) ),
               nrgenerators := Length( ElementsFamily(
                                           FamilyObj( S ) )!.names ) ) );
    end );


#############################################################################
##
#M  IsFinite( <S> ) . . . . . . . . . . . . . for a semigroup of assoc. words
##
InstallMethod( IsFinite,
    "for a semigroup of assoc. words",
    [ IsSemigroup and IsAssocWordCollection ],
    IsTrivial );


#############################################################################
##
#M  Size( <S> ) . . . . . . . . . . . . . . . . . .  size of a free semigroup
##
InstallMethod( Size,
    "for a free semigroup",
    [ IsSemigroup and IsAssocWordWithOneCollection ],
    function( S )
    if IsTrivial( S ) then
      return 1;
    else
      return infinity;
    fi;
    end );


    #
    # I suspect this methos subsumes the one above SL
    #
    InstallImmediateMethod(Size, IsSemigroup and IsAssocWordCollection
            and HasGeneratorsOfMagma, 0, function(s)
        local x, gens;
        gens := GeneratorsOfMagma(s);
        if Length(gens) = 0 then
            return 0;
        fi;
        for x in gens do
            if Length(x) > 0 then
                return infinity;
            fi;
        od;
        return 1;
    end);



#############################################################################
##
#M  Random( <S> ) . . . . . . . . . . . .  random element of a free semigroup
##
#T use better method for the whole family
##
InstallMethodWithRandomSource(Random,
    "for a random source and a free semigroup",
    [ IsRandomSource, IsSemigroup and IsAssocWordCollection ],
    function( rs, S )
    local len, result, gens, i;

    # Get a random length for the word.
    len:= Random( rs, Integers );
    if 0 <= len then
      len:= 2 * len;
    else
      len:= -2 * len - 1;
    fi;

    # Multiply $'len' + 1$ random generators.
    gens:= GeneratorsOfMagma( S );
    result:= Random( rs, gens );
    for i in [ 1 .. len ] do
      result:= result * Random( rs, gens );
    od;

    # Return the result.
    return result;
    end );


#############################################################################
##
#M  MagmaGeneratorsOfFamily( <F> )
##
InstallMethod( MagmaGeneratorsOfFamily,
    "for a family of free semigroup elements",
    [ IsAssocWordFamily ],
    F -> List( [ 1 .. Length( F!.names ) ],
                 i -> ObjByExtRep( F, 1, 1, [ i, 1 ] ) ) );

# GeneratorsOfSemigroup returns the generators in ascending order

InstallMethod( GeneratorsSmallest,
        "for a free semigroup",
        [ IsFreeSemigroup ],
        GeneratorsOfSemigroup);


#############################################################################
##
#F  FreeSemigroup( [<wfilt>, ]<rank>[, <name>] )
#F  FreeSemigroup( [<wfilt>, ]<name1>[, <name2>[, ...]] )
#F  FreeSemigroup( [<wfilt>, ]<names> )
#F  FreeSemigroup( [<wfilt>, ]infinity[, <name>][, <init>] )
##
InstallGlobalFunction( FreeSemigroup, function( arg )
    local rank,       # number of generators
          F,          # family of free semigroup element objects
          S,          # free semigroup, result
          processed;

    processed := FreeXArgumentProcessor( "FreeSemigroup", "s", arg, true, false );
    rank := Length( processed.names );

    # Construct the family of element objects of our semigroup.
    F := NewFamily( "FreeSemigroupElementsFamily",
          IsAssocWord,
          CanEasilySortElements,
          CanEasilySortElements and processed.lesy );

    # Install the data (names, no. of bits available for exponents, types).
    StoreInfoFreeMagma( F, processed.names, IsAssocWord );

    # Make the semigroup.
    if rank < infinity then
      S:= SemigroupByGenerators( MagmaGeneratorsOfFamily( F ) );
    else
      S:= SemigroupByGenerators( InfiniteListOfGenerators( F ) );
    fi;

    # store the whole semigroup in the family
    FamilyObj(S)!.wholeSemigroup:= S;
    F!.freeSemigroup:=S;

    SetIsFreeSemigroup( S, true );
    SetIsWholeFamily( S, true );
    SetIsTrivial( S, false );
    # Following is written defensively in case 0-generator free semigroups ever
    # become supported in the future.
    SetIsFinite( S, rank = 0 );
    SetIsEmpty( S, rank = 0 );
    SetIsCommutative( S, rank <= 1 );
    return S;
end );


#############################################################################
##
#M  ViewObj( <S> )  . . . . . . . . . . . . . . . . . .  for a free semigroup
##
InstallMethod( ViewObj,
    "for a free semigroup containing the whole family",
    [ IsSemigroup and IsAssocWordCollection and IsWholeFamily ],
    function( S )
    if GAPInfo.ViewLength * 10 < Length( GeneratorsOfMagma( S ) ) then
      Print( "<free semigroup with ", Length( GeneratorsOfMagma( S ) ),
             " generators>" );
    else
      Print( "<free semigroup on the generators ",
             GeneratorsOfMagma( S ), ">" );
    fi;
    end );
