#############################################################################
##
#W  mapprep.gi                  GAP library                     Thomas Breuer
#W                                                         & Martin Schoenert
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains (representation dependent)
##
##  1. methods for general mappings in 'IsDefaultMappingRep'
##  2. methods for composition mappings,
##  3. methods for mappings by function,
##  4. methods for inverse mappings
##  5. methods for identity mappings
##  6. methods for zero mappings
##
Revision.mapprep_gi :=
    "@(#)$Id$";


#############################################################################
##
##  1. methods for general mappings in 'IsDefaultMappingRep'
##

#############################################################################
##
#R  IsDefaultGeneralMappingRep( <map> )
##
##  Source and range of such a general mapping are stored in its kind, as
##  'DataKind( KindObj( <map> ) )[1]' resp.
##  'DataKind( KindObj( <map> ) )[2]'.
##
##  Note that this representation does *not* decide whether <map> is
##  a positional or a component object.
##
IsDefaultGeneralMappingRep := NewRepresentation(
    "IsDefaultGeneralMappingRep",
    IsGeneralMapping and HasSource and HasRange,
    [] );
#T methods to handle attributes 'One', 'Inverse', and 'InverseGeneralMapping', 
#T 'ImagesSource', 'PreImagesRange'?


#############################################################################
##
#F  KindOfDefaultGeneralMapping( <source>, <range>, <filter> )
##
KindOfDefaultGeneralMapping := function( source, range, filter )
    local Kind;

    # Do a cheap test whether the general mapping has equal source and range.
    if IsIdentical( source, range ) then
      filter:= filter and IsEndoGeneralMapping;
    fi;

    # Construct the kind.
    Kind:= NewKind( GeneralMappingsFamily(
                          ElementsFamily( FamilyObj( source ) ),
                          ElementsFamily( FamilyObj( range  ) ) ),
                    IsDefaultGeneralMappingRep and filter );

    # Store source and range.
    SetDataKind( Kind, [ source, range ] );

    # Return the kind.
    return Kind;
end;


#############################################################################
##
#M  Range( <map> )
##
InstallMethod( Range, true,
    [ IsGeneralMapping and IsDefaultGeneralMappingRep ],
    2*SUM_FLAGS + 1,  # higher than the system getter!
    map -> DataKind( KindObj( map ) )[2] );


#############################################################################
##
#M  Source( <map> )
##
InstallMethod( Source, true,
    [ IsGeneralMapping and IsDefaultGeneralMappingRep ],
    2*SUM_FLAGS + 1,  # higher than the system getter!
    map -> DataKind( KindObj( map ) )[1] );


#############################################################################
##
##  2. methods for composition mappings,
##

#############################################################################
##
#R  IsCompositionMappingRep( <map> )
##
IsCompositionMappingRep := NewRepresentation( "IsCompositionMappingRep",
    IsGeneralMapping and IsAttributeStoringRep, [ "map1", "map2" ] );
#T better list object?


#############################################################################
##
#M  CompositionMapping2( <map2>, <map1> ) . . . . .  for two general mappings
##
InstallMethod( CompositionMapping2,
    "method for two general mappings",
    FamSource1EqFamRange2,
    [ IsGeneralMapping, IsGeneralMapping ], 0,
    function( map2, map1 )
    local com;        # composition of <map1> and <map2>, result

    # Check that the source of 'map2' is a subset of the range of 'map1'
    if not IsSubset( Range( map1 ), Source( map2 ) ) then
      Error( "source of 'map2' must be a subset of the range of 'map1'" );
    fi;

    # make the general mapping
    if IsSPGeneralMapping( map1 ) and IsSPGeneralMapping( map2 ) then
      com:= Objectify( KindOfDefaultGeneralMapping( Source( map1 ),
                                                    Range( map2 ),
                        IsCompositionMappingRep and IsSPGeneralMapping ),
                     rec() );
    else
      com:= Objectify( KindOfDefaultGeneralMapping( Source( map1 ),
                                                    Range( map2 ),
                        IsCompositionMappingRep and IsNonSPGeneralMapping ),
                     rec() );
    fi;

    # enter the identifying information
    com!.map1:= map1;
    com!.map2:= map2;

    # enter useful information
    if     HasIsInjective( map1 ) and IsInjective( map1 )
       and HasIsInjective( map2 ) and IsInjective( map2 ) then
      SetIsInjective( com, true );
    fi;
    if     HasIsSingleValued( map1 ) and IsSingleValued( map1 )
       and HasIsSingleValued( map2 ) and IsSingleValued( map2 ) then
      SetIsSingleValued( com, true );
    fi;
    if     HasIsSurjective( map1 ) and IsSurjective( map1 )
       and HasIsSurjective( map2 ) and IsSurjective( map2 ) then
      SetIsSurjective( com, true );
    fi;
    if     HasIsTotal( map1 ) and IsTotal( map1 )
       and HasIsTotal( map2 ) and IsTotal( map2 ) then
      SetIsTotal( com, true );
    fi;

    # return the composition
    return com;
    end );


