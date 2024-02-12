#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Martin Schönert, Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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


#############################################################################
##
##  1. methods for general mappings in 'IsDefaultMappingRep'
##

#############################################################################
##
#R  IsDefaultGeneralMappingRep( <map> )
##
##  Source and range of such a general mapping are stored in its type, as
##  'DataType( TypeObj( <map> ) )[1]' resp.
##  'DataType( TypeObj( <map> ) )[2]'.
##
##  Note that this representation does *not* decide whether <map> is
##  a positional or a component object.
##
DeclareRepresentation( "IsDefaultGeneralMappingRep",
    IsGeneralMapping and HasSource and HasRange,
    [] );
#T methods to handle attributes 'One', 'Inverse', and 'InverseGeneralMapping',
#T 'ImagesSource', 'PreImagesRange'?


#############################################################################
##
#F  TypeOfDefaultGeneralMapping( <source>, <range>, <filter> )
##
InstallGlobalFunction( TypeOfDefaultGeneralMapping,
    function( source, range, filter )
    local Type;

    # Do a cheap test whether the general mapping has equal source and range.
    if IsIdenticalObj( source, range ) then
      filter:= filter and IsEndoGeneralMapping;
    fi;

    # Construct the type.
    Type:= NewType( GeneralMappingsFamily(
                          ElementsFamily( FamilyObj( source ) ),
                          ElementsFamily( FamilyObj( range  ) ) ),
                    IsDefaultGeneralMappingRep and filter );

    # Store source and range.
    SetDataType( Type, [ source, range ] );

    # Return the type.
    return Type;
end );


#############################################################################
##
#M  Range( <map> )
##
InstallMethod( Range,
    "for default general mapping",
    true,
    [ IsGeneralMapping and IsDefaultGeneralMappingRep ],
    GETTER_FLAGS + 1,  # higher than the system getter!
    map -> DataType( TypeObj( map ) )[2] );


#############################################################################
##
#M  Source( <map> )
##
InstallMethod( Source,
    "for default general mapping",
    true,
    [ IsGeneralMapping and IsDefaultGeneralMappingRep ],
    GETTER_FLAGS + 1,  # higher than the system getter!
    map -> DataType( TypeObj( map ) )[1] );


#############################################################################
##
##  2. methods for composition mappings,
##

#############################################################################
##
#F  ConstituentsCompositionMapping( <map> )
##
InstallGlobalFunction(ConstituentsCompositionMapping,function(map)
  if not IsCompositionMappingRep(map) then
    Error("<map> must be `IsCompositionMappingRep'");
  fi;
  return [map!.map1,map!.map2];
end);

#############################################################################
##
#M  CompositionMapping2( <map2>, <map1> ) . . . . .  for two general mappings
##
InstallGlobalFunction(CompositionMapping2General,
function( map2, map1 )
local com;        # composition of <map1> and <map2>, result

  # Make the general mapping.
  if IsSPGeneralMapping( map1 ) and IsSPGeneralMapping( map2 ) then
    com:= Objectify( TypeOfDefaultGeneralMapping( Source( map1 ),
                                                  Range( map2 ),
                      IsCompositionMappingRep and IsSPGeneralMapping ),
                    rec() );
  else
    com:= Objectify( TypeOfDefaultGeneralMapping( Source( map1 ),
                                                  Range( map2 ),
                      IsCompositionMappingRep and IsNonSPGeneralMapping ),
                    rec() );
  fi;

  # Enter the identifying information.
  # (Maintenance of useful information is dealt with by the
  # wrapper function `CompositionMapping'.)
  com!.map1:= map1;
  com!.map2:= map2;

  # Return the composition.
  return com;
end );

InstallMethod( CompositionMapping2,
    "for two general mappings",
    FamSource1EqFamRange2,
    [ IsGeneralMapping, IsGeneralMapping ], 0,
    CompositionMapping2General);

