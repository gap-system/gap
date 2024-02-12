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
##  This file contains
##  1. the design of families of general mappings
##     now moved to mapping1.gi since it contain GAP/HPCGAP divergence
##  2. generic methods for general mappings
##  3. generic methods for underlying relations of general mappings
##

#############################################################################
##
##  2. generic methods for general mappings
##


#############################################################################
##
#M  PrintObj( <map> ) . . . . . . . . . . . . . . . . . . for general mapping
##
InstallMethod( PrintObj,
    "for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    Print( "<general mapping: ", Source( map ), " -> ", Range( map ), " >" );
    end );


#############################################################################
##
#M  PrintObj( <map> ) . . . . . . . . . . . . . . . . . . . . . . for mapping
##
InstallMethod( PrintObj,
    "for a mapping",
    true,
    [ IsMapping ], 0,
    function( map )
    Print( "<mapping: ", Source( map ), " -> ", Range( map ), " >" );
    end );
#T these are `ViewObj' methods. How could real `PrintObj' methods look like?


# #############################################################################
# ##
# #M  IsOne( <map> )  . . . . . . . . . . . . . . . . . . . for general mapping
# ##
# InstallOtherMethod( IsOne,
#     "for general mapping",
#     true,
#     [ IsGeneralMapping ], 0,
#     map ->     Source( map ) = Range( map )
#            and IsBijective( map )
#            and ForAll( Source( map ), elm -> ImageElm( map, elm ) = elm ) );


#############################################################################
##
#M  IsZero( <map> ) . . . . . . . . . . . . . . . . . . . for general mapping
##
InstallOtherMethod( IsZero,
    "for general mapping",
    true,
    [ IsGeneralMapping ], 0,
    map ->     Zero( Range( map ) ) <> fail
           and IsTotal( map )
           and ImagesSource( map ) = [ Zero( Range( map ) ) ] );


#############################################################################
##
#M  IsEndoGeneralMapping( <map> ) . . . . . . . . . . . . for general mapping
##
InstallOtherMethod( IsEndoGeneralMapping,
    "for general mapping",
    true,
    [ IsGeneralMapping ], 0,
    map -> Source( map ) = Range( map ) );


#############################################################################
##
#F  Image( <map> )  . . . .  set of images of the source of a general mapping
#F  Image( <map>, <elm> ) . . . .  unique image of an element under a mapping
#F  Image( <map>, <coll> )  . . set of images of a collection under a mapping
##
InstallGlobalFunction( Image, function ( arg )

    local   map,        # mapping <map>, first argument
            elm;        # element <elm>, second argument

    if Length(arg) > 0 and not IsGeneralMapping( arg[1] ) then
      ErrorNoReturn( "<map> must be a general mapping" );
    fi;

    # image of the source under <map>, which may be multi valued in this case
    if Length( arg ) = 1 then

        return ImagesSource( arg[1] );

    elif Length( arg ) = 2 then

      map := arg[1];
      elm := arg[2];

      # image of a single element <elm> under the mapping <map>
      if     FamSourceEqFamElm( FamilyObj( map ), FamilyObj( elm ) ) then
        if not IsMapping( map ) then
          ErrorNoReturn( "<map> must be single-valued and total" );
        elif not elm in Source( map ) then
          ErrorNoReturn( "<elm> must be an element of Source(<map>)" );
        fi;
        return ImageElm( map, elm );

      # image of a collection of elements <elm> under the mapping <map>
      elif CollFamSourceEqFamElms( FamilyObj( map ), FamilyObj(elm) ) then
        if not IsSubset( Source( map ), elm ) then
          ErrorNoReturn( "the collection <elm> must be contained in ",
                         "Source(<map>)" );
        fi;

        if IsDomain( elm ) or IsSSortedList( elm ) then
          if HasSource(map) and IsIdenticalObj(Source(map),elm) then
            return ImagesSource( map );
          else
            return ImagesSet( map, elm );
          fi;
        elif IsHomogeneousList( elm ) then
          return ImagesSet( map, Set( elm ) );
        fi;

      # image of the empty list
      elif IsList( elm ) and IsEmpty( elm ) then

        return [];

      else
        ErrorNoReturn( "the families of the element or collection <elm> ",
                       "and Source(<map>) don't match, ",
                       "maybe <elm> is not contained in Source(<map>) or ",
                       "is not a homogeneous list or collection" );
      fi;
    fi;
    ErrorNoReturn( "usage: Image(<map>), Image(<map>,<elm>), ",
                   "Image(<map>,<coll>)" );
end );

#############################################################################
##
#M  <map>(<elm>)
#M  <map>(<coll>)
##
##  Method to allow mappings to be used like functions when appropriate

InstallMethod(CallFuncList, [IsGeneralMapping, IsList],
        function(map, lst)
    if Length(lst) <> 1 then
        TryNextMethod();
    fi;
    return Image(map, lst[1]);
end);