#############################################################################
##
#M  IsInjective( <map> )  . . . . . . . . . . . . . . for composition mapping
##
InstallMethod( IsInjective,
    "method for a composition mapping",
    true,
    [ IsCompositionMappingRep ], 0,
    function( com )
    if IsInjective( com!.map1 ) and IsInjective( com!.map2 ) then
      return true;
    fi;
    if not IsInjective( com!.map1 ) and IsTotal( com!.map2 ) then
      return false;
    fi;
    if     IsSurjective( com!.map1 ) and IsSingleValued( com!.map1 )
       and not IsInjective( com!.map2 ) then
      return false;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  IsSingleValued( <map> )   . . . . . . . . . . . . for composition mapping
##
InstallMethod( IsSingleValued,
    "method for a composition mapping",
    true,
    [ IsCompositionMappingRep ], 0,
    function( com )
    if IsSingleValued( com!.map1 ) and IsSingleValued( com!.map2 ) then
      return true;
    fi;
    if     not IsSingleValued( com!.map1 )
       and IsInjective( com!.map2 ) and IsTotal( com!.map2 ) then
      return false;
    fi;
    if IsSurjective( com!.map1 ) and not IsSingleValued( com!.map2 ) then
      return false;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  IsSurjective( <map> ) . . . . . . . . . . . . . . for composition mapping
##
InstallMethod( IsSurjective,
    "method for a composition mapping",
    true,
    [ IsCompositionMappingRep ], 0,
    function( com )
    if   not IsSurjective( com!.map2 ) then
      return false;
    elif IsSurjective( com!.map1 ) then
      return true;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  IsTotal( <map> )  . . . . . . . . . . . . . . . . for composition mapping
##
InstallMethod( IsTotal,
    "method for a composition mapping",
    true,
    [ IsCompositionMappingRep ], 0,
    function( com )
    if not IsTotal( com!.map1 ) then
      return false;
    elif IsTotal( com!.map2 ) then
      return true;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . . . . . . . . . . . . for composition mapping
##
InstallMethod( ImagesElm,
    "method for a composition mapping, and an element",
    FamSourceEqFamElm,
    [ IsCompositionMappingRep, IsObject ], 0,
    function( com, elm )
    local im;
    im:= ImagesElm( com!.map1, elm );
    if not IsEmpty( im ) then
      return ImagesSet( com!.map2, im );
    else
      return [];
    fi;
    end );


#############################################################################
##
#M  ImagesSet( <map>, <elms> )  . . . . . . . . . . . for composition mapping
##
InstallMethod( ImagesSet,
    "method for a composition mapping, and an collection",
    CollFamSourceEqFamElms,
    [ IsCompositionMappingRep, IsCollection ], 0,
    function ( com, elms )
    local im;
    im:= ImagesSet( com!.map1, elms );
    if not IsEmpty( im ) then
      return ImagesSet( com!.map2, im );
    else
      return [];
    fi;
    end );


#############################################################################
##
#M  ImagesRepresentative( <map>, <elm> )  . . . . . . for composition mapping
##
InstallMethod( ImagesRepresentative,
    "method for a composition mapping, and an element",
    FamSourceEqFamElm,
    [ IsCompositionMappingRep, IsObject ], 0,
    function( com, elm )
    local im, rep;
    im:= ImagesRepresentative( com!.map1, elm );
    if im = fail then
      # 'elm' has no images under 'com!.map1', so it has none under 'com'.
      return fail;
    else
      im:= ImagesRepresentative( com!.map2, im );
      if im <> fail then
        return im;
      fi;

      # It may happen that only the chosen representative has no images.
      for im in Enumerator( ImagesElm( com!.map1, elm ) ) do
        rep:= ImagesRepresentative( com!.map2, im );
        if rep <> fail then
          return rep;
        fi;
      od;
      return fail;
    fi;
    end );


#############################################################################
##
#M  PreImagesElm( <map>, <elm> )  . . . . . . . . . . for composition mapping
##
InstallMethod( PreImagesElm,
    "method for a composition mapping, and an element",
    FamRangeEqFamElm,
    [ IsCompositionMappingRep, IsObject ], 0,
    function( com, elm )
    local im;
    im:= PreImagesElm( com!.map2, elm );
    if not IsEmpty( im ) then
      return PreImagesSet( com!.map1, im );
    else
      return [];
    fi;
    end );


#############################################################################
##
#M  PreImagesSet( <map>, <elm> )  . . . . . . . . . . for composition mapping
##
InstallMethod( PreImagesSet,
    "method for a composition mapping, and an collection",
    CollFamRangeEqFamElms,
    [ IsCompositionMappingRep, IsCollection ], 0,
    function( com, elms )
    local im;
    im:= PreImagesSet( com!.map2, elms );
    if not IsEmpty( im ) then
      return PreImagesSet( com!.map1, im );
    else
      return [];
    fi;
    end );


#############################################################################
##
#M  PreImagesRepresentative( <map>, <elm> ) . . . . . for composition mapping
##
InstallMethod( PreImagesRepresentative,
    "method for a composition mapping, and an element",
    FamRangeEqFamElm,
    [ IsCompositionMappingRep, IsObject ], 0,
    function( com, elm )
    local im, rep;
    im:= PreImagesRepresentative( com!.map2, elm );
    if im = fail then
      # 'elm' has no preimages under 'com!.map2', so it has none under 'com'.
      return fail;
    else
      im:= PreImagesRepresentative( com!.map1, im );
      if im <> fail then
        return im;
      fi;

      # It may happen that only the chosen representative has no preimages.
      for im in Enumerator( PreImagesElm( com!.map2, elm ) ) do
        rep:= PreImagesRepresentative( com!.map1, im );
        if rep <> fail then
          return rep;
        fi;
      od;
      return fail;
    fi;
    end );


#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <map> ) . . . . . for composition mapping
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "method for a composition mapping that resp. add. and add.inv.",
    true,
    [ IsGeneralMapping and IsCompositionMappingRep
      and RespectsAddition and RespectsAdditiveInverses ], 0,
    function( com )
    if IsInjective( com!.map2 ) then
      return KernelOfAdditiveGeneralMapping( com!.map1 );
    else
      return PreImagesSet( com!.map1,
                 KernelOfAdditiveGeneralMapping( com!.map2 ) );
    fi;
    end );


#############################################################################
##
#M  CoKernelOfAdditiveGeneralMapping( <map> ) . . . . for composition mapping
##
InstallMethod( CoKernelOfAdditiveGeneralMapping,
    "method for a composition mapping that resp. add. and add.inv.",
    true,
    [ IsGeneralMapping and IsCompositionMappingRep
      and RespectsAddition and RespectsAdditiveInverses ], 0,
    function( com )
    if IsSingleValued( com!.map1 ) then
      return CoKernelOfAdditiveGeneralMapping( com!.map2 );
    else
      return ImagesSet( com!.map2,
                 CoKernelOfAdditiveGeneralMapping( com!.map1 ) );
    fi;
    end );


#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <map> ) . . for composition mapping
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    "method for a composition mapping that resp. mult. and inv.",
    true,
    [ IsGeneralMapping and IsCompositionMappingRep
      and RespectsMultiplication and RespectsInverses ], 0,
    function( com )
    if IsInjective( com!.map2 ) then
      return KernelOfMultiplicativeGeneralMapping( com!.map1 );
    else
      return PreImagesSet( com!.map1,
                 KernelOfMultiplicativeGeneralMapping( com!.map2 ) );
    fi;
    end );


#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <map> ) . for composition mapping
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
    "method for a composition mapping that resp. mult. and inv.",
    true,
    [ IsGeneralMapping and IsCompositionMappingRep
      and RespectsMultiplication and RespectsInverses ], 0,
    function( com )
    if IsSingleValued( com!.map1 ) then
      return CoKernelOfMultiplicativeGeneralMapping( com!.map2 );
    else
      return ImagesSet( com!.map2,
                 CoKernelOfMultiplicativeGeneralMapping( com!.map1 ) );
    fi;
    end );


#############################################################################
##
#M  PrintObj( <map> ) . . . . . . . . . . . . . . . . for composition mapping
##
InstallMethod( PrintObj,
    "method for a composition mapping",
    true,
    [ IsCompositionMappingRep ], 100,
    function( com )
    Print( "CompositionMapping( ", com!.map1, ", ", com!.map2, " )" );
    end );
 

#############################################################################
##
##  3. methods for mappings by function,
##

#############################################################################
##
#R  IsMappingByFunctionRep( <map> )
##
IsMappingByFunctionRep := NewRepresentation(
    "IsMappingByFunctionRep",
    IsNonSPGeneralMapping and IsMapping and IsAttributeStoringRep,
    [ "fun" ] );
#T really attribute storing ??


#############################################################################
##
#R  IsMappingByFunctionWithInverseRep( <map> )
##
IsMappingByFunctionWithInverseRep := NewRepresentation(
    "IsMappingByFunctionWithInverseRep",
        IsMappingByFunctionRep
    and IsBijective,
#T 1996/10/10 fceller where to put non-reps, 4th position?
    [ "fun", "invFun" ] );


#############################################################################
##
#F  MappingByFunction( <D>, <E>, <fun> )  . . . . .  create map from function
#F  MappingByFunction( <D>, <E>, <fun>, <invfun> )
##
MappingByFunction := function ( arg )
    local   map;        # mapping <map>, result

    # no inverse function given
    if Length(arg) = 3  then

      # make the general mapping
      map:= Objectify( KindOfDefaultGeneralMapping( arg[1], arg[2],
                               IsMappingByFunctionRep
                           and IsSingleValued
                           and IsTotal ),
                       rec( fun:= arg[3] ) );

    # inverse function given
    elif Length(arg) = 4  then

      # make the mapping
      map:= Objectify( KindOfDefaultGeneralMapping( arg[1], arg[2],
                               IsMappingByFunctionWithInverseRep
                           and IsBijective ),
                       rec( fun    := arg[3],
                            invFun := arg[4] ) );

    # otherwise signal an error
    else
      Error( "usage: MappingByFunction( <D>, <E>, <fun>[, <inv>] )" );
    fi;

    # return the mapping
    return map;
end;


#############################################################################
##
#M  ImageElm( <map>, <elm> )  . . . . . . . . . . . . for mapping by function
##
InstallMethod( ImageElm,
    "method for mapping by function",
    FamSourceEqFamElm,
    [ IsMappingByFunctionRep, IsObject ], 0,
    function ( map, elm )
    return map!.fun( elm );
    end );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . . . . . . . . . . . . for mapping by function
##
InstallMethod( ImagesElm,
    "method for mapping by function",
    FamSourceEqFamElm,
    [ IsMappingByFunctionRep, IsObject ], 0,
    function ( map, elm )
    return [ map!.fun( elm ) ];
    end );


#############################################################################
##
#M  ImagesRepresentative( <map>, <elm> )  . . . . . . for mapping by function
##
InstallMethod( ImagesRepresentative,
    "method for mapping by function",
    FamSourceEqFamElm,
    [ IsMappingByFunctionRep, IsObject ], 0,
    function ( map, elm )
    return map!.fun( elm );
    end );


#############################################################################
##
#M  PreImageElm( <map>, <elm> ) . . . . . . . . . . . for mapping by function
##
InstallMethod( PreImageElm,
    "method for mapping by function",
    FamRangeEqFamElm,
    [ IsMappingByFunctionWithInverseRep, IsObject ], 0,
    function ( map, elm )
    return map!.invFun( elm );
    end );


#############################################################################
##
#M  PreImagesElm( <map>, <elm> )  . . . . . . . . . . for mapping by function
##
InstallMethod( PreImagesElm,
    "method for mapping by function",
    FamRangeEqFamElm,
    [ IsMappingByFunctionWithInverseRep, IsObject ], 0,
    function ( map, elm )
    return [ map!.invFun( elm ) ];
    end );


#############################################################################
##
#M  PreImagesRepresentative( <map>, <elm> ) . . . . . for mapping by function
##
InstallMethod( PreImagesRepresentative,
    "method for mapping by function",
    FamRangeEqFamElm,
    [ IsMappingByFunctionWithInverseRep, IsObject ], 0,
    function ( map, elm )
    return map!.invFun( elm );
    end );


#############################################################################
##
#M  InverseGeneralMapping( <map> )  . . . . . . . . . for mapping by function
##
InstallMethod( InverseGeneralMapping,
    "method for mapping by function",
    true,
    [ IsMappingByFunctionWithInverseRep ], 0,
    function ( map )
    local inv;
    inv:= MappingByFunction( Range( map ), Source( map ),
                             map!.invFun, map!.fun );
    SetInverseGeneralMapping( inv, map );
    return inv;
    end );


#############################################################################
##
#M  PrintObj( <map> ) . . . . . . . . . . . . . . . . for mapping by function
##
InstallMethod( PrintObj,
    "method for mapping by function",
    true,
    [ IsMappingByFunctionRep ], 0,
    function ( map )
    Print( "GeneralMappingByFunction( ",
           Source( map ), ", ", Range( map ), ", ",
           map!.fun, " )" );
    end );


#############################################################################
##
#M  PrintObj( <map> ) . . . . . . . . .  for mapping by function with inverse
##
InstallMethod( PrintObj,
    "method for mapping by function with inverse",
    true,
    [ IsMappingByFunctionWithInverseRep ], 0,
    function ( map )
    Print( "MappingByFunction( ",
           Source( map ), ", ", Range( map ), ", ",
           map!.fun, ", ", map!.invFun, " )" );
    end );


#############################################################################
##
##  4. methods for inverse mappings
##

#############################################################################
##
#R  IsInverseGeneralMappingRep( <map> )
##
##  Note that if a mapping knows its inverse mapping then also the inverse
##  mapping knows its inverse mapping.
##  So we need this flag to avoid infinite recursion when a question is
##  delegated to the inverse of a mapping.
##
IsInverseGeneralMappingRep := NewRepresentation(
    "IsInverseGeneralMappingRep",
    IsNonSPGeneralMapping,
    [] );


#############################################################################
##
#M  InverseGeneralMapping( <map> ) . for a general mapping with known inverse
##
InstallImmediateMethod( InverseGeneralMapping,
    IsGeneralMapping and HasInverse, 0,
    function( map )
    if Inverse( map ) <> fail then
      return Inverse( map );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  InverseGeneralMapping( <map> ) . . . . . . . . . .  for a general mapping
##
InstallMethod( InverseGeneralMapping,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function ( map )
    local   inv;

    # make the mapping
    inv:= Objectify( KindOfDefaultGeneralMapping( Range( map ),
                                                  Source( map ),
                             IsInverseGeneralMappingRep
                         and IsAttributeStoringRep ),
                     rec() );

    # if possible, enter preimage and image
    if HasImagesSource( map ) then
      SetPreImagesRange( inv, ImagesSource( map ) );
    fi;
    if HasPreImagesRange( map )  then
      SetImagesSource( inv, PreImagesRange( map ) );
    fi;

    # Enter known properties.
    if HasIsTotal( map ) then
      SetIsSurjective( inv, IsTotal( map ) );
    fi;
    if HasIsSurjective( map ) then
      SetIsTotal( inv, IsSurjective( map ) );
    fi;
    if HasIsInjective( map ) then
      SetIsSingleValued( inv, IsInjective( map ) );
    fi;
    if HasIsSingleValued( map ) then
      SetIsInjective( inv, IsSingleValued( map ) );
    fi;

    if HasRespectsMultiplication( map ) then
      SetRespectsMultiplication( inv, RespectsMultiplication( map ) );
    fi;
    if HasRespectsInverses( map ) then
      SetRespectsInverses( inv, RespectsInverses( map ) );
    elif HasRespectsOne( map ) then
      SetRespectsOne( inv, RespectsOne( map ) );
    fi;

    if HasRespectsAddition( map ) then
      SetRespectsAddition( inv, RespectsAddition( map ) );
    fi;
    if HasRespectsAdditiveInverses( map ) then
      SetRespectsAdditiveInverses( inv, RespectsAdditiveInverses( map ) );
    elif HasRespectsZero( map ) then
      SetRespectsZero( inv, RespectsZero( map ) );
    fi;

#T there is an asymmetry of resp. sc. mult.?

    # we know the inverse general mapping of the inverse general mapping ;-)
    SetInverseGeneralMapping( inv, map );

    # return the inverse general mapping
    return inv;
    end );


#############################################################################
##
#M  IsSingleValued( <map> ) . . . . . . . . . . . . .  for an inverse mapping
##
InstallMethod( IsSingleValued,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseGeneralMappingRep ], 0,
    inv -> IsInjective( InverseGeneralMapping( inv ) ) );


#############################################################################
##
#M  IsInjective( <map> )  . . . . . . . . . . . . . .  for an inverse mapping
##
InstallMethod( IsInjective,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseGeneralMappingRep ], 0,
    inv -> IsSingleValued( InverseGeneralMapping( inv ) ) );