#############################################################################
##
#M  IsInjective( <map> )  . . . . . . . . . . . . . . for composition mapping
##
InstallMethod( IsInjective,
    "for a composition mapping",
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
    "for a composition mapping",
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
    "for a composition mapping",
    true,
    [ IsCompositionMappingRep ], 0,
    function( com )
    if   not IsSurjective( com!.map2 ) then
      return false;
    elif IsSurjective( com!.map1 ) and
         IsSubset( Range( com!.map1 ), PreImagesRange( com!.map2 ) ) then
      return true;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  IsTotal( <map> )  . . . . . . . . . . . . . . . . for composition mapping
##
InstallMethod( IsTotal,
    "for a composition mapping",
    true,
    [ IsCompositionMappingRep ], 0,
    function( com )
    if not IsTotal( com!.map1 ) then
      return false;
    elif IsTotal( com!.map2 ) and
         IsSubset( Source( com!.map2 ), ImagesSource( com!.map1 ) ) then
      return true;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . . . . . . . . . . . . for composition mapping
##
InstallMethod( ImagesElm,
    "for a composition mapping, and an element",
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
    "for a composition mapping, and a collection",
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
    "for a composition mapping, and an element",
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
    "for a composition mapping, and an element",
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
    "for a composition mapping, and a collection",
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
    "for a composition mapping, and an element",
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
    "for a composition mapping that resp. add. and add.inv.",
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
    "for a composition mapping that resp. add. and add.inv.",
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
    "for a composition mapping that resp. mult. and inv.",
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
    "for a composition mapping that resp. mult. and inv.",
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
#M  ViewObj( <map> )  . . . . . . . . . . . . . . . . for composition mapping
#M  PrintObj( <map> ) . . . . . . . . . . . . . . . . for composition mapping
##
InstallMethod( ViewObj,
    "for a composition mapping",
    true,
    [ IsCompositionMappingRep ], 100,
    function( com )
    Print( "CompositionMapping( ", BHINT );
    View( com!.map2 );
    Print( ",", BHINT, " " );
    View( com!.map1 );
    Print( " )", BHINT );
    end );

InstallMethod( PrintObj,
    "for a composition mapping",
    true,
    [ IsCompositionMappingRep ], 100,
    function( com )
    Print( "CompositionMapping( ", com!.map2, ", ", com!.map1, " )" );
    end );


#############################################################################
##
##  3. methods for mappings by function,
##

#############################################################################
##
#R  IsMappingByFunctionRep( <map> )
##
DeclareRepresentation( "IsMappingByFunctionRep",
    IsMapping and IsAttributeStoringRep,
    [ "fun" ] );
#T really attribute storing ??


#############################################################################
##
#R  IsMappingByFunctionWithInverseRep( <map> )
##
DeclareRepresentation( "IsMappingByFunctionWithInverseRep",
        IsMappingByFunctionRep
    and IsBijective,
#T 1996/10/10 fceller where to put non-reps, 4th position?
    [ "fun", "invFun" ] );

#############################################################################
##
#R  IsNonSPMappingByFunctionRep( <map> )
##
DeclareRepresentation( "IsNonSPMappingByFunctionRep",
    IsNonSPGeneralMapping and IsMappingByFunctionRep, [] );

#############################################################################
##
#R  IsNonSPMappingByFunctionWithInverseRep( <map> )
##
DeclareRepresentation( "IsNonSPMappingByFunctionWithInverseRep",
        IsMappingByFunctionWithInverseRep and IsNonSPMappingByFunctionRep,
    [ "fun", "invFun" ] );

#############################################################################
##
#R  IsSPMappingByFunctionRep( <map> )
##
DeclareRepresentation( "IsSPMappingByFunctionRep",
    IsSPGeneralMapping and IsMappingByFunctionRep, [] );

#############################################################################
##
#R  IsSPMappingByFunctionWithInverseRep( <map> )
##
DeclareRepresentation( "IsSPMappingByFunctionWithInverseRep",
        IsMappingByFunctionWithInverseRep and IsSPMappingByFunctionRep,
    [ "fun", "invFun" ] );


#############################################################################
##
#F  MappingByFunction( <D>, <E>, <fun> )  . . . . .  create map from function
#F  MappingByFunction( <D>, <E>, <fun>, <invfun> )
##
InstallGlobalFunction( MappingByFunction, function ( arg )
    local   map;        # mapping <map>, result


    if not Length(arg) in [3,4,5] then
      # signal an error
      Error( "usage: MappingByFunction( <D>, <E>, <fun>[, <inv>] )" );
    fi;

    # ensure that the source and range are domains
    if not (IsDomain(arg[1]) and IsDomain(arg[2])) then
        Error("MappingByFunction: Source and Range must be domains");
    fi;

    # no inverse function given
    if Length(arg)<>4  then

      # make the general mapping
      map:= Objectify( TypeOfDefaultGeneralMapping( arg[1], arg[2],
                               IsNonSPMappingByFunctionRep
                           and IsSingleValued
                           and IsTotal ),
                       rec( fun:= arg[3] ) );
      if Length(arg)=5 and IsFunction(arg[5]) then
        map!.prefun:=arg[5];
      fi;

    # inverse function given
    elif Length(arg) = 4  then

      # make the mapping
      map:= Objectify( TypeOfDefaultGeneralMapping( arg[1], arg[2],
                               IsNonSPMappingByFunctionWithInverseRep
                           and IsBijective ),
                       rec( fun    := arg[3],
                            invFun := arg[4],
                            prefun := arg[4]) );

    fi;

    # return the mapping
    return map;
end );


#############################################################################
##
#M  ImageElm( <map>, <elm> )  . . . . . . . . . . . . for mapping by function
##
InstallMethod( ImageElm,
    "for mapping by function",
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
    "for mapping by function",
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
    "for mapping by function",
    FamSourceEqFamElm,
    [ IsMappingByFunctionRep, IsObject ], 0,
    function ( map, elm )
    return map!.fun( elm );
    end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <map> )   . for mapping by function
##
InstallMethod(KernelOfMultiplicativeGeneralMapping,"hom by function",true,
    [ IsMappingByFunctionRep and IsGroupHomomorphism ],0,
function ( map )
  return
  KernelOfMultiplicativeGeneralMapping(AsGroupGeneralMappingByImages(map));
end );

#############################################################################
##
#M  PreImagesRepresentative( <map>, <elm> ) . . . . . for mapping by function
##
InstallMethod( PreImagesRepresentative,
    "for mapping by function",
    FamRangeEqFamElm,
    [ IsMappingByFunctionRep, IsObject ], 0,
  function ( map, elm )
    if not IsBound(map!.prefun) then
      # no quick way known
      TryNextMethod();
    fi;
    return map!.prefun( elm );
  end );


#############################################################################
##
#M  PreImageElm( <map>, <elm> ) . . . . . . . . . . . for mapping by function
##
InstallMethod( PreImageElm,
    "for mapping by function",
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
    "for mapping by function",
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
    "for mapping by function with inverse",
    FamRangeEqFamElm,
    [ IsMappingByFunctionWithInverseRep, IsObject ], 0,
    function ( map, elm )
    return map!.invFun( elm );
    end );



#############################################################################
##
##  Transfer information about the mapping map to its associated inverse
##  mapping inv. For example, if map is total than inv is surjective and
##  vice versa.
##
BindGlobal( "TransferMappingPropertiesToInverse", function ( map, inv )
    # If possible, enter preimage and image.
    if HasImagesSource( map ) then
      SetPreImagesRange( inv, ImagesSource( map ) );
    fi;
    if HasPreImagesRange( map )  then
      SetImagesSource( inv, PreImagesRange( map ) );
    fi;

    # Maintain important properties.
    if HasIsSingleValued( map ) then
      SetIsInjective( inv, IsSingleValued( map ) );
    fi;
    if HasIsInjective( map ) then
      SetIsSingleValued( inv, IsInjective( map ) );
    fi;
    if HasIsTotal( map ) then
      SetIsSurjective( inv, IsTotal( map ) );
    fi;
    if HasIsSurjective( map ) then
      SetIsTotal( inv, IsSurjective( map ) );
    fi;
    if HasIsEndoGeneralMapping( map ) then
      SetIsEndoGeneralMapping( inv, IsEndoGeneralMapping( map ) );
    fi;

    # Maintain the maintainings w.r.t. multiplication.
    if HasRespectsMultiplication( map ) then
      SetRespectsMultiplication( inv, RespectsMultiplication( map ) );
    fi;
    if HasRespectsInverses( map ) then
      SetRespectsInverses( inv, RespectsInverses( map ) );
    elif HasRespectsOne( map ) then
      SetRespectsOne( inv, RespectsOne( map ) );
    fi;

    # Maintain the maintainings w.r.t. addition.
    if HasRespectsAddition( map ) then
      SetRespectsAddition( inv, RespectsAddition( map ) );
    fi;
    if HasRespectsAdditiveInverses( map ) then
      SetRespectsAdditiveInverses( inv, RespectsAdditiveInverses( map ) );
    elif HasRespectsZero( map ) then
      SetRespectsZero( inv, RespectsZero( map ) );
    fi;

    # Maintain respecting of scalar multiplication.
    # (Note the slight asymmetry, depending on the coefficient domains.)
    if     HasRespectsScalarMultiplication( map )
       and   LeftActingDomain( Source( map ) )
           = LeftActingDomain( Range( map ) ) then
      SetRespectsScalarMultiplication( inv,
          RespectsScalarMultiplication( map ) );
    fi;

    # We know the inverse general mapping of the inverse general mapping ;-).
    SetInverseGeneralMapping( inv, map );
end );

#############################################################################
##
#M  InverseGeneralMapping( <map> )  . . . . . . . . . for mapping by function
##
InstallMethod( InverseGeneralMapping, "for mapping by function", true,
    [ IsMappingByFunctionWithInverseRep ], 0,
    function ( map )
    local inv;
    inv:= MappingByFunction( Range( map ), Source( map ),
                             map!.invFun, map!.fun );
    TransferMappingPropertiesToInverse( map, inv );
    return inv;
    end );

InstallMethod( RestrictedInverseGeneralMapping, "for mapping by function", true,
    [ IsMappingByFunctionWithInverseRep ], 0,
    function ( map )
    local inv;
    inv:= MappingByFunction( Image( map ), Source( map ),
                             map!.invFun, map!.fun );
    TransferMappingPropertiesToInverse( map, inv );
    return inv;
    end );


#############################################################################
##
#M  ViewObj( <map> )  . . . . . . . . . . . . . . . . for mapping by function
#M  PrintObj( <map> ) . . . . . . . . . . . . . . . . for mapping by function
##
InstallMethod( ViewObj,
    "for mapping by function",
    true,
    [ IsMappingByFunctionRep ], 0,
    function ( map )
    Print( "MappingByFunction( " );
    View( Source( map ) );
    Print( ", " );
    View( Range( map ) );
    Print( ", " );
    View( map!.fun );
    Print( " )" );
    end );

InstallMethod( PrintObj,
    "for mapping by function",
    true,
    [ IsMappingByFunctionRep ], 0,
    function ( map )
    Print( "MappingByFunction( ",
           Source( map ), ", ", Range( map ), ", ",
           map!.fun, " )" );
    end );


#############################################################################
##
#M  ViewObj( <map> )  . . . . . . . . .  for mapping by function with inverse
#M  PrintObj( <map> ) . . . . . . . . .  for mapping by function with inverse
##
InstallMethod( ViewObj,
    "for mapping by function with inverse",
    true,
    [ IsMappingByFunctionWithInverseRep ], 0,
    function ( map )
    Print( "MappingByFunction( " );
    View( Source( map ) );
    Print( ", " );
    View( Range( map ) );
    Print( ", " );
    View( map!.fun );
    Print( ", " );
    View( map!.invFun );
    Print( " )" );
    end );

InstallMethod( PrintObj,
    "for mapping by function with inverse",
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
DeclareRepresentation( "IsInverseGeneralMappingRep",
    IsNonSPGeneralMapping,
    [] );


#############################################################################
##
#M  InverseGeneralMapping( <map> ) . for a general mapping with known inverse
##
InstallImmediateMethod( InverseGeneralMapping,
    IsGeneralMapping and HasInverse and IsAttributeStoringRep, 0,
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
    "for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function ( map )
    local   inv;

    # Make the mapping.
    inv:= Objectify( TypeOfDefaultGeneralMapping( Range( map ),
                                                  Source( map ),
                             IsInverseGeneralMappingRep
                         and IsAttributeStoringRep ),
                     rec() );

    TransferMappingPropertiesToInverse( map, inv );

    # Return the inverse general mapping.
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
#M  ViewObj( <invmap> ) . . . . . . . . . . . . . . . . . .  for inv. mapping
#M  PrintObj( <invmap> )  . . . . . . . . . . . . . . . . .  for inv. mapping
##
InstallMethod( ViewObj,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseGeneralMappingRep ], 100,
    function ( inv )
    Print( "InverseGeneralMapping( " );
    View( InverseGeneralMapping( inv ) );
    Print( " )" );
    end );

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
BindGlobal( "ImmediateImplicationsIdentityMapping", function( idmap )

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
        if IsAdditiveGroup( source ) then
          SetRespectsAdditiveInverses( idmap, true );

          # linear structure
          if IsLeftModule( source ) then
            SetRespectsScalarMultiplication( idmap, true );
          fi;

        fi;
      fi;
    fi;
end );


#############################################################################
##
#M  IdentityMapping( <D> )  . . . . . . . .  identity mapping of a collection
##
InstallMethod( IdentityMapping,
    "for a collection",
    true,
    [ IsCollection ], 0,
    function( D )
    local id;

    # make the mapping
    id := Objectify( TypeOfDefaultGeneralMapping( D, D,
                                  IsSPGeneralMapping
                              and IsAdditiveElementWithInverse
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
    "for identity mapping and integer",
    true,
    [ IsGeneralMapping and IsOne, IsInt ],
    SUM_FLAGS, # can't do better
  ReturnFirst );


#############################################################################
##
#M  ImageElm( <idmap>, <elm> )  . . . . . .  for identity mapping and element
##
InstallMethod( ImageElm,
    "for identity mapping and object",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsOne, IsObject ],
    SUM_FLAGS, # can't do better
  function ( id, elm )
    return elm;
  end );


#############################################################################
##
#M  ImagesElm( <idmap>, <elm> )  . . . . . . for identity mapping and element
##
InstallMethod( ImagesElm,
    "for identity mapping and object",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsOne, IsObject ],
    SUM_FLAGS, # can't do better
  function ( id, elm )
    return [ elm ];
  end );


#############################################################################
##
#M  ImagesSet( <idmap>, <coll> ) . . . .  for identity mapping and collection
##
InstallMethod( ImagesSet,
    "for identity mapping and collection",
    CollFamSourceEqFamElms,
    [ IsGeneralMapping and IsOne, IsCollection ],
    SUM_FLAGS, # can't do better
  function ( id, elms )
    return elms;
  end );

#############################################################################
##
#M  ImagesSource( <idmap> )
##
InstallMethod( ImagesSource,"for identity mapping",true,
    [ IsGeneralMapping and IsOne ], SUM_FLAGS, # can't do better
function ( id )
  return Source(id);
end );


#############################################################################
##
#M  ImagesRepresentative( <idmap>, <elm> )   for identity mapping and element
##
InstallMethod( ImagesRepresentative,
    "for identity mapping and object",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsOne, IsObject ],
    SUM_FLAGS, # can't do better
  function ( id, elm )
    return elm;
  end );


#############################################################################
##
#M  PreImageElm( <idmap>, <elm> )   . . . .  for identity mapping and element
##
InstallMethod( PreImageElm,
    "for identity mapping and object",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsOne, IsObject ],
    SUM_FLAGS, # can't do better
  function ( id, elm )
    return elm;
  end );


#############################################################################
##
#M  PreImagesElm( <idmap>, <elm> )  . . . .  for identity mapping and element
##
InstallMethod( PreImagesElm,
    "for identity mapping and object",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsOne, IsObject ],
    SUM_FLAGS, # can't do better
  function ( id, elm )
    return [ elm ];
  end );


#############################################################################
##
#M  PreImagesSet( <idmap>, <coll> ) . . . for identity mapping and collection
##
InstallMethod( PreImagesSet,
    "for identity mapping and collection",
    CollFamRangeEqFamElms,
    [ IsGeneralMapping and IsOne, IsCollection ],
    SUM_FLAGS, # can't do better
  function ( id, elms )
    return elms;
  end );


#############################################################################
##
#M  PreImagesRepresentative( <idmap>, <elm> )
##
InstallMethod( PreImagesRepresentative,
    "for identity mapping and object",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsOne, IsObject ],
    SUM_FLAGS, # can't do better
  function ( id, elm )
    return elm;
  end );


