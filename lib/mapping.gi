#############################################################################
##
#W  mapping.gi                  GAP library                  Martin Schoenert
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the generic methods for general mappings.
##
Revision.mapping_gi :=
    "@(#)$Id$";


#############################################################################
##
##  some usual family predicates for mapping methods
##
FamRangeEqFamElm := function( FamMap, FamElm )
    return     HasFamilyRange( FamMap )
           and IsIdentical( FamilyRange( FamMap ), FamElm );
end;

FamSourceEqFamElm := function( FamMap, FamElm )
    return     HasFamilySource( FamMap )
           and IsIdentical( FamilySource( FamMap ), FamElm );
end;

CollFamRangeEqFamElms := function( FamMap, FamElms )
    return     HasFamilyRange( FamMap )
           and HasCollectionsFamily( FamilyRange( FamMap ) )
           and IsIdentical( CollectionsFamily( FamilyRange( FamMap ) ),
                            FamElms );
end;

CollFamSourceEqFamElms := function( FamMap, FamElms )
    return     HasFamilySource( FamMap )
           and HasCollectionsFamily( FamilySource( FamMap ) )
           and IsIdentical( CollectionsFamily( FamilySource( FamMap ) ),
                            FamElms );
end;

FamElmEqFamSource := function( FamElm, FamMap )
    return     HasFamilySource( FamMap )
           and IsIdentical( FamElm, FamilySource( FamMap ) );
end;

FamElmEqFamRange := function( FamElm, FamMap )
    return     HasFamilyRange( FamMap )
           and IsIdentical( FamElm, FamilyRange( FamMap ) );
end;

FamSource2EqFamRange1 := function( Fam1, Fam2 )
    return     HasFamilySource( Fam2 )
           and HasFamilyRange(  Fam1 )
           and IsIdentical( FamilySource( Fam2 ), FamilyRange( Fam1 ) );
end;

FamSource1EqFamRange2 := function( Fam1, Fam2 )
    return     HasFamilySource( Fam1 )
           and HasFamilyRange(  Fam2 )
           and IsIdentical( FamilySource( Fam1 ), FamilyRange( Fam2 ) );
end;

FamRange1EqFamRange2 := function( Fam1, Fam2 )
    return     HasFamilyRange( Fam1 )
           and HasFamilyRange( Fam2 )
           and IsIdentical( FamilyRange( Fam1 ), FamilyRange( Fam2 ) );
end;

FamSource1EqFamSource2 := function( Fam1, Fam2 )
    return     HasFamilySource( Fam1 )
           and HasFamilySource( Fam2 )
           and IsIdentical( FamilySource( Fam1 ), FamilySource( Fam2 ) );
end;

FamMapFamSourceFamRange := function( FamMap, FamElm1, FamElm2 )
    return HasFamilySource( FamMap ) and
           HasFamilyRange( FamMap ) and
           IsIdentical( FamilySource( FamMap ), FamElm1 ) and
           IsIdentical( FamilyRange( FamMap), FamElm2 );
end;

#############################################################################
##
#M  GeneralMappingsFamily( <sourcefam>, <rangefam> )
##
InstallMethod( GeneralMappingsFamily, true, [ IsFamily, IsFamily ], 0,
    function( sourcefam, rangefam )

    local sourcepos,
          rangepos,
          i,
          Fam;

    sourcepos := 0;
    rangepos  := 0;
    for i in [ 1 .. Length( FAMILIES_SOURCE ) ] do
      if IsIdentical( sourcefam, FAMILIES_SOURCE[i] ) then
        sourcepos:= i;
        break;
      fi;
    od;
    for i in [ 1 .. Length( FAMILIES_RANGE ) ] do
      if IsIdentical( rangefam, FAMILIES_RANGE[i] ) then
        rangepos:= i;
        break;
      fi;
    od;
    if 0 = sourcepos then
      Add( FAMILIES_SOURCE, sourcefam );
      Add( FAMILIES_MAPPINGS, [] );
      sourcepos:= Length( FAMILIES_SOURCE );
    fi;
    if 0 = rangepos then
      Add( FAMILIES_RANGE, rangefam );
      rangepos:= Length( FAMILIES_RANGE );
    fi;
    if not IsBound( FAMILIES_MAPPINGS[ sourcepos ][ rangepos ] ) then

      # We do really have to work a little.
      Fam:= NewFamily( "GeneralMappingsFamily", IsGeneralMapping );
      SetFamilySource( Fam, sourcefam );
      SetFamilyRange(  Fam, rangefam  );
      FAMILIES_MAPPINGS[ sourcepos ][ rangepos ]:= Fam;

    fi;
    return FAMILIES_MAPPINGS[ sourcepos ][ rangepos ];
    end );


