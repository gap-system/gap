#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, and Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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
    [ IsGeneralMapping ],
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
        if not DirectProductElement( [ pair1[1] * pair2[1], pair1[2] * pair2[2] ] )
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
    [ IsGeneralMapping ],
    function( map )
    local S, R;
    S:= Source( map );
    R:= Range(  map );
    return     IsMagmaWithOne( S )
           and IsMagmaWithOne( R )
           and One( R ) in ImagesElm( map, One( S ) );
    end );


#############################################################################
##
#M  RespectsInverses( <mapp> )  . . . . . . . .  for a finite general mapping
##
InstallMethod( RespectsInverses,
    "method for a general mapping",
    [ IsGeneralMapping ],
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
      if not DirectProductElement( [ Inverse( pair[1] ), Inverse( pair[2] ) ] )
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
    [ IsGeneralMapping and RespectsMultiplication and RespectsOne ],
    function( mapp )

    local S, oneR, kernel, pair;

    S:= Source( mapp );
    if IsFinite( S ) then

      oneR:= One( Range( mapp ) );
      kernel:= Filtered( Enumerator( S ),
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

    if     IsMagmaWithInverses( S )
       and HasRespectsInverses( mapp ) and RespectsInverses( mapp ) then
      return SubmagmaWithInversesNC( S, kernel );
    else
      return SubmagmaWithOneNC( S, kernel );
    fi;
    end );


#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <map> )
#M              . . .  for injective gen. mapping that respects mult. and one
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    "method for an injective gen. mapping that respects mult. and one",
    [ IsGeneralMapping and RespectsMultiplication
                       and RespectsOne and IsInjective ],
    SUM_FLAGS,# can't do better in injective case
    map -> TrivialSubmagmaWithOne( Source( map ) ) );


#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <mapp> )  for finite gen. mapping
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
    "method for a finite general mapping",
    [ IsGeneralMapping and RespectsMultiplication and RespectsOne ],
    function( mapp )

    local R, oneS, cokernel, rel, pair;

    R:= Range( mapp );
    if IsFinite( R ) then

      oneS:= One( Source( mapp ) );
      rel:= UnderlyingRelation( mapp );
      cokernel:= Filtered( Enumerator( R ),
                           r -> DirectProductElement( [ oneS, r ] ) in rel );

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

    if     IsMagmaWithInverses( R )
       and HasRespectsInverses( mapp ) and RespectsInverses( mapp ) then
      return SubmagmaWithInversesNC( R, cokernel );
    else
      return SubmagmaWithOneNC( R, cokernel );
    fi;
    end );


#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <map> )
#M            . .  for single-valued gen. mapping that respects mult. and one
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
    "method for a single-valued gen. mapping that respects mult. and one",
    [ IsGeneralMapping and RespectsMultiplication
                       and RespectsOne and IsSingleValued ],
    SUM_FLAGS,# can't do better in single-valued case
#T SUM_FLAGS ?
    map -> TrivialSubmagmaWithOne( Range( map ) ) );


#############################################################################
##
#M  IsSingleValued( <map> ) . .  for gen. mapping that respects mult. and one
##
InstallMethod( IsSingleValued,
    "method for a gen. mapping that respects mult. and inverses",
    [ IsGeneralMapping and RespectsMultiplication and RespectsInverses ],
    map -> IsTrivial( CoKernelOfMultiplicativeGeneralMapping( map ) ) );


#############################################################################
##
#M  IsInjective( <map> )  . for gen. mapping that respects mult. and inverses
##
InstallMethod( IsInjective,
    "method for a gen. mapping that respects mult. and one",
    [ IsGeneralMapping and RespectsMultiplication and RespectsInverses ],
    map -> IsTrivial( KernelOfMultiplicativeGeneralMapping( map ) ) );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . . .  for s.p. gen. mapping resp. mult. & inv.
##
InstallMethod( ImagesElm,
    "method for s.p. general mapping respecting mult. & inv., and element",
    FamSourceEqFamElm,
    [ IsSPGeneralMapping and RespectsMultiplication and RespectsInverses,
      IsObject ],
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
      IsGroup ],
