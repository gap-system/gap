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
##  This file contains methods for mutable bases, in the representations of
##  - mutable bases that store immutable bases
##  - mutable bases that use immutable bases for nicer modules
##


#############################################################################
##
#M  ShallowCopy( <MB> ) . . . . . . . . . . . . . . . . . for a mutable basis
##
InstallMethod( ShallowCopy,
    "generic method for mutable basis",
    true,
    [ IsMutableBasis ], 0,
    MB -> ShallowCopy( BasisVectors( MB ) ) );



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
#M  ImmutableBasis( <MB>, <V> )
##
##  This method is needed for the case that one wants to construct a basis
##  of <V>, and successive closures of mutable bases are needed to get a
##  mutable basis; from this one then creates the immutable basis,
##  and wants the particular object <V> to be the underlying module.
##
InstallMethod( ImmutableBasis,
    "for mutable basis, and free left module",
    IsIdenticalObj,
    [ IsMutableBasis, IsFreeLeftModule ], 0,
    function( MB, V )

    local B, vectors;

    B:= ImmutableBasis( MB );

    if not IsIdenticalObj( UnderlyingLeftModule( B ), V ) then

      # If `V' does not know left module generators yet,
      # we store them now.
      vectors:= BasisVectors( B );
      UseBasis( V, vectors );

      # We cannot simply replace the module;
      # for example if `B' is handled by nice/ugly vectors
      # then the module is needed to construct these vectors!
      B:= BasisWithReplacedLeftModule( B, V );
      SetBasis( V, B );

    fi;
    return B;
    end );


#############################################################################
##
#R  IsMutableBasisByImmutableBasisRep( <B> )
##
##  The default case of a mutable basis stores an immutable basis,
##  and constructs a new one whenever the mutable basis is changed.
##
DeclareRepresentation( "IsMutableBasisByImmutableBasisRep",
    IsComponentObjectRep,
    [ "immutableBasis", "leftActingDomain" ] );


#############################################################################
##
#M  MutableBasis( <R>, <vectors> )
#M  MutableBasis( <R>, <vectors>, <zero> )
##
InstallMethod( MutableBasis,
    "generic method for ring and collection",
    true,
    [ IsRing, IsCollection ], 0,
    function( R, vectors )
    local B;

    if ForAll( vectors, IsZero ) then
      return MutableBasis( R, [], vectors[1] );
    fi;

    B:= rec(
             immutableBasis   := Basis(
                                     LeftModuleByGenerators( R, vectors ) ),
             leftActingDomain := R
            );

    return Objectify( NewType( FamilyObj( vectors ),
                                   IsMutableBasis
                               and IsMutable
                               and IsMutableBasisByImmutableBasisRep ),
                      B );
    end );

InstallOtherMethod( MutableBasis,
    "generic method for ring, list, and object",
    true,
    [ IsRing, IsList, IsObject ], 0,
    function( R, vectors, zero )
    local B;

    B:= rec(
             immutableBasis   := Basis(
                                     LeftModuleByGenerators( R, vectors,
                                                             zero ) ),
             leftActingDomain := R
            );

    return Objectify( NewType( CollectionsFamily( FamilyObj( zero ) ),
                                   IsMutableBasis
                               and IsMutable
                               and IsMutableBasisByImmutableBasisRep ),
                      B );
    end );


#############################################################################
##
#M  ViewObj( <MB> ) . . . . . . . . . . . . . . . . . .  view a mutable basis
##
InstallMethod( ViewObj,
    "for mutable basis represented by an immutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisByImmutableBasisRep ], 0,
    function( MB )
    Print( "<mutable basis over " );
    View( MB!.leftActingDomain );
    Print( ", ", Pluralize( NrBasisVectors( MB ), "vector" ), ">" );
    end );