#############################################################################
##
#F  Image( <map>, <elm> ) . . . . . . . . image of an element under a mapping
#F  Image( <map> )
##
Image := function ( arg )
    local   map,        # mapping <map>, first argument
            elm;        # element <elm>, second argument

    # image of the source under <map>, which may be multi valued in this case
    if   Length( arg ) = 1 then

        return ImagesSource( arg[1] );

    elif Length( arg ) = 2 then

      map := arg[1];
      elm := arg[2];

      # image of a single element <elm> under the mapping <map>
      if not IsMapping( map ) then
        Error( "<map> must be a mapping" );
      fi;
      if IsIdentical( FamilySource( FamilyObj( map ) ),
                      FamilyObj( elm ) ) then

        return ImageElm( map, elm );

      # image of a set or list of elments <elm> under the mapping <map>
      elif IsIdentical( CollectionsFamily( FamilySource( FamilyObj( map ) ) ),
                        FamilyObj( elm ) ) then

        if IsDomain( elm ) or IsSSortedList( elm ) then
          return ImagesSet( map, elm );
        elif IsHomogeneousList( elm ) then
          return ImagesSet( map, Set( elm ) );
        fi;

      fi;

    fi;
    Error( "usage: Image( <map> ) or Image( <map>, <elm> )" );
end;


#############################################################################
##
#F  Images( <map>, <elm> )  . .  images of an element under a general mapping
##
Images := function ( arg )
    local   map,        # mapping <map>, first argument
            elm;        # element <elm>, second argument

    # image of the source under <map>
    if Length( arg ) = 1  then

        return ImagesSource(  arg[1] );

    elif Length( arg ) = 2 then

        map := arg[1];
        elm := arg[2];

        if not IsGeneralMapping( map ) then
          Error( "<map> must be a (general) mapping" );
        fi;

        # image of a single element <elm> under the mapping <map>
        if IsIdentical( FamilySource( FamilyObj( map ) ),
                        FamilyObj( elm ) ) then

          return ImagesElm( map, elm );

        # image of a set or list of elments <elm> under the mapping <map>
        elif IsIdentical( CollectionsFamily( FamilySource( FamilyObj( map ) ) ),
                          FamilyObj( elm ) ) then

          if IsDomain( elm ) or IsSSortedList( elm ) then
            return ImagesSet( map, elm );
          elif IsHomogeneousList( elm ) then
            return ImagesSet( map, Set( elm ) );
          fi;

        fi;
    fi;
    Error( "usage: Images( <map> ) or Images( <map>, <elm> )" );
end;


#############################################################################
##
#F  PreImage(<bij>[,<img>]) . . . .  preimage of an element under a bijection
##
PreImage := function ( arg )
    local   bij,        # bijection <bij>, first argument
            img,        # element <img>, second argument
            pre;        # image of <img> under <bij>, result

    # preimage of the range under <bij>, which may be a multi valued mapping
    if Length( arg ) = 1  then

        return PreImagesRange( arg[1] );

    elif Length( arg ) = 2 then

        bij := arg[1];
        img := arg[2];

        # preimage of a single element <img> under the bijection <bij>
        if IsIdentical( FamilyRange( FamilyObj( bij ) ),
                        FamilyObj( img ) ) then

            return PreImageElm( bij, img );

        # preimage of a set or list of elments <img> under the bijection <bij>
        elif IsIdentical( CollectionsFamily( FamilyRange( FamilyObj( bij ) ) ),
                          FamilyObj( img ) ) then

          if IsDomain( img ) or IsSSortedList( bij ) then
            return PreImagesSet( bij, img );
          elif IsHomogeneousList( img ) then
            return PreImagesSet( bij, Set( img ) );
          fi;

        fi;
    fi;
    Error("usage: PreImage( <bij> ) or PreImage( <bij>, <img> )");
