#############################################################################
##
#W  mapphomo.gi                 GAP library                     Thomas Breuer
#W                                                         and Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for properties of mappings preserving
##  algebraic structure.
##
##  1. methods for general mappings that respect multiplication
##  2. methods for general mappings that respect addition
##  3. methods for general mappings that respect scalar multiplication
##  4. ...
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
    elif not IsFinite( map ) then
      Error( "cannot determine whether infinite mapping <map> ",
             "respects multiplication" );
    else
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
    fi;
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
           and Tuple( [ One( S ), One( R ) ] ) in map;
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
    elif not IsFinite( map ) then
      Error( "cannot determine whether infinite mapping <map> ",
             "respects inverses" );
    else
      enum:= Enumerator( map );
      for pair in enum do
        if not Tuple( [ Inverse( pair[1] ), Inverse( pair[2] ) ] )
               in map then
          return false;
        fi;
      od;
      return true;
    fi;
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

    if IsFinite( mapp ) then

      oneR:= One( Range( mapp ) );
      kernel:= [];
      for pair in Enumerator( mapp ) do
        if pair[2] = oneR then
          Add( kernel, pair[1] );
        fi;
      od;

    elif IsFinite( Source( mapp ) ) then

      oneR:= One( Range( mapp ) );
      kernel:= Filtered( Enumerator( Source( mapp ) ),
                         s -> Tuple( [ s, oneR ] ) in mapp );

    else
      Error( "cannot compute kernel of infinite mapping" );
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
    map -> TrivialSubmonoid( Source( map ) ) );


#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <mapp> )  for finite gen. mapping
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
    "method for a finite general mapping",
    true,
    [ IsGeneralMapping and RespectsMultiplication and RespectsOne ], 0,
    function( mapp )

    local oneS, cokernel, pair;

    if IsFinite( mapp ) then

      oneS:= One( Source( mapp ) );
      cokernel:= [];
      for pair in Enumerator( mapp ) do
        if pair[1] = oneS then
          Add( cokernel, pair[2] );
        fi;
      od;

    elif IsFinite( Range( mapp ) ) then

      oneS:= One( Source( mapp ) );
      cokernel:= Filtered( Enumerator( Range( mapp ) ),
                           r -> Tuple( [ oneS, r ] ) in mapp );

    else
      Error( "cannot compute cokernel of infinite mapping" );
    fi;

    return MagmaWithOneByGenerators( cokernel );
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
    map -> TrivialSubmonoid( Range( map ) ) );


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
      elms:= Intersection2( elms, PreImagesRange( map ) );
    fi;

    return ClosureGroup( CoKernelOfMultiplicativeGeneralMapping( map ),
                   SubgroupNC( Range( map ),
                   List( GeneratorsOfMagmaWithInverses( elms ),
                         gen -> ImagesRepresentative( map, gen ) ) ) );
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
    
    pre:= ImagesRepresentative( map, elm );
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
      elms:= Intersection( elms, ImagesSource( map ) );
    fi;
    return ClosureGroup( KernelOfMultiplicativeGeneralMapping( map ),
                   SubgroupNC( Source( map ),
                   List( GeneratorsOfMagmaWithInverses( elms ),
                         gen -> PreImagesRepresentative( map, gen ) ) ) );
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
    elif not IsFinite( map ) then
      Error( "cannot determine whether infinite mapping <map> ",
             "respects addition" );
    else
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
    fi;
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
           and Tuple( [ Zero( S ), Zero( R ) ] ) in map;
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
    elif not IsFinite( map ) then
      Error( "cannot determine whether infinite mapping <map> ",
             "respects inverses" );
    else
      enum:= Enumerator( map );
      for pair in enum do
        if not Tuple( [ AdditiveInverse( pair[1] ),
                        AdditiveInverse( pair[2] ) ] )
               in map then
          return false;
        fi;
      od;
      return true;
    fi;
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

    local zeroR, kernel, pair;

    if IsFinite( mapp ) then

      zeroR:= Zero( Range( mapp ) );
      kernel:= [];
      for pair in Enumerator( mapp ) do
        if pair[2] = zeroR then
          Add( kernel, pair[1] );
        fi;
      od;
      return AdditiveMagmaWithZeroByGenerators( kernel );

    elif IsFinite( Source( mapp ) ) then

      zeroR:= Zero( Range( mapp ) );
      kernel:= Filtered( Enumerator( Source( mapp ) ),
                         s -> Tuple( [ s, zeroR ] ) in mapp );
      return AdditiveMagmaWithZeroByGenerators( kernel );

    else
      Error( "cannot compute kernel of infinite mapping" );
    fi;
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
#M  CoKernelOfAdditiveGeneralMapping( <mapp> )  .  for finite general mapping
##
InstallMethod( CoKernelOfAdditiveGeneralMapping,
    "method for a finite general mapping",
    true,
    [ IsGeneralMapping and RespectsAddition and RespectsZero ], 0,
    function( mapp )

    local zeroS, cokernel, pair;

    if IsFinite( mapp ) then

      zeroS:= Zero( Source( mapp ) );
      cokernel:= [];
      for pair in Enumerator( mapp ) do
        if pair[1] = zeroS then
          Add( cokernel, pair[2] );
        fi;
      od;

    elif IsFinite( Range( mapp ) ) then

      zeroS:= Zero( Source( mapp ) );
      cokernel:= Filtered( Enumerator( Range( mapp ) ),
                           r -> Tuple( [ zeroS, r ] ) in mapp );

    else
      Error( "cannot compute cokernel of infinite mapping" );
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
    "method for s.p. gen. mapping respecting add. & add.inv., and element",
    CollFamSourceEqFamElms,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses,
      IsAdditiveGroup ], 0,
    function( map, elms )

    if not IsTotal( map ) then
      elms:= Intersection2( elms, PreImagesRange( map ) );
    fi;

    return ClosureAdditiveGroup( CoKernelOfAdditiveGeneralMapping( map ),
                   SubadditiveMagmaWithInversesNC( Range( map ),
                   List( GeneratorsOfAdditiveMagmaWithInverses( elms ),
                         gen -> ImagesRepresentative( map, gen ) ) ) );
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
    
    pre:= ImagesRepresentative( map, elm );
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
      elms:= Intersection( elms, ImagesSource( map ) );
    fi;
    return ClosureAdditiveGroup( KernelOfAdditiveGeneralMapping( map ),
                   SubadditiveMagmaWithInversesNC( Source( map ),
                   List( GeneratorsOfAdditiveMagmaWithInverses( elms ),
                         gen -> PreImagesRepresentative( map, gen ) ) ) );
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
      return false;
    elif not IsFinite( D ) or not IsFinite( map ) then
      Error( "cannot determine whether infinite mapping <map> ",
             "respects scalar multiplication" );
    else
      D:= Enumerator( D );
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
#M  IsFieldHomomorphism( <mapp> )
##
InstallMethod( IsFieldHomomorphism,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    map -> IsRingHomomorphism( map ) and IsField( Source( map ) ) );


#############################################################################
##
#E  mapphomo.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