#############################################################################
##
#M  IsSurjective( <map> ) . . . . . . . . . . . . . .  for an inverse mapping
##
InstallMethod( IsSurjective,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseGeneralMappingRep ], 0,
    inv -> IsTotal( InverseGeneralMapping( inv ) ) );


#############################################################################
##
#M  IsTotal( <map> )  . . . . . . . . . . . . . . . .  for an inverse mapping
##
InstallMethod( IsTotal,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseGeneralMappingRep ], 0,
    inv -> IsSurjective( InverseGeneralMapping( inv ) ) );


#############################################################################
##
#M  CoKernelOfAdditiveGeneralMapping( <invmap> )  . . . . for inverse mapping
##
InstallMethod( CoKernelOfAdditiveGeneralMapping,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseGeneralMappingRep ], 0,
    inv -> KernelOfAdditiveGeneralMapping(
               InverseGeneralMapping( inv ) ) );


#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <invmap> )  . . . . . for inverse mapping
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseGeneralMappingRep ], 0,
    inv -> CoKernelOfAdditiveGeneralMapping(
               InverseGeneralMapping( inv ) ) );


#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <invmap> )  . for inverse mapping
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseGeneralMappingRep ], 0,
    inv -> KernelOfMultiplicativeGeneralMapping(
               InverseGeneralMapping( inv ) ) );