function( map, elms )
  local genimages, img;
  # Try to map a generating set of elms; this works if and only if map
  # is defined on all of elms.
  genimages:= List( GeneratorsOfMagmaWithInverses( elms ),
                    gen -> ImagesRepresentative( map, gen ) );
  if fail in genimages then
    TryNextMethod();
  fi;

  img := SubgroupNC( Range( map ), Concatenation(
              GeneratorsOfMagmaWithInverses(
                  CoKernelOfMultiplicativeGeneralMapping( map ) ),
              genimages ) );
  if IsSingleValued(map) then
    # At this point we know that the restriction of map to elms is a
    # group homomorphism. Hence we can transfer some knowledge about
    # elms to img.
    if HasIsInjective(map) and IsInjective(map) then
      UseIsomorphismRelation( elms, img );
    else
      UseFactorRelation( elms, fail, img );
    fi;
  fi;
  return img;
end );

InstallMethod( ImagesSet,
    "method for injective s.p. mapping respecting mult. & inv., and group",
    CollFamSourceEqFamElms,
    [ IsSPGeneralMapping and IsMapping and IsInjective and
      RespectsMultiplication and RespectsInverses,
      IsGroup ],
    function( map, elms )
    local   img;

    img := SubgroupNC( Range( map ),
                    List( GeneratorsOfMagmaWithInverses( elms ),
                          gen -> ImagesRepresentative( map, gen ) ) );
    UseIsomorphismRelation( elms, img );
    if     IsActionHomomorphism( map )
       and HasBaseOfGroup( UnderlyingExternalSet( map ) )
       and not HasBaseOfGroup( img )
       and not HasStabChainMutable( img )  then
        if not IsBound( UnderlyingExternalSet( map )!.basePermImage )  then
            UnderlyingExternalSet( map )!.basePermImage :=
             List(BaseOfGroup(UnderlyingExternalSet(map)),
                  b->PositionCanonical(HomeEnumerator(
                         UnderlyingExternalSet( map ) ), b ) );
        fi;
        SetBaseOfGroup( img, UnderlyingExternalSet( map )!.basePermImage );
#T is this the right place?
#T and is it allowed to access `!.basePermImage'?
    fi;
    return img;
    end );


#############################################################################
##
#M  PreImagesElm( <map>, <elm> )  .  for s.p. gen. mapping resp. mult. & inv.
##
InstallMethod( PreImagesElm,
    "method for s.p. general mapping respecting mult. & inv., and element",
    FamRangeEqFamElm,
    [ IsSPGeneralMapping and RespectsMultiplication and RespectsInverses,
      IsObject ],
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
      IsGroup ],
  function( map, elms )
  local genpreimages,  pre;
    genpreimages:=GeneratorsOfMagmaWithInverses( elms );
    if Length(genpreimages)>0 and CanEasilyCompareElements(genpreimages[1]) then
      # remove identities
      genpreimages:=Filtered(genpreimages,i->i<>One(i));
    fi;

    genpreimages:= List(genpreimages,
                      gen -> PreImagesRepresentative( map, gen ) );
    if fail in genpreimages then
      TryNextMethod();
    fi;

    pre := SubgroupNC( Source( map ), Concatenation(
               GeneratorsOfMagmaWithInverses(
                   KernelOfMultiplicativeGeneralMapping( map ) ),
               genpreimages ) );
    if     HasSize( KernelOfMultiplicativeGeneralMapping( map ) )
       and HasSize( elms )  then
        SetSize( pre, Size( KernelOfMultiplicativeGeneralMapping( map ) )
                * Size( elms ) );
    fi;
    return pre;
    end );

InstallMethod( PreImagesSet,
    "method for injective s.p. mapping respecting mult. & inv., and group",
    CollFamRangeEqFamElms,
    [ IsSPGeneralMapping and IsMapping and IsInjective and
      RespectsMultiplication and RespectsInverses,
      IsGroup ],
    function( map, elms )
    local   pre;

    pre := SubgroupNC( Source( map ),
                    List( GeneratorsOfMagmaWithInverses( elms ),
                          gen -> PreImagesRepresentative( map, gen ) ) );
    UseIsomorphismRelation( elms, pre );
    return pre;
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
    [ IsGeneralMapping ],
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
        if not DirectProductElement( [ pair1[1] + pair2[1], pair1[2] + pair2[2] ] )
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
    [ IsGeneralMapping ],
    function( map )
    local S, R;
    S:= Source( map );
    R:= Range(  map );
    return     IsAdditiveMagmaWithZero( S )
           and IsAdditiveMagmaWithZero( R )
           and Zero( R ) in ImagesElm( map, Zero( S ) );
    end );