end;


#############################################################################
##
#F  PreImages(<map>,<img>)  . . . . . preimages of an element under a mapping
##
PreImages := function ( arg )
    local   map,        # mapping <map>, first argument
            img;        # element <img>, second argument

    # preimage of the range under <map>
    if Length( arg ) = 1  then

        return PreImagesRange( arg[1] );

    elif Length( arg ) = 2 then
        map := arg[1];
        img := arg[2];

        # preimage of a single element <img> under the mapping <map>
        if IsIdentical( FamilyRange( FamilyObj( map ) ),
                        FamilyObj( img ) ) then

            return PreImagesElm( map, img );

        # preimage of a set or list of elements <img> under the mapping <map>
        elif IsIdentical( CollectionsFamily( FamilyRange( FamilyObj( map ) ) ),
                          FamilyObj( img ) ) then

          if IsDomain( img ) or IsSSortedList( map ) then
            return PreImagesSet( map, img );
          elif IsHomogeneousList( img ) then
            return PreImagesSet( map, Set( img ) );
          fi;

        fi;
    fi;
    Error("usage: PreImages( <map> ) or PreImages( <map>, <img> )");
end;


#############################################################################
##
#F  CompositionMapping(<map1>,<map2>, ... ) . . . . . composition of mappings
##
CompositionMapping := function ( arg )
    local   com,        # composition of the arguments, result
            i;          # loop variable

    # check the arguments
    if Length( arg ) = 0  then
        Error("usage: CompositionMapping(<map1>..)");
    fi;

    # unravel the argument list
    if Length( arg ) = 1  and IsList( arg[1] )  then
        arg := arg[1];
    fi;

    # compute the composition
    com := arg[ Length( arg ) ];
    if not IsGeneralMapping( com ) then
      Error( "<com> must be (general) mapping" );
    fi;
    for i  in Reversed( [1..Length( arg )-1] )  do
        if not IsGeneralMapping( arg[i] ) then
          Error( "<i>-th argument must be (general) mapping" );
        elif not IsIdentical( FamilySource( FamilyObj( arg[i] ) ),
                              FamilyRange(  FamilyObj( com ) ) ) then
            Error( "the range of <com> and the source of 'arg[i]' ",
                   "must be contained in the same family" );
        fi;
        com := CompositionMapping2( arg[i], com );
    od;

    # return the composition
    return com;
end;


#############################################################################
##
#M  IsSingleValued( <map> )
##
InstallMethod( IsSingleValued, true, [ IsGeneralMapping ], 0,
    function ( map )

    # test that each element of the source has exactly one image
    if IsFinite( Source( map ) )  then
        return ForAll( Source( map ),
                       elm -> Size( Images( map, elm ) ) = 1 );

    # give up if <map> has an infinite source
    else
        Error("sorry, can not test if <map> is a mapping, infinite source");
    fi;
    end );

#############################################################################
##
#M  AsMapping( <map> )
##
InstallMethod( AsMapping, true, [ IsGeneralMapping ], 0,
    function ( map )

    if not IsSingleValued( map ) then
      return fail;
    fi;

    Error( "generic method to create mapping from general mapping not yet implemented" );
    end );


#############################################################################
##
#M  IsInjective( <map> ) . . . . . . . . . . . test if a mapping is injective
##
InstallMethod( IsInjective, true, [ IsMapping ], 0,
    function ( map )

    # if the source is larger than the range, <map> can not be injective
    if Size( Range( map ) ) < Size( Source( map ) )  then
        return false;

    # compare the size of the source with the size of the image
    elif IsFinite( Source( map ) )  then
        return Size( Source( map ) ) = Size( Image( map ) );

    # give up if <map> has an infinite source
    else
        Error("sorry, can not test if <map> is injective, infinite source");
    fi;
    end );