#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <invmap> )  . . for inverse mapping
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseGeneralMappingRep ], 0,
    inv -> CoKernelOfMultiplicativeGeneralMapping(
               InverseGeneralMapping( inv ) ) );


#############################################################################
##
#M  ImageElm( <invmap>, <map> ) . . . . . . . for inverse mapping and element
##
InstallMethod( ImageElm,
    "for an inverse mapping and an element",
    FamSourceEqFamElm,
    [ IsMapping and IsInverseGeneralMappingRep, IsObject ], 0,
    function ( inv, elm )
    return PreImageElm( InverseGeneralMapping( inv ), elm );
    end );


#############################################################################
##
#M  ImagesElm( <invmap>, <map> )  . . . . . . for inverse mapping and element
##
InstallMethod( ImagesElm,
    "for an inverse mapping and an element",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsInverseGeneralMappingRep, IsObject ], 0,
    function ( inv, elm )
    return PreImagesElm( InverseGeneralMapping( inv ), elm );
    end );


#############################################################################
##
#M  ImagesSet( <invmap>, <coll> ) . . . .  for inverse mapping and collection
##
InstallMethod( ImagesSet,
    "for an inverse mapping and a collection",
    CollFamSourceEqFamElms,
    [ IsGeneralMapping and IsInverseGeneralMappingRep, IsCollection ], 0,
    function ( inv, elms )
    return PreImagesSet( InverseGeneralMapping( inv ), elms );
    end );


