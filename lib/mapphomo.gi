#############################################################################
##
#W  mapphomo.gi                 GAP library                     Thomas Breuer
#W                                                         and Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for properties of mappings preserving
##  algebraic structure.
##
##  1. methods for general mappings that respect multiplication
##  2. methods for general mappings that respect addition
##  3. methods for general mappings that respect scalar multiplication
##  4. properties and attributes of gen. mappings that respect multiplicative
##     and additive structure
##  5. default equality tests for structure preserving mappings
##
Revision.mapphomo_gi :=
    "@(#)$Id$";


#############################################################################
##
##  1. methods for general mappings that respect multiplication
##

#############################################################################
##
#M  RespectsMultiplication( <mapp> )  . . . . .  for a finite general mapping
##
InstallMethod( RespectsMultiplication,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    local S, R, enum, pair1, pair2;

    S:= Source( map );
    R:= Range(  map );
    if not ( IsMagma( S ) and IsMagma( R ) ) then
      return false;
    fi;

    map:= UnderlyingRelation( map );

    if not IsFinite( map ) then
      TryNextMethod();
    fi;
    enum:= Enumerator( map );
    for pair1 in enum do
      for pair2 in enum do
        if not Tuple( [ pair1[1] * pair2[1], pair1[2] * pair2[2] ] )
           in map then
          return false;
        fi;
      od;
    od;
    return true;
    end );


#############################################################################
##
#M  RespectsOne( <mapp> ) . . . . . . . . . . .  for a finite general mapping
##
InstallMethod( RespectsOne,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    local S, R;
    S:= Source( map );
    R:= Range(  map );
    return     IsMagmaWithOne( S )
           and IsMagmaWithOne( R )
           and One( R ) in ImagesElm( One( R ) );
    end );


#############################################################################
##
#M  RespectsInverses( <mapp> )  . . . . . . . .  for a finite general mapping
##
InstallMethod( RespectsInverses,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    local S, R, enum, pair;
    S:= Source( map );
    R:= Range(  map );
    if not ( IsMagmaWithInverses( S ) and IsMagmaWithInverses( R ) ) then
      return false;
    fi;

    map:= UnderlyingRelation( map );
    if not IsFinite( map ) then
      TryNextMethod();
    fi;

    enum:= Enumerator( map );
    for pair in enum do
      if not Tuple( [ Inverse( pair[1] ), Inverse( pair[2] ) ] )
             in map then
        return false;
      fi;
    od;
    return true;
    end );


#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <mapp> )  . for finite gen. mapping
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    "method for a finite general mapping",
    true,
    [ IsGeneralMapping and RespectsMultiplication and RespectsOne ], 0,
    function( mapp )

    local oneR, kernel, pair;

    if IsFinite( Source( mapp ) ) then

      oneR:= One( Range( mapp ) );
      kernel:= Filtered( Enumerator( Source( mapp ) ),
                         s -> oneR in ImagesElm( mapp, s ) );

    elif IsFinite( UnderlyingRelation( mapp ) ) then

      oneR:= One( Range( mapp ) );
      kernel:= [];
      for pair in Enumerator( UnderlyingRelation( mapp ) ) do
        if pair[2] = oneR then
          Add( kernel, pair[1] );
        fi;
      od;

    else
      TryNextMethod();
    fi;

    if     HasIsAssociative( Source( mapp ) )
       and IsAssociative( Source( mapp ) ) then
      return MonoidByGenerators( kernel );
    else
      return MagmaWithOneByGenerators( kernel );
    fi;
    end );


#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <map> )
#M              . . .  for injective gen. mapping that respects mult. and one
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    "method for an injective gen. mapping that respects mult. and one",
    true,
    [ IsGeneralMapping and RespectsMultiplication
                       and RespectsOne and IsInjective ], SUM_FLAGS,
    map -> TrivialSubmagmaWithOne( Source( map ) ) );


