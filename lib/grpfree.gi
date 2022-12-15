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
##  This file contains the methods for free groups.
##
##  Free groups are treated as   special cases of finitely presented  groups.
##  In addition,   elements  of  a free   group are
##  (associative) words, that is they have a normal  form that allows an easy
##  equalitity test.
##


#############################################################################
##
#M  Iterator( <G> )
##
##  The implementation of iterator and enumerator for free groups is more
##  complicated than for free semigroups and monoids, since one has to be
##  careful to avoid cancellation of generators and their inverses when
##  building words.
##  So the iterator for a free group of rank $n$ uses the following ordering.
##  Enumerate signless words (that is, forget about the signs of exponents)
##  as given by the enumerator of free monoids, and for each such word
##  consisting of $k$ pairs of generators/exponents, enumerate all
##  $2^k$ possibilities of signs for the exponents.
##
##  The enumerator for a free group uses a different succession, in order to
##  make the bijection of words and positive integers easy to calculate.
##
##  There are exactly $2n (2n-1)^{l-1}$ words of length $l$, for $l > 0$.
##
##  So the word corresponding to the integer
##  $m = 1 + \sum_{i=1}^{l-1} 2n (2n-1)^{i-1} + m^{\prime}$,
##  with $1 \leq m^{\prime} \leq 2n (2n-1)^l$,
##  is the $m^{\prime}$-th word of length $l$.
##
##  Write $m^{\prime} - 1 = c_1 - 1 + \sum_{i=2}^l (c_i - 1) 2n (2n-1)^{i-2}$
##  where $1 \leq c_1 \leq 2n$ and $1 \leq c_i \leq 2n-1$ for
##  $2 \leq i \leq l$.
##
##  Let $(s_1, s_2, \ldots, s_{2n}) = (g_1, g_1^{-1}, g_2, \ldots, g_n^{-1})$
##  and translate the coefficient vector $(c_1, c_2, \ldots, c_l)$ to
##  $s(c_1) s(c_2) \cdots s(c_l)$, defined by $s(c_1) = s_{c_1}$, and
##  \[ s(c_{i+1}) = \left\{ \begin{array}{lcl}
##         s_{c_{i+1}}   & ; & c_i \equiv 1 \bmod 2, c_{i+1} \leq c_i \\
##         s_{c_{i+1}}   & ; & c_i \equiv 0 \bmod 2, c_{i+1} \leq c_{i-2} \\
##         s_{c_{i+1}+1} & ; & \mbox{\rm otherwise}
##                            \end{array} \right.    \]
##
BindGlobal( "NextIterator_FreeGroup", function( iter )
    local word, oldword, exp, len, pos, i;

    # Increase the counter.
    # Get the next sign distribution of same length if possible.
    word:= iter!.word;
    oldword:= ShallowCopy( word );
    exp:= iter!.exp;
    len:= Length( word );
    pos:= 2;
    while pos <= len and word[ pos ] < 0 do
      pos:= pos + 2;
    od;
    if pos <= len then
      for i in [ 2, 4 .. pos ] do
        word[i]:= - word[i];
      od;
    else

      # We have enumerated all sign vectors,
      # so we must take the next tuple.
      FreeSemigroup_NextWordExp( iter );

    fi;

    return ObjByExtRep( iter!.family, 1, exp, oldword );
    end );

BindGlobal( "ShallowCopy_FreeGroup", iter -> rec(
                 family         := iter!.family,
                 nrgenerators   := iter!.nrgenerators,
                 exp            := iter!.exp,
                 word           := ShallowCopy( iter!.word ),
                 length         := iter!.length,
                 counter        := ShallowCopy( iter!.counter ) ) );

InstallMethod( Iterator,
    "for a free group",
    [ IsAssocWordWithInverseCollection and IsWholeFamily and IsGroup ],
    G -> IteratorByFunctions( rec(
             IsDoneIterator := ReturnFalse,
             NextIterator   := NextIterator_FreeGroup,
             ShallowCopy    := ShallowCopy_FreeGroup,

             family         := ElementsFamily( FamilyObj( G ) ),
             nrgenerators   := Length( GeneratorsOfGroup( G ) ),
             exp            := 0,
             word           := [],
             length         := 0,
             counter        := [ 0, 0 ] ) ) );