#############################################################################
##
#M  ViewObj( <idmap> )  . . . . . . . . . . . . . . . .  for identity mapping
#M  PrintObj( <idmap> ) . . . . . . . . . . . . . . . .  for identity mapping
#M  String( <idmap> ) . . . . . . . . . . . . . . . . .  for identity mapping
##
InstallMethod( ViewObj,
    "for identity mapping",
    true,
    [ IsGeneralMapping and IsOne ],
    # rank up, but just to exactly SUM_FLAGS, so that mappings in a special
    # representation with a custom printing method still get that, even if
    # the rank of IsGeneralMapping and IsOne happens to be increased a lot
    {} -> SUM_FLAGS - RankFilter( IsGeneralMapping and IsOne ),
  function ( id )
    Print( "IdentityMapping( " );
    View( Source( id ) );
    Print( " )" );
  end );

InstallMethod( PrintObj,
    "for identity mapping",
    true,
    [ IsGeneralMapping and IsOne ],
    # rank up, but just to exactly SUM_FLAGS, so that mappings in a special
    # representation with a custom printing method still get that, even if
    # the rank of IsGeneralMapping and IsOne happens to be increased a lot
    {} -> SUM_FLAGS - RankFilter( IsGeneralMapping and IsOne ),
    function ( id )
    Print( "IdentityMapping( ", Source( id ), " )" );
    end );