#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <mapp> )  for finite gen. mapping
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
    "method for a finite general mapping",
    true,
    [ IsGeneralMapping and RespectsMultiplication and RespectsOne ], 0,
    function( mapp )

    local oneS, cokernel, rel, pair;

    if IsFinite( Range( mapp ) ) then

      oneS:= One( Source( mapp ) );
      rel:= UnderlyingRelation( mapp );
      cokernel:= Filtered( Enumerator( Range( mapp ) ),
                           r -> Tuple( [ oneS, r ] ) in rel );

    elif   IsFinite( UnderlyingRelation( mapp ) )
       and HasAsList( UnderlyingRelation( mapp ) ) then

      # Note that we must not call 'Enumerator' for the underlying
      # relation since this is allowed to call (functions that may call)
      # 'CoKernelOfMultiplicativeGeneralMapping'.
      oneS:= One( Source( mapp ) );
      cokernel:= [];
      for pair in AsList( UnderlyingRelation( mapp ) ) do
        if pair[1] = oneS then
          Add( cokernel, pair[2] );
        fi;
      od;

    else
      TryNextMethod();
    fi;

    if     HasIsAssociative( Range( mapp ) )
       and IsAssociative( Range( mapp ) ) then
      return MonoidByGenerators( cokernel );
    else
      return MagmaWithOneByGenerators( cokernel );
    fi;
    end );


#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <map> )
#M            . .  for single-valued gen. mapping that respects mult. and one
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
    "method for a single-valued gen. mapping that respects mult. and one",
    true,
    [ IsGeneralMapping and RespectsMultiplication
                       and RespectsOne and IsSingleValued ], SUM_FLAGS,
#T SUM_FLAGS ?
    map -> TrivialSubmagmaWithOne( Range( map ) ) );


#############################################################################
##
#M  IsSingleValued( <map> ) . .  for gen. mapping that respects mult. and one
##
InstallMethod( IsSingleValued,
    "method for a gen. mapping that respects mult. and inverses",
    true,
    [ IsGeneralMapping and RespectsMultiplication and RespectsInverses ],
    0,
    map -> IsTrivial( CoKernelOfMultiplicativeGeneralMapping( map ) ) );


#############################################################################
##
#M  IsInjective( <map> )  . for gen. mapping that respects mult. and inverses
##
InstallMethod( IsInjective,
    "method for a gen. mapping that respects mult. and one",
    true,
    [ IsGeneralMapping and RespectsMultiplication and RespectsInverses ],
    0,
    map -> IsTrivial( KernelOfMultiplicativeGeneralMapping( map ) ) );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . . .  for s.p. gen. mapping resp. mult. & inv.
##
InstallMethod( ImagesElm,
    "method for s.p. general mapping respecting mult. & inv., and element",
    FamSourceEqFamElm,
    [ IsSPGeneralMapping and RespectsMultiplication and RespectsInverses,
      IsObject ], 0,
    function( map, elm )
    local img;
    img:= ImagesRepresentative( map, elm );
    if img = fail then
      return [];
    else
      return RightCoset( CoKernelOfMultiplicativeGeneralMapping(map), img );
    fi;
    end );


#############################################################################
##
#M  ImagesSet( <map>, <elms> )  . .  for s.p. gen. mapping resp. mult. & inv.
##
InstallMethod( ImagesSet,
    "method for s.p. general mapping respecting mult. & inv., and group",
    CollFamSourceEqFamElms,
    [ IsSPGeneralMapping and RespectsMultiplication and RespectsInverses,
      IsGroup ], 0,
    function( map, elms )

    if not IsTotal( map ) then
      elms:= Intersection2( PreImagesRange( map ), elms );
    fi;

    elms:= ClosureGroup( CoKernelOfMultiplicativeGeneralMapping( map ),
                   SubgroupNC( Range( map ),
                   List( GeneratorsOfMagmaWithInverses( elms ),
                         gen -> ImagesRepresentative( map, gen ) ) ) );
    UseSubsetRelation( Range( map ), elms );
    return elms;
    end );


#############################################################################
##
#M  PreImagesElm( <map>, <elm> )  .  for s.p. gen. mapping resp. mult. & inv.
##
InstallMethod( PreImagesElm,
    "method for s.p. general mapping respecting mult. & inv., and element",
    FamRangeEqFamElm,
    [ IsSPGeneralMapping and RespectsMultiplication and RespectsInverses,
      IsObject ], 0,
      function( map, elm )
    local   pre;

    pre:= PreImagesRepresentative( map, elm );
    if pre = fail then
      return [];
    else
      return RightCoset( KernelOfMultiplicativeGeneralMapping( map ), pre );
    fi;
    end );