#############################################################################
##
#M  PrintObj( <MB> )  . . . . . . . . . . . . . . . . . print a mutable basis
##
InstallMethod( PrintObj,
    "for mutable basis represented by an immutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisByImmutableBasisRep ], 0,
    function( MB )
    if NrBasisVectors( MB )  = 0 then
      Print( "MutableBasis( ", MB!.leftActingDomain, ", [], ",
             Zero( UnderlyingLeftModule( MB!.immutableBasis ) ), " )" );
    else
      Print( "MutableBasis( ", MB!.leftActingDomain, ", ",
             BasisVectors( MB!.immutableBasis ), " )" );
    fi;
    end );


#############################################################################
##
#M  BasisVectors( <MB> )
##
InstallOtherMethod( BasisVectors,
    "for mutable basis represented by an immutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisByImmutableBasisRep ], 0,
    MB -> BasisVectors( MB!.immutableBasis ) );


#############################################################################
##
#M  CloseMutableBasis( <MB>, <v> )
##
InstallMethod( CloseMutableBasis,
    "for mutable basis represented by an immutable basis, and vector",
    IsCollsElms,
    [ IsMutableBasis and IsMutable and IsMutableBasisByImmutableBasisRep,
      IsVector ], 0,
    function( MB, v )
    local V, B, vectors;
    B:= MB!.immutableBasis;
    V:= UnderlyingLeftModule( B );
    if not v in V then
      vectors:= Concatenation( BasisVectors( B ), [ v ] );
      V:= LeftModuleByGenerators( LeftActingDomain( V ), vectors );
      UseBasis( V, vectors );
      MB!.immutableBasis := Basis( V );
      return true;
    else
      # The basis was not extended.
      return false;
    fi;
    end );


#############################################################################
##
#M  IsContainedInSpan( <MB>, <v> )
##
InstallMethod( IsContainedInSpan,
    "for mutable basis represented by an immutable basis, and vector",
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
    "for mutable basis represented by an immutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisByImmutableBasisRep ], 0,
    MB -> MB!.immutableBasis );


#############################################################################
##
#R  IsMutableBasisViaNiceMutableBasisRep( <B> )
##
DeclareRepresentation( "IsMutableBasisViaNiceMutableBasisRep",
    IsComponentObjectRep,
    [ "leftModule", "niceMutableBasis", "zero" ] );


#############################################################################
##
#F  MutableBasisViaNiceMutableBasisMethod2( <R>, <vectors> )
##
##  *Note* that <vectors> must be a collection.
##  (This must be guaranteed by the installations of this function as
##  method of `MutableBasis'.)
##
InstallGlobalFunction( MutableBasisViaNiceMutableBasisMethod2,
    function( R, vectors )

    local M, nice, B;

    if ForAll( vectors, IsZero ) then
      return MutableBasisViaNiceMutableBasisMethod3( R, [], vectors[1] );
    fi;

    M:= LeftModuleByGenerators( R, vectors );
    if not IsHandledByNiceBasis( M ) then
      Error( "<M> is not handled via nice bases" );
    fi;
    nice:= MutableBasis( R, List( vectors, v -> NiceVector( M, v ) ) );

    B:= rec(
             niceMutableBasis  := nice,
             leftModule := M
            );

    return Objectify( NewType( FamilyObj( vectors ),
                                   IsMutableBasis
                               and IsMutable
                               and IsMutableBasisViaNiceMutableBasisRep ),
                      B );
end );


#############################################################################
##
#F  MutableBasisViaNiceMutableBasisMethod3( <R>, <vectors>, <zero> )
##
InstallGlobalFunction( MutableBasisViaNiceMutableBasisMethod3,
    function( R, vectors, zero )

    local M, B;

    M:= LeftModuleByGenerators( R, vectors, zero );
    B:= rec( leftModule:= M );

    # If `vectors' is empty then in general `M' will *not* be
    # handled by nice bases.
    if IsHandledByNiceBasis( M ) then

      B.niceMutableBasis:= MutableBasis( R,
                                       List( vectors,
                                             v -> NiceVector( M, v ) ),
                                       NiceVector( M, zero ) );

    elif IsEmpty( vectors ) then

      B.zero:= zero;

    else
      Error( "<M> is not handled via nice bases" );
    fi;

    return Objectify( NewType( CollectionsFamily( FamilyObj( zero ) ),
                                   IsMutableBasis
                               and IsMutable
                               and IsMutableBasisViaNiceMutableBasisRep ),
                      B );
end );