#############################################################################
##
#M  IsSurjective( <map> )  . . . . . . . . .  test if a mapping is surjective
##
InstallMethod( IsSurjective, true, [ IsMapping ], 0,
    function ( map )

    # if the source is smaller than the range, <map> can not be surjective
    if Size( Source( map ) ) < Size( Range( map ) )  then
        return false;

    # otherwise compare the size of the range with the size of the image
    elif IsFinite( Range( map ) )  then
        return Size( Range( map ) ) = Size( Image( map ) );

    # give up if <map> has an infinite range
    else
        Error("sorry, can not test if <map> is surjective, infinite range");
    fi;
    end );

#############################################################################
##
#M  '<map> = <map2>'  . . . . . . . . . . . .  test if two mappings are equal
##
InstallMethod( \=, IsIdentical, [ IsGeneralMapping, IsGeneralMapping ], 0,
    function ( map1, map2 )

    # if <map1> is a mapping
    # maybe the properties we already know determine the result
    if ( HasIsTotal( map1 ) and HasIsTotal( map2 )
       and IsTotal( map1 ) <> IsTotal( map2 ) )
    or ( HasIsSingleValued( map1 ) and HasIsSingleValued( map2 )
       and IsSingleValued( map1 ) <> IsSingleValued( map2 ) )
    or ( HasIsInjective( map1 ) and HasIsInjective( map2 )
       and IsInjective( map1 ) <> IsInjective( map2 ) )
    or ( HasIsSurjective( map1 ) and HasIsSurjective( map2 )
       and IsSurjective( map1 ) <> IsSurjective( map2 ) )
#T  or (IsBound(map1.isHomomorphism) and IsBound(map2.isHomomorphism)
#T              and map1.isHomomorphism <> map2.isHomomorphism)
    then
      return false;
    fi;

    # otherwise we must really test the equality
    return Source( map1 ) = Source( map2 )
       and Range( map1 )  = Range( map2 )
       and ForAll( Source( map1 ),
                   elm -> ImagesElm( map1, elm ) = ImagesElm( map2, elm ) );
    end );

#############################################################################
##
#M  '<map> \< <map2>' . . . . . . . . . . . . . . . . .  compare two mappings
##
InstallMethod( \<, IsIdentical, [ IsGeneralMapping, IsGeneralMapping ], 0,
    function ( map1, map2 )
    local   elms,       # elements of the source of <map1> and <map2>
            i;          # loop variable

    # compare the sources and the rangs
    if Source( map1 ) <> Source( map2 ) then
      return Source( map1 ) < Source( map2 );
    elif Range( map1 ) <> Range( map2 ) then
      return Range( map1 ) < Range( map2 );

    # otherwise compare the images lexicographically
    else

      # find the first element where the images differ
      elms := EnumeratorSorted( Source( map1 ) );
      i := 1;
      while i <= Length( elms )
            and ImagesElm( map1, elms[i] ) = ImagesElm( map2, elms[i] )  do
        i := i + 1;
      od;

      # compare the image sets
      return     i <= Length( elms )
             and ImagesElm( map1, elms[i] ) < ImagesElm( map2, elms[i] );

    fi;
    end );

#############################################################################
##
#M  '<map> \* <map2>'
##
InstallMethod( \*, FamSource2EqFamRange1,
    [ IsGeneralMapping, IsGeneralMapping ], 0,
    function ( map1, map2 )
    return CompositionMapping2( map2, map1 );
    end );

#############################################################################
##
#F  '<map> \^ <map2>'
#F  '<elm> \^ <map>'
#F  '<map> \^ <int>'  . . . . . . . . . . . . . . . . . .  power of a mapping
#T what about <coll> \^ <map> ?
##
FamSourceRgtEqFamsLft := function( FamLft, FamRgt )
    return     IsIdentical( FamilySource( FamLft ), FamilyRange( FamLft ) )
           and IsIdentical( FamilySource( FamRgt ), FamilyRange( FamLft ) );
end;

InstallMethod( \^, FamSourceRgtEqFamsLft, [ IsMapping, IsMapping ], 0,
    function ( lft, rgt )
    if not IsBijective( rgt )  then
        Error("<rgt> must be a bijection");
    fi;
    return rgt^-1 * lft * rgt;
    end );

