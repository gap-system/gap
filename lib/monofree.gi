#############################################################################
##
#W  monofree.gi                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for free monoids.
##
Revision.monofree_gi:=
    "@(#)$Id$";


#############################################################################
##
#M  IsWholeFamily( <M> )  . . . . . . . . . is a free monoid the whole family
##
##  <M> contains the whole family of its elements if and only if all
##  magma generators of the family are among the monoid generators of <M>.
##
InstallMethod( IsWholeFamily,
    "method for a free monoid",
    true,
    [ IsAssocWordWithOneCollection and IsMonoid ], 0,
    M -> IsSubset( GeneratorsMagmaFamily( FamilyObj( M ) ),
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
    "method for a free monoid",
    true,
    [ IsAssocWordWithOneCollection and IsWholeFamily ], 0,
    function( M )

    # A free free group needs another method.
    # A trivial group needs another method.
    if IsAssocWordWithInverseCollection( M ) or IsTrivial( M ) then
      TryNextMethod();
    fi;

    return Objectify( NewKind( IteratorsFamily, IsFreeSemigroupIterator ),
            rec(
                 family       := ElementsFamily( FamilyObj( M ) ),
                 nrgenerators := Length( GeneratorsOfMagmaWithOne( M ) ),
                 exp          := 0,
                 word         := [],
                 counter      := [ 0, 0 ],
                 length       := 0
                )
           );
    end );


#############################################################################
##
#M  Enumerator( <M> ) . . . . . . . . . . . . .  enumerator for a free monoid
##
IsFreeMonoidEnumerator := NewRepresentation( "IsFreeMonoidEnumerator",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "family", "nrgenerators" ] );

InstallMethod( \[\],
    "method for enumerator of a free monoid",
    true,
    [ IsFreeMonoidEnumerator, IsPosRat and IsInt ], 0,
    FreeMonoid_ElementNumber );

InstallMethod( Position,
    "method for enumerator of a free monoid",
    function(F1,F2,F3) return IsCollsElms(F1,F2); end,
    [ IsFreeMonoidEnumerator, IsObject, IsZeroCyc ], 0,
    FreeMonoid_NumberElement );

InstallMethod( Enumerator,
    "method for a free monoid",
    true,
    [ IsAssocWordWithOneCollection and IsWholeFamily and IsMonoid ], 0,
    function( M )
    local enum;

    # A free group needs another method.
    # A trivial group needs another method.
    if IsAssocWordWithInverseCollection( M ) or IsTrivial( M ) then
      TryNextMethod();
    fi;

    enum:= Objectify( NewKind( FamilyObj( M ), IsFreeMonoidEnumerator ),
           rec( family       := ElementsFamily( FamilyObj( M ) ),
                nrgenerators := Length( GeneratorsOfMagmaWithOne( M ) ) ) );
    SetUnderlyingCollection( enum, M );
    return enum;
    end );


#############################################################################
##
#M  Random( <M> ) . . . . . . . . . . . . . . random element of a free monoid
##
#T use better method for the whole family, and for abelian monoids
##
InstallMethod( Random,
    "method for a free monoid",
    true,
    [ IsMonoid and IsAssocWordWithOneCollection ], 0,
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
    "method for a free monoid",
    true,
    [ IsMonoid and IsAssocWordWithOneCollection ], 0,
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
    "method for a family of free monoid elements",
    true,
    [ IsAssocWordWithOneFamily ], 0,
    F -> ObjByExtRep( F, 1, 1, [] ) );


#############################################################################
##
#A  GeneratorsMagmaFamily( <F> )
##
InstallMethod( GeneratorsMagmaFamily,
    "method for a family of free monoid elements",
    true,
    [ IsAssocWordWithOneFamily ], 0,
    function( F )

    local gens;

    # Make the generators.
    gens:= List( [ 1 .. Length( F!.names ) ],
                 i -> ObjByExtRep( F, 1, 1, [ i, 1 ] ) );
    Add( gens, One( F ) );

    # Return the magma generators.
    return gens;
    end );


#############################################################################
##
#F  FreeMonoid( <n> )
#F  FreeMonoid( <names> )
##
##  is a free monoid on <n> generators, or on generators that shall be
##  printed as the strings in the list <names>.
##
FreeMonoid := function( n )

    local   names,      # list of generators names
            F,          # family of free monoid element objects
            M;          # free monoid, result

    # Check the arguments.
    if IsInt( n ) and 0 <= n then
      names:= List( [ 1 .. n ], x -> Concatenation( "m.", String( x ) ) );
    elif IsList( n ) and 0 <= Length( n ) and ForAll( n, IsString ) then
      names:= n;
      n:= Length( names );
    else
      Error( "<n> must be a nonnegative integer or a list of strings" );
    fi;

    # Construct the family of element objects of our monoid.
    F:= NewFamily( "FreeMonoidElementsFamily", IsAssocWordWithOne );

    # Install the data (names, no. of bits available for exponents, kinds).
    StoreInfoFreeMagma( F, names, IsAssocWordWithOne );

    # Make the monoid
    if IsEmpty( names ) then
      M:= MonoidByGenerators( [], One( F ) );
    else
      M:= MonoidByGenerators( List( [ 1 .. Length( names ) ],
                            i -> ObjByExtRep( F, 1, 1, [ i, 1 ] ) ) );
    fi;
    SetIsWholeFamily( M, true );

    # Store whether the monoid is trivial.
    SetIsTrivial( M, n = 0 );

    # Return the free monoid.
    return M;
end;


#############################################################################
##
#E  monofree.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