#############################################################################
##
#M  ImagesSet( <invmap>, <coll> ) . . . .  for inverse mapping and collection
##
InstallMethod( ImagesRepresentative,
    "for an inverse mapping and an element",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsInverseGeneralMappingRep, IsObject ], 0,
    function ( inv, elm )
    return PreImagesRepresentative( InverseGeneralMapping( inv ), elm );
    end );


#############################################################################
##
#M  PreImageElm( <invmap>, <elm> )  . . . . . for inverse mapping and element
##
InstallMethod( PreImageElm,
    "for an inj. & surj. inverse mapping, and an element",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsInverseGeneralMappingRep
                       and IsInjective and IsSurjective, IsObject ], 0,
    function ( inv, elm )
    return ImageElm( InverseGeneralMapping( inv ), elm );
    end );


#############################################################################
##
#M  PreImagesElm( <invmap>, <elm> ) . . . . . for inverse mapping and element
##
InstallMethod( PreImagesElm,
    "for an inverse mapping and an element",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsInverseGeneralMappingRep, IsObject ], 0,
    function ( inv, elm )
    return ImagesElm( InverseGeneralMapping( inv ), elm );
    end );


#############################################################################
##
#M  PreImagesSet( <invmap>, <coll> )  . .  for inverse mapping and collection
##
InstallMethod( PreImagesSet,
    "for an inverse mapping and a collection",
    CollFamRangeEqFamElms,
    [ IsGeneralMapping and IsInverseGeneralMappingRep, IsCollection ], 0,
    function ( inv, elms )
    return ImagesSet( InverseGeneralMapping( inv ), elms );
    end );