InstallOtherMethod( \^, FamElmEqFamSource, [ IsObject, IsMapping ], 0,
    function ( elm, map )
    return ImageElm( map, elm );
    end );

InstallMethod( \^, true, [ IsMapping, IsNegRat and IsInt ], 0,
    function ( map, n )
    local pow;
    if not IsBijective( map ) then
      Error( "<map> must be a bijection" );
    fi;
#T or accept non-bijective mappings?
#T (allow powering of multi-valued or non-total general mappings?)
    return Inverse( map ) ^ (-n);
    end );

InstallOtherMethod( One, true, [ IsGeneralMapping ], 0,
    function ( map )
    if not IsIdentical( FamilySource( FamilyObj( map ) ),
                        FamilyRange( FamilyObj( map ) ) ) then
      Error( "source and range of <map> are not in the same family" );
    fi;
    return IdentityMapping( Source( map ) );
    end );

InstallMethod( \^, true, [ IsGeneralMapping, IsPosRat and IsInt ], 0,
    function ( map, n )
    local   pow,        # <map> raised to the <n>th power, result
            i;          # loop variable

    # compute the power
    pow := IdentityMapping( Source( map ) );
    i := 2 ^ (Log( n, 2 ) + 1);
    while 1 < i  do
        pow := CompositionMapping2( pow, pow );
        i := QuoInt( i, 2 );
        if i <= n  then
            pow := CompositionMapping2( pow, map );
            n := n - i;
        fi;
    od;

    # return the power
    return pow;
    end );


#############################################################################
##
#M  <elm> / <map> . . . . . . . . . . . . . . . . . . . . preimage of element
##
InstallOtherMethod( \/, FamElmEqFamRange, [ IsObject,
        IsGeneralMapping and IsInjective and IsSurjective ], 0,
    function( elm, map )
    return PreImageElm( map, elm );
    end );

#############################################################################
##
#M  ImageElm( <map>, <elm> )
##
InstallMethod( ImageElm, FamSourceEqFamElm, [ IsMapping, IsObject ], 0,
    function ( map, elm )
    return Enumerator( ImagesElm( map, elm ) )[1];
    end );


#############################################################################
##
#M  ImagesElm( <map>, <elm> )
##
InstallMethod( ImagesElm, true, [ IsGeneralMapping, IsObject ], 0,
    function ( map, elm )
    Error( "no default function to find images of <elm> under <map>" );
    end );


#############################################################################
##
#M  ImagesSet( <map>, <elms> )
##
InstallMethod( ImagesSet, CollFamSourceEqFamElms,
    [ IsGeneralMapping, IsCollection ], 0,
    function ( map, elms )
    return Union( List( Enumerator( elms ), elm -> ImagesElm( map, elm ) ) );
    end );

#############################################################################
##
#M  ImagesSource( <map> )
##
InstallMethod( ImagesSource, true, [ IsGeneralMapping ], 0,
    map -> ImagesSet( map, Source( map ) ) );

InstallMethod( ImagesSource, true, [ IsGeneralMapping and IsSurjective ], 0,
    Range );


#############################################################################
##
#M  ImagesRepresentative( <map>, <elm> )
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
    [ IsGeneralMapping, IsObject ], 0,
    function ( map, elm )
    local   rep,        # representative, result
            imgs;       # all images of <elm> under <map>

    # get all images of <elm> under <map>
    imgs := ImagesElm( map, elm );

    # check that <elm> has at least one image under <map>
    if Size( imgs ) = 0  then
        Error("<elm> must have at least one image under <map>");
    fi;

    # pick one image from the source, which is probably a proper set
    # and return it
    return Representative( imgs );
    end );


#############################################################################
##
#M  PreImageElm( <map>, <elm> )
##
InstallMethod( PreImageElm, FamRangeEqFamElm,
    [ IsGeneralMapping and IsInjective and IsSurjective, IsObject ], 0,
    function ( bij, elm )

    # check that <bij> is a bijection
    if not IsBijective( bij )  then
        Error("<bij> must be a bijection, not an arbitrary mapping");
    fi;

    # take the first and only preimage of <elm> under <bij>
    return Enumerator( PreImages( bij, elm ) )[1];
    end );

