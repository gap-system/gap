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
##  This file contains methods for (left/right/two-sided) ideals
##  in algebras and algebras-with-one.
##


#############################################################################
##
#F  IsLeftIdealFromGenerators( <AsStructA>, <AsStructS>, <GensA>, <GensS> )
##
BindGlobal( "IsLeftIdealFromGenerators",
    function( AsStructA, AsStructS, GeneratorsA, GeneratorsS )
    return function( A, S )

    local inter,   # intersection of left acting domains
          gensS,   # suitable generators of `S'
          a,       # loop over suitable generators of `A'
          i;       # loop over `gensS'

    if not IsSubset( A, S ) then
      return false;
    elif LeftActingDomain( A ) <> LeftActingDomain( S ) then
      inter:= Intersection2( LeftActingDomain( A ), LeftActingDomain( S ) );
      return IsLeftIdeal( AsStructA( inter, A ), AsStructS( inter, S ) );
    fi;

    gensS:= GeneratorsS( S );
    for a in GeneratorsA( A ) do
      for i in gensS do
        if not a * i in S then
          return false;
        fi;
      od;
    od;
    return true;
    end;
end );


#############################################################################
##
#F  IsRightIdealFromGenerators( <AsStructA>, <AsStructS>, <GensA>, <GensS> )
##
BindGlobal( "IsRightIdealFromGenerators",
    function( AsStructA, AsStructS, GeneratorsA, GeneratorsS )
    return function( A, S )

    local inter,   # intersection of left acting domains
          gensS,   # suitable generators of `S'
          a,       # loop over suitable generators of `A'
          i;       # loop over `gensS'

    if not IsSubset( A, S ) then
      return false;
    elif LeftActingDomain( A ) <> LeftActingDomain( S ) then
      inter:= Intersection2( LeftActingDomain( A ), LeftActingDomain( S ) );
      return IsRightIdeal( AsStructA( inter, A ), AsStructS( inter, S ) );
    fi;

    gensS:= GeneratorsS( S );
    for a in GeneratorsA( A ) do
      for i in gensS do
        if not i * a in S then
          return false;
        fi;
      od;
    od;
    return true;
    end;
end );


#############################################################################
##
#M  IsLeftIdealOp( <A>, <S> )
##
##  Check whether the subalgebra <S> is a left ideal in <A>,
##  i.e., whether <S> is contained in <A> and $a * i$ lies in <S>
##  for all basis vectors $a$ of <A> and $s$ of <S>.
##
##  For associative algebras(-with-one), we need to check only the products
##  of algebra(-with-one) generators.
##
InstallOtherMethod( IsLeftIdealOp,
    "for FLMLOR and free left module",
    IsIdenticalObj,
    [ IsFLMLOR, IsFreeLeftModule ], 0,
    IsLeftIdealFromGenerators( AsFLMLOR, AsLeftModule,
                               GeneratorsOfLeftModule,
                               GeneratorsOfLeftModule ) );

InstallOtherMethod( IsLeftIdealOp,
    "for associative FLMLOR and free left module",
    IsIdenticalObj,
    [ IsFLMLOR and IsAssociative, IsFreeLeftModule ], 0,
    IsLeftIdealFromGenerators( AsFLMLOR, AsLeftModule,
                               GeneratorsOfLeftOperatorRing,
                               GeneratorsOfLeftModule ) );

InstallOtherMethod( IsLeftIdealOp,
    "for associative FLMLOR-with-one and free left module",
    IsIdenticalObj,
    [ IsFLMLORWithOne and IsAssociative, IsFreeLeftModule ], 0,
    IsLeftIdealFromGenerators( AsFLMLOR, AsLeftModule,
                               GeneratorsOfLeftOperatorRingWithOne,
                               GeneratorsOfLeftModule ) );