#############################################################################
##
#M  PreImagesSet( <map>, <elms> ) .  for s.p. gen. mapping resp. mult. & inv.
##
InstallMethod( PreImagesSet,
    "method for s.p. general mapping respecting mult. & inv., and group",
    CollFamRangeEqFamElms,
    [ IsSPGeneralMapping and RespectsMultiplication and RespectsInverses,
      IsGroup ], 0,
    function( map, elms )
    if not IsSurjective( map ) then
      elms:= Intersection2( ImagesSource( map ), elms );
    fi;
    elms:= ClosureGroup( KernelOfMultiplicativeGeneralMapping( map ),
                   SubgroupNC( Source( map ),
                   List( GeneratorsOfMagmaWithInverses( elms ),
                         gen -> PreImagesRepresentative( map, gen ) ) ) );
    UseSubsetRelation( Source( map ), elms );
    return elms;
    end );


#############################################################################
##
##  2. methods for general mappings that respect addition
##

#############################################################################
##
#M  RespectsAddition( <mapp> )  . . . . . . . .  for a finite general mapping
##
InstallMethod( RespectsAddition,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    local S, R, enum, pair1, pair2;

    S:= Source( map );
    R:= Range(  map );
    if not ( IsAdditiveMagma( S ) and IsAdditiveMagma( R ) ) then
      return false;
    fi;

    map:= UnderlyingRelation( map );
    if not IsFinite( map ) then
      TryNextMethod();
    fi;

    enum:= Enumerator( map );
    for pair1 in enum do
      for pair2 in enum do
        if not Tuple( [ pair1[1] + pair2[1], pair1[2] + pair2[2] ] )
           in map then
          return false;
        fi;
      od;
    od;
    return true;
    end );


#############################################################################
##
#M  RespectsZero( <mapp> )  . . . . . . . . . .  for a finite general mapping
##
InstallMethod( RespectsZero,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    local S, R;
    S:= Source( map );
    R:= Range(  map );
    return     IsAdditiveMagmaWithZero( S )
           and IsAdditiveMagmaWithZero( R )
           and Zero( R ) in ImagesElm( Zero( S ) );
    end );


#############################################################################
##
#M  RespectsAdditiveInverses( <mapp> )  . . . .  for a finite general mapping
##
InstallMethod( RespectsAdditiveInverses,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    local S, R, enum, pair;
    S:= Source( map );
    R:= Range(  map );
    if not (     IsAdditiveMagmaWithInverses( S )
             and IsAdditiveMagmaWithInverses( R ) ) then
      return false;
    fi;

    map:= UnderlyingRelation( map );
    if not IsFinite( map ) then
      TryNextMethod();
    fi;

    enum:= Enumerator( map );
    for pair in enum do
      if not Tuple( [ AdditiveInverse( pair[1] ),
                      AdditiveInverse( pair[2] ) ] )
             in map then
        return false;
      fi;
    od;
    return true;
    end );


#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <mapp> )  .  for a finite general mapping
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "method for a finite general mapping",
    true,
    [ IsGeneralMapping and RespectsAddition and RespectsZero ], 0,
    function( mapp )

    local zeroR, rel, kernel, pair;

    if IsFinite( Source( mapp ) ) then

      zeroR:= Zero( Range( mapp ) );
      rel:= UnderlyingRelation( mapp );
      kernel:= Filtered( Enumerator( Source( mapp ) ),
                         s -> Tuple( [ s, zeroR ] ) in rel );

    elif IsFinite( UnderlyingRelation( mapp ) ) then

      zeroR:= Zero( Range( mapp ) );
      kernel:= [];
      for pair in Enumerator( UnderlyingRelation( mapp ) ) do
        if pair[2] = zeroR then
          Add( kernel, pair[1] );
        fi;
      od;

    else
      TryNextMethod();
    fi;

    return AdditiveMagmaWithZeroByGenerators( kernel );
    end );


#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <map> )
#M              . . .  for injective gen. mapping that respects add. and zero
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "method for an injective gen. mapping that respects add. and zero",
    true,
    [ IsGeneralMapping and RespectsAddition
                       and RespectsZero and IsInjective ], SUM_FLAGS,
    map -> TrivialSubadditiveMagmaWithZero( Source( map ) ) );


#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <map> ) . . . . . . . .  for zero mapping
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "method for zero mapping",
    true,
    [ IsGeneralMapping and RespectsAddition and RespectsZero and IsZero ],
    SUM_FLAGS,
    Source );