#############################################################################
##
#F  Images( <map> ) . . . .  set of images of the source of a general mapping
#F  Images( <map>, <elm> )  . . . set of images of an element under a mapping
#F  Images( <map>, <coll> ) . . set of images of a collection under a mapping
##
InstallGlobalFunction( Images, function ( arg )

    local   map,        # mapping <map>, first argument
            elm;        # element <elm>, second argument

    if Length(arg) > 0 and not IsGeneralMapping( arg[1] ) then
      ErrorNoReturn( "<map> must be a general mapping" );
    fi;

    # image of the source under <map>
    if Length( arg ) = 1  then

        return ImagesSource(  arg[1] );

    elif Length( arg ) = 2 then

        map := arg[1];
        elm := arg[2];

        # image of a single element <elm> under the mapping <map>
        if     FamSourceEqFamElm( FamilyObj( map ), FamilyObj( elm ) ) then
          if not elm in Source( map ) then
            ErrorNoReturn( "<elm> must be an element of Source(<map>)" );
          fi;
          return ImagesElm( map, elm );

        # image of a collection of elements <elm> under the mapping <map>
        elif CollFamSourceEqFamElms( FamilyObj( map ), FamilyObj(elm) ) then
          if not IsSubset( Source( map ), elm ) then
            ErrorNoReturn( "the collection <elm> must be contained in ",
                           "Source(<map>)" );
          fi;

          if IsDomain( elm ) or IsSSortedList( elm ) then
            return ImagesSet( map, elm );
          elif IsHomogeneousList( elm ) then
            return ImagesSet( map, Set( elm ) );
          fi;

        # image of the empty list
        elif IsList( elm ) and IsEmpty( elm ) then

          return [];

        else
          ErrorNoReturn( "the families of the element or collection <elm> ",
                         "and Source(<map>) don't match, ",
                         "maybe <elm> is not contained in Source(<map>) or ",
                         "is not a homogeneous list or collection" );
        fi;
    fi;
    ErrorNoReturn( "usage: Images(<map>), Images(<map>,<elm>), ",
                   "Images(<map>,<coll>)" );
end );


#############################################################################
##
#F  PreImage( <map> ) . .  set of preimages of the range of a general mapping
#F  PreImage( <map>, <elm> )  . unique preimage of an elm under a gen.mapping
#F  PreImage(<map>,<coll>)   set of preimages of a coll. under a gen. mapping
##
InstallGlobalFunction( PreImage, function ( arg )

    local   map,        # gen. mapping <map>, first argument
            img;        # element <img>, second argument

    if Length( arg ) > 0 and not IsGeneralMapping( arg[1] ) then
      ErrorNoReturn( "<map> must be a general mapping" );
    fi;

    # preimage of the range under <map>, which may be a general mapping
    if Length( arg ) = 1  then

        return PreImagesRange( arg[1] );

    elif Length( arg ) = 2 then

        map := arg[1];
        img := arg[2];

        # preimage of a single element <img> under <map>
        if     FamRangeEqFamElm( FamilyObj( map ), FamilyObj( img ) ) then
          if not ( IsInjective( map ) and IsSurjective( map ) ) then
            ErrorNoReturn( "<map> must be an injective and surjective ",
                           "mapping" );
          elif not img in Range( map ) then
            ErrorNoReturn( "<elm> must be an element of Range(<map>)" );
          fi;
          return PreImageElm( map, img );

        # preimage of a collection of elements <img> under <map>
        elif CollFamRangeEqFamElms( FamilyObj( map ), FamilyObj( img ) ) then
          if not IsSubset( Range( map ), img ) then
            ErrorNoReturn( "the collection <elm> must be contained in ",
                           "Range(<map>)" );
          fi;

          if IsDomain( img ) or IsSSortedList( img ) then
            return PreImagesSet( map, img );
          elif IsHomogeneousList( img ) then
            return PreImagesSet( map, Set( img ) );
          fi;

        # preimage of the empty list
        elif IsList( img ) and IsEmpty( img ) then

          return [];

        else
          ErrorNoReturn( "the families of the element or collection <elm> ",
                         "and Range(<map>) don't match, ",
                         "maybe <elm> is not contained in Range(<map>) or ",
                         "is not a homogeneous list or collection" );
        fi;
    fi;
    ErrorNoReturn( "usage: PreImage(<map>), PreImage(<map>,<img>), ",
                   "PreImage(<map>,<coll>)" );
end );


#############################################################################
##
#F  PreImages( <map> )  . . . set of preimages of the range of a gen. mapping
#F  PreImages(<map>,<elm>)  . set of preimages of an elm under a gen. mapping
#F  PreImages(<map>,<coll>)  set of preimages of a coll. under a gen. mapping
##
InstallGlobalFunction( PreImages, function ( arg )

    local   map,        # mapping <map>, first argument
            img;        # element <img>, second argument

    # preimage of the range under <map>
    if Length( arg ) = 1  then

        return PreImagesRange( arg[1] );

    elif Length( arg ) = 2 then

        map := arg[1];
        img := arg[2];

        if not IsGeneralMapping( map ) then
          ErrorNoReturn( "<map> must be a general mapping" );
        fi;

        # preimage of a single element <img> under <map>
        if     FamRangeEqFamElm( FamilyObj( map ), FamilyObj( img ) ) then
            if not img in Range( map ) then
                ErrorNoReturn( "<elm> must be an element of Range(<map>)" );
            fi;
            return PreImagesElm( map, img );

        # preimage of a collection of elements <img> under <map>
        elif CollFamRangeEqFamElms( FamilyObj( map ), FamilyObj( img ) ) then
          if not IsSubset( Range( map ), img ) then
            ErrorNoReturn( "the collection <elm> must be contained in ",
                           "Range(<map>)" );
          fi;

          if IsDomain( img ) or IsSSortedList( img ) then
            return PreImagesSet( map, img );
          elif IsHomogeneousList( img ) then
            return PreImagesSet( map, Set( img ) );
          fi;

        # preimage of the empty list
        elif IsList( img ) and IsEmpty( img ) then

          return [];

        else
          ErrorNoReturn( "the families of the element or collection <elm> ",
                         "and Range(<map>) don't match, ",
                         "maybe <elm> is not contained in Range(<map>) or ",
                         "is not a homogeneous list or collection" );
        fi;
    fi;
    ErrorNoReturn( "usage: PreImages(<map>), PreImages(<map>,<img>), ",
                   "PreImages(<map>,<coll>)" );
end );


