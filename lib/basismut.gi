#############################################################################
##
#W  basismut.gi                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods for mutable bases, in the representations of
##  - mutable bases that store immutable bases
##  - mutable bases that use immutable bases for nicer modules
##
Revision.basismut_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  NrBasisVectors( <MB> )  . . . . . . . . . . . . . . . for a mutable basis
##
##  The default method constructs the basis vctors, and returns the length of
##  this list.
##
##  (Better methods for special representations avoid to construct the basis
##  vectors.)
##
InstallMethod( NrBasisVectors,
    "generic method for mutable basis",
    true,
    [ IsMutableBasis ], 0,
    MB -> Length( BasisVectors( MB ) ) );


#############################################################################
##
#R  IsMutableBasisByImmutableBasisRep( <B> )
##
##  The default case of a mutable basis stores an immutable basis,
##  and constructs a new one whenever the mutable basis is changed.
##
IsMutableBasisByImmutableBasisRep := NewRepresentation(
    "IsMutableBasisByImmutableBasisRep",
    IsComponentObjectRep and IsMutable,
    [ "immutableBasis", "leftActingDomain" ] );


#############################################################################
##
#M  MutableBasisByGenerators( <R>, <vectors> )
#M  MutableBasisByGenerators( <R>, <vectors>, <zero> )
##
InstallMethod( MutableBasisByGenerators,
    "generic method for ring and collection",
    true,
    [ IsRing, IsCollection ], 0,
    function( R, vectors )
    local B;

    if ForAll( vectors, IsZero ) then
      return MutableBasisByGenerators( R, [], vectors[1] );
    fi;

    B:= rec(
             immutableBasis   := BasisOfDomain(
                                     LeftModuleByGenerators( R, vectors ) ),
             leftActingDomain := R
            );

    return Objectify( NewKind( FamilyObj( vectors ),
                                   IsMutableBasis
                               and IsMutableBasisByImmutableBasisRep ),
                      B );
    end );

InstallOtherMethod( MutableBasisByGenerators,
    "generic method for ring, list, and zero vector",
    true,
    [ IsRing, IsList, IsVector ], 0,
    function( R, vectors, zero )
    local B;

    B:= rec(
             immutableBasis   := BasisOfDomain(
                                     LeftModuleByGenerators( R, vectors,
                                                             zero ) ),
             leftActingDomain := R
            );

    return Objectify( NewKind( CollectionsFamily( FamilyObj( zero ) ),
                                   IsMutableBasis
                               and IsMutableBasisByImmutableBasisRep ),
                      B );
    end );


#############################################################################
##
#M  PrintObj( <MB> )  . . . . . . . . . . . . . . . . . print a mutable basis
##
InstallMethod( PrintObj,
    "method for mutable basis represented by an immutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisByImmutableBasisRep ], 0,
    function( MB )
    Print( "<mutable basis over ", MB!.leftActingDomain, ", ",
           NrBasisVectors( MB ), " vectors>" );
    end );


#############################################################################
##
#M  BasisVectors( <MB> )
##
InstallOtherMethod( BasisVectors,
    "method for mutable basis represented by an immutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisByImmutableBasisRep ], 0,
    MB -> BasisVectors( MB!.immutableBasis ) );


#############################################################################
##
#M  CloseMutableBasis( <MB>, <v> )
##
InstallMethod( CloseMutableBasis,
    "method for mutable basis represented by an immutable basis, and vector",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisByImmutableBasisRep, IsVector ], 0,
    function( MB, v )
    local V, B, vectors;
    B:= MB!.immutableBasis;
    V:= UnderlyingLeftModule( B );
    if not v in V then
      vectors:= Concatenation( BasisVectors( B ), [ v ] );
      V:= LeftModuleByGenerators( LeftActingDomain( V ), vectors );
      UseBasis( V, vectors );
      MB!.immutableBasis := BasisOfDomain( V );
    fi;
    end );


#############################################################################
##
#M  IsContainedInSpan( <MB>, <v> )
##
InstallMethod( IsContainedInSpan,
    "method for mutable basis represented by an immutable basis, and vector",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisByImmutableBasisRep, IsVector ], 0,
    function( MB, v )
    return v in UnderlyingLeftModule( MB!.immutableBasis );
    end );


#############################################################################
##
#M  ImmutableBasis( <MB> )
##
InstallMethod( ImmutableBasis,
    "method for mutable basis represented by an immutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisByImmutableBasisRep ], 0,
    MB -> MB!.immutableBasis );


#############################################################################
##
#R  IsMutableBasisViaNiceMutableBasisRep( <B> )
##
IsMutableBasisViaNiceMutableBasisRep := NewRepresentation(
    "IsMutableBasisViaNiceMutableBasisRep",
    IsComponentObjectRep and IsMutable,
    [ "leftModule", "niceMutableBasis", "zero" ] );


#############################################################################
##
#F  MutableBasisViaNiceMutableBasisMethod2( <R>, <vectors> )
##
##  *Note* that <vectors> must be a collection.
##  (This must be guaranteed by the installations of this function as
##  method of 'MutableBasisByGenerators'.)
##
MutableBasisViaNiceMutableBasisMethod2 := function( R, vectors )

    local M, nice, B;

    if ForAll( vectors, IsZero ) then
      return MutableBasisViaNiceMutableBasisMethod3( R, [], vectors[1] );
    fi;

    M:= LeftModuleByGenerators( R, vectors );
    PrepareNiceFreeLeftModule( M );