#############################################################################
##
#M  CoKernelOfAdditiveGeneralMapping( <mapp> )  .  for finite general mapping
##
InstallMethod( CoKernelOfAdditiveGeneralMapping,
    "method for a finite general mapping",
    true,
    [ IsGeneralMapping and RespectsAddition and RespectsZero ], 0,
    function( mapp )

    local zeroS, rel, cokernel, pair;

    if IsFinite( Range( mapp ) ) then

      zeroS:= Zero( Source( mapp ) );
      rel:= UnderlyingRelation( mapp );
      cokernel:= Filtered( Enumerator( Range( mapp ) ),
                           r -> Tuple( [ zeroS, r ] ) in rel );

    elif   IsFinite( UnderlyingRelation( mapp ) )
       and HasAsList( UnderlyingRelation( mapp ) ) then

      # Note that we must not call 'Enumerator' for the underlying
      # relation since this is allowed to call (functions that may call)
      # 'CoKernelOfAdditiveGeneralMapping'.
      zeroS:= Zero( Source( mapp ) );
      cokernel:= [];
      for pair in AsList( UnderlyingRelation( mapp ) ) do
        if pair[1] = zeroS then
          Add( cokernel, pair[2] );
        fi;
      od;

    else
      TryNextMethod();
    fi;

    return AdditiveMagmaWithZeroByGenerators( cokernel );
    end );


#############################################################################
##
#M  CoKernelOfAdditiveGeneralMapping( <map> )
#M            . .  for single-valued gen. mapping that respects add. and zero
##
InstallMethod( CoKernelOfAdditiveGeneralMapping,
    "method for a single-valued gen. mapping that respects add. and zero",
    true,
    [ IsGeneralMapping and RespectsAddition
                       and RespectsZero and IsSingleValued ], SUM_FLAGS,
#T SUM_FLAGS ?
    map -> TrivialSubadditiveMagmaWithZero( Range( map ) ) );


#############################################################################
##
#M  IsSingleValued( <map> ) . for gen. mapping that respects add. & add. inv.
##
InstallMethod( IsSingleValued,
    "method for a gen. mapping that respects add. and add. inverses",
    true,
    [ IsGeneralMapping and RespectsAddition and RespectsAdditiveInverses ],
    0,
    map -> IsTrivial( CoKernelOfAdditiveGeneralMapping(map) ) );


#############################################################################
##
#M  IsInjective( <map> )  . . for gen. mapping that respects add. & add. inv.
##
InstallMethod( IsInjective,
    "method for a gen. mapping that respects add. and add. inverses",
    true,
    [ IsGeneralMapping and RespectsAddition and RespectsAdditiveInverses ],
    0,
    map -> IsTrivial( KernelOfAdditiveGeneralMapping(map) ) );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . . for s.p. gen. mapping resp. add. & add.inv.
##
InstallMethod( ImagesElm,
    "method for s.p. gen. mapping respecting add. & add.inv., and element",
    FamSourceEqFamElm,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses,
      IsObject ], 0,
    function( map, elm )
    local img;
    img:= ImagesRepresentative( map, elm );
    if img = fail then
      return [];
    else
      return AdditiveCoset( CoKernelOfAdditiveGeneralMapping( map ), img );
    fi;
    end );


#############################################################################
##
#M  ImagesSet( <map>, <elms> )  . for s.p. gen. mapping resp. add. & add.inv.
##
InstallMethod( ImagesSet,
    "method for s.p. gen. mapping resp. add. & add.inv., and add. group",
    CollFamSourceEqFamElms,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses,
      IsAdditiveGroup ], 0,
    function( map, elms )

    if not IsTotal( map ) then
      elms:= Intersection2( PreImagesRange( map ), elms );
    fi;

    elms:= ClosureAdditiveGroup( CoKernelOfAdditiveGeneralMapping( map ),
                   SubadditiveMagmaWithInversesNC( Range( map ),
                   List( GeneratorsOfAdditiveMagmaWithInverses( elms ),
                         gen -> ImagesRepresentative( map, gen ) ) ) );
    UseSubsetRelation( Range( map ), elms );
    return elms;
    end );


#############################################################################
##
#M  PreImagesElm( <map>, <elm> )  for s.p. gen. mapping resp. add. & add.inv.
##
InstallMethod( PreImagesElm,
    "method for s.p. gen. mapping respecting add. & add.inv., and element",
    FamRangeEqFamElm,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses,
      IsObject ], 0,
      function( map, elm )
    local   pre;

    pre:= PreImagesRepresentative( map, elm );
    if pre = fail then
      return [];
    else
      return AdditiveCoset( KernelOfAdditiveGeneralMapping( map ), pre );
    fi;
    end );


