#############################################################################
##
#W  mapprep.gi                  GAP library                     Thomas Breuer
#W                                                         & Martin Schoenert
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains representation dependent methods for the following
##  general mappings.
##  - general mappings in 'IsDefaultMappingRep'
##  - composition mappings,
##  - mappings by function,
##  - identity mappings
##  - inverse mappings
##
Revision.mapprep_gi :=
    "@(#)$Id$";


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
#T methods to handle attributes 'One' and 'Inverse', 
#T 'ImagesSource', 'PreImagesRange'?
#T and what about domain attributes, such as 'AsList' ??


#############################################################################
##
#F  KindOfDefaultGeneralMapping( <source>, <range>, <filter> )
##
KindOfDefaultGeneralMapping := function( source, range, filter )
    local Kind;
    Kind:= NewKind( CollectionsFamily( TuplesFamily(
                        [ ElementsFamily( FamilyObj( source ) ),
                          ElementsFamily( FamilyObj( range  ) ) ] ) ),
                    IsDefaultGeneralMappingRep and filter );
    Kind![3]:= [ source, range ];
    return Kind;
end;


#############################################################################
##
#M  Range( <map> )
##
InstallMethod( Range, true,
    [ IsGeneralMapping and IsDefaultGeneralMappingRep ], 2*SUM_FLAGS + 1,
    function ( map )
    return DataKind( KindObj( map ) )[2];
    end );


#############################################################################
##
#M  Source( <map> )
##
InstallMethod( Source, true,
    [ IsGeneralMapping and IsDefaultGeneralMappingRep ], 2*SUM_FLAGS + 1,
    function ( map )
    return DataKind( KindObj( map ) )[1];
    end );


#############################################################################
##
#R  IsCompositionMappingRep( <map> )
##
IsCompositionMappingRep := NewRepresentation( "IsCompositionMappingRep",
    IsNonSPGeneralMapping and IsComponentObjectRep, [ "map1", "map2" ] );
#T better list object?


#############################################################################
##
#M  CompositionMapping2( <map2>, <map1> ) . . . . .  for two general mappings
##
InstallMethod( CompositionMapping2,
    "method for two general mappings",
    IsIdentical,
    [ IsGeneralMapping, IsGeneralMapping ], 0,
    function( map2, map1 )
    local com;        # composition of <map1> and <map2>, result

    # Check that the source of 'map2' is a subset of the range of 'map1'
    if not IsSubset( Range( map1 ), Source( map2 ) ) then
      Error( "source of 'map2' must be a subset of the range of 'map1'" );
    fi;

    # make the general mapping
    com:= Objectify( KindOfDefaultGeneralMapping( Source( map1 ),
                                                  Range( map2 ),
                                                  IsCompositionMappingRep ),
                     rec() );

    # enter the identifying information
    com!.map1:= map1;
    com!.map2:= map2;

    # return the composition
    return com;
    end );


#############################################################################
##
#M  CompositionMapping2( <map2>, <map1> ) . . . . . . . . .  for two mappings
##
InstallMethod( CompositionMapping2,
    "method for two mappings",
    IsIdentical,
    [ IsMapping, IsMapping ], 0,
    function( map2, map1 )
    local   com;        # composition of 'map1' and 'map2', result

    # Check that the source of 'map2' is a subset of the range of 'map1'
    if not IsSubset( Range( map1 ), Source( map2 ) ) then
      Error( "source of 'map2' must be a subset of the range of 'map1'" );
    fi;

    # make the mapping
    com:= Objectify( KindOfDefaultGeneralMapping( Source( map1 ),
                                                  Range( map2 ),
                                                  IsCompositionMappingRep ),
                     rec() );

    # enter the identifying information
    com!.map1:= map1;
    com!.map2:= map2;

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
    com -> IsInjective( com!.map1 ) and IsInjective( com!.map2 ) );


#############################################################################
##
#M  IsSingleValued( <map> )   . . . . . . . . . . . . for composition mapping
##
InstallMethod( IsSingleValued,
    "method for a composition mapping",
    true,
    [ IsCompositionMappingRep ], 0,
    com -> IsSingleValued( com!.map1 ) and IsSingleValued( com!.map2 ) );