#############################################################################
##
#M  Enumerator( <G> )
##
BindGlobal( "ElementNumber_FreeGroup",
    function( enum, nr )
    local n, 2n, nn, l, power, word, exp, maxexp, cc, sign, i, c;

    if nr = 1 then
      return One( enum!.family );
    fi;

    n:= enum!.nrgenerators;
    2n:= 2 * n;
    nn:= 2n - 1;

    # Compute the length of the word corresponding to `nr'.
    l:= 0;
    power:= 2n;
    nr:= nr - 1;
    while 0 < nr do
      nr:= nr - power;
      l:= l+1;
      power:= power * nn;
    od;
    nr:= nr + power / nn - 1;

    # Compute the vector of the `(nr + 1)'-th element of length `l'.
    exp:= 0;
    maxexp:= 1;
    c:= nr mod 2n;
    nr:= ( nr - c ) / 2n;
    cc:= c;
    if c mod 2 = 0 then
      sign:= 1;
    else
      sign:= -1;
      c:= c-1;
    fi;
    word:= [ c/2 + 1 ];
    for i in [ 1 .. l ] do

      # translate `c'
      if cc < c or ( cc mod 2 = 1 and cc-2 < c ) then
        c:= c+1;
      fi;

      if c = cc then
        exp:= exp + 1;
      else
        Add( word, sign * exp );
        if maxexp < exp then
          maxexp:= exp;
        fi;
        exp:= 1;

        cc:= c;
        if c mod 2 = 0 then
          sign:= 1;
        else
          sign:= -1;
          c:= c-1;
        fi;
        Add( word, c/2 + 1 );
      fi;
      c:= nr mod nn;
      nr:= ( nr - c ) / nn;
    od;
    Add( word, sign * exp );

    # Return the element.
    return ObjByExtRep( enum!.family, 1, maxexp, word );
    end );

BindGlobal( "NumberElement_FreeGroup",
    function( enum, elm )
    local l, len, i, n, 2n, nn, nr, j, power, c, cc, exp;

    if not IsCollsElms( FamilyObj( enum ), FamilyObj( elm ) ) then
      return fail;
    fi;

    elm:= ExtRepOfObj( elm );
    l:= Length( elm );

    if l = 0 then
      return 1;
    fi;

    # Calculate the length of the word.
    len:= 0;
    for i in [ 2, 4 .. l ] do
      exp:= elm[i];
      if 0 < exp then
        len:= len + elm[i];
      else
        len:= len - elm[i];
      fi;
    od;

    # Calculate the number of words of smaller length, plus 1.
    n:= enum!.nrgenerators;
    2n:= 2 * n;
    nn:= 2n - 1;
    nr:= 2;
    power:= 2n;
    for i in [ 1 .. len-1 ] do
      nr:= nr + power;
      power:= power * nn;
    od;

    # Add the position in the words of length 'len'.
    c:= 2 * elm[1] - 1;
    exp:= elm[2];
    if 0 < exp then
      c:= c-1;
    else
      exp:= -exp;
    fi;
    nr:= nr + c;
    power:= 2n;
    cc:= c;
    c:= c - ( c mod 2 );
    for j in [ 2 .. exp ] do
      nr:= nr + c * power;
      power:= power * nn;
    od;

    for i in [ 4, 6 .. l ] do
      c:= 2 * elm[ i-1 ] - 1;
      exp:= elm[i];
      if 0 < exp then
        c:= c-1;
      else
        exp:= -exp;
      fi;
      if cc < c or ( cc mod 2 = 1 and cc - 2 < c ) then
        cc:= c;
        c:= c - 1;
      else
        cc:= c;
      fi;
      nr:= nr + c * power;
      power:= power * nn;
      c:= cc - ( cc mod 2 );
      for j in [ 2 .. exp ] do
        nr:= nr + c * power;
        power:= power * nn;
      od;
    od;

    return nr;
    end );

InstallMethod( Enumerator,
    "for enumerator of a free group",
    [ IsAssocWordWithInverseCollection and IsWholeFamily and IsGroup ],
    G -> EnumeratorByFunctions( G, rec(
             NumberElement := NumberElement_FreeGroup,
             ElementNumber := ElementNumber_FreeGroup,

             family        := ElementsFamily( FamilyObj( G ) ),
             nrgenerators  := Length( ElementsFamily(
                                          FamilyObj( G ) )!.names ) ) ) );