#############################################################################
##
#M  PreImagesSet( <map>, <elms> ) for s.p. gen. mapping resp. add. & add.inv.
##
InstallMethod( PreImagesSet,
    "method for s.p. gen. mapping resp. add. & add.inv., and add. group",
    CollFamRangeEqFamElms,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses,
      IsAdditiveGroup ], 0,
    function( map, elms )

    if not IsSurjective( map ) then
      elms:= Intersection2( ImagesSource( map ), elms );
    fi;

    elms:= ClosureAdditiveGroup( KernelOfAdditiveGeneralMapping( map ),
                   SubadditiveMagmaWithInversesNC( Source( map ),
                   List( GeneratorsOfAdditiveMagmaWithInverses( elms ),
                         gen -> PreImagesRepresentative( map, gen ) ) ) );
    UseSubsetRelation( Source( map ), elms );
    return elms;
    end );


#############################################################################
##
##  3. methods for general mappings that respect scalar multiplication
##


#############################################################################
##
#M  RespectsScalarMultiplication( <mapp> )  . .  for a finite general mapping
##
InstallMethod( RespectsScalarMultiplication,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )

    local S, R, D, pair, c;

    S:= Source( map );
    R:= Range(  map );
    if not ( IsLeftModule( S ) and IsLeftModule( R ) ) then
      return false;
    fi;

    D:= LeftActingDomain( S );
    if not IsSubset( LeftActingDomain( R ), D ) then
#T subset is allowed?
      return false;
    elif not IsFinite( D ) or not IsFinite( map ) then
      Error( "cannot determine whether infinite mapping <map> ",
             "respects scalar multiplication" );
    else
      D:= Enumerator( D );
      map:= UnderlyingRelation( map );
      for pair in Enumerator( map ) do
        for c in D do
          if not Tuple( [ c * pair[1], c * pair[2] ] ) in map then
            return false;
          fi;
        od;
      od;
      return true;
    fi;
    end );


#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <mapp> )  . . for a finite linear mapping
##
##  We need a special method for being able to return a left module.
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "method for a finite linear mapping",
    true,
    [ IsGeneralMapping and RespectsAddition and RespectsZero
                       and RespectsScalarMultiplication ], 0,
    function( mapp )

    local zeroR, rel, kernel, pair;

    if not IsExtLSet( Source( mapp ) ) then
      TryNextMethod();
    fi;

    if IsFinite( Source( mapp ) ) then

      zeroR:= Zero( Range( mapp ) );
      rel:= UnderlyingRelation( mapp );
      kernel:= Filtered( Enumerator( Source( mapp ) ),
                         s -> Tuple( [ s, zeroR ] ) in rel );

    elif IsFinite( UnderlyingRelation( mapp ) ) then

      zeroR:= Zero( Range( mapp ) );
      kernel:= [];
      for pair in Enumerator( UnderlyingRelation( mapp ) ) do
        if pair[2] = zeroR then
          Add( kernel, pair[1] );
        fi;
      od;

    else
      TryNextMethod();
    fi;

    return LeftModuleByGenerators( LeftActingDomain( Source( mapp ) ),
                                   kernel );
    end );


#############################################################################
##
#M  CoKernelOfAdditiveGeneralMapping( <mapp> )  . . for finite linear mapping
##
##  We need a special method for being able to return a left module.
##
InstallMethod( CoKernelOfAdditiveGeneralMapping,
    "method for a finite linear mapping",
    true,
    [ IsGeneralMapping and RespectsAddition and RespectsZero
                       and RespectsScalarMultiplication ], 0,
    function( mapp )

    local zeroS, rel, cokernel, pair;

    if not IsExtLSet( Range( mapp ) ) then
      TryNextMethod();
    fi;

    if IsFinite( Range( mapp ) ) then

      zeroS:= Zero( Source( mapp ) );
      rel:= UnderlyingRelation( mapp );
      cokernel:= Filtered( Enumerator( Range( mapp ) ),
                           r -> Tuple( [ zeroS, r ] ) in rel );

    elif IsFinite( UnderlyingRelation( mapp ) ) then

      zeroS:= Zero( Source( mapp ) );
      cokernel:= [];
      for pair in Enumerator( UnderlyingRelation( mapp ) ) do
        if pair[1] = zeroS then
          Add( cokernel, pair[2] );
        fi;
      od;

    else
      TryNextMethod();
    fi;

    return LeftModuleByGenerators( LeftActingDomain( Range( mapp ) ),
                                   cokernel );
    end );