#############################################################################
##
#M  ViewObj( <MB> ) . . . . . . . . . . . . . . . . . .  view a mutable basis
##
InstallMethod( ViewObj,
    "for mutable basis represented by a nice mutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisViaNiceMutableBasisRep ], 0,
    function( MB )
    Print( "<mutable basis over " );
    View( LeftActingDomain( MB!.leftModule ) );
    if IsBound( MB!.niceMutableBasis ) then
      Print( ", ",
             Pluralize( NrBasisVectors( MB!.niceMutableBasis ), "vector" ),
             ">" );
    else
      Print( ", 0 vectors>" );
    fi;
    end );


#############################################################################
##
#M  PrintObj( <MB> )  . . . . . . . . . . . . . . . . . print a mutable basis
##
InstallMethod( PrintObj,
    "for mutable basis represented by a nice mutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisViaNiceMutableBasisRep ], 0,
    function( MB )
    if IsBound( MB!.niceMutableBasis ) then
      Print( "MutableBasis( ",
             LeftActingDomain( MB!.leftModule ), ", ",
             BasisVectors( MB!.niceMutableBasis ), ", ",
             Zero( LeftActingDomain( MB!.leftModule ) ), " )" );
    else
      Print( "MutableBasis( ",
             LeftActingDomain( MB!.leftModule ), ", [], ",
             Zero( LeftActingDomain( MB!.leftModule ) ), " )" );
    fi;
    end );


#############################################################################
##
#M  BasisVectors( <MB> )
##
InstallOtherMethod( BasisVectors,
    "for mutable basis represented by a nice mutable basis",
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
    "for mutable basis represented by a nice mutable basis",
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
    "for mutable basis repres. by a nice mutable basis, and vector",
    IsCollsElms,
    [ IsMutableBasis and IsMutable and IsMutableBasisViaNiceMutableBasisRep,
      IsVector ], 0,
    function( MB, v )
    local R, M;
    if IsBound( MB!.niceMutableBasis ) then
      return CloseMutableBasis( MB!.niceMutableBasis,
                         NiceVector( MB!.leftModule, v ) );
    elif v <> MB!.zero then

      # We have to setup the component `niceMutableBasis'.
      R:= LeftActingDomain( MB!.leftModule );
      M:= LeftModuleByGenerators( R, [ v ] );
      if not IsHandledByNiceBasis( M ) then
        Error( "<M> must be handled via nice bases" );
      fi;
      MB!.leftModule:= M;
      MB!.niceMutableBasis:= MutableBasis( R,
                                       [ NiceVector( M, v ) ] );
      return true;

    fi;
    end );


#############################################################################
##
#M  IsContainedInSpan( <MB>, <v> )
##
InstallMethod( IsContainedInSpan,
    "for mutable basis repres. by a nice mutable basis, and vector",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisViaNiceMutableBasisRep, IsVector ], 0,
    function( MB, v )
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
    "for mutable basis represented by a nice mutable basis",
    true,
    [ IsMutableBasis and IsMutableBasisViaNiceMutableBasisRep ], 0,
    function( MB )

    local M, nice, vectors, B;

    M:= MB!.leftModule;

    if IsBound( MB!.niceMutableBasis ) then

      nice:= ImmutableBasis( MB!.niceMutableBasis );
      vectors:= List( BasisVectors( nice ), v -> UglyVector( M, v ) );
      if not IsEmpty( vectors ) then
        M:= LeftModuleByGenerators( LeftActingDomain( M ), vectors );
        SetNiceFreeLeftModule( M, UnderlyingLeftModule( nice ) );
      fi;

#T use that we have the nice basis already!
#T (do not construct it twice!)

    else

      vectors:= [];

    fi;
    B:= BasisNC( M, vectors );
    if HasIsSmallList( vectors ) then
      SetIsSmallList( B, IsSmallList( vectors ) );
    fi;
    return B;
    end );