#############################################################################
##
#M  PreImagesRepresentative( <invmap>, <elm> )  . . for inv. mapping and elm.
##
InstallMethod( PreImagesRepresentative,
    "for an inverse mapping and an element",
    FamRangeEqFamElm,
    [ IsInverseGeneralMappingRep, IsObject ], 0,
    function ( inv, elm )
    return ImagesRepresentative( InverseGeneralMapping( inv ), elm );
    end );


#############################################################################
##
#M  PrintObj( <invmap> )  . . . . . . . . . . . . . . . . .  for inv. mapping
##
InstallMethod( PrintObj,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseGeneralMappingRep ], 100,
    function ( inv )
    Print( "InverseGeneralMapping( ", InverseGeneralMapping( inv )," )" );
    end );


#############################################################################
##
##  5. methods for identity mappings
##
##  For each domain we need to construct only one identity mapping.
##  In order to allow this to interact with other mappings of this domain
##  (for example, with automorphisms of a field in a special representation),
##  one needs to install methods to compare these mappings with the identity
##  mapping via '\=' and '\<'.
##
##  Methods for identity mappings are all installed with rank 'SUM_FLAGS'.
##

#############################################################################
##
##  An identity mapping whose source has a nice structure gets the properties
##  to respect this structure.
##
ImmediateImplicationsIdentityMapping := function( idmap )

    local source;

    source:= Source( idmap );

    # multiplicative structure
    if IsMagma( source ) then
      SetRespectsMultiplication( idmap, true );
      if IsMagmaWithOne( source ) then
	SetRespectsOne( idmap, true );
	if IsMagmaWithInverses( source ) then
	  SetRespectsInverses( idmap, true );
	fi;
      fi;
    fi;

    # additive structure
    if IsAdditiveMagma( source ) then
      SetRespectsAddition( idmap, true );
      if IsAdditiveMagmaWithZero( source ) then
	SetRespectsZero( idmap, true );
	if IsAdditiveMagmaWithInverses( source ) then
	  SetRespectsAdditiveInverses( idmap, true );

          # linear structure
          if IsLeftModule( source ) then
            SetRespectsScalarMultiplication( idmap, true );
          fi;

	fi;
      fi;
    fi;
end;


#############################################################################
##
#M  IdentityMapping( <D> )  . . . . . . . .  identity mapping of a collection
##
InstallMethod( IdentityMapping,
    "method for a collection",
    true,
    [ IsCollection ], 0,
    function( D )
    local id;

    # make the mapping
    id := Objectify( KindOfDefaultGeneralMapping( D, D,
                                  IsSPGeneralMapping
                              and IsAttributeStoringRep
                              and IsOne ),
                     rec() );

    # the identity mapping is self-inverse
    SetInverseGeneralMapping( id, id );

    # set the respectings
    ImmediateImplicationsIdentityMapping( id );

    # return the identity mapping
    return id;
    end );


#############################################################################
##
#M  \^( <idmap>, <n> )  . . . . . . . . . .  for identity mapping and integer
##
InstallMethod( \^,
    "method for identity mapping and integer",
    true,
    [ IsGeneralMapping and IsOne, IsInt ], SUM_FLAGS,
    function ( id, n )
    return id;
    end );

    
#############################################################################
##
#M  ImageElm( <idmap>, <elm> )  . . . . . .  for identity mapping and element
##
InstallMethod( ImageElm,
    "method for identity mapping and object",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsOne, IsObject ], SUM_FLAGS,
    function ( id, elm )
    return elm;
    end );

    
#############################################################################
##
#M  ImagesElm( <idmap>, <elm> )  . . . . . . for identity mapping and element
##
InstallMethod( ImagesElm,
    "method for identity mapping and object",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsOne, IsObject ], SUM_FLAGS,
    function ( id, elm )
    return [ elm ];
    end );

    
#############################################################################
##
#M  ImagesSet( <idmap>, <coll> ) . . . .  for identity mapping and collection
##
InstallMethod( ImagesSet,
    "method for identity mapping and collection",
    CollFamSourceEqFamElms,
    [ IsGeneralMapping and IsOne, IsCollection ], SUM_FLAGS,
    function ( id, elms )
    return elms;
    end );

    
#############################################################################
##
#M  ImagesRepresentative( <idmap>, <elm> )   for identity mapping and element
##
InstallMethod( ImagesRepresentative,
    "method for identity mapping and object",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsOne, IsObject ], SUM_FLAGS,
    function ( id, elm )
    return elm;
    end );


