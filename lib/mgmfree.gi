#############################################################################
##
#W  mgmfree.gi                  GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for free magmas.
##
##  Element objects of free magmas are nonassociative words.
##  For the external representation see the file 'word.gi'.
##
##  (Note that a free semigroup is not a free magma, so we must not deal
##  with objects in `IsWord' here but with objects in `IsNonassocWord'.)
##
Revision.mgmfree_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  IsWholeFamily( <M> )  . . . . . . . . .  is a free magma the whole family
##
##  <M> contains the whole family of its elements if and only if all
##  magma generators of the family are among the magma generators of <M>.
##
InstallMethod( IsWholeFamily,
    "method for a free magma",
    true,
    [ IsMagma and IsNonassocWordCollection ], 0,
    M -> IsSubset( GeneratorsMagmaFamily( ElementsFamily( FamilyObj( M ) ) ),
                   GeneratorsOfMagma( M ) ) );


#############################################################################
##
#T  Iterator( <M> ) . . . . . . . . . . . . . . . . iterator for a free magma
##


#############################################################################
##
#T  Enumerator( <M> ) . . . . . . . . . . . . . . enumerator for a free magma
##


#############################################################################
##
#M  IsFinite( <M> ) . . . . . . . . . . . . .  for a magma of nonassoc. words
##
InstallMethod( IsFinite,
    "method for a magma of nonassoc. words",
    true,
    [ IsMagma and IsNonassocWordCollection ], 0,
    IsTrivial );


#############################################################################
##
#M  Size( <M> ) . . . . . . . . . . . . . . . . . . . .  size of a free magma
##
InstallMethod( Size,
    "method for a free magma",
    true,
    [ IsMagma and IsNonassocWordWithOneCollection ], 0,
    function( M )
    if IsTrivial( M ) then
      return 1;
    else
      return infinity;
    fi;
    end );


#############################################################################
##
#M  Random( <S> ) . . . . . . . . . . . . . .  random element of a free magma
##
#T use better method for the whole family
##
InstallMethod( Random,
    "method for a free magma",
    true,
    [ IsMagma and IsNonassocWordCollection ], 0,
    function( M )

    local len,
          result,
          gens,
          i;

    # Get a random length for the word.
    len:= Random( Integers );
    if 0 <= len then
      len:= 2 * len;
    else
      len:= -2 * len - 1;
    fi;

    # Multiply $'len' + 1$ random generators.
    gens:= GeneratorsOfMagma( M );
    result:= Random( gens );
    for i in [ 1 .. len ] do
      if Random( [ 0, 1 ] ) = 0 then
        result:= result * Random( gens );
      else
        result:= Random( gens ) * result;
      fi;
    od;

    # Return the result.
    return result;
    end );


#############################################################################
##
#M  GeneratorsMagmaFamily( <F> )  . . . . . for family of free magma elements
##
InstallMethod( GeneratorsMagmaFamily,
    "method for a family of free magma elements",
    true,
    [ IsNonassocWordFamily ], 0,
    F -> List( [ 1 .. Length( F!.names ) ], i -> ObjByExtRep( F, i ) ) );


#############################################################################
##
#F  FreeMagma( <rank> )
#F  FreeMagma( <rank>, <name> )
#F  FreeMagma( <name1>, <name2>, ... )
#F  FreeMagma( <names> )
##
FreeMagma := function( arg )

    local   names,      # list of generators names
            F,          # family of free magma element objects
            M;          # free magma, result

    # Get and check the argument list, and construct names if necessary.
    if   Length( arg ) = 1 and arg[1] = infinity then
      names:= InfiniteListOfNames( "x" );
    elif Length( arg ) = 2 and arg[1] = infinity then
      names:= InfiniteListOfNames( arg[2] );
    elif Length( arg ) = 1 and IsInt( arg[1] ) and 0 < arg[1] then
      names:= List( [ 1 .. arg[1] ],
                    i -> Concatenation( "x", String(i) ) );
    elif Length( arg ) = 2 and IsInt( arg[1] ) and 0 < arg[1] then
      names:= List( [ 1 .. arg[1] ],
                    i -> Concatenation( arg[2], String(i) ) );
    elif 1 <= Length( arg ) and ForAll( arg, IsString ) then
      names:= arg;
    elif Length( arg ) = 1 and IsList( arg[1] ) and not IsEmpty( arg[1]) then
      names:= arg[1];
    else
      Error("usage: FreeMagma(<name1>,<name2>..),FreeMagma(<rank>)");
    fi;

    # Construct the family of element objects of our magma.
    F:= NewFamily( "FreeMagmaElementsFamily", IsNonassocWord );

    # Store the names and the default type.
    F!.names:= names;
    F!.defaultType:= NewType( F, IsNonassocWord and IsBracketRep );

    # Make the magma.
    if IsFinite( names ) then
      M:= MagmaByGenerators( GeneratorsMagmaFamily( F ) );
    else
      M:= MagmaByGenerators( InfiniteListOfGenerators( F ) );
    fi;

    SetIsWholeFamily( M, true );
    SetIsTrivial( M, false );
    return M;
end;


#############################################################################
##
#E  mgmfree.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