#############################################################################
##
#M  IsSurjective( <map> ) . . . . . . . . . . . . . . for composition mapping
##
InstallMethod( IsSurjective,
    "method for a composition mapping",
    true,
    [ IsCompositionMappingRep ], 0,
    function( com )
    if  IsSurjective( com!.map1 ) and IsSurjective( com!.map2 ) then
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
    if  IsTotal( com!.map1 ) and IsTotal( com!.map2 ) then
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
    function ( com, elm )
    local im;
    im:= ImagesRepresentative( com!.map1, elm );
    if im <> fail then
      return ImagesRepresentative( com!.map2, im );
    else
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
    local im;
    im:= PreImagesRepresentative( com!.map2, elm );
    if im <> fail then
      return PreImagesRepresentative( com!.map1, im );
    else
      return fail;
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
    and IsBijective
    and IsMultiplicativeElementWithInverse,
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
#M  Inverse( <map> )  . . . . . . . . . . . . . . . . for mapping by function
##
InstallMethod( Inverse,
    "method for mapping by function",
    true,
    [ IsMappingByFunctionWithInverseRep ], 0,
    function ( map )
    local inv;
    inv:= MappingByFunction( Range( map ), Source( map ),
                             map!.invFun, map!.fun );
    SetInverse( inv, map );
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
#R  IsIdentityMappingRep( <map> )
##
##  For each domain we need to construct only one identity mapping.
##  In order to allow this to interact with other mappings of this domain
##  (for example, with automorphisms of a field in a special representation),
##  one needs to install methods to compare these mappings with the identity
##  mapping via '\=' and '\<'.
##
IsIdentityMappingRep := NewRepresentation( "IsIdentityMappingRep",
    IsSPGeneralMapping and IsAttributeStoringRep,
    [] );


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
	fi;
      fi;
    fi;

    # linear structure
    if IsLeftModule( source ) then
      SetRespectsScalarMultiplication( idmap, true );
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
    function ( D )
    local Fam, id;

    Fam:= ElementsFamily( FamilyObj( D ) );

    # make the mapping
    id := Objectify( KindOfDefaultGeneralMapping( D, D,
                                  IsIdentityMappingRep
                              and IsMapping
                              and IsBijective
                              and IsMultiplicativeElementWithInverse ),
                     rec() );

    # enter preimage and image
    SetPreImagesRange( id, D );
    SetImagesSource(   id, D );

    # the identity mapping is self-inverse
    SetInverse( id, id );

    # set the respectings
    ImmediateImplicationsIdentityMapping( id );

    # return the identity mapping
    return id;
    end );


#############################################################################
##
##  methods for identity mappings (all installed with rank 'SUM_FLAGS')
##

#############################################################################
##
#M  \^( <idmap>, <n> )  . . . . . . . . . .  for identity mapping and integer
##
InstallMethod( \^,
    "method for identity mapping and integer",
    true,
    [ IsMapping and IsIdentityMappingRep, IsInt ], SUM_FLAGS,
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
    [ IsMapping and IsIdentityMappingRep, IsObject ], SUM_FLAGS,
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
    [ IsMapping and IsIdentityMappingRep, IsObject ], SUM_FLAGS,
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
    [ IsMapping and IsIdentityMappingRep, IsCollection ], SUM_FLAGS,
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
    [ IsMapping and IsIdentityMappingRep, IsObject ], SUM_FLAGS,
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
    [ IsMapping and IsBijective and IsIdentityMappingRep,
      IsObject ], SUM_FLAGS,
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
    [ IsMapping and IsIdentityMappingRep, IsObject ], SUM_FLAGS,
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
    [ IsMapping and IsIdentityMappingRep, IsCollection ], SUM_FLAGS,
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
    [ IsMapping and IsIdentityMappingRep, IsObject ], SUM_FLAGS,
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
    [ IsMapping and IsIdentityMappingRep ], SUM_FLAGS,
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
    [ IsGeneralMapping, IsMapping and IsIdentityMappingRep ], SUM_FLAGS,
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
    [ IsMapping and IsIdentityMappingRep, IsGeneralMapping ], SUM_FLAGS,
    function ( id, map )
    return map;
    end );


#############################################################################
##
#R  IsInverseMappingRep( <map> )
##
##  Note that if a mapping knows its inverse mapping then also the inverse
##  mapping knows its inverse mapping.
##  So we need this flag to avoid infinite recursion when a question is
##  delegated to the inverse of a mapping.
##
IsInverseMappingRep := NewRepresentation( "IsInverseMappingRep",
    IsNonSPGeneralMapping,
    [] );


#############################################################################
##
#M  InverseGeneralMapping( <map> ) . . . inverse mapping of a general mapping
##
##  This inverse of a general mapping is again a general mapping.
##  (If one wants a mapping, one has to call 'Inverse'.
##  This will cause a check that <map> is bijective.)
##
InstallImmediateMethod( InverseGeneralMapping,
    IsGeneralMapping and HasInverse, 0,
    Inverse );

InstallMethod( InverseGeneralMapping,
    "method for bijective general mapping",
    true,
    [ IsGeneralMapping and IsBijective ], 0,
    Inverse );

InstallMethod( InverseGeneralMapping,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function ( map )
    local   inv;

    # make the mapping
    inv:= Objectify( KindOfDefaultGeneralMapping( Range( map ),
                                                  Source( map ),
                         IsInverseMappingRep and IsAttributeStoringRep ),
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

    # we know the inverse mapping of the inverse mapping ;-)
    SetInverseGeneralMapping( inv, map );

    # return the inverse general mapping
    return inv;
    end );


#############################################################################
##
#M  Inverse( <map> )  . . . . . . . . .  inverse mapping of a general mapping
##
##  The inverse of a general mapping is again a general mapping.
#T allowed ??
##  The inverse of a mapping <map> is a mapping if and only if <map> is
##  bijective, otherwise is a general mapping.
##
InstallOtherMethod( Inverse,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function ( map )
    local   inv;

    # make the mapping
    if IsBijective( map ) then
      inv:= Objectify( KindOfDefaultGeneralMapping( Range( map ),
                                                    Source( map ),
                                    IsInverseMappingRep
                                and IsMapping
                                and IsInjective
                                and IsSurjective
                                and IsAttributeStoringRep ),
                       rec() );
    else
#T allowed ??
      inv:= Objectify( KindOfDefaultGeneralMapping( Range( map ),
                                                    Source( map ),
                                    IsInverseMappingRep
                                and IsAttributeStoringRep ),
                       rec() );
    fi;

    # if possible, enter preimage and image
    if HasImagesSource( map ) then
      SetPreImagesRange( inv, ImagesSource( map ) );
    fi;
    if HasPreImagesRange( map )  then
      SetImagesSource( inv, PreImagesRange( map ) );
    fi;

    # we know the inverse mapping of the inverse mapping ;-)
    SetInverse( inv, map );

    # return the inverse mapping
    return inv;
    end );


#############################################################################
##
#M  Enumerator( <map> ) . . . . . . . . . . . . . . .  for an inverse mapping
##
InstallMethod( Enumerator,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseMappingRep ], 0,
    inv -> List( Enumerator( InverseGeneralMapping( inv ) ),
                 tuple -> Tuple( [ tuple[2], tuple[1] ] ) ) );


#############################################################################
##
#M  IsSingleValued( <map> ) . . . . . . . . . . . . .  for an inverse mapping
##
InstallMethod( IsSingleValued,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseMappingRep ], 0,
    inv -> IsInjective( InverseGeneralMapping( inv ) ) );