InstallMethod( String,
    "for identity mapping",
    [ IsGeneralMapping and IsOne ],
    # rank up, but just to exactly SUM_FLAGS, so that mappings in a special
    # representation with a custom printing method still get that, even if
    # the rank of IsGeneralMapping and IsOne happens to be increased a lot
    {} -> SUM_FLAGS - RankFilter( IsGeneralMapping and IsOne ),
  function ( id )
    return StringFormatted( "IdentityMapping( {} )", Source(id) );
  end );


#############################################################################
##
#M  CompositionMapping2( <map>, <idmap> ) .  for gen. mapping and id. mapping
##
InstallMethod( CompositionMapping2,
  "for general mapping and identity mapping", FamSource1EqFamRange2,
  [ IsGeneralMapping, IsGeneralMapping and IsOne ],
  {} -> SUM_FLAGS + RankFilter( IsGeneralMapping and IsZero ),  # should be higher than the rank for a zero mapping
function ( map, id )
  if not IsSubset(Range(id),Source(map)) then
    # if the identity is defined on something smaller, we need to take a
    # true `CompositionMapping'.
    TryNextMethod();
  fi;
  return map;
end );


#############################################################################
##
#M  CompositionMapping2( <idmap>, <map> ) .  for id. mapping and gen. mapping
##
InstallMethod( CompositionMapping2,
  "for identity mapping and general mapping",FamSource1EqFamRange2,
  [ IsGeneralMapping and IsOne, IsGeneralMapping ],
  {} -> SUM_FLAGS + RankFilter( IsGeneralMapping and IsZero ),  # should be higher than the rank for a zero mapping
function( id, map )
  if not IsSubset(Source(id),Range(map)) then
    # if the identity is defined on something smaller, we need to take a
    # true `CompositionMapping'.
    TryNextMethod();
  fi;
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
BindGlobal( "ImmediateImplicationsZeroMapping", function( zeromap )

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
        if IsAdditiveGroup( source ) then
          SetRespectsAdditiveInverses( zeromap, true );
        fi;
      fi;
    fi;

    # linear structure
    if IsLeftModule( source ) then
      SetRespectsScalarMultiplication( zeromap, true );
    fi;
end );


#############################################################################
##
#F  ZeroMapping( <source>, <range> )
##
##  maps every element of <source> to 'Zero( <range> )'.
##  This is independent of the structure of <source> and <range>.
##
InstallMethod( ZeroMapping,
    "for collection and additive-magma-with-zero",
    true,
    [ IsCollection, IsAdditiveMagmaWithZero ], 0,
    function( S, R )

    local zero;   # the zero mapping, result

    # make the mapping
    zero := Objectify( TypeOfDefaultGeneralMapping( S, R,
                                  IsSPGeneralMapping
                              and IsAdditiveElementWithInverse
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
    "for zero mapping and positive integer",
    true,
    [ IsGeneralMapping and IsZero, IsPosInt ], SUM_FLAGS,
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
    "for zero mapping",
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
    "for zero mapping and object",
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
    "for zero mapping and object",
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
    "for zero mapping and collection",
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
    "for zero mapping and object",
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
    "for zero mapping and object",
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
    "for zero mapping and collection",
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
    "for zero mapping and object",
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
#M  ViewObj( <zeromap> )  . . . . . . . . . . . . . . . . .  for zero mapping
#M  PrintObj( <zeromap> ) . . . . . . . . . . . . . . . . .  for zero mapping
##
InstallMethod( ViewObj,
    "for zero mapping",
    true,
    [ IsGeneralMapping and IsZero ],
    # rank up, but just to exactly SUM_FLAGS, so that mappings in a special
    # representation with a custom printing method still get that, even if
    # the rank of IsGeneralMapping and IsZero happens to be increased a lot
    {} -> SUM_FLAGS - RankFilter( IsGeneralMapping and IsZero ),
    function( zero )
    Print( "ZeroMapping( " );
    View( Source( zero ) );
    Print( ", " );
    View( Range( zero ) );
    Print( " )" );
    end );

InstallMethod( PrintObj,
    "for zero mapping",
    true,
    [ IsGeneralMapping and IsZero ],
    # rank up, but just to exactly SUM_FLAGS, so that mappings in a special
    # representation with a custom printing method still get that, even if
    # the rank of IsGeneralMapping and IsZero happens to be increased a lot
    {} -> SUM_FLAGS - RankFilter( IsGeneralMapping and IsZero ),
    function( zero )
    Print( "ZeroMapping( ", Source( zero ), ", ", Range( zero ), " )" );
    end );


#############################################################################
##
#M  CompositionMapping2( <map>, <zeromap> ) for gen. mapping and zero mapping
##
InstallMethod( CompositionMapping2,
    "for general mapping and zero mapping",
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
    "for zero mapping and single-valued gen. mapping that resp. zero",
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
    "for zero mapping",
    true,
    [ IsGeneralMapping and IsZero ], 0,
    zero -> Size( Source( zero ) ) = 1 );


#############################################################################
##
#M  IsSurjective( <zeromap> ) . . . . . . . . . . . . . . .  for zero mapping
##
InstallMethod( IsSurjective,
    "for zero mapping",
    true,
    [ IsGeneralMapping and IsZero ], 0,
    zero -> Size( Range( zero ) ) = 1 );

#############################################################################
##
##  7. methods for general restricted mappings,
##

#############################################################################
##
#M  GeneralRestrictedMapping( <map>, <source>, <range> )
##
InstallGlobalFunction(GeneralRestrictedMapping,
function( map, s,r )
local filter, res, prop;

  # Make the general mapping.
  if IsSPGeneralMapping( map )  then
    filter := IsSPGeneralMapping;
  else
    filter := IsNonSPGeneralMapping;
  fi;
  res:= Objectify( TypeOfDefaultGeneralMapping( s,r,
            IsGeneralRestrictedMappingRep and filter ),
          rec() );

  # Enter the identifying information.
  res!.map:= map;

  for prop in [IsSingleValued, IsTotal, IsInjective, RespectsMultiplication, RespectsInverses,
          RespectsAddition, RespectsAdditiveInverses, RespectsScalarMultiplication] do
    if Tester(prop)(map) and prop(map) then
      Setter(prop)(res, true);
    fi;
  od;

  # Return the restriction.
  return res;
end );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . . . . . . . . . . . . for restricted mapping
##
InstallMethod( ImagesElm,
    "for a restricted mapping, and an element",
    FamSourceEqFamElm,
    [ IsGeneralRestrictedMappingRep, IsObject ], 0,
    function( res, elm )
    local im;
    im:= ImagesElm( res!.map, elm );
    if not ( (HasIsSingleValued(res) and IsSingleValued(res)) or
        (HasIsSingleValued(res!.map) and IsSingleValued(res!.map)) ) then
      im:=Intersection(Range(res),im);
    fi;
    return im;
  end );


#############################################################################
##
#M  ImagesSet( <map>, <elms> )  . . . . . . . . . . . for restricted mapping
##
InstallMethod( ImagesSet,
    "for a restricted mapping, and a collection",
    CollFamSourceEqFamElms,
    [ IsGeneralRestrictedMappingRep, IsCollection ], 0,
    function ( res, elms )
    local im;
    im:= ImagesSet( res!.map, elms );
    if not ( (HasIsSingleValued(res) and IsSingleValued(res)) or
        (HasIsSingleValued(res!.map) and IsSingleValued(res!.map)) ) then
      im:=Intersection(Range(res),im);
    fi;
    return im;
  end );


#############################################################################
##
#M  ImagesRepresentative( <map>, <elm> )  . . . . . . for restricted mapping
##
InstallMethod( ImagesRepresentative,
    "for a restricted mapping, and an element",
    FamSourceEqFamElm,
    [ IsGeneralRestrictedMappingRep, IsObject ], 0,
    function( res, elm )
    local im;
    im:= ImagesRepresentative( res!.map, elm );
    if im = fail then
      # 'elm' has no images under 'res!.map', so it has none under 'res'.
      return fail;
    elif im in Range(res) then
      return im;
    elif HasIsSingleValued(res!.map) and IsSingleValued(res!.map) then
      return fail; # no other choice
    else
      # It may happen that only the chosen representative is not in im
      im:= ImagesElm( res!.map, elm );
      return First(im,i->i in Range(res));
    fi;
end );


#############################################################################
##
#M  PreImagesElm( <map>, <elm> )  . . . . . . . . . . for restricted mapping
##
InstallMethod( PreImagesElm,
    "for a restricted mapping, and an element",
    FamRangeEqFamElm,
    [ IsGeneralRestrictedMappingRep, IsObject ], 0,
    function( res, elm )
    local preim;
    preim:= PreImagesElm( res!.map, elm );
    if not ( (HasIsInjective(res) and IsInjective(res)) or
        (HasIsInjective(res!.map) and IsInjective(res!.map)) ) then
      preim:=Intersection(Source(res),preim);
    fi;
    return preim;
end );


#############################################################################
##
#M  PreImagesSet( <map>, <elm> )  . . . . . . . . . . for restricted mapping
##
InstallMethod( PreImagesSet,
    "for a restricted mapping, and a collection",
    CollFamRangeEqFamElms,
    [ IsGeneralRestrictedMappingRep, IsCollection ], 0,
    function( res, elms )
    local preim;
    preim:= PreImagesSet( res!.map, elms );
    if not ( (HasIsInjective(res) and IsInjective(res)) or
        (HasIsInjective(res!.map) and IsInjective(res!.map)) ) then
      preim:=Intersection(Source(res),preim);
    fi;
    return preim;
    end );


#############################################################################
##
#M  PreImagesRepresentative( <map>, <elm> ) . . . . . for restricted mapping
##
InstallMethod( PreImagesRepresentative,
    "for a restricted mapping, and an element",
    FamRangeEqFamElm,
    [ IsGeneralRestrictedMappingRep, IsObject ], 0,
    function( res, elm )
    local preim;
    preim:= PreImagesRepresentative( res!.map, elm );
    if preim = fail then
      # 'elm' has no preimages under 'res!.map', so it has none under 'res'.
      return fail;
    elif preim in Source(res) then
      return preim;
    elif HasIsInjective(res!.map) and IsInjective(res!.map) then
      return fail; # no other choice
    else
      preim:= PreImages( res!.map, elm );
      return First(preim,x->x in Source(res));
    fi;
    end );


#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <map> ) . . . . . for restricted mapping
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "for a restricted mapping that resp. add. and add.inv.", true,
    [ IsGeneralMapping and IsGeneralRestrictedMappingRep
      and RespectsAddition and RespectsAdditiveInverses ], 0,
function( res )
  return Intersection(Source(res),KernelOfAdditiveGeneralMapping( res!.map ));
end );


#############################################################################
##
#M  CoKernelOfAdditiveGeneralMapping( <map> ) . . . . for restricted mapping
##
InstallMethod( CoKernelOfAdditiveGeneralMapping,
    "for a restricted mapping that resp. add. and add.inv.",
    true,
    [ IsGeneralMapping and IsGeneralRestrictedMappingRep
      and RespectsAddition and RespectsAdditiveInverses ], 0,
function( res )
  return Intersection(Range(res),CoKernelOfAdditiveGeneralMapping( res!.map ));
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <map> ) . . for restricted mapping
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    "for a restricted mapping that resp. mult. and inv.",
    true,
    [ IsGeneralMapping and IsGeneralRestrictedMappingRep
      and RespectsMultiplication and RespectsInverses ], 0,
function( res )
  return Intersection(Source(res),
                      KernelOfMultiplicativeGeneralMapping(res!.map));
end );

#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <map> ) . for restricted mapping
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
    "for a restricted mapping that resp. mult. and inv.",
    true,
    [ IsGeneralMapping and IsGeneralRestrictedMappingRep
      and RespectsMultiplication and RespectsInverses ], 0,
function( res )
  return Intersection(Range(res),
                      CoKernelOfMultiplicativeGeneralMapping(res!.map));
end );

#############################################################################
##
#M  ViewObj( <map> )  . . . . . . . . . . . . . . . . for restricted mapping
#M  PrintObj( <map> ) . . . . . . . . . . . . . . . . for restricted mapping
##
InstallMethod( ViewObj,
    "for a restricted mapping",
    true,
    [ IsGeneralRestrictedMappingRep ], 100,
    function( res )
    Print( "GeneralRestrictedMapping( " );
    View( res!.map );
    Print( ", " );
    View( Source(res) );
    Print( ", " );
    View( Range(res) );
    Print( " )" );
    end );

InstallMethod( PrintObj,
    "for a restricted mapping",
    true,
    [ IsGeneralRestrictedMappingRep ], 100,
    function( res )
    Print( "GeneralRestrictedMapping( ", res!.map, ", ", Source(res),
           ",", Range(res)," )" );
    end );


#############################################################################
##
#M  RestrictedMapping(<hom>,<U>)
##
InstallMethod(RestrictedMapping,"for mapping that is already restricted",
  CollFamSourceEqFamElms,
  [IsGeneralMapping and IsGeneralRestrictedMappingRep, IsDomain],
  SUM_FLAGS,
function(hom, U)
  return GeneralRestrictedMapping (hom!.map, U, Range(hom!.map));
end);


#############################################################################
##
#M  RestrictedMapping(<hom>,<U>)
##
InstallMethod(RestrictedMapping,"use GeneralRestrictedMapping",
  CollFamSourceEqFamElms,[IsGeneralMapping,IsDomain],0,
function(hom, U)
  return GeneralRestrictedMapping (hom, U, Range(hom));
end);