#############################################################################
##
#M  RespectsAdditiveInverses( <mapp> )  . . . .  for a finite general mapping
##
InstallMethod( RespectsAdditiveInverses,
    "method for a general mapping",
    [ IsGeneralMapping ],
    function( map )
    local S, R, enum, pair;
    S:= Source( map );
    R:= Range(  map );
    if not (     IsAdditiveGroup( S )
             and IsAdditiveGroup( R ) ) then
      return false;
    fi;

    map:= UnderlyingRelation( map );
    if not IsFinite( map ) then
      TryNextMethod();
    fi;

    enum:= Enumerator( map );
    for pair in enum do
      if not DirectProductElement( [ AdditiveInverse( pair[1] ),
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
    [ IsGeneralMapping and RespectsAddition and RespectsZero ],
    function( mapp )

    local S, zeroR, rel, kernel, pair;

    S:= Source( mapp );
    if IsFinite( Source( mapp ) ) then

      zeroR:= Zero( Range( mapp ) );
      rel:= UnderlyingRelation( mapp );
      kernel:= Filtered( Enumerator( S ),
                         s -> DirectProductElement( [ s, zeroR ] ) in rel );

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

    if     IsAdditiveGroup( S )
       and HasRespectsAdditiveInverses( mapp )
       and RespectsAdditiveInverses( mapp ) then
      return SubadditiveMagmaWithInversesNC( S, kernel );
    else
      return SubadditiveMagmaWithZeroNC( S, kernel );
    fi;
    end );


#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <map> )
#M              . . .  for injective gen. mapping that respects add. and zero
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "method for an injective gen. mapping that respects add. and zero",
    [ IsGeneralMapping and RespectsAddition
                       and RespectsZero and IsInjective ],
    SUM_FLAGS,# can't do better in injective case
    map -> TrivialSubadditiveMagmaWithZero( Source( map ) ) );


#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <map> ) . . . . . . . .  for zero mapping
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "method for zero mapping",
    [ IsGeneralMapping and RespectsAddition and RespectsZero and IsZero ],
    SUM_FLAGS,# can't do better for zero mapping
    Source );


#############################################################################
##
#M  CoKernelOfAdditiveGeneralMapping( <mapp> )  .  for finite general mapping
##
InstallMethod( CoKernelOfAdditiveGeneralMapping,
    "method for a finite general mapping",
    [ IsGeneralMapping and RespectsAddition and RespectsZero ],
    function( mapp )

    local R, zeroS, rel, cokernel, pair;

    R:= Range( mapp );
    if IsFinite( R ) then

      zeroS:= Zero( Source( mapp ) );
      rel:= UnderlyingRelation( mapp );
      cokernel:= Filtered( Enumerator( R ),
                           r -> DirectProductElement( [ zeroS, r ] ) in rel );

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

    if     IsAdditiveGroup( R )
       and HasRespectsAdditiveInverses( mapp )
       and RespectsAdditiveInverses( mapp ) then
      return SubadditiveMagmaWithInversesNC( R, cokernel );
    else
      return SubadditiveMagmaWithZeroNC( R, cokernel );
    fi;
    end );


#############################################################################
##
#M  CoKernelOfAdditiveGeneralMapping( <map> )
#M            . .  for single-valued gen. mapping that respects add. and zero
##
InstallMethod( CoKernelOfAdditiveGeneralMapping,
    "method for a single-valued gen. mapping that respects add. and zero",
    [ IsGeneralMapping and RespectsAddition
                       and RespectsZero and IsSingleValued ],
    SUM_FLAGS,# can't do better in single-valued case
#T SUM_FLAGS ?
    map -> TrivialSubadditiveMagmaWithZero( Range( map ) ) );