#############################################################################
##
#M  ImagesSet( <map>, <elms> )  . . . . .  for linear mapping and left module
##
InstallMethod( ImagesSet,
    "method for linear mapping and left module",
    CollFamSourceEqFamElms,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses
          and RespectsScalarMultiplication,
      IsLeftModule ], 0,
    function( map, elms )

    if not IsTotal( map ) then
      elms:= Intersection2( elms, PreImagesRange( map ) );
    fi;

    elms:= ClosureLeftModule( CoKernelOfAdditiveGeneralMapping( map ),
                   LeftModuleByGenerators( LeftActingDomain( elms ),
                       List( GeneratorsOfLeftModule( elms ),
                             gen -> ImagesRepresentative( map, gen ) ),
                       Zero( Range( map ) ) ) );
    UseSubsetRelation( Range( map ), elms );
    return elms;
    end );


#############################################################################
##
#M  PreImagesSet( <map>, <elms> ) . . . .  for linear mapping and left module
##
InstallMethod( PreImagesSet,
    "method for linear mapping and left module",
    CollFamRangeEqFamElms,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses
          and RespectsScalarMultiplication,
      IsLeftModule ], 0,
    function( map, elms )

    if not IsSurjective( map ) then
      elms:= Intersection( elms, ImagesSource( map ) );
    fi;

    elms:= ClosureLeftModule( KernelOfAdditiveGeneralMapping( map ),
                   LeftModuleByGenerators( LeftActingDomain( elms ),
                       List( GeneratorsOfLeftModule( elms ),
                             gen -> PreImagesRepresentative( map, gen ) ),
                       Zero( Source( map ) ) ) );
    UseSubsetRelation( Source( map ), elms );
    return elms;
    end );


#############################################################################
##
##  4. properties and attributes of gen. mappings that respect multiplicative
##     and additive structure
##

#############################################################################
##
#M  IsFieldHomomorphism( <mapp> )
##
InstallMethod( IsFieldHomomorphism,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    map -> IsRingHomomorphism( map ) and IsField( Source( map ) ) );


#############################################################################
##
#M  ImagesSet( <map>, <elms> )  . . . . . . . . . for algebra hom. and FLMLOR
##
InstallMethod( ImagesSet,
    "method for algebra hom. and FLMLOR",
    CollFamSourceEqFamElms,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses
          and RespectsScalarMultiplication and RespectsMultiplication,
      IsFLMLOR ], 0,
    function( map, elms )

    if not IsTotal( map ) then
      elms:= Intersection2( elms, PreImagesRange( map ) );
    fi;

    elms:= ClosureLeftOperatorRing( CoKernelOfAdditiveGeneralMapping( map ),
                   FLMLORByGenerators( LeftActingDomain( elms ),
                       List( GeneratorsOfLeftOperatorRing( elms ),
                             gen -> ImagesRepresentative( map, gen ) ),
                       Zero( Range( map ) ) ) );
    UseSubsetRelation( Range( map ), elms );
    return elms;
    end );


#############################################################################
##
#M  ImagesSet( <map>, <elms> )  .  for alg.-with-one hom. and FLMLOR-with-one
##
InstallMethod( ImagesSet,
    "method for algebra-with-one hom. and FLMLOR-with-one",
    CollFamSourceEqFamElms,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses
          and RespectsScalarMultiplication and RespectsMultiplication
          and RespectsOne,
      IsFLMLORWithOne ], 0,
    function( map, elms )

    if not IsTotal( map ) then
      elms:= Intersection2( elms, PreImagesRange( map ) );
    fi;

    elms:= ClosureLeftOperatorRing( CoKernelOfAdditiveGeneralMapping( map ),
                   FLMLORWithOneByGenerators( LeftActingDomain( elms ),
                       List( GeneratorsOfLeftOperatorRingWithOne( elms ),
                             gen -> ImagesRepresentative( map, gen ) ),
                       Zero( Range( map ) ) ) );
    UseSubsetRelation( Range( map ), elms );
    return elms;
    end );