#############################################################################
##
#M  PreImagesElm( <map>, <elm> )
##
InstallMethod( PreImagesElm, FamRangeEqFamElm,
               [ IsGeneralMapping, IsObject ], 0,
    function ( map, elm )

    # for a finite source simply run over the elements of the source
    if IsFinite( Source( map ) )  then
        return Filtered( Source( map ),
                         pre -> elm in Images( map, pre ) );

    # give up if <map> has an infinite source
    else
      Error("sorry, can not compute preimages under <map>, infinite source");
    fi;
    end );


#############################################################################
##
#M  PreImagesSet( <map>, <elms> )
##
InstallMethod( PreImagesSet, CollFamRangeEqFamElms,
    [ IsGeneralMapping, IsCollection ], 0,
    function ( map, elms )
    return Union( List( Enumerator( elms ), elm -> PreImages( map, elm ) ) );
    end );


#############################################################################
##
#M  PreImagesRange( <map> )
##
InstallMethod( PreImagesRange, true, [ IsGeneralMapping ], 0,
    map -> PreImagesSet( map, Range( map ) ) );

InstallMethod( PreImagesRange, true, [ IsGeneralMapping and IsTotal ], 0,
    Source );


#############################################################################
##
#M  PreImagesRepresentative( <map>, <elm> )
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
    [ IsGeneralMapping, IsObject ], 0,
    function ( map, elm )
    local   pres;       # all preimages of <elm> under <map>

    # get all preimages of <elm> under <map>
    pres := PreImages( map, elm );

    # check that <elm> has at least one preimage under <map>
    if Size( pres ) = 0  then
        Error("<elm> must have at least one preimage under <map>");
    fi;

    # pick one preimage from the source, which is probably a proper set,
    # and return it.
    return Representative( pres );
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
    IsAttributeStoringRep,
    [] );


#############################################################################
##
##  An identity mapping whose source has a nice structure get the property
##  to respect this structure.
##
ImmediateImplicationsIdentityMapping := function( idmap )
    if IsMagma( Source( idmap ) ) then
      SetRespectsMultiplication(idmap,true);
      if IsMagmaWithOne(Source(idmap)) then
	SetRespectsOne(idmap,true);
	if IsMagmaWithInverses(Source(idmap)) then
	  SetRespectsInverses(idmap,true);
	fi;
      fi;
    fi;
end;


#############################################################################
##
#M  IdentityMapping( <D> )  . . . . . . . .  identity mapping of a collection
##
#T collsgen.g?
InstallMethod( IdentityMapping, true, [ IsCollection ], 0,
    function ( D )
    local Fam, id;

    Fam:= ElementsFamily( FamilyObj( D ) );

    # make the mapping record
    id := Objectify( KindOfDefaultGeneralMapping( D, D,
                                  IsIdentityMappingRep
                              and IsMapping and IsBijective
                              and IsMultiplicativeElementWithInverse ),
#T should hold for all general mappings with source and range in the same family
                     rec() );

    # enter preimage and image
    SetPreImagesRange( id, D );
    SetImagesSource(   id, D );

    # the identity mapping is self-inverse
    SetInverse( id, id );

    # set the respectings
    ImmediateImplicationsIdentityMapping(id);

    # return the identity mapping
    return id;
    end );


#############################################################################
##
##  An identity mapping whose source has a nice structure gets the properties
##  to respect this structure.
##
ImmediateImplicationsIdentityMapping := function (idmap)
    if IsMagma( Source( idmap ) ) then
      SetRespectsMultiplication(idmap,true);
      if IsMagmaWithOne(Source(idmap)) then
	SetRespectsOne(idmap,true);
	if IsMagmaWithInverses(Source(idmap)) then
	  SetRespectsInverses(idmap,true);
	fi;
      fi;
    fi;
end;


#############################################################################
##
##  methods for identity mappings (all installed with rank 'SUM_FLAGS')
##
InstallMethod( \^,
    "method for identity mapping and integer",
    true,
    [ IsMapping and IsIdentityMappingRep, IsInt ], SUM_FLAGS,
    function ( id, n )
    return id;
    end );

    