#############################################################################
##
#M  IsSingleValued( <map> ) . for gen. mapping that respects add. & add. inv.
##
InstallMethod( IsSingleValued,
    "method for a gen. mapping that respects add. and add. inverses",
    [ IsGeneralMapping and RespectsAddition and RespectsAdditiveInverses ],
    map -> IsTrivial( CoKernelOfAdditiveGeneralMapping(map) ) );


#############################################################################
##
#M  IsInjective( <map> )  . . for gen. mapping that respects add. & add. inv.
##
InstallMethod( IsInjective,
    "method for a gen. mapping that respects add. and add. inverses",
    [ IsGeneralMapping and RespectsAddition and RespectsAdditiveInverses ],
    map -> IsTrivial( KernelOfAdditiveGeneralMapping(map) ) );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . . for s.p. gen. mapping resp. add. & add.inv.
##
InstallMethod( ImagesElm,
    "method for s.p. gen. mapping respecting add. & add.inv., and element",
    FamSourceEqFamElm,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses,
      IsObject ],
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
      IsAdditiveGroup ],
    function( map, elms )
    local genimages;
    genimages:= List( GeneratorsOfAdditiveGroup( elms ),
                      gen -> ImagesRepresentative( map, gen ) );
    if fail in genimages then
      TryNextMethod();
    fi;

    return SubadditiveGroupNC( Range( map ), Concatenation(
               GeneratorsOfAdditiveGroup(
                   CoKernelOfAdditiveGeneralMapping( map ) ),
               genimages ) );
    end );


#############################################################################
##
#M  PreImagesElm( <map>, <elm> )  for s.p. gen. mapping resp. add. & add.inv.
##
InstallMethod( PreImagesElm,
    "method for s.p. gen. mapping respecting add. & add.inv., and element",
    FamRangeEqFamElm,
    [ IsSPGeneralMapping and RespectsAddition and RespectsAdditiveInverses,
      IsObject ],
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
      IsAdditiveGroup ],
    function( map, elms )
    local genpreimages;
    genpreimages:= List( GeneratorsOfAdditiveGroup( elms ),
                      gen -> PreImagesRepresentative( map, gen ) );
    if fail in genpreimages then
      TryNextMethod();
    fi;

    return SubadditiveGroupNC( Source( map ), Concatenation(
               GeneratorsOfAdditiveGroup(
                   KernelOfAdditiveGeneralMapping( map ) ),
               genpreimages ) );
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
    [ IsGeneralMapping ],
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
    fi;

    map:= UnderlyingRelation( map );

    if not IsFinite( D ) or not IsFinite( map ) then
      Error( "cannot determine whether the infinite mapping <map> ",
             "respects scalar multiplication" );
    else
      D:= Enumerator( D );
      for pair in Enumerator( map ) do
        for c in D do
          if not DirectProductElement( [ c * pair[1], c * pair[2] ] ) in map then
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
    [ IsGeneralMapping and RespectsAddition and RespectsZero
                       and RespectsScalarMultiplication ],
    function( mapp )

    local S, zeroR, rel, kernel, pair;

    S:= Source( mapp );
    if not IsExtLSet( S ) then
      TryNextMethod();
    fi;

    if IsFinite( S ) then

      zeroR:= Zero( Range( mapp ) );
      rel:= UnderlyingRelation( mapp );
      kernel:= Filtered( Enumerator( S ),
                         s -> DirectProductElement( [ s, zeroR ] ) in rel );

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

    return LeftModuleByGenerators( LeftActingDomain( S ), kernel );
    end );