InstallMethod( IsLeftIdealOp,
    "for associative FLMLOR and FLMLOR",
    IsIdenticalObj,
    [ IsFLMLOR and IsAssociative, IsFLMLOR ], 0,
    IsLeftIdealFromGenerators( AsFLMLOR, AsFLMLOR,
                               GeneratorsOfLeftOperatorRing,
                               GeneratorsOfLeftOperatorRing ) );


#############################################################################
##
#M  IsRightIdealOp( <A>, <S> )
##
##  Check whether the subalgebra <S> is a right ideal in <A>,
##  i.e., whether <S> is contained in <A> and $s * a$ lies in <S>
##  for all basis vectors $a$ of <A> and $s$ of <S>.
##
##  For associative algebras(-with-one), we need to check only the products
##  of algebra(-with-one) generators.
##
InstallOtherMethod( IsRightIdealOp,
    "for FLMLOR and free left module",
    IsIdenticalObj,
    [ IsFLMLOR, IsFreeLeftModule ], 0,
    IsRightIdealFromGenerators( AsFLMLOR, AsLeftModule,
                                GeneratorsOfLeftModule,
                                GeneratorsOfLeftModule ) );

InstallOtherMethod( IsRightIdealOp,
    "for associative FLMLOR and free left module",
    IsIdenticalObj,
    [ IsFLMLOR and IsAssociative, IsFreeLeftModule ], 0,
    IsRightIdealFromGenerators( AsFLMLOR, AsLeftModule,
                                GeneratorsOfLeftOperatorRing,
                                GeneratorsOfLeftModule ) );

InstallOtherMethod( IsRightIdealOp,
    "for associative FLMLOR-with-one and free left module",
    IsIdenticalObj,
    [ IsFLMLORWithOne and IsAssociative, IsFreeLeftModule ], 0,
    IsRightIdealFromGenerators( AsFLMLOR, AsLeftModule,
                                GeneratorsOfLeftOperatorRingWithOne,
                                GeneratorsOfLeftModule ) );

InstallMethod( IsRightIdealOp,
    "for associative FLMLOR and FLMLOR",
    IsIdenticalObj,
    [ IsFLMLOR and IsAssociative, IsFLMLOR ], 0,
    IsRightIdealFromGenerators( AsFLMLOR, AsFLMLOR,
                                GeneratorsOfLeftOperatorRing,
                                GeneratorsOfLeftOperatorRing ) );


#############################################################################
##
#M  IsTwoSidedIdealOp( <A>, <S> )
##
##  Check whether the subspace or subalgebra $S$ is an ideal in $A$,
##  i.e., whether $a s \in S$ and $s a \in S$
##  for all basis vectors $a$ of $A$ and $s$ of $S$.
##
InstallOtherMethod( IsTwoSidedIdealOp,
    "for commutative FLMLOR and free left module",
    IsIdenticalObj,
    [ IsFLMLOR and IsCommutative, IsFreeLeftModule ], 0,
    IsLeftIdeal );

InstallOtherMethod( IsTwoSidedIdealOp,
    "for anti-commutative FLMLOR and free left module",
    IsIdenticalObj,
    [ IsFLMLOR and IsAnticommutative, IsFreeLeftModule ], 0,
    IsLeftIdeal );

InstallOtherMethod( IsTwoSidedIdealOp,
    "for FLMLOR and free left module",
    IsIdenticalObj,
    [ IsFLMLOR, IsFreeLeftModule ], 0,
    function( A, S )
    return IsLeftIdeal( A, S ) and IsRightIdeal( A, S );
#T Check containment only once!
    end );