#############################################################################
##
#M  PreImagesSet( <map>, <elms> ) . . . . . . . . for algebra hom. and FLMLOR
##
InstallMethod( PreImagesSet,
    "method for algebra hom. and FLMLOR",
    CollFamRangeEqFamElms,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses
          and RespectsScalarMultiplication and RespectsMultiplication,
      IsFLMLOR ], 0,
    function( map, elms )

    if not IsSurjective( map ) then
      elms:= Intersection( elms, ImagesSource( map ) );
    fi;

    elms:= ClosureLeftOperatorRing( KernelOfAdditiveGeneralMapping( map ),
                   FLMLORByGenerators( LeftActingDomain( elms ),
                       List( GeneratorsOfLeftOperatorRing( elms ),
                             gen -> PreImagesRepresentative( map, gen ) ),
                       Zero( Source( map ) ) ) );
    UseSubsetRelation( Source( map ), elms );
    return elms;
    end );


#############################################################################
##
#M  PreImagesSet( <map>, <elms> )  for alg.-with-one hom. and FLMLOR-with-one
##
InstallMethod( PreImagesSet,
    "method for algebra-with-one hom. and FLMLOR-with-one",
    CollFamRangeEqFamElms,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses
          and RespectsScalarMultiplication and RespectsMultiplication
          and RespectsOne,
      IsFLMLORWithOne ], 0,
    function( map, elms )

    if not IsSurjective( map ) then
      elms:= Intersection( elms, ImagesSource( map ) );
    fi;

    elms:= ClosureLeftOperatorRing( KernelOfAdditiveGeneralMapping( map ),
                   FLMLORWithOneByGenerators( LeftActingDomain( elms ),
                       List( GeneratorsOfLeftOperatorRingWithOne( elms ),
                             gen -> PreImagesRepresentative( map, gen ) ),
                       Zero( Source( map ) ) ) );
    UseSubsetRelation( Source( map ), elms );
    return elms;
    end );


#############################################################################
##
##  5. default equality tests for structure preserving mappings
##
##  The default methods for equality tests of single-valued and structure
##  preserving general mappings first check some necessary conditions:
##  Source and range of both must be equal, and if both know whether they
##  are injective, surjective or total, the values must be equal if the
##  general mappings are equal.
##
##  In the second step, appropriate generators of the preimage of the general
##  mappings are considered.
##  If the general mapping respects multiplication, one, inverses, addition,
##  zero, additive inverses, scalar multiplication then
##  the preimage is a magma, magma-with-one, magma-with-inverses,
##  additive-magma, additive-magma-with-zero, additive-magma-with-inverses,
##  respectively.
##  So the general mappings are equal if the images of the appropriate
##  generators are equal.
##


#############################################################################
##
#F  InstallEqMethodForMappingsFromGenerators( <IsStruct>,
#F                           <GeneratorsOfStruct>, <respects>, <infostring> )
##
InstallEqMethodForMappingsFromGenerators := function( IsStruct,
    GeneratorsOfStruct, respects, infostring )

    InstallMethod( \=,
        Concatenation( "method for two s.v. gen. mappings", infostring ),
        IsIdentical,
        [ IsGeneralMapping and IsSingleValued and respects,
          IsGeneralMapping and IsSingleValued and respects ],
        0,
        function( map1, map2 )
        local gen;
        if   not IsStruct( Source( map1 ) ) then
          TryNextMethod();
        elif     HasIsInjective( map1 ) and HasIsInjective( map2 )
             and IsInjective( map1 ) <> IsInjective( map2 ) then
          return false;
        elif     HasIsSurjective( map1 ) and HasIsSurjective( map2 )
             and IsSurjective( map1 ) <> IsSurjective( map2 ) then
          return false;
        elif     HasIsTotal( map1 ) and HasIsTotal( map2 )
             and IsTotal( map1 ) <> IsTotal( map2 ) then
          return false;
        elif    Source( map1 ) <> Source( map2 )
             or Range ( map1 ) <> Range ( map2 ) then
          return false;
        fi;

        for gen in GeneratorsOfStruct( PreImagesRange( map1 ) ) do
          if    ImagesRepresentative( map1, gen )
             <> ImagesRepresentative( map2, gen ) then
            return false;
          fi;
        od;
        return true;
        end );
end;


#############################################################################
##
#M  \=( <map1>, <map2> )  . . . . . . . . . . . . . . . .  for s.v. gen. map.
##
InstallEqMethodForMappingsFromGenerators( IsDomain,
    GeneratorsOfDomain,
    IsObject,
    "" );