#############################################################################
##
#M  PreImageElm( <idmap>, <elm> )   . . . .  for identity mapping and element
##
InstallMethod( PreImageElm,
    "method for identity mapping and object",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsOne, IsObject ], SUM_FLAGS,
    function ( id, elm )
    return elm;
    end );


#############################################################################
##
#M  PreImagesElm( <idmap>, <elm> )  . . . .  for identity mapping and element
##
InstallMethod( PreImagesElm,
    "method for identity mapping and object",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsOne, IsObject ], SUM_FLAGS,
    function ( id, elm )
    return [ elm ];
    end );


#############################################################################
##
#M  PreImagesSet( <idmap>, <coll> ) . . . for identity mapping and collection
##
InstallMethod( PreImagesSet,
    "method for identity mapping and collection",
    CollFamRangeEqFamElms,
    [ IsGeneralMapping and IsOne, IsCollection ], SUM_FLAGS,
    function ( id, elms )
    return elms;
    end );


#############################################################################
##
#M  PreImagesRepresentative( <idmap>, <elm> )
##
InstallMethod( PreImagesRepresentative,
    "method for identity mapping and object",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsOne, IsObject ], SUM_FLAGS,
    function ( id, elm )
    return elm;
    end );


#############################################################################
##
#M  PrintObj( <idmap> ) . . . . . . . . . . . . . . . .  for identity mapping
##
InstallMethod( PrintObj,
    "method for identity mapping",
    true,
    [ IsGeneralMapping and IsOne ], SUM_FLAGS,
    function ( id )
    Print( "IdentityMapping( ", Source( id )," )" );
    end );


#############################################################################
##
#M  CompositionMapping2( <map>, <idmap> ) .  for gen. mapping and id. mapping
##
InstallMethod( CompositionMapping2,
    "method for general mapping and identity mapping",
    FamSource1EqFamRange2,
    [ IsGeneralMapping, IsGeneralMapping and IsOne ],
    SUM_FLAGS + 1,  # should be higher than the rank for a zero mapping
    function ( map, id )
    return map;
    end );


#############################################################################
##
#M  CompositionMapping2( <idmap>, <map> ) .  for id. mapping and gen. mapping
##
InstallMethod( CompositionMapping2,
    "method for identity mapping and general mapping",
    FamSource1EqFamRange2,
    [ IsGeneralMapping and IsOne, IsGeneralMapping ],
    SUM_FLAGS + 1,  # should be higher than the rank for a zero mapping
    function( id, map )
    return map;
    end );


#############################################################################
##
##  6. methods for zero mappings
##
##  methods for zero mappings are all installed with rank 'SUM_FLAGS'
##
#T (use 'IsZero' in '\+' method for mappings ...)


#############################################################################
##
##  A zero mapping whose source has a nice structure gets the properties
##  to respect this structure.
##
ImmediateImplicationsZeroMapping := function( zeromap )

    local source;

    source:= Source( zeromap );

    # multiplicative structure
    if IsMagma( source ) then
      SetRespectsMultiplication( zeromap, true );
      if IsMagmaWithOne( source ) then
	SetRespectsOne( zeromap, false );
	if IsMagmaWithInverses( source ) then
	  SetRespectsInverses( zeromap, false );
	fi;
      fi;
    fi;

    # additive structure
    if IsAdditiveMagma( source ) then
      SetRespectsAddition( zeromap, true );
      if IsAdditiveMagmaWithZero( source ) then
	SetRespectsZero( zeromap, true );
	if IsAdditiveMagmaWithInverses( source ) then
	  SetRespectsAdditiveInverses( zeromap, true );
	fi;
      fi;
    fi;

    # linear structure
    if IsLeftModule( source ) then
      SetRespectsScalarMultiplication( zeromap, true );
    fi;
end;


#############################################################################
##
#F  ZeroMapping( <source>, <range> )
##
##  maps every element of <source> to 'Zero( <range> )'.
##  This is independent of the structure of <source> and <range>.
##
InstallMethod( ZeroMapping,
    "method for collection and additive-magma-with-zero",
    true,
    [ IsCollection, IsAdditiveMagmaWithZero ], 0,
    function( S, R )

    local zero;   # the zero mapping, result

    # make the mapping
    zero := Objectify( KindOfDefaultGeneralMapping( S, R,
                                  IsSPGeneralMapping
                              and IsAttributeStoringRep
                              and IsZero ),
                       rec() );

    # set the respectings
    ImmediateImplicationsZeroMapping( zero );

    # return the zero mapping
    return zero;
    end );


#############################################################################
##
#M  \^( <zeromap>, <n> )  . . . . . . . for zero mapping and positive integer
##
InstallMethod( \^,
    "method for zero mapping and positive integer",
    true,
    [ IsGeneralMapping and IsZero, IsInt and IsPosRat ], SUM_FLAGS,
    function( zero, n )
    if Zero( Source( zero ) ) in Range( zero ) then
      return zero;
    else
      Error( "source and range of <zero> do not match" );
    fi;
    end );


