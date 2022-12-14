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
##  This file contains the methods for free monoids.
##


#############################################################################
##
#M  IsWholeFamily( <M> )  . . . . . . . . . is a free monoid the whole family
##
##  <M> contains the whole family of its elements if and only if all
##  magma generators of the family are among the monoid generators of <M>.
##
InstallMethod( IsWholeFamily,
    "for a free monoid",
    [ IsAssocWordWithOneCollection and IsMonoid ],
    M -> IsSubset( MagmaGeneratorsOfFamily( FamilyObj( M ) ),
                   GeneratorsOfMagmaWithOne( M ) ) );


#############################################################################
##
#M  Iterator( <M> ) . . . . . . . . . . . . . . .  iterator for a free monoid
##
##  Iterator and enumerator of free monoids are implemented very similar
##  to iterator and enumerator for free semigroups.
##  The only difference is the existence of the empty word.
##
InstallMethod( Iterator,
    "for a free monoid",
    [ IsAssocWordWithOneCollection and IsWholeFamily ],
    function( M )

    # A free group needs another method.
    # A trivial group needs another method.
    if IsAssocWordWithInverseCollection( M ) or IsTrivial( M ) then
      TryNextMethod();
    fi;

    return IteratorByFunctions( rec(
               IsDoneIterator := ReturnFalse,
               NextIterator   := NextIterator_FreeSemigroup,
               ShallowCopy    := ShallowCopy_FreeSemigroup,

               family         := ElementsFamily( FamilyObj( M ) ),
               nrgenerators   := Length( GeneratorsOfMagmaWithOne( M ) ),
               exp            := 0,
               word           := [],
               counter        := [ 0, 0 ],
               length         := 0 ) );
    end );


#############################################################################
##
#M  Enumerator( <M> ) . . . . . . . . . . . . .  enumerator for a free monoid
##
InstallMethod( Enumerator,
    "for a free monoid",
    [ IsAssocWordWithOneCollection and IsWholeFamily and IsMonoid ],
    function( M )

    # A free group needs another method.
    # A trivial group needs another method.
    if IsAssocWordWithInverseCollection( M ) or IsTrivial( M ) then
      TryNextMethod();
    fi;

    return EnumeratorByFunctions( M, rec(
               ElementNumber := ElementNumber_FreeMonoid,
               NumberElement := NumberElement_FreeMonoid,

               family        := ElementsFamily( FamilyObj( M ) ),
               nrgenerators  := Length( ElementsFamily(
                                            FamilyObj( M ) )!.names ) ) );
    end );


#############################################################################
##
#M  Random( <M> ) . . . . . . . . . . . . . . random element of a free monoid
##
#T use better method for the whole family, and for abelian monoids
##
InstallMethodWithRandomSource( Random,
    "for a random source and a free monoid",
    [ IsRandomSource, IsMonoid and IsAssocWordWithOneCollection ],
    function( rs, M )
    local len, result, gens, i;

    if IsTrivial( M ) then
      return One( M );
    fi;

    # Get a random length for the word.
    len:= Random( rs, Integers );
    if 0 < len then
      len:= 2 * len;
    elif len < 0 then
      len:= -2 * len - 1;
    else
      return One( M );
    fi;

    # Multiply 'len' random generators.
    gens:= GeneratorsOfMagmaWithOne( M );
    result:= Random( rs, gens );
    for i in [ 2 .. len ] do
      result:= result * Random( rs, gens );
    od;

    # Return the result.
    return result;
    end );


#############################################################################
##
#M  Size( <M> ) . . . . . . . . . . . . . . . . . . . . size of a free monoid
##
InstallMethod( Size,
    "for a free monoid",
    [ IsMonoid and IsAssocWordWithOneCollection ],
    function( M )
    if IsTrivial( M ) then
      return 1;
    else
      return infinity;
    fi;
    end );


#############################################################################
##
#A  One( <Fam> )
##
InstallOtherMethod( One,
    "for a family of free monoid elements",
    [ IsAssocWordWithOneFamily ],
    F -> ObjByExtRep( F, 1, 1, [] ) );


#############################################################################
##
#A  MagmaGeneratorsOfFamily( <F> )
##
InstallMethod( MagmaGeneratorsOfFamily,
    "for a family of free monoid elements",
    [ IsAssocWordWithOneFamily ],
    function( F )
    local gens;

    # Make the generators.
    gens:= List( [ 1 .. Length( F!.names ) ],
                 i -> ObjByExtRep( F, 1, 1, [ i, 1 ] ) );
    Add( gens, One( F ) );

    # Return the magma generators.
    return gens;
    end );

# GeneratorsOfMonoid returns the generators in ascending order

InstallMethod( GeneratorsSmallest,
        "for a free monoid",
        [ IsFreeMonoid ],
        GeneratorsOfMonoid);

#############################################################################
##
#F  FreeMonoid( [<wfilt>, ]<rank>[, <name>] )
#F  FreeMonoid( [<wfilt>, ][<name1>[, <name2>[, ...]]] )
#F  FreeMonoid( [<wfilt>, ]<names> )
#F  FreeMonoid( [<wfilt>, ]infinity[, <name>][, <init>] )
##
InstallGlobalFunction( FreeMonoid, function( arg )
    local rank,       # number of generators
          F,          # family of free monoid element objects
          M,          # free monoid, result
          processed;

    processed := FreeXArgumentProcessor( "FreeMonoid", "m", arg, true, true );
    rank := Length( processed.names );

    # Construct the family of element objects of our monoid.
    F:= NewFamily( "FreeMonoidElementsFamily",
          IsAssocWordWithOne,
          CanEasilySortElements,
          CanEasilySortElements and processed.lesy );

    # Install the data (names, no. of bits available for exponents, types).
    StoreInfoFreeMagma( F, processed.names, IsAssocWordWithOne );

    # Make the monoid
    if rank = 0 then
      M:= MonoidByGenerators( [], One(F) );
    elif rank < infinity then
      M:= MonoidByGenerators( List( [ 1 .. rank ],
                              i -> ObjByExtRep( F, 1, 1, [ i, 1 ] ) ) );
    else
      M:= MonoidByGenerators( InfiniteListOfGenerators( F ) );
    fi;

    # store the whole monoid in the family
    FamilyObj(M)!.wholeMonoid:= M;
    F!.freeMonoid:=M;
    SetIsFreeMonoid( M, true);
    SetIsWholeFamily( M, true );

    SetIsTrivial( M, rank = 0 );
    SetIsFinite( M, rank = 0 );
    SetIsFinitelyGeneratedMonoid(M, rank < infinity );
    SetIsCommutative( M, rank <= 1 );

    return M;
end );


#############################################################################
##
#M  ViewObj( <M> )  . . . . . . . . . . . . . . . . . . . . for a free monoid
##
InstallMethod( ViewObj,
    "for a free monoid containing the whole family",
    [ IsMonoid and IsAssocWordCollection and IsWholeFamily ],
    function( M )
    if IsEmpty( GeneratorsOfMagmaWithOne( M ) ) then
      Print( "<free monoid of rank zero>" );
    elif GAPInfo.ViewLength * 10 < Length( GeneratorsOfMagmaWithOne( M ) ) then
      Print( "<free monoid with ", Length( GeneratorsOfMagmaWithOne( M ) ),
             " generators>" );
    else
      Print( "<free monoid on the generators ",
             GeneratorsOfMagmaWithOne( M ), ">" );
    fi;
    end );
