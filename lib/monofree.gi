#############################################################################
##
#W  monofree.gi                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
    "for a free monoid",
    true,
    [ IsAssocWordWithOneCollection and IsMonoid ], 0,
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
    true,
    [ IsAssocWordWithOneCollection and IsWholeFamily ], 0,
    function( M )

    # A free free group needs another method.
    # A trivial group needs another method.
    if IsAssocWordWithInverseCollection( M ) or IsTrivial( M ) then
      TryNextMethod();
    fi;

    return Objectify( NewType( IteratorsFamily, IsFreeSemigroupIteratorRep ),
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
DeclareRepresentation( "IsFreeMonoidEnumeratorRep",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "family", "nrgenerators" ] );

InstallMethod( \[\],
    "for enumerator of a free monoid",
    true,
    [ IsFreeMonoidEnumeratorRep, IsPosInt ], 0,
    FreeMonoid_ElementNumber );

InstallMethod( Position,
    "for enumerator of a free monoid",
    IsCollsElmsX,
    [ IsFreeMonoidEnumeratorRep, IsObject, IsZeroCyc ], 0,
    FreeMonoid_NumberElement );

InstallMethod( Enumerator,
    "for a free monoid",
    true,
    [ IsAssocWordWithOneCollection and IsWholeFamily and IsMonoid ], 0,
    function( M )
    local enum;

    # A free group needs another method.
    # A trivial group needs another method.
    if IsAssocWordWithInverseCollection( M ) or IsTrivial( M ) then
      TryNextMethod();
    fi;

    enum:= Objectify( NewType( FamilyObj( M ), IsFreeMonoidEnumeratorRep ),
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
#A  MagmaGeneratorsOfFamily( <F> )
##
InstallMethod( MagmaGeneratorsOfFamily,
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
#F  FreeMonoid( <rank> )
#F  FreeMonoid( <rank>, <name> )
#F  FreeMonoid( <name1>, <name2>, ... )
#F  FreeMonoid( <names> )
#F  FreeMonoid( infinity, <name>, <init> )
##
InstallGlobalFunction( FreeMonoid, function( arg )

    local   names,      # list of generators names
            F,          # family of free monoid element objects
            M;          # free monoid, result

    # Get and check the argument list, and construct names if necessary.
    if   Length( arg ) = 1 and arg[1] = infinity then
      names:= InfiniteListOfNames( "m" );
    elif Length( arg ) = 2 and arg[1] = infinity then
      names:= InfiniteListOfNames( arg[2] );
    elif Length( arg ) = 3 and arg[1] = infinity then
      names:= InfiniteListOfNames( arg[2], arg[3] );
    elif Length( arg ) = 1 and IsInt( arg[1] ) and 0 <= arg[1] then
      names:= List( [ 1 .. arg[1] ],
                    i -> Concatenation( "m", String(i) ) );
      MakeImmutable( names );
    elif Length( arg ) = 2 and IsInt( arg[1] ) and 0 <= arg[1] then
      names:= List( [ 1 .. arg[1] ],
                    i -> Concatenation( arg[2], String(i) ) );
      MakeImmutable( names );
    elif Length( arg ) = 1 and IsList( arg[1] ) and IsEmpty( arg[1] ) then
      names:= arg[1];
    elif 1 <= Length( arg ) and ForAll( arg, IsString ) then
      names:= arg;
    elif Length( arg ) = 1 and IsList( arg[1] ) then
      names:= arg[1];
    else
      Error("usage: FreeMonoid(<name1>,<name2>..) or FreeMonoid(<rank>)");
    fi;

    # Handle the trivial case.
    if IsEmpty( names ) then
      return FreeGroup( 0 );
    fi;

    # Construct the family of element objects of our monoid.
    F:= NewFamily( "FreeMonoidElementsFamily", IsAssocWordWithOne );

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

    # Return the free monoid.
    return M;
end );


#############################################################################
##
#M  ViewObj( <M> )  . . . . . . . . . . . . . . . . . . . . for a free monoid
##
InstallMethod( ViewObj,
    "for a free monoid containing the whole family",
    true,
    [ IsMonoid and IsAssocWordCollection and IsWholeFamily ], 0,
    function( M )
    if VIEWLEN * 10 < Length( GeneratorsOfMagmaWithOne( M ) ) then
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