#############################################################################
##
#M  TwoSidedIdealByGenerators( <A>, <gens> ) .  create an ideal in an algebra
#M  LeftIdealByGenerators( <A>, <gens> ) .  create a left ideal in an algebra
#M  RightIdealByGenerators( <A>, <gens> )  . create right ideal in an algebra
##
##  We need special methods to make ideals in algebras themselves algebras.
##
InstallMethod( TwoSidedIdealByGenerators,
    "for FLMLOR and collection",
    IsIdenticalObj,
    [ IsFLMLOR, IsCollection ], 0,
    function( A, gens )
    local I, lad;
    I:= Objectify( NewType( FamilyObj( A ),
                                IsFLMLOR
                            and IsAttributeStoringRep ),
                   rec() );
    lad:= LeftActingDomain( A );
    SetLeftActingDomain( I, lad );
    SetGeneratorsOfTwoSidedIdeal( I, gens );
    SetLeftActingRingOfIdeal( I, A );
    SetRightActingRingOfIdeal( I, A );

    CheckForHandlingByNiceBasis( lad, gens, I, false );
    return I;
    end );

InstallMethod( LeftIdealByGenerators,
    "for FLMLOR and collection",
    IsIdenticalObj,
    [ IsFLMLOR, IsCollection ], 0,
    function( A, gens )
    local I, lad;
    I:= Objectify( NewType( FamilyObj( A ),
                                IsFLMLOR
                            and IsAttributeStoringRep ),
                   rec() );
    lad:= LeftActingDomain( A );
    SetLeftActingDomain( I, lad );
    SetGeneratorsOfLeftIdeal( I, gens );
    SetLeftActingRingOfIdeal( I, A );

    CheckForHandlingByNiceBasis( lad, gens, I, false );
    return I;
    end );

InstallMethod( RightIdealByGenerators,
    "for FLMLOR and collection",
    IsIdenticalObj,
    [ IsFLMLOR, IsCollection ], 0,
    function( A, gens )
    local I, lad;
    I:= Objectify( NewType( FamilyObj( A ),
                                IsFLMLOR
                            and IsAttributeStoringRep ),
                   rec() );
    lad:= LeftActingDomain( A );
    SetLeftActingDomain( I, lad );
    SetGeneratorsOfRightIdeal( I, gens );
    SetRightActingRingOfIdeal( I, A );

    CheckForHandlingByNiceBasis( lad, gens, I, false );
    return I;
    end );


InstallMethod( TwoSidedIdealByGenerators,
    "for FLMLOR and empty list",
    true,
    [ IsFLMLOR, IsList and IsEmpty ], 0,
    function( A, gens )
    local I, lad;
    I:= Objectify( NewType( FamilyObj( A ),
                                IsFLMLOR
                            and IsTrivial
                            and IsAttributeStoringRep ),
                   rec() );
    lad:= LeftActingDomain( A );
    SetLeftActingDomain( I, lad );
    SetGeneratorsOfTwoSidedIdeal( I, gens );
    SetGeneratorsOfLeftModule( I, gens );
    SetLeftActingRingOfIdeal( I, A );
    SetRightActingRingOfIdeal( I, A );

    CheckForHandlingByNiceBasis( lad, gens, I, false );
    return I;
    end );

InstallMethod( LeftIdealByGenerators,
    "for FLMLOR and empty list",
    true,
    [ IsFLMLOR, IsList and IsEmpty ], 0,
    function( A, gens )
    local I, lad;
    I:= Objectify( NewType( FamilyObj( A ),
                                IsFLMLOR
                            and IsTrivial
                            and IsAttributeStoringRep ),
                   rec() );
    lad:= LeftActingDomain( A );
    SetLeftActingDomain( I, lad );
    SetGeneratorsOfLeftIdeal( I, gens );
    SetGeneratorsOfLeftModule( I, gens );
    SetLeftActingRingOfIdeal( I, A );

    CheckForHandlingByNiceBasis( lad, gens, I, false );
    return I;
    end );

InstallMethod( RightIdealByGenerators,
    "for FLMLOR and empty list",
    true,
    [ IsFLMLOR, IsList and IsEmpty ], 0,
    function( A, gens )
    local I, lad;
    I:= Objectify( NewType( FamilyObj( A ),
                                IsFLMLOR
                            and IsTrivial
                            and IsAttributeStoringRep ),
                   rec() );
    lad:= LeftActingDomain( A );
    SetLeftActingDomain( I, lad );
    SetGeneratorsOfRightIdeal( I, gens );
    SetGeneratorsOfLeftModule( I, gens );
    SetRightActingRingOfIdeal( I, A );

    CheckForHandlingByNiceBasis( lad, gens, I, false );
    return I;
    end );