#############################################################################
##
#M  ImagesSource( <zeromap> ) . . . . . . . . . . . . . . .  for zero mapping
##
InstallMethod( ImagesSource,
    "method for zero mapping",
    true,
    [ IsGeneralMapping and IsZero ], SUM_FLAGS,
    function( zero )
    if IsAdditiveMagmaWithZero( Range( zero ) ) then
      return TrivialSubadditiveMagmaWithZero( Range( zero ) );
    else
      return [ Zero( Range( zero ) ) ];
    fi;
    end );


#############################################################################
##
#M  ImageElm( <zeromap>, <elm> )  . . . . . . .  for zero mapping and element
##
InstallMethod( ImageElm,
    "method for zero mapping and object",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsZero, IsObject ], SUM_FLAGS,
    function( zero, elm )
    return Zero( Range( zero ) );
    end );


#############################################################################
##
#M  ImagesElm( <zeromap>, <elm> )  . . . . . . . for zero mapping and element
##
InstallMethod( ImagesElm,
    "method for zero mapping and object",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsZero, IsObject ], SUM_FLAGS,
    function( zero, elm )
    return [ Zero( Range( zero ) ) ];
    end );


#############################################################################
##
#M  ImagesSet( <zeromap>, <coll> ) . . . . .  for zero mapping and collection
##
InstallMethod( ImagesSet,
    "method for zero mapping and collection",
    CollFamSourceEqFamElms,
    [ IsGeneralMapping and IsZero, IsCollection ], SUM_FLAGS,
    function( zero, elms )
    return TrivialSubadditiveMagmaWithZero( Range( zero ) );
    end );


#############################################################################
##
#M  ImagesRepresentative( <zeromap>, <elm> )  .  for zero mapping and element
##
InstallMethod( ImagesRepresentative,
    "method for zero mapping and object",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsZero, IsObject ], SUM_FLAGS,
    function( zero, elm )
    return Zero( Range( zero ) );
    end );


#############################################################################
##
#M  PreImagesElm( <zeromap>, <elm> )  . . . . .  for zero mapping and element
##
InstallMethod( PreImagesElm,
    "method for zero mapping and object",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsZero, IsObject ], SUM_FLAGS,
    function( zero, elm )
    if elm = Zero( Range( zero ) ) then
      return Source( zero );
    else
      return [];
    fi;
    end );


#############################################################################
##
#M  PreImagesSet( <zeromap>, <elms> ) . . . . for zero mapping and collection
##
InstallMethod( PreImagesSet,
    "method for zero mapping and collection",
    CollFamRangeEqFamElms,
    [ IsGeneralMapping and IsZero, IsCollection ], SUM_FLAGS,
    function( zero, elms )
    if Zero( Range( zero ) ) in elms then
      return Source( zero );
    else
      return [];
    fi;
    end );


#############################################################################
##
#M  PreImagesRepresentative( <zeromap>, <elm> )
##
InstallMethod( PreImagesRepresentative,
    "method for zero mapping and object",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsZero, IsObject ], SUM_FLAGS,
    function( zero, elm )
    if elm = Zero( Range( zero ) ) then
      return Zero( Source( zero ) );
    else
      return fail;
    fi;
    end );


#############################################################################
##
#M  PrintObj( <zeromap> ) . . . . . . . . . . . . . . . . .  for zero mapping
##
InstallMethod( PrintObj,
    "method for zero mapping",
    true,
    [ IsGeneralMapping and IsZero ], SUM_FLAGS,
    function( zero )
    Print( "ZeroMapping( ", Source( zero ), ", ", Range( zero ), " )" );
    end );


#############################################################################
##
#M  CompositionMapping2( <map>, <zeromap> ) for gen. mapping and zero mapping
##
InstallMethod( CompositionMapping2,
    "method for general mapping and zero mapping",
    FamSource1EqFamRange2,
    [ IsGeneralMapping, IsGeneralMapping and IsZero ], SUM_FLAGS,
    function( map, zero )
    return ZeroMapping( Source( map ), Range( zero ) );
    end );


#############################################################################
##
#M  CompositionMapping2( <zeromap>, <map> ) for zero mapping and gen. mapping
##
InstallMethod( CompositionMapping2,
    "method for zero mapping and single-valued gen. mapping that resp. zero",
    FamSource1EqFamRange2,
    [ IsGeneralMapping and IsZero,
      IsGeneralMapping and IsSingleValued and RespectsZero ],
    SUM_FLAGS,
    function( zero, map )
    return ZeroMapping( Source( zero ), Range( map ) );
    end );


#############################################################################
##
#M  IsInjective( <zeromap> )  . . . . . . . . . . . . . . .  for zero mapping
##
InstallMethod( IsInjective,
    "method for zero mapping",
    true,
    [ IsGeneralMapping and IsZero ], 0,
    zero -> Size( Source( zero ) ) = 1 );


#############################################################################
##
#M  IsSurjective( <zeromap> ) . . . . . . . . . . . . . . .  for zero mapping
##
InstallMethod( IsSurjective,
    "method for zero mapping",
    true,
    [ IsGeneralMapping and IsZero ], 0,
    zero -> Size( Range( zero ) ) = 1 );


#############################################################################
##
#E  mapprep.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