#############################################################################
##
#M  IsInjective( <map> )  . . . . . . . . . . . . . .  for an inverse mapping
##
InstallMethod( IsInjective,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseMappingRep ], 0,
    inv -> IsSingleValued( InverseGeneralMapping( inv ) ) );


#############################################################################
##
#M  IsSurjective( <map> ) . . . . . . . . . . . . . .  for an inverse mapping
##
InstallMethod( IsSurjective,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseMappingRep ], 0,
    inv -> IsTotal( InverseGeneralMapping( inv ) ) );


#############################################################################
##
#M  IsTotal( <map> )  . . . . . . . . . . . . . . . .  for an inverse mapping
##
InstallMethod( IsTotal,
    "for an inverse mapping",
    true,
    [ IsGeneralMapping and IsInverseMappingRep ], 0,
    inv -> IsSurjective( InverseGeneralMapping( inv ) ) );


#############################################################################
##
#M  ImageElm( <invmap>, <map> ) . . . . . . . for inverse mapping and element
##
InstallMethod( ImageElm,
    "for an inverse mapping and an element",
    FamSourceEqFamElm,
    [ IsMapping and IsInverseMappingRep, IsObject ], 0,
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
    [ IsGeneralMapping and IsInverseMappingRep, IsObject ], 0,
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
    [ IsGeneralMapping and IsInverseMappingRep, IsCollection ], 0,
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
    [ IsGeneralMapping and IsInverseMappingRep, IsObject ], 0,
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
    [ IsGeneralMapping and IsInverseMappingRep
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
    [ IsGeneralMapping and IsInverseMappingRep, IsObject ], 0,
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
    [ IsGeneralMapping and IsInverseMappingRep, IsCollection ], 0,
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
    [ IsInverseMappingRep, IsObject ], 0,
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
    [ IsGeneralMapping and IsInverseMappingRep ], 100,
    function ( inv )
    Print( "InverseGeneralMapping( ", InverseGeneralMapping( inv )," )" );
    end );

InstallMethod( PrintObj,
    "for an inverse mapping",
    true,
    [ IsMapping and IsBijective and IsInverseMappingRep ], 100,
    function ( inv )
    Print( "Inverse( ", InverseGeneralMapping( inv )," )" );
    end );


#############################################################################
##
#E  mapprep.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



