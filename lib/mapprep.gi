#############################################################################
##
#W  mapprep.gi                  GAP library                  Martin Schoenert
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
##  - mappings by function.
##
##  (Note that inverse mappings and identity mappings are not representation
##  dependent; see 'mapping.gi' for their methods.)
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
#T methods to handle attributes 'One' and 'Inverse'!


#############################################################################
##
#F  KindOfDefaultGeneralMapping( <source>, <range>, <filter> )
##
KindOfDefaultGeneralMapping := function( source, range, filter )
    local Kind;
    Kind:= NewKind( GeneralMappingsFamily(
                      ElementsFamily( FamilyObj( source ) ),
                      ElementsFamily( FamilyObj( range ) ) ),
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
#R  IsCompositionMapping( <map> )
##
IsCompositionMapping := NewRepresentation( "IsCompositionMapping",
    IsGeneralMapping and IsComponentObjectRep, [ "map1", "map2" ] );
#T better list object?


#############################################################################
##
#R  IsGeneralMappingByFunction( <map> )
##
IsGeneralMappingByFunction := NewRepresentation(
    "IsGeneralMappingByFunction",
    IsGeneralMapping and IsAttributeStoringRep, [ "fun" ] );


#############################################################################
##
#R  IsMappingByFunctionWithInverse( <map> )
##
IsMappingByFunctionWithInverse := NewRepresentation(
    "IsMappingByFunctionWithInverse",
    IsGeneralMappingByFunction and IsBijective
        and IsMultiplicativeElementWithInverse,
#T 1996/10/10 fceller where to put non-reps, 4th position?
    [ "fun", "invFun" ] );


#############################################################################
##
#F  GeneralMappingByFunction( <D>, <E>, <fun> ) . .  create map from function
#F  GeneralMappingByFunction( <D>, <E>, <fun>, <invfun> )
##
#T Do we need 'MappingByFunction' ?
##
GeneralMappingByFunction := function ( arg )
    local   map;        # mapping <map>, result

    # no inverse function given
    if Length(arg) = 3  then

      # make the mapping
      map:= Objectify( KindOfDefaultGeneralMapping( arg[1], arg[2],
                                                IsGeneralMappingByFunction ),
#T no chance to make this a mapping!
                       rec() );

      # enter the function
      map!.fun:= arg[3];

      # enter the known stuff
      SetPreImagesRange( map, arg[1] );
#T really total?
#T (better set 'IsTotal' to 'true' ?)

    # inverse function given
    elif Length(arg) = 4  then

      # make the mapping
      map:= Objectify( KindOfDefaultGeneralMapping( arg[1], arg[2],
                                            IsMappingByFunctionWithInverse ),
                       rec() );

      # enter the function and its inverse
      map!.fun    := arg[3];
      map!.invFun := arg[4];

      # enter the known stuff
      SetIsInjective( map, true );
      SetIsSurjective( map, true );
      SetIsBijective( map, true );
      SetPreImagesRange( map, arg[1] );
      SetImagesSource( map, arg[2] );

    # otherwise signal an error
    else
      Error( "usage: GeneralMappingByFunction( <D>, <E>, <fun> [, <inv>] )" );
    fi;

    # return the mapping
    return map;
end;


#############################################################################
##
#F  CompositionMapping2( <map1>, <map2> )
##
InstallMethod( CompositionMapping2, IsIdentical,
    [ IsGeneralMapping, IsGeneralMapping ], 0,
    function ( map1, map2 )
    local   com;        # composition of <map1> and <map2>, result

    # make the mapping
    if IsMapping( map1 ) and IsMapping( map2 ) then
      com := Objectify( KindOfDefaultGeneralMapping( Source( map2 ),
                                                 Range( map1 ),
                                   IsCompositionMapping and IsMapping ),
                        rec() );
    else
      com := Objectify( KindOfDefaultGeneralMapping( Source( map2 ),
                                                 Range( map1 ),
                                                 IsCompositionMapping ),
                        rec() );
    fi;

    # enter the identifying information
    com!.map1:= map1;
    com!.map2:= map2;

    # return the composition
    return com;
    end );


InstallMethod( IsInjective, true, [ IsCompositionMapping ], 0,
    function ( com )
    if      IsMapping( com!.map1 )  and IsInjective( com!.map1 )
        and IsMapping( com!.map2 )  and IsInjective( com!.map2 )
    then
        return true;
    fi;
    TryNextMethod();
    end );

InstallMethod( IsSurjective, true, [ IsCompositionMapping ], 0,
    function ( com )
    if      IsMapping( com!.map1 )  and IsSurjective( com!.map1 )
        and IsMapping( com!.map2 )  and IsSurjective( com!.map2 )
    then
        return true;
    fi;
    TryNextMethod();
    end );

#T InstallMethod( IsGroupHomomorphism, true, [ IsCompositionMapping ], 0,
#T     function ( com )
#T     if      IsMapping( com!.map1 )  and IsGroupHomomorphism( com!.map1 )
#T         and IsMapping( com!.map2 )  and IsGroupHomomorphism( com!.map2 )  then
#T         return true;
#T     fi;
#T     TryNextMethod();
#T     end );

InstallMethod( ImagesElm, FamSourceEqFamElm,
    [ IsCompositionMapping, IsObject ], 0,
    function ( com, elm )
    return ImagesSet( com!.map1, ImagesElm( com!.map2, elm ) );
    end );

InstallMethod( ImagesSet, CollFamSourceEqFamElms,
    [ IsCompositionMapping, IsCollection ], 0,
    function ( com, elms )
    return ImagesSet( com!.map1, ImagesSet( com!.map2, elms ) );
    end );

InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
    [ IsCompositionMapping, IsObject ], 0,
    function ( com, elm )
    return ImagesRepresentative( com!.map1,
                                 ImagesRepresentative( com!.map2, elm ) );
    end );