InstallMethod( ImageElm,
    "method for identity mapping and object",
    FamSourceEqFamElm,
    [ IsMapping and IsIdentityMappingRep, IsObject ], SUM_FLAGS,
    function ( id, elm )
    return elm;
    end );

InstallMethod( ImagesElm,
    "method for identity mapping and object",
    FamSourceEqFamElm,
    [ IsMapping and IsIdentityMappingRep, IsObject ], SUM_FLAGS,
    function ( id, elm )
    return [ elm ];
    end );

InstallMethod( ImagesSet,
    "method for identity mapping and object",
    CollFamSourceEqFamElms,
    [ IsMapping and IsIdentityMappingRep, IsCollection ], SUM_FLAGS,
    function ( id, elms )
    return elms;
    end );

InstallMethod( ImagesRepresentative,
    "method for identity mapping and object",
    FamSourceEqFamElm,
    [ IsMapping and IsIdentityMappingRep, IsObject ], SUM_FLAGS,
    function ( id, elm )
    return elm;
    end );

InstallMethod( PreImageElm,
    "method for identity mapping and object",
    FamRangeEqFamElm,
    [ IsMapping and IsBijective and IsIdentityMappingRep,
      IsObject ], SUM_FLAGS,
    function ( id, elm )
    return elm;
    end );

InstallMethod( PreImagesElm,
    "method for identity mapping and object",
    FamRangeEqFamElm,
    [ IsMapping and IsIdentityMappingRep, IsObject ], SUM_FLAGS,
    function ( id, elm )
    return [ elm ];
    end );

InstallMethod( PreImagesSet,
    "method for identity mapping and collection",
    CollFamRangeEqFamElms,
    [ IsMapping and IsIdentityMappingRep, IsCollection ], SUM_FLAGS,
    function ( id, elms )
    return elms;
    end );

InstallMethod( PreImagesRepresentative,
    "method for identity mapping and object",
    FamRangeEqFamElm,
    [ IsMapping and IsIdentityMappingRep, IsObject ], SUM_FLAGS,
    function ( id, elm )
    return elm;
    end );

InstallMethod( PrintObj,
    "method for identity mapping",
    true, [ IsMapping and IsIdentityMappingRep ], SUM_FLAGS,
    function ( id )
    Print( "IdentityMapping( ", Source( id )," )" );
    end );

InstallMethod( CompositionMapping2,
    "method for general mapping and identity mapping",
    FamSource1EqFamRange2,
    [ IsGeneralMapping, IsMapping and IsIdentityMappingRep ], SUM_FLAGS,
    function ( map, id )
    return map;
    end );

InstallMethod( CompositionMapping2,
    "method for identity mapping and general mapping",
    FamSource1EqFamRange2,
    [ IsMapping and IsIdentityMappingRep, IsGeneralMapping ], SUM_FLAGS,
    function ( id, map )
    return map;
    end );


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

