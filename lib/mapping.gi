#############################################################################
##
#W  mapping.gi                  GAP library                     Thomas Breuer
#W                                                         & Martin Schoenert
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
#F  GeneralMappingsFamily( <famsourceelms>, <famrangeelms> )
##
GeneralMappingsFamily := function( FS, FR )
    return CollectionsFamily( TuplesFamily( [ FS, FR ] ) );
end;
#T should be obsolete!


#############################################################################
##
#M  PrintObj( <map> ) . . . . . . . . . . . . . . . . . . for general mapping
##
InstallMethod( PrintObj,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    Print( "<general mapping: ", Source( map ), " -> ", Range( map ), " >" );
    end );


#############################################################################
##
#M  IsFinite( <map> ) . . . . . . . . . . . . . . . . . . for general mapping
##
InstallMethod( IsFinite,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    if IsFinite( Source( map ) ) and IsFinite( Range( map ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Enumerator( <map> ) . . . . . . . . . . . . . . . . . for general mapping
##
InstallMethod( Enumerator,
    "method for a finite general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    local enum, S, R, elm, imgs;
    enum:= [];
    S:= Source( map );
    R:= Range( map );
    if   IsFinite( S ) then
      for elm in Enumerator( S ) do
        imgs:= ImagesElm( map, elm );
        if IsFinite( imgs ) then
          UniteSet( enum, List( imgs, im -> Tuple( [ elm, im ] ) ) );
        else
          TryNextMethod();
        fi;
      od;
      return enum;
    elif IsFinite( R ) then
      for elm in Enumerator( R ) do
        imgs:= PreImagesElm( map, elm );
        if IsFinite( imgs ) then
          UniteSet( enum, List( imgs, im -> Tuple( [ im, elm ] ) ) );
        else
          TryNextMethod();
        fi;
      od;
      return enum;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  \in( <tuple>, <map> ) . . . . . . . . . . for element and general mapping
##
##  Note that '\in' may use the basic mapping functions.
##
InstallMethod( \in,
    "method for an element and a general mapping",
    IsElmsColls,
    [ IsTuple, IsGeneralMapping ], 0,
    function( elm, map )
    return elm[2] in ImagesElm( map, elm[1] );
    end );


#############################################################################
##
#F  Image( <map>, <elm> ) . . . . . . . . image of an element under a mapping
#F  Image( <map> )
##
Image := function ( arg )

    local   map,        # mapping <map>, first argument
            elm,        # element <elm>, second argument
            famsource;  # family or source elements

    # image of the source under <map>, which may be multi valued in this case
    if   Length( arg ) = 1 then

        return ImagesSource( arg[1] );

    elif Length( arg ) = 2 then

      map := arg[1];
      elm := arg[2];

      if not IsGeneralMapping( map ) then
        Error( "<map> must be a general mapping" );
      fi;

      famsource:= ComponentsOfTuplesFamily( ElementsFamily(
                      FamilyObj( map ) ) )[1];

      if IsIdentical( famsource, FamilyObj( elm ) ) then

        return ImageElm( map, elm );

      # image of a set or list of elments <elm> under the mapping <map>
      elif IsIdentical( CollectionsFamily( famsource ),
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
            elm,        # element <elm>, second argument
            famsource;  # family or source elements

    # image of the source under <map>
    if Length( arg ) = 1  then

        return ImagesSource(  arg[1] );

    elif Length( arg ) = 2 then

        map := arg[1];
        elm := arg[2];

        if not IsGeneralMapping( map ) then
          Error( "<map> must be a general mapping" );
        fi;

        famsource:= ComponentsOfTuplesFamily( ElementsFamily(
                        FamilyObj( map ) ) )[1];

        # image of a single element <elm> under the mapping <map>
        if IsIdentical( famsource, FamilyObj( elm ) ) then

          return ImagesElm( map, elm );

        # image of a set or list of elments <elm> under the mapping <map>
        elif IsIdentical( CollectionsFamily( famsource ),
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
#F  PreImage(<map>[,<img>]) . . . preimage of an element under a gen. mapping
##
PreImage := function ( arg )
    local   map,        # gen. mapping <map>, first argument
            img,        # element <img>, second argument
            pre,        # preimage of <img> under <map>, result
            famrange;   # family or range elements

    # preimage of the range under <map>, which may be a multi valued mapping
    if Length( arg ) = 1  then

        return PreImagesRange( arg[1] );

    elif Length( arg ) = 2 then

        map := arg[1];
        img := arg[2];

        if not IsGeneralMapping( map ) then
          Error( "<map> must be a general mapping" );
        fi;

        famrange:= ComponentsOfTuplesFamily( ElementsFamily(
                       FamilyObj( map ) ) )[2];

        # preimage of a single element <img> under <map>
        if IsIdentical( famrange, FamilyObj( img ) ) then

            return PreImageElm( map, img );

        # preimage of a set or list of elments <img> under <map>
        elif IsIdentical( CollectionsFamily( famrange ),
                          FamilyObj( img ) ) then

          if IsDomain( img ) or IsSSortedList( map ) then
            return PreImagesSet( map, img );
          elif IsHomogeneousList( img ) then
            return PreImagesSet( map, Set( img ) );
          fi;

        fi;
    fi;
    Error("usage: PreImage( <map> ) or PreImage( <map>, <img> )");
end;


#############################################################################
##
#F  PreImages(<map>,<img>)  . . . . . preimages of an element under a mapping
##
PreImages := function ( arg )
    local   map,        # mapping <map>, first argument
            img,        # element <img>, second argument
            famrange;   # family or range elements

    # preimage of the range under <map>
    if Length( arg ) = 1  then

        return PreImagesRange( arg[1] );

    elif Length( arg ) = 2 then
        map := arg[1];
        img := arg[2];

        if not IsGeneralMapping( map ) then
          Error( "<map> must be a general mapping" );
        fi;

        famrange:= ComponentsOfTuplesFamily( ElementsFamily(
                       FamilyObj( map ) ) )[2];

        # preimage of a single element <img> under <map>
        if IsIdentical( famrange, FamilyObj( img ) ) then

            return PreImagesElm( map, img );

        # preimage of a set or list of elements <img> under <map>
        elif IsIdentical( CollectionsFamily( famrange ),
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
        elif not FamSource2EqFamRange1( FamilyObj( com ),
                                        FamilyObj( arg[i] ) ) then
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
#M  IsTotal( <map> )  . . . . . . . . . . . . . . . . . . for general mapping
##
InstallMethod( IsTotal,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )

    # For a total and injective general mapping,
    # the range cannot be smaller than the source.

    if     HasIsInjective( map ) and IsInjective( map )
       and Size( Range( map ) ) < Size( Source( map ) ) then
      return false;
    else
      return IsSubset( PreImagesRange( map ), Source( map ) );
    fi;
    end );
    

#############################################################################
##
#M  IsSurjective( <map> ) . . . . . . . . . . . . . . . . for general mapping
##
InstallMethod( IsSurjective,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )

    # For a single-valued and surjective general mapping,
    # the source cannot be smaller than the range.

    if     HasIsSingleValued( map ) and IsSingleValued( map )
       and Size( Source( map ) ) < Size( Range( map ) ) then
      return false;
    else
      return IsSubset( ImagesSource( map ), Range( map ) );
    fi;
    end );


#############################################################################
##
#M  IsSingleValued( <map> ) . . . . . . . . . . . . . . for a general mapping
##
InstallMethod( IsSingleValued,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )

    if HasIsSurjective( map ) and IsSurjective( map ) then

      # For a single-valued and surjective general mapping,
      # the range cannot be larger than the source.
      if Size( Source( map ) ) < Size( Range( map ) ) then
        return false;
      fi;

    fi;

    if IsFinite( Source( map ) )  then

      # test that each element of the source has at most one image
      return ForAll( Source( map ),
                     elm -> Size( ImagesElm( map, elm ) ) <= 1 );

    else

      # give up if <map> has an infinite source
      TryNextMethod();

    fi;
    end );


#############################################################################
##
#M  IsInjective( <map> )  . . . . . . . . . . . . . . . for a general mapping
##
InstallMethod( IsInjective,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )

    local enum,    # enumerator for the source
          imgs,    # list of images for the elements of the source
          elm,     # loop over 'enum'
          img;     # one set of images

    if HasIsTotal( map ) and IsTotal( map ) then

      # For a total and injective general mapping,
      # the source cannot be larger than the range.
      if Size( Range( map ) ) < Size( Source( map ) ) then
        return false;
      fi;

    fi;

    if IsFinite( Source( map ) ) then

      # Check that the images of different elements are disjoint.
      enum:= Enumerator( Source( map ) );
      imgs:= [];
      for elm in enum do
        img:= ImagesElm( map, elm );
        if ForAny( imgs, im -> Size( Intersection2( im, img ) ) <> 0 ) then
          return false;
        fi;
        Add( imgs, img );
      od;
      return true;

    else

      # give up if <map> has an infinite source
      TryNextMethod();

    fi;
    end );


#############################################################################
##
#M  IsInjective( <map> )  . . . . . . . . . . . . . . . . . . . for a mapping
##
InstallMethod( IsInjective,
    "method for a mapping",
    true,
    [ IsGeneralMapping and IsTotal and IsSingleValued ], 0,
    function( map )

    # For a total and injective general mapping,
    # the source cannot be larger than the range.
    if Size( Range( map ) ) < Size( Source( map ) ) then
      return false;

    # compare the size of the source with the size of the image
    elif IsFinite( Source( map ) )  then
      return Size( Source( map ) ) = Size( ImagesSource( map ) );

    # give up if <map> has an infinite source
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  \=( <map1>, <map2> )  . . . . . . . . . . . . .  for two general mappings
##
InstallMethod( \=,
    "method for two general mappings",
    IsIdentical,
    [ IsGeneralMapping, IsGeneralMapping ], 0,
    function( map1, map2 )

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
#M  \<( <map1>, <map2> )  . . . . . . . . . . . . .  for two general mappings
##
InstallMethod( \<,
    "method for two general mappings",
    IsIdentical,
    [ IsGeneralMapping, IsGeneralMapping ], 0,
    function( map1, map2 )
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
#M  \*( <map1>, <map2> )  . . . . . . . . . . . . .  for two general mappings
##
InstallMethod( \*,
    "method for two general mappings",
    FamSource2EqFamRange1,
    [ IsGeneralMapping, IsGeneralMapping ], 0,
    function( map1, map2 )
    return CompositionMapping2( map2, map1 );
    end );


#############################################################################
##
#M  \^( <map1>, <map2> )  . . . . . . . . conjugation of two general mappings
##
InstallMethod( \^,
    "method for two general mappings",
    FamSourceRgtEqFamsLft,
    [ IsGeneralMapping, IsGeneralMapping ], 0,
    function( lft, rgt )
    return InverseGeneralMapping( rgt ) * lft * rgt;
    end );


#############################################################################
##
#M  \^( <elm>, <map> )
#T what about <coll> \^ <map> ?
##
InstallOtherMethod( \^,
    "method for element in the source, and general mapping",
    FamElmEqFamSource,
    [ IsObject, IsGeneralMapping ], 0,
    function( elm, map )
    return ImageElm( map, elm );
    end );


#############################################################################
##
#M  One( <map> )  . . . . . . . . . . . . . . . . . . . . .  identity mapping
##
InstallOtherMethod( One,
    "method for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    if Source( map ) = Range( map ) then
      return IdentityMapping( Source( map ) );
    else
      Error( "source and range of <map> are different" );
    fi;
    end );


#############################################################################
##
#M  <elm> / <map> . . . . . . . . . . . . . . . . . . . . preimage of element
##
InstallOtherMethod( \/,
    "method for element, and inj. & surj. general mapping",
    FamElmEqFamRange,
    [ IsObject, IsGeneralMapping and IsInjective and IsSurjective ], 0,
    function( elm, map )
    return PreImageElm( map, elm );
    end );


#############################################################################
##
#M  ImageElm( <map>, <elm> )  . . . . . . . . . . . . for mapping and element
##
InstallMethod( ImageElm,
    "method for mapping, and element",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsTotal and IsSingleValued, IsObject ], 0,
    ImagesRepresentative );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . . .  for non s.p. general mapping and element
##
InstallMethod( ImagesElm,
    "method for non s.p. general mapping, and element",
    true,
    [ IsNonSPGeneralMapping, IsObject ], 0,
    function( map, elm )
    Error( "no default function to compute images of <elm> under <map>" );
    end );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . . . for gen. mapping with enumerator and elm.
##
InstallMethod( ImagesElm,
    "method for general mapping with enumerator, and element",
    true,
    [ IsGeneralMapping and HasEnumerator, IsObject ], 0,
    function( map, elm )
    local imgs, pair;
    imgs:= [];
    for pair in Enumerator( map ) do
      if pair[1] = elm then
        AddSet( imgs, pair[2] );
      fi;
    od;
    return imgs;
    end );


#############################################################################
##
#M  ImagesSet( <map>, <elms> )  . . . . .  for generel mapping and collection
##
InstallMethod( ImagesSet,
    "method for general mapping, and collection",
    CollFamSourceEqFamElms,
    [ IsGeneralMapping, IsCollection ], 0,
    function( map, elms )
    local imgs, elm, im;
    imgs:= [];
    for elm in Enumerator( elms ) do
      im:= ImagesElm( map, elm );
      if im = fail then
        return fail;
      else
        UniteSet( imgs, im );
      fi;
    od;
    return imgs;
    end );


#############################################################################
##
#M  ImagesSource( <map> ) . . . . . . . . . . . . . . . . for general mapping
##
InstallMethod( ImagesSource,
    "method for general mapping",
    true,
    [ IsGeneralMapping ], 0,
    map -> ImagesSet( map, Source( map ) ) );


#############################################################################
##
#M  ImagesSource( <map> ) . . . . . . . . . .  for surjective general mapping
##
InstallMethod( ImagesSource,
    "method for surjective general mapping",
    true,
    [ IsGeneralMapping and IsSurjective ], 0,
    Range );


#############################################################################
##
#M  ImagesRepresentative( <map>, <elm> )  . . . for s.p. gen. mapping and elm
##
InstallMethod( ImagesRepresentative,
    "method for s.p. general mapping, and element",
    FamSourceEqFamElm,
    [ IsSPGeneralMapping, IsObject ], 0,
    function( map, elm )
    Error( "no default method for s.p. general mapping" );
    end );


#############################################################################
##
#M  ImagesRepresentative( <map>, <elm> )  . for non s.p. gen. mapping and elm
##
InstallMethod( ImagesRepresentative,
    "method for non s.p. general mapping, and element",
    FamSourceEqFamElm,
    [ IsNonSPGeneralMapping, IsObject ], 0,
    function( map, elm )
    local   rep,        # representative, result
            imgs;       # all images of <elm> under <map>

    # get all images of <elm> under <map>
    imgs:= ImagesElm( map, elm );

    # check that <elm> has at least one image under <map>
    if imgs = fail and Size( imgs ) = 0  then
      return fail;
    else

      # pick one image, and return it
      return Representative( imgs );
    fi;
    end );


#############################################################################
##
#M  PreImageElm( <map>, <elm> )
##
InstallMethod( PreImageElm,
    "method for inj. & surj. general mapping, and element",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsInjective and IsSurjective, IsObject ], 0,
    PreImagesRepresentative );


#############################################################################
##
#M  PreImagesElm( <map>, <elm> )  . . . . . . for general mapping and element
##
InstallMethod( PreImagesElm,
    "method for general mapping, and element",
    FamRangeEqFamElm,
    [ IsGeneralMapping, IsObject ], 0,
    function ( map, elm )

    # for a finite source simply run over the elements of the source
    if IsFinite( Source( map ) )  then
        return Filtered( Source( map ),
                         pre -> elm in ImagesElm( map, pre ) );

    # give up if <map> has an infinite source
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  PreImagesSet( <map>, <elms> ) . . . .  for general mapping and collection
##
InstallMethod( PreImagesSet,
    "method for general mapping, and collection",
    CollFamRangeEqFamElms,
    [ IsGeneralMapping, IsCollection ], 0,
    function( map, elms )
    local primgs, elm, prim;
    primgs:= [];
    for elm in Enumerator( elms ) do
      prim:= PreImagesElm( map, elm );
      if prim = fail then
        return fail;
      else
        UniteSet( primgs, prim );
      fi;
    od;
    return primgs;
    end );


#############################################################################
##
#M  PreImagesRange( <map> ) . . . . . . . . . . . . . . . for general mapping
##
InstallMethod( PreImagesRange,
    "method for general mapping",
    true,
    [ IsGeneralMapping ], 0,
    map -> PreImagesSet( map, Range( map ) ) );


#############################################################################
##
#M  PreImagesRange( <map> ) . . . . . . . . . . . . for total general mapping
##
InstallMethod( PreImagesRange,
    "method for total general mapping",
    true,
    [ IsGeneralMapping and IsTotal ], 0,
    Source );


#############################################################################
##
#M  PreImagesRepresentative( <map>, <elm> )  . .  for s.p. gen. mapping & elm
##
InstallMethod( PreImagesRepresentative,
    "method for s.p. general mapping, and element",
    FamRangeEqFamElm,
    [ IsSPGeneralMapping, IsObject ], 0,
    function( map, elm )
    Error( "no default method for s.p. general mapping" );
    end );


#############################################################################
##
#M  PreImagesRepresentative( <map>, <elm> )
##
InstallMethod( PreImagesRepresentative,
    "method for total non-s.p. general mapping, and element",
    FamRangeEqFamElm,
    [ IsNonSPGeneralMapping, IsObject ], 0,
    function ( map, elm )
    local   pres;       # all preimages of <elm> under <map>

    # get all preimages of <elm> under <map>
    pres := PreImagesElm( map, elm );

    # check that <elm> has at least one preimage under <map>
    if Size( pres ) = 0  then
        Error("<elm> must have at least one preimage under <map>");
    fi;

    # pick one preimage, and return it.
    return Representative( pres );
    end );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . . . . . . . . . . . for wrong family relation
##
InstallMethod( ImagesElm,
    "method for general mapping and element",
    FamSourceNotEqFamElm,
    [ IsGeneralMapping, IsObject ], 0,
    ReturnFail );


#############################################################################
##
#M  ImagesRepresentative( <map>, <elm> )  . . . . . for wrong family relation
##
InstallMethod( ImagesRepresentative,
    "method for general mapping and element",
    FamSourceNotEqFamElm,
    [ IsGeneralMapping, IsObject ], 0,
    ReturnFail );


#############################################################################
##
#M  PreImagesElm( <map>, <elm> )  . . . . . . . . . for wrong family relation
##
InstallMethod( PreImagesElm,
    "method for general mapping and element",
    FamRangeNotEqFamElm,
    [ IsGeneralMapping, IsObject ], 0,
    ReturnFail );


#############################################################################
##
#M  PreImagesRepresentative( <map>, <elm> ) . . . . for wrong family relation
##
InstallMethod( PreImagesRepresentative,
    "method for general mapping and element",
    FamRangeNotEqFamElm,
    [ IsGeneralMapping, IsObject ], 0,
    ReturnFail );


#############################################################################
##
#F  GeneralMappingByElements( <S>, <R>, <elms> )
##
##  is the general mapping with source <S> and range <R>,
##  and with elements in the list <elms> of tuples.
##
GeneralMappingByElements := function( S, R, elms )

    local map, tupfam;

    # Check the arguments.
    if   not ( IsDomain( S ) and IsDomain( R ) ) then

      Error( "<S> and <R> must be domains" );

    elif IsEmpty( elms ) then

      # Construct an empty general mapping.
      map:= Objectify( KindOfDefaultGeneralMapping( S, R,
                               IsNonSPGeneralMapping
                           and IsAttributeStoringRep
                           and IsEmpty ),
                       rec() );

    elif IsTuplesCollection( elms ) then

      tupfam:= ElementsFamily( FamilyObj( elms ) );
      if     IsIdentical( ElementsFamily( FamilyObj( S ) ),
                          ComponentsOfTuplesFamily( tupfam )[1] )
         and IsIdentical( ElementsFamily( FamilyObj( R ) ),
                          ComponentsOfTuplesFamily( tupfam )[2] ) then

        # Construct the general mapping.
        map:= Objectify( KindOfDefaultGeneralMapping( S, R,
                                 IsNonSPGeneralMapping
                             and IsAttributeStoringRep ),
                         rec() );

      else
        Error( "families of arguments do not match" );
      fi;

    else
      Error( "<elms> must be a collection of tuples or empty" );
    fi;

    # Set the identifying information.
    elms:= AsList( elms );
    SetEnumerator( map, elms );
    SetAsList( map, elms );

    # Return the general mapping.
    return map;
end;


#############################################################################
##
#E  mapping.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