#############################################################################
##
#M  GeneratorsOfLeftModule( <I> ) . . . . . . . . . . . . . . .  for an ideal
#M  GeneratorsOfLeftOperatorRing( <I> ) . . . . . . . . . . . .  for an ideal
##
##  We need methods to compute algebra or left module generators from the
##  known (left/right/two-sided) ideal generators.
##  For that, we use `MutableBasisOfClosureUnderAction' in the case that the
##  acting algebra is known to be associative,
##  and `MutableBasisOfIdealInNonassociativeAlgebra' otherwise.
##
##  Note that by the call to `UseBasis', afterwards left module generators
##  are known, also if `GeneratorsOfLeftOperatorRing' had been called.
##
BindGlobal( "LeftModuleGeneratorsForIdealFromGenerators", function( I, Igens, R, side )

    local F,        # left acting domain of `I'
          maxdim,   # upper bound for the dimension of `I'
          mb,       # mutable basis of `I'
          gens;     # left module generators of `I', result

    F:= LeftActingDomain( I );
    if not IsFLMLOR( R ) then
      TryNextMethod();
    elif not IsSubset( F, LeftActingDomain( R ) ) then
      R:= AsFLMLOR( Intersection( F, LeftActingDomain( R ) ), R );
    fi;

    # Get an upper bound for the dimension of the ideal.
    if HasDimension( R ) then
      maxdim:= Dimension( R );
    else
      maxdim:= infinity;
    fi;

    if HasIsAssociative( R ) and IsAssociative( R ) then

      # We may use `MutableBasisOfClosureUnderAction'.
      mb:= MutableBasisOfClosureUnderAction(
               F,
               GeneratorsOfLeftOperatorRing( R ),
               side,
               Igens,
               \*,
               Zero( I ),
               maxdim );

    else

      # We must use `MutableBasisOfIdealInNonassociativeAlgebra'.
      mb:= MutableBasisOfIdealInNonassociativeAlgebra(
               F,
               GeneratorsOfLeftModule( R ),
               Igens,
               Zero( I ),
               side,
               maxdim );

    fi;

    gens:= BasisVectors( mb );
    UseBasis( I, gens );

    return gens;
end );


InstallMethod( GeneratorsOfLeftModule,
    "for FLMLOR with known ideal generators",
    true,
    [ IsFLMLOR and HasGeneratorsOfTwoSidedIdeal ], 0,
    I -> LeftModuleGeneratorsForIdealFromGenerators( I,
             GeneratorsOfTwoSidedIdeal( I ),
             LeftActingRingOfIdeal( I ), "both" ) );

InstallMethod( GeneratorsOfLeftModule,
    "for FLMLOR with known left ideal generators",
    true,
    [ IsFLMLOR and HasGeneratorsOfLeftIdeal ],
    {} -> RankFilter( HasGeneratorsOfTwoSidedIdeal ),
    I -> LeftModuleGeneratorsForIdealFromGenerators( I,
             GeneratorsOfLeftIdeal( I ),
             LeftActingRingOfIdeal( I ), "left" ) );

InstallMethod( GeneratorsOfLeftModule,
    "for FLMLOR with known right ideal generators",
    true,
    [ IsFLMLOR and HasGeneratorsOfRightIdeal ],
    {} -> RankFilter( HasGeneratorsOfTwoSidedIdeal ),
    I -> LeftModuleGeneratorsForIdealFromGenerators( I,
             GeneratorsOfRightIdeal( I ),
             RightActingRingOfIdeal( I ), "right" ) );