#############################################################################
##
#M  CoKernelOfAdditiveGeneralMapping( <mapp> )  . . for finite linear mapping
##
##  We need a special method for being able to return a left module.
##
InstallMethod( CoKernelOfAdditiveGeneralMapping,
    "method for a finite linear mapping",
    [ IsGeneralMapping and RespectsAddition and RespectsZero
                       and RespectsScalarMultiplication ],
    function( mapp )

    local R, zeroS, rel, cokernel, pair;

    R:= Range( mapp );
    if not IsExtLSet( R ) then
      TryNextMethod();
    fi;

    if IsFinite( R ) then

      zeroS:= Zero( Source( mapp ) );
      rel:= UnderlyingRelation( mapp );
      cokernel:= Filtered( Enumerator( R ),
                           r -> DirectProductElement( [ zeroS, r ] ) in rel );

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

    return LeftModuleByGenerators( LeftActingDomain( R ), cokernel );
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
      IsLeftModule ],
    function( map, elms )
    local genimages;
    genimages:= List( GeneratorsOfLeftModule( elms ),
                      gen -> ImagesRepresentative( map, gen ) );
    if fail in genimages then
      TryNextMethod();
    fi;

    return SubmoduleNC( Range( map ), Concatenation(
               GeneratorsOfLeftModule(
                   CoKernelOfAdditiveGeneralMapping( map ) ),
               genimages ) );
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
      IsLeftModule ],
    function( map, elms )
    local genpreimages;
    genpreimages:= List( GeneratorsOfLeftModule( elms ),
                         gen -> PreImagesRepresentative( map, gen ) );
    if fail in genpreimages then
      TryNextMethod();
    fi;

    return SubmoduleNC( Source( map ), Concatenation(
               GeneratorsOfLeftModule(
                   KernelOfAdditiveGeneralMapping( map ) ),
               genpreimages ) );
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
    [ IsGeneralMapping ],
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
      IsFLMLOR ],
    function( map, elms )
    local genimages;
    genimages:= List( GeneratorsOfLeftOperatorRing( elms ),
                      gen -> ImagesRepresentative( map, gen ) );
    if fail in genimages then
      TryNextMethod();
    fi;

    return SubFLMLORNC( Range( map ), Concatenation(
               GeneratorsOfLeftOperatorRing(
                   CoKernelOfAdditiveGeneralMapping( map ) ),
               genimages ) );
#T handle the case of ideals!
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
      IsFLMLORWithOne ],
    function( map, elms )
    local genimages;
    genimages:= List( GeneratorsOfLeftOperatorRingWithOne( elms ),
                      gen -> ImagesRepresentative( map, gen ) );
    if fail in genimages then
      TryNextMethod();
    fi;

    return SubFLMLORWithOneNC( Range( map ), Concatenation(
               GeneratorsOfLeftOperatorRingWithOne(
                   CoKernelOfAdditiveGeneralMapping( map ) ),
               genimages ) );
#T handle the case of ideals!
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
      IsFLMLOR ],
    function( map, elms )
    local genpreimages;
    genpreimages:= List( GeneratorsOfLeftOperatorRing( elms ),
                         gen -> PreImagesRepresentative( map, gen ) );
    if fail in genpreimages then
      TryNextMethod();
    fi;

    return SubFLMLORNC( Source( map ), Concatenation(
               GeneratorsOfLeftOperatorRing(
                   KernelOfAdditiveGeneralMapping( map ) ),
               genpreimages ) );
#T handle the case of ideals!
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
      IsFLMLORWithOne ],
    function( map, elms )
    local genpreimages;
    genpreimages:= List( GeneratorsOfLeftOperatorRingWithOne( elms ),
                         gen -> PreImagesRepresentative( map, gen ) );
    if fail in genpreimages then
      TryNextMethod();
    fi;

    return SubFLMLORNC( Source( map ), Concatenation(
               GeneratorsOfLeftOperatorRingWithOne(
                   KernelOfAdditiveGeneralMapping( map ) ),
               genpreimages ) );
#T handle the case of ideals!
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
#M  \=( <map1>, <map2> )  . . . . . . . . . . . . . . . .  for s.v. gen. map.
##
InstallEqMethodForMappingsFromGenerators( IsObject,
    AsList,
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
InstallEqMethodForMappingsFromGenerators( IsAdditiveGroup,
    GeneratorsOfAdditiveGroup,
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


#############################################################################
##
#M  \=( <map1>, <map2> )   s.v.g.m. resp. add.,add.inv.,mult.,one,scal. mult.
##
InstallEqMethodForMappingsFromGenerators( IsField,
    GeneratorsOfField,
    IsFieldHomomorphism,
    " that is a field homomorphism" );