#############################################################################
##
#F  CompositionMapping(<map1>,<map2>, ... ) . . . . . composition of mappings
##
InstallGlobalFunction( CompositionMapping, function ( arg )
    local   com,        # composition of the arguments, result
            nxt,        # next general mapping in the composition
            new,        # intermediate composition
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

        nxt:= arg[i];

        # Check that the composition can be formed.
        if not IsGeneralMapping( nxt ) then
          Error( "<i>-th argument must be (general) mapping" );
        elif not FamSource2EqFamRange1( FamilyObj( com ),
                                        FamilyObj( nxt ) ) then
            Error( "the range of <com> and the source of <nxt> ",
                   "must be contained in the same family" );
        fi;

        # Compute the composition.
        new := CompositionMapping2( nxt, com );

        # Maintain properties
        # (Do only *cheap* tests, otherwise one could attempt to check
        # `IsSubset( Source( nxt ), ImagesSource( com ) )' in the case
        # of `IsTotal', and to check in the case of `IsSurjective' whether
        # `IsSubset( Range( com ), PreImagesRange( nxt ) )' holds.)
        if     HasIsSingleValued( com ) and IsSingleValued( com )
           and HasIsSingleValued( nxt ) and IsSingleValued( nxt ) then
          SetIsSingleValued( new, true );
        fi;
        if     HasIsInjective( com ) and IsInjective( com )
           and HasIsInjective( nxt ) and IsInjective( nxt ) then
          SetIsInjective( new, true );
        fi;

        if     HasIsTotal( com ) and IsTotal( com )
           and HasIsTotal( nxt ) and IsTotal( nxt )
           and ((HasImagesSource(com) and
           CanComputeIsSubset(Source(nxt),ImagesSource(com)) and
           IsSubset(Source(nxt),ImagesSource(com)))
           or (HasRange(com) and
           CanComputeIsSubset(Source(nxt),Range(com)) and
           IsSubset(Source(nxt),Range(com))) ) then
          SetIsTotal( new, true );
        fi;

        if  HasRange(com) and  IsIdenticalObj(Source(nxt),Range(com)) then
          if     HasIsTotal( com ) and IsTotal( com )
             and HasIsTotal( nxt ) and IsTotal( nxt ) then
            SetIsTotal( new, true );
          fi;
          if     HasIsSurjective( com ) and IsSurjective( com )
             and HasIsSurjective( nxt ) and IsSurjective( nxt ) then
            SetIsSurjective( new, true );
          fi;
        fi;

        # Maintain respectings.
        if     HasRespectsAddition( com )
           and HasRespectsAddition( nxt )
           and RespectsAddition( com )
           and RespectsAddition( nxt ) then
          SetRespectsAddition( new, true );
        fi;
        if     HasRespectsAdditiveInverses( com )
           and HasRespectsAdditiveInverses( nxt )
           and RespectsAdditiveInverses( com )
           and RespectsAdditiveInverses( nxt ) then
          SetRespectsAdditiveInverses( new, true );
        elif   HasRespectsZero( com )
           and HasRespectsZero( nxt )
           and RespectsZero( com )
           and RespectsZero( nxt ) then
          SetRespectsZero( new, true );
        fi;

        if     HasRespectsMultiplication( com )
           and HasRespectsMultiplication( nxt )
           and RespectsMultiplication( com )
           and RespectsMultiplication( nxt ) then
          SetRespectsMultiplication( new, true );
        fi;
        if     HasRespectsInverses( com )
           and HasRespectsInverses( nxt )
           and RespectsInverses( com )
           and RespectsInverses( nxt ) then
          SetRespectsInverses( new, true );
        elif   HasRespectsOne( com )
           and HasRespectsOne( nxt )
           and RespectsOne( com )
           and RespectsOne( nxt ) then
          SetRespectsOne( new, true );
        fi;

        if     IsIdenticalObj( Source( nxt ), Range( com ) )
           and HasRespectsScalarMultiplication( com )
           and HasRespectsScalarMultiplication( nxt )
           and RespectsScalarMultiplication( com )
           and RespectsScalarMultiplication( nxt ) then

          # Note that equality of the two relevant domains
          # does in general not suffice to get linearity,
          # since their left acting domains must fit, too.
          SetRespectsScalarMultiplication( new, true );

        fi;

        com:= new;

    od;

    if IsIdenticalObj( Source( com ), Range( com ) ) then
      SetIsEndoGeneralMapping( com, true );
    fi;

    # Return the composition.
    return com;
end );