#############################################################################
##
#M  \=( <map1>, <map2> )  . . . . . . . . . .  for s.v. gen. map. resp. mult.
##
InstallEqMethodForMappingsFromGenerators( IsMagma,
    GeneratorsOfMagma,
    RespectsMultiplication,
    " that respect mult." );


#############################################################################
##
#M  \=( <map1>, <map2> )  . . . . . .  for s.v. gen. map. resp. mult. and one
##
InstallEqMethodForMappingsFromGenerators( IsMagmaWithOne,
    GeneratorsOfMagmaWithOne,
    RespectsMultiplication and RespectsOne,
    " that respect mult. and one" );


#############################################################################
##
#M  \=( <map1>, <map2> )  . . . . . . for s.v. gen. map. resp. mult. and inv.
##
InstallEqMethodForMappingsFromGenerators( IsMagmaWithInverses,
    GeneratorsOfMagmaWithInverses,
    RespectsMultiplication and RespectsInverses,
    " that respect mult. and inv." );


#############################################################################
##
#M  \=( <map1>, <map2> )  . . . . . . . . . . . for s.v. gen. map. resp. add.
##
InstallEqMethodForMappingsFromGenerators( IsAdditiveMagma,
    GeneratorsOfAdditiveMagma,
    RespectsAddition,
    " that respect add." );


#############################################################################
##
#M  \=( <map1>, <map2> )  . . . . . .  for s.v. gen. map. resp. add. and zero
##
InstallEqMethodForMappingsFromGenerators( IsAdditiveMagmaWithZero,
    GeneratorsOfAdditiveMagmaWithZero,
    RespectsAddition and RespectsZero,
    " that respect add. and zero" );


#############################################################################
##
#M  \=( <map1>, <map2> )  . . . . for s.v. gen. map. resp. add. and add. inv.
##
InstallEqMethodForMappingsFromGenerators( IsAdditiveMagmaWithInverses,
    GeneratorsOfAdditiveMagmaWithInverses,
    RespectsAddition and RespectsAdditiveInverses,
    " that respect add. and add. inv." );


#############################################################################
##
#M  \=( <map1>, <map2> )  . . .  for s.v. gen. map. resp. mult.,add.,add.inv.
##
InstallEqMethodForMappingsFromGenerators( IsRing,
    GeneratorsOfRing,
    RespectsMultiplication and
    RespectsAddition and RespectsAdditiveInverses,
    " that respect mult.,add.,add.inv." );


#############################################################################
##
#M  \=( <map1>, <map2> )  .  for s.v. gen. map. resp. mult.,one,add.,add.inv.
##
InstallEqMethodForMappingsFromGenerators( IsRingWithOne,
    GeneratorsOfRingWithOne,
    RespectsMultiplication and RespectsOne and
    RespectsAddition and RespectsAdditiveInverses,
    " that respect mult.,one,add.,add.inv." );


#############################################################################
##
#M  \=( <map1>, <map2> )   for s.v. gen. map. resp. add.,add.inv.,scal. mult.
##
InstallEqMethodForMappingsFromGenerators( IsLeftModule,
    GeneratorsOfLeftModule,
    RespectsAddition and RespectsAdditiveInverses and
    RespectsScalarMultiplication,
    " that respect add.,add.inv.,scal. mult." );


#############################################################################
##
#M  \=( <map1>, <map2> )   for s.v.g.m. resp. add.,add.inv.,mult.,scal. mult.
##
InstallEqMethodForMappingsFromGenerators( IsLeftOperatorRing,
    GeneratorsOfLeftOperatorRing,
    RespectsAddition and RespectsAdditiveInverses and
    RespectsMultiplication and RespectsScalarMultiplication,
    " that respect add.,add.inv.,mult.,scal. mult." );


#############################################################################
##
#M  \=( <map1>, <map2> )   s.v.g.m. resp. add.,add.inv.,mult.,one,scal. mult.
##
InstallEqMethodForMappingsFromGenerators( IsLeftOperatorRingWithOne,
    GeneratorsOfLeftOperatorRingWithOne,
    RespectsAddition and RespectsAdditiveInverses and
    RespectsMultiplication and RespectsOne and RespectsScalarMultiplication,
    " that respect add.,add.inv.,mult.,one,scal. mult." );

#T no methods that use 'GeneratorsOfDivisionRing' ?


#############################################################################
##
#E  mapphomo.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