#T is this an argument against binding 'NiceVector' to a module?
#T (would a homomorphism be more elegant?)

    nice:= MutableBasisByGenerators( R,
                                     List( vectors,
                                           v -> NiceVector( M, v ) ) );

    B:= rec(
             niceMutableBasis  := nice,
             leftModule := M
            );

    return Objectify( NewKind( FamilyObj( vectors ),
                                   IsMutableBasis
                               and IsMutableBasisViaNiceMutableBasisRep ),
                      B );
end;


#############################################################################
##
#F  MutableBasisViaNiceMutableBasisMethod3( <R>, <vectors>, <zero> )
##
MutableBasisViaNiceMutableBasisMethod3 := function( R, vectors, zero )

    local M, nice, B;

    M:= LeftModuleByGenerators( R, vectors, zero );
    B:= rec( leftModule:= M );

    # If 'vectors' is empty then in general 'M' will *not* be
    # handled by nice bases.
    if IsHandledByNiceBasis( M ) then

      PrepareNiceFreeLeftModule( M );
#T is this an argument against binding 'NiceVector' to a module?
#T (would a homomorphism be more elegant?)

      B.niceMutableBasis:= MutableBasisByGenerators( R,
                                       List( vectors,
                                             v -> NiceVector( M, v ) ),
                                       NiceVector( M, zero ) );

    elif IsEmpty( vectors ) then

      B.zero:= zero;

    else
      Error( "<M> is not handled via nice bases" );
    fi;

    return Objectify( NewKind( CollectionsFamily( FamilyObj( zero ) ),
                                   IsMutableBasis
                               and IsMutableBasisViaNiceMutableBasisRep ),
                      B );
end;


#############################################################################
##
#M  PrintObj( <MB> )  . . . . . . . . . . . . . . . . . print a mutable basis
##
InstallMethod( PrintObj,
    "method for mutable basis represented by a nice mutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisViaNiceMutableBasisRep ], 0,
    function( MB )
    if IsBound( MB!.niceMutableBasis ) then
      Print( "<mutable basis over ", LeftActingDomain( MB!.leftModule ),
             ", ", NrBasisVectors( MB!.niceMutableBasis ), " vectors>" );
    else
      Print( "<mutable basis over ", LeftActingDomain( MB!.leftModule ),
             ", 0 vectors>" );
    fi;
    end );


#############################################################################
##
#M  BasisVectors( <MB> )
##
InstallOtherMethod( BasisVectors,
    "method for mutable basis represented by a nice mutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisViaNiceMutableBasisRep ], 0,
    function( MB )
    local M;
    if IsBound( MB!.niceMutableBasis ) then
      M:= MB!.leftModule;
      return Immutable( List( BasisVectors( MB!.niceMutableBasis ),
                              v -> UglyVector( M, v ) ) );
    else
      return Immutable( [] );
    fi;
    end );


#############################################################################
##
#M  NrBasisVectors( <MB> )  .  for a mutable basis using a nice mutable basis
##
InstallMethod( NrBasisVectors,
    "method for mutable basis represented by a nice mutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisViaNiceMutableBasisRep ], 0,
    function( MB )
    if IsBound( MB!.niceMutableBasis ) then
      return Length( BasisVectors( MB!.niceMutableBasis ) );
    else
      return 0;
    fi;
    end );


#############################################################################
##
#M  CloseMutableBasis( <MB>, <v> )
##
InstallMethod( CloseMutableBasis,
    "method for mutable basis repres. by a nice mutable basis, and vector",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisViaNiceMutableBasisRep, IsVector ], 0,
    function( MB, v )
    local R, M;
    if IsBound( MB!.niceMutableBasis ) then
      CloseMutableBasis( MB!.niceMutableBasis,
                         NiceVector( MB!.leftModule, v ) );
    elif v <> MB!.zero then

      # We have to setup the component 'niceMutableBasis'.
      R:= LeftActingDomain( MB!.leftModule );
      M:= LeftModuleByGenerators( R, [ v ] );
      if not IsHandledByNiceBasis( M ) then
        Error( "<M> must be handled via nice bases" );
      fi;
      MB!.leftModule:= M;
      MB!.niceMutableBasis:= MutableBasisByGenerators( R,
                                       [ NiceVector( M, v ) ] );

    fi;
    end );


#############################################################################
##
#M  IsContainedInSpan( <MB>, <v> )
##
InstallMethod( IsContainedInSpan,
    "method for mutable basis repres. by a nice mutable basis, and vector",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisViaNiceMutableBasisRep, IsVector ], 0,
    function( MB, v )
    local R, M;
    if IsBound( MB!.niceMutableBasis ) then
      return IsContainedInSpan( MB!.niceMutableBasis,
                                NiceVector( MB!.leftModule, v ) );
    else
      return v = MB!.zero;
    fi;
    end );


#############################################################################
##
#M  ImmutableBasis( <MB> )
##
InstallMethod( ImmutableBasis,
    "method for mutable basis represented by a nice mutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisViaNiceMutableBasisRep ], 0,
    function( MB )

    local M, nice, vectors;

    M:= MB!.leftModule;

    if IsBound( MB!.niceMutableBasis ) then

      nice:= ImmutableBasis( MB!.niceMutableBasis );
      vectors:= List( BasisVectors( nice ), v -> UglyVector( M, v ) );
      if not IsEmpty( vectors ) then
        M:= LeftModuleByGenerators( LeftActingDomain( M ), vectors );
        PrepareNiceFreeLeftModule( M );
        SetNiceFreeLeftModule( M, UnderlyingLeftModule( nice ) );
      fi;

#T use that we have the nice basis already!
#T (do not construct it twice!)

    else

      vectors:= [];

    fi;
    return BasisByGeneratorsNC( M, vectors );
    end );


#############################################################################
##
#E  basismut.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



