#############################################################################
##
#W  grpfree.gi                  GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for free groups.
##
Revision.grpfree_gi :=
    "@(#)$Id$";

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
##  consisting of $k$, say, pairs of generators/exponents, enumerate all
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
IsFreeGroupIterator := NewRepresentation( "IsFreeGroupIterator",
    IsIterator and IsComponentObjectRep,
    [ "family", "nrgenerators", "exp", "word", "counter", "length" ] );

InstallMethod( NextIterator, true, [ IsFreeGroupIterator ], 0,
    function( iter )

    local word,
          oldword,
          exp,
          len,
          pos,
          i;

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

InstallMethod( IsDoneIterator, true, [ IsFreeGroupIterator ], 0,
    ReturnFalse );

InstallMethod( Iterator, true,
    [ IsAssocWordWithInverseCollection and IsWholeFamily ], 0,
#T only for the whole family ! (generalize!)
    G -> Objectify( NewKind( IteratorsFamily, IsFreeGroupIterator ),
                    rec(
                         family         := ElementsFamily( FamilyObj( G ) ),
                         nrgenerators   := Length( GeneratorsOfGroup( G ) ),
                         exp            := 0,
                         word           := [],
                         length         := 0,
                         counter        := [ 0, 0 ]
                        )
                   ) );

#############################################################################
##
#M  Enumerator( <G> )
##
IsFreeGroupEnumerator := NewRepresentation( "IsFreeGroupEnumerator",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "family", "nrgenerators" ] );

InstallMethod( \[\], true, [ IsFreeGroupEnumerator, IsPosRat and IsInt ], 0,
    function( enum, nr )

    local n,
          2n,
          nn,
          l,
          power,
          word,
          exp,
          maxexp,
          cc,
          sign,
          i,
          c;

    if nr = 1 then
      return One( enum!.family );
    fi;

    n:= enum!.nrgenerators;
    2n:= 2 * n;
    nn:= 2n - 1;

    # Compute the length of the word corresponding to 'nr'.
    l:= 0;
    power:= 2n;
    nr:= nr - 1;
    while 0 < nr do
      nr:= nr - power;
      l:= l+1;
      power:= power * nn;
    od;
    nr:= nr + power / nn - 1;

    # Compute the vector of the '(nr + 1)'-th element of length 'l'.
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

      # translate 'c'
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

InstallMethod( Position,
    function(F1,F2,F3) return IsCollsElms(F1,F2); end,
    [ IsFreeGroupEnumerator, IsAssocWordWithInverse, IsZeroCyc ], 0,
    function( enum, elm, zero )

    local l,
          len,
          i,
          n,
          2n,
          nn,
          nr,
          j,
          power,
          c,
          cc,
          exp;

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

InstallMethod( Enumerator, true,
    [ IsAssocWordWithInverseCollection and IsWholeFamily ], 0,
#T generalize!
    function( G )
    local enum;
    enum:= Objectify( NewKind( FamilyObj( G ), IsFreeGroupEnumerator ),
                    rec( family        := ElementsFamily( FamilyObj( G ) ),
                         nrgenerators  := Length( GeneratorsOfGroup( G ) ) )
                     );
    SetUnderlyingCollection( enum, G );
    return enum;
    end );


#############################################################################
##
#M  IsWholeFamily( <G> )
##
##  If all magma generators of the family are among the group generators
##  of <G> then <G> contains the whole family of its elements.
##
InstallMethod( IsWholeFamily, true,
    [ IsAssocWordWithInverseCollection and IsGroup ], 0,
    function( M )
    if IsSubset( GeneratorsMagmaFamily( FamilyObj( M ) ),
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
InstallMethod( Random, true,
    [ IsAssocWordWithInverseCollection and IsGroup ], 0,
    function( M )

    local len,
          result,
          gens,
          i;

    # Get a random length for the word.
    len:= Random( Integers );
    if 0 < len then
      len:= 2 * len;
    elif len < 0 then
      len:= -2 * len - 1;
    else
      return One( M );
    fi;

    # Multiply 'len' random generator powers.
    gens:= GeneratorsOfGroup( M );
    result:= Random( gens ) ^ Random( Integers );
    for i in [ 2 .. len ] do
      result:= result * Random( gens ) ^ Random( Integers );
    od;

    # Return the result.
    return result;
    end );


#############################################################################
##
#M  Size( <G> )
##
InstallMethod( Size, true,
    [ IsAssocWordWithInverseCollection and IsGroup ], 0,
    function( G )
    if IsTrivial( G ) then
      return 1;
    else
      return infinity;
    fi;
    end );


#############################################################################
##
#M  GeneratorsMagmaFamily( <F> )
##
InstallMethod( GeneratorsMagmaFamily, true,
    [ IsAssocWordWithInverseFamily ], 0,
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
#F  FreeGroup( <rank> ) . . . . . . . . . . . . . .  free group of given rank
#F  FreeGroup( <rank>, <name> )
#F  FreeGroup( <name1>, <name2>, ... )
##
FreeGroup := function ( arg )

    local   names,      # list of generators names
            F,          # family of free group element objects
            G;          # free group, result

    # Get and check the argument list, and construct names if necessary.
    if Length( arg ) = 1 and IsInt( arg[1] ) and 0 <= arg[1] then
      names:= List( [ 1 .. arg[1] ],
                    i -> Concatenation( "f.", String(i) ) );
    elif Length( arg ) = 2 and IsInt( arg[1] ) and 0 <= arg[1] then
      names:= List( [ 1 .. arg[1] ],
                    i -> Concatenation( arg[2], String(i) ) );
    elif 1 <= Length( arg ) and ForAll( arg, IsString ) then
      names:= arg;
    elif Length( arg ) = 1 and IsList( arg[1] ) then
      names:= arg[1];
    else
      Error("usage: FreeGroup(<name1>,<name2>..) or FreeGroup(<rank>)");
    fi;

    # Construct the family of element objects of our group.
    F:= NewFamily( "FreeGroupElementsFamily", IsAssocWordWithInverse );

    # Install the data (names, no. of bits available for exponents, kinds).
    StoreInfoFreeMagma( F, names, IsAssocWordWithInverse );

    # Make the group.
    if IsEmpty( names ) then
      G:= GroupByGenerators( [], One( F ) );
    else
      G:= GroupByGenerators( List( [ 1 .. Length( names ) ],
                     i -> ObjByExtRep( F, 1, 1, [ i, 1 ] ) ) );

    fi;

    SetIsWholeFamily( G, true );

    # Store whether the group is trivial.
    SetIsTrivial( G, Length( names ) = 0 );

    # Return the free group.
    return G;
end;


#############################################################################
##
#E  grpfree.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