#############################################################################
##
#M  IsWholeFamily( <G> )
##
##  If all magma generators of the family are among the group generators
##  of <G> then <G> contains the whole family of its elements.
##
InstallMethod( IsWholeFamily,
    "for a free group",
    [ IsAssocWordWithInverseCollection and IsGroup ],
    function( M )
    if IsSubset( MagmaGeneratorsOfFamily( ElementsFamily( FamilyObj( M ) ) ),
                 GeneratorsOfGroup( M ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Random( <M> )
##
#T isn't this a generic group method? (without guarantee about distribution)
##
InstallMethodWithRandomSource( Random,
    "for a random source and a free group",
    [ IsRandomSource, IsAssocWordWithInverseCollection and IsGroup ],
    function( rs, M )
    local len, result, gens, i;

    # Get a random length for the word.
    len:= Random( rs, Integers );
    if 0 < len then
      len:= 2 * len;
    elif len < 0 then
      len:= -2 * len - 1;
    else
      return One( M );
    fi;

    # Multiply 'len' random generator powers.
    gens:= GeneratorsOfGroup( M );
    result:= Random( rs, gens ) ^ Random( rs, Integers );
    for i in [ 2 .. len ] do
      result:= result * Random( rs, gens ) ^ Random( rs, Integers );
    od;

    # Return the result.
    return result;
    end );


#############################################################################
##
#M  Size( <G> ) . . . . . . . . . . . . . . . . . . . . . .  for a free group
##
InstallMethod( Size,
    "for a free group",
    [ IsAssocWordWithInverseCollection and IsGroup ],
    function( G )
    if IsTrivial( G ) then
      return 1;
    else
      return infinity;
    fi;
    end );


#############################################################################
##
#M  IsCommutative( <G> ) . . . . . . . . . . . . . . . . . . for a free group
##
InstallMethod( IsCommutative,
    "for a free group",
    [ IsFreeGroup and HasIsFinitelyGeneratedGroup ],
    function( G )
    if not IsFinitelyGeneratedGroup( G ) then
      return false;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  IsSolvableGroup( <G> ) . . . . . . . . . . . . . . . . . for a free group
##
InstallMethod( IsSolvableGroup,
    "for a free group",
    [ IsFreeGroup ],
    10, # rank it higher than the method in the fr package
    G -> IsAbelian( G ) );


#############################################################################
##
#M  MagmaGeneratorsOfFamily( <F> )
##
InstallMethod( MagmaGeneratorsOfFamily,
    "for a family of assoc. words",
    [ IsAssocWordWithInverseFamily ],
    function( F )
    local gens;

    # Make the generators.
    gens:= List( [ 1 .. Length( F!.names ) ],
                 i -> ObjByExtRep( F, 1, 1, [ i, 1 ] ) );
    Append( gens, List( [ 1 .. Length( F!.names ) ],
                 i -> ObjByExtRep( F, 1, 1, [ i, -1 ] ) ) );
    Add( gens, One( F ) );

    # Return the magma generators.
    return gens;
    end );

#############################################################################
##
#M  Order <elm> )
##
InstallMethod( Order,
        "free group element",
        [ IsElementOfFreeGroup ],
        0,
        function(elt)
           if IsOne(elt) then
               return 1;
           else
               return infinity;
           fi;
        end);

# the following method returns a lex-minimal generating set for a free group
# it relies on the (unguaranteed) ordering of free group elements, that
# inverses of generators come before the generators, and generators of low
# number come before those of higher number.

InstallMethod( GeneratorsSmallest,
        "for a free group",
        [ IsFreeGroup ],
        x->List(GeneratorsOfGroup(x),Inverse));

#############################################################################
##
#F  FreeGroup( [<wfilt>,]<rank>[, <name>] ) . . . .  free group of given rank
#F  FreeGroup( [<wfilt>,][<name1>[, <name2>[, ...]]] )
#F  FreeGroup( [<wfilt>,]<names> )
#F  FreeGroup( [<wfilt>,]infinity[, <name>][, <init>] )
##
InstallGlobalFunction( FreeGroup, function ( arg )
    local rank,       # number of generators
          F,          # family of free group element objects
          G,          # free group, result
          processed;

    processed := FreeXArgumentProcessor( "FreeGroup", "f", arg, true, true );
    rank := Length( processed.names );

    # Construct the family of element objects of our group.
    F := NewFamily( "FreeGroupElementsFamily",
                    IsAssocWordWithInverse and IsElementOfFreeGroup,
                    CanEasilySortElements,
                    CanEasilySortElements and processed.lesy );

    # Install the data (names, no. of bits available for exponents, types).
    StoreInfoFreeMagma( F, processed.names, IsAssocWordWithInverse and
                                            IsElementOfFreeGroup );

    # Make the group.
    if rank = 0 then
      G:= GroupByGenerators( [], One( F ) );
    elif rank < infinity then
      G:= GroupByGenerators( List( [ 1 .. rank ],
                                   i -> ObjByExtRep( F, 1, 1, [ i, 1 ] ) ) );
    else
      G:= GroupByGenerators( InfiniteListOfGenerators( F ) );
    fi;

    SetIsWholeFamily( G, true );

    # Store whether group is finitely generated / trivial / abelian / solvable.
    SetIsFinitelyGeneratedGroup( G, rank < infinity );
    SetIsTrivial( G, rank = 0 );
    SetIsAbelian( G, rank <= 1 );
    SetIsSolvableGroup( G, rank <= 1 );

    # Store the whole group in the family.
    FamilyObj(G)!.wholeGroup := G;
    F!.freeGroup:=G;
    SetFilterObj(G,IsGroupOfFamily);

    return G;
end );


#############################################################################
##
#M  FreeGeneratorsOfFpGroup( <F> )
##
InstallMethod( FreeGeneratorsOfFpGroup,
    "for a free group",
    [ IsSubgroupFpGroup and IsGroupOfFamily and IsFreeGroup ],
    GeneratorsOfGroup );


#############################################################################
##
#M  RelatorsOfFpGroup( <F> )
##
InstallMethod( RelatorsOfFpGroup,
    "for a free group",
    [ IsSubgroupFpGroup and IsGroupOfFamily and IsFreeGroup ],
    F -> [] );


#############################################################################
##
#M  FreeGroupOfFpGroup( <F> )
##
InstallMethod( FreeGroupOfFpGroup,
    "for a free group",
    [ IsSubgroupFpGroup and IsGroupOfFamily and IsFreeGroup ],
    IdFunc );


#############################################################################
##
#M  UnderlyingElement( w )
##
InstallMethod( UnderlyingElement,
    "for an element of a free group",
    [ IsElementOfFreeGroup ],
    IdFunc );


#############################################################################
##
#M  ElementOfFpGroup( w )
##
InstallOtherMethod( ElementOfFpGroup,
    "for a family of free group elements, and an assoc. word",
    [ IsElementOfFreeGroupFamily and IsAssocWordWithInverseFamily,
      IsAssocWordWithInverse ],
    function( fam, w ) return w; end );


#############################################################################
##
#M  ViewObj(<G>)
##
InstallMethod( ViewObj,
    "subgroup of free group",
    [ IsFreeGroup ],
function(G)
  if IsGroupOfFamily(G) then
    if IsEmpty(GeneratorsOfGroup(G)) then
      Print("<free group of rank zero>");
    elif Length(GeneratorsOfGroup(G)) > GAPInfo.ViewLength * 10 then
      Print("<free group with ",Length(GeneratorsOfGroup(G))," generators>");
    else
      Print("<free group on the generators ",GeneratorsOfGroup(G),">");
    fi;
  else
    Print("Group(");
    if HasGeneratorsOfGroup(G) then
      if not IsBound(G!.gensWordLengthSum) then
        G!.gensWordLengthSum:=Sum(List(GeneratorsOfGroup(G),Length));
      fi;
      if G!.gensWordLengthSum <= GAPInfo.ViewLength * 30 then
        Print(GeneratorsOfGroup(G));
      else
        Print("<",Pluralize(Length(GeneratorsOfGroup(G)),"generator"),">");
      fi;
    else
      Print("<free, no generators known>");
    fi;
    Print(")");
  fi;
end);


#############################################################################
##
#M  \.( <F>, <n> )  . . . . . . . . . .  access to generators of a free group
##
InstallAccessToGenerators( IsSubgroupFpGroup and IsGroupOfFamily
                                             and IsFreeGroup,
                           "free group containing the whole family",
                           GeneratorsOfMagmaWithInverses );