InstallMethod( InverseGeneralMapping, true, [ IsGeneralMapping ], 0,
    function ( map )
    local   inv;

    # make the mapping
    inv:= Objectify( KindOfDefaultGeneralMapping( Range( map ),
                                                  Source( map ),
                              IsInverseMapping and IsAttributeStoringRep ),
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

    # return the inverse mapping
    return inv;
    end );


#############################################################################
##
#M  Inverse( <map> ) . . . . . . . . . . inverse mapping of a general mapping
##
##  The inverse of a general mapping is again a general mapping.
##  The inverse of a mapping <map> is a mapping if and only if <map> is
##  bijective, otherwise is a general mapping.
#T what about non-total injective and surjective general mappings?
##
InstallOtherMethod( Inverse, true, [ IsGeneralMapping ], 0,
    function ( map )
    local   inv;

    # make the mapping
    if IsMapping( map ) and IsBijective( map ) then
      inv:= Objectify( KindOfDefaultGeneralMapping( Range( map ),
                                                    Source( map ),
                                    IsInverseMapping
                                and IsMapping
                                and IsAttributeStoringRep ),
                       rec() );
    else
      inv:= Objectify( KindOfDefaultGeneralMapping( Range( map ),
                                                    Source( map ),
                                    IsInverseMapping
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

    # maybe we know that this mapping is single valued
    if HasIsBijective( map ) and IsBijective( map ) then
      SetIsInjective( inv, true );
      SetIsSurjective( inv, true );
    fi;

    # we know the inverse mapping of the inverse mapping ;-)
    SetInverse( inv, map );

    # return the inverse mapping
    return inv;
    end );

InstallMethod( IsSingleValued, true, [ IsInverseMapping ], 0,
    inv ->     IsMapping( Inverse( inv ) )
           and IsBijective( Inverse( inv ) ) );

InstallMethod( IsInjective, true, [ IsInverseMapping and IsMapping ], 0,
    inv -> IsBijective( Inverse( inv ) ) );

InstallMethod( IsSurjective, true, [ IsInverseMapping and IsMapping ], 0,
    inv -> IsBijective( Inverse( inv ) ) );

#T InstallMethod( IsGroupHomomorphism, true, [ IsInverseMapping ], 0,
#T     function ( inv )
#T     if not IsMapping( inv )  then
#T         Error("<map> must be a single valued mapping");
#T     fi;
#T     if IsMapping( Inverse( inv ) )
#T         and IsGroupHomomorphism( Inverse( inv ) )
#T     then
#T         return IsBijective( Inverse( inv ) );
#T     fi;
#T     TryNextMethod();
#T     end );

InstallMethod( ImageElm, FamSourceEqFamElm,
    [ IsInverseMapping and IsMapping, IsObject ], 0,
    function ( inv, elm )
    return PreImageElm( Inverse( inv ), elm );
    end );

InstallMethod( ImagesElm, FamSourceEqFamElm,
    [ IsInverseMapping, IsObject ], 0,
    function ( inv, elm )
    return PreImagesElm( Inverse( inv ), elm );
    end );

InstallMethod( ImagesSet, CollFamSourceEqFamElms,
    [ IsInverseMapping, IsCollection ], 0,
    function ( inv, elms )
    return PreImagesSet( Inverse( inv ), elms );
    end );

InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
    [ IsInverseMapping, IsObject ], 0,
    function ( inv, elm )
    return PreImagesRepresentative( Inverse( inv ), elm );
    end );

InstallMethod( PreImageElm, FamRangeEqFamElm,
    [ IsInverseMapping and IsInjective and IsSurjective, IsObject ], 0,
    function ( inv, elm )
    return ImageElm( Inverse( inv ), elm );
    end );

InstallMethod( PreImagesElm, FamRangeEqFamElm,
    [ IsInverseMapping, IsObject ], 0,
    function ( inv, elm )
    return ImagesElm( Inverse( inv ), elm );
    end );

InstallMethod( PreImagesSet, CollFamRangeEqFamElms,
    [ IsInverseMapping, IsCollection ], 0,
    function ( inv, elms )
    return Images( Inverse( inv ), elms );
    end );

InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
    [ IsInverseMapping, IsObject ], 0,
    function ( inv, elm )
    return ImagesRepresentative( Inverse( inv ), elm );
    end );

InstallMethod( PrintObj, true, [ IsInverseMapping ], 100,
    function ( inv )
    Print( "Inverse( ", Inverse( inv )," )" );
    end );
    
IsBijectiveMappingByFunctionsRep := NewRepresentation
    ( "IsBijectiveMappingByFunctionsRep", IsGeneralMapping and IsBijective,
      [ "there", "back" ] );

BijectiveMappingByFunctions := function( G, H, I, P )
    local   map;
    
    map := Objectify( NewKind
               ( GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                                        ElementsFamily( FamilyObj( H ) ) ),
                 IsBijectiveMappingByFunctionsRep ),
               rec( there := I, back := P ) );    
    SetSource( map, G );
    SetRange ( map, H );
    return map;
end;

InstallMethod( PrintObj, true, [ IsBijectiveMappingByFunctionsRep ], 0,
    function( map )
    Print( "<bijective mapping by functions>" );
end );

#############################################################################
##
#E  mapping.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