# Temporarily disabled -- See #569
# Currently some group homomrophisms construct inverse maps that are really
# restricted inverses (i.e. defined only on the image). Together with these
# immediate methods this can cause wrong indications of IsSurjective etc.
# for these maps. While this needs to be fixed in the future properly, the
# immediate methods are temporarily disabled to avoid this error having
# further effects.
# #############################################################################
# ##
# #M  IsInjective( <map> )  . . . . . for gen. mapp. with known inv. gen. mapp.
# #M  IsSingleValued( <map> ) . . . . for gen. mapp. with known inv. gen. mapp.
# #M  IsSurjective( <map> ) . . . . . for gen. mapp. with known inv. gen. mapp.
# #M  IsTotal( <map> )  . . . . . . . for gen. mapp. with known inv. gen. mapp.
# ##
# InstallImmediateMethod( IsInjective,
#     IsGeneralMapping and HasInverseGeneralMapping, 0,
#     function( map )
#     map:= InverseGeneralMapping( map );
#     if HasIsSingleValued( map ) then
#       return IsSingleValued( map );
#     else
#       TryNextMethod();
#     fi;
#     end );
#
# InstallImmediateMethod( IsSingleValued,
#     IsGeneralMapping and HasInverseGeneralMapping, 0,
#     function( map )
#     map:= InverseGeneralMapping( map );
#     if HasIsInjective( map ) then
#       return IsInjective( map );
#     else
#       TryNextMethod();
#     fi;
#     end );
#
# InstallImmediateMethod( IsSurjective,
#     IsGeneralMapping and HasInverseGeneralMapping, 0,
#     function( map )
#     map:= InverseGeneralMapping( map );
#     if HasIsTotal( map ) then
#       return IsTotal( map );
#     else
#       TryNextMethod();
#     fi;
#     end );
#
# InstallImmediateMethod( IsTotal,
#     IsGeneralMapping and HasInverseGeneralMapping, 0,
#     function( map )
#     map:= InverseGeneralMapping( map );
#     if HasIsSurjective( map ) then
#       return IsSurjective( map );
#     else
#       TryNextMethod();
#     fi;
#     end );