InstallMethod( PreImagesElm, FamRangeEqFamElm,
    [ IsCompositionMapping, IsObject ], 0,
    function ( com, elm )
    return PreImagesSet( com!.map2, PreImagesElm( com!.map1, elm ) );
    end );

InstallMethod( PreImagesSet, CollFamRangeEqFamElms,
    [ IsCompositionMapping, IsCollection ], 0,
    function ( com, elms )
    return PreImagesSet( com!.map2, PreImagesSet( com!.map1, elms ) );
    end );

InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
    [ IsCompositionMapping, IsObject ], 0,
    function ( com, elm )
    return PreImagesRepresentative( com!.map2,
                              PreImagesRepresentative( com!.map1, elm ) );
    end );

InstallMethod( PrintObj, true, [ IsCompositionMapping ], 100,
    function ( com )
    Print( "CompositionMapping( ", com!.map1, ", ", com!.map2, " )" );
    end );

InstallOtherMethod( ImageElm, FamSourceEqFamElm,
    [ IsGeneralMappingByFunction, IsObject ], 0,
    function ( map, elm )
    return map!.fun( elm );
    end );

InstallMethod( ImagesElm, FamSourceEqFamElm,
    [ IsGeneralMappingByFunction, IsObject ], 0,
    function ( map, elm )
    return [ map!.fun( elm ) ];
    end );

InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
    [ IsGeneralMappingByFunction, IsObject ], 0,
    function ( map, elm )
    return map!.fun( elm );
    end );

InstallMethod( PreImageElm, FamRangeEqFamElm,
    [ IsMappingByFunctionWithInverse, IsObject ], 0,
    function ( map, elm )
    return map!.invFun( elm );
    end );

InstallMethod( PreImagesElm, FamRangeEqFamElm,
    [ IsMappingByFunctionWithInverse, IsObject ], 0,
    function ( map, elm )
    return [ map!.invFun( elm ) ];
    end );

InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
    [ IsMappingByFunctionWithInverse, IsObject ], 0,
    function ( map, elm )
    return map!.invFun( elm );
    end );

InstallMethod( Inverse, true, [ IsMappingByFunctionWithInverse ], 0,
    function ( map )
    local   inv;
    inv := GeneralMappingByFunction( Range( map ), Source( map ),
                              map!.invFun, map!.fun );
    SetInverse( inv, map );
    return inv;
    end );

InstallMethod( PrintObj, true, [ IsGeneralMappingByFunction ], 0,
    function ( map )
    Print( "GeneralMappingByFunction( ",
           Source( map ), ", ", Range( map ), ", ",
           map!.fun, " )" );
    end );

InstallMethod( PrintObj, true, [ IsMappingByFunctionWithInverse ], 0,
    function ( map )
    Print( "MappingByFunction( ",
           Source( map ), ", ", Range( map ), ", ",
           map!.fun, ", ", map!.invFun, " )" );
    end );

#T MappingsOps.Group       := function ( Mappings, gens, id )
#T     local   gen;
#T 
#T     # check the arguments
#T     if not IsMapping( id )  or not IsBijection( id )  then
#T         Error("<id> must be a bijection");
#T     fi;
#T     if id.source <> id.range  then
#T         Error("the source and range of <id> must be equal");
#T     fi;
#T     for gen  in gens  do
#T         if not IsMapping( gen )  or not IsBijection( gen )  then
#T             Error("<gen> must be a bijection");
#T         fi;
#T         if gen.source <> id.source  or gen.range <> id.range  then
#T             Error("<gen> must permute the source of <id>");
#T         fi;
#T     od;
#T 
#T     # delegate the work
#T     return GroupElementsOps.Group( Mappings, gens, id );
#T end;


#############################################################################
##
#E  mapprep.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