InstallMethod( GeneratorsOfLeftOperatorRing,
    "for FLMLOR with known ideal generators",
    true,
    [ IsFLMLOR and HasGeneratorsOfTwoSidedIdeal ], 0,
    I -> LeftModuleGeneratorsForIdealFromGenerators( I,
             GeneratorsOfTwoSidedIdeal( I ),
             LeftActingRingOfIdeal( I ), "both" ) );

InstallMethod( GeneratorsOfLeftOperatorRing,
    "for FLMLOR with known left ideal generators",
    true,
    [ IsFLMLOR and HasGeneratorsOfLeftIdeal ],
    {} -> RankFilter( HasGeneratorsOfTwoSidedIdeal ),
    I -> LeftModuleGeneratorsForIdealFromGenerators( I,
             GeneratorsOfLeftIdeal( I ),
             LeftActingRingOfIdeal( I ), "left" ) );

InstallMethod( GeneratorsOfLeftOperatorRing,
    "for FLMLOR with known right ideal generators",
    true,
    [ IsFLMLOR and HasGeneratorsOfRightIdeal ],
    {} -> RankFilter( HasGeneratorsOfTwoSidedIdeal ),
    I -> LeftModuleGeneratorsForIdealFromGenerators( I,
             GeneratorsOfRightIdeal( I ),
             RightActingRingOfIdeal( I ), "right" ) );


#############################################################################
##
#M  AsLeftIdeal( <R>, <S> ) . . . . . . . . . . . . . . . . . for two FLMLORs
#M  AsRightIdeal( <R>, <S> )  . . . . . . . . . . . . . . . . for two FLMLORs
#M  AsTwoSidedIdeal( <R>, <S> ) . . . . . . . . . . . . . . . for two FLMLORs
##
##  The difference to the generic methods for two rings is that we need only
##  algebra generators and not ring generators of <S>.
##
InstallMethod( AsLeftIdeal,
    "for two FLMLORs",
    IsIdenticalObj,
    [ IsFLMLOR, IsFLMLOR ], 0,
    function( R, S )
    local I, gens;
    if not IsLeftIdeal( R, S ) then
      I:= fail;
    else
      gens:= GeneratorsOfLeftOperatorRing( S );
      I:= LeftIdealByGenerators( R, gens );
      SetGeneratorsOfLeftOperatorRing( I, gens );
    fi;
    return I;
    end );

InstallMethod( AsRightIdeal,
    "for two FLMLORs",
    IsIdenticalObj,
    [ IsRing, IsRing ], 0,
    function( R, S )
    local I, gens;
    if not IsRightIdeal( R, S ) then
      I:= fail;
    else
      gens:= GeneratorsOfLeftOperatorRing( S );
      I:= RightIdealByGenerators( R, gens );
      SetGeneratorsOfLeftOperatorRing( I, gens );
    fi;
    return I;
    end );

InstallMethod( AsTwoSidedIdeal,
    "for two FLMLORs",
    IsIdenticalObj,
    [ IsRing, IsRing ], 0,
    function( R, S )
    local I, gens;
    if not IsTwoSidedIdeal( R, S ) then
      I:= fail;
    else
      gens:= GeneratorsOfLeftOperatorRing( S );
      I:= TwoSidedIdealByGenerators( R, gens );
      SetGeneratorsOfLeftOperatorRing( I, gens );
    fi;
    return I;
    end );


#############################################################################
##
#M  IsFiniteDimensional( <I> ). . . . . . . . . .  for an ideal in an algebra
##
InstallMethod( IsFiniteDimensional,
    "for an ideal in an algebra",
    true,
    [ IsFLMLOR and HasLeftActingRingOfIdeal ], 0,
    function( I )
    if IsFiniteDimensional( LeftActingRingOfIdeal( I ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( IsFiniteDimensional,
    "for an ideal in an algebra",
    true,
    [ IsFLMLOR and HasRightActingRingOfIdeal ], 0,
    function( I )
    if IsFiniteDimensional( RightActingRingOfIdeal( I ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );
