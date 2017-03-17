#############################################################################
##
#W  monofree.gi                 GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
InstallMethod( Random,
    "for a free monoid",
    [ IsMonoid and IsAssocWordWithOneCollection ],
    function( M )
    local len, result, gens, i;

    # Get a random length for the word.
    len:= Random( Integers );
    if 0 < len then
      len:= 2 * len;
    elif len < 0 then
      len:= -2 * len - 1;
    else
      return One( M );
    fi;

    # Multiply 'len' random generators.
    gens:= GeneratorsOfMagmaWithOne( M );
    result:= Random( gens );
    for i in [ 2 .. len ] do
      result:= result * Random( gens );
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
#F  FreeMonoid( <rank> )
#F  FreeMonoid( <rank>, <name> )
#F  FreeMonoid( <name1>, <name2>, ... )
#F  FreeMonoid( <names> )
#F  FreeMonoid( infinity, <name>, <init> )
##
InstallGlobalFunction( FreeMonoid, function( arg )
    local names,      # list of generators names
          F,          # family of free monoid element objects
          zarg,
          lesy,       # filter for letter or syllable words family
          M;          # free monoid, result

  lesy:=IsLetterWordsFamily; # default
  if IsFilter(arg[1]) then
    lesy:=arg[1];
    zarg:=arg{[2..Length(arg)]};
  else
    zarg:=arg;
  fi;

    # Get and check the argument list, and construct names if necessary.
    if   Length( zarg ) = 1 and zarg[1] = infinity then
      names:= InfiniteListOfNames( "m" );
    elif Length( zarg ) = 2 and zarg[1] = infinity then
      names:= InfiniteListOfNames( zarg[2] );
    elif Length( zarg ) = 3 and zarg[1] = infinity then
      names:= InfiniteListOfNames( zarg[2], zarg[3] );
    elif Length( zarg ) = 1 and IsInt( zarg[1] ) and 0 <= zarg[1] then
      names:= List( [ 1 .. zarg[1] ],
                    i -> Concatenation( "m", String(i) ) );
      MakeImmutable( names );
    elif Length( zarg ) = 2 and IsInt( zarg[1] ) and 0 <= zarg[1] then
      names:= List( [ 1 .. zarg[1] ],
                    i -> Concatenation( zarg[2], String(i) ) );
      MakeImmutable( names );
    elif Length( zarg ) = 1 and IsList( zarg[1] ) and IsEmpty( zarg[1] ) then
      names:= zarg[1];
    elif 1 <= Length( zarg ) and ForAll( zarg, IsString ) then
      names:= zarg;
    elif Length( zarg ) = 1 and IsList( zarg[1] )
                            and ForAll( zarg[1], IsString ) then
      names:= zarg[1];
    else
      Error("usage: FreeMonoid(<name1>,<name2>..) or FreeMonoid(<rank>)");
    fi;

    # Handle the trivial case.
    if IsEmpty( names ) then
      M:=FreeGroup( 0 );
      # we still need to set some monoid specific entries to keep
      # the monoid code happy
      F:=ElementsFamily(FamilyObj(M));
      FamilyObj(M)!.wholeMonoid:= M;
      F!.freeMonoid:=M;
      return M;
    fi;

    # deal with letter words family types
    if lesy=IsLetterWordsFamily then
      if Length(names)>127 then
	lesy:=IsWLetterWordsFamily;
      else
	lesy:=IsBLetterWordsFamily;
      fi;
    elif lesy=IsBLetterWordsFamily and Length(names)>127 then
      lesy:=IsWLetterWordsFamily;
    fi;

    # Construct the family of element objects of our monoid.
    F:= NewFamily( "FreeMonoidElementsFamily", IsAssocWordWithOne,
			  CanEasilySortElements, # the free monoid can.
			  CanEasilySortElements # the free monoid can.
			  and lesy);

    # Install the data (names, no. of bits available for exponents, types).
    StoreInfoFreeMagma( F, names, IsAssocWordWithOne );

    # Make the monoid
    if IsFinite( names ) then
      M:= MonoidByGenerators( List( [ 1 .. Length( names ) ],
                              i -> ObjByExtRep( F, 1, 1, [ i, 1 ] ) ) );
    else
      M:= MonoidByGenerators( InfiniteListOfGenerators( F ) );
    fi;

    SetIsFreeMonoid(M,true);

    SetIsWholeFamily( M, true );
    SetIsTrivial( M, false );

		# store the whole monoid in the family
    FamilyObj(M)!.wholeMonoid:= M;
    F!.freeMonoid:=M;


    # Return the free monoid.
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
    if GAPInfo.ViewLength * 10 < Length( GeneratorsOfMagmaWithOne( M ) ) then
      Print( "<free monoid with ", Length( GeneratorsOfMagmaWithOne( M ) ),
             " generators>" );
    else
      Print( "<free monoid on the generators ",
             GeneratorsOfMagmaWithOne( M ), ">" );
    fi;
    end );


#############################################################################
##
#E