#############################################################################
##
#M  IsTotal( <map> )  . . . . . . . . . . . . . . . . . . for general mapping
##
InstallMethod( IsTotal, "for a general mapping", true,
    [ IsGeneralMapping ], 0,
    function( map )

    # For a total and injective general mapping,
    # the range cannot be smaller than the source.

    if     HasIsInjective( map ) and IsInjective( map )
       and CanComputeSize(Range(map)) and CanComputeSize(Source(map))
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
InstallMethod( IsSurjective, "for a general mapping", true,
    [ IsGeneralMapping ], 0,
    function( map )

    # For a single-valued and surjective general mapping,
    # the source cannot be smaller than the range.

    if     HasIsSingleValued( map ) and IsSingleValued( map )
       and CanComputeSize(Range(map)) and CanComputeSize(Source(map))
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
InstallMethod( IsSingleValued, "for a general mapping", true,
    [ IsGeneralMapping ], 0,
    function( map )

    if HasIsSurjective( map ) and IsSurjective( map )
       and CanComputeSize(Range(map)) and CanComputeSize(Source(map)) then

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
InstallMethod( IsInjective, "for a general mapping", true,
    [ IsGeneralMapping ], 0,
    function( map )

    local enum,    # enumerator for the source
          imgs,    # list of images for the elements of the source
          elm,     # loop over `enum'
          img;     # one set of images

    if HasIsTotal( map ) and IsTotal( map ) then

      # For a total and injective general mapping,
      # the source cannot be larger than the range.
      if Size( Range( map ) ) < Size( Source( map ) )
       and CanComputeSize(Range(map)) and CanComputeSize(Source(map)) then
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
InstallMethod( IsInjective, "for a mapping", true,
    [ IsGeneralMapping and IsTotal and IsSingleValued ], 0,
    function( map )

    # For a total and injective general mapping,
    # the source cannot be larger than the range.
    if Size( Range( map ) ) < Size( Source( map ) )
       and CanComputeSize(Range(map)) and CanComputeSize(Source(map)) then
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
    "for two general mappings",
    IsIdenticalObj,
    [ IsGeneralMapping, IsGeneralMapping ], 0,
    function( map1, map2 )

    # Maybe the properties we already know determine the result.
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

    # Otherwise we must really test the equality.
    return     Source( map1 )             = Source( map2 )
           and Range( map1 )              = Range( map2 )
           and UnderlyingRelation( map1 ) = UnderlyingRelation( map2 );
    end );


#############################################################################
##
#M  \<( <map1>, <map2> )  . . . . . . . . . . . . .  for two general mappings
##
##  Compare the sources, the ranges, the underlying relation.
##
InstallMethod( \<,
    "for two general mappings",
    IsIdenticalObj,
    [ IsGeneralMapping, IsGeneralMapping ], 0,
    function( map1, map2 )
    if Source( map1 ) <> Source( map2 ) then
      return Source( map1 ) < Source( map2 );
    elif Range( map1 ) <> Range( map2 ) then
      return Range( map1 ) < Range( map2 );
    else
      return UnderlyingRelation( map1 ) < UnderlyingRelation( map2 );
    fi;
    end );


#############################################################################
##
#M  \+( <map>, <zero> ) . . . . . . . .  for general mapping and zero mapping
##
InstallOtherMethod( \+,
    "for general mapping and zero mapping",
    IsIdenticalObj,
    [ IsGeneralMapping, IsGeneralMapping and IsZero ], 0,
    ReturnFirst );


#############################################################################
##
#M  \+( <zero>, <map> ) . . . . . . . .  for zero mapping and general mapping
##
InstallOtherMethod( \+,
    "for zero mapping and general mapping",
    IsIdenticalObj,
    [ IsGeneralMapping and IsZero, IsGeneralMapping ], 0,
    function( zero, map )
    return map;
    end );


#############################################################################
##
#M  \*( <map1>, <map2> )  . . . . . . . . . . . . .  for two general mappings
##
InstallMethod( \*, "for two general mappings", FamSource2EqFamRange1,
    [ IsGeneralMapping, IsGeneralMapping ], 0,
function( map1, map2 )
  return CompositionMapping( map2, map1 );
end );


#############################################################################
##
#M  \^( <map1>, <map2> )  . . . . . . . . conjugation of two general mappings
##
InstallMethod( \^,
#T or shall this involve the usual inverse?
#T (then <map2> must be a bijection from its source to its source)
    "for two general mappings",
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
    "for element in the source, and general mapping",
    FamElmEqFamSource,
    [ IsObject, IsGeneralMapping ], 0,
    function( elm, map )
    return ImageElm( map, elm );
    end );


#############################################################################
##
#M  OneOp( <map> )  . . . . . . . . . . . . . . . . . . . .  identity mapping
##
InstallOtherMethod( OneOp,
    "for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    if IsEndoGeneralMapping( map ) then
      return IdentityMapping( Source( map ) );
    else
      return fail;
    fi;
    end );


#############################################################################
##
#M  ZeroOp( <map> ) . . . . . . . . . . . . . . . . . . . . . .  zero mapping
##
InstallOtherMethod( ZeroOp,
    "for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    map -> ZeroMapping( Source( map ), Range( map ) ) );


#############################################################################
##
#M  InverseOp( <map> )  . . . . . . . . . delegate to `InverseGeneralMapping'
##
InstallMethod( InverseOp,
    "for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    local inv;
    if IsEndoGeneralMapping( map ) and IsBijective( map ) then
      inv := InverseGeneralMapping( map );
      SetIsEndoGeneralMapping( inv, true );
      SetIsBijective (inv, true); # this may seem superfluous, but
           # IsInjective may create an InverseGeneralMapping which does not
           # know that it is bijective
      return inv;
    else
      Info(InfoWarning,1,
        "The mapping must be bijective and have source=range\n",
        "#I  You might want to use `InverseGeneralMapping'");
      return fail;
    fi;
    end );


#############################################################################
##
#M  \*( <zero>, <map> ) . . . . . . . . .  for zero and total general mapping
##
InstallMethod( \*,
    "for zero and total general mapping",
    FamElmEqFamRange,
    [ IsRingElement and IsZero, IsGeneralMapping and IsTotal ], 0,
    function( zero, map )
    if IsGeneralMapping( zero ) then
      TryNextMethod();
    else
      return ZeroMapping( Source( map ), Range( map ) );
    fi;
    end );


#############################################################################
##
#M  <elm> / <map> . . . . . . . . . . . . . . . . . . . . preimage of element
##
InstallOtherMethod( \/,
    "for element, and inj. & surj. general mapping",
    FamElmEqFamRange,
    [ IsObject, IsGeneralMapping and IsInjective and IsSurjective ], 0,
    function( elm, map )
    return PreImageElm( map, elm );
    end );


#############################################################################
##
#M  ImageElm( <map>, <elm> )  . . . . . . . . . . . . for mapping and element
##
InstallOtherMethod( ImageElm,
    "for general mapping, and element",
    FamSourceEqFamElm,
    [ IsGeneralMapping, IsObject ], 0,
    function( map, elm )
    if not ( IsSingleValued( map ) and IsTotal( map ) ) then
      Error( "<map> must be single-valued and total" );
    fi;
    return ImageElm( map, elm );
    end );


InstallMethod( ImageElm,
    "for mapping, and element",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsTotal and IsSingleValued, IsObject ], 0,
    ImagesRepresentative );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . . .  for non s.p. general mapping and element
##
InstallMethod( ImagesElm,
    "for non s.p. general mapping, and element",
    FamSourceEqFamElm,
    [ IsNonSPGeneralMapping, IsObject ], 0,
    function( map, elm )
    Error( "no default function to compute images of <elm> under <map>" );
    end );


#############################################################################
##
#M  ImagesElm( <map>, <elm> ) . .  for const. time access gen. map., and elm.
##
InstallMethod( ImagesElm,
    "for constant time access general mapping, and element",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsConstantTimeAccessGeneralMapping, IsObject ], 0,
    function( map, elm )
    local imgs, pair;
    imgs:= [];
    for pair in GeneratorsOfDomain( UnderlyingRelation( map ) ) do
      if pair[1] = elm then
        AddSet( imgs, pair[2] );
      fi;
    od;
    return imgs;
    end );


#############################################################################
##
#M  ImagesSet( <map>, <elms> )  . . for generel mapping and finite collection
##
InstallMethod( ImagesSet,
    "for general mapping, and finite collection",
    CollFamSourceEqFamElms,
    [ IsGeneralMapping, IsCollection ], 0,
    function( map, elms )
    local imgs, elm;
    if not IsFinite( elms ) then
      TryNextMethod();
    fi;
    imgs:= [];
    for elm in Enumerator( elms ) do
      UniteSet( imgs, AsList( ImagesElm( map, elm ) ) );
    od;
    return imgs;
    end );

InstallMethod( ImagesSet,
    "for general mapping, and empty list",
    true,
    [ IsGeneralMapping, IsList and IsEmpty ], 0,
    function( map, elms )
    return [];
    end );


#############################################################################
##
#M  ImagesSource( <map> ) . . . . . . . . . . . . . . . . for general mapping
##
InstallMethod( ImagesSource,
    "for general mapping",
    true,
    [ IsGeneralMapping ], 0,
    map -> ImagesSet( map, Source( map ) ) );


#############################################################################
##
#M  ImagesSource( <map> ) . . . . . . . . . .  for surjective general mapping
##
InstallMethod( ImagesSource,
    "for surjective general mapping (delegate to `Range')",
    true,
    [ IsGeneralMapping and IsSurjective ],
    SUM_FLAGS, # immediately delegate, don;'t try anything else
    Range );


#############################################################################
##
#M  ImagesRepresentative( <map>, <elm> )  . . . for s.p. gen. mapping and elm
##
InstallMethod( ImagesRepresentative,
    "for s.p. general mapping, and element",
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
    "for non s.p. general mapping, and element",
    FamSourceEqFamElm,
    [ IsNonSPGeneralMapping, IsObject ], 0,
    function( map, elm )
    local
            imgs;       # all images of <elm> under <map>

    # get all images of <elm> under <map>
    imgs:= ImagesElm( map, elm );

    # check that <elm> has at least one image under <map>
    if IsEmpty( imgs ) then
      return fail;
    fi;

    # pick one image, and return it
    return Representative( imgs );
    end );


#############################################################################
##
#M  PreImageElm( <map>, <elm> )
##
InstallOtherMethod( PreImageElm,
    "for general mapping, and element",
    FamRangeEqFamElm,
    [ IsGeneralMapping, IsObject ], 0,
    function( map, elm )
    if not ( IsInjective( map ) and IsSurjective( map ) ) then
      Error( "<map> must be injective and surjective" );
    fi;
    return PreImageElm( map, elm );
    end );

InstallMethod( PreImageElm,
    "for inj. & surj. general mapping, and element",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsInjective and IsSurjective, IsObject ], 0,
    PreImagesRepresentative );


#############################################################################
##
#M  PreImagesElm( <map>, <elm> )  . . . . . . for general mapping and element
##
##  more or less delegate to `ImagesElm'
##
InstallMethod( PreImagesElm,
    "for general mapping with finite source, and element",
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
#M  PreImagesElm( <map>, <elm> )   for const. time access gen. map., and elm.
##
InstallMethod( PreImagesElm,
    "for constant time access general mapping, and element",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsConstantTimeAccessGeneralMapping, IsObject ], 0,
    function( map, elm )
    local preimgs, pair;
    preimgs:= [];
    for pair in GeneratorsOfDomain( UnderlyingRelation( map ) ) do
      if pair[2] = elm then
        AddSet( preimgs, pair[1] );
      fi;
    od;
    return preimgs;
    end );


#############################################################################
##
#M  PreImagesSet( <map>, <elms> ) . for general mapping and finite collection
##
InstallMethod( PreImagesSet,
    "for general mapping, and finite collection",
    CollFamRangeEqFamElms,
    [ IsGeneralMapping, IsCollection ], 0,
    function( map, elms )
    local primgs, elm;
    if not IsFinite( elms ) then
      TryNextMethod();
    fi;
    primgs:= [];
    for elm in Enumerator( elms ) do
      UniteSet( primgs, AsList( PreImagesElm( map, elm ) ) );
    od;
    return primgs;
    end );

InstallMethod( PreImagesSet,
    "for general mapping, and empty list",
    true,
    [ IsGeneralMapping, IsList and IsEmpty ], 0,
    function( map, elms )
    return [];
    end );


#############################################################################
##
#M  PreImagesRange( <map> ) . . . . . . . . . . . . . . . for general mapping
##
InstallMethod( PreImagesRange,
    "for general mapping",
    true,
    [ IsGeneralMapping ], 0,
    map -> PreImagesSet( map, Range( map ) ) );


#############################################################################
##
#M  PreImagesRange( <map> ) . . . . . . . . . . . . for total general mapping
##
InstallMethod( PreImagesRange,
    "for total general mapping (delegate to `Source')",
    true,
    [ IsGeneralMapping and IsTotal ],
    SUM_FLAGS, # immediately delegate, don't try anything else
    Source );


#############################################################################
##
#M  PreImagesRepresentative( <map>, <elm> )  . .  for s.p. gen. mapping & elm
##
InstallMethod( PreImagesRepresentative,
    "for s.p. general mapping, and element",
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
    "for total non-s.p. general mapping, and element",
    FamRangeEqFamElm,
    [ IsNonSPGeneralMapping, IsObject ], 0,
    function ( map, elm )
    local   pres;       # all preimages of <elm> under <map>

    # get all preimages of <elm> under <map>
    pres := PreImagesElm( map, elm );

    # check that <elm> has at least one preimage under <map>
    if IsEmpty( pres ) then
      return fail;
    fi;

    # pick one preimage, and return it.
    return Representative( pres );
    end );


#############################################################################
##
#F  GeneralMappingByElements( <S>, <R>, <elms> )
##
InstallGlobalFunction( GeneralMappingByElements, function( S, R, elms )
    local map, tupfam, rel;

    # Check the arguments.
    if   not ( IsDomain( S ) and IsDomain( R ) ) then

      Error( "<S> and <R> must be domains" );

    elif IsDirectProductElementCollection( elms ) then

      tupfam:= ElementsFamily( FamilyObj( elms ) );
      if not (  IsIdenticalObj( ElementsFamily( FamilyObj( S ) ),
                          ComponentsOfDirectProductElementsFamily( tupfam )[1] )
         and IsIdenticalObj( ElementsFamily( FamilyObj( R ) ),
                          ComponentsOfDirectProductElementsFamily( tupfam )[2] ) ) then
        Error( "families of arguments do not match" );
      fi;

    elif IsEmpty( elms ) then

      tupfam:= DirectProductElementsFamily( [ ElementsFamily( FamilyObj( S ) ),
                               ElementsFamily( FamilyObj( R ) ) ] );

    else
      Error( "<elms> must be a collection of direct product elements or empty" );
    fi;

    # Construct the general mapping.
    map:= Objectify( TypeOfDefaultGeneralMapping( S, R,
                             IsNonSPGeneralMapping
                         and IsAttributeStoringRep ),
                     rec() );

    # Construct the underlying relation.
    rel:= DomainByGenerators( tupfam, elms );
    SetUnderlyingRelation( map, rel );
    SetUnderlyingGeneralMapping( rel, map );

    # Return the general mapping.
    return map;
end );


#############################################################################
##
#M  UnderlyingRelation( <map> ) . . . . . . . . . . . . for a general mapping
##
InstallMethod( UnderlyingRelation,
    "for a general mapping",
    true,
    [ IsGeneralMapping ], 0,
    function( map )
    local type, rel;
    type:= NewType( DirectProductFamily( [ FamilyObj( Source( map ) ),
                                           FamilyObj( Range( map ) ) ] ),
                    IsDomain and IsAttributeStoringRep );
    rel:= Objectify( type, rec() );
    SetUnderlyingGeneralMapping( rel, map );
    return rel;
    end );


#############################################################################
##
#M  SetUnderlyingGeneralMapping( <rel>, <map> )
##
##  Make sure that <map> gets the flag `IsConstantTimeAccessGeneralMapping'
##  if <rel> knows its `AsList'.
##  (Note that if `AsList( <rel> )' is known at the time when <rel> is
##  constructed, we cannot use the setter method of `AsList' for domains
##  with known `UnderlyingGeneralMapping'.)
##
InstallMethod( SetUnderlyingGeneralMapping,
    "for an underlying relation and a general mapping",
    true,
    [ IsDomain and IsDirectProductElementCollection and HasAsList
      and IsAttributeStoringRep,
      IsGeneralMapping ], 0,
    function( rel, map )
    SetIsConstantTimeAccessGeneralMapping( map, true );
    TryNextMethod();
    end );

InstallMethod( SetUnderlyingGeneralMapping,
    "for an underlying relation and a general mapping",
    true,
    [ IsDomain and IsDirectProductElementCollection and HasGeneratorsOfDomain
      and IsAttributeStoringRep,
      IsGeneralMapping ], 0,
    function( rel, map )
    SetIsConstantTimeAccessGeneralMapping( map, true );
    TryNextMethod();
    end );


#############################################################################
##
#M  SetAsList( <rel>, <dpelms> )
#M  SetGeneratorsOfDomain( <rel>, <dpelms> )
##
##  Make sure that <map> gets the flag `IsConstantTimeAccessGeneralMapping'
##  if <rel> knows its `AsList' or `GeneratorsOfDomain' value,
##  where <map> is the underlying general mapping of <rel>.
##
InstallMethod( SetAsList,
    "for an underlying relation and a list of direct product elements",
    IsIdenticalObj,
    [ IsDomain and IsDirectProductElementCollection and HasUnderlyingGeneralMapping
      and IsAttributeStoringRep,
      IsDirectProductElementCollection ],
    function( rel, dpelms )
    SetIsConstantTimeAccessGeneralMapping( UnderlyingGeneralMapping( rel ),
        true );
    TryNextMethod();
    end );

InstallMethod( SetGeneratorsOfDomain,
    "for an underlying relation and a list of direct product elements",
    IsIdenticalObj,
    [ IsDomain and IsDirectProductElementCollection and HasUnderlyingGeneralMapping
      and IsAttributeStoringRep,
      IsDirectProductElementCollection ],
    function( rel, dpelms )
    SetIsConstantTimeAccessGeneralMapping( UnderlyingGeneralMapping( rel ),
        true );
    TryNextMethod();
    end );


#############################################################################
##
##  3. generic methods for underlying relations of general mappings
##
##  If the underlying relation $Rel$ of a general mapping $F$ stores $F$
##  as value of `UnderlyingGeneralMapping' then $Rel$ may delegate questions
##  to the mapping operations for $F$.
##


#############################################################################
##
#M  \=( <rel1>, <rel2> )  .  for underlying relations of two general mappings
##
InstallMethod( \=,
    "for two underlying relations of general mappings",
    IsIdenticalObj,
    [ IsDomain and IsDirectProductElementCollection and HasUnderlyingGeneralMapping,
      IsDomain and IsDirectProductElementCollection and HasUnderlyingGeneralMapping ], 0,
    function( rel1, rel2 )
    local map1, map2;
    map1:= UnderlyingGeneralMapping( rel1 );
    map2:= UnderlyingGeneralMapping( rel2 );

    # Check that the sets of first resp. second components agree.
    if    PreImagesRange( map1 ) <> PreImagesRange( map2 )
       or ImagesSource( map1 ) <> ImagesSource( map2 ) then
      return false;
    fi;

    # Really test the equality.
    if   IsFinite( PreImagesRange( map1 ) ) then
      return ForAll( PreImagesRange( map1 ),
                   elm -> ImagesElm( map1, elm ) = ImagesElm( map2, elm ) );
    elif IsFinite( PreImagesRange( map2 ) ) then
      return ForAll( PreImagesRange( map2 ),
                   elm -> ImagesElm( map1, elm ) = ImagesElm( map2, elm ) );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  \<( <rel1>, <rel> )  .  for underlying relations of two general mappings
##
InstallMethod( \<,
    "for two underlying relations of general mappings",
    IsIdenticalObj,
    [ IsDomain and IsDirectProductElementCollection and HasUnderlyingGeneralMapping,
      IsDomain and IsDirectProductElementCollection and HasUnderlyingGeneralMapping ], 0,
    function( rel1, rel2 )
    local map1,       # first general mapping,
          map2,       # second general mapping,
          elms,       # elements of the source of <map1> and <map2>
          i;          # loop variable

    map1:= UnderlyingGeneralMapping( rel1 );
    map2:= UnderlyingGeneralMapping( rel2 );

    # find the first element where the images differ
    elms := EnumeratorSorted( Union(PreImagesRange(map1),PreImagesRange(map2)));
    i := 1;
    while i <= Length( elms )
          and ImagesElm( map1, elms[i] ) = ImagesElm( map2, elms[i] )  do
      i := i + 1;
    od;

    # compare the image sets
    return     i <= Length( elms )
           and   EnumeratorSorted( ImagesElm( map1, elms[i] ) )
               < EnumeratorSorted( ImagesElm( map2, elms[i] ) );
#T note that we do not have a generic `\<' method for domains !
    end );



#############################################################################
##
#M  IsFinite( <rel> ) . . . . .  for underlying relation of a general mapping
##
InstallMethod( IsFinite,
    "for an underlying relation of a general mapping",
    true,
    [ IsDomain and IsDirectProductElementCollection and HasUnderlyingGeneralMapping ], 0,
    function( rel )
    local map;
    map:= UnderlyingGeneralMapping( rel );
    if IsFinite( Source( map ) ) and IsFinite( Range( map ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Enumerator( <rel> ) . . . .  for underlying relation of a general mapping
##
InstallMethod( Enumerator,
    "for an underlying relation of a general mapping",
    true,
    [ IsDomain and IsDirectProductElementCollection and HasUnderlyingGeneralMapping ], 0,
    function( rel )
    local map, enum, S, R, elm, imgs;
    map:= UnderlyingGeneralMapping( rel );
    enum:= [];
    S:= Source( map );
    R:= Range( map );
    if   IsFinite( S ) then
      for elm in Enumerator( S ) do
        imgs:= ImagesElm( map, elm );
        if IsFinite( imgs ) then
          UniteSet( enum, List( imgs, im -> DirectProductElement( [ elm, im ] ) ) );
        else
          TryNextMethod();
        fi;
      od;
      return enum;
    elif IsFinite( R ) then
      for elm in Enumerator( R ) do
        imgs:= PreImagesElm( map, elm );
        if IsFinite( imgs ) then
          UniteSet( enum, List( imgs, im -> DirectProductElement( [ im, elm ] ) ) );
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
#M  \in( <dpelm>, <map> ) . . . . . . for elm and underl. rel. of a gen. map.
##
InstallMethod( \in,
    "for an element and an underlying relation of a general mapping",
    IsElmsColls,
    [ IsDirectProductElement,
      IsDomain and IsDirectProductElementCollection and HasUnderlyingGeneralMapping ], 0,
    function( elm, rel )
    return elm[2] in ImagesElm( UnderlyingGeneralMapping( rel ), elm[1] );
    end );


#############################################################################
##
#M  Size( <rel> ) . . . . . . .  for underlying relation of a general mapping
##
InstallMethod( Size,
    "for an underlying relation of a general mapping",
    [ IsDomain and IsDirectProductElementCollection and HasUnderlyingGeneralMapping ],
    function( rel )
    local map;
    map:= UnderlyingGeneralMapping( rel );
    if     HasIsTotal( map ) and HasIsSingleValued( map )
       and IsTotal( map ) and IsSingleValued( map ) then
      return Size( Source( map ) );
    elif   HasIsInjective( map ) and HasIsSurjective( map )
       and IsInjective( map ) and IsSurjective( map ) then
      return Size( Range( map ) );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsGeneratorsOfMagmaWithInverses( <mappinglist> )
##
##  All members of the collection have same source, all have same range.
##  Check that all are invertible.
##
InstallMethod( IsGeneratorsOfMagmaWithInverses,
    "for a collection of general mappings",
    true,
    [ IsGeneralMappingCollection ], 0,
    mappinglist -> ForAll( mappinglist, map ->
    (HasIsBijective(map) and IsBijective(map)) or Inverse( map ) <> fail ) );

#############################################################################
##
#M  CopyMappingAttributes(<from>,<to>)
##
InstallGlobalFunction(CopyMappingAttributes,
function(f,t)
  if HasIsTotal(f) and not HasIsTotal(t) then
    SetIsTotal(t,IsTotal(f));
  fi;
  if HasIsSingleValued(f) and not HasIsSingleValued(t) then
    SetIsSingleValued(t,IsSingleValued(f));
  fi;
  if HasIsInjective(f) and not HasIsInjective(t) then
    SetIsInjective(t,IsInjective(f));
  fi;
  if HasIsSurjective(f) and not HasIsSurjective(t) then
    SetIsSurjective(t,IsSurjective(f));
  fi;
  if HasSource(f) and not HasSource(t) then
    SetSource(t,Source(f));
  fi;
  if HasImagesSource(f) and not HasImagesSource(t) then
    SetImagesSource(t,ImagesSource(f));
  fi;
  if HasRange(f) and not HasRange(t) then
    SetRange(t,Range(f));
  fi;
end);
